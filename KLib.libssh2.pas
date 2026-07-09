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

unit KLib.libssh2;

{
  Minimal Object Pascal translation of the libssh2 C API (subset for SFTP).

  Only the functions needed by KLib.SFTP are declared. The library is loaded
  dynamically (LoadLibrary / GetProcAddress) so that a missing libssh2.dll does
  NOT prevent the application from starting: the SFTP feature simply reports as
  unavailable.

  libssh2 is BSD licensed and can be redistributed inside closed-source products.
  Deployment: libssh2.dll plus its crypto backend DLLs (e.g. OpenSSL
  libcrypto-3.dll / libssl-3.dll, or a WinCNG build) next to the executable.

  Calling convention on Windows: cdecl.

  NOTE: C 'unsigned long' and 'long' are 32-bit on Windows (LLP64), therefore
  mapped to LongWord / LongInt (not NativeUInt / NativeInt). 'size_t' / 'ssize_t'
  are pointer-sized -> NativeUInt / NativeInt.
}

interface

uses
  Winapi.WinSock2;

type
  PLIBSSH2_SESSION = Pointer;
  PLIBSSH2_SFTP = Pointer;
  PLIBSSH2_SFTP_HANDLE = Pointer;
  PLIBSSH2_KNOWNHOSTS = Pointer;
  PLIBSSH2_KNOWNHOST = Pointer;

  LIBSSH2_SFTP_ATTRIBUTES = record
    flags: LongWord;
    filesize: UInt64;
    uid: LongWord;
    gid: LongWord;
    permissions: LongWord;
    atime: LongWord;
    mtime: LongWord;
  end;

  PLIBSSH2_SFTP_ATTRIBUTES = ^LIBSSH2_SFTP_ATTRIBUTES;

const
  LIBSSH2_DLL_DEFAULT = 'libssh2.dll';

  LIBSSH2_ERROR_NONE = 0;
  LIBSSH2_ERROR_EAGAIN = -37;

  //libssh2_sftp_open_ex open_type
  LIBSSH2_SFTP_OPENFILE = 0;
  LIBSSH2_SFTP_OPENDIR = 1;

  //libssh2_sftp_stat_ex stat_type
  LIBSSH2_SFTP_STAT = 0;
  LIBSSH2_SFTP_LSTAT = 1;
  LIBSSH2_SFTP_SETSTAT = 2;

  //file transfer flags (LIBSSH2_FXF_*)
  LIBSSH2_FXF_READ = $00000001;
  LIBSSH2_FXF_WRITE = $00000002;
  LIBSSH2_FXF_APPEND = $00000004;
  LIBSSH2_FXF_CREAT = $00000008;
  LIBSSH2_FXF_TRUNC = $00000010;
  LIBSSH2_FXF_EXCL = $00000020;

  //permission bits (mode)
  LIBSSH2_SFTP_S_IRUSR = $0100; //0400
  LIBSSH2_SFTP_S_IWUSR = $0080; //0200
  LIBSSH2_SFTP_S_IXUSR = $0040; //0100
  LIBSSH2_SFTP_S_IRGRP = $0020; //0040
  LIBSSH2_SFTP_S_IXGRP = $0008; //0010
  LIBSSH2_SFTP_S_IROTH = $0004; //0004
  LIBSSH2_SFTP_S_IXOTH = $0001; //0001
  //0644
  LIBSSH2_SFTP_MODE_0644 = LIBSSH2_SFTP_S_IRUSR or LIBSSH2_SFTP_S_IWUSR or
    LIBSSH2_SFTP_S_IRGRP or LIBSSH2_SFTP_S_IROTH;
  //0755
  LIBSSH2_SFTP_MODE_0755 = LIBSSH2_SFTP_S_IRUSR or LIBSSH2_SFTP_S_IWUSR or
    LIBSSH2_SFTP_S_IXUSR or LIBSSH2_SFTP_S_IRGRP or LIBSSH2_SFTP_S_IXGRP or
    LIBSSH2_SFTP_S_IROTH or LIBSSH2_SFTP_S_IXOTH;

  //session disconnect reason
  SSH_DISCONNECT_BY_APPLICATION = 11;

  //sftp status codes (libssh2_sftp_last_error)
  LIBSSH2_FX_NO_SUCH_FILE = 2;

  //known_hosts
  LIBSSH2_KNOWNHOST_FILE_OPENSSH = 1;
  LIBSSH2_KNOWNHOST_TYPE_PLAIN = 1;
  LIBSSH2_KNOWNHOST_KEYENC_RAW = $00010000; //1 shl 16
  LIBSSH2_KNOWNHOST_CHECK_MATCH = 0;
  LIBSSH2_KNOWNHOST_CHECK_MISMATCH = 1;
  LIBSSH2_KNOWNHOST_CHECK_NOTFOUND = 2;
  LIBSSH2_KNOWNHOST_CHECK_FAILURE = 3;

