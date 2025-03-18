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

unit KLib.Graphics;

interface

uses
  KLib.Types, KLib.Constants,
  RzDBCmbo,
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls, Vcl.Dialogs, Vcl.Forms,
  System.Classes;

type
  TLabelLoading = class
  private
    timer: TTimer;
    count: integer;
    _labelSource: TLabel;
    procedure onTimer(Sender: TObject);
    procedure setLabelSource(value: TLabel);
    function getLabelSource: TLabel;
  public
    countRepeatMax: integer;
    textToRepeat: string;
    caption: string;
    property labelSource: TLabel read getLabelSource write setLabelSource;
    constructor create(labelSource: TLabel; textToRepeat: string = '.'; countRepeatMax: integer = 3); overload;
    constructor create(textToRepeat: string = '.'; countRepeatMax: integer = 3); overload;
    procedure start;
    procedure stop;
    Destructor Destroy; override;
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
    position: KLib.Types.TPosition;
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
procedure makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; value: string);
procedure setFormInCenterOfScreen(form: TForm);
procedure setComponentInMiddlePosition(control: TControl);

procedure loadImgFileToTImage(img: TImage; pathImgFile: string); //todo keep version with devexpress and see the differences
//!not include in realease!

function getImageAsAnsiString(fileName: string): AnsiString;

function myOpenDialog(initialDir: string = EMPTY_STRING; filter: string = 'All |*.*'): string;
function mySaveDialog(initialDir: string = EMPTY_STRING;
  fileName: string = EMPTY_STRING; filter: string = 'All |*.*'): string;

procedure myShowMessage(msg: string; title: string = ''; confirmValue: string = 'ok');
function confirmMessage(msg: string; title: string = ''; yesValue: string = 'yes'; noValue: string = 'no'): boolean;
function myMessageDlg(title: string; msg: string; buttons: TArrayOfStrings; defaultButton: string = '';
  msgDlgType: TMsgDlgType = TMsgDlgType.mtCustom): string; //new version of customMessageDlg
function customMessageDlg(msg: string; dlgType: TMsgDlgType; buttons: TMsgDlgButtons;
  captionButtons: array of string; dlgCaption: string): Integer; deprecated;

function getComponentInFormByName(componentName: string; myForm: TForm): TComponent;

procedure createFormByClassName(className: string);

function getStrFixedWordWrapInWidth(source: string; width: integer; font: TFont): string;
function getNumberOfCharactersInWidth(widthOfCaption: integer; font: TFont): integer;
function getWidthOfSingleCharacter(font: TFont): integer;
function getWidthOfCaption(numberOfCharacters: integer; myFont: TFont): integer;

function getHeightOfCaption(text: string; font: TFont; width: integer): integer;
function getHeightOfSingleCharacter(myFont: TFont): integer;

procedure setDBComboBox(control: TRzDBComboBox; codeDescriptions: TArray<TCodeDescription>);

implementation

uses
  KLib.Utils, KLib.Generics, KLib.Validate,
  Winapi.Windows,
  System.SysUtils, System.Types;

//    dxGDIPlusClasses,   todo keep version with devexpress and see the differences
//!not include in realease!
//-------------------------------------------------------------------------------------------------
//  TLabelLoading
//-------------------------------------------------------------------------------------------------
constructor TLabelLoading.create(labelSource: TLabel; textToRepeat: string = '.'; countRepeatMax: integer = 3);
begin
  Self._labelSource := labelSource;
  create(textToRepeat, countRepeatMax);
end;

constructor TLabelLoading.create(textToRepeat: string = '.'; countRepeatMax: integer = 3);
begin
  Self.textToRepeat := textToRepeat;
  Self.countRepeatMax := countRepeatMax;
  Self.count := 0;
  Self.caption := labelSource.Caption;
  timer := TTimer.create(nil);
  Timer.Interval := 600;
  Timer.OnTimer := onTimer;
  Timer.Enabled := false;
end;

procedure TLabelLoading.start;
begin
  timer.Enabled := true;
end;

procedure TLabelLoading.stop;
begin
  timer.Enabled := false;
  _labelSource.Caption := caption;
end;

procedure TLabelLoading.onTimer(Sender: TObject);
begin
  if (count = countRepeatMax) then
  begin
    labelSource.Caption := caption;
    count := 0;
  end
  else
  begin
    labelSource.Caption := labelSource.Caption + textToRepeat;
    inc(count);
  end;
end;

procedure TLabelLoading.setLabelSource(value: TLabel);
begin
  Self.stop;
  _labelSource := value;
  Self.caption := value.Caption;
  Self.start;
