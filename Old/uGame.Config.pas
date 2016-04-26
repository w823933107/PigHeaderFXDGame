{
  ≈‰÷√µ•‘™
}

unit uGame.Config;

interface

uses uGame.Interf, System.IniFiles, qjson;

type
  // INI≈‰÷√
  TGameConfigManagerINI = class(TInterfacedObject, IGameConfigManager)
  private
    FIniFile: TIniFile;
  public
    destructor Destroy; override;
    procedure SetFileName(aFileName: string);
    procedure SetConfig(const aGameConfig: TGameConfig);
    function GetConfig(): TGameConfig;
  end;

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

implementation

resourcestring
  StrAutoRunGuard = 'AutoRunGuard';
  StrWndState = 'WndState';
  StrGameConfig = 'GameConfig';

  { TGameConfigManagerINI }

destructor TGameConfigManagerINI.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TGameConfigManagerINI.GetConfig: TGameConfig;
begin
  Result.iWndState := FIniFile.ReadInteger(
    StrGameConfig,
    StrWndState,
    wsActive);
  Result.bAutoRunGuard := FIniFile.ReadBool(
    StrGameConfig,
    StrAutoRunGuard,
    True);
end;

procedure TGameConfigManagerINI.SetConfig(const aGameConfig: TGameConfig);
begin
  FIniFile.WriteInteger(
    StrGameConfig,
    StrWndState,
    aGameConfig.iWndState);
  FIniFile.WriteBool(
    StrGameConfig,
    StrAutoRunGuard,
    aGameConfig.bAutoRunGuard);
end;

procedure TGameConfigManagerINI.SetFileName(aFileName: string);
begin
  if not Assigned(FIniFile) then
    FIniFile := TIniFile.Create(aFileName);
end;

{ TGameConfigManagerJson }

constructor TGameConfigManagerJson.Create;
begin
  FJson := TQJson.Create;
end;

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

end.
