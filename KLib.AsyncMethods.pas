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

unit KLib.AsyncMethods;

interface

uses
  KLib.Types;

type
  TAsyncMethods = class
  private
    anonymousMethods: TArrayOfAnonymousMethods;
    thenCallback: TCallBack;
    catchCallback: TCallback;
    numberProcedures: integer;
    countProceduresDone: integer;
    constructor Create(_then: TCallBack; _catch: TCallback); reintroduce; overload;
    procedure executeProcedures;
    procedure executeAsyncMethod(_anonymousMethod: TAnonymousMethod); overload;
    procedure incCountProceduresDone;
    function _get_exit: boolean;
    procedure _set_exit(value: boolean);
    property _exit: boolean read _get_exit write _set_exit;
  public
    status: TAsyncMethodStatus;
    constructor Create(methods: TArrayOfMethods; callBacks: TCallbacks); reintroduce; overload;
    constructor Create(methods: TArrayOfMethods; _then: TCallBack; _catch: TCallback); reintroduce; overload;
    constructor Create(anonymousMethods: TArrayOfAnonymousMethods; callBacks: TCallbacks); reintroduce; overload;
    constructor Create(anonymousMethods: TArrayOfAnonymousMethods; _then: TCallBack; _catch: TCallback); reintroduce; overload; //restituire array con tutti i valori passati?
    destructor Destroy; override;
  end;

implementation

uses
  KLib.AsyncMethod,
  KLib.Common;

constructor TAsyncMethods.Create(methods: TArrayOfMethods; callBacks: TCallbacks);
var
  _arrayOfAnonymousMethods: TArrayOfAnonymousMethods;
begin
  _arrayOfAnonymousMethods := getArrayOfAnonymousMethodsFromArrayOfMethods(methods);
  Create(_arrayOfAnonymousMethods, callBacks);
end;

constructor TAsyncMethods.Create(methods: TArrayOfMethods; _then: TCallBack; _catch: TCallback);
var
  _arrayOfAnonymousMethods: TArrayOfAnonymousMethods;
begin
  _arrayOfAnonymousMethods := getArrayOfAnonymousMethodsFromArrayOfMethods(methods);
  Create(_arrayOfAnonymousMethods, _then, _catch);
end;

constructor TAsyncMethods.Create(anonymousMethods: TArrayOfAnonymousMethods; callBacks: TCallbacks);
begin
  Create(anonymousMethods, TCallBack(callBacks.resolve), TCallback(callBacks.reject));
end;

constructor TAsyncMethods.Create(anonymousMethods: TArrayOfAnonymousMethods; _then: TCallBack; _catch: TCallback);
begin
  Self.anonymousMethods := anonymousMethods;

  Create(_then, _catch);
end;

constructor TAsyncMethods.Create(_then: TCallBack; _catch: TCallback);
begin
  Self.numberProcedures := Length(anonymousMethods);
  Self.countProceduresDone := 0;
  status := TAsyncMethodStatus.created;
  thenCallback := _then;
  catchCallback := _catch;
  executeProcedures;
end;

procedure TAsyncMethods.executeProcedures;
var
  i: integer;
begin
  status := TAsyncMethodStatus.pending;
  for i := 0 to numberProcedures - 1 do
  begin
    executeAsyncMethod(Self.anonymousMethods[i]);
  end;
end;

procedure TAsyncMethods.executeAsyncMethod(_anonymousMethod: TAnonymousMethod);
begin
  TAsyncMethod.Create(
    procedure(resolve: TCallBack; reject: TCallback)
    begin
      if not _exit then
      begin
        _anonymousMethod;
        resolve('');
      end;
    end,
    procedure(value: String)
    begin
      incCountProceduresDone;
    end,
    procedure(value: String)
    begin
      if not _exit then
      begin
        status := TAsyncMethodStatus.rejected;
        catchCallback(value);
        _exit := true;
      end;
    end);
end;

procedure TAsyncMethods.incCountProceduresDone;
begin
  inc(countProceduresDone);
  if (countProceduresDone = numberProcedures) then
  begin
    status := TAsyncMethodStatus.fulfilled;
    thenCallback('');
    _exit := true;
  end;
end;

function TAsyncMethods._get_exit: boolean;
begin
  Result := (status = TAsyncMethodStatus.fulfilled) or (status = TAsyncMethodStatus.rejected);
end;

procedure TAsyncMethods._set_exit(value: boolean);
begin
  if value = true then
  begin
    Destroy;
  end;
end;

destructor TAsyncMethods.Destroy;
begin
  inherited;
end;

end.
