object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'DtTstItemMgr'
  ClientHeight = 602
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
    602)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLog: TLabel
    Left = 8
    Top = 520
    Width = 9
    Height = 60
    Alignment = taCenter
    AutoSize = False
    Caption = 'L O G'
    WordWrap = True
  end
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
    Top = 32
    Width = 73
    Height = 13
    Caption = 'Database Info:'
  end
  object lbLog: TListBox
    Left = 23
    Top = 520
    Width = 886
    Height = 73
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object btnConnect: TButton
    Left = 120
    Top = 56
    Width = 100
    Height = 32
    Caption = 'Connect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object db_grid_Top: TDBGrid
    Left = 300
    Top = 84
    Width = 609
    Height = 193
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_Top
    TabOrder = 2
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
    TabOrder = 3
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
    TabOrder = 4
    OnClick = btnGetMetadataClick
  end
  object lbResult: TListBox
    Left = 8
    Top = 164
    Width = 273
    Height = 281
    ItemHeight = 13
    TabOrder = 5
    OnDblClick = lbResultDblClick
  end
  object btnRefreshBottom: TButton
    Left = 848
    Top = 287
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 6
    OnClick = btnRefreshBottomClick
  end
  object btnRefreshTop: TButton
    Left = 848
    Top = 59
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 7
    OnClick = btnRefreshTopClick
  end
  object btnInsertBottom: TButton
    Left = 791
    Top = 287
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 8
    OnClick = btnInsertBottomClick
  end
  object btnInsertTop: TButton
    Left = 791
    Top = 59
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 9
    OnClick = btnInsertTopClick
  end
  object btnDeleteBottom: TButton
    Left = 728
    Top = 287
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 10
    OnClick = btnDeleteBottomClick
  end
  object btnDeleteTop: TButton
    Left = 728
    Top = 59
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 11
    OnClick = btnDeleteTopClick
  end
  object chbMetadataTablesOnly: TCheckBox
    Left = 144
    Top = 137
    Width = 150
    Height = 17
    Caption = 'List Tables Only (On/Off)'
    TabOrder = 12
    OnClick = chbMetadataTablesOnlyClick
  end
  object cbbDb: TComboBox
    Left = 241
    Top = 5
    Width = 668
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 13
  end
  object btnCreTblSample: TButton
    Left = 8
    Top = 480
    Width = 273
    Height = 25
    Caption = 'Create Table'
    Enabled = False
    TabOrder = 14
    WordWrap = True
    OnClick = btnCreTblSampleClick
  end
  object btnDrpTbl: TButton
    Left = 8
    Top = 450
    Width = 81
    Height = 25
    Caption = 'Drop Table'
    Enabled = False
    TabOrder = 15
    WordWrap = True
    OnClick = btnDrpTblClick
  end
  object edDbInfo: TEdit
    Left = 241
    Top = 29
    Width = 668
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 16
    Text = '<none>'
  end
  object btnInitDtTstDb: TButton
    Left = 8
    Top = 94
    Width = 273
    Height = 31
    Caption = 'Create Database Tables for Product "DtTstItemMgr"'
    Enabled = False
    TabOrder = 17
    WordWrap = True
    OnClick = btnInitDtTstDbClick
  end
  object chbServerCharsetUtf8: TCheckBox
    Left = 16
    Top = 31
    Width = 140
    Height = 17
    Caption = 'Server CharSet = UTF8'
    TabOrder = 18
  end
  object chbDoDbUpdate: TCheckBox
    Left = 17
    Top = 62
    Width = 97
    Height = 17
    Caption = 'Do DB Update'
    Checked = True
    State = cbChecked
    TabOrder = 19
  end
  object btnIsql: TButton
    Left = 236
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
    TabOrder = 20
    OnClick = btnIsqlClick
  end
  object chbIsqlVisible: TCheckBox
    Left = 236
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
    TabOrder = 21
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
