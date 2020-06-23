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
  public
    constructor Create(oLog: TDtTstLog; oDbToClone: TDtTstDb);
    destructor Destroy(); override;

    function ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress; ADMIN_MODE: Boolean) : Boolean; override;

    procedure ADM_CreateTable_ITEMTYPE(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
    procedure ADM_CreateTable_ITEM(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
    procedure ADM_CreateTable_ITEMGROUP(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);

    procedure META_After_DropTable(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); override;
    procedure META_Before_DropTable(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); override;
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstWin, uDtTstFirebird,
  System.Classes, SysUtils, StrUtils, System.IOUtils, Vcl.Forms;

constructor TDtTstDbItemMgr.Create(oLog: TDtTstLog; oDbToClone: TDtTstDb);
begin
  inherited Create(oLog, '');

  m_oLog.LogLIFE('TDtTstDbItemMgr.Create');

  { ATTN: Copy BELOW members in descendants!!! }
  m_sIsqlPathPRI            := oDbToClone.IsqlPathPRI;
  m_sIsqlPathSEC            := oDbToClone.IsqlPathSEC;
  m_iIsqlOptions            := oDbToClone.IsqlOptions;
  m_bUTF8                   := oDbToClone.UTF8;
  m_asConnectStrings        := TStringList.Create();
  oDbToClone.GetConnectStrings(nil {cbb}, m_asConnectStrings);
  m_sConnectString          := oDbToClone.ConnectString;
  m_sConnectUser            := oDbToClone.ConnectUser;
  m_sConnectPassword        := oDbToClone.ConnectPassword;
  m_oCon                    := oDbToClone.SQLConnection;
  m_iADM_DbInfVersion_ADM   := oDbToClone.ADM_DbInfVersion_ADM;
  m_sADM_DbInfProduct       := oDbToClone.ADM_DbInfProduct;
  m_iADM_UserID             := oDbToClone.ADM_UserID;
  m_iADM_DbInfVersion_PRD   := oDbToClone.ADM_DbInfVersion_PRD;
  { ATTN: Copy ABOVE members in descendants!!! }

end;

destructor TDtTstDbItemMgr.Destroy();
begin
  m_oLog.LogLIFE('TDtTstDbItemMgr.Destroy');

  inherited Destroy();
end;

function TDtTstDbItemMgr.ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress; ADMIN_MODE: Boolean) : Boolean;
begin
  Result := False; // Indicated that there are more Database Updates pending...

  // Updating ADM tables...
  if not inherited ADM_DoDbUpdates_internal(oProvider, frmPrs, ADMIN_MODE) then
  begin
    Exit; // There are more Database Updates pending...
  end;

  if ADM_DbInfVersion_PRD <> ciDB_VERSION_PRD then
  begin

    if ADM_DbInfVersion_PRD > ciDB_VERSION_PRD then
    begin
      raise Exception.Create('Database PRD Version (' + IntToStr(ADM_DbInfVersion_PRD) +
                 ') is NEWER than the Application''s supported Database PRD Version (' +
                 IntToStr(ciDB_VERSION_PRD) + ')!');
    end;

    //if ADM_DbInfVersion_PRD < ciDB_VERSION_PRD then
    begin
      if (not ADMIN_MODE) or (not QuestionMsgDlg('Database PRD Version (' + IntToStr(ADM_DbInfVersion_PRD) +
                   ') is OLDER than the Application''s supported Database PRD Version (' +
                   IntToStr(ciDB_VERSION_PRD) + ')!' + CHR(10) + CHR(10) +
                   'Database UPDATE is required!' + CHR(10) + CHR(10) +
                   'Do you want to continue?')) then
      begin
        raise Exception.Create('Database PRD Version (' + IntToStr(ADM_DbInfVersion_PRD) +
                   ') is OLDER than the Application''s supported Database PRD Version (' +
                   IntToStr(ciDB_VERSION_PRD) + ')!' + CHR(10) + CHR(10) +
                   'Database UPDATE is required!' + CHR(10) + CHR(10) +
                   'Please contact the Database Administrator!');
      end;
    end;

    if Assigned(frmPrs) and (not frmPrs.Visible) then
    begin

      frmPrs.Show();
      frmPrs.Init('Database Update');

      Application.ProcessMessages;

    end;

    //if ADM_DbInfVersion < ciDB_VERSION then
    begin

      if Assigned(frmPrs) and (ADM_DbInfVersion_PRD < 101) then
      begin
        frmPrs.SetProgressMinMax(ADM_DbInfVersion_PRD, ciDB_VERSION_PRD);
      end;


      case ADM_DbInfVersion_PRD of

        100: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to PRD Version v1.01');

          ADM_CreateTable_ITEMTYPE(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_PRD);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        101: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to PRD Version v1.02');

          ADM_CreateTable_ITEM(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_PRD);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        102: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to PRD Version v1.03');

          ADM_CreateTable_ITEMGROUP(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_PRD);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        else begin

          raise Exception.Create('Current Database ADM Version (' + IntToStr(ADM_DbInfVersion_PRD) +
                 ') is UNKNOWN!');

        end;

      end;

      if ADM_DbInfVersion_PRD < ciDB_VERSION_PRD then
      begin
        Exit; // There are more Database Updates pending...
      end;

    end;
  end;

  // ATTN: Have to be called each time!!!
  ADM_UpdateOrInsert_LoginUser(nil {nil = DO Transaction} );

  Result := True; // Indicates that Database is Up-To-Date!!!
end;

procedure TDtTstDbItemMgr.META_After_DropTable(oProvider: TDBXDataExpressMetaDataProvider; sTable : string);
begin

  inherited META_After_DropTable(oProvider, sTable);

  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_PRD(nil {nil = DO Transaction}, 100);

  end
  else if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_USR_ITEM) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_PRD(nil {nil = DO Transaction}, 101);

  end
  else if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_USR_ITEMGROUP) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v102!
    ADM_Update_DBINFO_VER_PRD(nil {nil = DO Transaction}, 102);

  end;

