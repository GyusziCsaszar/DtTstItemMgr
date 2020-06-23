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
    lblRs: TLabel;
    dsp_Top: TDataSetProvider;
    cds_Top: TClientDataSet;
    ds_cds_Top: TDataSource;
    sds_Bottom: TSimpleDataSet;
    ds_sds_Bottom: TDataSource;
    db_grid_Bottom: TDBGrid;
    lbObjects: TListBox;
    btnRsRefresh: TButton;
    btnRsInsert: TButton;
    btnRsDelete: TButton;
    chbMetadataTablesOnly: TCheckBox;
    con_Firebird_UTF8: TSQLConnection;
    panDbInfo: TPanel;
    lblCaption: TLabel;
    panLeft: TPanel;
    panAdminMode: TPanel;
    chbAutoLogin: TCheckBox;
    tsViews: TTabSet;
    lbLog: TListBox;
    lbTasks: TListBox;
    procedure sds_BottomAfterPost(DataSet: TDataSet);
    procedure cds_TopAfterPost(DataSet: TDataSet);
    procedure lbObjectsDblClick(Sender: TObject);
    procedure btnRsRefreshClick(Sender: TObject);
    procedure btnRsInsertClick(Sender: TObject);
    procedure btnRsDeleteClick(Sender: TObject);
    procedure chbMetadataTablesOnlyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chbAutoLoginClick(Sender: TObject);
    procedure tsViewsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure lbTasksClick(Sender: TObject);
    procedure lbTasksDblClick(Sender: TObject);
    procedure lbTasksDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbTasksMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbObjectsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbObjectsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbObjectsClick(Sender: TObject);
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

    procedure DoDropColumn();
    procedure DoDropTable(cID_Object: char; sCaption_Object: string);

    procedure DoRefreshMetaData();

    procedure DoImportTable(cID_Object: char; sCaption_Object: string);

    procedure DoOpen(cID_Object: char; sCaption_Object: string);
    procedure DoTasksClick();

    procedure DoLbMeasuerItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure DoLbDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);

    function MnuGRP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuGRP(sCaption: string; iIndent: integer) : string;
    function MnuCAP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuCAP(sCaption: string; iIndent: integer) : string;
    function MnuITM_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuITM(sCaption: string; iIndent: integer) : string;
    function MnuSPC() : string;
    procedure Menu_ExtractItem(sItem: string; var rcID: char; var rsCaption: string);

    procedure Menu_AddTask_Button(cID: char; sCaption: string);
    procedure Menu_AddTask_Group(sCaption: string; iIndent: integer);
    procedure Menu_AddTask_Item(sCaption: string; iIndent: integer);

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

  m_oApp.LOG.m_lbLogView := lbLog;

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

  // ATTN: Force event handler...
  tsViews.TabIndex := 1; tsViews.TabIndex := 0;

  // Registry...
  chbAutoLogin         .Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin'   , False);
  chbMetadataTablesOnly.Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'MetaTablesOnly', False);

  DoDbConnect();

  m_oApp.LOG.LogUI('TFrmMain.FormShow END');
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

  db_grid_Top.Visible    := (NewTab = 0);

  db_grid_Bottom.Visible := (NewTab = 1);

end;

procedure TFrmMain.btnRsDeleteClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnRsDeleteClick BEGIN');

  if db_grid_Top.Visible then
  begin

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

  end
  else // if db_grid_Bottom.Visible then
  begin

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

  end;

  m_oApp.LOG.LogUI('TFrmMain.btnRsDeleteClick END');
end;

procedure TFrmMain.btnRsInsertClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnRsInsertClick BEGIN');

  if db_grid_Top.Visible then
  begin

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

  end
  else // if db_grid_Bottom.Visible then
  begin

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

  end;

  m_oApp.LOG.LogUI('TFrmMain.btnRsInsertClick END');
end;

procedure TFrmMain.btnRsRefreshClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.btnRsRefreshClick BEGIN');

  if db_grid_Top.Visible then
  begin

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

  end
  else // if db_grid_Bottom.Visible then
  begin

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

  end;

  m_oApp.LOG.LogUI('TFrmMain.btnRsRefreshClick END');
end;

