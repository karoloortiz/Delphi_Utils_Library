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
//  - MinAttribute
//  - MaxAttribute
//  - IgnoreAttribute
//  - RequiredAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generics.JSON, KLib.Generics.Attributes; //always include
//
// type
//  TResponse = record
//  public
//    [MaxAttribute(8)]
//    timestamp: string;
//    timestamps: TArrayOfString;
//    values: TArrayOfInteger;
//    [RequiredAttribute]
//    success: boolean;
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
    class procedure processJSONObjectClass(Instance: TObject; RttiType: TRttiInstanceType; JSONObject: TJSONObject);
    class procedure processJSONObject(Instance: Pointer; RttiType: TRttiType; JSONObject: TJSONObject);

    class function processClass(ClassInstance: TObject; ClassType: TRttiInstanceType; AIgnoreEmpty: Boolean = False): TJSONObject;

  public
    class procedure saveToFile<T>(myRecord: T; filename: string;
      ignoreEmptyStrings: boolean = true);
    class function getJSONAsString<T>(myRecord: T; ignoreEmptyStrings: boolean = true): string;
    class function getJSONObject<T>(const myRecord: T; ignoreEmptyStrings: Boolean = True): TJSONObject;

    class function JSONToTValue(JSONValue: TJSONValue; TargetType: TRttiType): TValue;
    class function getJSONFromTValue(const AValue: TValue; AIgnoreEmpty: Boolean;
      minValue: double = -1; maxValue: double = -1): TJSONValue;
    //
    class function readFromFile<T>(filename: string): T;
    class function getParsedJSON<T>(JSONAsString: string): T; overload;
    class function getParsedJSON<T>(JSONValue: TJSONValue): T; overload;
  end;

implementation

uses
  KLib.Utils, KLib.Math, KLib.Constants,
  System.DateUtils, System.SysUtils, System.Classes, System.Generics.Collections;

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
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Value: TValue;
  ObjInstance: TObject;
begin
  RttiType := Ctx.GetType(TypeInfo(T));

  TValue.Make(@myRecord, TypeInfo(T), Value);

  if RttiType.TypeKind = tkClass then
  begin
    ObjInstance := Value.AsObject;
    if ObjInstance = nil then
    begin
      Result := TJSONObject.Create;
    end
    else
    begin
      Result := processClass(ObjInstance, RttiType as TRttiInstanceType, ignoreEmptyStrings);
    end;
  end
  else if RttiType.TypeKind = tkRecord then
  begin
    Result := processRecord(@myRecord, TypeInfo(T), ignoreEmptyStrings);
  end
  else
  begin
    raise Exception.Create('Type must be a class or record');
  end;
end;

class function TJSONGenerics.processRecord(Instance: Pointer; TypeInfo: PTypeInfo; AIgnoreEmpty: Boolean): TJSONObject;
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  FieldTValue: TValue;
  JSONPair: TJSONPair;
  _customName: string;
  _minAttributeValue: double;
  _maxAttributeValue: double;
  _isRequiredAttribute: boolean;
  _isDefaultAttribute: boolean;

  _jsonValue: TJSONValue;
  _errorMessage: string;
