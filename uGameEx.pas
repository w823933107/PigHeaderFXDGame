{
  主逻辑中没有阻塞函数,是在一个循环中进行实时检测判断执行的,
  但是通关后的操作是进行阻塞的,必须执行完成后才能跳出循环
}

unit uGameEx;

interface

uses uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass, QPlugins,
  System.Types, System.Threading, Winapi.ActiveX, System.Classes;

type

  // 游戏主逻辑
  TGame = class(TGamebase)
  private
    FObj: IChargeObj;
    FMyObj: TMyObj;
    FGameData: PGameData;
    FCheckTask: ITask;
    FMainTask: ITask;
  private
    FGameConfigManager: IGameConfigManager;
    FMap: IMap;
    FMove: IMove;
    FRoleInfoHandle: IRoleInfoHandle;
    FPassGame: IPassGame;
    FDoor: IDoor;
    FMan: IMan;
    FMonster: IMonster;
    FGoods: IGoods;
    FCheckTimeOut: ICheckTimeOut;
    FSkill: ISkill;
  private
    procedure GameTask; // 主逻辑作业
    procedure CheckTask; // 检测作业
    procedure LoopHandle; // 循环处理
    procedure InMapHandle; // 图内操作
    procedure OutMapHandle; // 图外操作
    procedure UnknownMapHandle; // 未知图操作
    procedure CreateGameObjs(aGameData: PGameData); // 创建对象集
    procedure FreeGameObjs;
    procedure DoorClosedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
    procedure DoorOpenedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
  private
    procedure GoToInMap;
    procedure ChangeRole;
    procedure LongTimeNoMoveHandle(const aManPoint: TPoint);
  public
    constructor Create();
    destructor Destroy; override;
    procedure Start; // 配置信息
    procedure Stop;
    function Guard(): Boolean;
  end;

  // 为了支持插件,进行了再次封装
  TGameService = class(TQService, IGameService)
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