function TFrmMain.GetSelectedMetaItem(var rsItem: string; var rsType: string) : Boolean;
var
  i: integer;
  sItem: string;
begin
  Result := False;
  rsItem := '';
  rsType := '';

  if lbObjects.ItemIndex < 0 then
  begin
    WarningMsgDlg('No item is selected!');
    exit;
  end;

  if lbObjects.Items[lbObjects.ItemIndex].IsEmpty() then
  begin
    WarningMsgDlg('No item is selected!');
    exit;
  end;

  if Pos('DUAL ', lbObjects.Items[lbObjects.ItemIndex]) = 1 then
  begin
    rsItem := lbObjects.Items[lbObjects.ItemIndex];
    rsType := 'DUAL';
    Result := True;
    Exit;
  end;

  if (lbObjects.Items[lbObjects.ItemIndex][1] <> ' ') and
     (lbObjects.Items[lbObjects.ItemIndex][1] <> '[') then
  begin
    if ContainsText(lbObjects.Items[lbObjects.ItemIndex].ToUpper(), 'SELECT ') then
    begin
      rsItem := lbObjects.Items[lbObjects.ItemIndex];
      rsType := 'SQL';
      Result := True;
      Exit;
    end
    else
    begin
      rsItem := lbObjects.Items[lbObjects.ItemIndex];
      rsType := 'TABLE';
      Result := True;
      Exit;
    end;
  end;

  sItem := TRIM(lbObjects.Items[lbObjects.ItemIndex]);

  if (not sItem.IsEmpty()) and (sItem[1] = '[') then
  begin
    WarningMsgDlg('Header item is selected!');
    Exit;
  end;

  rsItem := TRIM(lbObjects.Items[lbObjects.ItemIndex]);

  for i := lbObjects.ItemIndex - 1 downto 0 do
  begin

    sItem := TRIM(lbObjects.Items[i]);

    if (not sItem.IsEmpty()) and (sItem[1] = '[') then
    begin
      rsType := sItem.Substring(1, sItem.Length - 2);
      Result := True;
      Exit;
    end;

  end;

end;

procedure TFrmMain.OpenSql(sTable, sSql: string);
begin
  try
    lblRs.Caption := 'N/A';

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

      lblRs.Caption := sTable;

    end;
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  try
    sds_Bottom.Active := False;
    sds_Bottom.DataSet.CommandText := '';

    if not sSQL.IsEmpty() then
    begin

      sds_Bottom.DataSet.CommandText := m_oApp.LOG.LogSQL(sSQL);
      sds_Bottom.Active := True;
      m_oApp.LOG.LogINFO('Simple DataSet is Active!');

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

  DoRefreshMetaData();

  m_oApp.LOG.LogUI('TFrmMain.chbMetadataTablesOnlyClick END');
end;

procedure TFrmMain.DoDbConnect();
var
  frmFdb: TFrmFDB;
  iModalResult: integer;
  sSqlOpenSelect: string;
begin
  m_oApp.LOG.LogInfo('TFrmMain.DoDbConnect BEGIN');

  sSqlOpenSelect := '';

  frmFdb := TFrmFDB.Create(self, m_oApp);
  try

    m_oApp.LOG.LogUI('TFrmFDB.ShowModal CALL');
    iModalResult := frmFdb.ShowModal(con_Firebird_ANSI, con_Firebird_UTF8);
    m_oApp.LOG.LogUI('TFrmFDB.ShowModal RETU');

    if iModalResult <> mrOk then
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

    DoRefreshMetaData();

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

  m_oApp.LOG.LogInfo('TFrmMain.DoDbConnect END');
end;

procedure TFrmMain.DoDropColumn();
var
  sItem, sType, sTblCol, sTbl, sCol: string;
  i: integer;
begin

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

  DoRefreshMetaData();
end;

