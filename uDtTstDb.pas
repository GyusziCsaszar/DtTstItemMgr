unit uDtTstDb;

interface

uses
  { DtTst Units: } uDtTstLog, uFrmProgress,
  System.Classes, System.IOUtils, Vcl.StdCtrls,
  Data.Db, Data.SqlExpr,
  DbxCommon, DbxMetaDataProvider,
  DbxDataExpressMetaDataProvider,
  DbxClient; //, DbxDataStoreMetaData;

type
  TDtTstDb = class (TObject)
  protected
    m_oLog: TDtTstLog;
  protected
    { ATTN: Copy BELOW members in descendants!!! }
    m_sIsqlPath: string;
    m_iIsqlOptions: integer;
    m_bUTF8: Boolean;
    m_asConnectStrings: TStringList;
    m_sConnectString: string;
    m_sConnectUser: string;
    m_sConnectPassword: string;
    m_oCon: TSQLConnection;
    m_iADM_DbInfVersion: integer;
    m_sADM_DbInfProduct: string;
    { ATTN: Copy ABOVE members in descendants!!! }
  public
    constructor Create(oLog: TDtTstLog; sIniPath: string);
    destructor Destroy(); override;

    function GetIsqlPath() : string;
    property IsqlPath: string read GetIsqlPath;
    function GetIsqlOptions() : integer;
    property IsqlOptions: integer read getIsqlOptions;
    function GetUTF8() : Boolean;
    property UTF8: Boolean read GetUTF8;
    procedure GetConnectStrings(cbb: TComboBox; asConnectStrings: TStringList);
    function GetConnectString() : string;
    procedure SetConnectString(sValue: string);
    property ConnectString: string read GetConnectString write SetConnectString;
    function GetConnectUser() : string;
    property ConnectUser: string read GetConnectUser;
    function GetConnectPassword() : string;
    property ConnectPassword: string read GetConnectPassword;

    procedure Connect(oCon: TSQLConnection);
    procedure AfterConnect(); virtual;

    function GetSQLConnection() : TSQLConnection;
    property SQLConnection: TSQLConnection read GetSQLConnection;

    function GetLoginUser() : string;
    property LoginUser: string read GetLoginUser;

    function ADM_GetDbInfVersion() : integer;
    property ADM_DbInfVersion: integer read ADM_GetDbInfVersion;
    function ADM_GetDbInfProduct() : string;
    property ADM_DbInfProduct: string read ADM_GetDbInfProduct;

    function TableExists(sTable: string) : Boolean;
    function GetTableCount() : integer;

    function FIXOBJNAME(sTable: string) : string;

    procedure DB_SelectGenerators(asResult: TStringList);
    procedure DB_SelectTriggers(asResult: TStringList; sTable: string; bDetails: Boolean);

    function ADM_DoDbUpdates(frmPrs: TFrmProgress) : Boolean; virtual;

    procedure ADM_Increment_DBINFO_VER(oCon: TSQLConnection {nil = DO Transaction});
    procedure ADM_Update_DBINFO_VER(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);
    procedure ADM_CreateTable_DBINFO();

    procedure META_AddColumn_TimeStamp(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
    procedure META_AddColumn_INT32(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
    procedure META_AddColumn_VARCHAR(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean; iLen: integer);

    procedure META_AddIndex_PrimaryKey(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);

    procedure META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); virtual;
    procedure META_DropTable(sTable: string);

    procedure META_CreateTable_SAMPLE(const AConnection: TDBXConnection);

  protected
    function META_GetProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts,
  SysUtils, IniFiles;

constructor TDtTstDb.Create(oLog: TDtTstLog; sIniPath: string);
var
  fIni: TIniFile;
  iDbCnt, iDbDef, iDb, iVal: Integer;
  sDb: string;
begin
  m_oLog := oLog;

  { ATTN: Copy BELOW members in descendants!!! }
  m_sIsqlPath           := '';
  m_iIsqlOptions        := -1;
  m_bUTF8               := False;
  m_asConnectStrings    := TStringList.Create();
  m_sConnectString      := '';
  m_sConnectUser        := '';
  m_sConnectPassword    := '';
  m_oCon                := nil;
  m_iADM_DbInfVersion   := 0;
  m_sADM_DbInfProduct   := '';
  { ATTN: Copy ABOVE members in descendants!!! }

  inherited Create();

  m_oLog.LogLIFE('TDtTstDb.Create');

  if not sIniPath.IsEmpty then
  begin
    if FileExists(sIniPath) then
    begin
      try
        m_oLog.LogVERSION('INI Path (for TDtTstDb): ' + sIniPath);

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

        m_sConnectUser     := fIni.ReadString(csINI_SEC_DB, csINI_VAL_DB_USR, '');
        m_sConnectPassword := fIni.ReadString(csINI_SEC_DB, csINI_VAL_DB_PW , '');

        iVal := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_UTF8, 0);
        m_bUTF8 := (iVal <> 0);

        m_sIsqlPath    := fIni.ReadString( csINI_SEC_DB, csINI_VAL_DB_ISQLPATH, '');
        m_iIsqlOptions := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_ISQLOPTS, -1);

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

