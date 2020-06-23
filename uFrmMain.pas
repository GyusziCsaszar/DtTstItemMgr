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
    btnCrePrdTbls: TButton;
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
    btnDbOpen: TButton;
    btnDrpCol: TButton;
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
    procedure btnCrePrdTblsClick(Sender: TObject);
    procedure btnIsqlClick(Sender: TObject);
    procedure tsDevChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure btnSqlOpenClick(Sender: TObject);
    procedure lbLogDblClick(Sender: TObject);
    procedure btnSqlOpenSampleClick(Sender: TObject);
    procedure btnIsqlExecClick(Sender: TObject);
    procedure btnIsqlExecSampleClick(Sender: TObject);
    procedure btnDbOpenClick(Sender: TObject);
    procedure btnDrpColClick(Sender: TObject);
  private
    { Private declarations }
    con_Firebird: TSQLConnection;
    m_oLog: TDtTstLog;
    m_oDb: TDtTstDb;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    function GetSelectedMetaItem(var rsItem: string; var rsType: string) : Boolean;

    procedure OpenSql(sTable, sSql: string);
    procedure IsqlOpen(sStatements, sTerm: string);

    procedure AttachDbItemManager(bForceUpdate: Boolean);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstWin, uDtTstFirebird, uDtTstDbItemMgr, uFrmProgress,
  System.IOUtils, Vcl.Clipbrd, StrUtils;

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
  m_oLog.LogVERSION('App Info: PRD = ' + csPRODUCT + ', VER = ' + IntToStr(ciVERSION));
  m_oLog.LogVERSION('App.DB Info: ADM_VER = ' + IntToStr(ciDB_VERSION_ADM) +
                      ', PRD = ' + csPRODUCT + ', PRD.VER = ' + IntToStr(ciDB_VERSION_PRD) );

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

procedure TFrmMain.btnDbOpenClick(Sender: TObject);
// SRC: http://www.delphibasics.co.uk/RTL.asp?Name=topendialog
var
  frmOf: TOpenDialog;
begin

  frmOf := TOpenDialog.Create(self);
  try

    // Set up the starting directory to be the current one
    //frmOf.InitialDir := GetCurrentDir();

    // Only allow existing files to be selected
    frmOf.Options := [ofFileMustExist];

    // Allow only .xyz files to be selected
    frmOf.Filter := csFBRD_DBFILE_FILTER + '|All Files (*.*)|*.*';

    // Select .xyz as the starting filter type
    frmOf.FilterIndex := 1;

    // Display the open file dialog
    if not frmOf.Execute then
    begin
      Exit;
    end;

    cbbDb.Text := 'localhost:' + frmOf.FileName;

  finally
    FreeAndNil(frmOf);
  end;
end;

