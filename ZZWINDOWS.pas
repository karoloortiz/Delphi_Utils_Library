unit ZZWINDOWS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AccCtrl,
  ACLAPI, ShellAPI, system.IOUtils, System.Zip, Vcl.ComCtrls, Winsvc, ComObj,
  ActiveX, IdHttp, IdComponent, URLMon, IdTCPClient, Winsock,
  Vcl.StdCtrls, Vcl.ExtCtrls, Registry,
  TLHelp32,
  MyAccess, inifiles;

const
  WM_SERVICE_START = WM_USER + 0;
  WM_SERVICE_STOP = WM_USER + 1;
  WM_SERVICE_ERROR = WM_USER + 2;
  WM_DOWNLOAD_COMPLETE = WM_USER + 10;

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

  //----------------------------------
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  //----------------------------------
  TExplicitAccess = EXPLICIT_ACCESS_A;

  //----------------------------------
  TEnumInfo = record
    ProcessID: DWORD;
    HWND: THandle;
  end;

  PEnumInfo = ^TEnumInfo;

  //----------------------------------
  TPIDCredentials = record
    ownerUserName: string;
    domain: string;
  end;

  //----------------------------------
  _TOKEN_USER = record
    User: TSidAndAttributes;
  end;

  PTOKEN_USER = ^_TOKEN_USER;

  //----------------------------------
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

  //----------------------------------
  TWindowsService = class
    class procedure aStart(handleSender: HWND; nameService: string; nameMachine: string = ''); overload;
    class function start(nameService: string; nameMachine: string = ''): Boolean; overload;
    class function stop(nameService: string; nameMachine: string = ''; force: boolean = false): Boolean; overload;
    class function existsService(nameService: string; nameMachine: string = ''): Boolean; overload;
    function deleteService(nameService: string): boolean; overload;
    class function isPortAvaliable(host: string; port: Word): boolean;
  private
    name_s: string;
    port_s: integer;
    class var handleSCM, handleS: SC_HANDLE;
    class var statusS: TServiceStatus;
    class var dwChkP, dwWaitT: DWord;
    function getNameService: string;
    procedure setNameService(const Value: string);
    function getPortService: integer;
    procedure setPortService(const Value: integer);
    class function getHandleSCM: SC_HANDLE; static;
    class procedure setHandleSCM(const Value: SC_HANDLE); static;
    class function getHandleS: SC_HANDLE; static;
    class procedure setHandleS(const Value: SC_HANDLE); static;
    class function getstatusS: TServiceStatus; static;
    class procedure setstatusS(const Value: TServiceStatus); static;
    class function getDwChkP: DWord; static;
    class procedure setDwChkP(const Value: DWord); static;
    class function getDwWaitTime: DWord; static;
    class procedure setDwWaitTime(const Value: DWord); static;
  protected
    property nameService: string read getNameService write setNameService;
    property portService: integer read getPortService write setPortService;
    class property handleService_control_manager: SC_HANDLE read getHandleSCM write setHandleSCM;
    class property handleService: SC_HANDLE read getHandleS write setHandleS;
    class property service_status: TServiceStatus read getstatusS write setstatusS;
    class property dwCheckpoint: DWord read getDwChkP write setDwChkP;
    class property dwWaitTime: DWord read getDwWaitTime write setDwWaitTime;
    procedure aStart; overload; virtual; abstract;
    function start: boolean; overload; virtual; abstract;
    function stop: boolean; overload; virtual; abstract;
    function existsService: boolean; overload; virtual; abstract;
    function createService: boolean; overload; virtual; abstract;
  end;

  TMySQLService = class(TWindowsService)
  public
    pathMysqlBin: string;
    constructor create(nameService: string; portService: integer; pathMysqlBin: string);
    function deleteService: boolean; overload;
    procedure aStart(handleSender: HWND); overload;
    procedure stop; overload;
    function existsService: boolean; overload;
    function createService(path_my_ini: string; forceInstall: boolean = false): boolean;
    procedure mysqldump(username, password, database, fileNameOut: string);
    procedure mysqlpump(username, password, database, fileNameOut: string);
    procedure importScript(username, password, fileNameIn: string);
  end;

  TCredentials = record
    username: string;
    password: string;
  end;

  TMySQLInfo = record
  private
    _path_bin: string;
    procedure setPath_bin(path_bin: string);
  public
    path_ini: string;
    property path_bin: string read _path_bin write setPath_bin;
    function getPath_mysqladmin: string;
    function getPath_mysqld: string;
  end;

  TMySQL = class
  private
    active: boolean;
    commandCredentials: string;
    _credentials: TCredentials;
    procedure setCredentials(credentials: TCredentials);
    procedure initialCheckAndSetup;
    function checkLibVisualStudio2013: boolean;
    procedure installLibVisualStudio2013;
    procedure waitUntilProcessStart;
    procedure setCommandCredentials;
    procedure setPortToIni(port: integer);
    function getPortFromIni: integer;
  public
    database: string;
    MySQLInfo: TMySQLInfo;
    iniFileManipulator: TIniFile;
    property credentials: TCredentials read _credentials write setCredentials;
    property port: integer read getPortFromIni write setPortToIni;
    constructor create(credentials: TCredentials; MySQLInfo: TMySQLInfo);
    procedure start;
    procedure stop;

  end;

  //----------------------------------
  TLabel_loading = class
  private
    originalText: string;
    timer: TTimer;
    count: integer;
    lblSource: TLabel;
    procedure on_timer(Sender: TObject);
    procedure setLabelSource(const Value: TLabel);
    function getLabelSource: TLabel;
  public
    repeatMax: integer;
    textToRepeat: string;
    property labelSource: TLabel read getLabelSource write setLabelSource;
    constructor Create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3); overload;
    constructor Create(textToRepeat: string; countRepeatMax: integer = 3); overload;
    destructor Destroy; override;
    procedure start;
    procedure stop;
  end;

