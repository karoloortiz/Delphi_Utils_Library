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

unit KLib.Indy;

interface

uses
  KLib.Types, KLib.Constants, KLib.MyIdFTP,
  IdFTP, IdHTTP, IdSMTP,
  System.Classes;

procedure TCPPrintFilesInDir(hostPort: THostPort; dirName: string; fileType: string = EMPTY_STRING);
procedure TCPPrintFilesInDirWithStartingFileName(hostPort: THostPort;
  dirName: string; startingFileName: string = EMPTY_STRING; fileType: string = EMPTY_STRING);
procedure TCPPrintFromFile(hostPort: THostPort; fileName: string);
procedure TCPPrintText(hostPort: THostPort; text: string);

procedure putFtpFile(FTPCredentials: TFTPCredentials;
  sourceFileName: string; targetFileName: string; isOverwriteEnabledForced: boolean = NOT_FORCE_OVERWRITE);
function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
function getValidTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
function getTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;

procedure sendEmail(settings: TSMTPSettings; email: TEmailMessage); overload;
procedure sendEmail(smtp: TIdSMTP; email: TEmailMessage); overload;
function getIdSMTP(settings: TSMTPSettings): TIdSMTP;

function getOAuth2Response(const url: string; const clientID: string; const clientSecret: string): TOAuth2Response;
function HTTP_get(url: string; paramList: TStringList; credentials: TCredentials): string; overload;
function HTTP_get(url: string; paramList: TStringList; idHTTPRequest: TIdHTTPRequest = nil): string; overload;
function HTTP_post(url: string; paramList: TStringList; credentials: TCredentials): string; overload;
function HTTP_post(url: string; bearerToken: string; body: string; responseFileName: string = EMPTY_STRING): string; overload;
function HTTP_post(url: string; body: string; idHTTPRequest: TIdHTTPRequest = nil; responseFileName: string = EMPTY_STRING): string; overload;
function HTTP_post(url: string; paramList: TStringList; idHTTPRequest: TIdHTTPRequest = nil): string; overload;
function HTTP_delete(url: string; bearerToken: string): string; overload;
function HTTP_delete(url: string; idHTTPRequest: TIdHTTPRequest = nil): string; overload;
//USING INDY WITH SSL (E.G downloadFileWithIndy) YOU NEED libeay32.dll, libssl32.dll, ssleay32.dll
//INCLUDE RESOURCES IN YOUR PROJECT
//  RESOURCE_LIBEAY32: TResource = (name: 'LIBEAY32'; _type: DLL_TYPE);
//  RESOURCE_LIBSSL32: TResource = (name: 'LIBSSL32'; _type: DLL_TYPE);
//  RESOURCE_SSLEAY32: TResource = (name: 'SSLEAY32'; _type: DLL_TYPE);
procedure downloadZipFileAndExtract(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
procedure getOpenSSLDLLsFromResource;
procedure tryToDeleteOpenSSLDLLsIfExists;
procedure deleteOpenSSLDLLsIfExists;

function getMD5ChecksumFile(fileName: string): string;

implementation

uses
  KLib.Validate, KLib.Common, KLib.FileSystem, KLib.StringUtils, KLib.MyIdHTTP,
  KLib.StringListHelper, Klib.Windows, KLib.Generics.JSON,
  IdGlobal, IdHash, IdHashMessageDigest, IdSSLOpenSSL, IdFTPCommon, IdTCPClient,
  IdMessage, IdText, IdAttachmentFile, IdExplicitTLSClientServerBase,
  System.SysUtils, System.NetEncoding;

procedure TCPPrintFilesInDir(hostPort: THostPort; dirName: string; fileType: string = EMPTY_STRING);
begin
  TCPPrintFilesInDirWithStartingFileName(hostPort, dirName, EMPTY_STRING, fileType);
end;

procedure TCPPrintFilesInDirWithStartingFileName(hostPort: THostPort;
  dirName: string; startingFileName: string = EMPTY_STRING; fileType: string = EMPTY_STRING);
const
  IGNORE_CASE = true;
var
  _files: TStringList;
  _file: string;
  _fileName: string;
begin
  _files := getFileNamesListInDir(dirName, fileType);
  for _file in _files do
  begin
    _fileName := ExtractFileName(_file);
    if (_fileName.StartsWith(startingFileName, IGNORE_CASE)) or (startingFileName = EMPTY_STRING) then
    begin
      TCPPrintFromFile(hostPort, _file)
    end;
  end;
  FreeAndNil(_files);
end;

procedure TCPPrintFromFile(hostPort: THostPort; fileName: string);
var
  _text: string;
begin
  _text := getTextFromFile(fileName);
  TCPPrintText(hostPort, _text);
end;

procedure TCPPrintText(hostPort: THostPort; text: string);
var
  TCPClient: TIdTCPClient;
begin
  TCPClient := TIdTCPClient.Create(nil);
  with TCPClient do
  begin
    Host := hostPort.host;
    Port := hostPort.port;
  end;
  try
    TCPClient.Connect;
    TCPClient.Socket.Write(text);
    TCPClient.Disconnect;
  finally
    TCPClient.Free;
  end;
end;

procedure putFtpFile(FTPCredentials: TFTPCredentials;
  sourceFileName: string; targetFileName: string; isOverwriteEnabledForced: boolean = NOT_FORCE_OVERWRITE);
var
  _connection: TMyIdFTP;
begin
  _connection := getValidTMyIdFTP(FTPCredentials);
  try
    _connection.Connect;
    _connection.put(sourceFileName, targetFileName, isOverwriteEnabledForced);
  finally
    begin
      FreeAndNil(_connection);
    end;
  end;
end;

function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
var
  _connection: TMyIdFTP;
  _result: boolean;
begin
  _result := true;
  _connection := getTMyIdFTP(FTPCredentials);
  try
    _connection.Connect;
    if FTPCredentials.pathFTPDir <> EMPTY_STRING then
    begin
      _connection.ChangeDir(FTPCredentials.pathFTPDir);
    end;
  except
    on E: Exception do
    begin
      _result := false;
    end;
  end;
  _connection.Disconnect;
  _connection.Free;

  Result := _result;
end;

function getValidTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
var
  connection: TMyIdFTP;
begin
  validateFTPCredentials(FTPCredentials);
  connection := getTMyIdFTP(FTPCredentials);
  Result := connection;
end;

function getTMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
var
  connection: TMyIdFTP;
begin
  validateRequiredFTPProperties(FTPCredentials);
  connection := TMyIdFTP.Create(nil);
  with connection do
  begin
    Host := FTPCredentials.server;
    Username := FTPCredentials.credentials.username;
    Password := FTPCredentials.credentials.password;
    Port := FTPCredentials.port;
    TransferType := TIdFTPTransferType(FTPCredentials.transferType);
  end;

  if connection.Port = 0 then
  begin
    connection.Port := FTP_DEFAULT_PORT;
  end;

  //todo create function checkIFEnumIsInValidRange
  if (connection.transferType < Low(TIdFTPTransferType)) or (connection.transferType > High(TIdFTPTransferType)) then
  begin
    connection.transferType := ftBinary;
  end;
  connection.Passive := true;

  connection.defaultDir := FTPCredentials.pathFTPDir;

  Result := connection;
end;

procedure sendEmail(settings: TSMTPSettings; email: TEmailMessage);
var
  _smtp: TIdSMTP;
begin
  _smtp := getIdSMTP(settings);
  try
    _smtp.connect;
    sendEmail(_smtp, email);
  finally
    _smtp.disconnect;
    FreeAndNil(_smtp);
  end;
end;

procedure sendEmail(smtp: TIdSMTP; email: TEmailMessage);
var
  _mail: TIdMessage;
  _bodyPart: TIdText;
begin
  _mail := TIdMessage.Create(nil);
  try
    _mail.CharSet := 'utf-8';
    validateThatEmailIsValid(email.FromAddress);
    _mail.From.Address := email.FromAddress;
    _mail.Subject := email.Subject;

    for var i := 0 to Length(email.ToAddresses) - 1 do
    begin
      validateThatEmailIsValid(email.ToAddresses[i]);
      _mail.Recipients.Add.Address := email.ToAddresses[i];
    end;
    for var i := 0 to Length(email.CcAddresses) - 1 do
    begin
      validateThatEmailIsValid(email.CcAddresses[i]);
      _mail.CCList.Add.Address := email.CcAddresses[i];
    end;
    for var i := 0 to Length(email.BccAddresses) - 1 do
    begin
      validateThatEmailIsValid(email.BccAddresses[i]);
      _mail.BCCList.Add.Address := email.BccAddresses[i];
    end;

    _mail.ContentType := 'multipart/mixed';

    _bodyPart := TIdText.Create(_mail.MessageParts);
    case email.contentType of
      TContentType.text_plain:
        _bodyPart.ContentType := 'text/plain; charset=UTF-8';
      TContentType.text_html:
        _bodyPart.ContentType := 'text/html; charset=UTF-8';
    end;
    _bodyPart.Body.Text := email.Body + sLineBreak + email.Signature;

    for var i := 0 to Length(email.Attachments) - 1 do
    begin
      validateThatFileExists(email.Attachments[i]);
      TIdAttachmentFile.Create(_mail.MessageParts, email.Attachments[i]);
    end;
    if not smtp.Connected then
    begin
      raise Exception.Create('SMTP not connected.');
    end;

    smtp.Send(_mail);
  finally
    _mail.Free;
  end;
end;

function getIdSMTP(settings: TSMTPSettings): TIdSMTP;
var
  smtp: TIdSMTP;

  _sslHandler: TIdSSLIOHandlerSocketOpenSSL;
  //_oauth: TIdOAuth2BearerAuthenticator; todo adds oauth
begin
  smtp := TIdSMTP.Create(nil);

  _sslHandler := TIdSSLIOHandlerSocketOpenSSL.Create(smtp);
  smtp.IOHandler := _sslHandler;
  case settings.provider of
    TEmailProvider.custom:
      begin
        smtp.Host := settings.host;
        smtp.Port := settings.port;
        if (settings.useTls) then
        begin
          smtp.UseTLS := utUseExplicitTLS;
        end;
        if (not settings.useTls) then
        begin
          smtp.UseTLS := utNoTLSSupport;
        end;
      end;
    TEmailProvider.gmail:
      begin
        smtp.Host := 'smtp.gmail.com';
        smtp.Port := 587;
        smtp.UseTLS := utUseExplicitTLS;
      end;
    TEmailProvider.outlook:
      begin
        smtp.Host := 'smtp-mail.outlook.com';
        smtp.Port := 587;
        smtp.UseTLS := utUseExplicitTLS;
      end;
  end;

  _sslHandler.Host := smtp.Host;
  _sslHandler.Port := smtp.Port;
  if (settings.useTls) then
  begin
    _sslHandler.SSLOptions.Method := sslvTLSv1_2;
  end;

  if settings.accessToken <> '' then
  begin
    raise Exception.Create('Oauth not already supported');
    //_oauth := TIdOAuth2BearerAuthenticator.Create(smtp);
    //_oauth.AccessToken := settings.accessToken;
    //smtp.AuthType := satSASL;
    //smtp.SASLMechanisms.Add.SASL := _oauth;
  end
  else
  begin
    smtp.Username := settings.username;
    smtp.Password := settings.password;
    smtp.AuthType := satDefault;
  end;

  Result := smtp;
end;

function getOAuth2Response(const url: string; const clientID: string; const clientSecret: string): TOAuth2Response;
var
  OAuth2Response: TOAuth2Response;
  _response: string;
  _authHeader: string;
  _idHTTPRequest: TIdHTTPRequest;
  _params: TStringList;
begin
  _idHTTPRequest := TIdHTTPRequest.Create(nil);
  _authHeader := 'Basic ' + TNetEncoding.Base64.Encode(clientID + ':' + clientSecret).Replace(#13#10, '');
  _idHTTPRequest.CustomHeaders.Add('Authorization: ' + _authHeader);
  _idHTTPRequest.ContentType := 'application/x-www-form-urlencoded';

  _params := TStringList.Create();
  _params.Add('grant_type=client_credentials');
  try
    _response := HTTP_post(url, _params, _idHTTPRequest);
    OAuth2Response := TJSONGenerics.getParsedJSON<TOAuth2Response>(_response);
  finally
    FreeAndNil(_idHTTPRequest);
    FreeAndNil(_params);
  end;

  Result := OAuth2Response;
end;

function HTTP_get(url: string; paramList: TStringList; credentials: TCredentials): string;
var
  HTTP_response: string;
  _idHTTPRequest: TIdHTTPRequest;
begin
  _idHTTPRequest := TIdHTTPRequest.Create(nil);
  try
    if (not credentials.isEmpty()) then
    begin
      with _idHTTPRequest do
      begin
        BasicAuthentication := true;
        Username := credentials.username;
        Password := credentials.password;
      end;
    end;
    HTTP_response := HTTP_get(url, paramList, _idHTTPRequest);
  finally
    FreeAndNil(_idHTTPRequest);
  end;

  Result := HTTP_response;
end;

function HTTP_get(url: string; paramList: TStringList; idHTTPRequest: TIdHTTPRequest = nil): string;
var
  HTTP_response: string;
  _HTTP: TMyIdHTTP;
  _url: string;
begin
  _HTTP := TMyIdHTTP.Create(nil);

  if Assigned(idHTTPRequest) then
  begin
    _HTTP.Request := idHTTPRequest;
  end;

  _url := getHTTPGetEncodedUrl(url, paramList);
  try
    HTTP_response := _HTTP.Get(_url);
  finally
    _HTTP.Free;
  end;

  Result := HTTP_response;
end;

function HTTP_post(url: string; paramList: TStringList; credentials: TCredentials): string;
var
  HTTP_response: string;
  _idHTTPRequest: TIdHTTPRequest;
begin
  _idHTTPRequest := TIdHTTPRequest.Create(nil);
  try
    if (not credentials.isEmpty()) then
    begin
      with _idHTTPRequest do
      begin
        BasicAuthentication := true;
        Username := credentials.username;
        Password := credentials.password;
      end;
    end;
    HTTP_response := HTTP_post(url, paramList, _idHTTPRequest);
  finally
    FreeAndNil(_idHTTPRequest);
  end;

  Result := HTTP_response;
end;

function HTTP_post(url: string; bearerToken: string; body: string; responseFileName: string = EMPTY_STRING): string;
var
  HTTPResponse: string;

  _idHTTPRequest: TIdHTTPRequest;
begin

  _idHTTPRequest := TIdHTTPRequest.Create(nil);
  try
    _idHTTPRequest.CustomHeaders.AddValue('Authorization', 'Bearer ' + bearerToken);
    _idHTTPRequest.ContentType := 'application/json';

    HTTPResponse := HTTP_post(url, body, _idHTTPRequest, responseFileName);
  finally
    FreeAndNil(_idHTTPRequest);
  end;

  Result := HTTPResponse;
end;

function HTTP_post(url: string; body: string; idHTTPRequest: TIdHTTPRequest = nil;
  responseFileName: string = EMPTY_STRING): string;
var
  HTTP_response: string;

  _HTTP: TMyIdHTTP;
  _requestStream: TStringStream;
  _responseStream: TStringStream;
begin
  _HTTP := TMyIdHTTP.Create(nil);
  _responseStream := TStringStream.Create('', TEncoding.UTF8);
  try
    if Assigned(idHTTPRequest) then
    begin
      _HTTP.Request := idHTTPRequest;
    end;

    _requestStream := TStringStream.Create(body, TEncoding.UTF8);
    try
      _HTTP.Post(url, _requestStream, _responseStream);
      HTTP_response := _responseStream.DataString;
    finally
      _requestStream.Free;
    end;
  finally
    _HTTP.Free;
    _responseStream.Free;
  end;

  if (responseFileName <> EMPTY_STRING) then
  begin
    saveToFile(HTTP_response, responseFileName);
  end;

  Result := HTTP_response;
end;

function HTTP_post(url: string; paramList: TStringList; idHTTPRequest: TIdHTTPRequest = nil): string;
var
  HTTP_response: string;
  _HTTP: TMyIdHTTP;
begin
  _HTTP := TMyIdHTTP.Create(nil);

  if Assigned(idHTTPRequest) then
  begin
    _HTTP.Request := idHTTPRequest;
  end;

  try
    HTTP_response := _HTTP.Post(url, paramList);
  finally
    _HTTP.Free;
  end;

  Result := HTTP_response;
end;

function HTTP_delete(url: string; bearerToken: string): string;
var
  response: string;
  _idHTTPRequest: TIdHTTPRequest;
begin
  _idHTTPRequest := TIdHTTPRequest.Create(nil);
  _idHTTPRequest.CustomHeaders.Add('Authorization: Bearer ' + bearerToken);
  response := HTTP_delete(url, _idHTTPRequest);

  Result := response;
end;

function HTTP_delete(url: string; idHTTPRequest: TIdHTTPRequest = nil): string;
var
  HTTP_response: string;
  _HTTP: TMyIdHTTP;
begin
  _HTTP := TMyIdHTTP.Create(nil);

  if Assigned(idHTTPRequest) then
  begin
    _HTTP.Request := idHTTPRequest;
  end;

  try
    HTTP_response := _HTTP.Delete(url);
  finally
    _HTTP.Free;
  end;

  Result := HTTP_response;
end;

//USING INDY YOU NEED libeay32.dll AND libssl32.dll
procedure downloadZipFileAndExtract(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
var
  _ZipFileName: string;
begin
  downloadFile(info, forceOverwrite);
  _ZipFileName := getCombinedPath(destinationPath, info.fileName);
  unzip(_ZipFileName, destinationPath, forceDeleteZipFile);
end;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
const
  ERR_MSG = 'Error downloading file.';
var
  _downloadSuccess: boolean;
  _HTTP: TMyIdHTTP;
  _memoryStream: TMemoryStream;
  _links: TStringList;
  i: integer;
begin
  if forceOverwrite then
  begin
    deleteFileIfExists(info.fileName);
  end;

  _downloadSuccess := false;
  i := 0;
  _HTTP := TMyIdHTTP.Create(nil);
  _memoryStream := TMemoryStream.Create;
  _links := TStringList.Create;
  _links.Add(info.link);
  _links.AddStrings(info.alternative_links);
  try
    while (not _downloadSuccess) and (i < _links.Count) do
    begin
      try
        _HTTP.Get(_links[i], _memoryStream);
        _downloadSuccess := true;
      except
        on E: Exception do
        begin
          _memoryStream.Clear;
        end;
      end;
      Inc(i);
    end;

    if not _downloadSuccess then
    begin
      raise Exception.Create(ERR_MSG);
    end;

    _memoryStream.SaveToFile(info.fileName);
  finally
    _HTTP.Free;
    FreeAndNil(_memoryStream);
    FreeAndNil(_links);
  end;

  if info.MD5 <> '' then
  begin
    validateMD5File(info.fileName, info.MD5, ERR_MSG);
  end;
end;

const
  RESOURCE_LIBEAY32: TResource = (name: 'LIBEAY32'; _type: DLL_TYPE);
  RESOURCE_LIBSSL32: TResource = (name: 'LIBSSL32'; _type: DLL_TYPE);
  RESOURCE_SSLEAY32: TResource = (name: 'SSLEAY32'; _type: DLL_TYPE);
  FILENAME_LIBSSL32 = 'libssl32.dll';
  FILENAME_LIBEAY32 = 'libeay32.dll';
  FILENAME_SSLEAY32 = 'ssleay32.dll';

procedure getOpenSSLDLLsFromResource;
var
  _path_libeay32: string;
  _path_libssl32: string;
  _path_ssleay32: string;
begin
  _path_libeay32 := getCombinedPathWithCurrentDir(FILENAME_LIBEAY32);
  if not checkIfFileExists(_path_libeay32) then
  begin
    getResourceAsFile(RESOURCE_LIBEAY32, _path_libeay32);
  end;
  _path_libssl32 := getCombinedPathWithCurrentDir(FILENAME_LIBSSL32);
  if not checkIfFileExists(_path_libssl32) then
  begin
    getResourceAsFile(RESOURCE_LIBSSL32, _path_libssl32);
  end;
  _path_ssleay32 := getCombinedPathWithCurrentDir(FILENAME_SSLEAY32);
  if not checkIfFileExists(_path_ssleay32) then
  begin
    getResourceAsFile(RESOURCE_SSLEAY32, _path_ssleay32);
  end;
end;

procedure tryToDeleteOpenSSLDLLsIfExists;
begin
  tryToExecuteProcedure(deleteOpenSSLDLLsIfExists);
end;

procedure deleteOpenSSLDLLsIfExists;
var
  _path_libeay32: string;
  _path_libssl32: string;
  _path_ssleay32: string;
begin
  UnLoadOpenSSLLibrary;

  _path_libeay32 := getCombinedPathWithCurrentDir(FILENAME_LIBEAY32);
  deleteFileIfExists(_path_libeay32);
  _path_libssl32 := getCombinedPathWithCurrentDir(FILENAME_LIBSSL32);
  deleteFileIfExists(_path_libssl32);
  _path_ssleay32 := getCombinedPathWithCurrentDir(FILENAME_SSLEAY32);
  deleteFileIfExists(_path_ssleay32);
end;

function getMD5ChecksumFile(fileName: string): string;
var
  MD5: string;
  _IdHashMessageDigest: TIdHashMessageDigest5;
  _fileStream: TFileStream;
begin
  validateThatFileExists(fileName);

  _IdHashMessageDigest := TIdHashMessageDigest5.Create;
  _fileStream := TFileStream.Create(fileName, fmOpenRead or fmShareDenyWrite);
  try
    MD5 := _IdHashMessageDigest.HashStreamAsHex(_fileStream);
  finally
    begin
      _fileStream.Free;
      _IdHashMessageDigest.Free;
    end;
  end;

  Result := MD5;
end;

end.
