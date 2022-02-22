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

unit KLib.MyString;

interface

uses
  KLib.Constants;

type
  myString = type string;

  TMyStringHelper = record helper for myString
    procedure setParamAsDoubleQuotedDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedDateTime(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime;
      formatting: string; caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure setParamAsSingleQuotedDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedDateTime(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime;
      formatting: string; caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure setParamAsDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsDateTime(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure setParamAsDateTimeWithFormatting(paramName: string; value: TDateTime;
      formatting: string; caseSensitive: boolean = false);
    procedure setParamAsFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure doubleQuoted;
    procedure singleQuoted;
  end;

implementation

uses
  KLib.Utils, KLib.Windows,
  System.SysUtils;

procedure TMyStringHelper.setParamAsDoubleQuotedDate(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsDoubleQuotedDateTimeWithFormatting(paramName, value, DATE_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedDateTime(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsDoubleQuotedDateTimeWithFormatting(paramName, value, DATETIME_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime;
  formatting: string; caseSensitive: boolean = false);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeAsStringWithFormatting(value, formatting);
  setParamAsDoubleQuotedString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedFloat(paramName: string; value: Double;
  decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsDoubleQuotedString(paramName, _doubleAsString, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedString(paramName: string; value: string;
  caseSensitive: boolean = false);
var
  _doubleQuotedValue: string;
begin
  _doubleQuotedValue := getDoubleQuotedString(value);
  setParamAsString(paramName, _doubleQuotedValue, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedDate(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsSingleQuotedDateTimeWithFormatting(paramName, value, DATE_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedDateTime(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsSingleQuotedDateTimeWithFormatting(paramName, value, DATETIME_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedDateTimeWithFormatting(paramName: string; value: TDateTime;
  formatting: string; caseSensitive: boolean = false);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeAsStringWithFormatting(value, formatting);
  setParamAsSingleQuotedString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedFloat(paramName: string; value: Double;
  decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsSingleQuotedString(paramName, _doubleAsString, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedString(paramName: string; value: string;
  caseSensitive: boolean = false);
var
  _singleQuotedValue: string;
begin
  _singleQuotedValue := getSingleQuotedString(value);
  setParamAsString(paramName, _singleQuotedValue, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDate(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsDateTimeWithFormatting(paramName, value, DATETIME_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDateTime(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  setParamAsDateTimeWithFormatting(paramName, value, DATETIME_FORMAT, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDateTimeWithFormatting(paramName: string; value: TDateTime;
  formatting: string; caseSensitive: boolean = false);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeAsStringWithFormatting(value, formatting);
  setParamAsString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsFloat(paramName: string; value: Double;
  decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsString(paramName, _doubleAsString, caseSensitive);
end;

procedure TMyStringHelper.setParamAsString(paramName: string; value: string;
  caseSensitive: boolean = false);
var
  _param: string;
begin
  _param := paramName;
  if _param[1] <> ':' then
  begin
    _param := ':' + _param;
  end;

  if caseSensitive then
  begin
    Self := StringReplace(Self, _param, value, [rfReplaceAll]);
  end
  else
  begin
    Self := StringReplace(Self, _param, value, [rfReplaceAll, rfIgnoreCase]);
  end;
end;

procedure TMyStringHelper.doubleQuoted;
begin
  Self := getDoubleQuotedString(Self);
end;

procedure TMyStringHelper.singleQuoted;
begin
  Self := getSingleQuotedString(Self);
end;

end.
