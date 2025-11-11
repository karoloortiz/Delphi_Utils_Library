object Presentation: TPresentation
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Presentation'
  ClientHeight = 693
  ClientWidth = 817
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  StyleElements = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object pnl_head: TPanel
    Left = 0
    Top = 0
    Width = 817
    Height = 136
    Align = alTop
    Color = clHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    StyleElements = []
    object _spacer_head_top: TRzSpacer
      Left = 1
      Top = 1
      Width = 815
      Align = alTop
    end
    object _spacer_head_titleSubtitle: TRzSpacer
      Left = 1
      Top = 69
      Width = 815
      Height = 15
      Align = alTop
      ExplicitTop = 65
    end
    object _spacer_hed_bottom: TRzSpacer
      Left = 1
      Top = 120
      Width = 815
      Height = 15
      Align = alBottom
      ExplicitTop = 135
    end
    object lbl_subtitle: TLabel
      Left = 1
      Top = 84
      Width = 118
      Height = 35
      Align = alTop
      Alignment = taCenter
      Caption = '(subtitle)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Roboto'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = False
      StyleElements = []
    end
    object lbl_title: TLabel
      Left = 1
      Top = 26
      Width = 73
      Height = 43
      Align = alTop
      Alignment = taCenter
      Caption = 'Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -36
      Font.Name = 'Roboto'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = False
      StyleElements = []
    end
  end
  object pnl_bottom: TPanel
    Left = 0
    Top = 602
    Width = 817
    Height = 91
    Align = alBottom
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 1
    StyleElements = []
    object pnl_buttons: TPanel
      Left = 85
      Top = 10
      Width = 656
      Height = 66
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      StyleElements = []
      object _pnl_countSlide: TPanel
        Left = 226
        Top = 0
        Width = 204
        Height = 66
        Align = alClient
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        StyleElements = []
        object lbl_countSlide: TLabel
          Left = 0
          Top = 0
          Width = 32
          Height = 50
          Align = alClient
          Alignment = taCenter
          Caption = #13'1/6'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'Roboto'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
          StyleElements = []
        end
      end
      object _pnl_box_button_back: TPanel
        Left = 0
        Top = 0
        Width = 226
        Height = 66
        Align = alLeft
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        StyleElements = []
        object pnl_button_back: TPanel
          Left = 0
          Top = 0
          Width = 226
          Height = 66
          Align = alClient
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 0
          object _shape_button_back: TShape
            Left = 10
            Top = 1
            Width = 206
            Height = 61
            Cursor = crHandPoint
          end
          object button_img_back: TImage
            Left = 10
            Top = 0
            Width = 206
            Height = 61
            Cursor = crHandPoint
            Center = True
            Picture.Data = {
              0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000024
              000000240806000000E10098980000005D494441547801EDCE310D80500C00D1
              1BF0FB25FC0101158230042000962A8092147297DCFEF8486636F23698331F6D
              30F9D60DB3FC0D23468C9803588159F0234CFD378AD74105A81D984553850AAA
              12559F2851A2822645DE3E33BB00823F932358D0D44C0000000049454E44AE42
              6082}
            OnClick = button_img_backClick
          end
        end
      end
      object _pnl_box_button_next: TPanel
        Left = 430
        Top = 0
        Width = 226
        Height = 66
        Align = alRight
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 2
        StyleElements = []
        object pnl_button_next: TPanel
          Left = 0
          Top = 0
          Width = 226
          Height = 66
          Align = alClient
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 0
          StyleElements = []
          object _shape_button_next: TShape
            Left = 15
            Top = 6
            Width = 206
            Height = 61
            Cursor = crHandPoint
            Brush.Color = clHotLight
            Pen.Color = clHotLight
          end
          object button_img_next: TImage
            Left = 15
            Top = 5
            Width = 206
            Height = 61
            Cursor = crHandPoint
            Center = True
            Picture.Data = {
              0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000024
              000000240806000000E100989800000066494441547801EDD5A10D80500C0661
              04925D3B0202896010C6602424E2904F6081167297D47F49C5DFD91732030288
              3A985664637A6003A8841A7E8112254A1430DE703370DC82E2D9A21A68C97AD9
              04EC574CDECEAD62C48811F32EA861D2510D6366B53B0199A7F73934D6CDCD00
              00000049454E44AE426082}
            Proportional = True
            OnClick = button_img_nextClick
          end
        end
        object pnl_button_end: TPanel
          Left = 0
          Top = 0
          Width = 226
          Height = 66
          Align = alClient
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 1
          StyleElements = []
          object _shape_button_end: TShape
            Left = 15
            Top = 6
            Width = 206
            Height = 61
            Cursor = crHandPoint
            Brush.Color = clHotLight
            Pen.Color = clHotLight
          end
          object lbl_button_end: TLabel
            Left = 15
            Top = 23
            Width = 206
            Height = 36
            Cursor = crHandPoint
            Alignment = taCenter
            AutoSize = False
            Caption = 'End'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -21
            Font.Name = 'Roboto'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            StyleElements = []
            OnClick = lbl_button_endClick
          end
        end
      end
    end
  end
  object pnl_body: TPanel
    Left = 0
    Top = 136
    Width = 817
    Height = 466
    Align = alClient
    AutoSize = True
    Color = clYellow
    ParentBackground = False
    TabOrder = 2
    StyleElements = []
    object pnl_image: TPanel
      Left = 1
      Top = 1
      Width = 815
      Height = 419
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      StyleElements = []
      object _spacer_image_bottom: TRzSpacer
        Left = 0
        Top = 399
        Width = 815
        Height = 20
        Align = alBottom
        ExplicitTop = 404
      end
      object _spacer_image_top: TRzSpacer
        Left = 0
        Top = 0
        Width = 815
        Align = alTop
        ExplicitLeft = 2
        ExplicitTop = 6
        ExplicitWidth = 631
      end
      object _spacer_image_left: TRzSpacer
        Left = 0
        Top = 25
        Width = 10
        Height = 374
        Orientation = orVertical
        Align = alLeft
        ExplicitLeft = 1
        ExplicitTop = 26
        ExplicitHeight = 233
      end
      object _spacer_image_right: TRzSpacer
        Left = 805
        Top = 25
        Width = 10
        Height = 374
        Orientation = orVertical
        Align = alRight
        ExplicitLeft = 631
        ExplicitHeight = 235
      end
      object img_body: TImage
        Left = 10
        Top = 25
        Width = 795
        Height = 374
        Align = alClient
        Center = True
        Proportional = True
        ExplicitLeft = 155
        ExplicitTop = 115
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
    end
    object pnl_extraDescription: TPanel
      Left = 1
      Top = 420
      Width = 815
      Height = 45
      Align = alBottom
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      StyleElements = []
      object _spacer_extraDescription_left: TRzSpacer
        Left = 0
        Top = 5
        Width = 100
        Height = 35
        Orientation = orVertical
        Align = alLeft
      end
      object _spacer_extraDescription_right: TRzSpacer
        Left = 715
        Top = 5
        Width = 100
        Height = 35
        Orientation = orVertical
        Align = alRight
        ExplicitLeft = 680
      end
      object _spacer_extraDescription_upper: TRzSpacer
        Left = 0
        Top = 0
        Width = 815
        Height = 5
        Align = alTop
      end
      object _spacer_extraDescription_bottom: TRzSpacer
        Left = 0
        Top = 40
        Width = 815
        Height = 5
        Align = alBottom
        ExplicitTop = 34
      end
      object _pnl_extraDescription: TPanel
        Left = 100
        Top = 5
        Width = 615
        Height = 35
        Align = alClient
        AutoSize = True
        BevelOuter = bvNone
        ParentColor = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        StyleElements = []
        object img_extraDescription_info: TImage
          Left = 583
          Top = 0
          Width = 32
          Height = 35
          CustomHint = balloonHint
          Align = alRight
          ParentShowHint = False
          Picture.Data = {
            0B546478504E47496D61676589504E470D0A1A0A0000000D4948445200000020
            000000200806000000737A7AF40000001974455874536F667477617265004164
            6F626520496D616765526561647971C9653C0000000B744558745469746C6500
            496E666F3B6D122D86000000D849444154785EEDD7B10DC3201086D14C40C538
            EEE99881016E10B6714BE92DDCD17905DACB1FC955448231CA1D458AD75A9F85
            C1C7839955CD13B02C4B8B010F11126428A70C092278308D6775055820D8802F
            DA80C08E063858816F5AC1DD0D08B0030FDA21F4060438804FA30E0857035CF5
            CDC7EDE05A01B6B1E6A356B0DF0208F8C7E85380E9D96AEF074AE71635B5000F
            2C10F0E26B01513020D602926040AA0564C1805C0B288201453D407D09D43FC2
            29B7A10716E2A73C8A5F482080D47FC7DA0389FE48A63F94EA8FE5FA179379AE
            66FFDBF1133FB4970A6D7EA48C0000000049454E44AE426082}
          Proportional = True
          ShowHint = True
          ExplicitLeft = 525
          ExplicitTop = 11
          ExplicitHeight = 24
        end
        object _spacer__extraDescription_left: TRzSpacer
          Left = 0
          Top = 0
          Width = 32
          Height = 35
          Orientation = orVertical
          Align = alLeft
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitHeight = 22
        end
        object lbl_extraDescription: TLabel
          Left = 32
          Top = 0
          Width = 183
          Height = 29
          Align = alClient
          Alignment = taCenter
          Caption = 'Extra Description'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -24
          Font.Name = 'Roboto'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
          StyleElements = []
        end
      end
    end
  end
  object balloonHint: TBalloonHint
    Style = bhsStandard
    Delay = 0
    HideAfter = 15000
    Left = 645
    Top = 481
  end
end
