unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstConsts, uDtTstAppDb,
  { ATTN: for DBExpress: } midaslib,
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids, SimpleDS, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Tabs;

type
  TFrmMain = class(TForm)
    con_Firebird_ANSI: TSQLConnection;
    qry_Top: TSQLQuery;
    db_grid_Top: TDBGrid;
    lblTop: TLabel;
    dsp_Top: TDataSetProvider;
    cds_Top: TClientDataSet;
    ds_cds_Top: TDataSource;
    sds_Bottom: TSimpleDataSet;
    ds_sds_Bottom: TDataSource;
    db_grid_Bottom: TDBGrid;
    lblBottom: TLabel;
    btnGetMetadata: TButton;
    lbResult: TListBox;
    btnRefreshBottom: TButton;
    btnRefreshTop: TButton;
    btnInsertBottom: TButton;
    btnInsertTop: TButton;
    btnDeleteBottom: TButton;
    btnDeleteTop: TButton;
    chbMetadataTablesOnly: TCheckBox;
    btnDrpTbl: TButton;
    con_Firebird_UTF8: TSQLConnection;
    btnDrpCol: TButton;
    btnImpTbl: TButton;
    panDbInfo: TPanel;
    lblCaption: TLabel;
    panLeft: TPanel;
    panAdminMode: TPanel;
    chbAutoLogin: TCheckBox;
    tsViews: TTabSet;
    procedure sds_BottomAfterPost(DataSet: TDataSet);
    procedure cds_TopAfterPost(DataSet: TDataSet);
    procedure btnGetMetadataClick(Sender: TObject);
    procedure lbResultDblClick(Sender: TObject);
    procedure btnRefreshTopClick(Sender: TObject);
    procedure btnRefreshBottomClick(Sender: TObject);
    procedure btnInsertTopClick(Sender: TObject);
    procedure btnInsertBottomClick(Sender: TObject);
    procedure btnDeleteTopClick(Sender: TObject);
    procedure btnDeleteBottomClick(Sender: TObject);
    procedure chbMetadataTablesOnlyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDrpTblClick(Sender: TObject);
    procedure btnDrpColClick(Sender: TObject);
    procedure btnImpTblClick(Sender: TObject);
    procedure chbAutoLoginClick(Sender: TObject);
    procedure tsViewsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
  private
    { Private declarations }
    con_Firebird: TSQLConnection;
    m_oApp: TDtTstAppDb;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    function GetSelectedMetaItem(var rsItem: string; var rsType: string) : Boolean;

    procedure OpenSql(sTable, sSql: string);

    procedure DoDbConnect();
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstUtils, uDtTstWin, uDtTstFirebird, uDtTstDb, uDtTstDbItemMgr,
  { DtTst Forms: } uFrmProgress, uFrmDataImport, uFrmFDB,
  System.IOUtils, StrUtils;

constructor TFrmMain.Create(AOwner: TComponent);
begin

  // NOTE: ShowMessage Title setting...
  Application.Title := csCOMPANY + ' ' + csPRODUCT_TITLE + ' ' + csVERSION_TITLE;

  con_Firebird := nil;

  m_oApp := TDtTstAppDb.Create(TPath.ChangeExtension(Application.ExeName, csLOG_UTF8_EXT), //csLOG_EXT),
                             TPath.ChangeExtension(Application.ExeName, csINI_EXT));

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  //m_oApp.LOG.m_lbLogView := lbLog;

  m_oApp.LOG.LogLIFE('TFrmMain.Create');

  try

    m_oApp.SetDb(TDtTstDb.Create(m_oApp.LOG, TPath.ChangeExtension(Application.ExeName, csINI_EXT)));

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

