unit KLib.Windows;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellApi,
  System.Classes,
  KLib.Types;

const
  WM_SERVICE_START = WM_USER + 0;
  WM_SERVICE_ERROR = WM_USER + 2;

type
  TMemoryRam = class
  private
    class var RamStats: TMemoryStatusEx;
  public
    class procedure initialize;
    class function getTotalMemoryString: string; overload;
    class function getTotalMemoryDouble: double;
    class function getTotalFreeMemoryString: string;
    class function getTotalFreeMemoryDouble: double;
    class function getPercentageFreeMemory: string;
  end;

  TWindowsService = class
    class procedure aStart(handleSender: HWND; nameService: string; nameMachine: string = '');
    class procedure start(nameService: string; nameMachine: string = '');
    class procedure stopIfExists(nameService: string; nameMachine: string = '';
      force: boolean = false);
    class procedure stop(nameService: string; nameMachine: string = '';
      force: boolean = false);
    class function isRunning(nameService: string; nameMachine: string = ''): boolean;
    class function existsService(nameService: string; nameMachine: string = ''): boolean;
    class procedure deleteService(nameService: string);
    class function isPortAvaliable(host: string; port: Word): boolean;
  protected
    function createService: boolean; overload; virtual; abstract; //TODO IMPLEMENTE CODE
  end;

  //----------------------------------
function getFirstPortAvaliable(defaultPort: integer): integer;

function runUnderWine: boolean;
function getVersionSO: string;
function IsUserAnAdmin: boolean; external shell32;

procedure shellExecuteAndWait(fileName: string; params: string; runAsAdmin: boolean = true;
  showWindow: cardinal = SW_HIDE);
procedure executeAndWaitExe(const pathExe: string);
procedure closeApplication(className, windowsName: string; handleSender: HWND = 0);

function sendDataStruct(className, windowsName: string; handleSender: HWND; data_send: TMemoryStream): boolean;

function netShare(pathFolder: string; netName: string = ''; netPassw: string = ''): string;
procedure addTCP_IN_FirewallException(name: string; port: Word; description: string = ''; grouping: string = '';
  executable: String = '');
procedure grantAllPermissionToObject(windowsUserName: string; myObject: string);

procedure createDesktopLink(fileName: string; nameDesktopLink: string; description: string);
function GetDesktopFolder: string;
function checkIfIsWindowsSubfolder(mainFolder: string; subFolder: string): boolean;
function getValidFullPathInWindowsStyle(path: string): string;
function getPathInWindowsStyle(path: string): string;

//-----------------------------------------------------------------
function setProcessWindowToForeground(processName: string): boolean;
function getPIDOfCurrentUserByProcessName(nameProcess: string): DWORD;
function checkUserOfProcess(userName: String; PID: DWORD): boolean;
function getPIDCredentials(PID: DWORD): TPIDCredentials;
function getPIDByProcessName(nameProcess: string): DWORD;
function getWindowsUsername: string;
function getMainWindowHandleByPID(PID: DWORD): DWORD;

//------------------------------------------------------------------
implementation

uses
  System.IOUtils, System.SysUtils,
  System.Win.ComObj, System.Win.Registry,
  Winapi.AccCtrl, Winapi.ACLAPI, Winapi.TLHelp32, Winapi.ActiveX, Winapi.Winsvc, Winapi.Shlobj,
  Vcl.Forms,
  IdTCPClient,
  KLib.Utils;

