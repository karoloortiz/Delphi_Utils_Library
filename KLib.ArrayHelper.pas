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

unit KLib.ArrayHelper;

interface

uses
  System.SysUtils;

type
  TArrayHelper<T> = record
  private
    _items: TArray<T>;
  public
    //set
    class operator Implicit(value: TArrayHelper<T>): TArray<T>;

    //get
    class operator Implicit(value: TArray<T>): TArrayHelper<T>;

    function filter(const predicate: TFunc<T, Boolean>): TArray<T>;
  end;

implementation

class operator TArrayHelper<T>.Implicit(value: TArrayHelper<T>): TArray<T>;
begin
  Result := value._items;
end;

class operator TArrayHelper<T>.Implicit(value: TArray<T>): TArrayHelper<T>;
begin
  Result._items := value;
end;

function TArrayHelper<T>.Filter(const predicate: TFunc<T, Boolean>): TArray<T>;
var
  newArray: TArray<T>;

  _item: T;
  _sizeNewArray: Integer;
begin
  SetLength(newArray, Length(_items));
  _sizeNewArray := 0;
  for _item in _items do
    if predicate(_item) then
    begin
      Result[_sizeNewArray] := _item;
      Inc(_sizeNewArray);
    end;
  SetLength(newArray, _sizeNewArray);

  Result := newArray;
end;

end.
