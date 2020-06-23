unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTs Units: } uDtTstConsts, uDtTstLog, uDtTstDb,
  { ATTN: for DBExpress: } midaslib,
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids, SimpleDS, Vcl.ExtCtrls;

type
  TFrmMain = class(TForm)
    lblLog: TLabel;
    lbLog: TListBox;
    con_Firebird: TSQLConnection;
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
    btnCreTbl: TButton;
    btnDrpTbl: TButton;
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
    procedure btnCreTblClick(Sender: TObject);
    procedure btnDrpTblClick(Sender: TObject);
  private
    { Private declarations }
    m_oLog: TDtTstLog;
    m_oDb: TDtTstDb;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  System.IOUtils;

constructor TFrmMain.Create(AOwner: TComponent);
begin

  m_oLog := TDtTstLog.Create(TPath.ChangeExtension(Application.ExeName, csLOG_EXT),
                             TPath.ChangeExtension(Application.ExeName, csINI_EXT));

  inherited Create(AOwner);

  m_oLog.m_lbLogView := lbLog;

  m_oLog.LogLIFE('TFrmMain.Create');

  try
    m_oDb := TDtTstDb.Create(m_oLog, TPath.ChangeExtension(Application.ExeName, csINI_EXT));
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

destructor TFrmMain.Destroy();
begin
  m_oLog.LogLIFE('TFrmMain.Destroy');

  FreeAndNil(m_oDb);

  inherited Destroy();

  FreeAndNil(m_oLog);
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  // NOTE: FormShow is called just before Form becomes visible BUT during construction!!!

  // ShowMessage Title setting...
  Application.Title := self.Caption;

  // First LogINFO...
  m_oLog.LogINFO('Executable Path: ' + Application.ExeName);

  // DB Info from INI file...
  cbbDb.Text := '';
  cbbDb.Items.Clear();

  if not Assigned(m_oDb) then
  begin
    Close();
    Exit();
  end;

  m_oDb.GetConnectStrings(cbbDb);
end;

procedure TFrmMain.btnCreTblClick(Sender: TObject);
var
  oDb: TDtTstDb;
begin

  // try SRC: https://stackoverflow.com/questions/6601147/how-to-correctly-write-try-finally-except-statements
  try
    try
      oDb := TDtTstDb.Create(m_oLog, '');

      oDb.CreateTable(con_Firebird.DBXConnection);

      ShowMessage('You have created table DELPHIEXPERTS!');
    finally
      FreeAndNil(oDb);
    end;
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

end;

procedure TFrmMain.btnDrpTblClick(Sender: TObject);
var
  oDb: TDtTstDb;
begin

  // try SRC: https://stackoverflow.com/questions/6601147/how-to-correctly-write-try-finally-except-statements
  try
    try
      oDb := TDtTstDb.Create(m_oLog, '');

      oDb.DropTable(con_Firebird.DBXConnection);

      ShowMessage('You have dropped table DELPHIEXPERTS!');

    finally
      FreeAndNil(oDb);
    end;
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  if btnGetMetadata.Enabled then btnGetMetadata.Click;

  end;

procedure TFrmMain.cds_TopAfterPost(DataSet: TDataSet);
begin
  cds_Top.ApplyUpdates(0);
end;

procedure TFrmMain.sds_BottomAfterPost(DataSet: TDataSet);
begin
  sds_Bottom.ApplyUpdates(0);
end;

procedure TFrmMain.btnDeleteTopClick(Sender: TObject);
begin

  if not cds_Top.Active then exit;

  try
    cds_Top.Delete();
    cds_Top.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.btnDeleteBottomClick(Sender: TObject);
begin

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Delete();
    sds_Bottom.ApplyUpdates(0);
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.btnInsertTopClick(Sender: TObject);
begin

  if not cds_Top.Active then exit;

  try
    cds_Top.Insert();
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.btnInsertBottomClick(Sender: TObject);
begin

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Insert();
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.btnRefreshTopClick(Sender: TObject);
begin

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
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.btnRefreshBottomClick(Sender: TObject);
begin

  if not sds_Bottom.Active then exit;

  try
    sds_Bottom.Active := False;

    sds_Bottom.Active := True;
    m_oLog.LogINFO('Simple DataSet is Active!');
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.lbResultDblClick(Sender: TObject);
var
  sTable: string;
