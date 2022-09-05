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

{

  //### DON'T USE property serviceName; -- RESERVED ONLY FOR procedure installOrUninstallService

  USAGE OF SERVER (runService or Inherited mode):
  1)CALL KLib.MyService.Utils.runService(runServiceParams);
  2)INHERITED MODE:
  ___-OVERRIDE procedure ServiceCreate(Sender: TObject); AND SET:
  ______- executorMethod: TAnonymousMethod; // REQUIRED
  ______- eventLogDisabled: boolean; // NOT REQUIRED
  ______- rejectCallback: TCallBack; // NOT REQUIRED
  - IN PROJECT START SERVICE WITH
  if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
  begin
  Vcl.SvcMgr.Application.Initialize;
  end;
  Vcl.SvcMgr.Application.CreateForm(TCustomMyService, MyService);  //####DON'T CHANGE MyService variable
  Vcl.SvcMgr.Application.Run;
}

unit KLib.MyService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  KLib.MyThread, KLib.Windows.EventLog, KLib.Types;

const
  DEFAULT_INSTALL_PARAMETER_NAME = '--install';

type
  TMyService = class(TService)
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    workerThread: TMyThread;
    eventLog: TEventLog;
    _serviceName: string;
    _regkeyDescription: string;
    _applicationName: string;
    _installParameterName: string;
    _rejectCallback: TCallBack;
    procedure _set_service_name(value: string);
    procedure _set_regkeyDescription(value: string);
    function _get_applicationName: string;
    function _get_installParameterName: string;
    procedure _set_rejectCallback(value: TCallBack);
    function _get_rejectCallback: TCallBack;
  protected
  public
    executorMethod: TAnonymousMethod;
    eventLogDisabled: boolean;
    customParameters: string;

    procedure writeInfoInEventLog(msg: string; raiseExceptionEnabled: boolean = true);
    procedure writeErrorInEventLog(msg: string; raiseExceptionEnabled: boolean = true);
    function getDefaultServiceName: string;
    function GetServiceController: TServiceController; override;

    property serviceName: string read _serviceName write _set_service_name; //USED ONLY FOR INSTALLATION OF SERVICE
    property regkeyDescription: string read _regkeyDescription write _set_regkeyDescription;
    property applicationName: string read _get_applicationName write _applicationName;
    property installParameterName: string read _get_installParameterName write _installParameterName;
    property rejectCallback: TCallBack read _get_rejectCallback write _set_rejectCallback;
  end;

var
  MyService: TMyService;

implementation

{$r *.dfm}


uses
  KLib.Windows, KLib.Utils, KLib.Constants, KLib.MyString,
  System.Win.Registry;

procedure TMyService.ServiceCreate(Sender: TObject);
begin
  serviceName := getDefaultServiceName;
  executorMethod := procedure
    begin
      sleep(2000);
    end;
end;

procedure TMyService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  try
    if not Assigned(executorMethod) then
    begin
      raise Exception.Create('executorMethod not assigned. Set executorMethod before create TMyService.');
    end;

    workerThread := TMyThread.Create(executorMethod, rejectCallback);
    if not eventLogDisabled then
    begin
      eventLog := TEventLog.Create(applicationName);
    end;
    writeInfoInEventLog('Service has been started.', RAISE_EXCEPTION_DISABLED);
    Started := True;
  except
    on E: Exception do
    begin
      rejectCallback('Service failed to start :' + E.Message);
      ServiceShutdown(Self);
    end;
  end;
end;

procedure TMyService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  workerThread.myResume;
  Continued := True;
  writeInfoInEventLog('Service has been resumed.', RAISE_EXCEPTION_DISABLED);
end;

procedure TMyService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  workerThread.pause;
  Paused := True;
  writeInfoInEventLog('Service has been paused.', RAISE_EXCEPTION_DISABLED);
end;

procedure TMyService.ServiceShutdown(Sender: TService);
var
  Stopped: boolean;
begin
  ServiceStop(Self, Stopped);
end;

procedure TMyService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  try
    Stopped := True; // always stop service, even if we had exceptions, this is to prevent "stuck" service (must reboot then)

    if Assigned(workerThread) then
    begin
      workerThread.stop;
      while WaitForSingleObject(workerThread.Handle, WaitHint - 100) = WAIT_TIMEOUT do
      begin
        ReportStatus;
      end;
      FreeAndNil(workerThread);
    end;

    writeInfoInEventLog('Service has been stopped.', RAISE_EXCEPTION_DISABLED);
  except
    on E: Exception do
    begin
      rejectCallback('Service failed to stop :' + E.Message);
    end;
  end;
end;

procedure TMyService.ServiceAfterInstall(Sender: TService);
var
  _service_regKey: string;
  _ImagePath: string;
  _extraParams: string;
