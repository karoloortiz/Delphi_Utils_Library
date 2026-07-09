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

unit KLib.FileTransfer;

{
  Protocol-agnostic file transfer abstraction (FTP / SFTP).

  Unifies the BEHAVIOR behind a single interface (IFileTransferClient) while
  keeping the connection DATA separated per protocol (TFtpCredentials in FTP,
  TSFTPCredentials in SFTP). The caller programs against the interface and no
  longer knows nor cares which protocol is in use; the protocol is chosen once,
  by which factory overload is called.

    FTP  -> TFtpTransferClient  (wraps KLib.MyIdFTP / KLib.Indy, Indy based)
    SFTP -> TSftpTransferClient (wraps KLib.SFTP / libssh2)

  remotePath semantics: relative to the base remote directory configured on the
  credentials (TFtpCredentials.pathFTPDir for FTP, TSFTPCredentials.remoteDir for
  SFTP). FTP changes into that directory on connect; the SFTP adapter prepends it
  to remotePath. So passing a bare file name lands in the configured directory
  for both protocols. An absolute remotePath (leading '/') bypasses the base
  directory in SFTP.

  Usage:
    var
      _client: IFileTransferClient;
    begin
      _client := getFileTransferClient(sftpCredentials); //or ftpCredentials
      _client.connect;
      try
        _client.uploadFile('C:\out\doc.pdf', 'doc.pdf');
      finally
        _client.disconnect;
      end;
    end;
    //no manual Free: IFileTransferClient is reference counted.
}

interface

uses
  System.SysUtils,
  KLib.Types;

type
  EFileTransferException = class(Exception);

  TFileTransferProtocol = (ftpProtocol, sftpProtocol);

  IFileTransferClient = interface
    ['{6F3A1C42-9E7B-4D58-A1F0-2C9D8B4E7A31}']
    procedure connect;
    procedure disconnect;
    procedure uploadFile(localPath: string; remotePath: string);
    procedure downloadFile(remotePath: string; localPath: string);
    procedure deleteFile(remotePath: string);
    function isFileExists(remotePath: string): boolean;
    procedure makeDir(remotePath: string);
  end;

function getFileTransferClient(ftpCredentials: TFtpCredentials): IFileTransferClient; overload;
function getFileTransferClient(sftpCredentials: TSFTPCredentials): IFileTransferClient; overload;

implementation

uses
  KLib.Constants,
  KLib.MyIdFTP, KLib.Indy,
  KLib.SFTP,
  IdFTP;

type
  TFtpTransferClient = class(TInterfacedObject, IFileTransferClient)
  private
    credentials: TFtpCredentials;
    connection: TMyIdFTP;
    isConnected: boolean;

    procedure ensureConnected;
  public
    constructor create(ftpCredentials: TFtpCredentials);
    destructor Destroy; override;

    procedure connect;
    procedure disconnect;
    procedure uploadFile(localPath: string; remotePath: string);
    procedure downloadFile(remotePath: string; localPath: string);
    procedure deleteFile(remotePath: string);
    function isFileExists(remotePath: string): boolean;
    procedure makeDir(remotePath: string);
  end;

  TSftpTransferClient = class(TInterfacedObject, IFileTransferClient)
  private
    client: TSFTPClient;
    remoteDir: string;

    function resolveRemote(remotePath: string): string;
  public
    constructor create(sftpCredentials: TSFTPCredentials);
    destructor Destroy; override;

    procedure connect;
    procedure disconnect;
    procedure uploadFile(localPath: string; remotePath: string);
    procedure downloadFile(remotePath: string; localPath: string);
    procedure deleteFile(remotePath: string);
    function isFileExists(remotePath: string): boolean;
    procedure makeDir(remotePath: string);
  end;

function getFileTransferClient(ftpCredentials: TFtpCredentials): IFileTransferClient;
begin
  Result := TFtpTransferClient.create(ftpCredentials);
end;

function getFileTransferClient(sftpCredentials: TSFTPCredentials): IFileTransferClient;
begin
  Result := TSftpTransferClient.create(sftpCredentials);
