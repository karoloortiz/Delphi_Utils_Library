{
  KLib Version = 4.0
  The Clear BSD License

  Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
  zitrokarol@gmail.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted (subject to the limitations in the disclaimer
  below) provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
  THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
}

unit KLib.Logger;

//  Winston-like logger:
//  - TLogger dispatches every entry to its transports (file, callback, custom)
//  - levels filter both on the logger and on each transport
//  - createChild shares the transports and tags the entries with a category
//  - TFileLogTransport writes one file per day (open-append-close on every entry, so nothing
//    stays open and nothing is lost on crash) and deletes the files older than retentionDays
//  - a failing transport never raises to the caller and never blocks the other transports
//
//  Example:
//    _settings.clear;
//    _settings.dirName := 'C:\app\log';
//    _settings.retentionDays := 60;
//    logger := TLogger.Create(logInfo);
//    logger.addTransport(TFileLogTransport.Create(_settings));
//    logger.info('started');
//    rmaLogger := logger.createChild('RMA');
//    rmaLogger.error('import failed', e);

interface

uses
  System.SysUtils, System.SyncObjs;

type
  TLogLevel = (logDebug, logInfo, logWarning, logError);

  TLogEntry = record
    timestamp: TDateTime;
    level: TLogLevel;
    category: string;
    message: string;
  end;

  TLogFormatter = reference to function(entry: TLogEntry): string;
  TLogCallback = reference to procedure(entry: TLogEntry; formattedText: string);

  ILogTransport = interface
    ['{C07476E4-BEC1-442A-8088-E60DBA802B9D}']
    procedure write(entry: TLogEntry);
  end;

  TLogTransport = class(TInterfacedObject, ILogTransport)
  private
    _lock: TCriticalSection;
  protected
    procedure writeFormattedText(entry: TLogEntry; formattedText: string); virtual; abstract;
  public
    level: TLogLevel;
    formatter: TLogFormatter;

    constructor Create(level: TLogLevel = logDebug);
    procedure write(entry: TLogEntry);
    destructor Destroy; override;
  end;

  TFileLogTransportSettings = record
    dirName: string;
    fileNamePrefix: string;
    dateFormat: string;
    fileExtension: string;
    retentionDays: Integer; // 0 = never delete
    level: TLogLevel;

    procedure clear;
  end;

  TFileLogTransport = class(TLogTransport)
  private
    _settings: TFileLogTransportSettings;
    _currentDate: TDate;
    procedure rotateIfDateIsChanged(date: TDate);
    procedure deleteExpiredFiles;
    procedure appendToLogFile(fileName: string; text: string);
    procedure appendToFile(fileName: string; text: string);
  protected
    procedure writeFormattedText(entry: TLogEntry; formattedText: string); override;
  public
    constructor Create(settings: TFileLogTransportSettings);
    function getFileName(date: TDate): string;
  end;

  TCallbackLogTransport = class(TLogTransport)
  private
    _callback: TLogCallback;
  protected
    procedure writeFormattedText(entry: TLogEntry; formattedText: string); override;
  public
    constructor Create(callback: TLogCallback; level: TLogLevel = logDebug);
  end;

  TLogger = class
  private
    _transports: TArray<ILogTransport>;
    _category: string;
  public
    level: TLogLevel;

    constructor Create(level: TLogLevel = logDebug);
    procedure addTransport(transport: ILogTransport);
    function createChild(category: string): TLogger;
    procedure log(level: TLogLevel; message: string);
    procedure debug(message: string);
    procedure info(message: string);
    procedure warning(message: string);
    procedure error(message: string); overload;
    procedure error(message: string; e: Exception); overload;
  end;

function getDefaultLogFormat(entry: TLogEntry): string;
function getLogLevelAsString(level: TLogLevel): string;

implementation

uses
  KLib.Constants,
  System.Classes, System.IOUtils, System.DateUtils;

const
  LOG_TIMESTAMP_FORMAT = 'yyyy-mm-dd hh:nn:ss.zzz';
  MAX_WRITE_ATTEMPTS = 3;
  WRITE_RETRY_DELAY_MS = 50;

//############################----TLogTransport----##################################

constructor TLogTransport.Create(level: TLogLevel = logDebug);
begin
  inherited Create;
  Self.level := level;
  Self.formatter := getDefaultLogFormat;
  _lock := TCriticalSection.Create;
end;

procedure TLogTransport.write(entry: TLogEntry);
var
  _formattedText: string;
begin
  if entry.level >= level then
  begin
    _formattedText := formatter(entry);
    _lock.Enter;
    try
      writeFormattedText(entry, _formattedText);
    finally
      _lock.Leave;
    end;
  end;
end;

destructor TLogTransport.Destroy;
begin
  FreeAndNil(_lock);
  inherited;
end;

//############################----TFileLogTransport----##################################

procedure TFileLogTransportSettings.clear;
begin
  Self.dirName := EMPTY_STRING;
  Self.fileNamePrefix := 'log_';
  Self.dateFormat := 'yyyy_mm_dd';
  Self.fileExtension := '.log';
  Self.retentionDays := 0;
  Self.level := logDebug;
end;

constructor TFileLogTransport.Create(settings: TFileLogTransportSettings);
const
  ERR_MSG = 'TFileLogTransport: dirName is empty.';
begin
  if settings.dirName = EMPTY_STRING then
  begin
    raise Exception.Create(ERR_MSG);
  end;

  inherited Create(settings.level);
  _settings := settings;
  _currentDate := 0;
end;

function TFileLogTransport.getFileName(date: TDate): string;
var
  _fileName: string;
begin
  _fileName := TPath.Combine(_settings.dirName,
    _settings.fileNamePrefix + FormatDateTime(_settings.dateFormat, date) + _settings.fileExtension);

  Result := _fileName;
