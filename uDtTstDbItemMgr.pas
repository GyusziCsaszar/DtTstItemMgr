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

    function ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress) : Boolean; override;

    procedure ADM_CreateTable_ITEMTYPE(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);

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
  m_sIsqlPath               := oDbToClone.IsqlPath;
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

function TDtTstDbItemMgr.ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress) : Boolean;
begin
  Result := False; // Indicated that there are more Database Updates pending...

  // Updating ADM tables...
  if not inherited ADM_DoDbUpdates_internal(oProvider, frmPrs) then
  begin
    Exit; // There are more Database Updates pending...
  end;

  if ADM_DbInfVersion_PRD <> ciDB_VERSION_PRD then
  begin

    if ADM_DbInfVersion_PRD > ciDB_VERSION_PRD then
    begin
      raise Exception.Create('Database PRD Version (' + IntToStr(ADM_DbInfVersion_PRD) +
                 ') is newer than the Application''s supported Database PRD Version (' +
                 IntToStr(ciDB_VERSION_PRD) + ')!');
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

procedure TDtTstDbItemMgr.META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string);
begin

  inherited META_AfterDrop(oProvider, sTable);

  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_PRD(nil {nil = DO Transaction}, 100);

  end;

end;

procedure TDtTstDbItemMgr.ADM_CreateTable_ITEMTYPE(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
  sOutput: string;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_USR_ITEMTYPE);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_USR_ITEMTYPE);

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRCRE       , False {bNullable}, 31);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE       , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_X_USRUPD       , False {bNullable}, 31);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPUPD       , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID           , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_USR_ITEMTYPE_NAME  , False {bNullable}, 255);

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Generator }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_USR_ITEMTYPE +  '_' + csDB_FLD_ADM_X_ID);
    if Assigned(frmPrs) then Application.ProcessMessages;

    META_CreateGenerator(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Trigger }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_USR_ITEMTYPE + '_BI');
    if Assigned(frmPrs) then Application.ProcessMessages;

    sOutput := ISQL_Execute(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                            IsqlPath,
                            ConnectString,
                            ConnectUser, ConnectPassword,
                            True {bGetOutput},
                            (IsqlOptions = 1) {bVisible},
                            'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) + CHR(13) + CHR(10) +
                                        ' ACTIVE BEFORE INSERT OR UPDATE' + CHR(13) + CHR(10) +
                                        ' POSITION 0' + CHR(13) + CHR(10) +
                                        ' AS' + CHR(13) + CHR(10) +
                                        ' BEGIN' + CHR(13) + CHR(10) +
                                        ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                                        FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) +
                                        '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                                        ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRCRE) + ' = current_user;' + CHR(13) + CHR(10) +
                                        ' IF (INSERTING AND NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
                                        ' NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_USRUPD) + ' = current_user;' + CHR(13) + CHR(10) +
                                        ' NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPUPD) + ' = current_timestamp;' + CHR(13) + CHR(10) +
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

  if Assigned(frmPrs) then frmPrs.AddStep('Creating index ' + csDB_TBL_USR_ITEMTYPE + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_USR_ITEMTYPE, csDB_FLD_ADM_X_ID);

  if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
  if Assigned(frmPrs) then Application.ProcessMessages;

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

end.
