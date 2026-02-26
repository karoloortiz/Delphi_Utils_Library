unit KLib.Template.Evaluator;

interface

uses
  System.Classes, System.Contnrs,
  KLib.Template.Lexer,
  System.Rtti,
  System.Generics.Collections;

type
  TUndefinedMode = (umSilent, umStrict, umDebug);

  // Accessible in templates via {{ loop.index }}, {{ loop.first }}, etc.
  TLoopInfo = record
    index: Integer;
    index0: Integer;
    revindex: Integer;
    revindex0: Integer;
    first: Boolean;
    last: Boolean;
    length: Integer;
    previtem: TValue;
    nextitem: TValue;
    depth: Integer;
    depth0: Integer;
  end;

  // Context passed to evaluate for include/extends resolution
  TEvaluateContext = record
    templateName: string;
    templateDir: string;
    searchPaths: TStringList;
    globals: TDictionary<string, TValue>;
    cache: TObject; // TTemplateCache (TObject to avoid circular unit dependency)
    ownedObjects: TObjectList; // owns TObject values created during evaluation (dict literals, namespace)
    autoescapeEnabled: Boolean;
    undefinedMode: TUndefinedMode;
    sandboxEnabled: Boolean;
  end;

  TTranslateFunction = reference to function(const text: string): string;

function evaluate(const tokens: TArray<TToken>; const data: TValue): string; overload;
function evaluate(const tokens: TArray<TToken>; const data: TValue; const ctx: TEvaluateContext): string; overload;
procedure setTranslateFunction(fn: TTranslateFunction);

implementation

uses
  KLib.Template.Filters,
  KLib.Template.Exceptions,
  KLib.Types,
  KLib.Utils,
  KLib.StringUtils,
  System.SysUtils, System.StrUtils, System.TypInfo, System.IOUtils,
  System.Math, System.RegularExpressions;

var
  _translateFn: TTranslateFunction;

procedure setTranslateFunction(fn: TTranslateFunction);
begin
  _translateFn := fn;
end;

type
  TScope = TDictionary<string, TValue>;

  TMacroEntry = record
    paramNames: TArray<string>;
    paramDefaults: TArray<string>;  // '' if no default, expression string otherwise
    bodyStart: Integer;
    bodyEnd: Integer;
  end;

  TForParseResult = record
    isValid: Boolean;
    loopVar: string;
    collectionExpr: string;
    filterExpr: string;   // 'if condition' filter expression
    isRecursive: Boolean;  // 'recursive' keyword
  end;

  TArrayIndexResult = record
    isArrayAccess: Boolean;
    baseName: string;
    index: Integer;
  end;

// ---- RTTI scope helpers ----

procedure populateScope(scope: TScope; const data: TValue);
var
  _ctx: TRttiContext;
  _rttiType: TRttiType;
  _field: TRttiField;
  _prop: TRttiProperty;
  _fieldValue: TValue;
begin
  if data.Kind = tkRecord then
  begin
    _rttiType := _ctx.GetType(data.TypeInfo);
    for _field in _rttiType.GetFields do
    begin
      try
        _fieldValue := _field.GetValue(data.GetReferenceToRawData);
        scope.AddOrSetValue(LowerCase(_field.Name), _fieldValue);
      except
        on E: Exception do
          ;
      end;
    end;
  end
  else if data.Kind = tkClass then
  begin
    if not (data.IsEmpty or (data.AsObject = nil)) then
    begin
      _rttiType := _ctx.GetType(data.TypeInfo);
      for _field in _rttiType.GetFields do
      begin
        try
          _fieldValue := _field.GetValue(data.AsObject);
          scope.AddOrSetValue(LowerCase(_field.Name), _fieldValue);
        except
          on E: Exception do
            ;
        end;
      end;
      for _prop in _rttiType.GetProperties do
      begin
        try
          _fieldValue := _prop.GetValue(data.AsObject);
          scope.AddOrSetValue(LowerCase(_prop.Name), _fieldValue);
        except
          on E: Exception do
            ;
        end;
      end;
    end;
  end;
end;

// getFieldValue is in KLib.Utils (shared with KLib.Template.Filters)

function parseArrayIndex(const part: string): TArrayIndexResult;
var
  _bracketPos: Integer;
  _closeBracket: Integer;
  _indexStr: string;
begin
  Result.isArrayAccess := False;
  Result.baseName := part;
  Result.index := 0;
  _bracketPos := Pos('[', part);
  if _bracketPos > 0 then
  begin
    _closeBracket := Pos(']', part);
    if _closeBracket > _bracketPos then
    begin
      _indexStr := Trim(Copy(part, _bracketPos + 1, _closeBracket - _bracketPos - 1));
      if TryStrToInt(_indexStr, Result.index) then
      begin
        Result.baseName := Copy(part, 1, _bracketPos - 1);
        Result.isArrayAccess := True;
      end;
    end;
  end;
end;

function resolvePath(scopeStack: TStack<TScope>; const path: string): TValue;
var
  _parts: TArray<string>;
  _currentValue: TValue;
  i: Integer;
  _scopeEnum: TStack<TScope>.TEnumerator;
  _scope: TScope;
  _found: Boolean;
  _indexResult: TArrayIndexResult;
  _arrLen: Integer;
  _adjustedIndex: Integer;
begin
  Result := TValue.Empty;
  // @root access — resolve from bottom of scope stack
  if SameText(Copy(path, 1, 6), '@root.') then
  begin
    _parts := SplitString(Copy(path, 7, MaxInt), '.');
    _scopeEnum := scopeStack.GetEnumerator;
    _scope := nil;
    try
      while _scopeEnum.MoveNext do
      begin
        _scope := _scopeEnum.Current;
      end;
      if (_scope <> nil) and _scope.TryGetValue(LowerCase(_parts[0]), _currentValue) then
      begin
        for i := 1 to High(_parts) do
        begin
          _currentValue := getFieldValue(_currentValue, _parts[i]);
        end;
        Result := _currentValue;
      end;
    finally
      FreeAndNil(_scopeEnum);
    end;
    Exit;
  end;
  _parts := SplitString(path, '.');
  _found := False;
  _scopeEnum := scopeStack.GetEnumerator;
  try
    while _scopeEnum.MoveNext and not _found do
    begin
      _scope := _scopeEnum.Current;
      _indexResult := parseArrayIndex(_parts[0]);
      if _indexResult.isArrayAccess then
      begin
        if _scope.TryGetValue(LowerCase(_indexResult.baseName), _currentValue) then
        begin
          _found := True;
          if _currentValue.Kind = tkDynArray then
          begin
            _arrLen := _currentValue.GetArrayLength;
            _adjustedIndex := _indexResult.index;
            if _adjustedIndex < 0 then
            begin
              _adjustedIndex := _arrLen + _adjustedIndex;
            end;
            if (_adjustedIndex >= 0) and (_adjustedIndex < _arrLen) then
            begin
              _currentValue := _currentValue.GetArrayElement(_adjustedIndex);
            end
            else
            begin
              _currentValue := TValue.Empty;
            end;
          end;
        end;
      end
      else
      begin
        if _scope.TryGetValue(LowerCase(_parts[0]), _currentValue) then
        begin
          _found := True;
        end;
      end;
    end;
  finally
    FreeAndNil(_scopeEnum);
  end;

  if _found then
  begin
    for i := 1 to High(_parts) do
    begin
      _indexResult := parseArrayIndex(_parts[i]);
      if _indexResult.isArrayAccess then
      begin
        _currentValue := getFieldValue(_currentValue, _indexResult.baseName);
        if not _currentValue.IsEmpty and (_currentValue.Kind = tkDynArray) then
        begin
          _arrLen := _currentValue.GetArrayLength;
          _adjustedIndex := _indexResult.index;
          if _adjustedIndex < 0 then
          begin
            _adjustedIndex := _arrLen + _adjustedIndex;
          end;
          if (_adjustedIndex >= 0) and (_adjustedIndex < _arrLen) then
            _currentValue := _currentValue.GetArrayElement(_adjustedIndex)
          else
            _currentValue := TValue.Empty;
        end;
      end
      else
      begin
        _currentValue := getFieldValue(_currentValue, _parts[i]);
      end;
    end;
    Result := _currentValue;
  end;
end;

function resolvePathEx(scopeStack: TStack<TScope>; const path: string;
  undefinedMode: TUndefinedMode; const templateName: string = '';
  line: Integer = 0; col: Integer = 0): TValue;
begin
  Result := resolvePath(scopeStack, path);
  if Result.IsEmpty and (undefinedMode <> umSilent) then
  begin
    if undefinedMode = umStrict then
    begin
      raise ETemplateError.create('Undefined variable: ' + path, templateName, line, col);
    end
    else
    begin
      Result := TValue.From<string>('{{ undefined: ' + path + ' }}');
    end;
  end;
end;

function parseForStatement(const stmt: string): TForParseResult;
var
  _ofPos: Integer;
  _kwLen: Integer;
  _collExpr: string;
  _ifPos: Integer;
begin
  Result.isValid := False;
  Result.loopVar := '';
  Result.collectionExpr := '';
  Result.filterExpr := '';
  Result.isRecursive := False;
  if SameText(Copy(Trim(stmt), 1, 4), 'for ') then
  begin
    _ofPos := Pos(' of ', LowerCase(stmt));
    _kwLen := 4;
    if _ofPos = 0 then
    begin
      _ofPos := Pos(' in ', LowerCase(stmt));
      _kwLen := 4;
    end;
    if _ofPos > 0 then
    begin
      Result.loopVar := Trim(Copy(stmt, 5, _ofPos - 5));
      _collExpr := Trim(Copy(stmt, _ofPos + _kwLen, MaxInt));
      // Check for 'recursive' keyword at end
      if SameText(Copy(_collExpr, Length(_collExpr) - 8, 9), 'recursive') then
      begin
        Result.isRecursive := True;
        _collExpr := Trim(Copy(_collExpr, 1, Length(_collExpr) - 9));
      end;
      // Check for ' if condition' part
      _ifPos := Pos(' if ', LowerCase(_collExpr));
      if _ifPos > 0 then
      begin
        Result.filterExpr := Trim(Copy(_collExpr, _ifPos + 4, MaxInt));
        _collExpr := Trim(Copy(_collExpr, 1, _ifPos - 1));
      end;
      Result.collectionExpr := _collExpr;
      Result.isValid := True;
    end;
  end;
end;

// ---- Expression helpers ----

function findTopLevelStr(const s: string; const sub: string): Integer;
var
  i: Integer;
  _inStr: Boolean;
  _strChar: Char;
  _parenDepth: Integer;
