unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows, QString;

type
  TGame = class(TGamebase, IGame)
  private
    FObj: IChargeObj;
    FJob: IntPtr;
    FGameData: PGameData;
    procedure DoGame(AJob: PQJob); // 主逻辑
  private
    procedure SetGameConfigManager(const value: IGameConfigManager);
  public
    constructor Create(const AId: TGuid; AName: QStringW); override;

    destructor Destroy; override;
    procedure Start; // 配置信息
    procedure Stop;
  end;

implementation

{ TGame }

constructor TGame.Create(const AId: TGuid; AName: QStringW);
begin
  inherited;
  New(FGameData);
  Obj := TObjFactory.CreateChargeObj;
  Obj.SetDict(0, '.\Main.txt'); // 设置字库
  Obj.SetPath('.\Pic'); // 设置路径
end;

destructor TGame.Destroy;
begin
  inherited;
  Dispose(FGameData);
end;

procedure TGame.DoGame(AJob: PQJob);
// 绑定游戏
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('地下城与勇士', '地下城与勇士');
    if Result = 0 then
      raise Exception.Create('no game running');
    iBind := Obj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if iBind <> 1 then
      raise Exception.Create('bind game error');
    Obj.SetWindowState(Result, 1); // 激活游戏窗口
  end;

begin
  try
    try
      AJob.Worker.ComNeeded(); // 初始化COM库
      FGameData^.Hwnd := BindGame; // 保存游戏窗口句柄
      while not AJob.IsTerminated do
      begin

        Sleep(20);
      end;
    except
      on E: Exception do
        RunInMainThread(
          procedure
          begin
            MessageBoxW(0, PWideChar(E.Message), '警告', MB_OK + MB_ICONWARNING);
          end);
    end;
  finally
    Workers.Clear; // 清除所有作业
  end;
end;

procedure TGame.SetGameConfigManager(const value: IGameConfigManager);
begin

end;

procedure TGame.Start;
var
  JobState: TQJobState;
begin
  // 作业不存在时执行
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(DoGame, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.Clear; // 清除所有作业
end;

initialization

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // 设置插件路径

finalization

end.
