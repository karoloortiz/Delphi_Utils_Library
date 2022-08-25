unit KLib.Windows.EventLog;

interface

type
  TEventLog = class
  private
    handle: THandle;
    procedure checkEventLogHandle;
    procedure Write(entryType: Word; eventId: Cardinal; value: string);
  public
    applicationName: string;

    constructor Create(applicationName: string);
    procedure writeInfo(value: string);
    procedure writeWarning(value: string);
    procedure writeError(value: string);
    class procedure addEventApplicationToRegistry(applicationName: string; fileName: string); // Requires admin rights. Typically called once-off during the application's installation
    class procedure deleteEventApplicationFromRegistry(applicationName: string); // Requires admin rights.
    class function getRegistryKey(applicationName: string): string;
    destructor Destroy; overload; override;
  end;

implementation

uses
  KLib.Windows, KLib.Constants,
  Winapi.Windows,
  System.Win.Registry,
  System.SysUtils;

constructor TEventLog.Create(applicationName: string);
begin
  Self.applicationName := applicationName;
end;

procedure TEventLog.writeInfo(value: string);
begin
  Write(EVENTLOG_INFORMATION_TYPE, 1, value);
end;

procedure TEventLog.writeWarning(value: string);
begin
  Write(EVENTLOG_WARNING_TYPE, 2, value);
end;

procedure TEventLog.writeError(value: string);
begin
  Write(EVENTLOG_ERROR_TYPE, 3, value);
end;

procedure TEventLog.checkEventLogHandle;
begin
  if handle = 0 then
  begin
    handle := RegisterEventSource(nil, PChar(applicationName));
  end;
  if handle <= 0 then
  begin
    raise Exception.Create('Could not obtain Event Log handle.');
  end;
end;

procedure TEventLog.Write(entryType: Word; eventId: Cardinal; value: string);
begin
  checkEventLogHandle;
  ReportEvent(handle, entryType, 0, eventId, nil, 1, 0, @value, nil);
end;

class procedure TEventLog.addEventApplicationToRegistry(applicationName: string; fileName: string);
const
  ERR_MSG = 'Error updating the registry. This action requires administrative rights: ';
var
  _regKey: string;
begin
  _regKey := getRegistryKey(applicationName);
  try
    writeIn_HKEY_LOCAL_MACHINE(_regKey, 'EventMessageFile', fileName, FORCE);
    writeIn_HKEY_LOCAL_MACHINE(_regKey, 'TypesSupported', 7, FORCE);
  except
    on E: Exception do
    begin
      raise Exception.Create(ERR_MSG + e.Message);
    end;
  end;
end;

class procedure TEventLog.deleteEventApplicationFromRegistry(applicationName: string);
var
  _regKey: string;
begin
  _regKey := getRegistryKey(applicationName);
  deleteKeyInHKEY_LOCAL_MACHINE(_regKey);
end;

class function TEventLog.getRegistryKey(applicationName: string): string;
var
  regKey: string;
begin
  regKey := EVENTLOG_APPLICATION_REGKEY + '\' + applicationName;

  Result := regKey;
end;

destructor TEventLog.Destroy;
begin
  if handle > 0 then
  begin
    DeregisterEventSource(handle);
  end;
end;

end.
