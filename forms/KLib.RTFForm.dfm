object RTFForm: TRTFForm
  Left = 0
  Top = 0
  ActiveControl = pnl_head
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'RTFForm'
  ClientHeight = 758
  ClientWidth = 894
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  StyleElements = []
  OnCreate = FormCreate
  TextHeight = 13
  object pnl_bottom: TPanel
    Left = 0
    Top = 645
    Width = 894
    Height = 113
    Align = alBottom
    BevelEdges = [beTop]
    BevelOuter = bvLowered
    Color = clWhite
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    StyleElements = []
    object _img_checkBox_unCheck: TImage
      Left = 45
      Top = 23
      Width = 45
      Height = 45
      Cursor = crHandPoint
      Center = True
      Picture.Data = {
        0B546478504E47496D61676589504E470D0A1A0A0000000D494844520000001B
        0000001B08060000008DD4F4550000000473424954080808087C086488000000
        8549444154484B63648080090C0C0CFE0C0C0C0A503E35A9070C0C0C0B181818
        1A19A116E553D3741C66812DFBC0C0C0C04F07CB1E802CFB8F6411884F6D0037
        7FD4324A8276341829093DB8DED1601C0D46BC21309A404613C8680219CECD02
        7AB5AE1E821A3C0D0C0C0CF554C951F80D01B71B41006461020303833C0D2C7D
        086D1137000021F336C6D55A4AD40000000049454E44AE426082}
      Proportional = True
      Visible = False
    end
    object _img_checkBox_check: TImage
      Left = 105
      Top = 23
      Width = 45
      Height = 45
      Cursor = crHandPoint
      Center = True
      Picture.Data = {
        0B546478504E47496D61676589504E470D0A1A0A0000000D494844520000001B
        0000001B08060000008DD4F4550000000473424954080808087C086488000001
        0649444154484BDDD6ED11C1301CC7F16F2760032330021BB0810D3001266004
        23D88011D8A0DDC006DCCFB52EADA44973D117F2AA2F72F95CFF4F49060C812D
        B02CBF49BC72E00C6C32E008AC1203B6E3F6C21EC0A0072C17F6EC017A137F81
        DDCB688DCDA8FDE2CF044D4BE40A7CC0D45805A9E8B4845EAABF4B893521F5AF
        A0496ACC0BA5AAC620C885592BC9D18BC1900D73569205EB04D9B019A072D552
        826BA56B809D211BA69215786B01A32057CEDAC068A8AD1A6DA0AEA275794B54
        61AEF5916FA0B735751334CFFA6A581F14D26736300A0AC1B4C704A3A150AC02
        17C0C19C7521A133F7A41CC45EFBBFB1BE5E5745EFEF462556D3610E8CBC59EE
        BEA1004EC0EE05120E5AC6A31E19D90000000049454E44AE426082}
      Proportional = True
      Visible = False
    end
    object _pnl_bottom: TPanel
      Left = 305
      Top = 5
      Width = 286
      Height = 96
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object buttom_pnl_confirm: TPanel
        Left = 0
        Top = 60
        Width = 286
        Height = 36
        Cursor = crHandPoint
        Align = alBottom
        BevelOuter = bvNone
        Caption = 'Confirm'
        Color = clHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHighlightText
        Font.Height = -20
        Font.Name = 'Roboto'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        StyleElements = []
        OnClick = buttom_pnl_confirmClick
      end
      object pnl_checkbox: TPanel
        Left = 0
        Top = 0
        Width = 286
        Height = 51
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHighlightText
        Font.Height = -20
        Font.Name = 'Roboto'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentColor = True
        ParentFont = False
        ShowCaption = False
        TabOrder = 1
        StyleElements = []
        object checkBox_img: TImage
          Left = 1
          Top = 8
          Width = 30
          Height = 33
          Cursor = crHandPoint
          Center = True
          Picture.Data = {
            0B546478504E47496D61676589504E470D0A1A0A0000000D494844520000001B
            0000001B08060000008DD4F4550000000473424954080808087C086488000000
            8549444154484B63648080090C0C0CFE0C0C0C0A503E35A9070C0C0C0B181818
            1A19A116E553D3741C66812DFBC0C0C0C04F07CB1E802CFB8F6411884F6D0037
            7FD4324A8276341829093DB8DED1601C0D46BC21309A404613C8680219CECD02
            7AB5AE1E821A3C0D0C0C0CF554C951F80D01B71B41006461020303833C0D2C7D
            086D1137000021F336C6D55A4AD40000000049454E44AE426082}
          Proportional = True
          OnClick = checkBox_imgClick
        end
        object lbl_checkBox: TLabel
          Left = 35
          Top = 15
          Width = 251
          Height = 26
          AutoSize = False
          Caption = 'Agree'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -17
          Font.Name = 'Roboto'
          Font.Style = [fsBold]
          ParentFont = False
          StyleElements = []
        end
      end
    end
  end
  object pnl_head: TPanel
    Left = 0
    Top = 0
    Width = 894
    Height = 61
    Align = alTop
    BevelEdges = []
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clWhite
    ParentBiDiMode = False
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    StyleElements = []
    object button_exit: TImage
      Left = 845
      Top = 5
      Width = 28
      Height = 36
      Cursor = crHandPoint
      Picture.Data = {
        0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000030
        0000003008060000005702F9870000000473424954080808087C086488000001
        C9494441546843ED9A5972C3200C40F1C9DA9B849CACE426CDCD3ACA20C6C12C
        DA58DAA9FF126FEF09096BB00F976DDEFB2FE7DC338410F27D2B7F7BEFBD73EE
        2384703F731CE71F111E0E84EDBE8B448487C0C2065849220964F0E8B55C2283
        47AE24F112A8C02F97A8C0BF491C1DF865121DF824010290F3985FAD3A9D964E
        1C264CA16D2438F05008E7225E2EC1858774C9A7D1651212F88B409C91A64B48
        E18B02B32534F0558159125AF8A6C068090BF8AEC028092B789280B584253C59
        C04AC21A9E25A0951801CF16904A8C8217097025627738AC597C6B255AAD68BE
        8F1155CA65C59DAE58803912C3DA749580818438F21811B58042420D2F2EE252
        3E306BC204FE5F004782197D3CCD6414D43520843793500928E14D24C40246F0
        6A099100031ED730F7692538F0B8382C3987D27FB0A7510D88E6DC960C39852C
        002CAE91CB90042C6F6C792D520A59DF90D93B751F76CD1118012F787A3725AA
        0223E12D258A0233E0AD242E0233E12D24FECEF2FA8AC82B160A5261FFFE574C
        3B445E3312F096123E29B8759AA7EE0385DA7C518F2306F68129D492980E4F9C
        9D1E21047F7E4B59925806DF9178C15F7AA12C9D96C35724127CB1998B12DFBB
        7CA992497C62E4F1FF1F90559ABFE06BC0760000000049454E44AE426082}
      Proportional = True
      OnClick = button_exitClick
    end
    object lbl_title: TLabel
      Left = 60
      Top = 5
      Width = 756
      Height = 46
      Alignment = taCenter
      AutoSize = False
      Caption = 'Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -37
      Font.Name = 'Roboto'
      Font.Style = [fsBold]
      Font.Quality = fqAntialiased
      ParentFont = False
      StyleElements = []
    end
  end
  object bodyText_richEdit: TRzRichEdit
    Left = 0
    Top = 61
    Width = 894
    Height = 584
    Align = alClient
    Alignment = taCenter
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clWhite
    Ctl3D = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    HideSelection = False
    HideScrollBars = False
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
    WantTabs = True
    StyleElements = []
    DisabledColor = clWhite
    FrameColor = clWhite
    FrameHotColor = clBtnHighlight
    FrameSides = []
    ReadOnlyColor = clWhite
  end
end
