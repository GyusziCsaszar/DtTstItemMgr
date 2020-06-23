unit uDtTstFirebird;

interface

uses
  { DtTst Units: } uDtTstLog,
  SysUtils;

function IsqlExec(oLog: TDtTstLog; sIoFolderPath, sIsqlPath, sDb, sUser, sPassword: string; bGetOutput, bVisible: Boolean; sStatements, sTerm: string) : string;

implementation

uses
  { DtTst Units: } uDtTstConsts, uDtTstWin,
  StrUtils, System.IOUtils;

function IsqlExec(oLog: TDtTstLog; sIoFolderPath, sIsqlPath, sDb, sUser, sPassword: string; bGetOutput, bVisible: Boolean; sStatements, sTerm: string) : string;
var
  sPars: string;
  sInPath, sOutPath: string;
  sIn: string;
begin

  Result := '';

  sInPath  := sIoFolderPath + '\' + csISQL_FILE_IN;
  TFile.WriteAllText(sInPath, '');

  sOutPath := sIoFolderPath + '\' + csISQL_FILE_OUT;
  TFile.WriteAllText(sOutPath, '');

  if sTerm.IsEmpty() then
  begin
    sTerm := ';';
  end;

  try

    sPars := '';

    sIn := '';

    if not sDb.IsEmpty() then
    begin

      if StartsText('LOCALHOST:', sDb.ToUpper()) then
      begin
        sDb := sDb.Substring(10);
      end;

      sIn := sIn + 'CONNECT ' + '''' + sDb + '''' + ';' + CHR(13) + CHR(10);
    end;

    if sStatements.IsEmpty() then
    begin
      // NOTE: Below statement fails WITHOUT CONNECTION!!!
      sIn := sIn + 'select current_timestamp from RDB$DATABASE' + ';' + CHR(13) + CHR(10);
    end
    else
    begin

      if sTerm <> ';' then
      begin
        sIn := sIn + 'SET TERM ' + sTerm + ' ' + ';' + CHR(13) + CHR(10);
      end;

      sIn := sIn + sStatements;

      if sTerm <> ';' then
      begin
        sIn := sIn + 'SET TERM ' + ';' + ' ' + sTerm  + CHR(13) + CHR(10);
      end;

    end;

    if bVisible then
    begin
      // NOTE: Press any key...
      sIn := sIn + 'SHELL PAUSE' + ';' + CHR(13) + CHR(10);
    end;

    TFile.WriteAllText(sInPath, sIn);

    if not sIn.IsEmpty() then
    begin
      if not sPars.IsEmpty() then sPars := sPars + ' ';
      sPars := sPars + '-input ' + oLog.LogSQL(sInPath);

      oLog.LogSQL(sIn);
    end;

    // NOT WORKS!!!
    {
    if not sDb.IsEmpty() then
    begin

      if StartsText('LOCALHOST:', sDb.ToUpper()) then
      begin
        sDb := sDb.Substring(10);
      end;

      if not sPars.IsEmpty() then sPars := sPars + ' ';
      sPars := sPars + '-database ' + '"' + sDb + '"';
    end;
    }

    if bGetOutput then
    begin
      if not sPars.IsEmpty() then sPars := sPars + ' ';
      sPars := sPars + '-output ' + sOutPath;
    end;

    if not sUser.IsEmpty() then
    begin
      if not sPars.IsEmpty() then sPars := sPars + ' ';
      sPars := sPars + '-user ' + sUser;
    end;

    if not sPassword.IsEmpty() then
    begin
      if not sPars.IsEmpty() then sPars := sPars + ' ';
      sPars := sPars + '-password ' + sPassword;
    end;

    ExecuteApplication(sIsqlPath, sPars, bVisible);

    Result := TFile.ReadAllText(sOutPath);

  finally

    TFile.WriteAllText(sInPath, '');

    TFile.WriteAllText(sOutPath, '');

  end;

end;

end.
