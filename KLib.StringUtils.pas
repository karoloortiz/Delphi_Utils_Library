{
  KLib Version = 4.0
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

unit KLib.StringUtils;

interface

uses
  KLib.Constants, KLib.Types,
  System.SysUtils, System.Classes;

function encryptString(value: string; key: string): string;
function decryptString(value: string; key: string): string;

function getStatusAsString(status: TStatus): string;

function getValidItalianTelephoneNumber(number: string): string;
function getValidTelephoneNumber(number: string): string;

function getRandString(size: integer = 5): string;

function getZPLWithTextInsertedAtEOF(zpl: string; extraText: string): string;
function getEscapedMySQLString(mainString: string): string;
function getHTTPGetEncodedUrl(url: string; paramList: TStringList): string;
function getEscapedHTMLString(mainString: string): string;
function getEscapedXMLString(mainString: string): string;
function getEscapedJSONString(mainString: string): string;
function getDoubleQuotedString(mainString: string): string;
function getSingleQuotedString(mainString: string): string;
function getQuotedString(mainString: string; quoteCharacter: Char): string;
function getDoubleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getSingleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getExtractedString(mainString: string; quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
function getDequotedString(mainString: string): string;
function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer;
  forceOverwriteIndexCharacter: boolean = NOT_FORCE_OVERWRITE): string;
function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_STRING): string;
function getStringWithFixedLength(value: string; fixedLength: integer): string;
function getStringFromStream(stream: TStream): string;

function getNumberOfLinesInStrFixedWordWrap(source: string): integer;
function stringToStrFixedWordWrap(source: string; fixedLen: Integer): string;
function stringToStringListWithFixedLen(source: string; fixedLen: Integer): TStringList;
function stringToStringListWithDelimiter(value: string; delimiter: Char): TStringList;
function stringToTStringList(source: string): TStringList;
function stringToVariantType(stringValue: string; destinationTypeAsString: string): Variant;

function arrayOfStringToTStringList(arrayOfStrings: array of string): TStringList;
function arrayOfVariantToTStringList(arrayOfVariant: Variant): TStringList;

function splitStringsAsTArrayStrings(source: string; chunkSize: Integer): TArray<string>;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string); overload;
procedure splitStrings(source: string; splitIndex: integer; var destFirstString: string; var destSecondString: string); overload;
procedure splitStrings(source: string; delimiterPosition: integer; delimiterLength: integer; var destFirstString: string; var destSecondString: string); overload;
function getMergedStrings(firstString: string; secondString: string; delimiter: string = EMPTY_STRING): string;

function checkIfEmailIsValid(email: string): boolean;
function checkIfRegexIsValid(text: string; regex: string): boolean;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): boolean;

function myStringReplace(mainString: string; OldPattern: array of string; NewPattern: array of string; Flags: TReplaceFlags): string; overload;
function myStringReplace(const SourceString, OldPattern, NewPattern: string; Flags: TReplaceFlags): string; overload;

function myAnsiPos(subString: string; mainString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): integer;

function getDoubleAsString(value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT): string;
function getFloatToStrDecimalSeparator: char;

implementation

uses
  System.StrUtils, System.Character, System.RegularExpressions,
  System.Variants, System.NetEncoding, System.Hash,
  KLib.Validate;

function encryptString(value: string; key: string): string;
var
  _hashedKey: string;
  _xorBytes: TBytes;
  _i: Integer;
begin
  _hashedKey := THashSHA2.GetHashString(key);
  _xorBytes := TEncoding.UTF8.GetBytes(value);
  for _i := 0 to Length(_xorBytes) - 1 do
  begin
    _xorBytes[_i] := _xorBytes[_i] xor Byte(_hashedKey[(_i mod Length(_hashedKey)) + 1]);
  end;
  Result := TNetEncoding.Base64.EncodeBytesToString(_xorBytes);
end;

function decryptString(value: string; key: string): string;
var
  _hashedKey: string;
  _xorBytes: TBytes;
  _i: Integer;
begin
  _hashedKey := THashSHA2.GetHashString(key);
  _xorBytes := TNetEncoding.Base64.DecodeStringToBytes(value);
  for _i := 0 to Length(_xorBytes) - 1 do
  begin
    _xorBytes[_i] := _xorBytes[_i] xor Byte(_hashedKey[(_i mod Length(_hashedKey)) + 1]);
  end;
  Result := TEncoding.UTF8.GetString(_xorBytes);
end;

