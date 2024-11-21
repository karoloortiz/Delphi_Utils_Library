﻿{
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

unit KLib.Utils;

interface

uses
  KLib.Types, KLib.Constants, KLib.MyThread,
  Vcl.Imaging.pngimage,
  System.SysUtils, System.Classes;

procedure deleteFilesInDir(pathDir: string; const filesToKeep: array of string);
procedure deleteFilesInDirWithStartingFileName(dirName: string; startingFileName: string; fileType: string = EMPTY_STRING);
procedure createEmptyFileIfNotExists(filename: string);
procedure createEmptyFile(filename: string);
procedure deleteFileIfExists(fileName: string);
function checkIfFileExistsAndIsEmpty(fileName: string): boolean;
function checkIfFileExistsAndIsNotEmpty(fileName: string): boolean;
function checkIfFileIsEmpty(fileName: string): boolean;
function checkIfFileExistsInSystem32(filename: string): boolean;
function checkIfFileExists(fileName: string): boolean;
procedure replaceTextInFile(oldText: string; newText: string; filename: string; filenameOutput: string = EMPTY_STRING;
  replaceFlags: TReplaceFlags = [rfReplaceAll]);
function getTextFromFile(fileName: string): string;

function checkIfThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64): boolean;
function getFreeSpaceOnDrive(drive: char): int64;
function getIndexOfDrive(drive: char): integer;
function getDriveExe: char;
function getDirSize(path: string): int64;
procedure createDirIfNotExists(dirName: string);
function checkIfDirExists(dirName: string): boolean;

function checkIfIsLinuxSubDir(subDir: string; mainDir: string): boolean;
function getPathInLinuxStyle(path: string): string;

function checkIfIsSubDir(subDir: string; mainDir: string; trailingPathDelimiter: char = SPACE_STRING): boolean;
function getValidFullPath(fileName: string): string;
function checkIfIsAPath(path: string): boolean;
function getCombinedPath(path1: string; path2: string): string;
function getTempfolderPath: string;

function getParentDir(source: string): string;

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): string;
function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): TStringList;

procedure appendToFileInNewLine(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE); overload;
procedure appendToFile(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE); overload;
procedure saveToFile(source: string; fileName: string);

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

function getValidItalianTelephoneNumber(number: string): string;
function getValidTelephoneNumber(number: string): string;

function getRandString(size: integer = 5): string;

function getCurrentDayOfWeekAsString: string;
function getDayOfWeekAsString(date: TDateTime): string;
function getCurrentDateTimeAsString: string;
function getDateTimeAsString(date: TDateTime): string;
function getCurrentDateAsString: string;
function getDateAsString(date: TDateTime): string;
function getCurrentTimeStamp: string;
function getCurrentDateTimeWithFormattingAsString(formatting: string = DATE_FORMAT): string;
function getDateTimeWithFormattingAsString(value: TDateTime; formatting: string = DATE_FORMAT): string;
function getCurrentDateTime: TDateTime;

function getEscapedMySQLString(mainString: string): string;
function getHTTPGetEncodedUrl(url: string; paramList: TStringList): string;
function getEscapedHTMLString(mainString: string): string;
function getEscapedXMLString(mainString: string): string;
function getEscapedJSONString(mainString: string): string;
function getDoubleQuotedString(mainString: string): string;
function getSingleQuotedString(mainString: string): string;
function getQuotedString(mainString: string; quoteCharacter: Char): string;
function getDoubleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getSingleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getExtractedString(mainString: string; quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getDequotedString(mainString: string): string;
function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer;
  forceOverwriteIndexCharacter: boolean = NOT_FORCE_OVERWRITE): string;
function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_STRING): string;
function getStringWithFixedLength(value: string; fixedLength: integer): string;
function getStringFromStream(stream: TStream): string;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDate(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;

function getNumberOfLinesInStrFixedWordWrap(source: string): integer;
function stringToStrFixedWordWrap(source: string; fixedLen: Integer): string;
function stringToStringListWithFixedLen(source: string; fixedLen: Integer): TStringList;
function stringToStringListWithDelimiter(value: string; delimiter: Char): TStringList;
function stringToTStringList(source: string): TStringList;
function stringToVariantType(stringValue: string; destinationTypeAsString: string): Variant;

function arrayOfStringToTStringList(arrayOfStrings: array of string): TStringList;
function arrayOfVariantToTStringList(arrayOfVariant: Variant): TStringList;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string); overload;
procedure splitStrings(source: string; delimiterPosition: integer; delimiterLength: integer; var destFirstString: string; var destSecondString: string); overload;
function getMergedStrings(firstString: string; secondString: string; delimiter: string = EMPTY_STRING): string;

function checkIfEmailIsValid(email: string): boolean;
function checkIfRegexIsValid(text: string; regex: string): boolean;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): boolean;

function myStringReplace(mainString: string; OldPattern: array of string; NewPattern: array of string; Flags: TReplaceFlags): string; overload;
function myStringReplace(const SourceString, OldPattern, NewPattern: string; Flags: TReplaceFlags): string; overload;

