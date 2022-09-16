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

unit KLib.MyThread;

interface

uses
  KLib.Types, KLib.Constants, KLib.MyEvent,
  System.Classes;

type
  TMyThread = class(TThread)
  private
    _executorMethod: TAnonymousMethod;
    _rejectCallBack: TCallBack;
    _CreateSuspended: boolean;

    _event: TMyEvent;

    procedure _set_status(value: TStatus);
    function _get_IsRunning: boolean;
  protected
    _status: TStatus;
  public
    onChangeStatus: TCallBack;
    property status: TStatus read _status write _set_status;
    property isRunning: boolean read _get_IsRunning;

    constructor Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; CreateSuspended: boolean = false;
      onChangeStatus: TCallBack = nil);
    procedure Execute; override;
    procedure myStart(raiseExceptionEnabled: boolean = true);
    procedure pause;
    procedure myResume;
    procedure stop(force: boolean = false);

    function getACopyMyThread: TMyThread;
    destructor Destroy; override;
  end;

implementation

uses
  KLib.Utils,
  System.SysUtils;

constructor TMyThread.Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; CreateSuspended: boolean = false;
  onChangeStatus: TCallBack = nil);
begin
  Self._executorMethod := executorMethod;
  Self._rejectCallBack := rejectCallBack;
  Self._CreateSuspended := CreateSuspended;
  Self.onChangeStatus := onChangeStatus;

  Self.status := TStatus.created;
  Self._event := TMyEvent.Create(not CreateSuspended);
  inherited Create(CreateSuspended);
  if not CreateSuspended then
  begin
    _event.enable;
    status := TStatus.running;
  end;
end;

procedure TMyThread.myStart(raiseExceptionEnabled: boolean = true);
begin
  case status of
    TStatus.created:
      begin
        Start;
        _event.enable;
        status := TStatus.running;
      end;
    TStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot restart it.');
      end;
    TStatus.paused:
      begin
        myResume;
      end;
    TStatus.running:
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
    TStatus.created:
      begin
        raise Exception.Create('Thread not started, you cannot pause it.');
      end;
    TStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot pause it.');
      end;
    TStatus.paused:
      begin
        raise Exception.Create('Thread already paused.');
      end;
    TStatus.running:
      begin
        if (not Terminated) then
        begin
          _event.disable;
          status := TStatus.paused;
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
    TStatus.created:
      begin
        raise Exception.Create('Thread not started, you cannot resume it.');
      end;
    TStatus.stopped:
      begin
        raise Exception.Create('Thread stopped, you cannot restart it.');
      end;
    TStatus.paused:
      begin
        _event.enable;
        status := TStatus.running;
      end;
    TStatus.running:
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
    if (status <> TStatus.created) and (status <> TStatus.paused) then
    begin
      WaitFor;
    end;
    _event.enable;
    status := TStatus.stopped;
  end;

begin
  case status of
    TStatus.created:
      begin
        _stop;
      end;
    TStatus.stopped:
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
    TStatus.paused:
      begin
        _stop;
      end;
    TStatus.running:
      begin
        _stop;
      end;
  else
    begin
      Exception.Create('Incorrect status');
    end;
  end;
end;

function TMyThread.getACopyMyThread: TMyThread;
var
  myThread: TMyThread;
begin
  myThread := TMyThread.Create(Self._executorMethod, Self._rejectCallBack, Self._CreateSuspended, Self.onChangeStatus);

  Result := myThread;
end;

procedure TMyThread._set_status(value: TStatus);
begin
  _status := value;
  if Assigned(onChangeStatus) then
  begin
    onChangeStatus(get_status_asString(_status));
  end;
end;

function TMyThread._get_IsRunning: boolean;
begin
  Result := status = TStatus.running;
end;

destructor TMyThread.Destroy;
begin
  stop(FORCE);
  _event.Free;
  inherited;
end;

end.