class procedure TMemoryRam.initialize;
begin
  FillChar(RamStats, SizeOf(MemoryStatusEx), #0);
  RamStats.dwLength := SizeOf(MemoryStatusEx);
  GlobalMemoryStatusEx(RamStats);
end;

class function TMemoryRam.getTotalMemoryString: string;
begin
  result := floattostr(RamStats.ullTotalPhys / 1048576) + ' MB';
end;

class function TMemoryRam.getTotalMemoryDouble: Double;
begin
  result := RamStats.ullTotalPhys / 1048576;
end;

class function TMemoryRam.getTotalFreeMemoryString: string;
begin
  result := floattostr(RamStats.ullAvailPhys / 1048576) + ' MB';
end;

class function TMemoryRam.getTotalFreeMemoryDouble: Double;
begin
  result := RamStats.ullAvailPhys / 1048576;
end;

class function TMemoryRam.getPercentageFreeMemory: string;
begin
  result := inttostr(RamStats.dwMemoryLoad) + '%';
end;

//----------------------------------------------------------------------------------------

class procedure TWindowsService.aStart(handleSender: HWND; nameService: string;
  nameMachine: string = '');
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        TWindowsService.Start(nameService, nameMachine);
        PostMessage(handleSender, WM_SERVICE_START, 0, 0);
      except
        on E: Exception do
        begin
          PostMessage(handleSender, WM_SERVICE_ERROR, 0, 0);
        end;
      end;
    end).Start;
end;

class procedure TWindowsService.Start(nameService: string; nameMachine: string = '');
const
  ERR_MSG = 'Service not started';
var
  cont: integer;
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
  dwCheckpoint: DWord;
  dwWaitTime: DWord;

  _exit: boolean;
begin
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (QueryServiceStatus(handleService, serviceStatus)) then
      begin
        if (serviceStatus.dwCurrentState = SERVICE_RUNNING) then
        begin
          CloseServiceHandle(handleService);
          CloseServiceHandle(handleServiceControlManager);
          Exit;
        end;

        if not startService(handleService, 0, PPChar(nil)^) then
        begin
          raise Exception.Create(ERR_MSG);
          CloseServiceHandle(handleService);
          CloseServiceHandle(handleServiceControlManager);
          Exit;
        end;
        QueryServiceStatus(handleService, serviceStatus);

        //stato servizio a partire...
        _exit := false;
        cont := 0;
        while not(_exit) do
        begin
          QueryServiceStatus(handleService, serviceStatus);
          if (serviceStatus.dwCurrentState = SERVICE_RUNNING) or (cont >= 30) then
          begin
            _exit := true;
          end;
          Sleep(3000);

          cont := cont + 1;
        end;
        //        while not(serviceStatus.dwCurrentState = SERVICE_RUNNING) and (cont < 15) do
        //        begin
        //          dwCheckpoint := serviceStatus.dwCheckPoint;
        //          dwWaitTime := serviceStatus.dwWaitHint div 10;
        //          Sleep(dwWaitTime);
        //
        //          if (not QueryServiceStatus(handleService, serviceStatus)) then
        //            break;
        //          if (serviceStatus.dwCheckPoint > dwCheckpoint) then
        //            break;
        //          cont := cont + 1;
        //        end;
      end;
    end;
    QueryServiceStatus(handleService, serviceStatus);
    if not(serviceStatus.dwCurrentState = SERVICE_RUNNING) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
    CloseServiceHandle(handleService);
  end;
  CloseServiceHandle(handleServiceControlManager);
end;

class procedure TWindowsService.stopIfExists(nameService: string; nameMachine: string = '';
force: boolean = false);
begin
  if existsService(nameService) then
  begin
    stop(nameService, nameMachine, force);
  end;
end;

class procedure TWindowsService.Stop(nameService: string; nameMachine: string = '';
force: boolean = false);
const
  ERR_MSG = 'Service not stopped';
var
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
  dwCheckpoint: DWord;
