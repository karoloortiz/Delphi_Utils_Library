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

//  ATTRIBUTES:
//  - SettingStringsAttribute
//  - ParamNameAttribute
//  - DefaultValueAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generic.Attributes; //always include
//
//type
//
//  [SettingStringsAttribute(_double_quotted)]
//  TApplicationShellParams = record
//  public
//    [
//      ParamNameAttribute(INSTALL_PARAMETER_NAME),
//      DefaultValueAttribute('false')
//      ]
//    install: boolean;
//
//    [
//      ParamNameAttribute(UNINSTALL_PARAMETER_NAME),
//      DefaultValueAttribute('false')
//      ]
//    uninstall: boolean;
//
//    [
//      ParamNameAttribute(INSTALL_PARAMETER_NAME),
//      ParamNameAttribute(UNINSTALL_PARAMETER_NAME),
//      DefaultValueAttribute(SERVICE_NAME)
//      ]
//    serviceName: string;
//
//    [
//      ParamNameAttribute(SILENT_PARAMETER_NAME),
//      DefaultValueAttribute('false')
//      ]
//    silent: boolean;
//
//    [
//      ParamNameAttribute(HELP_PARAMETER_NAME),
//      ParamNameAttribute(HELP_PARAMETER_SHORT_NAME),
//      DefaultValueAttribute('false')
//      ]
//    help: boolean;
//  end;
//
//var
//  ApplicationShellParams: TApplicationShellParams;
//
//implementation
//
//initialization
//
//  ApplicationShellParams := TShellParamsGeneric.get<TApplicationShellParams>();
//
//#####################################
unit KLib.Generic.ShellParams;

//        --defaults-file
interface

uses
  KLib.Generic.Attributes, KLib.Constants, KLib.Types;

type
  TShellParamsGeneric = class
  public
    class function get<T>: T;
  end;

implementation

uses
  KLib.Utils, KLib.Windows,
  Rtti,
  System.SysUtils;

class function TShellParamsGeneric.get<T>: T;
var
  _record: T;

  _settingStringsAttribute: TSettingStringsAttributeType;

  _paramNameAttribute: string;
  _defaultValueAttribute: string;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _parameterExists: boolean;
  _paramNames: TArrayOfStrings;
  _valuesExcluded: TArrayOfStrings;
begin
  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  //  try
  for _customAttribute in _rttiType.GetAttributes() do
  begin
    if _customAttribute is SettingStringsAttribute then
    begin
      _settingStringsAttribute := SettingStringsAttribute(_customAttribute).value;
    end;
  end;

  _valuesExcluded := [];
  for _rttiField in _rttiType.GetFields do
  begin
    _customAttributes := _rttiField.GetAttributes;
    for _customAttribute in _customAttributes do
    begin
      if _customAttribute is ParamNameAttribute then
      begin
        _paramNameAttribute := ParamNameAttribute(_customAttribute).value;
        _valuesExcluded := _valuesExcluded + [_paramNameAttribute];
      end;
    end;
  end;

  for _rttiField in _rttiType.GetFields do
  begin
    _paramNames := [];
    _defaultValueAttribute := EMPTY_STRING;

    _customAttributes := _rttiField.GetAttributes;
    for _customAttribute in _customAttributes do
    begin
      if _customAttribute is ParamNameAttribute then
      begin
        _paramNameAttribute := ParamNameAttribute(_customAttribute).value;
        _paramNames := _paramNames + [_paramNameAttribute];
      end;

      if _customAttribute is DefaultValueAttribute then
      begin
        _defaultValueAttribute := DefaultValueAttribute(_customAttribute).value;
      end;
    end;

    _propertyName := _rttiField.Name;
    _propertyType := _rttiField.FieldType.ToString;
    if _defaultValueAttribute <> EMPTY_STRING then
    begin
      _propertyValue := stringToVariantType(_defaultValueAttribute, _propertyType);
    end
    else
    begin
      _propertyValue := myDefault(_propertyType);
    end;

    _parameterExists := checkIfParameterExists(_paramNames);
    if _parameterExists then
    begin
      _propertyValue := getValueOfParameter(_paramNames, _valuesExcluded);

      if _propertyType = 'string' then
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
      else if _propertyType = 'Char' then
      begin
        //
      end
      else if _propertyType = 'Boolean' then
      begin
        _propertyValue := true;
      end;
    end;

    _rttiField.SetValue(@_record, TValue.FromVariant(_propertyValue));
  end;

  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;

  Result := _record;
end;

end.
