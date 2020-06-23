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
  object lblTop: TLabel
    Left = 528
    Top = 17
    Width = 21
    Height = 16
    Caption = 'N/A'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
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
  object lblBottom: TLabel
    Left = 528
    Top = 189
    Width = 21
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'N/A'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object panLeft: TPanel
    Left = 0
    Top = 43
    Width = 515
    Height = 575
    Anchors = [akLeft, akTop, akBottom]
    Color = clWindow
    ParentBackground = False
    TabOrder = 4
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
      Color = clWindow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 1
      OnClick = chbMetadataTablesOnlyClick
    end
    object chbShowLog: TCheckBox
      Left = 436
      Top = 5
      Width = 97
      Height = 17
      Caption = 'Log Viewer'
      Color = clWindow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 2
      OnClick = chbShowLogClick
    end
  end
  object db_grid_Top: TDBGrid
    Left = 539
    Top = 43
    Width = 369
    Height = 134
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
    Left = 539
    Top = 216
    Width = 369
    Height = 153
    Anchors = [akLeft, akRight, akBottom]
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
    OnKeyDown = lbObjectsKeyDown
    OnKeyPress = lbObjectsKeyPress
    OnKeyUp = lbObjectsKeyUp
    OnMeasureItem = lbObjectsMeasureItem
    OnMouseDown = lbObjectsMouseDown
    OnMouseUp = lbObjectsMouseUp
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
    TabOrder = 3
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
    TabOrder = 5
  end
  object lbLog: TListBox
    Left = 539
    Top = 383
    Width = 278
    Height = 197
    Anchors = [akLeft, akBottom]
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 6
    OnDblClick = lbLogDblClick
  end
  object lbTasks: TListBox
    Left = 287
    Top = 71
    Width = 218
    Height = 509
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 7
    OnClick = lbTasksClick
    OnDrawItem = lbTasksDrawItem
    OnKeyDown = lbTasksKeyDown
    OnKeyPress = lbTasksKeyPress
    OnKeyUp = lbTasksKeyUp
    OnMeasureItem = lbTasksMeasureItem
    OnMouseDown = lbTasksMouseDown
    OnMouseUp = lbTasksMouseUp
  end
  object tvTree: TTreeView
    Left = 832
    Top = 383
    Width = 76
    Height = 197
    Anchors = [akLeft, akRight, akBottom]
    DoubleBuffered = True
    Indent = 19
    ParentDoubleBuffered = False
    StateImages = ilTree
    TabOrder = 8
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
    Left = 68
    Top = 239
  end
  object dsp_Top: TDataSetProvider
    DataSet = qry_Top
    Left = 116
    Top = 240
  end
  object cds_Top: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Top'
    AfterPost = cds_TopAfterPost
    Left = 164
    Top = 239
  end
  object ds_cds_Top: TDataSource
    DataSet = cds_Top
    OnDataChange = ds_cds_TopDataChange
    Left = 220
    Top = 239
  end
  object sds_Bottom: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird_ANSI
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_BottomAfterPost
    Left = 68
    Top = 302
  end
  object ds_sds_Bottom: TDataSource
    DataSet = sds_Bottom
    Left = 220
    Top = 302
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
  object ilTree: TImageList
    Height = 13
    Width = 13
    Left = 856
    Top = 472
    Bitmap = {
      494C010103002C0038000D000D00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000340000000D0000000100200000000000900A
      0000000000000000000000000000000000003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333FF3333
      33FF333333FF333333FF333333FF333333FF333333FF333333FF333333FF3333
      33FF333333FF333333FF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000033333300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF003333330033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0033333300333333FFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFB0E4EFFFB0E4EFFFF6F6F6FFC9AEFFFFC9AE
      FFFFF6F6F6FFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000033333300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF003333330033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0033333300333333FFB0E4
      EFFFF6F6F6FFC9AEFFFF241CEDFF241CEDFFC9AEFFFFF6F6F6FFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFF6F6F6FFC9AEFFFF241CEDFFE2E2E2FFE2E2
      E2FF241CEDFFC9AEFFFFF6F6F6FFB0E4EFFFB0E4EFFFB0E4EFFF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000033333300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF003333330033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0033333300333333FFB8B8
      B8FF241CEDFFE2E2E2FFB0E4EFFFB0E4EFFFE2E2E2FF241CEDFFC9AEFFFFF6F6
      F6FFB0E4EFFFB0E4EFFF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFE2E2E2FF241CEDFFC9AEFFFFF6F6F6FFB0E4EFFF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000033333300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF003333330033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0033333300333333FFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFE2E2E2FF241C
      EDFFC9AEFFFFF6F6F6FF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFE2E2E2FF241CEDFFB8B8B8FF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000033333300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF003333330033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0033333300333333FFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000033333300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003333330033333300FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0033333300333333FFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4
      EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFFB0E4EFFF333333FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333003333
      3300333333003333330033333300333333003333330033333300333333FF3333
      33FF333333FF333333FF333333FF333333FF333333FF333333FF333333FF3333
      33FF333333FF333333FF333333FF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424D3E000000000000003E00000028000000340000000D00000001000100
      00000000680000000000000000000000000000000000000000000000FFFFFF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000}
  end
end
