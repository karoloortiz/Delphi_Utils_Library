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

unit KLib.SFTP;

{
  SFTP client built on top of libssh2 (unit KLib.libssh2.pas).

  Supports both authentication methods:
  - password        (sftpAuthPassword)
  - private key file (sftpAuthPrivateKey), with optional passphrase

  The underlying libssh2.dll is loaded on demand: if it is not present the
  feature is simply unavailable (isSftpAvailable = false) and the existing
  FTP flow is not affected.

  Placed in the project source (not in the read-only boundaries submodule);
  written in KLib style so it can be promoted to boundaries later.

  Usage (one-shot):
  var
  _credentials: TSFTPCredentials;
  begin
  _credentials.clear;
  _credentials.host := 'sftp.example.com';
  _credentials.credentials.username := 'user';
  _credentials.credentials.password := 'secret';
  _credentials.authMethod := sftpAuthPassword;
  sftpUploadFile(_credentials, 'C:\out\doc.pdf', '/incoming/doc.pdf');
  end;

  Usage (private key):
  _credentials.authMethod := sftpAuthPrivateKey;
  _credentials.privateKeyPath := 'C:\keys\id_rsa';
  _credentials.publicKeyPath := 'C:\keys\id_rsa.pub'; //optional
  _credentials.passphrase := 'keypass';               //optional

  Usage (host key verification, anti-MITM - optional):
  If knownHostsPath is set, after the handshake the server host key is
  checked against the given OpenSSH known_hosts file. On MISMATCH or
  NOTFOUND the connection is refused (ESFTPException). If left empty the
  check is skipped (previous behaviour). Requires a libssh2.dll built with
  known_hosts support; otherwise an explicit error is raised.

  _credentials.knownHostsPath := 'C:\keys\known_hosts';
  //known_hosts line format (one per host):
  //  sftp.example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...

  Usage (reusing one connection for several files):
  var
  _client: TSFTPClient;
  begin
  _client := TSFTPClient.create(_credentials);
  try
  _client.connect;
  _client.uploadFile('C:\out\a.pdf', '/incoming/a.pdf');
  _client.uploadFile('C:\out\b.pdf', '/incoming/b.pdf');
  finally
  FreeAndNil(_client);
  end;
  end;
}

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  Winapi.WinSock2,
  KLib.Types, KLib.libssh2;

const
  SFTP_TRANSFER_BUFFER_SIZE = 32768;

type
  ESFTPException = class(Exception);

  TSFTPClient = class
  private
    credentials: TSFTPCredentials;
    socketHandle: TSocket;
    session: PLIBSSH2_SESSION;
    sftp: PLIBSSH2_SFTP;
    isConnected: boolean;

    function getEffectivePort: integer;
    procedure openSession;
    procedure verifyHostKey;
    procedure authenticate;
    procedure authenticateWithPassword;
    procedure authenticateWithPrivateKey;
    procedure raiseSessionError(contextMsg: string; returnCode: integer);
    procedure closeSocketHandle;
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

function isSftpAvailable: boolean;

procedure sftpUploadFile(credentials: TSFTPCredentials; localPath: string; remotePath: string);
procedure sftpDownloadFile(credentials: TSFTPCredentials; remotePath: string; localPath: string);
procedure sftpDeleteFile(credentials: TSFTPCredentials; remotePath: string);

implementation

uses
  KLib.FileSystem, KLib.Windows, KLib.Constants,
  WinApi.Windows;

const
  FILENAME_LIBSSH2 = 'libssh2.dll';
  FILENAME_ZLIB = 'z.dll';
{$ifdef WIN32}
  FILENAME_LIBCRYPTO3 = 'libcrypto-3.dll';
  FILENAME_LIBSSL3 = 'libssl-3.dll';
{$else}
  FILENAME_LIBCRYPTO3 = 'libcrypto-3-x64.dll';
  FILENAME_LIBSSL3 = 'libssl-3-x64.dll';
{$endif}


var
  isWinsockStarted: boolean = false;
  isLibraryStarted: boolean = false;
  initLock: TCriticalSection;

procedure extractDllIfMissing(resourceName: string; fileName: string);
var
  _path: string;
begin
  _path := getCombinedPathWithCurrentDir(fileName);
  if not checkIfFileExists(_path) then
  begin
    getResourceAsDllFile(resourceName, _path);
  end;