procedure TFrmMain.DoDropTable(cID_Object: char; sCaption_Object: string);
begin

  if not QuestionMsgDlg('Do you want to really DROP table "' + sCaption_Object + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.META_DropTable(sCaption_Object);

    InfoMsgDlg('You have DROPPED table "' + sCaption_Object + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  DoRefreshMetaData();
end;

procedure TFrmMain.DoRefreshMetaData();
var
  iIdx: integer;
  cID: char;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin

  //if m_oApp.DB.Connected then Exit;
  if (not Assigned(con_Firebird)) or (not con_Firebird.Connected) then Exit;

  lbObjects.Items.Clear();
  lbTasks.Items.Clear();

  if m_oApp.ADMIN_MODE then
  begin

    con_Firebird.GetTableNames(lbObjects.Items, False);

    for iIdx := 0 to lbObjects.Items.Count - 1 do
    begin
      lbObjects.Items[iIdx] := MnuCAP_Selectable(ccMnuItmID_Table, lbObjects.Items[iIdx], 0);
    end;
  end;

  if (not chbMetadataTablesOnly.Checked) and m_oApp.ADMIN_MODE then
  begin

    iIdx := -1;
    while True do
    begin
      iIdx := iIdx + 1;

      if iIdx >= lbObjects.Items.Count then
      begin
        break;
      end;

      Menu_ExtractItem(lbObjects.Items[iIdx], cID, sTable);

      // Table Fields
      asItems := TStringList.Create();
      try

        con_Firebird.GetFieldNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Columns', 2));

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM_Selectable(ccMnuItmID_Table_Column, sTable + '.' + sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      // Table Indices
      asItems := TStringList.Create();
      try

        con_Firebird.GetIndexNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Indices', 2));

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM(sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      // Table Triggers
      asItems := TStringList.Create();
      try

        m_oApp.DB.Select_Triggers(asItems, sTable {sTable}, True {bDetails}, '' {sTriggerName});

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Triggers', 2));

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM(sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuSPC());

    end;

    lbObjects.Items.Insert(0, MnuGRP_Selectable(ccMnuGrpID_Database, 'Database', 0));

    lbObjects.Items.Insert(1, MnuGRP('Properties', 0));

    lbObjects.Items.Insert(2, MnuITM('Login Username: ' + con_Firebird.GetLoginUsername(), 0));

    lbObjects.Items.Insert(3, MnuITM('Default SchemaName: ' + con_Firebird.GetDefaultSchemaName(), 0));

    lbObjects.Items.Insert(4, MnuITM('Driver Func: ' + con_Firebird.GetDriverFunc, 0));

    lbObjects.Items.Insert(5, MnuITM('Server Charset: ' + con_Firebird.Params.Values['ServerCharset'] + ' // NOTE: Requested by client!', 0));

    iIdx := 5;

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP('Generators', 0));
    asItems := TStringList.Create();
    try

      m_oApp.DB.Select_Generators(asItems);

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuITM(sItem, 0));
      end;
    finally
      FreeAndNil(asItems);
    end;
  end
  else
  begin
    iIdx := -1;
  end;

  if m_oApp.ADMIN_MODE then
  begin

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP('Tables', 0));

    {
    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuSPC());
    }

    lbObjects.Items.Add(MnuGRP('Queries', 0));

    lbObjects.Items.Add(MnuCAP_Selectable(ccMnuItmID_Query, '|DUAL (in firebird RDB$DATABASE)|select current_timestamp from RDB$DATABASE', 0));

  end;

  lbObjects.Items.Add(MnuGRP(csPRODUCT_TITLE, 0));

  lbObjects.Items.Add(MnuCAP_Selectable(ccMnuItmID_Query, '|ITEM TYPES|SELECT ' + csDB_FLD_USR_ITEMTYPE_NAME +
                     ' FROM ' + csDB_TBL_USR_ITEMTYPE +
                     ' ORDER BY ' + csDB_FLD_USR_ITEMTYPE_NAME, 0));

  lbObjects.Items.Add(MnuSPC());

end;

procedure TFrmMain.DoImportTable(cID_Object: char; sCaption_Object: string);
var
  asCols: TStringList;
  frmImp: TFrmDataImport;
begin

  asCols := TStringList.Create();
  frmImp := TFrmDataImport.Create(self, m_oApp);
  try

    con_Firebird.GetFieldNames(sCaption_Object, asCols);

    frmImp.Init(sCaption_Object, asCols);

    FreeAndNil(asCols);

    frmImp.ShowModal();

  finally
    FreeAndNil(asCols);
    FreeAndNil(frmImp);
  end;
end;

procedure TFrmMain.lbObjectsMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
  DoLbMeasuerItem(Control, Index, Height);
