unit KLib.Graphics;

interface

uses
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls, Vcl.Dialogs, Vcl.Forms,
  System.Classes,
  KLib.Types;

type
  TLabelLoading = class
  private
    originalText: string;
    timer: TTimer;
    count: integer;
    lblSource: TLabel;
    procedure onTimer(Sender: TObject);
    procedure setLabelSource(const Value: TLabel);
    function getLabelSource: TLabel;
  public
    repeatMax: integer;
    textToRepeat: string;
    property labelSource: TLabel read getLabelSource write setLabelSource;
    constructor create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3); overload;
    constructor create(textToRepeat: string; countRepeatMax: integer = 3); overload;
    destructor destroy; override;
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

  TComponentInfo = record
    position: TPosition;
    size: TSize;
    procedure setFromComponent(component: TControl);
    procedure setSizeFromComponent(component: TControl);
    procedure setPositionFromComponent(component: TControl);
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

procedure loadImgFileToTImage(img: TImage; pathImgFile: string);

function customMessageDlg(msg: string; dlgType: TMsgDlgType; buttons: TMsgDlgButtons;
  captionButtons: array of string; dlgCaption: string): Integer;

function getComponentInFormByName(componentName: string; myForm: TForm): TComponent;

function getStrFixedWordWrapInWidth(source: string; width: integer; font: TFont): string;
function getNumberOfCharactersInWidth(widthOfCaption: integer; font: TFont): integer;
function getWidthOfSingleCharacter(font: TFont): integer;
function getWidthOfCaption(numberOfCharacters: integer; myFont: TFont): integer;

function getHeightOfCaption(text: string; font: TFont; width: integer): integer;
function getHeightOfSingleCharacter(myFont: TFont): integer;

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  dxGDIPlusClasses,
  KLib.Utils;

