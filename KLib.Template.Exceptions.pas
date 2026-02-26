unit KLib.Template.Exceptions;

interface

uses
  System.SysUtils;

type
  ETemplateError = class(Exception)
  public
    templateName: string;
    line: Integer;
    col: Integer;
    constructor create(const msg: string; const tplName: string; line: Integer; col: Integer);
  end;

  EBreakLoop = class(Exception);
  EContinueLoop = class(Exception);
  EStopTemplate = class(Exception)
  public
    output: string;
  end;

implementation

constructor ETemplateError.create(const msg: string; const tplName: string; line: Integer; col: Integer);
var
  _location: string;
begin
  Self.templateName := tplName;
  Self.line := line;
  Self.col := col;
  if tplName <> '' then
    _location := Format(' [%s:%d:%d]', [tplName, line, col])
  else
    _location := Format(' [line %d, col %d]', [line, col]);
  inherited Create(msg + _location);
end;

end.
