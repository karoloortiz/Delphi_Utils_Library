unit KLib.Graphics;

interface

uses
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.Windows;

type
  TLabelLoading = class
  private
    originalText: string;
    timer: TTimer;
    count: integer;
    lblSource: TLabel;
    procedure on_timer(Sender: TObject);
    procedure setLabelSource(const Value: TLabel);
    function getLabelSource: TLabel;
  public
    repeatMax: integer;
    textToRepeat: string;
    property labelSource: TLabel read getLabelSource write setLabelSource;
    constructor Create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3); overload;
    constructor Create(textToRepeat: string; countRepeatMax: integer = 3); overload;
    destructor Destroy; override;
    procedure start;
    procedure stop;
  end;

  TRGB = record
  private
    _red: integer;
    _green: integer;
    _blue: integer;
    procedure setRedColor(color: integer);
    procedure setGreenColor(color: integer);
    procedure setBlueColor(color: integer);
    function getValidColor(color: integer): integer;
  public
    property red: integer read _red write setRedColor;
    property green: integer read _green write setGreenColor;
    property blue: integer read _blue write setBlueColor;
    procedure loadFromString(colorString: String);
    procedure loadFromTColor(color: TColor);
    function getColorAsString: String;
    function getTColor: TColor;
  end;

function TColorToString(color: TColor): string;
function RGBStringToTColor(colorRGB: string): TColor;

procedure setLighterTColorToTPanel(component: TPanel; color: TColor; levelLighter: integer = 1);
procedure setDarkerTColorToTPanel(component: TPanel; color: TColor; levelLighter: integer = 1);
function getLighterTColor(color: TColor; levelLighter: integer = 1): TColor;
function getDarkerTColor(color: TColor; levelDarker: integer = 1): TColor;
procedure setTColorToTPanel(component: TPanel; color: TColor);
procedure makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; myString: String);
procedure setComponentInMiddlePosition(control: TControl);

function customMessageDlg(CONST Msg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons;
  Caption: ARRAY OF string; dlgcaption: string): Integer;

implementation

//-------------------------------------------------------------------------------------------------
//  TLabelLoading
//-------------------------------------------------------------------------------------------------
constructor TLabelLoading.Create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.labelSource := labelSource;
  Create(textToRepeat, countRepeatMax);
end;