begin
  _service_regKey := SERVICES_REGKEY + '\' + serviceName;
  writeIn_HKEY_LOCAL_MACHINE(_service_regKey, 'Description', _regkeyDescription);

  _ImagePath := readStringFrom_HKEY_LOCAL_MACHINE(_service_regKey, 'ImagePath');
  if customParameters <> EMPTY_STRING then
  begin
    _extraParams := ' ' + customParameters;
  end
  else
  begin
    _extraParams := EMPTY_STRING;
  end;
  _ImagePath := _ImagePath + ' ' + installParameterName + ' ' + serviceName + _extraParams;
  writeIn_HKEY_LOCAL_MACHINE(_service_regKey, 'ImagePath', _ImagePath);

  writeIn_HKEY_LOCAL_MACHINE(_service_regKey, 'ApplicationName', applicationName);

  if not eventLogDisabled then
  begin
    TEventLog.addEventApplicationToRegistry(applicationName, exeFileName);
    writeInfoInEventLog('Service installed.', RAISE_EXCEPTION_DISABLED);
  end;
end;

procedure TMyService.ServiceAfterUninstall(Sender: TService);
begin
  if not eventLogDisabled then
  begin
    writeInfoInEventLog('Service will be uninstalled.', RAISE_EXCEPTION_DISABLED);
    TEventLog.deleteEventApplicationFromRegistry(applicationName);
  end;
end;

procedure TMyService.writeInfoInEventLog(msg: string; raiseExceptionEnabled: boolean = true);
begin
  if Assigned(eventLog) then
  begin
    eventLog.writeInfo(msg);
  end
  else if raiseExceptionEnabled then
  begin
    raise Exception.Create('eventLog unassigned. Set eventLogDisabled=false before create TMyService.');
  end;
end;

procedure TMyService.writeErrorInEventLog(msg: string; raiseExceptionEnabled: boolean = true);
begin
  if Assigned(eventLog) then
  begin
    eventLog.writeError(msg);
  end
  else if raiseExceptionEnabled then
  begin
    raise Exception.Create('eventLog unassigned. Set eventLogDisabled=false before create TMyService.');
  end;
end;

function TMyService.getDefaultServiceName: string;
var
  defaultServiceName: string;
  _tempString: string;
begin
  if checkIfParameterExists(installParameterName) then
  begin
    _tempString := getValueOfParameter(installParameterName);
    if checkIfRegexIsValid(_tempString, REGEX_ONLY_LETTERS_NUMBERS_AND__) then
    begin
      defaultServiceName := _tempString;
    end;
  end;

  if defaultServiceName = EMPTY_STRING then
  begin
    defaultServiceName := ClassName.substring(1)
  end;

  Result := defaultServiceName;
end;

procedure TMyService._set_service_name(value: string);
begin
  _serviceName := value;

  if _serviceName = EMPTY_STRING then
  begin
    _serviceName := getDefaultServiceName;
  end;

  DisplayName := _serviceName;
  Name := _serviceName;
end;

procedure TMyService._set_regkeyDescription(value: string);
begin
  _regkeyDescription := value;

  if _regkeyDescription = EMPTY_STRING then
  begin
    _regkeyDescription := applicationName + ' 1.0';
  end;
end;

function TMyService._get_applicationName: string;
var
  applicationName: string;
begin
  if _applicationName = EMPTY_STRING then
  begin
    applicationName := _serviceName;
  end
  else
  begin
    applicationName := _applicationName;
  end;

  Result := applicationName;
end;

function TMyService._get_installParameterName: string;
var
  installParameterName: string;
begin
  if installParameterName = EMPTY_STRING then
  begin
    installParameterName := DEFAULT_INSTALL_PARAMETER_NAME;
  end
  else
  begin
    installParameterName := _installParameterName;
  end;

  Result := installParameterName;
end;

procedure TMyService._set_rejectCallback(value: TCallBack);
begin
  _rejectCallback := value;
end;

function TMyService._get_rejectCallback: TCallBack;
var
  rejectCallback: TCallBack;
begin
  rejectCallback := procedure(msg: string)
    begin
      writeErrorInEventLog('ERROR -> ' + msg, RAISE_EXCEPTION_DISABLED);
      if Assigned(_rejectCallback) then
      begin
        _rejectCallback(msg);
      end;
    end;

  Result := rejectCallback;
end;

procedure TMyService.ServiceDestroy(Sender: TObject);
begin
  if Assigned(eventLog) then
  begin
    FreeAndNil(eventLog);
  end;
end;

//##############################################################################
procedure ServiceController(CtrlCode: DWord); stdcall; //generated by default
begin
  MyService.Controller(CtrlCode);
end;

function TMyService.GetServiceController: TServiceController; //generated by default
begin
  Result := ServiceController;
end;

end.