end;

procedure getSftpDLLsFromResource;
begin
{$ifdef WIN32}
  extractDllIfMissing('LIBSSH2_X86', FILENAME_LIBSSH2);
  extractDllIfMissing('LIBCRYPTO3_X86', FILENAME_LIBCRYPTO3);
  extractDllIfMissing('LIBSSL3_X86', FILENAME_LIBSSL3);
  extractDllIfMissing('ZLIB_X86', FILENAME_ZLIB);
{$else IFDEF WIN64}
  extractDllIfMissing('LIBSSH2_X64', FILENAME_LIBSSH2);
  extractDllIfMissing('LIBCRYPTO3_X64', FILENAME_LIBCRYPTO3);
  extractDllIfMissing('LIBSSL3_X64', FILENAME_LIBSSL3);
  extractDllIfMissing('ZLIB_X64', FILENAME_ZLIB);
{$endif}
end;

procedure tryGetSftpDLLsFromResource;
begin
  try
    getSftpDLLsFromResource;
  except
    on E: Exception do
    begin
      //best effort: if the resources are missing or extraction fails,
      //  we continue and loadLibssh2 will provide the diagnostic error
    end;
  end;
end;

procedure ensureLibReady;
var
  _wsaData: TWSAData;
begin
  initLock.Enter;
  try
    if not isLibssh2Loaded then
    begin
      tryGetSftpDLLsFromResource;
      if not loadLibssh2 then
      begin
        raise ESFTPException.create('SFTP unavailable: cannot load ' +
          LIBSSH2_DLL_DEFAULT + '. ' + getLibssh2LastLoadError);
      end;
    end;

    if not isWinsockStarted then
    begin
      if WSAStartup($0202, _wsaData) <> 0 then
      begin
        raise ESFTPException.create('SFTP: Winsock initialization failed');
      end;
      isWinsockStarted := true;
    end;

    if not isLibraryStarted then
    begin
      if libssh2_init(0) <> 0 then
      begin
        raise ESFTPException.create('SFTP: libssh2_init failed');
      end;
      isLibraryStarted := true;
    end;
  finally
    initLock.Leave;
  end;
end;

function toUtf8(value: string): RawByteString;
var
  _utf8: RawByteString;
begin
  _utf8 := UTF8Encode(value);

  Result := _utf8;
end;

function connectSocket(host: string; port: integer): TSocket;
var
  _hints: TAddrInfo;
  _addrResult: PAddrInfo;
  _addr: PAddrInfo;
  _sock: TSocket;
  _hostUtf8: RawByteString;
  _portStr: RawByteString;
  _returnCode: integer;
  _isConnected: boolean;
begin
  FillChar(_hints, SizeOf(_hints), 0);
  _hints.ai_family := AF_UNSPEC; //IPv4 e IPv6
  _hints.ai_socktype := SOCK_STREAM;
  _hints.ai_protocol := IPPROTO_TCP;

  _hostUtf8 := toUtf8(host);
  _portStr := RawByteString(IntToStr(port));

  _addrResult := nil;
  _returnCode := getaddrinfo(PAnsiChar(_hostUtf8), PAnsiChar(_portStr), _hints, _addrResult);
  if (_returnCode <> 0) or (_addrResult = nil) then
  begin
    raise ESFTPException.create('SFTP: host resolution failed -> ' + host);
  end;

  _sock := INVALID_SOCKET;
  _isConnected := false;
  try
    _addr := _addrResult;
    while (not _isConnected) and (_addr <> nil) do
    begin
      _sock := socket(_addr.ai_family, _addr.ai_socktype, _addr.ai_protocol);
      if _sock <> INVALID_SOCKET then
      begin
        if Winapi.WinSock2.connect(_sock, _addr.ai_addr^, integer(_addr.ai_addrlen)) = 0 then
        begin
          _isConnected := true;
        end
        else
        begin
          closesocket(_sock);
          _sock := INVALID_SOCKET;
        end;
      end;

      if not _isConnected then
      begin
        _addr := _addr.ai_next;
      end;
    end;
  finally
    freeaddrinfo(_addrResult^);
  end;

  if not _isConnected then
  begin
    raise ESFTPException.create('SFTP: connection failed -> ' + host + ':' + IntToStr(port));
  end;

  Result := _sock;
