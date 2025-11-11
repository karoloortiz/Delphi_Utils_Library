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

unit KLib.ServiceApp.HttpServerAdapter;

interface

uses
  KLib.ServiceAppPort, KLib.Types, KLib.MyIdHTTPServer, KLib.Constants,
  Winapi.Messages,
  System.Classes;

type
  TIdContext = KLib.MyIdHTTPServer.TIdContext;
  TMyIdHTTPRequestInfo = KLib.MyIdHTTPServer.TIdHTTPRequestInfo;
  TMyIdHTTPResponseInfo = KLib.MyIdHTTPServer.TIdHTTPResponseInfo;

  THttpServerAdapter = class(TInterfacedObject, IServiceAppPort)
  private
    _handle: THandle;
    procedure WndMethod(var Msg: TMessage);
    function _get_defaultServerErrorJSONResponse: string;
    procedure _set_defaultServerErrorJSONResponse(value: string);
  protected
    function getRejectCallBack: TCallBack;
    procedure setRejectCallBack(value: TCallBack);
    function getOnChangeStatus(): TOnChangeStatus;
    procedure setOnChangeStatus(value: TOnChangeStatus);

    property defaultServerErrorJSONResponse: string read _get_defaultServerErrorJSONResponse write _set_defaultServerErrorJSONResponse;
  public
    httpServer: TMyIdHTTPServer;

    property rejectCallBack: TCallBack read getRejectCallBack write setRejectCallBack;
    property onChangeStatus: TOnChangeStatus read getOnChangeStatus write setOnChangeStatus;

    constructor Create(port: integer;
      rejectCallBack: TCallBack; defaultServerErrorJSONResponse: string = EMPTY_STRING; onChangeStatus: TOnChangeStatus = nil); overload;
    constructor Create(httpServer: TMyIdHTTPServer); overload;
    constructor Create(); overload;

    procedure start; virtual;
    procedure pause; virtual;
    procedure resume; virtual;
    procedure stop; virtual;
    procedure restart; virtual;

    procedure waitUntilIsRunning; virtual;

    function getStatus: TStatus; virtual;
    function getHandle: integer; virtual;

    destructor Destroy; override;
  end;

implementation

uses
  KLib.Common,
  Winapi.Windows,
  System.SysUtils;

constructor THttpServerAdapter.Create(port: integer;
  rejectCallBack: TCallBack; defaultServerErrorJSONResponse: string = EMPTY_STRING; onChangeStatus: TOnChangeStatus = nil);
begin
  create();
  httpServer := TMyIdHTTPServer.Create(port, rejectCallBack, defaultServerErrorJSONResponse,
    onChangeStatus);
end;

constructor THttpServerAdapter.Create(httpServer: TMyIdHTTPServer);
begin
  create();
  Self.httpServer := httpServer;
end;

constructor THttpServerAdapter.Create();
begin
  Self._handle := AllocateHWnd(WndMethod);
end;

procedure THttpServerAdapter.start;
begin
  httpServer.listenAsync();
end;

procedure THttpServerAdapter.pause;
begin
  httpServer.stop;
end;

procedure THttpServerAdapter.resume;
begin
  httpServer.listenAsync();
end;

procedure THttpServerAdapter.stop;
begin
  httpServer.stop;
end;

procedure THttpServerAdapter.restart;
begin
  httpServer.stop();
  httpServer.listenAsync();
end;

procedure THttpServerAdapter.waitUntilIsRunning;
begin
  Sleep(INFINITE); //better because not use mainThread
  //  _server.waitUntilIsRunning;
end;

function THttpServerAdapter.getStatus: TStatus;
begin
  Result := httpServer.status;
end;

function THttpServerAdapter.getHandle: integer;
begin
  Result := _handle;
end;

procedure THttpServerAdapter.WndMethod(var Msg: TMessage);
begin
  Msg.Result := DefWindowProc(_handle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

function THttpServerAdapter._get_defaultServerErrorJSONResponse: string;
begin
  Result := httpServer.defaultServerErrorJSONResponse;
end;

procedure THttpServerAdapter._set_defaultServerErrorJSONResponse(value: string);
begin
  httpServer.defaultServerErrorJSONResponse := value;
end;

function THttpServerAdapter.getRejectCallBack: TCallBack;
begin
  Result := httpServer.rejectCallback;
end;

procedure THttpServerAdapter.setRejectCallBack(value: TCallBack);
begin
  httpServer.rejectCallback := value;
end;

function THttpServerAdapter.getOnChangeStatus(): TOnChangeStatus;
begin
  Result := httpServer.onChangeStatus;
end;

procedure THttpServerAdapter.setOnChangeStatus(value: TOnChangeStatus);
begin
  httpServer.onChangeStatus := value;
end;

destructor THttpServerAdapter.Destroy;
begin
  FreeAndNil(httpServer);
  DeallocateHWnd(_handle);
  inherited;
end;

end.