begin
  Result := TJSONObject.Create;
  try
    RttiType := Ctx.GetType(TypeInfo);

    for Field in RttiType.GetFields do
    begin
      if Field.GetAttribute<IgnoreAttribute> <> nil then
        Continue;

      // Get custom name
      _customName := Field.Name;
      if Field.GetAttribute<CustomNameAttribute> <> nil then
      begin
        _customName := Field.GetAttribute<CustomNameAttribute>.Value;
      end;

      // Get field value
      FieldTValue := Field.GetValue(Instance);

      _isRequiredAttribute := Field.GetAttribute<RequiredAttribute> <> nil;

      _isDefaultAttribute := Field.GetAttribute<DefaultValueAttribute> <> nil;
      // Apply default value
      if (checkIfTValueIsEmpty(FieldTValue)) then
      begin
        if (_isRequiredAttribute) and (not _isDefaultAttribute) then
        begin
          raise Exception.Create('Field required: ' + _customName);
        end;
        FieldTValue := getDefaultTValue(Field);
      end;

      //apply minlength attribute
      _minAttributeValue := -1;
      if (Field.GetAttribute<MinAttribute> <> nil) then
      begin
        _minAttributeValue := Field.GetAttribute<MinAttribute>.Value;
      end;

      //apply maxlength attribute
      _maxAttributeValue := -1;
      if (Field.GetAttribute<MaxAttribute> <> nil) then
      begin
        _maxAttributeValue := Field.GetAttribute<MaxAttribute>.Value;
      end;

      // Skip empty values
      if (AIgnoreEmpty and checkIfTValueIsEmpty(FieldTValue)
        and (Field.FieldType.TypeKind <> tkRecord)) then
        Continue;

      // Create JSON pair
      _jsonValue := getJSONFromTValue(FieldTValue, AIgnoreEmpty, _minAttributeValue,
        _maxAttributeValue);
      if (Assigned(_jsonValue)) then
      begin
        JSONPair := TJSONPair.Create(_customName, _jsonValue);
        try
          Result.AddPair(JSONPair);
        except
          JSONPair.Free;
          raise;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      FreeAndNil(Result);
      _errorMessage := E.Message;
      if (Assigned(Field)) then
      begin
        if (E.message.Contains('JSON process error in field: ')) then
        begin
          _errorMessage := 'JSON process error in field: ' + Field.Name +
            E.message.Replace('JSON process error in field: ', '.');
        end
        else
        begin
          _errorMessage := 'JSON process error in field: ' + Field.Name + ' -> ' +
            E.message;
        end;
      end;
      raise Exception.Create(_errorMessage);
    end;
  end;
end;

class function TJSONGenerics.getJSONFromTValue(const AValue: TValue; AIgnoreEmpty: Boolean;
  minValue: double = -1; maxValue: double = -1): TJSONValue;
var
  _value: TValue;
  Ctx: TRttiContext;
  RttiType: TRttiType;
  i: Integer;
  Arr: TJSONArray;
  Obj: TJSONObject;
  _maxArraySize: integer;
  _currentMaxValue: double;

  _classType: TRttiInstanceType;
  _classInstance: TObject;
  _getCountProperty: TRttiProperty;
  _getItemMethod: TRttiMethod;
  _countValue, _itemValue, _keyValue, _dictValue, _keysValue: TValue;
  _count: Integer;
  _jsonElement: TJSONValue;
  _keyString: string;
  _keysObject: TObject;
  _keysType: TRttiInstanceType;

  _keysProperty: TRttiProperty;
  _toArrayMethod: TRttiMethod;
  _keysArrayValue: TValue;
  _keysArrayLength: Integer;

  _itemsProperty: TRttiIndexedProperty; // Cambia da TRttiProperty a TRttiIndexedProperty