begin
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_STOP or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (ControlService(handleService, SERVICE_CONTROL_STOP, serviceStatus)) then
      begin
        if (QueryServiceStatus(handleService, serviceStatus)) then
        begin
          while (SERVICE_STOPPED <> serviceStatus.dwCurrentState) do
          begin
            dwCheckpoint := serviceStatus.dwCheckPoint;
            Sleep(250);
            if (not QueryServiceStatus(handleService, serviceStatus)) then
              break;
            if (serviceStatus.dwCheckPoint > dwCheckpoint) then
              break;
          end;
        end;
      end
      else
      begin
        if (force) then
        begin
          //kill processo servizio
          shellExecuteAndWait('cmd.exe', PCHAR('/K taskkill /f /fi "SERVICES eq ' + nameService + '" & EXIT'));
        end;
      end;
      QueryServiceStatus(handleService, serviceStatus);
      CloseServiceHandle(handleService);
    end;
    CloseServiceHandle(handleService);
  end;
  if not(serviceStatus.dwCurrentState = SERVICE_STOPPED) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
end;

class function TWindowsService.isRunning(nameService: string; nameMachine: string = ''): boolean;
var
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
begin
  result := false;
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (QueryServiceStatus(handleService, serviceStatus)) then
      begin
        if (serviceStatus.dwCurrentState = SERVICE_RUNNING) then
        begin
          Result := True;
        end;
      end;
    end;
    CloseServiceHandle(handleService);
  end;
  CloseServiceHandle(handleServiceControlManager);
end;

class function TWindowsService.existsService(nameService: string; nameMachine: string = ''): Boolean;
var
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
  dwCheckpoint: DWord;
  dwWaitTime: DWord;
begin
  try
    handleServiceControlManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    handleService := OpenService(handleServiceControlManager, PChar(nameService),
      SERVICE_ALL_ACCESS);
  except
    RaiseLastOSError;
  end;
  if (GetLastError() <> ERROR_SUCCESS) then
  begin
    Result := false;
  end
  else
  begin
    Result := true;
  end;
  CloseServiceHandle(handleService);
  CloseServiceHandle(handleServiceControlManager);
end;

class procedure TWindowsService.deleteService(nameService: string);
begin
  if (existsService(nameService)) then
  begin
    if isRunning(nameService) then
    begin
      stop(nameService, '', true);
    end;
    shellExecuteAndWait('cmd.exe', pchar('/K SC DELETE ' + nameService + ' & EXIT'));
    if (existsService(nameService)) then
    begin
      raise Exception.Create('Unable to delete the Windows service.');
    end;
  end;
end;

class function TWindowsService.isPortAvaliable(host: string; port: Word): boolean;
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

function getFirstPortAvaliable(defaultPort: integer): integer;
var
  _port: integer;
begin
  _port := defaultPort;
  while not TWindowsService.isPortAvaliable('127.0.0.1', _port) do
  begin
    inc(_port);
  end;
  result := _port;
end;

function runUnderWine: boolean;
begin
  //check if application runs under Wine
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('Software\Wine') then
      begin
        Result := true;
      end
      else
      begin
        Result := false;
      end;
    finally
      Free;
    end;
end;

function getVersionSO: string;
begin
  case TOSVersion.Architecture of
    arIntelX86:
      Result := '32_bit';
    arIntelX64:
      Result := '64_bit';
  else
    Result := 'Unknown OS architecture';
  end;
end;

procedure shellExecuteAndWait(fileName: string; params: string; runAsAdmin: boolean = true;
showWindow: cardinal = SW_HIDE);
var
  exInfo: TShellExecuteInfo;
  Ph: DWORD;
