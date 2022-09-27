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

//##### JSON #################
//  ATTRIBUTES:
//  - DefaultValueAttribute
//  - IgnoreAttribute
//###########---EXAMPLE OF USE----##########################
// uses
//  KLib.Generics.JSON, KLib.Generics.Attributes; //always include
//
// type
//  TResponse = record
//  public
//    timestamp: string;
//    sucess: string;
//    [DefaultValueAttribute('yes')]
//    error: string;
//    [IgnoreAttribute]
//    ignoredField: string;
//  end;
//
//  ...
//  var
//  _response: TResponse;
//
//  begin
//  ...
//  _responseText := TJSONGenerics.getJSONAsString<TResponse>(_response);
//#####################################

unit KLib.Generics.JSON;

interface

uses
  KLib.Constants,
  System.JSON;

type

  TJSONGenerics = class
  public

    class function getJSONAsString<T>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;
    class function getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string; overload;

    class function getJSONObject<T>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;
    class function getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
      (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject; overload;

    class function getParsedJSON<T>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(jsonAsString: string): T; overload;
    class function getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(jsonAsString: string): T; overload;
  end;

implementation

uses
  KLib.Generics, KLib.Generics.Attributes, KLib.Utils,
  System.Generics.Collections, System.SysUtils, System.Rtti, System.Variants;

class function TJSONGenerics.getJSONAsString<T>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
begin
  Result := TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONAsString<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): string;
var
  jsonAsString: string;
  _JSONObject: TJSONObject;
begin
  _JSONObject := getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(myRecord, ignoreEmptyStrings);
  jsonAsString := _JSONObject.ToString;
  _JSONObject.Free;

  Result := jsonAsString;
end;

class function TJSONGenerics.getJSONObject<T>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
begin
  Result := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, T>(myRecord, ignoreEmptyStrings);
end;

class function TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
  (myRecord: T; ignoreEmptyStrings: boolean = IGNORE_EMPTY_STRINGS): TJSONObject;
var
  JSONObject: TJSONObject;
  _JSONArray: TJsonArray;
  _JSONObject: TJSONObject;

  _defaultRecord: T;

  _ignoreAttribute: boolean;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _propertyValueIsEmpty: boolean;

  _subObject: TJSONObject;
  _T_sub: T;
  _U_sub: U;
  _V_sub: V;
  _W_sub: W;
  _X_sub: X;
  _Y_sub: Y;
  _Z_sub: Z;
  _A_sub: A;
  _B_sub: B;
  _C_sub: C;
  _D_sub: D;
  _E_sub: E;
  _F_sub: F;
  _G_sub: G;
  _H_sub: H;
  _I_sub: I;
  _J_sub: J;
  _K_sub: K;
  _L_sub: L;
  _M_sub: M;
  _N_sub: N;
  _O_sub: O;
  _P_sub: P;
  _Q_sub: Q;
  _R_sub: R;
  _S_sub: S;

  _newTValue: TValue;

  _arrayType: string;
  _i: integer;
  _exists: boolean;
