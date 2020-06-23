object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 614
  ClientWidth = 916
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
    916
    614)
  PixelsPerInch = 96
  TextHeight = 13
  object lblRs: TLabel
    Left = 528
    Top = 44
    Width = 22
    Height = 13
    Caption = 'N/A:'
    ParentShowHint = False
    ShowHint = True
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
  object lblLog: TLabel
    Left = 528
    Top = 431
    Width = 183
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'LOG (DblClk = Copy line to Clipboard!)'
  end
  object panLeft: TPanel
    Left = 0
    Top = 43
    Width = 515
    Height = 575
    Anchors = [akLeft, akTop, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 7
    object chbAutoLogin: TCheckBox
      Left = 8
      Top = 5
      Width = 97
      Height = 17
      Caption = 'Auto Login'
      TabOrder = 0
      OnClick = chbAutoLoginClick
    end
    object chbMetadataTablesOnly: TCheckBox
      Left = 179
      Top = 5
      Width = 145
      Height = 17
      Caption = 'Tables and Queries Only'
      TabOrder = 1
      OnClick = chbMetadataTablesOnlyClick
    end
    object chbShowLog: TCheckBox
      Left = 436
      Top = 5
      Width = 97
      Height = 17
      Caption = 'Log Viewer'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chbShowLogClick
    end
  end
  object db_grid_Top: TDBGrid
    Left = 528
    Top = 69
    Width = 380
    Height = 156
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = ds_cds_Top
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object db_grid_Bottom: TDBGrid
    Left = 528
    Top = 69
    Width = 380
    Height = 156
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = ds_sds_Bottom
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object lbObjects: TListBox
    Left = 8
    Top = 71
    Width = 273
    Height = 509
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 2
    OnClick = lbObjectsClick
    OnDblClick = lbObjectsDblClick
    OnDrawItem = lbObjectsDrawItem
    OnMeasureItem = lbObjectsMeasureItem
  end
  object btnRsRefresh: TButton
    Left = 847
    Top = 38
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 3
    OnClick = btnRsRefreshClick
  end
  object btnRsInsert: TButton
    Left = 790
    Top = 38
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 4
    OnClick = btnRsInsertClick
  end
  object btnRsDelete: TButton
    Left = 727
    Top = 38
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 5
    OnClick = btnRsDeleteClick
  end
  object panDbInfo: TPanel
    Left = 0
    Top = 586
    Width = 918
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
  end
  object panAdminMode: TPanel
    Left = 300
    Top = 8
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
    TabOrder = 8
  end
  object tsViews: TTabSet
    Left = 528
    Top = 16
    Width = 380
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    DitherBackground = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    SelectedColor = clInactiveCaption
    SoftTop = True
    Style = tsSoftTabs
    Tabs.Strings = (
      'Query, Provider and Client DataSet'
      'Simple DataSet')
    TabIndex = 0
    OnChange = tsViewsChange
  end
  object lbLog: TListBox
    Left = 528
    Top = 448
    Width = 380
    Height = 132
    Anchors = [akLeft, akRight, akBottom]
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 10
    OnDblClick = lbLogDblClick
  end
  object lbTasks: TListBox
    Left = 287
    Top = 71
    Width = 218
    Height = 509
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 11
    OnClick = lbTasksClick
    OnDblClick = lbTasksDblClick
    OnDrawItem = lbTasksDrawItem
    OnMeasureItem = lbTasksMeasureItem
  end
  object db_grid_Details: TDBGrid
    Left = 528
    Top = 240
    Width = 380
    Height = 185
    Anchors = [akLeft, akRight, akBottom]
    DataSource = ds_sds_Details
    TabOrder = 12
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
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
    Top = 140
  end
  object qry_Top: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = con_Firebird_ANSI
    Left = 548
    Top = 111
  end
  object dsp_Top: TDataSetProvider
    DataSet = qry_Top
    Left = 652
    Top = 112
  end
  object cds_Top: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Top'
    AfterPost = cds_TopAfterPost
    Left = 732
    Top = 111
  end
  object ds_cds_Top: TDataSource
    DataSet = cds_Top
    OnDataChange = ds_cds_TopDataChange
    Left = 844
    Top = 111
  end
  object sds_Bottom: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird_ANSI
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_BottomAfterPost
    Left = 548
    Top = 174
  end
  object ds_sds_Bottom: TDataSource
    DataSet = sds_Bottom
    OnDataChange = ds_sds_BottomDataChange
    Left = 844
    Top = 174
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
    Top = 140
  end
  object tmrStart: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrStartTimer
    Left = 16
    Top = 80
  end
  object sds_Details: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird_ANSI
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_DetailsAfterPost
    Left = 552
    Top = 328
  end
  object ds_sds_Details: TDataSource
    DataSet = sds_Details
    Left = 848
    Top = 328
  end
end
