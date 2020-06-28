unit uFrmProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  { DtTst Units: } uDtTstApp,
  Vcl.ExtCtrls;

type
  TFrmProgress = class(TForm)
    panLower: TPanel;
    lblCaption: TLabel;
    pbPrs: TProgressBar;
    lbHistory: TListBox;
    btnClose: TButton;
    btnAbort: TButton;
    btnCopyToClipboard: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnCopyToClipboardClick(Sender: TObject);
    procedure btnAbortClick(Sender: TObject);
  private
    { Private declarations }
    m_oApp: TDtTstApp;

    m_bCanAbort: Boolean;
    m_bAbortPressed: Boolean;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    procedure Init(bCanAbort: Boolean; sTitle: string);

    procedure SetProgressToMax();
    procedure SetProgressMinMax(iMin, iMax: integer);
    procedure SetProgressPos(iPos: integer);
    procedure AddStepHeader(sStepHeader: string);
    procedure AddStep(sStep: string);
    procedure AddStepEnd(sStepEnd: string);
    procedure Done();

    function GetAbortPressed() : Boolean;
    procedure SetAbortPressed(bValue: Boolean);
    property AbortPressed: Boolean read GetAbortPressed write SetAbortPressed;

  end;

var
  FrmProgress: TFrmProgress;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConsts, uDtTstWin,
  System.Math, Clipbrd;

constructor TFrmProgress.Create(AOwner: TComponent; oApp: TDtTstApp);
begin

  m_oApp := oApp;

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmProgress');

  m_oApp.LOG.LogLIFE('TFrmProgress.Create');
end;

destructor TFrmProgress.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmProgress.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmProgress');

  m_oApp := nil; // ATTN: Do not Free here!

  inherited Destroy();
end;

procedure TFrmProgress.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;
end;

procedure TFrmProgress.Init(bCanAbort: Boolean; sTitle: string);
begin

  lblCaption.Caption := sTitle + '...';

  m_bCanAbort      := bCanAbort;
  m_bAbortPressed  := False;

  btnAbort.Visible := m_bCanAbort;
  btnAbort.Enabled := m_bCanAbort;

  btnClose.Enabled := False;
end;

procedure TFrmProgress.SetProgressToMax();
begin
  try
    pbPrs.Position := pbPrs.Max;
  except
    //NOP...
  end;
end;

procedure TFrmProgress.SetProgressMinMax(iMin, iMax: integer);
begin
  try
    pbPrs.Max       := iMax;
    pbPrs.Min       := iMin;
    pbPrs.Position  := iMin;
  except
    //NOP...
  end;
end;

procedure TFrmProgress.SetProgressPos(iPos: integer);
begin
  pbPrs.Position  := Max(pbPrs.Min, Min(iPos, pbPrs.Max));
end;

procedure TFrmProgress.AddStepHeader(sStepHeader: string);
begin

  if lbHistory.Items.Count > 0 then lbHistory.Items.Add('');
  lbHistory.Items.Add('[ ' + sStepHeader + ' ]');

  // NOTE: Scroll into view...
  lbHistory.ItemIndex := lbHistory.Items.Count - 1;
end;

procedure TFrmProgress.AddStep(sStep: string);
begin

  lbHistory.Items.Add('  ' + sStep + '...');

  // NOTE: Scroll into view...
  lbHistory.ItemIndex := lbHistory.Items.Count - 1;
end;

procedure TFrmProgress.AddStepEnd(sStepEnd: string);
begin
  if lbHistory.Items.Count < 1 then Exit;
  lbHistory.Items[lbHistory.Items.Count - 1] := lbHistory.Items[lbHistory.Items.Count - 1] + ' ...' + sStepEnd;
end;

procedure TFrmProgress.btnAbortClick(Sender: TObject);
begin
  m_bAbortPressed  := True;
  btnAbort.Enabled := False;
end;

procedure TFrmProgress.btnCloseClick(Sender: TObject);
begin
  self.Close();
end;

procedure TFrmProgress.btnCopyToClipboardClick(Sender: TObject);
begin

  Clipboard.AsText := lblCaption.Caption + CHR(13) + CHR(10)
    + CHR(13) + CHR(10) + lbHistory.Items.Text;

end;

procedure TFrmProgress.Done();
begin

  lbHistory.Items.Add('');

  // NOTE: Scroll into view...
  lbHistory.ItemIndex := lbHistory.Items.Count - 1;

  btnClose.Enabled := True;
  btnAbort.Enabled := False;
end;

function TFrmProgress.GetAbortPressed() : Boolean;
begin
  Result := m_bAbortPressed;
end;

procedure TFrmProgress.SetAbortPressed(bValue: Boolean);
begin
  m_bAbortPressed  := bValue;

  btnAbort.Enabled := (not m_bAbortPressed);
end;


end.
