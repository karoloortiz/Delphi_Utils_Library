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

//  ATTRIBUTES:
//  - FileNameAttribute
//  - SettingStringsAttribute
//  - SettingDoubleAttribute      //TODO
//  - SectionNameAttribute
//
//  - CustomNameAttribute
//  - BooleanAsStringAttribute
//  - DefaultValueAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generics.Ini, KLib.Generics.Attributes; //always include
//
// type
//  [
//    FileNameAttribute('settings.ini'),
//    SettingStringsAttribute(double_quotted)
//    ]
//  TSettingsIni = record
//  public
//    [SectionNameAttribute('section_1')]
//    [DefaultValueAttribute('log.txt')]
//    string_value: string;
//    integer_value: integer;
//    double_value: double;
//    boolean_value: boolean;
//    char_value: char;
//    [SectionNameAttribute('section_1')]
//    string_value2: string;
//    integer_value2: integer;
//    double_value2: double;
//    [
//     CustomNameAttribute('my_custom_name'),
//     BooleanAsStringAttribute('yes', 'no'),
//     DefaultValueAttribute('true')
//    ]
//    boolean_value2: boolean;
//    char_value2: char;
//  end;
//
// implementation
//
// var
//  settings:TSettingsIni;
//
// begin
//
//  with settings do
//  begin
//  ...
//  end;
//
//  TIniGenerics.saveTofile<TSettingsIni>(settings);
//  settings:= TIniGenerics.tryGetFromFile<TSettingsIni>();
//#####################################
unit KLib.Generics.Ini;

interface

uses
  KLib.Constants, KLib.Types;

type
  TIniGenerics = class
  public
    class procedure saveToFile<T>(iniRecord: T; fileName: string = EMPTY_STRING; sectionName: string = 'default_section');
    class function tryGetFromFile<T>(fileName: string = EMPTY_STRING; sectionName: string = 'default_section'): T;
    class function getFromFile<T>(fileName: string = EMPTY_STRING; sectionName: string = 'default_section';
      isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION): T;
  end;

  TTempJsonRecord = record
    _arrayOfStrings: TArrayOfStrings;
  end;

implementation

uses
  KLib.Generics.Attributes, KLib.Generics, KLib.Generics.JSON,
  KLib.IniFiles, KLib.Windows, KLib.Utils, KLib.Validate,
  System.Rtti, System.SysUtils, System.Variants;

class procedure TIniGenerics.saveToFile<T>(iniRecord: T; fileName: string = EMPTY_STRING; sectionName: string = 'default_section');
var
  _fileName: string;
  _settingStringsAttribute: TSettingStringsAttributeType;
  _sectionName: string;
  _customName: string;
  _booleanAsString: boolean;
  _booleanAsStringAttribute: TCustomAttribute;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;
begin
  _fileName := fileName;
  _settingStringsAttribute := _null;
  _sectionName := sectionName;

  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  //  try
  for _customAttribute in _rttiType.GetAttributes() do
  begin
    if (_customAttribute is FileNameAttribute) and (_fileName = EMPTY_STRING) then
    begin
      _fileName := FileNameAttribute(_customAttribute).value;
    end;

    if _customAttribute is SettingStringsAttribute then
    begin
      _settingStringsAttribute := SettingStringsAttribute(_customAttribute).value;
    end;
  end;

  createEmptyFileIfNotExists(_fileName);

  for _rttiField in _rttiType.GetFields do
  begin
    _propertyName := _rttiField.Name;
    _propertyType := _rttiField.FieldType.ToString;

    VarClear(_propertyValue);

    _customName := EMPTY_STRING;
    _booleanAsString := false;
    for _customAttribute in _rttiField.GetAttributes do
    begin
      if _customAttribute is SectionNameAttribute then
      begin
        _sectionName := SectionNameAttribute(_customAttribute).value;
      end;
      if _customAttribute is CustomNameAttribute then
      begin
        _customName := CustomNameAttribute(_customAttribute).value;
      end;
      if _customAttribute is BooleanAsStringAttribute then
      begin
        _booleanAsString := true;
        _booleanAsStringAttribute := _customAttribute;
      end;
    end;

    if (_propertyType = 'string') or (_propertyType = 'Char') then
    begin
      _propertyValue := _rttiField.GetValue(@iniRecord).AsString;

      case _settingStringsAttribute of
        _null:
          ;
        single_quotted:
          begin
            _propertyValue := getSingleQuotedString(_propertyValue);
          end;
        double_quotted:
          begin
            _propertyValue := getDoubleQuotedString(_propertyValue);
          end;
      end;
    end
    else if _propertyType = 'Integer' then
    begin
      _propertyValue := _rttiField.GetValue(@iniRecord).AsInteger;
    end
    else if _propertyType = 'Double' then
    begin
      _propertyValue := _rttiField.GetValue(@iniRecord).AsExtended;
    end
    else if _propertyType = 'Boolean' then
    begin
      _propertyValue := _rttiField.GetValue(@iniRecord).AsBoolean;
      if _booleanAsString then
      begin
        if _propertyValue = true then
        begin
          _propertyValue := BooleanAsStringAttribute(_booleanAsStringAttribute).true;
        end
        else
        begin
          _propertyValue := BooleanAsStringAttribute(_booleanAsStringAttribute).false;
        end;
      end;
    end;

    if _customName <> EMPTY_STRING then
    begin
      _propertyName := _customName;
    end;

    setStringValueToIniFile(_fileName, _sectionName, _propertyName, _propertyValue);

  end;
  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;