end;

function TLabelLoading.getLabelSource: TLabel;
begin
  Result := _labelSource;
end;

destructor TLabelLoading.destroy;
begin
  FreeAndNil(timer);
  inherited Destroy;
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
  Self.position.top := _componentPositionInScreenCoordinates.Y;
  Self.position.left := _componentPositionInScreenCoordinates.X;
  Self.position.bottom := _componentPositionInScreenCoordinates.Y + Self.size.heightAsInteger;
  Self.position.right := _componentPositionInScreenCoordinates.X + Self.size.widthAsInteger;
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

procedure makePanelVisibleOnlyIfStringIsNotNull(myPanel: TPanel; value: string);
begin
  if value <> '' then
  begin
    myPanel.Visible := true;
  end
  else
  begin
    myPanel.Visible := false;
  end;
end;

procedure setFormInCenterOfScreen(form: TForm);
begin
  form.Left := (form.Monitor.Width - form.Width) div 2;
  form.Top := (form.Monitor.Height - form.Height) div 2;
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
  _img: TPicture;
begin
  _img := TPicture.Create;
  _img.LoadFromFile(pathImgFile);
  img.Picture := _img;
end;

//procedure loadImgFileToTImage(img: TImage; pathImgFile: string);
//var
//  _img: TdxSmartImage;
//begin
//  _img := TdxSmartImage.Create;
//  _img.LoadFromFile(pathImgFile);
//  img.Picture.Graphic := _img;
//end;

function getImageAsAnsiString(fileName: string): AnsiString;
var
  imageAsString: AnsiString;

  _pic: TPicture;
  _memoryStream: TMemoryStream;
begin
  validateThatFileExists(fileName);

  _pic := TPicture.Create;
  _memoryStream := TMemoryStream.Create;
  try
    _pic.LoadFromFile(fileName);

    _pic.Graphic.SaveToStream(_memoryStream);
    _memoryStream.Position := 0;
    SetLength(imageAsString, _memoryStream.Size);
    _memoryStream.ReadBuffer(imageAsString[1], _memoryStream.Size);
  finally
    _pic.Free;
    _memoryStream.Free;
  end;

  Result := imageAsString;
end;

function myOpenDialog(initialDir: string = EMPTY_STRING; filter: string = 'All |*.*'): string;
var
  _result: string;

  _opendialog: TOpenDialog;
  _initialDir: string;
begin
  _initialDir := getValidFullPath(initialDir);
  if (_initialDir = EMPTY_STRING) then
  begin
    _initialDir := GetCurrentDir;
  end;

  _opendialog := TOpenDialog.Create(nil);
  try
    _opendialog.InitialDir := _initialDir;
    _opendialog.Options := [ofFileMustExist];
    _opendialog.Filter := filter;
    _opendialog.FilterIndex := 1;
    if (_opendialog.execute) then
    begin
      _result := _opendialog.FileName;
    end
    else
    begin
      _result := EMPTY_STRING;
    end;
  finally
    FreeAndNil(_opendialog)
  end;

  Result := _result;
end;

function mySaveDialog(initialDir: string = EMPTY_STRING;
  fileName: string = EMPTY_STRING; filter: string = 'All |*.*'): string;
var
  _result: string;

  _saveDialog: TSaveDialog;
  _initialDir: string;
begin
  _initialDir := getValidFullPath(initialDir);
  if (_initialDir = EMPTY_STRING) then
  begin
    _initialDir := GetCurrentDir;
  end;

  _saveDialog := TSaveDialog.Create(nil);
  try
    _saveDialog.InitialDir := _initialDir;
    _saveDialog.Filter := filter;
    _saveDialog.FilterIndex := 1;
    _saveDialog.FileName := fileName;
    if (_saveDialog.execute) then
    begin
      _result := _saveDialog.FileName;
    end
    else
    begin
      _result := EMPTY_STRING;
    end;
  finally
    FreeAndNil(_saveDialog)
  end;

  Result := _result;
end;

procedure myShowMessage(msg: string; title: string = ''; confirmValue: string = 'ok');
var
  _title: string;
  _msg: string;
begin
  _title := title;
  if (_title.IsEmpty()) then
  begin
    _title := Application.Title;
  end;
  _msg := msg.PadRight(60, ' ');

  myMessageDlg(_title, _msg, [confirmValue]);
end;

function confirmMessage(msg: string; title: string = ''; yesValue: string = 'yes'; noValue: string = 'no'): boolean;
var
  _title: string;
begin
  _title := title;
  if (_title.IsEmpty()) then
  begin
    _title := Application.Title;
  end;
  Result := myMessageDlg(_title, msg, [yesValue, noValue]) = yesValue;
