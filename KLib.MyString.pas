unit KLib.MyString;

interface

uses
  KLib.Constants;

type
  myString = type string;

  TMyStringHelper = record helper for myString
    procedure setParamAsDoubleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime; formatting: string = 'yyyy-mm-dd');
    procedure setParamAsDoubleQuotedFloat(paramName: string; value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT);
    procedure setParamAsDoubleQuotedString(paramName: string; value: string);

    procedure setParamAsDateTimeWithFormatting(paramName: string; value: TDateTime; formatting: string = 'yyyy-mm-dd');
    procedure setParamAsFloat(paramName: string; value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT);
    procedure setParamAsString(paramName: string; value: string);
  end;

implementation

uses
  KLib.Utils, KLib.Windows,
  System.SysUtils;

procedure TMyStringHelper.setParamAsDoubleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime; formatting: string = 'yyyy-mm-dd');
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeAsStringWithFormatting(value, formatting);
  setParamAsDoubleQuotedString(paramName, _dateTimeAsStringWithFormatting);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedFloat(paramName: string; value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsDoubleQuotedString(paramName, _doubleAsString);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedString(paramName: string; value: string);
var
  _doubleQuotedValue: string;
begin
  _doubleQuotedValue := getDoubleQuotedString(value);
  setParamAsString(paramName, _doubleQuotedValue);
end;

procedure TMyStringHelper.setParamAsDateTimeWithFormatting(paramName: string; value: TDateTime; formatting: string = 'yyyy-mm-dd');
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeAsStringWithFormatting(value, formatting);
  setParamAsString(paramName, _dateTimeAsStringWithFormatting);
end;

procedure TMyStringHelper.setParamAsFloat(paramName: string; value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsString(paramName, _doubleAsString);
end;

procedure TMyStringHelper.setParamAsString(paramName: string; value: string);
var
  _param: string;
begin
  _param := paramName;
  if _param[1] <> ':' then
  begin
    _param := ':' + _param;
  end;
  Self := StringReplace(Self, _param, value, [rfReplaceAll]);
end;

end.
