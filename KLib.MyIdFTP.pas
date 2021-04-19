unit KLib.MyIdFTP;

interface

uses
  IdFTP,
  KLib.Types, KLib.Constants;

type
  TMyIdFTP = class(TIdFTP)
  public
    constructor create(FTPCredentials: TFTPCredentials); overload;
    procedure put(sourceFileName: string; targetFileName: string; force: boolean = FORCE_OVERWRITE); overload;
    procedure deleteFileIfExists(filename: string);
    function checkIfFileExists(filename: string): boolean;
  end;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
function getMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;

implementation

uses
  KLib.Utils;

constructor TMyIdFTP.create(FTPCredentials: TFTPCredentials);
begin
  Self := getValidMyIdFTP(FTPCredentials);
end;

procedure TMyIdFTP.put(sourceFileName: string; targetFileName: string; force: boolean = FORCE_OVERWRITE);
const
  AAppend: Boolean = False;
  AStartPos = -1;
begin
  if force then
  begin
    deleteFileIfExists(targetFileName);
  end;
  inherited Put(sourceFileName, targetFileName, AAppend, AStartPos);
end;

procedure TMyIdFTP.deleteFileIfExists(filename: string);
var
  _existsFile: boolean;
begin
  _existsFile := checkIfFileExists(filename);
  if _existsFile then
  begin
    Delete(filename);
  end;
end;

function TMyIdFTP.checkIfFileExists(filename: string): boolean;
var
  existsFile: boolean;
  i: integer;
begin
  List('*', false); //TODO https://stackoverflow.com/questions/30867501/delphi-bug-in-indy-ftp-list-method

  existsFile := false;
  i := 0;
  while not existsFile and (i <= DirectoryListing.Count - 1) do
  begin
    existsFile := DirectoryListing[i].FileName = fileName;
    inc(i);
  end;
  result := existsFile;
end;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
begin
  Result := TMyIdFTP(getValidIdFTP(FTPCredentials));
end;

function getMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
begin
  Result := TMyIdFTP(getIdFTP(FTPCredentials));
end;

end.
