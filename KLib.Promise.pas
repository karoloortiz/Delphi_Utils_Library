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

unit KLib.Promise;

interface

uses
  KLib.Types, Klib.Constants, KLib.ListOfThreads, KLib.MyEvent,
  System.Classes;

type

  TPromise = class
  private
    _executorFunction: TExecutorFunction;
    _alreadyExecuted: boolean;
    _autoClean: boolean;
    _autoCleanSetted: boolean;

    _promiseFinished_event: TMyEvent;

    _executor_thread: TThread;
    _then_threadList: TListOfThreads;
    _catch_threadList: TListOfThreads;

    _default_reject_callback: TCallBack;

    procedure execute;
    procedure executeInAnonymousThread;
    procedure resolve(msg: string);
    procedure reject(msg: string);
  public
    status: TAsyncMethodStatus;
    resultOfPromise: string;

    constructor Create(_method: KLib.Types.TMethod;
      _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN); reintroduce; overload;
    constructor Create(_procedure: KLib.Types.TProcedure;
      _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN); reintroduce; overload;
    constructor Create(_anonymousMethod: KLib.Types.TAnonymousMethod;
      _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN); reintroduce; overload;
    //autoClean is like a FreeOnTerminate on TThread
    constructor Create(executorFunction: TExecutorFunction; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN); reintroduce; overload;
    constructor Create(executorFunction: TExecutorFunction; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN); reintroduce; overload;
    function setCallbacks(callbacks: TCallBacks): TPromise; overload;
    function _then(onFulfilled: TCallBack; onRejected: TCallBack): TPromise; overload;
    function _then(onFulfilled: TCallBack): TPromise; overload;
    function _catch(onRejected: TCallback): TPromise;
    procedure _finally; overload;
    procedure _finally(onFinally: KLib.Types.TAnonymousMethod); overload;

    function await(): string;
    procedure internalWait(ATimeout: Cardinal = INFINITE);

    destructor Destroy; override;

  end;

  TArrayOfPromises = array of TPromise; //not move in KLib.Types (circular reference)

