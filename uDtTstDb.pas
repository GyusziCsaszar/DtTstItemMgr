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
    m_sIsqlPathPRI, m_sIsqlPathSEC: string;
    m_iIsqlOptions: integer;
    m_bUTF8: Boolean;
    m_asConnectStrings: TStringList;
    m_sConnectString: string;
    m_sConnectUser: string;
    m_sConnectPassword: string;
    m_oCon: TSQLConnection;
    m_iADM_DbInfVersion_ADM: integer;
    m_sADM_DbInfProduct: string;
    m_iADM_UserID: integer;
    m_iADM_DbInfVersion_PRD: integer;
    { ATTN: Copy ABOVE members in descendants!!! }
  public
    constructor Create(oLog: TDtTstLog; sIniPath: string);
    destructor Destroy(); override;

    function GetIsqlPathChecked() : string;
    property IsqlPathChecked: string read GetIsqlPathChecked;
    function GetIsqlPathPRI() : string;
    property IsqlPathPRI: string read GetIsqlPathPRI;
    function GetIsqlPathSEC() : string;
    property IsqlPathSEC: string read GetIsqlPathSEC;

    function GetIsqlOptions() : integer;
    property IsqlOptions: integer read getIsqlOptions;

    function GetUTF8() : Boolean;
    property UTF8: Boolean read GetUTF8;
    procedure GetConnectStrings(cbb: TComboBox; asConnectStrings: TStringList);
    function GetConnectString() : string;
    procedure SetConnectString(sValue: string);
    property ConnectString: string read GetConnectString write SetConnectString;
    function GetConnectUser() : string;
    procedure SetConnectUser(sValue: string);
    property ConnectUser: string read GetConnectUser write SetConnectUser;
    function GetConnectPassword() : string;
    procedure SetConnectPassword(sValue: string);
    property ConnectPassword: string read GetConnectPassword write SetConnectPassword;

    function GetConnected(): Boolean;
    property Connected: Boolean read GetConnected;

    procedure Connect(oCon: TSQLConnection);
    procedure AfterConnect(); virtual;

    function GetSQLConnection() : TSQLConnection;
    property SQLConnection: TSQLConnection read GetSQLConnection;

    function GetLoginUser() : string;
    property LoginUser: string read GetLoginUser;

    function ADM_GetDbInfVersion_PRD() : integer;
    property ADM_DbInfVersion_PRD: integer read ADM_GetDbInfVersion_PRD;
    function ADM_GetUserID() : integer;
    property ADM_UserID: integer read ADM_GetUserID;
    function ADM_GetDbInfVersion_ADM() : integer;
    property ADM_DbInfVersion_ADM: integer read ADM_GetDbInfVersion_ADM;
    function ADM_GetDbInfProduct() : string;
    property ADM_DbInfProduct: string read ADM_GetDbInfProduct;

    function TableExists(sTable: string) : Boolean;
    function GetTableCount() : integer;

    function FIXOBJNAME(sTable: string) : string;

    procedure Select_Generators(asResult: TStringList);
    function Select_Triggers(asResult: TStringList; sTable: string; bDetails: Boolean; sTriggerName: string) : Boolean;

    procedure ExecuteSQL(oCon: TSQLConnection {nil = DO Transaction}; sSql: string);

    procedure ADM_DoDbUpdates(frmPrs: TFrmProgress);
    function ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress) : Boolean; virtual;

    procedure ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
    procedure ADM_Insert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});

    procedure ADM_CreateTable_TABLES(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
    procedure ADM_CreateTable_USERS(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);

    procedure ADM_UpdateOrInsert_NewTable(oCon: TSQLConnection {nil = DO Transaction}; sTable: string);

    procedure ADM_Increment_DBINFO_VER_PRD(oCon: TSQLConnection {nil = DO Transaction});
    procedure ADM_Update_DBINFO_VER_PRD(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);

    procedure ADM_Increment_DBINFO_VER_ADM(oCon: TSQLConnection {nil = DO Transaction});
    procedure ADM_Update_DBINFO_VER_ADM(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);

    procedure ADM_AlterTable_DBINFO_AddProductVersion(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
    procedure ADM_CreateTable_DBINFO(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);

    procedure META_AddColumn_TimeStamp(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
    procedure META_AddColumn_INT32(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean);
    procedure META_AddColumn_VARCHAR(oTable: TDBXMetaDataTable; sColumnName: string; bNullable: Boolean; iLen: integer);

    procedure META_DropGenerator(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);
    procedure META_CreateGenerator(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);

    procedure META_CreateIndex_PrimaryKey(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);

    procedure META_DropTableColumn(sTableName, sColumnName: string);

    procedure META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable : string); virtual;
    procedure META_DropTable(sTable: string);

    procedure META_CreateTable_SAMPLE(const AConnection: TDBXConnection);

  protected
    function META_GetProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstFirebird,
  SysUtils, StrUtils, IniFiles, Vcl.Forms;

constructor TDtTstDb.Create(oLog: TDtTstLog; sIniPath: string);
var
  fIni: TIniFile;
  iDbCnt, iDbDef, iDb, iVal: Integer;
  sDb: string;
begin
  m_oLog := oLog;

  { ATTN: Copy BELOW members in descendants!!! }
  m_sIsqlPathPRI            := '';
  m_sIsqlPathSEC            := '';
  m_iIsqlOptions            := -1;
  m_bUTF8                   := False;
  m_asConnectStrings        := TStringList.Create();
  m_sConnectString          := '';
  m_sConnectUser            := '';
  m_sConnectPassword        := '';
  m_oCon                    := nil;
  m_iADM_DbInfVersion_ADM   := 0;
  m_sADM_DbInfProduct       := '';
  m_iADM_UserID             := 0;
  m_iADM_DbInfVersion_PRD   := 0;
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

        m_sIsqlPathPRI := fIni.ReadString( csINI_SEC_DB, csINI_VAL_DB_ISQLPATH,     '');
        m_sIsqlPathSEC := fIni.ReadString( csINI_SEC_DB, csINI_VAL_DB_ISQLPATH_ALT, '');
        m_iIsqlOptions := fIni.ReadInteger(csINI_SEC_DB, csINI_VAL_DB_ISQLOPTS,     -1);

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

function TDtTstDb.GetIsqlPathChecked() : string;
begin
  Result := '';

  if not m_sIsqlPathPRI.IsEmpty() then
  begin
    if not TPath.IsRelativePath(m_sIsqlPathPRI) then
    begin
      if FileExists(m_sIsqlPathPRI) then
      begin
        Result := m_sIsqlPathPRI;
        Exit;
      end;
    end
    else
    begin
      Result := m_sIsqlPathPRI;
      Exit;
    end;
  end;

  if not m_sIsqlPathSEC.IsEmpty() then
  begin
    if not TPath.IsRelativePath(m_sIsqlPathSEC) then
    begin
      if FileExists(m_sIsqlPathSEC) then
      begin
        Result := m_sIsqlPathSEC;
        Exit;
      end;
    end
    else
    begin
      Result := m_sIsqlPathSEC;
      Exit;
    end;
  end;

  if Result.IsEmpty() then
  begin
    raise Exception.Create('ERROR: No Firebird Isql tool Path specified!');
  end;

end;

function TDtTstDb.GetIsqlPathPRI() : string;
begin
  Result := m_sIsqlPathPRI;
end;

function TDtTstDb.GetIsqlPathSEC() : string;
begin
  Result := m_sIsqlPathSEC;
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

procedure TDtTstDb.SetConnectUser(sValue: string);
begin
  m_sConnectUser := sValue;
end;

function TDtTstDb.GetConnectPassword() : string;
begin
  Result := m_sConnectPassword;
end;

procedure TDtTstDb.SetConnectPassword(sValue: string);
begin
  m_sConnectPassword := sValue;
end;

function TDtTstDb.GetConnected(): Boolean;
begin
  Result := False;

  if Assigned(m_oCon) then
  begin
    Result := m_oCon.Connected;
  end;
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
                    '( Version = ' + IntToStr(ADM_DbInfVersion_ADM) +
                    ', Product = "' + ADM_DbInfProduct + '" )' + '")' );

end;

procedure TDtTstDb.AfterConnect();
var
  oQry: TSQLQuery;
begin

  m_iADM_DbInfVersion_ADM := -1;
  m_sADM_DbInfProduct     := '';

  if TableExists(csDB_TBL_ADM_DBINF) then
  begin

    oQry := TSQLQuery.Create(nil);
    try

      oQry.SQLConnection := m_oCon;

      oQry.SQL.Text := m_oLog.LogSQL('SELECT * FROM ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                                     ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = 1;');
      oQry.Open();

      if not oQry.IsEmpty() then
      begin
        m_iADM_DbInfVersion_ADM := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_VER    )).AsInteger;
        m_sADM_DbInfProduct     := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD    )).AsString;

        if ADM_DbInfVersion_ADM > 102 then
        begin
          m_iADM_DbInfVersion_PRD := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD_VER)).AsInteger;
        end
        else
        begin
          m_iADM_DbInfVersion_PRD := 0;
        end;

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

