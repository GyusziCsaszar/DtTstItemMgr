unit uDtTstDbItemMgr;

interface

uses
  { DtTst Units: } uDtTstLog, uDtTstDb, uFrmProgress,
  Data.Db, Data.SqlExpr,
  DbxCommon, DbxMetaDataProvider,
  DbxDataExpressMetaDataProvider,
  DbxClient; //, DbxDataStoreMetaData;

type
  TDtTstDbItemMgr = class (TDtTstDb)
  protected
    m_iADM_UserID: integer;
  public
    constructor Create(oLog: TDtTstLog; oDbToClone: TDtTstDb);
    destructor Destroy(); override;

    function ADM_GetUserID(): integer;
    property ADM_UserID: integer read ADM_GetUserID;

    function ADM_DoDbUpdates(frmPrs: TFrmProgress) : Boolean; override;

    procedure ADM_UpdateOrInsert_NewTable(oCon: TSQLConnection {nil = DO Transaction}; sTable: string);

    procedure ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
    procedure ADM_Insert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});

    procedure ADM_CreateTable_TABLES(frmPrs: TFrmProgress);
    procedure ADM_CreateTable_USERS(frmPrs: TFrmProgress);

    procedure META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); override;
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstFirebird,
  System.Classes, SysUtils, StrUtils, System.IOUtils, Vcl.Forms;

constructor TDtTstDbItemMgr.Create(oLog: TDtTstLog; oDbToClone: TDtTstDb);
begin
  inherited Create(oLog, '');

  m_oLog.LogLIFE('TDtTstDbItemMgr.Create');

  { ATTN: Copy BELOW members in descendants!!! }
  m_sIsqlPath           := oDbToClone.IsqlPath;
  m_iIsqlOptions        := oDbToClone.IsqlOptions;
  m_bUTF8               := oDbToClone.UTF8;
  m_asConnectStrings    := TStringList.Create();
  oDbToClone.GetConnectStrings(nil {cbb}, m_asConnectStrings);
  m_sConnectString      := oDbToClone.ConnectString;
  m_sConnectUser        := oDbToClone.ConnectUser;
  m_sConnectPassword    := oDbToClone.ConnectPassword;
  m_oCon                := oDbToClone.SQLConnection;
  m_iADM_DbInfVersion   := oDbToClone.ADM_DbInfVersion;
  m_sADM_DbInfProduct   := oDbToClone.ADM_DbInfProduct;
  { ATTN: Copy ABOVE members in descendants!!! }

  m_iADM_UserID := 0;
end;

destructor TDtTstDbItemMgr.Destroy();
begin
  m_oLog.LogLIFE('TDtTstDbItemMgr.Destroy');

  inherited Destroy();
end;

function TDtTstDbItemMgr.ADM_GetUserID(): integer;
begin
  Result := m_iADM_UserID;
end;

