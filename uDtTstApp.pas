unit uDtTstApp;

interface

uses
  { DtTst Units: } uDtTstLog;

type
  TDtTstApp = class (TObject)
  protected
    m_oLog: TDtTstLog;
    m_bAdminMode: Boolean;
  public
    constructor Create(sLogPath: string; sIniPath: string);
    destructor Destroy(); override;

    function GetAdminMode(): Boolean;
    property ADMIN_MODE: Boolean read GetAdminMode;

    function GetLog() : TDtTstLog;
    property LOG: TDtTstLog read GetLog;

  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstWin,
  System.SysUtils, IniFiles;

constructor TDtTstApp.Create(sLogPath: string; sIniPath: string);
var
  fIni: TIniFile;
  bIniPresent: Boolean;
begin

  m_oLog := TDtTstLog.Create(sLogPath, //csLOG_EXT),
                             sIniPath);

  m_bAdminMode := False;

  inherited Create();

  bIniPresent := False;

  if not sIniPath.IsEmpty then
  begin
    if FileExists(sIniPath) then
    begin
      try

        // DO NOT!!!
        //LogINFO('INI Path (for TDtTstLog): ' + sIniPath);

        fIni := TIniFile.Create(sIniPath);

        if not fIni.SectionExists(csINI_SEC_APP) then
        begin

          // DO NOT!!!
          //raise m_oLog.LogERROR(Exception.Create('No INI Section "' + csINI_SEC_APP + '"! INI File: ' + sIniPath));
        end
        else
        begin
          m_bAdminMode := (fIni.ReadInteger(csINI_SEC_APP, csINI_VAL_APP_ADMIN_MODE, 0 {False}) <> 0);

          bIniPresent := True;
        end;

      finally
        FreeAndNil(fIni);
      end;
    end;
  end;

  if bIniPresent then
  begin
    m_oLog.LogVERSION('INI Path (for TDtTstLog): ' + sIniPath);
  end;

end;

destructor TDtTstApp.Destroy();
begin
  m_oLog.LogLIFE('TDtTstApp.Destroy');

  inherited Destroy();

  FreeAndNil(m_oLog);
end;

function TDtTstApp.GetAdminMode(): Boolean;
begin
  Result := m_bAdminMode;
end;

function TDtTstApp.GetLog() : TDtTstLog;
begin
  Result := m_oLog;
end;

end.