end;

function myMessageDlg(title: string; msg: string; buttons: TArrayOfStrings; defaultButton: string = '';
  msgDlgType: TMsgDlgType = TMsgDlgType.mtCustom): string;
const
  MAX_NUMBER_BUTTONS = 8;

  //mbNo, mbOk, mbCancel, mbHelp are not used

  MESSAGE_DIALOG_BUTTONS: array [0 .. MAX_NUMBER_BUTTONS - 1] of TMsgDlgBtn =
    (mbYes, mbAbort, mbRetry, mbIgnore, mbAll, mbNoToAll, mbYesToAll, mbClose);

  RESULTS_BUTTONS: array [0 .. MAX_NUMBER_BUTTONS - 1] of integer =
    (mrYes, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll, mrYesToAll, mrClose);

  ERR_MSG = 'Too many buttons. The maxium number of buttons is 8.';
var
  _result: string;

  _countButtons: integer;
  _indexOfDefaultButton: integer;
  _defaultMsgDlgButton: TMsgDlgBtn;

  _messageDialog: TForm;
  _buttons: TMsgDlgButtons;
  _buttonsIndex: Integer;

  _messageDialogResult: integer;
  _RESULTS_BUTTONS_index: integer;

  i: Integer;
  _button: TButton;
begin
  _countButtons := Length(buttons);
  Assert(_countButtons <= MAX_NUMBER_BUTTONS, ERR_MSG);

  _indexOfDefaultButton := TGenerics.getElementIndexFromArray<string>(buttons, defaultButton);
  if _indexOfDefaultButton = -1 then
  begin
    _indexOfDefaultButton := 0;
  end;

  _defaultMsgDlgButton := MESSAGE_DIALOG_BUTTONS[_indexOfDefaultButton];

  _buttons := [];
  for i := 0 to _countButtons - 1 do
  begin
    Include(_buttons, MESSAGE_DIALOG_BUTTONS[i]);
  end;

  _messageDialog := createMessageDialog(msg, msgDlgType, _buttons, _defaultMsgDlgButton);
  _messageDialog.Caption := title;
  _messageDialog.BiDiMode := bdLeftToRight;
  _buttonsIndex := 0;
  for i := 0 to _messageDialog.componentcount - 1 do
  begin
    if (_messageDialog.components[i] is TButton) then
    Begin
      _button := TButton(_messageDialog.components[i]);
      if _buttonsIndex <= High(buttons) then
      begin
        _button.Caption := buttons[_buttonsIndex];
      end;
      inc(_buttonsIndex);
    end;
  end;

  _messageDialogResult := _messageDialog.ShowModal;

  FreeAndNil(_messageDialog);

  if (_messageDialogResult <> mrNo) and (_messageDialogResult <> mrOk) and (_messageDialogResult <> mrCancel) then
  begin
    _RESULTS_BUTTONS_index := TGenerics.getElementIndexFromArray<integer>(RESULTS_BUTTONS, _messageDialogResult);
    _result := buttons[_RESULTS_BUTTONS_index];
  end
  else
  begin
    _result := '';
  end;

  Result := _result;
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
const
  ERR_MSG = 'Component doesn''t exists in form.';
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
    raise Exception.Create(ERR_MSG);
  end;
end;

procedure createFormByClassName(className: string);
var
  _form: TForm;
begin
  _form := TFormClass(FindClass(className)).Create(Application);
  try
    _form.Show;
  finally
    _form.Free;
  end;
end;

function getStrFixedWordWrapInWidth(source: string; width: integer; font: TFont): string;
var
  _numberMaxCharactersInWidth: integer;
  strFixedWordWrap: string;
begin
  _numberMaxCharactersInWidth := getNumberOfCharactersInWidth(width, font);
  strFixedWordWrap := stringToStrFixedWordWrap(source, _numberMaxCharactersInWidth);
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
  height: integer;

  _label: TLabel;
  _text: string;
begin
  _text := 'A';
  _label := TLabel.Create(nil);
  with _label do
  begin
    AutoSize := true;
    Font := myFont;
    Caption := _text;
  end;
  height := _label.Height;
  FreeAndNil(_label);

  Result := height;
end;

procedure setDBComboBox(control: TRzDBComboBox; codeDescriptions: TArray<TCodeDescription>);
var
  _codeDescription: TCodeDescription;
begin
  control.ClearItemsValues;
  for _codeDescription in codeDescriptions do
  begin
    control.AddItemValue(_codeDescription.description, _codeDescription.code);
  end;
end;

end.
