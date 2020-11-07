unit KLib.Utils;

interface

uses
  KLib.Types,
  System.SysUtils, System.Classes,
  Vcl.Imaging.pngimage,
  IdFTP;

const
  DEFAULT_DOWNLOAD_OPTIONS: TDownloadOptions = (forceOverwrite: true; useIndy: true);
  _DEFAULT_ERROR_STRING_VALUE_INI_FILES = '*_/&@';

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

function getIntValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string): integer; overload;
function getIntValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string;
  defaultPropertyValue: integer): integer; overload;
function getStringValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;
procedure createEmptyFileIfNotExists(filename: string);
procedure createEmptyFile(filename: string);
function fileExistsAndEmpty(filePath: string): Boolean;
procedure deleteFileIfExists(fileName: string);
procedure exceptionIfFileNotExists(fileName: string);

procedure validateThatThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64);
function getFreeSpaceOnDrive(drive: char): int64;
function getIndexOfDrive(drive: char): integer;
function getDriveExe: char;
function getDirSize(path: string): int64;
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

procedure unzipResource(nameResource: string; destinationFolder: string);
function getPNGResource(nameResource: String): TPngImage;
procedure getResourceAsEXEFile(nameResource: String; destinationFileName: string);
procedure getResourceAsZIPFile(nameResource: String; destinationFileName: string);
procedure getResourceAsFile(resource: TResource; destinationFileName: string);
function getResourceAsString(resource: TResource): string;
function getResourceAsStream(resource: TResource): TResourceStream;

procedure downloadZipFileAndExtract(info: TDownloadInfo; options: TDownloadOptions;
  destinationPath: string; forceDeleteZipFile: boolean = false);
procedure downloadFile(info: TDownloadInfo; options: TDownloadOptions);
procedure getOpenSSLDLLsFromResource;
procedure deleteOpenSSLDLLsIfExists;
procedure unzip(zipFileName: string; destinationFolder: string; deleteZipAfterUnzip: boolean = false);

function readStringWithEnvVariables(source: string): string; // TODO MOVE IN KLIB.WINDOWS?

function getNumberOfLinesInStrFixedWordWrap(source: String): integer;
function strToStrFixedWordWrap(source: String; fixedLen: Integer): String;
function strToStringList(source: String; fixedLen: Integer): TStringList;

function getValidFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
procedure validateFTPCredentials(FTPCredentials: TFTPCredentials);
function getFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;

procedure executeProcedure(myProcedure: TAnonymousMethod); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

function currentDayOfWeekAsString: string;
function dayOfWeekAsString(date: TDateTime): string;
function currentDateTimeAsString: string;
function dateTimeAsString(date: TDateTime): string;
function currentDateAsString: string;
function dateAsString(date: TDateTime): string;
function getRandString(size: integer = 5): string;

implementation

uses
  System.Zip, System.IOUtils, System.StrUtils, System.IniFiles,
  Vcl.ExtCtrls,
  Winapi.Windows, Winapi.ShellAPI,
  IdGlobal, IdHash, IdHashMessageDigest, IdHTTP, IdSSLOpenSSL,
  UrlMon;

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

function getIntValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string): integer;
var
  _stringValue: string;
  _intValue: integer;
begin
  _stringValue := getStringValueFromIniFile(nameSection, nameProperty, fileNameIni);
  _intValue := StrToInt(_stringValue);
  Result := _intValue;
end;

function getIntValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string;
  defaultPropertyValue: integer): integer;
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: integer;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  exceptionIfFileNotExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadInteger(nameSection, nameProperty, defaultPropertyValue);
  FreeAndNil(_iniManipulator);

  Result := value;
end;

function getStringValueFromIniFile(nameSection: string; nameProperty: string; fileNameIni: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;
const
  ERR_MSG = 'No property assigned.';
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: string;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  exceptionIfFileNotExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadString(nameSection, nameProperty, defaultPropertyValue);
  FreeAndNil(_iniManipulator);
  if value = _DEFAULT_ERROR_STRING_VALUE_INI_FILES then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  Result := value;
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

procedure exceptionIfFileNotExists(fileName: string);
begin
  if not FileExists(fileName) then
  begin
    raise Exception.Create('File: ' + fileName + ' doesn''t exists.');
  end;
end;

procedure validateThatThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64);
const
  ERR_NOT_ENOUGH_SPACE_ON_DRIVE_MSG = 'There is not enough space available on the Drive: ';
