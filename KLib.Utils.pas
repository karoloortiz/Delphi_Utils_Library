{
  KLib Version = 4.0
  The Clear BSD License

  Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
  zitrokarol@gmail.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted (subject to the limitations in the disclaimer
  below) provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
  THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
}

unit KLib.Utils;

interface

uses
  KLib.Types, KLib.Constants,
  System.SysUtils, System.Classes, System.Rtti, System.JSON, System.TypInfo,
  Data.DB;

function getCleanJSONString(const JSONStr: string): string;
function getCleanJSON(JsonValue: TJSONValue): TJSONValue;

function getSchemaOfType(AType: PTypeInfo): string;

function getMaxOfTValue(value: TValue): double;
function getResizedTValue(value: TValue; max: Double): TValue;
function getDefaultTValue(AType: TRttiType): TValue;

function checkIfTValueIsEmpty(const AValue: TValue): Boolean;

function getBitValueOfWord(const sourceValue: Cardinal; const bitIndex: Byte): Boolean;
function getWordWithBitEnabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
function getWordWithBitDisabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
function getWordWithBitSetted(const sourceValue: Cardinal; const bitIndex: Byte; const bitValue: Boolean): Cardinal;

function checkIfVariantTypeIsEmpty(value: Variant; typeAsString: string = EMPTY_STRING): boolean;
function checkIfIsEmptyOrNull(value: Variant): boolean;
function myDefault(typeAsString: string = EMPTY_STRING): Variant;

function getValidItalianTelephoneNumber(number: string): string;
function getValidTelephoneNumber(number: string): string;
function checkIfEmailIsValid(email: string): boolean;
function checkIfRegexIsValid(text: string; regex: string): boolean;
function getStatusAsString(status: TStatus): string;

implementation

uses
  System.Variants, System.Generics.Collections, System.RegularExpressions,
  KLib.StringUtils, KLib.DateTimeUtils;

function getCleanJSONString(const JSONStr: string): string;
var
  JsonValue, CleanedJson: TJSONValue;
begin
  JsonValue := TJSONObject.ParseJSONValue(JSONStr);
  if Assigned(JsonValue) then
    try
      CleanedJson := getCleanJSON(JsonValue);
      try
        Result := CleanedJson.ToJSON;
      finally
        CleanedJson.Free;
      end;
    finally
      JsonValue.Free;
    end
  else
    Result := '{}';
end;

function getCleanJSON(JsonValue: TJSONValue): TJSONValue;
var
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  Pair: TJSONPair;
  NewObject: TJSONObject;
  NewArray: TJSONArray;
  Item: TJSONValue;
  i: Integer;
begin
  if JsonValue is TJSONObject then
  begin
    JSONObject := TJSONObject(JsonValue);
    NewObject := TJSONObject.Create;
    try
      for Pair in JSONObject do
      begin
        Pair.JsonValue := getCleanJSON(Pair.JsonValue);
        if not(Pair.JsonValue is TJSONString and (Pair.JsonValue.Value = '')) and
          not(Pair.JsonValue is TJSONObject and (TJSONObject(Pair.JsonValue).Count = 0)) and
          not(Pair.JsonValue is TJSONArray and (TJSONArray(Pair.JsonValue).Count = 0)) then
        begin
          NewObject.AddPair(Pair.JsonString.Value, Pair.JsonValue.Clone as TJSONValue);
        end;
      end;
      Result := NewObject;
    except
      NewObject.Free;
      raise;
    end;
  end
  else if JsonValue is TJSONArray then
  begin
    JSONArray := TJSONArray(JsonValue);
    NewArray := TJSONArray.Create;
    try
      for i := 0 to JSONArray.Count - 1 do
      begin
        Item := getCleanJSON(JSONArray.Items[i]);
        if not(Item is TJSONString and (Item.Value = '')) and
          not(Item is TJSONObject and (TJSONObject(Item).Count = 0)) and
          not(Item is TJSONArray and (TJSONArray(Item).Count = 0)) then
        begin
          NewArray.AddElement(Item.Clone as TJSONValue);
        end;
      end;
      Result := NewArray;
    except
      NewArray.Free;
      raise;
    end;
  end
  else
  begin
    Result := JsonValue.Clone as TJSONValue;
  end;
end;

