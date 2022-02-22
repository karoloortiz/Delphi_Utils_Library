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
