unit uDtTstApp;

interface

uses
  { DtTst Units: } uDtTstLog;

type
  TDtTstApp = class (TObject)
  protected
    m_oLog: TDtTstLog;
  public
    constructor Create(sLogPath: string; sIniPath: string);
    destructor Destroy(); override;

    function GetLog() : TDtTstLog;
    property LOG: TDtTstLog read GetLog;

  end;

implementation

uses
  { DtTst Units: } uDtTstWin,
  System.SysUtils;

constructor TDtTstApp.Create(sLogPath: string; sIniPath: string);
begin

  m_oLog := TDtTstLog.Create(sLogPath, //csLOG_EXT),
                             sIniPath);

  inherited Create();

end;

destructor TDtTstApp.Destroy();
begin
  m_oLog.LogLIFE('TDtTstApp.Destroy');

  inherited Destroy();

  FreeAndNil(m_oLog);
end;

function TDtTstApp.GetLog() : TDtTstLog;
begin
  Result := m_oLog;
end;

end.
