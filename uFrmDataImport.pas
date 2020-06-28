unit uFrmDataImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstApp,
  Vcl.Grids, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFrmDataImport = class(TForm)
    panLower: TPanel;
    lblCaption: TLabel;
    grpTbl: TGroupBox;
    grpCsv: TGroupBox;
    lblCsvPath: TLabel;
    lblCsvDelim: TLabel;
    lblCsvRowCnt: TLabel;
    lblCsvErrMark: TLabel;
    edCsvPath: TEdit;
    btnCsvOpen: TButton;
    btnCsvPreview: TButton;
    sgrd: TStringGrid;
    edCsvDelim: TEdit;
    chbFstRowIsHeader: TCheckBox;
    edCsvRowCnt: TEdit;
    chbTrimCells: TCheckBox;
    edCsvErrMark: TEdit;
    lblTblCol: TLabel;
    cbbTblCol: TComboBox;
    lblTblCsvCol: TLabel;
    cbbTblCsvCol: TComboBox;
    btnImport: TButton;
    btnPreCheck: TButton;
    btnClose: TButton;
    btnTblColAdd: TButton;
    sgrdDef: TStringGrid;
    btnTblColReset: TButton;
    tmrStart: TTimer;
    chbTblCsvTRIM: TCheckBox;
    lbTree: TListBox;
    chbTblCsvEmpty: TCheckBox;
    btnRememberDef: TButton;
    chbShowTreeDetails: TCheckBox;
    btnSortTree: TButton;
    tvTree: TTreeView;
    lblTblCsvColSep: TLabel;
    edTblCsvColSep: TEdit;
    procedure btnCsvOpenClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCsvPreviewClick(Sender: TObject);
    procedure edCsvDelimChange(Sender: TObject);
    procedure edCsvPathChange(Sender: TObject);
    procedure chbFstRowIsHeaderClick(Sender: TObject);
    procedure edCsvRowCntChange(Sender: TObject);
    procedure chbTrimCellsClick(Sender: TObject);
    procedure edCsvErrMarkChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnTblColAddClick(Sender: TObject);
    procedure btnPreCheckClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnTblColResetClick(Sender: TObject);
    procedure tmrStartTimer(Sender: TObject);
    procedure btnRememberDefClick(Sender: TObject);
    procedure btnSortTreeClick(Sender: TObject);
  private
    { Private declarations }
    m_oApp: TDtTstApp;

    m_bInsertOnly: Boolean;

    m_iIniImportDefIndex: integer;

    m_sTableOrView: string;

    m_asColInfos: TStringList;

    m_oStreamCSV: TStreamReader;
    m_cDelimCSV: char;
    m_asRowCSV: TStringList;
    m_iCsvColCount: integer;
    m_iCsvDataRow: integer;
    m_iCsvFileRow: integer;
    m_bAsked_MoreRowCols, m_bAsked_FewerRowCols: Boolean;

    m_sDefAsString: string;

    m_bDB_TREE: Boolean;
    m_iCol_DB_TREE_NODE   : integer;
    m_iCol_DB_TREE_PARENT : integer;
    m_iCol_DB_TREE_PATH   : integer;
    m_iCol_DB_TREE_LEVEL  : integer;

    m_asTree: TStringList;

    m_iTvTree_WidthEx: integer;
    m_iLbTree_HeightEx: integer;

    procedure ClearPreview();
    procedure ClearPreview_DEF();
    procedure ClearPreview_DB_TREE();

    procedure ShowTreeCtrls();

    function OpenCSV() : Boolean;
    function ReadCSVLine() : Boolean;
    procedure CloseCSV();

    function LoadCSVHeader() : Boolean;
    function LoadNextCSVRow() : Boolean;

    procedure ProcessCSV(bChkOnly: Boolean);

    procedure DB_TREE_Fill(asTree: TStrings);
    procedure DB_TREE_Add(asTree: TStrings; asTblCols, asCsvVals, asCsvCols: TStringList);
    function DB_TREE_AddKey(asTree: TStrings; sKey: string) : string;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    procedure Init(bInsertOnly: Boolean; iIniImportDefIndex: integer; sCaption, sTableOrView: string; asCols, asColInfos: TStringList);

  end;

var
  FrmDataImport: TFrmDataImport;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConsts, uDtTstUtils, uDtTstWin, uDtTstAppDb, uFrmProgress, uDtTstDbSql,
  System.IOUtils, StrUtils, System.Math;

const

  ciSGrdDef_ColIdx_CsvCol = 1;
  ciSGrdDef_ColIdx_DbType = 2;
  ciSGrdDef_ColIdx_DbLen  = 3;
  ciSGrdDef_ColIdx_DbNull = 4;
  ciSGrdDef_ColIdx_FldSep = 5;
  ciSGrdDef_COUNT         = 6;

constructor TFrmDataImport.Create(AOwner: TComponent; oApp: TDtTstApp);
begin

  m_oApp := oApp;

  m_cDelimCSV := ';';

  m_iIniImportDefIndex := -1;

  m_sTableOrView := '';

  m_asColInfos := TStringList.Create();

  m_bDB_TREE := False;
  m_iCol_DB_TREE_NODE   := -1;
  m_iCol_DB_TREE_PARENT := -1;
  m_iCol_DB_TREE_PATH   := -1;
  m_iCol_DB_TREE_LEVEL  := -1;

  m_asTree := TStringList.Create();

  m_iTvTree_WidthEx  := 0;
  m_iLbTree_HeightEx := 0;

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataImport');

  m_oApp.LOG.LogLIFE('TFrmDataImport.Create');
end;

destructor TFrmDataImport.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmDataImport.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataImport');

  CloseCSV();

  m_oApp := nil; // ATTN: Do not Free here!

  FreeAndNil(m_asColInfos);

  FreeAndNil(m_asTree);

  inherited Destroy();
end;

procedure TFrmDataImport.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;

  btnRememberDef.Visible := (m_iIniImportDefIndex < 0);

  edCsvDelim.Text := m_cDelimCSV;

  m_iTvTree_WidthEx  := (tvTree.Left + tvTree.Width) - (grpTbl.Left + grpTbl.Width);
  tvTree.Visible     := False;
  grpTbl.Width       := grpTbl.Width + m_iTvTree_WidthEx;
  lbTree.Visible     := False;
  grpCsv.Width       := grpCsv.Width + m_iTvTree_WidthEx;

  m_iLbTree_HeightEx := (tvTree.Top - lbTree.Top);
  lbTree.Visible     := False;
  tvTree.Top         := tvTree.Top    - m_iLbTree_HeightEx;
  tvTree.Height      := tvTree.Height + m_iLbTree_HeightEx;

  ClearPreview();

  // Registry...
  edCsvPath.Text := LoadStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', m_sTableOrView + '_CSVPath', '');

  tmrStart.Enabled := True;

end;

procedure TFrmDataImport.tmrStartTimer(Sender: TObject);
begin

  tmrStart.Enabled := False;

  if not TEdit_Text(edCsvPath).IsEmpty() then
  begin
    btnCsvPreview.Click();
  end;
end;

