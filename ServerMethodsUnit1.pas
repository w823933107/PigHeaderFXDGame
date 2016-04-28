unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, System.Json,
  Datasnap.DSProviderDataModuleAdapter;

type
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
    function GetReleaseVersion(var aversion: string): Boolean;
    function GetDllFile: TJSONArray;
  end;

implementation


{$R *.dfm}


uses System.StrUtils, Spring.Utils, Data.DBXJSONCommon;

function TServerMethods1.EchoString(Value: string): string;
begin
  Result := Value;
end;

function TServerMethods1.GetDllFile: TJSONArray;
var
  stream: TBytesStream;
  I: Integer;
begin
  Result := TJSONArray.Create;
  stream := TBytesStream.Create();
  try
    stream.LoadFromFile('pigheader.dll');
    stream.Position := 0;
    Result := TDBXJSONTools.StreamToJSON(stream, 0, stream.Size);
  finally
    stream.Free;
  end;
end;

function TServerMethods1.GetReleaseVersion(var aversion: string): Boolean;
var
  version: string;
begin
  version := TFileVersionInfo.GetVersionInfo('pigheader.dll').FileVersion;
  Result := aversion = version;
  aversion := version;
end;

function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

end.
