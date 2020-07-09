unit KLib.Types;

interface

type
  TCredentials = record
    username: string;
    password: string;
  end;

  TProcedureOfObject = procedure of object;

  TAsyncifyProcedureReply = record
    handle: THandle;
    msg_resolve: Cardinal;
    msg_reject: Cardinal;
  end;

  TPIDCredentials = record
    ownerUserName: string;
    domain: string;
  end;

implementation

end.