var
  _freeSpaceDrive: int64;
begin
  _freeSpaceDrive := getFreeSpaceOnDrive(drive);
  if _freeSpaceDrive < requiredSpaceInBytes then
  begin
    raise Exception.Create(ERR_NOT_ENOUGH_SPACE_ON_DRIVE_MSG + drive);
  end;
end;

function getFreeSpaceOnDrive(drive: char): int64;
const
  ERR_MSG_INVALID_DRIVE = 'The drive is invalid.';
  ERR_MSG_DRIVE_READ_ONLY = 'The drive is read-only';
var
  _indexOfDrive: integer;
  freeSpaceOnDrive: int64;
begin
  _indexOfDrive := getIndexOfDrive(drive);
  freeSpaceOnDrive := 0;
  freeSpaceOnDrive := DiskFree(_indexOfDrive);
  case freeSpaceOnDrive of
    - 1:
      raise Exception.Create(ERR_MSG_INVALID_DRIVE);
    0:
      raise Exception.Create(ERR_MSG_DRIVE_READ_ONLY);
  end;
  Result := freeSpaceOnDrive;
end;

function getIndexOfDrive(drive: char): integer;
const
  ASCII_FIRST_ALPHABET_CHARACTER = 65;
  ASCII_LAST_ALPHABET_CHARACTER = 90;

  ERR_MSG = 'Invalid drive character.';
var
  _drive: string;
  _asciiIndex: integer;
begin
  _drive := uppercase(drive);
  _asciiIndex := integer(_drive[1]);
  if not((_asciiIndex >= ASCII_FIRST_ALPHABET_CHARACTER) and (_asciiIndex <= ASCII_LAST_ALPHABET_CHARACTER)) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  Result := (_asciiIndex - ASCII_FIRST_ALPHABET_CHARACTER) + 1;
end;

function getDriveExe: char;
var
  _dirExe: string;
begin
  _dirExe := getDriveExe;
  Result := _dirExe[1];
end;

function getDirSize(path: string): int64;
var
  _searchRec: TSearchRec;
  totalSize: int64;
  _subFolderSize: int64;
begin
  totalSize := 0;
  path := getValidFullPath(path);
  path := IncludeTrailingBackSlash(path);
  if FindFirst(path + '*', faAnyFile, _searchRec) = 0 then
  begin
    repeat
      if (_searchRec.attr and faDirectory) > 0 then
      begin
        if (_searchRec.name <> '.') and (_searchRec.name <> '..') then
        begin
          _subFolderSize := getDirSize(path + _searchRec.name);
          inc(totalSize, _subFolderSize);
        end;
      end
      else
      begin
        inc(totalSize, _searchRec.size);
      end;
    until FindNext(_searchRec) <> 0;
    System.SysUtils.FindClose(_searchRec);
  end;
  Result := totalSize;
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
  Result := MD5.HashStreamAsHex(fileStream);
  fileStream.Free;
  MD5.Free;
end;

procedure unzipResource(nameResource: string; destinationFolder: string);
const
  ZIP_FILE_EXTENSION = '.zip';
  DELETE_ZIP_AFTER_UNZIP = TRUE;
var
  _tempZipFileName: string;
begin
  _tempZipFileName := getRandString + ZIP_FILE_EXTENSION; //TODO group extensions
  _tempZipFileName := TPath.Combine(destinationFolder, _tempZipFileName);
  getResourceAsZIPFile(nameResource, _tempZipFileName);
  unzip(_tempZipFileName, destinationFolder, DELETE_ZIP_AFTER_UNZIP);
end;

function getPNGResource(nameResource: String): TPngImage;
const
  TYPE_PNG_RESOURCE = 'PNG';
var
  _resource: TResource;
  resourceStream: TResourceStream;
  resourceAsPNG: TPngImage;
