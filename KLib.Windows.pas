{
  KLib Version = 2.0
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

unit KLib.Windows;

interface

uses
  KLib.Types, Klib.Constants,
  Winapi.Windows, Winapi.ShellApi, Winapi.AccCtrl,
  System.Classes;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
function getFirstPortAvaliable(defaultPort: integer; host: string = LOCALHOST_IP_ADDRESS): integer;
function checkIfPortIsAvaliable(host: string; port: Word): boolean;
function checkIfAddressIsLocalhost(address: string): boolean;
function getIPFromHostName(hostName: string): string; //if hostname is alredy an ip address, returns hostname
function getIP: string;

function checkIfRunUnderWine: boolean;
function checkIfWindowsArchitectureIsX64: boolean;

type
  TWindowsArchitecture = (WindowsX86, WindowsX64);
function getWindowsArchitecture: TWindowsArchitecture;
function checkIfUserIsAdmin: boolean;
function IsUserAnAdmin: boolean; external shell32; //KEPT THE SIGNATURE, NOT RENAME!!!

type
  TShowWindowType = (
    SW_HIDE = Winapi.Windows.SW_HIDE,
    SW_SHOWNORMAL = Winapi.Windows.SW_SHOWNORMAL,
    SW_NORMAL = Winapi.Windows.SW_NORMAL,
    SW_SHOWMINIMIZED = Winapi.Windows.SW_SHOWMINIMIZED,
    SW_SHOWMAXIMIZED = Winapi.Windows.SW_SHOWMAXIMIZED,
    SW_MAXIMIZE = Winapi.Windows.SW_MAXIMIZE,
    SW_SHOWNOACTIVATE = Winapi.Windows.SW_SHOWNOACTIVATE,
    SW_SHOW = Winapi.Windows.SW_SHOW,
    SW_MINIMIZE = Winapi.Windows.SW_MINIMIZE,
    SW_SHOWMINNOACTIVE = Winapi.Windows.SW_SHOWMINNOACTIVE,
    SW_SHOWNA = Winapi.Windows.SW_SHOWNA,
    SW_RESTORE = Winapi.Windows.SW_RESTORE,
    SW_SHOWDEFAULT = Winapi.Windows.SW_SHOWDEFAULT,
    SW_FORCEMINIMIZE = Winapi.Windows.SW_FORCEMINIMIZE,
    SW_MAX = Winapi.Windows.SW_MAX
    );

procedure openWebPageWithDefaultBrowser(url: string);

function shellExecuteExeAsAdmin(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType.SW_HIDE;
  exceptionIfFunctionFails: boolean = false): integer;
function shellExecuteExe(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType.SW_HIDE;
  exceptionIfFunctionFails: boolean = false; operation: string = 'open'): integer;

function shellExecuteExCMDAndWait(params: string; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType.SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
function shellExecuteExAndWait(fileName: string; params: string = ''; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType.SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
function executeAndWaitExe(fileName: string; params: string = ''; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;

function netShare(targetDir: string; netName: string = ''; netPassw: string = '';
  grantAllPermissionToEveryoneGroup: boolean = false): string;
procedure addTCP_IN_FirewallException(ruleName: string; port: Word; description: string = ''; grouping: string = '';
  executable: string = '');
procedure deleteFirewallException(ruleName: string);

type
  TExplicitAccess = EXPLICIT_ACCESS_A;
procedure grantAllPermissionsNetToTheObjectForTheEveryoneGroup(myObject: string);
procedure grantAllPermissionNetToTheObject(windowsGroupOrUser: string; myObject: string);
procedure grantAllPermissionsToTheObjectForTheEveryoneGroup(myObject: string);
procedure grantAllPermissionsToTheObjectForTheUsersGroup(myObject: string);
procedure grantAllPermissionsToTheObject(windowsGroupOrUser: string; myObject: string);

function checkIfWindowsGroupOrUserExists(windowsGroupOrUser: string): boolean;

procedure createDesktopLink(fileName: string; nameDesktopLink: string; description: string);
function getDesktopDirPath: string;

procedure copyDirIntoTargetDir(sourceDir: string; targetDir: string; forceOverwrite: boolean = false);
procedure copyDir(sourceDir: string; destinationDir: string; silent: boolean = true);
procedure createHideDir(dirName: string; forceDelete: boolean = false);
procedure deleteDirectoryIfExists(dirName: string; silent: boolean = true);

procedure myMoveFile(sourceFileName: string; targetFileName: string);

procedure createEmptyFileIfNotExists(filename: string);
procedure createEmptyFile(filename: string);

function checkIfIsWindowsSubDir(subDir: string; mainDir: string): boolean;
function getParentDir(source: string): string;
function getValidFullPathInWindowsStyle(path: string): string;
function getPathInWindowsStyle(path: string): string;

function getStringWithEnvVariablesReaded(source: string): string;
//-----------------------------------------------------------------
//TODO REFACTOR
function setProcessWindowToForeground(processName: string): boolean;
function getPIDOfCurrentUserByProcessName(nameProcess: string): DWORD;
function getWindowsUsername: string;
function checkUserOfProcess(userName: String; PID: DWORD): boolean;
function getPIDCredentials(PID: DWORD): TPIDCredentials;
function getPIDByProcessName(nameProcess: string): DWORD;
function getMainWindowHandleByPID(PID: DWORD): DWORD;
//------------------------------------------------------------------

procedure closeApplication(handle: THandle);
function sendMemoryStreamUsing_WM_COPYDATA(handle: THandle; data: TMemoryStream): integer;
function sendStringUsing_WM_COPYDATA(handle: THandle; data: string; msgIdentifier: integer = 0): integer;
procedure mySetForegroundWindow(handle: THandle);
function checkIfWindowExists(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm'): boolean;
function myFindWindow(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm'): THandle;

function checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key: string): boolean;

procedure waitForMultiple(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = true);
procedure waitFor(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = true);

procedure raiseLastSysErrorMessage;
function getLastSysErrorMessage: string;

function getLocaleDecimalSeparator: char;

implementation

uses
  KLib.Utils, KLib.Validate,
  Vcl.Forms,
  Winapi.ACLAPI, Winapi.TLHelp32, Winapi.ActiveX, Winapi.Shlobj, Winapi.Winsock, Winapi.UrlMon, Winapi.Messages,
  System.SysUtils, System.Win.ComObj, System.Win.Registry,
  IdTCPClient;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
const
  ERR_MSG = 'Error downloading file.';
var
  _downloadSuccess: boolean;
begin
  with info do
  begin
    if forceOverwrite then
    begin
      deleteFileIfExists(fileName);
    end;
    _downloadSuccess := URLDownloadToFile(nil, pChar(link), pchar(fileName), 0, nil) = S_OK;
    if not _downloadSuccess then
    begin
      raise Exception.Create(ERR_MSG);
    end;
    if md5 <> '' then
    begin
      validateMD5File(fileName, md5, ERR_MSG);
    end;
  end;
end;

function getFirstPortAvaliable(defaultPort: integer; host: string = LOCALHOST_IP_ADDRESS): integer;
var
  _port: integer;
begin
  _port := defaultPort;
  while not checkIfPortIsAvaliable(host, _port) do
  begin
    inc(_port);
  end;
  result := _port;
end;

function checkIfPortIsAvaliable(host: string; port: Word): boolean;
var
  IdTCPClient: TIdTCPClient;
begin
  Result := True;
  try
    IdTCPClient := TIdTCPClient.Create(nil);
    try
      IdTCPClient.Host := host;
      IdTCPClient.Port := port;
      IdTCPClient.Connect;
      Result := False;
    finally
      IdTCPClient.Free;
    end;
  except
    //Ignore exceptions
  end;
end;

function checkIfAddressIsLocalhost(address: string): boolean;
var
  _address: string;
  _localhostIP_address: string;

  _result: boolean;
begin
  _result := true;
  _address := getIPFromHostName(address);
  if _address <> LOCALHOST_IP_ADDRESS then
  begin
    _localhostIP_address := getIP;
    if _address <> _localhostIP_address then
    begin
      _result := false;
    end;
  end;
  Result := _result;
end;

function getIPFromHostName(hostName: string): string;
const
  ERR_WINSOCK_MSG = 'Winsock initialization error.';
  ERR_NO_IP_FOUND_WITH_HOSTBAME_MSG = 'No IP found with hostname: ';
var
  varTWSAData: TWSAData;
  varPHostEnt: PHostEnt;
  varTInAddr: TInAddr;
  ip: string;
begin
  if WSAStartup($101, varTWSAData) <> 0 then
  begin
    raise Exception.Create(ERR_WINSOCK_MSG);
  end
  else
  begin
    try
      varPHostEnt := gethostbyname(PAnsiChar(AnsiString(hostName)));
      varTInAddr := PInAddr(varPHostEnt^.h_Addr_List^)^;
      ip := String(inet_ntoa(varTInAddr));
    except
      on E: Exception do
      begin
        WSACleanup;
        raise Exception.Create(ERR_NO_IP_FOUND_WITH_HOSTBAME_MSG + hostName);
      end;
    end;
  end;
  WSACleanup;
  Result := ip;
end;

function getIP: string;
type
  pu_long = ^u_long;
const
  ERR_MSG = 'Winsock initialization error.';
var
  varTWSAData: TWSAData;
  varPHostEnt: PHostEnt;
  varTInAddr: TInAddr;
  namebuf: Array [0 .. 255] of ansichar;
  ip: string;
begin
  if WSAStartup($101, varTWSAData) <> 0 then
  begin
    raise Exception.Create(ERR_MSG);
  end
  else
  begin
    getHostName(nameBuf, sizeOf(nameBuf));
    varPHostEnt := gethostbyname(nameBuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    ip := string(inet_ntoa(varTInAddr));
  end;
  WSACleanup;
  Result := ip;
end;

function checkIfRunUnderWine: boolean;
const
  KEY_WINE = 'Software\Wine';
begin
  Result := checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(KEY_WINE);
end;

function checkIfWindowsArchitectureIsX64: boolean;
var
  _WindowsArchitecture: TWindowsArchitecture;
begin
  _WindowsArchitecture := getWindowsArchitecture;
  Result := _WindowsArchitecture = TWindowsArchitecture.WindowsX64;
end;

function getWindowsArchitecture: TWindowsArchitecture;
const
  ERR_MSG_PLATFORM = 'The OS. is not Windows.';
  ERR_MSG_ARCHITECTURE = 'Unknown OS architecture.';
begin
  if TOSVersion.Platform <> pfWindows then
  begin
    raise Exception.Create(ERR_MSG_PLATFORM);
  end;
  case TOSVersion.Architecture of
    arIntelX86:
      Result := TWindowsArchitecture.WindowsX86;
    arIntelX64:
      Result := TWindowsArchitecture.WindowsX64;
  else
    begin
      raise Exception.Create(ERR_MSG_ARCHITECTURE);
    end;
  end;
end;

function checkIfUserIsAdmin: boolean;
begin
  Result := IsUserAnAdmin;
end;

procedure openWebPageWithDefaultBrowser(url: string);
begin
  ShellExecute(0, 'open', PChar(url), nil, nil, Winapi.Windows.SW_NORMAL);
end;

function shellExecuteExeAsAdmin(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType.SW_HIDE;
  exceptionIfFunctionFails: boolean = false): integer;
var
  _result: integer;
begin
  _result := shellExecuteExe(fileName, params, showWindowType, exceptionIfFunctionFails, 'runas');
  Result := _result;
end;

function shellExecuteExe(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType.SW_HIDE;
  exceptionIfFunctionFails: boolean = false; operation: string = 'open'): integer;
var
  _returnCode: integer;
  errMsg: string;
begin
  _returnCode := shellExecute(0, pchar(operation), pchar(getDoubleQuotedString(fileName)), PCHAR(trim(params)),
    pchar(ExtractFileDir(fileName)), integer(showWindowType));

  if exceptionIfFunctionFails then
  begin
    case _returnCode of
      0:
        errMsg := 'The operating system is out of memory or resources.';
      2:
        errMsg := 'The specified file was not found';
      3:
        errMsg := 'The specified path was not found.';
      5:
        errMsg := 'Windows 95 only: The operating system denied access to the specified file';
      8:
        errMsg := 'Windows 95 only: There was not enough memory to complete the operation.';
      10:
        errMsg := 'Wrong Windows version';
      11:
        errMsg := 'The .EXE file is invalid (non-Win32 .EXE or error in .EXE image)';
      12:
        errMsg := 'Application was designed for a different operating system';
      13:
        errMsg := 'Application was designed for MS-DOS 4.0';
      15:
        errMsg := 'Attempt to load a real-mode program';
      16:
        errMsg := 'Attempt to load a second instance of an application with non-readonly data segments.';
      19:
        errMsg := 'Attempt to load a compressed application file.';
      20:
        errMsg := 'Dynamic-link library (DLL) file failure.';
      26:
        errMsg := 'A sharing violation occurred.';
      27:
        errMsg := 'The filename association is incomplete or invalid.';
      28:
        errMsg := 'The DDE transaction could not be completed because the request timed out.';
      29:
        errMsg := 'The DDE transaction failed.';
      30:
        errMsg := 'The DDE transaction could not be completed because other DDE transactions were being processed.';
      31:
        errMsg := 'There is no application associated with the given extension.';
      32:
        errMsg := 'Windows 95 only: The specified dynamic-link library was not found.';
    else
      errMsg := '';
    end;

    if errMsg <> '' then
    begin
      raise Exception.Create(errMsg);
    end;
  end;

  result := _returnCode;
end;

function shellExecuteExCMDAndWait(params: string; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType.SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
begin
  result := shellExecuteExAndWait(CMD_EXE_NAME, params, runAsAdmin, showWindowType, exceptionIfReturnCodeIsNot0);
end;

function shellExecuteExAndWait(fileName: string; params: string = ''; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType.SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
var
  _shellExecuteInfo: TShellExecuteInfo;

  returnCode: Longint;
begin
  returnCode := -1;

  FillChar(_shellExecuteInfo, SizeOf(_shellExecuteInfo), 0);
  with _shellExecuteInfo do
  begin
    cbSize := SizeOf(_shellExecuteInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    Wnd := GetActiveWindow();
    if (runAsAdmin) then
    begin
      _shellExecuteInfo.lpVerb := 'runas';
    end
    else
    begin
      _shellExecuteInfo.lpVerb := '';
    end;
    _shellExecuteInfo.lpParameters := PChar(trim(params));
    lpFile := PChar(FileName);
    nShow := integer(showWindowType);
  end;
  if not ShellExecuteEx(@_shellExecuteInfo) then
  begin
    raiseLastSysErrorMessage;
  end;

  //TODO CHECK
  waitForMultiple(_shellExecuteInfo.hProcess);
  //  waitFor(_shellExecuteInfo.hProcess);

  if not GetExitCodeProcess(_shellExecuteInfo.hProcess, dword(returnCode)) then //assign return code
  begin
    raiseLastSysErrorMessage;
  end;

  CloseHandle(_shellExecuteInfo.hProcess);

  if (exceptionIfReturnCodeIsNot0) and (returnCode <> 0) then
  begin
    raise Exception.Create(fileName + ' exit code: ' + IntToStr(returnCode));
  end;

  Result := returnCode;
end;

function executeAndWaitExe(fileName: string; params: string = ''; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
var
  _commad: String;
  _startupInfo: TStartupInfo;
  _processInfo: TProcessInformation;

  returnCode: Longint;
begin
  returnCode := -1;

  _commad := getDoubleQuotedString(fileName) + ' ' + trim(params);

  FillChar(_startupInfo, sizeOf(_startupInfo), 0);
  with _startupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := Winapi.Windows.SW_HIDE;
  end;
  if not CreateProcess(nil, pchar(_commad), nil, nil, false,
    //   CREATE_NO_WINDOW,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, //TODO check if is ok
    nil, nil, _startupInfo, _processInfo) then
  begin
    raiseLastSysErrorMessage;
  end;

  //TODO CHECK
  waitForMultiple(_processInfo.hProcess);
  //  waitFor(_processInfo.hProcess);

  if not GetExitCodeProcess(_processInfo.hProcess, dword(returnCode)) then //assign return code
  begin
    raiseLastSysErrorMessage;
  end;

  CloseHandle(_processInfo.hProcess);
  CloseHandle(_processInfo.hThread);

  if (exceptionIfReturnCodeIsNot0) and (returnCode <> 0) then
  begin
    raise Exception.Create(fileName + ' exit code: ' + IntToStr(returnCode));
  end;

  Result := returnCode;
end;

type
  //----------------------------------
  SHARE_INFO_2 = record
    shi2_netname: pWideChar;
    shi2_type: DWORD;
    shi2_remark: pWideChar;
    shi2_permissions: DWORD;
    shi2_max_uses: DWORD;
    shi2_current_uses: DWORD;
    shi2_path: pWideChar;
    shi2_passwd: pWideChar;
  end;

  PSHARE_INFO_2 = ^SHARE_INFO_2;

function netShareAdd(servername: PWideChar; level: DWORD; buf: Pointer; parm_err: LPDWORD): DWORD; stdcall;
  external 'NetAPI32.dll' name 'NetShareAdd';

function netShare(targetDir: string; netName: string = ''; netPassw: string = '';
  grantAllPermissionToEveryoneGroup: boolean = false): string;
const
  NERR_SUCCESS = 0;
  STYPE_DISKTREE = 0;
  STYPE_PRINTQ = 1;
  STYPE_DEVICE = 2;
  STYPE_IPC = 3;
  ACCESS_READ = $01;
  ACCESS_WRITE = $02;
  ACCESS_CREATE = $04;
  ACCESS_EXEC = $08;
  ACCESS_DELETE = $10;
  ACCESS_ATRIB = $20;
  ACCESS_PERM = $40;
  ACCESS_ALL = ACCESS_READ or ACCESS_WRITE or ACCESS_CREATE or ACCESS_EXEC or ACCESS_DELETE or ACCESS_ATRIB or ACCESS_PERM;

  ERR_MSG = 'Unable to share folder :';
var
  _targetDir: string;
  AShareInfo: PSHARE_INFO_2;
  parmError: DWORD;
  pathSharedDir: string;
  shareExistsAlready: boolean;

  _errMsg: string;
begin
  shareExistsAlready := false;
  _targetDir := getValidFullPathInWindowsStyle(targetDir);
  AShareInfo := New(PSHARE_INFO_2);
  try
    with AShareInfo^ do
    begin
      if (netName = '') then
      begin
        shi2_netname := PWideChar(extractfilename(_targetDir));
      end
      else
      begin
        shi2_netname := PWideChar(netName);
      end;
      shi2_type := STYPE_DISKTREE;
      shi2_remark := nil;
      shi2_permissions := ACCESS_ALL;
      shi2_max_uses := DWORD(-1); // Maximum allowed
      shi2_current_uses := 0;
      shi2_path := PWideChar(_targetDir);
      if (netPassw = '') then
      begin
        shi2_passwd := nil;
      end
      else
      begin
        shi2_passwd := PWideChar(netPassw);
      end;
    end;

    if (netShareAdd(nil, 2, PBYTE(AShareInfo), @parmError) <> NERR_SUCCESS) then
    begin
      shareExistsAlready := true;
    end;
    if not DirectoryExists(pathSharedDir) then
    begin
      _errMsg := ERR_MSG + getDoubleQuotedString(_targetDir);
      raise Exception.Create(_errMsg);
    end;
    pathSharedDir := '\\' + GetEnvironmentVariable('COMPUTERNAME') + '\' + AShareInfo.shi2_netname;
    if not(shareExistsAlready) and (grantAllPermissionToEveryoneGroup) then
    begin
      grantAllPermissionsNetToTheObjectForTheEveryoneGroup(pathSharedDir);
    end;
  finally
    FreeMem(AShareInfo, SizeOf(PSHARE_INFO_2));
  end;

  Result := pathSharedDir;
end;

procedure addTCP_IN_FirewallException(ruleName: string; port: Word; description: string = ''; grouping: string = '';
  executable: String = '');
const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;

  PROFILES = NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC OR NET_FW_PROFILE2_DOMAIN;

  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_ACTION_ALLOW = 1;
  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;
var
  FwPolicy2: OleVariant;
  rules: OleVariant;
  newFWRule: OleVariant;
begin
  CoInitialize(nil);

  newFWRule := CreateOleObject('HNetCfg.FWRule');
  newFWRule.Name := ruleName;
  if (description <> '') then
  begin
    newFWRule.Description := description;
  end
  else
  begin
    newFWRule.Description := ruleName;
  end;

  if (executable <> '') then
  begin
    newFWRule.Applicationname := executable;
  end;
  newFWRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  newFWRule.LocalPorts := port;
  newFWRule.Direction := NET_FW_RULE_DIR_IN;
  newFWRule.Enabled := TRUE;
  if (grouping <> '') then
  begin
    newFWRule.Grouping := grouping;
  end;
  newFWRule.Profiles := PROFILES;
  newFWRule.Action := NET_FW_ACTION_ALLOW;
  FwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  rules := FwPolicy2.Rules;
  rules.Add(newFWRule);

  CoUninitialize;
end;

procedure deleteFirewallException(ruleName: string);
var
  FwPolicy2: OleVariant;
  rules: OleVariant;
begin
  CoInitialize(nil);

  FwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  rules := FwPolicy2.Rules;
  rules.Remove(ruleName);

  CoUninitialize;
end;

procedure grantAllPermissionsNetToTheObjectForTheEveryoneGroup(myObject: string);
begin
  grantAllPermissionNetToTheObject(EVERYONE_GROUP, myObject);
end;

procedure grantAllPermissionNetToTheObject(windowsGroupOrUser: string; myObject: string);
var
  NewDacl, OldDacl: PACl;
  SD: PSECURITY_DESCRIPTOR;
  EA: TExplicitAccess;
begin
  validateThatWindowsGroupOrUserExists(windowsGroupOrUser);

  GetNamedSecurityInfo(PChar(myObject), SE_LMSHARE, DACL_SECURITY_INFORMATION, nil, nil, @OldDacl, nil, SD);
  BuildExplicitAccessWithName(@EA, PChar(windowsGroupOrUser), GENERIC_ALL, GRANT_ACCESS, SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @EA, OldDacl, NewDacl);
  SetNamedSecurityInfo(PChar(myObject), SE_LMSHARE, DACL_SECURITY_INFORMATION, nil, nil, NewDacl, nil);
end;

procedure grantAllPermissionsToTheObjectForTheEveryoneGroup(myObject: string);
begin
  grantAllPermissionsToTheObject(EVERYONE_GROUP, myObject);
end;

procedure grantAllPermissionsToTheObjectForTheUsersGroup(myObject: string);
begin
  grantAllPermissionsToTheObject(USERS_GROUP, myObject);
end;

procedure grantAllPermissionsToTheObject(windowsGroupOrUser: string; myObject: string);
var
  newDACL: PACl;
  oldDACL: PACl;
  securityDescriptor: PSECURITY_DESCRIPTOR;
  explicitAccess: TExplicitAccess;
begin
  validateThatWindowsGroupOrUserExists(windowsGroupOrUser);

  GetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, @oldDACL,
    nil, securityDescriptor);
  BuildExplicitAccessWithName(@explicitAccess, PChar(windowsGroupOrUser), GENERIC_ALL, GRANT_ACCESS,
    SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @explicitAccess, oldDACL, newDACL);
  SetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, newDACL, nil);
end;

function checkIfWindowsGroupOrUserExists(windowsGroupOrUser: string): boolean;
var
  _newDACL: PACl;
  _explicitAccess: TExplicitAccess;

  _result: boolean;
begin
  BuildExplicitAccessWithName(@_explicitAccess, PChar(windowsGroupOrUser), GENERIC_ALL, GRANT_ACCESS,
    SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @_explicitAccess, nil, _newDACL);
  _result := Assigned(_newDACL);
  Result := _result;
end;

procedure createDesktopLink(fileName: string; nameDesktopLink: string; description: string);
const
  ERR_MSG = 'Error creating desktop icon.';
var
  iobject: iunknown;
  islink: ishelllink;
  ipfile: ipersistfile;
  pidl: pitemidlist;
  infolder: array [0 .. MAX_PATH] of char;
  targetName: string;
  linkname: string;
  _desktopDirPath: string;
begin
  targetname := getValidFullPathInWindowsStyle(fileName);
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile := IObject as IPersistFile;

  with ISLink do
  begin
    SetDescription(PChar(description));
    SetPath(PChar(targetName));
    SetWorkingDirectory(PChar(ExtractFilePath(targetName)));
  end;

  SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList(PIDL, InFolder);

  _desktopDirPath := getDesktopDirPath;
  LinkName := IncludeTrailingPathDelimiter(_desktopDirPath);
  LinkName := LinkName + nameDesktopLink + '.lnk';

  if not IPFile.Save(PWideChar(LinkName), False) = S_OK then
  begin
    raise Exception.Create(ERR_MSG);
  end;
end;

function getDesktopDirPath: string;
var
  PIDList: PItemIDList;
  Buffer: array [0 .. MAX_PATH - 1] of Char;
begin
  Result := '';
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, PIDList);
  if Assigned(PIDList) then
  begin
    if SHGetPathFromIDList(PIDList, Buffer) then
    begin
      Result := Buffer;
    end;
  end;
end;

procedure copyDirIntoTargetDir(sourceDir: string; targetDir: string; forceOverwrite: boolean = false);
const
  ERR_MSG = 'Cannot rename: ';
var
  _parentDirTargetDir: string;
  _sourceDirName: string;
  _tempTargetDir: string;

  _err_msg: string;
begin
  if forceOverwrite then
  begin
    deleteDirectoryIfExists(targetDir);
  end
  else
  begin
    validateThatDirNotExists(targetDir);
  end;

  _parentDirTargetDir := getParentDir(targetDir);
  _sourceDirName := ExtractFileName(getValidFullPathInWindowsStyle(sourceDir));
  _tempTargetDir := getCombinedPath(_parentDirTargetDir, _sourceDirName);
  copyDir(sourceDir, _parentDirTargetDir);
  if not RenameFile(_tempTargetDir, targetDir) then
  begin
    _err_msg := ERR_MSG + getDoubleQuotedString(_tempTargetDir);
    raise Exception.Create(_err_msg);
  end;
end;

const
  SILENT_FLAGS: FILEOP_FLAGS = FOF_SILENT or FOF_NOCONFIRMATION;

procedure copyDir(sourceDir: string; destinationDir: string; silent: boolean = true);
var
  sHFileOpStruct: TSHFileOpStruct;
  shFileOperationResult: integer;
begin
  ZeroMemory(@sHFileOpStruct, SizeOf(sHFileOpStruct));
  with sHFileOpStruct do
  begin
    wFunc := FO_COPY;
    pFrom := PChar(sourceDir + #0);
    pTo := PChar(destinationDir);
    if silent then
    begin
      fFlags := FOF_FILESONLY or SILENT_FLAGS;
    end
    else
    begin
      fFlags := FOF_FILESONLY;
    end;
  end;
  shFileOperationResult := ShFileOperation(sHFileOpStruct);
  if shFileOperationResult <> 0 then
  begin
    raise Exception.Create('Unable to copy ' + sourceDir + ' to ' + destinationDir);
  end;
end;

procedure createHideDir(dirName: string; forceDelete: boolean = false);
const
  ERR_MSG = 'Error creating hide dir.';
begin
  if forceDelete then
  begin
    deleteDirectoryIfExists(dirName);
  end;

  if CreateDir(dirName) then
  begin
    SetFileAttributes(pchar(dirName), FILE_ATTRIBUTE_HIDDEN);
  end
  else
  begin
    raise Exception.Create(ERR_MSG);
  end;
end;

procedure deleteDirectoryIfExists(dirName: string; silent: boolean = true);
const
  ERR_MSG = 'Unable to delete :';
var
  sHFileOpStruct: TSHFileOpStruct;
  shFileOperationResult: integer;

  errMsg: string;
begin
  if DirectoryExists(dirName) then
  begin
    ZeroMemory(@sHFileOpStruct, SizeOf(sHFileOpStruct));
    with sHFileOpStruct do
    begin
      wFunc := FO_DELETE;
      pFrom := PChar(DirName + #0); //double zero-terminated
      if silent then
      begin
        fFlags := SILENT_FLAGS;
      end
    end;
    shFileOperationResult := SHFileOperation(sHFileOpStruct);
    if (shFileOperationResult <> 0) or (DirectoryExists(dirName)) then
    begin
      errMsg := ERR_MSG + dirName;
      raise Exception.Create(errMsg);
    end;
  end;
end;

procedure myMoveFile(sourceFileName: string; targetFileName: string);
var
  _result: boolean;
begin
  _result := MoveFile(pchar(sourceFileName), pchar(targetFileName));
  if not _result then
  begin
    raiseLastSysErrorMessage;
  end;
end;

procedure createEmptyFileIfNotExists(filename: string);
begin
  if not FileExists(filename) then
  begin
    createEmptyFile(filename);
  end;
end;

procedure createEmptyFile(filename: string);
var
  _handle: THandle;
begin
  _handle := FileCreate(fileName);
  if _handle = INVALID_HANDLE_VALUE then
  begin
    raise Exception.Create('Error creating file: ' + fileName);
  end
  else
  begin
    FileClose(_handle);
  end;
end;

function checkIfIsWindowsSubDir(subDir: string; mainDir: string): boolean;
var
  _subDir: string;
  _mainDir: string;
  _isSubDir: Boolean;
begin
  _subDir := getPathInWindowsStyle(subDir);
  _mainDir := getPathInWindowsStyle(mainDir);
  _isSubDir := checkIfIsSubDir(_subDir, _mainDir);
  result := _isSubDir
end;

function getParentDir(source: string): string;
var
  parentDir: string;
begin
  parentDir := getValidFullPathInWindowsStyle(source);
  parentDir := ExtractFilePath(parentDir);
  result := parentDir;
end;

function getValidFullPathInWindowsStyle(path: string): string;
var
  _path: string;
begin
  _path := getValidFullPath(path);
  _path := getPathInWindowsStyle(_path);
  result := _path;
end;

function getPathInWindowsStyle(path: string): string;
var
  _path: string;
begin
  _path := StringReplace(path, '/', '\', [rfReplaceAll, rfIgnoreCase]);
  result := _path;
end;

function getStringWithEnvVariablesReaded(source: string): string;
var
  tempStringDir: string;
  tempStringPos: string;
  posStart: integer;
  posEnd: integer;
  valueToReplace: string;
  newValue: string;
  _result: string;
begin
  tempStringPos := source;
  tempStringDir := source;
  _result := source;
  repeat
    posStart := pos('%', tempStringPos);
    tempStringPos := copy(tempStringPos, posStart + 1, length(tempStringPos));
    posEnd := posStart + pos('%', tempStringPos);
    if (posStart > 0) and (posEnd > 1) then
    begin
      valueToReplace := copy(tempStringDir, posStart, posEnd - posStart + 1);
      newValue := GetEnvironmentVariable(copy(valueToReplace, 2, length(valueToReplace) - 2));
      if newValue <> '' then
      begin
        _result := stringreplace(_result, valueToReplace, newValue, []);
      end;
    end
    else
    begin
      exit;
    end;
    tempStringDir := copy(tempStringDir, posEnd + 1, length(tempStringDir));
    tempStringPos := tempStringDir;
  until posStart < 0;

  Result := _result;
end;

//----------------------------------------------------------------------
function setProcessWindowToForeground(processName: string): boolean;
var
  PIDProcess: DWORD;
  windowHandle: THandle;
begin
  PIDProcess := getPIDOfCurrentUserByProcessName(processName);
  windowHandle := getMainWindowHandleByPID(PIDProcess);

  if windowHandle <> 0 then
  begin
    mySetForegroundWindow(windowHandle);
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

type
  TProcessCompare = record
    username: string;
    nameProcess: string;
  end;

  TFunctionProcessCompare = function(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean;

function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD; forward;
function checkProcessUserName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; forward;

function getPIDOfCurrentUserByProcessName(nameProcess: string): DWORD;
var
  processCompare: TProcessCompare;
begin
  processCompare.nameProcess := nameProcess;
  processCompare.username := getWindowsUsername();
  result := getPID(nameProcess, checkProcessUserName, processCompare);
end;

function getWindowsUsername: string;
var
  userName: string;
  userNameLen: DWORD;
begin
  userNameLen := 256;
  SetLength(userName, userNameLen);
  if GetUserName(PChar(userName), userNameLen) then
  begin
    Result := Copy(userName, 1, userNameLen - 1);
  end
  else
  begin
    Result := '';
  end;
end;

function checkProcessName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; forward;

function checkProcessUserName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
var
  sameProcessName: boolean;
  sameUserOfProcess: boolean;
begin
  sameProcessName := checkProcessName(processEntry, processCompare);
  sameUserOfProcess := checkUserOfProcess(processCompare.username, processEntry.th32ProcessID);
  Result := sameProcessName and sameUserOfProcess;
end;

//TODO: CREARE CLASSE PER RAGGUPPARE OGGETTI

function checkUserOfProcess(userName: String; PID: DWORD): boolean;
var
  PIDCredentials: TPIDCredentials;
begin
  PIDCredentials := getPIDCredentials(PID);
  if PIDCredentials.ownerUserName = userName then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
  end;
end;

type
  _TOKEN_USER = record
    User: TSidAndAttributes;
  end;

  PTOKEN_USER = ^_TOKEN_USER;

function getPIDCredentials(PID: DWORD): TPIDCredentials;
var
  hToken: THandle;
  cbBuf: Cardinal;
  ptiUser: PTOKEN_USER;
  snu: SID_NAME_USE;
  processHandle: THandle;
  UserSize, DomainSize: DWORD;
  bSuccess: Boolean;
  user: string;
  domain: string;
  PIDCredentials: TPIDCredentials;
begin
  processHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
  if processHandle <> 0 then
  begin
    if OpenProcessToken(processHandle, TOKEN_QUERY, hToken) then
    begin
      bSuccess := GetTokenInformation(hToken, TokenUser, nil, 0, cbBuf);
      ptiUser := nil;
      while (not bSuccess) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) do
      begin
        ReallocMem(ptiUser, cbBuf);
        bSuccess := GetTokenInformation(hToken, TokenUser, ptiUser, cbBuf, cbBuf);
      end;
      CloseHandle(hToken);

      if not bSuccess then
      begin
        Exit;
      end;

      UserSize := 0;
      DomainSize := 0;
      LookupAccountSid(nil, ptiUser.User.Sid, nil, UserSize, nil, DomainSize, snu);
      if (UserSize <> 0) and (DomainSize <> 0) then
      begin
        SetLength(User, UserSize);
        SetLength(Domain, DomainSize);
        if LookupAccountSid(nil, ptiUser.User.Sid, PChar(User), UserSize,
          PChar(Domain), DomainSize, snu) then
        begin
          PIDCredentials.ownerUserName := StrPas(PChar(User));
          PIDCredentials.domain := StrPas(PChar(Domain));
        end;
      end;

      if bSuccess then
      begin
        FreeMem(ptiUser);
      end;
    end;
    CloseHandle(processHandle);
  end;

  Result := PIDCredentials;
end;

function getPIDByProcessName(nameProcess: string): DWORD;
var
  processCompare: TProcessCompare;
begin
  processCompare.nameProcess := nameProcess;
  result := getPID(nameProcess, checkProcessName, processCompare);
end;

function checkProcessName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
begin
  result := processEntry.szExeFile = processCompare.nameProcess;
end;

function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD;
var
  processEntry: TProcessEntry32;
  snapHandle: THandle;
  processID: DWORD;
begin
  processID := 0;
  snapHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  processEntry.dwSize := sizeof(TProcessEntry32);
  Process32First(snapHandle, processEntry);
  repeat //loop su tutti i processi nello snapshot acquisito
    with processEntry do
    begin
      //esegui confronto
      if (fn(processEntry, processCompare)) then
      begin
        processID := th32ProcessID;
        break;
      end;
    end;
  until (not(Process32Next(snapHandle, processEntry)));
  CloseHandle(snapHandle);

  result := processID;
end;

type
  TEnumInfo = record
    pid: DWORD;
    handle: THandle;
  end;

function enumWindowsProc(Wnd: THandle; Param: LPARAM): boolean; stdcall; forward;

function getMainWindowHandleByPID(PID: DWORD): DWORD;
var
  enumInfo: TEnumInfo;
begin
  enumInfo.pid := PID;
  enumInfo.handle := 0;
  EnumWindows(@enumWindowsProc, LPARAM(@enumInfo));
  Result := enumInfo.handle;
end;

type
  PEnumInfo = ^TEnumInfo;

function enumWindowsProc(Wnd: THandle; Param: LPARAM): boolean; stdcall;
var
  PID: DWORD;
  PEI: PEnumInfo;

  _result: boolean;
begin
  // Param matches the address of the param that is passed
  PEI := PEnumInfo(Param);
  GetWindowThreadProcessID(Wnd, @PID);

  _result := (PID <> PEI^.pid) or (not IsWindowVisible(WND)) or (not IsWindowEnabled(WND));

  if not _result then
  begin
    PEI^.handle := WND; //break on return FALSE
  end;

  Result := _result;
end;
//----------------------------------------------------------------------------------------

procedure closeApplication(handle: THandle);
begin
  SendMessage(handle, WM_CLOSE, Application.Handle, 0);
end;

//TODO CHECK IF THE LOOP IS NECCESARY
//procedure closeApplication(className: string; windowsName: string; handleSender: THandle = 0);
//var
//  receiverHandle: THandle;
//begin
//  receiverHandle := 1;
//  while (receiverHandle <> 0) do
//  begin
//    //classname (tclass) windows name (caption)
//    receiverHandle := FindWindow(PChar(className), PChar(windowsName));
//    if (receiverHandle <> 0) then
//    begin
//      SendMessage(receiverHandle, WM_CLOSE, Integer(handleSender), 0);
//    end;
//  end;
//end;

function sendMemoryStreamUsing_WM_COPYDATA(handle: THandle; data: TMemoryStream): integer;
var
  _copyDataStruct: TCopyDataStruct;
  _result: integer;
begin
  _copyDataStruct.dwData := integer(data.Memory);
  _copyDataStruct.cbData := data.size;
  _copyDataStruct.lpData := data.Memory;
  _result := SendMessage(handle, WM_COPYDATA, Integer(Application.Handle), Integer(@_copyDataStruct));

  Result := _result;
end;

function sendStringUsing_WM_COPYDATA(handle: THandle; data: string; msgIdentifier: integer = 0): integer;
var
  _copyDataStruct: TCopyDataStruct;
  _result: integer;
begin
  _copyDataStruct.cbData := 1 + Length(data);
  _copyDataStruct.lpData := pansichar(ansistring(data));
  _copyDataStruct.dwData := integer(msgIdentifier);

  _result := SendMessage(handle, WM_COPYDATA, integer(handle), integer(@_copyDataStruct));
  Result := _result;
end;

procedure mySetForegroundWindow(handle: THandle);
begin
  SetForegroundWindow(handle);
  postMessage(handle, WM_SYSCOMMAND, SC_RESTORE, 0);
end;

function checkIfWindowExists(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm'): boolean;
begin
  Result := myFindWindow(className, captionForm) <> 0;
end;

function myFindWindow(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm'): THandle;
begin
  result := FindWindow(pchar(className), pchar(captionForm));
end;

function checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key: string): boolean;
var
  registry: TRegistry;
  isOpenKey: boolean;
begin
  registry := TRegistry.Create;
  try
    registry.RootKey := HKEY_LOCAL_MACHINE;
    isOpenKey := registry.OpenKeyReadOnly(key);
  finally
    registry.Free;
  end;
  Result := isOpenKey;
end;

procedure waitForMultiple(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = true);
const
  ERR_MSG_TIMEOUT = 'The timeout interval was elapsed.';
var
  _msg: TMsg;
  _return: DWORD;

  _exit: boolean;
begin
  _exit := false;
  while not _exit do
  begin
    _return := MsgWaitForMultipleObjects(1, { 1 handle to wait on }
      processHandle,
      False, { wake on any event }
      timeout,
      QS_PAINT or QS_SENDMESSAGE or QS_POSTMESSAGE //todo check
      //      QS_PAINT or QS_POSTMESSAGE or QS_SENDMESSAGE or QS_ALLPOSTMESSAGE { wake on paint messages or messages from other threads }
      );
    case _return of
      WAIT_OBJECT_0:
        _exit := true;
      WAIT_FAILED:
        raiseLastSysErrorMessage;
      WAIT_TIMEOUT:
        raise Exception.Create(ERR_MSG_TIMEOUT);
    else
      begin
        if modalMode then
        begin
          while PeekMessage(_msg, 0, WM_PAINT, WM_PAINT, PM_REMOVE) do
          begin
            DispatchMessage(_msg);
          end;
        end
        else
        begin
          Application.ProcessMessages;
        end;
      end;
    end;
  end;
end;

procedure waitFor(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = true);
const
  ERR_MSG_TIMEOUT = 'The timeout interval was elapsed.';
var
  _msg: TMsg;
  _return: DWORD;

  _exit: boolean;
begin
  _exit := false;
  while not _exit do
  begin
    _return := WaitForSingleObject(processHandle, timeout);
    case _return of
      WAIT_OBJECT_0:
        _exit := true;
      WAIT_FAILED:
        raiseLastSysErrorMessage;
      WAIT_TIMEOUT:
        raise Exception.Create(ERR_MSG_TIMEOUT);
    else
      begin
        if modalMode then
        begin
          while PeekMessage(_msg, 0, WM_PAINT, WM_PAINT, PM_REMOVE) do
          begin
            DispatchMessage(_msg);
          end;
        end
        else
        begin
          Application.ProcessMessages;
        end;
      end;
    end;
  end;
end;

procedure raiseLastSysErrorMessage;
var
  sysErrMsg: string;
begin
  sysErrMsg := getLastSysErrorMessage;
  raise Exception.Create(sysErrMsg);
end;

function getLastSysErrorMessage: string;
var
  _errorCode: cardinal;
  sysErrMsg: string;
begin
  _errorCode := GetLastError;
  sysErrMsg := SysErrorMessage(_errorCode);
  Result := sysErrMsg;
end;

function getLocaleDecimalSeparator: char;
const
  LOCALE_NAME_SYSTEM_DEFAULT = '!x-sys-default-locale';
var
  _buffer: array [1 .. 10] of Char;
  decimalSeparator: Char;
begin
  FillChar(_buffer, SizeOf(_buffer), 0);
  Win32Check(GetLocaleInfoEx(LOCALE_NAME_SYSTEM_DEFAULT, LOCALE_SDECIMAL, @_buffer[1], SizeOf(_buffer)) <> 0);
  decimalSeparator := _buffer[1];

  Result := decimalSeparator;
end;

end.