end;

procedure TDtTstDbItemMgr.META_Before_DropTable(oProvider: TDBXDataExpressMetaDataProvider; sTable : string);
begin

  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_USR_ITEM) then
  begin

    //META_DropView('V_' + csDB_TBL_USR_ITEM);

    oProvider.Execute( m_oLog.LogSQL('DROP VIEW ' + 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) + ';'));

  end;

  inherited META_Before_DropTable(oProvider, sTable);

end;

procedure TDtTstDbItemMgr.ADM_CreateTable_ITEMTYPE(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_USR_ITEMTYPE);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_USR_ITEMTYPE);

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRCRE       , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE       , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRUPD       , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPUPD       , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID           , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEMTYPE_NAME  , False {bNullable},  ciDB_FLD_USR_ITEMTYPE_NAME_Length);

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

  finally
    FreeAndNil(oTable);
  end;

  { Foreign Key }

  // NONE...

  { Generator }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_USR_ITEMTYPE +  '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateGenerator(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Trigger }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_USR_ITEMTYPE + '_BI');
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateTrigger( FIXOBJNAME(csDB_TBL_USR_ITEMTYPE),
                      FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) + '_BI',
                      ' ACTIVE BEFORE INSERT OR UPDATE' + CHR(13) + CHR(10) +
                      ' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      { INSERTING - ID }
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                      FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) +
                      '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                      { INSERTING - USRCRE, TSPCRE}
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      { INSERTING OR UPDATING - USRUPD, TSPUPD }
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRUPD) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPUPD) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      ' END');

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Indices }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating Primary Key index ' + csDB_TBL_USR_ITEMTYPE + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  if Assigned(frmPrs) then frmPrs.AddStep('Creating UNIQUE index ' + csDB_TBL_USR_ITEMTYPE + '_' + csDB_FLD_USR_ITEMTYPE_NAME);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_UNIQUE(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_USR_ITEMTYPE_NAME);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { VIEWS }

  // NONE...

  { ROWS }

  m_oCon.StartTransaction(oTD);
  try

    { Tables Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Inserting table ' + csDB_TBL_USR_ITEMTYPE + ' into table ' + csDB_TBL_ADM_TABLES);
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_UpdateOrInsert_NewTable(m_oCon {nil = DO Transaction}, csDB_TBL_USR_ITEMTYPE);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { DB Version Increment }

    if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_Increment_DBINFO_VER_PRD(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    m_oCon.Commit(oTD);

  except
    m_oCon.Rollback(oTD);
  end;

end;

procedure TDtTstDbItemMgr.ADM_CreateTable_ITEM(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_USR_ITEM);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_USR_ITEM);

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRCRE         , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE         , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRUPD         , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPUPD         , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID             , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEM_ITEMNR      , False {bNullable},  ciDB_FLD_USR_ITEM_ITEMNR_Length);

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEM_NAME        , False {bNullable},  ciDB_FLD_USR_ITEM_NAME_Length);

    META_AddColumn_INT32(     oTable, csDB_FLD_USR_ITEM_ITEMTYPE_ID , True  {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_USR_ITEM_AMO         , True  {bNullable});

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

  finally
    FreeAndNil(oTable);
  end;

  { Foreign Key }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating Foreign Key constraint FK_' + csDB_TBL_USR_ITEM +  '_' + csDB_FLD_USR_ITEM_ITEMTYPE_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateConstraint_ForeignKey(oProvider,
          csDB_TBL_USR_ITEM,     csDB_FLD_USR_ITEM_ITEMTYPE_ID,
          csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Generator }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_USR_ITEM +  '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateGenerator(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Trigger }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_USR_ITEM + '_BI');
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateTrigger( FIXOBJNAME(csDB_TBL_USR_ITEM),
                      FIXOBJNAME(csDB_TBL_USR_ITEM) + '_BI',
                      ' ACTIVE BEFORE INSERT OR UPDATE' + CHR(13) + CHR(10) +
                      ' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      { INSERTING - ID }
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                      FIXOBJNAME(csDB_TBL_USR_ITEM) +
                      '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                      { INSERTING - USRCRE, TSPCRE}
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      { INSERTING OR UPDATING - USRUPD, TSPUPD }
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRUPD) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPUPD) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      ' END');

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Indices }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating Primary Key index ' + csDB_TBL_USR_ITEM + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { ... }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating UNIQUE index ' + csDB_TBL_USR_ITEM + '_' + csDB_FLD_USR_ITEM_ITEMNR);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_UNIQUE(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_USR_ITEM_ITEMNR);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { ... }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating NON-Unique index ' + csDB_TBL_USR_ITEM + '_' + csDB_FLD_USR_ITEM_NAME);
  if Assigned(frmPrs) then Application.ProcessMessages;

  // FIX: A name allowed for more rows!!!
