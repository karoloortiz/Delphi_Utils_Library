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

unit KLib.Windows;

interface

uses
  KLib.Types, Klib.Constants,
  Winapi.Windows, Winapi.ShellApi, Winapi.AccCtrl, Winapi.ACLAPI,
  System.Classes;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
function getFirstPortAvaliable(defaultPort: integer; host: string = LOCALHOST_IP_ADDRESS): integer;
function checkIfPortIsAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS): boolean;
function checkIfAddressIsLocalhost(address: string): boolean;
function getIPFromHostName(hostName: string): string; //if hostname is alredy an ip address, returns hostname
function getIP: string;

function checkIfRunUnderWine: boolean;
function checkIfWindowsArchitectureIsX64: boolean;

type
  TWindowsArchitecture = (WindowsX86, WindowsX64);
function getWindowsArchitecture: TWindowsArchitecture;
function checkIfUserIsAdmin: boolean;

type
  TShowWindowType = (
    _SW_HIDE = Winapi.Windows.SW_HIDE,
    _SW_SHOWNORMAL = Winapi.Windows.SW_SHOWNORMAL,
    _SW_NORMAL = Winapi.Windows.SW_NORMAL,
    _SW_SHOWMINIMIZED = Winapi.Windows.SW_SHOWMINIMIZED,
    _SW_SHOWMAXIMIZED = Winapi.Windows.SW_SHOWMAXIMIZED,
    _SW_MAXIMIZE = Winapi.Windows.SW_MAXIMIZE,
    _SW_SHOWNOACTIVATE = Winapi.Windows.SW_SHOWNOACTIVATE,
    _SW_SHOW = Winapi.Windows.SW_SHOW,
    _SW_MINIMIZE = Winapi.Windows.SW_MINIMIZE,
    _SW_SHOWMINNOACTIVE = Winapi.Windows.SW_SHOWMINNOACTIVE,
    _SW_SHOWNA = Winapi.Windows.SW_SHOWNA,
    _SW_RESTORE = Winapi.Windows.SW_RESTORE,
    _SW_SHOWDEFAULT = Winapi.Windows.SW_SHOWDEFAULT,
    _SW_FORCEMINIMIZE = Winapi.Windows.SW_FORCEMINIMIZE,
    _SW_MAX = Winapi.Windows.SW_MAX
    );