procedure TGame.ChangeRole;
var
  x, y: OleVariant;
  iRet: Integer;
  procedure SelectMemu;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindStr(325, 91, 542, 221, '游戏菜单', clStrWhite, 1.0, x, y);
      if iRet > -1 then
      begin
        Break;
      end
      else
      begin
        FObj.KeyPressChar('esc');
        Sleep(500);
      end;
    end;
  end;

  procedure GotoSelectRole;

  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(364, 383, 436, 464, '选择角色.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        FObj.MoveTo(x, y);
        Sleep(200);
        FObj.LeftClick;
        Sleep(200);
        MoveToFixPoint;
      end
      else
      begin
        iRet := FObj.FindStr(482, 471, 630, 582, '结束游戏',
          StrColorOffset('ddc593'), 1.0, x, y);
        if iRet > -1 then
        begin
          Break;
        end;
      end;
      Sleep(100);
    end;
  end;

  procedure GotoInGame;
  var
    oldX: Integer; // 记录人物初始坐标
  begin
    oldX := 0;
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(38, 42, 617, 531, '左上角.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        oldX := x; // 记录第一次坐标
        Break;
      end;
      Sleep(500);
    end;
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(38, 42, 617, 531, '左上角.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        if x <> oldX then
        begin

          Break;
        end
        else
        begin
          FObj.KeyPressChar('right');
          Sleep(1000);
        end;
      end;
      Sleep(100);
    end;
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindStr(211, 128, 774, 540, '黄金哥布林|赛丽亚|邮件箱',
        StrColorOffset('f7d65a'), 1.0, x, y);
      if iRet > -1 then
      begin
        Sleep(5000);
        CloseGameWindows;
        Break;
      end
      else
      begin
        FObj.KeyPressChar('space');
        Sleep(3000);
      end;
      Sleep(100);
    end;
  end;
  function UpdataGameInfo: TRoleInfo;
  begin
    Result := FRoleInfoHandle.GetRoleInfo;
  end;

begin
  CloseGameWindows;
  SelectMemu;
  GotoSelectRole;
  GotoInGame;
  GameData.RoleInfo := UpdataGameInfo; // 重新设置人物信息
  if (GameData.RoleInfo.MainJob <> mjKuangzhanshi) and
    (GameData.RoleInfo.MainJob <> mjYuxuemoshen) and
    (GameData.RoleInfo.MainJob <> mjSilingshushi) and
    (GameData.RoleInfo.MainJob <> mjLinghunshougezhe)
  then
    warnning;
  // 等级检测
  if GameData.RoleInfo.Lv <= 50 then
    warnning;
  // 等级较大的重新设置地图等级
  if GameData.RoleInfo.Lv >= 80 then
    GameData.GameConfig.iMapLv := 3;
end;

procedure TGame.CheckTask;
var
  x, y: OleVariant;
  iRet: Integer;
  hGame: Integer;
begin
  while (not Terminated) do
  begin
    TTask.CurrentTask.CheckCanceled;
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
  FCheckTask := nil;
end;

constructor TGame.Create;
begin
  // 创建并初始化对象
  New(FGameData);
  FObj := TObjFactory.CreateChargeObj;
  FGameData.Terminated := False;
  FGameData.Obj := FObj;
  GameData := FGameData;
  FMyObj := TObjFactory.CreateMyObj(FObj);
  FGameData.MyObj := FMyObj;
  FGameConfigManager := GlobalContainer.Resolve<IGameConfigManager>;

  FObj.SetDict(0, sDictPath); // 设置字库
  FObj.SetPath(sPicPath); // 设置路径
  // // 创建配置管理器

end;

procedure TGame.CreateGameObjs(aGameData: PGameData);
begin
  FRoleInfoHandle := GlobalContainer.Resolve<IRoleInfoHandle>;
  FRoleInfoHandle.SetGameData(aGameData);

  FMap := GlobalContainer.Resolve<IMap>;
  FMap.SetGameData(aGameData);

  FMove := GlobalContainer.Resolve<IMove>;
  FMove.SetGameData(aGameData);

  FPassGame := GlobalContainer.Resolve<IPassGame>;
  FPassGame.SetGameData(aGameData);

  FDoor := GlobalContainer.Resolve<IDoor>;
  FDoor.SetGameData(aGameData);

  FMan := GlobalContainer.Resolve<IMan>;
  FMan.SetGameData(aGameData);

  FMonster := GlobalContainer.Resolve<IMonster>;
  FMonster.SetGameData(aGameData);

  FGoods := GlobalContainer.Resolve<IGoods>;
  FGoods.SetGameData(aGameData);

  FCheckTimeOut := GlobalContainer.Resolve<ICheckTimeOut>;
  FCheckTimeOut.SetGameData(aGameData);

  FSkill := GlobalContainer.Resolve<ISkill>;
  FSkill.SetGameData(aGameData);
end;

destructor TGame.Destroy;
begin
  Dispose(FGameData);
  FGameConfigManager := nil;
  FMyObj.Free;
  inherited;
end;

procedure TGame.DoorClosedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
var
  ptMonster, ptMonsterArrived: TPoint;
begin
  FMonster.ManPoint := aManPoint;
  ptMonster := FMonster.Point; // 获取怪物坐标
  // 长时间未获得怪物坐标进行寻怪
  if FCheckTimeOut.IsMonsterFindTimeOut(ptMonster) then
  begin
    FMove.StopMove;
    FMove.MoveToFindMonster(aManPoint, aMiniMap);
    LongTimeNoMoveHandle(aManPoint);
    Exit;
  end;
  // 移动向怪物
  if not ptMonster.IsZero then
  begin
    if FMonster.IsArriviedMonster(ptMonsterArrived) then
    begin
      // 调整方向
      if FGameData.GameConfig.bNearAdjustDirection then
      begin
        if ptMonsterArrived.x < (aManPoint.x - 5) then
        begin
          Obj.KeyPressChar('left');
          Sleep(60);
        end
        else
          if ptMonsterArrived.x > (aManPoint.x + 5) then
        begin
          Obj.KeyPressChar('right');
          Sleep(60);
        end;
      end;
      // 达到怪物杀怪
      FMove.StopMove;
      FSkill.ReleaseSkill;
      FCheckTimeOut.ResetManStopWatch;
    end
    else
    begin
      FMove.MoveToMonster(aManPoint, ptMonster, aMiniMap);
      LongTimeNoMoveHandle(aManPoint);
    end;

  end;

end;

procedure TGame.DoorOpenedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
var
  ptDoor, ptGoods: TPoint;
begin

  // 10s捡物
  if not FCheckTimeOut.IsInMapPickupGoodsOpenedTimeOut(aMiniMap) then
  begin
    FGoods.ManPoint := aManPoint; // 用来计算最近物品坐标
    ptGoods := FGoods.Point; // 获取物品坐标
    if not ptGoods.IsZero then
    begin
      // 有物品走向物品,不继续执行进门
      FMove.MoveToGoods(aManPoint, ptGoods, aMiniMap);
      LongTimeNoMoveHandle(aManPoint);
      Exit;
    end;
  end;
  // 超时进门
  FDoor.ManPoint := aManPoint;
  FDoor.MiniMap := aMiniMap;
  if FDoor.IsArrviedDoor then // 到达门,进门
  begin
    FMove.StopMove;
    FMove.MoveInDoor(FDoor.KeyCode);
  end
  else
  begin
    ptDoor := FDoor.Point; // 获得门坐标
    if not ptDoor.IsZero then
    begin
      FMove.MoveToDoor(aManPoint, ptDoor, aMiniMap); // 进门
    end;
    LongTimeNoMoveHandle(aManPoint);
  end;

end;

procedure TGame.FreeGameObjs;
begin
  FRoleInfoHandle := nil;
  FMap := nil;
  FMove := nil;
  FPassGame := nil;
  FDoor := nil;
  FMan := nil;
  FMonster := nil;
  FGoods := nil;
  FCheckTimeOut := nil;
  FSkill := nil;
end;

procedure TGame.GameTask;
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
      CoInitializeEx(nil, 0); // 初始化Com库
      FGameData^.GameConfig := FGameConfigManager.Config; // 读取配置文件
      FGameData^.Hwnd := BindGame; // 保存游戏窗口句柄
      FGameData.Terminated := False;
      CreateGameObjs(FGameData); // 创建需要使用的对象
      LoopHandle; // 循环处理
    except
      on E: EGame do
      begin
        Application.MessageBox(PWideChar(E.Message), '警告');
        CodeSite.Send('error operator');
      end;
    end;
  finally
    CodeSite.Send('start to clear ');
    FreeGameObjs;
    FMainTask := nil;
    CoUninitialize;

    // 清除所有作业 ,调用后似乎不能正确执行
  end;
end;

procedure TGame.GoToInMap;
var
  iRet: Integer;
  x, y: OleVariant;
  // 打开大地图
  procedure OpenLargeMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(2, 4, 108, 48, '大地图.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        Break;
      end
      else
      begin
        FObj.KeyPressChar('n');
        Sleep(1000);
      end;
    end;
  end;
// 移动到地图附近
  procedure MoveToNearMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(336, 444, 358, 467, '大指针.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        // 到达目的地
        Break;
      end
      else
      begin
        // 未到达就鼠标右击
        FObj.MoveTo(346, 454);
        Sleep(200);
        FObj.RightClick;
        Sleep(2000);
        MoveToFixPoint;
      end;
    end;
  end;

// 进入地图
  procedure DoInMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      // 发现打开了
      iRet := FObj.FindStr(696, 538, 790, 566, '返回城镇',
        StrColorOffset('ddc593'), 1.0, x, y);
      if iRet > -1 then
      begin
        FObj.KeyUpChar('right'); // 弹起右键
        Sleep(1000);
        Break;
      end
      else
      begin
        // 未发现打开
        FObj.KeyDownChar('right');
        Sleep(1000);
      end;
    end;
  end;
// 选中外围
  procedure SelectMap;
  begin
    // 进入到了选图位置
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(8, 269, 230, 470, '根特外围(未选中).bmp',
        clPicOffsetZero, 0.9, 0, x, y);
      // 如果是未选中状态
      if iRet > -1 then
      begin
        FObj.MoveTo(x, y);
        Sleep(400);
        FObj.LeftClick;
        Sleep(400);
        MoveToFixPoint;
      end
      else
      begin
        iRet := FObj.FindPic(8, 269, 230, 470, '根特外围(选中).bmp',
          clPicOffsetZero, 0.9, 0, x, y);
        // 如果是选中状态
        if iRet > -1 then
        begin
          // 设置地图等级
          Break;
        end;
      end;
    end;
  end;
  procedure SelectMapLv;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(8, 269, 230, 470,
        '普通.bmp|冒险.bmp|勇士.bmp|王者.bmp', clPicOffsetZero, 0.9, 0, x, y);
      if iRet > -1 then
      begin
        with GameData.GameConfig do
        begin
          if iRet = iMapLv then
          begin
            while not Terminated do
            begin
              TTask.CurrentTask.CheckCanceled;
              if FMap.MiniMap = mmMain1 then
              begin
                Exit;
              end
              else
              begin
                FObj.KeyPressChar('space');
                Sleep(500);
              end;

            end;

          end
          else
            if iRet < iMapLv then
          begin
            FObj.KeyPressChar('right');
            Sleep(500);
          end
          else
          begin
            FObj.KeyPressChar('left');
            Sleep(500);
          end;
        end;
      end;
    end;
  end;

begin

  OpenLargeMap;
  MoveToNearMap;
  DoInMap;
  SelectMap;
  SelectMapLv;

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
    ChDir(sPath);
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
// 加血
  procedure HpHandle;
  var
    iRet: Integer;
    x, y: OleVariant;
  begin
    iRet := FObj.CmpColor(37, 558, 'bb1111-333333', 0.9);
    if iRet = 1 then
    begin
      iRet := FObj.FindPic(80, 553, 270, 592, '达人HP药剂.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        // FObj.KeyPressChar('1');
        // Sleep(100);
        FObj.MoveTo(x, y);
        Sleep(100);
        FObj.RightClick;
        Sleep(200);
        MoveToFixPoint;
      end;
    end;

  end;
  function GetManPoint(var aManPoint: TPoint): Boolean;
  begin
    Result := False;
    aManPoint := FMan.Point;
    if FCheckTimeOut.IsManFindTimeOut(aManPoint) then // 必须把坐标传给他进行超时检测
    begin
      FMove.StopMove;
      FMove.RandomMove; // 随机移动
    end
    else
      Result := True;
  end;

  procedure PickupGoods(aMiniMap: TMiniMap);
  begin
    // if not FCheckTimeOut.IsInMapPickupGoodsTimeOut(aMiniMap) then
    // begin
    if FGoods.IsArrivedGoods then
    begin
      FMove.StopMove;
      FGoods.PickupGoods;
      FCheckTimeOut.ResetManStopWatch;
    end;
    // end;
  end;

var
  aMiniMap: TMiniMap;
  ptMan: TPoint;
  bDoorState: Boolean;
begin
  aMiniMap := FMap.MiniMap; // 获取小地图
  case aMiniMap of
    mmUnknown:
      FMove.StopMove; // 停止移动
    mmClickCards:
      begin
        FPassGame.ClickCards; // 翻牌
      end;
    mmPassGame:
      begin
        FPassGame.EndSell; // 卖物等
        FSkill.RestetSkills; // 重置技能
      end;
  else
    CloseGameWindows; // 关闭所有窗口
    HpHandle; // 血处理
    if FSkill.ReleaseHelperSkill then // 释放辅助技能
      FCheckTimeOut.ResetManStopWatch;
    if not GetManPoint(ptMan) then // 获取人物坐标
    begin
      Exit;
    end;

    // 图很长时间没有变化了,进行报警
    if FCheckTimeOut.IsInMapLongTimeOut(aMiniMap) then
    begin
      warnning;
    end;
    // 虚弱报警
    if IsWeakInMap then
    begin
      warnning;
    end;
    PickupGoods(aMiniMap); // 捡物
    bDoorState := FDoor.IsOpen;
    if not FCheckTimeOut.CompareMiniMap(aMiniMap) then
      FMove.StopMove; // 停止
    if bDoorState then
    begin
      DoorOpenedHandle(aMiniMap, ptMan)
    end
    else
    begin
      DoorClosedHandle(aMiniMap, ptMan);
    end;

  end;

end;

procedure TGame.LongTimeNoMoveHandle(const aManPoint: TPoint);
begin
  if not aManPoint.IsZero then
  begin
    if FCheckTimeOut.IsManMoveTimeOut(aManPoint) then // 如果人物坐标长时间没有变化,说明卡位了
    begin
      FMove.StopMove;
      FSkill.DestroyBarrier; // 破坏一下障碍
      FMove.RandomMove; // 随机移动
    end;
  end;
end;

procedure TGame.LoopHandle;
var
  aLargeMap: TLargeMap;
begin
  CloseGameWindows; // 关闭所有窗口
  FGameData.RoleInfo := FRoleInfoHandle.GetRoleInfo; // 获取角色信息,获取失败抛出异常
  if FGameData.GameConfig.bVIP then // 依据类型设置字的颜色
    FGameData.ManStrColor := clVip
  else
    FGameData.ManStrColor := clStrWhite;
  FCheckTask := TTask.Run(CheckTask); // 运行检测任务
  while (not Terminated) do
  begin
    TTask.CurrentTask.CheckCanceled; // 检测
    aLargeMap := FMap.LargeMap; // 获取大地图
    if FCheckTimeOut.IsOutMapTimeOut(aLargeMap) then // 检测是否在图外超时
      warnning;
    case aLargeMap of
      lmUnknown:
        UnknownMapHandle; // 未知图操作
      lmOut:
        OutMapHandle; // 图内操作
      lmIn:
        InMapHandle; // 图内操作
    end;
    Sleep(GameData.GameConfig.iLoopDelay); // 循环延时
  end;
end;

procedure TGame.OutMapHandle;
var
  ChangeRoleTask, GotoInMapTask: ITask;
begin
  CloseGameWindows; // 关闭所有窗口
  FMove.StopMove;
  // 虚弱进行等待
  if IsWeak then
  begin
    // warnning;
    Sleep(1000);
  end
  else
  begin
    // 不虚弱检测疲劳
    if not IsHavePilao then
    begin
      // 开始换角色作业,并等待完成
      ChangeRoleTask := TTask.Run(ChangeRole);
      if not ChangeRoleTask.Wait(1000 * 60 * 2) then
      begin
        ChangeRoleTask.Cancel;
        warnning;
      end;
    end
    else
    begin
      // 开始进图作业,并等待完成
      GotoInMapTask := TTask.Run(GoToInMap);
      if not GotoInMapTask.Wait(1000 * 60 * 2) then
      begin
        GotoInMapTask.Cancel;
        warnning;
      end;
    end;
  end;
end;

procedure TGame.Start;
begin
  if (not Assigned(FMainTask)) and (not Assigned(FCheckTask)) then
  begin
    FMainTask := TTask.Run(GameTask);
  end;

end;

procedure TGame.Stop;
begin
  if Assigned(FMainTask) then
  begin
    FGameData.Terminated := True;
    if FMainTask.Status = TTaskStatus.Running then
      FMainTask.Cancel;
  end;
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
RegisterServices('Services/Game', [TGameService.Create(IGameService,
  'GameService')]);

finalization

UnregisterServices('Services/Game', ['GameService']);
CleanupGlobalContainer;

end.