begin
  FillChar(exInfo, SizeOf(exInfo), 0);
  with exInfo do
  begin
    cbSize := SizeOf(exInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    Wnd := GetActiveWindow();
    if (runAsAdmin) then
    begin
      exInfo.lpVerb := 'runas';
    end
    else
    begin
      exInfo.lpVerb := '';
    end;
    exInfo.lpParameters := PChar(Params);
    lpFile := PChar(FileName);
    nShow := showWindow;
  end;
  if ShellExecuteEx(@exInfo) then
    Ph := exInfo.hProcess
  else
  begin
    raise Exception.Create(SysErrorMessage(GetLastError));
  end;
  while WaitForSingleObject(exInfo.hProcess, 50) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;
  CloseHandle(Ph);
end;

procedure executeAndWaitExe(const pathExe: string); // full path più eventuali parametri
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(pathExe);
  fillChar(tmpStartupInfo, sizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if createProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 10 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 10) > 0 do
    begin
      application.ProcessMessages;
    end;
    closeHandle(tmpProcessInformation.hProcess);
    closeHandle(tmpProcessInformation.hThread);
  end
  else
  begin
    raiseLastOSError;
  end;
end;

procedure closeApplication(className, windowsName: string; handleSender: HWND = 0);
var
  receiverHandle: THandle;
begin
  //identificazione finestra tramite tipo oggetto e windows name (caption)
  receiverHandle := 1;
  while (receiverHandle <> 0) do
  begin
    receiverHandle := FindWindow(PChar(className), PChar(windowsName));
    if (receiverHandle <> 0) then
    begin
      SendMessage(receiverHandle, WM_CLOSE, Integer(handleSender), 0);
    end;
  end;
end;

function sendDataStruct(className, windowsName: string; handleSender: HWND; data_send: TMemoryStream): boolean;
var
  receiverHandle: THandle;
  copyDataStruct: TCopyDataStruct;
begin
  //identificazione finestra tramite tipo oggetto e windows name (caption)
  receiverHandle := FindWindow(PChar(className), PChar(windowsName));
  if receiverHandle <> 0 then
  begin
    copyDataStruct.dwData := integer(data_send.Memory);
    copyDataStruct.cbData := data_send.size;
    copyDataStruct.lpData := data_send.Memory;
    if (SendMessage(receiverHandle, WM_COPYDATA, Integer(handleSender), Integer(@copyDataStruct)) <> 1) then
    begin
      result := false;
    end
    else
    begin
      result := true;
    end;
  end
  else
  begin
    result := false;
  end;
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

  TExplicitAccess = EXPLICIT_ACCESS_A;

procedure grantAllPermissionNet(user, source: string);
var
  NewDacl, OldDacl: PACl;
  SD: PSECURITY_DESCRIPTOR;
  EA: TExplicitAccess;
begin
  GetNamedSecurityInfo(PChar(source), SE_LMSHARE, DACL_SECURITY_INFORMATION, nil, nil, @OldDacl, nil, SD);
  BuildExplicitAccessWithName(@EA, PChar(user), GENERIC_ALL, GRANT_ACCESS, SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @EA, OldDacl, NewDacl);
  SetNamedSecurityInfo(PChar(source), SE_LMSHARE, DACL_SECURITY_INFORMATION, nil, nil, NewDacl, nil);
end;

function netShareAdd(servername: PWideChar; level: DWORD; buf: Pointer; parm_err: LPDWORD): DWORD; stdcall;
  external 'NetAPI32.dll' name 'NetShareAdd';

function netShare(pathFolder: string; netName: string = ''; netPassw: string = ''): string;
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
var
  AShareInfo: PSHARE_INFO_2;
  parmError: DWORD;
  pathShareFolder: string;
  shareExistsAlready: boolean;
begin
  shareExistsAlready := false;
  pathFolder := ExcludeTrailingPathDelimiter(pathFolder);
  AShareInfo := New(PSHARE_INFO_2);
  try
    with AShareInfo^ do
    begin
      if (netName = '') then
      begin
        shi2_netname := PWideChar(extractfilename(pathFolder));
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
      shi2_path := PWideChar(pathFolder);
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

    pathShareFolder := '\\' + GetEnvironmentVariable('COMPUTERNAME') + '\' + AShareInfo.shi2_netname;

    if DirectoryExists(pathShareFolder) then
    begin
      if not shareExistsAlready then
      begin
        grantAllPermissionNet('Everyone', pathShareFolder);
      end;
      Result := pathShareFolder;
    end
    else
    begin
      Result := 'error';
    end;

  finally
    FreeMem(AShareInfo, SizeOf(PSHARE_INFO_2));
  end;
end;

procedure addTCP_IN_FirewallException(name: string; port: Word; description: string = ''; grouping: string = '';
executable: String = '');
const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;
  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_ACTION_ALLOW = 1;
  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;
var
  fwPolicy2: OleVariant;
  RulesObject: OleVariant;
  Profile: Integer;
  NewRule: OleVariant;
begin
  CoInitialize(nil);

  Profile := NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC OR NET_FW_PROFILE2_DOMAIN;
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;

  NewRule := CreateOleObject('HNetCfg.FWRule');
  NewRule.Name := name;

  if (description <> '') then
  begin
    NewRule.Description := description;
  end
  else
  begin
    NewRule.Description := name;
  end;

  if (executable <> '') then
  begin
    NewRule.Applicationname := executable;
  end;
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts := port;
  NewRule.Direction := NET_FW_RULE_DIR_IN;
  NewRule.Enabled := TRUE;
  if (grouping <> '') then
  begin
    NewRule.Grouping := grouping;
  end;
  NewRule.Profiles := Profile;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  RulesObject.Add(NewRule);

  CoUninitialize;
end;

procedure grantAllPermissionToObject(windowsUserName: string; myObject: string);
var
  NewDacl, OldDacl: PACl;
  SD: PSECURITY_DESCRIPTOR;
  EA: TExplicitAccess;
begin
  GetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, @OldDacl, nil, SD);
  BuildExplicitAccessWithName(@EA, PChar(windowsUserName), GENERIC_ALL, GRANT_ACCESS, SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @EA, OldDacl, NewDacl);
  SetNamedSecurityInfo(PChar(myObject), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, NewDacl, nil);
