unit KLib.MyThread;

interface

uses
  KLib.Types, KLib.Constants,
  System.Classes, System.SyncObjs;

type
  TOnChangeStatus = procedure(value: TThreadStatus);

  TMyThread = class(TThread)
  private
    _executorMethod: TAnonymousMethod;
    _rejectCallBack: TCallBack;
    _CreateSuspended: boolean;

    _event: TEvent;

    procedure _set_status(value: TThreadStatus);
  protected
    _status: TThreadStatus;
  public
    onChangeStatus: TCallBack;
    property status: TThreadStatus read _status write _set_status;

    constructor Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; CreateSuspended: boolean = false; onChangeStatus: TCallBack = nil);
    procedure Execute; override;
    procedure myStart(raiseExceptionEnabled: boolean = true);
    procedure pause;
    procedure myResume;
    procedure stop(force: boolean = false);

    function copy: TMyThread;
    function get_status_asString: string;
    destructor Destroy; override;
  end;

implementation

uses
  KLib.Utils,
  System.SysUtils;

constructor TMyThread.Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; CreateSuspended: boolean = false; onChangeStatus: TCallBack = nil);
begin
  Self._executorMethod := executorMethod;
  Self._rejectCallBack := rejectCallBack;
  Self._CreateSuspended := CreateSuspended;
  Self.onChangeStatus := onChangeStatus;

  Self.status := TThreadStatus.created;
  Self._event := TEvent.Create(nil, true, not CreateSuspended, '');
  inherited Create(CreateSuspended);
  if not CreateSuspended then
  begin
    _event.SetEvent;
    status := TThreadStatus.running;
  end;
end;

procedure TMyThread.myStart(raiseExceptionEnabled: boolean = true);
begin
  case status of
    TThreadStatus.created:
      begin
        Start;
        _event.SetEvent;
        status := TThreadStatus.running;
      end;
    TThreadStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot restart it.');
      end;
    TThreadStatus.paused:
      begin
        myResume;
      end;
    TThreadStatus.running:
      begin
        if raiseExceptionEnabled then
        begin
          raise Exception.Create('Thread already running.');
        end;
      end;
  else
    begin
      Exception.Create('Incorrect status');
    end;
  end;
end;

procedure TMyThread.pause;
begin
  case status of
    TThreadStatus.created:
      begin
        raise Exception.Create('Thread not started, you cannot pause it.');
      end;
    TThreadStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot pause it.');
      end;
    TThreadStatus.paused:
      begin
        raise Exception.Create('Thread already paused.');
      end;
    TThreadStatus.running:
      begin
        if (not Terminated) then
        begin
          _event.ResetEvent;
          status := TThreadStatus.paused;
        end;
      end;
  else
    begin
      Exception.Create('Incorrect status');
    end;
  end;
end;

procedure TMyThread.myResume;
begin
  case status of
    TThreadStatus.created:
      begin
        raise Exception.Create('Thread not started, you cannot resume it.');
      end;
    TThreadStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot restart it.');
      end;
    TThreadStatus.paused:
      begin
        _event.SetEvent;
        status := TThreadStatus.running;
      end;
    TThreadStatus.running:
      begin
        raise Exception.Create('Thread already running.');
      end;
  else
    begin
      Exception.Create('Incorrect status');
    end;
  end;

end;

procedure TMyThread.Execute;
begin
  while not Terminated do
  begin
    _event.WaitFor(INFINITE);
    try
      _executorMethod;
    except
      on E: Exception do
      begin
        _rejectCallBack(E.Message);
      end;
    end;
    TThread.Sleep(1000);
  end;
end;

procedure TMyThread.stop(force: boolean = false);
  procedure _stop;
  begin
    Terminate;
    if (status <> TThreadStatus.created) and (status <> TThreadStatus.paused) then
    begin
      WaitFor;
    end;
    _event.SetEvent;
    status := TThreadStatus.stopped;
  end;

begin
  case status of
    TThreadStatus.created:
      begin
        _stop;
      end;
    TThreadStatus.stopped:
      begin
        if force then
        begin
          _stop;
        end
        else
        begin
          raise Exception.Create('Thread already stopped.');
        end;
      end;
    TThreadStatus.paused:
      begin
        _stop;
      end;
    TThreadStatus.running:
      begin
        _stop;
      end;
  else
    begin
      Exception.Create('Incorrect status');
    end;
  end;
end;

function TMyThread.copy: TMyThread;
var
  myThread: TMyThread;
begin
  myThread := TMyThread.Create(Self._executorMethod, Self._rejectCallBack, Self._CreateSuspended, Self.onChangeStatus);

  Result := myThread;
end;

procedure TMyThread._set_status(value: TThreadStatus);
begin
  _status := value;
  if Assigned(onChangeStatus) then
  begin
    onChangeStatus(get_status_asString);
  end;
end;

function TMyThread.get_status_asString: string;
var
  status_asString: string;
begin
  case _status of
    TThreadStatus._null:
      status_asString := '_null';
    TThreadStatus.created:
      status_asString := 'created';
    TThreadStatus.stopped:
      status_asString := 'stopped';
    TThreadStatus.paused:
      status_asString := 'paused';
    TThreadStatus.running:
      status_asString := 'running';
  end;

  Result := status_asString;
end;

destructor TMyThread.Destroy;
begin
  stop(FORCE);
  _event.Free;
  inherited;
end;

end.
