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

unit KLib.Utils;

interface

uses
  KLib.Types, KLib.Constants,
  Vcl.Imaging.pngimage,
  System.SysUtils, System.Classes;

procedure deleteFilesInDirWithStartingFileName(dirName: string; startingFileName: string; fileType: string = EMPTY_STRING);
function checkIfFileExistsAndEmpty(fileName: string): boolean;
procedure deleteFileIfExists(fileName: string);
function getTextFromFile(fileName: string): string;

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

procedure unzipResource(nameResource: string; destinationDir: string);
function getPNGResource(nameResource: string): TPngImage;
procedure getResourceAsEXEFile(nameResource: string; destinationFileName: string);
procedure getResourceAsZIPFile(nameResource: string; destinationFileName: string);
procedure getResourceAsFile(resource: TResource; destinationFileName: string);
function getResourceAsString(resource: TResource): string;
function getResourceAsStream(resource: TResource): TResourceStream;

procedure unzip(zipFileName: string; destinationDir: string; deleteZipAfterUnzip: boolean = false);

function checkRequiredFTPProperties(FTPCredentials: TFTPCredentials): boolean;

function getValidTelephoneNumber(number: string): string;

function getRandString(size: integer = 5): string;

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): string;
function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): TstringList;

function getCombinedPath(path1: string; path2: string): string;

function getCurrentDayOfWeekAsString: string;
function getDayOfWeekAsString(date: TDateTime): string;
function getCurrentDateTimeAsString: string;
function getDateTimeAsString(date: TDateTime): string;
function getCurrentDateAsString: string;
function getDateAsString(date: TDateTime): string; //TODO REVIEW NAME?
function getCurrentTimeStamp: string;
function getCurrentDateTimeAsStringWithFormatting(formatting: string = DATE_FORMAT): string;
function getDateTimeAsStringWithFormatting(value: TDateTime; formatting: string = DATE_FORMAT): string;
function getCurrentDateTime: TDateTime;

function getParsedXMLstring(mainString: string): string; //todo add to myString
function getDoubleQuotedString(mainString: string): string;
function getSingleQuotedString(mainString: string): string;
function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer): string;
function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_string): string;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDate(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;

function getNumberOfLinesInStrFixedWordWrap(source: string): integer;
function strToStrFixedWordWrap(source: string; fixedLen: Integer): string;
function strToStringList(source: string; fixedLen: Integer): TstringList;
function stringToStringListWithDelimiter(value: string; delimiter: Char): TstringList;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string);
function getMergedStrings(firstString: string; secondString: string; delimiter: string = EMPTY_STRING): string;

function checkIfEmailIsValid(email: string): boolean;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = true): boolean;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; raiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TCallBack; raiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TProcedure; raiseExceptionEnabled: boolean = false); overload;
procedure executeProcedure(myProcedure: TAnonymousMethod); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

implementation

uses
  KLib.Validate, KLib.Indy,
  Vcl.ExtCtrls,
  System.Zip, System.IOUtils, System.StrUtils, System.Character, System.RegularExpressions, System.Variants;

procedure deleteFilesInDirWithStartingFileName(dirName: string; startingFileName: string; fileType: string = EMPTY_STRING);
const
  IGNORE_CASE = true;
var
  _files: TstringList;
  _file: string;
  _fileName: string;
begin
  _files := getFileNamesListInDir(dirName, fileType);
  for _file in _files do
  begin
    _fileName := ExtractFileName(_file);
    if _fileName.StartsWith(startingFileName, IGNORE_CASE) then
    begin
      deleteFileIfExists(_file);
    end;
  end;
  FreeAndNil(_files);
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

function getTextFromFile(fileName: string): string;
var
  text: string;
  _stringList: TstringList;
