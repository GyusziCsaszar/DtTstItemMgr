unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstConsts, uDtTstLog, uDtTstDb,
  { ATTN: for DBExpress: } midaslib,
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids, SimpleDS, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Tabs;

type
  TFrmMain = class(TForm)
    con_Firebird_ANSI: TSQLConnection;
    btnConnect: TButton;
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
    lblDb: TLabel;
    cbbDb: TComboBox;
    btnCreTblSample: TButton;
    btnDrpTbl: TButton;
    lblDbInfo: TLabel;
    edDbInfo: TEdit;
    btnInitDtTstDb: TButton;
    chbServerCharsetUtf8: TCheckBox;
    con_Firebird_UTF8: TSQLConnection;
    chbDoDbUpdate: TCheckBox;
    btnIsql: TButton;
    chbIsqlVisible: TCheckBox;
    tsDev: TTabSet;
    lbLog: TListBox;
    btnSqlOpen: TButton;
    moSql: TMemo;
    btnSqlOpenSample: TButton;
    btnIsqlExec: TButton;
    btnIsqlExecSample: TButton;
    edTerm: TEdit;
    procedure btnConnectClick(Sender: TObject);
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
    procedure btnCreTblSampleClick(Sender: TObject);
    procedure btnDrpTblClick(Sender: TObject);
    procedure btnInitDtTstDbClick(Sender: TObject);
    procedure btnIsqlClick(Sender: TObject);
    procedure tsDevChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure btnSqlOpenClick(Sender: TObject);
    procedure lbLogDblClick(Sender: TObject);
    procedure btnSqlOpenSampleClick(Sender: TObject);
    procedure btnIsqlExecClick(Sender: TObject);
    procedure btnIsqlExecSampleClick(Sender: TObject);
  private
    { Private declarations }
    con_Firebird: TSQLConnection;
    m_oLog: TDtTstLog;
    m_oDb: TDtTstDb;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure OpenSql(sTable, sSql: string);
    procedure IsqlOpen(sStatements, sTerm: string);

    procedure AttachDbItemManager();
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstWin, uDtTstFirebird, uDtTstDbItemMgr, uFrmProgress,
  System.IOUtils, Vcl.Clipbrd;

constructor TFrmMain.Create(AOwner: TComponent);
begin

  // NOTE: ShowMessage Title setting...
  Application.Title := csCOMPANY + ' ' + csPRODUCT_TITLE + ' ' + csVERSION_TITLE;

  con_Firebird := nil;

  m_oLog := TDtTstLog.Create(TPath.ChangeExtension(Application.ExeName, csLOG_UTF8_EXT), //csLOG_EXT),
                             TPath.ChangeExtension(Application.ExeName, csINI_EXT));

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  m_oLog.m_lbLogView := lbLog;

  m_oLog.LogLIFE('TFrmMain.Create');

  try
    m_oDb := TDtTstDb.Create(m_oLog, TPath.ChangeExtension(Application.ExeName, csINI_EXT));

    // ATTN!!!
    chbServerCharsetUtf8.Checked := m_oDb.UTF8;

  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

