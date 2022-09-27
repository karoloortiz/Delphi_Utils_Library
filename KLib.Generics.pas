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

unit KLib.Generics;

interface

type
  TGenerics = class
  public
    class function getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer; overload;
    class function getElementIndexFromArray<T>(myArray: array of T; element: T): integer; overload;

    class function getDefault<T>: T;
  end;

implementation

uses
  KLib.Generics.Attributes, KLib.Utils, KLib.Constants,
  System.Generics.Collections, System.SysUtils, System.Rtti, System.Variants;

class function TGenerics.getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer;
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

class function TGenerics.getElementIndexFromArray<T>(myArray: array of T; element: T): integer;
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

class function TGenerics.getDefault<T>: T;
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

    if (_propertyType = 'string') or (_propertyType = 'Char') then
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
