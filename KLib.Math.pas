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

unit KLib.Math;

interface

uses
  System.Types;

function distanceBetweenPoints(a: TPoint; b: TPoint): Double; overload;
function distanceBetweenPoints(Xa: integer; Ya: integer; Xb: integer; Yb: integer): Double; overload;
function megabyteToByte(MB: int64): int64;
function getMax(const a: integer; const b: integer): integer; overload;
function getMax(const a: double; const b: double): double; overload;
function getMin(const a: integer; const b: integer): integer; overload;
function getMin(const a: double; const b: double): double; overload;

implementation

uses
  KLib.Constants,
  System.Math;

function distanceBetweenPoints(a: TPoint; b: TPoint): Double; overload;
var
  Xa, Ya, Xb, Yb: integer;
begin
  Xa := a.X;
  Ya := a.Y;
  Xb := b.X;
  Yb := b.Y;

  Result := distanceBetweenPoints(Xa, Ya, Xb, Yb);
end;

function distanceBetweenPoints(Xa: integer; Ya: integer; Xb: integer; Yb: integer): Double; overload;
begin
  Result := sqrt(Power(Xa - Xb, 2) + Power(Ya - Yb, 2));
end;

function megabyteToByte(MB: int64): int64;
var
  bytes: int64;
begin
  bytes := MB * _1_MB_IN_BYTES;

  Result := bytes;
end;

function getMax(const a: integer; const b: integer): integer;
var
  _a: double;
  _b: double;
begin
  _a := a;
  _b := b;
  Result := Trunc(getMax(_a, _b));
end;

function getMax(const a: double; const b: double): double;
var
  max: double;
begin
  if a >= b then
  begin
    max := A
  end
  else
  begin
    max := B;
  end;

  Result := max;
end;

function getMin(const a: integer; const b: integer): integer;
var
  _a: double;
  _b: double;
begin
  _a := a;
  _b := b;

  Result := Trunc(getMin(_a, _b));
end;

function getMin(const a: double; const b: double): double;
var
  min: double;
begin
  if a <= b then
  begin
    min := A
  end
  else
  begin
    min := B;
  end;

  Result := min;
end;

end.
