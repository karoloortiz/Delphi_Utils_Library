unit KLib.MySQL;

interface

uses
  Winapi.Windows, inifiles, System.SysUtils, ShellAPI, MyAccess, Vcl.Dialogs,
  Vcl.Controls, Registry, System.Classes,
  KLib.Windows, KLib.Utils, KLib.Types;

type
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

  TMySQLProcess = class
  private
    credentials: TCredentials;
    path_MySQL: string;
    path_MySQL_datadir: string;
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
    procedure setInnodbSettingsInIni;
    procedure setPathsInIni;
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
    procedure connectToDatabase;
    procedure shutdownMySQL;
    destructor destroy; override;
  end;

implementation


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

procedure TMySQL.setCommandCredentials;
begin
  self.commandCredentials := '-u ' + _credentials.username + ' -p' + _credentials.password +
    ' --port ' + IntToStr(port) + ' ';
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
  shellExecute(0, 'open', pchar(MySQLInfo.getPath_mysqladmin), PCHAR(mysqld_command), nil, SW_HIDE);
end;

procedure TMySQL.setPortToIni(port: integer);
begin
  iniFileManipulator.WriteInteger('mysqld', 'port', port);
  setCommandCredentials;
end;

function TMySQL.getPortFromIni: integer;
begin
  Result := iniFileManipulator.ReadInteger('mysqld', 'port', 0);
end;

function TMySQL.checkLibVisualStudio2013: boolean;
var
  reg: TRegistry;
  carica_risorsa: TResourceStream;
begin
  result := false;
  //VERIFICA la presenza di Visual C++ Redistributable Package per Visual Studio 2013
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if (OpenKeyReadOnly('\SOFTWARE\Microsoft\VisualStudio\12.0\VC\Runtimes\x86')) or
        (OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x86')) or
        (OpenKeyReadOnly('\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x64')) then
      begin
        result := true;
      end;
    finally
      Free;
    end;
end;

procedure TMySQL.installLibVisualStudio2013;
var
  carica_risorsa: TResourceStream;
  nameResource: string;
begin
  ShowMessage('MySQL needs:' + #13#10 +
    'Visual C++ Redistributable Package Visual Studio 2013.' + #13#10 + #13#10 +
    'The installer will run.');

  //QUANDO SI UTILIZZA AGGIUNGERE "VCREDIST_32_bit EXE vcredist_x86.exe" e "VCREDIST_64_bit EXE assets\vcredist_x64.exe"
  //al file risorse DEL PROGETTO
  nameResource := 'VCREDIST_' + getVersionSO;
  ShowMessage(getVersionSO);
  //-----------------------------------------------------------
  if (FindResource(hInstance, PChar(nameResource), PChar('EXE')) <> 0) then
  begin
    carica_risorsa := TResourceStream.Create(HInstance, PChar(nameResource), PChar('EXE'));
    try
      carica_risorsa.Position := 0;
      carica_risorsa.SaveToFile('vcredist.exe');
    finally
      carica_risorsa.Free;
    end;
  end;
  executeAndWaitExe(GetCurrentDir + '\vcredist.exe');
  DeleteFile('vcredist.exe');
  if not checkLibVisualStudio2013 then
  begin
    raise Exception.Create('Visual C++ Redistributable Visual Studio 2013 not correctly installed.');
  end;
end;

const
  portMySQL = 3306;

constructor TMySQLProcess.create(credentialsMysql: TCredentials; path_MySQL: string; path_Mysql_datadir: string = '';
  numberConnections: integer = 1; allConnectionsAreClosed: boolean = true);
begin
  self.credentials := credentialsMysql;
  Self.path_MySQL := path_MySQL;
  Self.path_MySQL_datadir := path_Mysql_datadir;
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
    path_ini := path_mysql + 'my.ini';
    path_bin := path_mysql + 'bin';
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
begin
  port := getFirstPortAvaliable(portMySQL);
  connectionDB.Port := port;
  mysql.port := port;
end;

procedure TMySQLProcess.configureIni;
begin
  setPathsInIni;
  setInnodbSettingsInIni;
end;

procedure TMySQLProcess.setPathsInIni;
var
  _path_mysql: string;
  _path_datadir: string;
  _path_securefilepriv: string;
  _path_keyring: string;
begin
  _path_mysql := ExpandFileName(path_mysql);
  if path_MySQL_datadir <> '' then
  begin
    _path_datadir := ExpandFileName(path_MySQL_datadir);
  end
  else
  begin
    _path_datadir := '"' + _path_mysql + 'data"';
  end;
  mysql.iniFileManipulator.WriteString('mysqld', 'datadir', _path_datadir);
  _path_securefilepriv := '"' + _path_mysql + 'Uploads"';
  mysql.iniFileManipulator.WriteString('mysqld', 'secure-file-priv', _path_securefilepriv);
  _path_keyring := '"' + _path_mysql + 'keyring"';
  mysql.iniFileManipulator.WriteString('mysqld', 'loose_keyring_file_data', _path_keyring);
end;

procedure TMySQLProcess.setInnodbSettingsInIni;
begin
  TMemoryRam.initialize;
  if (TMemoryRam.getTotalFreeMemoryDouble > 300) then
  begin
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_buffer_pool_size', '200M');
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_log_file_size', '100M');
  end
  else if (TMemoryRam.getTotalFreeMemoryDouble > 200) then
  begin
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_buffer_pool_size', '100M');
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_log_file_size', '50M');
  end
  else if (TMemoryRam.getTotalFreeMemoryDouble > 100) then
  begin
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_buffer_pool_size', '50M');
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_log_file_size', '50M');
  end
  else
  begin
    //VALORI DEFAULT MYSQL
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_buffer_pool_size', '8M');
    mysql.iniFileManipulator.WriteString('mysqld', 'innodb_log_file_size', '48M');
  end;
  if TMemoryRam.getTotalFreeMemoryDouble < 40 then
  begin
    ShowMessage('Memoria RAM libera del computer insufficiente, controllare i processi del computer.' + #13#10
      + 'Il servizio MySQL potrebbe non avviarsi per le risorse limitate. ');
  end;
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

end.
