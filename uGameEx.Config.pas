{
  配置单元
}
unit uGameEx.Config;

interface

uses uGameEx.Interf, System.IniFiles, qjson, System.SysUtils;

type
  // 使用Json保存配置文件
  TGameConfigManagerJson = class(TInterfacedObject, IGameConfigManager)
  private
    FJson: TQJson;
    FFileName: string;
  public
    constructor Create();
    destructor Destroy; override;
    procedure SetFileName(aFileName: string);
    procedure SetConfig(const aGameConfig: TGameConfig);
    function GetConfig(): TGameConfig;
  end;

  TGameConfigManager = class(TInterfacedObject, IGameConfigManager)
  private
    FFileName: string;
    FIniFile: TIniFile;

  const
    sConfig = 'Config';
  public
    constructor Create();
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

{ TGameConfigManager }

constructor TGameConfigManager.Create;
begin
  FIniFile := TIniFile.Create(sConfigPath);
end;

destructor TGameConfigManager.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TGameConfigManager.GetConfig: TGameConfig;
begin
 // Result.iWndState := FIniFile.ReadInteger(sConfig,)
end;

procedure TGameConfigManager.SetConfig(const aGameConfig: TGameConfig);
begin

end;

procedure TGameConfigManager.SetFileName(aFileName: string);
begin
  FreeAndNil(FIniFile);
  FIniFile := TIniFile.Create(aFileName);
end;

initialization

// RegisterServices('Services/Game',
// [TGameConfigManagerJson.Create(IGameConfigManager, 'Config')]);

finalization

// UnregisterServices('Services/Game', ['Config']);

end.
