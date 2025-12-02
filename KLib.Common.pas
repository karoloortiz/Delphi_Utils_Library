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

unit KLib.Common;

interface

uses
  KLib.Types, KLib.Constants, KLib.MyThread,
  System.SysUtils;

procedure restartMyThread(var myThread: TMyThread);

function getArrayOfAnonymousMethodsFromArrayOfMethods(_methods: KLib.Types.TArrayOfMethods): KLib.Types.TArrayOfAnonymousMethods;
function getAnonymousMethodsFromMethod(_method: KLib.Types.TMethod): KLib.Types.TAnonymousMethod;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; isRaiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TCallBack; isRaiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TProcedure; isRaiseExceptionEnabled: boolean = false); overload;
procedure executeProcedure(myProcedure: TAnonymousMethod); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

function ifThen(condition: boolean; trueDateTime: TDateTime; falseDateTime: TDateTime = 0): TDateTime; overload;
function ifThen(condition: boolean; trueString: string; falseString: string = EMPTY_STRING): string; overload;

procedure validate(condition: boolean; errMsg: string);

function myIsDebuggerPresent: boolean;

implementation

uses
  System.Hash, System.NetEncoding;

procedure restartMyThread(var myThread: TMyThread);
var
  _tempThread: TMyThread;
begin
  _tempThread := myThread.getACopyMyThread;
  FreeAndNil(myThread);
  myThread := _tempThread;
  myThread.myStart(RAISE_EXCEPTION_DISABLED);
end;

function getArrayOfAnonymousMethodsFromArrayOfMethods(_methods: KLib.Types.TArrayOfMethods): KLib.Types.TArrayOfAnonymousMethods;
var
  arrayOfAnonymousMethods: TArrayOfAnonymousMethods;

  _lengthOfMethods: integer;
  i: integer;
begin
  _lengthOfMethods := Length(_methods);
  SetLength(arrayOfAnonymousMethods, _lengthOfMethods);

  for i := 0 to _lengthOfMethods - 1 do
  begin
    arrayOfAnonymousMethods[i] := getAnonymousMethodsFromMethod(_methods[i]);
  end;

  Result := arrayOfAnonymousMethods;
end;

function getAnonymousMethodsFromMethod(_method: KLib.Types.TMethod): KLib.Types.TAnonymousMethod;
begin
  Result :=
      procedure
    begin
      _method;
    end;
end;

procedure tryToExecuteProcedure(myProcedure: TProcedure; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TCallBack; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure executeProcedure(myProcedure: TAnonymousMethod);
begin
  myProcedure;
end;

procedure executeProcedure(myProcedure: TCallBack);
begin
  myProcedure('');
end;

function ifThen(condition: boolean; trueDateTime: TDateTime; falseDateTime: TDateTime = 0): TDateTime;
var
  _result: TDateTime;
begin
  _result := 0;

  if (condition) then
  begin
    _result := trueDateTime;
  end;
  if (not condition) then
  begin
    _result := falseDateTime;
  end;

  Result := _result;
end;

function ifThen(condition: boolean; trueString: string; falseString: string = EMPTY_STRING): string;
var
  _result: string;
begin
  _result := EMPTY_STRING;

  if (condition) then
  begin
    _result := trueString;
  end;
  if (not condition) then
  begin
    _result := falseString;
  end;

  Result := _result;
end;

procedure validate(condition: boolean; errMsg: string);
begin
  if not condition then
  begin
    raise Exception.Create(errMsg);
  end;
end;

function myIsDebuggerPresent: boolean;
begin
{$warn SYMBOL_PLATFORM OFF}
  Result := System.DebugHook <> 0;
end;

end.
