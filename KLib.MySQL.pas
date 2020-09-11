unit KLib.MySQL;

interface

uses
  System.IniFiles, System.SysUtils,
  Winapi.Windows,
  MyAccess,
  KLib.Types, KLib.Windows;

type

  TMySQLCredentials = record
    username: string;
    password: string;
    server: string;
    port: integer;
    daatabase: string;
  end;

  TMySQLIniManipulator = class(TIniFile)
  private
    function getPort: integer;
    procedure setPort(value: integer);
    function get_loose_keyring_file_data: string;
    procedure set_loose_keyring_file_data(value: string);
    function getSecurefilepriv: string;
    procedure setSecurefilepriv(value: string);
    function getDatadir: string;
    procedure setDatadir(value: string);
    function get_innodb_buffer_pool_size: string;
    procedure set_innodb_buffer_pool_size(value: string);
    function get_innodb_log_file_size: string;
    procedure set_innodb_log_file_size(value: string);
  public
    constructor Create(const FileName: string); overload;
    property port: integer read getPort write setPort;
    property loose_keyring_file_data: string read get_loose_keyring_file_data write set_loose_keyring_file_data;
    property securefilepriv: string read getSecurefilepriv write setSecurefilepriv;
    property datadir: string read getDatadir write setDatadir;
    property innodb_buffer_pool_size: string read get_innodb_buffer_pool_size write set_innodb_buffer_pool_size;
    property innodb_log_file_size: string read get_innodb_log_file_size write set_innodb_log_file_size;
    procedure setOptimizedInnodbSettings;
    procedure setDefaultPathsSettingsInIni(pathMySQLInstallationFolder: string; pathDatadir: string = '');
  end;

  TMySQLInfo = record
  private
    _pathBin: string;
    procedure setPathBin(path_bin: string);
  public
    path_ini: string;
    property path_bin: string read _pathBin write setPathBin;
    function getPathMysqlAdmin: string;
    function getPathMysqld: string;
  end;

  TMySQL = class
  private
    active: boolean;
    commandCredentials: string;
    _credentials: TCredentials;
    procedure setCredentials(credentials: TCredentials);
    procedure initialCheckAndSetup;
    procedure waitUntilProcessStart;
    procedure setPortToIni(port: integer);
    function getPortFromIni: integer;
    procedure setCommandCredentials;
  public
    database: string;
    MySQLInfo: TMySQLInfo;
    iniManipulator: TMySQLIniManipulator;
    property credentials: TCredentials read _credentials write setCredentials;
    property port: integer read getPortFromIni write setPortToIni;
    constructor create(credentials: TCredentials; MySQLInfo: TMySQLInfo);
    procedure start;
    procedure stop;
  end;

  TMySQLService = class(TWindowsService)
  public
    nameService: string;
    portService: integer;
    pathMysqlBin: string;
    constructor create(nameService: string; portService: integer; pathMysqlBin: string);
    procedure deleteService; overload;
    procedure addFirewallException;
    procedure aStart(handleSender: HWND); overload;
    procedure start; overload;
    procedure stop; overload;
    function existsService: boolean; overload;
    procedure createService(path_my_ini: string; forceInstall: boolean = false);
    procedure mysqldump(username, password, database, fileNameOut: string);
    procedure mysqlpump(username, password, database, fileNameOut: string);
    procedure importScript(username, password, fileNameIn: string);
  end;

  TMySQLProcess = class
  private
    credentials: TCredentials;
    pathMySQL: string;
    pathDatadir: string;
    connectionDB: TMyConnection;
    query: TMyQuery;
    allPersonalConnectionsAreClosed: boolean;
    numberConnections: integer;
    procedure createTMySQL;
    procedure createConnectionDB;
    procedure createQuery;
    procedure startMySQL;
    procedure configureIni;
    procedure setPort;
    function IsMysqlActive: boolean;
    function canYouShutdown: boolean;
    function canYouShutdown_personalConnectionsClosed: boolean;
    function canYouShutdown_personalConnectionsActived: boolean;
  public
    port: integer;
    mysql: TMySQL;
    errorException: Exception;
    constructor create(credentialsMysql: TCredentials; path_Mysql: string; path_Mysql_datadir: string = '';
      numberConnections: integer = 1; allConnectionsAreClosed: boolean = true);
    procedure AConnectToDatabase(reply: TAsyncifyProcedureReply);
    procedure promiseConnectToDatabase(resolve: TProcedureOfObject; reject: TProcedureOfObject);
    procedure connectToDatabaseInWaitForm(msg: string = '');
    procedure connectToDatabase;
    procedure shutdownMySQL;
    destructor destroy; override;
  end;

