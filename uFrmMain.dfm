object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 
    'Dt Test Item Manager v1.06 - EMPLOYEE.FDB Firebird Sample Databa' +
    'se'
  ClientHeight = 577
  ClientWidth = 917
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    917
    577)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLog: TLabel
    Left = 8
    Top = 397
    Width = 24
    Height = 13
    Caption = 'LOG:'
  end
  object lblCustomer: TLabel
    Left = 300
    Top = 32
    Width = 236
    Height = 13
    Caption = 'Customers (Query, Provider and Client DataSet):'
  end
  object lblEmployee: TLabel
    Left = 300
    Top = 215
    Width = 138
    Height = 13
    Caption = 'Employees (Simple DataSet):'
  end
  object lblResult: TLabel
    Left = 8
    Top = 118
    Width = 34
    Height = 13
    Caption = 'Result:'
  end
  object lbLog: TListBox
    Left = 8
    Top = 416
    Width = 901
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object btnConnect: TButton
    Left = 8
    Top = 32
    Width = 273
    Height = 49
    Caption = 'Connect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object db_grid_Customer: TDBGrid
    Left = 300
    Top = 51
    Width = 609
    Height = 158
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_cds_Customer
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object db_grid_Employee: TDBGrid
    Left = 300
    Top = 234
    Width = 609
    Height = 158
    Anchors = [akLeft, akTop, akRight]
    DataSource = ds_sds_Employee
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object pAttn: TPanel
    Left = 8
    Top = 3
    Width = 901
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'NOTE: Before creating DB Table.'
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
  end
  object btnGetMetadata: TButton
    Left = 8
    Top = 87
    Width = 273
    Height = 25
    Caption = 'Get Metadata'
    Enabled = False
    TabOrder = 5
    OnClick = btnGetMetadataClick
  end
  object lbResult: TListBox
    Left = 8
    Top = 137
    Width = 273
    Height = 255
    ItemHeight = 13
    TabOrder = 6
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
    Left = 224
    Top = 32
  end
  object qry_Customer: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'select * from customer;')
    SQLConnection = con_Employee
    Left = 332
    Top = 64
  end
  object dsp_Customer: TDataSetProvider
    DataSet = qry_Customer
    Left = 420
    Top = 64
  end
  object cds_Customer: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dsp_Customer'
    AfterPost = cds_CustomerAfterPost
    Left = 500
    Top = 64
  end
  object ds_cds_Customer: TDataSource
    DataSet = cds_Customer
    Left = 724
    Top = 64
  end
  object sds_Employee: TSimpleDataSet
    Aggregates = <>
    Connection = con_Employee
    DataSet.CommandText = 'select * from employee;'
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    AfterPost = sds_EmployeeAfterPost
    Left = 332
    Top = 248
  end
  object ds_sds_Employee: TDataSource
    DataSet = sds_Employee
    Left = 724
    Top = 248
  end
end