function myAnsiPos(subString: string; mainString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): integer;

function getDoubleAsString(value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT): string;
function getFloatToStrDecimalSeparator: char;

function get_status_asString(status: TStatus): string;

procedure restartMyThread(var myThread: TMyThread);

//TODO refactor
function getBitValueOfWord(const sourceValue: Cardinal; const bitIndex: Byte): Boolean;
function getWordWithBitEnabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
function getWordWithBitDisabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
function getWordWithBitSetted(const sourceValue: Cardinal; const bitIndex: Byte; const bitValue: Boolean): Cardinal;

function getArrayOfAnonymousMethodsFromArrayOfMethods(_methods: KLib.Types.TArrayOfMethods): KLib.Types.TArrayOfAnonymousMethods;
function getAnonymousMethodsFromMethod(_method: KLib.Types.TMethod): KLib.Types.TAnonymousMethod;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; isRaiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TCallBack; isRaiseExceptionEnabled: boolean = false); overload;
procedure tryToExecuteProcedure(myProcedure: TProcedure; isRaiseExceptionEnabled: boolean = false); overload;
procedure executeProcedure(myProcedure: TAnonymousMethod); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

function checkIfVariantTypeIsEmpty(value: Variant; typeAsString: string): boolean;
function checkIfIsEmptyOrNull(value: Variant): boolean;
function myDefault(typeAsString: string): Variant;

function myIsDebuggerPresent: boolean;

implementation

uses
  KLib.Validate, KLib.Indy, KLib.FileSearchReplacer, KLib.Math,
  Vcl.ExtCtrls,
  System.Zip, System.IOUtils, System.StrUtils, System.Character, System.RegularExpressions, System.Variants, System.NetEncoding;

procedure deleteFilesInDir(pathDir: string; const filesToKeep: array of string);
var
  _fileNamesList: TStringList;
  _fileName: string;
  _nameOfFile: string;
  _keepFile: boolean;
begin
  validateThatDirExists(pathDir);
  _fileNamesList := getFileNamesListInDir(pathDir);
  try
    for _fileName in _fileNamesList do
    begin
      _nameOfFile := ExtractFileName(_fileName);
      _keepFile := MatchText(_nameOfFile, filesToKeep);
      if not _keepFile then
      begin
        deleteFileIfExists(_fileName);
      end;
    end;
  finally
    FreeAndNil(_fileNamesList);
  end;
end;

procedure deleteFilesInDirWithStartingFileName(dirName: string; startingFileName: string; fileType: string = EMPTY_STRING);
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
      deleteFileIfExists(_file);
    end;
  end;
  FreeAndNil(_files);
end;

procedure createEmptyFileIfNotExists(filename: string);
begin
  if not checkIfFileExists(filename) then
  begin
    createEmptyFile(filename);
  end;
end;
{$hints OFF}


procedure createEmptyFile(filename: string);
var
  _handle: THandle;
begin
  _handle := FileCreate(fileName);
  if _handle = INVALID_HANDLE_VALUE then
  begin
    raise Exception.Create('Error creating file: ' + fileName);
  end
  else
  begin
    FileClose(_handle);
  end;
end;
{$hints ON}


procedure deleteFileIfExists(fileName: string);
const
  ERR_MSG = 'Error deleting file.';
begin
  if checkIfFileExists(fileName) then
  begin
    if not DeleteFile(pchar(fileName)) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

function checkIfFileExistsAndIsEmpty(fileName: string): boolean;
var
  fileExistsAndIsEmpty: boolean;
begin
  fileExistsAndIsEmpty := checkIfFileExists(fileName) and checkIfFileIsEmpty(fileName);

  Result := fileExistsAndIsEmpty;
end;

function checkIfFileExistsAndIsNotEmpty(fileName: string): boolean;
var
  fileExistsAndIsNotEmpty: boolean;
begin
  fileExistsAndIsNotEmpty := checkIfFileExists(fileName) and (not checkIfFileIsEmpty(fileName));

  Result := fileExistsAndIsNotEmpty;
end;

function checkIfFileIsEmpty(fileName: string): boolean;
var
  fileIsEmpty: boolean;

  _file: file of Byte;
  _size: integer;
begin
  AssignFile(_file, fileName);
  Reset(_file);
  _size := FileSize(_file);
  fileIsEmpty := _size = 0;
  CloseFile(_file);

  Result := fileIsEmpty;
end;

function checkIfFileExistsInSystem32(filename: string): boolean;
var
  fileExistsInSystem32: boolean;

  _fileName: string;
  _filenameIsAPath: boolean;
begin
  _fileName := filename;
  _filenameIsAPath := checkIfIsAPath(_fileName);
  if _filenameIsAPath then
  begin
    validateThatIsWindowsSubDir(_fileName, WINDOWS_SYSTEM32_PATH);
  end
  else
  begin
    _fileName := getCombinedPath(WINDOWS_SYSTEM32_PATH, _fileName);
  end;

  fileExistsInSystem32 := checkIfFileExists(_fileName);

  Result := fileExistsInSystem32;
