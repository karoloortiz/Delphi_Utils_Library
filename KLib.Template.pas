unit KLib.Template;

interface

uses
  KLib.Template.Filters,
  KLib.Template.Evaluator,
  System.Generics.Collections,
  System.Rtti;

type
  TTemplate = class
  public
    // Core rendering
    class function render<T>(const templateStr: string; const data: T): string;
    class function renderFromFile<T>(const templatePath: string; const data: T): string;

    // Cache control
    class procedure clearCache;
    class procedure precompile(const templatePath: string);

    // Search paths for include/extends
    class procedure addSearchPath(const path: string);
    class procedure clearSearchPaths;

    // Global variables (available in all render calls)
    class procedure setGlobal(const name: string; const value: string); overload;
    class procedure setGlobal(const name: string; const value: Integer); overload;
    class procedure clearGlobals;

    // Custom filters
    class procedure registerFilter(const name: string; fn: TFilterFn);
    class procedure registerFilterV(const name: string; fn: TFilterFnV);

    // Autoescape control
    class procedure setAutoescape(enabled: Boolean);

    // Undefined mode control
    class procedure setUndefinedMode(mode: TUndefinedMode);

    // Custom delimiters
    class procedure setDelimiters(const exprOpen: string; const exprClose: string;
      const stmtOpen: string; const stmtClose: string);

    // Sandbox mode
    class procedure setSandbox(enabled: Boolean);

  private
    class var _initialized: Boolean;
    class procedure ensureInit;
    class function renderInternal(const templateStr: string; const dataValue: TValue): string;
    class function renderFromFileInternal(const templatePath: string; const dataValue: TValue): string;
  end;

implementation

uses
  KLib.Template.Lexer,
  KLib.Template.Cache,
  KLib.FileSystem,
  System.Classes,
  System.SysUtils, System.IOUtils,
  System.SyncObjs;

var
  _searchPaths: TStringList;
  _cache: TTemplateCache;
  _globals: TDictionary<string, TValue>;
  _lock: TMultiReadExclusiveWriteSynchronizer;
  _autoescapeEnabled: Boolean;
  _undefinedMode: TUndefinedMode;
  _sandboxEnabled: Boolean;
  _delimExprOpen: string;
  _delimExprClose: string;
  _delimStmtOpen: string;
  _delimStmtClose: string;

class procedure TTemplate.ensureInit;
begin
  if _initialized then
    Exit;
  _lock.BeginWrite;
  try
    if _initialized then
      Exit;
    _searchPaths := TStringList.Create;
    _cache := TTemplateCache.Create;
    _globals := TDictionary<string, TValue>.Create;
    _initialized := True;
  finally
    _lock.EndWrite;
  end;
end;

class function TTemplate.renderInternal(const templateStr: string; const dataValue: TValue): string;
var
  _tokens: TArray<TToken>;
  _ctx: TEvaluateContext;
  _delim: TDelimiterConfig;
begin
  _lock.BeginRead;
  try
    if _delimExprOpen <> '' then
    begin
      _delim.exprOpen := _delimExprOpen;
      _delim.exprClose := _delimExprClose;
      _delim.stmtOpen := _delimStmtOpen;
      _delim.stmtClose := _delimStmtClose;
      _delim.commentOpen := '{#';
      _delim.commentClose := '#}';
      _tokens := tokenize(templateStr, _delim);
    end
    else
    begin
      _tokens := tokenize(templateStr);
    end;

    _ctx.templateName := '';
    _ctx.templateDir := '';
    _ctx.searchPaths := _searchPaths;
    _ctx.autoescapeEnabled := _autoescapeEnabled;
    _ctx.undefinedMode := _undefinedMode;
    _ctx.sandboxEnabled := _sandboxEnabled;
    _ctx.globals := _globals;

    Result := evaluate(_tokens, dataValue, _ctx);
  finally
    _lock.EndRead;
  end;
end;

class function TTemplate.renderFromFileInternal(const templatePath: string; const dataValue: TValue): string;
var
  _tokens: TArray<TToken>;
  _ctx: TEvaluateContext;
  _absPath: string;
  _modTime: TDateTime;
  _templateStr: string;
  _cacheResult: TCacheGetResult;
  _delim: TDelimiterConfig;
