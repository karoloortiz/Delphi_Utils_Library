unit KLib.Indy;

interface

uses
  KLib.Types, KLib.Constants,
  IdFTP,
  System.Classes;

procedure TCPPrintFilesInDir(hostPort: THostPort; dirName: string; fileType: string = EMPTY_STRING);
procedure TCPPrintFilesInDirWithStartingFileName(hostPort: THostPort;
  dirName: string; startingFileName: string = EMPTY_STRING; fileType: string = EMPTY_STRING);
procedure TCPPrintFromFile(hostPort: THostPort; fileName: string);
procedure TCPPrintText(hostPort: THostPort; text: string);

function getValidIdFTP(FTPCredentials: TFTPCredentials): TIdFTP;
function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
function getIdFTP(FTPCredentials: TFTPCredentials): TIdFTP;

function HTTP_post(url: string; paramList: TStringList): string;
//USING INDY WITH SSL (E.G downloadFileWithIndy) YOU NEED libeay32.dll, libssl32.dll, ssleay32.dll
//INCLUDE RESOURCES IN YOUR PROJECT
//  RESOURCE_LIBEAY32: TResource = (name: 'LIBEAY32'; _type: DLL_TYPE);
//  RESOURCE_LIBSSL32: TResource = (name: 'LIBSSL32'; _type: DLL_TYPE);
//  RESOURCE_SSLEAY32: TResource = (name: 'SSLEAY32'; _type: DLL_TYPE);
procedure downloadZipFileAndExtract(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
procedure getOpenSSLDLLsFromResource;
procedure deleteOpenSSLDLLsIfExists;

function getMD5ChecksumFile(fileName: string): string;

implementation

uses
  KLib.Validate, KLib.Utils,
  IdGlobal, IdHash, IdHashMessageDigest, IdHTTP, IdSSLOpenSSL, IdFTPCommon, IdTCPClient,
  System.SysUtils;

procedure TCPPrintFilesInDir(hostPort: THostPort; dirName: string; fileType: string = EMPTY_STRING);
begin
  TCPPrintFilesInDirWithStartingFileName(hostPort, dirName, fileType);
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
    if _fileName.StartsWith(startingFileName, IGNORE_CASE) then
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

function getValidIdFTP(FTPCredentials: TFTPCredentials): TIdFTP;
var
  connection: TIdFTP;
begin
  validateFTPCredentials(FTPCredentials);
  connection := getIdFTP(FTPCredentials);
  Result := connection;
end;

function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
var
  _connection: TIdFTP;
  _result: boolean;
begin
  _result := true;
  _connection := getIdFTP(FTPCredentials);
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

function getIdFTP(FTPCredentials: TFTPCredentials): TIdFTP;
var
  connection: TIdFTP;
begin
  validateRequiredFTPProperties(FTPCredentials);
  connection := TIdFTP.Create(nil);
  with FTPCredentials do
  begin
    connection.host := server;
    with credentials do
    begin
      connection.username := username;
      connection.password := password;
    end;
    connection.TransferType := TIdFTPTransferType(transferType);
  end;

  //todo create function checkIFEnumIsInValidRange
  if (connection.transferType < Low(TIdFTPTransferType)) or (connection.transferType > High(TIdFTPTransferType)) then
  begin
    connection.transferType := ftBinary;
  end;
  connection.Passive := true;
  Result := connection;
end;

function HTTP_post(url: string; paramList: TStringList): string;
var
  HTTP_response: string;
  _HTTP: TIdHTTP;
begin
  _HTTP := TIdHTTP.Create;
  try
    HTTP_response := _HTTP.Post(url, paramList);
  finally
    _HTTP.Free;
  end;

  Result := HTTP_response;
end;

//USING INDY YOU NEED libeay32.dll AND libssl32.dll
procedure downloadZipFileAndExtract(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
var
  pathZipFile: string;
begin
  downloadFile(info, forceOverwrite);
  pathZipFile := getCombinedPath(destinationPath, info.fileName);
  unzip(pathZipFile, destinationPath, forceDeleteZipFile);
end;

procedure downloadFile(info: TDownloadInfo; forceOverwrite: boolean);
const
  ERR_MSG = 'Error downloading file.';
var
  indyHTTP: TIdHTTP;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
  memoryStream: TMemoryStream;
begin
  with info do
  begin
    if forceOverwrite then
    begin
      deleteFileIfExists(fileName);
    end;

    indyHTTP := TIdHTTP.Create(nil);
    ioHandler := TIdSSLIOHandlerSocketOpenSSL.Create(indyHTTP);
    ioHandler.SSLOptions.SSLVersions := [
      TIdSSLVersion.sslvTLSv1, TIdSSLVersion.sslvTLSv1_1, TIdSSLVersion.sslvTLSv1_2,
      TIdSSLVersion.sslvSSLv2, TIdSSLVersion.sslvSSLv23,
      TIdSSLVersion.sslvSSLv3];
    indyHTTP.IOHandler := ioHandler;
    indyHTTP.HandleRedirects := true;

    memoryStream := TMemoryStream.Create;
    indyHTTP.Get(link, memoryStream);
    memoryStream.SaveToFile(fileName);

    FreeAndNil(memoryStream);
    ioHandler.Close;
    FreeAndNil(ioHandler);
    FreeAndNil(indyHTTP);

    if md5 <> '' then
    begin
      if not checkMD5File(fileName, md5) then
      begin
        raise Exception.Create(ERR_MSG);
      end;
    end;
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
  if not FileExists(_path_libeay32) then
  begin
    getResourceAsFile(RESOURCE_LIBEAY32, _path_libeay32);
  end;
  _path_libssl32 := getCombinedPathWithCurrentDir(FILENAME_LIBSSL32);
  if not FileExists(_path_libssl32) then
  begin
    getResourceAsFile(RESOURCE_LIBSSL32, _path_libssl32);
  end;
  _path_ssleay32 := getCombinedPathWithCurrentDir(FILENAME_SSLEAY32);
  if not FileExists(_path_ssleay32) then
  begin
    getResourceAsFile(RESOURCE_SSLEAY32, _path_ssleay32);
  end;
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
  MD5: TIdHashMessageDigest5;
  fileStream: TFileStream;
begin
  MD5 := TIdHashMessageDigest5.Create;
  fileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Result := MD5.HashStreamAsHex(fileStream);
  fileStream.Free;
  MD5.Free;
end;

end.
