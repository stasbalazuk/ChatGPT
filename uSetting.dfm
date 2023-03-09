object fSetting: TfSetting
  Left = 512
  Top = 312
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 287
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 408
    Height = 239
    Align = alClient
    BevelInner = bvRaised
    TabOrder = 0
    object ltemp: TLabel
      Left = 8
      Top = 214
      Width = 69
      Height = 13
      Caption = 'Temperature :'
    end
    object grpT: TGroupBox
      Left = 2
      Top = 2
      Width = 404
      Height = 71
      Align = alTop
      Caption = 'Token'
      TabOrder = 0
      object mmoToken: TMemo
        Left = 2
        Top = 15
        Width = 400
        Height = 54
        Align = alClient
        Lines.Strings = (
          '')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object edtTemp: TEdit
      Left = 80
      Top = 214
      Width = 41
      Height = 19
      BorderStyle = bsNone
      Color = clBtnFace
      Enabled = False
      TabOrder = 1
      Text = '0'
      OnKeyPress = edtTempKeyPress
    end
    object ud1: TUpDown
      Left = 121
      Top = 214
      Width = 16
      Height = 19
      Associate = edtTemp
      Max = 2
      TabOrder = 2
    end
    object grpGoogleLanguageApiKey: TGroupBox
      Left = 2
      Top = 73
      Width = 404
      Height = 72
      Align = alTop
      Caption = 'Google Language ApiKey'
      TabOrder = 3
      object mmoGoogleLanguageApiKey: TMemo
        Left = 2
        Top = 15
        Width = 400
        Height = 55
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object grpTelegram: TGroupBox
      Left = 2
      Top = 145
      Width = 404
      Height = 64
      Align = alTop
      Caption = 
        'Telegram ApiKey                                                 ' +
        '                        ChatID'
      TabOrder = 4
      object spl1: TSplitter
        Left = 301
        Top = 15
        Height = 47
        Align = alRight
      end
      object mmoTb: TMemo
        Left = 2
        Top = 15
        Width = 299
        Height = 47
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object mmoChatID: TMemo
        Left = 304
        Top = 15
        Width = 98
        Height = 47
        Align = alRight
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 239
    Width = 408
    Height = 48
    Align = alBottom
    BevelInner = bvRaised
    TabOrder = 1
    object btnSave: TBitBtn
      Left = 320
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Save'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnSaveClick
    end
  end
end