procedure TFrmDataImport.Init(bInsertOnly: Boolean; iIniImportDefIndex: integer; sCaption, sTableOrView: string; asCols, asColInfos: TStringList);
begin

  m_bInsertOnly         := bInsertOnly;

  m_iIniImportDefIndex  := iIniImportDefIndex;

  m_sTableOrView        := sTableOrView;

  m_asColInfos.Clear();
  if Assigned(asColInfos) then m_asColInfos.AddStrings(asColInfos);

  if m_oApp.ADMIN_MODE then
  begin
    lblCaption.Caption := 'Importing from CSV File into table ' + sCaption + ' (' + sTableOrView + ')';

    if m_bInsertOnly then
      lblCaption.Caption := lblCaption.Caption + ' (Insert)'
    else
      lblCaption.Caption := lblCaption.Caption + ' (InsertOrUpdate)';
  end
  else
  begin
    lblCaption.Caption := 'Importing from CSV File into table ' + sCaption;
  end;

  cbbTblCol.Items.AddStrings(asCols);

end;

procedure TFrmDataImport.ClearPreview();
begin

  sgrd.RowCount := 1;
  sgrd.ColCount := 1;
  sgrd.Cells[0, 0] := 'N/A';

  grpTbl.Visible := False;

  cbbTblCol   .ItemIndex := -1;
  cbbTblCsvCol.Items.Clear();

  ClearPreview_DEF();
end;

procedure TFrmDataImport.ClearPreview_DEF();
begin

  sgrdDef.RowCount := 1;
  sgrdDef.ColCount := 1;
  sgrdDef.Cells[0, 0] := 'N/A';

  chbTblCsvTRIM .Checked := True;
  chbTblCsvEmpty.Checked := False;

  btnPreCheck   .Enabled := False;
  btnImport     .Enabled := False;
  btnRememberDef.Enabled := False;

  m_sDefAsString := '';

  edTblCsvColSep.Text    := '';
  edTblCsvColSep.Enabled := True;

  ClearPreview_DB_TREE();
end;

procedure TFrmDataImport.ClearPreview_DB_TREE();
begin

  { DB TREE }

  lbTree.Items.Clear();
  lbTree.Sorted := False;

  m_asTree.Clear();

  tvTree.Items.Clear();

  //chbShowTreeDetails.Visible := True; // MUST NOT!!!
  chbShowTreeDetails.Enabled := True;

  btnSortTree       .Visible := False;

  m_bDB_TREE := False;

  m_iCol_DB_TREE_NODE   := -1;
  m_iCol_DB_TREE_PARENT := -1;
  m_iCol_DB_TREE_PATH   := -1;
  m_iCol_DB_TREE_LEVEL  := -1;

end;

procedure TFrmDataImport.ShowTreeCtrls;
begin

  chbShowTreeDetails.Visible := m_oApp.ADMIN_MODE;
  chbShowTreeDetails.Enabled := False;

  btnSortTree       .Visible := chbShowTreeDetails.Checked;

  if not tvTree.Visible then
  begin
    grpCsv.Width   := grpCsv.Width - m_iTvTree_WidthEx;
    grpTbl.Width   := grpTbl.Width - m_iTvTree_WidthEx;
    tvTree.Visible := True;
  end;

  if (chbShowTreeDetails.Checked) and (not lbTree.Visible) then
  begin
    tvTree.Height  := tvTree.Height - m_iLbTree_HeightEx;
    tvTree.Top     := tvTree.Top    + m_iLbTree_HeightEx;
    lbTree.Visible := True;
  end;

  if (not chbShowTreeDetails.Checked) and (lbTree.Visible) then
  begin
    lbTree.Visible := False;
    tvTree.Top     := tvTree.Top    - m_iLbTree_HeightEx;
    tvTree.Height  := tvTree.Height + m_iLbTree_HeightEx;
  end;

end;