function checkLibVisualStudio2013: boolean;
procedure installLibVisualStudio2013(fileName: string; showMsgInstall: boolean = true;
  deleteFileAfterInstall: boolean = true; isFileAResource: boolean = false);

implementation

uses
  Winapi.ShellAPI,
  Vcl.Dialogs, Vcl.Controls,
  System.Win.Registry, System.Classes, System.IOUtils,
  KLib.Utils, KLib.Async, KLib.WaitForm;

constructor TMySQLIniManipulator.Create(const FileName: string);
var
  _pathFile: string;
begin
  _pathFile := getValidFullPath(FileName);
  if not FileExists(_pathFile) then
  begin
    raise Exception.Create('File: ' + FileName + ' doesn''t exists.');
  end;

  inherited Create(_pathFile);
end;

function TMySQLIniManipulator.getPort: integer;
begin
  result := ReadInteger('mysqld', 'port', 0);
end;

procedure TMySQLIniManipulator.setPort(value: integer);
begin
  WriteInteger('mysqld', 'port', value);
end;

function TMySQLIniManipulator.get_loose_keyring_file_data: string;
begin
  result := ReadString('mysqld', 'loose_keyring_file_data', '');
end;

procedure TMySQLIniManipulator.set_loose_keyring_file_data(value: string);
var
  _pathInLinuxStyle: string;