begin
  JSONObject := TJSONObject.Create();

  _defaultRecord := KLib.Generics.TGenerics.getDefault<T>;

  _rttiContext := TRttiContext.Create;
  _rttiType := _rttiContext.GetType(TypeInfo(T));

  for _rttiField in _rttiType.GetFields do
  begin
    _propertyName := _rttiField.Name;
    _propertyType := _rttiField.FieldType.ToString;

    _ignoreAttribute := false;
    _customAttributes := _rttiField.GetAttributes;
    for _customAttribute in _customAttributes do
    begin
      if _customAttribute is IgnoreAttribute then
      begin
        _ignoreAttribute := true;
      end;
    end;

    if not _ignoreAttribute then
    begin
      if (_propertyType = 'string') or (_propertyType = 'Char') then
      begin
        _propertyValue := _rttiField.GetValue(@myRecord).AsString;
        _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
        if _propertyValueIsEmpty then
        begin
          _propertyValue := _rttiField.GetValue(@_defaultRecord).AsString;
        end;

        if not ignoreEmptyStrings then
        begin
          JSONObject.AddPair(TJSONPair.Create(_propertyName, string(_propertyValue)));
        end
        else
        begin
          JSONObject.AddPair(_propertyName, string(_propertyValue));
        end;
      end
      else if (_propertyType = 'Integer') or (_propertyType = 'Word') then
      begin
        _propertyValue := _rttiField.GetValue(@myRecord).AsInteger;
        _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
        if _propertyValueIsEmpty then
        begin
          _propertyValue := _rttiField.GetValue(@_defaultRecord).AsInteger;
        end;

        JSONObject.AddPair(_propertyName, TJSONNumber.Create(integer(_propertyValue)));
      end
      else if _propertyType = 'Double' then
      begin
        _propertyValue := _rttiField.GetValue(@myRecord).AsExtended;
        _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
        if _propertyValueIsEmpty then
        begin
          _propertyValue := _rttiField.GetValue(@_defaultRecord).AsExtended;
        end;

        JSONObject.AddPair(_propertyName, TJSONNumber.Create(double(_propertyValue)));
      end
      else if _propertyType = 'Boolean' then
      begin
        _propertyValue := _rttiField.GetValue(@myRecord).AsBoolean;
        _propertyValueIsEmpty := checkIfVariantTypeIsEmpty(_propertyValue, _propertyType);
        if _propertyValueIsEmpty then
        begin
          _propertyValue := _rttiField.GetValue(@_defaultRecord).AsBoolean;
        end;

        JSONObject.AddPair(_propertyName, TJSONBool.Create(_propertyValue));
      end
      else if _rttiField.FieldType.TypeKind = tkDynArray then
      begin
        _newTValue := _rttiField.GetValue(@myRecord);

        if _newTValue.GetArrayLength > 0 then
        begin
          _JSONArray := TJsonArray.Create();
          JSONObject.AddPair(TJSONPair.Create(_propertyName, _JSONArray));

          _arrayType := TRttiDynamicArrayType(_rttiField.FieldType).elementType.ToString;
          for _i := 0 to _newTValue.GetArrayLength - 1 do
          begin
            //        T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S
            _exists := true;
            if _arrayType = _rttiContext.GetType(TypeInfo(T)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
                (_newTValue.GetArrayElement(_i).AsType<T>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(U)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>
                (_newTValue.GetArrayElement(_i).AsType<U>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(V)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>
                (_newTValue.GetArrayElement(_i).AsType<V>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(W)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V>
                (_newTValue.GetArrayElement(_i).AsType<W>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(X)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W>
                (_newTValue.GetArrayElement(_i).AsType<X>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(Y)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X>
                (_newTValue.GetArrayElement(_i).AsType<Y>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(Z)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y>
                (_newTValue.GetArrayElement(_i).AsType<Z>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(A)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z>
                (_newTValue.GetArrayElement(_i).AsType<A>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(B)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A>
                (_newTValue.GetArrayElement(_i).AsType<B>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(C)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B>
                (_newTValue.GetArrayElement(_i).AsType<C>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(D)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C>
                (_newTValue.GetArrayElement(_i).AsType<D>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(E)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D>
                (_newTValue.GetArrayElement(_i).AsType<E>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(F)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E>
                (_newTValue.GetArrayElement(_i).AsType<F>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(G)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F>
                (_newTValue.GetArrayElement(_i).AsType<G>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(H)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
                (_newTValue.GetArrayElement(_i).AsType<H>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(I)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
                (_newTValue.GetArrayElement(_i).AsType<I>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(J)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
                (_newTValue.GetArrayElement(_i).AsType<J>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(K)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
                (_newTValue.GetArrayElement(_i).AsType<K>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(L)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
                (_newTValue.GetArrayElement(_i).AsType<L>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(M)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
                (_newTValue.GetArrayElement(_i).AsType<M>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(N)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
                (_newTValue.GetArrayElement(_i).AsType<N>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(O)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
                (_newTValue.GetArrayElement(_i).AsType<O>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(P)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
                (_newTValue.GetArrayElement(_i).AsType<P>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(Q)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
                (_newTValue.GetArrayElement(_i).AsType<Q>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(R)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
                (_newTValue.GetArrayElement(_i).AsType<R>, ignoreEmptyStrings);
            end
            else if _arrayType = _rttiContext.GetType(TypeInfo(S)).ToString then
            begin
              _JSONObject := TJSONGenerics.getJSONObject<S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
                (_newTValue.GetArrayElement(_i).AsType<S>, ignoreEmptyStrings);
            end
            else
            begin
              _exists := false;
            end;

            if _exists then
            begin
              _JSONArray.AddElement(_JSONObject);
            end;
          end;
        end;
      end
      else
      begin
        try
          _exists := true;
          //        T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S
          if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
          begin
            _T_sub := _rttiField.GetValue(@myRecord).AsType<T>;
            _subObject := TJSONGenerics.getJSONObject<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
              (_T_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(U)).ToString then
          begin
            _U_sub := _rttiField.GetValue(@myRecord).AsType<U>;
            _subObject := TJSONGenerics.getJSONObject<U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>
              (_U_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(V)).ToString then
          begin
            _V_sub := _rttiField.GetValue(@myRecord).AsType<V>;
            _subObject := TJSONGenerics.getJSONObject<V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>
              (_V_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(W)).ToString then
          begin
            _W_sub := _rttiField.GetValue(@myRecord).AsType<W>;
            _subObject := TJSONGenerics.getJSONObject<W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V>
              (_W_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(X)).ToString then
          begin
            _X_sub := _rttiField.GetValue(@myRecord).AsType<X>;
            _subObject := TJSONGenerics.getJSONObject<X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W>
              (_X_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(X)).ToString then
          begin
            _Y_sub := _rttiField.GetValue(@myRecord).AsType<Y>;
            _subObject := TJSONGenerics.getJSONObject<Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X>
              (_Y_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(Z)).ToString then
          begin
            _Z_sub := _rttiField.GetValue(@myRecord).AsType<Z>;
            _subObject := TJSONGenerics.getJSONObject<Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y>
              (_Z_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(A)).ToString then
          begin
            _A_sub := _rttiField.GetValue(@myRecord).AsType<A>;
            _subObject := TJSONGenerics.getJSONObject<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z>
              (_A_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(B)).ToString then
          begin
            _B_sub := _rttiField.GetValue(@myRecord).AsType<B>;
            _subObject := TJSONGenerics.getJSONObject<B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A>
              (_B_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(C)).ToString then
          begin
            _C_sub := _rttiField.GetValue(@myRecord).AsType<C>;
            _subObject := TJSONGenerics.getJSONObject<C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B>
              (_C_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(D)).ToString then
          begin
            _D_sub := _rttiField.GetValue(@myRecord).AsType<D>;
            _subObject := TJSONGenerics.getJSONObject<D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C>
              (_D_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(E)).ToString then
          begin
            _E_sub := _rttiField.GetValue(@myRecord).AsType<E>;
            _subObject := TJSONGenerics.getJSONObject<E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D>
              (_E_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(F)).ToString then
          begin
            _F_sub := _rttiField.GetValue(@myRecord).AsType<F>;
            _subObject := TJSONGenerics.getJSONObject<F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E>
              (_F_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(G)).ToString then
          begin
            _G_sub := _rttiField.GetValue(@myRecord).AsType<G>;
            _subObject := TJSONGenerics.getJSONObject<G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F>
              (_G_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(H)).ToString then
          begin
            _H_sub := _rttiField.GetValue(@myRecord).AsType<H>;
            _subObject := TJSONGenerics.getJSONObject<H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>
              (_H_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(I)).ToString then
          begin
            _I_sub := _rttiField.GetValue(@myRecord).AsType<I>;
            _subObject := TJSONGenerics.getJSONObject<I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>
              (_I_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(J)).ToString then
          begin
            _J_sub := _rttiField.GetValue(@myRecord).AsType<J>;
            _subObject := TJSONGenerics.getJSONObject<J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>
              (_J_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(K)).ToString then
          begin
            _K_sub := _rttiField.GetValue(@myRecord).AsType<K>;
            _subObject := TJSONGenerics.getJSONObject<K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>
              (_K_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(L)).ToString then
          begin
            _L_sub := _rttiField.GetValue(@myRecord).AsType<L>;
            _subObject := TJSONGenerics.getJSONObject<L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>
              (_L_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(M)).ToString then
          begin
            _M_sub := _rttiField.GetValue(@myRecord).AsType<M>;
            _subObject := TJSONGenerics.getJSONObject<M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>
              (_M_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(N)).ToString then
          begin
            _N_sub := _rttiField.GetValue(@myRecord).AsType<N>;
            _subObject := TJSONGenerics.getJSONObject<N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>
              (_N_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(O)).ToString then
          begin
            _O_sub := _rttiField.GetValue(@myRecord).AsType<O>;
            _subObject := TJSONGenerics.getJSONObject<O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>
              (_O_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(P)).ToString then
          begin
            _P_sub := _rttiField.GetValue(@myRecord).AsType<P>;
            _subObject := TJSONGenerics.getJSONObject<P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>
              (_P_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(Q)).ToString then
          begin
            _Q_sub := _rttiField.GetValue(@myRecord).AsType<Q>;
            _subObject := TJSONGenerics.getJSONObject<Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>
              (_Q_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(R)).ToString then
          begin
            _R_sub := _rttiField.GetValue(@myRecord).AsType<R>;
            _subObject := TJSONGenerics.getJSONObject<R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>
              (_R_sub, ignoreEmptyStrings);
          end
          else if _propertyType = _rttiContext.GetType(TypeInfo(S)).ToString then
          begin
            _S_sub := _rttiField.GetValue(@myRecord).AsType<S>;
            _subObject := TJSONGenerics.getJSONObject<S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>
              (_S_sub, ignoreEmptyStrings);
          end
          else
          begin
            _exists := false;
          end;

          if _exists then
          begin
            JSONObject.AddPair(_propertyName, _subObject);
          end;
        except
          on E: Exception do
          begin
            _propertyValueIsEmpty := _propertyValueIsEmpty; //try except only for debug
          end;
        end;
      end;

    end;
  end;

  //  except
  //    { ... Do something here ... }
  //  end;

  _rttiContext.Free;

  Result := JSONObject;
end;

//function TJSONUnMarshal.JSONToTValue(JsonValue: TJSONValue; rttiType: TRttiType): TValue;
//var
//  tvArray: array of TValue;
//  Value: string;
//  I: Integer;
//  elementType: TRttiType;
//  Data: TValue;
//  recField: TRTTIField;
//  attrRev: TJSONInterceptor;
//  jsonFieldVal: TJSONValue;
//  ClassType: TClass;
//  Instance: Pointer;
//begin
//  // null or nil returns empty
//  if (JsonValue = nil) or (JsonValue is TJSONNull) then
//    Exit(TValue.Empty);
//
//  // for each JSON value type
//  if JsonValue is TJSONNumber then
//    // get data "as is"
//    Value := TJSONNumber(JsonValue).ToString
//  else if JsonValue is TJSONString then
//    Value := TJSONString(JsonValue).Value
//  else if JsonValue is TJSONTrue then
//    Exit(True)
//  else if JsonValue is TJSONFalse then
//    Exit(False)
//  else if JsonValue is TJSONObject then
//    // object...
//    Exit(CreateObject(TJSONObject(JsonValue)))
//  else
//  begin
//    case rttiType.TypeKind of
//      TTypeKind.tkDynArray, TTypeKind.tkArray:
//        begin
//          // array
//          SetLength(tvArray, TJSONArray(JsonValue).Count);
//          if rttiType is TRttiArrayType then
//            elementType := TRttiArrayType(rttiType).elementType
//          else
//            elementType := TRttiDynamicArrayType(rttiType).elementType;
//          for I := 0 to Length(tvArray) - 1 do
//            tvArray[I] := JSONToTValue(TJSONArray(JsonValue).Items[I],
//              elementType);
//          Exit(TValue.FromArray(rttiType.Handle, tvArray));
//        end;
//      TTypeKind.tkRecord, TTypeKind.tkMRecord:
//        begin
//          TValue.Make(nil, rttiType.Handle, Data);
//          // match the fields with the array elements
//          I := 0;
//          for recField in rttiType.GetFields do
//          begin
//            Instance := Data.GetReferenceToRawData;
//            try
//              jsonFieldVal := TJSONArray(JsonValue).Items[I];
//            except
//              on e: Exception do
//                if e is EArgumentOutOfRangeException then
//                  continue
//                else
//                  raise;
//            end;
//            // check for type reverter
//            ClassType := nil;
//            if recField.FieldType.IsInstance then
//              ClassType := recField.FieldType.AsInstance.MetaclassType;
//            if (ClassType <> nil) then
//            begin
//              if HasReverter(ClassType, FIELD_ANY) then
//                RevertType(recField, Instance,
//                  Reverter(ClassType, FIELD_ANY),
//                  jsonFieldVal)
//              else
//              begin
//                attrRev := FieldTypeReverter(recField.FieldType);
//                if attrRev = nil then
//                  attrRev := FieldReverter(recField);
//                if attrRev <> nil then
//                  try
//                    RevertType(recField, Instance, attrRev, jsonFieldVal)
//                  finally
//                    attrRev.Free
//                  end
//                else
//                  recField.SetValue(Instance, JSONToTValue(jsonFieldVal,
//                    recField.FieldType));
//              end
//            end
//            else
//              recField.SetValue(Instance, JSONToTValue(jsonFieldVal,
//                recField.FieldType));
//            Inc(I);
//          end;
//          Exit(Data);
//        end;
//    end;
//  end;
//
//  // transform value string into TValue based on type info
//  Exit(StringToTValue(Value, rttiType.Handle));
//end;

//          //          L := 2;
//          //          DynArraySetLength(PPointer(@_record)^, TypeInfo(Z), 1, @L);

class function TJSONGenerics.getParsedJSON<T>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(jsonAsString: string): T;
begin
  Result := TJSONGenerics.getParsedJSON<T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, T>(jsonAsString);
end;

class function TJSONGenerics.getParsedJSON
  <T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>
  (jsonAsString: string): T;
var
  _record: T;

  _ignoreAttribute: boolean;

  _propertyName: string;
  _propertyType: string;
  _propertyValue: Variant;

  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _customAttributes: TArray<TCustomAttribute>;
  _customAttribute: TCustomAttribute;
  _rttiField: TRttiField;

  _JSONFile: TBytes;
  _JSONMain: TJSONValue;
  _string: string;
  _integer: integer;
  _double: double;
  _boolean: boolean;

  _subObject: TJSONObject;
  _T_sub: T;
  _U_sub: U;
  _V_sub: V;
  _W_sub: W;
  _X_sub: X;
  _Y_sub: Y;
  _Z_sub: Z;
  _A_sub: A;
  _B_sub: B;
  _C_sub: C;
  _D_sub: D;
  _E_sub: E;
  _F_sub: F;
  _G_sub: G;
  _H_sub: H;
  _I_sub: I;
  _J_sub: J;
  _K_sub: K;
  _L_sub: L;
  _M_sub: M;
  _N_sub: N;
  _O_sub: O;
  _P_sub: P;
  _Q_sub: Q;
  _R_sub: R;
  _S_sub: S;

  _propertyExists: boolean;

  _newTValue: TValue;

  _arrayOfTValue: array of TValue;
  _subArray: TJSONArray;
  _arrayType: string;

  _i: integer;
begin
  _record := KLib.Generics.TGenerics.getDefault<T>;

  _JSONFile := TEncoding.ASCII.GetBytes(jsonAsString);
  _JSONMain := TJSONObject.ParseJSONValue(_JSONFile, 0);

  _rttiContext := TRttiContext.Create;
  try
    if Assigned(_JSONMain) then
    begin
      _rttiType := _rttiContext.GetType(TypeInfo(T));

      for _rttiField in _rttiType.GetFields do
      begin
        _propertyName := _rttiField.Name;
        _propertyType := _rttiField.FieldType.ToString;

        VarClear(_propertyValue);

        _ignoreAttribute := false;
        _customAttributes := _rttiField.GetAttributes;
        for _customAttribute in _customAttributes do
        begin
          if _customAttribute is IgnoreAttribute then
          begin
            _ignoreAttribute := true;
          end;
        end;

        if not _ignoreAttribute then
        begin
          if (_propertyType = 'string') or (_propertyType = 'Char') then
          begin
            if _JSONMain.TryGetValue(_propertyName, _string) then
            begin
              _propertyValue := _string;
            end;
          end
          else if (_propertyType = 'Integer') or (_propertyType = 'Word') then
          begin
            if _JSONMain.TryGetValue(_propertyName, _integer) then
            begin
              _propertyValue := _integer;
            end;
          end
          else if _propertyType = 'Double' then
          begin
            if _JSONMain.TryGetValue(_propertyName, _double) then
            begin
              _propertyValue := _double;
            end;
          end
          else if _propertyType = 'Boolean' then
          begin
            if _JSONMain.TryGetValue(_propertyName, _boolean) then
            begin
              _propertyValue := _boolean;
            end;
          end
          else if _rttiField.FieldType.TypeKind = tkDynArray then
          begin
            try
              _subArray := _JSONMain.GetValue<TJSONArray>(_propertyName);
              SetLength(_arrayOfTValue, _subArray.Count);
              for _i := 0 to _subArray.Count - 1 do
              begin
                _arrayType := TRttiDynamicArrayType(_rttiField.FieldType).elementType.ToString;

                //  _X_sub: X;
                //  _Y_sub: Y;
                //  _Z_sub: Z;
                //  _A_sub: A;
                //  _B_sub: B;
                //  _C_sub: C;
                //  _D_sub: D;
                //  _E_sub: E;
                //  _F_sub: F;
                //  _G_sub: G;
                //  _H_sub: H;
                //  _I_sub: I;
                //  _J_sub: J;
                //  _K_sub: K;
                //  _L_sub: L;
                //  _M_sub: M;
                //  _N_sub: N;
                //  _O_sub: O;
                //  _P_sub: P;
                //  _Q_sub: Q;
                //  _R_sub: R;
                //  _S_sub: S;
                //              T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S

                if _arrayType = _rttiContext.GetType(TypeInfo(T)).ToString then
                begin
                  _T_sub := TJSONGenerics.getParsedJSON
                    <T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(_subArray.Items[_i].ToString);
                  TValue.Make(@_T_sub, TypeInfo(T), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(U)).ToString then
                begin
                  _U_sub := TJSONGenerics.getParsedJSON
                    <U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(_subArray.Items[_i].ToString);
                  TValue.Make(@_U_sub, TypeInfo(U), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(V)).ToString then
                begin
                  _V_sub := TJSONGenerics.getParsedJSON
                    <V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>(_subArray.Items[_i].ToString);
                  TValue.Make(@_V_sub, TypeInfo(V), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(X)).ToString then
                begin
                  _X_sub := TJSONGenerics.getParsedJSON
                    <X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W>(_subArray.Items[_i].ToString);
                  TValue.Make(@_X_sub, TypeInfo(X), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(Y)).ToString then
                begin
                  _Y_sub := TJSONGenerics.getParsedJSON
                    <Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X>(_subArray.Items[_i].ToString);
                  TValue.Make(@_Y_sub, TypeInfo(Y), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(Z)).ToString then
                begin
                  _Z_sub := TJSONGenerics.getParsedJSON
                    <Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y>(_subArray.Items[_i].ToString);
                  TValue.Make(@_Z_sub, TypeInfo(Z), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(A)).ToString then
                begin
                  _A_sub := TJSONGenerics.getParsedJSON
                    <A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z>(_subArray.Items[_i].ToString);
                  TValue.Make(@_A_sub, TypeInfo(A), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(B)).ToString then
                begin
                  _B_sub := TJSONGenerics.getParsedJSON
                    <B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A>(_subArray.Items[_i].ToString);
                  TValue.Make(@_B_sub, TypeInfo(B), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(C)).ToString then
                begin
                  _C_sub := TJSONGenerics.getParsedJSON
                    <C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B>(_subArray.Items[_i].ToString);
                  TValue.Make(@_C_sub, TypeInfo(C), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(D)).ToString then
                begin
                  _D_sub := TJSONGenerics.getParsedJSON
                    <D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C>(_subArray.Items[_i].ToString);
                  TValue.Make(@_D_sub, TypeInfo(D), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(E)).ToString then
                begin
                  _E_sub := TJSONGenerics.getParsedJSON
                    <E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D>(_subArray.Items[_i].ToString);
                  TValue.Make(@_E_sub, TypeInfo(E), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(F)).ToString then
                begin
                  _F_sub := TJSONGenerics.getParsedJSON
                    <F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E>(_subArray.Items[_i].ToString);
                  TValue.Make(@_F_sub, TypeInfo(F), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(G)).ToString then
                begin
                  _G_sub := TJSONGenerics.getParsedJSON
                    <G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F>(_subArray.Items[_i].ToString);
                  TValue.Make(@_G_sub, TypeInfo(G), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(H)).ToString then
                begin
                  _H_sub := TJSONGenerics.getParsedJSON
                    <H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>(_subArray.Items[_i].ToString);
                  TValue.Make(@_H_sub, TypeInfo(H), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(I)).ToString then
                begin
                  _I_sub := TJSONGenerics.getParsedJSON
                    <I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>(_subArray.Items[_i].ToString);
                  TValue.Make(@_I_sub, TypeInfo(I), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(J)).ToString then
                begin
                  _J_sub := TJSONGenerics.getParsedJSON
                    <J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>(_subArray.Items[_i].ToString);
                  TValue.Make(@_J_sub, TypeInfo(J), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(K)).ToString then
                begin
                  _K_sub := TJSONGenerics.getParsedJSON
                    <K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>(_subArray.Items[_i].ToString);
                  TValue.Make(@_K_sub, TypeInfo(K), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(L)).ToString then
                begin
                  _L_sub := TJSONGenerics.getParsedJSON
                    <L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>(_subArray.Items[_i].ToString);
                  TValue.Make(@_L_sub, TypeInfo(L), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(M)).ToString then
                begin
                  _M_sub := TJSONGenerics.getParsedJSON
                    <M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>(_subArray.Items[_i].ToString);
                  TValue.Make(@_M_sub, TypeInfo(M), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(N)).ToString then
                begin
                  _N_sub := TJSONGenerics.getParsedJSON
                    <N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>(_subArray.Items[_i].ToString);
                  TValue.Make(@_N_sub, TypeInfo(N), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(O)).ToString then
                begin
                  _O_sub := TJSONGenerics.getParsedJSON
                    <O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>(_subArray.Items[_i].ToString);
                  TValue.Make(@_O_sub, TypeInfo(O), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(P)).ToString then
                begin
                  _P_sub := TJSONGenerics.getParsedJSON
                    <P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(_subArray.Items[_i].ToString);
                  TValue.Make(@_P_sub, TypeInfo(P), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(Q)).ToString then
                begin
                  _Q_sub := TJSONGenerics.getParsedJSON
                    <Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(_subArray.Items[_i].ToString);
                  TValue.Make(@_Q_sub, TypeInfo(Q), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(R)).ToString then
                begin
                  _R_sub := TJSONGenerics.getParsedJSON
                    <R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(_subArray.Items[_i].ToString);
                  TValue.Make(@_R_sub, TypeInfo(R), _newTValue);
                end
                else if _arrayType = _rttiContext.GetType(TypeInfo(S)).ToString then
                begin
                  _S_sub := TJSONGenerics.getParsedJSON
                    <S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(_subArray.Items[_i].ToString);
                  TValue.Make(@_S_sub, TypeInfo(S), _newTValue);
                end;

                _arrayOfTValue[_i] := _newTValue;
              end;

              if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(T), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(U)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(U), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(V)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(V), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(W)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(W), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(X)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(X), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Y)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(Y), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Z)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(Z), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(A)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(A), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(B)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(B), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(C)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(C), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(D)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(D), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(E)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(E), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(F)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(F), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(G)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(G), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(H)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(H), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(I)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(I), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(J)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(J), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(K)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(K), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(L)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(L), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(M)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(M), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(N)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(N), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(O)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(O), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(P)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(P), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Q)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(Q), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(R)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(R), _arrayOfTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(S)).ToString then
              begin
                _newTValue := TValue.FromArray(TypeInfo(S), _arrayOfTValue);
              end;

              _rttiField.SetValue(@_record, _newTValue);
            except
              on E: Exception do
              begin
                _string := _string; //try except only for debug
              end;
            end;
          end
          else
          begin
            try
              _subObject := _JSONMain.GetValue<TJSONObject>(_propertyName);
              _propertyExists := true;
              if _propertyType = _rttiContext.GetType(TypeInfo(T)).ToString then
              begin
                _T_sub := TJSONGenerics.getParsedJSON
                  <T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(_subObject.ToString);
                TValue.Make(@_T_sub, TypeInfo(T), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(U)).ToString then
              begin
                _U_sub := TJSONGenerics.getParsedJSON
                  <U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(_subObject.ToString);
                TValue.Make(@_U_sub, TypeInfo(U), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(V)).ToString then
              begin
                _V_sub := TJSONGenerics.getParsedJSON
                  <V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>(_subObject.ToString);
                TValue.Make(@_V_sub, TypeInfo(V), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(X)).ToString then
              begin
                _X_sub := TJSONGenerics.getParsedJSON
                  <X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W>(_subObject.ToString);
                TValue.Make(@_X_sub, TypeInfo(X), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Y)).ToString then
              begin
                _Y_sub := TJSONGenerics.getParsedJSON
                  <Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X>(_subObject.ToString);
                TValue.Make(@_Y_sub, TypeInfo(Y), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Z)).ToString then
              begin
                _Z_sub := TJSONGenerics.getParsedJSON
                  <Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y>(_subObject.ToString);
                TValue.Make(@_Z_sub, TypeInfo(Z), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(A)).ToString then
              begin
                _A_sub := TJSONGenerics.getParsedJSON
                  <A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z>(_subObject.ToString);
                TValue.Make(@_A_sub, TypeInfo(A), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(B)).ToString then
              begin
                _B_sub := TJSONGenerics.getParsedJSON
                  <B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A>(_subObject.ToString);
                TValue.Make(@_B_sub, TypeInfo(B), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(C)).ToString then
              begin
                _C_sub := TJSONGenerics.getParsedJSON
                  <C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B>(_subObject.ToString);
                TValue.Make(@_C_sub, TypeInfo(C), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(D)).ToString then
              begin
                _D_sub := TJSONGenerics.getParsedJSON
                  <D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C>(_subObject.ToString);
                TValue.Make(@_D_sub, TypeInfo(D), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(E)).ToString then
              begin
                _E_sub := TJSONGenerics.getParsedJSON
                  <E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D>(_subObject.ToString);
                TValue.Make(@_E_sub, TypeInfo(E), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(F)).ToString then
              begin
                _F_sub := TJSONGenerics.getParsedJSON
                  <F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E>(_subObject.ToString);
                TValue.Make(@_F_sub, TypeInfo(F), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(G)).ToString then
              begin
                _G_sub := TJSONGenerics.getParsedJSON
                  <G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F>(_subObject.ToString);
                TValue.Make(@_G_sub, TypeInfo(G), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(H)).ToString then
              begin
                _H_sub := TJSONGenerics.getParsedJSON
                  <H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G>(_subObject.ToString);
                TValue.Make(@_H_sub, TypeInfo(H), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(I)).ToString then
              begin
                _I_sub := TJSONGenerics.getParsedJSON
                  <I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H>(_subObject.ToString);
                TValue.Make(@_I_sub, TypeInfo(I), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(J)).ToString then
              begin
                _J_sub := TJSONGenerics.getParsedJSON
                  <J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I>(_subObject.ToString);
                TValue.Make(@_J_sub, TypeInfo(J), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(K)).ToString then
              begin
                _K_sub := TJSONGenerics.getParsedJSON
                  <K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J>(_subObject.ToString);
                TValue.Make(@_K_sub, TypeInfo(K), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(L)).ToString then
              begin
                _L_sub := TJSONGenerics.getParsedJSON
                  <L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K>(_subObject.ToString);
                TValue.Make(@_L_sub, TypeInfo(L), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(M)).ToString then
              begin
                _M_sub := TJSONGenerics.getParsedJSON
                  <M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L>(_subObject.ToString);
                TValue.Make(@_M_sub, TypeInfo(M), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(N)).ToString then
              begin
                _N_sub := TJSONGenerics.getParsedJSON
                  <N, O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M>(_subObject.ToString);
                TValue.Make(@_N_sub, TypeInfo(N), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(O)).ToString then
              begin
                _O_sub := TJSONGenerics.getParsedJSON
                  <O, P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N>(_subObject.ToString);
                TValue.Make(@_O_sub, TypeInfo(O), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(P)).ToString then
              begin
                _P_sub := TJSONGenerics.getParsedJSON
                  <P, Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(_subObject.ToString);
                TValue.Make(@_P_sub, TypeInfo(P), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(Q)).ToString then
              begin
                _Q_sub := TJSONGenerics.getParsedJSON
                  <Q, R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(_subObject.ToString);
                TValue.Make(@_Q_sub, TypeInfo(Q), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(R)).ToString then
              begin
                _R_sub := TJSONGenerics.getParsedJSON
                  <R, S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(_subObject.ToString);
                TValue.Make(@_R_sub, TypeInfo(R), _newTValue);
              end
              else if _propertyType = _rttiContext.GetType(TypeInfo(S)).ToString then
              begin
                _S_sub := TJSONGenerics.getParsedJSON
                  <S, T, U, V, W, X, Y, Z, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(_subObject.ToString);
                TValue.Make(@_S_sub, TypeInfo(S), _newTValue);
              end
              else
              begin
                _propertyExists := false;
              end;

              if _propertyExists then
              begin
                _rttiField.SetValue(@_record, _newTValue);
              end;
            except
              on E: Exception do
              begin
                _string := _string; //try except only for debug
              end;
            end;
          end;

          if (not VarIsEmpty(_propertyValue)) then
          begin
            _rttiField.SetValue(@_record, TValue.FromVariant(_propertyValue));
          end;
        end
      end;
    end;

    //  except
    //    { ... Do something here ... }
    //  end;

  finally
    begin
      _rttiContext.Free;
      FreeAndNil(_JSONMain);
    end;
  end;

  Result := _record;
end;

end.
