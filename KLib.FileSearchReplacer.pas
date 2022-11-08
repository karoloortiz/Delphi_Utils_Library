unit KLib.FileSearchReplacer;

interface

uses
  KLib.Constants,
  System.Classes, System.SysUtils;

type
  TFileSearchReplacer = class
  private
    sourceFile: TFileStream;
    tempFile: TFileStream;
    encoding: TEncoding;
    customFilenameOutputEnabled: boolean;
    filenameOutput: string;
  public
    constructor Create(const fileName: string; const filenameOutput: string = EMPTY_STRING);

    procedure replace(const oldText: string; const newText: string; ReplaceFlags: TReplaceFlags = []);

    destructor Destroy; override;
  end;

implementation

uses
  KLib.Math, KLib.Validate, KLib.Utils,
  System.IOUtils, System.StrUtils;

constructor TFileSearchReplacer.Create(const fileName: string; const filenameOutput: string = EMPTY_STRING);
var
  _tmpFileName: string;
begin
  inherited Create;

  validateThatFileExists(fileName);

  if filenameOutput = EMPTY_STRING then
  begin
    Self.filenameOutput := fileName;
  end
  else
  begin
    Self.filenameOutput := filenameOutput;
  end;
  Self.sourceFile := TFileStream.Create(fileName, fmOpenReadWrite);
  Self.customFilenameOutputEnabled := Self.filenameOutput <> fileName;
  _tmpFileName := ChangeFileExt(fileName, '.TFileSearchReplaceTemp');

  Self.tempFile := TFileStream.Create(_tmpFileName, fmCreate);
end;

procedure TFileSearchReplacer.replace(const oldText: string; const newText: string;
  ReplaceFlags: TReplaceFlags = []);
  procedure CopyPreamble;
  var
    _preambleSize: Integer;
    _preambleBuf: TBytes;
  begin
    // Copy Encoding preamble
    SetLength(_preambleBuf, 100);
    sourceFile.Read(_preambleBuf, Length(_preambleBuf));
    sourceFile.Seek(0, soBeginning);

    _preambleSize := TEncoding.GetBufferEncoding(_preambleBuf, encoding);
    if _preambleSize <> 0 then
    begin
      tempFile.CopyFrom(sourceFile, _preambleSize);
    end;
  end;

  function getLastIndex(const Str: string; SubStr: string; caseSensitiveSearch: boolean): Integer;
  var
    i: Integer;
    _tmpSubStr: string;
    _tmpStr: string;
  begin
    _tmpStr := Str;
    _tmpSubStr := SubStr;

    if not caseSensitiveSearch then
    begin
      _tmpStr := UpperCase(Str);
      _tmpSubStr := UpperCase(SubStr);
    end;

    i := Pos(_tmpSubStr, _tmpStr);
    Result := i;
    while i > 0 do
    begin
      i := PosEx(_tmpSubStr, _tmpStr, i + 1);
      if i > 0 then
      begin
        Result := i;
      end;
    end;
    if Result > 0 then
    begin
      Inc(Result, Length(_tmpSubStr) - 1);
    end;
  end;

  procedure parseBuffer(bufferOfBytes: TBytes; var isReplaced: Boolean);
  var
    i: Integer;
    ReadedBufLen: Integer;
    BufStr: string;
    DestBytes: TBytes;
    _lastIndex: Integer;
  begin
    if isReplaced and (not(rfReplaceAll in ReplaceFlags)) then
    begin
      tempFile.Write(bufferOfBytes, Length(bufferOfBytes));
      Exit;
    end;

    // 1. Get chars from buffer
    ReadedBufLen := 0;
    for i := Length(bufferOfBytes) downto 0 do
      if encoding.GetCharCount(bufferOfBytes, 0, i) <> 0 then
      begin
        ReadedBufLen := i;
        Break;
      end;
    if ReadedBufLen = 0 then
      raise EEncodingError.Create('Cant convert bytes to str');

    sourceFile.Seek(ReadedBufLen - Length(bufferOfBytes), soCurrent);

    BufStr := encoding.GetString(bufferOfBytes, 0, ReadedBufLen);
    if rfIgnoreCase in ReplaceFlags then
    begin
      isReplaced := ContainsText(BufStr, oldText);
    end
    else
    begin
      isReplaced := ContainsStr(BufStr, oldText);
    end;

    if isReplaced then
    begin
      _lastIndex := getLastIndex(BufStr, oldText, not(rfIgnoreCase in ReplaceFlags));
      _lastIndex := getMax(_lastIndex, Length(BufStr) - Length(oldText) + 1);
    end
    else
    begin
      _lastIndex := Length(BufStr);
    end;

    SetLength(BufStr, _lastIndex);
    sourceFile.Seek(encoding.GetByteCount(BufStr) - ReadedBufLen, soCurrent);

    BufStr := StringReplace(BufStr, oldText, newText, ReplaceFlags);
    DestBytes := encoding.GetBytes(BufStr);
    tempFile.Write(DestBytes, Length(DestBytes));
  end;

var
  _bufferBytes: TBytes;
  _bufferLenght: Integer;
  bReplaced: Boolean;

  _sourceSize: int64;
begin
  sourceFile.Seek(0, soBeginning);
  tempFile.Size := 0;
  CopyPreamble;

  _sourceSize := sourceFile.Size;
  _bufferLenght := getMax(encoding.GetByteCount(oldText) * 5, 2048);
  _bufferLenght := getMax(encoding.GetByteCount(newText) * 5, _bufferLenght);
  SetLength(_bufferBytes, _bufferLenght);

  bReplaced := False;
  while sourceFile.Position < _sourceSize do
  begin
    _bufferLenght := sourceFile.Read(_bufferBytes, Length(_bufferBytes));
    SetLength(_bufferBytes, _bufferLenght);
    parseBuffer(_bufferBytes, bReplaced);
  end;

  if not customFilenameOutputEnabled then
  begin
    sourceFile.Size := 0;
    sourceFile.CopyFrom(tempFile, 0);
  end;
end;

destructor TFileSearchReplacer.Destroy;
var
  _tempFileName: string;
begin
  if Assigned(tempFile) then
  begin
    _tempFileName := tempFile.FileName;
  end;

  FreeAndNil(tempFile);
  FreeAndNil(sourceFile);

  if (not customFilenameOutputEnabled) and (_tempFileName <> EMPTY_STRING) then
  begin
    TFile.Delete(_tempFileName);
  end
  else
  begin
    deleteFileIfExists(filenameOutput);
    RenameFile(_tempFileName, filenameOutput);
  end;

  inherited;
end;

end.
