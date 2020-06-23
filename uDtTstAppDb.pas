unit uDtTstAppDb;

interface

uses
  { DtTst Units: } uDtTstApp, uDtTstDb;

type
  TDtTstAppDb = class (TDtTstApp)
  protected
    m_oDb: TDtTstDb;
  public
    constructor Create(sLogPath: string; sIniPath: string);
    destructor Destroy(); override;

    procedure SetDb(oDb: TDtTstDb);
    function GetDb() : TDtTstDb;
    property DB: TDttstDb read GetDb;

  end;

implementation

uses
  { DtTst Units: } uDtTstWin,
  System.SysUtils;

constructor TDtTstAppDb.Create(sLogPath: string; sIniPath: string);
begin

  inherited Create(sLogPath, //csLOG_EXT),
                             sIniPath);

end;

destructor TDtTstAppDb.Destroy();
begin
  m_oLog.LogLIFE('TDtTstAppDb.Destroy');

  FreeAndNil(m_oDb);

  inherited Destroy();
end;

procedure TDtTstAppDb.SetDb(oDb: TDtTstDb);
begin
  FreeAndNil(m_oDb);
  m_oDb := oDb;
end;

function TDtTstAppDb.GetDb() : TDtTstDb;
begin
  Result := m_oDb;
end;

end.

