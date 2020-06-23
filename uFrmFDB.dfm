object FrmFDB: TFrmFDB
  Left = 0
  Top = 0
  Caption = 'FrmFDB'
  ClientHeight = 364
  ClientWidth = 602
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
    602
    364)
  PixelsPerInch = 96
  TextHeight = 13
  object lblCaption: TLabel
    Left = 8
    Top = 9
    Width = 194
    Height = 25
    Caption = 'Connect to Database'
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
    Width = 604
    Height = 322
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      604
      322)
    object lblUser: TLabel
      Left = 216
      Top = 96
      Width = 26
      Height = 13
      Caption = 'User:'
    end
    object lblPw: TLabel
      Left = 192
      Top = 135
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object lblDb: TLabel
      Left = 8
      Top = 8
      Width = 219
      Height = 13
      Caption = 'Firebird Database Connect Strings (from INI):'
      Visible = False
    end
    object edUser: TEdit
      Left = 248
      Top = 93
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object edPw: TEdit
      Left = 248
      Top = 132
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
    object btnLogin: TButton
      Left = 216
      Top = 176
      Width = 75
      Height = 25
      Caption = 'Login'
      TabOrder = 2
      OnClick = btnLoginClick
    end
    object btnClose: TButton
      Left = 313
      Top = 176
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseClick
    end
    object cbbDb: TComboBox
      Left = 8
      Top = 27
      Width = 548
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Visible = False
    end
    object chbServerCharsetUtf8: TCheckBox
      Left = 8
      Top = 54
      Width = 140
      Height = 17
      Caption = 'Server CharSet = UTF8'
      Checked = True
      State = cbChecked
      TabOrder = 5
      Visible = False
    end
    object btnDbOpen: TButton
      Left = 562
      Top = 25
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 7
      Visible = False
      OnClick = btnDbOpenClick
    end
    object grpIsql: TGroupBox
      Left = 8
      Top = 77
      Width = 169
      Height = 124
      Caption = 'Firebird Isql tool'
      TabOrder = 8
      Visible = False
      object btnIsqlTest: TButton
        Left = 12
        Top = 25
        Width = 65
        Height = 25
        Caption = 'Test Isql'
        TabOrder = 0
        OnClick = btnIsqlTestClick
      end
    end
    object chbIsqlVisible: TCheckBox
      Left = 95
      Top = 102
      Width = 74
      Height = 17
      Caption = 'Show Isql'
      TabOrder = 9
    end
    object btnCreTblSample: TButton
      Left = 452
      Top = 144
      Width = 143
      Height = 57
      Anchors = [akTop, akRight]
      Caption = 'Create Table'
      Enabled = False
      TabOrder = 10
      Visible = False
      WordWrap = True
      OnClick = btnCreTblSampleClick
    end
    object chbAutoLogin: TCheckBox
      Left = 248
      Top = 54
      Width = 97
      Height = 17
      Caption = 'Auto Login'
      TabOrder = 11
      OnClick = chbAutoLoginClick
    end
    object btnCrePrdTbls: TButton
      Left = 452
      Top = 80
      Width = 143
      Height = 58
      Anchors = [akTop, akRight]
      Caption = 
        'Create Product Tables (in Empty DB or to add product to an exist' +
        'ing DB)'
      Enabled = False
      TabOrder = 12
      WordWrap = True
      OnClick = btnCrePrdTblsClick
    end
    object chbDoDbUpdate: TCheckBox
      Left = 452
      Top = 54
      Width = 97
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Do DB Update'
      Checked = True
      State = cbChecked
      TabOrder = 13
    end
    object btnIsqlShowDb: TButton
      Left = 20
      Top = 164
      Width = 147
      Height = 25
      Caption = 'SHOW Database'
      TabOrder = 14
      OnClick = btnIsqlShowDbClick
    end
    object tsDev: TTabSet
      Left = 0
      Top = 216
      Width = 602
      Height = 79
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      SelectedColor = clInactiveCaption
      SoftTop = True
      Style = tsSoftTabs
      Tabs.Strings = (
        'LOG'
        'SQL Editor')
      TabIndex = 1
      Visible = False
      OnChange = tsDevChange
    end
    object lbLog: TListBox
      Left = 14
      Top = 240
      Width = 575
      Height = 38
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 16
      Visible = False
      OnDblClick = lbLogDblClick
    end
    object moSql: TMemo
      Left = 14
      Top = 254
      Width = 575
      Height = 24
      Anchors = [akLeft, akTop, akRight, akBottom]
      ScrollBars = ssBoth
      TabOrder = 17
      Visible = False
    end
    object btnSqlOpen: TButton
      Left = 127
      Top = 223
      Width = 75
      Height = 25
      Caption = 'Open Query'
      Enabled = False
      TabOrder = 18
      Visible = False
      OnClick = btnSqlOpenClick
    end
    object btnSqlOpenSample: TButton
      Left = 208
      Top = 223
      Width = 57
      Height = 25
      Caption = 'Sample'
      TabOrder = 19
      Visible = False
      OnClick = btnSqlOpenSampleClick
    end
    object btnIsqlExec: TButton
      Left = 313
      Top = 223
      Width = 75
      Height = 25
      Caption = 'Isql Exec'
      TabOrder = 20
      Visible = False
      OnClick = btnIsqlExecClick
    end
    object btnIsqlExecSample: TButton
      Left = 394
      Top = 223
      Width = 57
      Height = 25
      Caption = 'Sample'
      TabOrder = 21
      Visible = False
      OnClick = btnIsqlExecSampleClick
    end
    object edTerm: TEdit
      Left = 470
      Top = 225
      Width = 50
      Height = 21
      Hint = 'Firebird Isql SET TERM ?'
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 22
      Text = ';'
      Visible = False
    end
    object btnIsqlCreateDb: TButton
      Left = 20
      Top = 133
      Width = 147
      Height = 25
      Caption = 'CREATE Database'
      TabOrder = 23
      OnClick = btnIsqlCreateDbClick
    end
    object panDbInfo: TPanel
      Left = 0
      Top = 293
      Width = 604
      Height = 29
      Alignment = taLeftJustify
      Anchors = [akLeft, akRight, akBottom]
      BevelEdges = []
      BevelInner = bvRaised
      BorderStyle = bsSingle
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 6
      Visible = False
    end
  end
  object panAdminMode: TPanel
    Left = 372
    Top = 24
    Width = 217
    Height = 29
    Anchors = [akTop, akRight]
    BevelEdges = []
    BevelInner = bvRaised
    BorderStyle = bsSingle
    Caption = 'Database Administration Mode'
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    Visible = False
  end
end
