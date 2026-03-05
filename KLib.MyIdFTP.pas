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

unit KLib.MyIdFTP;

interface

uses
  IdFTP,
  KLib.Types, KLib.Constants;

type
  TMyIdFTP = class(TIdFTP)
  public
    defaultDir: string;
    constructor create(ftpCredentials: TFtpCredentials); overload;
    procedure Connect; reintroduce;
    procedure put(sourceFileName: string; targetFileName: string; force: boolean = NOT_FORCE_OVERWRITE); overload;
    procedure deleteFileIfExists(filename: string);
    procedure makeDirIfNotExists(dirName: string);
    function checkIfFileExists(filename: string): boolean;
    function checkIfDirExists(dirName: string): boolean;
    destructor Destroy; overload; override;
  end;

implementation

uses
  KLib.Indy, KLib.Validate,
  IdFTPCommon, IdFTPList,
  System.Classes;

constructor TMyIdFTP.create(ftpCredentials: TFtpCredentials);
begin
  Self := getValidTMyIdFTP(ftpCredentials);
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
  _existsDir: boolean;
begin
  _existsDir := checkIfDirExists(dirName);
  if not _existsDir then
  begin
    MakeDir(dirName);
  end;
end;

//NOTE: List('*', false) forces NLST command which supports wildcards.
//  List with ADetails=true and UseMLIS=true sends MLSD which does NOT accept file masks.
//  ref: https://stackoverflow.com/questions/30867501/delphi-bug-in-indy-ftp-list-method
function TMyIdFTP.checkIfFileExists(filename: string): boolean;
var
  _existsFile: boolean;
  _i: integer;
begin
  List('*', false);

  _existsFile := false;
  _i := 0;
  while not _existsFile and (_i <= DirectoryListing.Count - 1) do
  begin
    _existsFile := (DirectoryListing[_i].FileName = fileName)
      and (DirectoryListing[_i].ItemType = ditFile);
    inc(_i);
  end;

  Result := _existsFile;
end;

function TMyIdFTP.checkIfDirExists(dirName: string): boolean;
var
  _existsDir: boolean;
  _i: integer;
begin
  List('*', false);

  _existsDir := false;
  _i := 0;
  while not _existsDir and (_i <= DirectoryListing.Count - 1) do
  begin
    _existsDir := (DirectoryListing[_i].FileName = dirName)
      and (DirectoryListing[_i].ItemType = ditDirectory);
    inc(_i);
  end;

  Result := _existsDir;
end;

destructor TMyIdFTP.Destroy;
begin
  inherited;
end;

end.
