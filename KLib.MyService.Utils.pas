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

unit KLib.MyService.Utils;

interface

uses
  KLib.Types, KLib.Constants;

type
  TRunServiceParams = record
    executorMethod: TAnonymousMethod;
    eventLogDisabled: boolean;
    rejectCallback: TCallBack;
    applicationName: string;
    installParameterName: string;

    procedure clear;
  end;

procedure runService(params: TRunServiceParams); overload;
procedure runService(executorMethod: TAnonymousMethod; eventLogDisabled: boolean = false; rejectCallback: TCallBack = nil;
  applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING); overload;
procedure installService(silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
procedure uninstallService(silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
procedure installOrUninstallService(install: boolean; silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);

implementation

uses
  KLib.MyService, KLib.MyServiceApplication,
  Vcl.SvcMgr;

procedure TRunServiceParams.clear;
begin
  with Self do
  begin
    executorMethod := nil;
    eventLogDisabled := false;
    rejectCallback := nil;
    applicationName := EMPTY_STRING;
    installParameterName := EMPTY_STRING;
  end;
end;

procedure runService(params: TRunServiceParams);
begin
  runService(params.executorMethod, params.eventLogDisabled, params.rejectCallback, params.applicationName, params.installParameterName);
end;

procedure runService(executorMethod: TAnonymousMethod; eventLogDisabled: boolean = false; rejectCallback: TCallBack = nil;
  applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
begin
  if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
  begin
    Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TMyService, MyService);
    MyService.executorMethod := executorMethod;
    MyService.eventLogDisabled := eventLogDisabled;
    MyService.rejectCallback := rejectCallback;
    MyService.applicationName := applicationName;
    MyService.installParameterName := installParameterName;
    Vcl.SvcMgr.Application.Run;
  end;
end;

procedure installService(silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
begin
  installOrUninstallService(true, silent, serviceName, regkeyDescription, applicationName, installParameterName);
end;

procedure uninstallService(silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
begin
  installOrUninstallService(false, silent, serviceName, regkeyDescription, applicationName, installParameterName);
end;

procedure installOrUninstallService(install: boolean; silent: boolean = false; serviceName: string = EMPTY_STRING;
  regkeyDescription: string = EMPTY_STRING; applicationName: string = EMPTY_STRING; installParameterName: string = EMPTY_STRING);
begin
  if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
  begin
    Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TMyService, MyService);
    MyService.serviceName := serviceName;
    MyService.regkeyDescription := regkeyDescription;
    MyService.applicationName := applicationName;
    MyService.installParameterName := installParameterName;
    TMyServiceApplication(Vcl.SvcMgr.Application).myRegisterServices(install, silent);
    with Vcl.SvcMgr.Application do
    begin
      Destroying;
      DestroyComponents;
    end;
  end;
end;

end.