end;

{ TFtpTransferClient }

constructor TFtpTransferClient.create(ftpCredentials: TFtpCredentials);
begin
  inherited create;
  credentials := ftpCredentials;
  connection := nil;
  isConnected := false;
end;

destructor TFtpTransferClient.Destroy;
begin
  disconnect;

  inherited;
end;

procedure TFtpTransferClient.ensureConnected;
begin
  if not isConnected then
  begin
    raise EFileTransferException.create('FTP: operation requested but not connected');
  end;
end;

procedure TFtpTransferClient.connect;
begin
  if isConnected then
  begin
    Exit;
  end;

  connection := getValidTMyIdFTP(credentials);
  try
    connection.Connect;
    isConnected := true;
  except
    FreeAndNil(connection);
    raise;
  end;
end;

procedure TFtpTransferClient.disconnect;
begin
  if Assigned(connection) then
  begin
    try
      if connection.Connected then
      begin
        connection.Disconnect;
      end;
    except
      //teardown: ignore disconnect errors
    end;
    FreeAndNil(connection);
  end;

  isConnected := false;
end;

procedure TFtpTransferClient.uploadFile(localPath: string; remotePath: string);
begin
  ensureConnected;
  connection.put(localPath, remotePath, FORCE_OVERWRITE);
end;

procedure TFtpTransferClient.downloadFile(remotePath: string; localPath: string);
begin
  ensureConnected;
  connection.Get(remotePath, localPath, True);
end;

procedure TFtpTransferClient.deleteFile(remotePath: string);
begin
  ensureConnected;
  connection.Delete(remotePath);
end;

function TFtpTransferClient.isFileExists(remotePath: string): boolean;
var
  _isExisting: boolean;
begin
  ensureConnected;
  _isExisting := connection.checkIfFileExists(remotePath);

  Result := _isExisting;
end;

procedure TFtpTransferClient.makeDir(remotePath: string);
begin
  ensureConnected;
  connection.makeDirIfNotExists(remotePath);
end;

{ TSftpTransferClient }

function combineRemotePath(baseDir: string; remotePath: string): string;
begin
  if (baseDir = '') or ((remotePath <> '') and (remotePath[1] = '/')) then
  begin
    //no base dir, or remotePath already absolute
    Result := remotePath;
  end
  else
  begin
    Result := baseDir;
    if Result[Length(Result)] <> '/' then
    begin
      Result := Result + '/';
    end;
    Result := Result + remotePath;
  end;
end;

constructor TSftpTransferClient.create(sftpCredentials: TSFTPCredentials);
begin
  inherited create;
  client := TSFTPClient.create(sftpCredentials);
  remoteDir := sftpCredentials.remoteDir;
end;

function TSftpTransferClient.resolveRemote(remotePath: string): string;
begin
  Result := combineRemotePath(remoteDir, remotePath);
end;

destructor TSftpTransferClient.Destroy;
begin
  FreeAndNil(client);

  inherited;
end;

procedure TSftpTransferClient.connect;
begin
  client.connect;
end;

procedure TSftpTransferClient.disconnect;
begin
  client.disconnect;
end;

procedure TSftpTransferClient.uploadFile(localPath: string; remotePath: string);
begin
  client.uploadFile(localPath, resolveRemote(remotePath));
end;

procedure TSftpTransferClient.downloadFile(remotePath: string; localPath: string);
begin
  client.downloadFile(resolveRemote(remotePath), localPath);
end;

procedure TSftpTransferClient.deleteFile(remotePath: string);
begin
  client.deleteFile(resolveRemote(remotePath));
end;

function TSftpTransferClient.isFileExists(remotePath: string): boolean;
var
  _isExisting: boolean;
begin
  _isExisting := client.isFileExists(resolveRemote(remotePath));

  Result := _isExisting;
end;

procedure TSftpTransferClient.makeDir(remotePath: string);
var
  _remote: string;
begin
  _remote := resolveRemote(remotePath);
  if not client.isFileExists(_remote) then
  begin
    client.makeDir(_remote);
  end;
end;

end.