function getStatusAsString(status: TStatus): string;
var
  status_asString: string;
begin
  case status of
    TStatus._null:
      status_asString := '_null';
    TStatus.created:
      status_asString := 'created';
    TStatus.stopped:
      status_asString := 'stopped';
    TStatus.paused:
      status_asString := 'paused';
    TStatus.running:
      status_asString := 'running';
  end;

  Result := status_asString;
end;

function getValidItalianTelephoneNumber(number: string): string;
var
  telephoneNumber: string;

  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  if _number = '' then
  begin
    telephoneNumber := '';
  end
  else
  begin
    if _number.StartsWith('0039') then
    begin
      _number := KLib.StringUtils.myStringReplace(_number, '0039', '+39', []);
    end;

    if not _number.StartsWith('+') then
    begin
      _number := '+39' + _number;
    end;

    if not _number.StartsWith('+39') then
    begin
      _number := myStringReplace(_number, '+', '+39', []);
    end;

    telephoneNumber := '+';
    for i := 2 to length(_number) do
    begin
      if _number[i].IsNumber then
      begin
        telephoneNumber := telephoneNumber + _number[i];
      end;
    end;
  end;

  Result := telephoneNumber;
end;

function getValidTelephoneNumber(number: string): string;
const
  ERR_MSG = 'Telephone number is empty.';
var
  telephoneNumber: string;

  _number: string;
  i: integer;
begin
  telephoneNumber := '';
  _number := trim(number);

  validateThatStringIsNotEmpty(_number, ERR_MSG);

  if _number[1] = '+' then
  begin
    telephoneNumber := '+';
  end;
  for i := 2 to length(_number) do
  begin
    if _number[i].IsNumber then
    begin
      telephoneNumber := telephoneNumber + _number[i];
    end;
  end;

  Result := telephoneNumber;
end;

function getRandString(size: integer = 5): string;
const
  ALPHABET: array [1 .. 62] of char = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
var
  randString: string;

  _randCharacter: char;
  _randIndexOfAlphabet: integer;
  _lengthAlphabet: integer;
  i: integer;
begin
  randString := '';
  _lengthAlphabet := length(ALPHABET);
  for i := 1 to size do
  begin
    _randIndexOfAlphabet := random(_lengthAlphabet) + 1;
    _randCharacter := ALPHABET[_randIndexOfAlphabet];
    randString := randString + _randCharacter;
  end;

  Result := randString;
end;

function getZPLWithTextInsertedAtEOF(zpl: string; extraText: string): string;
var
  _zpl: string;
  _indexLastPositionZPL: integer;
begin
  _indexLastPositionZPL := AnsiPos(END_ZPL_CMD, zpl) - 1;
  _ZPL := getMainStringWithSubStringInserted(zpl,
    extraText, _indexLastPositionZPL);

  Result := _zpl;
end;

