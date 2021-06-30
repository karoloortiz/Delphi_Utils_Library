{
  KLib Version = 1.0
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
