unit uFrmDataImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstApp,
  Vcl.Grids, Vcl.ExtCtrls;

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
  private
    { Private declarations }
    m_oApp: TDtTstApp;

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

    procedure ClearPreview();
    procedure ClearPreview_DEF();

    function OpenCSV() : Boolean;
    function ReadCSVLine() : Boolean;
    procedure CloseCSV();

    function LoadCSVHeader() : Boolean;
    function LoadNextCSVRow() : Boolean;

    procedure ProcessCSV(bChkOnly: Boolean);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    procedure Init(sCaption, sTableOrView: string; asCols, asColInfos: TStringList);

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

constructor TFrmDataImport.Create(AOwner: TComponent; oApp: TDtTstApp);
begin

  m_oApp := oApp;

  m_cDelimCSV := ';';

  m_sTableOrView := '';

  m_asColInfos := TStringList.Create();

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

  inherited Destroy();
end;

procedure TFrmDataImport.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;

  edCsvDelim.Text := m_cDelimCSV;

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

procedure TFrmDataImport.Init(sCaption, sTableOrView: string; asCols, asColInfos: TStringList);
begin

  m_sTableOrView := sTableOrView;

  m_asColInfos.Clear();
  if Assigned(asColInfos) then m_asColInfos.AddStrings(asColInfos);

  if m_oApp.ADMIN_MODE then
  begin
    lblCaption.Caption := 'Importing from CSV File into table ' + sCaption + ' (' + sTableOrView + ')';
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
      sgrdDef.ColCount := 5;
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

    if     m_sDefAsString.IsEmpty() then m_sDefAsString := Boolean2String(chbTblCsvTrim.Checked);
    if not m_sDefAsString.IsEmpty() then m_sDefAsString := m_sDefAsString + ';';
    m_sDefAsString := m_sDefAsString + cbbTblCol.Text + '|' + cbbTblCsvCol.Text + '|' + Boolean2String(chbTblCsvEmpty.Checked);

    cbbTblCol   .ItemIndex := -1;
    cbbTblCsvCol.ItemIndex := -1;

    chbTblCsvEmpty.Checked := False;

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
    frmPrs.Init('Preview CSV File');
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

    //Registry
    sDefsSaved := LoadStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', m_sTableOrView + '_Def', '');
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

            if asDefItems.Count = 3 then
            begin

              iIdx := cbbTblCol.Items.IndexOf(asDefItems[0]);
              if iIdx < 0 then Break;
              cbbTblCol.ItemIndex := iIdx;

              if not asDefItems[1].IsEmpty then
              begin
                iIdx := cbbTblCsvCol.Items.IndexOf(asDefItems[1]);
                if iIdx < 0 then Break;
                cbbTblCsvCol.ItemIndex := iIdx;
              end;

              chbTblCsvEmpty.Checked := String2Boolean(asDefItems[2]);

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
  asTblCols_NOT_NULL, asTblCols, asDbTypes, asDbLens, asCsvCols: TStringList;
  aiCsvColIndices: TArray<Integer>;
  asCsvVals: TStringList;
  iRow, iCol, iDbLen, iValLen, iTmp: integer;
  sTblCol_NOT_NULL, sTblCol, sCsvVal, sMsg, sTmp: string;
  //ayVal: TBytes;
  bBreak, bHit, bEmptyValueRequested: Boolean;
  iErrCnt: integer;
begin

  dbSql               := nil;
  asTblCols_NOT_NULL  := nil;
  asTblCols           := nil;
  asDbTypes           := nil;
  asDbLens            := nil;
  aiCsvColIndices     := nil;
  asCsvCols           := nil;
  asCsvVals           := nil;

  bBreak  := False;
  iErrCnt := 0;

  frmPrs := TFrmProgress.Create(self, m_oApp);
  try

    frmPrs.Show();
    if bChkOnly then
      frmPrs.Init('Checking CSV File')
    else
      frmPrs.Init('Importing CSV File');
    frmPrs.SetProgressToMax();
    frmPrs.AddStepHeader('CSV file "' + edCsvPath.Text + '"');
    Application.ProcessMessages;

    frmPrs.AddStep('Checking Import definition');
    Application.ProcessMessages;

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

          sMsg := 'ERROR: Table Column "' + sTblCol_NOT_NULL + '" has to get Value from CSV file! Cannot be NULL';

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

            if iValLen > iDbLen then
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

        if not bChkOnly then
        begin

          try

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

      if bBreak then Break;

      if m_oStreamCSV.EndOfStream then Break;
    end;

    CloseCSV();

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

    FreeAndNil(dbSql);
  end;

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

procedure TFrmDataImport.btnImportClick(Sender: TObject);
begin
  ProcessCSV(False {bChkOnly});
end;

end.
