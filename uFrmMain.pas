unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  midaslib, // ATTN!!!
  Data.DB, Data.SqlExpr,
  Data.DBXFirebird, Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider,
  Vcl.Grids, Vcl.DBGrids;

type
  TFrmMain = class(TForm)
    lblLog: TLabel;
    lbLog: TListBox;
    con_SalesCatalog: TSQLConnection;
    btnConnect: TButton;
    qry_SalesCatalog: TSQLQuery;
    ds_qry_SalesCatalog_NOK: TDataSource;
    db_grid_SalesCatalog: TDBGrid;
    lblSalesCatalog: TLabel;
    dsp_SalesCatalog: TDataSetProvider;
    cds_SalesCatalog: TClientDataSet;
    ds_cds_SalesCatalog: TDataSource;
    procedure btnConnectClick(Sender: TObject);
  private
    { Private declarations }
    procedure AddLogLine(sLogLine: string);
    function DateTimeToStrHu(dt: TDatetime): string;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.btnConnectClick(Sender: TObject);
begin

  btnConnect.Enabled := False;

  AddLogLine('Button Connect is Pressed!');

  con_SalesCatalog.Connected := True;

  AddLogLine('SQL Connection is Connected!');

  qry_SalesCatalog.Active := True;

  AddLogLine('SQL Query is Active!');

  cds_SalesCatalog.Active := True;

  AddLogLine('Client DataSet is Active!');

end;

procedure TFrmMain.AddLogLine(sLogLine: string);
var
  sLog: string;
begin

  sLog := DateTimeToStrHu(Now) + ' - ' + sLogLine;

  lbLog.Items.Insert(0, sLog);

end;

function TFrmMain.DateTimeToStrHu(dt: TDatetime): string;
// SRC: https://stackoverflow.com/questions/35200000/how-to-convert-delphi-tdatetime-to-string-with-microsecond-precision
//      Original Name = DateTimeToStrUs
var
    us: string;
begin
    //Spit out most of the result: '20160802 11:34:36.'
    Result := FormatDateTime('yyyy. mm. dd. hh":"nn":"ss"."', dt);

    //extract the number of microseconds
    dt := Frac(dt); //fractional part of day
    dt := dt * 24*60*60; //number of seconds in that day
    us := IntToStr(Round(Frac(dt)*1000000));

    //Add the us integer to the end:
    // '20160801 11:34:36.' + '00' + '123456'
    Result := Result + StringOfChar('0', 6-Length(us)) + us;
end;

end.