begin
  _stringList := TstringList.Create;
  try
    _stringList.LoadFromFile(fileName);
    text := _stringList.Text;
  finally
    _stringList.Free;
  end;
  Result := text;
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
  path := IncludeTrailingPathDelimiter(path);
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
  _result := getCombinedPath(_currentDir, pathToCombine);
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
  _path := stringReplace(path, '\', '/', [rfReplaceAll, rfIgnoreCase]);
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

procedure unzipResource(nameResource: string; destinationDir: string);
const
  DELETE_ZIP_AFTER_UNZIP = TRUE;
var
  _tempZipFileName: string;
begin
  _tempZipFileName := getRandString + '.' + ZIP_TYPE;
  _tempZipFileName := getCombinedPath(destinationDir, _tempZipFileName);
  getResourceAsZIPFile(nameResource, _tempZipFileName);
  unzip(_tempZipFileName, destinationDir, DELETE_ZIP_AFTER_UNZIP);
end;

function getPNGResource(nameResource: string): TPngImage;
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

procedure getResourceAsEXEFile(nameResource: string; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, EXE_TYPE, destinationFileName);
end;

procedure getResourceAsZIPFile(nameResource: string; destinationFileName: string);
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

function getResourceAsString(resource: TResource): string;
var
  resourceStream: TResourceStream;
  _stringList: TstringList;
  resourceAsString: string;
begin
  resourceAsString := '';
  resourceStream := getResourceAsStream(resource);
  _stringList := TstringList.Create;
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

function checkRequiredFTPProperties(FTPCredentials: TFTPCredentials): boolean;
var
  _result: boolean;
begin
  with FTPCredentials do
  begin
    _result := (server <> EMPTY_STRING) and (credentials.username <> EMPTY_STRING) and (credentials.password <> EMPTY_STRING);
  end;

  Result := _result;
end;

function getValidTelephoneNumber(number: string): string;
const
  ERR_MSG = 'Telephone number is empty.';
var
  telephoneNumber: string;
  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  validateThatStringIsNotEmpty(_number, ERR_MSG);

  if _number[1] = '+' then
  begin
    telephoneNumber := '+';
  end;
  for i := 2 to length(_number) do
  begin
    if _number[i].IsNumber then
    begin
      telephoneNumber := telephoneNumber + _number[i];
    end;
  end;

  Result := telephoneNumber;
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

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): string;
const
  ERR_MSG = 'No files found.';
var
  fileName: string;
  _fileNamesList: TstringList;
begin
  _fileNamesList := getFileNamesListInDir(dirName, fileType, fullPath);
  if _fileNamesList.Count > 0 then
  begin
    fileName := _fileNamesList[0];
  end
  else
  begin
    fileName := EMPTY_STRING;
  end;
  FreeAndNil(_fileNamesList);
  if fileName = EMPTY_STRING then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  Result := fileName;
end;

function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): TstringList;
var
  fileNamesList: TstringList;
  _searchRec: TSearchRec;
  _mask: string;
  _fileExists: boolean;
  _fileName: string;
begin
  fileNamesList := TstringList.Create;
  _mask := getCombinedPath(dirName, '*');
  if fileType <> EMPTY_STRING then
  begin
    _mask := _mask + '.' + fileType;
  end;
  _fileExists := FindFirst(_mask, faAnyFile - faDirectory, _searchRec) = 0;
  while _fileExists do
  begin
    _fileName := _searchRec.Name;
    if fullPath then
    begin
      _fileName := getCombinedPath(dirName, _fileName);
    end;
    fileNamesList.Add(_fileName);
    _fileExists := FindNext(_searchRec) = 0;
  end;

  Result := fileNamesList;
end;

function getCombinedPath(path1: string; path2: string): string;
begin
  Result := TPath.Combine(path1, path2);
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
  DAYS_OF_WEEK: TArray<string> = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
    ];
var
  _indexDayOfWeek: integer;
  _nameDay: string;
begin
  _indexDayOfWeek := DayOfWeek(date) - 1;
  _nameDay := DAYS_OF_WEEK[_indexDayOfWeek];
  Result := _nameDay;
end;

function getCurrentDateTimeAsString: string;
begin
  Result := getDateTimeAsString(Now);
end;

function getDateTimeAsString(date: TDateTime): string;
var
  _date: string;
  _time: string;
  _dateTime: string;