begin
  _pathInLinuxStyle := StringReplace(value, '\', '/', [rfReplaceAll, rfIgnoreCase]);
  WriteString('mysqld', 'loose_keyring_file_data', _pathInLinuxStyle);
end;

function TMySQLIniManipulator.getSecurefilepriv: string;
begin
  result := ReadString('mysqld', 'secure-file-priv', '');
end;

procedure TMySQLIniManipulator.setSecurefilepriv(value: string);
var
  _pathInLinuxStyle: string;
begin
  _pathInLinuxStyle := StringReplace(value, '\', '/', [rfReplaceAll, rfIgnoreCase]);
  WriteString('mysqld', 'secure-file-priv', _pathInLinuxStyle);
end;

function TMySQLIniManipulator.getDatadir: string;
begin
  result := ReadString('mysqld', 'datadir', '');
end;

procedure TMySQLIniManipulator.setDatadir(value: string);
var
  _pathInLinuxStyle: string;
begin
  _pathInLinuxStyle := StringReplace(value, '\', '/', [rfReplaceAll, rfIgnoreCase]);
  WriteString('mysqld', 'datadir', _pathInLinuxStyle);
end;

function TMySQLIniManipulator.get_innodb_buffer_pool_size: string;
begin
  result := ReadString('mysqld', 'innodb_buffer_pool_size', '');
end;

procedure TMySQLIniManipulator.set_innodb_buffer_pool_size(value: string);
begin
  WriteString('mysqld', 'innodb_buffer_pool_size', value);
end;

function TMySQLIniManipulator.get_innodb_log_file_size: string;
begin
  result := ReadString('mysqld', 'innodb_log_file_size', '');
end;

procedure TMySQLIniManipulator.set_innodb_log_file_size(value: string);
begin
  WriteString('mysqld', 'innodb_log_file_size', value);
end;

procedure TMySQLIniManipulator.setOptimizedInnodbSettings;
begin
  TMemoryRam.initialize;
  if (TMemoryRam.getTotalFreeMemoryDouble > 300) then
  begin
    innodb_buffer_pool_size := '200M';
    innodb_log_file_size := '100M';
  end
  else if (TMemoryRam.getTotalFreeMemoryDouble > 200) then
  begin
    innodb_buffer_pool_size := '100M';
    innodb_log_file_size := '50M';
  end
  else if (TMemoryRam.getTotalFreeMemoryDouble > 100) then
  begin
    innodb_buffer_pool_size := '50M';
    innodb_log_file_size := '50M';
  end
  else
  begin
    //VALORI DEFAULT
    innodb_buffer_pool_size := '8M';
    innodb_log_file_size := '48M';
  end;
  if TMemoryRam.getTotalFreeMemoryDouble < 40 then
  begin
    //TODO: CANCELLARE ? PUO' CREARE ERRORI CON I THREAD
    ShowMessage('Memoria RAM libera del computer insufficiente, controllare i processi del computer.' + #13#10
      + 'Il servizio MySQL potrebbe non avviarsi per le risorse limitate. ');
  end;
end;

procedure TMySQLIniManipulator.setDefaultPathsSettingsInIni(pathMySQLInstallationFolder: string;
  pathDatadir: string = '');
var
  _pathMySQL: string;
  _path_securefilepriv: string;
  _path_keyring: string;
  _path_datadir: string;
begin
  _pathMySQL := ExpandFileName(pathMySQLInstallationFolder);

  _path_securefilepriv := TPath.Combine(_pathMySQL, 'Uploads');
  _path_securefilepriv := ansiQuotedStr(_path_securefilepriv, '"');

  securefilepriv := _path_securefilepriv;

  _path_keyring := TPath.Combine(_pathMySQL, 'keyring');
  _path_keyring := ansiQuotedStr(_path_keyring, '"');
  loose_keyring_file_data := _path_keyring;

  if pathDatadir <> '' then
  begin
    _path_datadir := ExpandFileName(pathDatadir);
  end
  else
  begin
    _path_datadir := TPath.Combine(_pathMySQL, 'data');
  end;
  _path_datadir := ansiQuotedStr(_path_datadir, '"');
  datadir := _path_datadir;
end;

procedure TMySQLInfo.setPathBin(path_bin: string);
begin
  _pathBin := ExcludeTrailingPathDelimiter(path_bin);
end;

function TMySQLInfo.getPathMysqlAdmin: string;
begin
  Result := TPath.Combine(path_bin, 'mysqladmin.exe');
end;

function TMySQLInfo.getPathMysqld: string;
begin
  Result := TPath.Combine(path_bin, 'mysqld.exe');
end;

constructor TMySQL.create(credentials: TCredentials; MySQLInfo: TMySQLInfo);
begin
  iniManipulator := TMySQLIniManipulator.Create(MySQLInfo.path_ini);
  Self.credentials := credentials;
  self.MySQLInfo := MySQLInfo;
  initialCheckAndSetup;
end;

procedure TMySQL.setCredentials(credentials: TCredentials);
begin
  _credentials := credentials;
  setCommandCredentials;
end;

procedure TMySQL.initialCheckAndSetup;
var
  nameResource: string;
begin
  active := true;
  try
    if not checkLibVisualStudio2013 then
    begin
      //QUANDO SI UTILIZZA AGGIUNGERE "VCREDIST_32_bit EXE vcredist_x86.exe" e "VCREDIST_64_bit EXE assets\vcredist_x64.exe"
      //al file risorse DEL PROGETTO
      nameResource := 'VCREDIST_' + getVersionSO;
      installLibVisualStudio2013(nameResource, true);
    end;
  except
    on E: Exception do
    begin
      active := false;
      ShowMessage(e.Message);
    end;
  end;
end;

procedure TMySQL.start; // possible exception raised
var
  mysqld_command: string;
  path_myIni: string;
  path_mysqld: string;
begin
  path_myIni := ExcludeTrailingPathDelimiter(MySQLInfo.path_ini);
  path_mysqld := MySQLInfo.getPathMysqld;
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
  connectionDB: TMyConnection;
begin
  i := 0;
  _exit := false;
  _connected := false;
  connectionDB := TMyConnection.Create(nil);
  connectionDB.server := 'localhost';
  connectionDB.Username := credentials.username;
  connectionDB.Password := credentials.password;
  connectionDB.Port := port;
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
      connectionDB.Connected := true;
      connectionDB.Connected := false;
      _connected := true;
      _exit := true;
    except
      Inc(i, 1);
      sleep(3000);
    end;
  end;

  FreeAndNil(connectionDB);
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
  shellExecute(0, 'open', pchar(MySQLInfo.getPathMysqlAdmin), PCHAR(mysqld_command), nil, SW_HIDE);
end;

procedure TMySQL.setPortToIni(port: integer);
begin
  iniManipulator.port := port;
  setCommandCredentials;
end;

function TMySQL.getPortFromIni: integer;
begin
  result := iniManipulator.port;
end;

procedure TMySQL.setCommandCredentials;
begin
  self.commandCredentials := '-u ' + _credentials.username + ' -p' + _credentials.password +
    ' --port ' + IntToStr(port) + ' ';
end;

constructor TMySQLService.Create(nameService: string; portService: integer; pathMysqlBin: string);
begin
  Self.nameService := nameService;
  Self.pathMysqlBin := pathMysqlBin;
  self.portService := portService;
end;

procedure TMySQLService.deleteService;
begin
  deleteService(Self.nameService);
end;

procedure TMySQLService.addFirewallException;
const
  DESCRIPTION_SERVICE_MYSQL = 'Database MySQL';
  GROUP_SERVICE_MYSQL = 'MySQL';
begin
  addTCP_IN_FirewallException(nameService, portService, DESCRIPTION_SERVICE_MYSQL, GROUP_SERVICE_MYSQL);
end;

procedure TMySQLService.aStart(handleSender: HWND);
begin
  aStart(handleSender, nameService);
end;

procedure TMySQLService.start;
begin
  start(nameService);
end;

procedure TMySQLService.Stop;
begin
  stop(nameService);
end;

function TMySQLService.existsService: boolean;
begin
  Result := existsService(nameService);
end;

//TODO REFACTOR mysqldump, mysqlpump, importScript
procedure TMySQLService.mysqldump(username, password, database, fileNameOut: string);
var
  parametriMysqldump: string;
  parametriShell: string;
  pathMysqldumpExe: string;
begin
  parametriMysqldump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(portService) + ' --databases ' + database + ' --skip-triggers > ' + fileNameOut;
  pathMysqldumpExe := TPath.Combine(pathMysqlBin, 'mysqldump.exe');
  parametriShell := '/K ""' + pathMysqldumpExe + '" ' + parametriMysqldump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

procedure TMySQLService.mysqlpump(username, password, database, fileNameOut: string);
var
  parametriMysqlpump: string;
  parametriShell: string;
  pathMysqlpumpExe: string;
begin
  parametriMysqlpump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(portService) + ' --databases ' + database + ' --skip-triggers > ' + fileNameOut;
  pathMysqlpumpExe := TPath.Combine(pathMysqlBin, 'mysqlpump.exe');
  parametriShell := '/K ""' + pathMysqlpumpExe + '" ' + parametriMysqlpump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

procedure TMySQLService.importScript(username, password, fileNameIn: string);
var
  parametriMysqldump: string;
  parametriShell: string;
  pathMysqlExe: string;
begin
  parametriMysqldump := '-u ' + username + ' -p' + password + ' --port ' + inttostr(portService) + ' < ' + fileNameIn;
  pathMysqlExe := TPath.Combine(pathMysqlBin, 'mysql.exe');
  parametriShell := '/K ""' + pathMysqlExe + '" ' + parametriMysqldump + '"';
  shellExecuteAndWait('cmd.exe', PCHAR(parametriShell + ' & EXIT'));
end;

procedure TMySQLService.createService(path_my_ini: string; forceInstall: boolean = false);
var
  parametri: string;
  comandoCreazioneServizio: string;
  pathMysqldExe: string;
begin
  parametri := '--install ' + nameService + ' --defaults-file="' + path_my_ini + '"';
  pathMysqldExe := TPath.Combine(pathMysqlBin, 'mysqld.exe');
  comandoCreazioneServizio := '/K ""' + pathMysqldExe + '" ' + parametri + '"';

  //installazione servizio con wait
  if (existsService(nameService)) then
  begin
    if (forceInstall) then
    begin
      deleteService;
    end
    else
    begin
      raise Exception.Create('A service with the same name already exists.');
    end;
  end;

  shellExecuteAndWait('cmd.exe', PCHAR(comandoCreazioneServizio + ' & EXIT'));

  if not(existsService(nameService)) then
  begin
    raise Exception.Create('MySQL Service not created.');
  end;
end;

constructor TMySQLProcess.create(credentialsMysql: TCredentials; path_MySQL: string; path_Mysql_datadir: string = '';
  numberConnections: integer = 1; allConnectionsAreClosed: boolean = true);
begin
  self.credentials := credentialsMysql;
  path_mysql := ExpandFileName(path_mysql);
  Self.pathMySQL := ExcludeTrailingPathDelimiter(path_MySQL);
  Self.pathDatadir := ExcludeTrailingPathDelimiter(path_Mysql_datadir);
  self.numberConnections := numberConnections;
  self.allPersonalConnectionsAreClosed := allConnectionsAreClosed;
  createTMySQL;
  Self.port := mysql.port;
  createConnectionDB;
  createQuery;
  errorException := Exception.Create('');
end;

procedure TMySQLProcess.createTMySQL;
var
  mysqlInfo: TMySQLInfo;
begin
  with mysqlInfo do
  begin
    path_ini := TPath.Combine(pathMySQL, 'my.ini');
    path_bin := TPath.Combine(pathMySQL, 'bin');
  end;
  mysql := TMySQL.create(credentials, mysqlInfo);
end;

procedure TMySQLProcess.createConnectionDB;
begin
  connectionDB := TMyConnection.Create(nil);
  connectionDB.server := 'localhost';
  connectionDB.Username := credentials.username;
  connectionDB.Password := credentials.password;
  connectionDB.Port := self.port;
end;

procedure TMySQLProcess.createQuery;
begin
  query := TMyQuery.Create(nil);
  query.Connection := connectionDB;
end;

procedure TMySQLProcess.AConnectToDatabase(reply: TAsyncifyProcedureReply);
begin
  asyncifyProcedure(connectToDatabase, reply);
end;

procedure TMySQLProcess.promiseConnectToDatabase(resolve: TProcedureOfObject; reject: TProcedureOfObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        connectToDatabase;
        resolve;
      except
        on E: Exception do
        begin
          errorException := e;
          reject;
        end;
      end;
    end).Start;
end;

procedure TMySQLProcess.connectToDatabaseInWaitForm(msg: string = '');
const
  WAITFORM_MSG_MYSQL_START = 'MySQL si sta avviando,' + #13#10 + 'attendi.';
var
  _msg: string;
begin
  if msg <> '' then
  begin
    _msg := msg;
  end
  else
  begin
    _msg := WAITFORM_MSG_MYSQL_START;
  end;
  executeProcedureInWaitForm(connectToDatabase, _msg);
end;

procedure TMySQLProcess.connectToDatabase;
begin
  if not IsMysqlActive then
  begin
    startMySQL;
    if not IsMysqlActive then
    begin
      raise Exception.Create('MySQL non si è avviato.');
    end;
  end;
end;

function TMySQLProcess.IsMysqlActive: boolean;
begin
  Result := true;
  try
    connectionDB.Connected := false;
    connectionDB.Connected := true;
    connectionDB.Connected := false;
  except
    Result := false;
  end;
end;

procedure TMySQLProcess.startMySQL;
begin
  setPort;
  configureIni;
  try
    mysql.start;
  except
    on E: Exception do
      ShowMessage(e.Message);
  end;
end;

procedure TMySQLProcess.setPort;
const
  portMySQL = 3307;
begin
  port := getFirstPortAvaliable(portMySQL);
  connectionDB.Port := port;
  mysql.port := port;
end;

procedure TMySQLProcess.configureIni;
begin
  mysql.iniManipulator.setDefaultPathsSettingsInIni(pathMySQL, pathDatadir);
  mysql.iniManipulator.setOptimizedInnodbSettings;
end;

destructor TMySQLProcess.Destroy;
begin
  shutdownMySQL;
  inherited;
end;

procedure TMySQLProcess.shutdownMySQL;
var
  _close: boolean;
begin
  if IsMysqlActive then
  begin
    _close := canYouShutdown;
    if _close then
    begin
      mysql.stop;
    end;
  end;
end;

function TMySQLProcess.canYouShutdown: boolean;
begin
  if allPersonalConnectionsAreClosed then
  begin
    result := canYouShutdown_personalConnectionsClosed;
  end
  else
  begin
    result := canYouShutdown_personalConnectionsActived;
  end;
end;

function TMySQLProcess.canYouShutdown_personalConnectionsClosed: boolean;
var
  _realNumberConnections: integer;
begin
  query.SQL.Clear;
  query.SQL.Add('SELECT  USER');
  query.SQL.Add('FROM information_schema.PROCESSLIST');
  query.Open;
  _realNumberConnections := query.RecordCount - 1;
  if _realNumberConnections = 0 then
  begin
    result := true;
  end
  else
  begin
    if (_realNumberConnections > 0) and (_realNumberConnections < numberConnections) then
    begin
      if messagedlg('Altri programmi sono collegati al database, forzare la chiusura di quest''ultimo?',
        mtCustom, [mbYes, mbCancel], 0) = mrYes then
      begin
        result := true;
      end;
    end
    else
    begin
      result := false;
    end;
  end;
end;

function TMySQLProcess.canYouShutdown_personalConnectionsActived: boolean;
var
  _realNumberConnections: integer;
begin
  result := false;
  _realNumberConnections := numberConnections + 1;

  query.SQL.Clear;
  query.SQL.Add('SELECT  USER');
  query.SQL.Add('FROM information_schema.PROCESSLIST');
  query.SQL.Add('WHERE  USER = :UTENTE');
  query.SQL.Add('GROUP BY USER');
  if numberConnections > 1 then
  begin
    query.SQL.Add('HAVING COUNT(USER) BETWEEN ' + IntToStr(_realNumberConnections - 1) + ' AND ' + IntToStr(_realNumberConnections));
  end
  else
  begin
    query.SQL.Add('HAVING COUNT(USER) > ' + IntToStr(_realNumberConnections));
  end;
  query.SQL.Add('UNION ALL');
  query.SQL.Add('SELECT  USER');
  query.SQL.Add('FROM information_schema.PROCESSLIST');
  query.SQL.Add('WHERE USER <> :UTENTE AND EXISTS (');
  query.SQL.Add('SELECT  USER');
  query.SQL.Add('FROM information_schema.PROCESSLIST');
  query.SQL.Add('WHERE  USER = :UTENTE');
  query.SQL.Add('GROUP BY USER');
  query.SQL.Add('HAVING COUNT(USER) = 1');
  query.SQL.Add(')');
  query.SQL.Add('GROUP BY USER;');
  query.ParamByName('UTENTE').AsString := credentials.username;

  query.Open;
  if query.RecordCount = 0 then
  begin
    result := true;
  end
  else
  begin
    if messagedlg('Altri programmi sono collegati al database, forzare la chiusura di quest''ultimo?',
      mtCustom, [mbYes, mbCancel], 0) = mrYes then
    begin
      result := true;
    end;
  end;
end;

procedure installLibVisualStudio2013(fileName: string; showMsgInstall: boolean = true;
deleteFileAfterInstall: boolean = true; isFileAResource: boolean = false);
const
  MSG_INSTALL = 'MySQL needs:' + #13#10 +
    'Visual C++ Redistributable Package Visual Studio 2013.' + #13#10 + #13#10 +
    'The installer will run.';
  MSG_ERROR = 'Visual C++ Redistributable Visual Studio 2013 not correctly installed.';
var
  nameResource: string;
  pathFileName: string;
  pathCurrentDir: string;
begin
  pathFileName := fileName;

  if showMsgInstall then
  begin
    ShowMessage(MSG_INSTALL);
  end;

  if isFileAResource then
  begin
    pathCurrentDir := GetCurrentDir;
    pathFileName := TPath.Combine(pathCurrentDir, fileName);
    getResourceAsEXEFile(fileName, pathFileName);
  end;

  executeAndWaitExe(pathFileName);

  Sleep(2000);

  if deleteFileAfterInstall then
  begin
    deleteFileIfExists(pathFileName);
  end;

  if not checkLibVisualStudio2013 then
  begin
    raise Exception.Create(MSG_ERROR);
  end;
end;

function checkLibVisualStudio2013: boolean;
var
  reg: TRegistry;
  versionSO: string;
begin
  result := false;
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      versionSO := getVersionSO;
      if versionSO = '32_bit' then
      begin
        if (OpenKeyReadOnly('\SOFTWARE\Microsoft\VisualStudio\12.0\VC\Runtimes\x86')) or
          (OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x86')) then
        begin
          result := true;
        end;
      end
      else if versionSO = '64_bit' then
      begin
        if (OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x64')) then
        begin
          result := true;
        end;
      end;
    finally
      Free;
    end;
end;

end.
