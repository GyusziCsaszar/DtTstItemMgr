unit uDtTstDbSql;

interface

uses
  { DtTst Units: } uDtTstAppDb,
  System.Classes;

type
  TDtTstDbSql = class (TObject)
  private
    m_oApp: TDtTstAppDb;
  public
    constructor Create(oApp: TDtTstAppDb);
    destructor Destroy(); override;

    procedure Delete(sTable: string; sWhere: string);

    procedure Update(sTable: string; asColNames, asValues: TStringList; sWhere: string);

    procedure Insert(sTable: string; asColNames, asValues: TStringList);

    procedure InsertOrUpdate(sTable: string; asColNames, asValues: TStringList);

  end;

implementation

uses
  { DtTst Units: } uDtTstConsts,
  SysUtils,
  Data.Sqlexpr;

constructor TDtTstDbSql.Create(oApp: TDtTstAppDb);
begin
  m_oApp := oApp;

  inherited Create();

  m_oApp.LOG.LogLIFE('TDtTstDbSql.Create');
end;

destructor TDtTstDbSql.Destroy();
begin
  m_oApp.LOG.LogLIFE('TDtTstApp.Destroy');

  inherited Destroy();

  m_oApp := nil; // ATTN: Do not Free here!
end;

procedure TDtTstDbSql.Delete(sTable: string; sWhere: string);
var
  sSql: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // FIX: Before Insert Trigger!!!
    sSql := 'DELETE FROM ' + m_oApp.DB.FIXOBJNAME(sTable);

    sSql := sSql + ' WHERE ' + sWhere;

    // TODO...
    {
    ' RETURNING ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID);
    }

    oQry.SQLConnection := m_oApp.DB.SQLConnection;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oApp.LOG.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    //oQry.Prepared := True;

    m_oApp.DB.SQLConnection.StartTransaction(oTD);

    try

      oQry.ExecSQL(False);

      {
      oQry.Open();

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_X_ID)).AsInteger;
      }

      m_oApp.DB.SQLConnection.Commit(oTD);

    except

      m_oApp.DB.SQLConnection.Rollback(oTD);

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDbSql.Update(sTable: string; asColNames, asValues: TStringList; sWhere: string);
var
  iIdx: integer;
  sUpdateList, sSql, sVal: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    if asColNames.Count <> asValues.Count then
    begin
      raise Exception.Create('ERROR(TDtTstDbSql.Update): Count of Columns (' + IntToStr(asColNames.Count) + ') and Values (' + IntToStr(asValues.Count) + ') differ!');
    end;

    if sWhere.IsEmpty() then
    begin
      raise Exception.Create('ERROR(TDtTstDbSql.Update): No Where clause specified!');
    end;

    sUpdateList := '';
    for iIdx := 0 to asColNames.Count - 1 do
    begin

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        if not sUpdateList.IsEmpty() then sUpdateList := sUpdateList + ',';
        sUpdateList := sUpdateList + ' ' + asColNames[iIdx];

        sUpdateList := sUpdateList + ' = ' + ':VAL' + IntToStr(iIdx + 1);

      end;
    end;

    // FIX: Before Insert Trigger!!!
    sSql := 'UPDATE ' + m_oApp.DB.FIXOBJNAME(sTable);

    sSql := sSql + ' SET ' + sUpdateList;

    sSql := sSql + ' WHERE ' + sWhere;

    // TODO...
    {
    ' RETURNING ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID);
    }

    oQry.SQLConnection := m_oApp.DB.SQLConnection;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oApp.LOG.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    iIdx := -1;
    for sVal in asValues do
    begin
      iIdx := iIdx + 1;

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        oQry.Params.ParamByName('VAL' + IntToStr(iIdx + 1)).AsString := sVal;

      end;
    end;

    //oQry.Prepared := True;

    m_oApp.DB.SQLConnection.StartTransaction(oTD);

    try

      oQry.ExecSQL(False);

      {
      oQry.Open();

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_X_ID)).AsInteger;
      }

      m_oApp.DB.SQLConnection.Commit(oTD);

    except

      m_oApp.DB.SQLConnection.Rollback(oTD);

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDbSql.Insert(sTable: string; asColNames, asValues: TStringList);
var
  iIdx: integer;
  sColList, sValList, sSql, sVal: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    if asColNames.Count <> asValues.Count then
    begin
      raise Exception.Create('ERROR(TDtTstDbSql.Insert): Count of Columns (' + IntToStr(asColNames.Count) + ') and Values (' + IntToStr(asValues.Count) + ') differ!');
    end;

    sColList := '';
    for iIdx := 0 to asColNames.Count - 1 do
    begin

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        if not sColList.IsEmpty() then sColList := sColList + ',';
        sColList := sColList + ' ' + asColNames[iIdx];

        if not sValList.IsEmpty() then sValList := sValList + ',';
        sValList := sValList + ' ' + ':VAL' + IntToStr(iIdx + 1);

      end;
    end;

    // FIX: Before Insert Trigger!!!
    sSql := 'INSERT INTO ' + m_oApp.DB.FIXOBJNAME(sTable);

    sSql := sSql + ' (' + sColList + ' ) VALUES (' + sValList + ' )';

    // TODO...
    {
    ' RETURNING ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID);
    }

    oQry.SQLConnection := m_oApp.DB.SQLConnection;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oApp.LOG.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    iIdx := -1;
    for sVal in asValues do
    begin
      iIdx := iIdx + 1;

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        oQry.Params.ParamByName('VAL' + IntToStr(iIdx + 1)).AsString := sVal;

      end;
    end;

    //oQry.Prepared := True;

    m_oApp.DB.SQLConnection.StartTransaction(oTD);

    try

      oQry.ExecSQL(False);

      {
      oQry.Open();

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_X_ID)).AsInteger;
      }

      m_oApp.DB.SQLConnection.Commit(oTD);

    except

      m_oApp.DB.SQLConnection.Rollback(oTD);

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

