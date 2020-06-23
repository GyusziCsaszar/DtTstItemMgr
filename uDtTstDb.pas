unit uDtTstDb;

interface

uses
  { DtTs Units: } uDtTstLog,
  System.Classes, System.IOUtils, Vcl.StdCtrls,
  Data.Db, Data.SqlExpr,
  DbxCommon, DbxMetaDataProvider,
  DbxDataExpressMetaDataProvider,
  DbxClient; //, DbxDataStoreMetaData;

type
  TDtTstDb = class (TObject)
  private
    m_oLog: TDtTstLog;
    m_bUTF8: Boolean;
    m_asConnectStrings: TStringList;
    m_sConnectString: string;
    m_sConnectUser: string;
    m_sConnectPassword: string;
    m_oCon: TSQLConnection;
    m_iDtTstDbInfVersion: integer;
    m_sDtTstDbInfProduct: string;
  public
    constructor Create(oLog: TDtTstLog; sIniPath: string);
    destructor Destroy(); override;
    function GetUTF8() : Boolean;
    property UTF8: Boolean read GetUTF8;
    procedure GetConnectStrings(cbb: TComboBox);
    function GetConnectString() : string;
    procedure SetConnectString(sValue: string);
    property ConnectString: string read GetConnectString write SetConnectString;
    function GetConnectUser() : string;
    property ConnectUser: string read GetConnectUser;
    function GetConnectPassword() : string;
    property ConnectPassword: string read GetConnectPassword;

    procedure Connect(oCon: TSQLConnection);
    procedure AfterConnect(); virtual;

    function GetLoginUser() : string;
    property LoginUser: string read GetLoginUser;

    function GetDtTstDbInfVersion() : integer;
    property DtTstDbInfVersion: integer read GetDtTstDbInfVersion;
    function GetDtTstDbInfProduct() : string;
    property DtTstDbInfProduct: string read GetDtTstDbInfProduct;

    function TableExists(sTable: string) : Boolean;
    function GetTableCount() : integer;

    function FIXOBJNAME(sTable: string) : string;

    procedure CreateTableDtTstDbVer();

    procedure DropTable(sTable: string);

    procedure CreateTable(const AConnection: TDBXConnection);

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
  iDbCnt, iDbDef, iDb, iVal: Integer;
  sDb: string;
begin
  m_oLog := oLog;

  m_bUTF8 := False;
  m_asConnectStrings := TStringList.Create();
  m_sConnectString := '';
  m_sConnectUser := '';
  m_sConnectPassword := '';
  m_oCon := nil;
  m_iDtTstDbInfVersion := 0;
  m_sDtTstDbInfProduct := '';

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

        iVal := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_UTF8, 0);
        m_bUTF8 := (iVal <> 0);

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

  m_oCon := nil; // ATTN: Do not Free here!

  inherited Destroy();
end;

function TDtTstDb.GetUTF8() : Boolean;
begin
  Result := m_bUTF8;
end;

procedure TDtTstDb.GetConnectStrings(cbb: TComboBox);
begin
  cbb.Text := '';
  cbb.Items.Clear();

  cbb.Items.AddStrings(m_asConnectStrings);
  cbb.Text := m_sConnectString;
end;

function TDtTstDb.GetConnectString() : string;
begin
  Result := m_sConnectString;
end;

procedure TDtTstDb.SetConnectString(sValue: string);
begin
  m_sConnectString := sValue;
end;

function TDtTstDb.GetConnectUser() : string;
begin
  Result := m_sConnectUser;
end;

function TDtTstDb.GetConnectPassword() : string;
begin
  Result := m_sConnectPassword;
end;

procedure TDtTstDb.Connect(oCon: TSQLConnection);
begin

  m_oCon := oCon;

  m_oCon.Params.Values['Database'] := m_sConnectString;
  if m_oCon.Params.Values['Database'].IsEmpty() then
  begin
    raise Exception.Create('No Database specified!');
  end;

  m_oCon.Params.Values['User_Name'] := ConnectUser;
  m_oCon.Params.Values['Password' ] := ConnectPassword;

  if (m_oCon.Params.Values['User_Name'].Length > 0) and (m_oCon.Params.Values['Password'].Length > 0) then
  begin
    m_oCon.LoginPrompt := False;
  end;

  m_oCon.Connected := True;

  AfterConnect();
end;

procedure TDtTstDb.AfterConnect();
var
  oQry: TSQLQuery;