begin
  RttiType := Ctx.GetType(AValue.TypeInfo);

  _value := AValue;

  if (minValue > 0) then
  begin
    _currentMaxValue := getMaxOfTValue(_value);
    if (_currentMaxValue < minValue) then
    begin
      raise Exception.Create('Minimum value ' + FloatToStr(minValue) + ' not met for type: ' + RttiType.Name);
    end;
  end;

  if (maxValue > 0) then
  begin
    _value := getResizedTValue(_value, maxValue);
  end;

  case RttiType.TypeKind of
    tkInteger, tkInt64:
      Result := TJSONNumber.Create(_value.AsInteger);

    tkFloat:
      if _value.TypeInfo = TypeInfo(TDateTime) then
        Result := TJSONString.Create(DateToISO8601(_value.AsType<TDateTime>))
      else if _value.TypeInfo = TypeInfo(TDate) then
        Result := TJSONString.Create(getDateTimeWithFormattingAsString(_value.AsType<TDate>, DATE_FORMAT))
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
        _maxArraySize := _value.GetArrayLength;
        if (maxValue > 0) then
        begin
          _maxArraySize := getMin(_value.GetArrayLength, Trunc(maxValue));
        end;

        Arr := TJSONArray.Create;
        try
          for i := 0 to (_maxArraySize - 1) do
            Arr.AddElement(getJSONFromTValue(_value.GetArrayElement(i), AIgnoreEmpty));
          Result := Arr;
        except
          Arr.Free;
          raise;
        end;
      end;

    tkClass:
      begin
        if _value.IsEmpty or (_value.AsObject = nil) then
        begin
          if AIgnoreEmpty then
            Result := nil
          else
            Result := TJSONNull.Create;
        end
        else if RttiType.Name.StartsWith('TList<') then
        begin
          Arr := TJSONArray.Create;
          try
            _classType := RttiType as TRttiInstanceType;
            _classInstance := _value.AsObject;

            _getCountProperty := _classType.GetProperty('Count');
            _getItemMethod := _classType.GetMethod('GetItem');

            if (_getCountProperty <> nil) and (_getItemMethod <> nil) then
            begin
              _countValue := _getCountProperty.GetValue(_classInstance);
              _count := _countValue.AsInteger;

              for i := 0 to _count - 1 do
              begin
                _itemValue := _getItemMethod.Invoke(_classInstance, [i]);
                _jsonElement := getJSONFromTValue(_itemValue, AIgnoreEmpty, minValue, maxValue);
                if _jsonElement <> nil then
                  Arr.AddElement(_jsonElement);
              end;
            end;

            Result := Arr;
          except
            Arr.Free;
            raise;
          end;
        end
        else if RttiType.Name.StartsWith('TDictionary<') then
        begin
          _classInstance := _value.AsObject;
          if _classInstance = nil then
          begin
            if AIgnoreEmpty then
              Result := nil
            else
              Result := TJSONNull.Create;
            Exit;
          end;

          Obj := TJSONObject.Create;
          try
            _classType := RttiType as TRttiInstanceType;

            _keysProperty := _classType.GetProperty('Keys');
            if _keysProperty <> nil then
            begin
              _keysValue := _keysProperty.GetValue(_classInstance);

              if _keysValue.IsEmpty then
              begin
                Result := Obj;
                Exit;
              end;

              _keysObject := _keysValue.AsObject;

              if _keysObject = nil then
              begin
                Result := Obj;
                Exit;
              end;

              _keysType := Ctx.GetType(_keysObject.ClassInfo) as TRttiInstanceType;
              _toArrayMethod := _keysType.GetMethod('ToArray');

              if _toArrayMethod <> nil then
              begin
                _keysArrayValue := _toArrayMethod.Invoke(_keysObject, []);
                _keysArrayLength := _keysArrayValue.GetArrayLength;

                _itemsProperty := _classType.GetIndexedProperty('Items');

                if _itemsProperty <> nil then
                begin
                  for i := 0 to _keysArrayLength - 1 do
                  begin
                    _keyValue := _keysArrayValue.GetArrayElement(i);
                    _keyString := _keyValue.ToString;

                    try
                      _dictValue := (_itemsProperty as TRttiIndexedProperty).GetValue(_classInstance, [_keyValue]);
                      _jsonElement := getJSONFromTValue(_dictValue, AIgnoreEmpty, minValue, maxValue);
                      if _jsonElement <> nil then
                        Obj.AddPair(_keyString, _jsonElement);
                    except
                      Continue;
                    end;
                  end;
                end
                else
                begin
                  _getItemMethod := _classType.GetMethod('GetItem');
                  if _getItemMethod <> nil then
                  begin
                    for i := 0 to _keysArrayLength - 1 do
                    begin
                      _keyValue := _keysArrayValue.GetArrayElement(i);
                      _keyString := _keyValue.ToString;

                      try
                        _dictValue := _getItemMethod.Invoke(_classInstance, [_keyValue]);
                        _jsonElement := getJSONFromTValue(_dictValue, AIgnoreEmpty, minValue, maxValue);
                        if _jsonElement <> nil then
                          Obj.AddPair(_keyString, _jsonElement);
                      except
                        Continue;
                      end;
                    end;
                  end;
                end;
              end;
            end;

            Result := Obj;
          except
            Obj.Free;
            raise;
          end;
        end
        else
        begin
          _classType := RttiType as TRttiInstanceType;
          _classInstance := _value.AsObject;

          if _classInstance = nil then
          begin
            if AIgnoreEmpty then
              Result := nil
            else
              Result := TJSONNull.Create;
          end
          else
          begin
            Obj := processClass(_classInstance, _classType, AIgnoreEmpty);
            if Obj.Count > 0 then
              Result := Obj
            else
            begin
              Obj.Free;
              Result := nil;
            end;
          end;
        end;
      end;

  else
    raise Exception.Create('Unsupported type: ' + RttiType.Name);
  end;
end;