end;

procedure TFileLogTransport.writeFormattedText(entry: TLogEntry; formattedText: string);
var
  _date: TDate;
begin
  _date := DateOf(entry.timestamp);
  rotateIfDateIsChanged(_date);
  appendToLogFile(getFileName(_date), formattedText + sLineBreak);
end;

procedure TFileLogTransport.rotateIfDateIsChanged(date: TDate);
begin
  if date <> _currentDate then
  begin
    _currentDate := date;
    ForceDirectories(_settings.dirName);
    if _settings.retentionDays > 0 then
    begin
      deleteExpiredFiles;
    end;
  end;
end;

procedure TFileLogTransport.deleteExpiredFiles;
var
  _expirationDate: TDate;
  _fileName: string;
begin
  _expirationDate := IncDay(_currentDate, -_settings.retentionDays);
  for _fileName in TDirectory.GetFiles(_settings.dirName,
    _settings.fileNamePrefix + '*' + _settings.fileExtension) do
  begin
    // best effort: a locked or protected file must not stop the logging
    try
      if DateOf(TFile.GetLastWriteTime(_fileName)) < _expirationDate then
      begin
        TFile.Delete(_fileName);
      end;
    except
    end;
  end;
end;

procedure TFileLogTransport.appendToLogFile(fileName: string; text: string);
const
  ERR_MSG = 'TFileLogTransport: unable to write ';
var
  _attempt: Integer;
  _isWritten: boolean;
  _errorMessage: string;
begin
  _attempt := 0;
  _isWritten := false;
  _errorMessage := EMPTY_STRING;
  // retries cover the file being briefly locked by another process (antivirus, editor, backup)
  while (not _isWritten) and (_attempt < MAX_WRITE_ATTEMPTS) do
  begin
    Inc(_attempt);
    try
      appendToFile(fileName, text);
      _isWritten := true;
    except
      on e: Exception do
      begin
        _errorMessage := e.Message;
        if _attempt < MAX_WRITE_ATTEMPTS then
        begin
          Sleep(WRITE_RETRY_DELAY_MS);
        end;
      end;
    end;
  end;

  if not _isWritten then
  begin
    raise Exception.Create(ERR_MSG + fileName + ': ' + _errorMessage);
  end;
end;

procedure TFileLogTransport.appendToFile(fileName: string; text: string);
var
  _stream: TFileStream;
  _bytes: TBytes;
begin
  if TFile.Exists(fileName) then
  begin
    _stream := TFileStream.Create(fileName, fmOpenWrite or fmShareDenyWrite);
  end
  else
  begin
    _stream := TFileStream.Create(fileName, fmCreate or fmShareDenyWrite);
  end;
  try
    _stream.Seek(0, soEnd);
    // UTF-8 without BOM: TEncoding.GetBytes never adds the preamble
    _bytes := TEncoding.UTF8.GetBytes(text);
    _stream.WriteBuffer(_bytes, Length(_bytes));
  finally
    FreeAndNil(_stream);
  end;
end;

//############################----TCallbackLogTransport----##################################

constructor TCallbackLogTransport.Create(callback: TLogCallback; level: TLogLevel = logDebug);
begin
  inherited Create(level);
  _callback := callback;
end;

procedure TCallbackLogTransport.writeFormattedText(entry: TLogEntry; formattedText: string);
begin
  _callback(entry, formattedText);
end;

//############################----TLogger----##################################

constructor TLogger.Create(level: TLogLevel = logDebug);
begin
  inherited Create;
  Self.level := level;
  _transports := nil;
  _category := EMPTY_STRING;
end;

procedure TLogger.addTransport(transport: ILogTransport);
begin
  _transports := _transports + [transport];
end;

function TLogger.createChild(category: string): TLogger;
var
  _child: TLogger;
begin
  _child := TLogger.Create(level);
  _child._transports := Copy(_transports);
  _child._category := category;

  Result := _child;
end;

procedure TLogger.log(level: TLogLevel; message: string);
var
  _entry: TLogEntry;
  _transport: ILogTransport;
begin
  if level >= Self.level then
  begin
    _entry.timestamp := Now;
    _entry.level := level;
    _entry.category := _category;
    _entry.message := message;
    for _transport in _transports do
    begin
      // a failing transport must never break the caller or the other transports
      try
        _transport.write(_entry);
      except
      end;
    end;
  end;
end;

procedure TLogger.debug(message: string);
begin
  log(logDebug, message);
end;

procedure TLogger.info(message: string);
begin
  log(logInfo, message);
end;

procedure TLogger.warning(message: string);
begin
  log(logWarning, message);
end;

procedure TLogger.error(message: string);
begin
  log(logError, message);
end;

procedure TLogger.error(message: string; e: Exception);
begin
  log(logError, message + ': ' + e.ClassName + ' - ' + e.Message);
end;

//############################----functions----##################################

function getDefaultLogFormat(entry: TLogEntry): string;
var
  _text: string;
begin
  _text := FormatDateTime(LOG_TIMESTAMP_FORMAT, entry.timestamp) +
    ' [' + Format('%-7s', [getLogLevelAsString(entry.level)]) + ']';
  if entry.category <> EMPTY_STRING then
  begin
    _text := _text + ' [' + entry.category + ']';
  end;
  _text := _text + ' ' + entry.message;

  Result := _text;
end;

function getLogLevelAsString(level: TLogLevel): string;
const
  LOG_LEVEL_NAMES: array [TLogLevel] of string = ('DEBUG', 'INFO', 'WARNING', 'ERROR');
begin
  Result := LOG_LEVEL_NAMES[level];
end;

end.
