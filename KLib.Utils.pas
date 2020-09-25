unit KLib.Utils;

interface

uses
  System.SysUtils, System.Classes,
  PngImage,
  IdFTP,
  KLib.Types;

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

procedure createEmptyFileIfNotExists(filename: string);
procedure createEmptyFile(filename: string);
function fileExistsAndEmpty(filePath: string): Boolean;
procedure deleteFileIfExists(fileName: string);

function getDirExe: string;
procedure createDirIfNotExists(const dirName: string);
procedure createHideDir(const path: string; forceDelete: boolean = false);
procedure deleteDirectory(dirName: string);

function checkIfIsLinuxSubfolder(mainFolder: string; subFolder: string): boolean;
function getPathInLinuxStyle(path: string): string;

function checkIfIsSubFolder(subFolder: string; mainFolder: string): boolean;
function getValidFullPath(fileName: string): string;

function MD5FileChecker(fileName: string; MD5: string): boolean;
function getMD5FileChecksum(const fileName: string): string;

function getPNGResource(nameResource: String): TPngImage;
function getResourceAsString(nameResource: String; typeResource: string): String;
function getResourceAsStream(nameResource: String; typeResource: string): TResourceStream;
procedure getResourceAsEXEFile(nameResource: String; destinationPath: string);
procedure getResourceAsFile(nameResource: String; typeResource: string; destinationPath: string);

function readStringWithEnvVariables(source: string): string;
function getIPAddress: string;

function currentDayOfWeekAsString: string;
function dayOfWeekAsString(date: TDateTime): string;
function currentDateTimeAsString: string;
function dateTimeAsString(date: TDateTime): string;
function currentDateAsString: string;
function dateAsString(date: TDateTime): string;

procedure downloadZipFileAndExtract(downloadInfo: TDownloadInfo; destinationPath: string;
  forceOverWrite: boolean = true; forceDeleteZipFile: boolean = true);
procedure downloadFile(downloadInfo: TDownloadInfo; forceDelete: boolean);
procedure extractZip(zipFile: string; extractPath: string; forceDelete: boolean = false);

function getValidFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
procedure validateFTPCredentials(FTPCredentials: TFTPCredentials);
function getFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;

procedure executeProcedure(myProcedure: TProcedure); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

implementation

uses
  System.Zip, System.IOUtils, System.StrUtils,
  Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, Winapi.Winsock, Winapi.ShellAPI,
  IdGlobal, IdHash, IdHashMessageDigest,
  UrlMon;

const
  PNG_RESOURCE = 'PNG';

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

procedure createEmptyFileIfNotExists(filename: string);
begin
  if not FileExists(filename) then
  begin
    createEmptyFile(filename);
  end;
end;

procedure createEmptyFile(filename: string);
var
  _handle: THandle;
begin
  _handle := FileCreate(fileName);
  if _handle = INVALID_HANDLE_VALUE then
  begin
    raise Exception.Create('Error creating File: ' + fileName);
  end
  else
  begin
    FileClose(_handle);
  end;
end;

function fileExistsAndEmpty(filePath: string): Boolean;
var
  _file: file of Byte;
  size: integer;
begin
  result := false;
  if fileexists(filePath) then
  begin
    AssignFile(_file, filePath);
    Reset(_file);
    size := FileSize(_file);
    if size = 0 then
    begin
      result := true;
    end;
    CloseFile(_file);
  end;
end;

procedure deleteFileIfExists(fileName: string);
begin
  if FileExists(fileName) then
  begin
    if not DeleteFile(pchar(fileName)) then
    begin
      raise Exception.Create('Error deleting file.');
    end;
  end;
end;

function getDirExe: string;
begin
  result := ExtractFileDir(ParamStr(0));
end;

procedure createDirIfNotExists(const dirName: string);
begin
  if not DirectoryExists(dirName) then
  begin
    if not CreateDir(dirName) then
    begin
      raise Exception.Create('Error creating dir.');
    end;
  end;
end;

procedure createHideDir(const path: string; forceDelete: boolean = false);
begin
  if forceDelete then
  begin
    deleteDirectory(path);
  end;

  if CreateDir(path) then
  begin
    SetFileAttributes(pchar(path), FILE_ATTRIBUTE_HIDDEN);
  end
  else
  begin
    raise Exception.Create('Error creating hide dir');
  end;
end;

procedure deleteDirectory(dirName: string);
var
  FileOp: TSHFileOpStruct;
