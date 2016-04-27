{
  主逻辑中没有阻塞函数,是在一个循环中进行实时检测判断执行的,
  但是通关后的操作是进行阻塞的,必须执行完成后才能跳出循环
}

unit uGameEx;

interface

uses uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass, QPlugins,
  System.Types, System.Threading, Winapi.ActiveX, System.Classes,
  System.Diagnostics;

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
  strict private
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
  strict private
    procedure LongTimeNoMoveHandle(const aManPoint: TPoint);

  private
    function GetManPoint: TPoint;
  private
    // 图外的相关任务
    procedure DoOutMapTask;
    procedure DoGoToInMapTask;
    procedure DoChangeRoleTask;
    procedure DoWeakTask;
    // 图内相关任务
    procedure DoInNormalMapTask;
    procedure DoDoorOpenedTask;
    procedure DoDoorClosedTask;
    procedure HpHandle;
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

procedure TGame.DoChangeRoleTask;
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
        CloseGameWindows; // 等待5秒后关闭所有窗口
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

begin
  CloseGameWindows;
  SelectMemu;
  GotoSelectRole;
  GotoInGame;
  FGameData^.RoleInfo := FRoleInfoHandle.GetRoleInfo; // 重新设置人物信息
  if (FGameData^.RoleInfo.MainJob <> mjKuangzhanshi) and
    (FGameData^.RoleInfo.MainJob <> mjYuxuemoshen) and
    (FGameData^.RoleInfo.MainJob <> mjSilingshushi) and
    (FGameData^.RoleInfo.MainJob <> mjLinghunshougezhe)
  then
    warnning;
  // 等级检测
  if FGameData^.RoleInfo.Lv <= 50 then
    warnning;
  // 等级较大的重新设置地图等级
  if FGameData^.RoleInfo.Lv >= 80 then
    FGameData^.GameConfig.iMapLv := 3;
end;

procedure TGame.DoDoorClosedTask;
var
  ptMan, ptMonster, ptOldMonster, ptOldMan: TPoint;
  swMan, swMonster: TStopwatch;
  OldMiniMap, NewMiniMap: TMiniMap;
begin
  ptOldMan := TPoint.Zero;
  swMan := TStopwatch.Create;
  swMonster := TStopwatch.Create;
  OldMiniMap := FMap.MiniMap;
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    NewMiniMap := FMap.MiniMap;
    if NewMiniMap in [mmUnknown, mmPassGame, mmClickCards] then
      Break;
    if OldMiniMap <> NewMiniMap then
      Break;
    if FDoor.IsOpen then
      Break;
    CloseGameWindows;
    HpHandle;
    if IsWeakInMap then // 图内虚弱报警
      warnning;
    if FSkill.ReleaseHelperSkill then // 释放辅助技能
    begin
      swMan.Stop; // 释放技能也要停止计时
      swMan.Reset;
    end;
    if FGoods.IsArrivedGoods then // 到达物品捡物
    begin
      FGoods.PickupGoods;
      swMan.Stop; // 捡物停止计时
      swMan.Reset;
    end;

    ptMan := GetManPoint;
    if not ptMan.IsZero then
    begin
      // 如果和上一次相同,进行时间比较
      // ----------------------
      if ptOldMan = ptMan then
      begin
        if swMan.IsRunning then
        begin
          if swMan.ElapsedMilliseconds > 1000 * 5 then // 3秒位置没变进行随机移动
          begin
            FMove.StopMove;
            FSkill.DestroyBarrier;
            FMove.RandomMove;
            ptOldMan := TPoint.Zero;
            Sleep(20);
            Continue;
          end;
        end
        else
        begin
          swMan.Start;
        end;
      end
      else
      begin
        swMan.Stop;
        swMan.Reset;
      end;
      ptOldMan := ptMan; // 记录坐标
      // ---------------------------------
      FMonster.ManPoint := ptMan;
      if FMonster.IsArriviedMonster(ptMonster) then
      begin
        // 调整方向

        FMove.StopMove;
        if ptMonster.x < ptMan.x - 20 then
        begin
          FObj.KeyPressChar('left');
          Sleep(80);
        end
        else
          if ptMonster.x > ptMan.x + 20 then
        begin
          FObj.KeyPressChar('right');
          Sleep(80);
        end;
        FSkill.ReleaseSkill;
        swMan.Stop; // 到达怪物停止人物计时
        swMan.Reset;
        swMonster.Stop;
        swMonster.Reset;
      end
      else
      begin
        ptMonster := FMonster.Point;
        if ptMonster.IsZero then
        begin
          if swMonster.IsRunning then
          begin
            if swMonster.ElapsedMilliseconds >= 1000 * 4 then // 超时没找到挂我寻怪
            begin
              FMove.MoveToFindMonster(ptMan, OldMiniMap); // 寻怪
            end;
          end
          else
          begin
            swMonster.Start;
          end;

        end
        else
        begin
          swMonster.Stop;
          swMonster.Reset;
          FMove.MoveToMonster(ptMan, ptMonster, OldMiniMap);
        end;
      end;
    end;
    Sleep(20);
  end;
