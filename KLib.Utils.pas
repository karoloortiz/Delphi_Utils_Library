{
  KLib Version = 1.0
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

unit KLib.Utils;

interface

uses
  KLib.Types,
  Vcl.Imaging.pngimage,
  Xml.XMLIntf,
  IdFTP,
  System.SysUtils, System.Classes;

const
  _DEFAULT_ERROR_STRING_VALUE_INI_FILES = '*_/&@';

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer; overload;
function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer; overload;
function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;

procedure createEmptyFileIfNotExists(filename: string);
procedure createEmptyFile(filename: string);
function checkIfFileExistsAndEmpty(fileName: string): boolean;
procedure deleteFileIfExists(fileName: string);

function checkIfThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64): boolean;
function getFreeSpaceOnDrive(drive: char): int64;
function getIndexOfDrive(drive: char): integer;
function getDriveExe: char;
function getDirSize(path: string): int64;
function getCombinedPathWithCurrentDir(pathToCombine: string): string;
function getDirExe: string;
procedure createDirIfNotExists(dirName: string);

function checkIfIsLinuxSubDir(subDir: string; mainDir: string): boolean;
function getPathInLinuxStyle(path: string): string;

function checkIfIsSubDir(subDir: string; mainDir: string): boolean;
function getValidFullPath(fileName: string): string;

function checkMD5File(fileName: string; MD5: string): boolean;
function getMD5ChecksumFile(fileName: string): string;

procedure unzipResource(nameResource: string; destinationDir: string);
function getPNGResource(nameResource: String): TPngImage;
procedure getResourceAsEXEFile(nameResource: String; destinationFileName: string);
procedure getResourceAsZIPFile(nameResource: String; destinationFileName: string);
procedure getResourceAsFile(resource: TResource; destinationFileName: string);
function getResourceAsXSL(nameResource: string): IXMLDocument;
function getResourceAsString(resource: TResource): string;
function getResourceAsStream(resource: TResource): TResourceStream;

//USING INDY YOU NEED libeay32.dll AND libssl32.dll
procedure downloadZipFileAndExtractWithIndy(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
procedure downloadFileWithIndy(info: TDownloadInfo; forceOverwrite: boolean);
procedure getOpenSSLDLLsFromResource;
procedure deleteOpenSSLDLLsIfExists;

procedure unzip(zipFileName: string; destinationDir: string; deleteZipAfterUnzip: boolean = false);

function getNumberOfLinesInStrFixedWordWrap(source: String): integer;
function strToStrFixedWordWrap(source: String; fixedLen: Integer): String;
function strToStringList(source: String; fixedLen: Integer): TStringList;

function getValidFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
function checkRequiredFTPProperties(FTPCredentials: TFTPCredentials): boolean;
function getFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;

procedure executeProcedure(myProcedure: TAnonymousMethod); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

function getCurrentDayOfWeekAsString: string;
function getDayOfWeekAsString(date: TDateTime): string;
function getCurrentDateTimeAsString: string;
function getDateTimeAsString(date: TDateTime): string;
function getCurrentDateAsString: string;
function getDateAsString(date: TDateTime): string;
function getRandString(size: integer = 5): string;

function getDoubleQuotedString(value: string): string;
function getSingleQuotedString(value: string): string;
function getSubStringInsertedIntoString(mainString: string; insertedString: string; index: integer): string;

implementation

uses
  KLib.Validate, KLib.Constants,
  Vcl.ExtCtrls,
  Xml.XMLDoc,
  IdGlobal, IdHash, IdHashMessageDigest, IdHTTP, IdSSLOpenSSL,
  System.Zip, System.IOUtils, System.StrUtils, System.IniFiles;

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer;
var
  _stringValue: string;
  _intValue: integer;
begin
  _stringValue := getStringValueFromIniFile(fileNameIni, nameSection, nameProperty);
  _intValue := StrToInt(_stringValue);
  Result := _intValue;
end;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer;
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: integer;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadInteger(nameSection, nameProperty, defaultPropertyValue);
  FreeAndNil(_iniManipulator);

  Result := value;
end;

function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;
const
  ERR_MSG = 'No property assigned.';
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: string;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
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

function checkIfFileExistsAndEmpty(fileName: string): boolean;
var
  _file: file of Byte;
  _size: integer;
  _result: boolean;
begin
  _result := false;
  if fileexists(fileName) then
  begin
    AssignFile(_file, fileName);
    Reset(_file);
    _size := FileSize(_file);
    _result := _size = 0;
    CloseFile(_file);
  end;

  Result := _result;
end;

procedure deleteFileIfExists(fileName: string);
const
  ERR_MSG = 'Error deleting file.';
begin
  if FileExists(fileName) then
  begin
    if not DeleteFile(pchar(fileName)) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

function checkIfThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64): boolean;
var
  _freeSpaceDrive: int64;
  _result: boolean;