var
  //--- session ---
  libssh2_init: function(flags: Integer): Integer; cdecl;
  libssh2_exit: procedure; cdecl;
  libssh2_session_init_ex: function(myalloc: Pointer; myfree: Pointer;
    myrealloc: Pointer; abstractPtr: Pointer): PLIBSSH2_SESSION; cdecl;
  libssh2_session_set_blocking: procedure(session: PLIBSSH2_SESSION;
    blocking: Integer); cdecl;
  libssh2_session_handshake: function(session: PLIBSSH2_SESSION;
    sock: TSocket): Integer; cdecl;
  libssh2_session_disconnect_ex: function(session: PLIBSSH2_SESSION;
    reason: Integer; description: PAnsiChar; lang: PAnsiChar): Integer; cdecl;
  libssh2_session_free: function(session: PLIBSSH2_SESSION): Integer; cdecl;
  libssh2_session_last_error: function(session: PLIBSSH2_SESSION;
    var errmsg: PAnsiChar; var errmsg_len: Integer; want_buf: Integer): Integer; cdecl;

  //--- authentication ---
  libssh2_userauth_password_ex: function(session: PLIBSSH2_SESSION;
    username: PAnsiChar; username_len: LongWord; password: PAnsiChar;
    password_len: LongWord; passwd_change_cb: Pointer): Integer; cdecl;
  libssh2_userauth_publickey_fromfile_ex: function(session: PLIBSSH2_SESSION;
    username: PAnsiChar; username_len: LongWord; publickey: PAnsiChar;
    privatekey: PAnsiChar; passphrase: PAnsiChar): Integer; cdecl;
  libssh2_userauth_authenticated: function(session: PLIBSSH2_SESSION): Integer; cdecl;

  //--- sftp ---
  libssh2_sftp_init: function(session: PLIBSSH2_SESSION): PLIBSSH2_SFTP; cdecl;
  libssh2_sftp_shutdown: function(sftp: PLIBSSH2_SFTP): Integer; cdecl;
  libssh2_sftp_open_ex: function(sftp: PLIBSSH2_SFTP; filename: PAnsiChar;
    filename_len: LongWord; flags: LongWord; mode: LongInt;
    open_type: Integer): PLIBSSH2_SFTP_HANDLE; cdecl;
  libssh2_sftp_read: function(handle: PLIBSSH2_SFTP_HANDLE; buffer: PAnsiChar;
    buffer_maxlen: NativeUInt): NativeInt; cdecl;
  libssh2_sftp_write: function(handle: PLIBSSH2_SFTP_HANDLE; buffer: PAnsiChar;
    count: NativeUInt): NativeInt; cdecl;
  libssh2_sftp_close_handle: function(handle: PLIBSSH2_SFTP_HANDLE): Integer; cdecl;
  libssh2_sftp_unlink_ex: function(sftp: PLIBSSH2_SFTP; filename: PAnsiChar;
    filename_len: LongWord): Integer; cdecl;
  libssh2_sftp_mkdir_ex: function(sftp: PLIBSSH2_SFTP; path: PAnsiChar;
    path_len: LongWord; mode: LongInt): Integer; cdecl;
  libssh2_sftp_stat_ex: function(sftp: PLIBSSH2_SFTP; path: PAnsiChar;
    path_len: LongWord; stat_type: Integer;
    attrs: PLIBSSH2_SFTP_ATTRIBUTES): Integer; cdecl;
  libssh2_sftp_last_error: function(sftp: PLIBSSH2_SFTP): LongWord; cdecl;

  //--- host key / known_hosts (optional: bind does not fail if absent) ---
  libssh2_session_hostkey: function(session: PLIBSSH2_SESSION; var len: NativeUInt;
    var keyType: Integer): PAnsiChar; cdecl;
  libssh2_knownhost_init: function(session: PLIBSSH2_SESSION): PLIBSSH2_KNOWNHOSTS; cdecl;
  libssh2_knownhost_readfile: function(hosts: PLIBSSH2_KNOWNHOSTS; filename: PAnsiChar;
    fileType: Integer): Integer; cdecl;
  libssh2_knownhost_checkp: function(hosts: PLIBSSH2_KNOWNHOSTS; host: PAnsiChar;
    port: Integer; key: PAnsiChar; keylen: NativeUInt; typemask: Integer;
    var knownhost: PLIBSSH2_KNOWNHOST): Integer; cdecl;
  libssh2_knownhost_free: procedure(hosts: PLIBSSH2_KNOWNHOSTS); cdecl;