procedure openWebPageWithDefaultBrowser(url: string);
procedure openFileWithWord(fileName: string);
function getWordExeFileName: string;
function executeExeAsAdmin(fileName: string; params: string = ''; exceptionIfFunctionFails: boolean = true): integer;
function executeExe(fileName: string; params: string = ''; exceptionIfFunctionFails: boolean = true): integer;
function executeAndWaitExe(fileName: string; params: string = ''; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;

function shellExecuteOpen(fileName: string; params: string = ''; directory: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_NORMAL;
  exceptionIfFunctionFails: boolean = false): integer;

function shellExecuteExeAsAdmin(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_HIDE;
  exceptionIfFunctionFails: boolean = false): integer;
function shellExecuteExe(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_HIDE;
  exceptionIfFunctionFails: boolean = false; operation: string = 'open'): integer;
function myShellExecute(handle: integer; operation: string; fileName: string; params: string;
  directory: string; showWindowType: TShowWindowType; exceptionIfFunctionFails: boolean = false): integer;

function shellExecuteExCMDAndWait(params: string; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType._SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
function shellExecuteExAndWait(fileName: string; params: string = ''; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType._SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;

function netShare(targetDir: string; netName: string = ''; netPassw: string = '';
  grantAllPermissionToEveryoneGroup: boolean = false): string;
procedure addTCP_IN_FirewallException(ruleName: string; port: Word; description: string = ''; grouping: string = '';
  executable: string = '');
procedure deleteFirewallException(ruleName: string);

//#####################################################################################
type
  TExplicitAccess = EXPLICIT_ACCESS_A;
procedure grantAllPermissionsNetToTheObjectForTheEveryoneGroup(myObject: string);
procedure grantAllPermissionsNetToTheObjectForTheUsersGroup(myObject: string);
procedure grantAllPermissionNetToTheObject(windowsGroupOrUser: string; myObject: string);
//--------------------------------------------------------------------------------------
procedure grantAllPermissionsToTheObjectForTheEveryoneGroup(myObject: string);
procedure grantAllPermissionsToTheObjectForTheUsersGroup(myObject: string);
procedure grantAllPermissionsToTheObject(windowsGroupOrUser: string; myObject: string);
//--------------------------------------------------------------------------------------
procedure grantAllPermissionsToTheObjectForTheEveryoneGroup2(myObject: string);
procedure grantAllPermissionsToTheObjectForTheUsersGroup2(myObject: string);
procedure grantAllPermissionsToTheObject2(windowsGroupOrUser: string; myObject: string);
//#################################################################################

function checkIfWindowsGroupOrUserExists(windowsGroupOrUser: string): boolean;

procedure createDesktopLink(fileName: string; nameDesktopLink: string; description: string);
function getDesktopDirPath: string;

procedure copyDirIntoTargetDir(sourceDir: string; targetDir: string; forceOverwrite: boolean = NOT_FORCE_OVERWRITE);
procedure copyDir(sourceDir: string; destinationDir: string; silent: boolean = FORCE_SILENT);
procedure createHideDir(dirName: string; forceDelete: boolean = FORCE_DELETE);
procedure deleteDirectoryIfExists(dirName: string; silent: boolean = FORCE_SILENT);

procedure moveFileIntoTargetDir(sourceFileName: string; targetDir: string);

procedure myMoveFile(sourceFileName: string; targetFileName: string);

procedure renameDir(oldDir: string; newDir: string; silent: boolean = FORCE_SILENT);

procedure appendToFileInNewLine(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE); overload;
procedure appendToFile(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE); overload;

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

procedure writeIn_HKEY_LOCAL_MACHINE(key: string; name: string; value: Variant; forceCreationKey: boolean = NOT_FORCE);
function readStringFrom_HKEY_LOCAL_MACHINE(key: string; name: string = ''): string;
function checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key: string): boolean;
procedure deleteKeyInHKEY_LOCAL_MACHINE(key: string);

procedure waitForMultiple(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = MODAL_MODE);
procedure waitFor(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = MODAL_MODE);

procedure raiseLastSysErrorMessage;
function getLastSysErrorMessage: string;

function getLocaleDecimalSeparator: char;

procedure terminateCurrentProcess(exitCode: Cardinal = 0; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION);
procedure myTerminateProcess(processHandle: THandle; exitCode: Cardinal = 0; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION);

function getExecutionMode: TExecutionMode;
//###########-----NOT WORK ON WINDOWS XP, WINDOWS SERVER 2003, AND EARLIER VERSIONS OF THE WINDOWS OPERATING SYSTEM------------############
function checkIfCurrentProcessIsAServiceProcess: boolean;
function checkIfIsAServiceProcess(processHandle: THandle): boolean;
//###########-----

procedure myAttachConsole(attachToParentIfExists: boolean = true);
function getWMIAsString(wmiClass: string; wmiProperty: string; filter: string = EMPTY_STRING;
  wmiHost: string = '.'; root: string = 'root\CIMV2'): string;
function GetWMIstring(wmiHost, root, wmiClass, wmiProperty: string): string;
//################################################################################
function getCurrentPidAsString: string;
function getCurrentPid: integer;
function GetCurrentProcessId: DWORD;
//################################################################################
function getCombinedPathWithCurrentDir(pathToCombine: string): string;
function DirExe: string;
function getDirExe: string;
function exeFileName: string;
function getExeFileName: string;

function getValueOfParameter(parameterNames: TArrayOfStrings): string; overload; //get first param value finded
function getValueOfParameter(parameterNames: TArrayOfStrings; valuesExcluded: TArrayOfStrings): string; overload; //get first param value finded
function getValueOfParameter(parameterName: string): string; overload;
function getValueOfParameter(parameterName: string; valuesExcluded: TArrayOfStrings): string; overload;
function checkIfParameterExists(parameterNames: TArrayOfStrings): boolean; overload;
function checkIfParameterExists(parameterName: string): boolean; overload;

function myParamCount: integer;
function myParamStr(index: integer): string;
function getShellParamsAsString: string;
function getShellParams: TArrayOfStrings;
//################################################################################
function getFileCreationDateTime(fileName: string): TDateTime;
function getFileModifiedDateTime(fileName: string): TDateTime;
function getFileAccessedDateTime(fileName: string): TDateTime;
function getFileTzSpecificLocalTime(fileName: string; fileSystemTimeType: TFileSystemTimeType): TSystemTime;
function getFileSystemTime(fileName: string; fileSystemTimeType: TFileSystemTimeType): TSystemTime;
//################################################################################
//KEPT THE SIGNATURES, NOT RENAME!!!
function IsUserAnAdmin: boolean; external shell32;
function fixedGetNamedSecurityInfo(pObjectName: LPWSTR; ObjectType: SE_OBJECT_TYPE;
  SecurityInfo: SECURITY_INFORMATION; ppsidOwner, ppsidGroup: PPSID; ppDacl, ppSacl: PPACL;
  var ppSecurityDescriptor: PSECURITY_DESCRIPTOR): DWORD; stdcall;
  external 'ADVAPI32.DLL' name 'GetNamedSecurityInfoW';

function GetConsoleWindow: HWnd; stdcall;
  external 'kernel32.dll' name 'GetConsoleWindow';
function AttachConsole(ProcessId: DWORD): BOOL; stdcall;
  external 'kernel32.dll' name 'AttachConsole';

var
  shellParams: TArrayOfStrings;

implementation

uses
  KLib.FileSystem, KLib.StringUtils, KLib.Validate, KLib.StringListHelper,
  Vcl.Forms,
  Winapi.TLHelp32, Winapi.ActiveX, Winapi.Shlobj, Winapi.Winsock, Winapi.UrlMon, Winapi.Messages,
  System.SysUtils, System.Win.ComObj, System.Win.Registry, System.Variants, System.StrUtils,
  IdTCPClient;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
const
  ERR_MSG = 'Error downloading file.';
var
  _downloadSuccess: boolean;
  _links: TStringList;
  i: integer;
begin
  if forceOverwrite then
  begin
    deleteFileIfExists(info.fileName);
  end;

  _downloadSuccess := false;
  i := 0;
  _links := TStringList.Create;
  _links.Add(info.link);
  _links.AddStrings(info.alternative_links);
  try
    while (not _downloadSuccess) and (i < _links.Count) do
    begin
      _downloadSuccess := URLDownloadToFile(nil, pChar(_links[i]), pchar(info.fileName), 0, nil) = S_OK;
      Inc(i);
    end;
  finally
    FreeAndNil(_links);
  end;

  if not _downloadSuccess then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  if info.MD5 <> '' then
  begin
    validateMD5File(info.fileName, info.MD5, ERR_MSG);
  end;
end;

function getFirstPortAvaliable(defaultPort: integer; host: string = LOCALHOST_IP_ADDRESS): integer;
var
  port: integer;
begin
  port := defaultPort;
  while not checkIfPortIsAvaliable(port, host) do
  begin
    inc(port);
  end;

  Result := port;
end;

function checkIfPortIsAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS): boolean;
var
  isPortAvaliable: boolean;

  _IdTCPClient: TIdTCPClient;
begin
  isPortAvaliable := True;
  try
    _IdTCPClient := TIdTCPClient.Create(nil);
    try
      _IdTCPClient.Host := host;
      _IdTCPClient.Port := port;
      _IdTCPClient.Connect;
      isPortAvaliable := False;
    finally
      _IdTCPClient.Free;
    end;
  except
    //Ignore exceptions
  end;

  Result := isPortAvaliable;
end;

function checkIfAddressIsLocalhost(address: string): boolean;
var
  addressIsLocalhost: boolean;

  _address: string;
  _localhostIP_address: string;
begin
  addressIsLocalhost := true;
  _address := getIPFromHostName(address);
  if _address <> LOCALHOST_IP_ADDRESS then
  begin
    _localhostIP_address := getIP;
    if _address <> _localhostIP_address then
    begin
      addressIsLocalhost := false;
    end;
  end;

  Result := addressIsLocalhost;
end;

function getIPFromHostName(hostName: string): string;
const
  ERR_WINSOCK_MSG = 'Winsock initialization error.';
  ERR_NO_IP_FOUND_WITH_HOSTBAME_MSG = 'No IP found with hostname: ';
var
  ip: string;

  _varTWSAData: TWSAData;
  _varPHostEnt: PHostEnt;
  _varTInAddr: TInAddr;
begin
  if WSAStartup($101, _varTWSAData) <> 0 then
  begin
    raise Exception.Create(ERR_WINSOCK_MSG);
  end
  else
  begin
    try
      _varPHostEnt := gethostbyname(PAnsiChar(AnsiString(hostName)));
      _varTInAddr := PInAddr(_varPHostEnt^.h_Addr_List^)^;
      ip := String(inet_ntoa(_varTInAddr));
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
  ip: string;

  _varTWSAData: TWSAData;
  _varPHostEnt: PHostEnt;
  _varTInAddr: TInAddr;
  _namebuf: Array [0 .. 255] of ansichar;
begin
  if WSAStartup($101, _varTWSAData) <> 0 then
  begin
    raise Exception.Create(ERR_MSG);
  end
  else
  begin
    getHostName(_nameBuf, sizeOf(_nameBuf));
    _varPHostEnt := gethostbyname(_nameBuf);
    _varTInAddr.S_addr := u_long(pu_long(_varPHostEnt^.h_addr_list^)^);
    ip := string(inet_ntoa(_varTInAddr));
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
  _windowsArchitecture: TWindowsArchitecture;
begin
  _windowsArchitecture := getWindowsArchitecture;

  Result := _windowsArchitecture = TWindowsArchitecture.WindowsX64;
end;

function getWindowsArchitecture: TWindowsArchitecture;
const
  ERR_MSG_PLATFORM = 'The OS. is not Windows.';
  ERR_MSG_ARCHITECTURE = 'Unknown OS architecture.';
var
  windowsArchitecture: TWindowsArchitecture;
begin
  if TOSVersion.Platform <> pfWindows then
  begin
    raise Exception.Create(ERR_MSG_PLATFORM);
  end;
  case TOSVersion.Architecture of
    arIntelX86:
      windowsArchitecture := TWindowsArchitecture.WindowsX86;
    arIntelX64:
      windowsArchitecture := TWindowsArchitecture.WindowsX64;
  else
    begin
      raise Exception.Create(ERR_MSG_ARCHITECTURE);
    end;
  end;

  Result := windowsArchitecture;
end;

function checkIfUserIsAdmin: boolean;
begin
  Result := IsUserAnAdmin;
end;

procedure openWebPageWithDefaultBrowser(url: string);
begin
  shellExecuteOpen(url);
end;

procedure openFileWithWord(fileName: string);
var
  winwordFileName: string;
begin
  winwordFileName := getWordExeFileName();
  shellExecuteOpen(winwordFileName, getDoubleQuotedString(fileName));
end;

function getWordExeFileName: string;
const
  REG_KEY = '\Software\Microsoft\Windows\CurrentVersion\App Paths\Winword.exe';
begin
  Result := readStringFrom_HKEY_LOCAL_MACHINE(REG_KEY);
end;

function executeExeAsAdmin(fileName: string; params: string = ''; exceptionIfFunctionFails: boolean = true): integer;
var
  returnCode: integer;
begin
  returnCode := shellExecuteExeAsAdmin(fileName, params, TShowWindowType._SW_HIDE, exceptionIfFunctionFails);

  Result := returnCode;
end;

function executeExe(fileName: string; params: string = ''; exceptionIfFunctionFails: boolean = true): integer;
var
  returnCode: integer;
begin
  returnCode := shellExecuteExe(fileName, params, TShowWindowType._SW_HIDE, exceptionIfFunctionFails);

  Result := returnCode;
end;

function executeAndWaitExe(fileName: string; params: string = ''; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
var
  returnCode: Longint;

  _commad: String;
  _startupInfo: TStartupInfo;
  _processInfo: TProcessInformation;
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

function shellExecuteOpen(fileName: string; params: string = ''; directory: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_NORMAL;
  exceptionIfFunctionFails: boolean = false): integer;
var
  returnCode: integer;
begin
  returnCode := myShellExecute(0, 'open', fileName, params, directory, showWindowType, exceptionIfFunctionFails);

  Result := returnCode;
end;

function shellExecuteExeAsAdmin(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_HIDE;
  exceptionIfFunctionFails: boolean = false): integer;
var
  returnCode: integer;
begin
  returnCode := shellExecuteExe(fileName, params, showWindowType, exceptionIfFunctionFails, 'runas');

  Result := returnCode;
end;

function shellExecuteExe(fileName: string; params: string = ''; showWindowType: TShowWindowType = TShowWindowType._SW_HIDE;
  exceptionIfFunctionFails: boolean = false; operation: string = 'open'): integer;
var
  returnCode: integer;

  _directory: string;
begin
  _directory := ExtractFileDir(fileName);
  returnCode := myShellExecute(0, operation, getDoubleQuotedString(fileName), params, _directory, showWindowType, exceptionIfFunctionFails);

  Result := returnCode;
end;

function myShellExecute(handle: integer; operation: string; fileName: string; params: string;
  directory: string; showWindowType: TShowWindowType; exceptionIfFunctionFails: boolean = false): integer;
var
  returnCode: integer;

  errMsg: string;
begin
  returnCode := shellExecute(handle, pchar(operation), pchar(fileName), PCHAR(trim(params)),
    pchar(directory), integer(showWindowType));

  if exceptionIfFunctionFails then
  begin
    case returnCode of
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

  Result := returnCode;
end;

function shellExecuteExCMDAndWait(params: string; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType._SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
begin
  Result := shellExecuteExAndWait(CMD_EXE_NAME, params, runAsAdmin, showWindowType, exceptionIfReturnCodeIsNot0);
end;

function shellExecuteExAndWait(fileName: string; params: string = ''; runAsAdmin: boolean = false;
  showWindowType: TShowWindowType = TShowWindowType._SW_HIDE; exceptionIfReturnCodeIsNot0: boolean = false): LongInt;
var
  returnCode: Longint;

  _shellExecuteInfo: TShellExecuteInfo;
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
  pathSharedDir: string;

  _targetDir: string;
  _AShareInfo: PSHARE_INFO_2;
  _parmError: DWORD;
  _shareExistsAlready: boolean;
  _errMsg: string;
begin
  _shareExistsAlready := false;
  _targetDir := getValidFullPathInWindowsStyle(targetDir);
  _AShareInfo := New(PSHARE_INFO_2);
  try
    with _AShareInfo^ do
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

    if (netShareAdd(nil, 2, PBYTE(_AShareInfo), @_parmError) <> NERR_SUCCESS) then
    begin
      _shareExistsAlready := true;
    end;
    if not checkIfDirExists(pathSharedDir) then
    begin
      _errMsg := ERR_MSG + getDoubleQuotedString(_targetDir);
      raise Exception.Create(_errMsg);
    end;
    pathSharedDir := '\\' + GetEnvironmentVariable('COMPUTERNAME') + '\' + _AShareInfo.shi2_netname;
    if not(_shareExistsAlready) and (grantAllPermissionToEveryoneGroup) then
    begin
      grantAllPermissionsNetToTheObjectForTheEveryoneGroup(pathSharedDir);
    end;
  finally
    FreeMem(_AShareInfo, SizeOf(PSHARE_INFO_2));
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

procedure grantAllPermissionsNetToTheObjectForTheUsersGroup(myObject: string);
begin
  grantAllPermissionNetToTheObject(USERS_GROUP, myObject);
end;

procedure grantAllPermissionNetToTheObject(windowsGroupOrUser: string; myObject: string);
var
  NewDacl, OldDacl: PACl;
  SD: PSECURITY_DESCRIPTOR;
  EA: TExplicitAccess;
begin
  validateThatWindowsGroupOrUserExists(windowsGroupOrUser);

  fixedGetNamedSecurityInfo(PChar(myObject), SE_LMSHARE, DACL_SECURITY_INFORMATION, nil, nil, @OldDacl, nil, SD);
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

  fixedGetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, @oldDACL,
    nil, securityDescriptor);
  BuildExplicitAccessWithName(@explicitAccess, PChar(windowsGroupOrUser), GENERIC_ALL, GRANT_ACCESS,
    SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @explicitAccess, oldDACL, newDACL);
  SetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, newDACL, nil);
end;

procedure grantAllPermissionsToTheObjectForTheEveryoneGroup2(myObject: string);
begin
  grantAllPermissionsToTheObject2(EVERYONE_GROUP, myObject);
end;

procedure grantAllPermissionsToTheObjectForTheUsersGroup2(myObject: string);
begin
  grantAllPermissionsToTheObject2(USERS_GROUP, myObject);
end;

procedure grantAllPermissionsToTheObject2(windowsGroupOrUser: string; myObject: string);
begin
  validateThatWindowsGroupOrUserExists(windowsGroupOrUser);

  shellExecuteExeAsAdmin('icacls', getDoubleQuotedString(myObject) + ' /grant ' + getDoubleQuotedString(windowsGroupOrUser) + ':(OI)(CI)F /T');
end;

function checkIfWindowsGroupOrUserExists(windowsGroupOrUser: string): boolean;
var
  windowsGroupOrUserExists: boolean;

  _newDACL: PACl;
  _explicitAccess: TExplicitAccess;
begin
  BuildExplicitAccessWithName(@_explicitAccess, PChar(windowsGroupOrUser), GENERIC_ALL, GRANT_ACCESS,
    SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @_explicitAccess, nil, _newDACL);
  windowsGroupOrUserExists := Assigned(_newDACL);

  Result := windowsGroupOrUserExists;
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
  desktopDirPath: string;

  _PIDList: PItemIDList;
  _Buffer: array [0 .. MAX_PATH - 1] of Char;
begin
  desktopDirPath := '';
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, _PIDList);
  if Assigned(_PIDList) then
  begin
    if SHGetPathFromIDList(_PIDList, _Buffer) then
    begin
      desktopDirPath := _Buffer;
    end;
  end;

  Result := desktopDirPath;