function TDtTstDbItemMgr.ADM_DoDbUpdates(frmPrs: TFrmProgress) : Boolean;
begin
  Result := False; // Indicated that there are more Database Updates pending...

  if ADM_DbInfVersion <> ciDB_VERSION then
  begin

    if not inherited ADM_DoDbUpdates(frmPrs) then
    begin
      Exit; // There are more Database Updates pending...
    end;

    if ADM_DbInfVersion > ciDB_VERSION then
    begin
      raise Exception.Create('Database version (' + IntToStr(ADM_DbInfVersion) +
                 ') is newer than the Application''s supported Database version (' +
                 IntToStr(ciDB_VERSION) + ')!');
    end;

    if Assigned(frmPrs) and (not frmPrs.Visible) then
    begin

      frmPrs.Show();
      frmPrs.Init('Database Update');
      frmPrs.SetProgressMinMax(ADM_DbInfVersion, ciDB_VERSION);

      Application.ProcessMessages;

    end;

    //if ADM_DbInfVersion < ciDB_VERSION then
    begin

      case ADM_DbInfVersion of

        100: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to version v1.01');

          ADM_CreateTable_USERS(frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        101: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to version v1.02');

          ADM_CreateTable_TABLES(frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

      end;

      if ADM_DbInfVersion < ciDB_VERSION then
      begin
        Exit; // There are more Database Updates pending...
      end;

    end;
  end;

  // ATTN: Have to be called each time!!!
  ADM_UpdateOrInsert_LoginUser(nil {nil = DO Transaction} );

  Result := True; // Indicates that Database is Up-To-Date!!!
end;

procedure TDtTstDbItemMgr.ADM_UpdateOrInsert_NewTable(oCon: TSQLConnection {nil = DO Transaction}; sTable: string);
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    sSql := 'UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
                 ' (' + FIXOBJNAME(csDB_FLD_ADM_TABLES_NAME) +
                 ') VALUES (' + ':TNM' + ')' +
                 ' MATCHING (' + FIXOBJNAME(csDB_FLD_ADM_TABLES_NAME) + ')';

    if Assigned(oCon) then
      oQry.SQLConnection := oCon
    else
      oQry.SQLConnection := m_oCon;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    oQry.Params.ParamByName('TNM').AsString   := sTable;

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

procedure TDtTstDbItemMgr.ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // BUG: Increments ID field!!!
    {
    sSql := 'UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' (' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_LSTLOGIN) +
                 ') VALUES ((SELECT current_timestamp FROM RDB$DATABASE)' +
                 ', (SELECT GEN_ID(' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', 1) FROM RDB$DATABASE)' +
                 ', :USR' +
                 ', (SELECT current_timestamp FROM RDB$DATABASE))' +
                 ' MATCHING (' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) + ')' +
                 ' RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID);
    }
    // BUG: Increments ID field!!! + No OLD.ID is avalilable!!!
    {
    sSql := 'UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' (' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_LSTLOGIN) +
                 ') VALUES ((SELECT current_timestamp FROM RDB$DATABASE)' +
                 ', IIF(OLD.ID IS NULL,(SELECT GEN_ID(' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', 1) FROM RDB$DATABASE),OLD.ID)' +
                 ', :USR' +
                 ', (SELECT current_timestamp FROM RDB$DATABASE))' +
                 ' MATCHING (' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) + ')' +
                 ' RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID);
    }
    // FIX: Before Insert Trigger!!!
    sSql := 'UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' (' {+ FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', '} + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_LSTLOGIN) +
                 ') VALUES (' {+ '(SELECT current_timestamp FROM RDB$DATABASE)' +
                 ', (SELECT GEN_ID(' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', 1) FROM RDB$DATABASE)' +
                 ', '} + ':USR' +
                 ', (SELECT current_timestamp FROM RDB$DATABASE))' +
                 ' MATCHING (' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) + ')' +
                 ' RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID);

    if Assigned(oCon) then
      oQry.SQLConnection := oCon
    else
      oQry.SQLConnection := m_oCon;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    oQry.Params.ParamByName('USR').AsString   := LoginUser;

    //oQry.Prepared := True;

    if not Assigned(oCon) then
      m_oCon.StartTransaction(oTD);

    try

      //oQry.ExecSQL(False);
      oQry.Open();

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_USERS_ID)).AsInteger;

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

