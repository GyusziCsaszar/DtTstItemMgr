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

procedure TDtTstDbSql.InsertOrUpdate(sTable: string; asColNames, asValues: TStringList);
var
  sSql, str: string;
  iIdx: Integer;
  oQry: TSQLQuery;
  oTD: TTransactionDesc;
begin

  // SRC: http://codeverge.com/embarcadero.delphi.dbexpress/tsqlquery-params-and-insert-stat/1079500
  oQry := TSQLQuery.Create(nil);
  try

    // FIX: Before Insert Trigger!!!
    sSql := 'UPDATE OR INSERT INTO ' + m_oApp.DB.FIXOBJNAME(sTable) + ' (';

    iIdx := -1;
    for str in asColNames do
    begin
      iIdx := iIdx + 1;

      if iIdx > 0 then sSql := sSql + ',';
      sSql := sSql + ' ' + str;
    end;

    sSql := sSql + ') VALUES (';

    iIdx := -1;
    for str in asValues do
    begin
      iIdx := iIdx + 1;

      if iIdx > 0 then sSql := sSql + ',';
      sSql := sSql + ' ' + ':VAL' + IntToStr(iIdx + 1);
    end;

    sSql := sSql + ')';

    sSql := sSql + ' MATCHING (';

    iIdx := -1;
    for str in asColNames do
    begin
      iIdx := iIdx + 1;

      if iIdx > 0 then sSql := sSql + ',';
      sSql := sSql + ' ' + str;
    end;

    sSql := sSql + ')';

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
    for str in asValues do
    begin
      iIdx := iIdx + 1;

      oQry.Params.ParamByName('VAL' + IntToStr(iIdx + 1)).AsString := str;
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
