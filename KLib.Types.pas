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

unit KLib.Types;

interface

uses
  Vcl.Graphics,
  IdFTPCommon,
  System.Generics.Collections, System.SysUtils;

const
  ftASCII = TIdFTPTransferType(0);
  ftBinary = TIdFTPTransferType(1);

type
{$scopedenums ON}
  TTypeOfProcedure = (_null, _procedure, _method, _anonymousMethod);

  TAsyncMethodStatus = (_null, created, pending, fulfilled, rejected);

  TStatus = (_null, created, stopped, paused, running);

  TExecutionMode = (_null, desktop, service, cli);

  TType = (_null, _string, _integer, _double, _char, _boolean);

  TFileSystemTimeType = (created, modified, accessed);

  TWindowsServiceStartupType = (_null, delayed_auto, auto, manual, disabled);

  TEmailProvider = (custom, gmail, outlook);

  TContentType = (text_plain, text_html);
{$scopedenums OFF}

  TOAuth2Response = record
  public
    access_token: string;
    token_type: string;
    [DefaultValueAttribute('0')]
    expires_in: integer;
    [DefaultValueAttribute(EMPTY_STRING)]
    refresh_token: string;
    [DefaultValueAttribute(EMPTY_STRING)]
    scope: string;

    procedure readFromFile(filename: string);
    procedure saveToFile(filename: string);
    function getAsString(): string;
    procedure clear;
  end;

  TSMTPSettings = record
    host: string;
    port: Integer;
    useTls: Boolean;
    username: string;
    password: string;
    accessToken: string;
    provider: TEmailProvider;

    procedure clear;
  end;

  TEmailMessage = record
    fromAddress: string;
    toAddresses: TArray<string>;
    ccAddresses: TArray<string>;
    bccAddresses: TArray<string>;
    subject: string;
    body: string;
    signature: string;
    attachments: TArray<string>;

    contentType: TContentType;

    procedure clear;
  end;

  THostPort = record
    host: string;
    port: integer;

    procedure clear;
  end;

  TCredentials = record
    username: string;
    password: string;

    function isEmpty: Boolean;
    procedure clear;
  end;

  TFTPCredentials = record
    credentials: TCredentials;
    server: string;
    pathFTPDir: string;
    port: integer;
    transferType: TIdFTPTransferType;

    procedure clear;
  end;

  TDownloadInfo = record
    link: string;
    alternative_links: array of string;
    fileName: string;
    typeFile: string;
    MD5: string;

    procedure clear;
  end;

  TArrayOfDownloadInfo = array of TDownloadInfo;

  TPIDCredentials = record
    ownerUserName: string;
    domain: string;

    procedure clear;
  end;

  TColorButtom = record
    enabled: TColor;
    disabled: TColor;

    procedure clear;
  end;

  TPosition = record
    top: integer;
    bottom: integer;
    left: integer;
    right: integer;

    procedure clear;
  end;

  TSize = record
    length: double;
    width: double;
    height: double;

    function lengthAsInteger: integer;
    function widthAsInteger: integer;
    function heightAsInteger: integer;
    procedure clear;
  end;

  TCodeDescription = record
    description: string;
    code: string;

    procedure clear;
  end;

  TDateTimeRange = record
    _start: TDateTime;
    _end: TDateTime;
    function getAsString: string;

    procedure clear;
  end;

  TResource = record
    name: string;
    _type: string;

    procedure clear;
  end;

  TOnChangeStatus =
    reference to procedure(newStatus: TStatus = TStatus._null);

  TMethod = procedure of object;
  TArrayOfMethods = array of TMethod;

  TProcedure = procedure;
  TArrayOfProcedures = array of TProcedure;

  TAnonymousMethod = reference to procedure;
  TArrayOfAnonymousMethods = array of TAnonymousMethod;

  TCallBack = reference to procedure(msg: string = '');

  TCallBacks = record
    resolve: TCallBack;
    reject: TCallBack;

    procedure clear;
  end;

  TExecutorFunction = reference to procedure(resolve: TCallBack; reject: TCallback);

  TAsyncifyMethodReply = record
    handle: THandle;
    msg_resolve: Cardinal;
    msg_reject: Cardinal;

    procedure clear;
  end;

  TListOfDoubles = class(TList<Double>)
  end;

  TArrayOfStrings = TArray<string>;

  TArrayOfWord = array of Word;

  EExit = class(EAbort);
  //####--EXAMPLE USE
  //    raise EExit.Create('force exit in reject procedure');
  //            if (e.ClassType <> EExit) then
  //            begin
  //              reject(e.Message);
  //            end;
  //####---

