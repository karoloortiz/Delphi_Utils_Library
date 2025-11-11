# Windows Service Examples

Examples for creating Windows services with KLib.

## Service Types

### 1. Thread-Based Service

Background worker service using threads.

```pascal
unit MyService;

interface

uses
  KLib.MyService, KLib.ServiceApp.ThreadAdapter, KLib.MyThread;

type
  TMyWorkerService = class(TMyService)
    procedure ServiceCreate(Sender: TObject); override;
  end;

implementation

procedure TMyWorkerService.ServiceCreate(Sender: TObject);
begin
  inherited;

  serviceApp := TThreadAdapter.Create(
    procedure  // Main executor
    var
      thread: TMyThread;
    begin
      thread := TMyThread(TThread.CurrentThread);

      while not thread.isStopped do
      begin
        // Your service logic
        ProcessQueue();
        Sleep(5000);  // Check every 5 seconds
      end;
    end,
    procedure(errorMsg: string)  // Reject callback
    begin
      LogError('Service error: ' + errorMsg);
    end
  );
end;

end.
```

### 2. HTTP Server Service

Service that exposes HTTP endpoints.

```pascal
uses
  KLib.ServiceApp.HttpServerAdapter, KLib.MyIdHTTPServer;

procedure TMyHTTPService.ServiceCreate(Sender: TObject);
var
  adapter: THttpServerAdapter;
begin
  inherited;

  adapter := THttpServerAdapter.Create(
    8080,  // Port
    procedure(AContext: TIdContext;
              ARequestInfo: TMyIdHTTPRequestInfo;
              AResponseInfo: TMyIdHTTPResponseInfo)
    begin
      // Handle HTTP requests
      if ARequestInfo.URI = '/status' then
      begin
        AResponseInfo.ContentType := 'application/json';
        AResponseInfo.ContentText := '{"status":"running"}';
      end
      else if ARequestInfo.URI = '/api/data' then
      begin
        AResponseInfo.ContentText := GetData();
      end;
    end,
    procedure(errorMsg: string)  // Reject callback
    begin
      LogError('HTTP error: ' + errorMsg);
    end
  );

  serviceApp := adapter;
end;
```

## Service Installation

### Program File Setup

```pascal
program MyServiceApp;

uses
  Vcl.SvcMgr,
  MyService in 'MyService.pas' {MyWorkerService: TService};

{$R *.res}

begin
  if not Application.DelayInitialize or Application.Installing then
  begin
    Application.Initialize;
  end;

  Application.CreateForm(TMyWorkerService, MyService);
  Application.Run;
end.
```

### Install/Uninstall Service

```batch
# Install
MyServiceApp.exe --install --defaults-file="C:\config\service.ini"

# Uninstall
MyServiceApp.exe --uninstall

# Install with custom name
MyServiceApp.exe --install --name="MyCustomService"
```

## Service Configuration

### Using INI File

```ini
[Service]
Name=MyWorkerService
DisplayName=My Worker Service
Description=Background processing service
StartType=Automatic
```

Load in ServiceCreate:

```pascal
procedure TMyWorkerService.ServiceCreate(Sender: TObject);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(GetDefaultsFilePath);
  try
    DisplayName := ini.ReadString('Service', 'DisplayName', 'My Service');
    Description := ini.ReadString('Service', 'Description', '');
    // ... configure service
  finally
    ini.Free;
  end;

  // Then create serviceApp adapter...
end;
```

## Event Log Integration

```pascal
uses KLib.Windows.EventLog;

// Register event source (run once during install)
procedure TMyService.ServiceAfterInstall(Sender: TService);
begin
  TEventLog.addEventApplicationToRegistry('MyServiceName');
end;

// Log events
procedure LogToEventLog(const msg: string; eventType: TEventType);
var
  eventLog: TEventLog;
begin
  eventLog := TEventLog.Create('MyServiceName');
  try
    eventLog.logMessage(msg, eventType);
  finally
    eventLog.Free;
  end;
end;
```

## Service Lifecycle

```pascal
procedure TMyService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  LogInfo('Service starting...');
  Started := True;
end;

procedure TMyService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  LogInfo('Service stopping...');
  if Assigned(serviceApp) then
    serviceApp.stop;
  Stopped := True;
end;

procedure TMyService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  if Assigned(serviceApp) then
    serviceApp.pause;
  Paused := True;
end;

procedure TMyService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  if Assigned(serviceApp) then
    serviceApp._continue;
  Continued := True;
end;
```

## Best Practices

1. **Always handle exceptions** in service threads
2. **Use Event Log** for diagnostics (not ShowMessage!)
3. **Respond quickly** to stop/pause commands
4. **Use configuration files** for flexibility
5. **Log startup/shutdown** events
6. **Implement graceful shutdown** with timeouts

## See Also

- [KLib.MyService.pas](../../KLib.MyService.pas)
- [KLib.ServiceApp.ThreadAdapter.pas](../../KLib.ServiceApp.ThreadAdapter.pas)
- [KLib.ServiceApp.HttpServerAdapter.pas](../../KLib.ServiceApp.HttpServerAdapter.pas)
- [KLib.Windows.EventLog.pas](../../KLib.Windows.EventLog.pas)
- [Windows Service Documentation](../../README.md#windows-services)
