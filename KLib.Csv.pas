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

unit KLib.Csv;

interface

uses
  System.Classes, System.SysUtils,
  Data.DB,
  KLib.Constants, KLib.Types;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDate(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): TDate; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsDouble(mainString: string; index: integer; formatSettings: TFormatSettings; delimiter: Char = SEMICOLON_DELIMITER): Double; overload;
function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;

procedure exportDatasetToCSV(dataset: TDataSet; fileName: string); overload;
procedure exportDatasetToCSV(dataset: TDataSet; fileName: string; options: TCsvExportOptions); overload;

implementation

uses

  KLib.StringUtils, KLib.DateTimeUtils;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): TDate;
var
  _result: TDate;
begin
  _result := getCSVFieldFromStringAsDate(mainString, index, FormatSettings, delimiter);

  Result := _result;
end;

function getCSVFieldFromStringAsDate(mainString: string; index: integer; formatSettings: TFormatSettings;
  delimiter: Char = SEMICOLON_DELIMITER): TDate;
var
  _result: TDate;

  _fieldAsString: string;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToDate(_fieldAsString, formatSettings);

  Result := _result;
end;

function getCSVFieldFromStringAsDouble(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): Double;
var
  _result: Double;
begin
  _result := getCSVFieldFromStringAsDouble(mainString, index, FormatSettings, delimiter);

  Result := _result;
end;

function getCSVFieldFromStringAsDouble(mainString: string; index: integer; formatSettings: TFormatSettings;
  delimiter: Char = SEMICOLON_DELIMITER): Double;
var
  _result: Double;

  _fieldAsString: string;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToFloat(_fieldAsString, formatSettings);

  Result := _result;
end;

function getCSVFieldFromStringAsInteger(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): integer;
var
  _result: integer;

  _fieldAsString: string;
begin
  _fieldAsString := getCSVFieldFromString(mainString, index, delimiter);
  _result := StrToInt(_fieldAsString);

  Result := _result;
end;

function getCSVFieldFromString(mainString: string; index: integer; delimiter: Char = SEMICOLON_DELIMITER): string;
const
  ERR_MSG = 'Field index out of range.';
var
  _result: string;

  _stringList: TStringList;
begin
  _stringList := stringToStringListWithDelimiter(mainString, delimiter);
  try
    try
      _result := _stringList[index];
    except
      on E: Exception do
      begin
        raise Exception.Create(ERR_MSG);
      end;
    end;
  finally
    FreeAndNil(_stringList);
  end;

  Result := _result;
end;

procedure exportDatasetToCSV(dataset: TDataSet; fileName: string);
var
  _options: TCsvExportOptions;
begin
  _options := TCsvExportOptions.getDefault;
  exportDatasetToCSV(dataset, fileName, _options);
end;

procedure exportDatasetToCSV(dataset: TDataSet; fileName: string; options: TCsvExportOptions);
const
  ERR_MSG_DATASET_NIL = 'Dataset cannot be nil';
  ERR_MSG_FILENAME_EMPTY = 'Filename cannot be empty';
var
  _csvContent: TStringList;
  _headerRow: string;
  _dataRow: string;
  _fieldValue: string;
  _field: TField;
  _targetEncoding: TEncoding;
  _i: Integer;
begin
  if dataset = nil then
  begin
    raise Exception.Create(ERR_MSG_DATASET_NIL);
  end;

  if fileName = EMPTY_STRING then
  begin
    raise Exception.Create(ERR_MSG_FILENAME_EMPTY);
  end;

  _targetEncoding := options.encoding;
  if _targetEncoding = nil then
  begin
    _targetEncoding := TEncoding.UTF8;
  end;

  _csvContent := TStringList.Create;
  try
    if options.isIncludeHeader then
    begin
      _headerRow := EMPTY_STRING;
      for _i := 0 to dataset.FieldCount - 1 do
      begin
        if _i > 0 then
        begin
          _headerRow := _headerRow + options.delimiter;
        end;
        if options.isQuoteStrings then
        begin
          _fieldValue := getQuotedString(dataset.Fields[_i].FieldName, '"');
        end
        else
        begin
          _fieldValue := dataset.Fields[_i].FieldName;
        end;
        _headerRow := _headerRow + _fieldValue;
      end;
      _csvContent.Add(_headerRow);
    end;

    dataset.First;
    while not dataset.Eof do
    begin
      _dataRow := EMPTY_STRING;
      for _i := 0 to dataset.FieldCount - 1 do
      begin
        if _i > 0 then
        begin
          _dataRow := _dataRow + options.delimiter;
        end;

        _field := dataset.Fields[_i];
        if _field.IsNull then
        begin
          _fieldValue := EMPTY_STRING;
        end
        else
        begin
          case _field.DataType of
            ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
              begin
                if options.isQuoteStrings then
                begin
                  _fieldValue := getQuotedString(_field.AsString, '"');
                end
                else
                begin
                  _fieldValue := _field.AsString;
                end;
              end;
            ftDateTime, ftDate, ftTime:
              _fieldValue := getDateTimeWithFormattingAsString(_field.AsDateTime, options.dateFormat);
            ftFloat, ftCurrency, ftBCD, ftFMTBcd:
              begin
                _fieldValue := getDoubleAsString(_field.AsFloat, options.decimalSeparator);
                if options.isQuoteNumbers then
                begin
                  _fieldValue := getQuotedString(_fieldValue, '"');
                end;
              end;
            ftInteger, ftSmallint, ftLargeint, ftWord:
              begin
                _fieldValue := _field.AsString;
                if options.isQuoteNumbers then
                begin
                  _fieldValue := getQuotedString(_fieldValue, '"');
                end;
              end;
          else
            _fieldValue := _field.AsString;
          end;
        end;

        _dataRow := _dataRow + _fieldValue;
      end;
      _csvContent.Add(_dataRow);
      dataset.Next;
    end;

    _csvContent.SaveToFile(fileName, _targetEncoding);
  finally
    FreeAndNil(_csvContent);
  end;
end;

end.
