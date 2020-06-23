unit uDtTstUtils;

interface

function DateTimeToStrHu(dt: TDatetime): string;

implementation

uses
  SysUtils;

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
