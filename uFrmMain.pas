unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  { DtTst Units: } uDtTstConsts, uDtTstAppDb,
  { ATTN: for DBExpress: } midaslib,
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids, SimpleDS, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Tabs,
  System.ImageList, Vcl.ImgList,
  Generics.Collections;

type
  TFrmMain = class(TForm)
    con_Firebird_ANSI: TSQLConnection;
    qry_Top: TSQLQuery;
    db_grid_Top: TDBGrid;
    lblTop: TLabel;
    dsp_Top: TDataSetProvider;
    cds_Top: TClientDataSet;
    ds_cds_Top: TDataSource;
    sds_Bottom: TSimpleDataSet;
    ds_sds_Bottom: TDataSource;
    db_grid_Bottom: TDBGrid;
    lbObjects: TListBox;
    con_Firebird_UTF8: TSQLConnection;
    panDbInfo: TPanel;
    lblCaption: TLabel;
    panLeft: TPanel;
    panAdminMode: TPanel;
    lbLog: TListBox;
    lbTasks: TListBox;
    tmrStart: TTimer;
    chbAutoLogin: TCheckBox;
    chbMetadataTablesOnly: TCheckBox;
    chbShowLog: TCheckBox;
    lblBottom: TLabel;
    tvTree: TTreeView;
    ilTree: TImageList;
    tmrRefresh: TTimer;
    procedure sds_BottomAfterPost(DataSet: TDataSet);
    procedure cds_TopAfterPost(DataSet: TDataSet);
    procedure lbObjectsDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbTasksClick(Sender: TObject);
    procedure lbTasksDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbTasksMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbObjectsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbObjectsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbObjectsClick(Sender: TObject);
    procedure tmrStartTimer(Sender: TObject);
    procedure chbAutoLoginClick(Sender: TObject);
    procedure chbMetadataTablesOnlyClick(Sender: TObject);
    procedure ds_cds_TopDataChange(Sender: TObject; Field: TField);
    procedure chbShowLogClick(Sender: TObject);
    procedure lbLogDblClick(Sender: TObject);
    procedure lbTasksMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbTasksMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbTasksKeyPress(Sender: TObject; var Key: Char);
    procedure lbTasksKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbTasksKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbObjectsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbObjectsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbObjectsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbObjectsKeyPress(Sender: TObject; var Key: Char);
    procedure lbObjectsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrRefreshTimer(Sender: TObject);
  private
    { Private declarations }
    con_Firebird: TSQLConnection;
    m_oApp: TDtTstAppDb;
    m_bTasks_MouseDown: Boolean;
    m_bObjects_MouseDown: Boolean;
    m_bTablesView: Boolean;

    m_iDbInfo_HeightEx: integer;
    m_iLbLog_WidthEx: integer;
    m_iDbGrdBottom_HeightEx: integer;

    m_atnChecked: TObjectList<TObject>;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure DoGrid_Insert();
    procedure DoGrid_Delete();

    procedure DoGrid_Refresh();
    procedure SaveGridColumns(oGrd: TDBGrid; sName: string);
    procedure LoadGridColumns(oGrd: TDBGrid; sName: string);
    procedure OpenSql(sTable, sSql: string);

    procedure TREE_Refresh();
    procedure TREE_Update(bResetTree: Boolean; sID, sTreeNode: string);

    procedure DoDbConnect();

    procedure DoDropColumn(cID_Object: char; sCaption_Object: string);
    procedure DoDropTable(cID_Object: char; sCaption_Object: string);
    procedure DoDropView(cID_Object: char; sCaption_Object: string);

    procedure DoDeleteFromTable(cID_Object: char; sCaption_Object: string);

    procedure DoRefreshMetaData(bTablesView: Boolean);
    procedure DoRefreshMetaData_PRODUCT(var iIdx: integer);

    procedure DoEditTable(sAction, sCaption, sTable: string; asColsOverride, asColSources, asValues: TStringList;
                        sWhere, sChangeTagTable: string; bKeyEditAllowed: Boolean);
    procedure DoImportTable(bInsertOnly: Boolean; iIniImportDefIndex: integer; sCaption, sTable: string; asColsOverride: TStringList);

    procedure DoObjectsDblClick();
    procedure DoDetailsClick(cID_Object: char; sCaption_Object: string);

    function IsqlOpen(bConnectDB: Boolean; sStatements, sTerm: string; bChkIsqlResult: Boolean) : Boolean;

    procedure DoTaskOpenClick(cID_Object: char; sCaption_Object: string);

    procedure DoObjectsClick();
    procedure DoTasksClick();

    procedure DoLbMeasuerItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure DoLbDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState; bMouseDown: Boolean);

    function MnuGRP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuGRP(sCaption: string; iIndent: integer) : string;
    function MnuCAP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuCAP(sCaption: string; iIndent: integer) : string;
    function MnuITM_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
    function MnuITM(sCaption: string; iIndent: integer) : string;
    function MnuSPC() : string;
    function MnuBTN(cID: char; sCaption: string) : string;

    procedure Menu_ExtractItem(sItem: string; var rcID: char; var rsCaption: string);

    procedure Menu_AddTask_Button(cID: char; sCaption: string);
    procedure Menu_AddTask_Group(sCaption: string; iIndent: integer);
    procedure Menu_AddTask_Item(sCaption: string; iIndent: integer);

  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  { DtTst Units: } uDtTstConstsMenu, uDtTstUtils, uDtTstWin, uDtTstFirebird, uDtTstDb, uDtTstDbSql, uDtTstDbItemMgr,
  { DtTst Forms: } uFrmProgress, uFrmDataImport, uFrmFDB, uFrmDataEdit,
  System.IOUtils, StrUtils, Clipbrd, Math;

type
  TMyTreeNode = class(TObject)
  public
    m_tn: TTreeNode;
  end;

constructor TFrmMain.Create(AOwner: TComponent);
begin

  // NOTE: ShowMessage Title setting...
  Application.Title := csCOMPANY + ' ' + csPRODUCT_TITLE + ' ' + csVERSION_TITLE;

  con_Firebird := nil;

  m_bTasks_MouseDown   := False;
  m_bObjects_MouseDown := False;

  m_bTablesView := False;

  m_iDbInfo_HeightEx      := 0;
  m_iLbLog_WidthEx        := 0;
  m_iDbGrdBottom_HeightEx := 0;

  m_atnChecked := TObjectList<TObject>.Create();

  m_oApp := TDtTstAppDb.Create(TPath.ChangeExtension(Application.ExeName, csLOG_UTF8_EXT), //csLOG_EXT),
                             TPath.ChangeExtension(Application.ExeName, csINI_EXT));

  inherited Create(AOwner);

  LoadFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  //Registry...
  if m_oApp.ADMIN_MODE then
    chbShowLog.Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'ShowLog', True);

  if chbShowLog.Checked then
  begin
    m_oApp.LOG.m_lbLogView := lbLog;
  end;

  m_oApp.LOG.LogLIFE('TFrmMain.Create');

  try

    m_oApp.SetDb(TDtTstDb.Create(m_oApp.LOG, TPath.ChangeExtension(Application.ExeName, csINI_EXT)));

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

destructor TFrmMain.Destroy();
begin
  m_oApp.LOG.LogLIFE('TFrmMain.Destroy');

  SaveFormSizeReg(self, csCOMPANY, csPRODUCT, 'FrmMain');

  // Saving Columns...
  if cds_Top.Active    then SaveGridColumns(db_grid_Top,    lblTop   .Caption);
  if sds_Bottom.Active then SaveGridColumns(db_grid_Bottom, lblBottom.Caption);

  inherited Destroy();

  if Assigned(m_atnChecked) then m_atnChecked.Clear();
  FreeAndNil(m_atnChecked);

  FreeAndNil(m_oApp);
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.FormShow BEGIN');

  // NOTE: FormShow is called just before Form becomes visible BUT during construction!!!

  self      .Caption := Application.Title;
  lblCaption.Caption := Application.Title;

  m_iDbInfo_HeightEx := panDbInfo.Height;

  m_iLbLog_WidthEx := tvTree.Left - lbLog.Left;

  m_iDbGrdBottom_HeightEx := tvTree.Top - db_grid_Bottom.Top;

  // First LogINFO...
  m_oApp.LOG.LogVERSION('App Path: '  + Application.ExeName);
  m_oApp.LOG.LogVERSION('App Title: ' + Application.Title);
  m_oApp.LOG.LogVERSION('App Info: PRD = ' + csPRODUCT + ', VER = ' + IntToStr(ciVERSION));
  m_oApp.LOG.LogVERSION('App.DB Info: ADM_VER = ' + IntToStr(ciDB_VERSION_ADM) +
                      ', PRD = ' + csPRODUCT + ', PRD.VER = ' + IntToStr(ciDB_VERSION_PRD) );

  if not Assigned(m_oApp.DB) then
  begin
    Close();
    Exit();
  end;

  panAdminMode.Visible := m_oApp.ADMIN_MODE;
  panDbInfo   .Visible := m_oApp.ADMIN_MODE;

  // Registry...
  chbAutoLogin         .Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin'   , False);
  chbMetadataTablesOnly.Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'MetaTablesOnly', False);

  chbMetadataTablesOnly.Visible := m_oApp.ADMIN_MODE;

  db_grid_Top   .ReadOnly := (not m_oApp.ADMIN_MODE);
  db_grid_Bottom.ReadOnly := (not m_oApp.ADMIN_MODE);

  if not m_oApp.ADMIN_MODE then
    chbShowLog.Visible := False;

  if not chbShowLog.Checked then
  begin
    lbLog.Visible := False;
    tvTree.Left  := tvTree.Left  - m_iLbLog_WidthEx;
    tvTree.Width := tvTree.Width + m_iLbLog_WidthEx;
  end;

  db_grid_Bottom.Visible := False;
  tvTree.Top    := tvTree.Top    - m_iDbGrdBottom_HeightEx;
  tvTree.Height := tvTree.Height + m_iDbGrdBottom_HeightEx;
  lbLog.Top     := lbLog.Top     - m_iDbGrdBottom_HeightEx;
  lbLog.Height  := lbLog.Height  + m_iDbGrdBottom_HeightEx;

  if not m_oApp.ADMIN_MODE then
  begin
    lbObjects.Height := lbObjects.Height + m_iDbInfo_HeightEx;
    lbTasks  .Height := lbTasks  .Height + m_iDbInfo_HeightEx;
    lbLog    .Height := lbLog    .Height + m_iDbInfo_HeightEx;
    tvTree   .Height := tvTree   .Height + m_iDbInfo_HeightEx;
  end;

  tmrStart.Enabled := True;

  m_oApp.LOG.LogUI('TFrmMain.FormShow END');
