unit uDtTstUtils;

interface

uses
  System.Classes, Vcl.StdCtrls, StrUtils;

function Boolean2String(b: Boolean) : string;
function String2Boolean(s: string) : Boolean;

procedure CreateUTF8BOMFile(sPath: string; bOverWrite: Boolean);

procedure Split(cDelimiter: Char; str: string; ListOfStrings: TStringList);

function TComboBox_Text(ctrl: TComboBox) : string;
function TEdit_Text(ctrl: TEdit) : string;

function IIF(pResult: Boolean; pIfTrue: Variant; pIfFalse: Variant): Variant;

function DateTimeToStrHu(dt: TDatetime): string;

implementation

uses
  SysUtils, System.IOUtils;

function Boolean2String(b: Boolean) : string;
begin
  if b then
    Result := '1'
  else
    Result := '0';
end;

function String2Boolean(s: string) : Boolean;
begin
  if s = '1' then
    Result := True
  else
    Result := False;
end;

procedure CreateUTF8BOMFile(sPath: string; bOverWrite: Boolean);
begin
  if bOverWrite or (not FileExists(sPath)) then
  begin
    TFile.WriteAllBytes(sPath, [$EF, $BB, $BF]);
  end;
end;

procedure Split(cDelimiter: Char; str: string; ListOfStrings: TStringList);
// SRC: https://stackoverflow.com/questions/2625707/split-a-string-into-an-array-of-strings-based-on-a-delimiter
begin
 ListOfStrings.Clear;
 ListOfStrings.Delimiter       := cDelimiter;
 ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
 ListOfStrings.DelimitedText   := str;
end;

function TEdit_Text(ctrl: TEdit) : string;
begin
  Result := ctrl.Text;
end;

function TComboBox_Text(ctrl: TComboBox) : string;
begin
  Result := ctrl.Text;
end;

function IIF(pResult: Boolean; pIfTrue: Variant; pIfFalse: Variant): Variant;
// SRC: https://stackoverflow.com/questions/20425142/delphi-executing-conditional-statements-in-a-string
begin
  if pResult then
    Result := pIfTrue
  else
    Result := pIfFalse;
end;

function DateTimeToStrHu(dt: TDatetime): string;
// SRC: https://stackoverflow.com/questions/35200000/how-to-convert-delphi-tdatetime-to-string-with-microsecond-precision
//      Original Name = DateTimeToStrUs
var
    sMs: string;
begin
    //Spit out most of the result: '20160802 11:34:36.'
    Result := FormatDateTime('yyyy.mm.dd. hh":"nn":"ss"."', dt);

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