function TDtTstDb.GetIsqlPath() : string;
begin
  Result := m_sIsqlPath;
end;

function TDtTstDb.GetIsqlOptions() : integer;
begin
  Result := m_iIsqlOptions;
end;

function TDtTstDb.GetUTF8() : Boolean;
begin
  Result := m_bUTF8;
end;

procedure TDtTstDb.GetConnectStrings(cbb: TComboBox; asConnectStrings: TStringList);
begin

  if Assigned(cbb) then
  begin
    cbb.Text := '';
    cbb.Items.Clear();

    cbb.Items.AddStrings(m_asConnectStrings);
    cbb.Text := m_sConnectString;
  end;

  if Assigned(asConnectStrings) then
  begin
    asConnectStrings.Clear();
    asConnectStrings.AddStrings(m_asConnectStrings);
  end;
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

  m_oLog.LogVERSION('TDtTstDb.Connect - DONE - Database = "' + m_sConnectString + '"');

  m_oLog.LogVERSION('TDtTstDb.Connect - DONE - ' + csDB_TBL_ADM_DBINF +
                    '( Version = ' + IntToStr(ADM_DbInfVersion) +
                    ', Product = "' + ADM_DbInfProduct + '" )' + '")' );

end;

procedure TDtTstDb.AfterConnect();
var
  oQry: TSQLQuery;
begin

  m_iADM_DbInfVersion := -1;
  m_sADM_DbInfProduct := '';

  if TableExists(csDB_TBL_ADM_DBINF) then
  begin

    oQry := TSQLQuery.Create(nil);
    try

      oQry.SQLConnection := m_oCon;

      oQry.SQL.Text := m_oLog.LogSQL('SELECT * FROM ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                                     ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_ID) + ' = 1;');
      oQry.Open();

      if not oQry.IsEmpty() then
      begin
        m_iADM_DbInfVersion := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_VER)).AsInteger;
        m_sADM_DbInfProduct := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD)).AsString;
      end;

    finally
      oQry.Close();
      FreeAndNil(oQry);
    end;

  end;

end;

function TDtTstDb.GetSQLConnection() : TSQLConnection;
begin
  Result := m_oCon;
end;

function TDtTstDb.GetLoginUser() : string;
begin
  Result := '';

  if Assigned(m_oCon) and m_oCon.Connected then
  begin
    Result := m_oCon.GetLoginUsername();
  end;
end;

function TDtTstDb.ADM_GetDbInfVersion() : integer;
begin
  Result := m_iADM_DbInfVersion;
end;

function TDtTstDb.ADM_GetDbInfProduct() : string;
begin
  Result := m_sADM_DbInfProduct;
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

  if Result = 'USER' then raise Exception.Create('Firebird Reserved Word: ' + Result);

end;

procedure TDtTstDb.DB_SelectGenerators(asResult: TStringList);
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
  sTriggerInfo: string;
begin

  asResult.Clear();

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // SRC: https://stackoverflow.com/questions/21165393/get-list-of-all-sequences-and-its-values-in-firebird-sql/21171176
    sSql := 'select rdb$generator_name as gen_name from rdb$generators where rdb$system_flag is distinct from 1';

    oQry.SQLConnection := m_oCon;

    oQry.SQL.Add(m_oLog.LogSQL(sSql));

    try

      oQry.Open();

      while not oQry.Eof do
      begin

        asResult.Add(TRIM(oQry.FieldByName('gen_name').AsString));

        oQry.Next;
      end;

    except

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDb.DB_SelectTriggers(asResult: TStringList; sTable: string; bDetails: Boolean);
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
  sTriggerInfo: string;
