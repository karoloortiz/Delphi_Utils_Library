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

unit KLib.AsyncMethod;

interface

uses
  KLib.Types;

type

  TAsyncMethod = class
  private
    executorFunction: TExecutorFunction;
    thenCallback: TCallBack;
    catchCallback: TCallback;
    alreadyExecuted: boolean;
    enabledThenCallback: boolean;
    enabledCatchCallback: boolean;
    procedure execute;
    procedure executeInAnonymousThread;
    procedure resolve(msg: string);
    procedure reject(msg: string);
  public
    constructor Create(executorFunction: TExecutorFunction; callBacks: TCallbacks); reintroduce; overload;
    constructor Create(executorFunction: TExecutorFunction; _then: TCallBack; _catch: TCallback); reintroduce; overload;
    constructor Create(executorFunction: TExecutorFunction); reintroduce; overload;
    procedure _then(value: TCallBack);
    procedure _catch(value: TCallback);
    destructor Destroy; override;
  end;

implementation

uses
  Winapi.ActiveX,
  System.SysUtils, System.Classes;

constructor TAsyncMethod.Create(executorFunction: TExecutorFunction; callBacks: TCallbacks);
begin
  Create(executorFunction, TCallBack(callBacks.resolve), TCallback(callBacks.reject));
end;

constructor TAsyncMethod.Create(executorFunction: TExecutorFunction; _then: TCallBack; _catch: TCallback);
begin
  Create(executorFunction);
  Self._then(_then);
  Self._catch(_catch);
end;

constructor TAsyncMethod.Create(executorFunction: TExecutorFunction);
begin
  Self.executorFunction := executorFunction;
end;

procedure TAsyncMethod._then(value: TCallBack);
begin
  enabledThenCallback := true;
  thenCallback := value;
  execute;
end;

procedure TAsyncMethod._catch(value: TCallback);
begin
  enabledCatchCallback := true;
  catchCallback := value;
  execute;
end;

procedure TAsyncMethod.execute;
begin
  if (not alreadyExecuted) and (enabledThenCallback) and (enabledCatchCallback) then
  begin
    alreadyExecuted := true;
    executeInAnonymousThread;
  end;
end;

procedure TAsyncMethod.executeInAnonymousThread;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        try
          executorFunction(resolve, reject);
        except
          on e: Exception do
          begin
            if (e.ClassType <> EExit) then
            begin
              reject(e.Message);
            end;
          end;
        end;
      finally
        CoUninitialize;
        Self.Destroy;
      end;
    end).Start;
end;

procedure TAsyncMethod.resolve(msg: string);
begin
  thenCallback(msg);
  raise EExit.Create('force exit in resolve procedure');
end;

procedure TAsyncMethod.reject(msg: string);
begin
  catchCallback(msg);
  raise EExit.Create('force exit in reject procedure');
end;

destructor TAsyncMethod.Destroy;
begin
  inherited;
end;

end.
