unit KLib.Template.Cache;

interface

uses
  System.SysUtils, System.Classes,
  System.Generics.Collections,
  KLib.Template.Lexer;

type
  TTemplateCacheEntry = record
    tokens: TArray<TToken>;
    fileModTime: TDateTime;
  end;

  TCacheGetResult = record
    found: Boolean;
    tokens: TArray<TToken>;
  end;

  TTemplateCache = class
  private
    _lock: TMultiReadExclusiveWriteSynchronizer;
    _entries: TDictionary<string, TTemplateCacheEntry>;
  public
    constructor create;
    destructor Destroy; override;
    function getTokens(const path: string): TCacheGetResult;
    procedure setTokens(const path: string; const tokens: TArray<TToken>; modTime: TDateTime);
    procedure clear;
  end;

implementation

uses
  System.IOUtils;

constructor TTemplateCache.create;
begin
  inherited;
  _lock := TMultiReadExclusiveWriteSynchronizer.Create;
  _entries := TDictionary<string, TTemplateCacheEntry>.Create;
end;

destructor TTemplateCache.Destroy;
begin
  FreeAndNil(_lock);
  FreeAndNil(_entries);
  inherited;
end;

function TTemplateCache.getTokens(const path: string): TCacheGetResult;
var
  _entry: TTemplateCacheEntry;
  _normalPath: string;
  _foundInCache: Boolean;
  _fileUnchanged: Boolean;
begin
  _normalPath := LowerCase(path);
  _fileUnchanged := False;

  _lock.BeginRead;
  try
    _foundInCache := _entries.TryGetValue(_normalPath, _entry);
  finally
    _lock.EndRead;
  end;

  if _foundInCache then
  begin
    _fileUnchanged := TFile.Exists(path) and
      (TFile.GetLastWriteTime(path) = _entry.fileModTime);
  end;

  Result.found := _foundInCache and _fileUnchanged;
  if Result.found then
  begin
    Result.tokens := _entry.tokens;
  end
  else
  begin
    Result.tokens := nil;
  end;
end;

procedure TTemplateCache.setTokens(const path: string; const tokens: TArray<TToken>; modTime: TDateTime);
var
  _entry: TTemplateCacheEntry;
  _normalPath: string;
begin
  _normalPath := LowerCase(path);
  _entry.tokens := tokens;
  _entry.fileModTime := modTime;
  _lock.BeginWrite;
  try
    _entries.AddOrSetValue(_normalPath, _entry);
  finally
    _lock.EndWrite;
  end;
end;

procedure TTemplateCache.clear;
begin
  _lock.BeginWrite;
  try
    _entries.Clear;
  finally
    _lock.EndWrite;
  end;
end;

end.
