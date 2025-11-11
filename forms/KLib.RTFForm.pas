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

unit KLib.RTFForm;

interface

uses
  KLib.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.OleCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  {$ifdef KLIB_RAIZE}
  , RzEdit
  {$endif}
  dxGDIPlusClasses;

type
  TSizeRTF = (medium, small, large);

  TRTFFormCreate = record
    sizePDF: TSizeRTF;
    pathRTF: string;
    showScrollbar: boolean;
    titleCaption: string;
    checkboxCaption: string;
    confirmButtonCaption: string;
    colorRGBConfirmButton: string;
  end;

  TRTFForm = class(TForm)
    pnl_bottom: TPanel;
    _img_checkBox_unCheck: TImage;
    _img_checkBox_check: TImage;
    checkBox_img: TImage;
    _pnl_bottom: TPanel;
    lbl_checkBox: TLabel;
    buttom_pnl_confirm: TPanel;
    pnl_head: TPanel;
    button_exit: TImage;
    pnl_checkbox: TPanel;
    lbl_title: TLabel;
    bodyText_richEdit: TRzRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure checkBox_imgClick(Sender: TObject);
    procedure button_exitClick(Sender: TObject);
    procedure buttom_pnl_confirmClick(Sender: TObject);
  private
    sizeRTF: TSizeRTF;
    pathRTF: string;
    showScrollbar: boolean;
    colorRGBConfirmButton: string;

    colorButtom: TColorButtom;
    isCheckBoxChecked: boolean;
    procedure disableConfirmButtom;
    procedure enableConfirmButtom;
    procedure setSizeRTF;
    procedure setColorButtom;
    procedure initializeGraphicSettings;
    procedure initializeVariables;
    procedure loadRTFFromFile;
  public
    result: boolean;
    constructor Create(AOwner: TComponent; createInfo: TRTFFormCreate); reintroduce; overload;
  end;

procedure showRTF(myRTFPath: string; mytitleCaption: string = '');
function showCustomRTF(infoCreate: TRTFFormCreate): boolean;

var
  RTFForm: TRTFForm;

implementation

{$r *.dfm}


uses
  KLib.Graphics, KLib.FileSystem;

const
  RGBCOLOR_DISABLED_BUTTON = '180180180';

procedure showRTF(myRTFPath: string; mytitleCaption: string = '');
var
  _RTFFormCreate: TRTFFormCreate;
begin
  with _RTFFormCreate do
  begin
    pathRTF := myRTFPath;
    titleCaption := mytitleCaption;
    showScrollbar := true;
  end;
  showCustomRTF(_RTFFormCreate);
end;

function showCustomRTF(infoCreate: TRTFFormCreate): boolean;
var
  _RTFForm: TRTFForm;
  _result: boolean;
begin
  infoCreate.pathRTF := getValidFullPath(infoCreate.pathRTF);
  _RTFForm := TRTFForm.Create(nil, infoCreate);
  _RTFForm.ShowModal;
  _result := _RTFForm.result;
  result := _result;
  FreeAndNil(_RTFForm);
end;

constructor TRTFForm.Create(AOwner: TComponent; createInfo: TRTFFormCreate);
var
  _sizes: set of TSizeRTF;
begin
  Create(AOwner);
  _sizes := [small, medium, large];

  with createInfo do
  begin
    if (sizePDF in _sizes) then
    begin
      self.sizeRTF := sizePDF;
    end
    else
    begin
      self.sizeRTF := TSizeRTF.medium;
    end;
    self.pathRTF := pathRTF;
    Self.showScrollbar := showScrollbar;
    self.lbl_title.Caption := titleCaption;
    self.lbl_checkBox.Caption := checkboxCaption;
    self.buttom_pnl_confirm.Caption := confirmButtonCaption;
    self.colorRGBConfirmButton := colorRGBConfirmButton;
  end;

  initializeVariables;
  initializeGraphicSettings;
end;

procedure TRTFForm.initializeVariables;
begin
  result := false;
  isCheckBoxChecked := false;
  setColorButtom;
end;

procedure TRTFForm.setColorButtom;
begin
  colorButtom.disabled := RGBStringToTColor(RGBCOLOR_DISABLED_BUTTON);
  if colorRGBConfirmButton <> '' then
  begin
    colorButtom.enabled := RGBStringToTColor(colorRGBConfirmButton);
  end
  else
  begin
    colorButtom.enabled := buttom_pnl_confirm.Color;
  end;
end;

procedure TRTFForm.initializeGraphicSettings;
begin
  Caption := Application.Title;
  makePanelVisibleOnlyIfStringIsNotNull(pnl_checkbox, lbl_checkBox.Caption);
  makePanelVisibleOnlyIfStringIsNotNull(buttom_pnl_confirm, buttom_pnl_confirm.Caption);
  pnl_bottom.Visible := pnl_checkbox.Visible or buttom_pnl_confirm.Visible;
  setComponentInMiddlePosition(lbl_title);
  setComponentInMiddlePosition(buttom_pnl_confirm);
  setComponentInMiddlePosition(_pnl_bottom);
  setSizeRTF;
  disableConfirmButtom;

  bodyText_richEdit.HideScrollBars := not showScrollbar;
end;

procedure TRTFForm.setSizeRTF;
var
  _modifiedHeight: integer;
begin
  if sizeRTF <> TSizeRTF.medium then
  begin
    _modifiedHeight := trunc(bodyText_richEdit.Height / 2.5);
    if sizeRTF = TSizeRTF.small then
    begin
      _modifiedHeight := -_modifiedHeight;
    end;
    self.Height := self.Height + _modifiedHeight;
  end;
end;

procedure TRTFForm.FormCreate(Sender: TObject);
begin
  loadRTFFromFile;
end;

procedure TRTFForm.loadRTFFromFile;
var
  _fiileStream: TFileStream;
begin
  _fiileStream := TFileStream.Create(pathRTF, fmOpenRead);
  bodyText_richEdit.PlainText := False;
  bodyText_richEdit.Lines.LoadFromStream(_fiileStream);
  FreeAndNil(_fiileStream);
end;

procedure TRTFForm.checkBox_imgClick(Sender: TObject);
begin
  isCheckBoxChecked := not isCheckBoxChecked;
  if isCheckBoxChecked then
  begin
    checkBox_img.Picture := _img_checkBox_check.Picture;
    enableConfirmButtom;
  end
  else
  begin
    checkBox_img.Picture := _img_checkBox_unCheck.Picture;
    disableConfirmButtom;
  end;
end;

procedure TRTFForm.disableConfirmButtom;
begin
  buttom_pnl_confirm.Enabled := false;
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.disabled);
end;

procedure TRTFForm.enableConfirmButtom;
begin
  setTColorToTPanel(buttom_pnl_confirm, colorButtom.enabled);
  buttom_pnl_confirm.Enabled := true;
end;

procedure TRTFForm.buttom_pnl_confirmClick(Sender: TObject);
begin
  result := true;
  close;
end;

procedure TRTFForm.button_exitClick(Sender: TObject);
begin
  close;
end;

end.
