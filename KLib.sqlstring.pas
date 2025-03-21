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

unit KLib.sqlstring;

interface

uses
  KLib.Constants;

type
  sqlstring = type string;

  TSQLStringHelper = record helper for sqlstring
    procedure paramByNameAsDate(paramName: string; value: TDateTime;
      caseSensitive: boolean = false);
    procedure paramByNameAsDateTime(paramName: string;
      value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
    procedure paramByNameAsInteger(paramName: string; value: integer; caseSensitive: boolean = false);
    procedure paramByNameAsFloat(paramName: string; value: Double;
      decimalSeparator: char = MYSQL_DECIMAL_SEPARATOR; caseSensitive: boolean = false);
    procedure paramByNameAsString(paramName: string; value: double;
      decimalSeparator: char = DECIMAL_SEPARATOR_IT); overload;
    procedure paramByNameAsString(paramName: string; value: integer); overload;
    procedure paramByNameAsString(paramName: string; value: string;
      caseSensitive: boolean = false); overload;

    procedure setParamAsDoubleQuotedString(paramName: string; value: string;
      caseSensitive: boolean = false);
    procedure setParamAsString(paramName: string; value: string;
      caseSensitive: boolean = false);
    procedure saveToFile(fileName: string);
  end;

implementation

uses
  Klib.Utils, KLib.mystring,
  System.SysUtils;

procedure TSQLStringHelper.paramByNameAsDate(paramName: string; value: TDateTime;
  caseSensitive: boolean = false);
begin
  paramByNameAsDateTime(paramName, value, caseSensitive, DATE_FORMAT);
end;

procedure TSQLStringHelper.paramByNameAsDateTime(paramName: string;
  value: TDateTime; caseSensitive: boolean = false; formatting: string = DATETIME_FORMAT);
var
  _dateTimeAsStringWithFormatting: string;
begin
  _dateTimeAsStringWithFormatting := getDateTimeWithFormattingAsString(value, formatting);
  setParamAsDoubleQuotedString(paramName, _dateTimeAsStringWithFormatting, caseSensitive);
end;

procedure TSQLStringHelper.paramByNameAsInteger(paramName: string; value: integer; caseSensitive: boolean = false);
var
  _integerAsString: string;
begin
  _integerAsString := IntToStr(value);
  setParamAsString(paramName, _integerAsString, caseSensitive);
end;

procedure TSQLStringHelper.paramByNameAsFloat(paramName: string; value: Double;
  decimalSeparator: char = MYSQL_DECIMAL_SEPARATOR; caseSensitive: boolean = false);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  setParamAsString(paramName, _doubleAsString, caseSensitive);
end;

procedure TSQLStringHelper.paramByNameAsString(paramName: string; value: double;
  decimalSeparator: char = DECIMAL_SEPARATOR_IT);
var
  _doubleAsString: string;
begin
  _doubleAsString := getDoubleAsString(value, decimalSeparator);
  paramByNameAsString(paramName, _doubleAsString);
end;

procedure TSQLStringHelper.paramByNameAsString(paramName: string; value: integer);
var
  _integerAsString: string;
begin
  _integerAsString := IntToStr(value);
  paramByNameAsString(paramName, _integerAsString);
end;

procedure TSQLStringHelper.paramByNameAsString(paramName: string; value: string;
  caseSensitive: boolean = false);
begin
  setParamAsDoubleQuotedString(paramName, value, caseSensitive);
end;

procedure TSQLStringHelper.setParamAsDoubleQuotedString(paramName: string; value: string;
  caseSensitive: boolean = false);
var
  _mystring: mystring;
begin
  _mystring := Self;
  _mystring.setParamAsDoubleQuotedString(paramName, value, caseSensitive);

  Self := _mystring;
end;

procedure TSQLStringHelper.setParamAsString(paramName: string; value: string;
  caseSensitive: boolean = false);
var
  _mystring: mystring;
begin
  _mystring := Self;
  _mystring.setParamAsString(paramName, value, caseSensitive);

  Self := _mystring;
end;

procedure TSQLStringHelper.saveToFile(fileName: string);
var
  _mystring: mystring;
begin
  _mystring := Self;
  _mystring.saveToFile(fileName);
end;

end.
