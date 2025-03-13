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

unit KLib.ZPLPrinter;

interface

uses

  KLib.Types;

type

  TZPLPrinter = class
  private
    hostPort: THostPort;
  public
    constructor create(hostPort: THostPort);

    procedure printFromFile(filename: string);
    procedure print(texts: TArray<string>); overload;
    procedure print(text: string); overload;
    procedure updateConfig(const hostPort: THostPort);
  end;

implementation

uses
  KLib.Indy, KLib.Constants, KLib.Utils,
  System.SysUtils;

constructor TZPLPrinter.create(hostPort: THostPort);
begin
  updateConfig(hostPort);
end;

procedure TZPLPrinter.printFromFile(filename: string);
begin
  TCPPrintFromFile(hostPort, filename);
end;

procedure TZPLPrinter.print(texts: TArray<string>);
var
  _text: string;
  _textMod: string;
begin
  for _text in texts do
  begin
    _textMod := myStringReplace(_text, START_ZPL_CMD, EMPTY_STRING,
      [rfReplaceAll]);
    _textMod :=
      START_ZPL_CMD + sLineBreak +
      RESET_ZPL_CMD + sLineBreak +
      _text;
    print(_textMod);
  end;
end;

procedure TZPLPrinter.print(text: string);
begin
  TCPPrintText(hostPort, text);
end;

procedure TZPLPrinter.updateConfig(const hostPort: THostPort);
begin
  Self.hostPort := hostPort;
end;

end.