function runUnderWine: boolean;
function getVersionSO: string;
function shellExecuteAndWait(FileName, Params: string; Admin: boolean = true; showWindow: cardinal = SW_HIDE): boolean;
function sendDataStruct(className, windowsName: string; handleSender: HWND; data_send: TMemoryStream): boolean;
function closeApplication(className, windowsName: string; handleSender: HWND = 0): boolean;
function extractZip(ZipFile: string; ExtractPath: string; delete_file: boolean = false): boolean;
procedure addExceptionFirewall(Name: string; Port: Word; Description: string = ''; Grouping: string = ''; Executable: String = '');
procedure grantAllPermissionObject(user, source: string);
function readStringWithEnvVariables(source: string): string;
procedure executeAndWait(const aCommando: string);

function netShare(pathFolder: string; netName: string = ''; netPassw: string = ''): string;

function customMessageDlg(CONST Msg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons;
  Caption: ARRAY OF string; dlgcaption: string): Integer;
procedure setComponentInMiddlePosition(control: TControl);
function getIPAddress: string;
procedure deleteDirectory(const dirName: string);
function getDirExe: string;

function getFirstPortAvaliable(defaultPort: integer): integer;

//-----------------------------------------------------------------
function setProcessWindowToForeground(processName: string): boolean;
function getPIDOfCurrentUserByProcessName(nameProcess: string): DWORD;
function checkUserOfProcess(userName: String; PID: DWORD): boolean;
function GetPIDCredentials(PID: DWORD): TPIDCredentials;
function getPIDByProcessName(nameProcess: string): DWORD;
function getWindowsUsername: string;

function getMainWindowHandleByPID(PID: DWORD): DWORD;
function enumWindowsProc(Wnd: HWND; Param: LPARAM): Bool; stdcall;

//prove
type
  TProcessCompare = record
    username: string;
    nameProcess: string;
  end;

  TFunctionProcessCompare = function(processEntry: TProcessEntry32; processCompare: TProcessCompare): boolean;
function getPID(nameProcess: string; fn: TFunctionProcessCompare; processCompare: TProcessCompare): DWORD;

//------------------------------------------------------------------
implementation

function getDirExe: string;
begin
  result := ExtractFileDir(ParamStr(0));
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

procedure executeAndWait(const aCommando: string); // full path più eventuali parametri
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(aCommando);
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

function netShareAdd(servername: PWideChar; level: DWORD; buf: Pointer; parm_err: LPDWORD): DWORD; stdcall;
  external 'NetAPI32.dll' name 'NetShareAdd';

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

