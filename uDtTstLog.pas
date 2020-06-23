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
    m_iLogLevel_REQU: integer;
  public
    constructor Create(sLogPath: string; sIniPath: string);
    destructor Destroy(); override;
    function LogERROR(exc: Exception) : Exception;
    procedure LogLIFE(sLogLine: string);
    procedure LogINFO(sLogLine: string);
    procedure LogLINE(iLogLevel: integer; sLogLine: string);
  private
  end;

implementation

uses
  { DtTs Units: } uDtTstConsts, uDtTstUtils,
  System.IOUtils, IniFiles;

constructor TDtTstLog.Create(sLogPath: string; sIniPath: string);
var
  fIni: TIniFile;
begin
  m_lbLogView := nil;

  m_sLogPath  := sLogPath;
  m_iLogLevel_REQU := ciLOGLEVEL_ALL;

  inherited Create();

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
        end;

      finally
        FreeAndNil(fIni);
      end;
    end;
  end;

  LogLINE(ciLOGLEVEL_DECORATION, '');
  LogLINE(ciLOGLEVEL_DECORATION, '-=<[LOG START (LEVEL=' + IntToStr(m_iLogLevel_REQU) + ')]>=-');
end;

destructor TDtTstLog.Destroy();
begin
  LogLINE(ciLOGLEVEL_DECORATION, '-=<[LOG END]>=-');

  m_lbLogView := nil;

  inherited Destroy();
end;

function TDtTstLog.LogERROR(exc: Exception) : Exception;
begin
  Result := exc;
  LogLINE(ciLOGLEVEL_ERROR, 'ERR | ERROR: (' + exc.ClassName + ') ' + exc.Message);
end;

procedure TDtTstLog.LogLIFE(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_LIFETIME, 'LFE | ' + sLogLine);
end;

procedure TDtTstLog.LogINFO(sLogLine: string);
begin
  LogLINE(ciLOGLEVEL_NA, 'INF | ' + sLogLine);
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
    try

      // ATTN!!!
      CreateUTF8BOMFile(m_sLogPath, False {bOverWrite});

      TFile.AppendAllText(m_sLogPath, sLn + Chr(13) + Chr(10));

    except
      on exc : Exception do
      begin
        // NOP...
      end;
    end;
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

end.
