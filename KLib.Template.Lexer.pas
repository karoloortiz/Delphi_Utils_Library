unit KLib.Template.Lexer;

interface

type
  TTokenKind = (tkText, tkOutput, tkStatement, tkComment);

  TToken = record
    kind: TTokenKind;
    value: string;
    line: Integer;
    col: Integer;
  end;

  TLineCol = record
    line: Integer;
    col: Integer;
  end;

  TDelimiterConfig = record
    exprOpen: string;
    exprClose: string;
    stmtOpen: string;
    stmtClose: string;
    commentOpen: string;
    commentClose: string;
  end;

function tokenize(const templateStr: string): TArray<TToken>; overload;
function tokenize(const templateStr: string; const delimiters: TDelimiterConfig): TArray<TToken>; overload;

function defaultDelimiters: TDelimiterConfig;

// Pure utility: computes 1-based line and column for a byte position in a string.
// Exposed here so ETemplateError construction and other units can reuse it.
function computeLineCol(const s: string; pos: Integer): TLineCol;

implementation

uses
  System.SysUtils;

// Internal scan result — only used inside tokenize
type
  TScanResult = record
    found: Boolean;
    tagStart: Integer;
    openTag: string;
    closeTag: string;
    kind: TTokenKind;
    trimOpen: Boolean;
    trimClose: Boolean;
  end;

  TCloseResult = record
    pos: Integer;     // -1 if not found
    trimClose: Boolean;
  end;

function computeLineCol(const s: string; pos: Integer): TLineCol;
var
  i: Integer;
begin
  Result.line := 1;
  Result.col := 1;
  for i := 1 to pos - 1 do
  begin
    if s[i] = #10 then
    begin
      Inc(Result.line);
      Result.col := 1;
    end
    else
    begin
      Inc(Result.col);
    end;
  end;
end;

function defaultDelimiters: TDelimiterConfig;
begin
  Result.exprOpen := '{{';
  Result.exprClose := '}}';
  Result.stmtOpen := '{%';
  Result.stmtClose := '%}';
  Result.commentOpen := '{#';
  Result.commentClose := '#}';
end;

function scanForNextTagCustom(const s: string; startPos: Integer;
  const delim: TDelimiterConfig): TScanResult;
var
  i: Integer;
begin
  Result.found := False;
  i := startPos;
  while i <= Length(s) - 1 do
  begin
    // Check expression open
    if (i + Length(delim.exprOpen) - 1 <= Length(s)) and
       (Copy(s, i, Length(delim.exprOpen)) = delim.exprOpen) then
    begin
      Result.found := True;
      Result.tagStart := i;
      Result.kind := tkOutput;
      Result.openTag := delim.exprOpen;
      Result.closeTag := delim.exprClose;
      Result.trimOpen := False;
      Result.trimClose := False;
      // Check for trim marker
      if (i + Length(delim.exprOpen) <= Length(s)) and
         (s[i + Length(delim.exprOpen)] = '-') then
      begin
        Result.trimOpen := True;
        Result.openTag := delim.exprOpen + '-';
      end;
      Exit;
    end;
    // Check statement open
    if (i + Length(delim.stmtOpen) - 1 <= Length(s)) and
       (Copy(s, i, Length(delim.stmtOpen)) = delim.stmtOpen) then
    begin
      Result.found := True;
      Result.tagStart := i;
      Result.kind := tkStatement;
      Result.openTag := delim.stmtOpen;
      Result.closeTag := delim.stmtClose;
      Result.trimOpen := False;
      Result.trimClose := False;
      if (i + Length(delim.stmtOpen) <= Length(s)) and
         (s[i + Length(delim.stmtOpen)] = '-') then
      begin
        Result.trimOpen := True;
        Result.openTag := delim.stmtOpen + '-';
      end;
      Exit;
    end;
    // Check comment open
    if (i + Length(delim.commentOpen) - 1 <= Length(s)) and
       (Copy(s, i, Length(delim.commentOpen)) = delim.commentOpen) then
    begin
      Result.found := True;
      Result.tagStart := i;
      Result.kind := tkComment;
      Result.openTag := delim.commentOpen;
      Result.closeTag := delim.commentClose;
      Result.trimOpen := False;
      Result.trimClose := False;
      Exit;
    end;
    Inc(i);
  end;