end;

procedure createDesktopLink(fileName: string; nameDesktopLink: string; description: string);
var
  iobject: iunknown;
  islink: ishelllink;
  ipfile: ipersistfile;
  pidl: pitemidlist;
  infolder: array [0 .. MAX_PATH] of char;
  targetName: string;
  linkname: string;
begin
  targetname := getValidFullPath(fileName);
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

  LinkName := IncludeTrailingBackslash(GetDesktopFolder);
  LinkName := LinkName + nameDesktopLink + '.lnk';

  if not IPFile.Save(PWideChar(LinkName), False) = S_OK then
  begin
    raise Exception.Create('Error creating desktop icon.');
  end;
end;

function GetDesktopFolder: string;
var
  PIDList: PItemIDList;
  Buffer: array [0 .. MAX_PATH - 1] of Char;
begin
  Result := '';
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, PIDList);
  if Assigned(PIDList) then
    if SHGetPathFromIDList(PIDList, Buffer) then
      Result := Buffer;
end;

function checkIfIsWindowsSubfolder(mainFolder: string; subFolder: string): boolean;
var
  _mainFolder: string;
  _subFolder: string;
  _isSubFolder: Boolean;
begin
  _mainFolder := getPathInWindowsStyle(mainFolder);
  _subFolder := getPathInWindowsStyle(subFolder);
  _isSubFolder := checkIfIsSubFolder(_mainFolder, _subFolder);
  result := _isSubFolder
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

//----------------------------------------------------------------------
procedure mySetForegroundWindow(windowHandle: THandle); forward;

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

