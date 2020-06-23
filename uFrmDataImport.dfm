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
  object lblCaption: TLabel
    Left = 8
    Top = 9
    Width = 82
    Height = 25
    Caption = 'Import...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object panLower: TPanel
    Left = -4
    Top = 43
    Width = 754
    Height = 430
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      754
      430)
    object grpTbl: TGroupBox
      Left = 12
      Top = 207
      Width = 733
      Height = 179
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Database Table'
      TabOrder = 0
      Visible = False
      DesignSize = (
        733
        179)
      object lblTblNm: TLabel
        Left = 16
        Top = 24
        Width = 30
        Height = 13
        Caption = 'Table:'
      end
      object lblTblCol: TLabel
        Left = 179
        Top = 24
        Width = 39
        Height = 13
        Caption = 'Column:'
      end
      object lblTblCsvCol: TLabel
        Left = 367
        Top = 24
        Width = 61
        Height = 13
        Caption = 'CSV Column:'
      end
      object edTblNm: TEdit
        Left = 52
        Top = 21
        Width = 109
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = 'N/A'
      end
      object cbbTblCol: TComboBox
        Left = 223
        Top = 21
        Width = 130
        Height = 21
        Style = csDropDownList
        TabOrder = 1
      end
      object cbbTblCsvCol: TComboBox
        Left = 433
        Top = 21
        Width = 129
        Height = 21
        Style = csDropDownList
        TabOrder = 2
      end
      object btnTblColAdd: TButton
        Left = 584
        Top = 19
        Width = 55
        Height = 25
        Caption = 'Add'
        TabOrder = 3
        OnClick = btnTblColAddClick
      end
      object sgrdDef: TStringGrid
        Left = 16
        Top = 56
        Width = 701
        Height = 109
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 4
        ExplicitHeight = 80
        ColWidths = (
          64)
        RowHeights = (
          24)
      end
      object btnTblColReset: TButton
        Left = 658
        Top = 19
        Width = 59
        Height = 25
        Caption = 'Clear'
        TabOrder = 5
        OnClick = btnTblColResetClick
      end
    end
    object grpCsv: TGroupBox
      Left = 12
      Top = 13
      Width = 733
      Height = 188
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'CSV file:'
      ParentBackground = False
      ParentColor = False
      TabOrder = 1
      DesignSize = (
        733
        188)
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
      end
      object sgrd: TStringGrid
        Left = 16
        Top = 80
        Width = 701
        Height = 91
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 3
        ExplicitHeight = 120
        ColWidths = (
          64)
        RowHeights = (
          24)
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
    object btnImport: TButton
      Left = 12
      Top = 392
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Import'
      Enabled = False
      TabOrder = 2
      OnClick = btnImportClick
    end
    object btnPreCheck: TButton
      Left = 98
      Top = 392
      Width = 132
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Check before Import'
      TabOrder = 3
      OnClick = btnPreCheckClick
    end
    object btnClose: TButton
      Left = 670
      Top = 392
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Close'
      TabOrder = 4
      OnClick = btnCloseClick
    end
  end
end
