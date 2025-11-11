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

unit KLib.Crypto;

interface

uses
  System.SysUtils;

function encryptString(value: string; key: string): string;
function decryptString(value: string; key: string): string;

implementation

uses
  System.Hash, System.NetEncoding;

function encryptString(value: string; key: string): string;
var
  _hashedKey: string;
  _xorBytes: TBytes;
  _i: Integer;
begin
  _hashedKey := THashSHA2.GetHashString(key);
  _xorBytes := TEncoding.UTF8.GetBytes(value);
  for _i := 0 to Length(_xorBytes) - 1 do
  begin
    _xorBytes[_i] := _xorBytes[_i] xor Byte(_hashedKey[(_i mod Length(_hashedKey)) + 1]);
  end;
  Result := TNetEncoding.Base64.EncodeBytesToString(_xorBytes);
end;

function decryptString(value: string; key: string): string;
var
  _hashedKey: string;
  _xorBytes: TBytes;
  _i: Integer;
begin
  _hashedKey := THashSHA2.GetHashString(key);
  _xorBytes := TNetEncoding.Base64.DecodeStringToBytes(value);
  for _i := 0 to Length(_xorBytes) - 1 do
  begin
    _xorBytes[_i] := _xorBytes[_i] xor Byte(_hashedKey[(_i mod Length(_hashedKey)) + 1]);
  end;
  Result := TEncoding.UTF8.GetString(_xorBytes);
end;

end.