destructor TFrmMain.Destroy();
begin
  m_oLog.LogLIFE('TFrmMain.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  FreeAndNil(m_oDb);

  inherited Destroy();

  FreeAndNil(m_oLog);
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.FormShow BEGIN');

  // NOTE: FormShow is called just before Form becomes visible BUT during construction!!!

  self.Caption := Application.Title;

  // First LogINFO...
  m_oLog.LogVERSION('App Path: '  + Application.ExeName);
  m_oLog.LogVERSION('App Title: ' + Application.Title);
  m_oLog.LogVERSION('App Info: PRD = ' + csPRODUCT + ', VER = ' + IntToStr(ciVERSION) + ', DB(' + csPRODUCT + ').VER = ' + IntToStr(ciDB_VERSION));

  // DB Info from INI file...
  cbbDb.Text := '';
  cbbDb.Items.Clear();

  if not Assigned(m_oDb) then
  begin
    Close();
    Exit();
  end;

  m_oDb.GetConnectStrings(cbbDb, nil {asConnectStrings});

  btnCreTblSample.Caption := btnCreTblSample.Caption + ' "' + csDB_TBL_SAMPLE + '"';

  // ATTN: Force event handler...
  tsDev.TabIndex := 1; tsDev.TabIndex := 0;

  m_oLog.LogUI('TFrmMain.FormShow END');
end;

procedure TFrmMain.btnIsqlClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oLog.LogUI('TFrmMain.btnIsql BEGIN');

    sTerm := '';
    sStatements := '';

    // BUG LOOKUP!
    {
    sTerm := '!!';
    sStatements := 'CREATE TRIGGER ADMUSERS_BI FOR ADMUSERS' + CHR(13) + CHR(10) +
                   ' ACTIVE BEFORE INSERT' + CHR(13) + CHR(10) +
                   ' POSITION 0' + CHR(13) + CHR(10) +
                   ' AS' + CHR(13) + CHR(10) +
                   ' BEGIN' + CHR(13) + CHR(10) +
                   '  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(ADMUSERS_ID, 1);' + CHR(13) + CHR(10) +
                   ' END ' + sTerm;
    }

  IsqlOpen(sStatements, sTerm);

  m_oLog.LogUI('TFrmMain.btnIsql END');
end;

procedure TFrmMain.IsqlOpen(sStatements, sTerm: string);
var
  sOutput: string;
  frmPrs: TFrmProgress;
begin

  if m_oDb.IsqlPath.IsEmpty() then
  begin
    ErrorMsgDlg('No isql Path is specified!');
    exit;
  end;

  try

    frmPrs := TFrmProgress.Create(self);
    try

      frmPrs.Show();
      frmPrs.Init('Calling Firebird Isql tool');
      frmPrs.SetProgressToMax();

      frmPrs.AddStep('Starting Firebird Isql tool');

      sOutput := IsqlExec(m_oLog, TPath.GetDirectoryName(Application.ExeName),
                          m_oDb.IsqlPath,
                          cbbDb.Text,
                          m_oDb.ConnectUser, m_oDb.ConnectPassword,
                          True {bGetOutput},
                          chbIsqlVisible.Checked {bVisible},
                          sStatements,
                          sTerm);

      frmPrs.AddStepEnd('Done!');

      InfoMsgDlg('isql output (cch = ' + IntToStr(sOutput.Length) + '):' + CHR(10) + CHR(10) + sOutput);

    finally
      frmPrs.Close();
      FreeAndNil(frmPrs);
    end;

  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.btnCreTblSampleClick(Sender: TObject);
var
  oDb: TDtTstDb;
begin
  m_oLog.LogUI('TFrmMain.btnCreTblSampleClick BEGIN');

  // try SRC: https://stackoverflow.com/questions/6601147/how-to-correctly-write-try-finally-except-statements
  try
    try
      oDb := TDtTstDb.Create(m_oLog, '');

      oDb.META_CreateTable_SAMPLE(con_Firebird.DBXConnection);

      InfoMsgDlg('You have created table "' + csDB_TBL_SAMPLE + '"!');

    finally
      FreeAndNil(oDb);
    end;
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  m_oLog.LogUI('TFrmMain.btnCreTblSampleClick END');
end;

procedure TFrmMain.btnDrpTblClick(Sender: TObject);
var
  sTable: string;
begin
  m_oLog.LogUI('TFrmMain.btnDrpTblClick BEGIN');

  if lbResult.ItemIndex < 0 then
  begin
    WarningMsgDlg('No table is selected!');
    exit;
  end;

  if lbResult.Items[lbResult.ItemIndex][1] = ' ' then
  begin
    WarningMsgDlg('The selected item is not a Table Name!');
    exit;
  end;

  if lbResult.Items[lbResult.ItemIndex][1] = '[' then
  begin
    WarningMsgDlg('The selected item is not a Table Name!');
    exit;
  end;

  if Pos('DUAL ', lbResult.Items[lbResult.ItemIndex]) = 1 then
  begin
    ErrorMsgDlg('Table is not deletable!');
    exit;
  end;

  sTable := lbResult.Items[lbResult.ItemIndex];

  if not QuestionMsgDlg('Do you want to really DROP Table "' + sTable + '"?') then
  begin
    Exit;
  end;

  try

    m_oDb.META_DropTable(sTable);

    InfoMsgDlg('You have DROPPED Table "' + sTable + '"!');
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  m_oLog.LogUI('TFrmMain.btnDrpTblClick END');
end;

procedure TFrmMain.cds_TopAfterPost(DataSet: TDataSet);
begin
  m_oLog.LogUI('TFrmMain.cds_TopAfterPost BEGIN');
  cds_Top.ApplyUpdates(0);
  m_oLog.LogUI('TFrmMain.cds_TopAfterPost END');
end;

procedure TFrmMain.sds_BottomAfterPost(DataSet: TDataSet);
begin
  m_oLog.LogUI('TFrmMain.sds_BottomAfterPost BEGIN');
  sds_Bottom.ApplyUpdates(0);
  m_oLog.LogUI('TFrmMain.sds_BottomAfterPost END');
end;

procedure TFrmMain.btnDeleteTopClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnDeleteTopClick BEGIN');

  if not cds_Top.Active then exit;

  try
    cds_Top.Delete();
    cds_Top.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnDeleteTopClick END');
end;

procedure TFrmMain.btnDeleteBottomClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnDeleteBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Delete();
    sds_Bottom.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnDeleteBottomClick END');
end;

procedure TFrmMain.btnInsertTopClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnInsertTopClick BEGIN');

  if not cds_Top.Active then exit;

  try
    cds_Top.Insert();
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnInsertTopClick END');
end;

procedure TFrmMain.btnInsertBottomClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnInsertBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Insert();
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnInsertBottomClick END');
end;

procedure TFrmMain.btnRefreshTopClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnRefreshTopClick BEGIN');

  if not cds_Top.Active then exit;

  try
    cds_Top.Active := False;
    qry_Top.Active := False;

    qry_Top.Active := True;
    m_oLog.LogINFO('SQL Query is Active!');
    cds_Top.Active := True;
    m_oLog.LogINFO('Client DataSet is Active!');
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnRefreshTopClick END');
end;

procedure TFrmMain.btnRefreshBottomClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.btnRefreshBottomClick BEGIN');

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Active := False;

    sds_Bottom.Active := True;
    m_oLog.LogINFO('Simple DataSet is Active!');
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnRefreshBottomClick END');
end;

procedure TFrmMain.lbResultDblClick(Sender: TObject);
var
  sTable, sSql: string;
  bDUAL: Boolean;
begin
  m_oLog.LogUI('TFrmMain.lbResultDblClick BEGIN');

  if lbResult.ItemIndex < 0 then
  begin
    WarningMsgDlg('No table is selected!');
    exit;
  end;
  if lbResult.Items[lbResult.ItemIndex].IsEmpty() then
  begin
    WarningMsgDlg('No table is selected!');
    exit;
  end;

  bDUAL := (Pos('DUAL ', lbResult.Items[lbResult.ItemIndex]) = 1);

  if (lbResult.Items[lbResult.ItemIndex][1] = ' ') or
     (lbResult.Items[lbResult.ItemIndex][1] = '[') or
     (bDUAL) then
  begin
    if bDUAL then
    begin
      sTable := lbResult.Items[lbResult.ItemIndex];
    end
    else
    begin
      WarningMsgDlg('The selected item is not a Table Name!');

      sTable := 'N/A';
    end;

    sSql   := 'select current_timestamp from RDB$DATABASE;'
  end
  else
  begin
    sTable := lbResult.Items[lbResult.ItemIndex];
    sSql   := 'select * from ' + m_oDb.FIXOBJNAME(sTable) + ';'
  end;

  OpenSql(sTable, sSql);

  m_oLog.LogUI('TFrmMain.lbResultDblClick END');
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
      qry_Top.SQL.Add(m_oLog.LogSQL(sSQL));
      qry_Top.Active := True;
      m_oLog.LogINFO('SQL Query is Active!');
      cds_Top.Active := True;
      m_oLog.LogINFO('Client DataSet is Active!');
      lblTop.Caption := sTable + ' (Query, Provider and Client DataSet):';
    end;
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  try
    lblBottom.Caption := 'N/A (Simple DataSet):';
    sds_Bottom.Active := False;
    sds_Bottom.DataSet.CommandText := '';

    if not sSQL.IsEmpty() then
    begin
      sds_Bottom.DataSet.CommandText := m_oLog.LogSQL(sSQL);
      sds_Bottom.Active := True;
      m_oLog.LogINFO('Simple DataSet is Active!');
      lblBottom.Caption := sTable + ' (Simple DataSet):';
    end;
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.chbMetadataTablesOnlyClick(Sender: TObject);
begin
  m_oLog.LogUI('TFrmMain.chbMetadataTablesOnlyClick BEGIN');
  if btnGetMetadata.Enabled then btnGetMetadata.Click();
  m_oLog.LogUI('TFrmMain.chbMetadataTablesOnlyClick END');
end;

procedure TFrmMain.btnGetMetadataClick(Sender: TObject);
var
  iIdx: integer;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin
  m_oLog.LogUI('TFrmMain.btnGetMetadataClick BEGIN');

  lbResult.Items.Clear();

  con_Firebird.GetTableNames(lbResult.Items, False);

  if chbMetadataTablesOnly.Checked then exit;

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
      lbResult.Items.Insert(iIdx, '  [Fields]');

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + sItem);
      end;

    except
      on exc : Exception do
      begin
        m_oLog.LogERROR(exc);

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
        m_oLog.LogERROR(exc);

        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
      end;
    end;

    FreeAndNil(asItems);

    // Table Triggers
    asItems := TStringList.Create();
    try

      m_oDb.DB_SelectTriggers(asItems, sTable {sTable}, True {bDetails});

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
        m_oLog.LogERROR(exc);

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

  iIdx := 3;

  iIdx := iIdx + 1;
  lbResult.Items.Insert(iIdx, '[Generators]');
  asItems := TStringList.Create();
  try

    m_oDb.DB_SelectGenerators(asItems);

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

  m_oLog.LogUI('TFrmMain.btnGetMetadataClick END');