end;

function isSftpAvailable: boolean;
var
  _isAvailable: boolean;
begin
  try
    tryGetSftpDLLsFromResource;
    _isAvailable := loadLibssh2;
  except
    _isAvailable := false;
  end;

  Result := _isAvailable;
end;

{ TSFTPClient }

constructor TSFTPClient.create(sftpCredentials: TSFTPCredentials);
begin
  inherited create;
  credentials := sftpCredentials;
  socketHandle := INVALID_SOCKET;
  session := nil;
  sftp := nil;
  isConnected := false;
end;

destructor TSFTPClient.Destroy;
begin
  disconnect;

  inherited;
end;

function TSFTPClient.getEffectivePort: integer;
var
  _port: integer;
begin
  _port := credentials.port;
  if _port <= 0 then
  begin
    _port := SFTP_DEFAULT_PORT;
  end;

  Result := _port;
end;

procedure TSFTPClient.raiseSessionError(contextMsg: string; returnCode: integer);
var
  _errPtr: PAnsiChar;
  _errLen: integer;
  _detail: string;
  _errorCode: integer;
begin
  _errPtr := nil;
  _errLen := 0;
  _errorCode := returnCode;
  if (session <> nil) and Assigned(libssh2_session_last_error) then
  begin
    if returnCode = 0 then
    begin
      //rc not meaningful (e.g. failed init): use the actual session error code
      _errorCode := libssh2_session_last_error(session, _errPtr, _errLen, 0);
    end
    else
    begin
      libssh2_session_last_error(session, _errPtr, _errLen, 0);
    end;
  end;

  _detail := '';
  if _errPtr <> nil then
  begin
    _detail := ' - ' + string(AnsiString(_errPtr));
  end;

  raise ESFTPException.create(contextMsg + ' (rc=' + IntToStr(_errorCode) + ')' + _detail);
end;

procedure TSFTPClient.closeSocketHandle;
begin
  if socketHandle <> INVALID_SOCKET then
  begin
    closesocket(socketHandle);
    socketHandle := INVALID_SOCKET;
  end;
end;

procedure TSFTPClient.openSession;
var
  _returnCode: integer;
begin
  socketHandle := connectSocket(credentials.host, getEffectivePort);

  session := libssh2_session_init_ex(nil, nil, nil, nil);
  if session = nil then
  begin
    raise ESFTPException.create('SFTP: session creation failed');
  end;

  libssh2_session_set_blocking(session, 1);

  _returnCode := libssh2_session_handshake(session, socketHandle);
  if _returnCode <> 0 then
  begin
    raiseSessionError('SFTP: handshake failed', _returnCode);
  end;

  verifyHostKey;
end;

procedure TSFTPClient.verifyHostKey;
const
  KEY_TYPEMASK = LIBSSH2_KNOWNHOST_TYPE_PLAIN or LIBSSH2_KNOWNHOST_KEYENC_RAW;
var
  _knownHosts: PLIBSSH2_KNOWNHOSTS;
  _knownHostsPath: RawByteString;
  _hostUtf8: RawByteString;
  _hostKey: PAnsiChar;
  _hostKeyLen: NativeUInt;
  _hostKeyType: integer;
  _knownHostEntry: PLIBSSH2_KNOWNHOST;
  _checkResult: integer;