begin
  with _resource do
  begin
    name := nameResource;
    _type := TYPE_PNG_RESOURCE;
  end;
  resourceStream := getResourceAsStream(_resource);
  resourceAsPNG := TPngImage.Create;
  resourceAsPNG.LoadFromStream(resourceStream);
  resourceStream.Free;
  Result := resourceAsPNG;
end;

procedure _getResourceAs(nameResource: string; typeResource: string; destinationFileName: string); forward;

procedure getResourceAsEXEFile(nameResource: String; destinationFileName: string);
const
  TYPE_RESOURCE = 'EXE';
begin
  _getResourceAs(nameResource, TYPE_RESOURCE, destinationFileName);
end;

procedure getResourceAsZIPFile(nameResource: String; destinationFileName: string);
const
  TYPE_RESOURCE = 'ZIP';
begin
  _getResourceAs(nameResource, TYPE_RESOURCE, destinationFileName);
end;

procedure _getResourceAs(nameResource: string; typeResource: string; destinationFileName: string);
var
  _resource: TResource;
begin
  with _resource do
  begin
    name := nameResource;
    _type := typeResource;
  end;
  getResourceAsFile(_resource, destinationFileName);
end;

procedure getResourceAsFile(resource: TResource; destinationFileName: string);
var
  resourceStream: TResourceStream;
begin
  resourceStream := getResourceAsStream(resource);
  resourceStream.SaveToFile(destinationFileName);
  resourceStream.Free;
end;

function getResourceAsString(resource: TResource): string;
var
  resourceStream: TResourceStream;
  _stringList: TStringList;
  resourceAsString: String;
begin
  resourceAsString := '';
  resourceStream := getResourceAsStream(resource);
  _stringList := TStringList.Create;
  _stringList.LoadFromStream(resourceStream);
  resourceAsString := _stringList.Text;
  resourceStream.Free;
  Result := resourceAsString;
end;

function getResourceAsStream(resource: TResource): TResourceStream;
var
  resourceStream: TResourceStream;
begin
  with resource do
  begin
    if (FindResource(hInstance, PChar(name), PChar(_type)) <> 0) then
    begin
      resourceStream := TResourceStream.Create(HInstance, PChar(name), PChar(_type));
      resourceStream.Position := 0;
    end
    else
    begin
      raise Exception.Create('Not found a resource with name : ' + name + ' and type : '
        + _type);
    end;
  end;
  Result := resourceStream;
end;

procedure downloadZipFileAndExtract(info: TDownloadInfo; options: TDownloadOptions;
  destinationPath: string; forceDeleteZipFile: boolean = false);
var
  pathZipFile: string;
begin
  downloadFile(info, options);
  pathZipFile := TPath.Combine(destinationPath, info.fileName);
  unzip(pathZipFile, destinationPath, forceDeleteZipFile);
end;

procedure downloadFileWithIndy(link: string; fileName: string); forward;

procedure downloadFile(info: TDownloadInfo; options: TDownloadOptions);
const
  ERR_MSG = 'Error downloading file';
begin
  with info do
  begin
    with options do
    begin
      if forceOverwrite then
      begin
        deleteFileIfExists(fileName);
      end;
      if useIndy then
      begin
        downloadFileWithIndy(link, fileName);
      end
      else
      begin
        if (URLDownloadToFile(nil, pChar(link), pchar(fileName), 0, nil) <> S_OK) then
        begin
          raise Exception.Create(ERR_MSG);
        end;
      end;
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

//USING INDY YOU NEED libeay32.dll AND libssl32.dll
procedure downloadFileWithIndy(link: string; fileName: string);
var
  indyHTTP: TIdHTTP;
  ioHandler: TIdSSLIOHandlerSocketOpenSSL;
  memoryStream: TMemoryStream;
begin
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
end;

function getPath_libeay32: string; forward;
function getPath_libssl32: string; forward;

procedure getOpenSSLDLLsFromResource;
const
  RESOURCE_LIBEAY32: TResource = (name: 'LIBEAY32'; _type: 'DLL');
  RESOURCE_LIBSSL32: TResource = (name: 'LIBSSL32'; _type: 'DLL');