procedure TFrmDataImport.edCsvDelimChange(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.edCsvErrMarkChange(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.edCsvPathChange(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.edCsvRowCntChange(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.chbFstRowIsHeaderClick(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.chbTrimCellsClick(Sender: TObject);
begin
  ClearPreview();
end;

procedure TFrmDataImport.btnCloseClick(Sender: TObject);
begin
  Close();
end;

procedure TFrmDataImport.btnPreCheckClick(Sender: TObject);
begin
  ProcessCSV(True {bChkOnly});
end;

procedure TFrmDataImport.btnRememberDefClick(Sender: TObject);
begin
  SaveStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', m_sTableOrView + '_Def', m_sDefAsString);

  InfoMsgDlg('Definitions saved!');
end;

procedure TFrmDataImport.btnSortTreeClick(Sender: TObject);
begin
  lbTree.Sorted := True;
end;

procedure TFrmDataImport.btnImportClick(Sender: TObject);
begin
  ProcessCSV(False {bChkOnly});
end;

procedure TFrmDataImport.btnCsvOpenClick(Sender: TObject);
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
    frmOf.Filter := csCSV_FILE_FILTER + '|All Files (*.*)|*.*';

    // Select .xyz as the starting filter type
    frmOf.FilterIndex := 1;

    // Display the open file dialog
    if not frmOf.Execute then
    begin
      Exit;
    end;

    ClearPreview();

    edCsvPath.Text := frmOf.FileName;

    btnCsvPreview.Click();

  finally
    FreeAndNil(frmOf);
  end;
end;

procedure TFrmDataImport.btnTblColResetClick(Sender: TObject);
begin

  if (sgrdDef.RowCount = 1) and (sgrdDef.ColCount = 1) then Exit;

  if QuestionMsgDlg('Do you want to Clear Import Definition?') then
  begin

    ClearPreview_DEF();

  end;

end;

procedure TFrmDataImport.btnTblColAddClick(Sender: TObject);
var
  asParts, asType: TStringList;
  sInfo: string;
  iRow, iTmp: Integer;
begin

  asParts := TStringList.Create();
  asType  := TStringList.Create();
  try

    if TComboBox_Text(cbbTblCol).IsEmpty() then
    begin
      WarningMsgDlg('Select Table Column!');
      Exit;
    end;

    for iRow := 1 to sgrdDef.RowCount - 1 do
    begin
      if sgrdDef.Cells[0, iRow] = cbbTblCol.Text then
      begin
        WarningMsgDlg('Table Column "' + cbbTblCol.Text + '" already added!');
        Exit;
      end;
    end;

    if chbTblCsvEmpty.Checked then
    begin

      if not TComboBox_Text(cbbTblCsvCol).IsEmpty() then
      begin
        WarningMsgDlg('Do not select CSV Column when "EMPTY text value" is checked!');

        cbbTblCsvCol.ItemIndex := -1;

        Exit;
      end;

    end
    else
    begin

      if TComboBox_Text(cbbTblCsvCol).IsEmpty() then
      begin
        WarningMsgDlg('Select CSV Column!');
        Exit;
      end;

      for iRow := 1 to sgrdDef.RowCount - 1 do
      begin
        if sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, iRow] = cbbTblCsvCol.Text then
        begin
          WarningMsgDlg('CSV Column "' + cbbTblCsvCol.Text + '" already added!');
          Exit;
        end;
      end;

    end;

    if cbbTblCol.ItemIndex < m_asColInfos.Count then
    begin

      sInfo := m_asColInfos[cbbTblCol.ItemIndex];
      sInfo := StringReplace(sInfo,'(' , ';', [rfReplaceAll]);
      sInfo := StringReplace(sInfo,')|', '|', [rfReplaceAll]);

      Split('|', sInfo, asParts);
    end
    else
    begin
      asParts.Add('');
      asParts.Add('');
    end;

    if ContainsText(asParts[0],';') then
    begin
      Split(';', asParts[0], asType);
      asParts[0] := asType[0];
      asParts.Insert(1, asType[1]);
    end
    else
    begin
      asParts.Insert(1, '');
    end;

    if sgrdDef.ColCount = 1 then
    begin
      sgrdDef.ColCount := ciSGrdDef_COUNT;
      sgrdDef.RowCount := 1;

      sgrdDef.Cells[0, 0] := 'Table Column';
      sgrdDef.ColWidths[0] := {Max(sgrdDef.ColWidths[iCol],} Canvas.TextExtent(sgrdDef.Cells[0, 0]).cx + 10 {)};

      sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, 0] := 'CSV Column';
      sgrdDef.ColWidths[ciSGrdDef_ColIdx_CsvCol] := {Max(sgrdDef.ColWidths[iCol],}
          Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, 0]).cx + 10 {)};

      sgrdDef.Cells[ciSGrdDef_ColIdx_DbType, 0] := 'DB Type';
      sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbType] := {Max(sgrdDef.ColWidths[iCol],}
          Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbType, 0]).cx + 10 {)};

      sgrdDef.Cells[ciSGrdDef_ColIdx_DbLen, 0] := 'DB Length';
      sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbLen] := {Max(sgrdDef.ColWidths[iCol],}
          Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbLen, 0]).cx + 10 {)};

      sgrdDef.Cells[ciSGrdDef_ColIdx_DbNull, 0] := 'DB Nullable';
      sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbNull] := {Max(sgrdDef.ColWidths[iCol],}
          Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbNull, 0]).cx + 10 {)};

      sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, 0] := 'CSV Field Separator';
      sgrdDef.ColWidths[ciSGrdDef_ColIdx_FldSep] := {Max(sgrdDef.ColWidths[iCol],}
          Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, 0]).cx + 10 {)};

      btnPreCheck   .Enabled := True;
      btnImport     .Enabled := True;
      btnRememberDef.Enabled := True;

    end;

    sgrdDef.RowCount := sgrdDef.RowCount + 1;

    sgrdDef.Cells[0, sgrdDef.RowCount - 1] := cbbTblCol.Text;
    sgrdDef.ColWidths[0] := Max(sgrd.ColWidths[0], Canvas.TextExtent(sgrdDef.Cells[0, sgrdDef.RowCount - 1]).cx + 10 );

    sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, sgrdDef.RowCount - 1] := cbbTblCsvCol.Text;
    sgrdDef.ColWidths[ciSGrdDef_ColIdx_CsvCol] := Max(sgrdDef.ColWidths[ciSGrdDef_ColIdx_CsvCol],
        Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, sgrdDef.RowCount - 1]).cx + 10 );

    sgrdDef.Cells[ciSGrdDef_ColIdx_DbType, sgrdDef.RowCount - 1] := asParts[0];
    sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbType] := Max(sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbType],
        Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbType, sgrdDef.RowCount - 1]).cx + 10 );

    sgrdDef.Cells[ciSGrdDef_ColIdx_DbLen, sgrdDef.RowCount - 1] := asParts[1];
    sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbLen] := Max(sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbLen],
        Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbLen, sgrdDef.RowCount - 1]).cx + 10 );

    sgrdDef.Cells[ciSGrdDef_ColIdx_DbNull, sgrdDef.RowCount - 1] := asParts[2];
    sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbNull] := Max(sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbNull],
        Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_DbNull, sgrdDef.RowCount - 1]).cx + 10 );

    sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, sgrdDef.RowCount - 1] := TRIM(edTblCsvColSep.Text);
    sgrdDef.ColWidths[ciSGrdDef_ColIdx_FldSep] := Max(sgrdDef.ColWidths[ciSGrdDef_ColIdx_DbNull],
        Canvas.TextExtent(sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, sgrdDef.RowCount - 1]).cx + 10 );

    if     m_sDefAsString.IsEmpty() then m_sDefAsString := Boolean2String(chbTblCsvTrim.Checked);
    if not m_sDefAsString.IsEmpty() then m_sDefAsString := m_sDefAsString + ';';
    m_sDefAsString := m_sDefAsString + cbbTblCol.Text + '|' + cbbTblCsvCol.Text + '|' + Boolean2String(chbTblCsvEmpty.Checked) +
                      '|' + edTblCsvColSep.Text;

    cbbTblCol   .ItemIndex := -1;
    cbbTblCsvCol.ItemIndex := -1;

    chbTblCsvEmpty.Checked := False;

    if not TRIM(edTblCsvColSep.Text).IsEmpty() then
    begin
      edTblCsvColSep.Text    := '';
      edTblCsvColSep.Enabled := False; // ATTN: Allowed ONCE per Def!
    end;


  finally
    FreeAndNil(asParts);
    FreeAndNil(asType);
  end;

end;

function TFrmDataImport.OpenCSV() : Boolean;
begin
  Result := False;

  if TEdit_Text(edCsvPath).IsEmpty() then
  begin
    WarningMsgDlg('No CSV Path specified!');
    Exit;
  end;

  if not FileExists(edCsvPath.Text) then
  begin
    WarningMsgDlg('File "' + edCsvPath.Text + '" does not exist!');
    Exit;
  end;

  if TEdit_Text(edCsvRowCnt).IsEmpty() then
  begin
    WarningMsgDlg('No Preview Row Count specified!');
    Exit;
  end;

  SaveStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', m_sTableOrView + '_CSVPath', edCsvPath.Text);

  if TEdit_Text(edCsvDelim).IsEmpty() then edCsvDelim.Text := ';';
  m_cDelimCSV := TEdit_Text(edCsvDelim)[1];

  try

    m_oStreamCSV := TFile.OpenText(edCsvPath.Text);

    if m_oStreamCSV.EndOfStream then
    begin
      ErrorMsgDlg('File "' + edCsvPath.Text + '" is empty!');
      CloseCSV();
      Exit;
    end;

    m_asRowCSV := TStringList.Create();

    Result := True;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Unable to open file "' + edCsvPath.Text + '"!' + CHR(10) + CHR(10) + 'Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

function TFrmDataImport.ReadCSVLine() : Boolean;
begin
  Result := False;

  try

    Split(m_cDelimCsv, m_oStreamCSV.ReadLine(), m_asRowCSV);

    Result := True;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Unable to read file "' + edCsvPath.Text + '"!' + CHR(10) + CHR(10) + 'Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmDataImport.CloseCSV();
begin

  try

    if Assigned(m_oStreamCSV) then m_oStreamCSV.Close();

  finally

    FreeAndNil(m_asRowCSV);
    FreeAndNil(m_oStreamCSV);

  end;
end;