destructor TFrmMain.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmMain.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  inherited Destroy();

  FreeAndNil(m_oApp);
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.FormShow BEGIN');

  // NOTE: FormShow is called just before Form becomes visible BUT during construction!!!

  self      .Caption := Application.Title;
  lblCaption.Caption := Application.Title;

  // First LogINFO...
  m_oApp.LOG.LogVERSION('App Path: '  + Application.ExeName);
  m_oApp.LOG.LogVERSION('App Title: ' + Application.Title);
  m_oApp.LOG.LogVERSION('App Info: PRD = ' + csPRODUCT + ', VER = ' + IntToStr(ciVERSION));
  m_oApp.LOG.LogVERSION('App.DB Info: ADM_VER = ' + IntToStr(ciDB_VERSION_ADM) +
                      ', PRD = ' + csPRODUCT + ', PRD.VER = ' + IntToStr(ciDB_VERSION_PRD) );

  if not Assigned(m_oApp.DB) then
  begin
    Close();
    Exit();
  end;

  panAdminMode.Visible := m_oApp.ADMIN_MODE;
  panDbInfo   .Visible := m_oApp.ADMIN_MODE;

  // Registry...
  chbAutoLogin         .Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin'   , False);
  chbMetadataTablesOnly.Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'MetaTablesOnly', False);

  DoDbConnect();

  m_oApp.LOG.LogUI('TFrmMain.FormShow END');
end;

procedure TFrmMain.btnDrpColClick(Sender: TObject);
var
  sItem, sType, sTblCol, sTbl, sCol: string;
  i: integer;
