unit KLib.Types;

interface

uses
  Vcl.Graphics, IdFTPCommon;

type

  TCredentials = record
    username: string;
    password: string;
  end;

  TFTPCredentials = record
    credentials: TCredentials;
    server: string;
    pathFTPDir: string;
    transferType: TIdFTPTransferType;
  end;

  TDownloadInfo = record
    link: string;
    fileName: string;
    typeFile: string;
    md5: string;
  end;

  TPIDCredentials = record
    ownerUserName: string;
    domain: string;
  end;

  TColorButtom = record
    enabled: TColor;
    disabled: TColor;
  end;

  TArrayOfDownloadInfo = array of TDownloadInfo;

  TProcedureOfObject = procedure of object;
  TArrayOfObjectProcedures = array of TProcedureOfObject;

  TProcedure = reference to procedure;
  TArrayOfProcedures = array of TProcedure;

  TCallBack = reference to procedure(msg: String = '');

  TCallBacks = record
    resolve: TCallBack;
    reject: TCallBack;
  end;

  TAsyncifyProcedureReply = record
    handle: THandle;
    msg_resolve: Cardinal;
    msg_reject: Cardinal;
  end;

implementation

end.
