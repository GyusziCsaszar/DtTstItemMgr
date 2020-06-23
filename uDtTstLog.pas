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
  public
    constructor Create(sLogPath: string);
    destructor Destroy(); override;
    function LogERROR(exc: Exception) : Exception;
    procedure LogINFO(sLogLine: string);
    procedure LogLINE(sLogLine: string);
  private
  end;

implementation

uses
  { DtTs Units: } uDtTstUtils,
  System.IOUtils;

constructor TDtTstLog.Create(sLogPath: string);
begin
  m_lbLogView := nil;

  m_sLogPath := sLogPath;

  inherited Create();

  LogLINE('');
  LogLINE('-=<[LOG START]>=-');
end;

destructor TDtTstLog.Destroy();
begin
  LogLINE('-=<[LOG END]>=-');

  m_lbLogView := nil;

  inherited Destroy();
end;

function TDtTstLog.LogERROR(exc: Exception) : Exception;
begin
  Result := exc;
  LogLINE('-( E )- ERROR: (' + exc.ClassName + ') ' + exc.Message);
end;

procedure TDtTstLog.LogINFO(sLogLine: string);
begin
  LogLINE('-( I )- ' + sLogLine);
end;

procedure TDtTstLog.LogLINE(sLogLine: string);
var
  sLn: string;
begin

  if sLogLine.Length = 0 then
    sLn := ''
  else
    sLn := DateTimeToStrHu(Now) + ' ' + sLogLine;

  if m_sLogPath.Length > 0 then
  begin
    try
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
