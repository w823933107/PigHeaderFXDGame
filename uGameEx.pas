unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass;

type
  // 游戏主逻辑
  TGame = class(TGamebase)
  private
    FObj: IChargeObj;
    FJob: IntPtr;
    FGameData: PGameData;
  private
    FGameConfigManager: IGameConfigManager;
    FMap: IMap;
    FMove: IMove;
  private
    procedure GameJob(AJob: PQJob); // 主逻辑作业
    procedure CheckJob(AJob: PQJob); // 检测作业
    procedure LoopHandle; // 循环处理
    procedure InMapHandle; // 图内操作
    procedure OutMapHandle; // 图外操作
    procedure UnknownMapHandle; // 位置图操作
    procedure CreateGameObjs(aGameData: PGameData); // 创建对象集
  public
    constructor Create();
    destructor Destroy; override;
    procedure Start; // 配置信息
    procedure Stop;
    procedure SetApplicationHanlde(aHandle: THandle);
    function Guard(): Boolean;
  end;

  // 为了支持插件,进行了再次封装
  TGameService = class(TInterfacedObject, IGameService)
  private
    FGame: TGame;
  public
    destructor Destroy; override;
    procedure SetHandle(const aHandle: THandle);
    procedure Prepare; // 由于部分功能放在插件的钩子函数中会导致程序卡住不出来,所以只能这样了
    procedure Start; // 开始
    function Guard: Boolean; // 如果启用了保护返回true,否则返回false
    procedure Stop; // 停止
  end;

implementation


{ TGame }

procedure TGame.CheckJob(AJob: PQJob);
var
  x, y: OleVariant;
  iRet: Integer;
  hGame: Integer;
begin
  while not AJob.IsTerminated do
  begin
    // 检测客户端是否存在
    hGame := FObj.FindWindow('地下城与勇士', '地下城与勇士');
    if hGame = 0 then
      warnning;
    // 检测网络状态
    iRet := FObj.FindStr(0, 0, 800, 600, '网络连接中断', clStrWhite, 1.0, x, y);
    if iRet > -1 then
      warnning;
    // 检测窗口激活状态
    if FObj.GetWindowState(hGame, 1) = 0 then
      FObj.SetWindowState(hGame, 1);
    Sleep(2000);
  end;

end;

constructor TGame.Create;
begin
  New(FGameData);
  Obj := TObjFactory.CreateChargeObj;
  Obj.SetDict(0, sDictPath); // 设置字库
  Obj.SetPath(sPicPath); // 设置路径
  // // 创建配置管理器
  FGameConfigManager := GlobalContainer.Resolve<IGameConfigManager>;
end;

procedure TGame.CreateGameObjs(aGameData: PGameData);
begin
  FMap := GlobalContainer.Resolve<IMap>;
  FMap.SetGameData(aGameData);
  FMove := GlobalContainer.Resolve<IMove>;
  FMove.SetGameData(aGameData);
end;

destructor TGame.Destroy;
begin
  Dispose(FGameData);
  FGameConfigManager := nil;
  inherited;
  CodeSite.Send('TGame Destory');
end;

procedure TGame.GameJob(AJob: PQJob);
// 绑定游戏
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('地下城与勇士', '地下城与勇士');
    if Result = 0 then
      raise EGame.Create('no game running');
    iBind := Obj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if iBind <> 1 then
      raise EGame.Create('bind game error');
    Obj.SetWindowState(Result, 1); // 激活游戏窗口
  end;

begin
  try
    try
      CodeSite.Send('start to run');
      AJob.Worker.ComNeeded(); // 初始化COM库 ,似乎加上了之后无法正常退出程序了
      FGameData^.GameConfig := FGameConfigManager.Config; // 读取配置文件
      FGameData^.Hwnd := BindGame; // 保存游戏窗口句柄
      FGameData^.Job := AJob; // 保存主线程的作业对象
      GameData := FGameData; // 保存到当前类中,为了防止这个类以外使用而不出错
      CreateGameObjs(FGameData); // 创建需要使用的对象
      LoopHandle; // 循环处理
    except
      on E: EGame do
      // MessageBox(0, PWideChar(E.Message), '警告', MB_OK);
      begin
        Application.MessageBox(PWideChar(E.Message), '警告');
        CodeSite.Send('error operator');
      end;
    end;
  finally
    CodeSite.Send('start to clear ');
    // Workers.Clear;
    // 清除所有作业 ,调用后似乎不能正确执行
  end;
end;

function TGame.Guard(): Boolean;
var
  iRet: Integer;
  sPath: string;
begin
  Result := False;
  sPath := GetCurrentDir;
  if FGameConfigManager.Config.bAutoRunGuard then
  begin
    iRet := Obj.SetSimMode(2);
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('硬件驱动加载失败,错误码:' + iRet.ToString), '错误');
      Application.Terminate;
    end;
    iRet := Obj.DmGuard(1, 'f1');
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('f1盾开启失败,错误码:' + iRet.ToString), '错误');
      Application.Terminate;
    end;
    ChDir(sPath); // 重新设置路径
    iRet := Obj.DmGuard(1, 'block');
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('block驱动加载失败,错误码:' + iRet.ToString), '错误');
      Application.Terminate;
    end;
    Result := True;
  end;
end;

procedure TGame.InMapHandle;
begin
  case FMap.MiniMap of
    mmUnknown:
      begin

      end;
    mmClickCards:
      ;
    mmPassGame:
      ;
  else

  end;

end;

procedure TGame.LoopHandle;

begin
  Workers.Post(CheckJob, nil);
  while not Terminated do
  begin
    CloseGameWindows; // 关闭所有窗口
    case FMap.LargeMap of
      lmUnknown:
        UnknownMapHandle;
      lmOut:
        OutMapHandle;
      lmIn:
        InMapHandle;
    end;
    Sleep(GameData.GameConfig.iLoopDelay); // 循环延时
  end;
end;

procedure TGame.OutMapHandle;
begin

end;

procedure TGame.SetApplicationHanlde(aHandle: THandle);
begin
  Application.Handle := aHandle;
end;

procedure TGame.Start;
var
  JobState: TQJobState;
begin
  // 作业不存在时执行
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(GameJob, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.Clear; // 清除所有作业
end;

procedure TGame.UnknownMapHandle;
begin

end;

{ TGameService }

destructor TGameService.Destroy;
begin
  FGame.Free;
  inherited;
end;

function TGameService.Guard: Boolean;
begin
  Result := FGame.Guard;
end;

procedure TGameService.Prepare;
begin
  FGame := TGame.Create;
end;

procedure TGameService.SetHandle(const aHandle: THandle);
begin
  Application.Handle := aHandle;
end;

procedure TGameService.Start;
begin
  FGame.Start;
end;

procedure TGameService.Stop;
begin
  FGame.Stop;
end;

initialization

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // 设置插件路径
RegisterGameClass;
// RegisterServices('Services/Game', [TGameService.Create(IGameService,
// 'GameService')]);

finalization

// UnregisterServices('Services/Game', ['GameService']);
CleanupGlobalContainer;

end.
