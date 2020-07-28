unit KLib.Validate;

interface

uses
  System.RegularExpressions, Vcl.StdCtrls, System.SysUtils, Vcl.Forms, RzEdit, cxTextEdit, cxMaskEdit,
  KLib.Types;
//------REGEX----------
function isValidEmail(email: string): boolean;
//-------------------
procedure tryToValidate(validatingProcedure: TProcedureOfObject; errorLabel: TLabel);
procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TRzEdit; fieldName: string); overload;
procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TcxTextEdit; fieldName: string); overload;
procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TcxMaskEdit; fieldName: string); overload;

implementation

const
  REGEX_VALID_EMAIL = '([!#-''*+/-9=?A-Z^-~-]+(\.[!#-''*+/-9=?A-Z^-~-]+)*|"([]!#-[^-~ \t]|(\\[\t -~]))+")@([0'
    + '-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?(\.[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])'
    + '?)*|\[((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1'
    + '-9]?[0-9])){3}|IPv6:((((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){6}|::((0|[1-9A-Fa-f][0-9A-Fa-'
    + 'f]{0,3}):){5}|[0-9A-Fa-f]{0,4}::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){4}|(((0|[1-9A-Fa-f]'
    + '[0-9A-Fa-f]{0,3}):)?(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}'
    + '):){3}|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,2}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::((0|'
    + '[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){2}|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,3}(0|[1-9A-Fa-'
    + 'f][0-9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,'
    + '3}):){0,4}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::)((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):(0|[1-9'
    + 'A-Fa-f][0-9A-Fa-f]{0,3})|(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4]'
    + '[0-9]|1[0-9]{2}|[1-9]?[0-9])){3})|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,5}(0|[1-9A-Fa-'
    + 'f][0-9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3})|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3'
    + '}):){0,6}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::)|(?!IPv6:)[0-9A-Za-z-]*[0-9A-Za-z]:[!-Z^-'
    + '~]+)])';

function isValidEmail(email: string): boolean;
begin
  if TRegEx.IsMatch(email, REGEX_VALID_EMAIL) then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

procedure tryToValidate(validatingProcedure: TProcedureOfObject; errorLabel: TLabel);
begin
  try
    validatingProcedure;
    errorLabel.Visible := false;
  except
    on E: Exception do
    begin
      errorLabel.Caption := e.Message;
      errorLabel.Visible := true;
    end;
  end;
end;

procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TRzEdit; fieldName: string);
begin
  if myEdit.Text = '' then
  begin
    myForm.FocusControl(myEdit);
    raise Exception.Create('Il campo ' + QuotedStr(fieldName) + ' non può essere nullo');
  end;
end;

procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TcxTextEdit; fieldName: string);
begin
  if myEdit.Text = '' then
  begin
    myForm.FocusControl(myEdit);
    raise Exception.Create('Il campo ' + QuotedStr(fieldName) + ' non può essere nullo');
  end;
end;

procedure exceptionIfEditIsBlank(myForm: TForm; myEdit: TcxMaskEdit; fieldName: string);
begin
  if myEdit.Text = '' then
  begin
    myForm.FocusControl(myEdit);
    raise Exception.Create('Il campo ' + QuotedStr(fieldName) + ' non può essere nullo');
  end;
end;

end.