function getEscapedMySQLString(mainString: string): string;
begin
  Result := myStringReplace(mainString,
    ['\', #39, #34, #0, #10, #13, #26],
    ['\\', '\'#39, '\'#34, '\0', '\n', '\r', '\Z'],
    [rfReplaceAll]);
end;

function getHTTPGetEncodedUrl(url: string; paramList: TStringList): string;
var
  _param: string;
  _encodedUrl: string;
begin
  _encodedUrl := url + '?';
  for _param in paramList do
  begin
    _encodedUrl := _encodedUrl + '&' + _param;
  end;
  _encodedUrl := myStringReplace(_encodedUrl, '?&', '?', [rfReplaceAll]);

  Result := _encodedUrl;
end;

function getEscapedHTMLString(mainString: string): string;
begin
  Result := TNetEncoding.URL.Encode(mainString);
end;

function getEscapedXMLString(mainString: string): string;
begin
  Result := myStringReplace(mainString,
    ['&', '"', '''', '<', '>'],
    ['&amp;', '&quot;', '&#39;', '&lt;', '&gt;'],
    [rfreplaceall]);
end;

function getEscapedJSONString(mainString: string): string;

  procedure addChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 2, 1);
    Inc(AIndex, 2);
  end;

  procedure addUnicodeChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 6, 1);
    Inc(AIndex, 6);
  end;

var
  i, ix: Integer;
  AChar: Char;
begin
  Result := mainString;
  ix := 1;
  for i := 1 to System.Length(mainString) do
  begin
    AChar := mainString[i];
    case AChar of
      '/', '\', '"':
        begin
          System.Insert('\', Result, ix);
          Inc(ix, 2);
        end;
      #8: //backspace \b
        begin
          addChars('\b', Result, ix);
        end;
      #9:
        begin
          addChars('\t', Result, ix);
        end;
      #10:
        begin
          addChars('\n', Result, ix);
        end;
      #12:
        begin
          addChars('\f', Result, ix);
        end;
      #13:
        begin
          addChars('\r', Result, ix);
        end;
      #0 .. #7, #11, #14 .. #31:
        begin
          addUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
    else
      begin
        if Word(AChar) > 127 then
        begin
          addUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
        else
        begin
          Inc(ix);
        end;
      end;
    end;
  end;
end;

function getDoubleQuotedString(mainString: string): string;
begin
  Result := getQuotedString(mainString, '"');
end;

function getSingleQuotedString(mainString: string): string;
begin
  Result := getQuotedString(mainString, '''');
end;

function getQuotedString(mainString: string; quoteCharacter: Char): string;
begin
  Result := AnsiQuotedStr(mainString, quoteCharacter);
end;

function getDoubleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
begin
  Result := getExtractedString(mainString, '"', isRaiseExceptionEnabled);
end;

function getSingleQuoteExtractedString(mainString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
begin
  Result := getExtractedString(mainString, '''', isRaiseExceptionEnabled);
end;

function getExtractedString(mainString: string; quoteString: string; isRaiseExceptionEnabled: boolean = RAISE_EXCEPTION_DISABLED): string;
const
  ERR_MSG = 'String not found.';
var
  extractedString: string;

  _lengthQuotedString: integer;
  _lengthMainString: integer;
  _firstIndex: integer;
  _lastIndex: integer;
begin
  extractedString := EMPTY_STRING;

  _lengthQuotedString := quoteString.Length;
  _firstIndex := mainString.IndexOf(quoteString);
  if _firstIndex > -1 then
  begin
    _firstIndex := _firstIndex + _lengthQuotedString;

    _lengthMainString := Length(mainString);
    _lastIndex := mainString.LastIndexOf(quoteString, _lengthMainString, _lengthMainString - _firstIndex); //IGNORE FIRST OCCURENCE
    if _lastIndex > -1 then
    begin
      _lastIndex := _lastIndex - _lengthQuotedString;
      extractedString := mainString.Substring(_lengthQuotedString, _lastIndex);
    end;
  end;

  if (isRaiseExceptionEnabled) and (extractedString = EMPTY_STRING) then
  begin
    raise Exception.Create(ERR_MSG);
  end;

  Result := extractedString;
end;

function getDequotedString(mainString: string): string;
var
  dequotedString: string;
begin
  dequotedString := mainString;
  if ((mainString.Chars[0] = '"') and (mainString.Chars[dequotedString.Length - 1] = '"'))
    or ((mainString.Chars[0] = '''') and (mainString.Chars[dequotedString.Length - 1] = '''')) then
  begin
    dequotedString := mainString.Substring(1, mainString.Length - 2);
  end;

  Result := dequotedString;
end;

function getMainStringWithSubStringInserted(mainString: string; insertedString: string; index: integer;
  forceOverwriteIndexCharacter: boolean = NOT_FORCE_OVERWRITE): string;
const
  ERR_MSG = 'Index out of range.';
var
  mainStringWithSubStringInserted: string;

  _length: integer;
  _firstStringPart: string;
  _lastStringPart: string;
begin
  _length := Length(mainString);
  if (index > _length) or (index < 0) then
  begin
    raise Exception.Create(ERR_MSG);
  end;
  _firstStringPart := getStringWithFixedLength(mainString, index);
  if forceOverwriteIndexCharacter then
  begin
    Inc(index);
  end;
  _lastStringPart := Copy(mainString, index + 1, MaxInt);
  mainStringWithSubStringInserted := getMergedStrings(_firstStringPart, _lastStringPart, insertedString);

  Result := mainStringWithSubStringInserted;
end;

function getStringWithoutLineBreaks(mainString: string; substituteString: string = SPACE_STRING): string;
var
  stringWithoutLineBreaks: string;
begin
  stringWithoutLineBreaks := KLib.StringUtils.myStringReplace(mainString, #13#10, substituteString, [rfReplaceAll]);
  stringWithoutLineBreaks := myStringReplace(stringWithoutLineBreaks, #10, substituteString, [rfReplaceAll]);

  Result := stringWithoutLineBreaks;
end;

function getStringWithFixedLength(value: string; fixedLength: integer): string;
begin
  Result := Copy(value, 1, fixedLength);
end;

function getStringFromStream(stream: TStream): string;
var
  _string: string;

  _stringStream: TStringStream;
begin
  _string := '';

  if Assigned(stream) then
  begin
    stream.Position := 0;

    _stringStream := TStringStream.Create('', TEncoding.UTF8);
    try
      _stringStream.CopyFrom(stream, 0);
      _string := _stringStream.DataString;
    finally
      _stringStream.Free;
    end;
  end;

  Result := _string
end;

function getNumberOfLinesInStrFixedWordWrap(source: string): integer;
var
  _result: integer;

  _stringList: TStringList;
begin
  _stringList := stringToTStringList(source);
  _result := _stringList.Count;
  FreeAndNil(_stringList);

  Result := _result;
end;

function stringToStrFixedWordWrap(source: string; fixedLen: Integer): string;
var
  _result: string;

  _stringList: TStringList;
  _text: string;
begin
  _stringList := stringToStringListWithFixedLen(source, fixedLen);
  _text := _stringList.Text;
  FreeAndNil(_stringList);
  Delete(_text, length(_text), 1);
  _result := _text;

  Result := _result;
end;

function stringToStringListWithFixedLen(source: string; fixedLen: integer): TStringList;
var
  stringList: TStringList;

  i: integer;
  _sourceLen: integer;
begin
  stringList := TStringList.Create;
  stringList.LineBreak := #13;
  if fixedLen = 0 then
  begin
    fixedLen := Length(source) - 1;
  end;
  stringList.Capacity := (Length(source) div fixedLen) + 1;

  i := 1;
  _sourceLen := Length(source);

  while i <= _sourceLen do
  begin
    stringList.Add(Copy(source, i, fixedLen));
    Inc(i, fixedLen);
  end;

  Result := stringList;
end;

function stringToStringListWithDelimiter(value: string; delimiter: Char): TStringList;
var
  stringList: TStringList;
begin
  stringList := TStringList.Create;
  stringList.Clear;
  stringList.Delimiter := delimiter;
  stringList.StrictDelimiter := True;
  stringList.DelimitedText := value;

  Result := stringList;
end;

function stringToTStringList(source: string): TStringList;
var
  stringList: TStringList;
begin
  stringList := TStringList.Create;
  stringList.Text := source;

  Result := stringList;
end;

function stringToVariantType(stringValue: string; destinationTypeAsString: string): Variant;
var
  value: Variant;
begin
  if destinationTypeAsString = 'string' then //TODO CREATE TTYPE ENUM
  begin
    value := stringValue;
  end
  else if destinationTypeAsString = 'Integer' then
  begin
    value := StrToInt(stringValue);
  end
  else if destinationTypeAsString = 'Double' then
  begin
    value := StrToFloat(stringValue);
  end
  else if destinationTypeAsString = 'Char' then
  begin
    value := stringValue.Chars[0];
  end
  else if destinationTypeAsString = 'Boolean' then
  begin
    value := StrToBool(stringValue);
  end;

  Result := value;
end;

function arrayOfStringToTStringList(arrayOfStrings: array of string): TStringList;
var
  stringList: TStringList;

  _string: string;
begin
  stringList := TStringList.Create;
  for _string in arrayOfStrings do
  begin
    stringList.Add(_string);
  end;

  Result := stringList;
end;

function arrayOfVariantToTStringList(arrayOfVariant: Variant): TStringList;
var
  fieldStringList: TStringList;

  _highBound: integer;
  i: integer;
begin
  fieldStringList := TStringList.Create;

  _highBound := VarArrayHighBound(arrayOfVariant, 1);
  for i := VarArrayLowBound(arrayOfVariant, 1) to _highBound do
  begin
    fieldStringList.Add(arrayOfVariant[i]);
  end;

  Result := fieldStringList;
end;

function splitStringsAsTArrayStrings(source: string; chunkSize: Integer): TArray<string>;
var
  i, len, count: Integer;
begin
  len := Length(source);
  count := (len + chunkSize - 1) div chunkSize;
  SetLength(Result, count);

  for i := 0 to count - 1 do
    Result[i] := Copy(source, i * chunkSize + 1, chunkSize);
end;

procedure splitStrings(source: string; delimiter: string; var destFirstString: string; var destSecondString: string);
var
  _delimiterPosition: integer;
  _delimiterLength: integer;
begin
  _delimiterPosition := myAnsiPos(delimiter, source);
  _delimiterLength := Length(delimiter);
  splitStrings(source, _delimiterPosition, _delimiterLength, destFirstString, destSecondString);
end;

procedure splitStrings(source: string; splitIndex: integer; var destFirstString: string; var destSecondString: string);
begin
  splitStrings(source, splitIndex, 0, destFirstString, destSecondString);
end;

procedure splitStrings(source: string; delimiterPosition: integer; delimiterLength: integer; var destFirstString: string; var destSecondString: string);
var
  _lengthSource: integer;
  _lengthDestSecondString: integer;
  _lastPositionOfDelimiter: integer;
begin
  _lengthSource := Length(source);
  _lastPositionOfDelimiter := delimiterPosition + delimiterLength;
  if _lengthSource > _lastPositionOfDelimiter then
  begin
    _lengthDestSecondString := (_lengthSource - _lastPositionOfDelimiter) + 1;
    destFirstString := Copy(source, 0, delimiterPosition - 1);
    destSecondString := Copy(source, _lastPositionOfDelimiter, _lengthDestSecondString);
  end
  else
  begin
    destFirstString := source;
    destSecondString := '';
  end;
end;

function getMergedStrings(firstString: string; secondString: string; delimiter: string = EMPTY_STRING): string;
begin
  Result := firstString + delimiter + secondString;
end;

function checkIfEmailIsValid(email: string): boolean;
var
  emailIsValid: boolean;
begin
  emailIsValid := TRegEx.IsMatch(email, REGEX_VALID_EMAIL);

  Result := emailIsValid;
end;

function checkIfRegexIsValid(text: string; regex: string): boolean;
begin
  Result := TRegEx.IsMatch(text, regex);
end;

function checkIfMainStringContainsSubStringNoCaseSensitive(mainString: string; subString: string): boolean;
begin
  Result := checkIfMainStringContainsSubString(mainString, subString, NOT_CASE_SENSITIVE);
end;

function checkIfMainStringContainsSubString(mainString: string; subString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): boolean;
var
  _result: boolean;
begin
  if caseSensitiveSearch then
  begin
    _result := ContainsStr(mainString, subString);
  end
  else
  begin
    _result := ContainsText(mainString, subString);
  end;

  Result := _result;
end;

function myStringReplace(mainString: string; OldPattern: array of string; NewPattern: array of string; Flags: TReplaceFlags): string;
var
  stringReplaced: string;
  i: integer;
begin
  Assert(Length(OldPattern) = (Length(NewPattern)));
  stringReplaced := mainString;
  for i := Low(OldPattern) to High(OldPattern) do
  begin
    stringReplaced := KLib.StringUtils.myStringReplace(stringReplaced, OldPattern[i], NewPattern[i], Flags);
  end;

  Result := stringReplaced;
end;

function myStringReplace(const SourceString, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
  Result := System.SysUtils.StringReplace(SourceString, OldPattern, NewPattern, Flags);
end;

function myAnsiPos(subString: string; mainString: string; caseSensitiveSearch: boolean = CASE_SENSITIVE): integer;
var
  _subString: string;
  _mainString: string;
begin
  if caseSensitiveSearch then
  begin
    _subString := subString;
    _mainString := mainString;
  end
  else
  begin
    _subString := UpperCase(subString);
    _mainString := UpperCase(mainString);
  end;

  Result := AnsiPos(_subString, _mainString);
end;

function getDoubleAsString(value: Double; decimalSeparator: char = DECIMAL_SEPARATOR_IT): string;
var
  doubleAsString: string;
  _FloatToStrDecimalSeparator: char;
begin
  doubleAsString := FloatToStr(value);
  _FloatToStrDecimalSeparator := getFloatToStrDecimalSeparator;
  doubleAsString := myStringReplace(doubleAsString, _FloatToStrDecimalSeparator, decimalSeparator, [rfReplaceAll]);

  Result := doubleAsString;
end;

function getFloatToStrDecimalSeparator: char;
const
  VALUE_WITH_DECIMAL_SEPARATOR = 0.1;
  DECIMAL_SEPARATOR_INDEX = 2;
var
  doubleAsString: string;
begin
  doubleAsString := FloatToStr(VALUE_WITH_DECIMAL_SEPARATOR);

  Result := doubleAsString[DECIMAL_SEPARATOR_INDEX];
end;

end.
