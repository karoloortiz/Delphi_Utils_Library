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

unit KLib.FileSystem;

interface

uses
  KLib.Types, KLib.Constants,
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

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true; startingFileName: string = EMPTY_STRING): string;
function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING; fullPath: boolean = true; startingFileName: string = EMPTY_STRING): TStringList;

procedure appendToFileInNewLine(fileName: string; text: string; forceCreationFile: boolean = NOT_FORCE); overload;
procedure appendToFile(fileName: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE); overload;
procedure saveBase64ToFile(text: string; fileName: string);
procedure saveToFile(text: string; fileName: string); overload;
procedure saveToFile(text: string; fileName: string; encoding: TEncoding;
  forceOverwrite: boolean = FORCE_OVERWRITE); overload;

function checkMD5File(fileName: string; MD5: string): boolean;

procedure unzipResource(nameResource: string; destinationDir: string);
function getPNGResource(nameResource: string): TPngImage;
procedure getResourceAsExeFile(nameResource: string; destinationFileName: string);
procedure getResourceAsZipFile(nameResource: string; destinationFileName: string);
procedure getResourceAsYamlFile(nameResource: string; destinationFileName: string);
procedure getResourceAsHtmlFile(nameResource: string; destinationFileName: string);
procedure getResourceAsFile(resource: TResource; destinationFileName: string);
function getResourceAsString(resource: TResource): string;
function getResourceAsStream(resource: TResource): TResourceStream;

procedure unzip(zipFileName: string; destinationDir: string; deleteZipAfterUnzip: boolean = false);

function checkRequiredFTPProperties(FTPCredentials: TFTPCredentials): boolean;

implementation

uses
  KLib.Validate, KLib.Indy, KLib.FileSearchReplacer,
  KLib.StringUtils,
  System.Zip, System.IOUtils, System.StrUtils,
  System.NetEncoding;

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
var
  _files: TStringList;
  _file: string;
begin
  _files := getFileNamesListInDir(dirName, fileType, true, startingFileName);
  for _file in _files do
  begin
    deleteFileIfExists(_file);
  end;
  FreeAndNil(_files);
end;

procedure createEmptyFileIfNotExists(fileName: string);
begin
  if not checkIfFileExists(fileName) then
  begin
    createEmptyFile(fileName);
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
    FreeAndNil(_fileSearchReplacer);
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
    FreeAndNil(_stringList);
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
    try
      ForceDirectories(dirName);
    except
      on E: Exception do
      begin
        raise Exception.Create(ERR_MSG);
      end;
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

function getFirstFileNameInDir(dirName: string; fileType: string = EMPTY_STRING;
  fullPath: boolean = true; startingFileName: string = EMPTY_STRING): string;
const
  ERR_MSG = 'No files found.';
var
  fileName: string;

  _fileNamesList: TStringList;
begin
  _fileNamesList := getFileNamesListInDir(dirName, fileType, fullPath, startingFileName);
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

function getFileNamesListInDir(dirName: string; fileType: string = EMPTY_STRING;
  fullPath: boolean = true; startingFilename: string = EMPTY_STRING): TStringList;
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
  _mask := getCombinedPath(dirName, startingFileName + '*');
  if fileType <> EMPTY_STRING then
  begin
    _mask := _mask + '.' + fileType;
  end;
  _returnCode := FindFirst(_mask, faAnyFile - faDirectory, _searchRec);
  if ((_returnCode <> 0) AND (_returnCode <> 2) AND (_returnCode <> 18))
  then
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

procedure appendToFileInNewLine(fileName: string; text: string; forceCreationFile: boolean = NOT_FORCE);
begin
  appendToFile(fileName, text, forceCreationFile, FORCE);
end;

procedure appendToFile(fileName: string; text: string; forceCreationFile: boolean = NOT_FORCE;
  forceAppendInNewLine: boolean = NOT_FORCE);
var
  _text: string;
begin
  if forceCreationFile then
  begin
    createEmptyFileIfNotExists(fileName);
  end;
  _text := text;
  if (checkIfFileExistsAndIsNotEmpty(fileName)) then
  begin
    if (forceAppendInNewLine) then
    begin
      _text := sLineBreak + _text;
    end;
  end;

  TFile.AppendAllText(fileName, _text);
end;

procedure saveBase64ToFile(text: string; fileName: string);
var
  _bytes: TBytes;
  _stream: TBytesStream;
begin
  _bytes := TNetEncoding.Base64.DecodeStringToBytes(text);
  _stream := TBytesStream.Create(_bytes);
  try
    _stream.SaveToFile(fileName);
  finally
    FreeAndNil(_stream);
  end;
end;

procedure saveToFile(text: string; fileName: string);
begin
  saveToFile(text, fileName, TEncoding.UTF8);
end;

procedure saveToFile(text: string; fileName: string; encoding: TEncoding;
  forceOverwrite: boolean = FORCE_OVERWRITE);
var
  _stringList: TStringList;
  _parentDir: string;
begin
  _parentDir := getParentDir(fileName);
  createDirIfNotExists(_parentDir);
  try
    if (forceOverwrite) then
    begin
      deleteFileIfExists(fileName);
    end;
    _stringList := stringToTStringList(text);
    _stringList.SaveToFile(fileName, encoding);
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
  getResourceAsZipFile(nameResource, _tempZipFileName);
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
  FreeAndNil(_resourceStream);

  Result := resourceAsPNG;
end;

procedure _getResourceAsFile_(nameResource: string; typeResource: string; destinationFileName: string); forward;

procedure getResourceAsExeFile(nameResource: string; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, EXE_TYPE, destinationFileName);
end;

procedure getResourceAsZipFile(nameResource: string; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, ZIP_TYPE, destinationFileName);
end;

procedure getResourceAsYamlFile(nameResource: string; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, YAML_TYPE, destinationFileName);
end;

procedure getResourceAsHtmlFile(nameResource: string; destinationFileName: string);
begin
  _getResourceAsFile_(nameResource, HTML_TYPE, destinationFileName);
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
  FreeAndNil(_resourceStream);
  FreeAndNil(_stringList);

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
begin
  Result := (FTPCredentials.server <> EMPTY_STRING)
    and (FTPCredentials.credentials.username <> EMPTY_STRING)
    and (FTPCredentials.credentials.password <> EMPTY_STRING)
    and (FTPCredentials.port >= 0);
end;

initialization

// force linter to include code
if true then
begin
  try
    saveToFile('', '');
  except
    on E: Exception do
  end;
end;

end.
