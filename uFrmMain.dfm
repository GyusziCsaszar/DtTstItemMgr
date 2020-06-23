object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Dt Test Item Manager v1.02'
  ClientHeight = 577
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    643
    577)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLog: TLabel
    Left = 8
    Top = 373
    Width = 24
    Height = 13
    Caption = 'LOG:'
  end
  object lblSalesCatalog: TLabel
    Left = 8
    Top = 69
    Width = 69
    Height = 13
    Caption = 'Sales Catalog:'
  end
  object lbLog: TListBox
    Left = 8
    Top = 392
    Width = 627
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object btnConnect: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object db_grid_SalesCatalog: TDBGrid
    Left = 8
    Top = 88
    Width = 627
    Height = 279
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_SalesCatalog
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object con_SalesCatalog: TSQLConnection
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
    Left = 120
    Top = 160
  end
  object qry_SalesCatalog: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'select * from sales_catalog;')
    SQLConnection = con_SalesCatalog
    Left = 120
    Top = 216
  end
  object ds_qry_SalesCatalog_NOK: TDataSource
    DataSet = qry_SalesCatalog
    Enabled = False
    Left = 120
    Top = 272
  end
  object dsp_SalesCatalog: TDataSetProvider
    DataSet = qry_SalesCatalog
    Left = 264
    Top = 160
  end
  object cds_SalesCatalog: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_SalesCatalog'
    Left = 264
    Top = 216
  end
  object ds_cds_SalesCatalog: TDataSource
    DataSet = cds_SalesCatalog
    Left = 264
    Top = 272
  end
end