begin

  asResult.Clear();

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // SRC: https://stackoverflow.com/questions/26578880/how-to-print-firebird-triggers
    sSql := 'SELECT RDB$TRIGGER_NAME AS trigger_name,';

    if sTable.IsEmpty() and bDetails then
    begin
      sSql := sSql + ' RDB$RELATION_NAME AS table_name,';
    end;

    {
            ' RDB$TRIGGER_SOURCE AS trigger_body,' +
    }

    if bDetails then
    begin
      sSql := sSql + '  CASE RDB$TRIGGER_TYPE' +
              '   WHEN 1 THEN ''BEFORE''' +
              '   WHEN 2 THEN ''AFTER''' +
              '   WHEN 3 THEN ''BEFORE''' +
              '   WHEN 4 THEN ''AFTER''' +
              '   WHEN 5 THEN ''BEFORE''' +
              '   WHEN 6 THEN ''AFTER''' +
              '  END AS trigger_type,' +
              '  CASE RDB$TRIGGER_TYPE' +
              '   WHEN 1 THEN ''INSERT''' +
              '   WHEN 2 THEN ''INSERT''' +
              '   WHEN 3 THEN ''UPDATE''' +
              '   WHEN 4 THEN ''UPDATE''' +
              '   WHEN 5 THEN ''DELETE''' +
              '   WHEN 6 THEN ''DELETE''' +
              '  END AS trigger_event,' +
              '  CASE RDB$TRIGGER_INACTIVE' +
              '   WHEN 1 THEN ''Disabled'' ELSE ''Enabled''' +
              '  END AS trigger_enabled'; //',' +
              //'  RDB$DESCRIPTION AS trigger_comment';
    end;

    sSql := sSql + ' FROM RDB$TRIGGERS';

    if not sTable.IsEmpty() then
    begin
      sSql := sSql + ' WHERE RDB$RELATION_NAME = ' + '''' + FIXOBJNAME(sTable) + '''';
    end;

    oQry.SQLConnection := m_oCon;

    oQry.SQL.Add(m_oLog.LogSQL(sSql));

    try

      oQry.Open();

      while not oQry.Eof do
      begin

        sTriggerInfo := TRIM(oQry.FieldByName('trigger_name').AsString);

        if bDetails then
        begin

          sTriggerInfo := sTriggerInfo + ' ( ';

          if sTable.IsEmpty() then
          begin
            sTriggerInfo := sTriggerInfo + TRIM(oQry.FieldByName('table_name').AsString) + ', ';
          end;

          sTriggerInfo := sTriggerInfo + TRIM(oQry.FieldByName('trigger_type').AsString) + ', ';

          sTriggerInfo := sTriggerInfo + TRIM(oQry.FieldByName('trigger_event').AsString) + ', ';

          sTriggerInfo := sTriggerInfo + TRIM(oQry.FieldByName('trigger_enabled').AsString); // + ', ';

          //sTriggerInfo := sTriggerInfo + TRIM(oQry.FieldByName('trigger_comment').AsString) + ', ';

          sTriggerInfo := sTriggerInfo + ' ) ';

        end;

        asResult.Add(sTriggerInfo);

        oQry.Next;
      end;

    except

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

function TDtTstDb.ADM_DoDbUpdates(frmPrs: TFrmProgress) : Boolean;
begin
  Result := True; // Indicates that Database is Up-To-Date!!!
end;

procedure TDtTstDb.ADM_Increment_DBINFO_VER(oCon: TSQLConnection {nil = DO Transaction});
begin
  ADM_Update_DBINFO_VER( oCon {nil = DO Transaction}, m_iADM_DbInfVersion + 1);
  m_iADM_DbInfVersion := m_iADM_DbInfVersion + 1;
end;

procedure TDtTstDb.ADM_Update_DBINFO_VER(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);
var
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    if Assigned(oCon) then
      oQry.SQLConnection := oCon
    else
      oQry.SQLConnection := m_oCon;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL('UPDATE ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                 ' SET ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_VER) +
                 ' = :VER' +
                 ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_ID) + ' = 1' ));

    oQry.Params.ParamByName('VER').AsInteger  := iVersion;

    //oQry.Prepared := True;

    if not Assigned(oCon) then
      m_oCon.StartTransaction(oTD);

    try

      oQry.ExecSQL(False);

      if not Assigned(oCon) then
        m_oCon.Commit(oTD);

    except

      if not Assigned(oCon) then
        m_oCon.Rollback(oTD);

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDb.ADM_CreateTable_DBINFO();
var
  oProvider: TDBXDataExpressMetaDataProvider;
  oTable: TDBXMetaDataTable;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    oTable := TDBXMetaDataTable.Create;
    try

      { Table }

      oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_DBINF);

      META_AddColumn_INT32(  oTable, csDB_FLD_ADM_DBINF_ID , False {bNullable});

      META_AddColumn_INT32(  oTable, csDB_FLD_ADM_DBINF_VER, False {bNullable});

      META_AddColumn_VARCHAR(oTable, csDB_FLD_ADM_DBINF_PRD, False {bNullable}, 32);

      oProvider.CreateTable(oTable);

      { Generator }

      // NONE...

      { Trigger }

      // NONE...

    finally
      FreeAndNil(oTable);
    end;

    // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
    oQry := TSQLQuery.Create(nil);
    try

      oQry.SQLConnection := m_oCon;
      oQry.ParamCheck := True;
      // oQry.PrepareStatement;
      oQry.SQL.Add(m_oLog.LogSQL('INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                   ' (' + FIXOBJNAME(csDB_FLD_ADM_DBINF_ID) +
                   ', ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_VER) +
                   ', ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD) +
                   ') VALUES (:ID, :VER, :PRD)'));

      oQry.Params.ParamByName('ID').AsInteger   := 1;

      oQry.Params.ParamByName('VER').AsInteger  := 100;

      // ATTN: To write UTF8 string, nothing extra is required!!!
      {
      // Is this required to write UTF8 String???
      //oQry.Params.ParamByName('PRD').DataType := ftWideString;
      //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
      }

      oQry.Params.ParamByName('PRD').AsString   := csPRODUCT_FULL;

      //oQry.Prepared := True;

      m_oCon.StartTransaction(oTD);
      try

        oQry.ExecSQL(False);

        m_oCon.Commit(oTD);

        m_iADM_DbInfVersion := 100;
        m_sADM_DbInfProduct := csPRODUCT_FULL;

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

procedure TDtTstDb.META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable: string);
begin

  // NOP...

