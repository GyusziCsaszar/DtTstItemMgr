unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  midaslib, // ATTN!!!
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids, SimpleDS, Vcl.ExtCtrls;

type
  TFrmMain = class(TForm)
    lblLog: TLabel;
    lbLog: TListBox;
    con_Employee: TSQLConnection;
    btnConnect: TButton;
    qry_Customer: TSQLQuery;
    db_grid_Customer: TDBGrid;
    lblCustomer: TLabel;
    dsp_Customer: TDataSetProvider;
    cds_Customer: TClientDataSet;
    ds_cds_Customer: TDataSource;
    sds_Employee: TSimpleDataSet;
    ds_sds_Employee: TDataSource;
    db_grid_Employee: TDBGrid;
    lblEmployee: TLabel;
    pAttn: TPanel;
    btnGetMetadata: TButton;
    lblResult: TLabel;
    lbResult: TListBox;
    procedure btnConnectClick(Sender: TObject);
    procedure sds_EmployeeAfterPost(DataSet: TDataSet);
    procedure cds_CustomerAfterPost(DataSet: TDataSet);
    procedure btnGetMetadataClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadDbConnectPropsFromIni();
    function LogERROR(exc: Exception) : Exception;
    procedure LogINFO(sLogLine: string);
    procedure LogLINE(sLogLine: string);
    function DateTimeToStrHu(dt: TDatetime): string;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  IniFiles;

const
  sINI_SEC_DBCON = 'DB Connection';
  sINI_VAL_DBCON_DB = 'Database';
  sINI_VAL_DBCON_USR = 'User';
  sINI_VAL_DBCON_PW = 'Password';

procedure TFrmMain.cds_CustomerAfterPost(DataSet: TDataSet);
begin
  cds_Customer.ApplyUpdates(0);
end;

procedure TFrmMain.sds_EmployeeAfterPost(DataSet: TDataSet);
begin
  sds_Employee.ApplyUpdates(0);
end;

procedure TFrmMain.btnConnectClick(Sender: TObject);
begin

  try

    LogINFO('Executable Path: ' + Application.ExeName);

    LoadDbConnectPropsFromIni();

    LogINFO('Button Connect is Pressed!');

    con_Employee.Connected := True;

    LogINFO('SQL Connection is Connected!');

    qry_Customer.Active := True;

    LogINFO('SQL Query is Active!');

    cds_Customer.Active := True;

    LogINFO('Client DataSet is Active!');

    sds_Employee.Active := True;

    LogINFO('Simple DataSet is Active!');

    btnConnect.Enabled := False;

    btnGetMetadata.Enabled := True;

  except
    on exc : Exception do
    begin
      LogERROR(exc);
      ShowMessage('Error: ' + exc.ClassName + ' - ' + exc.Message);
    end;
  end;

end;

procedure TFrmMain.btnGetMetadataClick(Sender: TObject);
var
  iIdx: integer;
  sTable: string;
  asItems: TStringList;
  sItem: string;
begin
  lbResult.Items.Clear();

  con_Employee.GetTableNames(lbResult.Items, False);

  iIdx := -1;
  while True do
  begin
    iIdx := iIdx + 1;

    if iIdx >= lbResult.Items.Count then
    begin
      break;
    end;

    sTable := lbResult.Items[iIdx];

    // Table Fields
    asItems := TStringList.Create();
    begin

      con_Employee.GetFieldNames(sTable, asItems);

      iIdx := iIdx + 1;
      lbResult.Items.Insert(iIdx, '  [Fields]');

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + sItem);
      end;
    end;
    asItems.Free();

    // Table Indices
    asItems := TStringList.Create();
    begin

      con_Employee.GetIndexNames(sTable, asItems);

      iIdx := iIdx + 1;
      lbResult.Items.Insert(iIdx, '  [Indices]');

      for sItem in asItems do
      begin
        iIdx := iIdx + 1;
        lbResult.Items.Insert(iIdx, '    ' + sItem);
      end;
    end;
    asItems.Free();

  end;

  lbResult.Items.Insert(0, 'Login Username: ' + con_Employee.GetLoginUsername());

  lbResult.Items.Insert(1, 'Default SchemaName: ' + con_Employee.GetDefaultSchemaName());

  lbResult.Items.Insert(2, 'Driver Func: ' + con_Employee.GetDriverFunc);

  lbResult.Items.Insert(3, '[Tables]');

end;

procedure TFrmMain.LoadDbConnectPropsFromIni();
var
  sIniPath: string;
  fIni: TIniFile;
begin
  sIniPath := Application.ExeName.Substring(0, Application.ExeName.Length - 4) + '.INI';

  LogINFO('INI Path: ' + sIniPath);

  if not FileExists(sIniPath) then
  begin
    raise Exception.Create('INI File: "' + sIniPath + '" does not exist!');
  end;

  try
    fIni := TIniFile.Create(sIniPath);

    if not fIni.SectionExists(sINI_SEC_DBCON) then
    begin
      raise Exception.Create('No INI Section "' + sINI_SEC_DBCON + '"! INI File: ' + sIniPath);
    end;

    con_Employee.Params.Values['Database'] := fIni.ReadString(sINI_SEC_DBCON, sINI_VAL_DBCON_DB, '');

    if con_Employee.Params.Values['Database'].Length = 0 then
    begin
      raise Exception.Create('No "' + sINI_VAL_DBCON_DB + '" value in INI Section "' + sINI_SEC_DBCON + '"! INI File: ' + sIniPath);
    end;

    con_Employee.Params.Values['User_Name'] := fIni.ReadString(sINI_SEC_DBCON, sINI_VAL_DBCON_USR, '');
    con_Employee.Params.Values['Password'] := fIni.ReadString(sINI_SEC_DBCON, sINI_VAL_DBCON_PW, '');

    if (con_Employee.Params.Values['User_Name'].Length > 0) and (con_Employee.Params.Values['Password'].Length > 0) then
    begin
      con_Employee.LoginPrompt := False;
    end;

  finally
    fIni.Free();
  end;

end;

function TFrmMain.LogERROR(exc: Exception) : Exception;
begin
  Result := exc;
  LogLINE('-( E )- ERROR: (' + exc.ClassName + ') ' + exc.Message);
end;

procedure TFrmMain.LogINFO(sLogLine: string);
begin
  LogLINE('-( I )- ' + sLogLine);
end;

procedure TFrmMain.LogLINE(sLogLine: string);
begin
  lbLog.Items.Insert(0, DateTimeToStrHu(Now) + ' ' + sLogLine);
end;

function TFrmMain.DateTimeToStrHu(dt: TDatetime): string;
// SRC: https://stackoverflow.com/questions/35200000/how-to-convert-delphi-tdatetime-to-string-with-microsecond-precision
//      Original Name = DateTimeToStrUs
var
    sMs: string;
begin
    //Spit out most of the result: '20160802 11:34:36.'
    Result := FormatDateTime('yyyy. mm. dd. hh":"nn":"ss"."', dt);

    //extract the number of microseconds
    dt := Frac(dt); //fractional part of day
    dt := dt * 24*60*60; //number of seconds in that day

    //FIX: Using Round it is possible to get value of 1000000!!!
    //sMs := IntToStr(Round(Frac(dt)*1000000));
    sMs := IntToStr(Trunc(Frac(dt)*1000000));

    //Add the us integer to the end:
    // '20160801 11:34:36.' + '00' + '123456'
    Result := Result + StringOfChar('0', 6-Length(sMs)) + sMs;
end;

end.