begin
  m_oApp.LOG.LogUI('TFrmMain.btnDropCol BEGIN');

  if GetSelectedMetaItem({var} sItem, {var} sType) then
  begin
    if sType = 'Columns' then
    begin
      sTblCol := sItem;
    end
    else
    begin
      WarningMsgDlg('Item type "' + sType + '" is not supported by this operation!');
      Exit;
    end;
  end
  else
  begin
    Exit;
  end;

  i := Pos('.', sTblCol);
  if i < 1 then Exit;
  sTbl := sTblCol.Substring(0, i - 1);
  sCol := sTblCol.Substring(i);

  if not QuestionMsgDlg('Do you want to really DROP column "' + sCol + '" of table "' + sTbl + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.META_DropTableColumn(sTbl, sCol);

    InfoMsgDlg('You have DROPPED column "' + sCol + '" of table "' + sTbl + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  m_oApp.LOG.LogUI('TFrmMain.btnDropCol END');
end;

procedure TFrmMain.btnDrpTblClick(Sender: TObject);
var
  sItem, sType, sTable: string;
begin
  m_oApp.LOG.LogUI('TFrmMain.btnDrpTblClick BEGIN');

  if GetSelectedMetaItem({var} sItem, {var} sType) then
  begin
    if sType = 'TABLE' then
    begin
      sTable := sItem;
    end
    else
    begin
      WarningMsgDlg('Item type "' + sType + '" is not supported by this operation!');
      Exit;
    end;
  end
  else
  begin
    Exit;
  end;

  if not QuestionMsgDlg('Do you want to really DROP table "' + sTable + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.META_DropTable(sTable);

    InfoMsgDlg('You have DROPPED table "' + sTable + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  m_oApp.LOG.LogUI('TFrmMain.btnDrpTblClick END');
end;

procedure TFrmMain.btnImpTblClick(Sender: TObject);
var
  sItem, sType, sTable: string;
  asCols: TStringList;
  frmImp: TFrmDataImport;
begin
  m_oApp.LOG.LogUI('TFrmMain.btnImpTblClick BEGIN');

  if GetSelectedMetaItem({var} sItem, {var} sType) then
  begin
    if sType = 'TABLE' then
    begin
      sTable := sItem;
    end
    else
    begin
      WarningMsgDlg('Item type "' + sType + '" is not supported by this operation!');
      Exit;
    end;
  end
  else
  begin
    Exit;
  end;

  asCols := TStringList.Create();
  frmImp := TFrmDataImport.Create(self, m_oApp);
  try

    con_Firebird.GetFieldNames(sTable, asCols);

    frmImp.Init(sTable, asCols);

    FreeAndNil(asCols);

    frmImp.ShowModal();

  finally
    FreeAndNil(asCols);
    FreeAndNil(frmImp);
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnImpTblClick END');
end;

procedure TFrmMain.cds_TopAfterPost(DataSet: TDataSet);
begin
  m_oApp.LOG.LogUI('TFrmMain.cds_TopAfterPost BEGIN');

  cds_Top.ApplyUpdates(0);

  m_oApp.LOG.LogUI('TFrmMain.cds_TopAfterPost END');
end;

procedure TFrmMain.sds_BottomAfterPost(DataSet: TDataSet);
begin
  m_oApp.LOG.LogUI('TFrmMain.sds_BottomAfterPost BEGIN');

  sds_Bottom.ApplyUpdates(0);

  m_oApp.LOG.LogUI('TFrmMain.sds_BottomAfterPost END');
end;

procedure TFrmMain.tsViewsChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin

  //if not m_oApp.ADMIN_MODE then Exit;

  // TODO...

end;

procedure TFrmMain.btnDeleteTopClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnDeleteTopClick BEGIN');

  if not cds_Top.Active then exit;

  try
    cds_Top.Delete();
    cds_Top.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnDeleteTopClick END');
end;

procedure TFrmMain.btnDeleteBottomClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnDeleteBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Delete();
    sds_Bottom.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnDeleteBottomClick END');
end;

procedure TFrmMain.btnInsertTopClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnInsertTopClick BEGIN');

  if not cds_Top.Active then exit;

  try
    cds_Top.Insert();
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnInsertTopClick END');
end;

procedure TFrmMain.btnInsertBottomClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnInsertBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Insert();
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnInsertBottomClick END');
end;

procedure TFrmMain.btnRefreshTopClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnRefreshTopClick BEGIN');

  if not cds_Top.Active then exit;

  try

    cds_Top.Active := False;
    qry_Top.Active := False;

    qry_Top.Active := True;
    m_oApp.LOG.LogINFO('SQL Query is Active!');

    cds_Top.Active := True;
    m_oApp.LOG.LogINFO('Client DataSet is Active!');

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnRefreshTopClick END');
end;

procedure TFrmMain.btnRefreshBottomClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnRefreshBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try

    sds_Bottom.Active := False;

    sds_Bottom.Active := True;
    m_oApp.LOG.LogINFO('Simple DataSet is Active!');

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnRefreshBottomClick END');
end;

function TFrmMain.GetSelectedMetaItem(var rsItem: string; var rsType: string) : Boolean;
var
  i: integer;
  sItem: string;
begin
  Result := False;
  rsItem := '';
  rsType := '';

  if lbResult.ItemIndex < 0 then
  begin
    WarningMsgDlg('No item is selected!');
    exit;
  end;

  if lbResult.Items[lbResult.ItemIndex].IsEmpty() then
  begin
    WarningMsgDlg('No item is selected!');
    exit;
  end;

  if Pos('DUAL ', lbResult.Items[lbResult.ItemIndex]) = 1 then
  begin
    rsItem := lbResult.Items[lbResult.ItemIndex];
    rsType := 'DUAL';
    Result := True;
    Exit;
  end;

  if (lbResult.Items[lbResult.ItemIndex][1] <> ' ') and
     (lbResult.Items[lbResult.ItemIndex][1] <> '[') then
  begin
    if ContainsText(lbResult.Items[lbResult.ItemIndex].ToUpper(), 'SELECT ') then
    begin
      rsItem := lbResult.Items[lbResult.ItemIndex];
      rsType := 'SQL';
      Result := True;
      Exit;
    end
    else
    begin
      rsItem := lbResult.Items[lbResult.ItemIndex];
      rsType := 'TABLE';
      Result := True;
      Exit;
    end;
  end;

  sItem := TRIM(lbResult.Items[lbResult.ItemIndex]);

  if (not sItem.IsEmpty()) and (sItem[1] = '[') then
  begin
    WarningMsgDlg('Header item is selected!');
    Exit;
  end;

  rsItem := TRIM(lbResult.Items[lbResult.ItemIndex]);

  for i := lbResult.ItemIndex - 1 downto 0 do
  begin

    sItem := TRIM(lbResult.Items[i]);

    if (not sItem.IsEmpty()) and (sItem[1] = '[') then
    begin
      rsType := sItem.Substring(1, sItem.Length - 2);
      Result := True;
      Exit;
    end;

  end;

end;

procedure TFrmMain.lbResultDblClick(Sender: TObject);
var
  sItem, sType, sTable, sSql: string;
begin
  m_oApp.LOG.LogUI('TFrmMain.lbResultDblClick BEGIN');

  if GetSelectedMetaItem({var} sItem, {var} sType) then
  begin
    if sType = 'DUAL' then
    begin
      sTable := sItem;
      sSql   := 'select current_timestamp from RDB$DATABASE;'
    end
    else if sType = 'TABLE' then
    begin
      sTable := sItem;
      sSql   := 'select * from ' + sItem;
    end
    else if sType = 'SQL' then
    begin
      sTable := sItem;
      sSql   := sItem;
    end
    else
    begin
      WarningMsgDlg('Item type "' + sType + '" is not supported by this operation!');
      Exit;
    end;
  end
  else
  begin
    WarningMsgDlg('No table is selected!');

    sTable := 'N/A';
    sSql   := 'select current_timestamp from RDB$DATABASE;'
  end;

  OpenSql(sTable, sSql);

  m_oApp.LOG.LogUI('TFrmMain.lbResultDblClick END');
end;

procedure TFrmMain.OpenSql(sTable, sSql: string);
begin
  try
    lblTop.Caption := 'N/A (Query, Provider and Client DataSet):';
    cds_Top.Active := False;
    qry_Top.Active := False;
    qry_Top.SQL.Clear();

    if not sSQL.IsEmpty() then
    begin
      qry_Top.SQL.Add(m_oApp.LOG.LogSQL(sSQL));
      qry_Top.Active := True;
      m_oApp.LOG.LogINFO('SQL Query is Active!');
      cds_Top.Active := True;
      m_oApp.LOG.LogINFO('Client DataSet is Active!');
      lblTop.Caption := sTable + ' (Query, Provider and Client DataSet):';
    end;
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  try
    lblBottom.Caption := 'N/A (Simple DataSet):';
    sds_Bottom.Active := False;
    sds_Bottom.DataSet.CommandText := '';

    if not sSQL.IsEmpty() then
    begin
      sds_Bottom.DataSet.CommandText := m_oApp.LOG.LogSQL(sSQL);
      sds_Bottom.Active := True;
      m_oApp.LOG.LogINFO('Simple DataSet is Active!');
      lblBottom.Caption := sTable + ' (Simple DataSet):';
    end;
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.chbAutoLoginClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.chbAutoConnectClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin', chbAutoLogin.Checked);

  m_oApp.LOG.LogUI('TFrmMain.chbAutoConnectClick END');
end;

procedure TFrmMain.chbMetadataTablesOnlyClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.chbMetadataTablesOnlyClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'MetaTablesOnly', chbMetadataTablesOnly.Checked);

  if btnGetMetadata.Enabled then btnGetMetadata.Click();

  m_oApp.LOG.LogUI('TFrmMain.chbMetadataTablesOnlyClick END');
end;

procedure TFrmMain.btnGetMetadataClick(Sender: TObject);
var
  iIdx: integer;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin
  m_oApp.LOG.LogUI('TFrmMain.btnGetMetadataClick BEGIN');

  lbResult.Items.Clear();

  con_Firebird.GetTableNames(lbResult.Items, False);

  if not chbMetadataTablesOnly.Checked then
  begin

    iIdx := -1;
    while True do
    begin
      iIdx := iIdx + 1;

      if iIdx >= lbResult.Items.Count then
      begin
        break;
      end;

      sTable := lbResult.Items[iIdx];

      // Table Fields
      asItems := TStringList.Create();
      try

        con_Firebird.GetFieldNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '  [Columns]');

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + sTable + '.' + sItem);
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      // Table Indices
      asItems := TStringList.Create();
      try

        con_Firebird.GetIndexNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '  [Indices]');

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + sItem);
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      // Table Triggers
      asItems := TStringList.Create();
      try

        m_oApp.DB.Select_Triggers(asItems, sTable {sTable}, True {bDetails}, '' {sTriggerName});

        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '  [Triggers]');

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + sItem);
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbResult.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

    end;

    lbResult.Items.Insert(0, '[Properties]');

    lbResult.Items.Insert(1, '  Login Username: ' + con_Firebird.GetLoginUsername());

    lbResult.Items.Insert(2, '  Default SchemaName: ' + con_Firebird.GetDefaultSchemaName());

    lbResult.Items.Insert(3, '  Driver Func: ' + con_Firebird.GetDriverFunc);

    lbResult.Items.Insert(4, '  Server Charset: ' + con_Firebird.Params.Values['ServerCharset'] + ' // NOTE: Requested by client!');

    iIdx := 4;

    iIdx := iIdx + 1;
    lbResult.Items.Insert(iIdx, '[Generators]');
    asItems := TStringList.Create();
    try

      m_oApp.DB.Select_Generators(asItems);

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '  ' + sItem);
      end;
    finally
      FreeAndNil(asItems);
    end;

    iIdx := iIdx + 1;
    lbResult.Items.Insert(iIdx, '[Tables]');

    iIdx := iIdx + 1;
    lbResult.Items.Insert(iIdx, 'DUAL (in firebird RDB$DATABASE)');

    lbResult.Items.Add('[Queries]');
  end;

  lbResult.Items.Add('SELECT ' + csDB_FLD_USR_ITEMTYPE_NAME +
                     ' FROM ' + csDB_TBL_USR_ITEMTYPE +
                     ' ORDER BY ' + csDB_FLD_USR_ITEMTYPE_NAME);

  m_oApp.LOG.LogUI('TFrmMain.btnGetMetadataClick END');
