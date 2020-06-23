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
    Top = 72
    Width = 203
    Height = 13
    Caption = 'N/A (Query, Provider and Client DataSet):'
  end
  object lblBottom: TLabel
    Left = 300
    Top = 341
    Width = 105
    Height = 13
    Caption = 'N/A (Simple DataSet):'
  end
  object lblCaption: TLabel
    Left = 8
    Top = 9
    Width = 72
    Height = 25
    Caption = 'Product'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object panLeft: TPanel
    Left = 0
    Top = 43
    Width = 49
    Height = 575
    Anchors = [akLeft, akTop, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 15
  end
  object db_grid_Top: TDBGrid
    Left = 300
    Top = 91
    Width = 609
    Height = 237
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_Top
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object db_grid_Bottom: TDBGrid
    Left = 300
    Top = 360
    Width = 609
    Height = 220
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = ds_sds_Bottom
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object btnGetMetadata: TButton
    Left = 8
    Top = 71
    Width = 130
    Height = 43
    Caption = 'Get Metadata'
    Enabled = False
    TabOrder = 2
    OnClick = btnGetMetadataClick
  end
  object lbResult: TListBox
    Left = 8
    Top = 120
    Width = 273
    Height = 429
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 3
    OnDblClick = lbResultDblClick
  end
  object btnRefreshBottom: TButton
    Left = 848
    Top = 335
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 4
    OnClick = btnRefreshBottomClick
  end
  object btnRefreshTop: TButton
    Left = 848
    Top = 66
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 5
    OnClick = btnRefreshTopClick
  end
  object btnInsertBottom: TButton
    Left = 791
    Top = 335
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 6
    OnClick = btnInsertBottomClick
  end
  object btnInsertTop: TButton
    Left = 791
    Top = 66
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 7
    OnClick = btnInsertTopClick
  end
  object btnDeleteBottom: TButton
    Left = 728
    Top = 335
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 8
    OnClick = btnDeleteBottomClick
  end
  object btnDeleteTop: TButton
    Left = 728
    Top = 66
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 9
    OnClick = btnDeleteTopClick
  end
  object chbMetadataTablesOnly: TCheckBox
    Left = 144
    Top = 94
    Width = 150
    Height = 17
    Caption = 'List Tables Only (On/Off)'
    TabOrder = 10
    OnClick = chbMetadataTablesOnlyClick
  end
  object btnDrpTbl: TButton
    Left = 119
    Top = 555
    Width = 74
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Drop Table'
    Enabled = False
    TabOrder = 11
    WordWrap = True
    OnClick = btnDrpTblClick
  end
  object btnDrpCol: TButton
    Left = 199
    Top = 555
    Width = 82
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Drop Column'
    Enabled = False
    TabOrder = 12
    OnClick = btnDrpColClick
  end
  object btnImpTbl: TButton
    Left = 8
    Top = 555
    Width = 105
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Import Table (.CSV)'
    TabOrder = 13
    OnClick = btnImpTblClick
  end
  object panDbInfo: TPanel
    Left = 0
    Top = 586
    Width = 919
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
    TabOrder = 14
  end
  object panAdminMode: TPanel
    Left = 24
    Top = 36
    Width = 217
    Height = 29
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
    TabOrder = 16
  end
  object chbAutoLogin: TCheckBox
    Left = 144
    Top = 74
    Width = 97
    Height = 17
    Caption = 'Auto Login'
    TabOrder = 17
    OnClick = chbAutoLoginClick
  end
  object tsViews: TTabSet
    Left = 300
    Top = 16
    Width = 609
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    SoftTop = True
    Style = tsSoftTabs
    Tabs.Strings = (
      'View A'
      'View B')
    TabIndex = 0
    OnChange = tsViewsChange
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
    Top = 103
  end
  object dsp_Top: TDataSetProvider
    DataSet = qry_Top
    Left = 420
    Top = 104
  end
  object cds_Top: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Top'
    AfterPost = cds_TopAfterPost
    Left = 500
    Top = 103
  end
  object ds_cds_Top: TDataSource
    DataSet = cds_Top
    Left = 724
    Top = 103
  end
  object sds_Bottom: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird_ANSI
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_BottomAfterPost
    Left = 332
    Top = 374
  end
  object ds_sds_Bottom: TDataSource
    DataSet = sds_Bottom
    Left = 724
    Top = 374
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
