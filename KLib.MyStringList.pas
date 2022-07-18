unit KLib.MyStringList;

interface

uses
  System.Classes;

type
  TMyStringList = type TStringList;

  TMyStringListHelper = class helper for TStringList
    procedure addStrings(strings: array of string); overload;
  end;

implementation

uses
  Klib.Utils,
  System.SysUtils;

procedure TMyStringListHelper.addStrings(strings: array of string);
var
  _stringList: TStringList;
begin
  _stringList := arrayOfStringToTStringList(strings);
  try
    AddStrings(_stringList);
  finally
    begin
      FreeAndNil(_stringList);
    end;
  end;
end;

end.
