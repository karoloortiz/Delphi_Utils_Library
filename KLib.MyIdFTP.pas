unit KLib.MyIdFTP;

interface

uses
  IdFTP,
  KLib.Types, KLib.Constants;

type
  TMyIdFTP = class(TIdFTP)
  public
    defaultDir: string;
    constructor create(FTPCredentials: TFTPCredentials); overload;
    procedure Connect; overload; override;
    procedure put(sourceFileName: string; targetFileName: string; force: boolean = NOT_FORCE_OVERWRITE); overload;
    procedure deleteFileIfExists(filename: string);
    function checkIfFileExists(filename: string): boolean;
    // todo add destructor???
  end;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;

implementation

uses
  KLib.Utils;

function getValidMyIdFTP(FTPCredentials: TFTPCredentials): TMyIdFTP;
var
  _IdFTP: TIdFTP;
  connection: TMyIdFTP;
begin
  _IdFTP := getValidIdFTP(FTPCredentials);
  connection := TMyIdFTP(_IdFTP);
  connection.defaultDir := FTPCredentials.pathFTPDir;
  Result := connection;
end;

constructor TMyIdFTP.create(FTPCredentials: TFTPCredentials);
var
  _IdFTP: TIdFTP;
begin
  _IdFTP := getValidIdFTP(FTPCredentials);
  self := TMyIdFTP(_IdFTP);
  defaultDir := FTPCredentials.pathFTPDir;
end;

procedure TMyIdFTP.Connect;
begin
  inherited;
  if defaultDir <> '' then
  begin
    ChangeDir(defaultDir);
  end;
end;

procedure TMyIdFTP.put(sourceFileName: string; targetFileName: string; force: boolean = NOT_FORCE_OVERWRITE);
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

end.
