unit KLib.Types;

interface

uses
  Vcl.Graphics;

type
  TCredentials = record
    username: string;
    password: string;
  end;

  TProcedureOfObject = procedure of object;

  TArrayOfProcedures = array of TProcedureOfObject;

  TAsyncifyProcedureReply = record
    handle: THandle;
    msg_resolve: Cardinal;
    msg_reject: Cardinal;
  end;

  TPIDCredentials = record
    ownerUserName: string;
    domain: string;
  end;

  TColorButtom = record
    enabled: TColor;
    disabled: TColor;
  end;

implementation

end.
