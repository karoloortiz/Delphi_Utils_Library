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

unit KLib.ServiceApp.ThreadAdapter;

interface

uses
  KLib.ServiceAppPort, KLib.Types, KLib.MyThread,
  System.Classes;

type
  TThreadAdapter = class(TInterfacedObject, IServiceAppPort)
  private
  protected
    function getRejectCallBack: TCallBack;
    procedure setRejectCallBack(value: TCallBack);
    function getOnChangeStatus(): TOnChangeStatus;
    procedure setOnChangeStatus(value: TOnChangeStatus);
  public
    thread: TMyThread;

    property rejectCallBack: TCallBack read getRejectCallBack write setRejectCallBack;
    property onChangeStatus: TOnChangeStatus read getOnChangeStatus write setOnChangeStatus;

    constructor Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; onChangeStatus: TOnChangeStatus = nil); overload;
    //if you use this constructor, define your subclass and override Run method
    constructor Create(rejectCallBack: TCallBack; onChangeStatus: TOnChangeStatus = nil); overload;
    procedure start; virtual;
    procedure pause; virtual;
    procedure resume; virtual;
    procedure stop; virtual;
    procedure restart; virtual;

    procedure waitUntilIsRunning; virtual;

    function getStatus: TStatus; virtual;
    function getHandle: integer; virtual;
    procedure run; virtual;
    destructor Destroy; override;
  end;

implementation

uses
  KLib.Constants, KLib.Common, KLib.Windows,
  System.SysUtils;

constructor TThreadAdapter.Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; onChangeStatus: TOnChangeStatus = nil);
begin
  Self.thread := TMyThread.Create(executorMethod, rejectCallBack, FORCE_SUSPEND, onChangeStatus);
end;

constructor TThreadAdapter.Create(rejectCallBack: TCallBack; onChangeStatus: TOnChangeStatus = nil);
begin
  Self.thread := TMyThread.Create(Self.run, rejectCallBack, FORCE_SUSPEND, onChangeStatus);
end;

procedure TThreadAdapter.start;
begin
  thread.myStart();
end;

procedure TThreadAdapter.pause;
begin
  thread.pause;
end;

procedure TThreadAdapter.resume;
begin
  thread.myResume;
end;

procedure TThreadAdapter.stop;
begin
  thread.stop;
end;

procedure TThreadAdapter.restart;
begin
  restartMyThread(thread);
end;

procedure TThreadAdapter.waitUntilIsRunning;
begin
  Sleep(INFINITE); //better beacuse not use mainThread
  //  while _myThread.isRunning do
  //  begin
  //    waitForMultiple(_myThread.Handle);
  //  end;
end;

function TThreadAdapter.getStatus: TStatus;
begin
  Result := thread.status;
end;

function TThreadAdapter.getHandle: integer;
begin
  Result := thread.Handle;
end;

function TThreadAdapter.getRejectCallBack: TCallBack;
begin
  Result := thread.rejectCallback;
end;

procedure TThreadAdapter.setRejectCallBack(value: TCallBack);
begin
  thread.rejectCallback := value;
end;

function TThreadAdapter.getOnChangeStatus(): TOnChangeStatus;
begin
  Result := thread.onChangeStatus;
end;

procedure TThreadAdapter.setOnChangeStatus(value: TOnChangeStatus);
begin
  thread.onChangeStatus := value;
end;

procedure TThreadAdapter.run;
begin
  //override
end;

destructor TThreadAdapter.Destroy;
begin
  FreeAndNil(thread);
  inherited;
end;

end.