end;

procedure copyDirIntoTargetDir(sourceDir: string; targetDir: string; forceOverwrite: boolean = NOT_FORCE_OVERWRITE);
var
  _parentDirTargetDir: string;
  _sourceDirName: string;
  _tempTargetDir: string;
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
  renameDir(_tempTargetDir, targetDir);
end;

const
  SILENT_FLAGS: FILEOP_FLAGS = FOF_SILENT or FOF_NOCONFIRMATION;

procedure copyDir(sourceDir: string; destinationDir: string; silent: boolean = FORCE_SILENT);
var
  _sHFileOpStruct: TSHFileOpStruct;
  _shFileOperationResult: integer;
begin
  ZeroMemory(@_sHFileOpStruct, SizeOf(_sHFileOpStruct));
  with _sHFileOpStruct do
  begin
    wFunc := FO_COPY;
    pFrom := PChar(sourceDir + #0#0);
    pTo := PChar(destinationDir + #0#0);
    if silent then
    begin
      fFlags := FOF_FILESONLY or SILENT_FLAGS;
    end
    else
    begin
      fFlags := FOF_FILESONLY;
    end;
  end;
  _shFileOperationResult := ShFileOperation(_sHFileOpStruct);
  if _shFileOperationResult <> 0 then
  begin
    raise Exception.Create('Unable to copy ' + sourceDir + ' to ' + destinationDir);
  end;
end;

procedure createHideDir(dirName: string; forceDelete: boolean = FORCE_DELETE);
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

procedure deleteDirectoryIfExists(dirName: string; silent: boolean = FORCE_SILENT);
const
  ERR_MSG = 'Unable to delete :';
var
  _sHFileOpStruct: TSHFileOpStruct;
  _shFileOperationResult: integer;

  _errMsg: string;
begin
  if checkIfDirExists(dirName) then
  begin
    ZeroMemory(@_sHFileOpStruct, SizeOf(_sHFileOpStruct));
    with _sHFileOpStruct do
    begin
      wFunc := FO_DELETE;
      pFrom := PChar(DirName + #0#0); //double zero-terminated
      if silent then
      begin
        fFlags := SILENT_FLAGS;
      end
    end;
    _shFileOperationResult := SHFileOperation(_sHFileOpStruct);
    if (_shFileOperationResult <> 0) or (checkIfDirExists(dirName)) then
    begin
      _errMsg := ERR_MSG + dirName;
      raise Exception.Create(_errMsg);
    end;
  end;
end;

procedure moveFileIntoTargetDir(sourceFileName: string; targetDir: string);
var
  _fileName: string;
  _parentFolder: string;
  _targetFileName: string;
  _targetDir: string;
  _tagetDirIsAPath: boolean;
begin
  _tagetDirIsAPath := checkIfIsAPath(targetDir);
  if _tagetDirIsAPath then
  begin
    _targetDir := targetDir;
  end
  else
  begin
    _parentFolder := getParentDir(sourceFileName);
    _targetDir := getCombinedPath(_parentFolder, targetDir);
  end;
  createDirIfNotExists(_targetDir);
  _fileName := ExtractFileName(sourceFileName);
  _targetFileName := getCombinedPath(_targetDir, _fileName);
  deleteFileIfExists(_targetFileName);
  myMoveFile(sourceFileName, _targetFileName);
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

procedure renameDir(oldDir: string; newDir: string; silent: boolean = FORCE_SILENT);
const
  ERROR_CODE_SAMEFILE = 113;
var
  _sHFileOpStruct: TSHFileOpStruct;
  _shFileOperationResult: integer;
  _oldDir: string;
  _newDir: string;
begin
  _oldDir := getValidFullPathInWindowsStyle(oldDir);
  _newDir := getValidFullPathInWindowsStyle(newDir);
  if _oldDir <> _newDir then
  begin
    ZeroMemory(@_sHFileOpStruct, SizeOf(_sHFileOpStruct));
    with _sHFileOpStruct do
    begin
      wFunc := FO_RENAME;
      pFrom := PChar(_oldDir + #0#0);
      pTo := PChar(_newDir + #0#0);
      if silent then
      begin
        fFlags := SILENT_FLAGS;
      end;
    end;
    _shFileOperationResult := ShFileOperation(_sHFileOpStruct);
    if (_shFileOperationResult <> 0) and (_shFileOperationResult <> ERROR_CODE_SAMEFILE) then
    begin
      raise Exception.Create('Unable to rename ' + _oldDir + ' to ' + _newDir);
    end;
  end;
end;

procedure appendToFileInNewLine(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE);
begin
  KLib.Windows.appendToFile(fileName, text, forceCreationFile, FORCE);
end;

procedure appendToFile(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE);
var
  _file: TextFile;
  _text: string;
begin
  if forceCreationFile then
  begin
    createEmptyFileIfNotExists(filename);
  end;
  _text := text;
  if (checkIfFileExistsAndIsNotEmpty(filename)) then
  begin
    if (forceAppendInNewLine) then
    begin
      _text := sLineBreak + _text;
    end;
  end;

  AssignFile(_file, filename);
  Append(_file);
  Write(_file, _text);
  CloseFile(_file);
end;

function checkIfIsWindowsSubDir(subDir: string; mainDir: string): boolean;
var
  isSubDir: Boolean;

  _subDir: string;
  _mainDir: string;
begin
  _subDir := getPathInWindowsStyle(subDir);
  _mainDir := getPathInWindowsStyle(mainDir);
  isSubDir := checkIfIsSubDir(_subDir, _mainDir, WINDOWS_PATH_DELIMITER);

  Result := isSubDir
end;

function getParentDir(source: string): string;
var
  parentDir: string;
begin
  parentDir := getValidFullPathInWindowsStyle(source);
  parentDir := ExtractFilePath(parentDir);

  Result := parentDir;
end;

function getValidFullPathInWindowsStyle(path: string): string;
var
  validFullPathInWindowsStyle: string;
begin
  validFullPathInWindowsStyle := getValidFullPath(path);
  validFullPathInWindowsStyle := getPathInWindowsStyle(validFullPathInWindowsStyle);

  Result := validFullPathInWindowsStyle;
end;

function getPathInWindowsStyle(path: string): string;
var
  pathInWindowsStyl: string;
begin
  pathInWindowsStyl := myStringReplace(path, '/', '\', [rfReplaceAll, rfIgnoreCase]);

  Result := pathInWindowsStyl;
end;

function getStringWithEnvVariablesReaded(source: string): string;
var
  stringWithEnvVariablesReaded: string;

  _stringDir: string;
  _stringPos: string;
  _posStart: integer;
  _posEnd: integer;
  _valueToReplace: string;
  _newValue: string;
  _exit: boolean;
begin
  _exit := false;
  _stringPos := source;
  _stringDir := source;
  stringWithEnvVariablesReaded := source;
  while (not _exit) do
  begin
    _posStart := pos('%', _stringPos);
    _exit := (_posStart = 0);

    _stringPos := copy(_stringPos, _posStart + 1, length(_stringPos));
    _posEnd := _posStart + pos('%', _stringPos);
    if (_posStart > 0) and (_posEnd > 1) then
    begin
      _valueToReplace := copy(_stringDir, _posStart, _posEnd - _posStart + 1);
      _newValue := GetEnvironmentVariable(copy(_valueToReplace, 2, length(_valueToReplace) - 2));
      if _newValue <> '' then
      begin
        stringWithEnvVariablesReaded := KLib.StringUtils.myStringReplace(stringWithEnvVariablesReaded, _valueToReplace, _newValue, []);
      end;
    end
    else
    begin
      _exit := true;
    end;
    _stringDir := copy(_stringDir, _posEnd + 1, length(_stringDir));
    _stringPos := _stringDir;
  end;

  Result := stringWithEnvVariablesReaded;
end;

//----------------------------------------------------------------------
function setProcessWindowToForeground(processName: string): boolean;
var
  _result: boolean;

  _PIDProcess: DWORD;
  _windowHandle: THandle;
begin
  _PIDProcess := getPIDOfCurrentUserByProcessName(processName);
  _windowHandle := getMainWindowHandleByPID(_PIDProcess);

  if _windowHandle <> 0 then
  begin
    mySetForegroundWindow(_windowHandle);
    _result := true;
  end
  else
  begin
    _result := false;
  end;

  Result := _result;
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

  Result := getPID(nameProcess, checkProcessUserName, processCompare);
end;

function getWindowsUsername: string;
var
  windowsUsername: string;

  _userName: string;
  _userNameLen: DWORD;
begin
  _userNameLen := 256;
  SetLength(_userName, _userNameLen);
  if GetUserName(PChar(_userName), _userNameLen) then
  begin
    windowsUsername := Copy(_userName, 1, _userNameLen - 1);
  end
  else
  begin
    windowsUsername := '';
  end;

  Result := windowsUsername;
end;

function checkProcessName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; forward;

function checkProcessUserName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
var
  _sameProcessName: boolean;
  _sameUserOfProcess: boolean;
begin
  _sameProcessName := checkProcessName(processEntry, processCompare);
  _sameUserOfProcess := checkUserOfProcess(processCompare.username, processEntry.th32ProcessID);

  Result := _sameProcessName and _sameUserOfProcess;
end;

//TODO: CREARE CLASSE PER RAGGUPPARE OGGETTI

function checkUserOfProcess(userName: String; PID: DWORD): boolean;
var
  sameUser: boolean;

  _PIDCredentials: TPIDCredentials;
begin
  _PIDCredentials := getPIDCredentials(PID);
  sameUser := _PIDCredentials.ownerUserName = userName;

  Result := sameUser;
end;

type
  _TOKEN_USER = record
    User: TSidAndAttributes;
  end;

  PTOKEN_USER = ^_TOKEN_USER;

function getPIDCredentials(PID: DWORD): TPIDCredentials;
var
  PIDCredentials: TPIDCredentials;

  _hToken: THandle;
  _cbBuf: Cardinal;
  _ptiUser: PTOKEN_USER;
  _snu: SID_NAME_USE;
  _processHandle: THandle;
  _userSize: DWORD;
  _domainSize: DWORD;
  _bSuccess: Boolean;
  _user: string;
  _domain: string;
begin
  _processHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
  if _processHandle <> 0 then
  begin
    if OpenProcessToken(_processHandle, TOKEN_QUERY, _hToken) then
    begin
      _bSuccess := GetTokenInformation(_hToken, TokenUser, nil, 0, _cbBuf);
      _ptiUser := nil;
      while (not _bSuccess) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) do
      begin
        ReallocMem(_ptiUser, _cbBuf);
        _bSuccess := GetTokenInformation(_hToken, TokenUser, _ptiUser, _cbBuf, _cbBuf);
      end;
      CloseHandle(_hToken);

      if not _bSuccess then
      begin
        Exit;
      end;

      _userSize := 0;
      _domainSize := 0;
      LookupAccountSid(nil, _ptiUser.User.Sid, nil, _userSize, nil, _domainSize, _snu);
      if (_userSize <> 0) and (_domainSize <> 0) then
      begin
        SetLength(_user, _userSize);
        SetLength(_domain, _domainSize);
        if LookupAccountSid(nil, _ptiUser.User.Sid, PChar(_user), _userSize,
          PChar(_domain), _domainSize, _snu) then
        begin
          PIDCredentials.ownerUserName := StrPas(PChar(_user));
          PIDCredentials.domain := StrPas(PChar(_domain));
        end;
      end;

      if _bSuccess then
      begin
        FreeMem(_ptiUser);
      end;
    end;
    CloseHandle(_processHandle);
  end;

  Result := PIDCredentials;
end;

function getPIDByProcessName(nameProcess: string): DWORD;
var
  _processCompare: TProcessCompare;
begin
  _processCompare.nameProcess := nameProcess;

  Result := getPID(nameProcess, checkProcessName, _processCompare);
end;

function checkProcessName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
begin
  Result := processEntry.szExeFile = processCompare.nameProcess;
end;

function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD;
var
  processID: DWORD;

  _processEntry: TProcessEntry32;
  _snapHandle: THandle;
begin
  processID := 0;
  _snapHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  _processEntry.dwSize := sizeof(TProcessEntry32);
  Process32First(_snapHandle, _processEntry);
  repeat //loop over all process in snapshot
    with _processEntry do
    begin
      //execute processCompare
      if (fn(_processEntry, processCompare)) then
      begin
        processID := th32ProcessID;
        break;
      end;
    end;
  until (not(Process32Next(_snapHandle, _processEntry)));
  CloseHandle(_snapHandle);

  Result := processID;
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
  _result: boolean;

  PID: DWORD;
  PEI: PEnumInfo;
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
  _result: integer;

  _copyDataStruct: TCopyDataStruct;
begin
  _copyDataStruct.dwData := integer(data.Memory);
  _copyDataStruct.cbData := data.size;
  _copyDataStruct.lpData := data.Memory;
  _result := SendMessage(handle, WM_COPYDATA, Integer(Application.Handle), Integer(@_copyDataStruct));

  Result := _result;
end;

function sendStringUsing_WM_COPYDATA(handle: THandle; data: string; msgIdentifier: integer = 0): integer;
var
  _result: integer;
  _copyDataStruct: TCopyDataStruct;
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
  Result := FindWindow(pchar(className), pchar(captionForm));
end;

procedure writeIn_HKEY_LOCAL_MACHINE(key: string; name: string; value: Variant; forceCreationKey: boolean = NOT_FORCE);
const
  ERR_MSG = 'Unsupported variant type.';
var
  _registry: TRegistry;
  _isOpenKey: boolean;
begin
  _registry := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    _registry.RootKey := HKEY_LOCAL_MACHINE;
    _isOpenKey := _registry.OpenKey(key, forceCreationKey);
    if _isOpenKey then
    begin

      if (VarIsEmpty(value) or VarIsNull(value)) then
      begin
        _registry.WriteString(name, EMPTY_STRING);
      end
      else if (VarIsStr(value)) then
      begin
        _registry.WriteString(name, value);
      end
      else if (VarIsNumeric(value)) then
      begin
        _registry.WriteInteger(name, value);
      end
      else if (VarIsFloat(value)) then
      begin
        _registry.WriteInteger(name, value);
      end
      else
      begin
        raise Exception.Create(ERR_MSG);
      end;

      _registry.CloseKey;
    end
    else
    begin
      raise Exception.Create(key + ': Key not opened.');
    end;
  finally
    _registry.Free;
  end;
end;

function readStringFrom_HKEY_LOCAL_MACHINE(key: string; name: string = ''): string;
var
  value: string;

  _registry: TRegistry;
begin
  validateThatExistsKeyIn_HKEY_LOCAL_MACHINE(key);

  _registry := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    _registry.RootKey := HKEY_LOCAL_MACHINE;
    validateThatExistsKeyIn_HKEY_LOCAL_MACHINE(key);
    _registry.OpenKeyReadOnly(key);
    value := _registry.ReadString(name);
  finally
    _registry.Free;
  end;

  Result := value;
end;

function checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key: string): boolean;
var
  isOpenKey: boolean;

  _registry: TRegistry;
begin
  _registry := TRegistry.Create;
  try
    _registry.RootKey := HKEY_LOCAL_MACHINE;
    isOpenKey := _registry.OpenKeyReadOnly(key);
  finally
    _registry.Free;
  end;

  Result := isOpenKey;
end;

procedure deleteKeyInHKEY_LOCAL_MACHINE(key: string);
var
  _registry: TRegistry;
begin
  _registry := TRegistry.Create;
  try
    _registry.RootKey := HKEY_LOCAL_MACHINE;
    _registry.DeleteKey(key);
  finally
    _registry.Free;
  end;
end;

procedure waitForMultiple(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = MODAL_MODE);
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
      QS_PAINT or QS_SENDMESSAGE or QS_POSTMESSAGE
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

procedure waitFor(processHandle: THandle; timeout: DWORD = INFINITE; modalMode: boolean = MODAL_MODE);
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
  sysErrMsg: string;
  _errorCode: cardinal;
begin
  _errorCode := GetLastError;
  sysErrMsg := SysErrorMessage(_errorCode);

  Result := sysErrMsg;
end;

function getLocaleDecimalSeparator: char;
const
  LOCALE_NAME_SYSTEM_DEFAULT = '!x-sys-default-locale';
var
  decimalSeparator: Char;

  _buffer: array [1 .. 10] of Char;
begin
  FillChar(_buffer, SizeOf(_buffer), 0);
{$warn SYMBOL_PLATFORM OFF}
  Win32Check(GetLocaleInfoEx(LOCALE_NAME_SYSTEM_DEFAULT, LOCALE_SDECIMAL, @_buffer[1], SizeOf(_buffer)) <> 0);
{$warn SYMBOL_PLATFORM ON}
  decimalSeparator := _buffer[1];

  Result := decimalSeparator;
end;

procedure terminateCurrentProcess(exitCode: Cardinal = 0; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION);
var
  _currentProcess: THandle;
begin
  _currentProcess := GetCurrentProcess;
  myTerminateProcess(_currentProcess, exitCode, isRaiseExceptionEnabled);
end;

procedure myTerminateProcess(processHandle: THandle; exitCode: Cardinal = 0; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION);
var
  _success: LongBool;
begin
  _success := TerminateProcess(processHandle, exitCode);
  if not _success and isRaiseExceptionEnabled then
  begin
    raiseLastSysErrorMessage;
  end;
end;

function getExecutionMode: TExecutionMode;
var
  executionMode: TExecutionMode;

  _serviceModeEnabled: boolean;
  _desktopModeEnabled: boolean;
begin
  _serviceModeEnabled := checkIfCurrentProcessIsAServiceProcess;
  _desktopModeEnabled := myParamCount = 0;
  if _serviceModeEnabled then
  begin
    executionMode := TExecutionMode.service;
  end
  else if _desktopModeEnabled then
  begin
    executionMode := TExecutionMode.desktop;
  end
  else
  begin
    executionMode := TExecutionMode.cli;
  end;

  Result := executionMode;
end;

function checkIfCurrentProcessIsAServiceProcess: boolean;
var
  _currentProcess: THandle;
begin
  _currentProcess := GetCurrentProcess;

  Result := checkIfIsAServiceProcess(_currentProcess);
end;

function checkIfIsAServiceProcess(processHandle: THandle): boolean;
var
  _isServiceProcess: boolean;
  _tokenInformation: Cardinal;
  _length: Cardinal;
  _tokenHandle: THandle;
  _valid: boolean;
begin
  _isServiceProcess := false;

  _length := 0;
  _valid := OpenProcessToken(processHandle, TOKEN_QUERY, _tokenHandle);
  if _valid then
  begin
    try
      _valid := GetTokenInformation(_tokenHandle, TokenSessionId, @_tokenInformation, SizeOf(_tokenInformation), _length);
      if _valid then
      begin
        if _length <> 0 then
        begin
          _isServiceProcess := _tokenInformation = 0;
        end;
      end;
    finally
      CloseHandle(_tokenHandle);
    end;
  end;

  Result := _isServiceProcess;
end;

procedure myAttachConsole(attachToParentIfExists: boolean = true);
const
  ATTACH_PARENT_PROCESS = DWORD(-1);
begin
  if attachToParentIfExists then
  begin
    if not AttachConsole(ATTACH_PARENT_PROCESS) then
    begin
      AllocConsole;
    end;
    AttachConsole(ATTACH_PARENT_PROCESS);
  end
  else
  begin
    AllocConsole;
  end;
end;

function getWMIAsString(wmiClass: string; wmiProperty: string; filter: string = EMPTY_STRING;
  wmiHost: string = '.'; root: string = 'root\CIMV2'): string;
var
  objWMIService: OLEVariant;
  colItems: OLEVariant;
  colItem: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;

  function GetWMIObject(const objectName: String): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx; //for access to a bind context
    Moniker: IMoniker; //Enables you to use a moniker object
  begin
    OleCheck(CreateBindCtx(0, bindCtx));
    OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker)); //Converts a string into a moniker that identifies the object named by the string
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result)); //Binds to the specified object
  end;

