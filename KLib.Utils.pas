unit KLib.Utils;

interface

uses
  System.SysUtils, Winsock, ShellAPI, System.Zip,
  Winapi.Messages, System.Classes, Winapi.Windows, Vcl.ExtCtrls, PngImage;

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TProcedureOfObject = procedure of object;

  TAsyncifyProcedureReply = record
    handle: THandle;
    msg_resolve: Cardinal;
    msg_reject: Cardinal;
  end;

function getDirExe: string;
procedure deleteDirectory(const dirName: string);
function extractZip(ZipFile: string; ExtractPath: string; delete_file: boolean = false): boolean;

function getPNGResource(nameResource: String): TPngImage;
function getResourceAsString(nameResource: String; typeResource: string): String;
function getResourceAsStream(nameResource: String; typeResource: string): TResourceStream;

function readStringWithEnvVariables(source: string): string;
function getIPAddress: string;
procedure asyncifyProcedure(myProcedureWithThrowException: TProcedureOfObject; reply: TAsyncifyProcedureReply);

implementation

const
  PNG_RESOURCE = 'PNG';

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
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

function extractZip(ZipFile, ExtractPath: string; delete_file: boolean = false): boolean;
begin
  if tzipfile.isvalid(zipfile) then
  begin
    tzipfile.extractZipfile(zipfile, extractpath);
    if (delete_file) then
    begin
      System.SysUtils.deletefile(zipfile);
    end;
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

procedure asyncifyProcedure(myProcedureWithThrowException: TProcedureOfObject; reply: TAsyncifyProcedureReply);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        myProcedureWithThrowException;
        PostMessage(reply.handle, reply.msg_resolve, 0, 0);
      except
        on E: Exception do
        begin
          PostMessage(reply.handle, reply.msg_reject, 0, 0);
        end;
      end;
    end).Start;
end;

end.