end;

procedure TFrmMain.tmrStartTimer(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.tmrStartTimer START');

  tmrStart.Enabled := False;

  DoDbConnect();

  // Registry...
  chbAutoLogin         .Checked := LoadBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin'   , False);

  if (m_oApp.DB.ADM_DbInfVersion_PRD > 0) then
  begin

    // TREE...
    lblBottom.Caption := csITEM_ITEMGROUP;
    TREE_Refresh();

  end;

  m_oApp.LOG.LogUI('TFrmMain.tmrStartTimer END');
end;

procedure TFrmMain.cds_TopAfterPost(DataSet: TDataSet);
begin
  m_oApp.LOG.LogUI('TFrmMain.cds_TopAfterPost BEGIN');

  cds_Top.ApplyUpdates(0);

  m_oApp.LOG.LogUI('TFrmMain.cds_TopAfterPost END');
end;

procedure TFrmMain.sds_BottomAfterPost(DataSet: TDataSet);
begin
  m_oApp.LOG.LogUI('TFrmMain.sds_BottomAfterPost BEGIN');

  sds_Bottom.ApplyUpdates(0);

  m_oApp.LOG.LogUI('TFrmMain.sds_BottomAfterPost END');
end;

procedure TFrmMain.DoGrid_Delete();
begin

  if cds_Top.Active then
  begin

    if QuestionMsgDlg('Do you want to Delete the selected row?') then
    begin

      try
        cds_Top.Delete();
        cds_Top.ApplyUpdates(0);
      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);
          ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
        end;
      end;
    end;
  end;
end;

procedure TFrmMain.DoGrid_Insert();
begin

  if cds_Top.Active then
  begin

    if QuestionMsgDlg('Do you want to Insert a New row?') then
    begin

      try
        cds_Top.Insert();
      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);
          ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
        end;
      end;
    end;
  end;
end;

procedure TFrmMain.DoGrid_Refresh();
begin

  // Saving Columns...
  if cds_Top.Active    then SaveGridColumns(db_grid_Top,    lblTop   .Caption);
  if sds_Bottom.Active then SaveGridColumns(db_grid_Bottom, lblBottom.Caption);

  if cds_Top.Active then
  begin
    try

      cds_Top.Active := False;
      qry_Top.Active := False;

      // TREE...
      lblBottom.Caption := csITEM_ITEMGROUP;
      TREE_Refresh();

      qry_Top.Active := True;
      m_oApp.LOG.LogINFO('SQL Query is Active!');

      cds_Top.Active := True;
      m_oApp.LOG.LogINFO('Client DataSet is Active!');

      // Loading Columns...
      LoadGridColumns(db_grid_Top, lblTop.Caption);

    except
      on exc : Exception do
      begin
        m_oApp.LOG.LogERROR(exc);
        ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
      end;
    end;
  end;

  if sds_Bottom.Active then
  begin

    try

      sds_Bottom.Active := False;

      sds_Bottom.Active := True;
      m_oApp.LOG.LogINFO('Simple DataSet is Active!');

      // Loading Columns...
      LoadGridColumns(db_grid_Bottom, lblBottom.Caption);

    except
      on exc : Exception do
      begin
        m_oApp.LOG.LogERROR(exc);
        ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
      end;
    end;
  end;
end;

procedure TFrmMain.tmrRefreshTimer(Sender: TObject);
begin
  tmrRefresh.Enabled := False;

  DoGrid_Refresh();
end;

procedure TFrmMain.SaveGridColumns(oGrd: TDBGrid; sName: string);
var
  iCol: integer;