begin
  if credentials.knownHostsPath = '' then
  begin
    Exit;
  end;

  if not(Assigned(libssh2_session_hostkey) and Assigned(libssh2_knownhost_init) and
    Assigned(libssh2_knownhost_readfile) and Assigned(libssh2_knownhost_checkp) and
    Assigned(libssh2_knownhost_free)) then
  begin
    raise ESFTPException.create('SFTP: host key verification not supported by the loaded libssh2');
  end;

  _hostKeyLen := 0;

  _hostKey := libssh2_session_hostkey(session, _hostKeyLen, _hostKeyType);
  if (_hostKey = nil) or (_hostKeyLen = 0) then
  begin
    raise ESFTPException.create('SFTP: cannot obtain the server host key');
  end;

  _knownHosts := libssh2_knownhost_init(session);
  if _knownHosts = nil then
  begin
    raise ESFTPException.create('SFTP: known_hosts initialization failed');
  end;

  try
    _knownHostsPath := toUtf8(credentials.knownHostsPath);
    if libssh2_knownhost_readfile(_knownHosts, PAnsiChar(_knownHostsPath),
      LIBSSH2_KNOWNHOST_FILE_OPENSSH) < 0 then
    begin
      raise ESFTPException.create('SFTP: known_hosts read failed -> ' + credentials.knownHostsPath);
    end;

    _hostUtf8 := toUtf8(credentials.host);
    _knownHostEntry := nil;
    _checkResult := libssh2_knownhost_checkp(_knownHosts, PAnsiChar(_hostUtf8),
      getEffectivePort, _hostKey, _hostKeyLen, KEY_TYPEMASK, _knownHostEntry);

    case _checkResult of
      LIBSSH2_KNOWNHOST_CHECK_MATCH:
        begin
          //host verified
        end;
      LIBSSH2_KNOWNHOST_CHECK_MISMATCH:
        begin
          raise ESFTPException.create('SFTP: host key MISMATCH against known_hosts (possible MITM) -> ' + credentials.host);
        end;
      LIBSSH2_KNOWNHOST_CHECK_NOTFOUND:
        begin
          raise ESFTPException.create('SFTP: host key not found in known_hosts -> ' + credentials.host);
        end;
    else
      begin
        raise ESFTPException.create('SFTP: host key verification failed -> ' + credentials.host);
      end;
    end;
  finally
    libssh2_knownhost_free(_knownHosts);
  end;
end;

procedure TSFTPClient.authenticateWithPassword;
var
  _user: RawByteString;
  _password: RawByteString;
  _returnCode: integer;
begin
  _user := toUtf8(credentials.credentials.username);
  _password := toUtf8(credentials.credentials.password);

  _returnCode := libssh2_userauth_password_ex(session, PAnsiChar(_user),
    Length(_user), PAnsiChar(_password), Length(_password), nil);
  if _returnCode <> 0 then
  begin
    raiseSessionError('SFTP: password authentication failed', _returnCode);
  end;
end;

procedure TSFTPClient.authenticateWithPrivateKey;
var
  _user: RawByteString;
  _privateKey: RawByteString;
  _publicKey: RawByteString;
  _passphrase: RawByteString;
  _publicKeyPtr: PAnsiChar;
  _passphrasePtr: PAnsiChar;
  _returnCode: integer;
begin
  if credentials.privateKeyPath = '' then
  begin
    raise ESFTPException.create('SFTP: private key path not set');
  end;

  _user := toUtf8(credentials.credentials.username);
  _privateKey := toUtf8(credentials.privateKeyPath);
  _publicKey := toUtf8(credentials.publicKeyPath);
  _passphrase := toUtf8(credentials.passphrase);

  _publicKeyPtr := nil;
  if credentials.publicKeyPath <> '' then
  begin
    _publicKeyPtr := PAnsiChar(_publicKey);
  end;

  _passphrasePtr := nil;
  if credentials.passphrase <> '' then
  begin
    _passphrasePtr := PAnsiChar(_passphrase);
  end;

  _returnCode := libssh2_userauth_publickey_fromfile_ex(session, PAnsiChar(_user),
    Length(_user), _publicKeyPtr, PAnsiChar(_privateKey), _passphrasePtr);
  if _returnCode <> 0 then
  begin
    raiseSessionError('SFTP: private key authentication failed', _returnCode);
  end;
end;

procedure TSFTPClient.authenticate;
begin
  case credentials.authMethod of
    sftpAuthPassword:
      begin
        authenticateWithPassword;
      end;
    sftpAuthPrivateKey:
      begin
        authenticateWithPrivateKey;
      end;
  end;

  if libssh2_userauth_authenticated(session) = 0 then
  begin
    raise ESFTPException.create('SFTP: authentication failed');
  end;
end;

procedure TSFTPClient.connect;
begin
  if isConnected then
  begin
    Exit;
  end;

  ensureLibReady;

  try
    openSession;
    authenticate;

    sftp := libssh2_sftp_init(session);
    if sftp = nil then
    begin
      raiseSessionError('SFTP: SFTP subsystem initialization failed', 0);
    end;

    isConnected := true;
  except
    disconnect;
    raise;
  end;
