object myChatGPT: TmyChatGPT
  Left = 364
  Top = 177
  Width = 1196
  Height = 659
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object spl2: TSplitter
    Left = 869
    Top = 0
    Height = 628
    Align = alRight
  end
  object spl3: TSplitter
    Left = 145
    Top = 0
    Height = 628
  end
  object grp1: TGroupBox
    Left = 148
    Top = 0
    Width = 721
    Height = 628
    Align = alClient
    Caption = 'Response ChatGPT'
    TabOrder = 0
    object spl1: TSplitter
      Left = 2
      Top = 582
      Width = 717
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object Memo1: TMemo
      Left = 2
      Top = 15
      Width = 632
      Height = 408
      Color = clCream
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      Visible = False
      OnChange = Memo1Change
    end
    object grpTrans: TGroupBox
      Left = 2
      Top = 15
      Width = 717
      Height = 567
      Align = alClient
      Caption = 'Translate [EN/RU]'
      TabOrder = 1
      object Memo2: TMemo
        Left = 2
        Top = 15
        Width = 713
        Height = 550
        Align = alClient
        Color = clSkyBlue
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object pnl2: TPanel
      Left = 2
      Top = 585
      Width = 717
      Height = 41
      Align = alBottom
      BevelInner = bvLowered
      TabOrder = 2
      DesignSize = (
        717
        41)
      object edt1: TEdit
        Left = 8
        Top = 6
        Width = 705
        Height = 31
        Anchors = [akLeft, akTop, akBottom]
        BevelInner = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnKeyPress = edt1KeyPress
      end
    end
  end
  object grp2: TGroupBox
    Left = 872
    Top = 0
    Width = 316
    Height = 628
    Align = alRight
    Caption = 'Response Json'
    TabOrder = 1
    object mmo1: TMemo
      Left = 2
      Top = 15
      Width = 312
      Height = 611
      Align = alClient
      Enabled = False
      Lines.Strings = (
        '')
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 145
    Height = 628
    Align = alLeft
    BevelInner = bvLowered
    TabOrder = 2
    object g_query: TGroupBox
      Left = 2
      Top = 2
      Width = 141
      Height = 270
      Align = alClient
      Caption = 'Settings'
      TabOrder = 0
      object btn1: TButton
        Left = 8
        Top = 56
        Width = 121
        Height = 25
        Caption = 'Authentication'
        TabOrder = 0
        OnClick = btn1Click
      end
      object chksave: TCheckBox
        Left = 8
        Top = 248
        Width = 57
        Height = 17
        Caption = 'Save'
        TabOrder = 1
        OnClick = chksaveClick
      end
      object btnToken: TButton
        Left = 8
        Top = 24
        Width = 121
        Height = 25
        Caption = 'Your token'
        TabOrder = 2
        OnClick = btnTokenClick
      end
    end
    object grpClean: TGroupBox
      Left = 2
      Top = 272
      Width = 141
      Height = 354
      Align = alBottom
      Caption = 'Save'
      TabOrder = 1
      object lst2: TListBox
        Left = 2
        Top = 15
        Width = 137
        Height = 318
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = lst2Click
      end
      object stat1: TStatusBar
        Left = 2
        Top = 333
        Width = 137
        Height = 19
        Panels = <>
      end
    end
  end
end
