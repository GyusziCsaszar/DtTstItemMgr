object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 
    'Dt Test Item Manager v1.04 - EMPLOYEE.FDB Firebird Sample Databa' +
    'se'
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
  object lblCustomer: TLabel
    Left = 8
    Top = 69
    Width = 55
    Height = 13
    Caption = 'Customers:'
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
  object db_grid_Customer: TDBGrid
    Left = 8
    Top = 88
    Width = 627
    Height = 279
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_Customer
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object con_Employee: TSQLConnection
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
    Left = 48
    Top = 160
  end
  object qry_Customer: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'select * from customer;')
    SQLConnection = con_Employee
    Left = 152
    Top = 160
  end
  object dsp_Customer: TDataSetProvider
    DataSet = qry_Customer
    Left = 264
    Top = 104
  end
  object cds_Customer: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Customer'
    Left = 264
    Top = 160
  end
  object ds_cds_Customer: TDataSource
    DataSet = cds_Customer
    Left = 264
    Top = 216
  end
end
