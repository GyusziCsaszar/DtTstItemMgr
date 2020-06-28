unit uFrmFDB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  { DtTst Units: } uDtTstApp,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.SqlExpr, Vcl.Tabs;

type
  TFrmFDB = class(TForm)
    panLower: TPanel;
    lblCaption: TLabel;
    lblUser: TLabel;
    edUser: TEdit;
    lblPw: TLabel;
    edPw: TEdit;
    btnLogin: TButton;
    btnClose: TButton;
    cbbDb: TComboBox;
    chbServerCharsetUtf8: TCheckBox;
    panAdminMode: TPanel;
    lblDb: TLabel;
    panDbInfo: TPanel;
    btnDbOpen: TButton;
    grpIsql: TGroupBox;
    btnIsqlTest: TButton;
    chbIsqlVisible: TCheckBox;
    btnCreTblSample: TButton;
    chbAutoLogin: TCheckBox;
    btnCrePrdTbls: TButton;
    chbDoDbUpdate: TCheckBox;
    btnIsqlShowDb: TButton;
    tsDev: TTabSet;
    lbLog: TListBox;
    moSql: TMemo;
    btnSqlOpen: TButton;
    btnSqlOpenSample: TButton;
    btnIsqlExec: TButton;
    btnIsqlExecSample: TButton;
    edTerm: TEdit;
    btnIsqlCreateDb: TButton;
    btnIsqlCreateUser: TButton;
    edNewUser: TEdit;
    btnIsqlDropUser: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDbOpenClick(Sender: TObject);
    procedure btnIsqlTestClick(Sender: TObject);
    procedure btnCreTblSampleClick(Sender: TObject);
    procedure chbAutoLoginClick(Sender: TObject);
    procedure btnCrePrdTblsClick(Sender: TObject);
    procedure btnIsqlShowDbClick(Sender: TObject);
    procedure tsDevChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure btnIsqlExecSampleClick(Sender: TObject);
    procedure btnIsqlExecClick(Sender: TObject);
    procedure btnSqlOpenSampleClick(Sender: TObject);
    procedure btnSqlOpenClick(Sender: TObject);
    procedure lbLogDblClick(Sender: TObject);
    procedure btnIsqlCreateDbClick(Sender: TObject);
    procedure btnIsqlCreateUserClick(Sender: TObject);
    procedure btnIsqlDropUserClick(Sender: TObject);
  private
    { Private declarations }
    m_oApp: TDtTstApp;
    m_oConAnsi: TSQLConnection;
    m_oConUtf8: TSQLConnection;
    m_oCon    : TSQLConnection;
    m_bAutoLoginClick: Boolean;
  public
    { Public declarations }
    SQL_OpenSelect: string;

    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    function GetCon(): TSQLConnection;
    property CON: TSQLConnection read GetCon;

    function GetDbInfo() : string;

    function IsqlOpen(bConnectDB: Boolean; sStatements, sTerm: string; bChkIsqlResult: Boolean) : Boolean;

    procedure AttachDbItemManager(bForceUpdate: Boolean);

    function ShowModal(oConAnsi, oConUtf8: TSQLConnection) : integer; reintroduce;

  end;

var
  FrmFDB: TFrmFDB;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConsts, uDtTstUtils, uDtTstWin, uDtTstFirebird, uDtTstDb, uDtTstDbItemMgr, uDtTstAppDb,
  { DtTst Forms: } uFrmProgress,
  System.IOUtils, Vcl.Clipbrd, StrUtils;

constructor TFrmFDB.Create(AOwner: TComponent; oApp: TDtTstApp);
begin

  SQL_OpenSelect := '';

  m_oApp := oApp;

  m_bAutoLoginClick := False;

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmFDB');

  // Registry...
  chbAutoLogin       .Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin'   , False);

  // DB Info from INI file...
  cbbDb.Text := '';
  cbbDb.Items.Clear();

  (m_oApp as TDtTstAppDb).DB.GetConnectStrings(cbbDb, nil {asConnectStrings});

  chbServerCharsetUtf8.Checked := (m_oApp as TDtTstAppDb).DB.UTF8;

  m_oApp.LOG.LogLIFE('TFrmFDB.Create');
