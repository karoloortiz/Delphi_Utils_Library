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

unit KLib.MessageForm;

interface

uses
  KLib.Types,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  RzLabel, RzPanel, RzEdit,
  dxGDIPlusClasses;

type
  TSizeText = (medium, small, large);

  TMessageFormCreate = record
    colorRGB: string;
    sizeText: TSizeText;
    title: string;
    text: string;
    textIsRTFResource: boolean;
    confirmButtonCaption: string;
    cancelButtonCaption: string;
    checkboxCaption: string;
    imgIsResource: boolean;
    imgName: string;
  end;

  TMessageFormResult = record
    isConfirmButtonPressed: boolean;
    isCheckBoxChecked: boolean;
  end;

  TMessageForm = class(TForm)
    pnl_title: TPanel;
    _spacer_title_top: TRzSpacer;
    _spacer_title_bottom: TRzSpacer;
    pnl_bottom: TPanel;
    pnl_body: TPanel;
    lbl_title: TLabel;
    pnl_button_confirm: TPanel;
    pnl_button_cancel: TPanel;
    lbl_button_cancel: TLabel;
    lbl_button_confirm: TLabel;
    _shape_button_cancel: TShape;
    _shape_button_confirm: TShape;
    _pnl_body: TPanel;
    _pnl_bodyCenter: TPanel;
    img_bodyCenter: TImage;
    richEdit_bodyText: TRzRichEdit;
    _spacer_body_bottom: TRzSpacer;
    _spacer_body_left: TRzSpacer;
    _spacer_body_right: TRzSpacer;
    _spacer_body_top: TRzSpacer;
    pnl_checkBox: TPanel;
    _spacer_checkBox_upper: TRzSpacer;
    _spacer_checkBox_bottom: TRzSpacer;
    _pnl_checkBox: TPanel;
    checkBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure pnl_button_confirmClick(Sender: TObject);
    procedure pnl_button_cancelClick(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure lbl_button_confirmClick(Sender: TObject);
    procedure lbl_button_cancelClick(Sender: TObject);
  private
    returnValue: TMessageFormResult;
    resourceRTFName: string;
    text: string;
    img: TdxSmartImage;
    sizeText: TSizeText;
    mainColorRGB: string;
    mainColorDarker: TColor;
    procedure loadRTF;
    procedure setMainColor;
    procedure setSizeText;
    procedure setColorButtonConfirm;
    procedure setColorButtonCancel;
    procedure myClose(isConfirmButtonPressed: boolean = true);
  public
    constructor Create(AOwner: TComponent; createInfo: TMessageFormCreate); reintroduce; overload;
  published
  end;

function showMessageForm(infoCreate: TMessageFormCreate): TMessageFormResult;

var
  MessageForm: TMessageForm;

implementation

{$r *.dfm}


uses
  KLib.Graphics, KLib.Utils, KLib.Constants, KLib.FileSystem;

const
  TYPE_RESOURCE = RTF_TYPE;

function showMessageForm(infoCreate: TMessageFormCreate): TMessageFormResult;
var
  _showMessageForm: TMessageForm;
  _result: TMessageFormResult;
begin
  _showMessageForm := TMessageForm.Create(nil, infoCreate);
  _showMessageForm.ShowModal;
  _result := _showMessageForm.returnValue;
  FreeAndNil(_showMessageForm);

  result := _result;
end;

constructor TMessageForm.Create(AOwner: TComponent; createInfo: TMessageFormCreate);
var
  _sizes: set of TSizeText;
begin
  _sizes := [small, medium, large];
  Create(AOwner);

  Caption := Application.Title;

  with returnValue do
  begin
    isConfirmButtonPressed := false;
    isCheckBoxChecked := false;
  end;
  with createInfo do
  begin
    self.mainColorRGB := colorRGB;
    if (sizeText in _sizes) then
    begin
      self.sizeText := sizeText;
    end
    else
    begin
      self.sizeText := TSizeText.medium;
    end;

    self.lbl_title.Caption := title;
    if textIsRTFResource then
    begin
      self.resourceRTFName := text;
    end
    else
    begin
      self.text := text;
    end;
    self.lbl_button_confirm.Caption := confirmButtonCaption;
    self.lbl_button_cancel.Caption := cancelButtonCaption;
    self.checkBox.Caption := checkboxCaption;
    if imgName <> '' then
    begin
      Self.img := TdxSmartImage.Create;
      if imgIsResource then
      begin
        Self.img.LoadFromResource(HInstance, pchar(imgName), pchar('PNG'));
      end
      else
      begin
        Self.img.LoadFromFile(imgName);
      end;
      Self.img_bodyCenter.Picture.Graphic := self.img;
    end;
  end;

  setMainColor;
  setSizeText;
  makePanelVisibleOnlyIfStringIsNotNull(pnl_title, lbl_title.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(pnl_checkBox, checkBox.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(pnl_button_cancel, lbl_button_cancel.Caption);
end;

procedure TMessageForm.setMainColor;
var
  _RGB: TRGB;
begin
  if mainColorRGB <> '' then
  begin
    _RGB.loadFromString(mainColorRGB);
    setTColorToTPanel(pnl_title, _RGB.getTColor);
    mainColorDarker := getDarkerTColor(_RGB.getTColor, 1);
    setColorButtonConfirm;
    setColorButtonCancel;
  end;
end;

procedure TMessageForm.setSizeText;
var
  _modifiedHeightBodyText: integer;
begin
  if sizeText <> TSizeText.medium then
  begin
    _modifiedHeightBodyText := trunc(richEdit_bodyText.Height / 2);
    if sizeText = TSizeText.small then
    begin
      _modifiedHeightBodyText := -_modifiedHeightBodyText;
    end;
    pnl_body.Height := pnl_body.Height + _modifiedHeightBodyText;
    richEdit_bodyText.Height := richEdit_bodyText.Height + _modifiedHeightBodyText;
  end;
end;

procedure TMessageForm.setColorButtonConfirm;
begin
  _shape_button_confirm.Brush.Color := mainColorDarker;
  _shape_button_confirm.Pen.Color := mainColorDarker;
end;

procedure TMessageForm.setColorButtonCancel;
begin
  _shape_button_cancel.Brush.Color := clWhite;
  _shape_button_cancel.Pen.Color := mainColorDarker;
  lbl_button_cancel.Font.Color := mainColorDarker;
end;

procedure TMessageForm.FormCreate(Sender: TObject);
begin
  richEdit_bodyText.Lines.Text := text;
  if resourceRTFName <> '' then
  begin
    loadRTF;
  end;

  img_bodyCenter.Visible := Assigned(img);
end;

procedure TMessageForm.loadRTF;
var
  _resource: KLib.Types.TResource;
  _resourceStream: TResourceStream;
begin
  with _resource do
  begin
    name := resourceRTFName;
    _type := TYPE_RESOURCE;
  end;
  _resourceStream := getResourceAsStream(_resource);
  richEdit_bodyText.PlainText := False;
  richEdit_bodyText.Lines.LoadFromStream(_resourceStream);
  FreeAndNil(_resourceStream);
end;

procedure TMessageForm.lbl_button_cancelClick(Sender: TObject);
begin
  pnl_button_cancelClick(Sender);
end;

procedure TMessageForm.pnl_button_cancelClick(Sender: TObject);
begin
  myClose(false);
end;

procedure TMessageForm.lbl_button_confirmClick(Sender: TObject);
begin
  pnl_button_confirmClick(Sender);
end;

procedure TMessageForm.Panel2Click(Sender: TObject);
begin
  pnl_button_confirmClick(Sender);
end;

procedure TMessageForm.pnl_button_confirmClick(Sender: TObject);
begin
  myClose;
end;

procedure TMessageForm.myClose(isConfirmButtonPressed: boolean = true);
begin
  returnValue.isConfirmButtonPressed := isConfirmButtonPressed;
  returnValue.isCheckBoxChecked := checkBox.Checked;
  close;
end;

end.