begin
  FillChar(FileOp, SizeOf(FileOp), 0);
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(DirName + #0); //double zero-terminated
  FileOp.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
  SHFileOperation(FileOp);
  if DirectoryExists(dirName) then
  begin
    raise Exception.Create('Unable to delete ' + dirName);
  end;
end;

function checkIfIsLinuxSubfolder(mainFolder: string; subFolder: string): boolean;
var
  _mainFolder: string;
  _subFolder: string;
  _isSubFolder: Boolean;
begin
  _mainFolder := getPathInLinuxStyle(mainFolder);
  _subFolder := getPathInLinuxStyle(subFolder);
  _isSubFolder := checkIfIsSubFolder(_mainFolder, _subFolder);
  result := _isSubFolder
end;

function getPathInLinuxStyle(path: string): string;
var
  _path: string;
begin
  _path := StringReplace(path, '\', '/', [rfReplaceAll, rfIgnoreCase]);
  result := _path;
end;

function checkIfIsSubFolder(subFolder: string; mainFolder: string): boolean;
var
  _isSubFolder: Boolean;
begin
  mainFolder := LowerCase(mainFolder);
  subFolder := LowerCase(subFolder);
  _isSubFolder := AnsiStartsStr(mainFolder, subFolder);
  result := _isSubFolder;
end;

function getValidFullPath(fileName: string): string;
var
  _path: string;
begin
  _path := fileName;
  _path := ExpandFileName(_path);
  _path := ExcludeTrailingPathDelimiter(_path);
  result := _path;
end;

function MD5FileChecker(fileName: string; MD5: string): boolean;
var
  MD5File: string;
begin
  MD5File := getMD5FileChecksum(fileName);
  if UpperCase(MD5File) = UpperCase(MD5) then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

function getMD5FileChecksum(const fileName: string): string;
var
  MD5: TIdHashMessageDigest5;
  fileStream: TFileStream;
begin
  MD5 := TIdHashMessageDigest5.Create;
  fileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := MD5.HashStreamAsHex(fileStream)
  finally
    fileStream.Free;
    MD5.Free;
  end;
end;

function getPNGResource(nameResource: String): TPngImage;
var
  resourceStream: TResourceStream;
  resourceAsPNG: TPngImage;
begin
  resourceStream := getResourceAsStream(nameResource, PNG_RESOURCE);
  try
    resourceAsPNG := TPngImage.Create;
    resourceAsPNG.LoadFromStream(resourceStream);
  finally
    resourceStream.Free;
  end;
  Result := resourceAsPNG;
end;

function getResourceAsString(nameResource: String; typeResource: string): string;
var
  resourceStream: TResourceStream;
  _stringList: TStringList;
  resourceAsString: String;
begin
  resourceAsString := '';
  resourceStream := getResourceAsStream(nameResource, typeResource);
  try
    _stringList := TStringList.Create;
    _stringList.LoadFromStream(resourceStream);
    resourceAsString := _stringList.Text;
  finally
    resourceStream.Free;
  end;
  Result := resourceAsString;
end;

function getResourceAsStream(nameResource: String; typeResource: string): TResourceStream;
var
  resourceStream: TResourceStream;
begin
  if (FindResource(hInstance, PChar(nameResource), PChar(typeResource)) <> 0) then
  begin
    resourceStream := TResourceStream.Create(HInstance, PChar(nameResource), PChar(typeResource));
    resourceStream.Position := 0;
  end
  else
  begin
    raise Exception.Create('Not found a resource with name : ' + nameResource + ' and type : ' + typeResource);
  end;
  Result := resourceStream;
end;

procedure getResourceAsEXEFile(nameResource: String; destinationPath: string);
const
  TYPE_RESOURCE = 'EXE';
begin
  getResourceAsFile(nameResource, TYPE_RESOURCE, destinationPath);
end;

procedure getResourceAsFile(nameResource: String; typeResource: string; destinationPath: string);
var
  resourceStream: TResourceStream;
begin
  if (FindResource(hInstance, PChar(nameResource), PChar(typeResource)) <> 0) then
  begin
    resourceStream := TResourceStream.Create(HInstance, PChar(nameResource), PChar(typeResource));
    try
      resourceStream.Position := 0;
      resourceStream.SaveToFile(destinationPath);
    finally
      resourceStream.Free;
    end;
  end
  else
  begin
    raise Exception.Create('Not found a resource with name : ' + nameResource + ' and type : ' + typeResource);
  end;
end;

function readStringWithEnvVariables(source: string): string;
var
  tempStringDir: string;
  tempStringPos: string;
  posStart, posEnd: integer;
  valueToReplace, newValue: string;
begin
  tempStringPos := source;
  tempStringDir := source;
  result := source;
  repeat
    posStart := pos('%', tempStringPos);
    tempStringPos := copy(tempStringPos, posStart + 1, length(tempStringPos));
    posEnd := posStart + pos('%', tempStringPos);
    if (posStart > 0) and (posEnd > 1) then
    begin
      valueToReplace := copy(tempStringDir, posStart, posEnd - posStart + 1);
      newValue := GetEnvironmentVariable(copy(valueToReplace, 2, length(valueToReplace) - 2));
      if newValue <> '' then
      begin
        result := stringreplace(Result, valueToReplace, newValue, []);
      end;
    end
    else
    begin
      exit;
    end;
    tempStringDir := copy(tempStringDir, posEnd + 1, length(tempStringDir));
    tempStringPos := tempStringDir;
  until posStart < 0;
end;

function getIPAddress: string;
type
  pu_long = ^u_long;
var
  varTWSAData: TWSAData;
  varPHostEnt: PHostEnt;
  varTInAddr: TInAddr;
  namebuf: Array [0 .. 255] of ansichar;
begin
  if WSAStartup($101, varTWSAData) <> 0 Then
    Result := '-'
  else
  begin
    getHostName(nameBuf, sizeOf(nameBuf));
    varPHostEnt := getHostByName(nameBuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    Result := inet_ntoa(varTInAddr);
  end;
  WSACleanup;
end;

function currentDayOfWeekAsString: string;
var
  _nameDay: string;
begin
  _nameDay := dayOfWeekAsString(Now);
  result := _nameDay;
end;

function dayOfWeekAsString(date: TDateTime): string;
const
  DAYS_OF_WEEK: TArray<String> = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'];
var
  _indexDayOfWeek: integer;
  _nameDay: string;
begin
  _indexDayOfWeek := DayOfWeek(date) - 1;
  _nameDay := DAYS_OF_WEEK[_indexDayOfWeek];
  result := _nameDay;
end;

function currentDateTimeAsString: string;
begin
  result := dateTimeAsString(Now);
end;

function dateTimeAsString(date: TDateTime): string;
var
  _date: string;
  _time: string;
  _dateTime: string;
begin
  _date := dateAsString(date);
  _time := TimeToStr(date);
  _time := StringReplace(_time, ':', '', [rfReplaceAll, rfIgnoreCase]);
  _dateTime := _date + '_' + _time;
  result := _dateTime;
end;

function currentDateAsString: string;
begin
  result := dateAsString(Now);
end;

function dateAsString(date: TDateTime): string;
var
  _date: string;
begin
  _date := DateToStr(date);
  _date := StringReplace(_date, '/', '_', [rfReplaceAll, rfIgnoreCase]);
  result := _date;
end;

procedure downloadZipFileAndExtract(downloadInfo: TDownloadInfo; destinationPath: string;
  forceOverWrite: boolean = true; forceDeleteZipFile: boolean = true);
var
  pathZipFile: string;
begin
  downloadFile(downloadInfo, forceOverWrite);
  pathZipFile := TPath.Combine(destinationPath, downloadInfo.fileName);
  extractZip(pathZipFile, destinationPath, forceDeleteZipFile);
end;

procedure downloadFile(downloadInfo: TDownloadInfo; forceDelete: boolean);
const
  ERR_MSG = 'Error downloading file';
begin
  with downloadInfo do
  begin
    if forceDelete then
    begin
      deleteFileIfExists(fileName);
    end;
    if (URLDownloadToFile(nil, pChar(link), pchar(fileName), 0, nil) <> S_OK) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
    if md5 <> '' then
    begin
      if not MD5FileChecker(fileName, md5) then
      begin
        raise Exception.Create(ERR_MSG);
      end;
    end;
  end;
end;

procedure extractZip(zipFile: string; extractPath: string; forceDelete: boolean = false);
begin
  if tzipfile.isvalid(zipFile) then
  begin
    tzipfile.extractZipfile(zipFile, extractPath);
    if (forceDelete) then
    begin
      deleteFileIfExists(zipFile);
    end;
  end
  else
  begin
    raise Exception.Create('Zip File not valid.');
  end;
end;

//TODO CREATE CUSTOM FTP CLASS
function getValidFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
var
  connection: TIdFTP;
begin
  validateFTPCredentials(FTPCredentials);
  connection := getFTPConnection(FTPCredentials);
  Result := connection;
end;

procedure validateFTPCredentials(FTPCredentials: TFTPCredentials);
const
  ERR_MSG = 'Invalid FTP credentials';
var
  _connection: TIdFTP;
begin
  _connection := getFTPConnection(FTPCredentials);
  try
    _connection.Connect;
    if FTPCredentials.pathFTPDir <> '' then
    begin
      _connection.ChangeDir(FTPCredentials.pathFTPDir);
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
  _connection.Disconnect;
  _connection.Free;
end;

procedure validateRequiredFTPProperties(FTPCredentials: TFTPCredentials); forward;

function getFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
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
    connection.TransferType := transferType;
    connection.Passive := true;
  end;

  Result := connection;
end;

procedure validateRequiredFTPProperties(FTPCredentials: TFTPCredentials);
const
  ERR_MSG = 'Incomplete FTP credentials';
begin
  with FTPCredentials do
  begin
    if (server = '') or (credentials.username = '') or (credentials.password = '') then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

procedure executeProcedure(myProcedure: TProcedure);
begin
  myProcedure;
end;

procedure executeProcedure(myProcedure: TCallBack);
begin
  myProcedure('');
end;

end.