end;

destructor TFrmFDB.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmFDB.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmFDB');

  m_oApp := nil; // ATTN: Do not Free here!

  inherited Destroy();
end;

procedure TFrmFDB.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;

  btnCreTblSample.Caption := btnCreTblSample.Caption + ' "' + csDB_TBL_SAMPLE + '"';

  if not m_oApp.ADMIN_MODE then
  begin

    // ATTN: Force event handler...
    //tsDev.TabIndex := 1; tsDev.TabIndex := 0;
    tsDev.TabIndex := 0; tsDev.TabIndex := 1;

  end;

  // ATTN!!! Form has to work without calling to FormShow!!!

end;

procedure TFrmFDB.btnCloseClick(Sender: TObject);
begin
  if panAdminMode.Visible and (not btnLogin.Enabled) then
  begin
    ModalResult := mrOk;
  end
  else
  begin
    ModalResult := mrCancel;
  end;
end;

function TFrmFDB.GetCon(): TSQLConnection;
begin
  Result := m_oCon;
end;

procedure TFrmFDB.btnCrePrdTblsClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnCrePrdTblsClick BEGIN');

  if (not Assigned((m_oApp as TDtTstAppDb).DB.SQLConnection)) or (not (m_oApp as TDtTstAppDb).DB.SQLConnection.Connected) then
  begin
    ErrorMsgDlg('No Database is open!');
    Exit;
  end;

  if not chbDoDbUpdate.Checked then
  begin
    ErrorMsgDlg('Checkbox "Do DB Update" has to be checked!');
    Exit;
  end;

  if not (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct.IsEmpty() then
  begin
    if (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct = csPRODUCT_FULL then
    begin
      WarningMsgDlg('Database already contains Tables for Product "' + csPRODUCT_FULL + '"!');
    end
    else
    begin
      ErrorMsgDlg('Database contains Tables for DIFFERENT Product "' + (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct + '"!' +
                  CHR(10) + CHR(10) + 'No mixed Products are allowed in a single Database!');
    end;

    Exit;
  end;

  if (m_oApp as TDtTstAppDb).DB.GetTableCount() > 0 then
  begin
    if not QuestionMsgDlg('Database already has ' + IntToStr((m_oApp as TDtTstAppDb).DB.GetTableCount()) + ' Table(s) and is not Empty!' +
          CHR(10) + CHR(10) + 'Do you want to create Tables for Product "' + csCOMPANY + csPRODUCT + '"?') then
    begin
      Exit;
    end;
  end;

  try

    AttachDbItemManager(True {bForceUpdate});

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmFDB.btnCrePrdTblsClick END');
end;

procedure TFrmFDB.AttachDbItemManager(bForceUpdate: Boolean);
var
  oDbItemMgr: TDtTstDbItemMgr;
  sDbInfo: string;
  frmPrs: TFrmProgress;
begin

  // ATTN: In case of (one-and-only) Known DB
  //       OR FORCED (!)...
  if bForceUpdate or ((m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct = csPRODUCT_FULL) then
  begin

    // Replace oDb with oDbItemMgr...
    oDbItemMgr := TDtTstDbItemMgr.Create(m_oApp.LOG, (m_oApp as TDtTstAppDb).DB);

    (m_oApp as TDtTstAppDb).SetDb(oDbItemMgr);

    if chbDoDbUpdate.Checked then
    begin

      frmPrs := TFrmProgress.Create(self, m_oApp);
      try

        oDbItemMgr.ADM_DoDbUpdates(frmPrs, m_oApp.ADMIN_MODE);

        frmPrs.Done();
        while frmPrs.Visible do Application.ProcessMessages;

      finally
        frmPrs.Close();
        FreeAndNil(frmPrs);
      end;

    end;

    sDbInfo := 'LoginUsername = "' + (m_oApp as TDtTstAppDb).DB.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( ADM Version = ' + IntToStr((m_oApp as TDtTstAppDb).DB.ADM_DbInfVersion_ADM) +
                ', Product = "' + (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct + '"' +
                ', Product Version = ' + IntToStr((m_oApp as TDtTstAppDb).DB.ADM_DbInfVersion_PRD) +
                ', UserID = ' + IntToStr(oDbItemMgr.ADM_UserID) + ' )';
    sDbInfo := sDbInfo + ', DtTstDbItemMgr(  )';

    panDbInfo.Caption := sDbInfo;

  end;

end;

procedure TFrmFDB.btnCreTblSampleClick(Sender: TObject);
var
  oDb: TDtTstDb;
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnCreTblSampleClick BEGIN');

  // try SRC: https://stackoverflow.com/questions/6601147/how-to-correctly-write-try-finally-except-statements
  try
    try
      oDb := TDtTstDb.Create(m_oApp.LOG, '');

      oDb.META_CreateTable_SAMPLE((m_oApp as TDtTstAppDb).DB.SQLConnection.DBXConnection);

      InfoMsgDlg('You have created table "' + csDB_TBL_SAMPLE + '"!');

    finally
      FreeAndNil(oDb);
    end;
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogUI('TFrmFDB.btnCreTblSampleClick END');
end;

procedure TFrmFDB.btnDbOpenClick(Sender: TObject);
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
    frmOf.Filter := csFBRD_FDB_FILE_FILTER + '|All Files (*.*)|*.*';

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

function TFrmFDB.GetDbInfo() : string;
begin
  Result := panDbInfo.Caption;
end;

function TFrmFDB.IsqlOpen(bConnectDB: Boolean; sStatements, sTerm: string; bChkIsqlResult: Boolean) : Boolean;
var
  sDb, sOutput: string;
  frmPrs: TFrmProgress;
begin
  Result := False;

  try

    frmPrs := TFrmProgress.Create(self, m_oApp);
    try

      frmPrs.Show();
      frmPrs.Init(False {bCanAbort}, 'Calling Firebird Isql tool');
      frmPrs.SetProgressToMax();

      frmPrs.AddStep('Starting Firebird Isql tool');

      (m_oApp as TDtTstAppDb).DB.ConnectUser     := edUser.Text;
      (m_oApp as TDtTstAppDb).DB.ConnectPassword := edPw  .Text;

      if bConnectDB then
        sDb := cbbDb.Text
      else
        sDb := '';

      sOutput := ISQL_Execute(m_oApp.LOG, TPath.GetDirectoryName(Application.ExeName),
                              (m_oApp as TDtTstAppDb).DB.IsqlPathChecked,
                              sDb,
                              (m_oApp as TDtTstAppDb).DB.ConnectUser, (m_oApp as TDtTstAppDb).DB.ConnectPassword,
                              True {bGetOutput},
                              chbIsqlVisible.Checked {bVisible},
                              sStatements,
                              sTerm);

      frmPrs.AddStepEnd('Done!');

      if bChkIsqlResult then
      begin

        if not ContainsText(sOutput, csISQL_SUCCESS) then
        begin
          raise Exception.Create('Isql returned error: "' + sOutput + '"!');
        end;

      end;

      InfoMsgDlg('isql output (cch = ' + IntToStr(sOutput.Length) + '):' + CHR(10) + CHR(10) + sOutput);

      Result := True;

    finally
      frmPrs.Close();
      FreeAndNil(frmPrs);
    end;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmFDB.lbLogDblClick(Sender: TObject);
begin
  if lbLog.ItemIndex >= 0 then
  begin
    Clipboard.AsText := lbLog.Items[lbLog.ItemIndex];
  end;
end;

procedure TFrmFDB.btnIsqlExecClick(Sender: TObject);
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

    IsqlOpen(True {bConnectDB}, moSql.Lines.Text, edTerm.Text, False {bChkIsqlResult});
  end;
end;

procedure TFrmFDB.btnIsqlExecSampleClick(Sender: TObject);
begin
  edTerm.Text := '!!';
  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE!!';

  if btnIsqlExec.Enabled then btnIsqlExec.Click();

  edTerm.Text := ';';
  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE;';
end;

procedure TFrmFDB.btnIsqlCreateDbClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oApp.LOG.LogUI('btnIsqlCreateDbClick BEGIN');

  if TComboBox_Text(cbbDb).IsEmpty() then
  begin
    WarningMsgDlg('No database specified!');
    Exit;
  end;

  sTerm := '';
  sStatements := 'CREATE DATABASE ' + '''' + cbbDb.Text + '''' +
                 {' USER ' + edUser.Text +
                 ' PASSWORD ' + edPw.Text + }
                 ' PAGE_SIZE 4096';

  if chbServerCharsetUtf8.Checked then
  begin
   sStatements := sStatements + ' DEFAULT CHARACTER SET ' + 'UTF8';
   {' DEFAULT COLLATION ' + 'UTF8' +} // NO DEFAULT COLLATION
  end;

  if not QuestionMsgDlg('Do you want to create a new database as?' + CHR(10) + CHR(10) +
                        sStatements) then
  begin
    Exit;
  end;

  sStatements := sStatements + ';';

  if IsqlOpen(False {bConnectDB}, sStatements, sTerm, True {bChkIsqlResult}) then
  begin

    if btnLogin.Enabled and QuestionMsgDlg('Do you want to Login to new database?') then
    begin

      btnLogin.Click();

      if ((m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct <> csPRODUCT_FULL) then
      begin

        if btnCrePrdTbls.Enabled and QuestionMsgDlg('Do you want to create Product Tables?') then
        begin

          btnCrePrdTbls.Click();

        end;
      end;
    end;
  end;

  m_oApp.LOG.LogUI('btnIsqlCreateDbClick END');
end;

procedure TFrmFDB.btnIsqlCreateUserClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlCreateUserClick BEGIN');

  sTerm := '!!';

  sStatements := 'CREATE USER ' + edNewUser.Text + ' PASSWORD ''' + edPw.Text + '''' + sTerm;

  sStatements := sStatements +
    'EXECUTE BLOCK' +
    ' AS' +
    '   DECLARE VARIABLE tablename VARCHAR(32);' +
    ' BEGIN' +
    '   FOR SELECT rdb$relation_name' +
    '   FROM rdb$relations' +
    '   WHERE' +
    //' rdb$view_blr IS NULL' +
    //'   AND ' +
    ' (rdb$system_flag IS NULL OR rdb$system_flag = 0)' +
    '   INTO :tablename DO' +
    '   BEGIN' +
    '     EXECUTE STATEMENT (''GRANT ALL ON TABLE '' || :tablename || '' TO USER ' + edNewUser.Text + ''');' +
    '   END' +
    ' END' +
    sTerm;

  IsqlOpen(True {bConnectDB}, sStatements, sTerm, False {bChkIsqlResult});

  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlCreateUserClick END');
end;

procedure TFrmFDB.btnIsqlDropUserClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlDropUserClick BEGIN');

  sTerm := '';
  sStatements := 'DROP USER ' + edNewUser.Text + ';';

  IsqlOpen(True {bConnectDB}, sStatements, sTerm, False {bChkIsqlResult});

  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlDropUserClick END');
end;

procedure TFrmFDB.btnIsqlShowDbClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlShowDbClick BEGIN');

  sTerm := '';
  sStatements := 'SHOW DATABASE;';

  IsqlOpen(True {bConnectDB}, sStatements, sTerm, False {bChkIsqlResult});

  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlShowDbClick END');
end;

procedure TFrmFDB.btnIsqlTestClick(Sender: TObject);
var
  sStatements, sTerm: string;
begin
  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlTestClick BEGIN');

  sTerm := '';
  sStatements := '';

  IsqlOpen(True {bConnectDB}, sStatements, sTerm, False {bChkIsqlResult});

  m_oApp.LOG.LogUI('TFrmFDB.btnIsqlTestClick END');
end;

procedure TFrmFDB.chbAutoLoginClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmFDB.chbAutoConnectClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin', chbAutoLogin.Checked);

  m_oApp.LOG.LogUI('TFrmFDB.chbAutoConnectClick END');
end;

procedure TFrmFDB.tsDevChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin

  if not m_oApp.ADMIN_MODE then Exit;

  lbLog.Visible := (NewTab = 0);

  btnSqlOpen        .Visible := (NewTab = 1);
  btnSqlOpenSample  .Visible := (NewTab = 1);
  btnIsqlExec       .Visible := (NewTab = 1);
  btnIsqlExecSample .Visible := (NewTab = 1);
  edTerm            .Visible := (NewTab = 1);
  moSql             .Visible := (NewTab = 1);

end;

procedure TFrmFDB.btnSqlOpenClick(Sender: TObject);
var
  sSql: string;
begin
  if not moSql.Lines.Text.IsEmpty() then
  begin

    sSql := moSql.Lines.Text;

    if StartsText('SELECT ', TRIM(sSql.ToUpper())) then
    begin

      {
      OpenSql('SQL Editor', sSql);
      }

      // Syntax Check...
      (m_oApp as TDtTstAppDb).DB.ExecuteSQL(nil {nil = DO Transaction}, sSql);

      if QuestionMsgDlg('To open Select query this window needs to close!' + CHR(10) + CHR(10) +
                        'Do you want to continue?') then
      begin

        SQL_OpenSelect := sSql;

        ModalResult := mrOk;

      end;

    end
    else
    begin
      (m_oApp as TDtTstAppDb).DB.ExecuteSQL(nil {nil = DO Transaction}, sSql);
    end;

  end;
end;

procedure TFrmFDB.btnSqlOpenSampleClick(Sender: TObject);
begin

  moSql.Lines.Text := 'select current_timestamp from RDB$DATABASE';

  // ATTN: DO NOT!!! Closes form when sql is select!
  //if btnSqlOpen.Enabled then btnSqlOpen.Click();

end;

procedure TFrmFDB.btnLoginClick(Sender: TObject);
var
  sDbInfo, sMsg: string;
begin

  try

    if chbServerCharSetUtf8.Checked then
    begin
      m_oCon := m_oConUtf8;
    end
    else
    begin
      m_oCon := m_oConAnsi;
    end;

    (m_oApp as TDtTstAppDb).DB.ConnectUser     := edUser.Text;
    (m_oApp as TDtTstAppDb).DB.ConnectPassword := edPw  .Text;

    (m_oApp as TDtTstAppDb).DB.ConnectString := cbbDb.Text;
    (m_oApp as TDtTstAppDb).DB.Connect(m_oCon);

    sDbInfo := 'LoginUsername = "' + (m_oApp as TDtTstAppDb).DB.LoginUser + '"';
    sDbInfo := sDbInfo + ', DtTstDb( ADM Version = ' + IntToStr((m_oApp as TDtTstAppDb).DB.ADM_DbInfVersion_ADM) +
                ', Product = "' + (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct + '" )';

    panDbInfo.Caption := sDbInfo;

    // ATTN: Do not force!!! Attach only known DB here!!!
    AttachDbItemManager(False {bForce});

    if not m_oApp.ADMIN_MODE then
    begin
      if (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct <> csPRODUCT_FULL then
      begin
        sMsg := 'The Database Product "' + (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct +
          '"' + CHR(10) + 'is other than expected "' + csPRODUCT_FULL + '"!' + CHR(10) + CHR(10) + 'Contact the Database Administrator!';

        ErrorMsgDlg(sMsg);

        //raise Exception.Create(sMsg);
        Exit;
      end;
    end;

    // Connected...
    btnCrePrdTbls       .Enabled := ((m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct <> csPRODUCT_FULL);
    cbbDb               .Enabled := False;
    btnDbOpen           .Enabled := False;
    chbServerCharSetUtf8.Enabled := False;
    btnIsqlCreateDb     .Enabled := False;

    btnCreTblSample     .Enabled := True;
    btnSqlOpen          .Enabled := True;

    // FIX...
    {
    if panAdminMode.Visible then
    begin
    }
      btnLogin.Enabled := False;
    {
    end
    else
    begin
      ModalResult := mrOk;
    end;
    }

    if panAdminMode.Visible then
    begin
      if not m_bAutoLoginClick {chbAutoLogin.Checked} then InfoMsgDlg('To close this form press Close!');

      if (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct <> csPRODUCT_FULL then
      begin
        WarningMsgDlg('The Database Product "' + (m_oApp as TDtTstAppDb).DB.ADM_DbInfProduct +
          '"' + CHR(10) + 'is other than expected "' + csPRODUCT_FULL + '"!' + CHR(10) + CHR(10) +
          'To create Product tables press CREATE PRODUCT TABLES!');
      end;
    end
    else
    begin
      ModalResult := mrOk; // Close Form...
    end;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

function TFrmFDB.ShowModal(oConAnsi, oConUtf8: TSQLConnection) : integer;
var
  lbLog_Old: TListBox;
begin
  m_oConAnsi := oConAnsi;
  m_oConUtf8 := oConUtf8;

  m_oCon     := nil;

  panAdminMode          .Visible := m_oApp.ADMIN_MODE;
  lblDb                 .Visible := m_oApp.ADMIN_MODE;
  cbbDb                 .Visible := m_oApp.ADMIN_MODE;
  btnDbOpen             .Visible := m_oApp.ADMIN_MODE;
  chbServerCharsetUtf8  .Visible := m_oApp.ADMIN_MODE;
  panDbInfo             .Visible := m_oApp.ADMIN_MODE;
  grpIsql               .Visible := m_oApp.ADMIN_MODE;
  chbIsqlVisible        .Visible := m_oApp.ADMIN_MODE;
  btnIsqlCreateDb       .Visible := m_oApp.ADMIN_MODE;
  btnIsqlShowDb         .Visible := m_oApp.ADMIN_MODE;
  chbDoDbUpdate         .Visible := m_oApp.ADMIN_MODE;
  btnCrePrdTbls         .Visible := m_oApp.ADMIN_MODE;
  btnCreTblSample       .Visible := m_oApp.ADMIN_MODE;
  tsDev                 .Visible := m_oApp.ADMIN_MODE;
  moSql                 .Visible := m_oApp.ADMIN_MODE;
  btnSqlOpen            .Visible := m_oApp.ADMIN_MODE;
  btnSqlOpenSample      .Visible := m_oApp.ADMIN_MODE;
  btnIsqlExec           .Visible := m_oApp.ADMIN_MODE;
  btnIsqlExecSample     .Visible := m_oApp.ADMIN_MODE;
  edTerm                .Visible := m_oApp.ADMIN_MODE;
  btnIsqlCreateUser     .Visible := m_oApp.ADMIN_MODE;
  btnIsqlDropUser       .Visible := m_oApp.ADMIN_MODE;
  edNewUser             .Visible := m_oApp.ADMIN_MODE;

  //if m_oApp.ADMIN_MODE then
  begin
    edUser.Text := (m_oApp as TDtTstAppDb).DB.ConnectUser;
    edPw  .Text := (m_oApp as TDtTstAppDb).DB.ConnectPassword;
  end;

  if chbAutoLogin.Checked then
  begin

    m_bAutoLoginClick := True;

    btnLogin.Click();

    m_bAutoLoginClick := False;

    // CHNG: Exit even in ADMIN_MODE when AutoLogin is ON!
    //if (not btnLogin.Enabled) and (not panAdminMode.Visible) then
    if (not btnLogin.Enabled) then
    begin
      Result := mrOk;
      Exit;
    end;

  end;

  lbLog_Old := m_oApp.LOG.m_lbLogView;
  m_oApp.LOG.m_lbLogView := lbLog;
  try

    Result := inherited ShowModal();

  finally
    m_oApp.LOG.m_lbLogView := lbLog_Old;
  end;
end;

end.
