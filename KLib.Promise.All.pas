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

//example
//  TPromise.all(_promises)._then(
//    procedure(value: String) // _then method
//    begin
//      //resolve
//    end)._catch(
//    procedure(value: String) // _catch method
//    begin
//      //reject
//    end)._finally;;

unit KLib.Promise.All;

interface

uses
  KLib.Promise,
  KLib.Types, Klib.Constants;

type
  TPromiseAllHelper = class helper for TPromise
    //    class function all(methods: TArrayOfMethods; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
    //    class function all(procedures: TArrayOfProcedures; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
    class function all(anonymousMethods: TArrayOfAnonymousMethods; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
    class function all(anonymousMethods: TArrayOfAnonymousMethods; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
    class function all(promises: TArrayOfPromises; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
    class function all(promises: TArrayOfPromises; _then: TCallBack = nil; _catch: TCallback = nil; autoClean: boolean = NOT_AUTO_CLEAN): TPromise; overload;
  end;

implementation

uses
  System.SysUtils;

//class function TPromiseAllHelper.all(methods: TArrayOfMethods; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
//var
//  promiseAll: TPromise;
//
//  _promises: TArrayOfPromises;
//  _lengthOfMethods: integer;
//  i: integer;
//begin
//  _lengthOfMethods := Length(methods);
//  SetLength(_promises, _lengthOfMethods);
//
//  for i := 0 to _lengthOfMethods - 1 do
//  begin
//    _promises[i] := TPromise.Create(methods[i]);
//  end;
//
//  promiseAll := TPromise.all(_promises, autoClean);
//
//  Result := promiseAll;
//end;

//class function TPromiseAllHelper.all(procedures: TArrayOfProcedures; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
//var
//  promiseAll: TPromise;
//
//  _promises: TArrayOfPromises;
//  _lengthOfProcedures: integer;
//  i: integer;
//begin
//  _lengthOfProcedures := Length(procedures);
//  SetLength(_promises, _lengthOfProcedures);
//
//  for i := 0 to _lengthOfProcedures - 1 do
//  begin
//    _promises[i] := TPromise.Create(procedures[i]);
//  end;
//
//  promiseAll := TPromise.all(_promises, autoClean);
//
//  Result := promiseAll;
//end;

class function TPromiseAllHelper.all(anonymousMethods: TArrayOfAnonymousMethods; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := all(anonymousMethods, TCallBack(callBacks.resolve), TCallback(callBacks.reject), autoClean);
end;

class function TPromiseAllHelper.all(anonymousMethods: TArrayOfAnonymousMethods; _then: TCallBack = nil; _catch: TCallback = nil;
  autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
var
  promiseAll: TPromise;

  _promises: TArrayOfPromises;
  _lengthOfAnonymousMethods: integer;
  i: integer;
begin
  _lengthOfAnonymousMethods := Length(anonymousMethods);
  SetLength(_promises, _lengthOfAnonymousMethods);

  for i := 0 to _lengthOfAnonymousMethods - 1 do
  begin
    _promises[i] := TPromise.Create(anonymousMethods[i]);
  end;

  promiseAll := TPromise.all(_promises, _then, _catch, autoClean);

  Result := promiseAll;
end;

class function TPromiseAllHelper.all(promises: TArrayOfPromises; callBacks: TCallbacks; autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
begin
  Result := all(promises, TCallBack(callBacks.resolve), TCallback(callBacks.reject), autoClean);
end;

class function TPromiseAllHelper.all(promises: TArrayOfPromises; _then: TCallBack = nil; _catch: TCallback = nil;
  autoClean: boolean = NOT_AUTO_CLEAN): TPromise;
var
  promiseAll: TPromise;

  _promises: TArrayOfPromises;
begin
  _promises := promises;

  promiseAll := TPromise.Create(
    procedure(resolve: TCallBack; reject: TCallback)
    var
      numberPromises: integer;
      countPromisesDone: integer;
      i: integer;

      incCountProceduresDone: TCallBack;
    begin
      numberPromises := Length(_promises);
      countPromisesDone := 0;

      incCountProceduresDone := procedure(value: string)
        begin
          inc(countPromisesDone);
          if (countPromisesDone = numberPromises) then
          begin
            resolve('Promise.All resolved.');
          end;
        end;

      for i := 0 to numberPromises - 1 do
      begin
        _promises[i]._then(incCountProceduresDone, reject)._finally();
      end;
    end,
    _then,
    _catch,
    autoClean);

  Result := promiseAll;
end;

end.