class function TJSONGenerics.processClass(ClassInstance: TObject; ClassType: TRttiInstanceType; AIgnoreEmpty: Boolean = False): TJSONObject;
var
  Field: TRttiField;
  Prop: TRttiProperty;
  FieldValue: TValue;
  JSONElement: TJSONValue;
  FieldName: string;
  _customName: string;
  _minAttributeValue: double;
  _maxAttributeValue: double;
  _isRequiredAttribute: boolean;
  _isDefaultAttribute: boolean;
  _errorMessage: string;
  _fieldOffset: Integer;
begin
  Result := TJSONObject.Create;

  try
    if ClassInstance = nil then
    begin
      Exit;
    end;

    for Field in ClassType.GetFields do
    begin
      if Field.Visibility in [mvPublic, mvPublished] then
      begin
        if Field.GetAttribute<IgnoreAttribute> <> nil then
          Continue;

        _customName := Field.Name;
        if Field.GetAttribute<CustomNameAttribute> <> nil then
        begin
          _customName := Field.GetAttribute<CustomNameAttribute>.Value;
        end;

        try
          _fieldOffset := Field.Offset;

          if (_fieldOffset < 0) or (_fieldOffset > 100000) then
          begin
            if not AIgnoreEmpty then
              Result.AddPair(_customName, TJSONNull.Create);
            Continue;
          end;

          try
            if Field.FieldType.Name.StartsWith('TDictionary<') then
            begin
              try
                FieldValue := Field.GetValue(ClassInstance);
              except
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
                Continue;
              end;

              if FieldValue.IsEmpty then
              begin
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
                Continue;
              end;

              try
                if FieldValue.AsObject = nil then
                begin
                  if not AIgnoreEmpty then
                    Result.AddPair(_customName, TJSONNull.Create);
                  Continue;
                end;
              except
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
                Continue;
              end;
            end
            else
            begin
              FieldValue := Field.GetValue(ClassInstance);
            end;
          except
            on E: EAccessViolation do
            begin
              if Field.FieldType.TypeKind = tkClass then
              begin
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
                Continue;
              end
              else
              begin
                try
                  FieldValue := getDefaultTValue(Field);
                except
                  Continue;
                end;
              end;
            end;
            on E: Exception do
            begin
              if Field.FieldType.TypeKind = tkClass then
              begin
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
                Continue;
              end
              else
                raise;
            end;
          end;

          _isRequiredAttribute := Field.GetAttribute<RequiredAttribute> <> nil;
          _isDefaultAttribute := Field.GetAttribute<DefaultValueAttribute> <> nil;

          if (Field.FieldType.TypeKind = tkClass) then
          begin
            if FieldValue.IsEmpty or (FieldValue.AsObject = nil) then
            begin
              if _isRequiredAttribute and not _isDefaultAttribute then
              begin
                raise Exception.Create('Field required: ' + _customName);
              end;
              if AIgnoreEmpty then
                Continue
              else
                Result.AddPair(_customName, TJSONNull.Create);
              Continue;
            end;
          end;

          if (checkIfTValueIsEmpty(FieldValue)) and (Field.FieldType.TypeKind <> tkClass) then
          begin
            if (_isRequiredAttribute) and (not _isDefaultAttribute) then
            begin
              raise Exception.Create('Field required: ' + _customName);
            end;
            FieldValue := getDefaultTValue(Field);
          end;

          // Apply min/max attributes
          _minAttributeValue := -1;
          if (Field.GetAttribute<MinAttribute> <> nil) then
            _minAttributeValue := Field.GetAttribute<MinAttribute>.Value;

          _maxAttributeValue := -1;
          if (Field.GetAttribute<MaxAttribute> <> nil) then
            _maxAttributeValue := Field.GetAttribute<MaxAttribute>.Value;

          // Skip empty values if needed
          if (AIgnoreEmpty and checkIfTValueIsEmpty(FieldValue)
            and (Field.FieldType.TypeKind <> tkRecord)
            and (Field.FieldType.TypeKind <> tkClass)) then
            Continue;

          JSONElement := getJSONFromTValue(FieldValue, AIgnoreEmpty, _minAttributeValue, _maxAttributeValue);

          if (JSONElement <> nil) then
          begin
            Result.AddPair(_customName, JSONElement);
          end;
        except
          on E: EAccessViolation do
          begin
            if not AIgnoreEmpty then
              Result.AddPair(_customName, TJSONNull.Create);
          end;
          on E: Exception do
          begin
            _errorMessage := Format('JSON process error in field "%s": %s',
              [Field.Name, E.Message]);
            raise Exception.Create(_errorMessage);
          end;
        end;
      end;
    end;


    for Prop in ClassType.GetProperties do
    begin
      if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsReadable then
      begin
        if Prop.GetAttribute<IgnoreAttribute> <> nil then
          Continue;

        _customName := Prop.Name;
        if Prop.GetAttribute<CustomNameAttribute> <> nil then
          _customName := Prop.GetAttribute<CustomNameAttribute>.Value;

        if Result.FindValue(_customName) <> nil then
          Continue;

        try
          try
            FieldValue := Prop.GetValue(ClassInstance);
          except
            on E: EAccessViolation do
            begin
              if Prop.PropertyType.TypeKind = tkClass then
              begin
                if not AIgnoreEmpty then
                  Result.AddPair(_customName, TJSONNull.Create);
              end;
              Continue;
            end;
            on E: Exception do
            begin
              Continue;
            end;
          end;

          _isRequiredAttribute := Prop.GetAttribute<RequiredAttribute> <> nil;
          _isDefaultAttribute := Prop.GetAttribute<DefaultValueAttribute> <> nil;

          if (Prop.PropertyType.TypeKind = tkClass) then
          begin
            if FieldValue.IsEmpty or (FieldValue.AsObject = nil) then
            begin
              if _isRequiredAttribute and not _isDefaultAttribute then
                raise Exception.Create('Property required: ' + _customName);

              if AIgnoreEmpty then
                Continue
              else
                Result.AddPair(_customName, TJSONNull.Create);
              Continue;
            end;
          end;

          if (checkIfTValueIsEmpty(FieldValue)) and (Prop.PropertyType.TypeKind <> tkClass) then
          begin
            if (_isRequiredAttribute) and (not _isDefaultAttribute) then
              raise Exception.Create('Property required: ' + _customName);
            if not _isRequiredAttribute then
              Continue;
          end;

          _minAttributeValue := -1;
          if (Prop.GetAttribute<MinAttribute> <> nil) then
            _minAttributeValue := Prop.GetAttribute<MinAttribute>.Value;

          _maxAttributeValue := -1;
          if (Prop.GetAttribute<MaxAttribute> <> nil) then
            _maxAttributeValue := Prop.GetAttribute<MaxAttribute>.Value;

          if (AIgnoreEmpty and checkIfTValueIsEmpty(FieldValue)
            and (Prop.PropertyType.TypeKind <> tkClass)) then
            Continue;

          JSONElement := getJSONFromTValue(FieldValue, AIgnoreEmpty, _minAttributeValue, _maxAttributeValue);

          if (JSONElement <> nil) then
            Result.AddPair(_customName, JSONElement);
        except
          on E: Exception do
          begin
            if _isRequiredAttribute then
            begin
              _errorMessage := Format('JSON process error in property "%s": %s',
                [Prop.Name, E.Message]);
              raise Exception.Create(_errorMessage);
            end;
            Continue;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

