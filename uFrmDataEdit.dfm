object FrmDataEdit: TFrmDataEdit
  Left = 0
  Top = 0
  Caption = 'FrmDataEdit'
  ClientHeight = 360
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    559
    360)
  PixelsPerInch = 96
  TextHeight = 13
  object lblCaption: TLabel
    Left = 8
    Top = 9
    Width = 54
    Height = 25
    Caption = 'Edit...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object panLower: TPanel
    Left = 0
    Top = 43
    Width = 561
    Height = 318
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 637
    ExplicitHeight = 391
    DesignSize = (
      561
      318)
    object lblFld1: TLabel
      Left = 16
      Top = 24
      Width = 114
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblFld1'
      Visible = False
    end
    object lblTypeFld1: TLabel
      Left = 383
      Top = 24
      Width = 54
      Height = 13
      Caption = 'lblTypeFld1'
      Visible = False
    end
    object lblLenFld1: TLabel
      Left = 464
      Top = 24
      Width = 47
      Height = 13
      Caption = 'lblLenFld1'
      Visible = False
    end
    object lblFld2: TLabel
      Left = 16
      Top = 56
      Width = 114
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblFld2'
      Visible = False
    end
    object lblTypeFld2: TLabel
      Left = 383
      Top = 56
      Width = 54
      Height = 13
      Caption = 'lblTypeFld2'
      Visible = False
    end
    object lblLenFld2: TLabel
      Left = 464
      Top = 56
      Width = 47
      Height = 13
      Caption = 'lblLenFld2'
      Visible = False
    end
    object lblFld3: TLabel
      Left = 16
      Top = 88
      Width = 114
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblFld3'
      Visible = False
    end
    object lblTypeFld3: TLabel
      Left = 383
      Top = 88
      Width = 54
      Height = 13
      Caption = 'lblTypeFld3'
      Visible = False
    end
    object lblLenFld3: TLabel
      Left = 464
      Top = 88
      Width = 47
      Height = 13
      Caption = 'lblLenFld3'
      Visible = False
    end
    object lblFld4: TLabel
      Left = 16
      Top = 120
      Width = 114
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblFld4'
      Visible = False
    end
    object lblTypeFld4: TLabel
      Left = 383
      Top = 120
      Width = 54
      Height = 13
      Caption = 'lblTypeFld4'
      Visible = False
    end
    object lblLenFld4: TLabel
      Left = 464
      Top = 120
      Width = 47
      Height = 13
      Caption = 'lblLenFld4'
      Visible = False
    end
    object lblFld5: TLabel
      Left = 16
      Top = 152
      Width = 114
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblFld5'
      Visible = False
    end
    object lblTypeFld5: TLabel
      Left = 383
      Top = 152
      Width = 54
      Height = 13
      Caption = 'lblTypeFld5'
      Visible = False
    end
    object lblLenFld5: TLabel
      Left = 464
      Top = 152
      Width = 47
      Height = 13
      Caption = 'lblLenFld5'
      Visible = False
    end
    object edFld1: TEdit
      Left = 136
      Top = 21
      Width = 177
      Height = 21
      TabOrder = 0
      Visible = False
    end
    object chbNullFld1: TCheckBox
      Left = 328
      Top = 23
      Width = 49
      Height = 17
      TabStop = False
      Caption = 'NULL'
      TabOrder = 1
      Visible = False
    end
    object cbbFld1: TComboBox
      Left = 145
      Top = 21
      Width = 177
      Height = 21
      TabOrder = 2
      Visible = False
    end
    object edFld2: TEdit
      Left = 136
      Top = 53
      Width = 177
      Height = 21
      TabOrder = 3
      Visible = False
    end
    object chbNullFld2: TCheckBox
      Left = 328
      Top = 55
      Width = 49
      Height = 17
      TabStop = False
      Caption = 'NULL'
      TabOrder = 4
      Visible = False
    end
    object cbbFld2: TComboBox
      Left = 145
      Top = 53
      Width = 177
      Height = 21
      TabOrder = 5
      Visible = False
    end
    object edFld3: TEdit
      Left = 136
      Top = 85
      Width = 177
      Height = 21
      TabOrder = 6
      Visible = False
    end
    object cbbFld3: TComboBox
      Left = 145
      Top = 85
      Width = 177
      Height = 21
      TabOrder = 7
      Visible = False
    end
    object chbNullFld3: TCheckBox
      Left = 328
      Top = 87
      Width = 49
      Height = 17
      TabStop = False
      Caption = 'NULL'
      TabOrder = 8
      Visible = False
    end
    object edFld4: TEdit
      Left = 136
      Top = 117
      Width = 177
      Height = 21
      TabOrder = 9
      Visible = False
    end
    object cbbFld4: TComboBox
      Left = 145
      Top = 117
      Width = 177
      Height = 21
      TabOrder = 10
      Visible = False
    end
    object chbNullFld4: TCheckBox
      Left = 328
      Top = 119
      Width = 49
      Height = 17
      TabStop = False
      Caption = 'NULL'
      TabOrder = 11
      Visible = False
    end
    object btnUpdate: TButton
      Left = 368
      Top = 272
      Width = 90
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = 'Update'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 12
      OnClick = btnUpdateClick
    end
    object btnClose: TButton
      Left = 472
      Top = 280
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      TabOrder = 13
      OnClick = btnCloseClick
    end
    object edFld5: TEdit
      Left = 136
      Top = 149
      Width = 177
      Height = 21
      TabOrder = 14
      Visible = False
    end
    object cbbFld5: TComboBox
      Left = 145
      Top = 149
      Width = 177
      Height = 21
      TabOrder = 15
      Visible = False
    end
    object chbNullFld5: TCheckBox
      Left = 328
      Top = 151
      Width = 49
      Height = 17
      TabStop = False
      Caption = 'NULL'
      TabOrder = 16
      Visible = False
    end
  end
end
