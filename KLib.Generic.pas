{
  KLib Version = 2.0
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
//  - DefaultValueAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generic, KLib.Generic.Attributes; //always include
//
// type
//  TResponse = record
//  public
//    timestamp: string;
//    sucess: string;
//    [DefaultValueAttribute('yes')]
//    error: string;
//  end;
//
//  ...
//  var
//  _response: TResponse;
//
//  begin
//  ...
//  _responseText := TGeneric.getJSONAsString<TResponse>(_response);
//#####################################
unit KLib.Generic;

interface

uses
  KLib.Constants,
  System.JSON;

type
  TGeneric = class
  public
    class function getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer; overload;
    class function getElementIndexFromArray<T>(myArray: array of T; element: T): integer; overload;

    class function getJSONAsString<T, U, V, Z>(myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
    class function getJSONObject<T, U, V, Z>(myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;

    class function getParsedJSON<T, U, V, Z>(jsonAsString: string): T;

    class function getDefault<T>: T;
  end;

implementation

uses
  KLib.Generic.Attributes, KLib.Utils,
  System.Generics.Collections, System.SysUtils, System.Rtti, System.Variants,
  System.TypInfo;

class function TGeneric.getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer;
var
  _list: TList<T>;
  _element: T;
  elementIndex: integer;
begin
  _list := TList<T>.Create;
  for _element in myArray do
  begin
    _list.Add(_element);
  end;
  elementIndex := _list.IndexOf(element);
  FreeAndNil(_list);

  Result := elementIndex;
end;

class function TGeneric.getElementIndexFromArray<T>(myArray: array of T; element: T): integer;
var
  _list: TList<T>;
  _element: T;

  elementIndex: integer;
begin
  _list := TList<T>.Create;
  for _element in myArray do
  begin
    _list.Add(_element);
  end;
  elementIndex := _list.IndexOf(element);
  FreeAndNil(_list);

  Result := elementIndex;
end;

class function TGeneric.getJSONAsString<T, U, V, Z>(myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
var
  jsonAsString: string;
  _JSONObject: TJSONObject;
begin
  _JSONObject := getJSONObject<T, U, V, Z>(myRecord, ignoreEmptyStrings);
  jsonAsString := _JSONObject.ToString;
  _JSONObject.Free;

  Result := jsonAsString;
end;

class function TGeneric.getJSONObject<T, U, V, Z>(myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
type
  PZ = ^Z;
var
  JSONObject: TJSONObject;
  _record: T;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _propertyValueIsEmpty: boolean;

  _subObject: TJSONObject;
  _T_sub: T;
  _U_sub: U;
  _V_sub: V;
  _newTvalue: TValue;
begin
  JSONObject := TJSONObject.Create();

  _record := TGeneric.getDefault<T>;

  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  for _rttiField in _rttiType.GetFields do
  begin
    _propertyName := _rttiField.Name;
    _propertyType := _rttiField.FieldType.ToString;

    if _rttiField.FieldType.TypeKind = tkDynArray then
    begin
      //todo arrays
    end;

    if (_propertyType = 'string') or (_propertyType = 'Char') then
    begin
      _propertyValue := _rttiField.GetValue(@myRecord).AsString;
      _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
      if _propertyValueIsEmpty then
      begin
        _propertyValue := _rttiField.GetValue(@_record).AsString;
      end;

      if not ignoreEmptyStrings then
      begin
        JSONObject.AddPair(TJSONPair.Create(_propertyName, _propertyValue));
      end
      else
      begin
        JSONObject.AddPair(_propertyName, _propertyValue);
      end;
    end
    else if (_propertyType = 'Integer') or (_propertyType = 'Word') then
    begin
      _propertyValue := _rttiField.GetValue(@myRecord).AsInteger;
      _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
      if _propertyValueIsEmpty then
      begin
        _propertyValue := _rttiField.GetValue(@_record).AsInteger;
      end;

      JSONObject.AddPair(_propertyName, TJSONNumber.Create(_propertyValue));
    end
    else if _propertyType = 'Double' then
    begin
      _propertyValue := _rttiField.GetValue(@myRecord).AsExtended;
      _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
      if _propertyValueIsEmpty then
      begin
        _propertyValue := _rttiField.GetValue(@_record).AsExtended;
      end;

      JSONObject.AddPair(_propertyName, TJSONNumber.Create(_propertyValue));
    end
    else if _propertyType = 'Boolean' then
    begin
      _propertyValue := _rttiField.GetValue(@myRecord).AsBoolean;
      _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
      if _propertyValueIsEmpty then
      begin
        _propertyValue := _rttiField.GetValue(@_record).AsBoolean;
      end;

      JSONObject.AddPair(_propertyName, TJSONBool.Create(_propertyValue));
    end
    else
    begin
      try
        //        _subObject := _JSONMain.GetValue<TJSONObject>(_propertyName);

        //        if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
        //        begin
        //          _T_sub := TGeneric.getParsedJSON<T, U, V, Z>(_subObject.ToString);
        //          TValue.Make(@_T_sub, TypeInfo(T), _newTvalue);
        //          _rttiField.SetValue(@_record, _newTvalue);
        //        end

        if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
        begin
          _T_sub := _rttiField.GetValue(@myRecord).AsType<T>;
          _subObject := TGeneric.getJSONObject<T, U, V, Z>(_T_sub, NOT_IGNORE_EMPTY_STRINGS);
          JSONObject.AddPair(_propertyName, _subObject);
        end
        else if _propertyType = _rttiContext.GetType(TypeInfo(U)).ToString then
        begin
          _U_sub := _rttiField.GetValue(@myRecord).AsType<U>;
          _subObject := TGeneric.getJSONObject<U, V, T, Z>(_U_sub, NOT_IGNORE_EMPTY_STRINGS);
          JSONObject.AddPair(_propertyName, _subObject);
        end
        else if _propertyType = _rttiContext.GetType(TypeInfo(V)).ToString then
        begin
          _V_sub := _rttiField.GetValue(@myRecord).AsType<V>;
          _subObject := TGeneric.getJSONObject<V, T, U, Z>(_V_sub, NOT_IGNORE_EMPTY_STRINGS);
          JSONObject.AddPair(_propertyName, _subObject);
        end;
      except
        on E: Exception do
        begin
          //          _string := _string; //for debug
        end;
      end;
    end;

  end;

  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;

  Result := JSONObject;
end;

class function TGeneric.getParsedJSON<T, U, V, Z>(jsonAsString: string): T;
var
  _record: T;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _JSONFile: TBytes;
  _JSONMain: TJSONValue;
  _string: string;
  _integer: integer;
  _double: double;
  _boolean: boolean;

  _subObject: TJSONObject;
  _T_sub: T;
  _U_sub: U;
  _V_sub: V;
  _newTvalue: TValue;

  _Z_val: Z;
  L: integer;
  _rttiType2: TRttiType;
  _rttiField2: TRttiField;

begin
  _record := TGeneric.getDefault<T>;

  _JSONFile := TEncoding.ASCII.GetBytes(jsonAsString);
  _JSONMain := TJSONObject.ParseJSONValue(_JSONFile, 0);

  _rttiContext := TRttiContext.Create;
  try
    if Assigned(_JSONMain) then
    begin
      _rttiType := _rttiContext.GetType(TypeInfo(T));

      for _rttiField in _rttiType.GetFields do
      begin
        _propertyName := _rttiField.Name;
        _propertyType := _rttiField.FieldType.ToString;

        //        if _rttiField.FieldType.TypeKind = tkDynArray then
        //        begin
        //          //####################TODO######################S
        //          L := 2;
        //          //                                 @_record
        //          DynArraySetLength(PPointer(@_record)^, TypeInfo(Z), 1, @L);
        //
        //          _rttiType2 := _rttiContext.GetType(TypeInfo(V));
        //          for _rttiField2 in _rttiType2.GetFields do
        //          begin
        //            _propertyName := _rttiField2.Name;
        //            _propertyType := _rttiField2.FieldType.ToString;
        //          end;
        //          _propertyValue := 1578;
        //          _rttiType2.GetFields[0].SetValue(@_V_sub, TValue.FromVariant(_propertyValue));
        //          _propertyValue := '1578mystring';
        //          _rttiType2.GetFields[1].SetValue(@_V_sub, TValue.FromVariant(_propertyValue));
        //          TValue.Make(@_V_sub, TypeInfo(V), _newTvalue);
        //
        //          //todo
        //          add to _Z_val
        //
        //            DynArraySetLength(PPointer(@_Z_val)^, TypeInfo(Z), 1, @L);
        //          PPointer(@_Z_val)^[0];
        //          _rttiField.SetValue(PPointer(@_record, _newTvalue);
        //          end;

        VarClear(_propertyValue);

        //    _customAttributes := _rttiField.GetAttributes;
        //    for _customAttribute in _customAttributes do
        //    begin
        //
        //    end;

        if (_propertyType = 'string') or (_propertyType = 'Char') then
        begin
          if _JSONMain.TryGetValue(_propertyName, _string) then
          begin
            _propertyValue := _string;
          end;
        end
        else if (_propertyType = 'Integer') or (_propertyType = 'Word') then
        begin
          if _JSONMain.TryGetValue(_propertyName, _integer) then
          begin
            _propertyValue := _integer;
          end;
        end
        else if _propertyType = 'Double' then
        begin
          if _JSONMain.TryGetValue(_propertyName, _double) then
          begin
            _propertyValue := _double;
          end;
        end
        else if _propertyType = 'Boolean' then
        begin
          if _JSONMain.TryGetValue(_propertyName, _boolean) then
          begin
            _propertyValue := _boolean;
          end;
        end
        else
        begin
          try
            _subObject := _JSONMain.GetValue<TJSONObject>(_propertyName);

            if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
            begin
              _T_sub := TGeneric.getParsedJSON<T, U, V, Z>(_subObject.ToString);
              TValue.Make(@_T_sub, TypeInfo(T), _newTvalue);
              _rttiField.SetValue(@_record, _newTvalue);
            end
            else if _propertyType = _rttiContext.GetType(TypeInfo(U)).ToString then
            begin
              _U_sub := TGeneric.getParsedJSON<U, V, T, Z>(_subObject.ToString);
              TValue.Make(@_U_sub, TypeInfo(U), _newTvalue);
              _rttiField.SetValue(@_record, _newTvalue);
            end
            else if _propertyType = _rttiContext.GetType(TypeInfo(V)).ToString then
            begin
              _V_sub := TGeneric.getParsedJSON<V, U, T, Z>(_subObject.ToString);
              TValue.Make(@_V_sub, TypeInfo(V), _newTvalue);
              _rttiField.SetValue(@_record, _newTvalue);
            end;
          except
            on E: Exception do
            begin
              _string := _string; //for debug
            end;
          end;
        end;

        if (not VarIsEmpty(_propertyValue)) then
        begin
          _rttiField.SetValue(@_record, TValue.FromVariant(_propertyValue));
        end;
      end;
    end;

    //  except
    //    { ... Do something here ... }
    //  end;

  finally
    begin
      _rttiContext.Free;
      FreeAndNil(_JSONMain);
    end;
  end;

  Result := _record;
end;

class
  function TGeneric.getDefault<T>: T;
var
  _record: T;

  _defaultValueAttribute: string;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;
begin
  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  //  try
  for _rttiField in _rttiType.GetFields do
  begin
    _propertyName := _rttiField.Name;
    _propertyType := _rttiField.FieldType.ToString;

    VarClear(_propertyValue);
    _defaultValueAttribute := EMPTY_STRING;

    _customAttributes := _rttiField.GetAttributes;
    for _customAttribute in _customAttributes do
    begin
      if _customAttribute is DefaultValueAttribute then
      begin
        _defaultValueAttribute := DefaultValueAttribute(_customAttribute).value;
      end;
    end;

    if _defaultValueAttribute <> EMPTY_STRING then
    begin
      _propertyValue := stringToVariantType(_defaultValueAttribute, _propertyType);
    end
    else
    begin
      _propertyValue := myDefault(_propertyType);
    end;

    if _propertyType = 'string' then
    begin
      // already a string
    end
    else if _propertyType = 'Integer' then
    begin
      _propertyValue := StrToInt(_propertyValue);
    end
    else if _propertyType = 'Double' then
    begin
      _propertyValue := StrToFloat(_propertyValue);
    end
    else if _propertyType = 'Char' then
    begin
      // already a string
    end
    else if _propertyType = 'Boolean' then
    begin
      _propertyValue := StrToBool(_propertyValue);
    end;

    if (not VarIsEmpty(_propertyValue)) then
    begin
      _rttiField.SetValue(@_record, TValue.FromVariant(_propertyValue));
    end;
  end;

  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;

  Result := _record;
end;

end.
