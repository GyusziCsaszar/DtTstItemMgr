unit uDtTstWin;

interface

uses
  Vcl.Forms;

procedure LoadFormSizeReg(frm: TForm; sCompany, sProduct, sKey: string);
procedure SaveFormSizeReg(frm: TForm; sCompany, sProduct, sKey: string);

procedure ErrorMsgDlg(sErr: string);
procedure InfoMsgDlg(sInf: string);
procedure WarningMsgDlg(sWrn: string);
function QuestionMsgDlg(sQun: string) : boolean;

implementation

uses
  Vcl.Dialogs, Vcl.Controls, System.SysUtils, System.Win.Registry;

procedure LoadFormSizeReg(frm: TForm; sCompany, sProduct, sKey: string);
var
  sKeyPath: string;
  reg: TRegistry;
begin

  reg := TRegistry.Create;

  try

    sKeyPath := 'Software\' + sCompany + '\' + sProduct;
    if not sKey.IsEmpty() then
    begin
      sKeyPath := sKeyPath + '\' + sKey;
    end;

    //FIX...
    sKeyPath := sKeyPath + ' (' + IntToStr(Screen.WorkAreaWidth) + 'x' + IntToStr(Screen.WorkAreaHeight) + ')';

    if not reg.OpenKey(sKeyPath, True) then
    begin
      RaiseLastOSError();
    end;

    if not reg.ValueExists('DefWidth') then
    begin
      // Save Default Form Rectangle
      reg.WriteInteger('DefWidth' , frm.Width );
      reg.WriteInteger('DefHeight', frm.Height);

      // ATTN: Do not save default Top and Left!
      //       User CenterOnScreen instead!!!
    end;

    if reg.ValueExists('Width') then
    begin

      if frm.Position = poScreenCenter then
      begin
        frm.Position := poDesigned;
      end;

      frm.Width := reg.ReadInteger('Width');
    end;

    if reg.ValueExists('Height') then
    begin

      if frm.Position = poScreenCenter then
      begin
        frm.Position := poDesigned;
      end;

      frm.Height := reg.ReadInteger('Height');
    end;

    if reg.ValueExists('Top') then
    begin

      if frm.Position = poScreenCenter then
      begin
        frm.Position := poDesigned;
      end;

      frm.Top := reg.ReadInteger('Top');
    end;

    if reg.ValueExists('Left') then
    begin

      if frm.Position = poScreenCenter then
      begin
        frm.Position := poDesigned;
      end;

      frm.Left := reg.ReadInteger('Left');
    end;

  finally
    FreeAndNil(reg);
  end;
end;

procedure SaveFormSizeReg(frm: TForm; sCompany, sProduct, sKey: string);
var
  sKeyPath: string;
  reg: TRegistry;
  iDefVal: integer;
begin

  reg := TRegistry.Create;

  try

    sKeyPath := 'Software\' + sCompany + '\' + sProduct;
    if not sKey.IsEmpty() then
    begin
      sKeyPath := sKeyPath + '\' + sKey;
    end;

    //FIX...
    sKeyPath := sKeyPath + ' (' + IntToStr(Screen.WorkAreaWidth) + 'x' + IntToStr(Screen.WorkAreaHeight) + ')';

    if not reg.OpenKey(sKeyPath, True) then
    begin
      RaiseLastOSError();
    end;

    if reg.ValueExists('DefWidth') then
    begin
      iDefVal := reg.ReadInteger('DefWidth');

      if frm.Width > iDefVal then
      begin
        reg.WriteInteger('Width', frm.Width);
      end;
    end;

    if reg.ValueExists('DefHeight') then
    begin
      iDefVal := reg.ReadInteger('DefHeight');

      if frm.Height > iDefVal then
      begin
        reg.WriteInteger('Height', frm.Height);
      end;
    end;

    reg.WriteInteger('Top',   frm.Top );
    reg.WriteInteger('Left',  frm.Left);

  finally
    FreeAndNil(reg);
  end;

end;

procedure ErrorMsgDlg(sErr: string);
begin
  MessageDlg(sErr, mtError, [mbOk], 0);
end;

procedure InfoMsgDlg(sInf: string);
begin
  MessageDlg(sInf, mtInformation, [mbOk], 0);
end;

procedure WarningMsgDlg(sWrn: string);
begin
  MessageDlg(sWrn, mtWarning, [mbOk], 0);
end;

function QuestionMsgDlg(sQun: string) : boolean;
begin
  Result := False;
  if mrYes = MessageDlg(sQun, mtConfirmation, [mbYes, mbNo], 0, mbNo) then
  begin
    Result := True;
  end;
end;

end.