function loadLibssh2(dllPath: string = LIBSSH2_DLL_DEFAULT): boolean;
procedure unloadLibssh2;
function isLibssh2Loaded: boolean;
function getLibssh2LastLoadError: string;

implementation

uses
  System.SysUtils, System.SyncObjs,
  Winapi.Windows;

var
  libraryHandle: HMODULE = 0;
  loadLock: TCriticalSection;
  lastLoadError: string = '';

function isLibssh2Loaded: boolean;
var
  _isLoaded: boolean;
begin
  _isLoaded := libraryHandle <> 0;

  Result := _isLoaded;
end;

function getLibssh2LastLoadError: string;
begin
  Result := lastLoadError;
end;

function getProc(procName: string): Pointer;
var
  _address: Pointer;
begin
  _address := GetProcAddress(libraryHandle, PChar(procName));
  if _address = nil then
  begin
    raise Exception.create('libssh2: symbol not found -> ' + procName);
  end;

  Result := _address;
end;

function getProcOptional(procName: string): Pointer;
begin
  Result := GetProcAddress(libraryHandle, PChar(procName));
end;

procedure bindAllProcs;
begin
  @libssh2_init := getProc('libssh2_init');
  @libssh2_exit := getProc('libssh2_exit');
  @libssh2_session_init_ex := getProc('libssh2_session_init_ex');
  @libssh2_session_set_blocking := getProc('libssh2_session_set_blocking');
  @libssh2_session_handshake := getProc('libssh2_session_handshake');
  @libssh2_session_disconnect_ex := getProc('libssh2_session_disconnect_ex');
  @libssh2_session_free := getProc('libssh2_session_free');
  @libssh2_session_last_error := getProc('libssh2_session_last_error');

  @libssh2_userauth_password_ex := getProc('libssh2_userauth_password_ex');
  @libssh2_userauth_publickey_fromfile_ex := getProc('libssh2_userauth_publickey_fromfile_ex');
  @libssh2_userauth_authenticated := getProc('libssh2_userauth_authenticated');

  @libssh2_sftp_init := getProc('libssh2_sftp_init');
  @libssh2_sftp_shutdown := getProc('libssh2_sftp_shutdown');
  @libssh2_sftp_open_ex := getProc('libssh2_sftp_open_ex');
  @libssh2_sftp_read := getProc('libssh2_sftp_read');
  @libssh2_sftp_write := getProc('libssh2_sftp_write');
  @libssh2_sftp_close_handle := getProc('libssh2_sftp_close_handle');
  @libssh2_sftp_unlink_ex := getProc('libssh2_sftp_unlink_ex');
  @libssh2_sftp_mkdir_ex := getProc('libssh2_sftp_mkdir_ex');
  @libssh2_sftp_stat_ex := getProc('libssh2_sftp_stat_ex');

  @libssh2_sftp_last_error := getProcOptional('libssh2_sftp_last_error');
  @libssh2_session_hostkey := getProcOptional('libssh2_session_hostkey');
  @libssh2_knownhost_init := getProcOptional('libssh2_knownhost_init');
  @libssh2_knownhost_readfile := getProcOptional('libssh2_knownhost_readfile');
  @libssh2_knownhost_checkp := getProcOptional('libssh2_knownhost_checkp');
  @libssh2_knownhost_free := getProcOptional('libssh2_knownhost_free');
end;

function loadLibssh2(dllPath: string = LIBSSH2_DLL_DEFAULT): boolean;
var
  _isLoaded: boolean;
  _errorCode: Cardinal;
begin
  loadLock.Enter;
  try
    if isLibssh2Loaded then
    begin
      Result := true;
      Exit;
    end;

    _isLoaded := false;
    libraryHandle := LoadLibrary(PChar(dllPath));
    if libraryHandle = 0 then
    begin
      _errorCode := GetLastError;
      lastLoadError := 'Win32 error ' + IntToStr(_errorCode) + ': ' + SysErrorMessage(_errorCode);
    end
    else
    begin
      try
        bindAllProcs;
        _isLoaded := true;
        lastLoadError := '';
      except
        on E: Exception do
        begin
          lastLoadError := E.Message;
          FreeLibrary(libraryHandle);
          libraryHandle := 0;
        end;
      end;
    end;

    Result := _isLoaded;
  finally
    loadLock.Leave;
  end;
end;

procedure unloadLibssh2;
begin
  loadLock.Enter;
  try
    if isLibssh2Loaded then
    begin
      FreeLibrary(libraryHandle);
      libraryHandle := 0;
    end;
  finally
    loadLock.Leave;
  end;
end;

initialization

loadLock := TCriticalSection.Create;

finalization

FreeAndNil(loadLock);

end.
