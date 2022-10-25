{
  KLib Version = 3.0
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

unit KLib.WindowsService;

interface

uses
  KLib.Types,
  Winapi.Messages, Winapi.Winsvc;

const
  WM_SERVICE_START = WM_USER + 0;
  WM_SERVICE_ERROR = WM_USER + 2;

type
  TWindowsServiceState = (
    _NULL = -1,
    STOPPPED = SERVICE_STOPPED,
    START_PENDING = SERVICE_START_PENDING,
    STOP_PENDING = SERVICE_STOP_PENDING,
    RUNNING = SERVICE_RUNNING,
    CONTINUE_PENDING = SERVICE_CONTINUE_PENDING,
    PAUSE_PENDING = SERVICE_PAUSE_PENDING,
    PAUSED = SERVICE_PAUSED
    );

  TWindowsService = class //nameService is not case-sensitive
  public
    //    class procedure createService: boolean; //TODO IMPLEMENTE CODE
    class procedure aStart(handleSender: THandle; nameService: string; nameMachine: string = '');
    class procedure startIfExists(nameService: string; nameMachine: string = '');
    class procedure start(nameService: string; nameMachine: string = '');
    class procedure stopIfExists(nameService: string; nameMachine: string = ''; force: boolean = false);
    class procedure stop(nameService: string; nameMachine: string = ''; force: boolean = false);

    class function checkIfIsRunning(nameService: string; nameMachine: string = ''): boolean;
    class function checkIfIsPaused(nameService: string; nameMachine: string = ''): boolean;
    class function checkIfIsStopped(nameService: string; nameMachine: string = ''): boolean;

    class function checkCurrentState(state: TWindowsServiceState; nameService: string; nameMachine: string = ''): boolean;
    class function getCurrentState(nameService: string; nameMachine: string = ''): TWindowsServiceState;

    class function checkIfExists(nameService: string; nameMachine: string = ''): boolean;

    class procedure setStartupTypeAsDelayedAuto(nameService: string);
    class procedure setStartupTypeAsAuto(nameService: string);
    class procedure setStartupTypeAsManual(nameService: string);
    class procedure setStartupTypeAsDisabled(nameService: string);
    class procedure setStartupType(nameService: string; startupType: TWindowsServiceStartupType);

    class procedure delete(nameService: string);
  end;

implementation

uses
  KLib.Windows, KLib.Constants, KLib.Validate, KLib.Utils,
  Winapi.Windows,
  System.Classes, System.SysUtils;

class procedure TWindowsService.aStart(handleSender: THandle; nameService: string; nameMachine: string = '');
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        TWindowsService.start(nameService, nameMachine);
        PostMessage(handleSender, WM_SERVICE_START, 0, 0);
      except
        on E: Exception do
        begin
          PostMessage(handleSender, WM_SERVICE_ERROR, 0, 0);
        end;
      end;
    end).Start;
end;

class procedure TWindowsService.startIfExists(nameService: string; nameMachine: string = '');
begin
  if checkIfExists(nameService) then
  begin
    start(nameService, nameMachine);
  end;
end;

class procedure TWindowsService.start(nameService: string; nameMachine: string = '');
const
  ERR_MSG = 'Service not started.';
var
  _cont: integer;
  _handleServiceControlManager: SC_HANDLE;
  _handleService: SC_HANDLE;
  _serviceStatus: TServiceStatus;
  _exit: boolean;
  _errMsg: string;
