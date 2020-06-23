object FrmProgress: TFrmProgress
  Left = 0
  Top = 0
  Caption = 'FrmProgress'
  ClientHeight = 328
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -21
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    458
    328)
  PixelsPerInch = 96
  TextHeight = 25
  object lblCaption: TLabel
    Left = 8
    Top = 9
    Width = 98
    Height = 25
    Caption = 'Progress...'
  end
  object panLower: TPanel
    Left = 0
    Top = 56
    Width = 459
    Height = 273
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      459
      273)
    object lbHistory: TListBox
      Left = 24
      Top = 24
      Width = 411
      Height = 201
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 0
    end
    object btnClose: TButton
      Left = 360
      Top = 240
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Close'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnCloseClick
    end
    object btnCancel: TButton
      Left = 279
      Top = 240
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Visible = False
    end
  end
  object pbPrs: TProgressBar
    Left = 0
    Top = 43
    Width = 459
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
end
