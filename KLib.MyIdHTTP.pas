unit KLib.MyIdHTTP;

interface

uses
  IdHttp, IdSSLOpenSSLHeaders, IdSSLOpenSSL, IdCTypes,
  System.Classes;

type
  TMyIdHTTP = class(TIdHTTP)
  public
    constructor Create(AOwner: TComponent);
  private
    procedure OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL; const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
  end;

implementation

constructor TMyIdHTTP.Create(AOwner: TComponent);
begin
  IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  with IOHandler as TIdSSLIOHandlerSocketOpenSSL do
  begin
    OnStatusInfoEx := Self.OnStatusInfoEx;
    SSLOptions.Method := sslvSSLv23;
    SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_1, sslvTLSv1];
  end;
  inherited Create(AOwner);
end;

procedure TMyIdHTTP.OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
begin
  SSL_set_tlsext_host_name(AsslSocket, Request.Host);
end;

end.
