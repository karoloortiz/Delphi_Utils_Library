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