function getSchemaOfType(AType: PTypeInfo): string;
var
  ctx: TRTTIContext;
  rttiType: TRttiType;
  resultList: TStringList;

  procedure ProcessRecord(aType: TRttiType; indent: string);
  var
    subField: TRttiField;
    subFieldType: PTypeInfo;
    subType: TRttiType;
    elementType: PTypeInfo;
  begin
    for subField in aType.GetFields do
    begin
      subFieldType := subField.FieldType.Handle;

      case subFieldType.Kind of
        tkRecord:
          begin
            resultList.Add(indent + subField.Name + ': Record');
            ProcessRecord(ctx.GetType(subFieldType), indent + '  '); // Ricorsione
          end;
        tkDynArray:
          begin
            // Prendi il tipo degli elementi dell'array
            elementType := GetTypeData(subFieldType)^.elType2^;
            if Assigned(elementType) then
            begin
              resultList.Add(indent + subField.Name + ': Array of ' + string(elementType.Name));

              // Se gli elementi sono record, esplorali
              subType := ctx.GetType(elementType);
              if (subType <> nil) and (subType.TypeKind = tkRecord) then
              begin
                resultList.Add(indent + '  (Array Content): Record');
                ProcessRecord(subType, indent + '    ');
              end;
            end
            else
              resultList.Add(indent + subField.Name + ': Array of Unknown');
          end;
      else
        resultList.Add(indent + subField.Name + ': ' + subField.FieldType.ToString);
      end;
    end;
  end;

begin
  resultList := TStringList.Create;
  try
    rttiType := ctx.GetType(AType);
    if Assigned(rttiType) then
    begin
      resultList.Add(rttiType.Name + ': Record');
      ProcessRecord(rttiType, '  ');
    end;
    Result := resultList.Text;
  finally
    resultList.Free;
  end;
end;

function getMaxOfTValue(value: TValue): double;
var
  max: double;
begin
  case value.Kind of
    tkInteger:
      begin
        max := value.AsInteger;
      end;

    tkInt64:
      begin
        max := value.AsInt64;
      end;

    tkFloat:
      begin
        max := value.AsExtended;
      end;

    tkString, tkLString, tkWString, tkUString:
      begin
        max := Length(value.AsString);
      end;

  else
    raise Exception.Create('Unsupported type');
  end;

  Result := max;
end;

function getResizedTValue(value: TValue; max: Double): TValue;
var
  _string: string;
begin
  case value.Kind of
    tkInteger:
      begin
        if value.AsInteger >= Trunc(max) then
          Result := TValue.From<Integer>(Trunc(max))
        else
          Result := TValue.From<Integer>(value.AsInteger);
      end;

    tkInt64:
      begin
        if value.AsInt64 >= Trunc(max) then
          Result := TValue.From<Int64>(Trunc(max))
        else
          Result := TValue.From<Int64>(value.AsInt64);
      end;

    tkFloat:
      begin
        if value.AsExtended >= max then
          Result := TValue.From<Double>(max)
        else
          Result := TValue.From<Double>(value.AsExtended);
      end;

    tkString, tkLString, tkWString, tkUString:
      begin
        _string := value.AsString;
        if Length(_string) > Trunc(max) then
          _string := Copy(_string, 1, Trunc(max));
        Result := TValue.From<string>(_string);
      end;

  else
    Result := value;
  end;
end;

function getDefaultTValue(AType: TRttiType): TValue;
var
  _classType: TRttiInstanceType;
  _classinstance: TObject;
begin
  case AType.TypeKind of
    tkString, tkLString, tkWString, tkUString:
      Result := TValue.From<string>('');
    tkInteger, tkInt64:
      Result := TValue.From<Integer>(0);
    tkFloat:
      Result := TValue.From<Double>(0.0);
    tkEnumeration:
      if AType.Handle = TypeInfo(Boolean) then
      begin
        Result := TValue.From<Boolean>(false);
      end
      else
      begin
        Result := TValue.FromOrdinal(AType.Handle, 0);
      end;
    tkClass:
      begin
        _classType := AType as TRttiInstanceType;
        _classinstance := AType.GetMethod('Create').Invoke(_classType.MetaclassType, []).AsObject;

        Result := TValue.From<TObject>(_classinstance);
      end;
  else
    Result := TValue.Empty;
  end;
end;

function checkIfTValueIsEmpty(const AValue: TValue): Boolean;
begin
  case AValue.Kind of
    tkInteger, tkInt64:
      Result := AValue.AsInteger = 0;
    tkFloat:
      Result := AValue.AsExtended = 0;
    tkString, tkLString, tkWString, tkUString:
      Result := AValue.AsString = '';
    tkEnumeration:
      Result := AValue.AsOrdinal < 0;
  else
    Result := False;
  end;