procedure mySetForegroundWindow(windowHandle: THandle);
begin
  SetForegroundWindow(windowHandle);
  postMessage(windowHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
end;

type
  TEnumInfo = record
    ProcessID: DWORD;
    HWND: THandle;
  end;

  PEnumInfo = ^TEnumInfo;

function enumWindowsProc(Wnd: HWND; Param: LPARAM): Bool; stdcall; forward;

function getMainWindowHandleByPID(PID: DWORD): DWORD;
var
  enumInfo: TEnumInfo;
begin
  enumInfo.ProcessID := PID;
  enumInfo.HWND := 0;
  EnumWindows(@enumWindowsProc, LPARAM(@enumInfo));
  Result := enumInfo.HWND;
end;

function enumWindowsProc(Wnd: HWND; Param: LPARAM): Bool; stdcall;
var
  PID: DWORD;
  PEI: PEnumInfo;
begin
  // Param matches the address of the param that is passed

  PEI := PEnumInfo(Param);
  GetWindowThreadProcessID(Wnd, @PID);

  Result := (PID <> PEI^.ProcessID) or
    (not IsWindowVisible(WND)) or
    (not IsWindowEnabled(WND));

  if not Result then
    PEI^.HWND := WND; //break on return FALSE
end;

//TODO: CREARE CLASSE PER RAGGUPPARE OGGETTI
type
  TProcessCompare = record
    username: string;
    nameProcess: string;
  end;

  TFunctionProcessCompare = function(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean;

function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD; forward;

function checkProcessName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
begin
  if processEntry.szExeFile = processCompare.nameProcess then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

function checkProcessUserName(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean; // FUNZIONE PRIVATA
var
  sameProcessName: boolean;
  sameUserOfProcess: boolean;
begin
  sameProcessName := checkProcessName(processEntry, processCompare);
  sameUserOfProcess := checkUserOfProcess(processCompare.username, processEntry.th32ProcessID);
  if sameProcessName and sameUserOfProcess then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

function getPIDOfCurrentUserByProcessName(nameProcess: string): DWORD;
var
  processCompare: TProcessCompare;
begin
  processCompare.nameProcess := nameProcess;
  processCompare.username := getWindowsUsername();
  result := getPID(nameProcess, checkProcessUserName, processCompare);
end;

function getPIDByProcessName(nameProcess: string): DWORD;
var
  processCompare: TProcessCompare;
begin
  processCompare.nameProcess := nameProcess;
  result := getPID(nameProcess, checkProcessName, processCompare);
end;

function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD;
var
  processEntry: TProcessEntry32;
  handleSnap: THandle;
  processID: DWORD;
begin
  processID := 0;
  handleSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  processEntry.dwSize := sizeof(TProcessEntry32);
  Process32First(handleSnap, processEntry);
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
  until (not(Process32Next(handleSnap, processEntry)));
  CloseHandle(handleSnap);

  result := processID;
end;

function checkUserOfProcess(userName: String; PID: DWORD): boolean;
var
  PIDCredentials: TPIDCredentials;
begin
  PIDCredentials := GetPIDCredentials(PID);
  if PIDCredentials.ownerUserName = userName then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
  end;
end;

function getWindowsUsername: string;
var
  userName: string;
  userNameLen: DWORD;
begin
  userNameLen := 256;
  SetLength(userName, userNameLen);
  if GetUserName(PChar(userName), userNameLen)
  then
    Result := Copy(userName, 1, userNameLen - 1)
  else
    Result := '';
end;

type
  _TOKEN_USER = record
    User: TSidAndAttributes;
  end;

  PTOKEN_USER = ^_TOKEN_USER;

function GetPIDCredentials(PID: DWORD): TPIDCredentials;
var
  hToken: THandle;
  cbBuf: Cardinal;
  ptiUser: PTOKEN_USER;
  snu: SID_NAME_USE;
  ProcessHandle: THandle;
  UserSize, DomainSize: DWORD;
  bSuccess: Boolean;
  user: string;
  domain: string;
  PIDCredentials: TPIDCredentials;
begin
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
  if ProcessHandle <> 0 then
  begin
    if OpenProcessToken(ProcessHandle, TOKEN_QUERY, hToken) then
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
    CloseHandle(ProcessHandle);
  end;

  Result := PIDCredentials;
end;
//----------------------------------------------------------------------------------------

end.
