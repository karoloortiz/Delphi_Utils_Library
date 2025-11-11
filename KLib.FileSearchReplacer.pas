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

unit KLib.FileSearchReplacer;

interface

uses
  KLib.Constants,
  System.Classes, System.SysUtils;

type
  TFileSearchReplacer = class
  private
    sourceFile: TFileStream;
    tempFile: TFileStream;
    encoding: TEncoding;
    customFilenameOutputEnabled: boolean;
    filenameOutput: string;
  public
    constructor Create(const fileName: string; const filenameOutput: string = EMPTY_STRING);

    procedure replace(const oldText: string; const newText: string; ReplaceFlags: TReplaceFlags = []);

    destructor Destroy; override;
  end;

implementation

uses
  KLib.Math, KLib.Validate, KLib.StringUtils, KLib.FileSystem,
  Winapi.Windows,
  System.IOUtils, System.StrUtils;

constructor TFileSearchReplacer.Create(const fileName: string; const filenameOutput: string = EMPTY_STRING);
var
  _tmpFileName: string;
begin
  inherited Create;

  validateThatFileExists(fileName);

  if filenameOutput = EMPTY_STRING then
  begin
    Self.filenameOutput := fileName;
  end
  else
  begin
    Self.filenameOutput := filenameOutput;
  end;
  Self.sourceFile := TFileStream.Create(fileName, fmOpenReadWrite);
  Self.customFilenameOutputEnabled := Self.filenameOutput <> fileName;
  _tmpFileName := ChangeFileExt(fileName, '.TFileSearchReplaceTemp');

  Self.tempFile := TFileStream.Create(_tmpFileName, fmCreate);
end;

procedure TFileSearchReplacer.replace(const oldText: string; const newText: string;
  ReplaceFlags: TReplaceFlags = []);
  procedure CopyPreamble;
  var
    _preambleSize: Integer;
    _preambleBuf: TBytes;
  begin
    // Copy Encoding preamble
    SetLength(_preambleBuf, 100);
    sourceFile.Read(_preambleBuf, Length(_preambleBuf));
    sourceFile.Seek(0, soBeginning);

    _preambleSize := TEncoding.GetBufferEncoding(_preambleBuf, encoding);
    if _preambleSize <> 0 then
    begin
      tempFile.CopyFrom(sourceFile, _preambleSize);
    end;
  end;

  function getLastIndex(const Str: string; SubStr: string; caseSensitiveSearch: boolean): Integer;
  var
    i: Integer;
    _tmpSubStr: string;
    _tmpStr: string;
  begin
    _tmpStr := Str;
    _tmpSubStr := SubStr;

    if not caseSensitiveSearch then
    begin
      _tmpStr := UpperCase(Str);
      _tmpSubStr := UpperCase(SubStr);
    end;

    i := Pos(_tmpSubStr, _tmpStr);
    Result := i;
    while i > 0 do
    begin
      i := PosEx(_tmpSubStr, _tmpStr, i + 1);
      if i > 0 then
      begin
        Result := i;
      end;
    end;
    if Result > 0 then
    begin
      Inc(Result, Length(_tmpSubStr) - 1);
    end;
  end;

  procedure parseBuffer(bufferOfBytes: TBytes; var isReplaced: Boolean);
  var
    i: Integer;
    ReadedBufLen: Integer;
    BufStr: string;
    DestBytes: TBytes;
    _lastIndex: Integer;
  begin
    if isReplaced and (not(rfReplaceAll in ReplaceFlags)) then
    begin
      tempFile.Write(bufferOfBytes, Length(bufferOfBytes));
      Exit;
    end;

    // 1. Get chars from buffer
    ReadedBufLen := 0;
    for i := Length(bufferOfBytes) downto 0 do
      if encoding.GetCharCount(bufferOfBytes, 0, i) <> 0 then
      begin
        ReadedBufLen := i;
        Break;
      end;
    if ReadedBufLen = 0 then
      raise EEncodingError.Create('Cant convert bytes to str');

    sourceFile.Seek(ReadedBufLen - Length(bufferOfBytes), soCurrent);

    BufStr := encoding.GetString(bufferOfBytes, 0, ReadedBufLen);
    if rfIgnoreCase in ReplaceFlags then
    begin
      isReplaced := ContainsText(BufStr, oldText);
    end
    else
    begin
      isReplaced := ContainsStr(BufStr, oldText);
    end;

    if isReplaced then
    begin
      _lastIndex := getLastIndex(BufStr, oldText, not(rfIgnoreCase in ReplaceFlags));
      _lastIndex := getMax(_lastIndex, Length(BufStr) - Length(oldText) + 1);
    end
    else
    begin
      _lastIndex := Length(BufStr);
    end;

    SetLength(BufStr, _lastIndex);
    sourceFile.Seek(encoding.GetByteCount(BufStr) - ReadedBufLen, soCurrent);

    BufStr := KLib.StringUtils.myStringReplace(BufStr, oldText, newText, ReplaceFlags);
    DestBytes := encoding.GetBytes(BufStr);
    tempFile.Write(DestBytes, Length(DestBytes));
  end;

var
  _bufferBytes: TBytes;
  _bufferLength: Integer;
  bReplaced: Boolean;

  _sourceSize: int64;
begin
  sourceFile.Seek(0, soBeginning);
  tempFile.Size := 0;
  CopyPreamble;

  _sourceSize := sourceFile.Size;
  _bufferLength := getMax(encoding.GetByteCount(oldText) * 5, 2048);
  _bufferLength := getMax(encoding.GetByteCount(newText) * 5, _bufferLength);
  SetLength(_bufferBytes, _bufferLength);

  bReplaced := False;
  while sourceFile.Position < _sourceSize do
  begin
    _bufferLength := sourceFile.Read(_bufferBytes, Length(_bufferBytes));
    SetLength(_bufferBytes, _bufferLength);
    parseBuffer(_bufferBytes, bReplaced);
  end;

  if not customFilenameOutputEnabled then
  begin
    sourceFile.Size := 0;
    sourceFile.CopyFrom(tempFile, 0);
  end;
end;

destructor TFileSearchReplacer.Destroy;
var
  _tempFileName: string;
begin
  if Assigned(tempFile) then
  begin
    _tempFileName := tempFile.FileName;
  end;

  FreeAndNil(tempFile);
  FreeAndNil(sourceFile);

  if (not customFilenameOutputEnabled) and (_tempFileName <> EMPTY_STRING) then
  begin
    TFile.Delete(_tempFileName);
  end
  else
  begin
    deleteFileIfExists(filenameOutput);
    RenameFile(_tempFileName, filenameOutput);
  end;

  inherited;
end;

end.
