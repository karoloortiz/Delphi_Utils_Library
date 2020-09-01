unit KLib.Utils;

interface

uses
  System.SysUtils, System.Classes,
  PngImage,
  KLib.Types;

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

function fileExistsAndEmpty(filePath: string): Boolean;
procedure deleteFileIfExists(fileName: string);
function getDirExe: string;

procedure createHideDir(const path: string; forceDelete: boolean = false);
procedure deleteDirectory(const dirName: string);

procedure extractZip(zipFile: string; extractPath: string; forceDelete: boolean = false);

function MD5FileChecker(fileName: string; MD5: string): boolean;
function getMD5FileChecksum(const fileName: string): string;

function getPNGResource(nameResource: String): TPngImage;
function getResourceAsString(nameResource: String; typeResource: string): String;
function getResourceAsStream(nameResource: String; typeResource: string): TResourceStream;

function readStringWithEnvVariables(source: string): string;
function getIPAddress: string;

procedure downloadFile(downloadInfo: TDownloadInfo; forceDelete: boolean);

procedure executeProcedure(myProcedure: TProcedure); overload;
procedure executeProcedure(myProcedure: TCallBack); overload;

implementation

uses
  System.Zip, Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, Winapi.Winsock, Winapi.ShellAPI,
  IdGlobal, IdHash, IdHashMessageDigest,
  UrlMon;

const
  PNG_RESOURCE = 'PNG';

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
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

function getDirExe: string;
begin
  result := ExtractFileDir(ParamStr(0));
end;

procedure deleteDirectory(const dirName: string);
var
  FileOp: TSHFileOpStruct;
begin
  FillChar(FileOp, SizeOf(FileOp), 0);
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(DirName + #0); //double zero-terminated
  FileOp.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
  SHFileOperation(FileOp);
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

function getResourceAsString(nameResource: String; typeResource: string): String;
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

procedure downloadFile(downloadInfo: TDownloadInfo; forceDelete: boolean);
begin
  with downloadInfo do
  begin
    if forceDelete then
    begin
      deleteFileIfExists(fileName);
    end;
    if (URLDownloadToFile(nil, pChar(link), pchar(fileName), 0, nil) <> S_OK)
      or not(MD5FileChecker(fileName, md5)) then
    begin
      raise Exception.Create('Error downloading file.');
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