end;

function checkIfFileExists(fileName: string): boolean;
begin
  Result := FileExists(fileName);
end;

procedure replaceTextInFile(oldText: string; newText: string; filename: string; filenameOutput: string = EMPTY_STRING;
  replaceFlags: TReplaceFlags = [rfReplaceAll]);
var
  _fileSearchReplacer: TFileSearchReplacer;
begin
  _fileSearchReplacer := TFileSearchReplacer.Create(filename, filenameOutput);
  try
    _fileSearchReplacer.replace(oldText, newText, replaceFlags);
  finally
    _fileSearchReplacer.Free;
  end;
end;

function getTextFromFile(fileName: string): string;
var
  text: string;

  _stringList: TStringList;
begin
  _stringList := TStringList.Create;
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
  isSpaceAvailableOnDrive: boolean;

  _freeSpaceDrive: int64;
begin
  _freeSpaceDrive := getFreeSpaceOnDrive(drive);
  isSpaceAvailableOnDrive := _freeSpaceDrive > requiredSpaceInBytes;

  Result := isSpaceAvailableOnDrive;
end;

function getFreeSpaceOnDrive(drive: char): int64;
const
  ERR_MSG_INVALID_DRIVE = 'The drive is invalid.';
  ERR_MSG_DRIVE_READ_ONLY = 'The drive is read-only';
var
  freeSpaceOnDrive: int64;

  _indexOfDrive: integer;
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
  indexOfDrive: integer;

  _drive: string;
  _asciiIndex: integer;
begin
  _drive := uppercase(drive);
  _asciiIndex := integer(_drive[1]);
  if not((_asciiIndex >= ASCII_FIRST_ALPHABET_CHARACTER) and (_asciiIndex <= ASCII_LAST_ALPHABET_CHARACTER)) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  indexOfDrive := (_asciiIndex - ASCII_FIRST_ALPHABET_CHARACTER) + 1;

  Result := indexOfDrive;
end;

function getDriveExe: char;
var
  driveExe: char;

  _dirExe: string;
begin
  _dirExe := getDriveExe;
  driveExe := _dirExe[1];

  Result := driveExe;
end;

function getDirSize(path: string): int64;
var
  dirSize: int64;

  _searchRec: TSearchRec;
  _subDirSize: int64;
begin
  dirSize := 0;
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
          inc(dirSize, _subDirSize);
        end;
      end
      else
      begin
        inc(dirSize, _searchRec.size);
      end;
    until FindNext(_searchRec) <> 0;
    System.SysUtils.FindClose(_searchRec);
  end;

  Result := dirSize;
end;

procedure createDirIfNotExists(dirName: string);
const
  ERR_MSG = 'Error creating dir.';
begin
  if not checkIfDirExists(dirName) then
  begin
    if not CreateDir(dirName) then
    begin
      raise Exception.Create(ERR_MSG);
    end;
  end;
end;

function checkIfDirExists(dirName: string): boolean;
begin
  Result := DirectoryExists(dirName);
end;

function checkIfIsLinuxSubDir(subDir: string; mainDir: string): boolean;
var
  isSubDir: boolean;

  _subDir: string;
  _mainDir: string;
begin
  _subDir := getPathInLinuxStyle(subDir);
  _mainDir := getPathInLinuxStyle(mainDir);
  isSubDir := checkIfIsSubDir(_subDir, _mainDir, LINUX_PATH_DELIMITER);

  Result := isSubDir
end;

function getPathInLinuxStyle(path: string): string;
var
  pathInLinuxStyle: string;
begin
  pathInLinuxStyle := myStringReplace(path, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  Result := pathInLinuxStyle;
end;

function checkIfIsSubDir(subDir: string; mainDir: string; trailingPathDelimiter: char = SPACE_STRING): boolean;
var
  isSubDir: boolean;

  _subDir: string;
  _mainDir: string;
  _trailingPathDelimiter: char;
begin
  _subDir := LowerCase(subDir);
  _mainDir := LowerCase(mainDir);
  _trailingPathDelimiter := trailingPathDelimiter;
  if _trailingPathDelimiter = SPACE_STRING then
  begin
    _trailingPathDelimiter := PathDelim;
  end;

  if not(AnsiRightStr(_mainDir, 1) = _trailingPathDelimiter) then
  begin
    _mainDir := _mainDir + _trailingPathDelimiter;
  end;

  isSubDir := AnsiStartsStr(_mainDir, _subDir);

  Result := isSubDir;
end;

function getValidFullPath(fileName: string): string;
var
  path: string;
begin
  path := fileName;
  path := ExpandFileName(path);
  path := ExcludeTrailingPathDelimiter(path);

  Result := path;
end;

function checkIfIsAPath(path: string): boolean;
begin
  Result := ExtractFilePath(path) <> EMPTY_STRING;
end;

function getCombinedPath(path1: string; path2: string): string;
begin
  Result := TPath.Combine(path1, path2);
end;

function getTempfolderPath: string;
var
  path: string;
begin
  path := TPath.GetTempPath;
  path := ExcludeTrailingPathDelimiter(path);

  Result := path;
end;

function getParentDir(source: string): string;
var
  parentDir: string;
begin
  parentDir := getValidFullPath(source);
  parentDir := ExtractFilePath(parentDir);

  Result := parentDir;
end;

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): string;
const
  ERR_MSG = 'No files found.';
