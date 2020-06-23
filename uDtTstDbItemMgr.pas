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

  // Sample Code
  {
  if ADM_DbInfVersion_ADM <> ciDB_VERSION_ADM then
  begin

    if ADM_DbInfVersion_ADM > ciDB_VERSION_ADM then
    begin
      raise Exception.Create('Database ADM Version (' + IntToStr(ADM_DbInfVersion_ADM) +
                 ') is newer than the Application''s supported Database ADM Version (' +
                 IntToStr(ciDB_VERSION_ADM) + ')!');
    end;

    if Assigned(frmPrs) and (not frmPrs.Visible) then
    begin

      frmPrs.Show();
      frmPrs.Init('Database Update');
      frmPrs.SetProgressMinMax(ADM_DbInfVersion_ADM, ciDB_VERSION_ADM);

      Application.ProcessMessages;

    end;

    //if ADM_DbInfVersion < ciDB_VERSION then
    begin

      case ADM_DbInfVersion_ADM of

          0: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to ADM Version v1.00');

          ADM_CreateTable_DBINFO(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_ADM);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        100: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to ADM Version v1.01');

          ADM_CreateTable_USERS(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_ADM);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        101: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to ADM Version v1.02');

          ADM_CreateTable_TABLES(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_ADM);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

        102: begin

          if Assigned(frmPrs) then frmPrs.AddStepHeader('Updating to ADM Version v1.03');

          ADM_AlterTable_DBINFO_AddProductVersion(oProvider, frmPrs);

          if Assigned(frmPrs) then frmPrs.SetProgressPos(ADM_DbInfVersion_ADM);
          if Assigned(frmPrs) then Application.ProcessMessages;

        end;

      end;

      if ADM_DbInfVersion_ADM < ciDB_VERSION_ADM then
      begin
        Exit; // There are more Database Updates pending...
      end;

    end;
  end;
  }

  // ATTN: Have to be called each time!!!
  ADM_UpdateOrInsert_LoginUser(nil {nil = DO Transaction} );

  Result := True; // Indicates that Database is Up-To-Date!!!
end;

procedure TDtTstDbItemMgr.META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string);
begin

  inherited META_AfterDrop(oProvider, sTable);

  // Sample Code...
  {
  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_USERS) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_ADM(nil {nil = DO Transaction, 100);

  end
  else if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_TABLES) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_ADM_TABLES, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_ADM(nil {nil = DO Transaction, 101);

  end;
  }

end;

end.