end;

procedure TDtTstDb.META_AddColumn_TimeStamp(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
var
  oCol: TDBXTimestampColumn;
begin
  oCol := TDBXTimestampColumn.Create(FIXOBJNAME(sColumnName));

  oCol.Nullable := bNullable;

  oTable.AddColumn(oCol);
end;

procedure TDtTstDb.META_AddColumn_INT32(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
var
  oCol: TDBXInt32Column;
begin
  oCol := TDBXInt32Column.Create(FIXOBJNAME(sColumnName));

  oCol.Nullable := bNullable;

  oTable.AddColumn(oCol);
end;

procedure TDtTstDb.META_AddColumn_VARCHAR(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean; iLen: integer);
var
  oCol: TDBXAnsiCharColumn; //TDBXUnicodeCharColumn;
begin

  oCol := TDBXAnsiCharColumn.Create(FIXOBJNAME(sColumnName), iLen);
  // oCol := TDBXUnicodeCharColumn.Create(FIXOBJNAME(sColumnName), iLen);

  oCol.Nullable := bNullable;

  // ATTN!!!
  oCol.FixedLength := False; // To make VarChar...

  oTable.AddColumn(oCol);
end;

procedure TDtTstDb.META_AddIndex_PrimaryKey(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);
var
  oIdx: TDBXMetaDataIndex;
begin

  oIdx := TDBXMetaDataIndex.Create;
  try

    {ATTN: OPTIONAL to name the Index!!!}
    {      Original Sample does not do so!!!}
    oIdx.IndexName := FIXOBJNAME(sTableName) + '_' + FIXOBJNAME(sColumnName);

    oIdx.TableName := FIXOBJNAME(sTableName);
    oIdx.AddColumn(FIXOBJNAME(sColumnName));

    // Add the Primary Key with my provider
    oProvider.CreatePrimaryKey(oIdx);
  finally
    FreeAndNil(oIdx);
  end;
end;

procedure TDtTstDb.META_DropTable(sTable: string);
var
  oProvider: TDBXDataExpressMetaDataProvider;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    // ATTN: Indices of a Table will be dropped along with the table!!!
    //if oProvider.DropIndex('tblname', 'idxname') then
    //begin

      if not oProvider.DropTable('', sTable) then
      begin
        raise Exception.Create('Unable to drop table ' + sTable + '!');
      end;

    //end;

    META_AfterDrop(oProvider, sTable);

  finally
    FreeAndNil(oProvider);
  end;

end;

procedure TDtTstDb.META_CreateTable_SAMPLE(const AConnection: TDBXConnection);
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  MyProvider: TDBXDataExpressMetaDataProvider;
  MyNewTable: TDBXMetaDataTable;
  MyPrimaryKey: TDBXMetaDataIndex;
  MyIDColumn: TDBXInt32Column;
begin
  // Get the MetadataProvider from my Connection
  MyProvider := META_GetProvider(AConnection);
  try
    // Create the Table structure
    MyNewTable := TDBXMetaDataTable.Create;

    try
      MyNewTable.TableName := csDB_TBL_SAMPLE;
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
      MyPrimaryKey.IndexName := csDB_TBL_SAMPLE + '_ID';

      MyPrimaryKey.TableName := csDB_TBL_SAMPLE;
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

function TDtTstDb.META_GetProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  oProvider: TDBXDataExpressMetaDataProvider;
begin
  oProvider := TDBXDataExpressMetaDataProvider.Create;
  try
    oProvider.Connection := AConnection;
    oProvider.Open;
  except
    FreeAndNil(oProvider);
    raise ;
  end;
  Result := oProvider;
end;

end.
