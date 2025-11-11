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

unit KLib.Asyncify;

interface

uses
  KLib.Types;

procedure asyncify(executor: KLib.Types.TMethod); overload;
procedure asyncify(executor: KLib.Types.TProcedure); overload;
procedure asyncify(executor: KLib.Types.TAnonymousMethod); overload;

procedure asyncify(executor: KLib.Types.TMethod; myCallBacks: KLib.Types.TCallbacks); overload;
procedure asyncify(executor: KLib.Types.TProcedure; myCallBacks: KLib.Types.TCallbacks); overload;
procedure asyncify(executor: KLib.Types.TAnonymousMethod; myCallBacks: KLib.Types.TCallbacks); overload;

procedure asyncify(executor: KLib.Types.TMethod; myResolve: TCallBack; myReject: KLib.Types.TCallback); overload;
procedure asyncify(executor: KLib.Types.TProcedure; myResolve: KLib.Types.TCallBack; myReject: KLib.Types.TCallback); overload;

procedure asyncify(executor: KLib.Types.TAnonymousMethod; myResolve: TCallBack; myReject: KLib.Types.TCallback); overload;

//##################################################################################################

procedure asyncify(executor: KLib.Types.TMethod; reply: KLib.Types.TAsyncifyMethodReply); overload;
procedure asyncify(executor: KLib.Types.TProcedure; reply: KLib.Types.TAsyncifyMethodReply); overload;

procedure asyncify(executor: KLib.Types.TAnonymousMethod; reply: KLib.Types.TAsyncifyMethodReply); overload;

implementation

uses
  Winapi.Windows, Winapi.ActiveX,
  System.Classes, System.SysUtils;

procedure asyncify(executor: KLib.Types.TMethod);
begin
  asyncify(executor, KLib.Types.TCallBack(nil), KLib.Types.TCallback(nil));
end;

procedure asyncify(executor: KLib.Types.TProcedure);
begin
  asyncify(executor, KLib.Types.TCallBack(nil), KLib.Types.TCallback(nil));
end;

procedure asyncify(executor: KLib.Types.TAnonymousMethod);
begin
  asyncify(executor, KLib.Types.TCallBack(nil), KLib.Types.TCallback(nil));
end;

procedure asyncify(executor: KLib.Types.TMethod; myCallBacks: KLib.Types.TCallbacks);
begin
  asyncify(executor, KLib.Types.TCallBack(myCallBacks.resolve), KLib.Types.TCallback(myCallBacks.reject));
end;

procedure asyncify(executor: KLib.Types.TProcedure; myCallBacks: KLib.Types.TCallbacks);
begin
  asyncify(executor, KLib.Types.TCallBack(myCallBacks.resolve), KLib.Types.TCallback(myCallBacks.reject));
end;

procedure asyncify(executor: KLib.Types.TAnonymousMethod; myCallBacks: KLib.Types.TCallbacks);
begin
  asyncify(executor, KLib.Types.TCallBack(myCallBacks.resolve), KLib.Types.TCallback(myCallBacks.reject));
end;

procedure asyncify(executor: KLib.Types.TMethod; myResolve: KLib.Types.TCallBack; myReject: KLib.Types.TCallback);
begin
  asyncify(
    procedure
    begin
      executor;
    end,
    myResolve,
    myReject);
end;

procedure asyncify(executor: KLib.Types.TProcedure; myResolve: KLib.Types.TCallBack; myReject: KLib.Types.TCallback);
begin
  asyncify(
    procedure
    begin
      executor;
    end,
    myResolve,
    myReject);
end;

procedure asyncify(executor: KLib.Types.TAnonymousMethod; myResolve: KLib.Types.TCallBack; myReject: KLib.Types.TCallback);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        try
          executor;
          if Assigned(myResolve) then
          begin
            myResolve;
          end;
        except
          on E: Exception do
          begin
            if Assigned(myReject) then
            begin
              myReject(e.Message);
            end;
          end;
        end;
      finally
        CoUninitialize;
      end;
    end
    ).Start;
end;

//##################################################################################################

procedure asyncify(executor: KLib.Types.TMethod; reply: KLib.Types.TAsyncifyMethodReply);
begin
  asyncify(
    procedure
    begin
      executor;
    end,
    reply);
end;

procedure asyncify(executor: KLib.Types.TProcedure; reply: KLib.Types.TAsyncifyMethodReply);
begin
  asyncify(
    procedure
    begin
      executor;
    end,
    reply);
end;

procedure asyncify(executor: KLib.Types.TAnonymousMethod; reply: KLib.Types.TAsyncifyMethodReply);
var
  errorMsg_PString: PString;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      try
        try
          executor;
          PostMessage(reply.handle, reply.msg_resolve, 0, 0);
        except
          on E: Exception do
          begin
            New(errorMsg_PString);
            errorMsg_PString^ := E.Message;
            PostMessage(reply.handle, reply.msg_reject, 0, LParam(errorMsg_PString));
          end;
        end;
      finally
        CoUninitialize;
      end;
    end
    ).Start;
end;

end.