function TDtTstDb.ADM_GetDbInfVersion_PRD() : integer;
begin
  Result := m_iADM_DbInfVersion_PRD;
end;

function TDtTstDb.ADM_GetUserID() : integer;
begin
  Result := m_iADM_UserID;
end;

function TDtTstDb.ADM_GetDbInfVersion_ADM() : integer;
begin
  Result := m_iADM_DbInfVersion_ADM;
end;

function TDtTstDb.ADM_GetDbInfProduct() : string;
begin
  Result := m_sADM_DbInfProduct;
end;

function TDtTstDb.TableExists(sTable: string) : Boolean;
var
  asNA: TStringList;
begin

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

procedure TDtTstDb.Select_Generators(asResult: TStringList);
var
  sSql: string;
  oQry: TSQLQuery;
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

function TDtTstDb.Select_Triggers(asResult: TStringList; sTable: string; bDetails: Boolean; sTriggerName: string) : Boolean;
var
  sSql: string;
  oQry: TSQLQuery;
  sTriggerInfo: string;
begin
  Result := False;

  if Assigned(asResult) then asResult.Clear();

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // SRC: https://stackoverflow.com/questions/26578880/how-to-print-firebird-triggers
    sSql := 'SELECT RDB$TRIGGER_NAME AS trigger_name';

    if sTable.IsEmpty() then //and bDetails then
    begin
      sSql := sSql + ', ';
      sSql := sSql + ' RDB$RELATION_NAME AS table_name';
    end;

    {
            ' RDB$TRIGGER_SOURCE AS trigger_body,' +
    }

    if bDetails then
    begin
      sSql := sSql + ', ';
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

    if not sTriggerName.IsEmpty() then
    begin
      if sTable.IsEmpty() then
        sSql := sSql + ' WHERE'
      else
        sSql := sSql + ' AND';

      sSql := sSql + ' RDB$TRIGGER_NAME = ' + '''' + FIXOBJNAME(sTriggerName) + '''';

    end;

    oQry.SQLConnection := m_oCon;

    oQry.SQL.Add(m_oLog.LogSQL(sSql));

    try

      oQry.Open();

      while not oQry.Eof do
      begin

        if Assigned(asResult) then
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
        end;

        Result := True;

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