begin

  SaveIntegerReg(csCOMPANY, csPRODUCT, 'ColumnWidths\' + sName, 'ColumnCount', oGrd.Columns.Count);

  for iCol := 0 to oGrd.Columns.Count - 1 do
  begin
    SaveIntegerReg(csCOMPANY, csPRODUCT, 'ColumnWidths\' + sName, 'Column' + IntToStr(iCol + 1), oGrd.Columns[iCol].Width);
  end;

end;

procedure TFrmMain.LoadGridColumns(oGrd: TDBGrid; sName: string);
var
  iCount, iCol, iWidth: integer;
begin

  iCount := LoadIntegerReg(csCOMPANY, csPRODUCT, 'ColumnWidths\' + sName, 'ColumnCount', -1);

  // Column Widths...
  for iCol := 0 to oGrd.Columns.Count - 1 do
  begin
    if iCount = oGrd.Columns.Count then
    begin
      iWidth := LoadIntegerReg(csCOMPANY, csPRODUCT, 'ColumnWidths\' + sName,
                  'Column' + IntToStr(iCol + 1), ciDBGRID_COLWIDTH_DEF);

      oGrd.Columns[iCol].Width := Min(iWidth, ciDBGRID_COLWIDTH_MAX);
    end
    else
    begin
      oGrd.Columns[iCol].Width := ciDBGRID_COLWIDTH_DEF;
    end;
  end;

end;

procedure TFrmMain.OpenSql(sTable, sSql: string);
begin

  // Saving Columns...
  if cds_Top.Active    then SaveGridColumns(db_grid_Top,    lblTop   .Caption);
  if sds_Bottom.Active then SaveGridColumns(db_grid_Bottom, lblBottom.Caption);

  try
    lblTop.Caption := 'N/A';

    cds_Top.Active := False;
    qry_Top.Active := False;
    qry_Top.SQL.Clear();

    if not sSQL.IsEmpty() then
    begin

      qry_Top.SQL.Add(m_oApp.LOG.LogSQL(sSQL));
      qry_Top.Active := True;
      m_oApp.LOG.LogINFO('SQL Query is Active!');
      cds_Top.Active := True;
      m_oApp.LOG.LogINFO('Client DataSet is Active!');

      lblTop.Caption := sTable;

      // Loading Columns...
      LoadGridColumns(db_grid_Top, lblTop.Caption);

      //  FIX: Force Refresh...
      // NOTE: Not doing so, TFrmMain.ds_cds_TopDataChange
      //       will be called WITHOUT ACTIVE ROW
      //       which is otherwise MARKED ACTIVE!
      tmrRefresh.Enabled := True;

    end;
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  try
    lblBottom.Caption := csITEM_ITEMGROUP; //'N/A';

    sds_Bottom.Active := False;
    sds_Bottom.DataSet.CommandText := '';

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;
end;

procedure TFrmMain.ds_cds_TopDataChange(Sender: TObject; Field: TField);
var
  iRelCnt, iRel: integer;
  sField, sDefault, sSql, sID: string;
  bHasRel: Boolean;
begin

  if (m_oApp.DB.ADM_DbInfVersion_PRD > 0) and (ds_cds_Top.DataSet.FindField(csDB_FLD_USR_ITEM_ITEMNR) <> nil) then
  begin

    // TREE...
    lblBottom.Caption := csITEM_ITEMGROUP;
    TREE_Update(False {bResetTree}, ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR).AsString, '' {sTreeNode});

  end
  else if (m_oApp.DB.ADM_DbInfVersion_PRD > 0) and (ds_cds_Top.DataSet.FindField(csDB_FLD_USR_ITEMGROUP_NODE) <> nil) then
  begin

    // TREE...
    lblBottom.Caption := csITEM_ITEMGROUP;
    TREE_Update(False {bResetTree}, '' {sID}, ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMGROUP_NODE).AsString);

  end
  else
  begin

    //NOP...

  end;

  bHasRel := False;

  iRelCnt := m_oApp.DB.GetINIRelCount();
  for iRel := 0 to iRelCnt - 1 do
  begin
    if m_oApp.DB.GetINIRel(iRel, sField, sDefault, sSql) then
    begin

      if ds_cds_Top.DataSet.FindField(sField) <> nil then
      begin

        bHasRel := True;

        if not db_grid_Bottom.Visible then
        begin
          lbLog.Height  := lbLog.Height  - m_iDbGrdBottom_HeightEx;
          lbLog.Top     := lbLog.Top     + m_iDbGrdBottom_HeightEx;
          tvTree.Height := tvTree.Height - m_iDbGrdBottom_HeightEx;
          tvTree.Top    := tvTree.Top    + m_iDbGrdBottom_HeightEx;
          db_grid_Bottom.Visible := True;
        end;

        sID := ds_cds_Top.DataSet.FieldByName(sField).AsString;

        if sID.IsEmpty() then
          sID := sDefault;

        sds_Bottom.Active := False;

        if sDefault.IsEmpty() then // Char!!!
          sds_Bottom.DataSet.CommandText := sSql.Replace(':ID', '''' + sID + '''')
        else
          sds_Bottom.DataSet.CommandText := sSql.Replace(':ID', sID);

        sds_Bottom.Active := True;

        lblBottom.Caption := 'Details' + ' for ' + lblTop.Caption;

        // Loading Columns...
        LoadGridColumns(db_grid_Bottom, lblBottom.Caption);

        Break;
      end;

    end;
  end;

  if not bHasRel then
  begin

    if db_grid_Bottom.Visible then
    begin
      db_grid_Bottom.Visible := False;
      tvTree.Top    := tvTree.Top    - m_iDbGrdBottom_HeightEx;
      tvTree.Height := tvTree.Height + m_iDbGrdBottom_HeightEx;
      lbLog.Top     := lbLog.Top     - m_iDbGrdBottom_HeightEx;
      lbLog.Height  := lbLog.Height  + m_iDbGrdBottom_HeightEx;
    end;

  end;

end;

procedure TFrmMain.TREE_Refresh();
begin
  TREE_Update(True {bResetTree}, '' {sID}, '' {sTreeNode});
end;

procedure TFrmMain.TREE_Update(bResetTree: Boolean; sID, sTreeNode: string);
var
  sSql: string;
  oQry: TSQLQuery;
  iItemCount: integer;
  sTreePath: string;
  asNodes: TStringList;
  tn, tnTmp: TTreeNode;
  sNode: string;
  i, iLevel: integer;
  myTn: TMyTreeNode;
begin

  asNodes := TStringList.Create();
  oQry := TSQLQuery.Create(nil);
  try

    if bResetTree then
    begin

      sSql := 'SELECT ' + '0 AS ItemCount' +
                   ', ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH +
               ' FROM ' + csDB_TBL_USR_ITEMGROUP + ' A' +
           ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH;

    end
    else
    begin

      if not sID.IsEmpty() then
      begin

        // FIX: We need only the checked item(s)!!!
        {
        sSql := 'SELECT ' +
                     '(SELECT COUNT(*) FROM ' + csDB_TBL_USR_ITEM_ITEMGROUP + ' B' +
                     ' JOIN ' + csDB_TBL_USR_ITEM + ' C ON C.' + csDB_FLD_ADM_X_ID + ' = B.' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID +
                     ' WHERE B.' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID + ' = A.' + csDB_FLD_ADM_X_ID +
                       ' AND C.' + csDB_FLD_USR_ITEM_ITEMNR + ' = ''' + sID + ''') AS ItemCount' +
                     ', ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH +
                 ' FROM ' + csDB_TBL_USR_ITEMGROUP + ' A' +
             ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH;
        }

        sSql := 'SELECT ' + '1 AS ItemCount' +
                     ', ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH +
                 ' FROM ' + csDB_TBL_USR_ITEMGROUP + ' A' +
                 ' JOIN ' + csDB_TBL_USR_ITEM_ITEMGROUP + ' B' + ' ON ' + 'B.' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID + ' = A.' + csDB_FLD_ADM_X_ID +
                 ' JOIN ' + csDB_TBL_USR_ITEM + ' C ON C.' + csDB_FLD_ADM_X_ID + ' = B.' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID +
                 ' WHERE ' + 'C.' + csDB_FLD_USR_ITEM_ITEMNR + ' = ''' + sID + '''' +
             ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH;

      end
      else //if not sTreeNode.IsEmpty() then
      begin

        // FIX: We need only the checked item(s)!!!
        {
        sSql := 'SELECT ' +
                     '(IIF(A.' + csDB_FLD_USR_ITEMGROUP_NODE + ' = ''' + sTreeNode + ''', 1, 0)) AS ItemCount' +
                     ', ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH +
                 ' FROM ' + csDB_TBL_USR_ITEMGROUP + ' A' +
             ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH;
        }

        sSql := 'SELECT ' + '1 AS ItemCount' +
                     ', ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH +
                 ' FROM ' + csDB_TBL_USR_ITEMGROUP + ' A' +
                 ' WHERE ' + 'A.' + csDB_FLD_USR_ITEMGROUP_NODE + ' = ''' + sTreeNode + '''' +
             ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEMGROUP_PATH;

      end;
    end;

    oQry.SQLConnection := m_oApp.DB.SQLConnection;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oApp.LOG.LogSQL(sSql));

    oQry.Open();

    tvTree.Items.BeginUpdate;

    if bResetTree then
    begin
      tvTree.Items.Clear();
    end
    else
    begin

      // Clear previous Check-marks...
      for i := 0 to m_atnChecked.Count - 1 do
      begin
        if Assigned((m_atnChecked[i] as TMyTreeNode).m_tn) then
        begin
          (m_atnChecked[i] as TMyTreeNode).m_tn.StateIndex := 1;
        end;
      end;
    end;

    m_atnChecked.Clear();

    while not oQry.Eof do
    begin

      iItemCount := oQry.FieldByName('ItemCount').AsInteger;
      sTreePath  := oQry.FieldByName(csDB_FLD_USR_ITEMGROUP_PATH).AsString;

      if sTreePath.Length > 4 then
      begin

        Split(csDB_TREE_Delimiter, sTreePath.Substring(2, sTreePath.Length - 4), asNodes);

        tn := nil;
        for iLevel := 0 to asNodes.Count - 1 do //sNode in asNodes do
        begin

          sNode := asNodes[iLevel];

          if tn = nil then
          begin

            for i := 0 to tvTree.Items.Count - 1 do
            begin
              tvTree.Items[i].Expanded := True;

              if tvTree.Items[i].Text = sNode then
              begin
                tn := tvTree.Items[i];
                tn.Expanded := True;
              end;
            end;

            if tn = nil then
            begin
              tn := tvTree.Items.AddChild(nil, sNode);

              tn.StateIndex := 1;
              tn.Expanded := True;
            end;

          end
          else
          begin

            tnTmp := tn.getFirstChild();
            while tnTmp <> nil do
            begin
              tnTmp.Expanded := True;

              if tnTmp.Text = sNode then
              begin
                tn := tnTmp;
                tn.Expanded := True;

                Break;
              end;

              tnTmp := tn.GetNextChild(tnTmp);
            end;

            if tnTmp = nil then
            begin
              tn.Expanded := True;
              tn := tvTree.Items.AddChild(tn, sNode);
              tn.StateIndex := 1;
            end;

          end;

          if iItemCount = 0 then
          begin
            tn.Expanded := True;
            //tn.StateIndex := 1;

            tnTmp := tn.Parent;
            while tnTmp <> nil do
            begin

              if tnTmp.StateIndex = 1 then
              begin

                //tnTmp.StateIndex := 3; //tn.StateIndex;

              end;

              tnTmp.Expanded := True;
              tnTmp := tnTmp.Parent;
            end;

            if iLevel = (asNodes.Count - 1) then
            begin
              tn.Expanded := True;
              //tn.StateIndex := 2;
            end;
          end
          else
          begin

            tn.Expanded := True;

            tnTmp := tn.Parent;
            while tnTmp <> nil do
            begin

              if tnTmp.StateIndex = 1 then
              begin

                tnTmp.StateIndex := 3; //tn.StateIndex;

                // Remember Check...
                myTn := TMyTreeNode.Create();
                myTn.m_tn := tnTmp;
                m_atnChecked.Add(myTn);

              end;

              tnTmp.Expanded := True;
              tnTmp := tnTmp.Parent;
            end;

            if iLevel = (asNodes.Count - 1) then
            begin
              tn.Expanded := True;

              tn.StateIndex := 2;

              // Remember Check...
              myTn := TMyTreeNode.Create();
              myTn.m_tn := tn;
              m_atnChecked.Add(myTn);
            end;
          end;

        end;
      end;

      oQry.Next;
    end;

    tvTree.Items.EndUpdate;

    oQry.Close();

  finally
    FreeAndNil(asNodes);
    FreeAndNil(oQry);
  end;

end;

procedure TFrmMain.chbAutoLoginClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.chbAutoConnectClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\DB', 'AutoLogin', chbAutoLogin.Checked);

  m_oApp.LOG.LogUI('TFrmMain.chbAutoConnectClick END');
end;

procedure TFrmMain.chbMetadataTablesOnlyClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.chbMetadataTablesOnlyClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'MetaTablesOnly', chbMetadataTablesOnly.Checked);

  DoRefreshMetaData(m_bTablesView);

  m_oApp.LOG.LogUI('TFrmMain.chbMetadataTablesOnlyClick END');
end;

procedure TFrmMain.chbShowLogClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.chbShowLogClick BEGIN');

  SaveBooleanReg(csCOMPANY, csPRODUCT, 'Settings\UI', 'ShowLog', chbShowLog.Checked);

  if chbShowLog.Checked then
  begin
    m_oApp.LOG.m_lbLogView := lbLog;

    tvTree.Width := tvTree.Width - m_iLbLog_WidthEx;
    tvTree.Left  := tvTree.Left  + m_iLbLog_WidthEx;
    lbLog.Visible := True;
  end
  else
  begin
    m_oApp.LOG.m_lbLogView := nil;
    lbLog.Items.Clear();

    lbLog.Visible := False;
    tvTree.Left  := tvTree.Left  - m_iLbLog_WidthEx;
    tvTree.Width := tvTree.Width + m_iLbLog_WidthEx;
  end;

  m_oApp.LOG.LogUI('TFrmMain.chbShowLogClick END');
end;

procedure TFrmMain.DoDbConnect();
var
  frmFdb: TFrmFDB;
  iModalResult: integer;
  sSqlOpenSelect: string;
begin
  m_oApp.LOG.LogInfo('TFrmMain.DoDbConnect BEGIN');

  sSqlOpenSelect := '';

  frmFdb := TFrmFDB.Create(self, m_oApp);
  try

    m_oApp.LOG.LogUI('TFrmFDB.ShowModal CALL');
    iModalResult := frmFdb.ShowModal(con_Firebird_ANSI, con_Firebird_UTF8);
    m_oApp.LOG.LogUI('TFrmFDB.ShowModal RETU');

    if iModalResult <> mrOk then
    begin
      Close();
      Exit;
    end;

    sSqlOpenSelect := frmFdb.SQL_OpenSelect;

    con_Firebird := frmFdb.CON;

    panDbInfo.Caption := frmFdb.GetDbInfo();

  finally
    FreeAndNil(frmFdb);
  end;

  try

    // ATTN: Required!!!
    qry_Top    .SQLConnection := con_Firebird;
    sds_Bottom .   Connection := con_Firebird;

    m_oApp.LOG.LogINFO('SQL Connection is Connected!');

    DoRefreshMetaData(m_bTablesView);

    if not sSqlOpenSelect.IsEmpty() then
    begin
      OpenSql('SQL Editor', sSqlOpenSelect);
    end;

  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  m_oApp.LOG.LogInfo('TFrmMain.DoDbConnect END');
end;

procedure TFrmMain.DoDropColumn(cID_Object: char; sCaption_Object: string);
var
  asParts, asTblCol: TStringList;
begin

  asParts  := TStringList.Create();
  asTblCol := TStringList.Create();
  try

    Split('|', sCaption_Object, asParts);

    Split('.', asParts[2], asTblCol);

    if not QuestionMsgDlg('Do you want to DROP column "' + asTblCol[1] + '" of table "' + asTblCol[0] + '"?') then
    begin
      Exit;
    end;

    try

      m_oApp.DB.META_DropTableColumn(asTblCol[0], asTblCol[1]);

      InfoMsgDlg('You have DROPPED column "' + asTblCol[1] + '" of table "' + asTblCol[0] + '"!');
    except
      on exc : Exception do
      begin
        m_oApp.LOG.LogERROR(exc);
        ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
      end;
    end;

    DoRefreshMetaData(m_bTablesView);

  finally
    FreeAndNil(asParts);
      FreeAndNil(asTblCol);
  end;
end;

procedure TFrmMain.DoDeleteFromTable(cID_Object: char; sCaption_Object: string);
begin

  if not QuestionMsgDlg('Do you want to DELETE all ROWs of table "' + sCaption_Object + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.ExecuteSQL(nil {nil = DO Transaction}, 'DELETE FROM ' + m_oApp.DB.FIXOBJNAME(sCaption_Object) + ';');

    InfoMsgDlg('You have DELETED all ROWs of table "' + sCaption_Object + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.DoDropTable(cID_Object: char; sCaption_Object: string);
begin

  if not QuestionMsgDlg('Do you want to DROP table "' + sCaption_Object + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.META_DropTable(sCaption_Object);

    InfoMsgDlg('You have DROPPED table "' + sCaption_Object + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  DoRefreshMetaData(m_bTablesView);
end;

procedure TFrmMain.DoDropView(cID_Object: char; sCaption_Object: string);
begin

  if not QuestionMsgDlg('Do you want to DROP view "' + sCaption_Object + '"?') then
  begin
    Exit;
  end;

  try

    m_oApp.DB.META_DropView(sCaption_Object);

    InfoMsgDlg('You have DROPPED view "' + sCaption_Object + '"!');
  except
    on exc : Exception do
    begin
      m_oApp.LOG.LogERROR(exc);
      ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

  DoRefreshMetaData(m_bTablesView);
end;

procedure TFrmMain.DoRefreshMetaData(bTablesView: Boolean);
var
  iIdx: integer;
  cID: char;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin

  //if m_oApp.DB.Connected then Exit;
  if (not Assigned(con_Firebird)) or (not con_Firebird.Connected) then Exit;

  lbObjects.Items.Clear();
  lbTasks.Items.Clear();

  if bTablesView and m_oApp.ADMIN_MODE then
  begin

    con_Firebird.GetTableNames(lbObjects.Items, False);

    for iIdx := 0 to lbObjects.Items.Count - 1 do
    begin
      lbObjects.Items[iIdx] := MnuCAP_Selectable(ccMnuItmID_Table, lbObjects.Items[iIdx], 0);
    end;
  end;

  if (not chbMetadataTablesOnly.Checked) and bTablesView and m_oApp.ADMIN_MODE then
  begin

    iIdx := -1;
    while True do
    begin
      iIdx := iIdx + 1;

      if iIdx >= lbObjects.Items.Count then
      begin
        break;
      end;

      Menu_ExtractItem(lbObjects.Items[iIdx], cID, sTable);

      asItems := TStringList.Create();

      // Table Fields
      asItems.Clear();
      try

        con_Firebird.GetFieldNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Columns', 2));

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM_Selectable(ccMnuItmID_Table_Column, '|' + sItem + '|' + sTable + '.' + sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      // Table Indices
      asItems.Clear();
      try

        con_Firebird.GetIndexNames(sTable, asItems);

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Indices', 2));

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM(sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      // Table Triggers
      asItems.Clear();
      try

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Triggers', 2));

        m_oApp.DB.Select_Triggers(asItems, nil {asInfos}, sTable, '' {sTriggerName}, False {bDecorate}, False {bFull});

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM_Selectable(ccMnuItmID_Table_Trigger, '|' + sItem + '|' + sTable + '.' + sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      // Table Constraints
      asItems.Clear();
      try

        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuGRP('Constraints', 2));

        m_oApp.DB.Select_Constraints(False {bFKeysOnly}, asItems, nil {asInfos}, sTable, '' {sConstraintName}, False {bDecorate});

        for sItem in asItems do
        begin
          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, MnuITM_Selectable(ccMnuItmID_Table_Constraint, '|' + sItem + '|' + sTable + '.' + sItem, 2));
        end;

      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);

          iIdx := iIdx + 1;
          lbObjects.Items.Insert(iIdx, '    ' + '<ERROR RETRIVING...>');
        end;
      end;

      FreeAndNil(asItems);

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuSPC());

    end;
  end;

  if (not chbMetadataTablesOnly.Checked) and (not bTablesView) and m_oApp.ADMIN_MODE then
  begin
    iIdx := -1;

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP_Selectable(ccMnuGrpID_Database, 'Database', 0));

    {
    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP('Properties', 0));
    }

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuITM('Login Username: ' + con_Firebird.GetLoginUsername(), 1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuITM('Default SchemaName: ' + con_Firebird.GetDefaultSchemaName(), 1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuITM('Driver Func: ' + con_Firebird.GetDriverFunc, 1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuITM('Server Charset: ' + con_Firebird.Params.Values['ServerCharset'] + ' // NOTE: Requested by client!', 1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP('Generators', 0));
    asItems := TStringList.Create();
    try

      m_oApp.DB.Select_Generators(asItems);

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuITM(sItem, 1));
      end;
    finally
      FreeAndNil(asItems);
    end;

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP('Views', 0));
    asItems := TStringList.Create();
    try

      m_oApp.DB.Select_Views(asItems);

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_View, sItem, 1)); //MnuITM(sItem, 0));
      end;
    finally
      FreeAndNil(asItems);
    end;

  end
  else
  begin
    iIdx := -1;
  end;

  if m_oApp.ADMIN_MODE then
  begin

    if bTablesView then
    begin

      {
      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuGRP('Tables', 0));
      }

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuBTN(ccMnuBtnID_Tables_Back, 'Back'));

    end
    else
    begin

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuBTN(ccMnuBtnID_Tables, 'Tables and Views'));

    end;

    {
    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuSPC());
    }

    if not bTablesView then
    begin

      lbObjects.Items.Add(MnuGRP('Queries', 0));

      lbObjects.Items.Add(MnuCAP_Selectable(ccMnuItmID_Query, '|DUAL (in firebird RDB$DATABASE)|select current_timestamp from RDB$DATABASE', 1));

    end;

  end;

  // NOTE: Increase Scroll Height...
  lbObjects.Items.Add(MnuSPC());

  if not bTablesView then
  begin

    iIdx := -1;
    DoRefreshMetaData_PRODUCT(iIdx);

    if (m_oApp.ADMIN_MODE) and (m_oApp.DB.ADM_DbInfVersion_ADM > ciDB_VERSION_PRD_NONE) then
    begin

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuGRP(csPRODUCT_TITLE + ' (HIDDEN)', 0));

      // BUG: Unable to Edit!
      {
      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + '|' +
                         'SELECT ' + 'A.' + csDB_FLD_USR_ITEM_NAME +
                         ', ' + 'B.' + csDB_FLD_USR_ITEMTYPE_NAME +
                         ' FROM ' + csDB_TBL_USR_ITEM + ' A' +
                         ' LEFT JOIN ' + csDB_TBL_USR_ITEMTYPE + ' B' +
                         '   ON (B.' + csDB_FLD_ADM_X_ID + ' = A.' + csDB_FLD_USR_ITEM_ITEMTYPE_ID + ')' +
                         ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME, 1));
      }

      // BUG: Unable to Edit!
      {
      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + '|' +
                         'SELECT ' + csDB_FLD_USR_ITEM_NAME +
                         ', ' + '(SELECT ' + 'B.' + csDB_FLD_USR_ITEMTYPE_NAME +
                                 ' FROM ' + csDB_TBL_USR_ITEMTYPE + ' B' +
                                 ' WHERE ' + 'B.' + csDB_FLD_ADM_X_ID + ' = ' + csDB_FLD_USR_ITEM_ITEMTYPE_ID +
                                 ') ' + csDB_FLD_USR_ITEMTYPE_NAME +
                         ' FROM ' + csDB_TBL_USR_ITEM +
                         ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME, 1));
      }

      // BUG: Unable to Edit!
      {
      // SRC: https://forums.devart.com/viewtopic.php?t=22628
      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + '|' +
                         'SELECT ' + 'A.' + csDB_FLD_USR_ITEM_NAME + ', ' + 'B.' + csDB_FLD_USR_ITEMTYPE_NAME +
                         ' FROM ' + csDB_TBL_USR_ITEM + ' A' +
                             ', ' + csDB_TBL_USR_ITEMTYPE + ' B' +
                         ' WHERE ' + 'A.' + csDB_FLD_USR_ITEM_ITEMTYPE_ID + ' = ' + 'B.' + csDB_FLD_ADM_X_ID +
                         ' ORDER BY ' + 'A.' + csDB_FLD_USR_ITEM_NAME, 1));
      }
      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + ' (Table)' + '|' +
                                   'SELECT ' + csDB_FLD_ADM_X_ID +
                                        ', ' + csDB_FLD_USR_ITEM_ITEMNR +
                                        ', ' + csDB_FLD_USR_ITEM_NAME +
                                        ', ' + csDB_FLD_USR_ITEM_ITEMTYPE_ID +
                                        ', ' + csDB_FLD_USR_ITEM_AMO +
                                   ' FROM ' + csDB_TBL_USR_ITEM +
                                   ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME,
                                    1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + ' (View #1)' + '|' +
                                   'SELECT *' +
                                   ' FROM ' + 'V_' + csDB_TBL_USR_ITEM +
                                   ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME,
                                    1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + ' (View #2)' + '|' +
                                   'SELECT *' +
                                   ' FROM ' + 'V_' + csDB_TBL_USR_ITEM + '_EX' +
                                   ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME,
                                    1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM_GROUP + ' (Table)' + '|' +
                                   'SELECT ' + csDB_FLD_ADM_X_ID +
                                        ', ' + csDB_FLD_USR_ITEMGROUP_NODE +
                                        ', ' + csDB_FLD_USR_ITEMGROUP_LEVEL +
                                        ', ' + csDB_FLD_USR_ITEMGROUP_PATH +
                                   ' FROM ' + csDB_TBL_USR_ITEMGROUP +
                                   ' ORDER BY ' + csDB_FLD_USR_ITEMGROUP_NODE,
                                    1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuGRP('Database Administration Mode', 0));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + 'DB INFO' + '|' +
                                   'SELECT *' +
                                   ' FROM ' + csDB_TBL_ADM_DBINF, 1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + 'USERS' + '|' +
                                   'SELECT *' +
                                   ' FROM ' + csDB_TBL_ADM_USERS +
                                   ' ORDER BY ' + csDB_FLD_ADM_X_ID, 1));

      iIdx := iIdx + 1;
      lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + 'TABLES' + '|' +
                                   'SELECT *' +
                                   ' FROM ' + csDB_TBL_ADM_TABLES +
                                   ' ORDER BY ' + csDB_FLD_ADM_X_ID, 1));

    end;

  end;

end;

procedure TFrmMain.DoRefreshMetaData_PRODUCT(var iIdx: integer);
begin

  iIdx := -1;

  if (m_oApp.DB.ADM_DbInfProduct = csPRODUCT_FULL) then
  begin

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuGRP(csPRODUCT_TITLE, 0));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM + '|' +
                                 'SELECT *' +
                                 ' FROM ' + 'V_' + csDB_TBL_USR_ITEM + //'_EX' + // ATTN: ..._EX duplicates multi-node ITEM(s)!!!
                                 ' ORDER BY ' + csDB_FLD_USR_ITEM_NAME,
                                  1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM_TYPE + '|' +
                                 'SELECT ' + csDB_FLD_USR_ITEMTYPE_NAME +
                                 ' FROM ' + csDB_TBL_USR_ITEMTYPE +
                                 ' ORDER BY ' + csDB_FLD_USR_ITEMTYPE_NAME,
                                  1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM_GROUP + '|' +
                                 'SELECT ' + csDB_FLD_USR_ITEMGROUP_NODE +
                                      ', ' + csDB_FLD_USR_ITEMGROUP_LEVEL +
                                      ', ' + csDB_FLD_USR_ITEMGROUP_PATH +
                                 ' FROM ' + csDB_TBL_USR_ITEMGROUP +
                                 ' ORDER BY ' + csDB_FLD_USR_ITEMGROUP_NODE,
                                  1));

    iIdx := iIdx + 1;
    lbObjects.Items.Insert(iIdx, MnuCAP_Selectable(ccMnuItmID_Query, '|' + csITEM_ITEMGROUP + '|' +
                                 'SELECT ' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID +
                                      ', ' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID +
                                 ' FROM ' + csDB_TBL_USR_ITEM_ITEMGROUP +
                                 ' ORDER BY ' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID +
                                         ', ' + csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID,
                                  1));

  end;

end;

procedure TFrmMain.DoEditTable(sAction, sCaption, sTable: string; asColsOverride, asColSources, asValues: TStringList;
  sWhere, sChangeTagTable: string; bKeyEditAllowed: Boolean);
var
  asCols, asCols_InUse, asInfos, asTmp: TStringList;
  sCol, sColReal: string;
  frmEdt: TFrmDataEdit;
begin

  asCols       := TStringList.Create();
  asInfos      := TStringList.Create();
  asTmp        := TStringList.Create();
  asCols_InUse := nil;
  frmEdt := TFrmDataEdit.Create(self, m_oApp);
  try

    if Assigned(asColsOverride) then
    begin
      asCols_InUse := asColsOverride;

      for sCol in asCols_InUse do
      begin
        asTmp.Clear();

        sColReal := sCol;

        { DB TREE }
        if {EndsText not worked!} ContainsText(sCol, csDB_TREE_NODE) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_NODE, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_PARENT) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_PARENT, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_PATH) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_PATH, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_LEVEL) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_LEVEL, '', [rfReplaceAll]));
        end;

        if sColReal.IsEmpty() then
        begin
          if asInfos.Count = 0 then
          begin
            raise Exception.Create('ERROR: No DB Info available for column "' + sCol + '"! No DB Info to copy!');
          end;

          // ATTN: Copy DB Info of previous column!!!
          asInfos.Add(asInfos[asInfos.Count - 1]);

        end
        else
        begin

          if m_oApp.DB.Select_Fields(nil {asNames}, asTmp, sTable, sColReal, False {bDecorate}) then
            asInfos.Add(asTmp[0])
          else
            asInfos.Add(''); // ERROR...

        end;
      end;

    end
    else
    begin

      //con_Firebird.GetFieldNames(sTable, asCols);

      m_oApp.DB.Select_Fields(asCols {asNames}, asInfos, sTable, '' {sFieldName}, False {bDecorate});

      asCols_InUse := asCols;
    end;

    frmEdt.Init(sAction, sCaption, sTable, asCols_InUse, asInfos, asColSources, asValues, sWhere, sChangeTagTable, bKeyEditAllowed);

    FreeAndNil(asCols);
    FreeAndNil(asInfos);

    frmEdt.ShowModal();

    DoObjectsDblClick();

  finally
    FreeAndNil(asCols);
    //FreeAndNil(asCols_InUse); //DO NOT!!!
    FreeAndNil(asInfos);
    FreeAndNil(asTmp);
    FreeAndNil(frmEdt);
  end;
end;

procedure TFrmMain.DoImportTable(bInsertOnly: Boolean; iIniImportDefIndex: integer; sCaption, sTable: string; asColsOverride: TStringList);
var
  asCols, asCols_InUse, asInfos, asTmp: TStringList;
  sCol, sColReal: string;
  frmImp: TFrmDataImport;
begin

  asCols       := TStringList.Create();
  asInfos      := TStringList.Create();
  asTmp        := TStringList.Create();
  asCols_InUse := nil;
  frmImp := TFrmDataImport.Create(self, m_oApp);
  try

    if Assigned(asColsOverride) then
    begin
      asCols_InUse := asColsOverride;

      for sCol in asCols_InUse do
      begin
        asTmp.Clear();

        sColReal := sCol;

        { DB TREE }
        if {EndsText not worked!} ContainsText(sCol, csDB_TREE_NODE) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_NODE, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_PARENT) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_PARENT, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_PATH) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_PATH, '', [rfReplaceAll]));
        end
        else if {EndsText not worked!} ContainsText(sCol, csDB_TREE_LEVEL) then
        begin
          sColReal := TRIM(sCol.Replace(csDB_TREE_LEVEL, '', [rfReplaceAll]));
        end;

        if sColReal.IsEmpty() then
        begin
          if asInfos.Count = 0 then
          begin
            raise Exception.Create('ERROR: No DB Info available for column "' + sCol + '"! No DB Info to copy!');
          end;

          // ATTN: Copy DB Info of previous column!!!
          asInfos.Add(asInfos[asInfos.Count - 1]);

        end
        else
        begin

          if m_oApp.DB.Select_Fields(nil {asNames}, asTmp, sTable, sColReal, False {bDecorate}) then
            asInfos.Add(asTmp[0])
          else
            asInfos.Add(''); // ERROR...

        end;
      end;

    end
    else
    begin

      //con_Firebird.GetFieldNames(sTable, asCols);

      m_oApp.DB.Select_Fields(asCols {asNames}, asInfos, sTable, '' {sFieldName}, False {bDecorate});

      asCols_InUse := asCols;
    end;

    frmImp.Init(bInsertOnly, iIniImportDefIndex, sCaption, sTable, asCols_InUse, asInfos);

    FreeAndNil(asCols);
    FreeAndNil(asInfos);

    frmImp.ShowModal();

    DoObjectsDblClick();

  finally
    FreeAndNil(asCols);
    //FreeAndNil(asCols_InUse); //DO NOT!!!
    FreeAndNil(asInfos);
    FreeAndNil(asTmp);
    FreeAndNil(frmImp);
  end;
end;

procedure TFrmMain.lbObjectsMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
  DoLbMeasuerItem(Control, Index, Height);
end;

procedure TFrmMain.lbTasksMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
  DoLbMeasuerItem(Control, Index, Height);
end;

procedure TFrmMain.DoLbMeasuerItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  sItem: string;
begin

  sItem := (Control as TListBox).Items[Index];
  if sItem.IsEmpty() then Exit;

  case sItem[ciMnuIdx_Ctrl] of

    ccMnuBtn,
    ccMnuGrp,
    ccMnuCap : begin

      Height := Height * 2;

    end;

  end;

  //m_oApp.LOG.LogINFO('MeasureItem - Height - ' + IntToStr(Height));

end;

procedure TFrmMain.lbObjectsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoLbDrawItem(Control, Index, Rect, State, m_bObjects_MouseDown);
end;

procedure TFrmMain.lbTasksDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoLbDrawItem(Control, Index, Rect, State, m_bTasks_MouseDown);
end;

procedure TFrmMain.DoLbDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState; bMouseDown: Boolean);
// SRC: https://stackoverflow.com/questions/8563508/how-do-i-draw-the-selected-list-box-item-in-a-different-color
var
  sItem, sTitle: string;
  X, Y: integer;
  sz: TSize;
  asParts: TStringList;
begin

  sItem := (Control as TListBox).Items[Index];
  if sItem.IsEmpty() then Exit;

  sTitle := sItem.Substring(ciMnuCch);

  if (not sTitle.IsEmpty()) and (sTitle[1] = '|') then
  begin
    asParts := TStringList.Create();
    try
      Split('|', sTitle, asParts);
      sTitle := asParts[1];
    finally
      FreeAndNil(asParts);
    end;
  end;

  with (Control as TListBox).Canvas do
  begin

    case sItem[ciMnuIdx_Ctrl] of

      ccMnuBtn : begin

        if odSelected in State then
        begin
          Brush.Color := clWindow;
          Font.Color  := clWindowText;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        // DrawCaption((Control as TListBox).Handle, (Control as TListBox).Canvas.Handle, Rect, DC_ACTIVE or DC_ICON or DC_TEXT);
        // DrawFrameControl( (Control as TListBox).Canvas.Handle, Rect, DFC_CAPTION, DFCS_CAPTIONCLOSE );

        Rect.Left   := Rect.Left   + 3;
        Rect.Right  := Rect.Right  - 2;
        Rect.Top    := Rect.Top    + 3;
        Rect.Bottom := Rect.Bottom - 2;

        if bMouseDown and (odSelected in State) then
          DrawFrameControl( (Control as TListBox).Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED )
        else
          DrawFrameControl( (Control as TListBox).Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH );

        X := Rect.Left + 10;
        Y := Rect.Top  + 6;

        SetBkMode((Control as TListBox).Canvas.Handle, TRANSPARENT);
        TextOut(X, Y, sTitle);
        SetBkMode((Control as TListBox).Canvas.Handle, OPAQUE);

        {
        if odFocused In State then
        begin
          //Brush.Color := (Control as TListBox).Color;
          DrawFocusRect(Rect);
        end;
        }

      end;

      ccMnuGrp: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        (Control as TListBox).Canvas.Font.Height := (Control as TListBox).Canvas.Font.Height - 2;

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

        sz := TextExtent(sTitle);

        MoveTo(X, Y + sz.cy);
        LineTo(X + sz.cx, Y + sz.cy);

      end;

      ccMnuCap: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        (Control as TListBox).Canvas.Font.Height := (Control as TListBox).Canvas.Font.Height - 1;

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

        {
        sz := TextExtent(sTitle);

        MoveTo(X, Y + sz.cy);
        LineTo(X + sz.cx, Y + sz.cy);
        }

      end;

      ccMnuItm: begin

        if sItem[4] = '0' then
        begin
          if odSelected in State then
          begin
            Brush.Color := clWindow;
            Font.Color  := clWindowText;
          end;
        end;

        // ATTN: Required!!!
        FillRect(Rect);

        X := Rect.Left + ciMnuGrpItmLeftMargin;
        Y := Rect.Top; //  + 8;

        // Indent...
        X := X + (StrToInt(sItem[3]) * 5);

        TextOut(X, Y, sTitle);

      end

      else begin

        FillRect(Rect);
        TextOut(Rect.Left, Rect.Top, sItem);

      end;

    end;

  end;
end;

procedure TFrmMain.lbLogDblClick(Sender: TObject);
begin
  if lbLog.ItemIndex >= 0 then
  begin
    Clipboard.AsText := lbLog.Items[lbLog.ItemIndex];
  end;
end;

procedure TFrmMain.lbObjectsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsMouseDown BEGIN');

  m_bObjects_MouseDown := True;
  lbObjects.Repaint;

  {
  DoObjectsClick();
  }

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsMouseDown END');
end;

procedure TFrmMain.lbTasksMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbTasksMouseDown BEGIN');

  m_bTasks_MouseDown := True;
  lbTasks.Repaint;

  {
  DoTasksClick();
  }

  m_oApp.LOG.LogUI('TFrmMain.lbTasksMouseDown END');
end;

procedure TFrmMain.lbObjectsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsMouseUp BEGIN');

  m_bObjects_MouseDown := False;
  lbObjects.Repaint;

  DoObjectsClick();

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsMouseUp END');

end;

procedure TFrmMain.lbTasksMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbTasksMouseUp BEGIN');

  m_bTasks_MouseDown := False;
  lbTasks.Repaint;

  DoTasksClick();

  m_oApp.LOG.LogUI('TFrmMain.lbTasksMouseUp END');
end;

procedure TFrmMain.lbObjectsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyDown BEGIN');

  if Key = VK_SPACE then
  begin

    m_bObjects_MouseDown := True;
    lbObjects.Repaint;

    {
    DoObjectsClick();
    }

  end;

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyDown END');
end;

procedure TFrmMain.lbTasksKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyDown BEGIN');

  if Key = VK_SPACE then
  begin

    m_bTasks_MouseDown := True;
    lbTasks.Repaint;

    {
    DoTasksClick();
    }

  end;

  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyDown END');
end;

procedure TFrmMain.lbObjectsKeyPress(Sender: TObject; var Key: Char);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyPress BEGIN');

  {
  if Key = ' ' then //VK_SPACE then
  begin
    DoObjectsClick();
  end;
  }

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyPress END');
end;

procedure TFrmMain.lbTasksKeyPress(Sender: TObject; var Key: Char);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyPress BEGIN');

  {
  if Key = ' ' then //VK_SPACE then
  begin
    DoTasksClick();
  end;
  }

  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyPress END');
end;

procedure TFrmMain.lbObjectsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyUp BEGIN');

  if Key = VK_SPACE then
  begin

    m_bObjects_MouseDown := False;
    lbObjects.Repaint;

    DoObjectsClick();

  end;

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsKeyUp END');
end;

procedure TFrmMain.lbTasksKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyUp BEGIN');

  if Key = VK_SPACE then
  begin

    m_bTasks_MouseDown := False;
    lbTasks.Repaint;

    DoTasksClick();

  end;

  m_oApp.LOG.LogUI('TFrmMain.lbTasksKeyUp END');
end;

procedure TFrmMain.lbObjectsClick(Sender: TObject);
begin
  {
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsClick BEGIN');

  DoObjectClick();

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsClick END');
  }
end;

procedure TFrmMain.lbObjectsDblClick(Sender: TObject);
begin
  m_oApp.LOG.LogUI('TFrmMain.lbObjectsDblClick BEGIN');

  DoObjectsDblClick();

  m_oApp.LOG.LogUI('TFrmMain.lbObjectsDblClick END');
end;

procedure TFrmMain.DoObjectsDblClick();
var
  cID_Object: char;
  sCaption_Object: string;
  asParts: TStringList;
begin

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID_Object, sCaption_Object);

  DoTaskOpenClick(cID_Object, sCaption_Object);
end;

procedure TFrmMain.lbTasksClick(Sender: TObject);
begin
  {
  m_oApp.LOG.LogUI('TFrmMain.lbOptionsClick BEGIN');

  DoTasksClick();

  m_oApp.LOG.LogUI('TFrmMain.lbOptionsClick END');
  }
end;

procedure TFrmMain.DoDetailsClick(cID_Object: char; sCaption_Object: string);
var
  asParts, asTblCols, asInfos: TStringList;
  sInf, sInfos: string;
begin
  if cID_Object = ccMnuItmID_Table_Column then
  begin

    asParts   := TStringList.Create();
    asTblCols := TStringList.Create();
    asInfos   := TStringList.Create();
    try

      Split('|', sCaption_Object, asParts);

      Split('.', asParts[2], asTblCols);

      try

        if not m_oApp.DB.Select_Fields(nil {asNames}, asInfos, asTblCols[0], asTblCols[1], True {bDecorate}) then
        begin
          ErrorMsgDlg('ERROR: No information is available for' + CHR(10) + 'Column "' + asTblCols[1] + '" of table "' + asTblCols[0] + '"!');
        end
        else
        begin

          sInfos := 'Detailed information about' + CHR(10) + 'Column "' + asTblCols[1] + '" of table "' + asTblCols[0] + '":' + CHR(10);

          for sInf in asInfos do
          begin
            sInfos := sInfos + CHR(10) + StringReplace(sInf, '|', CHR(10), [rfReplaceAll]);
          end;

          InfoMsgDlg(sInfos);

        end;
      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);
          ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
        end;
      end;

    finally
      FreeAndNil(asParts);
      FreeAndNil(asTblCols);
      FreeAndNil(asInfos);
    end;
  end
  else if cID_Object = ccMnuItmID_Table_Trigger then
  begin

    asParts   := TStringList.Create();
    asTblCols := TStringList.Create();
    asInfos   := TStringList.Create();
    try

      Split('|', sCaption_Object, asParts);

      Split('.', asParts[2], asTblCols);

      try

        if not m_oApp.DB.Select_Triggers(nil {asNames}, asInfos, asTblCols[0], asTblCols[1], True {bDecorate}, False {bFull}) then
        begin
          ErrorMsgDlg('ERROR: No information is available for' + CHR(10) + 'Trigger "' + asTblCols[1] + '" of table "' + asTblCols[0] + '"!');
        end
        else
        begin

          sInfos := 'Detailed information about' + CHR(10) + 'Trigger "' + asTblCols[1] + '" of table "' + asTblCols[0] + '":' + CHR(10);

          for sInf in asInfos do
          begin
            sInfos := sInfos + CHR(10) + StringReplace(sInf, '|', CHR(10), [rfReplaceAll]);
          end;

          InfoMsgDlg(sInfos);

        end;
      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);
          ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
        end;
      end;

    finally
      FreeAndNil(asParts);
      FreeAndNil(asTblCols);
      FreeAndNil(asInfos);
    end;
  end
else if cID_Object = ccMnuItmID_Table_Constraint then
  begin

    asParts   := TStringList.Create();
    asTblCols := TStringList.Create();
    asInfos   := TStringList.Create();
    try

      Split('|', sCaption_Object, asParts);

      Split('.', asParts[2], asTblCols);

      try

        if not m_oApp.DB.Select_Constraints(false {bFKeysOnly}, nil {asNames}, asInfos, asTblCols[0], asTblCols[1], True {bDecorate}) then
        begin
          ErrorMsgDlg('ERROR: No information is available for' + CHR(10) + 'Constraint "' + asTblCols[1] + '" of table "' + asTblCols[0] + '"!');
        end
        else
        begin

          sInfos := 'Detailed information about' + CHR(10) + 'Constrint "' + asTblCols[1] + '" of table "' + asTblCols[0] + '":' + CHR(10);

          for sInf in asInfos do
          begin
            sInfos := sInfos + CHR(10) + StringReplace(sInf, '|', CHR(10), [rfReplaceAll]);
          end;

          InfoMsgDlg(sInfos);

        end;
      except
        on exc : Exception do
        begin
          m_oApp.LOG.LogERROR(exc);
          ErrorMsgDlg('Error: ' + exc.ClassName + ' - ' + exc.Message);
        end;
      end;

    finally
      FreeAndNil(asParts);
      FreeAndNil(asTblCols);
      FreeAndNil(asInfos);
    end;
  end
  else if cID_Object = ccMnuGrpID_Database then
  begin

    IsqlOpen(True {bConnectDB}, 'SHOW DATABASE;', '' {sTerm}, False {bChkIsqlResult});

  end;
end;

function TFrmMain.IsqlOpen(bConnectDB: Boolean; sStatements, sTerm: string; bChkIsqlResult: Boolean) : Boolean;
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

      {
      (m_oApp as TDtTstAppDb).DB.ConnectUser     := edUser.Text;
      (m_oApp as TDtTstAppDb).DB.ConnectPassword := edPw  .Text;

      if bConnectDB then
        sDb := cbbDb.Text
      else
        sDb := '';
      }

      sOutput := ISQL_Execute(m_oApp.LOG, TPath.GetDirectoryName(Application.ExeName),
                              m_oApp.DB.IsqlPathChecked,
                              m_oApp.DB.ConnectString,
                              m_oApp.DB.ConnectUser, m_oApp.DB.ConnectPassword,
                              True {bGetOutput},
                              (m_oApp.DB.IsqlOptions = 1) {bVisible},
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

procedure TFrmMain.DoTaskOpenClick(cID_Object: char; sCaption_Object: string);
var
  asParts: TStringList;
begin
  if (cID_Object = ccMnuItmID_Table) or (cID_Object = ccMnuItmID_View) then
  begin

    OpenSql(sCaption_Object, 'select * from ' + sCaption_Object);

  end
  else if cID_Object = ccMnuItmID_Query then
  begin

    asParts := TStringList.Create();
    try

      Split('|', sCaption_Object, asParts);

      OpenSql(asParts[1], asParts[2]);

    finally
      FreeAndNil(asParts);
    end;
  end;
end;

procedure TFrmMain.DoObjectsClick();
var
  cID: char;
  sCaption: string;
  asParts: TStringList;
  bKnown: Boolean;
begin

  lbTasks.Items.Clear();

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID, sCaption);

  asParts := TStringList.Create();
  try

    Split('|', sCaption, asParts);

    bKnown := True;

    Menu_AddTask_Group(                               'Browse'                , 0 );

    if (cID = ccMnuItmID_Table) or (cID = ccMnuItmID_View) or (cID = ccMnuItmID_Query)  then
      Menu_AddTask_Button(ccMnuBtnID_Open             , 'Open'                    );

    Menu_AddTask_Button(ccMnuBtnID_GrdRefresh         , 'Refresh'                 );

    if m_oApp.ADMIN_MODE then
    begin

      Menu_AddTask_Group(                               'Browse (Edit)'       , 0 );
      Menu_AddTask_Button(ccMnuBtnID_GrdInsert          , 'Insert'                );
      Menu_AddTask_Button(ccMnuBtnID_GrdDelete          , 'Delete'                );

    end;

    case cID of

      ccMnuBtnID_Tables: begin

        m_bTablesView := True;
        DoRefreshMetaData(m_bTablesView);

      end;

      ccMnuBtnID_Tables_Back: begin

        m_bTablesView := False;
        DoRefreshMetaData(m_bTablesView);

      end;

      ccMnuGrpID_Database: begin

        Menu_AddTask_Group(                               'View'                , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Refresh            , 'Refresh Metadata'      );
        Menu_AddTask_Button(ccMnuBtnID_Details            , 'Details'               );

      end;

      ccMnuItmID_View: begin

        Menu_AddTask_Group(                               'Caution!!!'          , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Drop_View          , 'DROP View'             );

      end;

      ccMnuItmID_Table: begin

        Menu_AddTask_Group(                               'Import'              , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Import_Table       , 'Import (CSV)'          );
        Menu_AddTask_Group(                               'Caution!!!'          , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Delete_From_Table  , 'DELETE from Table'     );
        Menu_AddTask_Button(ccMnuBtnID_Drop_Table         , 'DROP Table'            );

      end;

      ccMnuItmID_Table_Column: begin

        Menu_AddTask_Group(                               'View'                , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Details            , 'Details'               );
        Menu_AddTask_Group(                               'Caution!!!'          , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Drop_Column        , 'DROP Column'           );

      end;

      ccMnuItmID_Table_Trigger: begin

        Menu_AddTask_Group(                               'View'                , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Details            , 'Details'               );

      end;

      ccMnuItmID_Table_Constraint: begin

        Menu_AddTask_Group(                               'View'                , 0 );
        Menu_AddTask_Button(ccMnuBtnID_Details            , 'Details'               );

      end;

      ccMnuItmID_Query: begin

        if asParts[1] = csITEM_TYPE then
        begin
          Menu_AddTask_Group(                             'Edit'                , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item_Type   , csINSERT                );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item_Type   , csUPDATE                );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item_Type   , csDELETE                );
          Menu_AddTask_Group(                             'Import'              , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Import_Item_Type , 'Import (CSV)'          );
        end
        else if asParts[1] = csITEM + ' (View #1)' then
        begin
          Menu_AddTask_Group(                             'Import'              , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Import_Item_v1      , 'Import (CSV)'       );
        end
        else if asParts[1] = csITEM then
        begin
          Menu_AddTask_Group(                             'Edit'                , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item        , csINSERT                );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item        , csUPDATE                );
          Menu_AddTask_Button(ccMnuBtnID_Edit_Item        , csDELETE                );
          Menu_AddTask_Group(                             csITEM_GROUP + ' Assignment' , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Assign_Item        , csADD                );
          Menu_AddTask_Button(ccMnuBtnID_Assign_Item        , csREMOVE                );
          Menu_AddTask_Group(                             'Import'              , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Import_Item      , 'Import (CSV)'          );
        end
        else if asParts[1] = csITEM_GROUP then
        begin
          Menu_AddTask_Group(                             'Import'              , 0 );
          Menu_AddTask_Button(ccMnuBtnID_Import_Item_Group, 'Import (CSV)'          );
        end;

      end;

      else begin
        bKnown := False;
      end;

    end;

    if bKnown then
    begin

      // TODO...

    end;

    // ATTN: FIX: for BUG: Click on lb lower area Clicked on last Button!!!
    lbTasks.Items.Add(MnuSPC());

  finally
    FreeAndNil(asParts);
  end;

end;

procedure TFrmMain.DoTasksClick();
var
  cID_Task, cID_Object: char;
  sCaption_Task, sCaption_Object: string;
  asParts, asCols, asColSources, asValues: TStringList;
  bEdit: Boolean;
  sWhere, sChangeTagTable: string;
  bKeyEditAllowed: Boolean;
  sSql: string;
  bm: TBookmark;
begin

  if lbTasks.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbTasks.Items[lbTasks.ItemIndex], cID_Task, sCaption_Task);

  if lbObjects.ItemIndex < 0 then Exit;
  Menu_ExtractItem(lbObjects.Items[lbObjects.ItemIndex], cID_Object, sCaption_Object);

  asParts         := nil;
  asCols          := nil;
  asColSources    := nil;
  asValues        := nil;
  sWhere          := '';
  bKeyEditAllowed := False;
  try

    case cID_Task of

      { Common }

      ccMnuBtnID_Refresh : begin
        DoRefreshMetaData(m_bTablesView);
      end;

      ccMnuBtnID_Details : begin
        DoDetailsClick(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_Open : begin
        DoTaskOpenClick(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_Import_Table : begin
        DoImportTable(False {bInsertOnly / or InsertOrUpdate}, -1 {iIniImportDefIndex}, sCaption_Object, sCaption_Object, nil);
      end;

      ccMnuBtnID_Drop_View : begin
        DoDropView(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_Delete_From_Table : begin
        DoDeleteFromTable(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_Drop_Table : begin
        DoDropTable(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_Drop_Column : begin
        DoDropColumn(cID_Object, sCaption_Object);
      end;

      ccMnuBtnID_GrdRefresh : begin
        DoGrid_Refresh();
      end;

      ccMnuBtnID_GrdDelete : begin
        DoGrid_Delete();
      end;

      ccMnuBtnID_GrdInsert : begin
        DoGrid_Insert();
      end;

      { Product }

      ccMnuBtnID_Import_Item_Type : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEMTYPE_NAME);

        DoImportTable(False {bInsertOnly / or InsertOrUpdate}, 1 {iIniImportDefIndex}, asParts[1], csDB_TBL_USR_ITEMTYPE, asCols);

      end;

      ccMnuBtnID_Import_Item_v1 : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEM_ITEMNR);
        asCols.Add(csDB_FLD_USR_ITEM_NAME);
        asCols.Add(csDB_FLD_USR_ITEMTYPE_NAME);
        asCols.Add(csDB_FLD_USR_ITEM_AMO);

        DoImportTable(False {bInsertOnly / or InsertOrUpdate}, 2 {iIniImportDefIndex}, asParts[1], 'V_' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM), asCols);

      end;

      ccMnuBtnID_Import_Item : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEM_ITEMNR);
        asCols.Add(csDB_FLD_USR_ITEM_NAME);
        asCols.Add(csDB_FLD_USR_ITEMTYPE_NAME);
        asCols.Add(csDB_FLD_USR_ITEM_AMO);
        asCols.Add(csDB_FLD_USR_ITEMGROUP_NODE);

        DoImportTable(True {bInsertOnly / or InsertOrUpdate}, 3 {iIniImportDefIndex}, asParts[1], 'V_' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM) + '_EX', asCols);

      end;

      ccMnuBtnID_Import_Item_Group : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEMGROUP_NODE  + ' ' + csDB_TREE_NODE);
        asCols.Add(csDB_TREE_PARENT);
        asCols.Add(csDB_FLD_USR_ITEMGROUP_PATH  + ' ' + csDB_TREE_PATH);
        asCols.Add(csDB_FLD_USR_ITEMGROUP_LEVEL + ' ' + csDB_TREE_LEVEL);

        DoImportTable(False {bInsertOnly / or InsertOrUpdate}, 0 {iIniImportDefIndex}, asParts[1], csDB_TBL_USR_ITEMGROUP, asCols);

        // TREE...
        lblBottom.Caption := csITEM_ITEMGROUP;
        TREE_Refresh();

      end;

      ccMnuBtnID_Edit_Item_Type : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEMTYPE_NAME);

        asColSources := TStringList.Create();

        bEdit := False;
        if sCaption_Task = csINSERT then
        begin
          bEdit := True;
        end
        else //if (sCaption_Task = csUPDATE) or (sCaption_Task = csDELETE) then
        begin
          if ds_cds_Top.DataSet.Active then
          begin
            if not ds_cds_Top.DataSet.IsEmpty then
            begin
              if ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMTYPE_NAME) <> nil then
              begin
                bEdit := True;

                bKeyEditAllowed := True;

                sChangeTagTable := m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEMTYPE);

                asValues := TStringList.Create();
                asValues.Add(ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMTYPE_NAME).AsString);

                sWhere := m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) + ' = ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMTYPE_NAME).AsString + '''';
              end;
            end;
          end;
        end;

        if bEdit then
        begin
          DoEditTable(sCaption_Task, asParts[1], m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEMTYPE), asCols, asColSources, asValues,
                      sWhere, sChangeTagTable, bKeyEditAllowed);
        end
        else
        begin
          WarningMsgDlg('Select a record to ' + sCaption_Task + '!');
        end;

      end;

      ccMnuBtnID_Edit_Item : begin

        asParts := TStringList.Create();

        Split('|', sCaption_Object, asParts);

        asCols := TStringList.Create();
        asCols.Add(csDB_FLD_USR_ITEM_ITEMNR);
        asCols.Add(csDB_FLD_USR_ITEM_NAME);
        asCols.Add(csDB_FLD_USR_ITEMTYPE_NAME);
        asCols.Add(csDB_FLD_USR_ITEM_AMO);

        asColSources := TStringList.Create();
        asColSources.Add('');
        asColSources.Add('');
        asColSources.Add('1|SELECT ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                            ' FROM ' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEMTYPE) +
                        ' ORDER BY ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME));

        if sCaption_Task = csINSERT then
        begin
          bEdit := True;
        end
        else //if (sCaption_Task = csUPDATE) or (sCaption_Task = csDELETE) then
        begin
          if ds_cds_Top.DataSet.Active then
          begin
            if not ds_cds_Top.DataSet.IsEmpty then
            begin
              if ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR) <> nil then
              begin
                bEdit := True;

                bKeyEditAllowed := False;

                sChangeTagTable := m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM);

                asValues := TStringList.Create();
                asValues.Add(ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR).AsString);
                asValues.Add(ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_NAME).AsString);
                asValues.Add(ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMTYPE_NAME).AsString);
                asValues.Add(ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_AMO).AsString);

                sWhere := m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) + ' = ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR).AsString + '''';
              end;
            end;
          end;
        end;

        if bEdit then
        begin
          DoEditTable(sCaption_Task, asParts[1], 'V_' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM), asCols, asColSources, asValues,
                    sWhere, sChangeTagTable, bKeyEditAllowed);
        end
        else
        begin
          WarningMsgDlg('Select a record to ' + sCaption_Task + '!');
        end;

      end;

      ccMnuBtnID_Assign_Item : begin

        bEdit := False;

        if ds_cds_Top.DataSet.Active then
        begin
          if not ds_cds_Top.DataSet.IsEmpty then
          begin
            if ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR) <> nil then
            begin

              if sCaption_Task = csADD then
              begin

                if tvTree.Selected = nil then
                begin
                  WarningMsgDlg('Select a TREE node to Assign!');
                  bEdit := True; // Suppres other Msg!
                end
                else
                begin

                  bEdit := True;

                  sSql := 'INSERT INTO ' + 'V_' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM) + '_EX' +
                          ' ( ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) +
                             ', ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEM_NAME) +
                             ', ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMTYPE_NAME) +
                             ', ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEM_AMO) +
                             ', ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) +
                             ' ) VALUES ' +
                            '( ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR).AsString + '''' +
                            ', ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_NAME).AsString + '''' +
                            ', ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEMTYPE_NAME).AsString + '''' +
                            ', ' + {'''' +} ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_AMO).AsString + {'''' +}
                            ', ' + '''' + tvTree.Selected.Text + '''' +
                            ' );';

                  // FIX: ISC Error...
                  bm := ds_cds_Top.DataSet.GetBookmark();
                  ds_cds_Top.DataSet.Active := False;
                  try

                    try

                      m_oApp.DB.ExecuteSQL(nil {nil = DO Transaction}, sSql);

                    except
                      on exc : Exception do
                      begin
                        m_oApp.LOG.LogERROR(exc);

                        ErrorMsgDlg('Error assigning TREE node!' +  CHR(10) + CHR(10) +
                                'Error: ' + exc.ClassName + ' - ' + exc.Message);
                      end;
                    end;

                  finally
                    ds_cds_Top.DataSet.Active := True;

                    // Loading Columns...
                    LoadGridColumns(db_grid_Top, lblTop.Caption);

                    // Restory Active Row...
                    if ds_cds_Top.DataSet.BookmarkValid(bm) then
                    begin
                      try
                        ds_cds_Top.DataSet.GotoBookmark(bm);
                        ds_cds_Top.DataSet.FreeBookmark(bm);
                      except
                        //NOP...
                      end;
                    end;

                  end;

                end;

              end
              else if sCaption_Task = csREMOVE then
              begin

                if tvTree.Selected = nil then
                begin
                  WarningMsgDlg('Select a TREE node to Remove assignment!');
                  bEdit := True; // Suppres other Msg!
                end
                else
                begin

                  bEdit := True;

                  sSql := 'DELETE FROM ' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM_ITEMGROUP) + ' A' +
                          ' WHERE EXISTS (' +
                          ' SELECT B.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                          ' FROM ' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM_ITEMGROUP) + ' B' +
                              ', ' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM) + ' C' +
                              ', ' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEMGROUP) + ' D' +
                         ' WHERE ' + ' B.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID) + ' = ' + ' A.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                         '   AND ' + ' B.' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID) + ' = ' + ' C.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                         '   AND ' + ' B.' + m_oApp.DB.FIXOBJNAME(csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID) + ' = ' + ' D.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID) +
                         '   AND ' + ' C.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEM_ITEMNR) + ' = ' + '''' + ds_cds_Top.DataSet.FieldByName(csDB_FLD_USR_ITEM_ITEMNR).AsString + '''' +
                         '   AND ' + ' D.' + m_oApp.DB.FIXOBJNAME(csDB_FLD_USR_ITEMGROUP_NODE) + ' = ' + '''' + tvTree.Selected.Text + '''' +
                         ')';

                  // FIX: ISC Error...
                  bm := ds_cds_Top.DataSet.GetBookmark();
                  ds_cds_Top.DataSet.Active := False;
                  try

                    try

                      m_oApp.DB.ExecuteSQL(nil {nil = DO Transaction}, sSql);

                    except
                      on exc : Exception do
                      begin
                        m_oApp.LOG.LogERROR(exc);

                        ErrorMsgDlg('Error Removing assignment with TREE node!' +  CHR(10) + CHR(10) +
                                'Error: ' + exc.ClassName + ' - ' + exc.Message);
                      end;
                    end;

                  finally
                    ds_cds_Top.DataSet.Active := True;

                    // Loading Columns...
                    LoadGridColumns(db_grid_Top, lblTop.Caption);

                    // Restory Active Row...
                    if ds_cds_Top.DataSet.BookmarkValid(bm) then
                    begin
                      try
                        ds_cds_Top.DataSet.GotoBookmark(bm);
                        ds_cds_Top.DataSet.FreeBookmark(bm);
                      except
                        //NOP...
                      end;
                    end;
                  end;

                end;

              end;

            end;
          end;
        end;

        if not bEdit then
        begin
          WarningMsgDlg('Select a record to Assign!');
        end;

      end;

    end;

  finally
    FreeAndNil(asParts);
    FreeAndNil(asCols);
    FreeAndNil(asColSources);
    FreeAndNil(asValues);
  end;
