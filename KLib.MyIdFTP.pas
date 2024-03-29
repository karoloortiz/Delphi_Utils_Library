{
  KLib Version = 3.0
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

unit KLib.MyIdFTP;

interface

uses
  IdFTP,
  KLib.Types, KLib.Constants;

type
  TMyIdFTP = class(TIdFTP)
  public
    defaultDir: string;
    constructor create(FTPCredentials: TFTPCredentials); overload;
    procedure Connect; reintroduce;
    procedure put(sourceFileName: string; targetFileName: string; force: boolean = NOT_FORCE_OVERWRITE); overload;
    procedure deleteFileIfExists(filename: string);
    procedure makeDirIfNotExists(dirName: string);
    function checkIfFileExists(filename: string): boolean;
    destructor Destroy; overload; override;
  end;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
function getTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;

implementation

uses
  KLib.Utils, KLib.Indy, KLib.Validate,
  IdFTPCommon,
  System.Classes;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
var
  connection: TMyIdFTP;
begin
  validateFTPCredentials(FTPCredentials);
  connection := getTMyIdFTP(FTPCredentials);
  Result := connection;
end;

function getTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
var
  connection: TMyIdFTP;
begin
  validateRequiredFTPProperties(FTPCredentials);
  connection := TMyIdFTP.Create(nil);
  with connection do
  begin
    Host := FTPCredentials.server;
    Username := FTPCredentials.credentials.username;
    Password := FTPCredentials.credentials.password;
    Port := FTPCredentials.port;
    TransferType := TIdFTPTransferType(FTPCredentials.transferType);
  end;

  if connection.Port = 0 then
  begin
    connection.Port := FTP_DEFAULT_PORT;
  end;

  //todo create function checkIFEnumIsInValidRange
  if (connection.transferType < Low(TIdFTPTransferType)) or (connection.transferType > High(TIdFTPTransferType)) then
  begin
    connection.transferType := ftBinary;
  end;
  connection.Passive := true;

  connection.defaultDir := FTPCredentials.pathFTPDir;

  Result := connection;
end;

constructor TMyIdFTP.create(FTPCredentials: TFTPCredentials);
begin
  Self := getValidMyIdFTP(FTPCredentials);
end;

procedure TMyIdFTP.Connect;
begin
  inherited;
  if defaultDir <> '' then
  begin
    ChangeDir(defaultDir);
  end;
end;

procedure TMyIdFTP.put(sourceFileName: string; targetFileName: string; force: boolean = NOT_FORCE_OVERWRITE);
const
  AAppend: Boolean = False;
  AStartPos = -1;
begin
  if force then
  begin
    deleteFileIfExists(targetFileName);
  end;
  inherited Put(sourceFileName, targetFileName, AAppend, AStartPos);
end;

procedure TMyIdFTP.deleteFileIfExists(filename: string);
var
  _existsFile: boolean;
begin
  _existsFile := checkIfFileExists(filename);
  if _existsFile then
  begin
    Delete(filename);
  end;
end;

procedure TMyIdFTP.makeDirIfNotExists(dirName: string);
var
  _existsFile: boolean;
begin
  _existsFile := checkIfFileExists(dirName);
  if not _existsFile then
  begin
    MakeDir(dirName);
  end;
end;

function TMyIdFTP.checkIfFileExists(filename: string): boolean;
var
  existsFile: boolean;
  i: integer;
begin
  List('*', false); //TODO https://stackoverflow.com/questions/30867501/delphi-bug-in-indy-ftp-list-method

  existsFile := false;
  i := 0;
  while not existsFile and (i <= DirectoryListing.Count - 1) do
  begin
    existsFile := DirectoryListing[i].FileName = fileName;
    inc(i);
  end;
  result := existsFile;
end;

destructor TMyIdFTP.Destroy;
begin
  inherited;
end;

end.