procedure TDtTstDb.ExecuteSQL(oCon: TSQLConnection {nil = DO Transaction}; sSql: string);
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
    oQry.SQL.Add(m_oLog.LogSQL(sSql));

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

procedure TDtTstDb.ADM_DoDbUpdates(frmPrs: TFrmProgress);
var
  oProvider: TDBXDataExpressMetaDataProvider;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    while True do
    begin

        if ADM_DoDbUpdates_internal(oProvider, frmPrs) then
        begin
          Break; // Database is Up-To-Date!!!
        end;

    end;

  finally
    FreeAndNil(oProvider);
  end;

end;

function TDtTstDb.ADM_DoDbUpdates_internal(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress) : Boolean;
begin
  Result := False; // Indicated that there are more Database Updates pending...

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

      if Assigned(frmPrs) and (ADM_DbInfVersion_ADM < 101) then
      begin
        frmPrs.SetProgressMinMax(ADM_DbInfVersion_ADM, ciDB_VERSION_ADM);
      end;

      case ADM_DbInfVersion_ADM of

         -1,
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

        else begin

          raise Exception.Create('Current Database ADM Version (' + IntToStr(ADM_DbInfVersion_ADM) +
                 ') is UNKNOWN!');

        end;

      end;

      if ADM_DbInfVersion_ADM < ciDB_VERSION_ADM then
      begin
        Exit; // There are more Database Updates pending...
      end;

    end;
  end;

  Result := True; // Indicates that Database is Up-To-Date!!!
