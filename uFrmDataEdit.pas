unit uFrmDataEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  { DtTst Units: } uDtTstApp, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls;

type
  TFrmDataEdit = class(TForm)
    panLower: TPanel;
    lblCaption: TLabel;
    lblFld1: TLabel;
    edFld1: TEdit;
    chbNullFld1: TCheckBox;
    lblTypeFld1: TLabel;
    lblLenFld1: TLabel;
    cbbFld1: TComboBox;
    lblFld2: TLabel;
    edFld2: TEdit;
    chbNullFld2: TCheckBox;
    lblTypeFld2: TLabel;
    lblLenFld2: TLabel;
    cbbFld2: TComboBox;
    lblFld3: TLabel;
    edFld3: TEdit;
    cbbFld3: TComboBox;
    chbNullFld3: TCheckBox;
    lblTypeFld3: TLabel;
    lblLenFld3: TLabel;
    lblFld4: TLabel;
    edFld4: TEdit;
    cbbFld4: TComboBox;
    chbNullFld4: TCheckBox;
    lblTypeFld4: TLabel;
    lblLenFld4: TLabel;
    btnUpdate: TButton;
    btnClose: TButton;
    edFld5: TEdit;
    lblFld5: TLabel;
    cbbFld5: TComboBox;
    chbNullFld5: TCheckBox;
    lblTypeFld5: TLabel;
    lblLenFld5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    m_oApp: TDtTstApp;

    m_sTableOrView: string;

    m_asCols: TStringList;
    m_asColInfos: TStringList;
    m_asColSources: TStringList;

    m_sWhere: string;
    m_bKeyEditAllowed: Boolean;
    m_sChangeTagTable: string;

    m_sChangeTag_START: string;

    function CheckFields(asCols, asVals: TStringList) : Boolean;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; oApp: TDtTstApp); reintroduce;
    destructor Destroy(); override;

    procedure Init(sAction, sCaption, sTableOrView: string; asCols, asColInfos, asColSources, asValues: TStringList;
                    sWhere, sChangeTagTable: string; bKeyEditAllowed: Boolean);
  end;

var
  FrmDataEdit: TFrmDataEdit;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConsts, uDtTstUtils, uDtTstWin, uDtTstAppDb, uDtTstDbSql,
  System.StrUtils;

const

  ciCCH_BIG   = 25;

constructor TFrmDataEdit.Create(AOwner: TComponent; oApp: TDtTstApp);
begin

  m_oApp := oApp;

  m_sTableOrView := '';

  m_asCols        := TStringList.Create();
  m_asColInfos    := TStringList.Create();
  m_asColSources  := TStringList.Create();

  m_sWhere          := '';
  m_bKeyEditAllowed := False;
  m_sChangeTagTable := '';

  m_sChangeTag_START := '';

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataEdit');

  m_oApp.LOG.LogLIFE('TFrmDataEdit.Create');
end;

destructor TFrmDataEdit.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmDataEdit.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmDataEdit');

  m_oApp := nil; // ATTN: Do not Free here!

  FreeAndNil(m_asCols);
  FreeAndNil(m_asColInfos);

  inherited Destroy();
end;

procedure TFrmDataEdit.FormShow(Sender: TObject);
begin

  self.Caption := Application.Title;

end;

procedure TFrmDataEdit.Init(sAction, sCaption, sTableOrView: string; asCols, asColInfos, asColSources, asValues: TStringList;
  sWhere, sChangeTagTable: string; bKeyEditAllowed: Boolean);
var
  iCol, iFldLen: integer;
  lblFldX, lblTypeFldX, lblLenFldX: TLabel;
  chbNullFldX: TCheckBox;
  cbbFldX: TComboBox;
  edFldX: TEdit;
  sInfo, sSql: string;
  asDbColInfo, asType, asVals: TStringList;
