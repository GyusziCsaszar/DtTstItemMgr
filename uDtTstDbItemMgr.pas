unit uDtTstDbItemMgr;

interface

uses
  { DtTst Units: } uDtTstLog, uDtTstDb,
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

    function ADM_DoDbUpdates() : Boolean; override;

    function ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection) : Boolean;
    function ADM_Insert_LoginUser(oCon: TSQLConnection) : Boolean;

    procedure ADM_CreateTable_USERS();

    procedure META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); override;
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstFirebird,
  System.Classes, SysUtils, System.IOUtils, Vcl.Forms;

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

function TDtTstDbItemMgr.ADM_DoDbUpdates() : Boolean;
begin
  Result := False; // Indicated that there are more Database Updates pending...

  if not inherited ADM_DoDbUpdates() then
  begin
    Exit; // There are more Database Updates pending...
  end;

  if ADM_DbInfVersion > ciDB_VERSION then
  begin
    raise Exception.Create('Database version (' + IntToStr(ADM_DbInfVersion) +
               ') is newer than the Application''s supported Database version (' +
               IntToStr(ciDB_VERSION) + ')!');
  end;

  if ADM_DbInfVersion < ciDB_VERSION then
  begin

    ADM_CreateTable_USERS();

  end;

  //ADM_Insert_LoginUser(nil {nil = DO Transaction} );
  ADM_UpdateOrInsert_LoginUser(nil {nil = DO Transaction} );

  Result := True; // Indicates that Database is Up-To-Date!!!
end;

function TDtTstDbItemMgr.ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection) : Boolean;
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin
  Result := false;

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

      Result := True;

    except

      if Assigned(oCon) then
        oCon.Rollback(oTD)
      else
        m_oCon.Rollback(oTD);

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

function TDtTstDbItemMgr.ADM_Insert_LoginUser(oCon: TSQLConnection) : Boolean;
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin
  Result := false;

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

      Result := True;

    except

      if Assigned(oCon) then
        oCon.Rollback(oTD)
      else
        m_oCon.Rollback(oTD);

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDbItemMgr.ADM_CreateTable_USERS();
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

      oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_USERS);

      META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_TSPCRE         , False {bNullable});

      META_AddColumn_INT32(     oTable, csDB_FLD_ADM_USERS_ID       , False {bNullable});

      META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_USERS_USER     , False {bNullable}, 31);

      META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_USERS_LSTLOGIN , False {bNullable});

      oProvider.CreateTable(oTable);

      { Generator }

      oProvider.Execute(m_oLog.LogSQL('CREATE GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ';'));

      oProvider.Execute(m_oLog.LogSQL('SET GENERATOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
        '_' + FIXOBJNAME(csDB_FLD_ADM_USERS_ID) + ' TO 0;'));

      { Trigger }

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
      if not sOutput.IsEmpty() then
      begin
        raise Exception.Create('Isql returned error: "' + sOutput + '"!');
      end;


    finally
      FreeAndNil(oTable);
    end;

    META_AddIndex_PrimaryKey(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_USERS_ID);

    m_oCon.StartTransaction(oTD);
    try

      { Current User }

      if ADM_Insert_LoginUser(m_oCon {nil = DO Transaction} ) then
      begin

        { DB Version Increment }

        ADM_Increment_DBINFO_VER();

        m_oCon.Commit(oTD);

      end;

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
    ADM_Update_DBINFO_VER(100);

  end;

end;

end.