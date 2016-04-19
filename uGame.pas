// 游戏主逻辑
unit uGame;

interface

uses uGame.Interf, uObj, QWorker, Spring.Container,
  System.SysUtils, Winapi.Windows, System.Types, System.Rtti,
  System.Diagnostics;

// 游戏主体逻辑类
type
  TGame = class(TGameBase, IGame)
  private
    FJobHwnd: IntPtr;
    // FJob: PQJob;
    // FGameData:TGameData;
    FTerminated: Boolean; // 可能需要锁一下 FPTerminated: PBoolean;
    FIsRunning: Boolean;
    FObj: IChargeObj;
    FMyObj: TMyObj;
    FDoor: IDoor;
    FMonster: IMonster;
    FMan: IMan;
    FMove: IMove;
    FMap: IMap;
    FSkill: ISkill;
    FCheckTimeOut: ICheckTimeOut;
    FGoods: IGoods;
    FPassGame: IPassGame;
    FOutMap: IOutMap;
  private
    FGameConfigManager: IGameConfigManager;
    procedure SetGameConfigManager(const value: IGameConfigManager);
    procedure CreateObjInterf; // 创建对象接口
    procedure DestoryObjInterf; // 销毁对象接口
  private
    procedure MainProc(AJob: PQJob);
    procedure GameInit; // 游戏初始化操作
    procedure GameLoop; // 游戏循环
    procedure GameFinal; // 游戏结尾化操作
    procedure GameFinalMust; // 游戏结束后必须执行的操作,异常发生也需要执行
  private
    procedure GoToInMap(AJob: PQJob);
    procedure ChangeRole(AJob: PQJob);
    procedure CheckGame(AJob: PQJob);
  private
    procedure InMapHandle(const aMiniMap: TMiniMap);
    procedure OutMapHandle();
  public
    constructor Create();
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  end;

implementation

uses CodeSiteLogging;
{ TGame }

