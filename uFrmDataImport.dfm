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
      Top = 183
      Width = 733
      Height = 203
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Database Table'
      TabOrder = 0
      Visible = False
      DesignSize = (
        733
        203)
      object lblTblCol: TLabel
        Left = 16
        Top = 24
        Width = 39
        Height = 13
        Caption = 'Column:'
      end
      object lblTblCsvCol: TLabel
        Left = 16
        Top = 48
        Width = 61
        Height = 13
        Caption = 'CSV Column:'
      end
      object cbbTblCol: TComboBox
        Left = 83
        Top = 18
        Width = 130
        Height = 21
        Style = csDropDownList
        TabOrder = 0
      end
      object cbbTblCsvCol: TComboBox
        Left = 83
        Top = 45
        Width = 129
        Height = 21
        Style = csDropDownList
        TabOrder = 1
      end
      object btnTblColAdd: TButton
        Left = 286
        Top = 27
        Width = 55
        Height = 25
        Caption = 'Add'
        TabOrder = 2
        OnClick = btnTblColAddClick
      end
      object sgrdDef: TStringGrid
        Left = 16
        Top = 72
        Width = 701
        Height = 117
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 3
        ColWidths = (
          64)
        RowHeights = (
          24)
      end
      object btnTblColReset: TButton
        Left = 354
        Top = 27
        Width = 59
        Height = 25
        Caption = 'Clear'
        TabOrder = 4
        OnClick = btnTblColResetClick
      end
      object chbTblCsvTRIM: TCheckBox
        Left = 232
        Top = 31
        Width = 48
        Height = 17
        Caption = 'TRIM'
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
    end
    object grpCsv: TGroupBox
      Left = 12
      Top = 13
      Width = 733
      Height = 164
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'CSV file:'
      ParentBackground = False
      ParentColor = False
      TabOrder = 1
      DesignSize = (
        733
        164)
      object lblCsvPath: TLabel
        Left = 376
        Top = 24
        Width = 26
        Height = 13
        Caption = 'Path:'
      end
      object lblCsvDelim: TLabel
        Left = 16
        Top = 24
        Width = 33
        Height = 13
        Caption = 'Delim.:'
      end
      object lblCsvRowCnt: TLabel
        Left = 176
        Top = 19
        Width = 65
        Height = 30
        AutoSize = False
        Caption = 'Preview Row Count:'
        WordWrap = True
      end
      object lblCsvErrMark: TLabel
        Left = 296
        Top = 19
        Width = 41
        Height = 25
        AutoSize = False
        Caption = 'ERR mark:'
        WordWrap = True
      end
      object edCsvPath: TEdit
        Left = 408
        Top = 21
        Width = 178
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edCsvPathChange
      end
      object btnCsvOpen: TButton
        Left = 592
        Top = 19
        Width = 34
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 1
        OnClick = btnCsvOpenClick
      end
      object btnCsvPreview: TButton
        Left = 642
        Top = 19
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Preview'
        TabOrder = 2
        OnClick = btnCsvPreviewClick
      end
      object sgrd: TStringGrid
        Left = 16
        Top = 55
        Width = 701
        Height = 92
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 3
        ColWidths = (
          64)
        RowHeights = (
          24)
      end
      object edCsvDelim: TEdit
        Left = 55
        Top = 21
        Width = 30
        Height = 21
        Alignment = taCenter
        MaxLength = 1
        TabOrder = 4
        Text = ';'
        OnChange = edCsvDelimChange
      end
      object chbFstRowIsHeader: TCheckBox
        Left = 98
        Top = 14
        Width = 62
        Height = 17
        Caption = 'Header'
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = chbFstRowIsHeaderClick
      end
      object edCsvRowCnt: TEdit
        Left = 247
        Top = 21
        Width = 33
        Height = 21
        NumbersOnly = True
        TabOrder = 6
        Text = '10'
        OnChange = edCsvRowCntChange
      end
      object chbTrimCells: TCheckBox
        Left = 98
        Top = 32
        Width = 72
        Height = 17
        Caption = 'Trim Cells'
        TabOrder = 7
        OnClick = chbTrimCellsClick
      end
      object edCsvErrMark: TEdit
        Left = 332
        Top = 21
        Width = 29
        Height = 21
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
      Cancel = True
      Caption = 'Close'
      TabOrder = 4
      OnClick = btnCloseClick
    end
  end
  object tmrStart: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrStartTimer
    Left = 136
    Top = 8
  end
end
