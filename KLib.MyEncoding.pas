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

unit KLib.MyEncoding;

interface

uses
  System.SysUtils, System.Classes;

type
  TUTF8NoBOMEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TMyEncoding = class(TEncoding)
  private
    class var FUTF8NoBomEncoding: TEncoding;
    class function GetUTF8NoBom: TEncoding; static;
  public
    class function IsStandardEncoding(AEncoding: TEncoding): Boolean; static;
    class procedure FreeEncodings;
    class property UTF8NoBom: TEncoding read GetUTF8NoBom;
  end;

implementation

function TUTF8NoBOMEncoding.getPreamble: TBytes;
begin
  SetLength(Result, 0);
end;

class function TMyEncoding.GetUTF8NoBom: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUTF8NoBomEncoding = nil then
  begin
    LEncoding := TUTF8NoBOMEncoding.Create;
    if AtomicCmpExchange(Pointer(FUTF8NoBomEncoding), Pointer(LEncoding), nil) <> nil then
      LEncoding.Free
{$ifdef AUTOREFCOUNT}
    else
      FUTF8NoBomEncoding.__ObjAddRef
{$endif AUTOREFCOUNT};
  end;
  Result := FUTF8NoBomEncoding;
end;

class function TMyEncoding.IsStandardEncoding(AEncoding: TEncoding): Boolean;
begin
  Result := inherited;
  Result := Result or (AEncoding = FUTF8NoBomEncoding);
end;

class procedure TMyEncoding.FreeEncodings;
begin
  inherited;
  FreeAndNil(FUTF8NoBomEncoding);
end;

end.