begin
  _date := getDateAsString(date);
  _time := TimeToStr(date);
  _time := stringReplace(_time, ':', EMPTY_STRING, [rfReplaceAll, rfIgnoreCase]);
  _dateTime := _date + '_' + _time;
  Result := _dateTime;
end;

function getCurrentDateAsString: string;
begin
  Result := getDateAsString(Now);
end;

function getDateAsString(date: TDateTime): string;
var
  _date: string;
begin
  _date := DateToStr(date);
  _date := stringReplace(_date, '/', '_', [rfReplaceAll, rfIgnoreCase]);
  Result := _date;
end;

function getCurrentTimeStamp: string;
begin
  Result := getCurrentDateTimeAsStringWithFormatting(TIMESTAMP_FORMAT);
end;

function getCurrentDateTimeAsStringWithFormatting(formatting: string = DATE_FORMAT): string;
begin
  Result := getDateTimeAsStringWithFormatting(Now, formatting);
end;

function getDateTimeAsStringWithFormatting(value: TDateTime; formatting: string = DATE_FORMAT): string;
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := FormatDateTime(formatting, value);
  Result := _dateTimeAsStringWithFormatting;
end;

function getCurrentDateTime: TDateTime;
begin
  Result := Now;
end;

function getParsedXMLstring(mainString: string): string; //todo add to myString
var
  parsedXMLstring: string;
begin
  parsedXMLstring := mainString;
  parsedXMLstring := stringreplace(parsedXMLstring, '&', '&amp;', [rfreplaceall]);
  parsedXMLstring := stringreplace(parsedXMLstring, '"', '&quot;', [rfreplaceall]);
  parsedXMLstring := stringreplace(parsedXMLstring, '''', '&#39;', [rfreplaceall]);
  parsedXMLstring := stringreplace(parsedXMLstring, '<', '&lt;', [rfreplaceall]);
  parsedXMLstring := stringreplace(parsedXMLstring, '>', '&gt;', [rfreplaceall]);

  Result := parsedXMLstring;
end;

function getDoubleQuotedString(mainString: string): string;
begin
  Result := AnsiQuotedStr(mainString, '"');
end;

function getSingleQuotedString(mainString: string): string;
begin
  Result := AnsiQuotedStr(mainString, '''');
end;

function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer): string;
const
  ERR_MSG = 'Index out of range.';
var
  _result: string;
  _lenght: integer;
  _firstStringPart: string;
  _lastStringPart: string;
begin
  _lenght := Length(mainString);
  if (index > _lenght) or (index < 0) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  _firstStringPart := Copy(mainString, 0, index);
  _lastStringPart := Copy(mainString, index + 1, MaxInt);
  _result := _firstStringPart + insertedString + _lastStringPart;

  Result := _result;
end;

function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_string): string;
var
  stringWithoutLineBreaks: string;
begin
  stringWithoutLineBreaks := stringReplace(mainString, #13#10, substituteString, [rfReplaceAll]);
  stringWithoutLineBreaks := stringReplace(stringWithoutLineBreaks, #10, substituteString, [rfReplaceAll]);
  Result := stringWithoutLineBreaks;
end;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): TDate;
var
  _result: TDate;
begin
  _result := getCSVFieldFromStringAsDate(mainString, index, FormatSettings, delimiter);
  Result := _result;
end;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; formatSettings: TFormatSettings;
  delimiter: Char = SEMICOLON_DELIMITER): TDate;
var
  _fieldAsString: string;
  _result: TDate;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToDate(_fieldAsString, formatSettings);

  Result := _result;
end;

function getCSVFieldFromStringAsDouble(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): Double;
var
  _result: Double;
begin
  _result := getCSVFieldFromStringAsDouble(mainString, index, FormatSettings, delimiter);

  Result := _result;
end;

function getCSVFieldFromStringAsDouble(mainString: string; index: integer; formatSettings: TFormatSettings;
  delimiter: Char = SEMICOLON_DELIMITER): Double;
var
  _fieldAsString: string;
  _result: Double;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToFloat(_fieldAsString, formatSettings);

  Result := _result;