end;

procedure TGame.DoDoorOpenedTask;
var
  OldMiniMap, NewMiniMap: TMiniMap;
  ptMan, ptGoods, ptDoor, ptOldMan: TPoint;
  swPickupGoods, swMan: TStopwatch;
  bIsExistGoods, bIsOutTime: Boolean;
begin
  OldMiniMap := FMap.MiniMap; // 记录下当前的地图
  swPickupGoods := TStopwatch.StartNew;
  swMan := TStopwatch.Create;
  ptOldMan := TPoint.Zero;
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    NewMiniMap := FMap.MiniMap;
    if NewMiniMap in [mmUnknown, mmPassGame, mmClickCards] then
      Break;
    if OldMiniMap <> NewMiniMap then // 检测地图是否变化
      Break;
    if FDoor.IsClose then // 门已经关闭了跳出
      Break;
    CloseGameWindows;
    HpHandle;
    if IsWeakInMap then
      warnning;
    if FGoods.IsArrivedGoods then // 到达物品捡物
      FGoods.PickupGoods;
    ptMan := GetManPoint;
    if not ptMan.IsZero then
    begin
      // 如果和上一次相同,进行时间比较
      // ----------------------------
      if ptOldMan = ptMan then
      begin
        if swMan.IsRunning then
        begin
          if swMan.ElapsedMilliseconds > 1000 * 5 then // 3秒位置没变进行随机移动
          begin
            FMove.StopMove;
            FSkill.DestroyBarrier;
            FMove.RandomMove;
            ptOldMan := TPoint.Zero;
            Continue;
          end;
        end
        else
        begin
          swMan.Start;
        end;
      end
      else
      begin
        swMan.Stop;
        swMan.Reset;
      end;
      ptOldMan := ptMan; // 记录坐标
      // -------------------
      bIsExistGoods := FGoods.IsExistGoods;
      if bIsExistGoods then // 物品存在进行捡物
      begin
        bIsOutTime := swPickupGoods.ElapsedMilliseconds > 1000 * 10;
        if not bIsOutTime then // 检测物品捡物时间
        begin
          FGoods.ManPoint := ptMan; // 设置人物坐标用来获取最近坐标
          ptGoods := FGoods.Point;
          FMove.MoveToGoods(ptMan, ptGoods, OldMiniMap);
        end;
      end;
      if (not bIsExistGoods) or (bIsOutTime) then
      begin
        FDoor.ManPoint := ptMan;
        FDoor.MiniMap := OldMiniMap;
        if FDoor.IsArrviedDoor then // 到达门进门
        begin
          FMove.StopMove;
          FMove.MoveInDoor(FDoor.KeyCode);
        end
        else
        begin
          ptDoor := FDoor.Point;
          FMove.MoveToDoor(ptMan, ptDoor, OldMiniMap);
        end;
      end;
    end;
    Sleep(20);
  end;
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
  FObj.SetShowErrorMsg(0); // 关闭弹出
  FGameData.Terminated := False;
  FGameData.Obj := FObj;
  SetGameData(FGameData);
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

procedure TGame.DoorClosedHandle(aMiniMap: TMiniMap;
  aManPoint:
  TPoint);
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

procedure TGame.DoorOpenedHandle(aMiniMap: TMiniMap;
  aManPoint:
  TPoint);
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
      FCheckTimeOut.ResetManStopWatch;
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
    FCheckTimeOut.ResetManStopWatch;
  end;

end;

procedure TGame.DoOutMapTask;
var
  ChangeRoleTask, GotoInMapTask, weakTask: ITask;
begin
  FMove.StopMove; // 停止移动
  FObj.KeyPressChar('esc'); // 防止有其他窗口,比如任务窗口
  Sleep(200);
  CloseGameWindows; // 再次关闭所有窗口
  FMove.StopMove; // 停止移动
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    if FMap.LargeMap <> lmOut then // 不在图外跳出
      Break;
    CloseGameWindows; // 关闭所有窗口
    // 虚弱进行等待
    if IsWeak then
    begin
      // 虚弱作业
      weakTask := TTask.Run(DoWeakTask);
      if not weakTask.Wait(1000 * 60 * 8) then // 等待作业完成
      begin
        weakTask.Cancel;
        warnning;
      end;
    end
    else
    begin
      // 不虚弱检测疲劳
      if not IsHavePilao then
      begin
        // 开始换角色作业,并等待完成
        ChangeRoleTask := TTask.Run(DoChangeRoleTask);
        if not ChangeRoleTask.Wait(1000 * 60 * 2) then
        begin
          ChangeRoleTask.Cancel;
          warnning;
        end;
      end
      else
      begin
        // 开始进图作业,并等待完成
        GotoInMapTask := TTask.Run(DoGoToInMapTask);
        if not GotoInMapTask.Wait(1000 * 60 * 2) then
        begin
          GotoInMapTask.Cancel;
          warnning;
        end;
      end;
    end;
    Sleep(100);
  end;