begin
  _handleService := 0;

  _handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (_handleServiceControlManager <> 0) then
  begin
    _handleService := OpenService(_handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (_handleService <> 0) then
    begin
      if (QueryServiceStatus(_handleService, _serviceStatus)) then
      begin
        if (_serviceStatus.dwCurrentState = SERVICE_RUNNING) then
        begin
          CloseServiceHandle(_handleService);
          CloseServiceHandle(_handleServiceControlManager);
          Exit;
        end;

        if not startService(_handleService, 0, PPChar(nil)^) then
        begin
          raise Exception.Create(ERR_MSG);
          CloseServiceHandle(_handleService);
          CloseServiceHandle(_handleServiceControlManager);
          Exit;
        end;
        QueryServiceStatus(_handleService, _serviceStatus);

        //SERVICE_START_PENDING...
        _exit := false;
        _cont := 0;
        while not(_exit) do
        begin
          case _serviceStatus.dwCurrentState of
            SERVICE_RUNNING:
              _exit := true;
            SERVICE_START_PENDING:
              if (_cont >= 60) then
              begin
                _exit := true;
              end;
          else
            _exit := true;
          end;

          if not _exit then
          begin
            Sleep(3000);
            _cont := _cont + 1;
            QueryServiceStatus(_handleService, _serviceStatus);
          end;
        end;
      end;
    end;
    CloseServiceHandle(_handleService);
  end;
  CloseServiceHandle(_handleServiceControlManager);

  Sleep(500);

  if not checkIfIsRunning(nameService, nameMachine) then
  begin
    _errMsg := ERR_MSG;

    if (_handleServiceControlManager = 0) or (_handleService = 0) then
    begin
      try
        raiseLastSysErrorMessage;
      except
        on E: Exception do
        begin
          _errMsg := _errMsg + ': ' + E.Message;
        end;
      end;
    end;

    raise Exception.Create(_errMsg);
  end;
end;

class procedure TWindowsService.stopIfExists(nameService: string; nameMachine: string = ''; force: boolean = false);
begin
  if checkIfExists(nameService) then
  begin
    stop(nameService, nameMachine, force);
  end;
end;

class procedure TWindowsService.Stop(nameService: string; nameMachine: string = ''; force: boolean = false);
const
  ERR_MSG = 'Service not stopped.';
var
  _handleServiceControlManager: SC_HANDLE;
  _handleService: SC_HANDLE;
  _serviceStatus: TServiceStatus;
  _dwCheckpoint: DWORD;
  _cmdParams: string;
  _errMsg: string;
begin
  _handleService := 0;

  _handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (_handleServiceControlManager <> 0) then
  begin
    _handleService := OpenService(_handleServiceControlManager, PChar(nameService), SERVICE_STOP or SERVICE_QUERY_STATUS);
    if (_handleService <> 0) then
    begin
      if (ControlService(_handleService, SERVICE_CONTROL_STOP, _serviceStatus)) then
      begin
        if (QueryServiceStatus(_handleService, _serviceStatus)) then
        begin
          while (SERVICE_STOPPED <> _serviceStatus.dwCurrentState) do
          begin
            _dwCheckpoint := _serviceStatus.dwCheckPoint;
            Sleep(250);
            if (not QueryServiceStatus(_handleService, _serviceStatus)) then
              break;
            if (_serviceStatus.dwCheckPoint > _dwCheckpoint) then
              break;
          end;
        end;
      end;
      CloseServiceHandle(_handleService);
    end;
    CloseServiceHandle(_handleServiceControlManager);
  end;

  if (force) then
  begin
    _cmdParams := '/K taskkill /f /fi "SERVICES eq ' + nameService + '" & EXIT';
    shellExecuteExCMDAndWait(_cmdParams, RUN_AS_ADMIN);
  end;

  Sleep(500);

  if not checkIfIsStopped(nameService, nameMachine) then
  begin
    _errMsg := ERR_MSG;

    if (_handleServiceControlManager = 0) or (_handleService = 0) then
    begin
      try
        raiseLastSysErrorMessage;
      except
        on E: Exception do
        begin
          _errMsg := _errMsg + ': ' + E.Message;
        end;
      end;
    end;

    raise Exception.Create(_errMsg);
  end;
end;

class function TWindowsService.checkIfIsRunning(nameService: string; nameMachine: string = ''): boolean;
begin
  Result := checkCurrentState(RUNNING, nameService, nameMachine);
end;

class function TWindowsService.checkIfIsPaused(nameService: string; nameMachine: string = ''): boolean;
begin
  Result := checkCurrentState(PAUSED, nameService, nameMachine);
end;

class function TWindowsService.checkIfIsStopped(nameService: string; nameMachine: string = ''): boolean;
begin
  Result := checkCurrentState(STOPPPED, nameService, nameMachine);
end;

class function TWindowsService.checkCurrentState(state: TWindowsServiceState; nameService: string; nameMachine: string = ''): boolean;
var
  _result: boolean;

  _currentState: TWindowsServiceState;
begin
  validateThatServiceExists(nameService);
  _currentState := getCurrentState(nameService, nameMachine);
  _result := state = _currentState;

  Result := _result;
end;

class function TWindowsService.getCurrentState(nameService: string; nameMachine: string = ''): TWindowsServiceState;
const
  ERR_MSG = 'Cannot retrieve Windows service state.';
var
  currentState: TWindowsServiceState;

  _handleServiceControlManager: SC_HANDLE;
  _handleService: SC_HANDLE;
  _serviceStatus: TServiceStatus;
  _errMsg: string;
begin
  _handleService := 0;
  currentState := _NULL;

  _handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (_handleServiceControlManager <> 0) then
  begin
    _handleService := OpenService(_handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (_handleService <> 0) then
    begin
      if (QueryServiceStatus(_handleService, _serviceStatus)) then
      begin
        currentState := TWindowsServiceState(_serviceStatus.dwCurrentState);
      end;
    end;
    CloseServiceHandle(_handleService);
  end;
  CloseServiceHandle(_handleServiceControlManager);

  if (_handleServiceControlManager = 0) or (_handleService = 0) then
  begin
    _errMsg := ERR_MSG;
    try
      raiseLastSysErrorMessage;
    except
      on E: Exception do
      begin
        _errMsg := _errMsg + ': ' + E.Message;
      end;
    end;

    raise Exception.Create(_errMsg);
  end;

  Result := currentState;
end;

class function TWindowsService.checkIfExists(nameService: string; nameMachine: string = ''): boolean; //nameService is not case-sensitive
const
  ERR_MSG = 'Cannot check if Windows service exists.';
var
  serviceExists: boolean;

  _handleServiceControlManager: SC_HANDLE;
  _handleService: SC_HANDLE;
  _errMsg: string;
begin
{$hints OFF}
  _handleServiceControlManager := 0;
  //  _handleService := 0;
{$hints ON}
  try
    _handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
    _handleService := OpenService(_handleServiceControlManager, PChar(nameService),
      SERVICE_ALL_ACCESS);

    CloseServiceHandle(_handleService);
    CloseServiceHandle(_handleServiceControlManager);
  except
    RaiseLastOSError;
  end;
  serviceExists := GetLastError() = ERROR_SUCCESS;

  if (_handleServiceControlManager = 0) then
  begin
    _errMsg := ERR_MSG;
    try
      raiseLastSysErrorMessage;
    except
      on E: Exception do
      begin
        _errMsg := _errMsg + ': ' + E.Message;
      end;
    end;

    raise Exception.Create(_errMsg);
  end;

  Result := serviceExists;
end;

class procedure TWindowsService.setStartupTypeAsDelayedAuto(nameService: string);
begin
  setStartupType(nameService, TWindowsServiceStartupType.delayed_auto);
end;

class procedure TWindowsService.setStartupTypeAsAuto(nameService: string);
begin
  setStartupType(nameService, TWindowsServiceStartupType.auto);
end;

class procedure TWindowsService.setStartupTypeAsManual(nameService: string);
begin
  setStartupType(nameService, TWindowsServiceStartupType.manual);
end;

class procedure TWindowsService.setStartupTypeAsDisabled(nameService: string);
begin
  setStartupType(nameService, TWindowsServiceStartupType.disabled);
end;

class procedure TWindowsService.setStartupType(nameService: string; startupType: TWindowsServiceStartupType);
const
  ERR_MSG = 'Invalid startup type';
var
  _cmdParams: string;
  _startuTypeCMD: string;
begin
  validateThatServiceExists(nameService);
  case startupType of
    TWindowsServiceStartupType._null:
      raise Exception.Create(nameService + ' : ' + ERR_MSG);
    TWindowsServiceStartupType.delayed_auto:
      _startuTypeCMD := 'delayed-auto';
    TWindowsServiceStartupType.auto:
      _startuTypeCMD := 'auto';
    TWindowsServiceStartupType.manual:
      _startuTypeCMD := 'demand';
    TWindowsServiceStartupType.disabled:
      _startuTypeCMD := 'disabled';
  end;
  _cmdParams := '/K SC CONFIG ' + getDoubleQuotedString(nameService) + ' START= ' + _startuTypeCMD;
  //  shellExecuteExCMDAndWait(_cmdParams, RUN_AS_ADMIN);
  _cmdParams := 'SC CONFIG ' + getDoubleQuotedString(nameService) + ' START= ' + _startuTypeCMD;
  shellExecuteExeAsAdmin(CMD_EXE_NAME, _cmdParams);
end;

class procedure TWindowsService.delete(nameService: string);
const
  ERR_MSG = 'Unable to delete the Windows service.';
var
  _cmdParams: string;
begin
  if (checkIfExists(nameService)) then
  begin
    if checkIfIsRunning(nameService) then
    begin
      stop(nameService, '', true);
    end;
    _cmdParams := '/K SC DELETE ' + nameService + ' & EXIT';

    shellExecuteExCMDAndWait(_cmdParams, RUN_AS_ADMIN);
    if (checkIfExists(nameService)) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

end.