var
  _query: string;
begin
  try
    CoInitialize(nil);
    try
      objWMIService := GetWMIObject(Format('winmgmts:\\%s\%s', [wmiHost, root]));
      _query := Format('SELECT * FROM %s', [wmiClass]);
      if filter <> EMPTY_STRING then
      begin
        _query := _query + ' WHERE ' + filter;
      end;
      colItems := objWMIService.ExecQuery(_query, 'WQL', 0);
      oEnum := IUnknown(colItems._NewEnum) as IEnumVariant;
      while oEnum.Next(1, colItem, iValue) = 0 do
      begin
        Result := colItem.Properties_.Item(wmiProperty, 0); //you can improve this code  ;) , storing the results in an TString.
      end;

    finally
      CoUninitialize;
    end;
  except
    on E: Exception do
    Begin
      raise Exception.Create(E.Message);
    End;
  end;
end;

function GetWMIstring(wmiHost, root, wmiClass, wmiProperty: string): string;
var
  objWMIService: OLEVariant;
  colItems: OLEVariant;
  colItem: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;

  function GetWMIObject(const objectName: String): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx; //for access to a bind context
    Moniker: IMoniker; //Enables you to use a moniker object
  begin
    OleCheck(CreateBindCtx(0, bindCtx));
    OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker)); //Converts a string into a moniker that identifies the object named by the string
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result)); //Binds to the specified object
  end;