var
  fileName: string;

  _fileNamesList: TStringList;
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

function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true): TStringList;
var
  fileNamesList: TStringList;

  _searchRec: TSearchRec;
  _mask: string;
  _fileExists: boolean;
  _fileName: string;
  _returnCode: integer;
  _errorMsg: string;
begin
  fileNamesList := TStringList.Create;
  _mask := getCombinedPath(dirName, '*');
  if fileType <> EMPTY_STRING then
  begin
    _mask := _mask + '.' + fileType;
  end;
  _returnCode := FindFirst(_mask, faAnyFile - faDirectory, _searchRec);
  if (_returnCode <> 0) and (_returnCode <> 2) then
  begin
    _errorMsg := dirName + ' : ' + SysErrorMessage(_returnCode);
    raise Exception.Create(_errorMsg);
  end;
  _fileExists := _returnCode = 0;
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

procedure appendToFileInNewLine(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE);
begin
  appendToFile(fileName, text, forceCreationFile, FORCE);
end;

procedure appendToFile(filename: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE);
var
  _text: string;
begin
  if forceCreationFile then
  begin
    createEmptyFileIfNotExists(filename);
  end;
  _text := text;
  if (checkIfFileExistsAndIsNotEmpty(filename)) then
  begin
    if (forceAppendInNewLine) then
    begin
      _text := sLineBreak + _text;
    end;
  end;

  TFile.AppendAllText(filename, _text);
end;

procedure saveToFile(source: string; fileName: string);
var
  _stringList: TStringList;
begin
  try
    _stringList := stringToTStringList(source);
    _stringList.SaveToFile(fileName);
  finally
    FreeAndNil(_stringList);
  end;
end;

function checkMD5File(fileName: string; MD5: string): boolean;
var
  MD5CheckedStatus: boolean;

  _MD5ChecksumFile: string;
begin
  _MD5ChecksumFile := getMD5ChecksumFile(fileName);
  MD5CheckedStatus := (UpperCase(_MD5ChecksumFile) = UpperCase(MD5));

  Result := MD5CheckedStatus;
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
  resourceAsPNG: TPngImage;

  _resource: TResource;
  _resourceStream: TResourceStream;
begin
  with _resource do
  begin
    name := nameResource;
    _type := PNG_TYPE;
  end;
  _resourceStream := getResourceAsStream(_resource);
  resourceAsPNG := TPngImage.Create;
  resourceAsPNG.LoadFromStream(_resourceStream);
  _resourceStream.Free;

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
  _destinationFileName: string;
begin
  with _resource do
  begin
    name := nameResource;
    _type := typeResource;
  end;
  _destinationFileName := destinationFileName;
  if not LowerCase(_destinationFileName).EndsWith('.' + LowerCase(typeResource)) then
  begin
    _destinationFileName := _destinationFileName + '.' + LowerCase(typeResource);
  end;
  getResourceAsFile(_resource, _destinationFileName);
end;

procedure getResourceAsFile(resource: TResource; destinationFileName: string);
var
  _resourceStream: TResourceStream;
  _destinationDirPath: string;
begin
  _destinationDirPath := getParentDir(destinationFileName);
  validateThatDirExists(_destinationDirPath);

  _resourceStream := getResourceAsStream(resource);
  _resourceStream.SaveToFile(destinationFileName);
  _resourceStream.Free;
end;

function getResourceAsString(resource: TResource): string;
var
  resourceAsString: string;
  _resourceStream: TResourceStream;
  _stringList: TStringList;
begin
  resourceAsString := '';
  _resourceStream := getResourceAsStream(resource);
  _stringList := TStringList.Create;
  _stringList.LoadFromStream(_resourceStream);
  resourceAsString := _stringList.Text;
  _resourceStream.Free;

  Result := resourceAsString;
end;

function getResourceAsStream(resource: TResource): TResourceStream;
var
  resourceStream: TResourceStream;

  _errMsg: string;
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
      _errMsg := 'Not found a resource with name : ' + name + ' and type : ' + _type;
      raise Exception.Create(_errMsg);
    end;
  end;

  Result := resourceStream;
end;

procedure unzip(zipFileName: string; destinationDir: string; deleteZipAfterUnzip: boolean = false);
const
  ERR_MSG = 'Invalid zip file.';
begin
  if TZipFile.isvalid(zipFileName) then
  begin
    TZipFile.extractZipfile(zipFileName, destinationDir);
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
    _result := (server <> EMPTY_STRING) and (credentials.username <> EMPTY_STRING) and (credentials.password <> EMPTY_STRING)
      and (port >= 0);
  end;

  Result := _result;
end;