end;

procedure TGame.DoWeakTask;
begin
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    CloseGameWindows;
    if FMap.LargeMap <> lmOut then // 不在图外跳出
      Break;
    if not IsWeak then
      Break;
    Sleep(1000);
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
      FGameData.Terminated := False;
      FGameData^.Hwnd := BindGame; // 保存游戏窗口句柄
      CreateGameObjs(FGameData); // 创建需要使用的对象
      LoopHandle; // 循环处理
    except
      on E: EGame do
      begin
        Application.MessageBox(PWideChar(E.Message), '警告');
        raise;
        CodeSite.Send('error operator');
      end
      else
        raise;
    end;
  finally
    CodeSite.Send('start to clear ');
    FreeGameObjs;
    FMainTask := nil;
    CoUninitialize;
    // 清除所有作业 ,调用后似乎不能正确执行
  end;
end;

function TGame.GetManPoint: TPoint;
var
  task: ITask;
  ptMan: PPoint;
begin
  Result := TPoint.Zero;
  ptMan := @Result;
  task := TTask.Run(
    procedure
    begin
      while not Terminated do
      begin
        TTask.CurrentTask.CheckCanceled;
        ptMan^ := FMan.Point;
        if not ptMan^.IsZero then
          Break;
        Sleep(100);
      end;

    end);
  if not task.Wait(1000 * 4) then // 等待4秒还是未获得进行随机移动
  begin
    task.Cancel;
    FSkill.DestroyBarrier;
    FMove.RandomMove;
  end;
end;

procedure TGame.DoGoToInMapTask;
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

procedure TGame.DoInNormalMapTask;
var
  OpenedTask, ClosedTask: ITask;
begin
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    if FMap.MiniMap in [mmPassGame, mmClickCards, mmUnknown] then
      Break;
    if FDoor.IsOpen then
    begin
      OpenedTask := TTask.Run(DoDoorOpenedTask);
      if not OpenedTask.Wait(1000 * 60 * 2) then
      begin
        OpenedTask.Cancel;
        warnning;
      end;
    end
    else
    begin
      ClosedTask := TTask.Run(DoDoorClosedTask);
      if not ClosedTask.Wait(1000 * 60 * 3) then
      begin
        ClosedTask.Cancel;
        warnning;
      end;
    end;
    Sleep(50);
  end;
end;

function TGame.Guard(): Boolean;
var
  iRet: Integer;
  sPath: string;
begin
  Result := False;
  sPath := GetCurrentDir;
  // if FGameConfigManager.Config.bAutoRunGuard then
  // begin
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
  // end;
end;

procedure TGame.HpHandle;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  iRet := FObj.CmpColor(37, 558, 'bb1111-444444', 1.0);
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

procedure TGame.InMapHandle;

var
  task: ITask;
begin

  case FMap.MiniMap of
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
    task := TTask.Run(DoInNormalMapTask);
    task.Wait();
  end;

end;

procedure TGame.LongTimeNoMoveHandle(
  const
  aManPoint:
  TPoint);
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
  FGameData^.RoleInfo := FRoleInfoHandle.GetRoleInfo; // 获取角色信息,获取失败抛出异常
  if FGameData.RoleInfo.Lv <= 50 then
    raise EGame.Create('Lv too low');
  if FGameData.GameConfig.bVIP then // 依据类型设置字的颜色
    FGameData.ManStrColor := clVip
  else
    FGameData.ManStrColor := clStrWhite;
  FCheckTask := TTask.Run(CheckTask); // 运行检测任务
  while (not Terminated) do
  begin
    try
      TTask.CurrentTask.CheckCanceled; // 检测
      aLargeMap := FMap.LargeMap; // 获取大地图

      case aLargeMap of
        lmUnknown:
          UnknownMapHandle; // 未知图操作
        lmOut:
          OutMapHandle; // 图内操作
        lmIn:
          InMapHandle; // 图内操作
      end;
      Sleep(GameData.GameConfig.iLoopDelay); // 循环延时
    except
      on E: EInvalidOp do // 屏蔽这个错误
      begin

      end;
    end;

  end;
end;

procedure TGame.OutMapHandle;
var
  OutMapTask: ITask;
begin
  OutMapTask := TTask.Run(DoOutMapTask);
  if not OutMapTask.Wait(1000 * 60 * 10) then // 超时报警
  begin
    OutMapTask.Cancel;
    warnning;
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
    FMainTask.Cancel;
  end;
  if Assigned(FCheckTask) then
  begin
    FCheckTask.Cancel;
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

procedure TGameService.SetHandle(
  const
  aHandle:
  THandle);
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