constructor TLabel_loading.Create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.labelSource := labelSource;
  Create(textToRepeat, countRepeatMax);
end;

constructor TLabel_loading.Create(textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.textToRepeat := textToRepeat;
  Self.repeatMax := countRepeatMax;
  Self.count := 0;
  Self.originalText := labelSource.Caption;
  timer := TTimer.Create(nil);
  Timer.Interval := 600;
  Timer.OnTimer := on_timer;
  Timer.Enabled := false;
end;

destructor TLabel_loading.Destroy;
begin
  FreeAndNil(timer);
  inherited Destroy;
end;

procedure TLabel_loading.setLabelSource(const Value: TLabel);
begin
  Self.stop;
  lblSource := Value;
  Self.originalText := Value.Caption;
  Self.start;
end;

function TLabel_loading.getLabelSource: TLabel;
begin
  Result := lblSource;
end;

procedure TLabel_loading.on_timer(Sender: TObject);
begin
  if (count = repeatMax) then
  begin
    labelSource.Caption := originalText;
    count := 0;
  end
  else
  begin
    labelSource.Caption := labelSource.Caption + textToRepeat;
    inc(count);
  end;
end;

procedure TLabel_loading.start;
begin
  timer.Enabled := true;
end;

procedure TLabel_loading.stop;
begin
  timer.Enabled := false;
  lblSource.Caption := originalText;
end;

constructor TMySQLService.Create(nameService: string; portService: integer; pathMysqlBin: string);
begin
  Self.nameService := nameService;
  Self.pathMysqlBin := pathMysqlBin;
  self.portService := portService;
end;

function TMySQLService.deleteService: boolean;
begin
  Result := deleteService(Self.nameService);
end;

procedure TMySQLService.aStart(handleSender: HWND);
begin
  aStart(handleSender, nameService);
end;

procedure TMySQLService.Stop;
begin
  stop(nameService);
end;

function TMySQLService.existsService: boolean;
begin
  Result := existsService(nameService);
end;

procedure TMySQLService.mysqldump(username, password, database, fileNameOut: string);
var
  parametriMysqldump, parametriShell: string;
begin
  parametriMysqldump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(port_s) + ' --databases ' + database + ' --skip-triggers > ' + fileNameOut;
  parametriShell := '/K ""' + pathMysqlBin + '\mysqldump.exe" ' + parametriMysqldump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

procedure TMySQLService.mysqlpump(username, password, database, fileNameOut: string);
var
  parametriMysqlpump, parametriShell: string;
begin
  parametriMysqlpump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(port_s) + ' --databases ' + database + ' --skip-triggers > ' + fileNameOut;
  parametriShell := '/K ""' + pathMysqlBin + '\mysqlpump.exe" ' + parametriMysqlpump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

procedure TMySQLService.importScript(username, password, fileNameIn: string);
var
  parametriMysqldump, parametriShell: string;
begin
  parametriMysqldump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(port_s) + ' < ' + fileNameIn;
  parametriShell := '/K ""' + pathMysqlBin + '\mysql.exe" ' + parametriMysqldump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

function TMySQLService.createService(path_my_ini: string; forceInstall: boolean = false): boolean;
var
  parametri, comandoCreazioneServizio: string;
begin
  parametri := '--install ' + nameService + ' --defaults-file="' + path_my_ini + '"';
  comandoCreazioneServizio := '/K ""' + pathMysqlBin + '\mysqld.exe" ' + parametri + '"';

  //installazione servizio con wait
  if (existsService(nameService)) then
  begin
    if (forceInstall) then
    begin
      deleteService;
    end
    else
    begin
      result := false;
      exit;
    end;
  end;

  shellExecuteAndWait('cmd.exe', PCHAR(comandoCreazioneServizio + ' & EXIT'));

  if (existsService(nameService)) then
  begin
    result := true;
  end
  else
  begin
    Result := false;
  end;
end;

procedure TMySQLInfo.setPath_bin(path_bin: string);
begin
  _path_bin := ExcludeTrailingPathDelimiter(path_bin);
end;

function TMySQLInfo.getPath_mysqladmin: string;
begin
  Result := path_bin + '\mysqladmin.exe';
end;

function TMySQLInfo.getPath_mysqld: string;
begin
  Result := path_bin + '\mysqld.exe';
end;

constructor TMySQL.create(credentials: TCredentials; MySQLInfo: TMySQLInfo);
begin
  iniFileManipulator := TIniFile.Create(MySQLInfo.path_ini);
  Self.credentials := credentials;
  self.MySQLInfo := MySQLInfo;
  initialCheckAndSetup;
end;

procedure TMySQL.setCredentials(credentials: TCredentials);
begin
  _credentials := credentials;
  setCommandCredentials;
end;

procedure TMySQL.start; // possible exception raised
var
  mysqld_command: string;
  path_myIni: string;
  path_mysqld: string;
begin
  path_myIni := ExcludeTrailingPathDelimiter(MySQLInfo.path_ini);
  path_mysqld := MySQLInfo.getPath_mysqld;
  if not fileexists(path_mysqld) and not fileexists(path_myIni) then
  begin
    raise Exception.Create('path_myIni or path_bin not exists.');
  end;
  mysqld_command := ' --defaults-file="' + path_myIni + '"';
  shellExecute(0, 'open', pchar(path_mysqld), PCHAR(mysqld_command), nil, SW_HIDE);

  waitUntilProcessStart;
end;

procedure TMySQL.waitUntilProcessStart;
var
  i: integer;
  _exit: boolean;
  _connected: boolean;
  connection: TMyConnection;
begin
  i := 0;
  _exit := false;
  _connected := false;
  connection := TMyConnection.Create(nil);
  connection.Username := credentials.username;
  connection.Password := credentials.password;
  connection.Port := port;
  while not _exit do
  begin
    if (i > 10) then
    begin
      if messagedlg('Apparentely MySQL takes long time to start, would you wait?',
        mtCustom, [mbYes, mbCancel], 0) = mrYes then
      begin
        i := 0;
      end
      else
      begin
        _exit := true;
      end;
    end;
    try
      connection.Connected := true;
      connection.Connected := false;
      _connected := true;
      _exit := true;
    except
      Inc(i, 1);
      sleep(3000);
    end;
  end;

  FreeAndNil(connection);
  if not _connected then
  begin
    raise Exception.Create('MySQL not started.');
  end;
end;

procedure TMySQL.stop;
var
  mysqld_command: string;
begin
  mysqld_command := commandCredentials + 'shutdown ';
  shellExecute(0, 'open', pchar(MySQLInfo.getPath_mysqladmin), PCHAR(mysqld_command), nil, SW_HIDE);
end;

procedure TMySQL.setCommandCredentials;
begin
  self.commandCredentials := '-u ' + _credentials.username + ' -p' + _credentials.password +
    ' --port ' + IntToStr(port) + ' ';
end;

procedure TMySQL.setPortToIni(port: integer);
begin
  iniFileManipulator.WriteInteger('mysqld', 'port', Self.port);
  setCommandCredentials;
end;

function TMySQL.getPortFromIni: integer;
begin
  Result := iniFileManipulator.ReadInteger('mysqld', 'port', 0);
end;

procedure TMySQL.initialCheckAndSetup;
begin
  active := true;
  try
    if not checkLibVisualStudio2013 then
    begin
      installLibVisualStudio2013;
    end;
  except
    on E: Exception do
    begin
      active := false;
      ShowMessage(e.Message);
    end;
  end;
end;

function TMySQL.checkLibVisualStudio2013: boolean;
var
  reg: TRegistry;
  carica_risorsa: TResourceStream;
begin
  result := true;
  //VERIFICA la presenza di Visual C++ Redistributable Package per Visual Studio 2013
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if (not OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x86')) and
        (not OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x64')) then
      begin
        result := false;
      end;
    finally
      Free;
    end;
end;

procedure TMySQL.installLibVisualStudio2013;
var
  carica_risorsa: TResourceStream;
begin
  ShowMessage('MySQL needs:' + #13#10 +
    'Visual C++ Redistributable Package Visual Studio 2013.' + #13#10 + #13#10 +
    'The installer will run.');
  // TO-DO? check version of system and install correct version (32 or 64 bit)?
  //------------------------------------------------------------
  //QUANDO SI UTILIZZA AGGIUNGERE "VCREDIST_32_bit EXE vcredist_x86.exe" al file risorse DEL PROGETTO
  //-----------------------------------------------------------
  if (FindResource(hInstance, PChar('VCREDIST_32_bit'), PChar('EXE')) <> 0) then
  begin
    carica_risorsa := TResourceStream.Create(HInstance, PChar('VCREDIST_32_bit'), PChar('EXE'));
    try
      carica_risorsa.Position := 0;
      carica_risorsa.SaveToFile('vcredist.exe');
    finally
      carica_risorsa.Free;
    end;
  end;
  ExecuteAndWait(GetCurrentDir + '\vcredist.exe');
  DeleteFile('vcredist.exe');
  if not checkLibVisualStudio2013 then
  begin
    raise Exception.Create('Visual C++ Redistributable Visual Studio 2013 not correctly installed.');
  end;
end;

function TWindowsService.getNameService: string;
begin
  result := name_s;
end;

procedure TWindowsService.setNameService(const Value: string);
begin
  name_s := Value;
end;

function TWindowsService.getPortService: integer;
begin
  result := port_s;
end;

procedure TWindowsService.setPortService(const Value: integer);
begin
  port_s := Value;
end;

class function TWindowsService.getHandleSCM: SC_HANDLE;
begin
  Result := handleSCM;
end;

class procedure TWindowsService.setHandleSCM(const Value: SC_HANDLE);
begin
  handleSCM := Value;
end;

class function TWindowsService.getHandleS: SC_HANDLE;
begin
  Result := handleS;
end;

class procedure TWindowsService.setHandleS(const Value: SC_HANDLE);
begin
  handleSCM := Value;
end;

class function TWindowsService.getstatusS: TServiceStatus;
begin
  Result := statusS;
end;

class procedure TWindowsService.setstatusS(const Value: TServiceStatus);
begin
  statusS := Value;
end;

class function TWindowsService.getDwChkP: DWord;
begin
  Result := dwChkP;
end;

class procedure TWindowsService.setDwChkP(const Value: DWord);
begin
  dwChkP := Value;
end;

class function TWindowsService.getDwWaitTime: DWord;
begin
  Result := dwWaitT;
end;

class procedure TWindowsService.setDwWaitTime(const Value: DWord);
begin
  dwWaitT := Value;
end;

function TWindowsService.deleteService(nameService: string): boolean;
begin
  if (existsService(nameService)) then
  begin
    shellExecuteAndWait('cmd.exe', pchar('/K SC DELETE ' + nameService + ' & EXIT'));
    if (existsService(nameService)) then
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
    result := true;
  end;
end;

class procedure TWindowsService.aStart(handleSender: HWND; nameService: string; nameMachine: string = '');
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      if TWindowsService.Start(nameService, nameMachine) then
      begin
        PostMessage(handleSender, WM_SERVICE_START, 0, 0);
      end
      else
      begin
        PostMessage(handleSender, WM_SERVICE_ERROR, 0, 0);
      end;
    end).Start;
end;

class function TWindowsService.Start(nameService: string; nameMachine: string = ''): Boolean;
var
  cont: integer;
begin
  cont := 0;
  handleSCM := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleSCM > 0) then
  begin
    handleS := OpenService(handleSCM, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (handleS > 0) then
    begin
      if (QueryServiceStatus(handleS, statusS)) then
      begin
        if (statusS.dwCurrentState = SERVICE_RUNNING) then
        begin
          Result := True;
          CloseServiceHandle(handleS);
          CloseServiceHandle(handleSCM);
          Exit;
        end;

        if not startService(handleS, 0, PPChar(nil)^) then
        begin
          Result := false;
          CloseServiceHandle(handleS);
          CloseServiceHandle(handleSCM);
          Exit;
        end
        else
        begin
          QueryServiceStatus(handleS, statusS);
        end;

        //stato servizio a partire...
        while not(SERVICE_RUNNING = statusS.dwCurrentState) and (cont < 15) do
        begin
          dwChkP := statusS.dwCheckPoint;
          dwWaitTime := statusS.dwWaitHint div 10;
          Sleep(dwWaitTime);

          if (not QueryServiceStatus(handleS, statusS)) then
            break;
          if (statusS.dwCheckPoint > dwChkP) then
            break;
          cont := cont + 1;
        end;
      end;
    end;
    QueryServiceStatus(handleS, statusS);
    Result := SERVICE_RUNNING = statusS.dwCurrentState;
    CloseServiceHandle(handleS);
  end;
  CloseServiceHandle(handleSCM);
end;

class function TWindowsService.existsService(nameService: string; nameMachine: string = ''): Boolean;
begin
  try
    handleSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    handleS := OpenService(handleSCM, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
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
  CloseServiceHandle(handleS);
  CloseServiceHandle(handleSCM);
end;

class function TWindowsService.Stop(nameService: string; nameMachine: string = ''; force: boolean = false): Boolean;
begin
  handleSCM := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleSCM > 0) then
  begin
    handleS := OpenService(handleSCM, PChar(nameService), SERVICE_STOP or SERVICE_QUERY_STATUS);
    if (handleS > 0) then
    begin
      if (ControlService(handleS, SERVICE_CONTROL_STOP, statusS)) then
      begin
        if (QueryServiceStatus(handleS, statusS)) then
        begin
          while (SERVICE_STOPPED <> statusS.dwCurrentState) do
          begin
            dwChkP := statusS.dwCheckPoint;
            Sleep(250);
            if (not QueryServiceStatus(handleS, statusS)) then
              break;
            if (statusS.dwCheckPoint > dwChkP) then
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
      QueryServiceStatus(handleS, statusS);
      CloseServiceHandle(handleS);
    end;
    CloseServiceHandle(handleSCM);
  end;
  Result := SERVICE_STOPPED = statusS.dwCurrentState;
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

function getVersionSO: string;
type
  TIsWow64Process = function(AHandle: THandle; var AIsWow64: BOOL): BOOL; stdcall;
var
  vKernel32Handle: DWORD;
  vIsWow64Process: TIsWow64Process;
  vIsWow64: BOOL;
begin
  //ritorna false se il sistema è a 32_bit
  Result := '32_bit';
  // Prova a caricare kernel32.dll  altrimenti esce e ritorna 32_bit
  vKernel32Handle := LoadLibrary('kernel32.dll');
  if (vKernel32Handle = 0) then
    Exit;
  try
    // Carica la windows api IsWow64Process altrimenti esce e ritorna 32_bit
    @vIsWow64Process := GetProcAddress(vKernel32Handle, 'IsWow64Process');
    if not Assigned(vIsWow64Process) then
      Exit;
  finally
    FreeLibrary(vKernel32Handle); //unload libreria
  end;
  //se le librerie sono state caricate il sistema è a 64 bit
  Result := '64_bit';
end;

procedure addExceptionFirewall(Name: string; Port: Word; Description: string = ''; Grouping: string = ''; Executable: String = '');
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
  Profile := NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC OR NET_FW_PROFILE2_DOMAIN;
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;

  NewRule := CreateOleObject('HNetCfg.FWRule');
  NewRule.Name := Name;

  if (Description <> '') then
  begin
    NewRule.Description := Description;
  end
  else
  begin
    NewRule.Description := Name;
  end;

  if (Executable <> '') then
  begin
    NewRule.Applicationname := Executable;
  end;
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts := Port;
  NewRule.Direction := NET_FW_RULE_DIR_IN;
  NewRule.Enabled := TRUE;
  if (Grouping <> '') then
  begin
    NewRule.Grouping := Grouping;
  end;
  NewRule.Profiles := Profile;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  RulesObject.Add(NewRule);
end;

function shellExecuteAndWait(FileName, Params: string; Admin: boolean = true; showWindow: cardinal = SW_HIDE): boolean;
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
    if (admin) then
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
    ShowMessage(SysErrorMessage(GetLastError));
    Result := false;
    exit;
  end;
  while WaitForSingleObject(exInfo.hProcess, 50) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;
  CloseHandle(Ph);
  Result := true;
end;

procedure grantAllPermissionObject(user, source: string);
var
  NewDacl, OldDacl: PACl;
  SD: PSECURITY_DESCRIPTOR;
  EA: TExplicitAccess;
begin
  GetNamedSecurityInfo(PChar(source), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, @OldDacl, nil, SD);
  BuildExplicitAccessWithName(@EA, PChar(user), GENERIC_ALL, GRANT_ACCESS, SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  SetEntriesInAcl(1, @EA, OldDacl, NewDacl);
  SetNamedSecurityInfo(PChar(source), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, NewDacl, nil);
end;

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

function closeApplication(className, windowsName: string; handleSender: HWND = 0): boolean;
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

function extractZip(ZipFile, ExtractPath: string; delete_file: boolean = false): boolean;
begin
  if tzipfile.isvalid(zipfile) then
  begin
    tzipfile.extractZipfile(zipfile, extractpath);
    if (delete_file) then
    begin
      deletefile(zipfile);
    end;
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

function readStringWithEnvVariables(source: string): string;
var
  tempStringDir: string;
  tempStringPos: string;
  posStart, posEnd: integer;
  valueToReplace, newValue: string;
begin
  tempStringPos := source;
  tempStringDir := source;
  result := source;
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
        result := stringreplace(Result, valueToReplace, newValue, []);
      end;
    end
    else
    begin
      exit;
    end;
    tempStringDir := copy(tempStringDir, posEnd + 1, length(tempStringDir));
    tempStringPos := tempStringDir;
  until posStart < 0;
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

function netShare(pathFolder: string; netName: string = ''; netPassw: string = ''): string;
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

function customMessageDlg(CONST Msg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons;
Caption: ARRAY OF string; dlgcaption: string): Integer;
var
  aMsgdlg: TForm;
  i: Integer;
  Dlgbutton: Tbutton;
  Captionindex: Integer;
begin
  aMsgdlg := createMessageDialog(Msg, DlgTypt, button);
  aMsgdlg.Caption := dlgcaption;
  aMsgdlg.BiDiMode := bdLeftToRight;
  Captionindex := 0;
  for i := 0 to aMsgdlg.componentcount - 1 Do
  begin
    if (aMsgdlg.components[i] is Tbutton) then
    Begin
      Dlgbutton := Tbutton(aMsgdlg.components[i]);
      if Captionindex <= High(Caption) then
        Dlgbutton.Caption := Caption[Captionindex];
      inc(Captionindex);
    end;
  end;
  Result := aMsgdlg.Showmodal;
  FreeAndNil(aMsgdlg);
end;

procedure setComponentInMiddlePosition(control: TControl);
var
  _left: integer;
begin
  _left := trunc(control.Parent.Width / 2) - trunc(control.Width / 2);
  control.Left := _left;
end;

function getIPAddress: string;
type
  pu_long = ^u_long;
var
  varTWSAData: TWSAData;
  varPHostEnt: PHostEnt;
  varTInAddr: TInAddr;
  namebuf: Array [0 .. 255] of ansichar;
begin
  if WSAStartup($101, varTWSAData) <> 0 Then
    Result := '-'
  else
  begin
    getHostName(nameBuf, sizeOf(nameBuf));
    varPHostEnt := getHostByName(nameBuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    Result := inet_ntoa(varTInAddr);
  end;
  WSACleanup;
end;

procedure deleteDirectory(const dirName: string);
var
  FileOp: TSHFileOpStruct;
begin
  FillChar(FileOp, SizeOf(FileOp), 0);
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(DirName + #0); //double zero-terminated
  FileOp.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
  SHFileOperation(FileOp);
end;

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
function setProcessWindowToForeground(processName: string): boolean;
var
  PIDProcess: DWORD;
  WindowHandle: THandle;
  currentThreadHandle: THandle;
  foregroundThreadHandle: THandle;
begin
  PIDProcess := getPIDOfCurrentUserByProcessName(processName);
  WindowHandle := getMainWindowHandleByPID(PIDProcess);

  if WindowHandle <> 0 then
  begin
    //TODO: DOPO PERIODO PROVA DA ELIMINARE
    //    LA SINCRONIZAZZIONE TRA THREAD NON DOVREBBE ESSERE PIU' NECCESSARIA PERCHE' PRELEVO L'ENUM DEL WINDOW
    //
    //    currentThreadHandle := GetCurrentThreadId;
    //    foregroundThreadHandle := GetWindowThreadProcessId(GetForegroundWindow, nil);
    //    AttachThreadInput(foregroundThreadHandle, currentThreadHandle, true);
    //    SetForegroundWindow(windowHandle);
    //    AttachThreadInput(foregroundThreadHandle, currentThreadHandle, false);

    SetForegroundWindow(WindowHandle);

    postMessage(WindowHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

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
  handleSnap, handleProcess: THandle;
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
//FINE TODO?

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