constructor TLabelLoading.Create(textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.textToRepeat := textToRepeat;
  Self.repeatMax := countRepeatMax;
  Self.count := 0;
  Self.originalText := labelSource.Caption;
  timer := TTimer.Create(nil);
  Timer.Interval := 600;
  Timer.OnTimer := on_timer;
  Timer.Enabled := false;
end;

destructor TLabelLoading.Destroy;
begin
  FreeAndNil(timer);
  inherited Destroy;
end;

procedure TLabelLoading.setLabelSource(const Value: TLabel);
begin
  Self.stop;
  lblSource := Value;
  Self.originalText := Value.Caption;
  Self.start;
end;

function TLabelLoading.getLabelSource: TLabel;
begin
  Result := lblSource;
end;

procedure TLabelLoading.on_timer(Sender: TObject);
begin
  if (count = repeatMax) then
  begin
    labelSource.Caption := originalText;
    count := 0;
  end
  else
  begin
    labelSource.Caption := labelSource.Caption + textToRepeat;
    inc(count);
  end;
end;

procedure TLabelLoading.start;
begin
  timer.Enabled := true;
end;

procedure TLabelLoading.stop;
begin
  timer.Enabled := false;
  lblSource.Caption := originalText;
end;

//-------------------------------------------------------------------------------------------------
//  TRGB
//-------------------------------------------------------------------------------------------------
procedure TRGB.loadFromString(colorString: String);
begin
  red := StrToInt(copy(colorString, 1, 3));
  green := StrToInt(copy(colorString, 4, 3));
  blue := StrToInt(copy(colorString, 7, 3));
end;

procedure TRGB.loadFromTColor(color: TColor);
begin
  red := GetRValue(color);
  green := GetGValue(color);
  blue := GetBValue(color);
end;

function TRGB.getColorAsString: String;
var
  _red: String;
  _green: String;
  _blue: String;
  _colorRGB: String;
begin
  _red := intToStr(red).PadLeft(3, '0');
  _green := intToStr(green).PadLeft(3, '0');
  _blue := intToStr(blue).PadLeft(3, '0');
  _colorRGB := _red + _green + _blue;
  Result := _colorRGB;
end;

function TRGB.getTColor: TColor;
begin
  Result := TColor(RGB(red, green, blue));
end;

procedure TRGB.setRedColor(color: integer);
begin
  _red := getValidColor(color);
end;

procedure TRGB.setGreenColor(color: integer);
begin
  _green := getValidColor(color);
end;

procedure TRGB.setBlueColor(color: integer);
begin
  _blue := getValidColor(color);
end;

function TRGB.getValidColor(color: integer): integer;
var
  _validColor: integer;
begin
  if color < 0 then
  begin
    _validColor := 0;
  end
  else if color > 255 then
  begin
    _validColor := 255;
  end
  else
  begin
    _validColor := color;
  end;
  Result := _validColor;
end;

function TColorToString(color: TColor): string;
var
  _rgb: TRGB;
begin
  _rgb.loadFromTColor(color);
  result := _rgb.getColorAsString;
end;

function RGBStringToTColor(colorRGB: string): TColor;
var
  _rgb: TRGB;
begin
  _rgb.loadFromString(colorRGB);
  result := _rgb.getTColor;
end;

//-------------------------------------------------------------------------------------------------
procedure setLighterTColorToTPanel(component: TPanel; color: TColor; levelLighter: integer = 1);
var
  _color: TColor;
begin
  _color := getLighterTColor(color, levelLighter);
  setTColorToTPanel(component, _color);
end;

procedure setDarkerTColorToTPanel(component: TPanel; color: TColor; levelLighter: integer = 1);
var
  _color: TColor;
begin
  _color := getDarkerTColor(color, levelLighter);
  setTColorToTPanel(component, _color);
end;

function getVariationOfTColor(color: TColor; typeOfVaration: String; level: integer = 1): TColor; forward;

function getLighterTColor(color: TColor; levelLighter: integer = 1): TColor;
begin
  Result := getVariationOfTColor(color, 'light', levelLighter);
end;

function getDarkerTColor(color: TColor; levelDarker: integer = 1): TColor;
begin
  Result := getVariationOfTColor(color, 'dark', levelDarker);
end;

function getRGBColorVariation(RGB_source: TRGB; variationColorValue: integer): TRGB;
var
  _RGB_colorVariation: TRGB;
begin
  with _RGB_colorVariation do
  begin
    if RGB_source.red > 0 then
    begin
      red := RGB_source.red + variationColorValue;
    end
    else
    begin
      red := 0;
    end;
    if RGB_source.green > 0 then
    begin
      green := RGB_source.green + variationColorValue;
    end
    else
    begin
      green := 0;
    end;
    if RGB_source.blue > 0 then
    begin
      blue := RGB_source.blue + variationColorValue;
    end
    else
    begin
      blue := 0;
    end;
  end;
  Result := _RGB_colorVariation;
end;

function getVariationOfTColor(color: TColor; typeOfVaration: String; level: integer = 1): TColor;
var
  _RGB_source: TRGB;
  _RGB_colorVariation: TRGB;
  _colorVariationValue: integer;
const
  VARIATION1_VALUE = 30;
  VARIATION2_VALUE = 50;
  VARIATION3_VALUE = 70;
begin
  _colorVariationValue := 0;

  _RGB_source.loadFromTColor(color);

  if level = 1 then
  begin
    _colorVariationValue := VARIATION1_VALUE;
  end
  else if level = 2 then
  begin
    _colorVariationValue := VARIATION2_VALUE;
  end
  else if level = 3 then
  begin
    _colorVariationValue := VARIATION3_VALUE;
  end;

  if typeOfVaration = 'dark' then
  begin
    _colorVariationValue := -_colorVariationValue;
  end;

  _RGB_colorVariation := getRGBColorVariation(_RGB_source, _colorVariationValue);

  Result := _RGB_colorVariation.getTColor;
end;

procedure setTColorToTPanel(component: TPanel; color: TColor);
begin
  component.ParentBackground := false;
  component.ParentColor := false;
  component.Color := color;
end;

procedure makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; myString: String);
begin
  if myString <> '' then
  begin
    myPanel.Visible := true;
  end
  else
  begin
    myPanel.Visible := false;
  end;
end;

procedure setComponentInMiddlePosition(control: TControl);
var
  _left: integer;
begin
  _left := trunc(control.Parent.Width / 2) - trunc(control.Width / 2);
  control.Left := _left;
end;

function customMessageDlg(CONST Msg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons;
  Caption: ARRAY OF string; dlgcaption: string): Integer;
var
  aMsgdlg: TForm;
  i: Integer;
  Dlgbutton: Tbutton;
  Captionindex: Integer;
begin
  aMsgdlg := createMessageDialog(Msg, DlgTypt, button);
  aMsgdlg.Caption := dlgcaption;
  aMsgdlg.BiDiMode := bdLeftToRight;
  Captionindex := 0;
  for i := 0 to aMsgdlg.componentcount - 1 Do
  begin
    if (aMsgdlg.components[i] is Tbutton) then
    Begin
      Dlgbutton := Tbutton(aMsgdlg.components[i]);
      if Captionindex <= High(Caption) then
        Dlgbutton.Caption := Caption[Captionindex];
      inc(Captionindex);
    end;
  end;
  Result := aMsgdlg.Showmodal;
  FreeAndNil(aMsgdlg);
end;

end.