begin
  if lbResult.ItemIndex < 0 then
  begin
    ShowMessage('No table is selected!');
    exit;
  end;

  if lbResult.Items[lbResult.ItemIndex][1] = ' ' then
  begin
    ShowMessage('The selected item is not a Table Name!');
    exit;
  end;

  if lbResult.Items[lbResult.ItemIndex][1] = '[' then
  begin
    ShowMessage('The selected item is not a Table Name!');
    exit;
  end;

  sTable := lbResult.Items[lbResult.ItemIndex];

  try
    lblTop.Caption := 'N/A (Query, Provider and Client DataSet):';
    cds_Top.Active := False;
    qry_Top.Active := False;
    qry_Top.SQL.Clear();
    qry_Top.SQL.Add('select * from ' + sTable + ';');
    qry_Top.Active := True;
    m_oLog.LogINFO('SQL Query is Active!');
    cds_Top.Active := True;
    m_oLog.LogINFO('Client DataSet is Active!');
    lblTop.Caption := sTable + ' (Query, Provider and Client DataSet):';
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  try
    lblBottom.Caption := 'N/A (Simple DataSet):';
    sds_Bottom.Active := False;
    sds_Bottom.DataSet.CommandText := 'select * from ' + sTable + ';';
    sds_Bottom.Active := True;
    m_oLog.LogINFO('Simple DataSet is Active!');
    lblBottom.Caption := sTable + ' (Simple DataSet):';
  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.chbMetadataTablesOnlyClick(Sender: TObject);
begin
  if btnGetMetadata.Enabled then btnGetMetadata.Click();
end;

procedure TFrmMain.btnGetMetadataClick(Sender: TObject);
var
  iIdx: integer;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin
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
    begin

      con_Firebird.GetFieldNames(sTable, asItems);

      iIdx := iIdx + 1;
      lbResult.Items.Insert(iIdx, '  [Fields]');

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + sItem);
      end;
    end;
    FreeAndNil(asItems);

    // Table Indices
    asItems := TStringList.Create();
    begin

      con_Firebird.GetIndexNames(sTable, asItems);

      iIdx := iIdx + 1;
      lbResult.Items.Insert(iIdx, '  [Indices]');

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + sItem);
      end;
    end;
    FreeAndNil(asItems);

  end;

  lbResult.Items.Insert(0, '[Properties]');

  lbResult.Items.Insert(1, '  Login Username: ' + con_Firebird.GetLoginUsername());

  lbResult.Items.Insert(2, '  Default SchemaName: ' + con_Firebird.GetDefaultSchemaName());

  lbResult.Items.Insert(3, '  Driver Func: ' + con_Firebird.GetDriverFunc);

  lbResult.Items.Insert(4, '[Tables]');

end;

procedure TFrmMain.btnConnectClick(Sender: TObject);
begin

  try

    con_Firebird.Params.Values['Database'] := cbbDb.Text;
    if con_Firebird.Params.Values['Database'].IsEmpty() then
    begin
      raise Exception.Create('No Database specified!');
    end;

    con_Firebird.Params.Values['User_Name'] := m_oDb.ConnectUser;
    con_Firebird.Params.Values['Password' ] := m_oDb.ConnectPassword;

    if (con_Firebird.Params.Values['User_Name'].Length > 0) and (con_Firebird.Params.Values['Password'].Length > 0) then
    begin
      con_Firebird.LoginPrompt := False;
    end;

    m_oLog.LogINFO('Button Connect is Pressed!');

    con_Firebird.Connected := True;

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

    cbbDb.Enabled := False;

    btnConnect.Enabled := False;

    btnGetMetadata.Enabled := True;
    btnCreTbl.Enabled := True;
    btnDrpTbl.Enabled := True;

    btnGetMetadata.Click();

  except
    on exc : Exception do
    begin
      m_oLog.LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

end.