procedure TFrmMain.btnIsqlClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oLog.LogUI('TFrmMain.btnIsql BEGIN');

  sTerm := '';
  sStatements := '';

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

    frmPrs := TFrmProgress.Create(self, m_oLog);
    try

      frmPrs.Show();
      frmPrs.Init('Calling Firebird Isql tool');
      frmPrs.SetProgressToMax();

      frmPrs.AddStep('Starting Firebird Isql tool');

      sOutput := ISQL_Execute(m_oLog, TPath.GetDirectoryName(Application.ExeName),
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

procedure TFrmMain.btnDrpColClick(Sender: TObject);
var
  sItem, sType, sTblCol, sTbl, sCol: string;
  i: integer;
begin
  m_oLog.LogUI('TFrmMain.btnDropCol BEGIN');

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

    m_oDb.META_DropTableColumn(sTbl, sCol);

    InfoMsgDlg('You have DROPPED column "' + sCol + '" of table "' + sTbl + '"!');
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  m_oLog.LogUI('TFrmMain.btnDropCol END');
end;

procedure TFrmMain.btnDrpTblClick(Sender: TObject);
var
  sItem, sType, sTable: string;
begin
  m_oLog.LogUI('TFrmMain.btnDrpTblClick BEGIN');

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

    m_oDb.META_DropTable(sTable);

    InfoMsgDlg('You have DROPPED table "' + sTable + '"!');
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
  m_oLog.LogUI('TFrmMain.lbResultDblClick BEGIN');

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

        m_oDb.Select_Triggers(asItems, sTable {sTable}, True {bDetails});

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

    lbResult.Items.Insert(4, '  Server Charset: ' + con_Firebird.Params.Values['ServerCharset'] + ' // NOTE: Requested by client!');

    iIdx := 4;

    iIdx := iIdx + 1;
    lbResult.Items.Insert(iIdx, '[Generators]');
    asItems := TStringList.Create();
    try

      m_oDb.Select_Generators(asItems);

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

  lbResult.Items.Add('SELECT ' + csDB_FLD_USR_ITEMTYPE_NAME + ' FROM ' + csDB_TBL_USR_ITEMTYPE);

  m_oLog.LogUI('TFrmMain.btnGetMetadataClick END');
end;

procedure TFrmMain.btnCrePrdTblsClick(Sender: TObject);
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

    // ROLLBACK...
    {
    // NOTE: DbUpdate to v100 by adding single table admDbInfo...
    m_oDb.ADM_CreateTable_DBINFO();

    sDbInfo := 'LoginUsername = "' + m_oDb.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( ADM Version = ' + IntToStr(m_oDb.ADM_DbInfVersion_ADM) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '" )';

    edDbInfo.Text := sDbInfo;
    }

    AttachDbItemManager(True {bForceUpdate});

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
    sDbInfo := sDbInfo + ', DtTstDb( ADM Version = ' + IntToStr(m_oDb.ADM_DbInfVersion_ADM) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '" )';

    edDbInfo.Text := sDbInfo;

    // ATTN: Do not force!!! Attach only known DB here!!!
    AttachDbItemManager(False {bForce});

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

    btnDbOpen           .Enabled := False;
    cbbDb               .Enabled := False;
    chbServerCharSetUtf8.Enabled := False;
    btnConnect          .Enabled := False;

    btnCrePrdTbls  .Enabled := (m_oDb.ADM_DbInfProduct <> csPRODUCT_FULL);
    btnGetMetadata .Enabled := True;
    btnCreTblSample.Enabled := True;
    btnDrpTbl      .Enabled := True;
    btnDrpCol      .Enabled := True;

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

procedure TFrmMain.AttachDbItemManager(bForceUpdate: Boolean);
var
  oDbItemMgr: TDtTstDbItemMgr;
  sDbInfo: string;
  frmPrs: TFrmProgress;
begin

  // ATTN: In case of (one-and-only) Known DB
  //       OR FORCED (!)...
  if bForceUpdate or (m_oDb.ADM_DbInfProduct = csPRODUCT_FULL) then
  begin

    // Replace oDb with oDbItemMgr...
    oDbItemMgr := TDtTstDbItemMgr.Create(m_oLog, m_oDb);
    FreeAndNil(m_oDb);
    m_oDb := oDbItemMgr;

    if chbDoDbUpdate.Checked then
    begin

      frmPrs := TFrmProgress.Create(self, m_oLog);
      try

        oDbItemMgr.ADM_DoDbUpdates(frmPrs);

        frmPrs.Done();
        while frmPrs.Visible do Application.ProcessMessages;

      finally
        frmPrs.Close();
        FreeAndNil(frmPrs);
      end;

    end;

    sDbInfo := 'LoginUsername = "' + m_oDb.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( ADM Version = ' + IntToStr(m_oDb.ADM_DbInfVersion_ADM) +
                ', Product = "' + m_oDb.ADM_DbInfProduct + '"' +
                ', Product Version = ' + IntToStr(m_oDb.ADM_DbInfVersion_PRD) +
                ', UserID = ' + IntToStr(oDbItemMgr.ADM_UserID) + ' )';
    sDbInfo := sDbInfo + ', DtTstDbItemMgr(  )';

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
var
  sSql: string;
begin
  if not moSql.Lines.Text.IsEmpty() then
  begin

    sSql := moSql.Lines.Text;

    if ContainsText(sSql.ToUpper(), 'SELECT ') then
    begin
      OpenSql('SQL Editor', sSql);
    end
    else
    begin
      m_oDb.ExecuteSQL(nil {nil = DO Transaction}, sSql);
    end;

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