begin
  objWMIService := GetWMIObject(Format('winmgmts:\\%s\%s', [wmiHost, root]));
  colItems := objWMIService.ExecQuery(Format('SELECT * FROM %s WHERE ProcessId = "840"', [wmiClass]), 'WQL', 0);
  oEnum := IUnknown(colItems._NewEnum) as IEnumVariant;
  while oEnum.Next(1, colItem, iValue) = 0 do
  begin
    Result := colItem.Properties_.Item(wmiProperty, 0); //you can improve this code  ;) , storing the results in an TString.
  end;
end;

function getCurrentPidAsString: string;
begin
  Result := IntToStr(getCurrentPid);
end;

function getCurrentPid: integer;
begin
  Result := GetCurrentProcessId;
end;

function GetCurrentProcessId: DWORD;
begin
  Result := Winapi.Windows.GetCurrentProcessId;
end;

function getCombinedPathWithCurrentDir(pathToCombine: string): string;
var
  _result: string;
begin
  _result := getCombinedPath(DirExe, pathToCombine);
  _result:= getValidFullPathInWindowsStyle(_result);

  Result := _result;
end;

function DirExe: string;
begin
  Result := getDirExe;
end;

function getDirExe: string;
begin
  Result := ExtractFileDir(getExeFileName);
