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

unit KLib.IniFiles;

interface

uses
  KLib.Constants;

const
  _DEFAULT_ERROR_STRING_VALUE_INI_FILES = '*_/&@';

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer; overload;
function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer; overload;
function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES; forceDequote: boolean = NOT_FORCE): string;
procedure setIntValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: integer);
procedure setStringValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: string);

implementation

uses
  KLib.Utils, KLib.Validate,
  System.IniFiles, System.SysUtils;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer;
var
  intValue: integer;

  _stringValue: string;
begin
  _stringValue := getStringValueFromIniFile(fileNameIni, nameSection, nameProperty);
  intValue := StrToInt(_stringValue);

  Result := intValue;
end;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer;
var
  value: integer;

  _pathIniFile: string;
  _iniManipulator: TIniFile;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadInteger(nameSection, nameProperty, defaultPropertyValue);
  FreeAndNil(_iniManipulator);

  Result := value;
end;

function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES; forceDequote: boolean = NOT_FORCE): string;
const
  ERR_MSG = 'No property assigned.';
var
  value: string;

  _pathIniFile: string;
  _iniManipulator: TMemIniFile;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TMemIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadString(nameSection, nameProperty, defaultPropertyValue);
  if forceDequote then
  begin
    value := getDequotedString(value);
  end;

  FreeAndNil(_iniManipulator);
  if value = _DEFAULT_ERROR_STRING_VALUE_INI_FILES then
  begin
    raise Exception.Create(ERR_MSG);
  end;

  Result := value;
end;

procedure setIntValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: integer);
var
  _iniManipulator: TIniFile;
  _pathIniFile: string;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  _iniManipulator.WriteInteger(nameSection, nameProperty, value);
  FreeAndNil(_iniManipulator);
end;

procedure setStringValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: string);
var
  _iniManipulator: TIniFile;
  _pathIniFile: string;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  _iniManipulator.WriteString(nameSection, nameProperty, value);
  FreeAndNil(_iniManipulator);
end;

end.
