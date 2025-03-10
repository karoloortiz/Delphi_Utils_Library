{
  KLib Version = 3.0
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

//##### JSON #################
//  ATTRIBUTES:
//  - CustomNameAttribute
//  - DefaultValueAttribute
//  - MaxLengthAttribute
//  - IgnoreAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generics.JSON, KLib.Generics.Attributes; //always include
//
// type
//  TResponse = record
//  public
//    [MaxLengthAttribute(8)]
//    timestamp: string;
//    timestamps: TArrayOfString;
//    values: TArrayOfInteger;
//    sucess: boolen;
//    [DefaultValueAttribute('yes')]
//    error: string;
//    [IgnoreAttribute]
//    ignoredField: string;
//  end;
//
//  ...
//  var
//  _response: TResponse;
//
//  begin
//  ...
//  _responseText := TJSONGenerics.getJSONAsString<TResponse>(_response);
//#####################################

unit KLib.Generics.JSON;

interface

uses
  KLib.Generics.Attributes,
  System.Rtti, System.JSON, System.TypInfo;

type

  TJSONRecord<T: record > = class
  public
    myRecord: T;
    constructor Create(); overload;
    constructor Create(const ARecord: T); overload;

    procedure readFromFile(filename: string);
    procedure saveToFile(filename: string);
    function getAsString(): string;
  end;

  TJSONGenerics = class
  private
    class function processRecord(Instance: Pointer; TypeInfo: PTypeInfo; AIgnoreEmpty: Boolean): TJSONObject;
    class function getDefaultTValue(Field: TRttiField): TValue;
    //
    class procedure processJSONObject(Instance: Pointer; RttiType: TRttiType; JSONObject: TJSONObject);
  public
    class procedure saveToFile<T>(myRecord: T; filename: string;
      ignoreEmptyStrings: boolean = true);
    class function getJSONAsString<T>(myRecord: T; ignoreEmptyStrings: boolean = true): string;
    class function getJSONObject<T>(const myRecord: T; ignoreEmptyStrings: Boolean = True): TJSONObject;

    class function JSONToTValue(JSONValue: TJSONValue; TargetType: TRttiType): TValue;
    class function getJSONFromTValue(const AValue: TValue; AIgnoreEmpty: Boolean; maxLenghtValue: double = -1): TJSONValue;
    //
    class function readFromFile<T>(filename: string): T;
    class function getParsedJSON<T>(JSONAsString: string): T; overload;
    class function getParsedJSON<T>(JSONValue: TJSONValue): T; overload;
  end;

implementation

//todo maxlengthattribute in getParsedJSON

uses
  KLib.Utils, KLib.Math,
  System.DateUtils, System.SysUtils, System.Classes;

constructor TJSONRecord<T>.Create();
begin
  myRecord := Default (T);
end;

constructor TJSONRecord<T>.Create(const ARecord: T);
begin
  myRecord := ARecord;
end;

procedure TJSONRecord<T>.readFromFile(filename: string);
var
  _text: string;
begin
  _text := getTextFromFile(filename);
  myRecord := TJSONGenerics.getParsedJSON<T>(_text);
end;

procedure TJSONRecord<T>.saveToFile(filename: string);
var
  _text: string;
begin
  _text := getAsString();
  KLib.Utils.saveToFile(_text, filename);
end;

function TJSONRecord<T>.getAsString(): string;
begin
  Result := TJSONGenerics.getJSONAsString<T>(myRecord);
end;

{ TJSONGenerics }

//  System.JSON.Serializers;
//procedure TShipmentRequest.saveToFile2(filename: string);
//var
//  Serializer: TJsonSerializer;
//  temp: string;
//begin
//  Serializer := TJsonSerializer.Create;
//  try
//    temp := Serializer.Serialize<TShipmentRequest>(Self);
//  finally
//    Serializer.Free;
//  end;
//end;

class procedure TJSONGenerics.saveToFile<T>(myRecord: T; filename: string;
  ignoreEmptyStrings: boolean = true);
var
  _text: string;
begin
  _text := TJSONGenerics.getJSONAsString<T>(myRecord);
  KLib.Utils.saveToFile(_text, filename);
end;

class function TJSONGenerics.getJSONAsString<T>(myRecord: T;
  ignoreEmptyStrings: boolean = true): string;
var
  JSONAsString: string;
  _JSONObject: TJSONObject;
begin
  _JSONObject := getJSONObject<T>(myRecord, ignoreEmptyStrings);
  JSONAsString := _JSONObject.ToString;
  _JSONObject.Free;

  Result := JSONAsString;
end;

class function TJSONGenerics.getJSONObject<T>(const myRecord: T; ignoreEmptyStrings: Boolean): TJSONObject;
begin
  Result := processRecord(@myRecord, TypeInfo(T), ignoreEmptyStrings);
end;

class function TJSONGenerics.processRecord(Instance: Pointer; TypeInfo: PTypeInfo; AIgnoreEmpty: Boolean): TJSONObject;
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  FieldTValue: TValue;
  JSONPair: TJSONPair;
  CustomName: string;
  maxLengthAttributeValue: double;

  _jsonValue: TJSONValue;
begin
  Result := TJSONObject.Create;
  try
    RttiType := Ctx.GetType(TypeInfo);

    for Field in RttiType.GetFields do
    begin
      if Field.GetAttribute<IgnoreAttribute> <> nil then
        Continue;

      // Get custom name
      CustomName := Field.Name;
      if Field.GetAttribute<CustomNameAttribute> <> nil then
        CustomName := Field.GetAttribute<CustomNameAttribute>.Value;

      // Get field value
      FieldTValue := Field.GetValue(Instance);

      // Apply default value
      if (checkIfTValueIsEmpty(FieldTValue)) then
      begin
        FieldTValue := getDefaultTValue(Field);
      end;

      //apply maxlength attribute
      maxLengthAttributeValue := -1;
      if (Field.GetAttribute<MaxLengthAttribute> <> nil) then
      begin
        maxLengthAttributeValue := Field.GetAttribute<MaxLengthAttribute>.Value;
      end;

      // Skip empty values
      if (AIgnoreEmpty and checkIfTValueIsEmpty(FieldTValue)
        and (Field.FieldType.TypeKind <> tkRecord)) then
        Continue;

      // Create JSON pair
      _jsonValue := getJSONFromTValue(FieldTValue, AIgnoreEmpty, maxLengthAttributeValue);
      if (Assigned(_jsonValue)) then
      begin
        JSONPair := TJSONPair.Create(CustomName, _jsonValue);
        try
          Result.AddPair(JSONPair);
        except
          JSONPair.Free;
          raise;
        end;
      end;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

class function TJSONGenerics.getJSONFromTValue(const AValue: TValue; AIgnoreEmpty: Boolean; maxLenghtValue: double = -1): TJSONValue;
var
  _value: TValue;
  Ctx: TRttiContext;
  RttiType: TRttiType;
  I: Integer;
  Arr: TJSONArray;
  Obj: TJSONObject;
  _maxArraySize: integer;
begin
  RttiType := Ctx.GetType(AValue.TypeInfo);

  _value := AValue;
  if (maxLenghtValue > 0) then
  begin
    _value := getResizedTValue(_value, maxLenghtValue);
  end;

  case RttiType.TypeKind of
    tkInteger, tkInt64:
      Result := TJSONNumber.Create(_value.AsInteger);

    tkFloat:
      if _value.TypeInfo = TypeInfo(TDateTime) then
        Result := TJSONString.Create(DateToISO8601(_value.AsType<TDateTime>))
      else
        Result := TJSONNumber.Create(_value.AsExtended);

    tkString, tkLString, tkWString, tkUString:
      Result := TJSONString.Create(_value.AsString);

    tkEnumeration:
      if _value.TypeInfo = TypeInfo(Boolean) then
        Result := TJSONBool.Create(_value.AsBoolean)
      else
        Result := TJSONString.Create(_value.ToString);

    tkRecord:
      begin
        // Modifica cruciale per i record annidati
        Obj := processRecord(_value.GetReferenceToRawData, _value.TypeInfo, AIgnoreEmpty);
        if Obj.Count > 0 then
          Result := Obj
        else
        begin
          Obj.Free;
          // Result := TJSONNull.Create;
          Result := nil;
        end;
      end;
    tkDynArray:
      begin
        _maxArraySize := _value.GetArrayLength - 1;
        if (maxLenghtValue > 0) then
        begin
          _maxArraySize := getMin(_value.GetArrayLength, Trunc(maxLenghtValue)) - 1;
        end;

        Arr := TJSONArray.Create;
        try
          for I := 0 to _maxArraySize do
            Arr.AddElement(getJSONFromTValue(_value.GetArrayElement(I), AIgnoreEmpty));
          Result := Arr;
        except
          Arr.Free;
          raise;
        end;
      end;

  else
    raise Exception.Create('Unsupported type: ' + RttiType.Name);
  end;
end;

class function TJSONGenerics.JSONToTValue(JSONValue: TJSONValue; TargetType: TRttiType): TValue;
var
  Ctx: TRttiContext;
  RecInstance: Pointer;
  I: Integer;
  Arr: TArray<TValue>;
  DynArrayType: TRttiDynamicArrayType;
begin
  case TargetType.TypeKind of
    tkInteger:
      Result := StrToIntDef(JSONValue.Value, 0);
    tkInt64:
      Result := StrToInt64Def(JSONValue.Value, 0);
    tkFloat:
      if TargetType.Handle = TypeInfo(TDateTime) then
        Result := ISO8601ToDate(JSONValue.Value)
      else
        Result := TJSONNumber(JSONValue).AsDouble;
    tkString, tkLString, tkWString, tkUString:
      Result := JSONValue.Value;
    tkEnumeration:
      if TargetType.Handle = TypeInfo(Boolean) then
        Result := JSONValue.GetValue<Boolean>
      else
        Result := TValue.FromOrdinal(TargetType.Handle, GetEnumValue(TargetType.Handle, JSONValue.Value));
    tkChar, tkWChar:
      Result := TValue.From<Char>(JSONValue.Value[1]);
    tkVariant:
      Result := TValue.From<Variant>(JSONValue.Value);
    tkRecord:
      begin
        TValue.Make(nil, TargetType.Handle, Result);
        RecInstance := Result.GetReferenceToRawData;
        processJSONObject(RecInstance, Ctx.GetType(TargetType.Handle), TJSONObject(JSONValue));
      end;
    tkDynArray:
      begin
        if JSONValue is TJSONArray then
        begin
          DynArrayType := TargetType as TRttiDynamicArrayType;
          SetLength(Arr, TJSONArray(JSONValue).Count);
          for I := 0 to High(Arr) do
            Arr[I] := JSONToTValue(TJSONArray(JSONValue).Items[I],
              DynArrayType.ElementType);
          Result := TValue.FromArray(TargetType.Handle, Arr);
        end;
      end;

  else
    raise EJSONException.CreateFmt('Unsupported type: %s', [TargetType.Name]);
  end;
end;

//----------------------
class function TJSONGenerics.readFromFile<T>(filename: string): T;
var
  _text: string;
begin
  _text := getTextFromFile(filename);

  Result := TJSONGenerics.getParsedJSON<T>(_text);
end;

class function TJSONGenerics.getParsedJSON<T>(JSONAsString: string): T;
var
  _result: T;

  _JSONFile: TBytes;
  _JSONValue: TJSONValue;
begin
  _JSONFile := TEncoding.UTF8.GetBytes(JSONAsString);
  _JSONValue := TJSONObject.ParseJSONValue(_JSONFile, 0);
  try
    _result := getParsedJSON<T>(_JSONValue);
  finally
    FreeAndNil(_JSONValue);
  end;

  Result := _result;
end;

class function TJSONGenerics.getParsedJSON<T>(JSONValue: TJSONValue): T;
var
  Ctx: TRttiContext;
begin
  if not(JSONValue is TJSONObject) then
    raise EJSONException.Create('TJSONObject expected');

  // Inizializza il record con valori di default
  Result := Default (T);

  // Elabora il JSON
  processJSONObject(@Result, Ctx.GetType(TypeInfo(T)), TJSONObject(JSONValue));
end;

class procedure TJSONGenerics.processJSONObject(Instance: Pointer; RttiType: TRttiType; JSONObject: TJSONObject);
var
  Field: TRttiField;
  CustomName: string;
  FieldValue: TJSONValue;
  FieldPath: string;
begin
  for Field in RttiType.GetFields do
  begin
    if Field.GetAttribute<IgnoreAttribute> <> nil then
      Continue;

    try
      // CustomNameAttribute
      CustomName := Field.Name;
      if (Field.GetAttribute<CustomNameAttribute> <> nil) then
      begin
        CustomName := Field.GetAttribute<CustomNameAttribute>.Value;
      end;

      FieldValue := JSONObject.GetValue(CustomName);

      if (Assigned(FieldValue)) then
      begin
        Field.SetValue(Instance, JSONToTValue(FieldValue, Field.FieldType));
      end;

      if (not Assigned(FieldValue)) then
      begin
        Field.SetValue(Instance, getDefaultTValue(Field));
      end;

    except
      on E: Exception do
      begin
        FieldPath := Format('%s.%s', [RttiType.Name, Field.Name]);
        raise EJSONException.CreateFmt('Errore nel campo %s: %s', [FieldPath, E.Message]);
      end;
    end;
  end;
end;

class function TJSONGenerics.getDefaultTValue(Field: TRttiField): TValue;
var
  DefaultAttr: DefaultValueAttribute;
begin
  DefaultAttr := Field.GetAttribute<DefaultValueAttribute>;

  if (DefaultAttr <> nil) then
  begin
    case Field.FieldType.TypeKind of
      tkString, tkLString, tkWString, tkUString:
        Result := TValue.From<string>(DefaultAttr.Value);
      tkInteger:
        Result := TValue.From<Integer>(StrToIntDef(DefaultAttr.Value, 0));
      tkEnumeration:
        if Field.FieldType.Handle = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(SameText(DefaultAttr.Value, 'true'));
    end;
  end
  else
  begin
    Result := KLib.Utils.getDefaultTValue(Field.FieldType);
  end;
end;

end.