function promisify(_method: KLib.Types.TMethod;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
function promisify(_method: KLib.Types.TMethod;
  _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;

function promisify(_procedure: KLib.Types.TProcedure;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
function promisify(_procedure: KLib.Types.TProcedure;
  _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;

function promisify(_anonymousMethod: KLib.Types.TAnonymousMethod;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
function promisify(_anonymousMethod: KLib.Types.TAnonymousMethod;
  _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;

implementation

uses
  Winapi.ActiveX,
  System.SysUtils, System.Types;

type
  EExitPromise = class(EAbort);

function promisify(_method: KLib.Types.TMethod;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := promisify(_method, callBacks.resolve, callBacks.reject, autoClean);
end;

function promisify(_method: KLib.Types.TMethod; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
begin
  Result := TPromise.Create(_method, _then, _catch, autoClean);
end;

function promisify(_procedure: KLib.Types.TProcedure;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := promisify(_procedure, callBacks.resolve, callBacks.reject, autoClean);
end;

function promisify(_procedure: KLib.Types.TProcedure; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
begin
  Result := TPromise.Create(_procedure, _then, _catch, autoClean);
end;

function promisify(_anonymousMethod: KLib.Types.TAnonymousMethod;
  callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := promisify(_anonymousMethod, callBacks.resolve, callBacks.reject, autoClean);
end;

function promisify(_anonymousMethod: KLib.Types.TAnonymousMethod; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := TPromise.Create(_anonymousMethod, _then, _catch, autoClean);
end;

constructor TPromise.Create(_method: KLib.Types.TMethod;
  _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN);
begin
  Create(
    procedure
    begin
      _method;
    end,
    _then, _catch, autoClean);
end;

constructor TPromise.Create(_procedure: KLib.Types.TProcedure;
_then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN);
begin
  Create(
    procedure
    begin
      _procedure;
    end,
    _then, _catch, autoClean);
end;

constructor TPromise.Create(_anonymousMethod: KLib.Types.TAnonymousMethod;
_then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN);
var
  _thenTemp: TCallBack;
  _catchTemp: TCallBack;
begin
  if Assigned(_then) then
  begin
    _thenTemp := _then;
  end
  else
  begin
    _thenTemp := procedure(value: String)
      begin
      end;
  end;

  if Assigned(_catch) then
  begin
    _catchTemp := _catch;
  end
  else
  begin
    _catchTemp := procedure(value: String)
      begin
        raise Exception.Create(value);
      end;
  end;

  Create(
    procedure(resolve: TCallBack; reject: TCallback)
    begin
      _anonymousMethod;
      resolve('Promise resolved');
    end,
    _thenTemp,
    _catchTemp,
    autoClean);
end;

constructor TPromise.Create(executorFunction: TExecutorFunction; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN);
begin
  Create(executorFunction, TCallBack(callBacks.resolve), TCallback(callBacks.reject), autoClean);
end;

constructor TPromise.Create(executorFunction: TExecutorFunction;
_then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN);
begin
  Self._then_threadList := TListOfThreads.Create;
  Self._catch_threadList := TListOfThreads.Create;
  Self._promiseFinished_event := TMyEvent.Create;
  Self.status := TAsyncMethodStatus.created;

  Self._executorFunction := executorFunction;
  Self._autoClean := autoClean;
  Self._autoCleanSetted := false;

  execute;

  if Assigned(_then) then
  begin
    Self._then(_then);
  end;
  if Assigned(_catch) then
  begin
    Self._catch(_catch);
  end;
end;

procedure TPromise.execute;
begin
  if (not _alreadyExecuted) then
  begin
    _alreadyExecuted := true;
    Self.status := TAsyncMethodStatus.pending;
    executeInAnonymousThread;
  end;
end;

procedure TPromise.executeInAnonymousThread;
begin
  _executor_thread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        try
          _executorFunction(resolve, reject);
        except
          on e: Exception do
          begin
            if (e.ClassType <> EExitPromise) then
            begin
              reject(e.Message);
            end;
          end;
        end;
      finally
        CoUninitialize;
      end;
    end);
  _executor_thread.FreeOnTerminate := False;
  _executor_thread.Start;

  if _autoClean then
  begin
    _finally;
  end;
end;

function TPromise.setCallbacks(callbacks: TCallBacks): TPromise;
begin
  _then(callbacks.resolve, callbacks.reject);

  Result := Self;
end;

function TPromise._then(onFulfilled: TCallBack; onRejected: TCallBack): TPromise;
begin
  _then(onFulfilled);
  _catch(onRejected);

  Result := Self;
end;

function TPromise._then(onFulfilled: TCallBack): TPromise;
var
  _then_thread: TThread;
begin
  _then_thread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        _promiseFinished_event.waitForInfinite;

        if status = TAsyncMethodStatus.fulfilled then
        begin
          try
            onFulfilled(resultOfPromise);
          except
            on E: Exception do
            begin
              if (e.ClassType <> EExitPromise) then
              begin
                _default_reject_callback(e.Message);
              end;
            end;
          end;
        end;
      finally
        CoUninitialize;
      end;
    end);
  _then_thread.FreeOnTerminate := False;
  _then_thread.Start;

  _then_threadList.Add(_then_thread);

  Result := Self;
end;

function TPromise._catch(onRejected: TCallback): TPromise;
var
  _catch_thread: TThread;
begin
  if not Assigned(_default_reject_callback) then
  begin
    _default_reject_callback := onRejected;
  end;

  _catch_thread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        _promiseFinished_event.waitForInfinite;

        if status = TAsyncMethodStatus.rejected then
        begin
          onRejected(resultOfPromise);
        end;
      finally
        CoUninitialize;
      end;
    end);
  _catch_thread.FreeOnTerminate := False;
  _catch_thread.Start;

  _catch_threadList.Add(_catch_thread);

  Result := Self;
end;

procedure TPromise._finally;
begin
  _finally(
    procedure
    begin
    end);
end;

procedure TPromise._finally(onFinally: KLib.Types.TAnonymousMethod);
begin
  if _autoCleanSetted then
  begin
    raise Exception.Create('TPromise.autoClean property already setted');
  end;

  TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        _promiseFinished_event.waitForInfinite;

        _then_threadList.WaitFor;
        _catch_threadList.WaitFor;

        onFinally;

      finally
        CoUninitialize;

        Self.Destroy;
      end;
    end).Start;

  Self._autoCleanSetted := true;
end;

function TPromise.Await: string;
begin
  InternalWait;

  System.TMonitor.Enter(Self);
  try
    if status = TAsyncMethodStatus.rejected then
    begin
      raise Exception.Create('Promise rejected with value: ' + Self.resultOfPromise);
    end;
    if status = TAsyncMethodStatus.fulfilled then
    begin
      Result := Self.resultOfPromise;
    end;
    if (status <> TAsyncMethodStatus.rejected)
      and (status <> TAsyncMethodStatus.fulfilled) then
    begin
      raise Exception.Create('InternalAwait finished, but our state is: ');
      // + GetEnumName(TypeInfo(TPromiseState), Ord(State)));
    end;
  finally
    System.TMonitor.Exit(Self);
  end;
end;

procedure TPromise.InternalWait(ATimeout: Cardinal = INFINITE);
const
  MT_SIGNAL_WAIT = 10;
  MT_SYNC_WAIT = 10;
var
  LRunning: Cardinal;
begin
  if (status = TAsyncMethodStatus.pending) then
  begin
    if TThread.CurrentThread.ThreadID = MainThreadID then
    begin
      LRunning := 0;

      _promiseFinished_event.waitForInfinite;

      _then_threadList.WaitFor;
      _catch_threadList.WaitFor;

      while (not(_promiseFinished_event.WaitFor(MT_SIGNAL_WAIT) = TWaitResult.wrSignaled))
        and (LRunning < ATimeout) do
      begin
        CheckSynchronize(MT_SYNC_WAIT);
        LRunning := LRunning + MT_SIGNAL_WAIT + MT_SYNC_WAIT;
      end;
    end
    else
    begin
      var
      LResult := _promiseFinished_event.WaitFor(ATimeout);

      _promiseFinished_event.waitForInfinite;

      _then_threadList.WaitFor;
      _catch_threadList.WaitFor;

      if LResult <> TWaitResult.wrSignaled then
      begin
        raise Exception.Create('Error Message');
      end;
      //raise EInternalWaitProblem.Create('Issue waiting for signal (not set before timeout?): ' + GetEnumName(TypeInfo(TWaitResult), Ord(LResult)));
    end;
  end;
end;

procedure TPromise.resolve(msg: string);
begin
  if (status = TAsyncMethodStatus.pending) then
  begin
    resultOfPromise := msg;
    status := TAsyncMethodStatus.fulfilled;
    _promiseFinished_event.enable;
    raise EExitPromise.Create('force exit in resolve procedure');
  end;
end;

procedure TPromise.reject(msg: string);
begin
  if (status = TAsyncMethodStatus.pending) then
  begin
    resultOfPromise := msg;
    status := TAsyncMethodStatus.rejected;
    _promiseFinished_event.enable;
    raise EExitPromise.Create('force exit in reject procedure');
  end;
end;

destructor TPromise.Destroy;
begin
  FreeAndNil(_executor_thread);
  FreeAndNil(_then_threadList);
  FreeAndNil(_catch_threadList);
  _promiseFinished_event.Free;

  inherited;
end;

end.