end;

procedure TSFTPClient.disconnect;
begin
  if (sftp <> nil) and Assigned(libssh2_sftp_shutdown) then
  begin
    libssh2_sftp_shutdown(sftp);
    sftp := nil;
  end;

  if (session <> nil) and Assigned(libssh2_session_disconnect_ex) then
  begin
    libssh2_session_disconnect_ex(session, SSH_DISCONNECT_BY_APPLICATION, 'bye', '');
    libssh2_session_free(session);
    session := nil;
  end;

  closeSocketHandle;

  isConnected := false;
end;

procedure TSFTPClient.uploadFile(localPath: string; remotePath: string);
var
  _remote: RawByteString;
  _handle: PLIBSSH2_SFTP_HANDLE;
  _stream: TFileStream;
  _buffer: TBytes;
  _bytesRead: integer;
  _totalWritten: NativeInt;
  _written: NativeInt;
begin
  if not isConnected then
  begin
    raise ESFTPException.create('SFTP: upload requested but not connected');
  end;

  _remote := toUtf8(remotePath);
  _handle := libssh2_sftp_open_ex(sftp, PAnsiChar(_remote), Length(_remote),
    LIBSSH2_FXF_WRITE or LIBSSH2_FXF_CREAT or LIBSSH2_FXF_TRUNC,
    LIBSSH2_SFTP_MODE_0644, LIBSSH2_SFTP_OPENFILE);
  if _handle = nil then
  begin
    raiseSessionError('SFTP: opening remote file for writing failed -> ' + remotePath, 0);
  end;

  try
    SetLength(_buffer, SFTP_TRANSFER_BUFFER_SIZE);
    _stream := TFileStream.create(localPath, fmOpenRead or fmShareDenyWrite);
    try
      _bytesRead := _stream.Read(_buffer[0], SFTP_TRANSFER_BUFFER_SIZE);
      while (_bytesRead > 0) do
      begin
        _totalWritten := 0;
        while (_totalWritten < _bytesRead) do
        begin
          _written := libssh2_sftp_write(_handle, PAnsiChar(@_buffer[_totalWritten]),
            _bytesRead - _totalWritten);
          if _written < 0 then
          begin
            raiseSessionError('SFTP: remote file write failed -> ' + remotePath, _written);
          end;
          _totalWritten := _totalWritten + _written;
        end;

        _bytesRead := _stream.Read(_buffer[0], SFTP_TRANSFER_BUFFER_SIZE);
      end;
    finally
      FreeAndNil(_stream);
    end;
  finally
    libssh2_sftp_close_handle(_handle);
  end;
end;

procedure TSFTPClient.downloadFile(remotePath: string; localPath: string);
var
  _remote: RawByteString;
  _handle: PLIBSSH2_SFTP_HANDLE;
  _stream: TFileStream;
  _buffer: TBytes;
  _bytesRead: NativeInt;
  _tempPath: string;
begin
  if not isConnected then
  begin
    raise ESFTPException.create('SFTP: download requested but not connected');
  end;

  _remote := toUtf8(remotePath);
  _handle := libssh2_sftp_open_ex(sftp, PAnsiChar(_remote), Length(_remote),
    LIBSSH2_FXF_READ, 0, LIBSSH2_SFTP_OPENFILE);
  if _handle = nil then
  begin
    raiseSessionError('SFTP: opening remote file for reading failed -> ' + remotePath, 0);
  end;

  try
    _tempPath := localPath + '.part';
    try
      SetLength(_buffer, SFTP_TRANSFER_BUFFER_SIZE);
      _stream := TFileStream.create(_tempPath, fmCreate);
      try
        _bytesRead := libssh2_sftp_read(_handle, PAnsiChar(@_buffer[0]), SFTP_TRANSFER_BUFFER_SIZE);
        while (_bytesRead > 0) do
        begin
          _stream.WriteBuffer(_buffer[0], _bytesRead);
          _bytesRead := libssh2_sftp_read(_handle, PAnsiChar(@_buffer[0]), SFTP_TRANSFER_BUFFER_SIZE);
        end;

        if _bytesRead < 0 then
        begin
          raiseSessionError('SFTP: remote file read failed -> ' + remotePath, _bytesRead);
        end;
      finally
        FreeAndNil(_stream);
      end;

      if System.SysUtils.FileExists(localPath) then
      begin
        System.SysUtils.DeleteFile(localPath);
      end;
      if not System.SysUtils.RenameFile(_tempPath, localPath) then
      begin
        raise ESFTPException.create('SFTP: cannot finalize local file -> ' + localPath);
      end;
    except
      System.SysUtils.DeleteFile(_tempPath);
      raise;
    end;
  finally
    libssh2_sftp_close_handle(_handle);
  end;
