unit KLib.MemoryRAM;

interface

uses
  Winapi.Windows;

type
  TMemoryRAM = class
  private
    class var RamStats: TMemoryStatusEx;
  public
    class procedure initialize;
    class function getTotalMemoryAsString: string;
    class function getTotalMemoryAsDouble: double;
    class function getTotalFreeMemoryAsString: string;
    class function getTotalFreeMemoryAsInteger: integer;
    class function getTotalFreeMemoryAsDouble: double;
    class function getPercentageFreeMemoryAsString: string;
  end;

implementation

uses
  KLib.Constants,
  System.SysUtils;

class procedure TMemoryRAM.initialize;
begin
  FillChar(RamStats, SizeOf(MemoryStatusEx), #0);
  RamStats.dwLength := SizeOf(MemoryStatusEx);
  GlobalMemoryStatusEx(RamStats);
end;

class function TMemoryRAM.getTotalMemoryAsString: string;
begin
  result := FloatToStr(RamStats.ullTotalPhys / _1_MB_IN_BYTES) + ' MB';
end;

class function TMemoryRAM.getTotalMemoryAsDouble: Double;
begin
  result := RamStats.ullTotalPhys / _1_MB_IN_BYTES;
end;

class function TMemoryRAM.getTotalFreeMemoryAsString: string;
begin
  result := FloatToStr(RamStats.ullAvailPhys / _1_MB_IN_BYTES) + ' MB';
end;

class function TMemoryRAM.getTotalFreeMemoryAsInteger: integer;
var
  _totalFreeMemoryDouble: double;
  _totalFreeMemoryInteger: integer;
begin
  _totalFreeMemoryDouble := getTotalMemoryAsDouble;
  _totalFreeMemoryInteger := trunc(_totalFreeMemoryDouble);
  Result := _totalFreeMemoryInteger;
end;

class function TMemoryRAM.getTotalFreeMemoryAsDouble: Double;
begin
  result := RamStats.ullAvailPhys / _1_MB_IN_BYTES;
end;

class function TMemoryRAM.getPercentageFreeMemoryAsString: string;
begin
  result := inttostr(RamStats.dwMemoryLoad) + '%';
end;

end.
