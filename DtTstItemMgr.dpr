program DtTstItemMgr;

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uDtTstDb in 'uDtTstDb.pas',
  uDtTstLog in 'uDtTstLog.pas',
  uDtTstUtils in 'uDtTstUtils.pas',
  uDtTstConsts in 'uDtTstConsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