end;

function scanForNextTag(const s: string; startPos: Integer): TScanResult;
var
  i: Integer;
  c1: Char;
  c2: Char;
begin
  Result.found := False;
  i := startPos;
  while i <= Length(s) - 1 do
  begin
    c1 := s[i];
    c2 := s[i + 1];
    if c1 = '{' then
    begin
      if c2 = '{' then
      begin
        Result.found := True;
        Result.tagStart := i;
        Result.kind := tkOutput;
        Result.closeTag := '}}';
        Result.trimClose := False;
        if (i + 2 <= Length(s)) and (s[i + 2] = '-') then
        begin
          Result.trimOpen := True;
          Result.openTag := '{{-';
        end
        else
        begin
          Result.trimOpen := False;
          Result.openTag := '{{';
        end;
        Exit;
      end
      else if c2 = '%' then
      begin
        Result.found := True;
        Result.tagStart := i;
        Result.kind := tkStatement;
        Result.closeTag := '%}';
        Result.trimClose := False;
        if (i + 2 <= Length(s)) and (s[i + 2] = '-') then
        begin
          Result.trimOpen := True;
          Result.openTag := '{%-';
        end
        else
        begin
          Result.trimOpen := False;
          Result.openTag := '{%';
        end;
        Exit;
      end
      else if c2 = '#' then
      begin
        Result.found := True;
        Result.tagStart := i;
        Result.kind := tkComment;
        Result.trimOpen := False;
        Result.trimClose := False;
        Result.openTag := '{#';
        Result.closeTag := '#}';
        Exit;
      end;
    end;
    Inc(i);
  end;
end;

function findCloseTag(const s: string; startPos: Integer; const closeTag: string): TCloseResult;
var
  i: Integer;
begin
  Result.pos := -1;
  Result.trimClose := False;
  i := startPos;
  while i <= Length(s) - Length(closeTag) + 1 do
  begin
    if Copy(s, i, Length(closeTag)) = closeTag then
    begin
      Result.pos := i;
      Result.trimClose := (i > 1) and (s[i - 1] = '-');
      Exit;
    end;
    Inc(i);
  end;
end;

function tokenize(const templateStr: string): TArray<TToken>;
var
  _tokens: TArray<TToken>;
  _count: Integer;
  _pos: Integer;
  _scan: TScanResult;
  _close: TCloseResult;
  _textBefore: string;
  _innerContent: string;
  _innerStart: Integer;
  _innerEnd: Integer;
  _lc: TLineCol;

  procedure addToken(kind: TTokenKind; const value: string; pos: Integer);
  begin
    if _count >= Length(_tokens) then
    begin
      SetLength(_tokens, _count + 32);
    end;
    _lc := computeLineCol(templateStr, pos);
    _tokens[_count].kind := kind;
    _tokens[_count].value := value;
    _tokens[_count].line := _lc.line;
    _tokens[_count].col := _lc.col;
    Inc(_count);
  end;

