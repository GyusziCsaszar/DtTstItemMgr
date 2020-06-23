unit uDtTstLog;

interface

uses
  SysUtils, Vcl.StdCtrls;

type
  TDtTstLog = class (TObject)
  public
    m_lbLogView: TListBox;
  private
    m_sLogPath: string;
    m_sLogPath_SQL: string;
    m_iLogLevel_REQU: integer;

    procedure AppendLogFile(sPath, sLn: string);
  public
    constructor Create(sLogPath: string; sIniPath: string);
    destructor Destroy(); override;
    function LogERROR(exc: Exception) : Exception;
    procedure LogVERSION(sLogLine: string);
    procedure LogLIFE(sLogLine: string);
    procedure LogUI(sLogLine: string);
    function LogSQL(sSql: string) : string;
    procedure LogINFO(sLogLine: string);
    procedure LogDECOR(sLogLine: string);
    procedure LogLINE(iLogLevel: integer; sLogLine: string);
  end;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstUtils,
  System.IOUtils, IniFiles;

constructor TDtTstLog.Create(sLogPath: string; sIniPath: string);
var
  fIni: TIniFile;
  bIniPresent: Boolean;
begin
  m_lbLogView := nil;

  m_sLogPath  := sLogPath;

  m_sLogPath_SQL := '';
  if not sLogPath.IsEmpty() then
  begin
    m_sLogPath_SQL := TPath.GetDirectoryName(sLogPath) + '\' +
            TPath.GetFileNameWithoutExtension(sLogPath) + '.SQL' + TPath.GetExtension(sLogPath);
  end;

  m_iLogLevel_REQU := ciLOGLEVEL_ALL;

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

        if not fIni.SectionExists(csINI_SEC_LOG) then
        begin

          // DO NOT!!!
          //raise LogERROR(Exception.Create('No INI Section "' + csINI_SEC_LOG + '"! INI File: ' + sIniPath));
        end
        else
        begin
          m_iLogLevel_REQU := fIni.ReadInteger(csINI_SEC_LOG, csINI_VAL_LOG_LEVEL, m_iLogLevel_REQU);

          bIniPresent := True;
        end;

      finally
        FreeAndNil(fIni);
      end;
    end;
  end;

  LogDECOR('');
  LogDECOR('-=<[LOG START (LEVEL = ' + IntToStr(m_iLogLevel_REQU) + ' )]>=-');

  if bIniPresent then
  begin
    LogVERSION('INI Path (for TDtTstLog): ' + sIniPath);
  end;

  LogVERSION('LOG Path (for TDtTstLog): ' + m_sLogPath);
end;

destructor TDtTstLog.Destroy();
begin

  LogDECOR('-=<[LOG END]>=-');

  m_lbLogView := nil;

  inherited Destroy();
end;

function TDtTstLog.LogERROR(exc: Exception) : Exception;
begin
  Result := exc;
  LogLINE(ciLOGLEVEL_ERROR, 'ERR | ERROR: (' + exc.ClassName + ') ' + exc.Message);
end;

procedure TDtTstLog.LogVERSION(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_VERSION, 'VER | ' + sLogLine);
end;

procedure TDtTstLog.LogLIFE(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_LIFETIME, 'LFE | ' + sLogLine);
end;

procedure TDtTstLog.LogUI(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_UI, 'GUI | ' + sLogLine);
end;

function TDtTstLog.LogSQL(sSql: string) : string;
begin
  Result := sSql;

  LogLINE(ciLOGLEVEL_SQL, 'SQL | ' + sSql);

  if not m_sLogPath_SQL.IsEmpty() then
  begin

    AppendLogFile(m_sLogPath_SQL, DateTimeToStrHu(Now) + ' | ' + sSql);

  end;
end;

procedure TDtTstLog.LogINFO(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_NA, 'INF | ' + sLogLine);
end;

procedure TDtTstLog.LogDECOR(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_DECOR, sLogLine);

  if not m_sLogPath_SQL.IsEmpty() then
  begin

    AppendLogFile(m_sLogPath_SQL, DateTimeToStrHu(Now) + ' | ' + sLogLine);

  end;

end;

procedure TDtTstLog.LogLINE(iLogLevel: integer; sLogLine: string);
var
  sLn: string;
begin

  if m_iLogLevel_REQU = ciLOGLEVEL_NONE then Exit;

  if m_iLogLevel_REQU > ciLOGLEVEL_NONE then
  begin
    if iLogLevel > m_iLogLevel_REQU then Exit;
  end;

  // FIX
  sLogLine := StringReplace(sLogLine, CHR(13) + CHR(10), ' <CRLF> ', [rfReplaceAll]);
  sLogLine := StringReplace(sLogLine,           CHR(10),   ' <LF> ', [rfReplaceAll]);

  if sLogLine.IsEmpty() then
    sLn := ''
  else
    sLn := DateTimeToStrHu(Now) + ' | ' + IntToStr(iLogLevel) + ' | ' + sLogLine;

  if m_sLogPath.Length > 0 then
  begin
    AppendLogFile(m_sLogPath, sLn);
  end;

  if Assigned(m_lbLogView) and Assigned(m_lbLogView.Parent) then
  begin
    try
      m_lbLogView.Items.Insert(0, sLn);
    except
      on exc : Exception do
      begin
        // NOP...
      end;
    end;
  end;
end;

procedure TDtTstLog.AppendLogFile(sPath, sLn: string);
begin
  try

    // ATTN!!!
    CreateUTF8BOMFile(sPath, False {bOverWrite});

    TFile.AppendAllText(sPath, sLn + Chr(13) + Chr(10));

  except
    on exc : Exception do
    begin
      // NOP...
    end;
  end;
end;

end.
