unit KLib.ArrayHelper;

interface

uses
  System.SysUtils;

type
  TArrayHelper<T> = record
  private
    FItems: TArray<T>;
  public
    // conversioni implicite per usare direttamente un array
    class operator Implicit(a: TArray<T>): TArrayHelper<T>;
    class operator Implicit(a: TArrayHelper<T>): TArray<T>;

    // metodo Filter stile LINQ
    function Filter(const predicate: TFunc<T, Boolean>): TArray<T>;
  end;

implementation

{ TArrayHelper<T> }

class operator TArrayHelper<T>.Implicit(a: TArray<T>): TArrayHelper<T>;
begin
  Result.FItems := a;
end;

class operator TArrayHelper<T>.Implicit(a: TArrayHelper<T>): TArray<T>;
begin
  Result := a.FItems;
end;

function TArrayHelper<T>.Filter(const predicate: TFunc<T, Boolean>): TArray<T>;
var
  item: T;
  count: Integer;
begin
  SetLength(Result, Length(FItems));
  count := 0;
  for item in FItems do
    if predicate(item) then
    begin
      Result[count] := item;
      Inc(count);
    end;
  SetLength(Result, count);
end;

end.