begin
  SetLength(_tokens, 64);
  _count := 0;
  _pos := 1;

  while _pos <= Length(templateStr) do
  begin
    _scan := scanForNextTag(templateStr, _pos);

    if not _scan.found then
    begin
      _textBefore := Copy(templateStr, _pos, Length(templateStr) - _pos + 1);
      if _textBefore <> '' then
      begin
        addToken(tkText, _textBefore, _pos);
      end;
      Break;
    end;

    _textBefore := Copy(templateStr, _pos, _scan.tagStart - _pos);
    if _scan.trimOpen then
    begin
      _textBefore := TrimRight(_textBefore);
    end;
    if _textBefore <> '' then
    begin
      addToken(tkText, _textBefore, _pos);
    end;

    _innerStart := _scan.tagStart + Length(_scan.openTag);
    _close := findCloseTag(templateStr, _innerStart, _scan.closeTag);

    if _close.pos = -1 then
    begin
      addToken(tkText, Copy(templateStr, _scan.tagStart, Length(templateStr) - _scan.tagStart + 1), _scan.tagStart);
      Break;
    end;

    _innerEnd := _close.pos - 1;
    if _close.trimClose and (_innerEnd >= _innerStart) and (templateStr[_innerEnd] = '-') then
    begin
      Dec(_innerEnd);
    end;

    _innerContent := Trim(Copy(templateStr, _innerStart, _innerEnd - _innerStart + 1));

    if _scan.kind <> tkComment then
    begin
      addToken(_scan.kind, _innerContent, _scan.tagStart);
    end;

    _pos := _close.pos + Length(_scan.closeTag);
    if _close.trimClose and (_pos <= Length(templateStr)) then
    begin
      while (_pos <= Length(templateStr)) and CharInSet(templateStr[_pos], [' ', #9, #13, #10]) do
      begin
        Inc(_pos);
      end;
    end;
  end;

  SetLength(_tokens, _count);
  Result := _tokens;
end;

function tokenize(const templateStr: string; const delimiters: TDelimiterConfig): TArray<TToken>;
var
  _tokens: TArray<TToken>;
  _count: Integer;
  _pos: Integer;
  _scan: TScanResult;
  _close: TCloseResult;
  _textBefore: string;
  _innerContent: string;
  _innerStart: Integer;
  _innerEnd: Integer;
  _lc: TLineCol;

  procedure addToken(kind: TTokenKind; const value: string; pos: Integer);
  begin
    if _count >= Length(_tokens) then
    begin
      SetLength(_tokens, _count + 32);
    end;
    _lc := computeLineCol(templateStr, pos);
    _tokens[_count].kind := kind;
    _tokens[_count].value := value;
    _tokens[_count].line := _lc.line;
    _tokens[_count].col := _lc.col;
    Inc(_count);
  end;

begin
  SetLength(_tokens, 64);
  _count := 0;
  _pos := 1;

  while _pos <= Length(templateStr) do
  begin
    _scan := scanForNextTagCustom(templateStr, _pos, delimiters);

    if not _scan.found then
    begin
      _textBefore := Copy(templateStr, _pos, Length(templateStr) - _pos + 1);
      if _textBefore <> '' then
      begin
        addToken(tkText, _textBefore, _pos);
      end;
      Break;
    end;

    _textBefore := Copy(templateStr, _pos, _scan.tagStart - _pos);
    if _scan.trimOpen then
    begin
      _textBefore := TrimRight(_textBefore);
    end;
    if _textBefore <> '' then
    begin
      addToken(tkText, _textBefore, _pos);
    end;

    _innerStart := _scan.tagStart + Length(_scan.openTag);
    _close := findCloseTag(templateStr, _innerStart, _scan.closeTag);

    if _close.pos = -1 then
    begin
      addToken(tkText, Copy(templateStr, _scan.tagStart, Length(templateStr) - _scan.tagStart + 1), _scan.tagStart);
      Break;
    end;

    _innerEnd := _close.pos - 1;
    if _close.trimClose and (_innerEnd >= _innerStart) and (templateStr[_innerEnd] = '-') then
    begin
      Dec(_innerEnd);
    end;

    _innerContent := Trim(Copy(templateStr, _innerStart, _innerEnd - _innerStart + 1));

    if _scan.kind <> tkComment then
    begin
      addToken(_scan.kind, _innerContent, _scan.tagStart);
    end;

    _pos := _close.pos + Length(_scan.closeTag);
    if _close.trimClose and (_pos <= Length(templateStr)) then
    begin
      while (_pos <= Length(templateStr)) and CharInSet(templateStr[_pos], [' ', #9, #13, #10]) do
      begin
        Inc(_pos);
      end;
    end;
  end;

  SetLength(_tokens, _count);
  Result := _tokens;
end;

end.