class function TJSONGenerics.JSONToTValue(JSONValue: TJSONValue; TargetType: TRttiType): TValue;
var
  Ctx: TRttiContext;
  RecInstance: Pointer;
  i: Integer;
  Arr: TArray<TValue>;
  DynArrayType: TRttiDynamicArrayType;
  _enumValue: integer;

  _classType: TRttiInstanceType;
  _classinstance: TObject;
  _addMethod: TRttiMethod;
  _elementType: TRttiType;

  _value: TValue;

  _keyType, _valueType: TRttiType;
  _keyValue, _valueValue: TValue;
  _jsonObject: TJSONObject;
  _jsonPair: TJSONPair;
begin
  case TargetType.TypeKind of
    tkInteger:
      Result := StrToIntDef(JSONValue.Value, 0);
    tkInt64:
      Result := StrToInt64Def(JSONValue.Value, 0);
    tkFloat:
      if TargetType.Handle = TypeInfo(TDateTime) then
        Result := TValue.From<TDateTime>(ISO8601ToDate(JSONValue.Value))
      else if TargetType.Handle = TypeInfo(TDate) then
        Result := TValue.From<TDate>(ISO8601ToDate(JSONValue.Value))
      else
        Result := TJSONNumber(JSONValue).AsDouble;
    tkString, tkLString, tkWString, tkUString:
      Result := JSONValue.Value;
    tkEnumeration:
      if TargetType.Handle = TypeInfo(Boolean) then
      begin
        Result := JSONValue.GetValue<Boolean>
      end
      else
      begin
        _enumValue := GetEnumValue(TargetType.Handle, JSONValue.Value);
        if (_enumValue < 0) then
        begin
          raise EJSONException.CreateFmt('Unsupported value: %s',
            [JSONValue.Value]);
        end;
        Result := TValue.FromOrdinal(TargetType.Handle, _enumValue);
      end;
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
          for i := 0 to High(Arr) do
            Arr[i] := JSONToTValue(TJSONArray(JSONValue).Items[i],
              DynArrayType.ElementType);
          Result := TValue.FromArray(TargetType.Handle, Arr);
        end;
      end;

    tkClass:
      begin
        if TargetType.Name.StartsWith('TList<') then
        begin
          if JSONValue is TJSONArray then
          begin
            _classType := TargetType as TRttiInstanceType;

            _classinstance := _classType.GetMethod('Create').Invoke(_classType.MetaclassType, []).AsObject;

            try
              _addMethod := _classType.GetMethod('Add');
              if (_addMethod = nil) or (Length(_addMethod.GetParameters) = 0) then
              begin
                raise EJSONException.Create('Add method not found or invalid in TList');
              end;

              _elementType := _addMethod.GetParameters[0].ParamType;

              for i := 0 to (TJSONArray(JSONValue).Count - 1) do
              begin
                _value := JSONToTValue(TJSONArray(JSONValue).Items[i], _elementType);
                _addMethod.Invoke(_classinstance, _value);
              end;

              Result := TValue.From<TObject>(_classinstance);
            except
              on E: Exception do
              begin
                _classinstance.Free;
                raise;
              end;
            end;
          end;
        end
        else if TargetType.Name.StartsWith('TDictionary<') then
        begin
          if JSONValue is TJSONObject then
          begin
            _classType := TargetType as TRttiInstanceType;

            _classinstance := _classType.GetMethod('Create').Invoke(_classType.MetaclassType, []).AsObject;

            try
              _addMethod := _classType.GetMethod('Add');
              if (_addMethod = nil) or (Length(_addMethod.GetParameters) < 2) then
              begin
                raise EJSONException.Create('Add method not found or invalid in TDictionary');
              end;

              _keyType := _addMethod.GetParameters[0].ParamType; // TKey
              _valueType := _addMethod.GetParameters[1].ParamType; // TValue

              _jsonObject := TJSONObject(JSONValue);
              for i := 0 to _jsonObject.Count - 1 do
              begin
                _jsonPair := _jsonObject.Pairs[i];

                _keyValue := JSONToTValue(TJSONString.Create(_jsonPair.JsonString.Value), _keyType);

                _valueValue := JSONToTValue(_jsonPair.JsonValue, _valueType);

                _addMethod.Invoke(_classinstance, [_keyValue, _valueValue]);
              end;

              Result := TValue.From<TObject>(_classinstance);
            except
              on E: Exception do
              begin
                _classinstance.Free;
                raise;
              end;
            end;
          end;
        end
        else
        begin
          if JSONValue is TJSONObject then
          begin
            _classType := TargetType as TRttiInstanceType;
            _classinstance := _classType.GetMethod('Create').Invoke(_classType.MetaclassType, []).AsObject;

            try
              processJSONObjectClass(_classinstance, _classType, TJSONObject(JSONValue)); // <-- CAMBIATO QUI

              Result := TValue.From<TObject>(_classinstance);
            except
              on E: Exception do
              begin
                _classinstance.Free;
                raise;
              end;
            end;
          end
          else
          begin
            raise Exception.Create('Unsupported type');
          end;
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
  RttiType: TRttiType;
  Value: TValue;
  ClassInstance: TObject;
