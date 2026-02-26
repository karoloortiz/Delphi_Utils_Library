unit KLib.Template.Filters;

interface

uses
  System.Generics.Collections,
  System.Rtti;

type
  // String→string filter (for scalar values)
  TFilterFn = reference to function(const value: string): string;
  // TValue→TValue filter (for array/complex values: sort, join, unique, sum, batch, split)
  TFilterFnV = reference to function(const value: TValue): TValue;

procedure registerFilter(const name: string; fn: TFilterFn);
procedure registerFilterV(const name: string; fn: TFilterFnV);

// Applies filter pipeline from expr (e.g. 'title | upper | trim') starting from rawValue
function applyFilters(const expr: string; const rawValue: string): string;
// Applies filter pipeline returning TValue (used when caller needs array output)
function applyFiltersV(const expr: string; const rawValue: TValue): TValue;
// Applies a single filter by name with args (e.g. 'upper' or 'truncate(50)')
function applyFilterByNameV(const filterExpr: string; const value: TValue): TValue;
// Splits s on ',' respecting quoted strings and nested parentheses
function splitArgs(const s: string): TArray<string>;

implementation

uses
  System.SysUtils, System.StrUtils, System.TypInfo, System.RegularExpressions,
  System.Math, System.NetEncoding, System.DateUtils, System.Hash,
  KLib.StringUtils, KLib.Utils, KLib.Types;

function tvalueToPrettyJson(const value: TValue; indent: Integer): string; forward;

function tvalueToJson(const value: TValue): string;
var
  _dict: TDictionary<string, TValue>;
  _pair: TPair<string, TValue>;
  _result: string;
  _arrLen: Integer;
  _first: Boolean;
  i: Integer;
  _strVal: string;
  _f: Double;
