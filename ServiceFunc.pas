//
// Created by the DataSnap proxy generator.
// 2016/4/28 9:55:47
//

unit ServiceFunc;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TServerMethods1Client = class(TDSAdminClient)
  private
    FEchoStringCommand: TDBXCommand;
    FReverseStringCommand: TDBXCommand;
    FGetReleaseVersionCommand: TDBXCommand;
    FGetDllFileCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
    function GetReleaseVersion(var aversion: string): Boolean;
    function GetDllFile: TJSONArray;
  end;

implementation

function TServerMethods1Client.EchoString(Value: string): string;
begin
  if FEchoStringCommand = nil then
  begin
    FEchoStringCommand := FDBXConnection.CreateCommand;
    FEchoStringCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FEchoStringCommand.Text := 'TServerMethods1.EchoString';
    FEchoStringCommand.Prepare;
  end;
  FEchoStringCommand.Parameters[0].Value.SetWideString(Value);
  FEchoStringCommand.ExecuteUpdate;
  Result := FEchoStringCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.ReverseString(Value: string): string;
begin
  if FReverseStringCommand = nil then
  begin
    FReverseStringCommand := FDBXConnection.CreateCommand;
    FReverseStringCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FReverseStringCommand.Text := 'TServerMethods1.ReverseString';
    FReverseStringCommand.Prepare;
  end;
  FReverseStringCommand.Parameters[0].Value.SetWideString(Value);
  FReverseStringCommand.ExecuteUpdate;
  Result := FReverseStringCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.GetReleaseVersion(var aversion: string): Boolean;
begin
  if FGetReleaseVersionCommand = nil then
  begin
    FGetReleaseVersionCommand := FDBXConnection.CreateCommand;
    FGetReleaseVersionCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGetReleaseVersionCommand.Text := 'TServerMethods1.GetReleaseVersion';
    FGetReleaseVersionCommand.Prepare;
  end;
  FGetReleaseVersionCommand.Parameters[0].Value.SetWideString(aversion);
  FGetReleaseVersionCommand.ExecuteUpdate;
  aversion := FGetReleaseVersionCommand.Parameters[0].Value.GetWideString;
  Result := FGetReleaseVersionCommand.Parameters[1].Value.GetBoolean;
end;

function TServerMethods1Client.GetDllFile: TJSONArray;
begin
  if FGetDllFileCommand = nil then
  begin
    FGetDllFileCommand := FDBXConnection.CreateCommand;
    FGetDllFileCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGetDllFileCommand.Text := 'TServerMethods1.GetDllFile';
    FGetDllFileCommand.Prepare;
  end;
  FGetDllFileCommand.ExecuteUpdate;
  Result := TJSONArray(FGetDllFileCommand.Parameters[0].Value.GetJSONValue(FInstanceOwner));
end;


constructor TServerMethods1Client.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;


constructor TServerMethods1Client.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;


destructor TServerMethods1Client.Destroy;
begin
  FEchoStringCommand.DisposeOf;
  FReverseStringCommand.DisposeOf;
  FGetReleaseVersionCommand.DisposeOf;
  FGetDllFileCommand.DisposeOf;
  inherited;
end;

end.