end;

procedure TFrmMain.lbTasksMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
  DoLbMeasuerItem(Control, Index, Height);
end;

procedure TFrmMain.DoLbMeasuerItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  sItem: string;
begin

  sItem := (Control as TListBox).Items[Index];
  if sItem.IsEmpty() then Exit;

  case sItem[ciMnuIdx_Ctrl] of

    ccMnuBtn,
    ccMnuGrp,
    ccMnuCap : begin

      Height := Height * 2;

    end;

  end;

  m_oApp.LOG.LogINFO('MeasureItem - Height - ' + IntToStr(Height));

end;

procedure TFrmMain.lbObjectsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoLbDrawItem(Control, Index, Rect, State);
end;

procedure TFrmMain.lbTasksDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoLbDrawItem(Control, Index, Rect, State);
end;

procedure TFrmMain.DoLbDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
// SRC: https://stackoverflow.com/questions/8563508/how-do-i-draw-the-selected-list-box-item-in-a-different-color
var
  sItem, sTitle: string;
  X, Y: integer;
  sz: TSize;
  asParts: TStringList;
begin

  sItem := (Control as TListBox).Items[Index];
  if sItem.IsEmpty() then Exit;

  sTitle := sItem.Substring(ciMnuCch);

  if (not sTitle.IsEmpty()) and (sTitle[1] = '|') then
  begin
    asParts := TStringList.Create();
    try
      Split('|', sTitle, asParts);
      sTitle := asParts[1];
    finally
      FreeAndNil(asParts);
    end;
  end;

  with (Control as TListBox).Canvas do
  begin

    case sItem[ciMnuIdx_Ctrl] of

      ccMnuBtn : begin

        if odSelected in State then
        begin
          Brush.Color := clWindow;
          Font.Color  := clWindowText;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        // DrawCaption((Control as TListBox).Handle, (Control as TListBox).Canvas.Handle, Rect, DC_ACTIVE or DC_ICON or DC_TEXT);
        // DrawFrameControl( (Control as TListBox).Canvas.Handle, Rect, DFC_CAPTION, DFCS_CAPTIONCLOSE );

        Rect.Left   := Rect.Left   + 3;
        Rect.Right  := Rect.Right  - 2;
        Rect.Top    := Rect.Top    + 3;
        Rect.Bottom := Rect.Bottom - 2;

        DrawFrameControl( (Control as TListBox).Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH );

        X := Rect.Left + 10;
        Y := Rect.Top  + 6;

        SetBkMode((Control as TListBox).Canvas.Handle, TRANSPARENT);
        TextOut(X, Y, sTitle);
        SetBkMode((Control as TListBox).Canvas.Handle, OPAQUE);

        {
        if odFocused In State then
        begin
          //Brush.Color := (Control as TListBox).Color;
          DrawFocusRect(Rect);
        end;
        }

      end;

      ccMnuGrp: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        (Control as TListBox).Canvas.Font.Height := (Control as TListBox).Canvas.Font.Height - 2;

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

        sz := TextExtent(sTitle);

        MoveTo(X, Y + sz.cy);
        LineTo(X + sz.cx, Y + sz.cy);

      end;

      ccMnuCap: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        (Control as TListBox).Canvas.Font.Height := (Control as TListBox).Canvas.Font.Height - 1;

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

        {
        sz := TextExtent(sTitle);

        MoveTo(X, Y + sz.cy);
        LineTo(X + sz.cx, Y + sz.cy);
        }

      end;

      ccMnuItm: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top; //  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

      end

      else begin

        FillRect(Rect);
        TextOut(Rect.Left, Rect.Top, sItem);

      end;

    end;

  end;
end;