//META_CreateIndex_UNIQUE(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_USR_ITEM_NAME);
  META_CreateIndex_NON_Unique(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_USR_ITEM_NAME);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { ... }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating NON-Unique index ' + csDB_TBL_USR_ITEM + '_' + csDB_FLD_USR_ITEM_ITEMTYPE_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_NON_Unique(oProvider, csDB_TBL_USR_ITEM, csDB_FLD_USR_ITEM_ITEMTYPE_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { VIEWS }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating view ' + 'V_' + csDB_TBL_USR_ITEM);
  if Assigned(frmPrs) then Application.ProcessMessages;

  // BUG: Read-Only View!!!
  {
  oProvider.Execute(
      m_oLog.LogSQL('CREATE VIEW ' + 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) +
                    ' AS SELECT ' + 'A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                       ', ' + 'B.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                       ' FROM ' + FIXOBJNAME(csDB_TBL_USR_ITEM) + ' A' +
                       ' LEFT JOIN ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) + ' B' +
                       '   ON (B.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMTYPE_ID) + ')' +
                       ' ORDER BY ' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME)) +
                       ';');
  }

  // SRC: https://www.wisdomjobs.com/e-university/firebird-tutorial-210/read-only-and-updatable-views-7816.html
  oProvider.Execute(
      m_oLog.LogSQL('CREATE VIEW ' + 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) +
                    ' AS SELECT ' + 'A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                             ', ' + 'A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                             ', ' + 'B.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                             ', ' + 'A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) +
                       ' FROM ' + FIXOBJNAME(csDB_TBL_USR_ITEM) + ' A' +
                           ', ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) + ' B' +
                       ' WHERE ' + 'A.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMTYPE_ID) + ' = ' + 'B.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                       ';'));

  // SRC: https://www.wisdomjobs.com/e-university/firebird-tutorial-210/read-only-and-updatable-views-7816.html
  {
    CREATE TRIGGER  TableView_Delete FOR TableView
    ACTIVE BEFORE DELETE AS
    BEGIN
    DELETE FROM Table1
    WHERE ColA = OLD.ColA;
    DELETE FROM Table2
    WHERE ColA = OLD.ColA;
    END
  }

  META_CreateTrigger( 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM),
                      'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) + '_DELETE',
                      ' ACTIVE BEFORE DELETE' + CHR(13) + CHR(10) +
                    //' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      '   DELETE FROM ' + FIXOBJNAME(csDB_TBL_USR_ITEM) + CHR(13) + CHR(10) +
                      '   WHERE ' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) + ' = OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                      ';'  + CHR(13) + CHR(10) +
                      ' END');

  // SRC: https://www.wisdomjobs.com/e-university/firebird-tutorial-210/read-only-and-updatable-views-7816.html
  {
    CREATE TRIGGER  TableView_Update FOR TableView
    ACTIVE BEFORE UPDATE AS
    BEGIN
    UPDATE Table1
    SET ColB = NEW.ColB
    WHERE ColA = OLD.ColA;
    UPDATE Table2
    SET ColC = NEW.ColC
    WHERE ColA = OLD.ColA;
    END
  }

  META_CreateTrigger( 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM),
                      'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) + '_UPDATE',
                      ' ACTIVE BEFORE UPDATE' + CHR(13) + CHR(10) +
                    //' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      '   UPDATE ' + FIXOBJNAME(csDB_TBL_USR_ITEM) + CHR(13) + CHR(10) +
                      '      SET ' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME)   + ' = NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME  ) + CHR(13) + CHR(10) +
                      '        , ' + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO)    + ' = NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO   ) + CHR(13) + CHR(10) +
                      '    WHERE ' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) + ' = OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                      ';'  + CHR(13) + CHR(10) +
                      ' END');

  // SRC: https://www.wisdomjobs.com/e-university/firebird-tutorial-210/read-only-and-updatable-views-7816.html
  {
    CREATE TRIGGER  TableView_Insert FOR TableView
    ACTIVE BEFORE INSERT AS
    BEGIN
    INSERT INTO Table1 values  (NEW.ColA,NEW.ColB);
    INSERT INTO Table2 values  (NEW.ColA,NEW.ColC);
    END
  }

  // BUG: Does not set FOREIGN KEY ID!!!
  {
  META_CreateTrigger( 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM),
                      'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) + '_INSERT',
                      ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                    //' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      '   INSERT INTO ' + FIXOBJNAME(csDB_TBL_USR_ITEM) +
                              ' ('      + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                              ', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                              //', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMTYPE_ID) +
                              ', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) + ' )' + CHR(13) + CHR(10) +
                      '   VALUES( NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                               ', NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                               ', NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) + ')' +
                      ';' + CHR(13) + CHR(10) +
                      '   UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) +
                      ' (' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ' )' + //CHR(13) + CHR(10) +
                      '   VALUES( NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ')' +
                      '   MATCHING( ' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ' )' +
                    //  '   RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                       ';' + CHR(13) + CHR(10) +
                      ' END');
  }

  META_CreateTrigger( 'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM),
                      'V_' + FIXOBJNAME(csDB_TBL_USR_ITEM) + '_INSERT',
                      ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                    //' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      '   DECLARE VARIABLE tmpID BIGINT;' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      '   UPDATE OR INSERT INTO ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) +
                      ' (' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ' )' + //CHR(13) + CHR(10) +
                      '   VALUES( NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ')' +
                      '   MATCHING( ' + FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ' )' +
                      '   RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' INTO :tmpID' +
                       ';' + CHR(13) + CHR(10) +
                      '   INSERT INTO ' + FIXOBJNAME(csDB_TBL_USR_ITEM) +
                              ' ('      + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                              ', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                              ', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMTYPE_ID) +
                              ', '      + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) + ' )' + CHR(13) + CHR(10) +
                      '   VALUES( NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                               ', NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                               ', :tmpID' +
                               ', NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) + ')' +
                      ';' + CHR(13) + CHR(10) +
                      ' END');

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { ROWS }

  m_oCon.StartTransaction(oTD);
  try

    { Tables Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Inserting table ' + csDB_TBL_USR_ITEM + ' into table ' + csDB_TBL_ADM_TABLES);
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_UpdateOrInsert_NewTable(m_oCon {nil = DO Transaction}, csDB_TBL_USR_ITEM);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { DB Version Increment }

    if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_Increment_DBINFO_VER_PRD(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    m_oCon.Commit(oTD);

  except
    m_oCon.Rollback(oTD);
  end;

end;

procedure TDtTstDbItemMgr.ADM_CreateTable_ITEMGROUP(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_USR_ITEMGROUP);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_USR_ITEMGROUP);

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRCRE       , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE       , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRUPD       , False {bNullable}, ciDB_FLD_ADM_X_USR_Lenght);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPUPD       , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID           , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEMGROUP_NODE , False {bNullable},  ciDB_FLD_USR_ITEMGROUP_NODE_Length);

    META_AddColumn_INT32(     oTable, csDB_FLD_USR_ITEMGROUP_LEVEL, False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEMGROUP_PATH , False {bNullable},  ciDB_FLD_USR_ITEMGROUP_PATH_Length);

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

  finally
    FreeAndNil(oTable);
  end;

  { Foreign Key }

  // NONE...

  { Generator }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_USR_ITEMGROUP +  '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateGenerator(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Trigger }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_USR_ITEMGROUP + '_BI');
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateTrigger( FIXOBJNAME(csDB_TBL_USR_ITEMGROUP),
                      FIXOBJNAME(csDB_TBL_USR_ITEMGROUP) + '_BI',
                      ' ACTIVE BEFORE INSERT OR UPDATE' + CHR(13) + CHR(10) +
                      ' POSITION 0' + CHR(13) + CHR(10) +
                      ' AS' + CHR(13) + CHR(10) +
                      ' BEGIN' + CHR(13) + CHR(10) +
                      { INSERTING - ID }
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                      FIXOBJNAME(csDB_TBL_USR_ITEMGROUP) +
                      '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                      { INSERTING - USRCRE, TSPCRE}
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                      ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      { INSERTING OR UPDATING - USRUPD, TSPUPD }
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRUPD) + ' = current_user;' + CHR(13) + CHR(10) +
                      ' IF (INSERTING ' + 'OR (NEW.' + FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) +
                      ' <> OLD.' + FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) +
                      ') ' + ') THEN ' + 'NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPUPD) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                      ' END');

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { Indices }

  if Assigned(frmPrs) then frmPrs.AddStep('Creating Primary Key index ' + csDB_TBL_USR_ITEMGROUP + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  if Assigned(frmPrs) then frmPrs.AddStep('Creating NON-Unique index ' + csDB_TBL_USR_ITEMGROUP + '_' + csDB_FLD_USR_ITEMGROUP_NODE);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_NON_Unique(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_USR_ITEMGROUP_NODE);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  if Assigned(frmPrs) then frmPrs.AddStep('Creating NON-Unique index ' + csDB_TBL_USR_ITEMGROUP + '_' + csDB_FLD_USR_ITEMGROUP_LEVEL);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_NON_Unique(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_USR_ITEMGROUP_LEVEL);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  if Assigned(frmPrs) then frmPrs.AddStep('Creating UNIQUE index ' + csDB_TBL_USR_ITEMGROUP + '_' + csDB_FLD_USR_ITEMGROUP_PATH);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_UNIQUE(oProvider, csDB_TBL_USR_ITEMGROUP, csDB_FLD_USR_ITEMGROUP_PATH);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

  { VIEWS }

  // NONE...

  { ROWS }

  m_oCon.StartTransaction(oTD);
  try

    { Tables Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Inserting table ' + csDB_TBL_USR_ITEMGROUP + ' into table ' + csDB_TBL_ADM_TABLES);
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_UpdateOrInsert_NewTable(m_oCon {nil = DO Transaction}, csDB_TBL_USR_ITEMGROUP);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { DB Version Increment }

    if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_Increment_DBINFO_VER_PRD(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    m_oCon.Commit(oTD);

  except
    m_oCon.Rollback(oTD);
  end;

end;

end.
