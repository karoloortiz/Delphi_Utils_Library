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

unit KLib.MyIdHTTP;

interface

uses
  IdHttp, IdSSLOpenSSLHeaders, IdSSLOpenSSL, IdCTypes,
  System.Classes;

type
  TMyIdHTTP = class(TIdHTTP)
  private
    procedure OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL; const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  end;

implementation

constructor TMyIdHTTP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  with IOHandler as TIdSSLIOHandlerSocketOpenSSL do
  begin
    OnStatusInfoEx := Self.OnStatusInfoEx;
    SSLOptions.Method := sslvSSLv23;
    SSLOptions.SSLVersions := [
      TIdSSLVersion.sslvTLSv1, TIdSSLVersion.sslvTLSv1_1, TIdSSLVersion.sslvTLSv1_2,
      TIdSSLVersion.sslvSSLv2, TIdSSLVersion.sslvSSLv23,
      TIdSSLVersion.sslvSSLv3];
  end;

  HandleRedirects := true;

  HTTPOptions := HTTPOptions + [hoNoProtocolErrorException, hoWantProtocolErrorContent];
end;

procedure TMyIdHTTP.OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
begin
  SSL_set_tlsext_host_name(AsslSocket, Request.Host);
end;

destructor TMyIdHTTP.Destroy;
begin
  IOHandler.Free;
  inherited;
end;

end.
