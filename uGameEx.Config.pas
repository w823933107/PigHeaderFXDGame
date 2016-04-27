{
  配置单元
}
unit uGameEx.Config;

interface

uses uGameEx.Interf, qjson;

type
  // 使用Json保存配置文件
  TGameConfigManagerJson = class(TInterfacedObject, IGameConfigManager)
  private
    FJson: TQJson;
    FFileName: string;
  public
    constructor Create(); overload;
  //   constructor Create(const AId: TGuid; AName: QStringW); overload; override;
    destructor Destroy; override;
    procedure SetFileName(aFileName: string);
    procedure SetConfig(const aGameConfig: TGameConfig);
    function GetConfig(): TGameConfig;
  end;

implementation

{ TGameConfigManagerJson }

constructor TGameConfigManagerJson.Create;
begin

  FJson := TQJson.Create;
  FFileName := sConfigPath; // 设置默认配置路径
end;

// constructor TGameConfigManagerJson.Create(const AId: TGuid; AName: QStringW);
// begin
// inherited;
// FJson := TQJson.Create;
// FFileName := sConfigPath; // 设置默认配置路径
// end;

destructor TGameConfigManagerJson.Destroy;
begin
  FJson.Free;
  inherited;
end;

function TGameConfigManagerJson.GetConfig: TGameConfig;
begin
  FJson.LoadFromFile(FFileName);
  FJson.ToRecord<TGameConfig>(Result);
end;

procedure TGameConfigManagerJson.SetConfig(const aGameConfig: TGameConfig);
begin
  FJson.FromRecord<TGameConfig>(aGameConfig);
  FJson.SaveToFile(FFileName);
end;

procedure TGameConfigManagerJson.SetFileName(aFileName: string);
begin
  if FFileName <> aFileName then
    FFileName := aFileName;

end;

initialization

//RegisterServices('Services/Game',
//  [TGameConfigManagerJson.Create(IGameConfigManager, 'Config')]);

finalization

//UnregisterServices('Services/Game', ['Config']);

end.