end;

procedure TFrmMain.btnInitDtTstDbClick(Sender: TObject);
var
  sDbInfo: string;
begin
  m_oLog.LogUI('TFrmMain.btnInitDtTstDbClick BEGIN');

  if (not Assigned(con_Firebird)) or (not con_Firebird.Connected) then
  begin
    WarningMsgDlg('No Database is open!');
    Exit;
  end;

  if not m_oDb.ADM_DbInfProduct.IsEmpty() then
  begin
    if m_oDb.ADM_DbInfProduct = csPRODUCT_FULL then
    begin
      WarningMsgDlg('Database already contains Tables for Product "' + csPRODUCT_FULL + '"!');
    end
    else
    begin
      ErrorMsgDlg('Database contains Tables for DIFFERENT Product "' + m_oDb.ADM_DbInfProduct + '"!' +
                  CHR(10) + CHR(10) + 'No mixed Products are allowed in a single Database!');
    end;

    Exit;
  end;

  if m_oDb.GetTableCount() > 0 then
  begin
    if not QuestionMsgDlg('Database already has ' + IntToStr(m_oDb.GetTableCount()) + ' Table(s) and is not Empty!' +
          CHR(10) + CHR(10) + 'Do you want to create Tables for Product "' + csCOMPANY + csPRODUCT + '"?') then
    begin
      Exit;
    end;
  end;

  try

    // NOTE: DbUpdate to v100 by adding single table and ADM Generator...
    m_oDb.ADM_CreateTable_DBINFO();

    sDbInfo := 'LoginUsername = "' + m_oDb.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( Version = ' + IntToStr(m_oDb.ADM_DbInfVersion) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '" )';

    edDbInfo.Text := sDbInfo;

    AttachDbItemManager();

  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  btnGetMetadata.Click();

  m_oLog.LogUI('TFrmMain.btnInitDtTstDbClick END');
end;

procedure TFrmMain.btnConnectClick(Sender: TObject);
var
  sDbInfo: string;
begin
  m_oLog.LogUI('TFrmMain.btnConnectClick BEGIN');

  try
    if chbServerCharSetUtf8.Checked then
    begin
      con_Firebird := con_Firebird_UTF8;
    end
    else
    begin
      con_Firebird := con_Firebird_ANSI;
    end;

    m_oDb.ConnectString := cbbDb.Text;
    m_oDb.Connect(con_Firebird);

    sDbInfo := 'LoginUsername = "' + m_oDb.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( Version = ' + IntToStr(m_oDb.ADM_DbInfVersion) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '" )';

    edDbInfo.Text := sDbInfo;

    AttachDbItemManager();

    // ATTN: Required!!!
    qry_Top.SQLConnection := con_Firebird;
    sds_Bottom.Connection := con_Firebird;

    m_oLog.LogINFO('SQL Connection is Connected!');

    // ATTN: No Query loaded at startup!!!
    {
    qry_Top.Active := True;

    m_oLog.LogINFO('SQL Query is Active!');

    cds_Top.Active := True;

    m_oLog.LogINFO('Client DataSet is Active!');

    sds_Bottom.Active := True;

    m_oLog.LogINFO('Simple DataSet is Active!');
    }

    cbbDb               .Enabled := False;
    chbServerCharSetUtf8.Enabled := False;
    btnConnect          .Enabled := False;

    btnInitDtTstDb .Enabled := True;
    btnGetMetadata .Enabled := True;
    btnCreTblSample.Enabled := True;
    btnDrpTbl      .Enabled := True;

    btnSqlOpen     .Enabled := True;

    btnGetMetadata.Click();

  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oLog.LogUI('TFrmMain.btnConnectClick END');
end;

procedure TFrmMain.AttachDbItemManager();
var
  oDbItemMgr: TDtTstDbItemMgr;
  sDbInfo: string;
  frmPrs: TFrmProgress;
begin

  // ATTN: In case of (one-and-only) Known DB...
  if m_oDb.ADM_DbInfProduct = csPRODUCT_FULL then
  begin

    // Replace oDb with oDbItemMgr...
    oDbItemMgr := TDtTstDbItemMgr.Create(m_oLog, m_oDb);
    FreeAndNil(m_oDb);
    m_oDb := oDbItemMgr;

    if chbDoDbUpdate.Checked then
    begin

      frmPrs := TFrmProgress.Create(self);
      try

        while True do
        begin

            if oDbItemMgr.ADM_DoDbUpdates(frmPrs) then
            begin
              Break; // Database is Up-To-Date!!!
            end;

        end;

        frmPrs.Done();
        while frmPrs.Visible do Application.ProcessMessages;

      finally
        frmPrs.Close();
        FreeAndNil(frmPrs);
      end;

    end;

    sDbInfo := 'LoginUsername = "' + m_oDb.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( Version = ' + IntToStr(m_oDb.ADM_DbInfVersion) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '" )';
    sDbInfo := sDbInfo + ', DtTstDbItemMgr( UserID = ' + IntToStr(oDbItemMgr.ADM_UserID) + ' )';

    edDbInfo.Text := sDbInfo;

  end;

end;

procedure TFrmMain.tsDevChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin

  lbLog.Visible := (NewTab = 0);

  btnSqlOpen        .Visible := (NewTab = 1);
  btnSqlOpenSample  .Visible := (NewTab = 1);
  btnIsqlExec       .Visible := (NewTab = 1);
  btnIsqlExecSample .Visible := (NewTab = 1);
  edTerm            .Visible := (NewTab = 1);
  moSql             .Visible := (NewTab = 1);

end;

procedure TFrmMain.lbLogDblClick(Sender: TObject);
begin
  if lbLog.ItemIndex >= 0 then
  begin
    Clipboard.AsText := lbLog.Items[lbLog.ItemIndex];
  end;
end;

procedure TFrmMain.btnSqlOpenClick(Sender: TObject);
begin
  if not moSql.Lines.Text.IsEmpty() then
  begin
    OpenSql('SQL Editor', moSql.Lines.Text);
  end;
end;

procedure TFrmMain.btnSqlOpenSampleClick(Sender: TObject);
begin
  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE';
  if btnSqlOpen.Enabled then btnSqlOpen.Click();
end;

procedure TFrmMain.btnIsqlExecClick(Sender: TObject);
begin
  if not moSql.Lines.Text.IsEmpty() then
  begin

    if edTerm.Text = '' then edTerm.Text := ';';

    if edTerm.Text <> ';' then
    begin
      if not QuestionMsgDlg('The default Isql TERM ";" has changed to "' + edTerm.Text + '"!' + CHR(13) + CHR(10) +
                            CHR(13) + CHR(10) + 'Do you want to conitune?') then
      begin
        Exit;
      end;
    end;

    IsqlOpen(moSql.Lines.Text, edTerm.Text);
  end;
end;

procedure TFrmMain.btnIsqlExecSampleClick(Sender: TObject);
begin
  edTerm.Text := '!!';
  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE!!';

  if btnIsqlExec.Enabled then btnIsqlExec.Click();

  edTerm.Text := ';';
  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE;';
end;

end.