procedure TDtTstDbSql.InsertOrUpdate(sTable: string; asColNames, asValues: TStringList);
var
  iIdx: integer;
  sColList, sValList, sSql, sVal: string;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    if asColNames.Count <> asValues.Count then
    begin
      raise Exception.Create('ERROR(TDtTstDbSql.InsertOrUpdate): Count of Columns (' + IntToStr(asColNames.Count) + ') and Values (' + IntToStr(asValues.Count) + ') differ!');
    end;

    sColList := '';
    for iIdx := 0 to asColNames.Count - 1 do
    begin

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        if not sColList.IsEmpty() then sColList := sColList + ',';
        sColList := sColList + ' ' + asColNames[iIdx];

        if not sValList.IsEmpty() then sValList := sValList + ',';
        sValList := sValList + ' ' + ':VAL' + IntToStr(iIdx + 1);

      end;
    end;

    // FIX: Before Insert Trigger!!!
    sSql := 'UPDATE OR INSERT INTO ' + m_oApp.DB.FIXOBJNAME(sTable);

    sSql := sSql + ' (' + sColList + ' ) VALUES (' + sValList + ' )';

    sSql := sSql + ' MATCHING (' + sColList + ' )';

    // TODO...
    {
    ' RETURNING ' + m_oApp.DB.FIXOBJNAME(csDB_FLD_ADM_X_ID);
    }

    oQry.SQLConnection := m_oApp.DB.SQLConnection;

    oQry.ParamCheck := True;
    // oQry.PrepareStatement;
    oQry.SQL.Add(m_oApp.LOG.LogSQL(sSql));

    // ATTN: To write UTF8 string, nothing extra is required!!!
    {
    // Is this required to write UTF8 String???
    //oQry.Params.ParamByName('PRD').DataType := ftWideString;
    //oQry.Params.ParamByName('PRD').AsWideString   := csCOMPANY + csPRODUCT;
    }

    iIdx := -1;
    for sVal in asValues do
    begin
      iIdx := iIdx + 1;

      if not asColNames[iIdx].IsEmpty() then  // Would happen with DB Tree!
      begin

        oQry.Params.ParamByName('VAL' + IntToStr(iIdx + 1)).AsString := sVal;

      end;
    end;

    //oQry.Prepared := True;

    m_oApp.DB.SQLConnection.StartTransaction(oTD);

    try

      oQry.ExecSQL(False);

      {
      oQry.Open();

      m_iADM_UserID := oQry.FieldByName(FIXOBJNAME(csDB_FLD_ADM_X_ID)).AsInteger;
      }

      m_oApp.DB.SQLConnection.Commit(oTD);

    except

      m_oApp.DB.SQLConnection.Rollback(oTD);

      raise;

    end;

  finally
    oQry.Close();
    FreeAndNil(oQry);
  end;
end;

end.
