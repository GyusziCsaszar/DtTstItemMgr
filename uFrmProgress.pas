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
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    m_oApp: TDtTstApp;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    procedure Init(sTitle: string);

    procedure SetProgressToMax();
    procedure SetProgressMinMax(iMin, iMax: integer);
    procedure SetProgressPos(iPos: integer);
    procedure AddStepHeader(sStepHeader: string);
    procedure AddStep(sStep: string);
    procedure AddStepEnd(sStepEnd: string);
    procedure Done();
  end;

var
  FrmProgress: TFrmProgress;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConsts, uDtTstWin,
  System.Math;

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

procedure TFrmProgress.Init(sTitle: string);
begin
  lblCaption.Caption := sTitle + '...';
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

procedure TFrmProgress.btnCloseClick(Sender: TObject);
begin
  self.Close();
end;

procedure TFrmProgress.Done();
begin

  lbHistory.Items.Add('');

  // NOTE: Scroll into view...
  lbHistory.ItemIndex := lbHistory.Items.Count - 1;

  btnClose.Enabled := true;
end;

end.
