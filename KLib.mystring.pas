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

unit KLib.mystring;

interface

uses
  KLib.Constants;

type
  mystring = type string;

  TMyStringHelper = record helper for mystring
    procedure setParamAsDoubleQuotedDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
    procedure setParamAsDoubleQuotedDateTime(paramName: string;
      value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
    procedure setParamAsDoubleQuotedInteger(paramName: string; value: integer; caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsDoubleQuotedString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure setParamAsSingleQuotedDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
    procedure setParamAsSingleQuotedDateTime(paramName: string;
      value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
    procedure setParamAsSingleQuotedInteger(paramName: string; value: integer; caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsSingleQuotedString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure setParamAsDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
    procedure setParamAsDateTime(paramName: string; value: TDateTime;
      caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
    procedure setParamAsInteger(paramName: string; value: integer; caseSensitive: boolean = false);
    procedure setParamAsFloat(paramName: string; value: Double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT; caseSensitive: boolean = false);
    procedure setParamAsString(paramName: string; value: string;
      caseSensitive: boolean = false);

    procedure escapeXML;
    procedure escapeJSON;
    procedure doubleQuote;
    procedure singleQuote;
    procedure quote(quotedCharacter: Char);
    procedure extractString(quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED);
    procedure dequote;
    procedure removeLineBreaks(substituteString: string = SPACE_STRING);
    procedure fixedWordWrap(fixedLen: Integer);
    procedure insertSubString(subString: string; index: integer);

    function getVariantType(destinationTypeAsString: string): Variant;
    function getNumberOfLines: integer;
    function checkIfContainsSubStringNoCaseSensitive(subString: string): boolean;
    function checkIfContainsSubString(subString: string; caseSensitiveSearch: boolean = true): boolean;

    procedure saveToFile(fileName: string);
  end;

implementation

uses
  KLib.Utils, KLib.Windows,
  System.SysUtils;

procedure TMyStringHelper.setParamAsDoubleQuotedDate(paramName: string; value: TDateTime;
  caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
begin
  setParamAsDoubleQuotedDateTime(paramName, value, caseSensitive, formatting);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedDateTime(paramName: string;
  value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeWithFormattingAsString(value, formatting);
  setParamAsDoubleQuotedString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsDoubleQuotedInteger(paramName: string; value: integer; caseSensitive: boolean = false);
var
  _integerAsString: string;
begin
  _integerAsString := IntToStr(value);
  setParamAsDoubleQuotedString(paramName, _integerAsString, caseSensitive);
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
  caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
begin
  setParamAsSingleQuotedDateTime(paramName, value, caseSensitive, formatting);
end;

procedure TMyStringHelper.setParamAsSingleQuotedDateTime(paramName: string;
  value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeWithFormattingAsString(value, formatting);
  setParamAsSingleQuotedString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsSingleQuotedInteger(paramName: string; value: integer; caseSensitive: boolean = false);
var
  _integerAsString: string;
begin
  _integerAsString := IntToStr(value);
  setParamAsSingleQuotedString(paramName, _integerAsString, caseSensitive);
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
  caseSensitive: boolean = false; formatting: string = DATE_FORMAT);
begin
  setParamAsDateTime(paramName, value, caseSensitive, formatting);
end;

procedure TMyStringHelper.setParamAsDateTime(paramName: string; value: TDateTime;
  caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeWithFormattingAsString(value, formatting);
  setParamAsString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TMyStringHelper.setParamAsInteger(paramName: string; value: integer; caseSensitive: boolean = false);
var
  _integerAsString: string;
begin
  _integerAsString := IntToStr(value);
  setParamAsString(paramName, _integerAsString, caseSensitive);
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
    Self := myStringReplace(Self, _param, value, [rfReplaceAll]);
  end
  else
  begin
    Self := myStringReplace(Self, _param, value, [rfReplaceAll, rfIgnoreCase]);
  end;
end;

procedure TMyStringHelper.escapeXML;
begin
  Self := getEscapedXMLString(Self);
end;

procedure TMyStringHelper.escapeJSON;
begin
  Self := getEscapedJSONString(Self);
end;

procedure TMyStringHelper.doubleQuote;
begin
  Self := getDoubleQuotedString(Self);
end;

procedure TMyStringHelper.singleQuote;
begin
  Self := getSingleQuotedString(Self);
end;

procedure TMyStringHelper.quote(quotedCharacter: Char);
begin
  Self := getQuotedString(Self, quotedCharacter);
end;

procedure TMyStringHelper.extractString(quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED);
begin
  Self := getExtractedString(Self, quoteString, isRaiseExceptionEnabled);
end;

procedure TMyStringHelper.dequote;
begin
  Self := getDequotedString(Self);
end;

function TMyStringHelper.getVariantType(destinationTypeAsString: string): Variant;
begin
  Result := stringToVariantType(Self, destinationTypeAsString);
end;

procedure TMyStringHelper.removeLineBreaks(substituteString: string = SPACE_STRING);
begin
  Self := getStringWithoutLineBreaks(Self, substituteString);
end;

procedure TMyStringHelper.fixedWordWrap(fixedLen: Integer);
begin
  Self := stringToStrFixedWordWrap(Self, fixedLen);
end;

procedure TMyStringHelper.insertSubString(subString: string; index: integer);
begin
  Self := getMainStringWithSubStringInserted(Self, subString, index);
end;

function TMyStringHelper.getNumberOfLines: integer;
begin
  Result := getNumberOfLinesInStrFixedWordWrap(Self);
end;

function TMyStringHelper.checkIfContainsSubStringNoCaseSensitive(subString: string): boolean;
begin
  Result := checkIfMainStringContainsSubStringNoCaseSensitive(Self, subString);
end;

function TMyStringHelper.checkIfContainsSubString(subString: string; caseSensitiveSearch: boolean = true): boolean;
begin
  Result := checkIfMainStringContainsSubString(Self, subString, caseSensitiveSearch);
end;

procedure TMyStringHelper.saveToFile(fileName: string);
begin
  KLib.Utils.saveToFile(Self, fileName);
end;

end.