end;

function TFrmMain.MnuGRP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuGrp + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuGRP(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuGrp + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuCAP_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuCap + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuCAP(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuCap + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuITM_Selectable(cID: char; sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuItm + cID + IntToStr(iIndent) + '1' + sCaption;
end;

function TFrmMain.MnuITM(sCaption: string; iIndent: integer) : string;
begin
  Result := ccMnuItm + '0' + IntToStr(iIndent) + '0' + sCaption;
end;

function TFrmMain.MnuSPC() : string;
begin
  Result := ccMnuItm + '0' + '0' + '0';
end;

procedure TFrmMain.Menu_ExtractItem(sItem: string; var rcID: char; var rsCaption: string);
begin

  rcID      := '0';
  rsCaption := '';

  if sItem.Length < ciMnuCch then Exit;

  rcID      := sItem[ciMnuIdx_ID];
  rsCaption := sItem.Substring(ciMnuCch);
end;

function TFrmMain.MnuBTN(cID: char; sCaption: string) : string;
begin
  Result := ccMnuBtn + cID + '0' + '0' + sCaption;
end;

procedure TFrmMain.Menu_AddTask_Button(cID: char; sCaption: string);
begin
  lbTasks.Items.Add(MnuBTN(cID, sCaption));
end;

procedure TFrmMain.Menu_AddTask_Group(sCaption: string; iIndent: integer);
begin
  lbTasks.Items.Add(MnuGRP(sCaption, iIndent));
end;

procedure TFrmMain.Menu_AddTask_Item(sCaption: string; iIndent: integer);
begin
  lbTasks.Items.Add(MnuITM(sCaption, iIndent));
end;

end.
