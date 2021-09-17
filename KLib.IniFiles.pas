unit KLib.IniFiles;

interface

const
  _DEFAULT_ERROR_STRING_VALUE_INI_FILES = '*_/&@';

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer; overload;
function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer; overload;
function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;
procedure setIntValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: integer);
procedure setStringValueToIniFile(fileNameIni: string; nameSection: string; nameProperty: string; value: string);

implementation

uses
  KLib.Utils, KLib.Validate,
  System.IniFiles, System.SysUtils;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string): integer;
var
  _stringValue: string;
  _intValue: integer;
begin
  _stringValue := getStringValueFromIniFile(fileNameIni, nameSection, nameProperty);
  _intValue := StrToInt(_stringValue);
  Result := _intValue;
end;

function getIntValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: integer): integer;
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: integer;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadInteger(nameSection, nameProperty, defaultPropertyValue);
  FreeAndNil(_iniManipulator);

  Result := value;
end;

function getStringValueFromIniFile(fileNameIni: string; nameSection: string; nameProperty: string;
  defaultPropertyValue: string = _DEFAULT_ERROR_STRING_VALUE_INI_FILES): string;
const
  ERR_MSG = 'No property assigned.';
var
  _pathIniFile: string;
  _iniManipulator: TIniFile;
  value: string;
begin
  _pathIniFile := getValidFullPath(fileNameIni);
  validateThatFileExists(_pathIniFile);
  _iniManipulator := TIniFile.Create(_pathIniFile);
  value := _iniManipulator.ReadString(nameSection, nameProperty, defaultPropertyValue);
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