begin
  if value.IsEmpty then
  begin
    Result := 'null';
  end
  else if value.Kind = tkDynArray then
  begin
    _arrLen := value.GetArrayLength;
    _result := '[';
    for i := 0 to _arrLen - 1 do
    begin
      if i > 0 then
      begin
        _result := _result + ', ';
      end;
      _result := _result + tvalueToJson(value.GetArrayElement(i));
    end;
    Result := _result + ']';
  end
  else if (value.Kind = tkClass) and (not value.IsEmpty) and
    (value.AsObject is TDictionary<string, TValue>) then
  begin
    _dict := TDictionary<string, TValue>(value.AsObject);
    _result := '{';
    _first := True;
    for _pair in _dict do
    begin
      if not _first then
      begin
        _result := _result + ', ';
      end;
      _result := _result + '"' + _pair.Key + '": ' + tvalueToJson(_pair.Value);
      _first := False;
    end;
    Result := _result + '}';
  end
  else if value.Kind in [tkInteger, tkInt64] then
  begin
    Result := getStringFromTValue(value);
  end
  else if value.Kind = tkFloat then
  begin
    _strVal := getStringFromTValue(value);
    if TryStrToFloat(_strVal, _f) then
    begin
      Result := FloatToStr(_f);
    end
    else
    begin
      Result := _strVal;
    end;
  end
  else if value.Kind = tkEnumeration then
  begin
    _strVal := getStringFromTValue(value);
    if SameText(_strVal, 'True') or SameText(_strVal, 'False') then
    begin
      Result := LowerCase(_strVal);
    end
    else
    begin
      Result := '"' + _strVal + '"';
    end;
  end
  else
  begin
    _strVal := getStringFromTValue(value);
    _strVal := StringReplace(_strVal, '\', '\\', [rfReplaceAll]);
    _strVal := StringReplace(_strVal, '"', '\"', [rfReplaceAll]);
    _strVal := StringReplace(_strVal, #10, '\n', [rfReplaceAll]);
    _strVal := StringReplace(_strVal, #13, '\r', [rfReplaceAll]);
    _strVal := StringReplace(_strVal, #9, '\t', [rfReplaceAll]);
    Result := '"' + _strVal + '"';
  end;
end;

function tvalueToPrettyJson(const value: TValue; indent: Integer): string;
var
  _dict: TDictionary<string, TValue>;
  _pair: TPair<string, TValue>;
  _arrLen: Integer;
  _prefix: string;
  _innerPrefix: string;
  _first: Boolean;
  i: Integer;
begin
  _prefix := StringOfChar(' ', indent);
  _innerPrefix := StringOfChar(' ', indent + 2);
  if value.IsEmpty then
  begin
    Result := 'null';
  end
  else if value.Kind = tkDynArray then
  begin
    _arrLen := value.GetArrayLength;
    if _arrLen = 0 then
    begin
      Result := '[]';
    end
    else
    begin
      Result := '[' + sLineBreak;
      for i := 0 to _arrLen - 1 do
      begin
        if i > 0 then
        begin
          Result := Result + ',' + sLineBreak;
        end;
        Result := Result + _innerPrefix + tvalueToPrettyJson(value.GetArrayElement(i), indent + 2);
      end;
      Result := Result + sLineBreak + _prefix + ']';
    end;
  end
  else if (value.Kind = tkClass) and (not value.IsEmpty) and
    (value.AsObject is TDictionary<string, TValue>) then
  begin
    _dict := TDictionary<string, TValue>(value.AsObject);
    if _dict.Count = 0 then
    begin
      Result := '{}';
    end
    else
    begin
      Result := '{' + sLineBreak;
      _first := True;
      for _pair in _dict do
      begin
        if not _first then
        begin
          Result := Result + ',' + sLineBreak;
        end;
        Result := Result + _innerPrefix + '"' + _pair.Key + '": ' +
          tvalueToPrettyJson(_pair.Value, indent + 2);
        _first := False;
      end;
      Result := Result + sLineBreak + _prefix + '}';
    end;
  end
  else
  begin
    Result := tvalueToJson(value);
  end;
end;

function _passesTest(const strVal: string; const args: TArray<string>): Boolean;
var
  _testName: string;
  _numVal: Double;
begin
  Result := False;
  if Length(args) = 0 then
  begin
    Result := (strVal <> '') and (strVal <> '0') and
      not SameText(strVal, 'false') and not SameText(strVal, 'none');
    Exit;
  end;
  _testName := LowerCase(args[0]);
  if _testName = 'odd' then
  begin
    if TryStrToFloat(strVal, _numVal) then
    begin
      Result := Odd(Round(_numVal));
    end;
  end
  else if _testName = 'even' then
  begin
    if TryStrToFloat(strVal, _numVal) then
    begin
      Result := not Odd(Round(_numVal));
    end;
  end
  else if _testName = 'number' then
  begin
    Result := TryStrToFloat(strVal, _numVal);
  end
  else if _testName = 'string' then
  begin
    Result := True;
  end
  else if _testName = 'none' then
  begin
    Result := (strVal = '');
  end
  else
  begin
    Result := (strVal <> '') and (strVal <> '0') and
      not SameText(strVal, 'false') and not SameText(strVal, 'none');
  end;
end;

// getFieldValue is in KLib.Utils (shared with KLib.Template.Evaluator)

var
  _registry: TDictionary<string, TFilterFn>;
  _registryV: TDictionary<string, TFilterFnV>;
  _lock: TMultiReadExclusiveWriteSynchronizer;

procedure registerFilter(const name: string; fn: TFilterFn);
begin
  _lock.BeginWrite;
  try
    _registry.AddOrSetValue(LowerCase(name), fn);
  finally
    _lock.EndWrite;
  end;
end;

procedure registerFilterV(const name: string; fn: TFilterFnV);
begin
  _lock.BeginWrite;
  try
    _registryV.AddOrSetValue(LowerCase(name), fn);
  finally
    _lock.EndWrite;
  end;
end;

// Extracts args from filter expression like 'replace("foo","bar")' or 'truncate(50)'
function getFilterArgs(const filterExpr: string; parenPos: Integer): TArray<string>;
var
  _inner: string;
  _closePos: Integer;
  _parts: TArray<string>;
  _cleanedArgs: TArray<string>;
  i: Integer;
  _arg: string;
  _hasArgs: Boolean;
begin
  _hasArgs := False;
  _closePos := LastDelimiter(')', filterExpr);
  if _closePos > parenPos then
  begin
    _inner := Trim(Copy(filterExpr, parenPos + 1, _closePos - parenPos - 1));
    if _inner <> '' then
    begin
      _parts := splitArgs(_inner);
      SetLength(_cleanedArgs, Length(_parts));
      for i := 0 to High(_parts) do
      begin
        _arg := Trim(_parts[i]);
        if (Length(_arg) >= 2) and CharInSet(_arg[1], ['''', '"']) then
        begin
          _arg := Copy(_arg, 2, Length(_arg) - 2);
        end;
        _cleanedArgs[i] := _arg;
      end;
      _hasArgs := True;
    end;
  end;
  if _hasArgs then
    Result := _cleanedArgs
  else
    Result := [];
end;

// Splits expr on '|' respecting quoted strings and parentheses
function splitPipeExpr(const expr: string): TArray<string>;
var
  _parts: TArray<string>;
  _count: Integer;
  _start: Integer;
  i: Integer;
  _inStr: Boolean;
  _strChar: Char;
  _parenDepth: Integer;
begin
  SetLength(_parts, 8);
  _count := 0;
  _start := 1;
  _inStr := False;
  _strChar := #0;
  _parenDepth := 0;
  for i := 1 to Length(expr) do
  begin
    if _inStr then
    begin
      if expr[i] = _strChar then
      begin
        _inStr := False;
      end;
    end
    else if CharInSet(expr[i], ['''', '"']) then
    begin
      _inStr := True;
      _strChar := expr[i];
    end
    else if expr[i] = '(' then
    begin
      Inc(_parenDepth);
    end
    else if expr[i] = ')' then
    begin
      Dec(_parenDepth);
    end
    else if (expr[i] = '|') and (_parenDepth = 0) then
    begin
      if _count >= Length(_parts) then
      begin
        SetLength(_parts, _count + 8);
      end;
      _parts[_count] := Copy(expr, _start, i - _start);
      Inc(_count);
      _start := i + 1;
    end;
  end;
  if _count >= Length(_parts) then
  begin
    SetLength(_parts, _count + 1);
  end;
  _parts[_count] := Copy(expr, _start, Length(expr) - _start + 1);
  Inc(_count);
  SetLength(_parts, _count);
  Result := _parts;
end;

// Splits s on ',' respecting quoted strings and nested parentheses
function splitArgs(const s: string): TArray<string>;
var
  _parts: TArray<string>;
  _count: Integer;
  _start: Integer;
  i: Integer;
  _inStr: Boolean;
  _strChar: Char;
  _parenDepth: Integer;
begin
  SetLength(_parts, 8);
  _count := 0;
  _start := 1;
  _inStr := False;
  _strChar := #0;
  _parenDepth := 0;
  for i := 1 to Length(s) do
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
    else if (s[i] = ',') and (_parenDepth = 0) then
    begin
      if _count >= Length(_parts) then
      begin
        SetLength(_parts, _count + 8);
      end;
      _parts[_count] := Copy(s, _start, i - _start);
      Inc(_count);
      _start := i + 1;
    end;
  end;
  if _count >= Length(_parts) then
  begin
    SetLength(_parts, _count + 1);
  end;
  _parts[_count] := Copy(s, _start, Length(s) - _start + 1);
  Inc(_count);
  SetLength(_parts, _count);
  Result := _parts;
end;

function applyFilterByNameV(const filterExpr: string; const value: TValue): TValue;
var
  _parenPos: Integer;
  _filterName: string;
  _args: TArray<string>;
  _fnV: TFilterFnV;
  _fn: TFilterFn;
  _strVal: string;
  _n: Integer;
  _sep: string;
  _fmt: string;
  _start: Integer;
  _end: Integer;
  _f: Double;
  _fVal: Double;
  _fArg: Double;
  _splitParts: TArray<string>;
  i: Integer;
  _arrLen: Integer;
  _groupSize: Integer;
  _groups: TArray<TValue>;
  _group: TArray<TValue>;
  _groupIdx: Integer;
  _itemIdx: Integer;
  _sum: Double;
  _seen: TDictionary<string, Boolean>;
  _unique: TArray<TValue>;
  _uniqueCount: Integer;
  _sorted: TArray<string>;
  _temp: string;
  j: Integer;
  _safeStr: TSafeString;
begin
  Result := value;
  _parenPos := Pos('(', filterExpr);

  if _parenPos > 0 then
    _filterName := LowerCase(Trim(Copy(filterExpr, 1, _parenPos - 1)))
  else
    _filterName := LowerCase(Trim(filterExpr));

  _args := [];
  if _parenPos > 0 then
    _args := getFilterArgs(filterExpr, _parenPos);

  // safe filter — returns TSafeString to signal the Evaluator to skip autoescape
  if SameText(_filterName, 'safe') then
  begin
    _safeStr.value := getStringFromTValue(value);
    Result := TValue.From<TSafeString>(_safeStr);
    Exit;
  end;

  // --- Array-specific filters ---

  if SameText(_filterName, 'join') then
  begin
    if value.Kind = tkDynArray then
    begin
      _sep := '';
      if Length(_args) > 0 then
        _sep := _args[0];
      _arrLen := value.GetArrayLength;
      _strVal := '';
      for i := 0 to _arrLen - 1 do
      begin
        if i > 0 then
          _strVal := _strVal + _sep;
        _strVal := _strVal + getStringFromTValue(value.GetArrayElement(i));
      end;
      Result := TValue.From<string>(_strVal);
    end;
    Exit;
  end;

  if SameText(_filterName, 'sort') then
  begin
    if value.Kind = tkDynArray then
    begin
      _arrLen := value.GetArrayLength;
      SetLength(_sorted, _arrLen);
      for i := 0 to _arrLen - 1 do
      begin
        _sorted[i] := getStringFromTValue(value.GetArrayElement(i));
      end;
      // Bubble sort (simple, sufficient for template use)
      for i := 0 to _arrLen - 2 do
      begin
        for j := 0 to _arrLen - 2 - i do
        begin
          if _sorted[j] > _sorted[j + 1] then
          begin
            _temp := _sorted[j];
            _sorted[j] := _sorted[j + 1];
            _sorted[j + 1] := _temp;
          end;
        end;
      end;
      // Rebuild as TValue array of strings
      Result := TValue.From < TArray < string >> (_sorted);
    end;
    Exit;
  end;

  if SameText(_filterName, 'unique') then
  begin
    if value.Kind = tkDynArray then
    begin
      _arrLen := value.GetArrayLength;
      _seen := TDictionary<string, Boolean>.Create;
      SetLength(_unique, _arrLen);
      _uniqueCount := 0;
      try
        for i := 0 to _arrLen - 1 do
        begin
          _strVal := getStringFromTValue(value.GetArrayElement(i));
          if not _seen.ContainsKey(_strVal) then
          begin
            _seen.Add(_strVal, True);
            _unique[_uniqueCount] := value.GetArrayElement(i);
            Inc(_uniqueCount);
          end;
        end;
      finally
        FreeAndNil(_seen);
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  if SameText(_filterName, 'sum') then
  begin
    _sum := 0;
    if value.Kind = tkDynArray then
    begin
      _arrLen := value.GetArrayLength;
      for i := 0 to _arrLen - 1 do
      begin
        _strVal := getStringFromTValue(value.GetArrayElement(i));
        if TryStrToFloat(_strVal, _f) then
          _sum := _sum + _f;
      end;
    end;
    Result := TValue.From<string>(FloatToStr(_sum));
    Exit;
  end;

  if SameText(_filterName, 'batch') then
  begin
    if value.Kind = tkDynArray then
    begin
      _groupSize := 2;
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) and (_n > 0) then
        _groupSize := _n;
      _arrLen := value.GetArrayLength;
      SetLength(_groups, (_arrLen + _groupSize - 1) div _groupSize);
      _groupIdx := 0;
      _itemIdx := 0;
      while _itemIdx < _arrLen do
      begin
        SetLength(_group, Min(_groupSize, _arrLen - _itemIdx));
        for i := 0 to High(_group) do
        begin
          _group[i] := value.GetArrayElement(_itemIdx + i);
        end;
        _groups[_groupIdx] := TValue.From < TArray < TValue >> (_group);
        Inc(_groupIdx);
        Inc(_itemIdx, _groupSize);
      end;
      Result := TValue.From < TArray < TValue >> (_groups);
    end;
    Exit;
  end;

  if SameText(_filterName, 'split') then
  begin
    _sep := ' ';
    if Length(_args) > 0 then
      _sep := _args[0];
    _strVal := getStringFromTValue(value);
    _splitParts := SplitString(_strVal, _sep);
    Result := TValue.From < TArray < string >> (_splitParts);
    Exit;
  end;

  // selectattr('attr') or selectattr('attr', '==', 'value')
  if SameText(_filterName, 'selectattr') then
  begin
    if (value.Kind = tkDynArray) and (Length(_args) > 0) then
    begin
      _arrLen := value.GetArrayLength;
      SetLength(_unique, _arrLen);
      _uniqueCount := 0;
      for i := 0 to _arrLen - 1 do
      begin
        _strVal := getStringFromTValue(resolveFieldPath(value.GetArrayElement(i), _args[0]));
        if Length(_args) >= 3 then
        begin
          // selectattr('attr', 'op', 'value')
          if (((_args[1] = '==') and (_strVal = _args[2])) or
            ((_args[1] = '!=') and (_strVal <> _args[2]))) then
          begin
            _unique[_uniqueCount] := value.GetArrayElement(i);
            Inc(_uniqueCount);
          end;
        end
        else
        begin
          // selectattr('attr') — truthy check
          if checkIfTValueIsTruthy(resolveFieldPath(value.GetArrayElement(i), _args[0])) then
          begin
            _unique[_uniqueCount] := value.GetArrayElement(i);
            Inc(_uniqueCount);
          end;
        end;
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // rejectattr('attr') or rejectattr('attr', '==', 'value')
  if SameText(_filterName, 'rejectattr') then
  begin
    if (value.Kind = tkDynArray) and (Length(_args) > 0) then
    begin
      _arrLen := value.GetArrayLength;
      SetLength(_unique, _arrLen);
      _uniqueCount := 0;
      for i := 0 to _arrLen - 1 do
      begin
        _strVal := getStringFromTValue(resolveFieldPath(value.GetArrayElement(i), _args[0]));
        if Length(_args) >= 3 then
        begin
          if not(((_args[1] = '==') and (_strVal = _args[2])) or
            ((_args[1] = '!=') and (_strVal <> _args[2]))) then
          begin
            _unique[_uniqueCount] := value.GetArrayElement(i);
            Inc(_uniqueCount);
          end;
        end
        else
        begin
          if not checkIfTValueIsTruthy(resolveFieldPath(value.GetArrayElement(i), _args[0])) then
          begin
            _unique[_uniqueCount] := value.GetArrayElement(i);
            Inc(_uniqueCount);
          end;
        end;
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // map(attribute='name') — extract a field from each element
  if SameText(_filterName, 'map') then
  begin
    if (value.Kind = tkDynArray) and (Length(_args) > 0) then
    begin
      _arrLen := value.GetArrayLength;
      // Parse named arg: attribute='name' or just 'name'
      _strVal := _args[0];
      _n := Pos('=', _strVal);
      if _n > 0 then
        _strVal := Trim(Copy(_strVal, _n + 1, MaxInt));
      SetLength(_unique, _arrLen);
      for i := 0 to _arrLen - 1 do
      begin
        _unique[i] := resolveFieldPath(value.GetArrayElement(i), _strVal);
      end;
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // list — identity filter (returns array as-is, useful after selectattr/rejectattr)
  if SameText(_filterName, 'list') then
  begin
    Exit;
  end;

  // tojson — serialize TValue to JSON string
  if SameText(_filterName, 'tojson') then
  begin
    Result := TValue.From<string>(tvalueToJson(value));
    Exit;
  end;

  // pprint — pretty-print a TValue with indentation
  if SameText(_filterName, 'pprint') then
  begin
    Result := TValue.From<string>(tvalueToPrettyJson(value, 0));
    Exit;
  end;

  // keys — extract keys from dict
  if SameText(_filterName, 'keys') then
  begin
    if (not value.IsEmpty) and (value.Kind = tkClass) and
      (value.AsObject is TDictionary<string, TValue>) then
    begin
      SetLength(_unique, TDictionary<string, TValue>(value.AsObject).Count);
      _uniqueCount := 0;
      for _strVal in TDictionary<string, TValue>(value.AsObject).Keys do
      begin
        _unique[_uniqueCount] := TValue.From<string>(_strVal);
        Inc(_uniqueCount);
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // values — extract values from dict
  if SameText(_filterName, 'values') then
  begin
    if (not value.IsEmpty) and (value.Kind = tkClass) and
      (value.AsObject is TDictionary<string, TValue>) then
    begin
      SetLength(_unique, TDictionary<string, TValue>(value.AsObject).Count);
      _uniqueCount := 0;
      for _strVal in TDictionary<string, TValue>(value.AsObject).Keys do
      begin
        _unique[_uniqueCount] := TDictionary<string, TValue>(value.AsObject).Items[_strVal];
        Inc(_uniqueCount);
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // items — extract [key, value] pairs from dict
  if SameText(_filterName, 'items') then
  begin
    if (not value.IsEmpty) and (value.Kind = tkClass) and
      (value.AsObject is TDictionary<string, TValue>) then
    begin
      SetLength(_unique, TDictionary<string, TValue>(value.AsObject).Count);
      _uniqueCount := 0;
      for _strVal in TDictionary<string, TValue>(value.AsObject).Keys do
      begin
        _unique[_uniqueCount] := TValue.From < TArray < TValue >> (
          TArray<TValue>.Create(
          TValue.From<string>(_strVal),
          TDictionary<string, TValue>(value.AsObject).Items[_strVal]));
        Inc(_uniqueCount);
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // dictsort — sort dict by key, return array of [key, value] pairs
  if SameText(_filterName, 'dictsort') then
  begin
    if (not value.IsEmpty) and (value.Kind = tkClass) and
      (value.AsObject is TDictionary<string, TValue>) then
    begin
      _arrLen := TDictionary<string, TValue>(value.AsObject).Count;
      SetLength(_sorted, _arrLen);
      _uniqueCount := 0;
      for _strVal in TDictionary<string, TValue>(value.AsObject).Keys do
      begin
        _sorted[_uniqueCount] := _strVal;
        Inc(_uniqueCount);
      end;
      // Bubble sort keys
      for i := 0 to _arrLen - 2 do
      begin
        for j := 0 to _arrLen - 2 - i do
        begin
          if _sorted[j] > _sorted[j + 1] then
          begin
            _temp := _sorted[j];
            _sorted[j] := _sorted[j + 1];
            _sorted[j + 1] := _temp;
          end;
        end;
      end;
      SetLength(_unique, _arrLen);
      for i := 0 to _arrLen - 1 do
      begin
        _unique[i] := TValue.From < TArray < TValue >> (
          TArray<TValue>.Create(
          TValue.From<string>(_sorted[i]),
          TDictionary<string, TValue>(value.AsObject).Items[_sorted[i]]));
      end;
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // select(test) — keep array elements passing a test
  if SameText(_filterName, 'select') then
  begin
    if value.Kind = tkDynArray then
    begin
      _arrLen := value.GetArrayLength;
      SetLength(_unique, _arrLen);
      _uniqueCount := 0;
      for i := 0 to _arrLen - 1 do
      begin
        _strVal := getStringFromTValue(value.GetArrayElement(i));
        if _passesTest(_strVal, _args) then
        begin
          _unique[_uniqueCount] := value.GetArrayElement(i);
          Inc(_uniqueCount);
        end;
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // reject(test) — remove array elements passing a test
  if SameText(_filterName, 'reject') then
  begin
    if value.Kind = tkDynArray then
    begin
      _arrLen := value.GetArrayLength;
      SetLength(_unique, _arrLen);
      _uniqueCount := 0;
      for i := 0 to _arrLen - 1 do
      begin
        _strVal := getStringFromTValue(value.GetArrayElement(i));
        if not _passesTest(_strVal, _args) then
        begin
          _unique[_uniqueCount] := value.GetArrayElement(i);
          Inc(_uniqueCount);
        end;
      end;
      SetLength(_unique, _uniqueCount);
      Result := TValue.From < TArray < TValue >> (_unique);
    end;
    Exit;
  end;

  // groupby(attr) — group array elements by attribute
  if SameText(_filterName, 'groupby') then
  begin
    if (value.Kind = tkDynArray) and (Length(_args) > 0) then
    begin
      _arrLen := value.GetArrayLength;
      _seen := TDictionary<string, Boolean>.Create;
      try
        // First pass: collect unique grouper values in order
        SetLength(_sorted, _arrLen);
        _uniqueCount := 0;
        for i := 0 to _arrLen - 1 do
        begin
          _strVal := getStringFromTValue(resolveFieldPath(value.GetArrayElement(i), _args[0]));
          if not _seen.ContainsKey(_strVal) then
          begin
            _seen.Add(_strVal, True);
            _sorted[_uniqueCount] := _strVal;
            Inc(_uniqueCount);
          end;
        end;
        // Second pass: build groups
        SetLength(_groups, _uniqueCount);
        for i := 0 to _uniqueCount - 1 do
        begin
          SetLength(_group, 0);
          for j := 0 to _arrLen - 1 do
          begin
            _temp := getStringFromTValue(resolveFieldPath(value.GetArrayElement(j), _args[0]));
            if _temp = _sorted[i] then
            begin
              SetLength(_group, Length(_group) + 1);
              _group[High(_group)] := value.GetArrayElement(j);
            end;
          end;
          _groups[i] := TValue.From < TArray < TValue >> (
            TArray<TValue>.Create(
            TValue.From<string>(_sorted[i]),
            TValue.From < TArray < TValue >> (_group)));
        end;
        Result := TValue.From < TArray < TValue >> (_groups);
      finally
        FreeAndNil(_seen);
      end;
    end;
    Exit;
  end;

  if SameText(_filterName, 'length') then
  begin
    if value.Kind = tkDynArray then
      Result := TValue.From<string>(IntToStr(value.GetArrayLength))
    else
      Result := TValue.From<string>(IntToStr(Length(getStringFromTValue(value))));
    Exit;
  end;

  // --- Try scalar V registry ---
  _lock.BeginRead;
  try
    if _registryV.TryGetValue(_filterName, _fnV) then
    begin
      Result := _fnV(value);
      Exit;
    end;
    // Try string registry, convert to/from string
    if _registry.TryGetValue(_filterName, _fn) then
    begin
      Result := TValue.From<string>(_fn(getStringFromTValue(value)));
      Exit;
    end;
  finally
    _lock.EndRead;
  end;

  // Parametric scalar filters with args
  if _parenPos > 0 then
  begin
    _strVal := getStringFromTValue(value);

    if SameText(_filterName, 'default') then
    begin
      if (_strVal = '') and (Length(_args) > 0) then
        Result := TValue.From<string>(_args[0]);
      Exit;
    end;

    if SameText(_filterName, 'truncate') then
    begin
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) and (Length(_strVal) > _n) then
        Result := TValue.From<string>(Copy(_strVal, 1, _n) + '...');
      Exit;
    end;

    if SameText(_filterName, 'replace') then
    begin
      if Length(_args) >= 2 then
        Result := TValue.From<string>(StringReplace(_strVal, _args[0], _args[1], [rfReplaceAll]));
      Exit;
    end;

    if SameText(_filterName, 'format') then
    begin
      if (Length(_args) > 0) and TryStrToFloat(_strVal, _f) then
        Result := TValue.From<string>(Format(_args[0], [_f]));
      Exit;
    end;

    if SameText(_filterName, 'center') then
    begin
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) then
      begin
        if Length(_strVal) < _n then
        begin
          _start := (_n - Length(_strVal)) div 2;
          Result := TValue.From<string>(StringOfChar(' ', _start) + _strVal +
            StringOfChar(' ', _n - _start - Length(_strVal)));
        end;
      end;
      Exit;
    end;

    if SameText(_filterName, 'slice') then
    begin
      if Length(_args) >= 2 then
      begin
        if TryStrToInt(_args[0], _start) and TryStrToInt(_args[1], _end) then
        begin
          if _start < 1 then
            _start := 1;
          if _end > Length(_strVal) then
            _end := Length(_strVal);
          Result := TValue.From<string>(Copy(_strVal, _start, _end - _start + 1));
        end;
      end;
      Exit;
    end;

    if SameText(_filterName, 'date') then
    begin
      if Length(_args) > 0 then
      begin
        _fmt := _args[0];
        if TryStrToFloat(_strVal, _f) then
          Result := TValue.From<string>(FormatDateTime(_fmt, _f));
      end;
      Exit;
    end;

    if SameText(_filterName, 'min') then
    begin
      if (Length(_args) > 0) and TryStrToFloat(_strVal, _fVal) and TryStrToFloat(_args[0], _fArg) then
      begin
        Result := TValue.From<string>(FloatToStr(Min(_fVal, _fArg)));
      end;
      Exit;
    end;

    if SameText(_filterName, 'max') then
    begin
      if (Length(_args) > 0) and TryStrToFloat(_strVal, _fVal) and TryStrToFloat(_args[0], _fArg) then
      begin
        Result := TValue.From<string>(FloatToStr(Max(_fVal, _fArg)));
      end;
      Exit;
    end;

    // dateformat — alias for date
    if SameText(_filterName, 'dateformat') then
    begin
      if Length(_args) > 0 then
      begin
        _fmt := _args[0];
        if TryStrToFloat(_strVal, _f) then
          Result := TValue.From<string>(FormatDateTime(_fmt, _f));
      end;
      Exit;
    end;

    // numberformat(format)
    if SameText(_filterName, 'numberformat') then
    begin
      if (Length(_args) > 0) and TryStrToFloat(_strVal, _f) then
      begin
        Result := TValue.From<string>(FormatFloat(_args[0], _f));
      end;
      Exit;
    end;

    // regex_replace(pattern, replacement)
    if SameText(_filterName, 'regex_replace') then
    begin
      if Length(_args) >= 2 then
      begin
        Result := TValue.From<string>(TRegEx.Replace(_strVal, _args[0], _args[1]));
      end;
      Exit;
    end;

    // indent(spaces, firstLine)
    if SameText(_filterName, 'indent') then
    begin
      _n := 4;
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) then
          ; // _n set from arg
      _splitParts := SplitString(_strVal, #10);
      _sep := StringOfChar(' ', _n);
      _strVal := '';
      for i := 0 to High(_splitParts) do
      begin
        if i > 0 then
        begin
          _strVal := _strVal + #10;
        end;
        if (i = 0) and ((Length(_args) < 2) or (LowerCase(_args[1]) <> 'true')) then
        begin
          _strVal := _strVal + _splitParts[i];
        end
        else
        begin
          _strVal := _strVal + _sep + _splitParts[i];
        end;
      end;
      Result := TValue.From<string>(_strVal);
      Exit;
    end;

    // wordwrap(width)
    if SameText(_filterName, 'wordwrap') then
    begin
      _n := 79;
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) then
          ;
      _splitParts := SplitString(_strVal, ' ');
      _strVal := '';
      _start := 0;
      for i := 0 to High(_splitParts) do
      begin
        if (_start > 0) and (_start + 1 + Length(_splitParts[i]) > _n) then
        begin
          _strVal := _strVal + #10 + _splitParts[i];
          _start := Length(_splitParts[i]);
        end
        else
        begin
          if _start > 0 then
          begin
            _strVal := _strVal + ' ';
            Inc(_start);
          end;
          _strVal := _strVal + _splitParts[i];
          _start := _start + Length(_splitParts[i]);
        end;
      end;
      Result := TValue.From<string>(_strVal);
      Exit;
    end;

    // lpad(width, char)
    if SameText(_filterName, 'lpad') then
    begin
      _n := 0;
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) then
      begin
        _sep := ' ';
        if (Length(_args) > 1) and (Length(_args[1]) > 0) then
        begin
          _sep := _args[1];
        end;
        if Length(_strVal) < _n then
        begin
          Result := TValue.From<string>(StringOfChar(_sep[1], _n - Length(_strVal)) + _strVal);
        end;
      end;
      Exit;
    end;

    // rpad(width, char)
    if SameText(_filterName, 'rpad') then
    begin
      _n := 0;
      if (Length(_args) > 0) and TryStrToInt(_args[0], _n) then
      begin
        _sep := ' ';
        if (Length(_args) > 1) and (Length(_args[1]) > 0) then
        begin
          _sep := _args[1];
        end;
        if Length(_strVal) < _n then
        begin
          Result := TValue.From<string>(_strVal + StringOfChar(_sep[1], _n - Length(_strVal)));
        end;
      end;
      Exit;
    end;
  end;
end;

function applyFilters(const expr: string; const rawValue: string): string;
var
  _parts: TArray<string>;
  _currentValue: TValue;
  i: Integer;
begin
  _parts := splitPipeExpr(expr);
  _currentValue := TValue.From<string>(rawValue);
  for i := 1 to High(_parts) do
  begin
    _currentValue := applyFilterByNameV(Trim(_parts[i]), _currentValue);
  end;
  Result := getStringFromTValue(_currentValue);
end;

function applyFiltersV(const expr: string; const rawValue: TValue): TValue;
var
  _parts: TArray<string>;
  _currentValue: TValue;
  i: Integer;
begin
  _parts := splitPipeExpr(expr);
  _currentValue := rawValue;
  for i := 1 to High(_parts) do
  begin
    _currentValue := applyFilterByNameV(Trim(_parts[i]), _currentValue);
  end;
  Result := _currentValue;
end;

// ---- Built-in filter implementations ----

// Note: getEscapedHTMLString in KLib.StringUtils does URL encoding (misnamed).
// getEscapedXMLString is the correct HTML entity escaper (&amp; &quot; &lt; &gt; &#39;).
// The html_escape filter delegates to getEscapedXMLString.

function nl2br(const value: string): string;
begin
  Result := StringReplace(value, #10, '<br>', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
end;

function stripTags(const value: string): string;
begin
  Result := TRegEx.Replace(value, '<[^>]+>', '');
end;

function titleCase(const value: string): string;
var
  _result: string;
  i: Integer;
  _prevSpace: Boolean;
begin
  _result := LowerCase(value);
  _prevSpace := True;
  for i := 1 to Length(_result) do
  begin
    if _prevSpace and CharInSet(_result[i], ['a' .. 'z']) then
    begin
      _result[i] := UpCase(_result[i]);
    end;
    _prevSpace := _result[i] = ' ';
  end;
  Result := _result;
end;

function wordCount(const value: string): Integer;
var
  _parts: TArray<string>;
  i: Integer;
  _count: Integer;
begin
  _parts := SplitString(Trim(value), ' ');
  _count := 0;
  for i := 0 to High(_parts) do
  begin
    if Trim(_parts[i]) <> '' then
    begin
      Inc(_count);
    end;
  end;
  Result := _count;
end;

procedure registerBuiltins;
begin
  // xmlattr — converts dict to XML/HTML attributes string
  registerFilterV('xmlattr',
    function(const value: TValue): TValue
    var
      _dict: TDictionary<string, TValue>;
      _pair: TPair<string, TValue>;
      _result: string;
    begin
      _result := '';
      if (not value.IsEmpty) and (value.Kind = tkClass) and
        (value.AsObject is TDictionary<string, TValue>) then
      begin
        _dict := TDictionary<string, TValue>(value.AsObject);
        for _pair in _dict do
        begin
          if _result <> '' then
          begin
            _result := _result + ' ';
          end;
          _result := _result + _pair.Key + '="' +
            getEscapedXMLString(getStringFromTValue(_pair.Value)) + '"';
        end;
      end;
      Result := TValue.From<string>(_result);
    end);

  registerFilter('upper',
    function(const value: string): string
    begin
      Result := UpperCase(value);
    end);

  registerFilter('lower',
    function(const value: string): string
    begin
      Result := LowerCase(value);
    end);

  registerFilter('trim',
    function(const value: string): string
    begin
      Result := Trim(value);
    end);

  registerFilter('html_escape',
    function(const value: string): string
    begin
      Result := getEscapedXMLString(value);
    end);

  registerFilter('nl2br',
    function(const value: string): string
    begin
      Result := nl2br(value);
    end);

  registerFilter('capitalize',
    function(const value: string): string
    var
      _s: string;
    begin
      _s := LowerCase(value);
      if Length(_s) > 0 then
      begin
        _s[1] := UpCase(_s[1]);
      end;
      Result := _s;
    end);

  registerFilter('title',
    function(const value: string): string
    begin
      Result := titleCase(value);
    end);

  registerFilter('strip_tags',
    function(const value: string): string
    begin
      Result := stripTags(value);
    end);

  registerFilter('abs',
    function(const value: string): string
    var
      _f: Double;
    begin
      if TryStrToFloat(value, _f) then
      begin
        Result := FloatToStr(Abs(_f));
      end
      else
      begin
        Result := value;
      end;
    end);

  registerFilter('round',
    function(const value: string): string
    var
      _f: Double;
    begin
      if TryStrToFloat(value, _f) then
      begin
        Result := IntToStr(Round(_f));
      end
      else
      begin
        Result := value;
      end;
    end);

  registerFilter('first',
    function(const value: string): string
    begin
      if Length(value) > 0 then
      begin
        Result := value[1];
      end
      else
      begin
        Result := '';
      end;
    end);

  registerFilter('last',
    function(const value: string): string
    begin
      if Length(value) > 0 then
      begin
        Result := value[Length(value)];
      end
      else
      begin
        Result := '';
      end;
    end);

  // T9 — New filters

  registerFilter('int',
    function(const value: string): string
    var
      _f: Double;
      _i: Integer;
    begin
      if TryStrToInt(value, _i) then
      begin
        Result := IntToStr(_i);
      end
      else if TryStrToFloat(value, _f) then
      begin
        Result := IntToStr(Trunc(_f));
      end
      else
      begin
        Result := '0';
      end;
    end);

  registerFilter('float',
    function(const value: string): string
    var
      _f: Double;
    begin
      if TryStrToFloat(value, _f) then
      begin
        Result := FloatToStr(_f);
      end
      else
      begin
        Result := '0';
      end;
    end);

  registerFilter('bool',
    function(const value: string): string
    var
      _lower: string;
    begin
      _lower := LowerCase(Trim(value));
      if (_lower = 'false') or (_lower = '0') or (_lower = 'no') or (_lower = '') then
      begin
        Result := 'false';
      end
      else
      begin
        Result := 'true';
      end;
    end);

  registerFilter('ceil',
    function(const value: string): string
    var
      _f: Double;
    begin
      if TryStrToFloat(value, _f) then
      begin
        Result := IntToStr(Ceil(_f));
      end
      else
      begin
        Result := value;
      end;
    end);

  registerFilter('floor',
    function(const value: string): string
    var
      _f: Double;
    begin
      if TryStrToFloat(value, _f) then
      begin
        Result := IntToStr(Floor(_f));
      end
      else
      begin
        Result := value;
      end;
    end);

  registerFilter('reverse',
    function(const value: string): string
    var
      _result: string;
      i: Integer;
    begin
      _result := '';
      for i := Length(value) downto 1 do
      begin
        _result := _result + value[i];
      end;
      Result := _result;
    end);

  registerFilter('wordcount',
    function(const value: string): string
    begin
      Result := IntToStr(wordCount(value));
    end);

  registerFilter('urlencode',
    function(const value: string): string
    begin
      Result := TNetEncoding.URL.Encode(value);
    end);

  registerFilter('e',
    function(const value: string): string
    begin
      Result := getEscapedXMLString(value);
    end);

  registerFilter('escape',
    function(const value: string): string
    begin
      Result := getEscapedXMLString(value);
    end);

  // urlize — convert URLs in text to anchor tags
  registerFilter('urlize',
    function(const value: string): string
    begin
      Result := TRegEx.Replace(value,
        '(https?://[^\s<>]+)',
        '<a href="$1">$1</a>');
    end);

  // filesizeformat — human-readable file sizes
  registerFilter('filesizeformat',
    function(const value: string): string
    var
      _bytes: Double;
    begin
      if TryStrToFloat(value, _bytes) then
      begin
        if _bytes < 1024 then
          Result := Format('%.0f Bytes', [_bytes])
        else if _bytes < 1024 * 1024 then
          Result := Format('%.1f kB', [_bytes / 1024])
        else if _bytes < 1024 * 1024 * 1024 then
          Result := Format('%.1f MB', [_bytes / (1024 * 1024)])
        else
          Result := Format('%.1f GB', [_bytes / (1024 * 1024 * 1024)]);
      end
      else
      begin
        Result := value;
      end;
    end);

  // base64encode
  registerFilter('base64encode',
    function(const value: string): string
    begin
      Result := TNetEncoding.Base64.Encode(value);
    end);

  // base64decode
  registerFilter('base64decode',
    function(const value: string): string
    begin
      Result := TNetEncoding.Base64.Decode(value);
    end);

  // md5
  registerFilter('md5',
    function(const value: string): string
    begin
      Result := LowerCase(THashMD5.GetHashString(value));
    end);

  // sha1
  registerFilter('sha1',
    function(const value: string): string
    begin
      Result := LowerCase(THashSHA1.GetHashString(value));
    end);

  // sha256
  registerFilter('sha256',
    function(const value: string): string
    begin
      Result := LowerCase(THashSHA2.GetHashString(value));
    end);

  // striptags — alias for strip_tags
  registerFilter('striptags',
    function(const value: string): string
    begin
      Result := stripTags(value);
    end);
end;

initialization

_lock := TMultiReadExclusiveWriteSynchronizer.Create;
_registry := TDictionary<string, TFilterFn>.Create;
_registryV := TDictionary<string, TFilterFnV>.Create;
registerBuiltins;

finalization

FreeAndNil(_registry);
FreeAndNil(_registryV);
FreeAndNil(_lock);

end.
