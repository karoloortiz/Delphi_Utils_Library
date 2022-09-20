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

unit KLib.ServiceApp.HttpServerAdapter;

interface

uses
  KLib.ServiceAppPort, KLib.Types, KLib.MyIdHTTPServer,
  Winapi.Messages,
  System.Classes;

type
  TMyOnCommandGetAnonymousMethod = KLib.MyIdHTTPServer.TMyOnCommandGetAnonymousMethod;
  TIdContext = KLib.MyIdHTTPServer.TIdContext;
  TIdHTTPRequestInfo = KLib.MyIdHTTPServer.TIdHTTPRequestInfo;
  TIdHTTPResponseInfo = KLib.MyIdHTTPServer.TIdHTTPResponseInfo;

  THttpServerAdapter = class(TInterfacedObject, IServiceAppPort)
  private
    _handle: THandle;
    procedure WndMethod(var Msg: TMessage);
  protected
    rejectCallBack: TCallBack;
  public
    _server: TMyIdHTTPServer;

    constructor Create(myOnCommandGetAnonymousMethod: TMyOnCommandGetAnonymousMethod; port: integer;
      rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil); overload;
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
  KLib.Constants, KLib.Utils,
  Winapi.Windows,
  System.SysUtils;

constructor THttpServerAdapter.Create(myOnCommandGetAnonymousMethod: TMyOnCommandGetAnonymousMethod; port: integer;
  rejectCallBack: TCallBack; onChangeStatus: TCallBack = nil);
begin
  Self.rejectCallBack := rejectCallBack;
  _server := TMyIdHTTPServer.Create(myOnCommandGetAnonymousMethod, port, rejectCallBack, onChangeStatus);
  _handle := AllocateHWnd(WndMethod);
end;

procedure THttpServerAdapter.start;
begin
  _server.Alisten;
end;

procedure THttpServerAdapter.pause;
begin
  _server.stop;
end;

procedure THttpServerAdapter.resume;
begin
  _server.Alisten;
end;

procedure THttpServerAdapter.stop;
begin
  _server.stop;
end;

procedure THttpServerAdapter.restart;
begin
  _server.stop(RAISE_EXCEPTION_DISABLED);
  _server.Alisten;
end;

procedure THttpServerAdapter.waitUntilIsRunning;
begin
  Sleep(INFINITE); //better beacuse not use mainThread
  //  _server.waitUntilIsRunning;
end;

function THttpServerAdapter.getStatus: TStatus;
begin
  Result := _server.status;
end;

function THttpServerAdapter.getHandle: integer;
begin
  Result := _handle;
end;

procedure THttpServerAdapter.WndMethod(var Msg: TMessage);
begin
  Msg.Result := DefWindowProc(_handle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

destructor THttpServerAdapter.Destroy;
begin
  FreeAndNil(_server);
  DeallocateHWnd(_handle);
  inherited;
end;

end.
