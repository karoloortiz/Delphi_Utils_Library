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

unit KLib.DateTimeUtils;

interface

uses
  KLib.Types, KLib.Constants,
  System.SysUtils, System.DateUtils;

function splitByMonths(startDate: TDateTime; endDate: TDateTime): TArray<TDateTimeRange>; overload;
function splitByMonths(datetimeRange: TDateTimeRange): TArray<TDateTimeRange>; overload;

function divideDateRange(startDate: TDateTime; endDate: TDateTime; divisions: integer = 2): TArray<TDateTimeRange>; overload;
function divideDateRange(datetimeRange: TDateTimeRange; divisions: integer = 2): TArray<TDateTimeRange>; overload;

function getCurrentDayOfWeekAsString: string;
function getDayOfWeekAsString(date: TDateTime): string;
function getCurrentDateTimeAsString: string;
function getDateTimeAsString(date: TDateTime): string;
function getCurrentDateAsString: string;
function getDateAsString(date: TDateTime): string;
function getCurrentTimeStamp: string;
function getCurrentDateTimeWithFormattingAsString(formatting: string = DATETIME_FORMAT): string;
function getDateTimeWithFormattingAsString(value: TDateTime; formatting: string = DATETIME_FORMAT): string;

function getCurrentDateTime: TDateTime;
function getDateFromString(value: string; formatting: string = EMPTY_STRING): TDate;
function getTimeFromString(value: string; formatting: string = EMPTY_STRING): TTime;

function isWorkingDay(date: TDateTime = 0): boolean;
function isHoliday(date: TDateTime = 0): boolean;
function isMonday(date: TDateTime = 0): boolean;
function isTuesday(date: TDateTime = 0): boolean;
function isWednesday(date: TDateTime = 0): boolean;
function isThursday(date: TDateTime = 0): boolean;
function isFriday(date: TDateTime = 0): boolean;
function isSaturday(date: TDateTime = 0): boolean;
function isSunday(date: TDateTime = 0): boolean;

implementation

uses
  KLib.StringUtils, KLib.Validate, KLib.Common;

function splitByMonths(startDate: TDateTime; endDate: TDateTime): TArray<TDateTimeRange>;
var
  _datetimeRange: TDateTimeRange;
begin
  _datetimeRange.clear;
  _datetimeRange._start := startDate;
  _datetimeRange._end := endDate;

  Result := splitByMonths(_datetimeRange);
end;

function splitByMonths(datetimeRange: TDateTimeRange): TArray<TDateTimeRange>;
var
  dateRanges: TArray<TDateTimeRange>;
  range: TDateTimeRange;
  currentStart: TDateTime;
  currentEnd: TDateTime;
  year, month, day: Word;
begin
  if datetimeRange._start > datetimeRange._end then
    raise Exception.Create('The start date must be earlier than the end date.');

  currentStart := datetimeRange._start;

  while currentStart <= datetimeRange._end do
  begin
    range.clear;

    // Decode the current start date
    DecodeDate(currentStart, year, month, day);

    // Calculate the end of the current month
    currentEnd := EncodeDate(year, month, DaysInAMonth(year, month));

    // Ensure the current end does not exceed the provided range
    if currentEnd > datetimeRange._end then
      currentEnd := datetimeRange._end;

    // Assign the range
    range._start := currentStart;
    range._end := currentEnd;

    // Add the range to the array
    SetLength(dateRanges, Length(dateRanges) + 1);
    dateRanges[High(dateRanges)] := range;

    // Move to the next month
    currentStart := currentEnd + 1;
  end;

  Result := dateRanges;
end;

function divideDateRange(startDate: TDateTime; endDate: TDateTime; divisions: Integer = 2): TArray<TDateTimeRange>;
var
  _datetimeRange: TDateTimeRange;
begin
  _datetimeRange.clear;
  _datetimeRange._start := startDate;
  _datetimeRange._end := endDate;

  Result := divideDateRange(_datetimeRange, divisions);
end;

function divideDateRange(datetimeRange: TDateTimeRange; divisions: Integer = 2): TArray<TDateTimeRange>;
var
  dateRanges: TArray<TDateTimeRange>;

  i: Integer;
  interval: TDateTime;
  currentStart: TDateTime;
  range: TDateTimeRange;
begin
  if (datetimeRange._start > datetimeRange._end) then
  begin
    raise Exception.Create('The start date must be earlier than the end date.');
  end;

  if (divisions <= 0) then
  begin
    raise Exception.Create('The number of divisions must be greater than 0.');
  end;

  if (divisions > Trunc(datetimeRange._end - datetimeRange._start) + 1) then
  begin
    raise Exception.Create('The number of divisions exceeds the number of days in the range.');
  end;
  // Calculate the interval for each division
  interval := (datetimeRange._end - datetimeRange._start) / divisions;

  // Initialize the result array
  SetLength(dateRanges, divisions);

  // Create each range
  currentStart := datetimeRange._start;
  for i := 0 to divisions - 1 do
  begin
    range.clear;

    range._start := currentStart;

    if (i = (divisions - 1)) then
    begin
      range._end := datetimeRange._end; // Ensure the last range ends exactly at endDate
    end
    else
    begin
      range._end := Trunc(currentStart + interval);
    end;

    dateRanges[i] := range;

    currentStart := range._end + 1; // Start the next range the day after the current end
  end;

  Result := dateRanges;