end;

procedure TFrmMain.DoDbConnect();
var
  frmFdb: TFrmFDB;
  sSqlOpenSelect, sDbInfo: string;
begin
  m_oApp.LOG.LogUI('TFrmMain.btnConnectClick BEGIN');

  sSqlOpenSelect := '';

  frmFdb := TFrmFDB.Create(self, m_oApp);
  try

    if frmFdb.ShowModal(con_Firebird_ANSI, con_Firebird_UTF8) <> mrOk then
    begin
      Close();
      Exit;
    end;

    sSqlOpenSelect := frmFdb.SQL_OpenSelect;

    con_Firebird := frmFdb.CON;

    panDbInfo.Caption := frmFdb.GetDbInfo();

  finally
    FreeAndNil(frmFdb);
  end;

  try

    // ATTN: Required!!!
    qry_Top.SQLConnection := con_Firebird;
    sds_Bottom.Connection := con_Firebird;

    m_oApp.LOG.LogINFO('SQL Connection is Connected!');

    // ATTN: No Query loaded at startup!!!
    {
    qry_Top.Active := True;

    m_oLog.LogINFO('SQL Query is Active!');

    cds_Top.Active := True;

    m_oLog.LogINFO('Client DataSet is Active!');

    sds_Bottom.Active := True;

    m_oLog.LogINFO('Simple DataSet is Active!');
    }

    btnGetMetadata .Enabled := True;
    btnDrpTbl      .Enabled := True;
    btnDrpCol      .Enabled := True;

    btnGetMetadata.Click();

    if not sSqlOpenSelect.IsEmpty() then
    begin
      OpenSql('SQL Editor', sSqlOpenSelect);
    end;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmMain.btnConnectClick END');
end;

end.
