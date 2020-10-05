unit KLib.Math;

interface

uses Types;

function distanceBetweenPoints(a, b: TPoint): Double; overload;
function distanceBetweenPoints(Xa, Ya, Xb, Yb: integer): Double; overload;

implementation

uses Math;

function distanceBetweenPoints(a, b: TPoint): Double; overload;
var
  Xa, Ya, Xb, Yb: integer;
begin
  Xa := a.X;
  Ya := a.Y;
  Xb := b.X;
  Yb := b.Y;

  Result := distanceBetweenPoints(Xa, Ya, Xb, Yb);
end;

function distanceBetweenPoints(Xa, Ya, Xb, Yb: integer): Double; overload;
begin
  Result := sqrt(Power(Xa - Xb, 2) + Power(Ya - Yb, 2));
end;

end.