end;

procedure TDtTstDb.META_AfterDrop(oProvider: TDBXDataExpressMetaDataProvider; sTable: string);
begin

  if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_USERS) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_ADM(nil {nil = DO Transaction}, 100);

  end
  else if FIXOBJNAME(sTable) = FIXOBJNAME(csDB_TBL_ADM_TABLES) then
  begin

    // ATTN: Deleting Table also deletes its Triggers!!!
    // oProvider.Execute(m_oLog.LogSQL('DROP TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + '_BI'));

    META_DropGenerator(oProvider, csDB_TBL_ADM_TABLES, csDB_FLD_ADM_X_ID);

    // NOTE: admUsers table added in v101!
    ADM_Update_DBINFO_VER_ADM(nil {nil = DO Transaction}, 101);

  end;

end;

procedure TDtTstDb.ADM_UpdateOrInsert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
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
                 ' RETURNING ' + FIXOBJNAME(csDB_FLD_ADM_X_ID);

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

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_X_ID)).AsInteger;

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

procedure TDtTstDb.ADM_Insert_LoginUser(oCon: TSQLConnection {nil = DO Transaction});
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

procedure TDtTstDb.ADM_CreateTable_TABLES(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
  sOutput: string;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_ADM_TABLES);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_TABLES);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE       , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID           , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_TABLES_NAME    , False {bNullable}, 31);

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Generator }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_ADM_TABLES +  '_' + csDB_FLD_ADM_X_ID);
    if Assigned(frmPrs) then Application.ProcessMessages;

    META_CreateGenerator(oProvider, csDB_TBL_ADM_TABLES, csDB_FLD_ADM_X_ID);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Trigger }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating trigger ' + csDB_TBL_ADM_TABLES + '_BI');
    if Assigned(frmPrs) then Application.ProcessMessages;

    sOutput := ISQL_Execute(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                            IsqlPathChecked,
                            ConnectString,
                            ConnectUser, ConnectPassword,
                            True {bGetOutput},
                            (IsqlOptions = 1) {bVisible},
                            'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) + CHR(13) + CHR(10) +
                                        ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                                        ' POSITION 0' + CHR(13) + CHR(10) +
                                        ' AS' + CHR(13) + CHR(10) +
                                        ' BEGIN' + CHR(13) + CHR(10) +
                                        ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                                        FIXOBJNAME(csDB_TBL_ADM_TABLES) +
                                        '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                                        ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
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

  if Assigned(frmPrs) then frmPrs.AddStep('Creating index ' + csDB_TBL_ADM_TABLES + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_ADM_TABLES, csDB_FLD_ADM_X_ID);

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
    ExecuteSQL(m_oCon {nil = DO Transaction}, 'UPDATE ' + FIXOBJNAME(csDB_TBL_ADM_TABLES) +
               ' SET ' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
               ' = (SELECT ' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' FROM ' + FIXOBJNAME(csDB_TBL_ADM_USERS) +
               ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = 1)' +
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

    ADM_Increment_DBINFO_VER_ADM(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    m_oCon.Commit(oTD);

  except
    m_oCon.Rollback(oTD);
  end;

end;

procedure TDtTstDb.ADM_CreateTable_USERS(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oTD: TTransactionDesc;
  sOutput: string;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_ADM_USERS);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_USERS);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_X_TSPCRE       , False {bNullable});

    META_AddColumn_INT32(     oTable, csDB_FLD_ADM_X_ID           , False {bNullable});

    META_AddColumn_VARCHAR(   oTable, csDB_FLD_ADM_USERS_USER     , False {bNullable}, 31);

    META_AddColumn_TimeStamp( oTable, csDB_FLD_ADM_USERS_LSTLOGIN , False {bNullable});

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Generator }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating generator ' + csDB_TBL_ADM_USERS +  '_' + csDB_FLD_ADM_X_ID);
    if Assigned(frmPrs) then Application.ProcessMessages;

    META_CreateGenerator(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_X_ID);

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
    sOutput := ISQL_Execute(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                            IsqlPathChecked,
                            ConnectString,
                            ConnectUser, ConnectPassword,
                            True {bGetOutput},
                            (IsqlOptions = 1) {bVisible},
                            'CREATE TRIGGER ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + '_BI FOR ' + FIXOBJNAME(csDB_TBL_ADM_USERS) + CHR(13) + CHR(10) +
                                        ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                                        ' POSITION 0' + CHR(13) + CHR(10) +
                                        ' AS' + CHR(13) + CHR(10) +
                                        ' BEGIN' + CHR(13) + CHR(10) +
                                        ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = GEN_ID(' +
                                        FIXOBJNAME(csDB_TBL_ADM_USERS) +
                                        '_' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ', 1);' + CHR(13) + CHR(10) +
                                        ' IF (NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) +
                                        ' IS NULL) THEN NEW.' + FIXOBJNAME(csDB_FLD_ADM_X_TSPCRE) + ' = current_timestamp;' + CHR(13) + CHR(10) +
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

  if Assigned(frmPrs) then frmPrs.AddStep('Creating index ' + csDB_TBL_ADM_USERS + '_' + csDB_FLD_ADM_X_ID);
  if Assigned(frmPrs) then Application.ProcessMessages;

  META_CreateIndex_PrimaryKey(oProvider, csDB_TBL_ADM_USERS, csDB_FLD_ADM_X_ID);

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

    ADM_Increment_DBINFO_VER_ADM(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    m_oCon.Commit(oTD);

  except
    m_oCon.Rollback(oTD);
  end;

end;

procedure TDtTstDb.ADM_UpdateOrInsert_NewTable(oCon: TSQLConnection {nil = DO Transaction}; sTable: string);
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

procedure TDtTstDb.ADM_Increment_DBINFO_VER_PRD(oCon: TSQLConnection {nil = DO Transaction});
begin
  ADM_Update_DBINFO_VER_PRD( oCon {nil = DO Transaction}, m_iADM_DbInfVersion_PRD + 1);
  m_iADM_DbInfVersion_PRD := m_iADM_DbInfVersion_PRD + 1;
end;

procedure TDtTstDb.ADM_Update_DBINFO_VER_PRD(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);
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
                 ' SET ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD_VER) +
                 ' = :PRDVER' +
                 ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = 1' ));

    oQry.Params.ParamByName('PRDVER').AsInteger  := iVersion;

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

procedure TDtTstDb.ADM_Increment_DBINFO_VER_ADM(oCon: TSQLConnection {nil = DO Transaction});
begin
  ADM_Update_DBINFO_VER_ADM( oCon {nil = DO Transaction}, m_iADM_DbInfVersion_ADM + 1);
  m_iADM_DbInfVersion_ADM := m_iADM_DbInfVersion_ADM + 1;
end;

procedure TDtTstDb.ADM_Update_DBINFO_VER_ADM(oCon: TSQLConnection {nil = DO Transaction}; iVersion: integer);
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
                 ' WHERE ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = 1' ));

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

procedure TDtTstDb.ADM_AlterTable_DBINFO_AddProductVersion(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Altering table ' + csDB_TBL_ADM_TABLES + ', adding column ' + csDB_FLD_ADM_DBINF_PRD_VER);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_DBINF);

    META_AddColumn_INT32(  oTable, csDB_FLD_ADM_DBINF_PRD_VER, False {bNullable});

    oProvider.AlterTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Generator }

    // NONE...

    { Trigger }

    // NONE...

  finally
    FreeAndNil(oTable);
  end;

  { Indices }

  // NONE...

  { ROWS }

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    { Initial Product Version Value }

    oQry.SQLConnection := m_oCon;
    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL('UPDATE ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                 ' SET ' + FIXOBJNAME(csDB_FLD_ADM_DBINF_PRD_VER) +
                 ' = :PRDVER WHERE ' + FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = 1'));

    oQry.Params.ParamByName('PRDVER').AsInteger  := 100;

    //oQry.Prepared := True;

    m_oCon.StartTransaction(oTD);
    try

      oQry.ExecSQL(False);

      m_oCon.Commit(oTD);

      m_iADM_DbInfVersion_PRD := 100;

    except
      m_oCon.Rollback(oTD);
    end;

    { DB Version Increment }

    if Assigned(frmPrs) then frmPrs.AddStep('Incrementing database version number');
    if Assigned(frmPrs) then Application.ProcessMessages;

    ADM_Increment_DBINFO_VER_ADM(m_oCon {nil = DO Transaction} );

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;

end;

procedure TDtTstDb.ADM_CreateTable_DBINFO(oProvider: TDBXDataExpressMetaDataProvider; frmPrs: TFrmProgress);
var
  oTable: TDBXMetaDataTable;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  oTable := TDBXMetaDataTable.Create;
  try

    { Table }

    if Assigned(frmPrs) then frmPrs.AddStep('Creating table ' + csDB_TBL_ADM_USERS);
    if Assigned(frmPrs) then Application.ProcessMessages;

    oTable.TableName := FIXOBJNAME(csDB_TBL_ADM_DBINF);

    META_AddColumn_INT32(  oTable, csDB_FLD_ADM_X_ID      , False {bNullable});

    META_AddColumn_INT32(  oTable, csDB_FLD_ADM_DBINF_VER , False {bNullable});

    META_AddColumn_VARCHAR(oTable, csDB_FLD_ADM_DBINF_PRD , False {bNullable}, 32);

    oProvider.CreateTable(oTable);

    if Assigned(frmPrs) then frmPrs.AddStepEnd('Done!');
    if Assigned(frmPrs) then Application.ProcessMessages;

    { Generator }

    // NONE...

    { Trigger }

    // NONE...

  finally
    FreeAndNil(oTable);
  end;

  { Indices }

  // NONE...

  { ROWS }


  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    { Initial ID, DB Version and Product Values }

    oQry.SQLConnection := m_oCon;
    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oLog.LogSQL('INSERT INTO ' + FIXOBJNAME(csDB_TBL_ADM_DBINF) +
                 ' (' + FIXOBJNAME(csDB_FLD_ADM_X_ID) +
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

      m_iADM_DbInfVersion_ADM := 100;
      m_sADM_DbInfProduct     := csPRODUCT_FULL;

    except
      m_oCon.Rollback(oTD);
    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;

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

procedure TDtTstDb.META_DropGenerator(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);
begin

  oProvider.Execute(m_oLog.LogSQL('DROP GENERATOR ' + FIXOBJNAME(sTableName) +
    '_' + FIXOBJNAME(sColumnName) + ';'));

end;

procedure TDtTstDb.META_CreateGenerator(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);
begin

  oProvider.Execute(m_oLog.LogSQL('CREATE GENERATOR ' + FIXOBJNAME(sTableName) +
    '_' + FIXOBJNAME(sColumnName) + ';'));

  oProvider.Execute(m_oLog.LogSQL('SET GENERATOR ' + FIXOBJNAME(sTableName) +
    '_' + FIXOBJNAME(sColumnName) + ' TO 0;'));

end;

procedure TDtTstDb.META_CreateIndex_PrimaryKey(oProvider: TDBXDataExpressMetaDataProvider; sTableName, sColumnName: string);
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

procedure TDtTstDb.META_DropTableColumn(sTableName, sColumnName: string);
var
  oProvider: TDBXDataExpressMetaDataProvider;
begin

  oProvider := META_GetProvider(m_oCon.DBXConnection);
  try

    oProvider.Execute(m_oLog.LogSQL('ALTER TABLE ' + FIXOBJNAME(sTableName) +
      ' DROP ' + FIXOBJNAME(sColumnName) + ';'));

  finally
    FreeAndNil(oProvider);
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