begin

  m_iDtTstDbInfVersion := -1;
  m_sDtTstDbInfProduct := '';

  if TableExists(csDB_TBL_ADM_DBINF) then
  begin

    oQry := TSQLQuery.Create(nil);
    try

      oQry.SQLConnection := m_oCon;

      oQry.SQL.Text := 'SELECT * FROM ' + FIXOBJNAME(csDB_TBL_ADM_DBINF);
      oQry.Open();

      if not oQry.IsEmpty() then
      begin
        m_iDtTstDbInfVersion := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_VER)).AsInteger;
        m_sDtTstDbInfProduct := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD)).AsString;
      end;

    finally
      oQry.Close();
      FreeAndNil(oQry);
    end;

  end;

end;

function TDtTstDb.GetLoginUser() : string;
begin
  Result := '';

  if Assigned(m_oCon) and m_oCon.Connected then
  begin
    Result := m_oCon.GetLoginUsername();
  end;
end;

function TDtTstDb.GetDtTstDbInfVersion() : integer;
begin
  Result := m_iDtTstDbInfVersion;
end;

function TDtTstDb.GetDtTstDbInfProduct() : string;
begin
  Result := m_sDtTstDbInfProduct;
end;

function TDtTstDb.TableExists(sTable: string) : Boolean;
var
  asNA: TStringList;
begin
  Result := False;

  asNA := TStringList.Create();
  try

    m_oCon.GetFieldNames(FIXOBJNAME(sTable), asNA);

    Result := (asNA.Count > 0);

  finally
    FreeAndNil(asNA);
  end;

end;

function TDtTstDb.GetTableCount() : integer;
var
  asNA: TStringList;
begin
  Result := 0;

  asNA := TStringList.Create();
  try

    m_oCon.GetTableNames(asNA, False);

    Result := asNA.Count;

  finally
    FreeAndNil(asNA);
  end;

end;

function TDtTstDb.FIXOBJNAME(sTable: string) : string;
begin
  Result := sTable.ToUpper();
end;

procedure TDtTstDb.CreateTableDtTstDbVer();
var
  oProvider: TDBXDataExpressMetaDataProvider;
  oTable: TDBXMetaDataTable;
  oColVer: TDBXInt32Column;
  oColPrd: TDBXUnicodeCharColumn; //TDBXAnsiCharColumn;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  oProvider := DBXGetMetaProvider(m_oCon.DBXConnection);
  try

    oTable := TDBXMetaDataTable.Create;
    try
      oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_DBINF);

      oColVer := TDBXInt32Column.Create(FIXOBJNAME(csDB_FLD_ADM_DBINF_VER));
      oColVer.Nullable := False;
      oTable.AddColumn(oColVer);

      // oColPrd := TDBXAnsiCharColumn.Create(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD), 32);
      oColPrd := TDBXUnicodeCharColumn.Create(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD), 32);
      oColPrd.Nullable := False;
      oColPrd.FixedLength := False; // To make VarChar...
      oTable.AddColumn(oColPrd);

      oProvider.CreateTable(oTable);

    finally
      FreeAndNil(oTable);
    end;

    // SRC:
    oQry := TSQLQuery.Create(nil);
    try

      oQry.SQLConnection := m_oCon;
      oQry.ParamCheck := True;
      // oQry.PrepareStatement;
      oQry.SQL.Add('INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                   ' (' + FIXOBJNAME(csDB_FLD_ADM_DBINF_VER) + ', ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD) +
                   ') VALUES (:VER, :PRD)');
      oQry.Params.ParamByName('VER').AsInteger  := 100;

      // ATTN: To write UTF8 string, nothing extra is required!!!
      {
      // Is this required to write UTF8 String???
      //oQry.Params.ParamByName('PRD').DataType := ftWideString;
      //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
      }

      oQry.Params.ParamByName('PRD').AsString   := csCOMPANY + csPRODUCT;

      //oQry.Prepared := True;

      m_oCon.StartTransaction(oTD);
      try
        oQry.ExecSQL(False);
        m_oCon.Commit(oTD);
      except
        m_oCon.Rollback(oTD);
      end;

    finally
      oQry.Close();
      FreeAndNil(oQry);
    end;

  finally
    FreeAndNil(oProvider);
  end;

end;

procedure TDtTstDb.DropTable(sTable: string);
var
  oProvider: TDBXDataExpressMetaDataProvider;
begin

  oProvider := DBXGetMetaProvider(m_oCon.DBXConnection);
  try

    // ATTN: Indices of a Table will be dropped along with the table!!!
    //if oProvider.DropIndex('tblname', 'idxname') then
    //begin

      if not oProvider.DropTable('', sTable) then
      begin
        raise Exception.Create('Unable to drop table ' + sTable + '!');
      end;

    //end;

  finally
    FreeAndNil(oProvider);
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