end;

function getCurrentDayOfWeekAsString: string;
var
  dayAsString: string;
begin
  dayAsString := getDayOfWeekAsString(Now);

  Result := dayAsString;
end;

function getDayOfWeekAsString(date: TDateTime): string;
const
  DAYS_OF_WEEK: TArray<string> = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
    ];
var
  dayAsString: string;
  _indexDayOfWeek: integer;
begin
  _indexDayOfWeek := DayOfWeek(date) - 1;
  dayAsString := DAYS_OF_WEEK[_indexDayOfWeek];

  Result := dayAsString;
end;

function getCurrentDateTimeAsString: string;
begin
  Result := getDateTimeAsString(Now);
end;

function getDateTimeAsString(date: TDateTime): string;
var
  dateTimeAsString: string;

  _date: string;
  _time: string;
begin
  _date := getDateAsString(date);
  _time := TimeToStr(date);
  _time := myStringReplace(_time, ':', EMPTY_STRING, [rfReplaceAll, rfIgnoreCase]);
  dateTimeAsString := _date + '_' + _time;

  Result := dateTimeAsString;
end;

function getCurrentDateAsString: string;
begin
  Result := getDateAsString(Now);
end;

function getDateAsString(date: TDateTime): string;
var
  dateAsString: string;
begin
  dateAsString := DateToStr(date);
  dateAsString := myStringReplace(dateAsString, '/', '_', [rfReplaceAll, rfIgnoreCase]);

  Result := dateAsString;
end;

function getCurrentTimeStamp: string;
begin
  Result := getCurrentDateTimeWithFormattingAsString(TIMESTAMP_FORMAT);
end;

function getCurrentDateTimeWithFormattingAsString(formatting: string = DATETIME_FORMAT): string;
begin
  Result := getDateTimeWithFormattingAsString(Now, formatting);
end;

function getDateTimeWithFormattingAsString(value: TDateTime; formatting: string = DATETIME_FORMAT): string;
var
  dateTimeAsStringWithFormatting: string;
begin
  dateTimeAsStringWithFormatting := FormatDateTime(formatting, value);

  Result := dateTimeAsStringWithFormatting;
end;

function getCurrentDateTime: TDateTime;
begin
  Result := Now;
end;

function getDateFromString(value: string; formatting: string = EMPTY_STRING): TDate;
var
  _formatSettings: TFormatSettings;
begin
  _formatSettings := TFormatSettings.Create;
  if (formatting <> EMPTY_STRING) then
  begin
    _formatSettings.DateSeparator := #0;
    if (checkIfStringContainsSubString(formatting, '-')) then
    begin
      _formatSettings.DateSeparator := '-';
    end;
    if (checkIfStringContainsSubString(formatting, '/')) then
    begin
      _formatSettings.DateSeparator := '/';
    end;
    _formatSettings.ShortDateFormat := formatting;
  end;

  Result := StrToDate(value, _formatSettings)
end;

function getTimeFromString(value: string; formatting: string = EMPTY_STRING): TTime;
var
  _formatSettings: TFormatSettings;
begin
  _formatSettings := TFormatSettings.Create;
  if (formatting <> EMPTY_STRING) then
  begin
    _formatSettings.TimeSeparator := #0;
    if (checkIfStringContainsSubString(formatting, ':')) then
    begin
      _formatSettings.TimeSeparator := ':';
    end;
    if (checkIfStringContainsSubString(formatting, '.')) then
    begin
      _formatSettings.TimeSeparator := '.';
    end;
    _formatSettings.LongTimeFormat := formatting;
  end;

  Result := StrToTime(value, _formatSettings)
end;

function isWorkingDay(date: TDateTime = 0): boolean;
var
  _day: integer;
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);
  _day := DayOfTheWeek(_date);

  Result := ((_day >= 1) and (_day <= 5));
end;

function isHoliday(date: TDateTime = 0): boolean;
var
  _day: integer;
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);
  _day := DayOfTheWeek(_date);

  Result := ((_day = 6) or (_day <= 7));
end;

function isMonday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 1;
end;

function isTuesday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 2;
end;

function isWednesday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 3;
end;

function isThursday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 4;
end;

function isFriday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 5;
end;

function isSaturday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 6;
end;

function isSunday(date: TDateTime = 0): boolean;
var
  _date: TDateTime;
begin
  _date := ifThen(date = 0, now, date);

  Result := DayOfTheWeek(_date) = 7;
end;

end.