begin
  _lock.BeginRead;
  try
    _absPath := TPath.GetFullPath(templatePath);

    _cacheResult := _cache.getTokens(_absPath);
    if _cacheResult.found then
    begin
      _tokens := _cacheResult.tokens;
    end
    else
    begin
      _templateStr := getTextFromFile(_absPath);
      if _delimExprOpen <> '' then
      begin
        _delim.exprOpen := _delimExprOpen;
        _delim.exprClose := _delimExprClose;
        _delim.stmtOpen := _delimStmtOpen;
        _delim.stmtClose := _delimStmtClose;
        _delim.commentOpen := '{#';
        _delim.commentClose := '#}';
        _tokens := tokenize(_templateStr, _delim);
      end
      else
      begin
        _tokens := tokenize(_templateStr);
      end;
      _modTime := TFile.GetLastWriteTime(_absPath);
      _cache.setTokens(_absPath, _tokens, _modTime);
    end;

    _ctx.templateName := TPath.GetFileName(templatePath);
    _ctx.templateDir := TPath.GetDirectoryName(_absPath);
    _ctx.searchPaths := _searchPaths;
    _ctx.cache := _cache;
    _ctx.autoescapeEnabled := _autoescapeEnabled;
    _ctx.undefinedMode := _undefinedMode;
    _ctx.sandboxEnabled := _sandboxEnabled;
    _ctx.globals := _globals;

    Result := evaluate(_tokens, dataValue, _ctx);
  finally
    _lock.EndRead;
  end;
end;

class function TTemplate.render<T>(const templateStr: string; const data: T): string;
var
  _dataValue: TValue;
begin
  ensureInit;
  TValue.Make(@data, TypeInfo(T), _dataValue);

  Result := renderInternal(templateStr, _dataValue);
end;

class function TTemplate.renderFromFile<T>(const templatePath: string; const data: T): string;
var
  _dataValue: TValue;
begin
  ensureInit;
  TValue.Make(@data, TypeInfo(T), _dataValue);

  Result := renderFromFileInternal(templatePath, _dataValue);
end;

class procedure TTemplate.clearCache;
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _cache.clear;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.precompile(const templatePath: string);
var
  _absPath: string;
  _tokens: TArray<TToken>;
  _modTime: TDateTime;
begin
  ensureInit;
  _lock.BeginRead;
  try
    _absPath := TPath.GetFullPath(templatePath);
    if not TFile.Exists(_absPath) then
      Exit;
    _tokens := tokenize(TFile.ReadAllText(_absPath));
    _modTime := TFile.GetLastWriteTime(_absPath);
    _cache.setTokens(_absPath, _tokens, _modTime);
  finally
    _lock.EndRead;
  end;
end;

class procedure TTemplate.addSearchPath(const path: string);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    if _searchPaths.IndexOf(path) < 0 then
      _searchPaths.Add(path);
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.clearSearchPaths;
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _searchPaths.Clear;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.setGlobal(const name: string; const value: string);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _globals.AddOrSetValue(LowerCase(name), TValue.From<string>(value));
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.setGlobal(const name: string; const value: Integer);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _globals.AddOrSetValue(LowerCase(name), TValue.From<Integer>(value));
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.clearGlobals;
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _globals.Clear;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.registerFilter(const name: string; fn: TFilterFn);
begin
  KLib.Template.Filters.registerFilter(name, fn);
end;

class procedure TTemplate.registerFilterV(const name: string; fn: TFilterFnV);
begin
  KLib.Template.Filters.registerFilterV(name, fn);
end;

class procedure TTemplate.setAutoescape(enabled: Boolean);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _autoescapeEnabled := enabled;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.setUndefinedMode(mode: TUndefinedMode);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _undefinedMode := mode;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.setDelimiters(const exprOpen: string; const exprClose: string;
  const stmtOpen: string; const stmtClose: string);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _delimExprOpen := exprOpen;
    _delimExprClose := exprClose;
    _delimStmtOpen := stmtOpen;
    _delimStmtClose := stmtClose;
    _cache.clear;
  finally
    _lock.EndWrite;
  end;
end;

class procedure TTemplate.setSandbox(enabled: Boolean);
begin
  ensureInit;
  _lock.BeginWrite;
  try
    _sandboxEnabled := enabled;
  finally
    _lock.EndWrite;
  end;
end;

initialization
  TTemplate._initialized := False;
  _lock := TMultiReadExclusiveWriteSynchronizer.Create;

finalization
  FreeAndNil(_searchPaths);
  FreeAndNil(_cache);
  FreeAndNil(_globals);
  FreeAndNil(_lock);

end.