end;

procedure TSFTPClient.deleteFile(remotePath: string);
var
  _remote: RawByteString;
  _returnCode: integer;
begin
  if not isConnected then
  begin
    raise ESFTPException.create('SFTP: delete requested but not connected');
  end;

  _remote := toUtf8(remotePath);
  _returnCode := libssh2_sftp_unlink_ex(sftp, PAnsiChar(_remote), Length(_remote));
  if _returnCode <> 0 then
  begin
    raiseSessionError('SFTP: remote file deletion failed -> ' + remotePath, _returnCode);
  end;
end;

function TSFTPClient.isFileExists(remotePath: string): boolean;
var
  _remote: RawByteString;
  _attrs: LIBSSH2_SFTP_ATTRIBUTES;
  _returnCode: integer;
  _sftpError: LongWord;
  _isExisting: boolean;
begin
  if not isConnected then
  begin
    raise ESFTPException.create('SFTP: existence check requested but not connected');
  end;

  _isExisting := false;
  FillChar(_attrs, SizeOf(_attrs), 0);
  _remote := toUtf8(remotePath);
  _returnCode := libssh2_sftp_stat_ex(sftp, PAnsiChar(_remote), Length(_remote),
    LIBSSH2_SFTP_STAT, @_attrs);

  if _returnCode = 0 then
  begin
    _isExisting := true;
  end
  else if Assigned(libssh2_sftp_last_error) then
  begin
    _sftpError := libssh2_sftp_last_error(sftp);
    if _sftpError <> LIBSSH2_FX_NO_SUCH_FILE then
    begin
      raiseSessionError('SFTP: existence check failed -> ' + remotePath, _returnCode);
    end;
  end;
  //if libssh2_sftp_last_error is unavailable: legacy behaviour (rc<>0 -> not existing)

  Result := _isExisting;
end;

procedure TSFTPClient.makeDir(remotePath: string);
var
  _remote: RawByteString;
  _returnCode: integer;
begin
  if not isConnected then
  begin
    raise ESFTPException.create('SFTP: makeDir requested but not connected');
  end;

  _remote := toUtf8(remotePath);
  _returnCode := libssh2_sftp_mkdir_ex(sftp, PAnsiChar(_remote), Length(_remote),
    LIBSSH2_SFTP_MODE_0755);
  if _returnCode <> 0 then
  begin
    raiseSessionError('SFTP: remote directory creation failed -> ' + remotePath, _returnCode);
  end;
end;

procedure sftpUploadFile(credentials: TSFTPCredentials; localPath: string; remotePath: string);
var
  _client: TSFTPClient;
begin
  _client := TSFTPClient.create(credentials);
  try
    _client.connect;
    _client.uploadFile(localPath, remotePath);
  finally
    FreeAndNil(_client);
  end;
end;

procedure sftpDownloadFile(credentials: TSFTPCredentials; remotePath: string; localPath: string);
var
  _client: TSFTPClient;
begin
  _client := TSFTPClient.create(credentials);
  try
    _client.connect;
    _client.downloadFile(remotePath, localPath);
  finally
    FreeAndNil(_client);
  end;
end;

procedure sftpDeleteFile(credentials: TSFTPCredentials; remotePath: string);
var
  _client: TSFTPClient;
begin
  _client := TSFTPClient.create(credentials);
  try
    _client.connect;
    _client.deleteFile(remotePath);
  finally
    FreeAndNil(_client);
  end;
end;

initialization

initLock := TCriticalSection.Create;

finalization

if isLibraryStarted and Assigned(libssh2_exit) then
begin
  libssh2_exit;
  isLibraryStarted := false;
end;
if isWinsockStarted then
begin
  WSACleanup;
  isWinsockStarted := false;
end;
unloadLibssh2;
FreeAndNil(initLock);

end.