end;

function ExeFileName: string;
begin
  Result := getExeFileName;
end;

function getExeFileName: string;
begin
  Result := myParamStr(0);
end;

function getValueOfParameter(parameterNames: TArrayOfStrings): string; overload; //get first param value finded
begin
  Result := getValueOfParameter(parameterNames, EMPTY_ARRAY_OF_STRINGS);
end;

function getValueOfParameter(parameterNames: TArrayOfStrings; valuesExcluded: TArrayOfStrings): string; //get first param value finded
var
  parameterValue: string;

  _countParameterNames: integer;
  i: integer;
  _exit: boolean;
begin
  parameterValue := EMPTY_STRING;

  _countParameterNames := Length(parameterNames);
  if _countParameterNames > 0 then
  begin
    i := 0;
    _exit := false;
    while not _exit do
    begin
      parameterValue := getValueOfParameter(parameterNames[i], valuesExcluded);

      if (parameterValue <> EMPTY_STRING) or (i >= (_countParameterNames - 1)) then
      begin
        _exit := true;
      end
      else
      begin
        inc(i);
      end;
    end;
  end;

  Result := parameterValue;
end;

function getValueOfParameter(parameterName: string): string;
begin
  Result := getValueOfParameter(parameterName, EMPTY_ARRAY_OF_STRINGS);