function TFrmDataImport.LoadCSVHeader() : Boolean;
var
  iCol: integer;
  sCol, sColTitle: string;
begin
  Result := False;

  if not ReadCSVLine() then Exit;

  m_iCsvColCount  := m_asRowCSV.Count;

  sgrd.ColCount := m_asRowCSV.Count;
//sgrd.RowCount := sgrd.RowCount + 1;

//sgrd.Rows[0] := asCols;

  iCol := -1;
  for sCol in m_asRowCSV do
  begin
    iCol := iCol + 1;

    if chbFstRowIsHeader.Checked then
      sColTitle := sCol
    else
      sColTitle := 'Column #' + IntToStr(iCol + 1);

    sgrd.ColWidths[iCol] := {Max(sgrd.ColWidths[iCol],} Canvas.TextExtent(sColTitle).cx + 10 {)};

    sgrd.Cells[iCol, 0] := sColTitle;

    cbbTblCsvCol.Items.Add(sColTitle);
  end;

  if chbFstRowIsHeader.Checked then
  begin
    m_iCsvDataRow := 0;

    if m_oStreamCSV.EndOfStream then
    begin
      ErrorMsgDlg('File "' + edCsvPath.Text + '" has Header Row but NO DATA ROW!!');
      CloseCSV();
      Exit;
    end;
  end
  else
  begin
    m_iCsvDataRow := 1
  end;

  Result := True;
end;

function TFrmDataImport.LoadNextCSVRow() : Boolean;
var
  iCol, iLastCol, iExCol, iExRow: integer;
  sCol, sCell: string;
  bBreak: Boolean;
begin
  Result := False;

  if (chbFstRowIsHeader.Checked) or (m_iCsvFileRow > 1) then
  begin

    if not ReadCSVLine() then Exit;

    m_iCsvDataRow := m_iCsvDataRow + 1;
  end;

  sgrd.RowCount := sgrd.RowCount + 1;

  bBreak := False;

  iCol := -1;
  for sCol in m_asRowCSV do
  begin
    iCol := iCol + 1;

    // CSV ERROR
    if iCol > m_iCsvColCount - 1 {sgrd.ColCount - 1} then
    begin

      if (not m_bAsked_MoreRowCols) and (not QuestionMsgDlg('CSV Data Row #' + IntToStr(m_iCsvDataRow) + ' has MORE (' + IntToStr(m_asRowCSV.Count) +
                          ') cells than expected (' + IntToStr(m_iCsvColCount) + ')!' + CHR(10) + CHR(10) +
                          'Do you want to continue?')) then
      begin
        bBreak := True;
      //Break;
      end;

      m_bAsked_MoreRowCols := True;

      iLastCol := sgrd.ColCount;
      sgrd.ColCount := Max(sgrd.ColCount, m_asRowCSV.Count);

      for iExCol := iLastCol to m_asRowCSV.Count - 1 do
      begin

        sCell := 'Column #' + IntToStr(iExCol + 1);

        sgrd.ColWidths[iExCol] := {Max(sgrd.ColWidths[iCol],} Canvas.TextExtent(sCell).cx + 10 {)};

        sgrd.Cells[iExCol, 0] := sCell;

        for iExRow := 1 to (sgrd.RowCount - 1) - 1 do
        begin
          // ATTN: Left old data will appear!!!
          sgrd.Cells[iExCol, iExRow] := edCsvErrMark.Text;
        end;
      end;
    end;

    if chbTrimCells.Checked then
      sCell := TRIM(sCol)
    else
      sCell := sCol;

    sgrd.ColWidths[iCol] := Max(sgrd.ColWidths[iCol], Canvas.TextExtent(sCell).cx + 10);

    sgrd.Cells[iCol, sgrd.RowCount - 1] := sCell;
  end;

  // ATTN: Left old data will appear!!!
  for iExCol := m_asRowCSV.Count to sgrd.ColCount - 1 do
  begin
    sgrd.Cells[iExCol, sgrd.RowCount - 1] := edCsvErrMark.Text;
  end;

  // CSV ERROR
  if m_asRowCSV.Count < m_iCsvColCount {sgrd.ColCount} then
  begin

    if (not m_bAsked_FewerRowCols) and (not QuestionMsgDlg('ERROR: CSV Data Row #' + IntToStr(m_iCsvDataRow) + ' has FEWER (' + IntToStr(m_asRowCSV.Count) +
                        ') cells than expected (' + IntToStr(m_iCsvColCount) + ')!' + CHR(10) + CHR(10) +
                        'Do you want to continue?')) then
    begin
      Exit;
    end;

    m_bAsked_FewerRowCols := True;
  end;

  Result := (not bBreak); // CSV ERROR
end;

procedure TFrmDataImport.btnCsvPreviewClick(Sender: TObject);
var
  frmPrs: TFrmProgress;
  iPreviewRowCount, iRow: integer;
  bError: Boolean;
  sDefsSaved, sDef: string;
  asDefs, asDefItems: TStringList;
  iIdx : Integer;
begin

  frmPrs := TFrmProgress.Create(self, m_oApp);
  try

    frmPrs.Show();
    frmPrs.Init(False {bCanAbort}, 'Preview CSV File');
    frmPrs.SetProgressToMax();
    frmPrs.AddStepHeader('CSV file "' + edCsvPath.Text + '"');
    Application.ProcessMessages;

    frmPrs.AddStep('Loading Preview');
    Application.ProcessMessages;

    ClearPreview();

    m_bAsked_MoreRowCols  := False;
    m_bAsked_FewerRowCols := False;

    if not OpenCSV() then Exit;

    iPreviewRowCount := StrToInt(edCsvRowCnt.Text);

    if not LoadCSVHeader() then Exit;

    bError := False;
    for iRow := 1 to iPreviewRowCount do
    begin

      if not LoadNextCSVRow() then
      begin

        // CSV ERROR
        bError := True;
        Break;
      end;

      if m_oStreamCSV.EndOfStream then Break;
    end;

    CloseCSV();

    frmPrs.AddStepEnd('Done!');
    Application.ProcessMessages;

    grpTbl.Visible := (not bError);

    sDefsSaved := '';
    if m_iIniImportDefIndex >= 0 then
    begin
      if m_iIniImportDefIndex < (m_oApp as TDtTstAppDb).DB.m_asImportDefs.Count then
      begin
        sDefsSaved := (m_oApp as TDtTstAppDb).DB.m_asImportDefs[m_iIniImportDefIndex];
      end;
    end
    else
    begin
      //Registry
      sDefsSaved := LoadStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', m_sTableOrView + '_Def', '');
    end;

    if not sDefsSaved.IsEmpty() then
    begin

      frmPrs.AddStep('Loading saved Definition');
      Application.ProcessMessages;

      asDefs     := TStringList.Create();
      asDefItems := TStringList.Create();
      try

        Split(';', sDefsSaved, asDefs);

        for sDef in asDefs do
        begin

          if sDef.Length = 1 then
          begin
            chbTblCsvTRIM.Checked := String2Boolean(sDef);
          end
          else
          begin

            Split('|', sDef, asDefItems);

            if (asDefItems.Count = 3) or (asDefItems.Count = 4) then
            begin

              iIdx := cbbTblCol.Items.IndexOf(asDefItems[0]);
              if iIdx < 0 then
              begin
                WarningMsgDlg('Error loading Import Definition!' + CHR(10) + CHR(10) +
                    'Required Table Column "' + asDefItems[0] + '" is not available!');
                Break;
              end;
              cbbTblCol.ItemIndex := iIdx;

              if not asDefItems[1].IsEmpty then
              begin
                iIdx := cbbTblCsvCol.Items.IndexOf(asDefItems[1]);
                if iIdx < 0 then
                begin
                  WarningMsgDlg('Error loading Import Definition!' + CHR(10) + CHR(10) +
                      'Required CSV Column "' + asDefItems[1] + '" is not available!' + CHR(10) + CHR(10) +
                      'TIP: Select CSV file containing required CSV Column!');
                  Break;
                end;
                cbbTblCsvCol.ItemIndex := iIdx;
              end;

              chbTblCsvEmpty.Checked := String2Boolean(asDefItems[2]);

              if asDefItems.Count = 4 then
              begin
                edTblCsvColSep.Text := asDefItems[3];
              end;

              btnTblColAdd.Click();

            end;
          end;

        end;

      finally
        FreeAndNil(asDefs);
        FreeAndNil(asDefItems);
      end;

      frmPrs.AddStepEnd('Done!');
      Application.ProcessMessages;

    end;

    frmPrs.Done();

  finally
    frmPrs.Close();
  end;