//-------------------------------------------------------------------------------------------------
//  TLabelLoading
//-------------------------------------------------------------------------------------------------
constructor TLabelLoading.create(labelSource: TLabel; textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.labelSource := labelSource;
  create(textToRepeat, countRepeatMax);
end;

constructor TLabelLoading.create(textToRepeat: string; countRepeatMax: integer = 3);
begin
  Self.textToRepeat := textToRepeat;
  Self.repeatMax := countRepeatMax;
  Self.count := 0;
  Self.originalText := labelSource.Caption;
  timer := TTimer.create(nil);
  Timer.Interval := 600;
  Timer.OnTimer := onTimer;
  Timer.Enabled := false;
end;

destructor TLabelLoading.destroy;
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

procedure TLabelLoading.onTimer(Sender: TObject);
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

procedure TComponentInfo.setFromComponent(component: TControl);
begin
  setSizeFromComponent(component);
  setPositionFromComponent(component);
end;

procedure TComponentInfo.setSizeFromComponent(component: TControl);
begin
  self.size.height := component.ClientHeight;
  self.size.width := component.ClientWidth;
end;

procedure TComponentInfo.setPositionFromComponent(component: TControl);
var
  _componentPositionInScreenCoordinates: TPoint;
begin
  _componentPositionInScreenCoordinates := component.ClientToScreen(Point(0, 0));
  self.position.top := _componentPositionInScreenCoordinates.Y;
  self.position.left := _componentPositionInScreenCoordinates.X;
  self.position.bottom := _componentPositionInScreenCoordinates.Y + self.size.height;
  self.position.right := _componentPositionInScreenCoordinates.X + self.size.width;
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

procedure loadImgFileToTImage(img: TImage; pathImgFile: string);
var
  _img: TdxSmartImage;
begin
  _img := TdxSmartImage.Create;
  _img.LoadFromFile(pathImgFile);
  img.Picture.Graphic := _img;
end;

function customMessageDlg(msg: string; dlgType: TMsgDlgType; buttons: TMsgDlgButtons;
  captionButtons: array of string; dlgCaption: string): Integer;
var
  msgDlgForm: TForm;
  i: Integer;
  dlgbutton: Tbutton;
  captionIndex: Integer;
begin
  msgDlgForm := createMessageDialog(msg, dlgType, buttons);
  msgDlgForm.Caption := dlgCaption;
  msgDlgForm.BiDiMode := bdLeftToRight;
  captionIndex := 0;
  for i := 0 to msgDlgForm.componentcount - 1 Do
  begin
    if (msgDlgForm.components[i] is TButton) then
    Begin
      dlgbutton := Tbutton(msgDlgForm.components[i]);
      if captionIndex <= High(captionButtons) then
      begin
        dlgbutton.Caption := captionButtons[captionIndex];
      end;
      inc(captionIndex);
    end;
  end;
  Result := msgDlgForm.Showmodal;
  FreeAndNil(msgDlgForm);
end;

function getComponentInFormByName(componentName: string; myForm: TForm): TComponent;
var
  i: Integer;
  _component: TComponent;
begin
  result := nil;
  for i := 0 to myForm.ComponentCount - 1 do
  begin
    _component := myForm.Components[i];
    if (_component.name = componentName) then
    begin
      result := _component;
    end;
  end;
  if (result = nil) then
  begin
    raise Exception.Create('Component doesn''t exists in form');
  end;
end;

function getStrFixedWordWrapInWidth(source: string; width: integer; font: TFont): string;
var
  _numberMaxCharactersInWidth: integer;
  strFixedWordWrap: string;
begin
  _numberMaxCharactersInWidth := getNumberOfCharactersInWidth(width, font);
  strFixedWordWrap := strToStrFixedWordWrap(source, _numberMaxCharactersInWidth);
  result := strFixedWordWrap;
end;

function getNumberOfCharactersInWidth(widthOfCaption: integer; font: TFont): integer;
var
  numberCharacters: integer;
  _widthSingleCharacter: integer;
begin
  _widthSingleCharacter := getWidthOfSingleCharacter(font);
  if widthOfCaption > _widthSingleCharacter then
  begin
    numberCharacters := trunc(widthOfCaption / _widthSingleCharacter);
  end
  else
  begin
    numberCharacters := 0;
  end;
  Result := numberCharacters;
end;

function getWidthOfSingleCharacter(font: TFont): integer;
var
  _width: integer;
begin
  _width := getWidthOfCaption(1, font);
  Result := _width;
end;

function getWidthOfCaption(numberOfCharacters: integer; myFont: TFont): integer;
var
  _label: TLabel;
  _text: string;
  _width: integer;
begin
  _text := _text.PadLeft(numberOfCharacters, 'A');
  _label := TLabel.Create(nil);
  with _label do
  begin
    AutoSize := true;
    Font := myFont;
    Caption := _text;
  end;
  _width := _label.Width;
  FreeAndNil(_label);
  Result := _width;
end;

function getHeightOfCaption(text: string; font: TFont; width: integer): integer;
const
  DEFAULT_FREE_SPACE = 0.3;
var
  _heightOfSingleCharacter: integer;
  _strFixedWordWrap: string;
  _countLines: integer;
  _defaultFreeSpace: double;
begin
  _heightOfSingleCharacter := getHeightOfSingleCharacter(font);
  _strFixedWordWrap := getStrFixedWordWrapInWidth(text, width, font);
  _countLines := getNumberOfLinesInStrFixedWordWrap(_strFixedWordWrap);
  _defaultFreeSpace := _heightOfSingleCharacter * DEFAULT_FREE_SPACE;
  result := trunc((_heightOfSingleCharacter * _countLines) + _defaultFreeSpace);
end;

function getHeightOfSingleCharacter(myFont: TFont): integer;
var
  _label: TLabel;
  _text: string;
  _height: integer;
begin
  _text := 'A';
  _label := TLabel.Create(nil);
  with _label do
  begin
    AutoSize := true;
    Font := myFont;
    Caption := _text;
  end;
  _height := _label.Height;
  FreeAndNil(_label);
  Result := _height;
end;

end.