begin

  m_sTableOrView := sTableOrView;

  m_asCols.Clear();
  if Assigned(asCols) then m_asCols.AddStrings(asCols);

  m_asColInfos.Clear();
  if Assigned(asColInfos) then m_asColInfos.AddStrings(asColInfos);

  m_asColSources.Clear();
  if Assigned(asColSources) then m_asColSources.AddStrings(asColSources);

  m_sWhere          := sWhere;
  m_bKeyEditAllowed := bKeyEditAllowed;
  m_sChangeTagTable := sChangeTagTable;

  if m_oApp.ADMIN_MODE then
  begin
    lblCaption.Caption := sAction + ' ' + sCaption + ' (' + sTableOrView + ')';
  end
  else
  begin
    lblCaption.Caption := sAction + ' ' + sCaption;
  end;

  btnUpdate.Caption := sAction;

  asDbColInfo := TStringList.Create();
  asType      := TStringList.Create();
  asVals      := TStringList.Create();
  try

    for iCol := 0 to m_asCols.Count - 1 do
    begin

      lblFldX := FindComponent('lblFld' + IntToStr(iCol + 1)) as TLabel;
      if lblFldX = nil then
      begin
        Break; // No more available fields! (do not raise Error!)
      end;

      lblFldX.Caption := m_asCols[iCol];
      lblFldX.Visible := True;

      if iCol < m_asColInfos.Count then
      begin

        sInfo := m_asColInfos[iCol];
        sInfo := StringReplace(sInfo,'(' , ';', [rfReplaceAll]);
        sInfo := StringReplace(sInfo,')|', '|', [rfReplaceAll]);

        Split('|', sInfo, asDbColInfo);
      end
      else
      begin
        asDbColInfo.Add('');
        asDbColInfo.Add('');
      end;

      if ContainsText(asDbColInfo[0],';') then
      begin
        Split(';', asDbColInfo[0], asType);
        asDbColInfo[0] := asType[0];
        asDbColInfo.Insert(1, asType[1]);
      end
      else
      begin
        asDbColInfo.Insert(1, '');
      end;

      lblTypeFldX := FindComponent('lblTypeFld' + IntToStr(iCol + 1)) as TLabel;
      lblTypeFldX.Caption := asDbColInfo[0];

      lblLenFldX := FindComponent('lblLenFld' + IntToStr(iCol + 1)) as TLabel;
      lblLenFldX.Caption := asDbColInfo[1];

      iFldLen := -1;
      if not asDbColInfo[1].IsEmpty() then
      begin
        iFldLen := StrToInt(asDbColInfo[1]);
      end;

      chbNullFldX := FindComponent('chbNullFld' + IntToStr(iCol + 1)) as TCheckBox;
      chbNullFldX.Enabled := (asDbColInfo[2] = 'NULL'); //'NOT NULL');

      cbbFldX := FindComponent('cbbFld' + IntToStr(iCol + 1)) as TComboBox;
      if iCol < m_asColSources.Count then
      begin
        sSql := m_asColSources[iCol];
        if sSql.Length > 2 then
        begin
          if sSql[1] <> '1' then
          begin
            cbbFldX.Style := csDropDownList;
          end;
          sSql := sSql.Substring(2);

          if not sSql.IsEmpty() then
          begin
            if (m_oApp as TDtTstAppDb).DB.OpenSQL_Into_StringList(sSql, asVals) then
            begin
              cbbFldX.Items.AddStrings(asVals);
            end;
          end;
        end;
      end;

      edFldX := FindComponent('edFld' + IntToStr(iCol + 1)) as TEdit;

      cbbFldX.Left := edFldX.Left;

      if (cbbFldX.Items.Count > 0) and (btnUpdate.Caption <> csDELETE) then
      begin
        edFldX.Enabled  := False;
        edFldX.Visible  := False;

        cbbFldX.Enabled := True;
        cbbFldX.Visible := True;

        if iFldLen > 0 then
        begin
          cbbFldX.MaxLength := iFldLen;
        end;
      end
      else
      begin
        edFldX.Enabled  := True;
        edFldX.Visible  := True;

        cbbFldX.Enabled := False;
        cbbFldX.Visible := False;

        if iFldLen > 0 then
        begin
          edFldX.MaxLength := iFldLen;
        end;

        if lblTypeFldX.Caption = 'INTEGER' then
        begin
          edFldX.NumbersOnly := True;
        end;
      end;

      if (Assigned(asValues)) and (iCol < asValues.Count) then
      begin
        if edFldX.Visible then
          edFldX.Text  := asValues[iCol]
        else
          cbbFldX.Text := asValues[iCol];

        if (not m_bKeyEditAllowed) and (ContainsText(m_sWhere, (m_oApp as TDtTstAppDb).DB.FIXOBJNAME(lblFldX.Caption))) then
        begin
          edFldX .Enabled := False;
          cbbFldX.Enabled := False;
        end;

        if btnUpdate.Caption = csDELETE then
        begin
          edFldX .ReadOnly := True;
        //cbbFldX.ReadOnly := False;
        end;

      end;

      if iFldLen > ciCCH_BIG then
      begin
        lblLenFldX .Left := lblLenFldX .Left + edFldX.Width;
        lblTypeFldX.Left := lblTypeFldX.Left + edFldX.Width;
        chbNullFldX.Left := chbNullFldX.Left + edFldX.Width;

        edFldX .Width := (edFldX.Width * 2);
        cbbFldX.Width :=  edFldX.Width;
      end;

      lblLenFldX .Visible := m_oApp.ADMIN_MODE;
      lblTypeFldX.Visible := m_oApp.ADMIN_MODE;
      chbNullFldX.Visible := m_oApp.ADMIN_MODE;

    end;

    if (btnUpdate.Caption <> csINSERT) and (not m_sChangeTagTable.IsEmpty()) then
    begin

      m_sChangeTag_START := (m_oApp as TDtTstAppDb).DB.GetChageTag(m_sChangeTagTable, m_sWhere);

    end;

  finally
    FreeAndNil(asDbColInfo);
    FreeAndNil(asType);
    FreeAndNil(asVals);
  end;