end;

function getValueOfParameter(parameterName: string; valuesExcluded: TArrayOfStrings): string;
var
  parameterValue: string;

  _parameterName: string;
  i: integer;
  _exit: boolean;
begin
  parameterValue := EMPTY_STRING;

  if myParamCount > 0 then
  begin
    _exit := false;
    i := 1;

    while not _exit do
    begin
      _parameterName := myParamStr(i);
      if (_parameterName = parameterName) then
      begin
        parameterValue := myParamStr(i + 1);

        if not MatchStr(parameterValue, valuesExcluded) then
        begin
          _exit := true;
        end
        else
        begin
          parameterValue := EMPTY_STRING;
        end;
      end;

      if i >= myParamCount then
      begin
        _exit := true;
      end;

      inc(i);
    end;
  end;

  Result := parameterValue;
end;

function checkIfParameterExists(parameterNames: TArrayOfStrings): boolean;
var
  parameterExists: boolean;

  _countParameterNames: integer;
  i: integer;
  _exit: boolean;
begin
  parameterExists := false;

  _countParameterNames := Length(parameterNames);
  if _countParameterNames > 0 then
  begin
    i := 0;
    _exit := false;
    while not _exit do
    begin
      parameterExists := checkIfParameterExists(parameterNames[i]);

      if (parameterExists) or (i >= (_countParameterNames - 1)) then
      begin
        _exit := true;
      end
      else
      begin
        inc(i);
      end;
    end;
  end;

  Result := parameterExists;
