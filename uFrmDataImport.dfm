object FrmDataImport: TFrmDataImport
  Left = 0
  Top = 0
  Caption = 'FrmDataImport'
  ClientHeight = 469
  ClientWidth = 749
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
    749
    469)
  PixelsPerInch = 96
  TextHeight = 13
  object grpCsv: TGroupBox
    Left = 8
    Top = 8
    Width = 733
    Height = 217
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'CSV file:'
    TabOrder = 0
    ExplicitWidth = 619
    DesignSize = (
      733
      217)
    object lblCsvPath: TLabel
      Left = 16
      Top = 24
      Width = 26
      Height = 13
      Caption = 'Path:'
    end
    object lblCsvDelim: TLabel
      Left = 16
      Top = 55
      Width = 45
      Height = 13
      Caption = 'Delimiter:'
    end
    object lblCsvRowCnt: TLabel
      Left = 112
      Top = 55
      Width = 98
      Height = 13
      Caption = 'Preview Row Count:'
    end
    object lblCsvErrMark: TLabel
      Left = 472
      Top = 55
      Width = 70
      Height = 13
      Caption = 'Cell ERR mark:'
    end
    object edCsvPath: TEdit
      Left = 48
      Top = 21
      Width = 587
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edCsvPathChange
      ExplicitWidth = 473
    end
    object btnCsvOpen: TButton
      Left = 642
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = btnCsvOpenClick
      ExplicitLeft = 528
    end
    object btnCsvPreview: TButton
      Left = 642
      Top = 50
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Preview'
      TabOrder = 2
      OnClick = btnCsvPreviewClick
      ExplicitLeft = 528
    end
    object sgrd: TStringGrid
      Left = 16
      Top = 80
      Width = 701
      Height = 120
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 1
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      TabOrder = 3
      ExplicitWidth = 587
    end
    object edCsvDelim: TEdit
      Left = 67
      Top = 53
      Width = 30
      Height = 21
      Alignment = taCenter
      MaxLength = 1
      TabOrder = 4
      Text = ';'
      OnChange = edCsvDelimChange
    end
    object chbFstRowIsHeader: TCheckBox
      Left = 310
      Top = 54
      Width = 62
      Height = 17
      Caption = 'Header'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = chbFstRowIsHeaderClick
    end
    object edCsvRowCnt: TEdit
      Left = 216
      Top = 53
      Width = 73
      Height = 21
      NumbersOnly = True
      TabOrder = 6
      Text = '10'
      OnChange = edCsvRowCntChange
    end
    object chbTrimCells: TCheckBox
      Left = 383
      Top = 54
      Width = 72
      Height = 17
      Caption = 'Trim Cells'
      TabOrder = 7
      OnClick = chbTrimCellsClick
    end
    object edCsvErrMark: TEdit
      Left = 548
      Top = 52
      Width = 88
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 8
      Text = '#'
      OnChange = edCsvErrMarkChange
    end
  end
end