procedure TDtTstDbItemMgr.ADM_Insert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    {
    sSql := 'INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' (' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_LSTLOGIN) +
                 ') VALUES ((SELECT current_timestamp FROM RDB$DATABASE)' +
                 ', (SELECT GEN_ID(' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', 1) FROM RDB$DATABASE)' +
                 ', :USR' +
                 ', (SELECT current_timestamp FROM RDB$DATABASE))';
    }
    // CHG: ID will be assigned in Before Insert Trigger!!!
    sSql := 'INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' (' {+ FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', '} + FIXOBJNAME(csDB_FLD_ADM_USERS_USER) +
                 ', ' + FIXOBJNAME(csDB_FLD_ADM_USERS_LSTLOGIN) +
                 ') VALUES ( ' {+ '(SELECT current_timestamp FROM RDB$DATABASE)' +
                 ', (SELECT GEN_ID(' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                 ', 1) FROM RDB$DATABASE)' +
                 ', '} + ':USR' +
                 ', (SELECT current_timestamp FROM RDB$DATABASE))';

    if Assigned(oCon) then
      oQry.SQLConnection := oCon
    else
      oQry.SQLConnection := m_oCon;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL(sSQL));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    oQry.Params.ParamByName('USR').AsString   := LoginUser;

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

procedure TDtTstDbItemMgr.ADM_CreateTable_TABLES(frmPrs: TFrmProgress);
var
  oProvider: TDBXDataExpressMetaDataProvider;
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
  sOutput: string;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    oTable := TDBXMetaDataTable.Create;
    try

      { Table }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_ADM_TABLES);
      if Assigned(frmPrs) then Application.ProcessMessages;

      oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_TABLES);

      META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_TSPCRE         , False {bNullable});

      META_AddColumn_INT32(     oTable, csDB_FLD_ADM_TABLES_ID      , False {bNullable});

      META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_TABLES_NAME    , False {bNullable}, 31);

      oProvider.CreateTable(oTable);

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { Generator }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_ADM_TABLES +  '_' + csDB_FLD_ADM_TABLES_ID);
      if Assigned(frmPrs) then Application.ProcessMessages;

      oProvider.Execute(m_oLog.LogSQL('CREATE GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) + ';'));

      oProvider.Execute(m_oLog.LogSQL('SET GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) + ' TO 0;'));

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { Trigger }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_ADM_TABLES + '_BI');
      if Assigned(frmPrs) then Application.ProcessMessages;

      sOutput := IsqlExec(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                          IsqlPath,
                          ConnectString,
                          ConnectUser, ConnectPassword,
                          True {bGetOutput},
                          (IsqlOptions = 1) {bVisible},
                          'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + CHR(13) + CHR(10) +
                                      ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                                      ' POSITION 0' + CHR(13) + CHR(10) +
                                      ' AS' + CHR(13) + CHR(10) +
                                      ' BEGIN' + CHR(13) + CHR(10) +
                                      ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) + ' = GEN_ID(' +
                                      FIXOBJNAME(csDB_TBL_ADM_TABLES) +
                                      '_' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) + ', 1);' + CHR(13) + CHR(10) +
                                      ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) + ' = (SELECT current_timestamp FROM RDB$DATABASE);' + CHR(13) + CHR(10) +
                                      ' END!!',
                                      '!!');

      if not ContainsText(sOutput, csISQL_SUCCESS) then
      begin
        raise Exception.Create('Isql returned error: "' + sOutput + '"!');
      end;

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

    finally
      FreeAndNil(oTable);
    end;

    { Indices }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating index ' + csDB_TBL_ADM_TABLES + '_' + csDB_FLD_ADM_TABLES_ID);
    if Assigned(frmPrs) then Application.ProcessMessages;

    META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_ADM_TABLES, csDB_FLD_ADM_TABLES_ID);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { ROWS }

    m_oCon.StartTransaction(oTD);
    try

      { Users Table }

      if Assigned(frmPrs) then frmPrs.AddStep('Inserting table ' + csDB_TBL_ADM_USERS + ' into table ' + csDB_TBL_ADM_TABLES);
      if Assigned(frmPrs) then Application.ProcessMessages;

      // ATTN: USERS table already created, now we add to TABLES...
      ADM_UpdateOrInsert_NewTable(m_oCon {nil = DO Transaction}, csDB_TBL_ADM_USERS);

      // NOTE: Updating to original (???) creation timestamp...
      USR_Update(m_oCon {nil = DO Transaction}, 'UPDATE ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
                 ' SET ' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                 ' = (SELECT ' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) + ' FROM ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                 ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' = 1)' +
                 ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_TABLES_NAME) + ' = ''' + csDB_TBL_ADM_USERS + '''');

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { Tables Table }

      if Assigned(frmPrs) then frmPrs.AddStep('Inserting table ' + csDB_TBL_ADM_TABLES + ' into table ' + csDB_TBL_ADM_TABLES);
      if Assigned(frmPrs) then Application.ProcessMessages;

      ADM_UpdateOrInsert_NewTable(m_oCon {nil = DO Transaction}, csDB_TBL_ADM_TABLES);

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { DB Version Increment }

      if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
      if Assigned(frmPrs) then Application.ProcessMessages;

      ADM_Increment_DBINFO_VER(m_oCon {nil = DO Transaction} );

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      m_oCon.Commit(oTD);

    except
      m_oCon.Rollback(oTD);
    end;

  finally
    FreeAndNil(oProvider);
  end;

end;

procedure TDtTstDbItemMgr.ADM_CreateTable_USERS(frmPrs: TFrmProgress);
var
  oProvider: TDBXDataExpressMetaDataProvider;
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
  sOutput: string;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    oTable := TDBXMetaDataTable.Create;
    try

      { Table }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_ADM_USERS);
      if Assigned(frmPrs) then Application.ProcessMessages;

      oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_USERS);

      META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_TSPCRE         , False {bNullable});

      META_AddColumn_INT32(     oTable, csDB_FLD_ADM_USERS_ID       , False {bNullable});

      META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_USERS_USER     , False {bNullable}, 31);

      META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_USERS_LSTLOGIN , False {bNullable});

      oProvider.CreateTable(oTable);

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { Generator }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_ADM_USERS +  '_' + csDB_FLD_ADM_USERS_ID);
      if Assigned(frmPrs) then Application.ProcessMessages;

      oProvider.Execute(m_oLog.LogSQL('CREATE GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ';'));

      oProvider.Execute(m_oLog.LogSQL('SET GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' TO 0;'));

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { Trigger }

      if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_ADM_USERS + '_BI');
      if Assigned(frmPrs) then Application.ProcessMessages;

      // BUG: Failed!
      {
      // SRC: https://docs.telerik.com/data-access/developers-guide/database-specifics/firebird/database-specifics-firebird-auto-inc-columns
      oProvider.Execute(m_oLog.LogSQL('CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      ' ACTIVE BEFORE INSERT' +
                                      ' POSITION 0' +
                                      ' AS' +
                                      ' BEGIN' +
                                      '  IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' = GEN_ID(' +
                                      FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ', 1);' +
                                      ' END;'));
      }
      // FIX: TERM has to be set!!! - BUG: SET TERM is only available in ISQL!!!
      {
      oProvider.Execute(m_oLog.LogSQL('SET TERM !! ; CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      ' ACTIVE BEFORE INSERT' +
                                      ' POSITION 0' +
                                      ' AS' +
                                      ' BEGIN' +
                                      '  IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' = GEN_ID(' +
                                      FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ', 1);' +
                                      ' END !! SET TERM ; !!'));
      }
      // BUG: admUsers.admCreTsp is updated by UPDATE OR INSERT!!!
      {
      sOutput := IsqlExec(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                          IsqlPath,
                          ConnectString,
                          ConnectUser, ConnectPassword,
                          True {bGetOutput,
                          (IsqlOptions = 1) {bVisible,
                          'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + CHR(13) + CHR(10) +
                                      ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                                      ' POSITION 0' + CHR(13) + CHR(10) +
                                      ' AS' + CHR(13) + CHR(10) +
                                      ' BEGIN' + CHR(13) + CHR(10) +
                                      ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' = GEN_ID(' +
                                      FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ', 1);' + CHR(13) + CHR(10) +
                                      ' END!!',
                                      '!!');
      }
      sOutput := IsqlExec(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                          IsqlPath,
                          ConnectString,
                          ConnectUser, ConnectPassword,
                          True {bGetOutput},
                          (IsqlOptions = 1) {bVisible},
                          'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + CHR(13) + CHR(10) +
                                      ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                                      ' POSITION 0' + CHR(13) + CHR(10) +
                                      ' AS' + CHR(13) + CHR(10) +
                                      ' BEGIN' + CHR(13) + CHR(10) +
                                      ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' = GEN_ID(' +
                                      FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                      '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ', 1);' + CHR(13) + CHR(10) +
                                      ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) +
                                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_TSPCRE) + ' = (SELECT current_timestamp FROM RDB$DATABASE);' + CHR(13) + CHR(10) +
                                      ' END!!',
                                      '!!');

      if not ContainsText(sOutput, csISQL_SUCCESS) then
      begin
        raise Exception.Create('Isql returned error: "' + sOutput + '"!');
      end;

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

    finally
      FreeAndNil(oTable);
    end;

    { Indices }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating index ' + csDB_TBL_ADM_USERS + '_' + csDB_FLD_ADM_USERS_ID);
    if Assigned(frmPrs) then Application.ProcessMessages;

    META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_USERS_ID);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { ROWS }

    m_oCon.StartTransaction(oTD);
    try

      { Current User }

      if Assigned(frmPrs) then frmPrs.AddStep('Inserting user into table ' + csDB_TBL_ADM_USERS);
      if Assigned(frmPrs) then Application.ProcessMessages;

      ADM_Insert_LoginUser(m_oCon {nil = DO Transaction} );

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      { DB Version Increment }

      if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
      if Assigned(frmPrs) then Application.ProcessMessages;

      ADM_Increment_DBINFO_VER(m_oCon {nil = DO Transaction} );

      if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
      if Assigned(frmPrs) then Application.ProcessMessages;

      m_oCon.Commit(oTD);

    except
      m_oCon.Rollback(oTD);
    end;

  finally
    FreeAndNil(oProvider);
  end;

end;

procedure TDtTstDbItemMgr.META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string);
begin

  inherited META_AfterDrop(oProvider, sTable);

  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_USERS) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    oProvider.Execute(m_oLog.LogSQL('DROP GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
      '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ';'));

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER(nil {nil = DO Transaction}, 100);

  end
  else if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_TABLES) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + '_BI'));

    oProvider.Execute(m_oLog.LogSQL('DROP GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
      '_' + FIXOBJNAME(csDB_FLD_ADM_TABLES_ID) + ';'));

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER(nil {nil = DO Transaction}, 101);

  end;

end;

end.
