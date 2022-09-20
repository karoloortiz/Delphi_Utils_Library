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

unit KLib.ServiceApp.ThreadAdapter;

interface

uses
  KLib.ServiceAppPort, KLib.Types, KLib.MyThread,
  System.Classes;

type
  TThreadAdapter = class(TInterfacedObject, IServiceAppPort)
  private
  protected
    rejectCallBack: TCallBack;
  public
    _myThread: TMyThread;

    constructor Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil); overload;
    constructor Create(rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil); overload; //if you use this constructor, define your subclass and override Run method
    procedure start; virtual;
    procedure pause; virtual;
    procedure resume; virtual;
    procedure stop; virtual;
    procedure restart; virtual;

    procedure waitUntilIsRunning; virtual;

    function getStatus: TStatus; virtual;
    function getHandle: integer; virtual;
    procedure Run; virtual; abstract;
    destructor Destroy; override;
  end;

implementation

uses
  KLib.Constants, KLib.Utils, KLib.Windows,
  System.SysUtils;

constructor TThreadAdapter.Create(executorMethod: TAnonymousMethod; rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil);
begin
  Self.rejectCallBack := rejectCallBack;
  _myThread := TMyThread.Create(executorMethod, rejectCallBack, FORCE_SUSPEND, onChangeStatus);
end;

constructor TThreadAdapter.Create(rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil);
begin
  Self.rejectCallBack := rejectCallBack;
  _myThread := TMyThread.Create(run, rejectCallBack, FORCE_SUSPEND, onChangeStatus);
end;

procedure TThreadAdapter.start;
begin
  _myThread.myStart();
end;

procedure TThreadAdapter.pause;
begin
  _myThread.pause;
end;

procedure TThreadAdapter.resume;
begin
  _myThread.myResume;
end;

procedure TThreadAdapter.stop;
begin
  _myThread.stop;
end;

procedure TThreadAdapter.restart;
begin
  restartMyThread(_myThread);
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
  Result := _myThread.status;
end;

function TThreadAdapter.getHandle: integer;
begin
  Result := _myThread.Handle;
end;

destructor TThreadAdapter.Destroy;
begin
  FreeAndNil(_myThread);
  inherited;
end;

end.
