object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Dt Test Item Manager v1.08'
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
    Top = 493
    Width = 24
    Height = 13
    Caption = 'LOG:'
  end
  object lblTop: TLabel
    Left = 300
    Top = 41
    Width = 203
    Height = 13
    Caption = 'N/A (Query, Provider and Client DataSet):'
  end
  object lblBottom: TLabel
    Left = 300
    Top = 269
    Width = 105
    Height = 13
    Caption = 'N/A (Simple DataSet):'
  end
  object lblDb: TLabel
    Left = 16
    Top = 8
    Width = 140
    Height = 13
    Caption = 'Available Firebird Databases:'
  end
  object lbLog: TListBox
    Left = 8
    Top = 512
    Width = 901
    Height = 82
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object btnConnect: TButton
    Left = 8
    Top = 32
    Width = 273
    Height = 28
    Caption = 'Connect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object db_grid_Top: TDBGrid
    Left = 300
    Top = 60
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
    Top = 288
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
    Top = 66
    Width = 130
    Height = 25
    Caption = 'Get Metadata'
    Enabled = False
    TabOrder = 4
    OnClick = btnGetMetadataClick
  end
  object lbResult: TListBox
    Left = 8
    Top = 97
    Width = 273
    Height = 384
    ItemHeight = 13
    TabOrder = 5
    OnDblClick = lbResultDblClick
  end
  object btnRefreshBottom: TButton
    Left = 848
    Top = 263
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 6
    OnClick = btnRefreshBottomClick
  end
  object btnRefreshTop: TButton
    Left = 848
    Top = 35
    Width = 61
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 7
    OnClick = btnRefreshTopClick
  end
  object btnInsertBottom: TButton
    Left = 791
    Top = 263
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 8
    OnClick = btnInsertBottomClick
  end
  object btnInsertTop: TButton
    Left = 791
    Top = 35
    Width = 51
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Insert'
    TabOrder = 9
    OnClick = btnInsertTopClick
  end
  object btnDeleteBottom: TButton
    Left = 728
    Top = 263
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 10
    OnClick = btnDeleteBottomClick
  end
  object btnDeleteTop: TButton
    Left = 728
    Top = 35
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 11
    OnClick = btnDeleteTopClick
  end
  object chbMetadataTablesOnly: TCheckBox
    Left = 144
    Top = 70
    Width = 150
    Height = 17
    Caption = 'List Tables Only (On/Off)'
    TabOrder = 12
    OnClick = chbMetadataTablesOnlyClick
  end
  object cbbDb: TComboBox
    Left = 162
    Top = 5
    Width = 747
    Height = 21
    TabOrder = 13
  end
  object con_Firebird: TSQLConnection
    ConnectionName = 'FirstDB'
    DriverName = 'Firebird'
    Params.Strings = (
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
      'Database='
      'User_Name='
      'Password='
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
      'ServerCharSet='
      'Trim Char=False')
    Left = 128
    Top = 144
  end
  object qry_Top: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = con_Firebird
    Left = 332
    Top = 72
  end
  object dsp_Top: TDataSetProvider
    DataSet = qry_Top
    Left = 420
    Top = 73
  end
  object cds_Top: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Top'
    AfterPost = cds_TopAfterPost
    Left = 500
    Top = 72
  end
  object ds_cds_Top: TDataSource
    DataSet = cds_Top
    Left = 724
    Top = 72
  end
  object sds_Bottom: TSimpleDataSet
    Aggregates = <>
    Connection = con_Firebird
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_BottomAfterPost
    Left = 332
    Top = 302
  end
  object ds_sds_Bottom: TDataSource
    DataSet = sds_Bottom
    Left = 724
    Top = 302
  end
end
