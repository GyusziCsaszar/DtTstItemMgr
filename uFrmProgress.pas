unit uFrmProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls;

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
  public
    { Public declarations }
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
  System.Math;

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
  pbPrs.Position := pbPrs.Max;
end;

procedure TFrmProgress.SetProgressMinMax(iMin, iMax: integer);
begin
  pbPrs.Max       := iMax;
  pbPrs.Min       := iMin;
  pbPrs.Position  := iMin;
end;

procedure TFrmProgress.SetProgressPos(iPos: integer);
begin
  pbPrs.Position  := Max(pbPrs.Min, Min(iPos, pbPrs.Max));
end;

procedure TFrmProgress.AddStepHeader(sStepHeader: string);
begin
  lbHistory.Items.Add('[ ' + sStepHeader + ' ]');
end;

procedure TFrmProgress.AddStep(sStep: string);
begin
  lbHistory.Items.Add('  ' + sStep + '...');
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
  btnClose.Enabled := true;
end;

end.
