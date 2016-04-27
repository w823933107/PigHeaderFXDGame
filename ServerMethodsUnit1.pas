unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, System.Json,
  Datasnap.DSProviderDataModuleAdapter,
  QPlugins;

type
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
    function GetReleaseVersion(var aVersion: Byte): Boolean;
    function GetDllFile: TJSONArray;

  end;

implementation


{$R *.dfm}


uses System.StrUtils;

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
    for I := Low(stream.Bytes) to High(stream.Bytes) do
    begin
      Result.Add(stream.Bytes[I]);
    end;
  finally
    stream.Free;
  end;
end;

function TServerMethods1.GetReleaseVersion(var aVersion: Byte): Boolean;
var
  version: TQVersion;
begin
  (PluginsManager.ById(iqversion) as iqversion).GetVersion(Version);
  Result := version.version.Release = aVersion;
  aVersion := version.version.Release;
end;

function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

end.