procedure TGame.ChangeRole(AJob: PQJob);
var
  x, y: OleVariant;
  iRet: Integer;

  procedure SelectMemu;
  begin
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindPic(38, 42, 617, 531, '左上角.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        oldX := x; // 记录第一次坐标
        Break;
      end;
      Sleep(500);
    end;
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindStr(211, 128, 774, 540, '黄金哥布林|赛丽亚|邮件箱',
        StrColorOffset('f7d65a'), 1.0, x, y);
      if iRet > -1 then
      begin
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
  var
    RoleInfoHandle: IRoleInfoHandle;
  begin
    RoleInfoHandle := GlobalContainer.Resolve<IRoleInfoHandle>;
    Result := RoleInfoHandle.GetRoleInfo;
  end;

begin
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
end;

procedure TGame.CheckGame(AJob: PQJob);
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
  FObj := TObjFactory.CreateChargeObj;
  // 设置路径和字库
  // FObj.SetDict(0, '.\Dict\Main.txt');
  // FObj.SetPath('.\Pic');
  FObj.SetDict(0, '..\Dict\Main.txt');
  FObj.SetPath('..\Pic');
  FMyObj := TMyObj.Create(FObj);

end;

procedure TGame.CreateObjInterf;
begin
  FDoor := GlobalContainer.Resolve<IDoor>;
  FMonster := GlobalContainer.Resolve<IMonster>;
  FMan := GlobalContainer.Resolve<IMan>;
  FMove := GlobalContainer.Resolve<IMove>;
  FMap := GlobalContainer.Resolve<IMap>;
  FSkill := GlobalContainer.Resolve<ISkill>;
  FCheckTimeOut := GlobalContainer.Resolve<ICheckTimeOut>;
  FGoods := GlobalContainer.Resolve<IGoods>;
  FPassGame := GlobalContainer.Resolve<IPassGame>;
  FOutMap := GlobalContainer.Resolve<IOutMap>;
end;

procedure TGame.DestoryObjInterf;
begin
  FDoor := nil;
  FMonster := nil;
  FMan := nil;
  FMove := nil;
  FMap := nil;
  FSkill := nil;
  FCheckTimeOut := nil;
  FGoods := nil;
  FPassGame := nil;
  FOutMap := nil;
end;

destructor TGame.Destroy;
begin
  FObj := nil;
  FMyObj.Free;
  inherited;
end;

procedure TGame.GameLoop;
  procedure CheckHanlde;
  var
    x, y: OleVariant;
    iRet: Integer;
  begin
    iRet := FObj.FindStr(0, 0, 800, 600, '网络连接中断', clStrWhite, 1.0, x, y);
    if iRet > -1 then
      warnning;
  end;
  procedure OutMapLoop;
  begin
    while not FTerminated do
    begin
      // CheckHanlde;
      if FMap.LargeMap <> lmOut then
        Break;
      CodeSite.Send('图外操作');
      OutMapHandle;
      Sleep(GameData.GameConfig.iLoopDelay);
    end;
  end;

  procedure InMapLoop;
  begin

    while not FTerminated do
    begin
      // CheckHanlde;
      if FMap.LargeMap <> lmIn then
        Break;
      CodeSite.Send('图内操作');
      InMapHandle(FMap.MiniMap); // 图内操作
      //
      Sleep(GameData.GameConfig.iLoopDelay);
    end;
  end;
  procedure UnknownMapLoop;
  begin
    while not FTerminated do
    begin
      if FMap.LargeMap <> lmUnknown then
        Break;
      CloseGameWindows;
    end;

  end;

begin
  Workers.Post(CheckGame, nil); // 投寄一个检测作业
  while not FTerminated do
  begin
    CodeSite.Send('线程运行中');
    // CheckHanlde;
    OutMapLoop;
    InMapLoop;
    UnknownMapLoop;
    Sleep(GameData.GameConfig.iLoopDelay);
  end;
end;

procedure TGame.GoToInMap(AJob: PQJob);
var
  iRet: Integer;
  x, y: OleVariant;
  // 打开大地图
  procedure OpenLargeMap;
  begin
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindPic(8, 269, 230, 470,
        '普通.bmp|冒险.bmp|勇士.bmp|王者.bmp', clPicOffsetZero, 0.9, 0, x, y);
      if iRet > -1 then
      begin
        with GameData.GameConfig do
        begin
          if iRet = iMapLv then
          begin
            FObj.KeyPressChar('space');
            Sleep(500);
            FObj.KeyPressChar('space');
            Sleep(500);
            Break;
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

procedure TGame.InMapHandle(const aMiniMap: TMiniMap);
// 门开启状态操作
  procedure DoorOpenDo;
  var
    ptMan, ptDoor, ptGoods: TPoint;
  begin
    // 由于通关结束了,BOSS门的颜色也会显示开启,所以需要判断是否还是杀怪关卡
    // 在单个图内超时报警
    if FCheckTimeOut.IsInMapLongTimeOut(aMiniMap) then
    begin
      warnning;
    end;

    ptMan := FMan.Point;
    // 移动超时
    if FCheckTimeOut.IsManMoveTimeOut(ptMan) then
    begin
      CodeSite.Send('人物移动超时,进行随机移动');
      FSkill.DestroyBarrier;
      FMove.RandomMove;
      Exit;
    end;
    // 发现超时
    if FCheckTimeOut.IsManFindTimeOut(ptMan) then
    begin
      CodeSite.Send('人物坐标获取超时,执行随机移动');
      FMove.RandomMove;
      Exit;
    end;
    // 捡物没有超时
    FGoods.ManPoint := ptMan;
    if not FCheckTimeOut.IsInMapPickupGoodsTimeOut(aMiniMap) then
    begin
      CodeSite.Send('捡物没有超时');
      if FGoods.IsArrivedGoods then
      begin
        CodeSite.Send('达到物品,捡物');
        FMove.StopMove;
        FGoods.PickupGoods;
        Exit;
      end
      else
      begin
        CodeSite.Send('没有到达物品');
        ptGoods := FGoods.Point;
        if not ptGoods.IsZero then
        begin
          CodeSite.Send('移向物品');
          FMove.MoveToGoods(ptMan, ptGoods, aMiniMap);
          Exit;
        end;
      end;

    end;

    // 找到怪物坐标
    if not ptMan.IsZero then
    begin
      // 初始化Door只写数据
      FDoor.ManPoint := ptMan;
      FDoor.MiniMap := aMiniMap;
      if FDoor.IsArrviedDoor then
      begin
        // 到达门,执行进门操作
        CodeSite.Send('到达门附近,执行进门');
        FMove.StopMove; // 停止移动
        FMove.MoveInDoor(FDoor.KeyCode);
        Exit;
      end;

      ptDoor := FDoor.Point;
      if not ptDoor.IsZero then
      begin
        // 找到门坐标,向门移动
        CodeSite.Send('已获取门坐标,执行移动');
        FMove.MoveToDoor(ptMan, ptDoor, aMiniMap);
      end
      else
      begin
        CodeSite.Send('门坐标获取失败');
      end;
    end;
  end;
// 门关闭状态操作
  procedure DoorCloseDo;
  var
    ptMonster, ptMan: TPoint;
  begin
    // 在特殊地方停止移动
    if (aMiniMap in [mmClickCards, mmPassGame]) then
    begin
      FMove.StopMove;
      Exit;
    end;

    FSkill.ReleaseHelperSkill; // 释放辅助技能

    ptMan := FMan.Point;
    // 如果到达物品捡一下物品
    if FGoods.IsArrivedGoods then
    begin
      FMove.StopMove;
      FGoods.PickupGoods;
    end;
    // 移动超时
    if FCheckTimeOut.IsManMoveTimeOut(ptMan) then
    begin
      CodeSite.Send('人物移动超时,进行随机移动');
      FSkill.DestroyBarrier; // 破坏障碍物一下
      FMove.RandomMove;
      Exit;
    end;

    // 发现超时
    if FCheckTimeOut.IsManFindTimeOut(ptMan) then
    begin
      CodeSite.Send('人物坐标获取超时,执行随机移动');
      FMove.RandomMove;
      Exit;
    end;
    if not ptMan.IsZero then
    begin
      ptMonster := FMonster.Point;
      if FCheckTimeOut.IsMonsterFindTimeOut(ptMonster) then
      begin
        CodeSite.Send('怪物坐标获取超时,执行寻怪');
        FMove.MoveToFindMonster(ptMan, aMiniMap);
        Exit;
      end;
      if not ptMonster.IsZero then
      begin
        // 找到怪物向怪物移动
        FMonster.ManPoint := ptMan;
        if FMonster.IsArrviedMonster then
        begin
          // 到达怪物,杀怪
          CodeSite.Send('到达怪物,停止移动,进行杀怪');
          CodeSite.Write('是否到达怪物', '是');
          FMove.StopMove; // 停止移动
          // 把人物调整到怪物方向
          // 人在左边
          if GameData.GameConfig.bNearAdjustDirection then
          begin
            if (ptMan.x < ptMonster.x - 80) then
              Obj.KeyPressChar('left')
            else
              if ptMan.x > ptMonster.x + 80 then
              Obj.KeyPressChar('right');
            Sleep(50);
          end;
          FSkill.ReleaseSkill; // 杀怪
        end
        else
        begin
          CodeSite.Write('是否到达怪物', '否');
          CodeSite.Send('怪物坐标获取成功,执行移向怪物');
          FMove.MoveToMonster(ptMan, ptMonster,
            aMiniMap);
        end;

      end;
    end;

  end;
// 翻牌
  procedure ClickCards;
  var
    x, y: OleVariant;
    iRet: Integer;
    bIsClick: Boolean;
    I: Integer;
  begin
    bIsClick := False;
    while not FTerminated do
    begin
      iRet := FObj.FindPic(6, 25, 483, 559,
        '牌1.bmp|黄金卡牌5.bmp|黄金卡牌5Ex.bmp|双倍黄金卡牌5.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet = -1 then
        Break
      else
      begin
        bIsClick := True;
        FObj.MoveTo(x - 40, y + 37);
        Sleep(100);
        FObj.LeftClick;
        Sleep(200);
      end;
    end;
    if bIsClick then
    begin
      Sleep(1000);
      // FObj.KeyPressChar('3');
      FObj.KeyDownChar('3');
      Sleep(200);
      FObj.KeyUpChar('3');
      Sleep(1000);
      for I := 0 to 30 do
      begin
        FObj.KeyPressChar('x');
        Sleep(80);
      end;
    end;

  end;
// 加血
  procedure AddHp;
  var
    iRet: Integer;
    x, y: OleVariant;
  begin
    iRet := FObj.CmpColor(37, 558, 'bb1111-333333', 1.0);
    if iRet = 1 then
    begin
      iRet := FObj.FindPic(80, 553, 270, 592, '达人HP药剂.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        FObj.KeyPressChar('1');
        Sleep(100);
        // FObj.MoveTo(x, y);
        // Sleep(100);
        // FObj.RightClick;
        // Sleep(200);
        // MoveToFixPoint;
      end;
    end;
  end;

begin
  // 依据所在地图执行操作

  CodeSite.Write('所在图', TRttiEnumerationType.GetName(aMiniMap));
  CloseGameWindows;
  if not(aMiniMap in [mmUnknown, mmPassGame, mmClickCards]) then
  begin
    AddHp;
    if FDoor.IsOpen then
    begin
      CodeSite.Send('门开启时的操作');
      DoorOpenDo; // 开启的操作
    end
    else
    begin
      CodeSite.Send('门关闭时的操作');
      DoorCloseDo; // 关闭的操作
    end;
  end
  else
  begin

    FMove.StopMove; // 此处不需要移动
    if aMiniMap = mmPassGame then
    begin
      FPassGame.Handle;
      FSkill.RestetSkills; // 重置技能
    end
    else
      if aMiniMap = mmClickCards then
    begin
      ClickCards;
    end;
  end;

end;

procedure TGame.GameFinal;
begin
  CodeSite.Send('普通的线程结束操作');
end;

procedure TGame.GameFinalMust;
begin
  CodeSite.Send('线程必须的清理操作');
  // 判断窗口是否置顶
  if FObj.GetWindowState(GameData.Hwnd, 5) = 1 then
    // if GameData.GameConfig.WndState = 1 then
    FObj.SetWindowState(GameData.Hwnd, 9); // 必须取消置顶
  DestoryObjInterf;
end;

procedure TGame.GameInit;
  function BindGame: Integer;
  var
    lBind: Integer;
  begin
    Result := FObj.FindWindow('地下城与勇士', '地下城与勇士');
    if Result = 0 then
      raise EBindFailed.Create('游戏窗口不存在!');
    lBind := FObj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if lBind <> 1 then
      raise EBindFailed.CreateFmt('绑定失败,错误码:%d', [lBind]);
    // 激活或置顶窗口
    case GameData.GameConfig.iWndState of
      0:
        FObj.SetWindowState(Result, 1);
      1:
        begin
          // 光置顶没有效果,必须先激活一下
          FObj.SetWindowState(Result, 1);
          FObj.SetWindowState(Result, 8);
        end;
    else
      FObj.SetWindowState(Result, 1); // 默认激活
    end;

  end;
  function UpdataGameInfo: TRoleInfo;
  var
    RoleInfoHandle: IRoleInfoHandle;
  begin
    RoleInfoHandle := GlobalContainer.Resolve<IRoleInfoHandle>;
    Result := RoleInfoHandle.GetRoleInfo;
  end;
  function UpdataManStrColor: string;
  begin
    if GameData.GameConfig.bVIP then
      Result := clVip
    else
      Result := clNoVip;
  end;

begin
  CreateObjInterf; // 创建对象接口
  GameData.PTerminated := @FTerminated;
  GameData.Obj := FObj;
  GameData.MyObj := FMyObj;
  GameData.GameConfig := FGameConfigManager.Config; // 设置配置信息,必须先设置配置信息
  GameData.Hwnd := BindGame; // 设置绑定窗口句柄
  GameData.RoleInfo := UpdataGameInfo; // 设置角色信息
  GameData.ManStrColor := UpdataManStrColor;
end;

procedure TGame.MainProc(AJob: PQJob);
begin
  try
    try
      // FJob := AJob;
      CodeSite.Send('游戏线程');
      // RegisterGameClass; // 注册游戏功能类
      AJob.Worker.ComNeeded(); // 支持COM

      GameInit; // 初始化游戏
      GameLoop; // 游戏循环
      GameFinal; // 清理操作
    except
      on E: EBindFailed do
      begin
        MessageBoxW(0, PChar(E.Message), '警告', MB_OK + MB_ICONWARNING);
        raise;
      end;
      on E: ERoleInfoFailed do
      begin
        MessageBoxW(0, PChar(E.Message), '警告', MB_OK + MB_ICONWARNING);
        raise;
      end;
      else
        raise;
    end;
  finally
    GameFinalMust; // 必须进行的清理操作
    // UnregisterGameClass; // 卸载功能
    FIsRunning := False;
    FTerminated := False;
    CodeSite.Send('线程已结束');
  end;

end;

procedure TGame.OutMapHandle;
// 是否虚弱
  function IsWeak: Boolean;
  var
    x, y: OleVariant;
    iRet: Integer;
  begin
    iRet := Obj.FindPic(242, 488, 800, 569, '虚弱.bmp', clPicOffsetZero,
      0.9, 0, x, y);
    Result := iRet > -1;
  end;

var
  hGotoInMap, hChangeRole: IntPtr;
begin
  CloseGameWindows;
  FMove.StopMove; // 停止移动
  // 虚弱进行等待
  if IsWeak then
  begin
    // warnning;
    Sleep(1000);
  end
  else
  begin
    // 不虚弱检测疲劳
    if IsNotHasPilao then
    begin
      // 投寄换角色作业,并等待完成
      hChangeRole := Workers.Post(ChangeRole, nil);
      if Workers.WaitJob(hChangeRole, 1000 * 60 * 2, False) = wrTimeout then
      begin
        Workers.ClearSingleJob(hChangeRole); // 等待完成,会立刻停止
        warnning;
      end;
    end
    else
    begin
      // 投寄进图作业,并等待完成
      hGotoInMap := Workers.Post(GoToInMap, nil);
      if Workers.WaitJob(hGotoInMap, 1000 * 60 * 2, False) = wrTimeout then
      begin
        Workers.ClearSingleJob(hGotoInMap);
        warnning;
      end;
    end;
  end;

end;

procedure TGame.SetGameConfigManager(const value: IGameConfigManager);
begin
  FGameConfigManager := value;
end;

procedure TGame.Start;
// var
// JobState: TQJobState;
begin
  // if not Workers.PeekJobState(FJobHwnd, JobState) then
  // begin
  // FJobHwnd := Workers.Post(MainProc, nil); // 投寄游戏主要任务
  // end
  // else
  // begin
  // MessageBoxW(0, '程序正在运行,请等待停止后再次运行!', '警告', MB_OK + MB_ICONWARNING);
  // Exit;
  // end;

  CodeSite.Send('start');
  if FIsRunning and (not Terminated) then // 已运行退出
  begin
    MessageBoxW(0, '程序正在运行,请等待停止后再次运行!', '警告', MB_OK + MB_ICONWARNING);
    Exit;
  end;
  FIsRunning := True;

end;

procedure TGame.Stop;
begin
  if (not FTerminated) and FIsRunning then
  begin
    FTerminated := True;
    Workers.Clear;
  end;

end;

end.