procedure TFrmMain.lbObjectsClick(Sender: TObject);
var
  cID: char;
  sCaption: string;
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsClick BEGIN');

  lbTasks.Items.Clear();

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID, sCaption);

  case cID of

    ccMnuGrpID_Database: begin

      Menu_AddTask_Group(                               'Tasks'             , 0 );
      Menu_AddTask_Button(ccMnuBtnID_Refresh          , 'Refresh Metadata'      );

    end;

    ccMnuItmID_Table: begin

      Menu_AddTask_Group(                               'Tasks'             , 0 );
      Menu_AddTask_Button(ccMnuBtnID_Open             , 'Open'                  );
      Menu_AddTask_Button(ccMnuBtnID_Import_Table     , 'Import Table (CSV)'    );
      Menu_AddTask_Button(ccMnuBtnID_Drop_Table       , 'DROP Table'            );

    end;

    ccMnuItmID_Table_Column: begin

      Menu_AddTask_Group(                               'Tasks'             , 0 );
      Menu_AddTask_Button(ccMnuBtnID_Drop_Column      , 'DROP Column'           );

    end;

    ccMnuItmID_Query: begin

      Menu_AddTask_Group(                               'Tasks'             , 0 );
      Menu_AddTask_Button(ccMnuBtnID_Open             , 'Open'                  );

    end;

  end;

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsClick END');
end;

procedure TFrmMain.lbObjectsDblClick(Sender: TObject);
var
  cID_Object: char;
  sCaption_Object: string;
  asParts: TStringList;
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsDblClick BEGIN');

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID_Object, sCaption_Object);

  DoOpen(cID_Object, sCaption_Object);

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsDblClick END');
end;

procedure TFrmMain.lbTasksClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbOptionsClick BEGIN');

  DoTasksClick();

  m_oApp.LOG.LogUI('TFrmMain.lbOptionsClick END');
end;

procedure TFrmMain.lbTasksDblClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbOptionsDblClick BEGIN');

  // TODO...

  m_oApp.LOG.LogUI('TFrmMain.lbOptionsDblClick END');
end;

procedure TFrmMain.DoOpen(cID_Object: char; sCaption_Object: string);
var
  asParts: TStringList;
begin
  if cID_Object = ccMnuItmID_Table then
  begin

    OpenSql(sCaption_Object, 'select * from ' + sCaption_Object);

  end
  else if cID_Object = ccMnuItmID_Query then
  begin

    asParts := TStringList.Create();
    try

      Split('|', sCaption_Object, asParts);

      OpenSql(asParts[1], asParts[2]);

    finally
      FreeAndNil(asParts);
    end;
  end;
end;

procedure TFrmMain.DoTasksClick();
var
  cID_Task, cID_Object: char;
  sCaption_Task, sCaption_Object: string;
begin

  if lbTasks.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbTasks.Items[lbTasks.ItemIndex], cID_Task, sCaption_Task);

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID_Object, sCaption_Object);

  case cID_Task of

    ccMnuBtnID_Refresh : begin
      DoRefreshMetaData();
    end;

    ccMnuBtnID_Open : begin
      DoOpen(cID_Object, sCaption_Object);
    end;

    ccMnuBtnID_Import_Table : begin
      DoImportTable(cID_Object, sCaption_Object);
    end;

    ccMnuBtnID_Drop_Table : begin
      DoDropTable(cID_Object, sCaption_Object);
    end;

    ccMnuBtnID_Drop_Column : begin
      DoDropColumn();
    end;

  end;
end;

function TFrmMain.MnuGRP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuGrp + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuGRP(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuGrp + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuCAP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuCap + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuCAP(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuCap + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuITM_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuItm + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuITM(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuItm + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuSPC() : string;
begin
  Result := ccMnuItm + '0' + '0' + '0';
end;

procedure TFrmMain.Menu_ExtractItem(sItem: string; var rcID: char; var rsCaption: string);
begin

  rcID      := '0';
  rsCaption := '';

  if sItem.Length < ciMnuCch then Exit;

  rcID      := sItem[ciMnuIdx_ID];
  rsCaption := sItem.Substring(ciMnuCch);
end;

procedure TFrmMain.Menu_AddTask_Button(cID: char; sCaption: string);
begin
  lbTasks.Items.Add(ccMnuBtn + cID + '0' + '0' + sCaption);
end;

procedure TFrmMain.Menu_AddTask_Group(sCaption: string; iIndent: integer);
begin
  lbTasks.Items.Add(MnuGRP(sCaption, iIndent));
end;

procedure TFrmMain.Menu_AddTask_Item(sCaption: string; iIndent: integer);
begin
  lbTasks.Items.Add(MnuITM(sCaption, iIndent));
end;

end.