begin
  _freeSpaceDrive := getFreeSpaceOnDrive(drive);
  _result := _freeSpaceDrive > requiredSpaceInBytes;
  Result := _result;
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
  _subDirSize: int64;
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
          _subDirSize := getDirSize(path + _searchRec.name);
          inc(totalSize, _subDirSize);
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

function getCombinedPathWithCurrentDir(pathToCombine: string): string;
var
  _result: string;
  _currentDir: string;
begin
  _currentDir := getDirExe;
  _result := TPath.Combine(_currentDir, pathToCombine);
  Result := _result;
end;

function getDirExe: string;
begin
  result := ExtractFileDir(ParamStr(0));
end;

procedure createDirIfNotExists(dirName: string);
const
  ERR_MSG = 'Error creating dir.';
begin
  if not DirectoryExists(dirName) then
  begin
    if not CreateDir(dirName) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

function checkIfIsLinuxSubDir(subDir: string; mainDir: string): boolean;
var
  _subDir: string;
  _mainDir: string;
  _isSubDir: Boolean;
begin
  _subDir := getPathInLinuxStyle(subDir);
  _mainDir := getPathInLinuxStyle(mainDir);
  _isSubDir := checkIfIsSubDir(_subDir, _mainDir);
  result := _isSubDir
end;

function getPathInLinuxStyle(path: string): string;
var
  _path: string;
