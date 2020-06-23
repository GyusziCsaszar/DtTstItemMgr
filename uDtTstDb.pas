unit uDtTstDb;

interface

uses
  { DtTs Units: } uDtTstLog,
  DbxCommon, DbxMetaDataProvider,
  DbxDataExpressMetaDataProvider,
  DbxClient; //, DbxDataStoreMetaData;

type
  TDtTstDb = class (TObject)
  private
    m_oLog: TDtTstLog;
  public
    constructor Create(oLog: TDtTstLog);
    destructor Destroy(); override;
    function CreateTable(const AConnection: TDBXConnection) : Boolean;
    function DropTable(const AConnection: TDBXConnection) : Boolean;
  private
    function DBXGetMetaProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
  end;

implementation

uses
  SysUtils;

constructor TDtTstDb.Create(oLog: TDtTstLog);
begin
  m_oLog := oLog;

  inherited Create();

  m_oLog.LogINFO('TDtTstDb.Create');
end;

destructor TDtTstDb.Destroy();
begin
  m_oLog.LogINFO('TDtTstDb.Destroy');

  m_oLog := nil;

  inherited Destroy();
end;

function TDtTstDb.DropTable(const AConnection: TDBXConnection) : Boolean;
var
  MyProvider: TDBXDataExpressMetaDataProvider;
begin
  Result := False;

  // Get the MetadataProvider from my Connection
  MyProvider := DBXGetMetaProvider(AConnection);
  try

    // ATTN: Indices of a Table will be dropped along with the table!!!

    //if MyProvider.DropIndex('DELPHIEXPERTS', 'DELPHIEXPERTS_ID') then
    //begin

      if MyProvider.DropTable('', 'DELPHIEXPERTS') then
      begin
        Result := True;
      end;

    //end;

  finally
    FreeAndNil(MyProvider);
  end;

end;

function TDtTstDb.CreateTable(const AConnection: TDBXConnection) : Boolean;
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  MyProvider: TDBXDataExpressMetaDataProvider;
  MyNewTable: TDBXMetaDataTable;
  MyPrimaryKey: TDBXMetaDataIndex;
  MyIDColumn: TDBXInt32Column;
begin
  Result := False;

  // Get the MetadataProvider from my Connection
  MyProvider := DBXGetMetaProvider(AConnection);
  try
    // Create the Table structure
    MyNewTable := TDBXMetaDataTable.Create;

    try
      MyNewTable.TableName := 'DELPHIEXPERTS';
      MyIDColumn := TDBXInt32Column.Create('ID');
      MyIDColumn.Nullable:=false;
      MyNewTable.AddColumn(MyIDColumn);
      MyNewTable.AddColumn(TDBXAnsiCharColumn.Create('Members', 50));
      // Add the Table in the Database with my provider
      MyProvider.CreateTable(MyNewTable);

    finally
      FreeAndNil(MyNewTable);
    end;

    // Now let us create a Primary Key on the ID Field
    MyPrimaryKey := TDBXMetaDataIndex.Create;

    try

      {ATTN: OPTIONAL to name the Index!!!}
      {      Original Sample does not do so!!!}
      MyPrimaryKey.IndexName := 'DELPHIEXPERTS_ID';

      MyPrimaryKey.TableName := 'DELPHIEXPERTS';
      MyPrimaryKey.AddColumn('ID');
      // Add the Primary Key with my provider
      MyProvider.CreatePrimaryKey(MyPrimaryKey);
    finally
      FreeAndNil(MyPrimaryKey);
    end;
  finally
    FreeAndNil(MyProvider);
  end;

  Result := True;
end;

function TDtTstDb.DBXGetMetaProvider(const AConnection: TDBXConnection) : TDBXDataExpressMetaDataProvider;
// SRC: https://www.embarcadero.com/images/dm/technical-papers/delphi-2010-and-firebird.pdf
var
  Provider: TDBXDataExpressMetaDataProvider;
begin
  Provider := TDBXDataExpressMetaDataProvider.Create;
  try
    Provider.Connection := AConnection;
    Provider.Open;
  except
    FreeAndNil(Provider);
    raise ;
  end;
  Result := Provider;
end;

end.
