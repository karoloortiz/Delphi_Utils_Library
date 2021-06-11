unit KLib.Generic;

interface

type
  TGeneric = class
  public
    class function getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer; overload;
    class function getElementIndexFromArray<T>(myArray: array of T; element: T): integer; overload;
  end;

implementation

uses
  System.Generics.Collections, System.SysUtils;

class function TGeneric.getElementIndexFromArray<T>(myArray: TArray<T>; element: T): integer;
var
  _list: TList<T>;
  _element: T;
  elementIndex: integer;
begin
  _list := TList<T>.Create;
  for _element in myArray do
  begin
    _list.Add(_element);
  end;
  elementIndex := _list.IndexOf(element);
  FreeAndNil(_list);

  Result := elementIndex;
end;

class function TGeneric.getElementIndexFromArray<T>(myArray: array of T; element: T): integer;
var
  _list: TList<T>;
  _element: T;

  elementIndex: integer;
begin
  _list := TList<T>.Create;
  for _element in myArray do
  begin
    _list.Add(_element);
  end;
  elementIndex := _list.IndexOf(element);
  FreeAndNil(_list);

  Result := elementIndex;
end;

end.