begin
  _path := StringReplace(path, '\', '/', [rfReplaceAll, rfIgnoreCase]);
  result := _path;
end;

function checkIfIsSubDir(subDir: string; mainDir: string): boolean;
var
  _isSubDir: Boolean;
begin
  mainDir := LowerCase(mainDir);
  subDir := LowerCase(subDir);
  _isSubDir := AnsiStartsStr(subDir, mainDir);
  result := _isSubDir;
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

function checkMD5File(fileName: string; MD5: string): boolean;
var
  _MD5ChecksumFile: string;
begin
  _MD5ChecksumFile := getMD5ChecksumFile(fileName);
  if UpperCase(_MD5ChecksumFile) = UpperCase(MD5) then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
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

procedure unzipResource(nameResource: string; destinationDir: string);
const
  DELETE_ZIP_AFTER_UNZIP = TRUE;
var
  _tempZipFileName: string;
begin
  _tempZipFileName := getRandString + '.' + ZIP_TYPE;
  _tempZipFileName := TPath.Combine(destinationDir, _tempZipFileName);
  getResourceAsZIPFile(nameResource, _tempZipFileName);
  unzip(_tempZipFileName, destinationDir, DELETE_ZIP_AFTER_UNZIP);
end;

function getPNGResource(nameResource: String): TPngImage;
var
  _resource: TResource;
  resourceStream: TResourceStream;
  resourceAsPNG: TPngImage;
begin
  with _resource do
  begin
    name := nameResource;
    _type := PNG_TYPE;
  end;
  resourceStream := getResourceAsStream(_resource);
  resourceAsPNG := TPngImage.Create;
  resourceAsPNG.LoadFromStream(resourceStream);
  resourceStream.Free;
  Result := resourceAsPNG;
end;

procedure _getResourceAsFile_(nameResource: string; typeResource: string; destinationFileName: string); forward;

procedure getResourceAsEXEFile(nameResource: String; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, EXE_TYPE, destinationFileName);
end;

procedure getResourceAsZIPFile(nameResource: String; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, ZIP_TYPE, destinationFileName);
end;

procedure _getResourceAsFile_(nameResource: string; typeResource: string; destinationFileName: string);
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

function getResourceAsXSL(nameResource: string): IXMLDocument;
var
  _resource: TResource;
  _resourceAsString: string;
  xls: IXMLDocument;
begin
  with _resource do
  begin
    name := nameResource;
    _type := XSL_TYPE;
  end;
  _resourceAsString := getResourceAsString(_resource);
  xls := LoadXMLData(_resourceAsString);
  Result := xls;
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
  errMsg: string;
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
      errMsg := 'Not found a resource with name : ' + name + ' and type : ' + _type;
      raise Exception.Create(errMsg);
    end;
  end;
  Result := resourceStream;
end;

//USING INDY YOU NEED libeay32.dll AND libssl32.dll
procedure downloadZipFileAndExtractWithIndy(info: TDownloadInfo; forceOverwrite: boolean;
  destinationPath: string; forceDeleteZipFile: boolean = false);
var
  pathZipFile: string;
begin
  downloadFileWithIndy(info, forceOverwrite);
  pathZipFile := TPath.Combine(destinationPath, info.fileName);
  unzip(pathZipFile, destinationPath, forceDeleteZipFile);
end;

procedure downloadFileWithIndy(info: TDownloadInfo; forceOverwrite: boolean);
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
  FILENAME_LIBSSL32 = 'libssl32.dll';
  FILENAME_LIBEAY32 = 'libeay32.dll';

procedure getOpenSSLDLLsFromResource;
var
  _path_libeay32: string;
  _path_libssl32: string;
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
end;

procedure deleteOpenSSLDLLsIfExists;
var
  _path_libeay32: string;
  _path_libssl32: string;
begin
  UnLoadOpenSSLLibrary;
  _path_libeay32 := getCombinedPathWithCurrentDir(FILENAME_LIBEAY32);
  deleteFileIfExists(_path_libeay32);
  _path_libssl32 := getCombinedPathWithCurrentDir(FILENAME_LIBSSL32);
  deleteFileIfExists(_path_libssl32);
end;

procedure unzip(zipFileName: string; destinationDir: string; deleteZipAfterUnzip: boolean = false);
const
  ERR_MSG = 'Invalid zip file.';
begin
  if tzipfile.isvalid(zipFileName) then
  begin
    tzipfile.extractZipfile(zipFileName, destinationDir);
    if (deleteZipAfterUnzip) then
    begin
      deleteFileIfExists(zipFileName);
    end;
  end
  else
  begin
    raise Exception.Create(ERR_MSG);
  end;
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

function getValidFTPConnection(FTPCredentials: TFTPCredentials): TIdFTP;
var
  connection: TIdFTP;
begin
  validateFTPCredentials(FTPCredentials);
  connection := getFTPConnection(FTPCredentials);
  Result := connection;
end;

function checkFTPCredentials(FTPCredentials: TFTPCredentials): boolean;
var
  _connection: TIdFTP;
  _result: boolean;
begin
  _result := true;
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
      _result := false;
    end;
  end;
  _connection.Disconnect;
  _connection.Free;

  Result := _result;
end;

function checkRequiredFTPProperties(FTPCredentials: TFTPCredentials): boolean;
var
  _result: boolean;
begin
  with FTPCredentials do
  begin
    _result := (server <> '') and (credentials.username <> '') and (credentials.password <> '');
  end;

  Result := _result;
end;

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

procedure executeProcedure(myProcedure: TAnonymousMethod);
begin
  myProcedure;
end;

procedure executeProcedure(myProcedure: TCallBack);
begin
  myProcedure('');
end;

function getCurrentDayOfWeekAsString: string;
var
  _nameDay: string;
begin
  _nameDay := getDayOfWeekAsString(Now);
  result := _nameDay;
end;

function getDayOfWeekAsString(date: TDateTime): string;
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

function getCurrentDateTimeAsString: string;
begin
  result := getDateTimeAsString(Now);
end;

function getDateTimeAsString(date: TDateTime): string;
var
  _date: string;
  _time: string;
  _dateTime: string;
begin
  _date := getDateAsString(date);
  _time := TimeToStr(date);
  _time := StringReplace(_time, ':', '', [rfReplaceAll, rfIgnoreCase]);
  _dateTime := _date + '_' + _time;
  result := _dateTime;
end;

function getCurrentDateAsString: string;
begin
  result := getDateAsString(Now);
end;

function getDateAsString(date: TDateTime): string;
var
  _date: string;
begin
  _date := DateToStr(date);
  _date := StringReplace(_date, '/', '_', [rfReplaceAll, rfIgnoreCase]);
  result := _date;
end;

function getRandString(size: integer = 5): string;
const
  ALPHABET: array [1 .. 62] of char = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
    _randIndexOfAlphabet := random(_lengthAlphabet) + 1;
    _randCharacter := ALPHABET[_randIndexOfAlphabet];
    _randString := _randString + _randCharacter;
  end;
  Result := _randString;
end;

function getDoubleQuotedString(value: string): string;
begin
  Result := AnsiQuotedStr(value, '"');
end;

function getSingleQuotedString(value: string): string;
begin
  Result := AnsiQuotedStr(value, '"');
end;

function getSubStringInsertedIntoString(mainString: string; insertedString: string; index: integer): string;
const
  ERR_MSG = 'Index out of range.';
var
  _lenght: integer;
begin
  if (index > _lenght) or (index < 0) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  _lenght := Length(mainString);
  Result := Copy(mainString, 0, index) + insertedString + Copy(mainString, index + 1, _lenght);
end;

end.
