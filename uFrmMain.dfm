object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 614
  ClientWidth = 917
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    917
    614)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTop: TLabel
    Left = 300
    Top = 65
    Width = 203
    Height = 13
    Caption = 'N/A (Query, Provider and Client DataSet):'
  end
  object lblBottom: TLabel
    Left = 300
    Top = 293
    Width = 105
    Height = 13
    Caption = 'N/A (Simple DataSet):'
  end
  object lblDb: TLabel
    Left = 16
    Top = 8
    Width = 219
    Height = 13
    Caption = 'Firebird Database Connect Strings (from INI):'
  end
  object lblDbInfo: TLabel
    Left = 162
    Top = 34
    Width = 73
    Height = 13
    Caption = 'Database Info:'
  end
  object btnConnect: TButton
    Left = 63
    Top = 56
    Width = 100
    Height = 32
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object db_grid_Top: TDBGrid
    Left = 300
    Top = 84
    Width = 609
    Height = 193
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_Top
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object db_grid_Bottom: TDBGrid
    Left = 300
    Top = 312
    Width = 609
    Height = 193
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_sds_Bottom
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object btnGetMetadata: TButton
    Left = 8
    Top = 133
    Width = 130
    Height = 25
    Caption = 'Get Metadata'
    Enabled = False
    TabOrder = 3
    OnClick = btnGetMetadataClick
  end
  object lbResult: TListBox
    Left = 8
    Top = 164
    Width = 273
    Height = 351
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 4
    OnDblClick = lbResultDblClick
  end
  object btnRefreshBottom: TButton
    Left = 848
    Top = 287
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 5
    OnClick = btnRefreshBottomClick
  end
  object btnRefreshTop: TButton
    Left = 848
    Top = 59
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 6
    OnClick = btnRefreshTopClick
  end
  object btnInsertBottom: TButton
    Left = 791
    Top = 287
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 7
    OnClick = btnInsertBottomClick
  end
  object btnInsertTop: TButton
    Left = 791
    Top = 59
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 8
    OnClick = btnInsertTopClick
  end
  object btnDeleteBottom: TButton
    Left = 728
    Top = 287
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 9
    OnClick = btnDeleteBottomClick
  end
  object btnDeleteTop: TButton
    Left = 728
    Top = 59
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 10
    OnClick = btnDeleteTopClick
  end
  object chbMetadataTablesOnly: TCheckBox
    Left = 144
    Top = 141
    Width = 150
    Height = 17
    Caption = 'List Tables Only (On/Off)'
    TabOrder = 11
    OnClick = chbMetadataTablesOnlyClick
  end
  object cbbDb: TComboBox
    Left = 311
    Top = 5
    Width = 598
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 12
  end
  object btnCreTblSample: TButton
    Left = 8
    Top = 555
    Width = 273
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Create Table'
    Enabled = False
    TabOrder = 13
    WordWrap = True
    OnClick = btnCreTblSampleClick
  end
  object btnDrpTbl: TButton
    Left = 8
    Top = 583
    Width = 81
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Drop Table'
    Enabled = False
    TabOrder = 14
    WordWrap = True
    OnClick = btnDrpTblClick
  end
  object edDbInfo: TEdit
    Left = 241
    Top = 31
    Width = 668
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 15
    Text = '<none>'
  end
  object btnCrePrdTbls: TButton
    Left = 8
    Top = 94
    Width = 273
    Height = 31
    Caption = 'Create Product Tables'
    Enabled = False
    TabOrder = 16
    WordWrap = True
    OnClick = btnCrePrdTblsClick
  end
  object chbServerCharsetUtf8: TCheckBox
    Left = 16
    Top = 33
    Width = 140
    Height = 17
    Caption = 'Server CharSet = UTF8'
    TabOrder = 17
  end
  object chbDoDbUpdate: TCheckBox
    Left = 179
    Top = 53
    Width = 97
    Height = 17
    Caption = 'Do DB Update'
    Checked = True
    State = cbChecked
    TabOrder = 18
  end
  object btnIsql: TButton
    Left = 8
    Top = 56
    Width = 45
    Height = 17
    Caption = 'ISQL'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 19
    OnClick = btnIsqlClick
  end
  object chbIsqlVisible: TCheckBox
    Left = 8
    Top = 73
    Width = 49
    Height = 18
    Caption = 'Visible'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 20
  end
  object tsDev: TTabSet
    Left = 300
    Top = 514
    Width = 609
    Height = 92
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Tabs.Strings = (
      'LOG'
      'SQL Editor')
    TabIndex = 0
    OnChange = tsDevChange
  end
  object lbLog: TListBox
    Left = 309
    Top = 535
    Width = 587
    Height = 58
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 22
    OnDblClick = lbLogDblClick
  end
  object moSql: TMemo
    Left = 310
    Top = 560
    Width = 587
    Height = 33
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 23
  end
  object btnSqlOpen: TButton
    Left = 309
    Top = 533
    Width = 75
    Height = 25
    Caption = 'Open Query'
    Enabled = False
    TabOrder = 24
    OnClick = btnSqlOpenClick
  end
  object btnSqlOpenSample: TButton
    Left = 382
    Top = 533
    Width = 57
    Height = 25
    Caption = 'Sample'
    TabOrder = 25
    OnClick = btnSqlOpenSampleClick
  end
  object btnIsqlExec: TButton
    Left = 464
    Top = 533
    Width = 75
    Height = 25
    Caption = 'Isql Exec'
    TabOrder = 26
    OnClick = btnIsqlExecClick
  end
  object btnIsqlExecSample: TButton
    Left = 536
    Top = 533
    Width = 57
    Height = 25
    Caption = 'Sample'
    TabOrder = 27
    OnClick = btnIsqlExecSampleClick
  end
  object edTerm: TEdit
    Left = 599
    Top = 535
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
    TabOrder = 28
    Text = ';'
  end
  object btnDbOpen: TButton
    Left = 241
    Top = 3
    Width = 64
    Height = 25
    Caption = 'Open...'
    TabOrder = 29
    OnClick = btnDbOpenClick
  end
  object btnDrpCol: TButton
    Left = 95
    Top = 583
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Drop Column'
    Enabled = False
    TabOrder = 30
    OnClick = btnDrpColClick
  end
  object btnImpTbl: TButton
    Left = 8
    Top = 523
    Width = 137
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Import Table (.CSV)'
    TabOrder = 31
    OnClick = btnImpTblClick
  end
  object chbAutoConnect: TCheckBox
    Left = 179
    Top = 71
    Width = 97
    Height = 17
    Caption = 'Auto Connect'
    TabOrder = 32
    OnClick = chbAutoConnectClick
  end
  object con_Firebird_ANSI: TSQLConnection
    DriverName = 'Firebird'
    Params.Strings = (
      'GetDriverFunc=getSQLDriverINTERBASE'
      'Database=database.fdb'
      'User_Name=sysdba'
      'Password=masterkey'
      'ServerCharSet='
      'DriverName=Firebird'
      'DriverUnit=Data.DBXFirebird'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver240.' +
        'bpl'
      
        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=24.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'
      
        'MetaDataPackageLoader=TDBXFirebirdMetaDataCommandFactory,DbxFire' +
        'birdDriver240.bpl'
      
        'MetaDataAssemblyLoader=Borland.Data.TDBXFirebirdMetaDataCommandF' +
        'actory,Borland.Data.DbxFirebirdDriver,Version=24.0.0.0,Culture=n' +
        'eutral,PublicKeyToken=91d62ebb5b0d1b1b'
      'LibraryName=dbxfb.dll'
      'LibraryNameOsx=libsqlfb.dylib'
      'VendorLib=fbclient.dll'
      'VendorLibWin64=fbclient.dll'
      'VendorLibOsx=/Library/Frameworks/Firebird.framework/Firebird'
      'Role=RoleName'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'IsolationLevel=ReadCommitted'
      'SQLDialect=3'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'TrimChar=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'RoleName=RoleName'
      'Trim Char=False')
    Left = 64
    Top = 212
  end
  object qry_Top: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = con_Firebird_ANSI
    Left = 332
    Top = 96
  end
  object dsp_Top: TDataSetProvider
    DataSet = qry_Top
    Left = 420
    Top = 97
  end
  object cds_Top: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Top'
    AfterPost = cds_TopAfterPost
    Left = 500
    Top = 96
  end
  object ds_cds_Top: TDataSource
    DataSet = cds_Top
    Left = 724
    Top = 96
  end
  object sds_Bottom: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird_ANSI
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_BottomAfterPost
    Left = 332
    Top = 326
  end
  object ds_sds_Bottom: TDataSource
    DataSet = sds_Bottom
    Left = 724
    Top = 326
  end
  object con_Firebird_UTF8: TSQLConnection
    DriverName = 'Firebird'
    Params.Strings = (
      'Database=database.fdb'
      'User_Name=sysdba'
      'Password=masterkey'
      'GetDriverFunc=getSQLDriverINTERBASE'
      'ServerCharSet=UTF8'
      'DriverName=Firebird'
      'DriverUnit=Data.DBXFirebird'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver240.' +
        'bpl'
      
        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=24.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'
      
        'MetaDataPackageLoader=TDBXFirebirdMetaDataCommandFactory,DbxFire' +
        'birdDriver240.bpl'
      
        'MetaDataAssemblyLoader=Borland.Data.TDBXFirebirdMetaDataCommandF' +
        'actory,Borland.Data.DbxFirebirdDriver,Version=24.0.0.0,Culture=n' +
        'eutral,PublicKeyToken=91d62ebb5b0d1b1b'
      'LibraryName=dbxfb.dll'
      'LibraryNameOsx=libsqlfb.dylib'
      'VendorLib=fbclient.dll'
      'VendorLibWin64=fbclient.dll'
      'VendorLibOsx=/Library/Frameworks/Firebird.framework/Firebird'
      'Role=RoleName'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'IsolationLevel=ReadCommitted'
      'SQLDialect=3'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'TrimChar=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'RoleName=RoleName'
      'Trim Char=False')
    Left = 176
    Top = 212
  end
end