function getValidItalianTelephoneNumber(number: string): string;
var
  telephoneNumber: string;

  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  if _number = '' then
  begin
    telephoneNumber := '';
  end
  else
  begin
    if _number.StartsWith('0039') then
    begin
      _number := KLib.Utils.myStringReplace(_number, '0039', '+39', []);
    end;

    if not _number.StartsWith('+') then
    begin
      _number := '+39' + _number;
    end;

    if not _number.StartsWith('+39') then
    begin
      _number := myStringReplace(_number, '+', '+39', []);
    end;

    telephoneNumber := '+';
    for i := 2 to length(_number) do
    begin
      if _number[i].IsNumber then
      begin
        telephoneNumber := telephoneNumber + _number[i];
      end;
    end;
  end;

  Result := telephoneNumber;
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
  randString: string;

  _randCharacter: char;
  _randIndexOfAlphabet: integer;
  _lengthAlphabet: integer;
  i: integer;
begin
  randString := '';
  _lengthAlphabet := length(ALPHABET);
  for i := 1 to size do
  begin
    _randIndexOfAlphabet := random(_lengthAlphabet) + 1;
    _randCharacter := ALPHABET[_randIndexOfAlphabet];
    randString := randString + _randCharacter;
  end;

  Result := randString;
end;

function getCurrentDayOfWeekAsString: string;
var
  dayAsString: string;
begin
  dayAsString := getDayOfWeekAsString(Now);

  Result := dayAsString;
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
  dayAsString: string;
  _indexDayOfWeek: integer;
begin
  _indexDayOfWeek := DayOfWeek(date) - 1;
  dayAsString := DAYS_OF_WEEK[_indexDayOfWeek];

  Result := dayAsString;
end;

function getCurrentDateTimeAsString: string;
begin
  Result := getDateTimeAsString(Now);
end;

function getDateTimeAsString(date: TDateTime): string;
var
  dateTimeAsString: string;

  _date: string;
  _time: string;
begin
  _date := getDateAsString(date);
  _time := TimeToStr(date);
  _time := myStringReplace(_time, ':', EMPTY_STRING, [rfReplaceAll, rfIgnoreCase]);
  dateTimeAsString := _date + '_' + _time;

  Result := dateTimeAsString;
end;

function getCurrentDateAsString: string;
begin
  Result := getDateAsString(Now);
end;

function getDateAsString(date: TDateTime): string;
var
  dateAsString: string;
begin
  dateAsString := DateToStr(date);
  dateAsString := myStringReplace(dateAsString, '/', '_', [rfReplaceAll, rfIgnoreCase]);

  Result := dateAsString;
end;

function getCurrentTimeStamp: string;
begin
  Result := getCurrentDateTimeWithFormattingAsString(TIMESTAMP_FORMAT);
end;

function getCurrentDateTimeWithFormattingAsString(formatting: string = DATE_FORMAT): string;
begin
  Result := getDateTimeWithFormattingAsString(Now, formatting);
end;

function getDateTimeWithFormattingAsString(value: TDateTime; formatting: string = DATE_FORMAT): string;
var
  dateTimeAsStringWithFormatting: string;
begin
  dateTimeAsStringWithFormatting := FormatDateTime(formatting, value);

  Result := dateTimeAsStringWithFormatting;
end;

function getCurrentDateTime: TDateTime;
begin
  Result := Now;
end;

