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

//##############---EXAMPLE OF USE---############
//var
//  _server: TMyIdHTTPServer;
//  _myOnGetAnonymousMethod: TMyOnCommandGetAnonymousMethod;
//begin
//  _myOnGetAnonymousMethod := procedure(var AContext: TIdContext; var ARequestInfo: TIdHTTPRequestInfo; var AResponseInfo: TIdHTTPResponseInfo)
//    begin
//      AResponseInfo.ResponseNo := 200;
//      AResponseInfo.ContentType := 'application/json';
//      AResponseInfo.ContentText := '{"_timestamp":"2017-07-03 08:34:17","_error":""}';
//    end;
//
//  _server := TMyIdHTTPServer.Create(_myOnGetAnonymousMethod, 8000);
//  _server.listen();
//########################################################

unit KLib.MyIdHTTPServer;

interface

uses
  KLib.MyEvent, KLib.Types,
  IdHTTPServer, IdContext, IdCustomHTTPServer;

type

  TIdContext = IdContext.TIdContext;
  TIdHTTPRequestInfo = IdCustomHTTPServer.TIdHTTPRequestInfo;
  TIdHTTPResponseInfo = IdCustomHTTPServer.TIdHTTPResponseInfo;

  TMyOnCommandGetAnonymousMethod =
    reference to procedure(var AContext: TIdContext; var ARequestInfo: TIdHTTPRequestInfo; var AResponseInfo: TIdHTTPResponseInfo);

  TMyIdHTTPServer = class(TIdHTTPServer)
  private
    _myOnCommandGetAnonymousMethod: TMyOnCommandGetAnonymousMethod;
    _isRunningEvent: TMyEvent;
    function _get_isRunning: boolean;
    procedure _set_status(value: TStatus);
  protected
    _status: TStatus;
    procedure _listen(asyncMode: boolean; port: integer = 0);
    procedure myOnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    onChangeStatus: TCallBack;
    property status: TStatus read _status write _set_status;

    constructor create(myOnCommandGetAnonymousMethod: TMyOnCommandGetAnonymousMethod; port: integer = 0;
      onChangeStatus: TCallBack = nil); overload;
    procedure Alisten(port: integer = 0);
    procedure listen(port: integer = 0);
    procedure stop(raiseExceptionEnabled: boolean = true);
    property isRunning: boolean read _get_isRunning;

    destructor Destroy; override;
  end;

implementation

uses
  KLib.Validate, KLib.Utils,
  System.SysUtils;

constructor TMyIdHTTPServer.create(myOnCommandGetAnonymousMethod: TMyOnCommandGetAnonymousMethod; port: integer = 0;
  onChangeStatus: TCallBack = nil);
begin
  inherited Create(nil);
  Self._myOnCommandGetAnonymousMethod := myOnCommandGetAnonymousMethod;
  Self.DefaultPort := port;
  Self.onChangeStatus := onChangeStatus;

  Self.OnCommandGet := Self.myOnCommandGet;
  Self._isRunningEvent := TMyEvent.Create;

  Self.status := TStatus.created;
end;

procedure TMyIdHTTPServer.Alisten(port: integer = 0);
begin
  _listen(true, port);
end;

procedure TMyIdHTTPServer.listen(port: integer = 0);
begin
  _listen(false, port);
end;

procedure TMyIdHTTPServer._listen(asyncMode: boolean; port: integer = 0);
const
  ERR_MSG = 'Port not assigned.';
begin
  //  Self.DefaultPort := port;
  //  _server.Active := True;

  //  inherited;
  //  if FPort <= 0 then
  //    FPort := GetDefaultPort;
  if (Self.DefaultPort = 0) and (port = 0) then
  begin
    raise Exception.Create(ERR_MSG);
  end
  else if (Self.DefaultPort = 0) then
  begin
    Self.DefaultPort := port; //todo check if port is open
  end;

  validateThatPortIsAvaliable(Self.DefaultPort);

  //  if FHost.IsEmpty then
  //    FHost := GetDefaultHost;

  //  LIdHTTPWebBrokerBridge := GetDefaultHTTPWebBroker;
  //  WebRequestHandler.WebModuleClass := WebModuleClass;
  //  try
  //    if FMaxConnections > 0 then
  //    begin
  //      WebRequestHandler.MaxConnections := FMaxConnections;
  //      GetDefaultHTTPWebBroker.MaxConnections := FMaxConnections;
  //    end;

  //    if FListenQueue = 0 then
  //      FListenQueue := IdListenQueueDefault;

  //    if FHorseProviderIOHandleSSL <> nil then
  //      InitServerIOHandlerSSLOpenSSL(LIdHTTPWebBrokerBridge, GetDefaultHorseProviderIOHandleSSL);
  //    LIdHTTPWebBrokerBridge.ListenQueue := FListenQueue;

  Self.Bindings.Clear;
  Self.Bindings.Add;
  Self.Bindings.Items[0].Port := Self.DefaultPort;
  Self.KeepAlive := true;
  Self.Active := true;
  Self.StartListening;
  _isRunningEvent.enable;
  Self.status := TStatus.running;
  //  LIdHTTPWebBrokerBridge.Bindings.Clear;
  //  if FHost <> GetDefaultHost then
  //  begin
  //    LIdHTTPWebBrokerBridge.Bindings.Add;
  //    //      LIdHTTPWebBrokerBridge.Bindings.Items[0].IP := FHost;
  //    LIdHTTPWebBrokerBridge.Bindings.Items[0].Port := FPort;
  //  end;

  //    LIdHTTPWebBrokerBridge.KeepAlive := FKeepConnectionAlive;
  //    LIdHTTPWebBrokerBridge.DefaultPort := FPort;
  //    LIdHTTPWebBrokerBridge.Active := True;
  //    LIdHTTPWebBrokerBridge.StartListening;
  //    FRunning := True;
  //    DoOnListen;

  //    if IsConsole then
  //    begin
  if not asyncMode then
  begin
    while isRunning do
    begin
      _isRunningEvent.WaitFor();
    end;
  end;
  //    end
  //  except
  //    on E: Exception do
  //    begin
  //      if IsConsole then
  //      begin
  //        Writeln(E.ClassName, ': ', E.Message);
  //        Read(LAttach);
  //      end
  //      else
  //{$if CompilerVersion >= 32.0}
  //        raise AcquireExceptionObject;
  //{$else}
  //        raise;
  //{$endif}
  //    end;
  //  end;
end;

procedure TMyIdHTTPServer.stop(raiseExceptionEnabled: boolean = true);
const
  ERR_MSG = 'Server doesn''t running.';
begin
  if isRunning then
  begin
    Self.StopListening;
    Self.Active := False;
    _isRunningEvent.disable;
    Self.status := TStatus.stopped;
  end
  else if raiseExceptionEnabled then
  begin
    raise Exception.Create(ERR_MSG);
  end;
end;

procedure TMyIdHTTPServer.myOnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  if Assigned(_myOnCommandGetAnonymousMethod) then
  begin
    _myOnCommandGetAnonymousMethod(AContext, ARequestInfo, AResponseInfo);
  end;
end;

procedure TMyIdHTTPServer._set_status(value: TStatus);
begin
  _status := value;
  if Assigned(onChangeStatus) then
  begin
    onChangeStatus(get_status_asString(_status));
  end;
end;

function TMyIdHTTPServer._get_isRunning: boolean;
begin
  Result := _isRunningEvent.value;
end;

destructor TMyIdHTTPServer.Destroy;
begin
  FreeAndNil(_isRunningEvent);
  inherited;
end;

end.