end;

//get a particular bit value
function getBitValueOfWord(const sourceValue: Cardinal; const bitIndex: Byte): Boolean;
begin
  Result := (sourceValue and (1 shl bitIndex)) <> 0;
end;

//set a particular bit as 1
function getWordWithBitEnabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal; //TODO refactor
begin
  Result := getWordWithBitSetted(sourceValue, bitIndex, true);
end;

//set a particular bit as 0
function getWordWithBitDisabled(const sourceValue: Cardinal; const bitIndex: Byte): Cardinal;
begin
  Result := getWordWithBitSetted(sourceValue, bitIndex, false);
end;

//enable or disable a bit
function getWordWithBitSetted(const sourceValue: Cardinal; const bitIndex: Byte; const bitValue: Boolean): Cardinal;
begin
  Result := (sourceValue or (1 shl bitIndex)) xor (Cardinal(not bitValue) shl bitIndex);
end;

function checkIfVariantTypeIsEmpty(value: Variant; typeAsString: string = EMPTY_STRING): boolean;
var
  isEmpty: boolean;

  _emptyValue: variant;
begin
  _emptyValue := myDefault(typeAsString);
  isEmpty := value = _emptyValue;

  Result := isEmpty;
end;

function checkIfIsEmptyOrNull(value: Variant): boolean;
begin
  Result := VarIsClear(value) or VarIsEmpty(value) or VarIsNull(value) or (VarCompareValue(value, Unassigned) = vrEqual);
  if (not Result) and VarIsStr(value) then
  begin
    Result := value = '';
  end;
end;

function myDefault(typeAsString: string = EMPTY_STRING): Variant;
var
  value: Variant;
begin
  if typeAsString = 'string' then
  begin
    value := Default (string);
  end;
  if typeAsString = 'Integer' then
  begin
    value := Default (Integer);
  end;
  if typeAsString = 'Double' then
  begin
    value := Default (Double);
  end;
  if typeAsString = 'Char' then
  begin
    value := Default (Char);
  end;
  if typeAsString = 'Boolean' then
  begin
    value := Default (Boolean);
  end;
  if (typeAsString = 'Variant') or (typeAsString = EMPTY_STRING) then
  begin
    value := Default (Variant);
  end;

  Result := value;
end;

function getValidItalianTelephoneNumber(number: string): string;
var
  telephoneNumber: string;
  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  if _number = '' then
  begin
    telephoneNumber := '';
  end
  else
  begin
    if _number.StartsWith('0039') then
    begin
      _number := StringReplace(_number, '0039', '+39', []);
    end;

    if not _number.StartsWith('+') then
    begin
      _number := '+39' + _number;
    end;

    if not _number.StartsWith('+39') then
    begin
      _number := StringReplace(_number, '+', '+39', []);
    end;

    telephoneNumber := '+';
    for i := 2 to length(_number) do
    begin
      if CharInSet(_number[i], ['0' .. '9']) then
      begin
        telephoneNumber := telephoneNumber + _number[i];
      end;
    end;
  end;

  Result := telephoneNumber;
end;

function getValidTelephoneNumber(number: string): string;
const
  ERR_MSG = 'Telephone number is empty.';
var
  telephoneNumber: string;
  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  if _number = '' then
    raise Exception.Create(ERR_MSG);

  if _number[1] = '+' then
  begin
    telephoneNumber := '+';
  end;
  for i := 2 to length(_number) do
  begin
    if CharInSet(_number[i], ['0' .. '9']) then
    begin
      telephoneNumber := telephoneNumber + _number[i];
    end;
  end;

  Result := telephoneNumber;
end;

function checkIfEmailIsValid(email: string): boolean;
begin
  Result := TRegEx.IsMatch(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
end;

function checkIfRegexIsValid(text: string; regex: string): boolean;
begin
  Result := TRegEx.IsMatch(text, regex);
end;

function getStatusAsString(status: TStatus): string;
var
  status_asString: string;
begin
  case status of
    TStatus._null:
      status_asString := '_null';
    TStatus.created:
      status_asString := 'created';
    TStatus.stopped:
      status_asString := 'stopped';
    TStatus.paused:
      status_asString := 'paused';
    TStatus.running:
      status_asString := 'running';
  end;

  Result := status_asString;
end;

end.