end;

function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
var
  _fieldAsString: string;
  _result: integer;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToInt(_fieldAsString);

  Result := _result;
end;

function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;
const
  ERR_MSG = 'Field index out of range.';
var
  _stringList: TstringList;
  _result: string;
begin
  _stringList := stringToStringListWithDelimiter(mainString, delimiter);
  try
    try
      _result := _stringList[index];
    except
      on E: Exception do
      begin
        raise Exception.Create(ERR_MSG);
      end;
    end;
  finally
    FreeAndNil(_stringList);
  end;

  Result := _result;
end;

function getNumberOfLinesInStrFixedWordWrap(source: string): integer;
var
  _stringList: TstringList;
  _result: integer;
begin
  _stringList := TstringList.Create;
  _stringList.Text := source;
  _result := _stringList.Count;
  FreeAndNil(_stringList);

  Result := _result;
end;

function strToStrFixedWordWrap(source: string; fixedLen: Integer): string;
var
  _stringList: TstringList;
  _text: string;
  _result: string;
begin
  _stringList := strToStringList(source, fixedLen);
  _text := _stringList.Text;
  FreeAndNil(_stringList);
  Delete(_text, length(_text), 1);
  _result := _text;

  Result := _result;
end;

function strToStringList(source: string; fixedLen: integer): TstringList;
var
  stringList: TstringList;
  i: Integer;
  _sourceLen: Integer;
begin
  stringList := TstringList.Create;
  stringList.LineBreak := #13;
  if fixedLen = 0 then
  begin
    fixedLen := Length(source) - 1;
  end;
  stringList.Capacity := (Length(source) div fixedLen) + 1;

  i := 1;
  _sourceLen := Length(source);

  while i <= _sourceLen do
  begin
    stringList.Add(Copy(source, i, fixedLen));
    Inc(i, fixedLen);
  end;

  result := stringList;
end;

function stringToStringListWithDelimiter(value: string; delimiter: Char): TstringList;
var
  _stringList: TstringList;
begin
  _stringList := TstringList.Create;
  _stringList.Clear;
  _stringList.Delimiter := delimiter;
  _stringList.StrictDelimiter := True;
  _stringList.DelimitedText := value;

  Result := _stringList;
end;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string);
var
  _startIndexDelimiter: integer;
  _endIndexDelimiter: integer;
  _lengthDestFirstString: integer;
  _lengthDestSecondString: integer;
begin
  _startIndexDelimiter := AnsiPos(delimiter, source);
  if _startIndexDelimiter > 0 then
  begin
    _endIndexDelimiter := _startIndexDelimiter + Length(delimiter);
    _lengthDestFirstString := _startIndexDelimiter - 1;
    _lengthDestSecondString := Length(source) - _endIndexDelimiter + 1;
    destFirstString := Copy(source, 0, _lengthDestFirstString);
    destSecondString := Copy(source, _endIndexDelimiter, _lengthDestSecondString);
  end
  else
  begin
    destFirstString := source;
    destSecondString := '';
  end;
end;

function getMergedStrings(firstString: string; secondString: string; delimiter: string = EMPTY_STRING): string;
begin
  Result := firstString + delimiter + secondString;
end;

function checkIfEmailIsValid(email: string): boolean;
var
  _result: boolean;
begin
  _result := TRegEx.IsMatch(email, REGEX_VALID_EMAIL);
  Result := _result;
end;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
const
  NO_CASE_SENSITIVE = false;
begin
  Result := checkIfMainStringContainsSubString(mainString, subString, NO_CASE_SENSITIVE);
end;

function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = true): boolean;
var
  _result: boolean;
begin
  if caseSensitiveSearch then
  begin
    _result := ContainsStr(mainString, subString);
  end
  else
  begin
    _result := ContainsText(mainString, subString);
  end;

  Result := _result;
end;

procedure tryToExecuteProcedure(myProcedure: TProcedure; raiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if raiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; raiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if raiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TCallBack; raiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if raiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
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

end.
