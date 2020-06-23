unit uDtTstDb;

interface

uses
  { DtTs Units: } uDtTstLog,
  System.Classes, System.IOUtils, Vcl.StdCtrls,
  DbxCommon, DbxMetaDataProvider,
  DbxDataExpressMetaDataProvider,
  DbxClient; //, DbxDataStoreMetaData;

type
  TDtTstDb = class (TObject)
  private
    m_oLog: TDtTstLog;
    m_asConnectStrings: TStringList;
    m_sConnectString: string;
    m_sConnectUser: string;
    m_sConnectPassword: string;
  public
    constructor Create(oLog: TDtTstLog; sIniPath: string);
    destructor Destroy(); override;
    procedure GetConnectStrings(cbb: TComboBox);
    function GetConnectUser() : string;
    property ConnectUser: string read GetConnectUser;
    function GetConnectPassword() : string;
    property ConnectPassword: string read GetConnectPassword;
    procedure CreateTable(const AConnection: TDBXConnection);
    procedure DropTable(const AConnection: TDBXConnection);
  private
    function DBXGetMetaProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
  end;

implementation

uses
  { DtTs Units: } uDtTstConsts,
  SysUtils, IniFiles;

constructor TDtTstDb.Create(oLog: TDtTstLog; sIniPath: string);
var
  fIni: TIniFile;
  iDbCnt, iDbDef, iDb: Integer;
  sDb: string;
begin
  m_oLog := oLog;

  m_asConnectStrings := TStringList.Create();
  m_sConnectString := '';
  m_sConnectUser := '';
  m_sConnectPassword := '';

  inherited Create();

  m_oLog.LogLIFE('TDtTstDb.Create');

  if not sIniPath.IsEmpty then
  begin
    if FileExists(sIniPath) then
    begin
      try
        m_oLog.LogINFO('INI Path (for TDtTstDb): ' + sIniPath);

        fIni := TIniFile.Create(sIniPath);

        if not fIni.SectionExists(csINI_SEC_DB) then
        begin
          raise m_oLog.LogERROR(Exception.Create('No INI Section "' + csINI_SEC_DB + '"! INI File: ' + sIniPath));
        end;

        iDbCnt := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_CONSTR_CNT, 0);
        iDbDef := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_CONSTR_DEF, 0);

        if iDbCnt < 1 then
        begin
          raise m_oLog.LogERROR(Exception.Create('No valid "' + csINI_VAL_DB_CONSTR_CNT + '" value in INI Section "' + csINI_SEC_DB + '"! INI File: ' + sIniPath));
        end;

        if (iDbDef < 1) or (iDbDef > iDbCnt) then iDbDef := 1;

        for iDb := 1 to iDbCnt do
        begin
          sDb := fIni.ReadString(csINI_SEC_DB, csINI_VAL_DB_CONSTR + IntToStr(iDb), '');
          if sDb.IsEmpty() then
          begin
            raise m_oLog.LogERROR(Exception.Create('No "' + csINI_VAL_DB_CONSTR + IntToStr(iDb) + '" value in INI Section "' + csINI_SEC_DB + '"! INI File: ' + sIniPath));
          end;

          m_asConnectStrings.Add(sDb);

          if iDb = iDbDef then
          begin
            m_sConnectString := sDb;
          end;
        end;

        m_sConnectUser := fIni.ReadString(csINI_SEC_DB, csINI_VAL_DB_USR, '');
        m_sConnectPassword := fIni.ReadString(csINI_SEC_DB, csINI_VAL_DB_PW, '');

      finally
        FreeAndNil(fIni);
      end;
    end;
  end;
end;

destructor TDtTstDb.Destroy();
begin
  m_oLog.LogLIFE('TDtTstDb.Destroy');

  m_oLog := nil; // ATTN: Do not Free here!

  FreeAndNil(m_asConnectStrings);

  inherited Destroy();
end;

procedure TDtTstDb.GetConnectStrings(cbb: TComboBox);
begin
  cbb.Text := '';
  cbb.Items.Clear();

  cbb.Items.AddStrings(m_asConnectStrings);
  cbb.Text := m_sConnectString;
end;

function TDtTstDb.GetConnectUser() : string;
begin
  Result := m_sConnectUser;
end;

function TDtTstDb.GetConnectPassword() : string;
begin
  Result := m_sConnectPassword;
end;

procedure TDtTstDb.DropTable(const AConnection: TDBXConnection);
var
  MyProvider: TDBXDataExpressMetaDataProvider;
begin
  // Get the MetadataProvider from my Connection
  MyProvider := DBXGetMetaProvider(AConnection);
  try

    // ATTN: Indices of a Table will be dropped along with the table!!!

    //if MyProvider.DropIndex('DELPHIEXPERTS', 'DELPHIEXPERTS_ID') then
    //begin

      if not MyProvider.DropTable('', 'DELPHIEXPERTS') then
      begin
        raise Exception.Create('Unable to drop table ' + 'DELPHIEXPERTS' + '!');
      end;

    //end;

  finally
    FreeAndNil(MyProvider);
  end;

end;

procedure TDtTstDb.CreateTable(const AConnection: TDBXConnection);
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  MyProvider: TDBXDataExpressMetaDataProvider;
  MyNewTable: TDBXMetaDataTable;
  MyPrimaryKey: TDBXMetaDataIndex;
  MyIDColumn: TDBXInt32Column;
begin
  // Get the MetadataProvider from my Connection
  MyProvider := DBXGetMetaProvider(AConnection);
  try
    // Create the Table structure
    MyNewTable := TDBXMetaDataTable.Create;

    try
      MyNewTable.TableName := 'DELPHIEXPERTS';
      MyIDColumn := TDBXInt32Column.Create('ID');
      MyIDColumn.Nullable:=false;
      MyNewTable.AddColumn(MyIDColumn);
      MyNewTable.AddColumn(TDBXAnsiCharColumn.Create('Members', 50));
      // Add the Table in the Database with my provider
      MyProvider.CreateTable(MyNewTable);

    finally
      FreeAndNil(MyNewTable);
    end;

    // Now let us create a Primary Key on the ID Field
    MyPrimaryKey := TDBXMetaDataIndex.Create;

    try

      {ATTN: OPTIONAL to name the Index!!!}
      {      Original Sample does not do so!!!}
      MyPrimaryKey.IndexName := 'DELPHIEXPERTS_ID';

      MyPrimaryKey.TableName := 'DELPHIEXPERTS';
      MyPrimaryKey.AddColumn('ID');
      // Add the Primary Key with my provider
      MyProvider.CreatePrimaryKey(MyPrimaryKey);
    finally
      FreeAndNil(MyPrimaryKey);
    end;
  finally
    FreeAndNil(MyProvider);
  end;
end;

function TDtTstDb.DBXGetMetaProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  Provider: TDBXDataExpressMetaDataProvider;
begin
  Provider := TDBXDataExpressMetaDataProvider.Create;
  try
    Provider.Connection := AConnection;
    Provider.Open;
  except
    FreeAndNil(Provider);
    raise ;
  end;
  Result := Provider;
end;

end.