implementation

uses

  KLib.Utils, KLib.Generics.JSON, KLib.Constants;

procedure TOAuth2Response.readFromFile(filename: string);
var
  _text: string;
begin
  _text := getTextFromFile(filename);
  Self := TJSONGenerics.getParsedJSON<TOAuth2Response>(_text);
end;

procedure TOAuth2Response.saveToFile(filename: string);
var
  _text: string;
begin
  _text := getAsString();
  KLib.Utils.saveToFile(_text, filename);
end;

function TOAuth2Response.getAsString(): string;
begin
  Result := TJSONGenerics.getJSONAsString<TOAuth2Response>(Self);
end;

procedure TOAuth2Response.clear();
begin
  access_token := EMPTY_STRING;
  token_type := EMPTY_STRING;
  expires_in := 0;
  refresh_token := EMPTY_STRING;
  scope := EMPTY_STRING;
end;

procedure TSMTPSettings.clear;
const
  EMPTY: TSMTPSettings = ();
begin
  Self := EMPTY;
  Self.provider := TEmailProvider.custom;
end;

procedure TEmailMessage.clear;
const
  EMPTY: TEmailMessage = ();
begin
  Self := EMPTY;
end;

function TDateTimeRange.getAsString: string;
var
  _startDataTimeAsString: string;
  _endDataTimeAsString: string;
begin
  _startDataTimeAsString := DateTimeToStr(self._start);
  _endDataTimeAsString := DateTimeToStr(self._end);

  Result := _startDataTimeAsString + ' - ' + _endDataTimeAsString;
end;

procedure THostPort.clear;
const
  EMPTY: THostPort = ();
begin
  Self := EMPTY;
end;

function TCredentials.isEmpty: boolean;
const
  EMPTY: TCredentials = ();
begin
  Result := (Self.username = '') and (Self.password = '');
end;

procedure TCredentials.clear;
const
  EMPTY: TCredentials = ();
begin
  Self := EMPTY;
end;

procedure TFTPCredentials.clear;
const
  EMPTY: TFTPCredentials = ();
begin
  Self := EMPTY;
end;

procedure TDownloadInfo.clear;
const
  EMPTY: TDownloadInfo = ();
begin
  Self := EMPTY;
end;

procedure TPIDCredentials.clear;
const
  EMPTY: TPIDCredentials = ();
begin
  Self := EMPTY;
end;

procedure TColorButtom.clear;
const
  EMPTY: TColorButtom = ();
begin
  Self := EMPTY;
end;

procedure TPosition.clear;
const
  EMPTY: TPosition = ();
begin
  Self := EMPTY;
end;

function TSize.lengthAsInteger: integer;
begin
  Result := trunc(length);
end;

function TSize.widthAsInteger: integer;
begin
  Result := trunc(width);
end;

function TSize.heightAsInteger: integer;
begin
  Result := trunc(height);
end;

procedure TSize.clear;
const
  EMPTY: TSize = ();
begin
  Self := EMPTY;
end;

procedure TCodeDescription.clear;
const
  EMPTY: TCodeDescription = ();
begin
  Self := EMPTY;
end;

procedure TDateTimeRange.clear;
const
  EMPTY: TDateTimeRange = ();
begin
  Self := EMPTY;
end;

procedure TResource.clear;
const
  EMPTY: TResource = ();
begin
  Self := EMPTY;
end;

procedure TCallBacks.clear;
const
  EMPTY: TCallBacks = ();
begin
  Self := EMPTY;
end;

procedure TAsyncifyMethodReply.clear;
const
  EMPTY: TAsyncifyMethodReply = ();
begin
  Self := EMPTY;
end;

end.