end;

function checkIfParameterExists(parameterName: string): boolean;
var
  parameterExists: boolean;

  _parameterName: string;
  i: integer;
  _exit: boolean;
begin
  parameterExists := false;

  _exit := false;
  i := 1;
  while not _exit do
  begin
    _parameterName := myParamStr(i);
    if (_parameterName = parameterName) then
    begin
      parameterExists := true;
      _exit := true;
    end;

    if i >= myParamCount then
    begin
      _exit := true;
    end;

    inc(i);
  end;

  Result := parameterExists;
end;

function myParamCount: Integer;
begin
  Result := Length(shellParams) - 1;
end;

function myParamStr(index: integer): string;
var
  _result: string;
begin
  _result := EMPTY_STRING;
  if index <= myParamCount then
  begin
    _result := shellParams[index];
  end;

  Result := _result;
end;

function getShellParamsAsString: string;
var
  shellParamsAsString: string;
  i: integer;
  _shellParamsLength: integer;
begin
  _shellParamsLength := Length(shellParams);

  for i := 0 to _shellParamsLength - 1 do
  begin
    shellParamsAsString := shellParamsAsString + SPACE_STRING + shellParams[i];
  end;

  Result := shellParamsAsString;
end;

function getShellParams: TArrayOfStrings;
var
  _result: TArrayOfStrings;

  _applicationPath: string;
  _commandLine: string;
  _params: string;
  _paramValue: string;
  _exit: boolean;

  _indexStartSubstring: integer;
  _indexEndSubstring: integer;
  _subString: string;

  _buffer: array [0 .. 260] of Char;
begin
  _result := [];

  SetString(_applicationPath, _buffer, GetModuleFileName(0, _buffer, Length(_buffer)));

  _result := _result + [_applicationPath];

  _applicationPath := getDoubleQuotedString(_applicationPath) + ' ';
  _commandLine := GetCommandLine;

  _params := _commandLine.Replace(_applicationPath, EMPTY_STRING);
  _params := Trim(_params);

  if _params.Length > 0 then
  begin
    _indexStartSubstring := 0;
    _subString := _params;
    _exit := false;
    while not _exit do
    begin
      _indexEndSubstring := -1;

      if (_subString.Chars[0] <> SPACE_STRING) then
      begin
        if (_subString.Chars[0] = '"') then
        begin
          _indexEndSubstring := _subString.Remove(0, 1).IndexOf('"') + 2;
        end
        else if (_subString.Chars[0] = '''') then
        begin
          _indexEndSubstring := _subString.Remove(0, 1).IndexOf('''') + 2;
        end;

        if (_indexEndSubstring = -1) then
        begin
          _indexEndSubstring := _subString.IndexOf(' ');
        end;

        if (_indexEndSubstring = -1) then
        begin
          _indexEndSubstring := _subString.Length;
        end;

        _paramValue := _subString.Substring(_indexStartSubstring, _indexEndSubstring);
        _result := _result + [_paramValue];

        _subString := _subString.Remove(_indexStartSubstring, _indexEndSubstring);

        if _subString.Length = 0 then
        begin
          _exit := true;
        end;
      end
      else
      begin
        _subString := Trim(_subString);
      end;
    end;
  end;

  Result := _result;
end;

function getFileCreationDateTime(fileName: string): TDateTime;
var
  creationDateTimeOfFile: TDateTime;

  _fileTzSpecificLocalTime: TSystemTime;
begin
  _fileTzSpecificLocalTime := getFileTzSpecificLocalTime(fileName, TFileSystemTimeType.created);
  creationDateTimeOfFile := SystemTimeToDateTime(_fileTzSpecificLocalTime);

  Result := creationDateTimeOfFile;
end;

function getFileModifiedDateTime(fileName: string): TDateTime;
var
  modifiedDateTimeOfFile: TDateTime;

  _fileTzSpecificLocalTime: TSystemTime;
begin
  _fileTzSpecificLocalTime := getFileTzSpecificLocalTime(fileName, TFileSystemTimeType.modified);
  modifiedDateTimeOfFile := SystemTimeToDateTime(_fileTzSpecificLocalTime);

  Result := modifiedDateTimeOfFile;
end;

function getFileAccessedDateTime(fileName: string): TDateTime;
var
  accesedDateTimeOfFile: TDateTime;

  _fileTzSpecificLocalTime: TSystemTime;
begin
  _fileTzSpecificLocalTime := getFileTzSpecificLocalTime(fileName, TFileSystemTimeType.accessed);
  accesedDateTimeOfFile := SystemTimeToDateTime(_fileTzSpecificLocalTime);

  Result := accesedDateTimeOfFile;
end;

function getFileTzSpecificLocalTime(fileName: string; fileSystemTimeType: TFileSystemTimeType): TSystemTime;
var
  FileTzSpecificLocalTime: TSystemTime;

  _fileSystemTime: TSystemTime;
begin
  _fileSystemTime := getFileSystemTime(fileName, fileSystemTimeType);

  if not SystemTimeToTzSpecificLocalTime(nil, _fileSystemTime, FileTzSpecificLocalTime) then
  begin
    RaiseLastOSError;
  end;

  Result := FileTzSpecificLocalTime;
end;

function getFileSystemTime(fileName: string; fileSystemTimeType: TFileSystemTimeType): TSystemTime;
var
  FileSystemTime: TSystemTime;

  _fileAttributeData: TWin32FileAttributeData;
  _FILETIME: TFileTime;
begin
  if not GetFileAttributesEx(PChar(fileName), GetFileExInfoStandard, @_fileAttributeData) then
  begin
    RaiseLastOSError;
  end;

  case fileSystemTimeType of
    TFileSystemTimeType.created:
      _FILETIME := _fileAttributeData.ftCreationTime;
    TFileSystemTimeType.modified:
      _FILETIME := _fileAttributeData.ftLastWriteTime;
    TFileSystemTimeType.accessed:
      _FILETIME := _fileAttributeData.ftLastAccessTime;
  end;

  if not FileTimeToSystemTime(_FILETIME, FileSystemTime) then
  begin
    RaiseLastOSError;
  end;

  Result := FileSystemTime;
end;

initialization

shellParams := getShellParams;

end.