begin
  if not(JSONValue is TJSONObject) then
    raise EJSONException.Create('TJSONObject expected');

  RttiType := Ctx.GetType(TypeInfo(T));

  if RttiType.TypeKind = tkClass then
  begin
    ClassInstance := (RttiType as TRttiInstanceType).GetMethod('Create').Invoke(
      (RttiType as TRttiInstanceType).MetaclassType, []).AsObject;
    try
      processJSONObjectClass(ClassInstance, RttiType as TRttiInstanceType, TJSONObject(JSONValue));
      TValue.Make(@ClassInstance, TypeInfo(T), Value);
      Result := Value.AsType<T>;
    except
      ClassInstance.Free;
      raise;
    end;
  end
  else if RttiType.TypeKind = tkRecord then
  begin
    Result := Default (T);
    processJSONObject(@Result, RttiType, TJSONObject(JSONValue));
  end
  else
  begin
    raise Exception.Create('Type must be a class or record');
  end;
end;

class procedure TJSONGenerics.processJSONObjectClass(Instance: TObject; RttiType: TRttiInstanceType; JSONObject: TJSONObject);
var
  Field: TRttiField;
  Prop: TRttiProperty;
  CustomName: string;
  FieldValue: TJSONValue;
  FieldPath: string;
  TValueField: TValue;
