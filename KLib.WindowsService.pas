{
  KLib Version = 1.0
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
  Winapi.Messages;

const
  WM_SERVICE_START = WM_USER + 0;
  WM_SERVICE_ERROR = WM_USER + 2;

type
  TWindowsService = class //nameService is not case-sensitive
  public
    //    class procedure createService: boolean; //TODO IMPLEMENTE CODE
    class procedure aStart(handleSender: THandle; nameService: string; nameMachine: string = '');
    class procedure startIfExists(nameService: string; nameMachine: string = '');
    class procedure start(nameService: string; nameMachine: string = '');
    class procedure stopIfExists(nameService: string; nameMachine: string = '';
      force: boolean = false);
    class procedure stop(nameService: string; nameMachine: string = '';
      force: boolean = false);
    class function checkIfIsRunning(nameService: string; nameMachine: string = ''): boolean;
    class function checkIfExists(nameService: string; nameMachine: string = ''): boolean;
    class procedure delete(nameService: string);
  end;

implementation

uses
  KLib.Windows, KLib.Constants,
  Winapi.Windows, Winapi.Winsvc,
  System.Classes, System.SysUtils;

class procedure TWindowsService.aStart(handleSender: THandle; nameService: string;
  nameMachine: string = '');
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
  cont: integer;
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;

  _exit: boolean;
begin
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (QueryServiceStatus(handleService, serviceStatus)) then
      begin
        if (serviceStatus.dwCurrentState = SERVICE_RUNNING) then
        begin
          CloseServiceHandle(handleService);
          CloseServiceHandle(handleServiceControlManager);
          Exit;
        end;

        if not startService(handleService, 0, PPChar(nil)^) then
        begin
          raise Exception.Create(ERR_MSG);
          CloseServiceHandle(handleService);
          CloseServiceHandle(handleServiceControlManager);
          Exit;
        end;
        QueryServiceStatus(handleService, serviceStatus);

        //SERVICE_START_PENDING...
        _exit := false;
        cont := 0;
        while not(_exit) do
        begin
          case serviceStatus.dwCurrentState of
            SERVICE_RUNNING:
              _exit := true;
            SERVICE_START_PENDING:
              if (cont >= 60) then
              begin
                _exit := true;
              end;
          else
            _exit := true;
          end;

          if not _exit then
          begin
            Sleep(3000);
            cont := cont + 1;
            QueryServiceStatus(handleService, serviceStatus);
          end;
        end;
      end;
    end;
    QueryServiceStatus(handleService, serviceStatus);
    if not(serviceStatus.dwCurrentState = SERVICE_RUNNING) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
    CloseServiceHandle(handleService);
  end;
  CloseServiceHandle(handleServiceControlManager);
end;

class procedure TWindowsService.stopIfExists(nameService: string; nameMachine: string = '';
force: boolean = false);
begin
  if checkIfExists(nameService) then
  begin
    stop(nameService, nameMachine, force);
  end;
end;

class procedure TWindowsService.Stop(nameService: string; nameMachine: string = '';
force: boolean = false);
const
  ERR_MSG = 'Service not stopped.';
var
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
  dwCheckpoint: DWord;
  _cmdParams: string;
begin
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_STOP or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (ControlService(handleService, SERVICE_CONTROL_STOP, serviceStatus)) then
      begin
        if (QueryServiceStatus(handleService, serviceStatus)) then
        begin
          while (SERVICE_STOPPED <> serviceStatus.dwCurrentState) do
          begin
            dwCheckpoint := serviceStatus.dwCheckPoint;
            Sleep(250);
            if (not QueryServiceStatus(handleService, serviceStatus)) then
              break;
            if (serviceStatus.dwCheckPoint > dwCheckpoint) then
              break;
          end;
        end;
      end
      else
      begin
        if (force) then
        begin
          _cmdParams := '/K taskkill /f /fi "SERVICES eq ' + nameService + '" & EXIT';
          shellExecuteExCMDAndWait(_cmdParams, RUN_AS_ADMIN);
        end;
      end;
      QueryServiceStatus(handleService, serviceStatus);
      CloseServiceHandle(handleService);
    end;
    CloseServiceHandle(handleService);
  end;
  if not(serviceStatus.dwCurrentState = SERVICE_STOPPED) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
end;

class function TWindowsService.checkIfIsRunning(nameService: string; nameMachine: string = ''): boolean;
var
  handleServiceControlManager: SC_HANDLE;
  handleService: SC_HANDLE;
  serviceStatus: TServiceStatus;
begin
  result := false;
  handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
  if (handleServiceControlManager > 0) then
  begin
    handleService := OpenService(handleServiceControlManager, PChar(nameService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (handleService > 0) then
    begin
      if (QueryServiceStatus(handleService, serviceStatus)) then
      begin
        if (serviceStatus.dwCurrentState = SERVICE_RUNNING) then
        begin
          Result := True;
        end;
      end;
    end;
    CloseServiceHandle(handleService);
  end;
  CloseServiceHandle(handleServiceControlManager);
end;

class function TWindowsService.checkIfExists(nameService: string; nameMachine: string = ''): boolean; //nameService is not case-sensitive
var
  _result: boolean;
  _handleServiceControlManager: SC_HANDLE;
  _handleService: SC_HANDLE;
begin
  try
    _handleServiceControlManager := OpenSCManager(PChar(nameMachine), nil, SC_MANAGER_CONNECT);
    _handleService := OpenService(_handleServiceControlManager, PChar(nameService),
      SERVICE_ALL_ACCESS);

    CloseServiceHandle(_handleService);
    CloseServiceHandle(_handleServiceControlManager);
  except
    RaiseLastOSError;
  end;
  _result := GetLastError() = ERROR_SUCCESS;

  Result := _result;
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