begin
  Result := 0;
  _inStr := False;
  _strChar := #0;
  _parenDepth := 0;
  i := 1;
  while (Result = 0) and (i <= Length(s) - Length(sub) + 1) do
  begin
    if _inStr then
    begin
      if s[i] = _strChar then
      begin
        _inStr := False;
      end;
    end
    else if CharInSet(s[i], ['''', '"']) then
    begin
      _inStr := True;
      _strChar := s[i];
    end
    else if s[i] = '(' then
    begin
      Inc(_parenDepth);
    end
    else if s[i] = ')' then
    begin
      Dec(_parenDepth);
    end
    else if (_parenDepth = 0) and SameText(Copy(s, i, Length(sub)), sub) then
    begin
      Result := i;
    end;
    Inc(i);
  end;
end;

// Returns position of RIGHTMOST sub not inside quotes or parens (left-to-right associativity)
function findLastTopLevelStr(const s: string; const sub: string): Integer;
var
  i: Integer;
  _inStr: Boolean;
  _strChar: Char;
  _parenDepth: Integer;
begin
  Result := 0;
  _inStr := False;
  _strChar := #0;
  _parenDepth := 0;
  i := 1;
  while i <= Length(s) - Length(sub) + 1 do
  begin
    if _inStr then
    begin
      if s[i] = _strChar then
      begin
        _inStr := False;
      end;
    end
    else if CharInSet(s[i], ['''', '"']) then
    begin
      _inStr := True;
      _strChar := s[i];
    end
    else if s[i] = '(' then
    begin
      Inc(_parenDepth);
    end
    else if s[i] = ')' then
    begin
      Dec(_parenDepth);
    end
    else if (_parenDepth = 0) and SameText(Copy(s, i, Length(sub)), sub) then
    begin
      Result := i;
    end;
    Inc(i);
  end;
end;

function resolveAtom(const atom: string; scopeStack: TStack<TScope>;
  ownedObjects: TObjectList = nil; undefinedMode: TUndefinedMode = umSilent;
  const templateName: string = ''; line: Integer = 0; col: Integer = 0): TValue;
var
  _t: string;
  _intVal: Integer;
  _floatVal: Double;
  _rangeInner: string;
  _rangeClose: Integer;
  _rangeParts: TArray<string>;
  _rangeStart: Integer;
  _rangeStop: Integer;
  _rangeStep: Integer;
  _rangeArr: TArray<Integer>;
  _rangeCount: Integer;
  i: Integer;
  // array/dict literal vars
  _arrInner: string;
  _arrParts: TArray<string>;
  _arrValues: TArray<TValue>;
  _dictObj: TDictionary<string, TValue>;
  _dictColonPos: Integer;
  _dictKey: string;
  // namespace vars
  _nsArgs: TArray<string>;
  _nsDict: TDictionary<string, TValue>;
  _nsEqPos: Integer;
  _nsKey: string;
  _nsValExpr: string;
begin
  _t := Trim(atom);
  if (Length(_t) >= 2) and
    (((_t[1] = '''') and (_t[Length(_t)] = '''')) or
    ((_t[1] = '"') and (_t[Length(_t)] = '"'))) then
  begin
    Result := TValue.From<string>(Copy(_t, 2, Length(_t) - 2));
  end
  else if SameText(_t, 'true') then
  begin
    Result := TValue.From<Boolean>(True);
  end
  else if SameText(_t, 'false') then
  begin
    Result := TValue.From<Boolean>(False);
  end
  else if SameText(_t, 'none') or SameText(_t, 'null') then
  begin
    Result := TValue.Empty;
  end
  // Array literal: ['a', 'b', 'c']
  else if (Length(_t) >= 2) and (_t[1] = '[') and (_t[Length(_t)] = ']') then
  begin
    _arrInner := Trim(Copy(_t, 2, Length(_t) - 2));
    if _arrInner = '' then
    begin
      Result := TValue.From<TArray<TValue>>(nil);
    end
    else
    begin
      _arrParts := splitArgs(_arrInner);
      SetLength(_arrValues, Length(_arrParts));
      for i := 0 to High(_arrParts) do
      begin
        _arrValues[i] := resolveAtom(Trim(_arrParts[i]), scopeStack);
      end;
      Result := TValue.From<TArray<TValue>>(_arrValues);
    end;
  end
  // Dict literal: {'key': 'val', 'key2': val2}
  else if (Length(_t) >= 2) and (_t[1] = '{') and (_t[Length(_t)] = '}') then
  begin
    _arrInner := Trim(Copy(_t, 2, Length(_t) - 2));
    _dictObj := TDictionary<string, TValue>.Create;
    if ownedObjects <> nil then
    begin
      ownedObjects.Add(_dictObj);
    end;
    if _arrInner <> '' then
    begin
      _arrParts := splitArgs(_arrInner);
      for i := 0 to High(_arrParts) do
      begin
        _dictColonPos := Pos(':', _arrParts[i]);
        if _dictColonPos > 0 then
        begin
          _dictKey := Trim(Copy(_arrParts[i], 1, _dictColonPos - 1));
          if (Length(_dictKey) >= 2) and CharInSet(_dictKey[1], ['''', '"']) then
          begin
            _dictKey := Copy(_dictKey, 2, Length(_dictKey) - 2);
          end;
          _dictObj.AddOrSetValue(LowerCase(_dictKey),
            resolveAtom(Trim(Copy(_arrParts[i], _dictColonPos + 1, MaxInt)), scopeStack, ownedObjects));
        end;
      end;
    end;
    Result := TValue.From<TObject>(_dictObj);
  end
  // namespace(key=val, key2=val2) — creates a mutable dict for loop scope
  else if SameText(Copy(LowerCase(_t), 1, 10), 'namespace(') then
  begin
    _rangeClose := LastDelimiter(')', _t);
    _arrInner := Trim(Copy(_t, 11, _rangeClose - 11));
    _nsDict := TDictionary<string, TValue>.Create;
    if ownedObjects <> nil then
    begin
      ownedObjects.Add(_nsDict);
    end;
    if _arrInner <> '' then
    begin
      _nsArgs := splitArgs(_arrInner);
      for i := 0 to High(_nsArgs) do
      begin
        _nsEqPos := Pos('=', _nsArgs[i]);
        if _nsEqPos > 0 then
        begin
          _nsKey := LowerCase(Trim(Copy(_nsArgs[i], 1, _nsEqPos - 1)));
          _nsValExpr := Trim(Copy(_nsArgs[i], _nsEqPos + 1, MaxInt));
          _nsDict.AddOrSetValue(_nsKey, resolveAtom(_nsValExpr, scopeStack, ownedObjects));
        end;
      end;
    end;
    Result := TValue.From<TObject>(_nsDict);
  end
  // joiner(sep) — creates a callable object that returns '' first time, sep thereafter
  else if SameText(Copy(LowerCase(_t), 1, 7), 'joiner(') then
  begin
    _rangeClose := LastDelimiter(')', _t);
    _arrInner := Trim(Copy(_t, 8, _rangeClose - 8));
    if (Length(_arrInner) >= 2) and CharInSet(_arrInner[1], ['''', '"']) then
    begin
      _arrInner := Copy(_arrInner, 2, Length(_arrInner) - 2);
    end;
    if _arrInner = '' then
    begin
      _arrInner := ', ';
    end;
    _nsDict := TDictionary<string, TValue>.Create;
    if ownedObjects <> nil then
    begin
      ownedObjects.Add(_nsDict);
    end;
    _nsDict.AddOrSetValue('__joiner_sep', TValue.From<string>(_arrInner));
    _nsDict.AddOrSetValue('__joiner_count', TValue.From<Integer>(0));
    Result := TValue.From<TObject>(_nsDict);
  end
  else if SameText(Copy(_t, 1, 6), 'range(') then
  begin
    // range(stop) / range(start, stop) / range(start, stop, step)
    _rangeClose := LastDelimiter(')', _t);
    _rangeInner := Trim(Copy(_t, 7, _rangeClose - 7));
    _rangeParts := SplitString(_rangeInner, ',');
    _rangeStart := 0;
    _rangeStep := 1;
    case Length(_rangeParts) of
      1:
        begin
          _rangeStop := StrToIntDef(Trim(_rangeParts[0]), 0);
        end;
      2:
        begin
          _rangeStart := StrToIntDef(Trim(_rangeParts[0]), 0);
          _rangeStop := StrToIntDef(Trim(_rangeParts[1]), 0);
        end;
    else
      begin
        _rangeStart := StrToIntDef(Trim(_rangeParts[0]), 0);
        _rangeStop := StrToIntDef(Trim(_rangeParts[1]), 0);
        _rangeStep := StrToIntDef(Trim(_rangeParts[2]), 1);
        if _rangeStep = 0 then
        begin
          _rangeStep := 1;
        end;
      end;
    end;
    if _rangeStep > 0 then
    begin
      _rangeCount := Max(0, (_rangeStop - _rangeStart + _rangeStep - 1) div _rangeStep);
    end
    else
    begin
      _rangeCount := Max(0, (_rangeStart - _rangeStop - _rangeStep - 1) div (-_rangeStep));
    end;
    SetLength(_rangeArr, _rangeCount);
    for i := 0 to _rangeCount - 1 do
    begin
      _rangeArr[i] := _rangeStart + i * _rangeStep;
    end;
    Result := TValue.From<TArray<Integer>>(_rangeArr);
  end
  else if TryStrToInt(_t, _intVal) then
  begin
    Result := TValue.From<Integer>(_intVal);
  end
  else if TryStrToFloat(_t, _floatVal) then
  begin
    Result := TValue.From<Double>(_floatVal);
  end
  else if (Length(_t) > 1) and (_t[1] = '-') then
  begin
    // Unary minus: -varName or -expr
    _floatVal := StrToFloatDef(getStringFromTValue(resolvePathEx(scopeStack, Copy(_t, 2, MaxInt), undefinedMode, templateName, line, col)), 0);
    Result := TValue.From<Double>(-_floatVal);
  end
  else
  begin
    Result := resolvePathEx(scopeStack, _t, undefinedMode, templateName, line, col);
  end;
end;

// Returns position of first '|' not inside quotes or parentheses, or 0 if not found
function findFirstPipePos(const s: string): Integer;
var
  i: Integer;
  _inStr: Boolean;
  _strChar: Char;
  _parenDepth: Integer;
begin
  Result := 0;
  _inStr := False;
  _strChar := #0;
  _parenDepth := 0;
  i := 1;
  while (Result = 0) and (i <= Length(s)) do
  begin
    if _inStr then
    begin
      if s[i] = _strChar then
      begin
        _inStr := False;
      end;
    end
    else if CharInSet(s[i], ['''', '"']) then
    begin
      _inStr := True;
      _strChar := s[i];
    end
    else if s[i] = '(' then
    begin
      Inc(_parenDepth);
    end
    else if s[i] = ')' then
    begin
      Dec(_parenDepth);
    end
    else if (s[i] = '|') and (_parenDepth = 0) then
    begin
      Result := i;
    end;
    Inc(i);
  end;
end;

// ---- Math expression evaluator ----
// Uses rightmost-operator approach for correct left-to-right associativity.

function evalPowerExpr(const expr: string; scopeStack: TStack<TScope>): TValue; forward;
function evalMathTerm(const expr: string; scopeStack: TStack<TScope>): TValue; forward;
function evalMathExpr(const expr: string; scopeStack: TStack<TScope>): TValue; forward;
function evalConcatExpr(const expr: string; scopeStack: TStack<TScope>): TValue; forward;

function evalPowerExpr(const expr: string; scopeStack: TStack<TScope>): TValue;
var
  _e: string;
  _posPow: Integer;
  _leftVal: TValue;
  _rightVal: TValue;
  _lf: Double;
  _rf: Double;
begin
  _e := Trim(expr);
  _posPow := findLastTopLevelStr(_e, ' ** ');
  if _posPow > 0 then
  begin
    _leftVal := evalPowerExpr(Trim(Copy(_e, 1, _posPow - 1)), scopeStack);
    _rightVal := resolveAtom(Trim(Copy(_e, _posPow + 4, MaxInt)), scopeStack);
    _lf := StrToFloatDef(getStringFromTValue(_leftVal), 0);
    _rf := StrToFloatDef(getStringFromTValue(_rightVal), 0);
    Result := TValue.From<Double>(Power(_lf, _rf));
  end
  else
  begin
    Result := resolveAtom(_e, scopeStack);
  end;
end;

function evalMathTerm(const expr: string; scopeStack: TStack<TScope>): TValue;
var
  _e: string;
  _posStar: Integer;
  _posDiv: Integer;
  _posFloorDiv: Integer;
  _posMod: Integer;
  _lastPos: Integer;
  _op: string;
  _opLen: Integer;
  _leftVal: TValue;
  _rightVal: TValue;
  _lf: Double;
  _rf: Double;
begin
  _e := Trim(expr);
  _posStar := findLastTopLevelStr(_e, ' * ');
  _posFloorDiv := findLastTopLevelStr(_e, ' // ');
  _posDiv := findLastTopLevelStr(_e, ' / ');
  _posMod := findLastTopLevelStr(_e, ' % ');

  // If _posDiv points to the same position as _posFloorDiv, it's actually '//' not '/'
  if (_posFloorDiv > 0) and (_posDiv = _posFloorDiv) then
  begin
    _posDiv := 0;
  end;

  _lastPos := 0;
  _op := '';
  _opLen := 3;
  if _posStar > _lastPos then
  begin
    _lastPos := _posStar;
    _op := '*';
    _opLen := 3;
  end;
  if _posFloorDiv > _lastPos then
  begin
    _lastPos := _posFloorDiv;
    _op := '//';
    _opLen := 4;
  end;
  if _posDiv > _lastPos then
  begin
    _lastPos := _posDiv;
    _op := '/';
    _opLen := 3;
  end;
  if _posMod > _lastPos then
  begin
    _lastPos := _posMod;
    _op := '%';
    _opLen := 3;
  end;

  if _lastPos > 0 then
  begin
    _leftVal := evalMathTerm(Trim(Copy(_e, 1, _lastPos - 1)), scopeStack);
    _rightVal := evalPowerExpr(Trim(Copy(_e, _lastPos + _opLen, MaxInt)), scopeStack);
    _lf := StrToFloatDef(getStringFromTValue(_leftVal), 0);
    _rf := StrToFloatDef(getStringFromTValue(_rightVal), 1);
    if _op = '*' then
    begin
      Result := TValue.From<Double>(_lf * _rf);
    end
    else if _op = '//' then
    begin
      if _rf = 0 then
      begin
        Result := TValue.From<Double>(0);
      end
      else
      begin
        Result := TValue.From<Double>(1.0 * Floor(_lf / _rf));
      end;
    end
    else if _op = '/' then
    begin
      if _rf = 0 then
      begin
        Result := TValue.From<Double>(0);
      end
      else
      begin
        Result := TValue.From<Double>(_lf / _rf);
      end;
    end
    else
    begin
      if _rf = 0 then
      begin
        Result := TValue.From<Double>(0);
      end
      else
      begin
        Result := TValue.From<Double>(FMod(_lf, _rf));
      end;
    end;
  end
  else
  begin
    Result := evalPowerExpr(_e, scopeStack);
  end;
end;

function evalMathExpr(const expr: string; scopeStack: TStack<TScope>): TValue;
var
  _e: string;
  _posAdd: Integer;
  _posSub: Integer;
  _lastPos: Integer;
  _op: string;
  _leftVal: TValue;
  _rightVal: TValue;
  _lf: Double;
  _rf: Double;
begin
  _e := Trim(expr);
  _posAdd := findLastTopLevelStr(_e, ' + ');
  _posSub := findLastTopLevelStr(_e, ' - ');

  _lastPos := 0;
  _op := '';
  if _posAdd > _lastPos then
  begin
    _lastPos := _posAdd;
    _op := '+';
  end;
  if _posSub > _lastPos then
  begin
    _lastPos := _posSub;
    _op := '-';
  end;

  if _lastPos > 0 then
  begin
    _leftVal := evalMathExpr(Trim(Copy(_e, 1, _lastPos - 1)), scopeStack);
    _rightVal := evalMathTerm(Trim(Copy(_e, _lastPos + 3, MaxInt)), scopeStack);
    _lf := StrToFloatDef(getStringFromTValue(_leftVal), 0);
    _rf := StrToFloatDef(getStringFromTValue(_rightVal), 0);
    if _op = '+' then
    begin
      Result := TValue.From<Double>(_lf + _rf);
    end
    else
    begin
      Result := TValue.From<Double>(_lf - _rf);
    end;
  end
  else
  begin
    Result := evalMathTerm(_e, scopeStack);
  end;
end;

// ~ is lowest-priority string concatenation (lower than +/-): 'Hello ' ~ name ~ '!'
function evalConcatExpr(const expr: string; scopeStack: TStack<TScope>): TValue;
var
  _e: string;
  _posConcat: Integer;
begin
  _e := Trim(expr);
  _posConcat := findLastTopLevelStr(_e, ' ~ ');
  if _posConcat > 0 then
  begin
    Result := TValue.From<string>(
      getStringFromTValue(evalConcatExpr(Trim(Copy(_e, 1, _posConcat - 1)), scopeStack)) +
      getStringFromTValue(evalMathExpr(Trim(Copy(_e, _posConcat + 3, MaxInt)), scopeStack)));
  end
  else
  begin
    Result := evalMathExpr(_e, scopeStack);
  end;
end;

function compareValues(const left: TValue; const right: TValue; const op: string): Boolean;
var
  _ls: string;
  _rs: string;
  _lf: Double;
  _rf: Double;
  _isNum: Boolean;
begin
  _ls := getStringFromTValue(left);
  _rs := getStringFromTValue(right);
  _isNum := TryStrToFloat(_ls, _lf) and TryStrToFloat(_rs, _rf);
  if op = '==' then
  begin
    if _isNum then
    begin
      Result := _lf = _rf;
    end
    else
    begin
      Result := _ls = _rs;
    end;
  end
  else if op = '!=' then
  begin
    if _isNum then
    begin
      Result := _lf <> _rf;
    end
    else
    begin
      Result := _ls <> _rs;
    end;
  end
  else if op = '>' then
  begin
    if _isNum then
    begin
      Result := _lf > _rf;
    end
    else
    begin
      Result := _ls > _rs;
    end;
  end
  else if op = '<' then
  begin
    if _isNum then
    begin
      Result := _lf < _rf;
    end
    else
    begin
      Result := _ls < _rs;
    end;
  end
  else if op = '>=' then
  begin
    if _isNum then
    begin
      Result := _lf >= _rf;
    end
    else
    begin
      Result := _ls >= _rs;
    end;
  end
  else if op = '<=' then
  begin
    if _isNum then
    begin
      Result := _lf <= _rf;
    end
    else
    begin
      Result := _ls <= _rs;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

function evalExprAsBoolean(const expr: string; scopeStack: TStack<TScope>): Boolean;
var
  _e: string;
  _pos: Integer;
  _ops: array [0..5] of string;
  _op: string;
  _leftVal: TValue;
  _rightVal: TValue;
  i: Integer;
  _testSubj: string;
  _testName: string;
  _testArg: string;
  _parenPos: Integer;
  _strVal: string;
  _numVal: Double;
  _intVal: Int64;
  _inPos: Integer;
  _haystack: TValue;
  _needle: TValue;
  _arrLen: Integer;
  j: Integer;
  _handled: Boolean;
begin
  _e := Trim(expr);
  Result := False;
  _handled := False;

  if _e = '' then
  begin
    _handled := True;
  end;

  if not _handled then
  begin
    _pos := findTopLevelStr(_e, ' or ');
    if _pos > 0 then
    begin
      Result := evalExprAsBoolean(Trim(Copy(_e, 1, _pos - 1)), scopeStack) or
        evalExprAsBoolean(Trim(Copy(_e, _pos + 4, MaxInt)), scopeStack);
      _handled := True;
    end;
  end;

  if not _handled then
  begin
    _pos := findTopLevelStr(_e, ' and ');
    if _pos > 0 then
    begin
      Result := evalExprAsBoolean(Trim(Copy(_e, 1, _pos - 1)), scopeStack) and
        evalExprAsBoolean(Trim(Copy(_e, _pos + 5, MaxInt)), scopeStack);
      _handled := True;
    end;
  end;

  if not _handled and SameText(Copy(_e, 1, 4), 'not ') then
  begin
    Result := not evalExprAsBoolean(Trim(Copy(_e, 5, MaxInt)), scopeStack);
    _handled := True;
  end;

  if not _handled then
  begin
    _inPos := findTopLevelStr(_e, ' not in ');
    if _inPos > 0 then
    begin
      _needle := resolveAtom(Trim(Copy(_e, 1, _inPos - 1)), scopeStack);
      _haystack := resolveAtom(Trim(Copy(_e, _inPos + 8, MaxInt)), scopeStack);
      if _haystack.Kind = tkDynArray then
      begin
        _arrLen := _haystack.GetArrayLength;
        Result := True;
        for j := 0 to _arrLen - 1 do
        begin
          if getStringFromTValue(_haystack.GetArrayElement(j)) = getStringFromTValue(_needle) then
          begin
            Result := False;
          end;
        end;
      end
      else
      begin
        Result := Pos(getStringFromTValue(_needle), getStringFromTValue(_haystack)) = 0;
      end;
      _handled := True;
    end;
  end;

  if not _handled then
  begin
    _inPos := findTopLevelStr(_e, ' in ');
    if _inPos > 0 then
    begin
      _needle := resolveAtom(Trim(Copy(_e, 1, _inPos - 1)), scopeStack);
      _haystack := resolveAtom(Trim(Copy(_e, _inPos + 4, MaxInt)), scopeStack);
      if _haystack.Kind = tkDynArray then
      begin
        _arrLen := _haystack.GetArrayLength;
        Result := False;
        for j := 0 to _arrLen - 1 do
        begin
          if getStringFromTValue(_haystack.GetArrayElement(j)) = getStringFromTValue(_needle) then
          begin
            Result := True;
          end;
        end;
      end
      else
      begin
        Result := Pos(getStringFromTValue(_needle), getStringFromTValue(_haystack)) > 0;
      end;
      _handled := True;
    end;
  end;

  if not _handled then
  begin
    _pos := findTopLevelStr(_e, ' is not ');
    if _pos > 0 then
    begin
      // 'x is not test' → equivalent to 'not (x is test)'
      Result := not evalExprAsBoolean(
        Trim(Copy(_e, 1, _pos - 1)) + ' is ' +
        Trim(Copy(_e, _pos + 8, MaxInt)),
        scopeStack);
      _handled := True;
    end;
  end;

  if not _handled then
  begin
    _pos := findTopLevelStr(_e, ' is ');
    if _pos > 0 then
    begin
      _testSubj := Trim(Copy(_e, 1, _pos - 1));
      _testName := Trim(Copy(_e, _pos + 4, MaxInt));
      _testArg := '';
      _parenPos := Pos('(', _testName);
      if _parenPos > 0 then
      begin
        _testArg := Trim(Copy(_testName, _parenPos + 1, Length(_testName) - _parenPos - 1));
        _testName := Trim(Copy(_testName, 1, _parenPos - 1));
      end;
      _testName := LowerCase(_testName);
      _leftVal := resolveAtom(_testSubj, scopeStack);
      _strVal := getStringFromTValue(_leftVal);

      if _testName = 'defined' then
      begin
        Result := not _leftVal.IsEmpty;
      end
      else if _testName = 'none' then
      begin
        Result := _leftVal.IsEmpty;
      end
      else if _testName = 'empty' then
      begin
        if _leftVal.IsEmpty then
        begin
          Result := True;
        end
        else if _leftVal.Kind = tkDynArray then
        begin
          Result := _leftVal.GetArrayLength = 0;
        end
        else
        begin
          Result := _strVal = '';
        end;
      end
      else if _testName = 'number' then
      begin
        Result := TryStrToFloat(_strVal, _numVal);
      end
      else if _testName = 'string' then
      begin
        Result := _leftVal.Kind in [tkString, tkLString, tkWString, tkUString];
      end
      else if _testName = 'odd' then
      begin
        if TryStrToFloat(_strVal, _numVal) then
        begin
          Result := Odd(Round(_numVal));
        end
        else
        begin
          Result := False;
        end;
      end
      else if _testName = 'even' then
      begin
        if TryStrToFloat(_strVal, _numVal) then
        begin
          Result := not Odd(Round(_numVal));
        end
        else
        begin
          Result := False;
        end;
      end
      else if _testName = 'divisibleby' then
      begin
        if TryStrToFloat(_strVal, _numVal) and (_testArg <> '') then
        begin
          _intVal := StrToInt64Def(_testArg, 0);
          if _intVal <> 0 then
          begin
            Result := (Round(_numVal) mod _intVal) = 0;
          end
          else
          begin
            Result := False;
          end;
        end;
      end
      else if _testName = 'startswith' then
      begin
        if _testArg <> '' then
        begin
          // Remove quotes from test arg if present
          if (Length(_testArg) >= 2) and CharInSet(_testArg[1], ['''', '"']) then
          begin
            _testArg := Copy(_testArg, 2, Length(_testArg) - 2);
          end;
          Result := SameText(Copy(_strVal, 1, Length(_testArg)), _testArg);
        end;
      end
      else if _testName = 'endswith' then
      begin
        if _testArg <> '' then
        begin
          if (Length(_testArg) >= 2) and CharInSet(_testArg[1], ['''', '"']) then
          begin
            _testArg := Copy(_testArg, 2, Length(_testArg) - 2);
          end;
          Result := SameText(Copy(_strVal, Length(_strVal) - Length(_testArg) + 1, MaxInt), _testArg);
        end;
      end
      else if _testName = 'contains' then
      begin
        if _testArg <> '' then
        begin
          if (Length(_testArg) >= 2) and CharInSet(_testArg[1], ['''', '"']) then
          begin
            _testArg := Copy(_testArg, 2, Length(_testArg) - 2);
          end;
          Result := Pos(LowerCase(_testArg), LowerCase(_strVal)) > 0;
        end;
      end
      else if _testName = 'match' then
      begin
        if _testArg <> '' then
        begin
          if (Length(_testArg) >= 2) and CharInSet(_testArg[1], ['''', '"']) then
          begin
            _testArg := Copy(_testArg, 2, Length(_testArg) - 2);
          end;
          Result := TRegEx.IsMatch(_strVal, _testArg);
        end;
      end
      else if _testName = 'hascontent' then
      begin
        Result := (not _leftVal.IsEmpty) and (_strVal <> '');
        if Result and (_leftVal.Kind = tkDynArray) then
        begin
          Result := _leftVal.GetArrayLength > 0;
        end;
      end
      else if _testName = 'iterable' then
      begin
        Result := (not _leftVal.IsEmpty) and (_leftVal.Kind = tkDynArray);
      end
      else if _testName = 'mapping' then
      begin
        Result := (not _leftVal.IsEmpty) and (_leftVal.Kind = tkClass) and
          (_leftVal.AsObject is TDictionary<string, TValue>);
      end
      else if _testName = 'sequence' then
      begin
        Result := (not _leftVal.IsEmpty) and (_leftVal.Kind = tkDynArray);
      end;
      _handled := True;
    end;
  end;

  if not _handled then
  begin
    _ops[0] := '!=';
    _ops[1] := '==';
    _ops[2] := '>=';
    _ops[3] := '<=';
    _ops[4] := '>';
    _ops[5] := '<';
    i := 0;
    while (i <= 5) and not _handled do
    begin
      _op := _ops[i];
      _pos := findTopLevelStr(_e, ' ' + _op + ' ');
      if _pos > 0 then
      begin
        _leftVal := resolveAtom(Trim(Copy(_e, 1, _pos - 1)), scopeStack);
        _rightVal := resolveAtom(Trim(Copy(_e, _pos + Length(_op) + 2, MaxInt)), scopeStack);
        Result := compareValues(_leftVal, _rightVal, _op);
        _handled := True;
      end;
      Inc(i);
    end;
  end;

  if not _handled then
  begin
    Result := checkIfTValueIsTruthy(resolveAtom(_e, scopeStack));
  end;
end;

// ---- Path resolution for include/extends ----

function resolveIncludePath(const filename: string; const currentDir: string; searchPaths: TStringList): string;
var
  _candidate: string;
  i: Integer;
  _resolved: Boolean;
begin
  _resolved := False;
  Result := '';

  if (not _resolved) and (currentDir <> '') then
  begin
    _candidate := TPath.Combine(currentDir, filename);
    if TFile.Exists(_candidate) then
    begin
      Result := _candidate;
      _resolved := True;
    end;
  end;

  if (not _resolved) and (searchPaths <> nil) then
  begin
    i := 0;
    while (i < searchPaths.Count) and not _resolved do
    begin
      _candidate := TPath.Combine(searchPaths[i], filename);
      if TFile.Exists(_candidate) then
      begin
        Result := _candidate;
        _resolved := True;
      end;
      Inc(i);
    end;
  end;

  if (not _resolved) and TFile.Exists(filename) then
  begin
    Result := filename;
  end;
end;

// Copies count tokens from src[srcStart..] into dst[dstOffset..] — safe for managed fields
// Forward declaration for recursive include/extends evaluation
function evaluateTokensWithContext(const tokens: TArray<TToken>; const data: TValue;
  ctx: TEvaluateContext; scopeStack: TStack<TScope>;
  macros: TDictionary<string, TMacroEntry>): string; forward;

// ---- Main evaluate functions ----

function evaluate(const tokens: TArray<TToken>; const data: TValue): string;
var
  _ctx: TEvaluateContext;
begin
  _ctx.templateName := '';
  _ctx.templateDir := '';
  _ctx.searchPaths := nil;
  _ctx.globals := nil;
  _ctx.cache := nil;
  _ctx.ownedObjects := nil;
  _ctx.autoescapeEnabled := False;
  _ctx.undefinedMode := umSilent;
  _ctx.sandboxEnabled := False;
  Result := evaluate(tokens, data, _ctx);
end;

function evaluate(const tokens: TArray<TToken>; const data: TValue; const ctx: TEvaluateContext): string;
var
  _scopeStack: TStack<TScope>;
  _rootScope: TScope;
  _macros: TDictionary<string, TMacroEntry>;
  _pair: TPair<string, TValue>;
  _localCtx: TEvaluateContext;
  _isRootCall: Boolean;
begin
  _scopeStack := TStack<TScope>.Create;
  _rootScope := TScope.Create;
  _macros := TDictionary<string, TMacroEntry>.Create;
  // Create ownedObjects list if this is the root evaluate call
  _isRootCall := ctx.ownedObjects = nil;
  _localCtx := ctx;
  if _isRootCall then
  begin
    _localCtx.ownedObjects := TObjectList.Create(True);
  end;
  try
    if _localCtx.globals <> nil then
    begin
      for _pair in _localCtx.globals do
      begin
        _rootScope.AddOrSetValue(LowerCase(_pair.Key), _pair.Value);
      end;
    end;
    populateScope(_rootScope, data);
    _scopeStack.Push(_rootScope);
    Result := evaluateTokensWithContext(tokens, data, _localCtx, _scopeStack, _macros);
  finally
    _scopeStack.Pop;
    FreeAndNil(_rootScope);
    FreeAndNil(_scopeStack);
    FreeAndNil(_macros);
    if _isRootCall then
    begin
      FreeAndNil(_localCtx.ownedObjects);
    end;
  end;
end;

function evaluateTokensWithContext(const tokens: TArray<TToken>; const data: TValue;
  ctx: TEvaluateContext; scopeStack: TStack<TScope>;
  macros: TDictionary<string, TMacroEntry>): string;
var
  _output: string;
  _recursionDepth: Integer;

  function resolveAtomOwned(const atom: string; line: Integer = 0; col: Integer = 0): TValue;
  begin
    Result := resolveAtom(atom, scopeStack, ctx.ownedObjects, ctx.undefinedMode,
      ctx.templateName, line, col);
  end;

  function resolveExprAsString(const expr: string): string;
  var
    _pipePos: Integer;
    _varPart: string;
    _rawValue: TValue;
    _hasMath: Boolean;
    _ternIfPos: Integer;
    _ternElsePos: Integer;
    _ternTrueExpr: string;
    _ternCondExpr: string;
    _ternFalseExpr: string;
  begin
    // Ternary: value if condition else other
    _ternIfPos := findTopLevelStr(expr, ' if ');
    if _ternIfPos > 0 then
    begin
      _ternElsePos := findTopLevelStr(expr, ' else ');
      if _ternElsePos > _ternIfPos then
      begin
        _ternTrueExpr := Trim(Copy(expr, 1, _ternIfPos - 1));
        _ternCondExpr := Trim(Copy(expr, _ternIfPos + 4, _ternElsePos - _ternIfPos - 4));
        _ternFalseExpr := Trim(Copy(expr, _ternElsePos + 6, MaxInt));
        if evalExprAsBoolean(_ternCondExpr, scopeStack) then
        begin
          Result := resolveExprAsString(_ternTrueExpr);
        end
        else
        begin
          Result := resolveExprAsString(_ternFalseExpr);
        end;
        Exit;
      end;
    end;
    _pipePos := findFirstPipePos(expr);
    if _pipePos > 0 then
    begin
      _varPart := Trim(Copy(expr, 1, _pipePos - 1));
      _rawValue := evalConcatExpr(_varPart, scopeStack);
      if _rawValue.IsEmpty then
      begin
        _rawValue := resolveAtomOwned(_varPart);
      end;
      Result := getStringFromTValue(applyFiltersV(expr, _rawValue));
    end
    else
    begin
      _hasMath := (findTopLevelStr(expr, ' + ') > 0) or
                  (findTopLevelStr(expr, ' - ') > 0) or
                  (findTopLevelStr(expr, ' * ') > 0) or
                  (findTopLevelStr(expr, ' // ') > 0) or
                  (findTopLevelStr(expr, ' / ') > 0) or
                  (findTopLevelStr(expr, ' % ') > 0) or
                  (findTopLevelStr(expr, ' ** ') > 0) or
                  (findTopLevelStr(expr, ' ~ ') > 0);
      if _hasMath then
      begin
        Result := getStringFromTValue(evalConcatExpr(Trim(expr), scopeStack));
      end
      else
      begin
        Result := getStringFromTValue(resolveAtomOwned(Trim(expr)));
      end;
    end;
  end;

  function resolveExprAsValue(const expr: string): TValue;
  var
    _pipePos: Integer;
    _varPart: string;
    _rawValue: TValue;
    _hasMath: Boolean;
    _ternIfPos: Integer;
    _ternElsePos: Integer;
    _ternTrueExpr: string;
    _ternCondExpr: string;
    _ternFalseExpr: string;
  begin
    // Ternary: value if condition else other
    _ternIfPos := findTopLevelStr(expr, ' if ');
    if _ternIfPos > 0 then
    begin
      _ternElsePos := findTopLevelStr(expr, ' else ');
      if _ternElsePos > _ternIfPos then
      begin
        _ternTrueExpr := Trim(Copy(expr, 1, _ternIfPos - 1));
        _ternCondExpr := Trim(Copy(expr, _ternIfPos + 4, _ternElsePos - _ternIfPos - 4));
        _ternFalseExpr := Trim(Copy(expr, _ternElsePos + 6, MaxInt));
        if evalExprAsBoolean(_ternCondExpr, scopeStack) then
        begin
          Result := resolveExprAsValue(_ternTrueExpr);
        end
        else
        begin
          Result := resolveExprAsValue(_ternFalseExpr);
        end;
        Exit;
      end;
    end;
    _pipePos := findFirstPipePos(expr);
    if _pipePos > 0 then
    begin
      _varPart := Trim(Copy(expr, 1, _pipePos - 1));
      _rawValue := evalConcatExpr(_varPart, scopeStack);
      if _rawValue.IsEmpty then
      begin
        _rawValue := resolveAtomOwned(_varPart);
      end;
      Result := applyFiltersV(expr, _rawValue);
    end
    else
    begin
      _hasMath := (findTopLevelStr(expr, ' + ') > 0) or
                  (findTopLevelStr(expr, ' - ') > 0) or
                  (findTopLevelStr(expr, ' * ') > 0) or
                  (findTopLevelStr(expr, ' // ') > 0) or
                  (findTopLevelStr(expr, ' / ') > 0) or
                  (findTopLevelStr(expr, ' % ') > 0) or
                  (findTopLevelStr(expr, ' ** ') > 0) or
                  (findTopLevelStr(expr, ' ~ ') > 0);
      if _hasMath then
      begin
        Result := evalConcatExpr(Trim(expr), scopeStack);
      end
      else
      begin
        Result := resolveAtomOwned(Trim(expr));
      end;
    end;
  end;

  function findMatchingEnd(const openKeyword: string; const closeKeyword: string;
    startPos: Integer; searchEnd: Integer): Integer;
  var
    _depth: Integer;
    i: Integer;
    _stmtLower: string;
  begin
    _depth := 1;
    i := startPos;
    while i <= searchEnd do
    begin
      if tokens[i].kind = tkStatement then
      begin
        _stmtLower := LowerCase(Trim(tokens[i].value));
        if SameText(Copy(_stmtLower, 1, Length(openKeyword) + 1), openKeyword + ' ') or
           SameText(_stmtLower, openKeyword) then
          Inc(_depth)
        else if SameText(_stmtLower, closeKeyword) then
        begin
          Dec(_depth);
          if _depth = 0 then
          begin
            Result := i;
            Exit;
          end;
        end;
      end;
      Inc(i);
    end;
    if (startPos > 0) and (startPos <= High(tokens)) then
    begin
      raise ETemplateError.create(
        Format('Unclosed tag "%s"', [openKeyword]),
        ctx.templateName, tokens[startPos - 1].line, tokens[startPos - 1].col);
    end
    else if Length(tokens) > 0 then
    begin
      raise ETemplateError.create(
        Format('Unclosed tag "%s"', [openKeyword]),
        ctx.templateName, tokens[0].line, tokens[0].col);
    end
    else
    begin
      raise ETemplateError.create(
        Format('Unclosed tag "%s"', [openKeyword]),
        ctx.templateName, 0, 0);
    end;
  end;

  function findNextBranchMarker(startPos: Integer; searchEnd: Integer): Integer;
  var
    i: Integer;
    _depth: Integer;
    _stmtLower: string;
  begin
    Result := -1;
    _depth := 0;
    i := startPos;
    while (i <= searchEnd) and (Result = -1) do
    begin
      if tokens[i].kind = tkStatement then
      begin
        _stmtLower := LowerCase(Trim(tokens[i].value));
        if SameText(Copy(_stmtLower, 1, 3), 'if ') then
        begin
          Inc(_depth);
        end
        else if SameText(_stmtLower, 'endif') then
        begin
          Dec(_depth);
        end
        else if (_depth = 0) and
          (SameText(Copy(_stmtLower, 1, 5), 'elif ') or SameText(_stmtLower, 'else')) then
        begin
          Result := i;
        end;
      end;
      Inc(i);
    end;
  end;

  function findForElse(startPos: Integer; searchEnd: Integer): Integer;
  var
    i: Integer;
    _depth: Integer;
    _stmtLower: string;
  begin
    Result := -1;
    _depth := 0;
    i := startPos;
    while (i <= searchEnd) and (Result = -1) do
    begin
      if tokens[i].kind = tkStatement then
      begin
        _stmtLower := LowerCase(Trim(tokens[i].value));
        if SameText(Copy(_stmtLower, 1, 4), 'for ') then
        begin
          Inc(_depth);
        end
        else if SameText(_stmtLower, 'endfor') then
        begin
          Dec(_depth);
        end
        else if (_depth = 0) and SameText(_stmtLower, 'else') then
        begin
          Result := i;
        end;
      end;
      Inc(i);
    end;
  end;

  function findMarkerInBlock(const markerKeyword: string; const openKeyword: string;
    const closeKeyword: string; startPos: Integer; searchEnd: Integer): Integer;
  var
    i: Integer;
    _depth: Integer;
    _stmtLower: string;
  begin
    Result := -1;
    _depth := 0;
    i := startPos;
    while (i <= searchEnd) and (Result = -1) do
    begin
      if tokens[i].kind = tkStatement then
      begin
        _stmtLower := LowerCase(Trim(tokens[i].value));
        if SameText(Copy(_stmtLower, 1, Length(openKeyword) + 1), openKeyword + ' ') or
           SameText(_stmtLower, openKeyword) then
        begin
          Inc(_depth);
        end
        else if SameText(_stmtLower, closeKeyword) then
        begin
          Dec(_depth);
        end
        else if (_depth = 0) and SameText(_stmtLower, markerKeyword) then
        begin
          Result := i;
        end;
      end;
      Inc(i);
    end;
  end;

  // Finds case/default markers at the top level within a switch block
  function findSwitchMarkers(startPos: Integer; searchEnd: Integer): TArray<Integer>;
  var
    i: Integer;
    _depth: Integer;
    _stmtLower: string;
    _count: Integer;
    _markers: TArray<Integer>;
  begin
    SetLength(_markers, 32);
    _count := 0;
    _depth := 0;
    i := startPos;
    while i <= searchEnd do
    begin
      if tokens[i].kind = tkStatement then
      begin
        _stmtLower := LowerCase(Trim(tokens[i].value));
        if SameText(Copy(_stmtLower, 1, 7), 'switch ') or SameText(_stmtLower, 'switch') then
        begin
          Inc(_depth);
        end
        else if SameText(_stmtLower, 'endswitch') then
        begin
          Dec(_depth);
        end
        else if (_depth = 0) and
          (SameText(Copy(_stmtLower, 1, 5), 'case ') or SameText(_stmtLower, 'default')) then
        begin
          if _count >= Length(_markers) then
          begin
            SetLength(_markers, _count + 32);
          end;
          _markers[_count] := i;
          Inc(_count);
        end;
      end;
      Inc(i);
    end;
    SetLength(_markers, _count);
    Result := _markers;
  end;

  procedure processTokensRange(startPos: Integer; endPos: Integer); forward;

  function callMacro(const macroName: string; const argStr: string): string;
  var
    _entry: TMacroEntry;
    _args: TArray<string>;
    _macroScope: TScope;
    _savedOutput: string;
    i: Integer;
    _argVal: TValue;
    _namedArgs: TDictionary<string, string>;
    _positionalCount: Integer;
    _singleArg: string;
    _eqPos: Integer;
    _namedKey: string;
  begin
    Result := '';
    if macros.TryGetValue(LowerCase(macroName), _entry) then
    begin
      // Special case: caller() returns pre-rendered call body content
      if _entry.bodyStart = -1 then
      begin
        Result := getStringFromTValue(resolvePath(scopeStack, '__caller_content'));
        Exit;
      end;
      _args := [];
      if Trim(argStr) <> '' then
      begin
        _args := splitArgs(argStr);
      end;
      // Separate positional and named args (e.g. type='text')
      _namedArgs := TDictionary<string, string>.Create;
      try
        _positionalCount := 0;
        for i := 0 to High(_args) do
        begin
          _singleArg := Trim(_args[i]);
          _eqPos := Pos('=', _singleArg);
          if (_eqPos > 1) and not CharInSet(_singleArg[_eqPos - 1], ['!', '<', '>']) then
          begin
            _namedKey := LowerCase(Trim(Copy(_singleArg, 1, _eqPos - 1)));
            _namedArgs.AddOrSetValue(_namedKey, Trim(Copy(_singleArg, _eqPos + 1, MaxInt)));
          end
          else
          begin
            _positionalCount := i + 1;
          end;
        end;
        _macroScope := TScope.Create;
        try
          for i := 0 to High(_entry.paramNames) do
          begin
            _namedKey := LowerCase(_entry.paramNames[i]);
            if _namedArgs.ContainsKey(_namedKey) then
            begin
              _argVal := resolveAtomOwned(_namedArgs[_namedKey]);
            end
            else if i < _positionalCount then
            begin
              _argVal := resolveAtomOwned(Trim(_args[i]));
            end
            else if (i <= High(_entry.paramDefaults)) and (_entry.paramDefaults[i] <> '') then
            begin
              _argVal := resolveAtomOwned(_entry.paramDefaults[i]);
            end
            else
            begin
              _argVal := TValue.Empty;
            end;
            _macroScope.AddOrSetValue(_namedKey, _argVal);
          end;
          scopeStack.Push(_macroScope);
          _savedOutput := _output;
          _output := '';
          try
            processTokensRange(_entry.bodyStart, _entry.bodyEnd);
            Result := _output;
          finally
            _output := _savedOutput;
            scopeStack.Pop;
          end;
        finally
          FreeAndNil(_macroScope);
        end;
      finally
        FreeAndNil(_namedArgs);
      end;
    end;
  end;

  procedure collectMacrosFromTokens(const srcTokens: TArray<TToken>;
    targetMacros: TDictionary<string, TMacroEntry>);
  var
    i: Integer;
    _stmt: string;
    _stmtLower: string;
    _macroName: string;
    _paramStr: string;
    _parenOpen: Integer;
    _parenClose: Integer;
    _rawParams: TArray<string>;
    _paramNames: TArray<string>;
    _paramDefaults: TArray<string>;
    _entry: TMacroEntry;
    _endPos: Integer;
    j: Integer;
    _eqPos: Integer;
    _singleParam: string;
  begin
    i := 0;
    while i <= High(srcTokens) do
    begin
      if srcTokens[i].kind = tkStatement then
      begin
        _stmt := Trim(srcTokens[i].value);
        _stmtLower := LowerCase(_stmt);
        if SameText(Copy(_stmtLower, 1, 6), 'macro ') then
        begin
          _macroName := Trim(Copy(_stmt, 7, MaxInt));
          _parenOpen := Pos('(', _macroName);
          _parenClose := Pos(')', _macroName);
          _paramStr := '';
          _paramNames := [];
          _paramDefaults := [];
          if (_parenOpen > 0) and (_parenClose > _parenOpen) then
          begin
            _paramStr := Trim(Copy(_macroName, _parenOpen + 1, _parenClose - _parenOpen - 1));
            _macroName := Trim(Copy(_macroName, 1, _parenOpen - 1));
            if _paramStr <> '' then
            begin
              _rawParams := splitArgs(_paramStr);
              SetLength(_paramNames, Length(_rawParams));
              SetLength(_paramDefaults, Length(_rawParams));
              for j := 0 to High(_rawParams) do
              begin
                _singleParam := Trim(_rawParams[j]);
                _eqPos := Pos('=', _singleParam);
                if _eqPos > 0 then
                begin
                  _paramNames[j] := Trim(Copy(_singleParam, 1, _eqPos - 1));
                  _paramDefaults[j] := Trim(Copy(_singleParam, _eqPos + 1, MaxInt));
                end
                else
                begin
                  _paramNames[j] := _singleParam;
                  _paramDefaults[j] := '';
                end;
              end;
            end;
          end;
          _endPos := i + 1;
          while _endPos <= High(srcTokens) do
          begin
            if (srcTokens[_endPos].kind = tkStatement) and
               SameText(LowerCase(Trim(srcTokens[_endPos].value)), 'endmacro') then
              Break;
            Inc(_endPos);
          end;
          _entry.paramNames := _paramNames;
          _entry.paramDefaults := _paramDefaults;
          _entry.bodyStart := i + 1;
          _entry.bodyEnd := _endPos - 1;
          targetMacros.AddOrSetValue(LowerCase(_macroName), _entry);
          i := _endPos + 1;
          Continue;
        end;
      end;
      Inc(i);
    end;
  end;

  procedure collectMacros;
  begin
    collectMacrosFromTokens(tokens, macros);
  end;

  // Flattens a multi-level extends chain into a single token stream with all blocks merged.
  function flattenExtendsChain(const srcTokens: TArray<TToken>; const srcCtx: TEvaluateContext): TArray<TToken>;
  var
    _fcBlocks: TDictionary<string, TArray<TToken>>;
    _fcStmt: string;
    _fcStmtLower: string;
    _fcBlockName: string;
    _fcBlockEndPos: Integer;
    _fcBlockToks: TArray<TToken>;
    _fcParentFile: string;
    _fcParentPath: string;
    _fcParentTokens: TArray<TToken>;
    _fcParentCtx: TEvaluateContext;
    _fcMerged: TArray<TToken>;
    _fcPrevLen: Integer;
    _fcParentStmt: string;
    _fcParentBlockName: string;
    _fcParentBlockEndPos: Integer;
    _fcParentBlockLen: Integer;
    _fcBlockContent: TArray<TToken>;
    _fcSuperToken: TToken;
    _fcParentRendered: string;
    _fcParentBlockRawToks: TArray<TToken>;
    _fcExtendsIdx: Integer;
    _bi: Integer;
    k: Integer;
    m: Integer;
  begin
    // Find extends statement
    _fcExtendsIdx := -1;
    for k := 0 to High(srcTokens) do
    begin
      if srcTokens[k].kind = tkStatement then
      begin
        if SameText(Copy(LowerCase(Trim(srcTokens[k].value)), 1, 8), 'extends ') then
        begin
          _fcExtendsIdx := k;
          Break;
        end;
      end
      else if (srcTokens[k].kind = tkText) and (Trim(srcTokens[k].value) <> '') then
      begin
        Break;
      end;
    end;
    if _fcExtendsIdx < 0 then
    begin
      Result := srcTokens;
      Exit;
    end;
    // Collect child blocks
    _fcBlocks := TDictionary<string, TArray<TToken>>.Create;
    try
      k := _fcExtendsIdx + 1;
      while k <= High(srcTokens) do
      begin
        if srcTokens[k].kind = tkStatement then
        begin
          _fcStmtLower := LowerCase(Trim(srcTokens[k].value));
          if SameText(Copy(_fcStmtLower, 1, 6), 'block ') then
          begin
            _fcBlockName := LowerCase(Trim(Copy(srcTokens[k].value, 7, MaxInt)));
            if SameText(Copy(_fcBlockName, Length(_fcBlockName) - 5, 6), 'scoped') then
            begin
              _fcBlockName := Trim(Copy(_fcBlockName, 1, Length(_fcBlockName) - 6));
            end;
            _fcBlockEndPos := k + 1;
            while _fcBlockEndPos <= High(srcTokens) do
            begin
              if (srcTokens[_fcBlockEndPos].kind = tkStatement) and
                 SameText(LowerCase(Trim(srcTokens[_fcBlockEndPos].value)), 'endblock') then
                Break;
              Inc(_fcBlockEndPos);
            end;
            SetLength(_fcBlockToks, _fcBlockEndPos - k - 1);
            for _bi := 0 to Length(_fcBlockToks) - 1 do
            begin
              _fcBlockToks[_bi] := srcTokens[k + 1 + _bi];
            end;
            _fcBlocks.AddOrSetValue(_fcBlockName, _fcBlockToks);
            k := _fcBlockEndPos + 1;
            Continue;
          end;
        end;
        Inc(k);
      end;
      // Resolve parent
      _fcStmt := Trim(srcTokens[_fcExtendsIdx].value);
      _fcParentFile := Trim(Copy(_fcStmt, 9, MaxInt));
      if (Length(_fcParentFile) >= 2) and CharInSet(_fcParentFile[1], ['''', '"']) then
      begin
        _fcParentFile := Copy(_fcParentFile, 2, Length(_fcParentFile) - 2);
      end;
      _fcParentPath := resolveIncludePath(_fcParentFile, srcCtx.templateDir, srcCtx.searchPaths);
      if _fcParentPath = '' then
      begin
        raise ETemplateError.create('Parent template not found: ' + _fcParentFile,
          srcCtx.templateName, srcTokens[_fcExtendsIdx].line, srcTokens[_fcExtendsIdx].col);
      end;
      _fcParentTokens := tokenize(TFile.ReadAllText(_fcParentPath));
      _fcParentCtx := srcCtx;
      _fcParentCtx.templateName := _fcParentFile;
      _fcParentCtx.templateDir := TPath.GetDirectoryName(_fcParentPath);
      // Recursively flatten parent if it also extends
      _fcParentTokens := flattenExtendsChain(_fcParentTokens, _fcParentCtx);
      // Merge: substitute parent blocks with child overrides
      SetLength(_fcMerged, 0);
      m := 0;
      while m <= High(_fcParentTokens) do
      begin
        if _fcParentTokens[m].kind = tkStatement then
        begin
          _fcParentStmt := LowerCase(Trim(_fcParentTokens[m].value));
          if SameText(Copy(_fcParentStmt, 1, 6), 'block ') then
          begin
            _fcParentBlockName := LowerCase(Trim(Copy(_fcParentTokens[m].value, 7, MaxInt)));
            if SameText(Copy(_fcParentBlockName, Length(_fcParentBlockName) - 5, 6), 'scoped') then
            begin
              _fcParentBlockName := Trim(Copy(_fcParentBlockName, 1, Length(_fcParentBlockName) - 6));
            end;
            _fcParentBlockEndPos := m + 1;
            while _fcParentBlockEndPos <= High(_fcParentTokens) do
            begin
              if (_fcParentTokens[_fcParentBlockEndPos].kind = tkStatement) and
                 SameText(LowerCase(Trim(_fcParentTokens[_fcParentBlockEndPos].value)), 'endblock') then
                Break;
              Inc(_fcParentBlockEndPos);
            end;
            if _fcBlocks.TryGetValue(_fcParentBlockName, _fcBlockContent) then
            begin
              // Pre-render parent block for super()
              _fcParentBlockLen := _fcParentBlockEndPos - m - 1;
              _fcParentRendered := '';
              if _fcParentBlockLen > 0 then
              begin
                SetLength(_fcParentBlockRawToks, _fcParentBlockLen);
                for _bi := 0 to _fcParentBlockLen - 1 do
                begin
                  _fcParentBlockRawToks[_bi] := _fcParentTokens[m + 1 + _bi];
                end;
                _fcParentRendered := evaluateTokensWithContext(
                  _fcParentBlockRawToks, data, _fcParentCtx, scopeStack, macros);
              end;
              // Emit super token + child block content, wrapped in block/endblock for further overrides
              _fcPrevLen := Length(_fcMerged);
              SetLength(_fcMerged, _fcPrevLen + 1);
              _fcMerged[_fcPrevLen] := _fcParentTokens[m]; // block statement
              // Super token
              _fcSuperToken.kind := tkStatement;
              _fcSuperToken.value := '__rawsuper|' + _fcParentRendered;
              _fcSuperToken.line := 0;
              _fcSuperToken.col := 0;
              _fcPrevLen := Length(_fcMerged);
              SetLength(_fcMerged, _fcPrevLen + 1);
              _fcMerged[_fcPrevLen] := _fcSuperToken;
              // Child block tokens
              _fcPrevLen := Length(_fcMerged);
              SetLength(_fcMerged, _fcPrevLen + Length(_fcBlockContent));
              for _bi := 0 to Length(_fcBlockContent) - 1 do
              begin
                _fcMerged[_fcPrevLen + _bi] := _fcBlockContent[_bi];
              end;
              // endblock
              _fcPrevLen := Length(_fcMerged);
              SetLength(_fcMerged, _fcPrevLen + 1);
              _fcMerged[_fcPrevLen] := _fcParentTokens[_fcParentBlockEndPos]; // endblock statement
            end
            else
            begin
              // Keep parent block as-is (wrapped in block/endblock)
              _fcPrevLen := Length(_fcMerged);
              _fcParentBlockLen := _fcParentBlockEndPos - m + 1;
              SetLength(_fcMerged, _fcPrevLen + _fcParentBlockLen);
              for _bi := 0 to _fcParentBlockLen - 1 do
              begin
                _fcMerged[_fcPrevLen + _bi] := _fcParentTokens[m + _bi];
              end;
            end;
            m := _fcParentBlockEndPos + 1;
            Continue;
          end;
        end;
        _fcPrevLen := Length(_fcMerged);
        SetLength(_fcMerged, _fcPrevLen + 1);
        _fcMerged[_fcPrevLen] := _fcParentTokens[m];
        Inc(m);
      end;
      Result := _fcMerged;
    finally
      FreeAndNil(_fcBlocks);
    end;
  end;

  // Handles {% extends 'base.html' %} — collects child blocks and merges with parent.
  // Appends result to _output (via closure). Returns index to advance past the extends block.
  procedure processExtendsStatement(tokenIdx: Integer; endPos: Integer);
  var
    _childTokens: TArray<TToken>;
    _flatTokens: TArray<TToken>;
    _childLen: Integer;
    k: Integer;
  begin
    _childLen := endPos - tokenIdx + 1;
    SetLength(_childTokens, _childLen);
    for k := 0 to _childLen - 1 do
    begin
      _childTokens[k] := tokens[tokenIdx + k];
    end;
    _flatTokens := flattenExtendsChain(_childTokens, ctx);
    _output := _output + evaluateTokensWithContext(
      _flatTokens, data, ctx, scopeStack, macros);
  end;

  procedure processTokensRange(startPos: Integer; endPos: Integer);
  var
    i: Integer;
    _stmt: string;
    _stmtLower: string;
    _forResult: TForParseResult;
    _collection: TValue;
    _blockEndPos: Integer;
    _loopScope: TScope;
    _elementValue: TValue;
    j: Integer;
    _ifExpr: string;
    _markerPos: Integer;
    _markerStmt: string;
    _branchStart: Integer;
    _nextMarker: Integer;
    _matched: Boolean;
    _loopInfo: TLoopInfo;
    _loopInfoValue: TValue;
    _setVarName: string;
    _setValueExpr: string;
    _eqPos: Integer;
    _setValue: TValue;
    _forElsePos: Integer;
    _inclFile: string;
    _inclPath: string;
    _inclTokens: TArray<TToken>;
    _inclCtx: TEvaluateContext;
    _macroCallName: string;
    _macroArgStr: string;
    _parenPos: Integer;
    _outputExpr: string;
    _setExprRight: string;
    _withScope: TScope;
    _withExpr: string;
    _withEqPos: Integer;
    _withVarName: string;
    _withVarValue: TValue;
    _savedOutput: string;
    _cycleArgs: TArray<string>;
    _cycleIdx: Integer;
    _loopVal: TValue;
    _loopIndex0: Integer;
    k: Integer;
    _cycleArg: string;
    _collPipePos: Integer;
    // include ignore missing
    _ignoreMissing: Boolean;
    // for...if pre-filter
    _filteredArr: TArray<TValue>;
    // recursive loop vars
    _recStart: Integer;
    _recEnd: Integer;
    _recVar: string;
    _recCollection: TValue;
    _recLoopInfo: TLoopInfo;
    _recLoopInfoValue: TValue;
    _recScope: TScope;
    _recElem: TValue;
    // namespace mutation vars
    _nsDotPos: Integer;
    _nsName: string;
    _nsFieldName: string;
    _nsObj: TValue;
    // call/caller vars
    _callExpr: string;
    _callerContent: string;
    _callerEntry: TMacroEntry;
    _callerPrevEntry: TMacroEntry;
    _callerHadPrev: Boolean;
    // loop.changed vars
    _changedArg: string;
    _changedPrev: string;
    // import/from vars
    _importExpr: string;
    _importAsPos: Integer;
    _importAlias: string;
    _importFile: string;
    _importPath: string;
    _importTokens: TArray<TToken>;
    _importMacros: TDictionary<string, TMacroEntry>;
    _importPair: TPair<string, TMacroEntry>;
    _importNames: TArray<string>;
    _importEntry: TMacroEntry;
    // break/continue vars
    _breakTriggered: Boolean;
    // filter block vars
    _filterName: string;
    // while vars
    _whileExpr: string;
    _whileCount: Integer;
    // switch vars
    _switchExpr: string;
    _switchVal: string;
    _switchMarkers: TArray<Integer>;
    _switchMatched: Boolean;
    _switchCaseVal: string;
    _switchBodyEnd: Integer;
    // autoescape block vars
    _aeValue: string;
    _savedAE: Boolean;
    // attempt vars
    _recoverPos: Integer;
    // sep vars
    _sepLoopVal: TValue;
    _sepLoopLast: Boolean;
    // global/local vars
    _globalVarName: string;
    _globalExprRight: string;
    // partial vars
    _partialName: string;
    _partialContent: string;
    // debug vars
    _scopeEnum: TStack<TScope>.TEnumerator;
    _scope: TScope;
    _importPair2: TPair<string, TValue>;
    // BUG-1: autoescape with TSafeString
    _resolvedValue: TValue;
    // FEAT-2: pluralize vars
    _pluralizePos: Integer;
    _singularForm: string;
    _pluralForm: string;
    _transResult: string;
    _countExpr: string;
    _countVal: Integer;
  begin
    Inc(_recursionDepth);
    try
    if ctx.sandboxEnabled and (_recursionDepth > 50) then
    begin
      if (startPos >= 0) and (startPos <= High(tokens)) then
        raise ETemplateError.create('Recursion depth limit exceeded in sandbox mode', ctx.templateName, tokens[startPos].line, tokens[startPos].col)
      else
        raise ETemplateError.create('Recursion depth limit exceeded in sandbox mode', ctx.templateName, 0, 0);
    end;
    i := startPos;
    while i <= endPos do
    begin
      case tokens[i].kind of
        tkText:
          begin
            _output := _output + tokens[i].value;
            if ctx.sandboxEnabled and (Length(_output) > 1048576) then
            begin
              raise ETemplateError.create('Output size limit exceeded in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
            end;
            Inc(i);
          end;

        tkOutput:
          begin
            _outputExpr := Trim(tokens[i].value);
            _parenPos := Pos('(', _outputExpr);
            if _parenPos > 0 then
            begin
              // {{ loop.cycle('a', 'b', ...) }}
              if SameText(Copy(LowerCase(_outputExpr), 1, 11), 'loop.cycle(') then
              begin
                _cycleArg := Trim(Copy(_outputExpr, 12, Length(_outputExpr) - 12));
                _cycleArgs := SplitString(_cycleArg, ',');
                for k := 0 to High(_cycleArgs) do
                begin
                  _cycleArgs[k] := Trim(_cycleArgs[k]);
                  if (Length(_cycleArgs[k]) >= 2) and CharInSet(_cycleArgs[k][1], ['''', '"']) then
                  begin
                    _cycleArgs[k] := Copy(_cycleArgs[k], 2, Length(_cycleArgs[k]) - 2);
                  end;
                end;
                if Length(_cycleArgs) > 0 then
                begin
                  _loopVal := resolvePath(scopeStack, 'loop');
                  _loopIndex0 := StrToIntDef(getStringFromTValue(getFieldValue(_loopVal, 'index0')), 0);
                  _cycleIdx := _loopIndex0 mod Length(_cycleArgs);
                  _output := _output + _cycleArgs[_cycleIdx];
                end;
                Inc(i);
                Continue;
              end;

              // {{ loop(collection) }} — recursive loop call
              if SameText(Copy(LowerCase(_outputExpr), 1, 5), 'loop(') then
              begin
                _recStart := -1;
                _recEnd := -1;
                _recVar := '';
                // Find recursive context from scope
                _loopVal := resolvePath(scopeStack, '__recursive_start');
                if not _loopVal.IsEmpty then
                begin
                  _recStart := _loopVal.AsInteger;
                  _recEnd := resolvePath(scopeStack, '__recursive_end').AsInteger;
                  _recVar := getStringFromTValue(resolvePath(scopeStack, '__recursive_var'));
                end;
                if (_recStart >= 0) and (_recVar <> '') then
                begin
                  _macroArgStr := Trim(Copy(_outputExpr, 6, Length(_outputExpr) - 6));
                  _recCollection := resolveAtomOwned(_macroArgStr, tokens[i].line, tokens[i].col);
                  if (not _recCollection.IsEmpty) and (_recCollection.Kind = tkDynArray) and
                     (_recCollection.GetArrayLength > 0) then
                  begin
                    _recLoopInfo.length := _recCollection.GetArrayLength;
                    for k := 0 to _recLoopInfo.length - 1 do
                    begin
                      _recElem := _recCollection.GetArrayElement(k);
                      _recLoopInfo.index := k + 1;
                      _recLoopInfo.index0 := k;
                      _recLoopInfo.revindex := _recLoopInfo.length - k;
                      _recLoopInfo.revindex0 := _recLoopInfo.length - k - 1;
                      _recLoopInfo.first := k = 0;
                      _recLoopInfo.last := k = _recLoopInfo.length - 1;
                      _recScope := TScope.Create;
                      try
                        TValue.Make(@_recLoopInfo, TypeInfo(TLoopInfo), _recLoopInfoValue);
                        _recScope.AddOrSetValue('loop', _recLoopInfoValue);
                        _recScope.AddOrSetValue(_recVar, _recElem);
                        populateScope(_recScope, _recElem);
                        _recScope.AddOrSetValue('__recursive_start', TValue.From<Integer>(_recStart));
                        _recScope.AddOrSetValue('__recursive_end', TValue.From<Integer>(_recEnd));
                        _recScope.AddOrSetValue('__recursive_var', TValue.From<string>(_recVar));
                        scopeStack.Push(_recScope);
                        try
                          processTokensRange(_recStart, _recEnd);
                        finally
                          scopeStack.Pop;
                        end;
                      finally
                        FreeAndNil(_recScope);
                      end;
                    end;
                  end;
                end;
                Inc(i);
                Continue;
              end;

              // {{ loop.changed(expr) }}
              if SameText(Copy(LowerCase(_outputExpr), 1, 13), 'loop.changed(') then
              begin
                _changedArg := resolveExprAsString(Trim(Copy(_outputExpr, 14, Length(_outputExpr) - 14)));
                _changedPrev := getStringFromTValue(resolvePath(scopeStack, '__loop_changed_prev'));
                if _changedArg <> _changedPrev then
                begin
                  _output := _output + 'True';
                  if scopeStack.Count > 0 then
                  begin
                    scopeStack.Peek.AddOrSetValue('__loop_changed_prev', TValue.From<string>(_changedArg));
                  end;
                end
                else
                begin
                  _output := _output + 'False';
                end;
                Inc(i);
                Continue;
              end;

              // {{ super() }}
              if SameText(_outputExpr, 'super()') then
              begin
                _output := _output + resolveExprAsString('__super');
                Inc(i);
                Continue;
              end;

              _macroCallName := Trim(Copy(_outputExpr, 1, _parenPos - 1));
              // joiner() call — check if variable is a joiner dict
              if (Pos('|', _macroCallName) = 0) and (Pos('.', _macroCallName) = 0) then
              begin
                _loopVal := resolvePath(scopeStack, LowerCase(_macroCallName));
                if (not _loopVal.IsEmpty) and (_loopVal.Kind = tkClass) and
                   (_loopVal.AsObject is TDictionary<string, TValue>) and
                   TDictionary<string, TValue>(_loopVal.AsObject).ContainsKey('__joiner_sep') then
                begin
                  _loopIndex0 := TDictionary<string, TValue>(_loopVal.AsObject)
                    .Items['__joiner_count'].AsInteger;
                  if _loopIndex0 = 0 then
                  begin
                    _output := _output + '';
                  end
                  else
                  begin
                    _output := _output + getStringFromTValue(
                      TDictionary<string, TValue>(_loopVal.AsObject).Items['__joiner_sep']);
                  end;
                  TDictionary<string, TValue>(_loopVal.AsObject).AddOrSetValue(
                    '__joiner_count', TValue.From<Integer>(_loopIndex0 + 1));
                  Inc(i);
                  Continue;
                end;
              end;
              if (Pos('|', _macroCallName) = 0) and
                 macros.ContainsKey(LowerCase(_macroCallName)) then
              begin
                _macroArgStr := Trim(Copy(_outputExpr, _parenPos + 1, Length(_outputExpr) - _parenPos - 1));
                _output := _output + callMacro(_macroCallName, _macroArgStr);
                Inc(i);
                Continue;
              end;
            end;
            _resolvedValue := resolveExprAsValue(_outputExpr);
            if _resolvedValue.IsType<TSafeString> then
            begin
              _output := _output + _resolvedValue.AsType<TSafeString>.value;
            end
            else if ctx.autoescapeEnabled then
            begin
              _output := _output + getEscapedXMLString(getStringFromTValue(_resolvedValue));
            end
            else
            begin
              _output := _output + getStringFromTValue(_resolvedValue);
            end;
            if ctx.sandboxEnabled and (Length(_output) > 1048576) then
            begin
              raise ETemplateError.create('Output size limit exceeded in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
            end;
            Inc(i);
          end;

        tkStatement:
          begin
            _stmt := Trim(tokens[i].value);
            _stmtLower := LowerCase(_stmt);

            // {% macro ... %} / {% endmacro %} — skip (already collected in collectMacros)
            if SameText(Copy(_stmtLower, 1, 6), 'macro ') then
            begin
              Inc(i);
              while i <= endPos do
              begin
                if (tokens[i].kind = tkStatement) and
                   SameText(LowerCase(Trim(tokens[i].value)), 'endmacro') then
                  Break;
                Inc(i);
              end;
              Inc(i);
              Continue;
            end;

            if SameText(_stmtLower, 'endmacro') then
            begin
              Inc(i);
              Continue;
            end;

            // {% raw %}...{% endraw %}
            if SameText(_stmtLower, 'raw') then
            begin
              Inc(i);
              while i <= endPos do
              begin
                if (tokens[i].kind = tkStatement) and
                   SameText(LowerCase(Trim(tokens[i].value)), 'endraw') then
                  Break;
                case tokens[i].kind of
                  tkText:
                    _output := _output + tokens[i].value;
                  tkOutput:
                    _output := _output + '{{ ' + tokens[i].value + ' }}';
                  tkStatement:
                    _output := _output + '{% ' + tokens[i].value + ' %}';
                  tkComment:
                    ; // skip comments even in raw
                end;
                Inc(i);
              end;
              Inc(i);
              Continue;
            end;

            // {% include 'file.html' %} or {% include varName %} or {% include ... ignore missing %}
            if SameText(Copy(_stmtLower, 1, 8), 'include ') then
            begin
              if ctx.sandboxEnabled then
              begin
                raise ETemplateError.create('Operation not allowed in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
              end;
              _inclFile := Trim(Copy(_stmt, 9, MaxInt));
              // Check for 'ignore missing' suffix
              _ignoreMissing := (Length(_inclFile) > 14) and
                SameText(Copy(_inclFile, Length(_inclFile) - 13, 14), 'ignore missing');
              if _ignoreMissing then
              begin
                _inclFile := Trim(Copy(_inclFile, 1, Length(_inclFile) - 14));
              end;

              if (Length(_inclFile) >= 2) and CharInSet(_inclFile[1], ['''', '"']) then
              begin
                _inclFile := Copy(_inclFile, 2, Length(_inclFile) - 2);
              end
              else
              begin
                _inclFile := getStringFromTValue(resolveAtomOwned(_inclFile, tokens[i].line, tokens[i].col));
              end;

              // Check partials first (from {% partial "name" %})
              _loopVal := resolvePath(scopeStack, '__partial_' + LowerCase(_inclFile));
              if not _loopVal.IsEmpty then
              begin
                _output := _output + getStringFromTValue(_loopVal);
                Inc(i);
                Continue;
              end;

              _inclPath := resolveIncludePath(_inclFile, ctx.templateDir, ctx.searchPaths);
              if _inclPath <> '' then
              begin
                _inclCtx := ctx;
                _inclCtx.templateName := _inclFile;
                _inclCtx.templateDir := TPath.GetDirectoryName(_inclPath);
                try
                  _inclTokens := tokenize(TFile.ReadAllText(_inclPath));
                except
                  on E: Exception do
                  begin
                    if not _ignoreMissing then
                    begin
                      raise ETemplateError.create(
                        'Cannot read include file: ' + _inclFile,
                        ctx.templateName, tokens[i].line, tokens[i].col);
                    end;
                  end;
                end;
                if _inclPath <> '' then
                begin
                  _output := _output + evaluateTokensWithContext(
                    _inclTokens, data, _inclCtx, scopeStack, macros);
                end;
              end
              else if not _ignoreMissing then
              begin
                raise ETemplateError.create(
                  'Include file not found: ' + _inclFile,
                  ctx.templateName, tokens[i].line, tokens[i].col);
              end;
              Inc(i);
              Continue;
            end;

            // {% extends 'base.html' %} — extracted to processExtendsStatement
            if SameText(Copy(_stmtLower, 1, 8), 'extends ') then
            begin
              if ctx.sandboxEnabled then
              begin
                raise ETemplateError.create('Operation not allowed in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
              end;
              processExtendsStatement(i, endPos);
              Break; // extends consumes the rest of the template
            end;

            // {% for item of/in items %} / {% for i in range(n) %} / {% for item in items | sort %}
            _forResult := parseForStatement(_stmt);
            if _forResult.isValid then
            begin
              _blockEndPos := findMatchingEnd('for', 'endfor', i + 1, endPos);
              _collPipePos := findFirstPipePos(_forResult.collectionExpr);
              if _collPipePos > 0 then
              begin
                _collection := applyFiltersV(
                  _forResult.collectionExpr,
                  resolveAtomOwned(Trim(Copy(_forResult.collectionExpr, 1, _collPipePos - 1)), tokens[i].line, tokens[i].col));
              end
              else
              begin
                _collection := resolveAtomOwned(Trim(_forResult.collectionExpr), tokens[i].line, tokens[i].col);
              end;
              _forElsePos := findForElse(i + 1, _blockEndPos - 1);

              // Pre-filter collection with 'for...if' condition
              if (not _collection.IsEmpty) and (_collection.Kind = tkDynArray) and
                 (_forResult.filterExpr <> '') then
              begin
                SetLength(_filteredArr, 0);
                for j := 0 to _collection.GetArrayLength - 1 do
                begin
                  _elementValue := _collection.GetArrayElement(j);
                  _loopScope := TScope.Create;
                  try
                    _loopScope.AddOrSetValue(LowerCase(_forResult.loopVar), _elementValue);
                    populateScope(_loopScope, _elementValue);
                    scopeStack.Push(_loopScope);
                    try
                      if evalExprAsBoolean(_forResult.filterExpr, scopeStack) then
                      begin
                        SetLength(_filteredArr, Length(_filteredArr) + 1);
                        _filteredArr[High(_filteredArr)] := _elementValue;
                      end;
                    finally
                      scopeStack.Pop;
                    end;
                  finally
                    FreeAndNil(_loopScope);
                  end;
                end;
                _collection := TValue.From<TArray<TValue>>(_filteredArr);
              end;

              if (not _collection.IsEmpty) and (_collection.Kind = tkDynArray) and
                 (_collection.GetArrayLength > 0) then
              begin
                _loopInfo.length := _collection.GetArrayLength;
                // Determine loop depth from parent loop scope
                _loopVal := resolvePath(scopeStack, 'loop');
                if _loopVal.IsEmpty then
                begin
                  _loopInfo.depth := 1;
                  _loopInfo.depth0 := 0;
                end
                else
                begin
                  _loopInfo.depth := StrToIntDef(getStringFromTValue(getFieldValue(_loopVal, 'depth')), 0) + 1;
                  _loopInfo.depth0 := _loopInfo.depth - 1;
                end;
                if scopeStack.Count > 0 then
                begin
                  scopeStack.Peek.AddOrSetValue('__loop_changed_prev', TValue.From<string>(#0));
                end;
                for j := 0 to _loopInfo.length - 1 do
                begin
                  _elementValue := _collection.GetArrayElement(j);
                  _loopInfo.index := j + 1;
                  _loopInfo.index0 := j;
                  _loopInfo.revindex := _loopInfo.length - j;
                  _loopInfo.revindex0 := _loopInfo.length - j - 1;
                  _loopInfo.first := j = 0;
                  _loopInfo.last := j = _loopInfo.length - 1;
                  if j > 0 then
                  begin
                    _loopInfo.previtem := _collection.GetArrayElement(j - 1);
                  end
                  else
                  begin
                    _loopInfo.previtem := TValue.Empty;
                  end;
                  if j < _loopInfo.length - 1 then
                  begin
                    _loopInfo.nextitem := _collection.GetArrayElement(j + 1);
                  end
                  else
                  begin
                    _loopInfo.nextitem := TValue.Empty;
                  end;
                  _loopScope := TScope.Create;
                  try
                    TValue.Make(@_loopInfo, TypeInfo(TLoopInfo), _loopInfoValue);
                    _loopScope.AddOrSetValue('loop', _loopInfoValue);
                    _loopScope.AddOrSetValue(LowerCase(_forResult.loopVar), _elementValue);
                    populateScope(_loopScope, _elementValue);
                    // For recursive loops, store the for body range and loop var for loop() calls
                    if _forResult.isRecursive then
                    begin
                      _loopScope.AddOrSetValue('__recursive_start', TValue.From<Integer>(i + 1));
                      if _forElsePos >= 0 then
                      begin
                        _loopScope.AddOrSetValue('__recursive_end', TValue.From<Integer>(_forElsePos - 1));
                      end
                      else
                      begin
                        _loopScope.AddOrSetValue('__recursive_end', TValue.From<Integer>(_blockEndPos - 1));
                      end;
                      _loopScope.AddOrSetValue('__recursive_var', TValue.From<string>(LowerCase(_forResult.loopVar)));
                    end;
                    scopeStack.Push(_loopScope);
                    _breakTriggered := False;
                    try
                      try
                        if _forElsePos >= 0 then
                        begin
                          processTokensRange(i + 1, _forElsePos - 1);
                        end
                        else
                        begin
                          processTokensRange(i + 1, _blockEndPos - 1);
                        end;
                      except
                        on E: EContinueLoop do
                          ; // skip to next iteration
                        on E: EBreakLoop do
                          _breakTriggered := True;
                      end;
                    finally
                      scopeStack.Pop;
                    end;
                  finally
                    FreeAndNil(_loopScope);
                  end;
                  if _breakTriggered then
                  begin
                    Break;
                  end;
                end;
              end
              else
              begin
                if _forElsePos >= 0 then
                begin
                  processTokensRange(_forElsePos + 1, _blockEndPos - 1);
                end;
              end;

              i := _blockEndPos + 1;
            end

            // {% if expr %}...{% elif %}...{% else %}...{% endif %}
            else if SameText(Copy(_stmtLower, 1, 3), 'if ') then
            begin
              _ifExpr := Trim(Copy(_stmt, 4, MaxInt));
              _blockEndPos := findMatchingEnd('if', 'endif', i + 1, endPos);
              _matched := False;
              _branchStart := i + 1;
              _markerPos := findNextBranchMarker(_branchStart, _blockEndPos - 1);

              if evalExprAsBoolean(_ifExpr, scopeStack) then
              begin
                if _markerPos >= 0 then
                begin
                  processTokensRange(_branchStart, _markerPos - 1);
                end
                else
                begin
                  processTokensRange(_branchStart, _blockEndPos - 1);
                end;
                _matched := True;
              end;

              while (not _matched) and (_markerPos >= 0) do
              begin
                _markerStmt := Trim(tokens[_markerPos].value);
                _branchStart := _markerPos + 1;
                _nextMarker := findNextBranchMarker(_branchStart, _blockEndPos - 1);
                if SameText(LowerCase(Copy(_markerStmt, 1, 5)), 'elif ') then
                begin
                  _ifExpr := Trim(Copy(_markerStmt, 6, MaxInt));
                  if evalExprAsBoolean(_ifExpr, scopeStack) then
                  begin
                    if _nextMarker >= 0 then
                    begin
                      processTokensRange(_branchStart, _nextMarker - 1);
                    end
                    else
                    begin
                      processTokensRange(_branchStart, _blockEndPos - 1);
                    end;
                    _matched := True;
                  end;
                end
                else
                begin
                  if _nextMarker >= 0 then
                  begin
                    processTokensRange(_branchStart, _nextMarker - 1);
                  end
                  else
                  begin
                    processTokensRange(_branchStart, _blockEndPos - 1);
                  end;
                  _matched := True;
                end;
                _markerPos := _nextMarker;
              end;

              i := _blockEndPos + 1;
            end

            // {% set varname = expr %} / {% set varname = expr | filter %}
            // {% set ns.field = expr %} (namespace mutation)
            // {% set varname %}...{% endset %} (block capture)
            else if SameText(Copy(_stmtLower, 1, 4), 'set ') then
            begin
              _setValueExpr := Trim(Copy(_stmt, 5, MaxInt));
              _eqPos := Pos('=', _setValueExpr);
              if _eqPos > 0 then
              begin
                _setVarName := Trim(Copy(_setValueExpr, 1, _eqPos - 1));
                _setExprRight := Trim(Copy(_setValueExpr, _eqPos + 1, MaxInt));
                _nsDotPos := Pos('.', _setVarName);
                if _nsDotPos > 0 then
                begin
                  // Namespace mutation: ns.field = value
                  _nsName := LowerCase(Trim(Copy(_setVarName, 1, _nsDotPos - 1)));
                  _nsFieldName := LowerCase(Trim(Copy(_setVarName, _nsDotPos + 1, MaxInt)));
                  _nsObj := resolvePath(scopeStack, _nsName);
                  if (not _nsObj.IsEmpty) and (_nsObj.Kind = tkClass) and
                     (_nsObj.AsObject is TDictionary<string, TValue>) then
                  begin
                    _setValue := TValue.From<string>(resolveExprAsString(_setExprRight));
                    TDictionary<string, TValue>(_nsObj.AsObject).AddOrSetValue(_nsFieldName, _setValue);
                  end;
                end
                else
                begin
                  _setValue := TValue.From<string>(resolveExprAsString(_setExprRight));
                  if scopeStack.Count > 0 then
                  begin
                    scopeStack.Peek.AddOrSetValue(LowerCase(_setVarName), _setValue);
                  end;
                end;
                Inc(i);
              end
              else
              begin
                // Block capture: {% set varname %}...{% endset %}
                _setVarName := Trim(_setValueExpr);
                _blockEndPos := findMatchingEnd('set', 'endset', i + 1, endPos);
                _savedOutput := _output;
                _output := '';
                processTokensRange(i + 1, _blockEndPos - 1);
                _setValue := TValue.From<string>(_output);
                _output := _savedOutput;
                if scopeStack.Count > 0 then
                begin
                  scopeStack.Peek.AddOrSetValue(LowerCase(_setVarName), _setValue);
                end;
                i := _blockEndPos + 1;
              end;
            end

            // {% with varname = expr %}...{% endwith %}
            // supports multiple: {% with a = expr1, b = expr2 %}
            else if SameText(Copy(_stmtLower, 1, 5), 'with ') then
            begin
              _blockEndPos := findMatchingEnd('with', 'endwith', i + 1, endPos);
              _withScope := TScope.Create;
              try
                _withExpr := Trim(Copy(_stmt, 6, MaxInt));
                // split assignments by comma at top-level
                for _withVarName in splitArgs(_withExpr) do
                begin
                  _withEqPos := Pos('=', _withVarName);
                  if _withEqPos > 0 then
                  begin
                    _macroCallName := LowerCase(Trim(Copy(_withVarName, 1, _withEqPos - 1)));
                    _setExprRight := Trim(Copy(_withVarName, _withEqPos + 1, MaxInt));
                    _withVarValue := TValue.From<string>(resolveExprAsString(_setExprRight));
                    _withScope.AddOrSetValue(_macroCallName, _withVarValue);
                  end;
                end;
                scopeStack.Push(_withScope);
                try
                  processTokensRange(i + 1, _blockEndPos - 1);
                finally
                  scopeStack.Pop;
                end;
              finally
                FreeAndNil(_withScope);
              end;
              i := _blockEndPos + 1;
            end

            else if SameText(_stmtLower, 'endwith') or SameText(_stmtLower, 'endset') then
            begin
              Inc(i);
            end

            // {% call macroname(args) %}...{% endcall %}
            else if SameText(Copy(_stmtLower, 1, 5), 'call ') then
            begin
              _callExpr := Trim(Copy(_stmt, 6, MaxInt));
              _blockEndPos := findMatchingEnd('call', 'endcall', i + 1, endPos);
              // Pre-render the call body as caller content
              _savedOutput := _output;
              _output := '';
              processTokensRange(i + 1, _blockEndPos - 1);
              _callerContent := _output;
              _output := _savedOutput;
              // Register temporary 'caller' macro that returns the pre-rendered content
              _callerEntry.paramNames := [];
              _callerEntry.paramDefaults := [];
              _callerEntry.bodyStart := -1;
              _callerEntry.bodyEnd := -2;
              _callerHadPrev := macros.TryGetValue('caller', _callerPrevEntry);
              macros.AddOrSetValue('caller', _callerEntry);
              // Parse macro name and args from call expression
              _parenPos := Pos('(', _callExpr);
              if _parenPos > 0 then
              begin
                _macroCallName := Trim(Copy(_callExpr, 1, _parenPos - 1));
                _macroArgStr := Trim(Copy(_callExpr, _parenPos + 1, Length(_callExpr) - _parenPos - 1));
              end
              else
              begin
                _macroCallName := _callExpr;
                _macroArgStr := '';
              end;
              // Temporarily push caller content into scope
              if scopeStack.Count > 0 then
              begin
                scopeStack.Peek.AddOrSetValue('__caller_content', TValue.From<string>(_callerContent));
              end;
              _output := _output + callMacro(_macroCallName, _macroArgStr);
              // Restore previous caller macro if any
              if _callerHadPrev then
              begin
                macros.AddOrSetValue('caller', _callerPrevEntry);
              end
              else
              begin
                macros.Remove('caller');
              end;
              i := _blockEndPos + 1;
              Continue;
            end

            // {% import 'file.html' as alias %}
            else if SameText(Copy(_stmtLower, 1, 7), 'import ') then
            begin
              if ctx.sandboxEnabled then
              begin
                raise ETemplateError.create('Operation not allowed in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
              end;
              _importExpr := Trim(Copy(_stmt, 8, MaxInt));
              _importAsPos := Pos(' as ', LowerCase(_importExpr));
              if _importAsPos > 0 then
              begin
                _importAlias := LowerCase(Trim(Copy(_importExpr, _importAsPos + 4, MaxInt)));
                _importFile := Trim(Copy(_importExpr, 1, _importAsPos - 1));
                if (Length(_importFile) >= 2) and CharInSet(_importFile[1], ['''', '"']) then
                begin
                  _importFile := Copy(_importFile, 2, Length(_importFile) - 2);
                end;
                _importPath := resolveIncludePath(_importFile, ctx.templateDir, ctx.searchPaths);
                if _importPath <> '' then
                begin
                  _importTokens := tokenize(TFile.ReadAllText(_importPath));
                  _importMacros := TDictionary<string, TMacroEntry>.Create;
                  try
                    collectMacrosFromTokens(_importTokens, _importMacros);
                    for _importPair in _importMacros do
                    begin
                      macros.AddOrSetValue(_importAlias + '.' + _importPair.Key, _importPair.Value);
                    end;
                  finally
                    FreeAndNil(_importMacros);
                  end;
                end;
              end;
              Inc(i);
              Continue;
            end

            // {% from 'file.html' import name1, name2 %}
            else if SameText(Copy(_stmtLower, 1, 5), 'from ') then
            begin
              if ctx.sandboxEnabled then
              begin
                raise ETemplateError.create('Operation not allowed in sandbox mode', ctx.templateName, tokens[i].line, tokens[i].col);
              end;
              _importExpr := Trim(Copy(_stmt, 6, MaxInt));
              _importAsPos := Pos(' import ', LowerCase(_importExpr));
              if _importAsPos > 0 then
              begin
                _importFile := Trim(Copy(_importExpr, 1, _importAsPos - 1));
                if (Length(_importFile) >= 2) and CharInSet(_importFile[1], ['''', '"']) then
                begin
                  _importFile := Copy(_importFile, 2, Length(_importFile) - 2);
                end;
                _importNames := splitArgs(Trim(Copy(_importExpr, _importAsPos + 8, MaxInt)));
                _importPath := resolveIncludePath(_importFile, ctx.templateDir, ctx.searchPaths);
                if _importPath <> '' then
                begin
                  _importTokens := tokenize(TFile.ReadAllText(_importPath));
                  _importMacros := TDictionary<string, TMacroEntry>.Create;
                  try
                    collectMacrosFromTokens(_importTokens, _importMacros);
                    for k := 0 to High(_importNames) do
                    begin
                      _importAlias := LowerCase(Trim(_importNames[k]));
                      if _importMacros.TryGetValue(_importAlias, _importEntry) then
                      begin
                        macros.AddOrSetValue(_importAlias, _importEntry);
                      end;
                    end;
                  finally
                    FreeAndNil(_importMacros);
                  end;
                end;
              end;
              Inc(i);
              Continue;
            end

            // synthetic token injected by processExtendsStatement to carry parent block content
            else if SameText(Copy(_stmtLower, 1, 11), '__rawsuper|') then
            begin
              if scopeStack.Count > 0 then
              begin
                scopeStack.Peek.AddOrSetValue('__super',
                  TValue.From<string>(Copy(tokens[i].value, 12, MaxInt)));
              end;
              Inc(i);
            end

            // {% break %}
            else if SameText(_stmtLower, 'break') then
            begin
              raise EBreakLoop.Create('');
            end

            // {% continue %}
            else if SameText(_stmtLower, 'continue') then
            begin
              raise EContinueLoop.Create('');
            end

            // {% filter filtername %}...{% endfilter %}
            else if SameText(Copy(_stmtLower, 1, 7), 'filter ') then
            begin
              _filterName := Trim(Copy(_stmt, 8, MaxInt));
              _blockEndPos := findMatchingEnd('filter', 'endfilter', i + 1, endPos);
              _savedOutput := _output;
              _output := '';
              processTokensRange(i + 1, _blockEndPos - 1);
              _output := _savedOutput + getStringFromTValue(
                applyFilterByNameV(_filterName, TValue.From<string>(_output)));
              i := _blockEndPos + 1;
            end

            // {% do expr %} — evaluate expression, discard result
            else if SameText(Copy(_stmtLower, 1, 3), 'do ') then
            begin
              resolveExprAsString(Trim(Copy(_stmt, 4, MaxInt)));
              Inc(i);
            end

            // {% autoescape true/false %}...{% endautoescape %}
            else if SameText(Copy(_stmtLower, 1, 11), 'autoescape ') then
            begin
              _aeValue := LowerCase(Trim(Copy(_stmt, 12, MaxInt)));
              _blockEndPos := findMatchingEnd('autoescape', 'endautoescape', i + 1, endPos);
              _savedAE := ctx.autoescapeEnabled;
              ctx.autoescapeEnabled := (_aeValue = 'true') or (_aeValue = 'on') or (_aeValue = '1');
              processTokensRange(i + 1, _blockEndPos - 1);
              ctx.autoescapeEnabled := _savedAE;
              i := _blockEndPos + 1;
            end

            // {% attempt %}...{% recover %}...{% endattempt %}
            else if SameText(_stmtLower, 'attempt') then
            begin
              _blockEndPos := findMatchingEnd('attempt', 'endattempt', i + 1, endPos);
              _recoverPos := findMarkerInBlock('recover', 'attempt', 'endattempt', i + 1, _blockEndPos - 1);
              _savedOutput := _output;
              _output := '';
              try
                if _recoverPos >= 0 then
                begin
                  processTokensRange(i + 1, _recoverPos - 1);
                end
                else
                begin
                  processTokensRange(i + 1, _blockEndPos - 1);
                end;
                _savedOutput := _savedOutput + _output;
              except
                on E: Exception do
                begin
                  _output := '';
                  if _recoverPos >= 0 then
                  begin
                    processTokensRange(_recoverPos + 1, _blockEndPos - 1);
                  end;
                  _savedOutput := _savedOutput + _output;
                end;
              end;
              _output := _savedOutput;
              i := _blockEndPos + 1;
            end

            // {% while condition %}...{% endwhile %}
            else if SameText(Copy(_stmtLower, 1, 6), 'while ') then
            begin
              _whileExpr := Trim(Copy(_stmt, 7, MaxInt));
              _blockEndPos := findMatchingEnd('while', 'endwhile', i + 1, endPos);
              _whileCount := 0;
              while evalExprAsBoolean(_whileExpr, scopeStack) and (_whileCount < 10000) do
              begin
                try
                  processTokensRange(i + 1, _blockEndPos - 1);
                except
                  on E: EContinueLoop do
                    ;
                  on E: EBreakLoop do
                    Break;
                end;
                Inc(_whileCount);
              end;
              i := _blockEndPos + 1;
            end

            // {% switch expr %}{% case val %}...{% case val2 %}...{% default %}...{% endswitch %}
            else if SameText(Copy(_stmtLower, 1, 7), 'switch ') then
            begin
              _switchExpr := resolveExprAsString(Trim(Copy(_stmt, 8, MaxInt)));
              _blockEndPos := findMatchingEnd('switch', 'endswitch', i + 1, endPos);
              _switchMarkers := findSwitchMarkers(i + 1, _blockEndPos - 1);
              _switchMatched := False;
              for k := 0 to High(_switchMarkers) do
              begin
                if _switchMatched then
                begin
                  Break;
                end;
                _markerStmt := LowerCase(Trim(tokens[_switchMarkers[k]].value));
                if SameText(Copy(_markerStmt, 1, 5), 'case ') then
                begin
                  _switchCaseVal := resolveExprAsString(Trim(Copy(tokens[_switchMarkers[k]].value, 6, MaxInt)));
                  if _switchCaseVal = _switchExpr then
                  begin
                    if k < High(_switchMarkers) then
                    begin
                      _switchBodyEnd := _switchMarkers[k + 1] - 1;
                    end
                    else
                    begin
                      _switchBodyEnd := _blockEndPos - 1;
                    end;
                    processTokensRange(_switchMarkers[k] + 1, _switchBodyEnd);
                    _switchMatched := True;
                  end;
                end
                else if SameText(_markerStmt, 'default') then
                begin
                  if k < High(_switchMarkers) then
                  begin
                    _switchBodyEnd := _switchMarkers[k + 1] - 1;
                  end
                  else
                  begin
                    _switchBodyEnd := _blockEndPos - 1;
                  end;
                  processTokensRange(_switchMarkers[k] + 1, _switchBodyEnd);
                  _switchMatched := True;
                end;
              end;
              i := _blockEndPos + 1;
            end

            // {% sep %}...{% endsep %} — render content between iterations, not on last
            else if SameText(_stmtLower, 'sep') then
            begin
              _blockEndPos := findMatchingEnd('sep', 'endsep', i + 1, endPos);
              _sepLoopLast := True;
              _sepLoopVal := resolvePath(scopeStack, 'loop');
              if not _sepLoopVal.IsEmpty then
              begin
                _sepLoopLast := checkIfTValueIsTruthy(getFieldValue(_sepLoopVal, 'last'));
              end;
              if not _sepLoopLast then
              begin
                processTokensRange(i + 1, _blockEndPos - 1);
              end;
              i := _blockEndPos + 1;
            end

            // {% compress %}...{% endcompress %} — collapse whitespace
            else if SameText(_stmtLower, 'compress') then
            begin
              _blockEndPos := findMatchingEnd('compress', 'endcompress', i + 1, endPos);
              _savedOutput := _output;
              _output := '';
              processTokensRange(i + 1, _blockEndPos - 1);
              _output := _savedOutput + TRegEx.Replace(_output, '\s+', ' ');
              i := _blockEndPos + 1;
            end

            // {% debug %} — dump scope variables
            else if SameText(_stmtLower, 'debug') then
            begin
              _output := _output + '<pre class="debug">' + sLineBreak;
              _scopeEnum := scopeStack.GetEnumerator;
              try
                while _scopeEnum.MoveNext do
                begin
                  for _importPair2 in _scopeEnum.Current do
                  begin
                    if Copy(_importPair2.Key, 1, 2) <> '__' then
                    begin
                      _output := _output + _importPair2.Key + ' = ' +
                        getStringFromTValue(_importPair2.Value) + sLineBreak;
                    end;
                  end;
                end;
              finally
                FreeAndNil(_scopeEnum);
              end;
              _output := _output + '</pre>';
              Inc(i);
            end

            // {% stop %} or {% stop "message" %}
            else if SameText(_stmtLower, 'stop') or SameText(Copy(_stmtLower, 1, 5), 'stop ') then
            begin
              raise EStopTemplate.Create(Trim(Copy(_stmt, 5, MaxInt)));
            end

            // {% unless condition %}...{% endunless %}
            else if SameText(Copy(_stmtLower, 1, 7), 'unless ') then
            begin
              _ifExpr := Trim(Copy(_stmt, 8, MaxInt));
              _blockEndPos := findMatchingEnd('unless', 'endunless', i + 1, endPos);
              if not evalExprAsBoolean(_ifExpr, scopeStack) then
              begin
                processTokensRange(i + 1, _blockEndPos - 1);
              end;
              i := _blockEndPos + 1;
            end

            // {% partial "name" %}...{% endpartial %} — store rendered content for later include
            else if SameText(Copy(_stmtLower, 1, 8), 'partial ') then
            begin
              _partialName := Trim(Copy(_stmt, 9, MaxInt));
              if (Length(_partialName) >= 2) and CharInSet(_partialName[1], ['''', '"']) then
              begin
                _partialName := Copy(_partialName, 2, Length(_partialName) - 2);
              end;
              _blockEndPos := findMatchingEnd('partial', 'endpartial', i + 1, endPos);
              _savedOutput := _output;
              _output := '';
              processTokensRange(i + 1, _blockEndPos - 1);
              _partialContent := _output;
              _output := _savedOutput;
              if scopeStack.Count > 0 then
              begin
                scopeStack.Peek.AddOrSetValue('__partial_' + LowerCase(_partialName),
                  TValue.From<string>(_partialContent));
              end;
              i := _blockEndPos + 1;
            end

            // {% global var = expr %}
            else if SameText(Copy(_stmtLower, 1, 7), 'global ') then
            begin
              _globalVarName := Trim(Copy(_stmt, 8, MaxInt));
              _eqPos := Pos('=', _globalVarName);
              if _eqPos > 0 then
              begin
                _globalExprRight := Trim(Copy(_globalVarName, _eqPos + 1, MaxInt));
                _globalVarName := LowerCase(Trim(Copy(_globalVarName, 1, _eqPos - 1)));
                _setValue := TValue.From<string>(resolveExprAsString(_globalExprRight));
                if ctx.globals <> nil then
                begin
                  ctx.globals.AddOrSetValue(_globalVarName, _setValue);
                end;
                // Also set in root scope (bottom of stack)
                _scopeEnum := scopeStack.GetEnumerator;
                try
                  _scope := nil;
                  while _scopeEnum.MoveNext do
                  begin
                    _scope := _scopeEnum.Current;
                  end;
                  if _scope <> nil then
                  begin
                    _scope.AddOrSetValue(_globalVarName, _setValue);
                  end;
                finally
                  FreeAndNil(_scopeEnum);
                end;
              end;
              Inc(i);
            end

            // {% local var = expr %}
            else if SameText(Copy(_stmtLower, 1, 6), 'local ') then
            begin
              _globalVarName := Trim(Copy(_stmt, 7, MaxInt));
              _eqPos := Pos('=', _globalVarName);
              if _eqPos > 0 then
              begin
                _globalExprRight := Trim(Copy(_globalVarName, _eqPos + 1, MaxInt));
                _globalVarName := LowerCase(Trim(Copy(_globalVarName, 1, _eqPos - 1)));
                _setValue := TValue.From<string>(resolveExprAsString(_globalExprRight));
                if scopeStack.Count > 0 then
                begin
                  scopeStack.Peek.AddOrSetValue(_globalVarName, _setValue);
                end;
              end;
              Inc(i);
            end

            // {% trans %}...{% endtrans %} — i18n translation block
            else if SameText(_stmtLower, 'trans') or SameText(Copy(_stmtLower, 1, 5), 'trans ') then
            begin
              _blockEndPos := findMatchingEnd('trans', 'endtrans', i + 1, endPos);
              _pluralizePos := findMarkerInBlock('pluralize', 'trans', 'endtrans', i + 1, _blockEndPos - 1);
              if _pluralizePos >= 0 then
              begin
                // Render singular form
                _savedOutput := _output;
                _output := '';
                processTokensRange(i + 1, _pluralizePos - 1);
                _singularForm := _output;
                // Render plural form
                _output := '';
                processTokensRange(_pluralizePos + 1, _blockEndPos - 1);
                _pluralForm := _output;
                // Determine count from expression after 'trans'
                _countExpr := Trim(Copy(_stmt, 6, MaxInt));
                _countVal := StrToIntDef(resolveExprAsString(_countExpr), 0);
                if _countVal = 1 then
                begin
                  _transResult := _singularForm;
                end
                else
                begin
                  _transResult := _pluralForm;
                end;
                // Translate
                if Assigned(_translateFn) then
                begin
                  _output := _savedOutput + _translateFn(_transResult);
                end
                else
                begin
                  _output := _savedOutput + _transResult;
                end;
              end
              else
              begin
                // Existing behavior (no pluralize)
                _savedOutput := _output;
                _output := '';
                processTokensRange(i + 1, _blockEndPos - 1);
                if Assigned(_translateFn) then
                begin
                  _output := _savedOutput + _translateFn(_output);
                end
                else
                begin
                  _output := _savedOutput + _output;
                end;
              end;
              i := _blockEndPos + 1;
            end

            // {% cycle 'a', 'b', 'c' %}
            else if SameText(Copy(_stmtLower, 1, 6), 'cycle ') then
            begin
              _cycleArg := Trim(Copy(_stmt, 7, MaxInt));
              _cycleArgs := splitArgs(_cycleArg);
              for k := 0 to High(_cycleArgs) do
              begin
                _cycleArgs[k] := Trim(_cycleArgs[k]);
                if (Length(_cycleArgs[k]) >= 2) and CharInSet(_cycleArgs[k][1], ['''', '"']) then
                begin
                  _cycleArgs[k] := Copy(_cycleArgs[k], 2, Length(_cycleArgs[k]) - 2);
                end;
              end;
              if Length(_cycleArgs) > 0 then
              begin
                _loopVal := resolvePath(scopeStack, 'loop');
                _loopIndex0 := StrToIntDef(getStringFromTValue(getFieldValue(_loopVal, 'index0')), 0);
                _cycleIdx := _loopIndex0 mod Length(_cycleArgs);
                _output := _output + _cycleArgs[_cycleIdx];
              end;
              Inc(i);
            end

            else
            begin
              Inc(i);
            end;
          end;

      else
      begin
        Inc(i);
      end;
      end;
    end;
    finally
      Dec(_recursionDepth);
    end;
  end;

begin
  _output := '';
  _recursionDepth := 0;
  collectMacros;
  try
    processTokensRange(0, High(tokens));
  except
    on E: EStopTemplate do
    begin
      E.output := _output;
    end;
  end;
  Result := _output;
end;

end.