begin
  for Field in RttiType.GetFields do
  begin
    if Field.Visibility in [mvPublic, mvPublished] then
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

        if Assigned(FieldValue) and not(FieldValue is TJSONNull) then
        begin
          Field.SetValue(Instance, JSONToTValue(FieldValue, Field.FieldType));
        end
        else
        begin
          Field.SetValue(Instance, getDefaultTValue(Field));
        end;

      except
        on E: Exception do
        begin
          FieldPath := Format('%s.%s', [RttiType.Name, Field.Name]);
          raise EJSONException.CreateFmt('Error in field %s : %s', [FieldPath, E.Message]);
        end;
      end;
    end;
  end;

  for Prop in RttiType.GetProperties do
  begin
    if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsWritable then
    begin
      if Prop.GetAttribute<IgnoreAttribute> <> nil then
        Continue;

      try
        // CustomNameAttribute
        CustomName := Prop.Name;
        if (Prop.GetAttribute<CustomNameAttribute> <> nil) then
        begin
          CustomName := Prop.GetAttribute<CustomNameAttribute>.Value;
        end;

        FieldValue := JSONObject.GetValue(CustomName);

        if Assigned(FieldValue) and not(FieldValue is TJSONNull) then
        begin
          TValueField := JSONToTValue(FieldValue, Prop.PropertyType);
          Prop.SetValue(Instance, TValueField);
        end
        else
        begin
          TValueField := KLib.Utils.getDefaultTValue(Prop.PropertyType);
          Prop.SetValue(Instance, TValueField);
        end;

      except
        on E: Exception do
        begin
          FieldPath := Format('%s.%s', [RttiType.Name, Prop.Name]);
          raise EJSONException.CreateFmt('Error in property %s : %s', [FieldPath, E.Message]);
        end;
      end;
    end;
  end;
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

      if Assigned(FieldValue) and not(FieldValue is TJSONNull) then
      begin
        Field.SetValue(Instance, JSONToTValue(FieldValue, Field.FieldType));
      end
      else
      begin
        Field.SetValue(Instance, getDefaultTValue(Field));
      end;

    except
      on E: Exception do
      begin
        FieldPath := Format('%s.%s', [RttiType.Name, Field.Name]);
        raise EJSONException.CreateFmt('Error in field %s : %s', [FieldPath, E.Message]);
      end;
    end;
  end;
end;

class function TJSONGenerics.getDefaultTValue(Field: TRttiField): TValue;
var
  _defaultAttr: DefaultValueAttribute;
begin
  _defaultAttr := Field.GetAttribute<DefaultValueAttribute>;

  if (_defaultAttr <> nil) then
  begin
    case Field.FieldType.TypeKind of
      tkString, tkLString, tkWString, tkUString:
        Result := TValue.From<string>(_defaultAttr.Value);
      tkInteger:
        Result := TValue.From<Integer>(StrToIntDef(_defaultAttr.Value, 0));
      tkEnumeration:
        if Field.FieldType.Handle = TypeInfo(Boolean) then
        begin
          Result := TValue.From<Boolean>(SameText(_defaultAttr.Value, 'true'));
        end;
    end;
  end
  else
  begin
    Result := KLib.Utils.getDefaultTValue(Field.FieldType);
  end;
end;

end.
