unit uFrmDataImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstLog, Vcl.Grids;

type
  TFrmDataImport = class(TForm)
    grpCsv: TGroupBox;
    lblCsvPath: TLabel;
    edCsvPath: TEdit;
    btnCsvOpen: TButton;
    btnCsvPreview: TButton;
    sgrd: TStringGrid;
    lblCsvDelim: TLabel;
    edCsvDelim: TEdit;
    chbFstRowIsHeader: TCheckBox;
    lblCsvRowCnt: TLabel;
    edCsvRowCnt: TEdit;
    chbTrimCells: TCheckBox;
    lblCsvErrMark: TLabel;
    edCsvErrMark: TEdit;
    procedure btnCsvOpenClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCsvPreviewClick(Sender: TObject);
    procedure edCsvDelimChange(Sender: TObject);
    procedure edCsvPathChange(Sender: TObject);
    procedure chbFstRowIsHeaderClick(Sender: TObject);
    procedure edCsvRowCntChange(Sender: TObject);
    procedure chbTrimCellsClick(Sender: TObject);
    procedure edCsvErrMarkChange(Sender: TObject);
  private
    { Private declarations }
    m_oLog: TDtTstLog;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oLog: TDtTstLog); reintroduce;
    destructor Destroy(); override;

    procedure ClearPreview();
  end;

var
  FrmDataImport: TFrmDataImport;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstUtils, uDtTstWin, uDtTstConsts,
  System.IOUtils, StrUtils, System.Math;

constructor TFrmDataImport.Create(AOwner: TComponent; oLog: TDtTstLog);
begin

  m_oLog := oLog;

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataImport');

  m_oLog.LogLIFE('TFrmProgress.Create');
end;

destructor TFrmDataImport.Destroy();
begin
  m_oLog.LogLIFE('TFrmProgress.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataImport');

  m_oLog := nil; // ATTN: Do not Free here!

  inherited Destroy();
end;

procedure TFrmDataImport.ClearPreview();
begin

  sgrd.RowCount := 1;
  sgrd.ColCount := 1;
  sgrd.Cells[0, 0] := 'N/A';

end;

procedure TFrmDataImport.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;

  ClearPreview();

  edCsvPath.Text := LoadStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', 'CSVPath', '');

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

  finally
    FreeAndNil(frmOf);
  end;
end;

procedure TFrmDataImport.btnCsvPreviewClick(Sender: TObject);
var
  iPreviewRowCount: integer;
  asCols: TStringList;
  strmCsv: TStreamReader;
  cDelim: char;
  sLn: string;
  iCsvColCount, iCol, iRow, iCsvRow, iLastCol, iExCol, iExRow: integer;
  sCol, sCell: string;
  bBreak, bAsked: Boolean;
begin

  ClearPreview();

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

  SaveStringReg(csCOMPANY, csPRODUCT, 'Settings\Import', 'CSVPath', edCsvPath.Text);

  asCols  := TStringList.Create();
  strmCsv := TFile.OpenText(edCsvPath.Text);
  try

    cDelim := ';';
    if TEdit_Text(edCsvDelim).IsEmpty() then
      edCsvDelim.Text := cDelim
    else
      cDelim := TEdit_Text(edCsvDelim)[1];

    iPreviewRowCount := StrToInt(edCsvRowCnt.Text);

    sLn := strmCsv.ReadLine();
    Split(cDelim, sLn, asCols);

    iCsvColCount  := asCols.Count;

    sgrd.ColCount := asCols.Count;
  //sgrd.RowCount := sgrd.RowCount + 1;

  //sgrd.Rows[0] := asCols;

    iCol := -1;
    for sCol in asCols do
    begin
      iCol := iCol + 1;

      if chbFstRowIsHeader.Checked then
        sCell := sCol
      else
        sCell := 'Column #' + IntToStr(iCol + 1);

      sgrd.ColWidths[iCol] := {Max(sgrd.ColWidths[iCol],} Canvas.TextExtent(sCell).cx + 10 {)};

      sgrd.Cells[iCol, 0] := sCell;
    end;

    if chbFstRowIsHeader.Checked then
      iCsvRow := 0
    else
      iCsvRow := 1;

    bBreak := False;
    for iRow := 1 to iPreviewRowCount do
    begin

      if (chbFstRowIsHeader.Checked) or (iRow > 1) then
      begin
        sLn := strmCsv.ReadLine();
        Split(cDelim, sLn, asCols);

        iCsvRow := iCsvRow + 1;
      end;

      sgrd.RowCount := sgrd.RowCount + 1;

      bAsked := False;

      iCol := -1;
      for sCol in asCols do
      begin
        iCol := iCol + 1;

        // CSV ERROR
        if iCol > iCsvColCount - 1 {sgrd.ColCount - 1} then
        begin

          if (not bAsked) and (not QuestionMsgDlg('CSV Data Row #' + IntToStr(iCsvRow) + ' has MORE (' + IntToStr(asCols.Count) +
                              ') cells than expected (' + IntToStr(iCsvColCount) + ')!' + CHR(10) + CHR(10) +
                              'Do you want to continue?')) then
          begin
            bBreak := True;
          //Break;
          end;

          bAsked := True;

          iLastCol := sgrd.ColCount;
          sgrd.ColCount := Max(sgrd.ColCount, asCols.Count);

          for iExCol := iLastCol to asCols.Count - 1 do
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
      for iExCol := asCols.Count to sgrd.ColCount - 1 do
      begin
        sgrd.Cells[iExCol, sgrd.RowCount - 1] := edCsvErrMark.Text;
      end;

      // CSV ERROR
      if asCols.Count < iCsvColCount {sgrd.ColCount} then
      begin

        if not QuestionMsgDlg('ERROR: CSV Data Row #' + IntToStr(iCsvRow) + ' has FEWER (' + IntToStr(asCols.Count) +
                            ') cells than expected (' + IntToStr(iCsvColCount) + ')!' + CHR(10) + CHR(10) +
                            'Do you want to continue?') then
        begin
          Break;
        end;
      end;

      // CSV ERROR
      if bBreak then Break;

      if strmCsv.EndOfStream then Break;
    end;

  finally
    strmCsv.Close();
    FreeAndNil(strmCsv);

    FreeAndNil(asCols);
  end;

end;

end.
