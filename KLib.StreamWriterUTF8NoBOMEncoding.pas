unit KLib.StreamWriterUTF8NoBOMEncoding;

interface

uses
  System.SysUtils, System.Classes;

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TStreamWriterUTF8NoBOMEncoding = class(TStreamWriter)
  private
    _UTF8NoBOM: TUTF8NoBOMEncoding;
  public
    constructor Create(fileName: string; newLine: string = slineBreak); overload;
    destructor Destroy; override;
  end;

implementation

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

constructor TStreamWriterUTF8NoBOMEncoding.Create(fileName: string; newLine: string = slineBreak);
const
  DISABLE_APPEND = false;
begin
  Self._UTF8NoBOM := TUTF8NoBOMEncoding.Create;
  inherited Create(fileName, DISABLE_APPEND, _UTF8NoBOM);
  Self.NewLine := newLine;
end;

destructor TStreamWriterUTF8NoBOMEncoding.Destroy;
begin
  inherited;
  FreeAndNil(_UTF8NoBOM);
end;

end.