end;

procedure TFrmDataImport.ProcessCSV(bChkOnly: Boolean);
var
  frmPrs: TFrmProgress;
  dbSql: TDtTstDbSql;
  asTblCols_NOT_NULL, asTblCols, asDbTypes, asDbLens, asCsvCols, asTreePath: TStringList;
  aiCsvColIndices: TArray<Integer>;
  asCsvVals: TStringList;
  iRow, iCol, iDbLen, iValLen, iTmp: integer;
  sTblCol_NOT_NULL, sTblCol, sCsvVal, sMsg, sTmp, sTreePath: string;
  //ayVal: TBytes;
  bBreak, bHit, bEmptyValueRequested: Boolean;
  iErrCnt: integer;
  asTree: TStrings;

  iCsvCol_FldSep: integer;
  sCsvCol_FldSep: string;
  iSubField: Integer;
  asSubFieldVals: TStringList;
  sSubFieldVals, sSubFieldVal: string;
  iSubFieldVal: integer;
begin

  dbSql               := nil;
  asTblCols_NOT_NULL  := nil;
  asTblCols           := nil;
  asDbTypes           := nil;
  asDbLens            := nil;
  aiCsvColIndices     := nil;
  asCsvCols           := nil;
  asCsvVals           := nil;
  asTreePath          := nil;
  asTree              := nil;

  bBreak  := False;
  iErrCnt := 0;

  frmPrs := TFrmProgress.Create(self, m_oApp);
  try

    frmPrs.Show();
    if bChkOnly then
      frmPrs.Init(True {bCanAbort}, 'Checking CSV File')
    else
      frmPrs.Init(True {bCanAbort}, 'Importing CSV File');
    frmPrs.SetProgressToMax();
    frmPrs.AddStepHeader('CSV file "' + edCsvPath.Text + '"');
    Application.ProcessMessages;

    frmPrs.AddStep('Checking Import definition');
    Application.ProcessMessages;

    iCsvCol_FldSep := -1;
    sCsvCol_FldSep := '';

    if not bChkOnly then
    begin
      dbSql := TDtTstDbSql.Create(m_oApp as TDtTstAppDb);
    end;

    //if not bChkOnly then
    begin

      asTblCols_NOT_NULL := TStringList.Create();

      for iCol := 1 to cbbTblCol.Items.Count - 1 do
      begin
        if ContainsText(m_asColInfos[iCol], '|NOT NULL|') then
        begin
          asTblCols_NOT_NULL.Add(cbbTblCol.Items[iCol]);
        end;
      end;

      asTblCols := TStringList.Create();
      asDbTypes := TStringList.Create();
      asDbLens  := TStringList.Create();
      for iRow := 1 to sgrdDef.RowCount - 1 do
      begin
        asTblCols.Add(sgrdDef.Cells[0, iRow]);

        asDbTypes.Add(sgrdDef.Cells[ciSGrdDef_ColIdx_DbType, iRow]);

        asDbLens .Add(sgrdDef.Cells[ciSGrdDef_ColIdx_DbLen, iRow]);

        if not sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, iRow].IsEmpty() then
        begin
          iCsvCol_FldSep := iRow - 1;
          sCsvCol_FldSep := sgrdDef.Cells[ciSGrdDef_ColIdx_FldSep, iRow];
        end;

      end;

      // ATTN: NOT NULL Columns have to get CSV Value!
      for sTblCol_NOT_NULL in asTblCols_NOT_NULL do
      begin
        bHit := False;

        for sTblCol in asTblCols do
        begin
          if sTblCol_NOT_NULL = sTblCol then
          begin
            bHit := True;
            Break;
          end;
        end;

        if not bHit then
        begin

          sMsg := 'ERROR: Table Column "' + sTblCol_NOT_NULL + '" has to get Value from CSV file! Cannot be NULL!';

          frmPrs.AddStep(sMsg);
          Application.ProcessMessages;

          sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

          iErrCnt := iErrCnt + 1;
          if not ErrorQuestionMsgDlg(sMsg) then
          begin
            bBreak := True;
            Break;
          end;

        end;

      end;

      { DB TREE }

      ClearPreview_DB_TREE();

      // ATTN!!!
      if chbShowTreeDetails.Checked then
        asTree := lbTree.Items
      else
        asTree := m_asTree;

      for iRow := 1 to sgrdDef.RowCount - 1 do
      begin
        sTblCol := sgrdDef.Cells[0, iRow];

        if {EndsText not worked!} ContainsText(sTblCol, csDB_TREE_NODE) then
        begin
          m_bDB_TREE := True;
          ShowTreeCtrls();

          m_iCol_DB_TREE_NODE := iRow - 1;

          sTblCol := TRIM(sTblCol.Replace(csDB_TREE_NODE, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sTblCol, csDB_TREE_PARENT) then
        begin
          m_bDB_TREE := True;
          ShowTreeCtrls();

          m_iCol_DB_TREE_PARENT := iRow - 1;

          sTblCol := TRIM(sTblCol.Replace(csDB_TREE_PARENT, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sTblCol, csDB_TREE_PATH) then
        begin
          m_bDB_TREE := True;
          ShowTreeCtrls();

          m_iCol_DB_TREE_PATH := iRow - 1;

          sTblCol := TRIM(sTblCol.Replace(csDB_TREE_PATH, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sTblCol, csDB_TREE_LEVEL) then
        begin
          m_bDB_TREE := True;
          ShowTreeCtrls();

          m_iCol_DB_TREE_LEVEL := iRow - 1;

          sTblCol := TRIM(sTblCol.Replace(csDB_TREE_LEVEL, '', [rfReplaceAll]));
        end;

        asTblCols[iRow - 1] := sTblCol;
      end;

      if m_bDB_TREE then
      begin

        sMsg := '';

        if m_iCol_DB_TREE_NODE < 0 then
        begin
          if sMsg.IsEmpty() then
            sMsg := 'ERROR: '
          else
            sMsg := sMsg + CHR(10) + CHR(10);

          sMsg := sMsg + 'Required column (ending with) "' + csDB_TREE_NODE + '" is not defined!';
        end;

        if m_iCol_DB_TREE_PARENT < 0 then
        begin
          if sMsg.IsEmpty() then
            sMsg := 'ERROR: '
          else
            sMsg := sMsg + CHR(10) + CHR(10);

          sMsg := sMsg + 'Required column (ending with) "' + csDB_TREE_PARENT + '" is not defined!';
        end;

        if m_iCol_DB_TREE_PATH < 0 then
        begin
          if sMsg.IsEmpty() then
            sMsg := 'ERROR: '
          else
            sMsg := sMsg + CHR(10) + CHR(10);

          sMsg := sMsg + 'Required column (ending with) "' + csDB_TREE_PATH + '" is not defined!';
        end;

        if m_iCol_DB_TREE_LEVEL < 0 then
        begin
          if sMsg.IsEmpty() then
            sMsg := 'ERROR: '
          else
            sMsg := sMsg + CHR(10) + CHR(10);

          sMsg := sMsg + 'Required column (ending with) "' + csDB_TREE_LEVEL + '" is not defined!';
        end;

        if not sMsg.IsEmpty() then
        begin

          frmPrs.AddStep(sMsg);
          Application.ProcessMessages;

          //sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

          iErrCnt := iErrCnt + 1;
          {if not ErrorQuestionMsgDlg} ErrorMsgDlg(sMsg); { then
          begin}
            bBreak := True;
            {Break;
          end;}
        end;

      end;

      if not bBreak then
      begin

        asCsvCols := TStringList.Create();

        aiCsvColIndices := TArray<Integer>.Create();
        SetLength(aiCsvColIndices, sgrdDef.RowCount);
        for iRow := 1 to sgrdDef.RowCount - 1 do
        begin

          aiCsvColIndices[iRow - 1] := -1;

          for iCol := 0 to sgrd.ColCount - 1 do
          begin
            if sgrd.Cells[iCol, 0] = sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, iRow] then
            begin
              aiCsvColIndices[iRow - 1] := iCol;
              Break;
            end;
          end;

          if aiCsvColIndices[iRow - 1] = -1 then
          begin
            // CHNG: Case of Empty Text Value!
            //raise Exception.Create('CSV Column "' + sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, iRow] + '" not found!');
          end;

          asCsvCols.Add(sgrdDef.Cells[ciSGrdDef_ColIdx_CsvCol, iRow]);

        end;

        asCsvVals := TStringList.Create;

      end;
    end;

    if iErrCnt = 0 then frmPrs.AddStepEnd('Done!');
    Application.ProcessMessages;

    iErrCnt := 0;

    if not bBreak then
    begin

      //ClearPreview();

      //m_bAsked_MoreRowCols  := False;
      //m_bAsked_FewerRowCols := False;

      frmPrs.AddStep('Opening file');
      Application.ProcessMessages;

      if not OpenCSV() then Exit;

      frmPrs.AddStepEnd('Done!');
      Application.ProcessMessages;

      frmPrs.AddStep('Loading CSV Header');
      Application.ProcessMessages;

      if not LoadCSVHeader() then Exit;

      frmPrs.AddStepEnd('Done!');
      Application.ProcessMessages;

      frmPrs.AddStep('Loading CSV Data');
      Application.ProcessMessages;

    end;

    while (not bBreak) do
    begin

      if frmPrs.AbortPressed then
      begin
        if QuestionMsgDlg('Do you want to Abort Import?') then
        begin
          bBreak := True;
          Break;
        end
        else
        begin
          frmPrs.AbortPressed := False;
        end;
      end;

      if sgrd.RowCount > 1 then
      begin
        sgrd.RowCount := 1;
      end;

      if not LoadNextCSVRow() then
      begin

        // CSV ERROR
        Break;
      end;

      Application.ProcessMessages;

      //if not bChkOnly then
      begin

        asCsvVals.Clear;

        for iCol := 0 to asTblCols.Count - 1 do
        begin

          bEmptyValueRequested := False;

          if aiCsvColIndices[iCol] < 0 then
          begin
            bEmptyValueRequested := True;
            sCsvVal := ''; // CHNG: Case of Empty Text Value
          end
          else if aiCsvColIndices[iCol] >= m_asRowCSV.Count then
            sCsvVal := ''
          else
            sCsvVal := m_asRowCSV[aiCsvColIndices[iCol]];

          { CSV Value CORRECTION }

          if chbTblCsvTRIM.Checked then
          begin
            sCsvVal := TRIM(sCsvVal);
            {
          //sCsvVal := sCsvVal.Replace(CHR( 9), '', [rfReplaceAll]);
            sCsvVal := sCsvVal.Replace(CHR(13), '', [rfReplaceAll]);
            sCsvVal := sCsvVal.Replace(CHR(10), '', [rfReplaceAll]);
            }
          end
          else
          begin
          //sCsvVal := sCsvVal.Replace(CHR( 9), '\t', [rfReplaceAll]);
            sCsvVal := sCsvVal.Replace(CHR(13), '\r', [rfReplaceAll]);
            sCsvVal := sCsvVal.Replace(CHR(10), '\n', [rfReplaceAll]);
          end;

          { CHECK - INTEGER }
          if asDbTypes[iCol] = 'INTEGER' then
          begin

            if bEmptyValueRequested then
            begin
              sCsvVal := '0';
            end
            else if not Integer.TryParse(sCsvVal, iTmp) then
            begin

              sTmp := sCsvVal;
              sTmp := sTmp.Replace(CHR( 9), '\t', [rfReplaceAll]);
              sTmp := sTmp.Replace(CHR(13), '\r', [rfReplaceAll]);
              sTmp := sTmp.Replace(CHR(10), '\n', [rfReplaceAll]);

              sMsg := 'ERROR: Value "' + sTmp + '" of CSV Column "' + asCsvCols[iCol] +
                      '" in CSV Data Row #' + IntToStr(m_iCsvDataRow) +
                      ' is not Number (' + asDbTypes[iCol] + ')!';

              frmPrs.AddStep(sMsg);
              Application.ProcessMessages;

              sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

              iErrCnt := iErrCnt + 1;
              if not ErrorQuestionMsgDlg(sMsg) then
              begin
                bBreak := True;
                Break;
              end;

            end;

          end;

          { CHECK - DB Length }
          if not asDbLens[iCol].IsEmpty() then
          begin

            iDbLen := StrToInt(asDbLens[iCol]);

            // BUG: NOT REQUIRED!!! TESTED with DB's Defalut Charset = UTF8!
            {
            if (m_oApp as TDtTstAppDb).DB.UTF8 then
            begin
              // ATTN: UTF8 raw byte len!!!
              ayVal   := TEncoding.UTF8.GetBytes(sCsvVal);
              iValLen := Length(ayVal);
            end
            else
            begin
            }
              iValLen := sCsvVal.Length;
            {
            end;
            }

            if (iValLen > iDbLen) and
               {ATTN: Multi-value CSV Cell!!!} (iCol <> iCsvCol_FldSep) then
            begin

              sMsg := 'ERROR: Length (' + IntToStr(iValLen) + ') of CSV Column "' + asCsvCols[iCol] +
                      '" in CSV Data Row #' + IntToStr(m_iCsvDataRow) +
                      ' is GREATER than expected by Table Column "' + asTblCols[iCol] +
                      '" Length (' + IntToStr(iDbLen) + ')!';

              // BUG: NOT REQUIRED!!! TESTED with DB's Defalut Charset = UTF8!
              {
              if (m_oApp as TDtTstAppDb).DB.UTF8 then
              begin
                sMsg := sMsg + CHR(10) + CHR(10) + 'NOTE: Charset is UTF8!';
              end;
              }

              frmPrs.AddStep(sMsg);
              Application.ProcessMessages;

              sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

              iErrCnt := iErrCnt + 1;
              if not ErrorQuestionMsgDlg(sMsg) then
              begin
                bBreak := True;
                Break;
              end;

            end;
          end;

          asCsvVals.Add(sCsvVal);
        end;

        if bBreak then Break;

        if m_bDB_TREE then
        begin

            try

              if iCsvCol_FldSep >= 0 then
              begin
                raise Exception.Create('CSV Field Separator is not supported in TREE!');
              end;

              DB_TREE_Add(asTree, asTblCols, asCsvVals, asCsvCols);

            except
              on exc : Exception do
              begin
                m_oApp.LOG.LogERROR(exc);

                sMsg := 'ERROR: Inserting CSV Data Row #' + IntToStr(m_iCsvDataRow) + '!' + CHR(10) + CHR(10) + 'Error: ' + exc.ClassName + ' - ' + exc.Message;

                frmPrs.AddStep(sMsg);
                Application.ProcessMessages;

                sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

                iErrCnt := iErrCnt + 1;
                if not ErrorQuestionMsgDlg(sMsg) then
                begin
                  bBreak := True;
                  Break;
                end;
              end;
            end;

        end
        else
        begin
          if not bChkOnly then
          begin

            if iCsvCol_FldSep >= 0 then
            begin

              asSubFieldVals := TStringList.Create();
              try

                sSubFieldVals := asCsvVals[iCsvCol_FldSep];

                Split(sCsvCol_FldSep[1], sSubFieldVals, asSubFieldVals);

                for iSubField := 0 to asSubFieldVals.Count - 1 do
                begin
                  sSubFieldVal := asSubFieldVals[iSubField];

                  if chbTrimCells.Checked then
                  begin
                    sSubFieldVal := TRIM(sSubFieldVal);
                  end;

                  asCsvVals[iCsvCol_FldSep] := sSubFieldVal;

                  try

                    if m_bInsertOnly then
                      dbSql.Insert(m_sTableOrView, asTblCols, asCsvVals)
                    else
                      dbSql.InsertOrUpdate(m_sTableOrView, asTblCols, asCsvVals);

                  except
                    on exc : Exception do
                    begin
                      m_oApp.LOG.LogERROR(exc);

                      sMsg := 'ERROR: Inserting CSV Data Row #' + IntToStr(m_iCsvDataRow) +
                              ', multi-value CSV Cell "' + sSubFieldVals + '", Sub Cell #' + IntToStr(iSubField + 1) +
                              ' value "' + sSubFieldVal + '"!' +  CHR(10) + CHR(10) +
                              'Error: ' + exc.ClassName + ' - ' + exc.Message;

                      frmPrs.AddStep(sMsg);
                      Application.ProcessMessages;

                      sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

                      iErrCnt := iErrCnt + 1;
                      if not ErrorQuestionMsgDlg(sMsg) then
                      begin
                        bBreak := True;
                        Break;
                      end;
                    end;
                  end;

                  if bBreak then Break;

                end;

              finally
                FreeAndNil(asSubFieldVals);
              end;

            end
            else
            begin

              try

                if m_bInsertOnly then
                  dbSql.Insert(m_sTableOrView, asTblCols, asCsvVals)
                else
                  dbSql.InsertOrUpdate(m_sTableOrView, asTblCols, asCsvVals);

              except
                on exc : Exception do
                begin
                  m_oApp.LOG.LogERROR(exc);

                  sMsg := 'ERROR: Inserting CSV Data Row #' + IntToStr(m_iCsvDataRow) + '!' + CHR(10) + CHR(10) + 'Error: ' + exc.ClassName + ' - ' + exc.Message;

                  frmPrs.AddStep(sMsg);
                  Application.ProcessMessages;

                  sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

                  iErrCnt := iErrCnt + 1;
                  if not ErrorQuestionMsgDlg(sMsg) then
                  begin
                    bBreak := True;
                    Break;
                  end;
                end;
              end;

            end;

          end;
        end;

      end;

      if bBreak then Break;

      if m_oStreamCSV.EndOfStream then Break;
    end;

    CloseCSV();

    if m_bDB_TREE then
    begin

      DB_TREE_Fill(asTree);

      if not bChkOnly then
      begin

        asTreePath := TStringList.Create();

        for sTreePath in asTree do
        begin

          try

              Split(sTreePath[1], sTreePath.Substring(2, sTreePath.Length - 4), asTreePath);

              asCsvVals[m_iCol_DB_TREE_NODE]   := asTreePath[asTreePath.Count - 1];
              asCsvVals[m_iCol_DB_TREE_PARENT] := ''; // ATTN: Not stored!
              asCsvVals[m_iCol_DB_TREE_PATH]   := sTreePath.Replace(sTreePath[1], csDB_TREE_Delimiter);
              asCsvVals[m_iCol_DB_TREE_LEVEL]  := IntToStr(asTreePath.Count);

              // ATTN: DO NOT INSERT only HERE!!!
              dbSql.InsertOrUpdate(m_sTableOrView, asTblCols, asCsvVals);

          except
            on exc : Exception do
            begin
              m_oApp.LOG.LogERROR(exc);

              sMsg := 'ERROR: Inserting DB TREE Rows!' + CHR(10) + CHR(10) + 'Error: ' + exc.ClassName + ' - ' + exc.Message;

              frmPrs.AddStep(sMsg);
              Application.ProcessMessages;

              sMsg := sMsg + CHR(10) + CHR(10) + 'Do you want to continue?';

              iErrCnt := iErrCnt + 1;
              if not ErrorQuestionMsgDlg(sMsg) then
              begin
                bBreak := True;
                Break;
              end;
            end;
          end;

        end;

      end;

    end;

    if bBreak then
    begin
      frmPrs.AddStep('ERROR! User cancelled opertation!');
    end
    else
    begin
      if iErrCnt = 0 then frmPrs.AddStepEnd('Done!');
    end;
    Application.ProcessMessages;

    frmPrs.Done();
    while frmPrs.Visible do Application.ProcessMessages;

    if not bChkOnly then
    begin
      Close();
    end;

  finally

    sgrd.RowCount := 1;
  //sgrd.ColCount := 1;
  //sgrd.Cells[0, 0] := 'N/A';

    frmPrs.Close();
    FreeAndNil(frmPrs);

    FreeAndNil(asTblCols_NOT_NULL);
    FreeAndNil(asTblCols);
    FreeAndNil(asDbTypes);
    FreeAndNil(asDbLens);

    //FreeAndNil(aiCsvColIndices); //MUST NOT!!!

    FreeAndNil(asCsvCols);

    FreeAndNil(asCsvVals);

    FreeAndNil(asTreePath);

    //FreeAndNil(asTree); //MUST NOT!!!

    FreeAndNil(dbSql);
  end;

end;

procedure TFrmDataImport.DB_TREE_Fill(asTree: TStrings);
var
  sKey, sNode: string;
  asTreePath: TStringList;
  tn, tnTmp: TTreeNode;
  i: Integer;
begin

  tvTree.Items.Clear();

  asTreePath := TStringList.Create();
  try

    for sKey in asTree do
    begin

      Split(sKey[1], sKey.Substring(2, sKey.Length - 4), asTreePath);

      tn := nil;
      for sNode in asTreePath do
      begin

        if tn = nil then
        begin

          for i := 0 to tvTree.Items.Count - 1 do
          begin
            if tvTree.Items[i].Text = sNode then
            begin
              tn := tvTree.Items[i];
            end;
          end;

          if tn = nil then
          begin
            tn := tvTree.Items.AddChild(nil, sNode);
          end;

        end
        else
        begin

          tnTmp := tn.getFirstChild();
          while tnTmp <> nil do
          begin

            if tnTmp.Text = sNode then
            begin
              tn := tnTmp;
              Break;
            end;

            tnTmp := tn.GetNextChild(tnTmp);
          end;

          if tnTmp = nil then
          begin
            tn.Expanded := True;
            tn := tvTree.Items.AddChild(tn, sNode);
          end;

        end;

      end;

    end;

  finally
    FreeAndNil(asTreePath);
  end;


end;

procedure TFrmDataImport.DB_TREE_Add(asTree: TStrings; asTblCols, asCsvVals, asCsvCols: TStringList);
var
  cKeyDelim: char;
  sDblKeyDelim: string;
  sNode, sParent, sKeyStart: string;
begin

  cKeyDelim    := ';';
  sDblKeyDelim := ';;';

  sNode := asCsvVals[m_iCol_DB_TREE_NODE];

  if sNode.IsEmpty then
  begin
    raise Exception.Create('Tree Node cannot be empty!');
  end;

  sParent := asCsvVals[m_iCol_DB_TREE_PARENT];

  if sParent.IsEmpty() then
  begin
    DB_TREE_AddKey (asTree, sDblKeyDelim + sNode + sDblKeyDelim);
  end
  else
  begin
    sKeyStart := DB_TREE_AddKey (asTree, sDblKeyDelim + sParent + sDblKeyDelim);
    DB_TREE_AddKey (asTree, {sDblKeyDelim + sParent + cKeyDelim} sKeyStart + sNode + sDblKeyDelim);
  end;

  // DEBUG...
  //asTree.Add(sParent + '|' + sNode)

  {
  m_iCol_DB_TREE_NODE   := -1;
  m_iCol_DB_TREE_PARENT := -1;
  m_iCol_DB_TREE_PATH   := -1;
  m_iCol_DB_TREE_LEVEL  := -1;
  }

end;

function TFrmDataImport.DB_TREE_AddKey(asTree: TStrings; sKey: string) : string;
var
  sKeyEnd, sKeyStart, sNewKeyStart: string;
  iIdx, iCmp, iIdxSub, iPos, iIdxSubSub, iCmpSubSub, iIdxMoveTo: integer;
  bExists: Boolean;
begin
  Result := sKey.Substring(0, sKey.Length - 1);

  { Looking for Key }

  sKeyEnd := sKey.Substring(1);

  iIdx := -1;
  while True do
  begin
    iIdx := iIdx + 1;

    if iIdx >= asTree.Count then Break;

    if ContainsText(asTree[iIdx], sKeyEnd) then
    begin
      Result := asTree[iIdx].Substring(0, asTree[iIdx].Length - 1); // - sKeyEnd.Length);

      Exit;
    end;

  end;

  { Inserting new Key }

  iIdx := -1;
  while True do
  begin
    iIdx := iIdx + 1;

    if iIdx >= asTree.Count then Break;

    iCmp := CompareText(sKey, asTree[iIdx]);

    if iCmp = 0 then
      Exit; // Exists!

    if iCmp < 0 then
      Break; // Sorted!
  end;

  if iIdx >= asTree.Count then
    asTree.Add(sKey)
  else
    asTree.Insert(iIdx, sKey);

  // DEBUG...
  //Exit;

  { Updating existing Keys }

  sNewKeyStart := sKey.Substring(0, sKey.Length - 1);

  iPos := sKey.Substring(2).IndexOf(';');
  sKeyStart := ';' + sKey.Substring(2 + iPos, sKey.Length - (2 + iPos + 1));
  if sKeyStart.Length > 3 then
  begin

    iIdxMoveTo := -1;

    iIdxSub := -1;
    while True do
    begin
      iIdxSub := iIdxSub + 1;

      if iIdxSub >= asTree.Count then Break;

      if iIdxSub <> iIdx then
      begin

        iCmp := CompareText(sKeyStart, asTree[iIdxSub].Substring(0, sKeyStart.Length));

        if StartsText(sKeyStart, asTree[iIdxSub]) then
        begin

          bExists := False;

          if iIdxMoveTo < 0 then
          begin
            iIdxSubSub := -1;
            while True do
            begin
              iIdxSubSub := iIdxSubSub + 1;

              if iIdxSubSub >= asTree.Count then Break;

              iCmpSubSub := CompareText(sKeyStart + sKeyStart[2], asTree[iIdxSubSub]);

              if iCmpSubSub = 0 then
              begin
                bExists := True;
                Break; // Exists!
              end;

              if iCmpSubSub < 0 then Break; // Sorted!
            end;
          end;

          if bExists then
          begin
            iIdxMoveTo := iIdx + 1; // ATTN: Each further keys here are Children of this!!!

            asTree.Delete(iIdxSub);
            iIdxSub := iIdxSub - 1;

          end
          else
          begin
            if iIdxMoveTo >= 0 then
            begin

              asTree.Insert(iIdxMoveTo, sNewKeyStart + asTree[iIdxSub].Substring(sKeyStart.Length));

              if iIdxMoveTo <= iIdxSub then
                iIdxSub := iIdxSub + 1;

              iIdxMoveTo := iIdxMoveTo + 1;

              asTree.Delete(iIdxSub);
              iIdxSub := iIdxSub - 1;

              if iIdxMoveTo > iIdxSub then
                iIdxMoveTo := iIdxMoveTo - 1;
            end
            else
            begin
              asTree[iIdxSub] := sNewKeyStart + asTree[iIdxSub].Substring(sKeyStart.Length);
            end;
          end;

        end;

        if iCmp < 0 then Break; // Sorted!

      end;
    end;

  end;

end;

end.