end;

class function TIniGenerics.tryGetFromFile<T>(fileName: string = EMPTY_STRING; sectionName: string = 'default_section'): T;
begin
  Result := getFromFile<T>(fileName, sectionName, RAISE_EXCEPTION_DISABLED);
end;

class function TIniGenerics.getFromFile<T>(fileName: string = EMPTY_STRING; sectionName: string = 'default_section';
  isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION): T;
var
  _record: T;

  _fileName: string;
  _settingStringsAttribute: TSettingStringsAttributeType;
  _fileExists: boolean;
  _sectionName: string;
  _customName: string;
  _booleanAsString: boolean;
  _booleanAsStringAttribute: TCustomAttribute;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _tempJSONRecord: TTempJsonRecord;

  _newTValue: TValue;
begin
  _record := TGenerics.getDefault<T>;

  _fileName := fileName;
  _settingStringsAttribute := _null;
  _sectionName := sectionName;

  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  //  try
  for _customAttribute in _rttiType.GetAttributes() do
  begin
    if (_customAttribute is FileNameAttribute) and (_fileName = EMPTY_STRING) then
    begin
      _fileName := FileNameAttribute(_customAttribute).value;
    end;

    if (_customAttribute is SettingStringsAttribute) then
    begin
      _settingStringsAttribute := SettingStringsAttribute(_customAttribute).value;
    end;
  end;

  _fileExists := checkIfFileExists(_fileName);

  if (_fileExists) then
  begin
    for _rttiField in _rttiType.GetFields do
    begin
      _propertyName := _rttiField.Name;
      _propertyType := _rttiField.FieldType.ToString;

      VarClear(_propertyValue);

      _customName := EMPTY_STRING;
      _booleanAsString := false;
      for _customAttribute in _rttiField.GetAttributes do
      begin
        if _customAttribute is SectionNameAttribute then
        begin
          _sectionName := SectionNameAttribute(_customAttribute).value;
        end;
        if _customAttribute is CustomNameAttribute then
        begin
          _customName := CustomNameAttribute(_customAttribute).value;
        end;
        if _customAttribute is BooleanAsStringAttribute then
        begin
          _booleanAsString := true;
          _booleanAsStringAttribute := _customAttribute;
        end;
      end;

      if _customName <> EMPTY_STRING then
      begin
        _propertyName := _customName;
      end;

      try
        _propertyValue := getStringValueFromIniFile(_fileName, _sectionName, _propertyName);

        if (_propertyType = 'string') or (_propertyType = 'Char') then
        begin
          case _settingStringsAttribute of
            _null:
              ;
            single_quotted:
              begin
                _propertyValue := getSingleQuoteExtractedString(_propertyValue);
              end;
            double_quotted:
              begin
                _propertyValue := getDoubleQuoteExtractedString(_propertyValue);
              end;
          end;
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
          if _booleanAsString then
          begin
            if _propertyValue = BooleanAsStringAttribute(_booleanAsStringAttribute).true then
            begin
              _propertyValue := true;
            end
            else if _propertyValue = BooleanAsStringAttribute(_booleanAsStringAttribute).false then
            begin
              _propertyValue := false;
            end
            else if isRaiseExceptionEnabled then
            begin
              raise Exception.Create('Incorrect value -> filename: ' + _fileName + ' section name: ' + _sectionName +
                ' property name: ' + _propertyName + ' property value: ' + _propertyValue);
            end
            else
            begin
              _propertyValue := false;
            end;

          end
          else
          begin
            _propertyValue := StrToBool(_propertyValue);
          end;
        end;

        if ((not VarIsEmpty(_propertyValue)) and
          (_rttiField.FieldType.TypeKind <> tkDynArray)) then
        begin
          _rttiField.SetValue(@_record, TValue.FromVariant(_propertyValue));
        end;

        if (_rttiField.FieldType.TypeKind = tkDynArray) then
        begin
          _tempJSONRecord := TJSONGenerics.getParsedJSON<TTempJsonRecord>(
            '{"_arrayOfStrings":' + _propertyValue + '}');

          TValue.Make(@_tempJSONRecord._arrayOfStrings, TypeInfo(TArrayOfStrings),
            _newTValue);
          _rttiField.SetValue(@_record, _newTValue);
        end;
      except
        on E: Exception do
      end;
    end;
  end;
  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;

  if (isRaiseExceptionEnabled) and (not _fileExists) then
  begin
    validateThatFileExists(_fileName);
  end;

  Result := _record;
end;

end.
