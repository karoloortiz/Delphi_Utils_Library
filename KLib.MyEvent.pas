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

unit KLib.MyEvent;

interface

uses
  System.SyncObjs;

type
  TMyEvent = class(TEvent)
  private
    _value: boolean;
  protected
    procedure _set_value(myValue: boolean);
    function _get_value: boolean;
  public
    property value: boolean read _get_value write _set_value;
    constructor Create(initialValue: boolean = false); overload;
    procedure enable;
    procedure disable;
    procedure SetEvent;
    procedure ResetEvent;
    procedure waitForInfinite;
    destructor Destroy; override;
  end;

implementation

constructor TMyEvent.Create(initialValue: boolean = false);
begin
  inherited Create(nil, true, initialValue, '');
  _value := initialValue;
end;

procedure TMyEvent._set_value(myValue: boolean);
begin
  if myValue then
  begin
    SetEvent;
  end
  else
  begin
    ResetEvent;
  end;
end;

function TMyEvent._get_value: boolean;
begin
  Result := Self._value;
end;

procedure TMyEvent.enable;
begin
  SetEvent;
end;

procedure TMyEvent.disable;
begin
  ResetEvent;
end;

procedure TMyEvent.SetEvent;
begin
  inherited;
  _value := true;
end;

procedure TMyEvent.ResetEvent;
begin
  inherited;
  _value := false;
end;

procedure TMyEvent.waitForInfinite;
begin
  WaitFor(INFINITE);
end;

destructor TMyEvent.destroy;
begin
  inherited;
end;

end.