end;

procedure TFrmDataEdit.btnCloseClick(Sender: TObject);
begin
  Close();
end;

function TFrmDataEdit.CheckFields(asCols, asVals: TStringList) : Boolean;
var
  iCol: integer;
  lblFldX, lblTypeFldX, lblLenFldX: TLabel;
  chbNullFldX: TCheckBox;
  cbbFldX: TComboBox;
  edFldX: TEdit;
  sVal: string;
begin
  Result := False;

  asCols.Clear();
  asVals.Clear();

  for iCol := 0 to m_asCols.Count - 1 do
  begin

    lblFldX := FindComponent('lblFld' + IntToStr(iCol + 1)) as TLabel;
    if lblFldX = nil then
    begin
      Break; // No more available fields! (do not raise Error!)
    end;

    asCols.Add(lblFldX.Caption);

    lblTypeFldX := FindComponent('lblTypeFld' + IntToStr(iCol + 1)) as TLabel;

    lblLenFldX := FindComponent('lblLenFld' + IntToStr(iCol + 1)) as TLabel;

    chbNullFldX := FindComponent('chbNullFld' + IntToStr(iCol + 1)) as TCheckBox;

    edFldX := FindComponent('edFld' + IntToStr(iCol + 1)) as TEdit;
    cbbFldX := FindComponent('cbbFld' + IntToStr(iCol + 1)) as TComboBox;

    if edFldX.Visible then
    begin
      sVal := edFldX.Text;

      if sVal.IsEmpty() then
      begin
        WarningMsgDlg('Field "' + lblFldX.Caption + '" is EMPTY!');
        edFldX.SetFocus();
        Exit;
      end;
    end
    else
    begin
      sVal := cbbFldX.Text;

      if sVal.IsEmpty() then
      begin
        WarningMsgDlg('Field "' + lblFldX.Caption + '" is EMPTY!');
        cbbFldX.SetFocus();
        Exit;
      end;
    end;

    asVals.Add(sVal);

  end;

  Result := True;
end;

procedure TFrmDataEdit.btnUpdateClick(Sender: TObject);
var
  asCols, asVals: TStringList;
  dbSql: TDtTstDbSql;
  sMsg, sChangeTag_NOW: string;
begin

  asCols := TStringList.Create();
  asVals := TStringList.Create();
  dbSql  := TDtTstDbSql.Create(m_oApp as TDtTstAppDb);
  try

    if btnUpdate.Caption <> csDELETE then
    begin

      if not CheckFields(asCols, asVals) then
      begin
        Exit;
      end;

    end;

    try

      if (btnUpdate.Caption <> csINSERT) and (not m_sChangeTagTable.IsEmpty()) then
      begin

        sChangeTag_NOW := (m_oApp as TDtTstAppDb).DB.GetChageTag(m_sChangeTagTable, m_sWhere);

        if sChangeTag_NOW <> m_sChangeTag_START then
        begin
          raise Exception.Create('Record has changed ("' + sChangeTag_NOW + '" vs. "' + m_sChangeTag_START + '")');
        end;

      end;

      if btnUpdate.Caption = csINSERT then
      begin

        dbSql.Insert {OrUpdate} (m_sTableOrView, asCols, asVals);

      end
      else if btnUpdate.Caption = csUPDATE then
      begin

        dbSql.{InsertOr} Update (m_sTableOrView, asCols, asVals, m_sWhere);

      end
      else if btnUpdate.Caption = csDELETE then
      begin

        dbSql.Delete(m_sTableOrView,m_sWhere);

      end;

      ModalResult := mrOk; // Close Form...

    except
      on exc : Exception do
      begin
        m_oApp.LOG.LogERROR(exc);

        sMsg := 'Error saving changes to Database!' +  CHR(10) + CHR(10) +
                'Error: ' + exc.ClassName + ' - ' + exc.Message;

        ErrorMsgDlg(sMsg);

        Exit;
      end;
    end;

  finally
    FreeAndNil(asCols);
    FreeAndNil(asVals);
    FreeAndNil(dbSql);
  end;

end;

end.