var
  _path_libeay32: string;
  _path_libssl32: string;
begin
  _path_libeay32 := getPath_libeay32;
  if not FileExists(_path_libeay32) then
  begin
    getResourceAsFile(RESOURCE_LIBEAY32, _path_libeay32);
  end;
  _path_libssl32 := getPath_libssl32;
  if not FileExists(_path_libssl32) then
  begin
    getResourceAsFile(RESOURCE_LIBSSL32, _path_libssl32);
  end;
end;

procedure deleteOpenSSLDLLsIfExists;
var
  _path_libeay32: string;
  _path_libssl32: string;
begin
  UnLoadOpenSSLLibrary;
  _path_libeay32 := getPath_libeay32;
  deleteFileIfExists(_path_libeay32);
  _path_libssl32 := getPath_libssl32;
  deleteFileIfExists(_path_libssl32);
end;

function getPath_libeay32: string;
const
  FILENAME_LIBEAY32 = 'libeay32.dll';
var
  _path_libeay32: string;
  _currentDir: string;
begin
  _currentDir := getDirExe;
  _path_libeay32 := TPath.Combine(_currentDir, FILENAME_LIBEAY32);
  Result := _path_libeay32;
end;

function getPath_libssl32: string;
const
  FILENAME_LIBSSL32 = 'libssl32.dll';
var
  _path_libssl32: string;
  _currentDir: string;
begin
  _currentDir := getDirExe;
  _path_libssl32 := TPath.Combine(_currentDir, FILENAME_LIBSSL32);
  Result := _path_libssl32;
end;

procedure unzip(zipFileName: string; destinationFolder: string; deleteZipAfterUnzip: boolean = false);
begin
  if tzipfile.isvalid(zipFileName) then
  begin
    tzipfile.extractZipfile(zipFileName, destinationFolder);
    if (deleteZipAfterUnzip) then
    begin
      deleteFileIfExists(zipFileName);
    end;
  end
  else
  begin
    raise Exception.Create('Invalid zip file.');
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

function getNumberOfLinesInStrFixedWordWrap(source: String): integer;
var
  _stringList: TStringList;
begin
  _stringList := TStringList.Create;
  _stringList.Text := source;
  result := _stringList.Count;
  FreeAndNil(_stringList);
end;

function strToStrFixedWordWrap(source: String; fixedLen: Integer): String;
var
  _stringList: TStringList;
  _result: string;
begin
  _stringList := strToStringList(source, fixedLen);
  _result := _stringList.Text;
  Delete(_result, length(_result), 1);
  result := _result;
  FreeAndNil(_stringList);
end;

function strToStringList(source: String; fixedLen: integer): TStringList;
var
  idx: Integer;
  srcLen: Integer;
  alist: TStringList;
begin
  alist := TStringList.Create;
  alist.LineBreak := #13;
  if fixedLen = 0 then
  begin
    fixedLen := Length(source) - 1;
  end;
  aList.Capacity := (Length(source) div fixedLen) + 1;

  idx := 1;
  srcLen := Length(source);

  while idx <= srcLen do
  begin
    aList.Add(Copy(source, idx, fixedLen));
    Inc(idx, fixedLen);
  end;

  result := alist;
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

procedure executeProcedure(myProcedure: TAnonymousMethod);
begin
  myProcedure;
end;

procedure executeProcedure(myProcedure: TCallBack);
begin
  myProcedure('');
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

function getRandString(size: integer = 5): string;
const
  ALPHABET: array [0 .. 62] of char = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
var
  _randString: string;
  _randCharacter: char;
  _randIndexOfAlphabet: integer;
  _lengthAlphabet: integer;
  i: integer;
begin
  _randString := '';
  _lengthAlphabet := length(ALPHABET);
  for i := 1 to size do
  begin
    _randIndexOfAlphabet := random(_lengthAlphabet);
    _randCharacter := ALPHABET[_randIndexOfAlphabet];
    _randString := _randString + _randCharacter;
  end;
  Result := _randString;
end;

end.