function getEscapedMySQLString(mainString: string): string;
begin
  Result := myStringReplace(mainString,
    ['\', #39, #34, #0, #10, #13, #26],
    ['\\', '\'#39, '\'#34, '\0', '\n', '\r', '\Z'],
    [rfReplaceAll]);
end;

function getHTTPGetEncodedUrl(url: string; paramList: TStringList): string;
var
  _param: string;
  _encodedUrl: string;
begin
  _encodedUrl := url + '?';
  for _param in paramList do
  begin
    _encodedUrl := _encodedUrl + '&' + _param;
  end;
  _encodedUrl := myStringReplace(_encodedUrl, '?&', '?', [rfReplaceAll]);

  Result := _encodedUrl;
end;

function getEscapedHTMLString(mainString: string): string;
begin
  Result := TNetEncoding.URL.Encode(mainString);
end;

function getEscapedXMLString(mainString: string): string;
begin
  Result := myStringReplace(mainString,
    ['&', '"', '''', '<', '>'],
    ['&amp;', '&quot;', '&#39;', '&lt;', '&gt;'],
    [rfreplaceall]);
end;

function getEscapedJSONString(mainString: string): string;

  procedure addChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 2, 1);
    Inc(AIndex, 2);
  end;

  procedure addUnicodeChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 6, 1);
    Inc(AIndex, 6);
  end;

var
  i, ix: Integer;
  AChar: Char;
begin
  Result := mainString;
  ix := 1;
  for i := 1 to System.Length(mainString) do
  begin
    AChar := mainString[i];
    case AChar of
      '/', '\', '"':
        begin
          System.Insert('\', Result, ix);
          Inc(ix, 2);
        end;
      #8: //backspace \b
        begin
          addChars('\b', Result, ix);
        end;
      #9:
        begin
          addChars('\t', Result, ix);
        end;
      #10:
        begin
          addChars('\n', Result, ix);
        end;
      #12:
        begin
          addChars('\f', Result, ix);
        end;
      #13:
        begin
          addChars('\r', Result, ix);
        end;
      #0 .. #7, #11, #14 .. #31:
        begin
          addUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
    else
      begin
        if Word(AChar) > 127 then
        begin
          addUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
        else
        begin
          Inc(ix);
        end;
      end;
    end;
  end;
end;

function getDoubleQuotedString(mainString: string): string;
begin
  Result := getQuotedString(mainString, '"');
end;

function getSingleQuotedString(mainString: string): string;
begin
  Result := getQuotedString(mainString, '''');
end;

function getQuotedString(mainString: string; quoteCharacter: Char): string;
begin
  Result := AnsiQuotedStr(mainString, quoteCharacter);
end;

function getDoubleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
begin
  Result := getExtractedString(mainString, '"', isRaiseExceptionEnabled);
end;

function getSingleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
begin
  Result := getExtractedString(mainString, '''', isRaiseExceptionEnabled);
end;

function getExtractedString(mainString: string; quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
const
  ERR_MSG = 'String not found.';
var
  extractedString: string;

  _lenghtQuotedString: integer;
  _lenghtMainString: integer;
  _firstIndex: integer;
  _lastIndex: integer;
begin
  extractedString := EMPTY_STRING;

  _lenghtQuotedString := quoteString.Length;
  _firstIndex := mainString.IndexOf(quoteString);
  if _firstIndex > -1 then
  begin
    _firstIndex := _firstIndex + _lenghtQuotedString;

    _lenghtMainString := Length(mainString);
    _lastIndex := mainString.LastIndexOf(quoteString, _lenghtMainString, _lenghtMainString - _firstIndex); //IGNORE FIRST OCCURENCE
    if _lastIndex > -1 then
    begin
      _lastIndex := _lastIndex - _lenghtQuotedString;
      extractedString := mainString.Substring(_lenghtQuotedString, _lastIndex);
    end;
  end;

  if (isRaiseExceptionEnabled) and (extractedString = EMPTY_STRING) then
  begin
    raise Exception.Create(ERR_MSG);
  end;

  Result := extractedString;
end;

function getDequotedString(mainString: string): string;
var
  dequotedString: string;
begin
  dequotedString := mainString;
  if ((mainString.Chars[0] = '"') and (mainString.Chars[dequotedString.Length - 1] = '"'))
    or ((mainString.Chars[0] = '''') and (mainString.Chars[dequotedString.Length - 1] = '''')) then
  begin
    dequotedString := mainString.Substring(1, mainString.Length - 2);
  end;

  Result := dequotedString;
end;

function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer;
  forceOverwriteIndexCharacter: boolean = NOT_FORCE_OVERWRITE): string;
const
  ERR_MSG = 'Index out of range.';
var
  mainStringWithSubStringInserted: string;

  _lenght: integer;
  _firstStringPart: string;
  _lastStringPart: string;
begin
  _lenght := Length(mainString);
  if (index > _lenght) or (index < 0) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  _firstStringPart := getStringWithFixedLength(mainString, index);
  if forceOverwriteIndexCharacter then
  begin
    Inc(index);
  end;
  _lastStringPart := Copy(mainString, index + 1, MaxInt);
  mainStringWithSubStringInserted := getMergedStrings(_firstStringPart, _lastStringPart, insertedString);

  Result := mainStringWithSubStringInserted;
end;

function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_STRING): string;
var
  stringWithoutLineBreaks: string;
begin
  stringWithoutLineBreaks := KLib.Utils.myStringReplace(mainString, #13#10, substituteString, [rfReplaceAll]);
  stringWithoutLineBreaks := myStringReplace(stringWithoutLineBreaks, #10, substituteString, [rfReplaceAll]);

  Result := stringWithoutLineBreaks;
end;

function getStringWithFixedLength(value: string; fixedLength: integer): string;
begin
  Result := Copy(value, 1, fixedLength);
end;

function getStringFromStream(stream: TStream): string;
var
  _string: string;

  _stringStream: TStringStream;
begin
  _string := '';

  if Assigned(stream) then
  begin
    _stringStream := TStringStream.Create('');
    try
      _stringStream.CopyFrom(stream, 0);
      _string := _stringStream.DataString;
    finally
      _stringStream.Free;
    end;
  end;

  Result := _string
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
  _result: TDate;

  _fieldAsString: string;
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
  _result: Double;

  _fieldAsString: string;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToFloat(_fieldAsString, formatSettings);

  Result := _result;
end;

function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
var
  _result: integer;

  _fieldAsString: string;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToInt(_fieldAsString);

  Result := _result;
end;

function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;
const
  ERR_MSG = 'Field index out of range.';
var
  _result: string;

  _stringList: TStringList;
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
  _result: integer;

  _stringList: TStringList;
begin
  _stringList := stringToTStringList(source);
  _result := _stringList.Count;
  FreeAndNil(_stringList);

  Result := _result;
end;

function stringToStrFixedWordWrap(source: string; fixedLen: Integer): string;
var
  _result: string;

  _stringList: TStringList;
  _text: string;
begin
  _stringList := stringToStringListWithFixedLen(source, fixedLen);
  _text := _stringList.Text;
  FreeAndNil(_stringList);
  Delete(_text, length(_text), 1);
  _result := _text;

  Result := _result;
end;

function stringToStringListWithFixedLen(source: string; fixedLen: integer): TStringList;
var
  stringList: TStringList;

  i: integer;
  _sourceLen: integer;
begin
  stringList := TStringList.Create;
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

  Result := stringList;
end;

function stringToStringListWithDelimiter(value: string; delimiter: Char): TStringList;
var
  stringList: TStringList;
begin
  stringList := TStringList.Create;
  stringList.Clear;
  stringList.Delimiter := delimiter;
  stringList.StrictDelimiter := True;
  stringList.DelimitedText := value;

  Result := stringList;
end;

function stringToTStringList(source: string): TStringList;
var
  stringList: TStringList;
begin
  stringList := TStringList.Create;
  stringList.Text := source;

  Result := stringList;
end;

function stringToVariantType(stringValue: string; destinationTypeAsString: string): Variant;
var
  value: Variant;
begin
  if destinationTypeAsString = 'string' then //TODO CREATE TTYPE ENUM
  begin
    value := stringValue;
  end
  else if destinationTypeAsString = 'Integer' then
  begin
    value := StrToInt(stringValue);
  end
  else if destinationTypeAsString = 'Double' then
  begin
    value := StrToFloat(stringValue);
  end
  else if destinationTypeAsString = 'Char' then
  begin
    value := stringValue.Chars[0];
  end
  else if destinationTypeAsString = 'Boolean' then
  begin
    value := StrToBool(stringValue);
  end;

  Result := value;
end;

function arrayOfStringToTStringList(arrayOfStrings: array of string): TStringList;
var
  stringList: TStringList;

  _string: string;
begin
  stringList := TStringList.Create;
  for _string in arrayOfStrings do
  begin
    stringList.Add(_string);
  end;

  Result := stringList;
end;

function arrayOfVariantToTStringList(arrayOfVariant: Variant): TStringList;
var
  fieldStringList: TStringList;

  _highBound: integer;
  i: integer;
begin
  fieldStringList := TStringList.Create;

  _highBound := VarArrayHighBound(arrayOfVariant, 1);
  for i := VarArrayLowBound(arrayOfVariant, 1) to _highBound do
  begin
    fieldStringList.Add(arrayOfVariant[i]);
  end;

  Result := fieldStringList;
end;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string);
var
  _delimiterPosition: integer;
  _delimiterLength: integer;
begin
  _delimiterPosition := myAnsiPos(delimiter, source);
  _delimiterLength := Length(delimiter);
  splitStrings(source, _delimiterPosition, _delimiterLength, destFirstString, destSecondString);
end;

procedure splitStrings(source: string; delimiterPosition: integer; delimiterLength: integer; var destFirstString: string; var destSecondString: string);
var
  _lenghtSource: integer;
  _lengthDestSecondString: integer;
  _lastPositionOfDelimiter: integer;
begin
  _lenghtSource := Length(source);
  _lastPositionOfDelimiter := delimiterPosition + delimiterLength;
  if _lenghtSource > _lastPositionOfDelimiter then
  begin
    _lengthDestSecondString := _lenghtSource - _lastPositionOfDelimiter;
    destFirstString := Copy(source, 0, delimiterPosition - 1);
    destSecondString := Copy(source, _lastPositionOfDelimiter + 1, _lengthDestSecondString);
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
  emailIsValid: boolean;
begin
  emailIsValid := TRegEx.IsMatch(email, REGEX_VALID_EMAIL);

  Result := emailIsValid;
end;

function checkIfRegexIsValid(text: string; regex: string): boolean;
begin
  Result := TRegEx.IsMatch(text, regex);
end;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
begin
  Result := checkIfMainStringContainsSubString(mainString, subString, NOT_CASE_SENSITIVE);
end;

function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): boolean;
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

function myStringReplace(mainString: string; OldPattern: array of string; NewPattern: array of string; Flags: TReplaceFlags): string;
var
  stringReplaced: string;
  i: integer;
begin
  Assert(Length(OldPattern) = (Length(NewPattern)));
  stringReplaced := mainString;
  for i := Low(OldPattern) to High(OldPattern) do
  begin
    stringReplaced := KLib.Utils.myStringReplace(stringReplaced, OldPattern[i], NewPattern[i], Flags);
  end;

  Result := stringReplaced;
end;

function myStringReplace(const SourceString, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
  Result := System.SysUtils.StringReplace(SourceString, OldPattern, NewPattern, Flags);
end;

function myAnsiPos(subString: string; mainString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): integer;
var
  _subString: string;
  _mainString: string;
begin
  if caseSensitiveSearch then
  begin
    _subString := subString;
    _mainString := mainString;
  end
  else
  begin
    _subString := UpperCase(subString);
    _mainString := UpperCase(mainString);
  end;

  Result := AnsiPos(_subString, _mainString);
end;

function getDoubleAsString(value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT): string;
var
  doubleAsString: string;
  _FloatToStrDecimalSeparator: char;
begin
  doubleAsString := FloatToStr(value);
  _FloatToStrDecimalSeparator := getFloatToStrDecimalSeparator;
  doubleAsString := myStringReplace(doubleAsString, _FloatToStrDecimalSeparator, decimalSeparator, [rfReplaceAll]);

  Result := doubleAsString;
end;

function getFloatToStrDecimalSeparator: char;
const
  VALUE_WITH_DECIMAL_SEPARATOR = 0.1;
  DECIMAL_SEPARATOR_INDEX = 2;
var
  doubleAsString: string;
begin
  doubleAsString := FloatToStr(VALUE_WITH_DECIMAL_SEPARATOR);

  Result := doubleAsString[DECIMAL_SEPARATOR_INDEX];
end;

function get_status_asString(status: TStatus): string;
var
  status_asString: string;
begin
  case status of
    TStatus._null:
      status_asString := '_null';
    TStatus.created:
      status_asString := 'created';
    TStatus.stopped:
      status_asString := 'stopped';
    TStatus.paused:
      status_asString := 'paused';
    TStatus.running:
      status_asString := 'running';
  end;

  Result := status_asString;
end;

procedure restartMyThread(var myThread: TMyThread);
var
  _tempThread: TMyThread;
begin
  _tempThread := myThread.getACopyMyThread;
  FreeAndNil(myThread);
  myThread := _tempThread;
  myThread.myStart(RAISE_EXCEPTION_DISABLED);
end;

//get a particular bit value
function getBitValueOfWord(const sourceValue: Cardinal; const bitIndex: Byte): Boolean;
begin
  Result := (sourceValue and (1 shl bitIndex)) <> 0;
end;

//set a particular bit as 1
function getWordWithBitEnabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal; //TODO refactor
begin
  Result := getWordWithBitSetted(sourceValue, bitIndex, true);
end;

//set a particular bit as 0
function getWordWithBitDisabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
begin
  Result := getWordWithBitSetted(sourceValue, bitIndex, false);
end;

//enable or disable a bit
function getWordWithBitSetted(const sourceValue: Cardinal; const bitIndex: Byte; const bitValue: Boolean): Cardinal;
begin
  Result := (sourceValue or (1 shl bitIndex)) xor (Cardinal(not bitValue) shl bitIndex);
end;

function getArrayOfAnonymousMethodsFromArrayOfMethods(_methods: KLib.Types.TArrayOfMethods): KLib.Types.TArrayOfAnonymousMethods;
var
  arrayOfAnonymousMethods: TArrayOfAnonymousMethods;

  _lengthOfMethods: integer;
  i: integer;
begin
  _lengthOfMethods := Length(_methods);
  SetLength(arrayOfAnonymousMethods, _lengthOfMethods);

  for i := 0 to _lengthOfMethods - 1 do
  begin
    arrayOfAnonymousMethods[i] := getAnonymousMethodsFromMethod(_methods[i]);
  end;

  Result := arrayOfAnonymousMethods;
end;

function getAnonymousMethodsFromMethod(_method: KLib.Types.TMethod): KLib.Types.TAnonymousMethod;
begin
  Result :=
      procedure
    begin
      _method;
    end;
end;

procedure tryToExecuteProcedure(myProcedure: TProcedure; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TAnonymousMethod; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

procedure tryToExecuteProcedure(myProcedure: TCallBack; isRaiseExceptionEnabled: boolean = false);
begin
  try
    executeProcedure(myProcedure);
  except
    on E: Exception do
    begin
      if isRaiseExceptionEnabled then
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

function checkIfVariantTypeIsEmpty(value: Variant; typeAsString: string): boolean;
var
  isEmpty: boolean;

  _emptyValue: variant;
begin
  _emptyValue := myDefault(typeAsString);
  isEmpty := value = _emptyValue;

  Result := isEmpty;
end;

function checkIfIsEmptyOrNull(value: Variant): boolean;
begin
  Result := VarIsClear(value) or VarIsEmpty(value) or VarIsNull(value) or (VarCompareValue(value, Unassigned) = vrEqual);
  if (not Result) and VarIsStr(value) then
  begin
    Result := value = '';
  end;
end;

function myDefault(typeAsString: string): Variant;
var
  value: Variant;
begin
  if typeAsString = 'string' then
  begin
    value := Default (string);
  end
  else if typeAsString = 'Integer' then
  begin
    value := Default (Integer);
  end
  else if typeAsString = 'Double' then
  begin
    value := Default (Double);
  end
  else if typeAsString = 'Char' then
  begin
    value := Default (Char);
  end
  else if typeAsString = 'Boolean' then
  begin
    value := Default (Boolean);
  end;

  Result := value;
end;

function myIsDebuggerPresent: boolean;
begin
  Result := System.DebugHook <> 0;
end;

end.
