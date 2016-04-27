{
  ���߼���û����������,����һ��ѭ���н���ʵʱ����ж�ִ�е�,
  ����ͨ�غ�Ĳ����ǽ���������,����ִ����ɺ��������ѭ��
}

unit uGameEx;

interface

uses uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass, QPlugins,
  System.Types, System.Threading, Winapi.ActiveX, System.Classes,
  System.Diagnostics;

type

  // ��Ϸ���߼�
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
    procedure GameTask; // ���߼���ҵ
    procedure CheckTask; // �����ҵ
    procedure LoopHandle; // ѭ������
    procedure InMapHandle; // ͼ�ڲ���
    procedure OutMapHandle; // ͼ�����
    procedure UnknownMapHandle; // δ֪ͼ����
    procedure CreateGameObjs(aGameData: PGameData); // ��������
    procedure FreeGameObjs;
    procedure DoorClosedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
    procedure DoorOpenedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
  strict private
    procedure LongTimeNoMoveHandle(const aManPoint: TPoint);

  private
    function GetManPoint: TPoint;
  private
    // ͼ����������
    procedure DoOutMapTask;
    procedure DoGoToInMapTask;
    procedure DoChangeRoleTask;
    procedure DoWeakTask;
    // ͼ���������
    procedure DoInNormalMapTask;
    procedure DoDoorOpenedTask;
    procedure DoDoorClosedTask;
    procedure HpHandle;
  public
    constructor Create();
    destructor Destroy; override;
    procedure Start; // ������Ϣ
    procedure Stop;
    function Guard(): Boolean;
  end;

  // Ϊ��֧�ֲ��,�������ٴη�װ
  TGameService = class(TQService, IGameService)
  private
    FGame: TGame;
  public
    destructor Destroy; override;
    procedure SetHandle(const aHandle: THandle);
    procedure Prepare; // ���ڲ��ֹ��ܷ��ڲ���Ĺ��Ӻ����лᵼ�³���ס������,����ֻ��������
    procedure Start; // ��ʼ
    function Guard: Boolean; // ��������˱�������true,���򷵻�false
    procedure Stop; // ֹͣ
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
      iRet := FObj.FindStr(325, 91, 542, 221, '��Ϸ�˵�', clStrWhite, 1.0, x, y);
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
      iRet := FObj.FindPic(364, 383, 436, 464, 'ѡ���ɫ.bmp', clPicOffsetZero,
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
        iRet := FObj.FindStr(482, 471, 630, 582, '������Ϸ',
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
    oldX: Integer; // ��¼�����ʼ����
  begin
    oldX := 0;
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(38, 42, 617, 531, '���Ͻ�.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        oldX := x; // ��¼��һ������
        Break;
      end;
      Sleep(500);
    end;
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(38, 42, 617, 531, '���Ͻ�.bmp', clPicOffsetZero,
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
      iRet := FObj.FindStr(211, 128, 774, 540, '�ƽ�粼��|������|�ʼ���',
        StrColorOffset('f7d65a'), 1.0, x, y);
      if iRet > -1 then
      begin
        Sleep(5000);
        CloseGameWindows; // �ȴ�5���ر����д���
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
  FGameData^.RoleInfo := FRoleInfoHandle.GetRoleInfo; // ��������������Ϣ
  if (FGameData^.RoleInfo.MainJob <> mjKuangzhanshi) and
    (FGameData^.RoleInfo.MainJob <> mjYuxuemoshen) and
    (FGameData^.RoleInfo.MainJob <> mjSilingshushi) and
    (FGameData^.RoleInfo.MainJob <> mjLinghunshougezhe)
  then
    warnning;
  // �ȼ����
  if FGameData^.RoleInfo.Lv <= 50 then
    warnning;
  // �ȼ��ϴ���������õ�ͼ�ȼ�
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
    if IsWeakInMap then // ͼ����������
      warnning;
    if FSkill.ReleaseHelperSkill then // �ͷŸ�������
    begin
      swMan.Stop; // �ͷż���ҲҪֹͣ��ʱ
      swMan.Reset;
    end;
    if FGoods.IsArrivedGoods then // ������Ʒ����
    begin
      FGoods.PickupGoods;
      swMan.Stop; // ����ֹͣ��ʱ
      swMan.Reset;
    end;

    ptMan := GetManPoint;
    if not ptMan.IsZero then
    begin
      // �������һ����ͬ,����ʱ��Ƚ�
      // ----------------------
      if ptOldMan = ptMan then
      begin
        if swMan.IsRunning then
        begin
          if swMan.ElapsedMilliseconds > 1000 * 5 then // 3��λ��û���������ƶ�
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
      ptOldMan := ptMan; // ��¼����
      // ---------------------------------
      FMonster.ManPoint := ptMan;
      if FMonster.IsArriviedMonster(ptMonster) then
      begin
        // ��������

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
        swMan.Stop; // �������ֹͣ�����ʱ
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
            if swMonster.ElapsedMilliseconds >= 1000 * 4 then // ��ʱû�ҵ�����Ѱ��
            begin
              FMove.MoveToFindMonster(ptMan, OldMiniMap); // Ѱ��
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
  OldMiniMap := FMap.MiniMap; // ��¼�µ�ǰ�ĵ�ͼ
  swPickupGoods := TStopwatch.StartNew;
  swMan := TStopwatch.Create;
  ptOldMan := TPoint.Zero;
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    NewMiniMap := FMap.MiniMap;
    if NewMiniMap in [mmUnknown, mmPassGame, mmClickCards] then
      Break;
    if OldMiniMap <> NewMiniMap then // ����ͼ�Ƿ�仯
      Break;
    if FDoor.IsClose then // ���Ѿ��ر�������
      Break;
    CloseGameWindows;
    HpHandle;
    if IsWeakInMap then
      warnning;
    if FGoods.IsArrivedGoods then // ������Ʒ����
      FGoods.PickupGoods;
    ptMan := GetManPoint;
    if not ptMan.IsZero then
    begin
      // �������һ����ͬ,����ʱ��Ƚ�
      // ----------------------------
      if ptOldMan = ptMan then
      begin
        if swMan.IsRunning then
        begin
          if swMan.ElapsedMilliseconds > 1000 * 5 then // 3��λ��û���������ƶ�
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
      ptOldMan := ptMan; // ��¼����
      // -------------------
      bIsExistGoods := FGoods.IsExistGoods;
      if bIsExistGoods then // ��Ʒ���ڽ��м���
      begin
        bIsOutTime := swPickupGoods.ElapsedMilliseconds > 1000 * 10;
        if not bIsOutTime then // �����Ʒ����ʱ��
        begin
          FGoods.ManPoint := ptMan; // ������������������ȡ�������
          ptGoods := FGoods.Point;
          FMove.MoveToGoods(ptMan, ptGoods, OldMiniMap);
        end;
      end;
      if (not bIsExistGoods) or (bIsOutTime) then
      begin
        FDoor.ManPoint := ptMan;
        FDoor.MiniMap := OldMiniMap;
        if FDoor.IsArrviedDoor then // �����Ž���
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
    // ���ͻ����Ƿ����
    hGame := FObj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if hGame = 0 then
      warnning;
    // �������״̬
    iRet := FObj.FindStr(0, 0, 800, 600, '���������ж�', clStrWhite, 1.0, x, y);
    if iRet > -1 then
      warnning;
    // ��ⴰ�ڼ���״̬
    if FObj.GetWindowState(hGame, 1) = 0 then
      FObj.SetWindowState(hGame, 1);
    Sleep(2000);
  end;
  FCheckTask := nil;
end;

constructor TGame.Create;
begin
  // ��������ʼ������
  New(FGameData);
  FObj := TObjFactory.CreateChargeObj;
  FObj.SetShowErrorMsg(0); // �رյ���
  FGameData.Terminated := False;
  FGameData.Obj := FObj;
  SetGameData(FGameData);
  FMyObj := TObjFactory.CreateMyObj(FObj);
  FGameData.MyObj := FMyObj;
  FGameConfigManager := GlobalContainer.Resolve<IGameConfigManager>;

  FObj.SetDict(0, sDictPath); // �����ֿ�
  FObj.SetPath(sPicPath); // ����·��
  // // �������ù�����

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
  ptMonster := FMonster.Point; // ��ȡ��������
  // ��ʱ��δ��ù����������Ѱ��
  if FCheckTimeOut.IsMonsterFindTimeOut(ptMonster) then
  begin
    FMove.StopMove;
    FMove.MoveToFindMonster(aManPoint, aMiniMap);
    LongTimeNoMoveHandle(aManPoint);
    Exit;
  end;
  // �ƶ������
  if not ptMonster.IsZero then
  begin
    if FMonster.IsArriviedMonster(ptMonsterArrived) then
    begin
      // ��������
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
      // �ﵽ����ɱ��
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
  // 10s����
  if not FCheckTimeOut.IsInMapPickupGoodsOpenedTimeOut(aMiniMap) then
  begin
    FGoods.ManPoint := aManPoint; // �������������Ʒ����
    ptGoods := FGoods.Point; // ��ȡ��Ʒ����
    if not ptGoods.IsZero then
    begin
      // ����Ʒ������Ʒ,������ִ�н���
      FMove.MoveToGoods(aManPoint, ptGoods, aMiniMap);
      LongTimeNoMoveHandle(aManPoint);
      FCheckTimeOut.ResetManStopWatch;
      Exit;
    end;
  end;
  // ��ʱ����
  FDoor.ManPoint := aManPoint;
  FDoor.MiniMap := aMiniMap;
  if FDoor.IsArrviedDoor then // ������,����
  begin
    FMove.StopMove;
    FMove.MoveInDoor(FDoor.KeyCode);
  end
  else
  begin
    ptDoor := FDoor.Point; // ���������
    if not ptDoor.IsZero then
    begin
      FMove.MoveToDoor(aManPoint, ptDoor, aMiniMap); // ����
    end;
    LongTimeNoMoveHandle(aManPoint);
    FCheckTimeOut.ResetManStopWatch;
  end;

end;

procedure TGame.DoOutMapTask;
var
  ChangeRoleTask, GotoInMapTask, weakTask: ITask;
begin
  FMove.StopMove; // ֹͣ�ƶ�
  FObj.KeyPressChar('esc'); // ��ֹ����������,�������񴰿�
  Sleep(200);
  CloseGameWindows; // �ٴιر����д���
  FMove.StopMove; // ֹͣ�ƶ�
  while not Terminated do
  begin
    TTask.CurrentTask.CheckCanceled;
    if FMap.LargeMap <> lmOut then // ����ͼ������
      Break;
    CloseGameWindows; // �ر����д���
    // �������еȴ�
    if IsWeak then
    begin
      // ������ҵ
      weakTask := TTask.Run(DoWeakTask);
      if not weakTask.Wait(1000 * 60 * 8) then // �ȴ���ҵ���
      begin
        weakTask.Cancel;
        warnning;
      end;
    end
    else
    begin
      // ���������ƣ��
      if not IsHavePilao then
      begin
        // ��ʼ����ɫ��ҵ,���ȴ����
        ChangeRoleTask := TTask.Run(DoChangeRoleTask);
        if not ChangeRoleTask.Wait(1000 * 60 * 2) then
        begin
          ChangeRoleTask.Cancel;
          warnning;
        end;
      end
      else
      begin
        // ��ʼ��ͼ��ҵ,���ȴ����
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
    if FMap.LargeMap <> lmOut then // ����ͼ������
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
// ����Ϸ
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if Result = 0 then
      raise EGame.Create('no game running');
    iBind := Obj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if iBind <> 1 then
      raise EGame.Create('bind game error');
    Obj.SetWindowState(Result, 1); // ������Ϸ����
  end;

begin
  try
    try
      CodeSite.Send('start to run');
      CoInitializeEx(nil, 0); // ��ʼ��Com��
      FGameData^.GameConfig := FGameConfigManager.Config; // ��ȡ�����ļ�
      FGameData.Terminated := False;
      FGameData^.Hwnd := BindGame; // ������Ϸ���ھ��
      CreateGameObjs(FGameData); // ������Ҫʹ�õĶ���
      LoopHandle; // ѭ������
    except
      on E: EGame do
      begin
        Application.MessageBox(PWideChar(E.Message), '����');
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
    // ���������ҵ ,���ú��ƺ�������ȷִ��
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
  if not task.Wait(1000 * 4) then // �ȴ�4�뻹��δ��ý�������ƶ�
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
  // �򿪴��ͼ
  procedure OpenLargeMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(2, 4, 108, 48, '���ͼ.bmp', clPicOffsetZero,
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
// �ƶ�����ͼ����
  procedure MoveToNearMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(336, 444, 358, 467, '��ָ��.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        // ����Ŀ�ĵ�
        Break;
      end
      else
      begin
        // δ���������һ�
        FObj.MoveTo(346, 454);
        Sleep(200);
        FObj.RightClick;
        Sleep(2000);
        MoveToFixPoint;
      end;
    end;
  end;

// �����ͼ
  procedure DoInMap;
  begin
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      // ���ִ���
      iRet := FObj.FindStr(696, 538, 790, 566, '���س���',
        StrColorOffset('ddc593'), 1.0, x, y);
      if iRet > -1 then
      begin
        FObj.KeyUpChar('right'); // �����Ҽ�
        Sleep(1000);
        Break;
      end
      else
      begin
        // δ���ִ�
        FObj.KeyDownChar('right');
        Sleep(1000);
      end;
    end;
  end;
// ѡ����Χ
  procedure SelectMap;
  begin
    // ���뵽��ѡͼλ��
    while (not Terminated) do
    begin
      TTask.CurrentTask.CheckCanceled;
      iRet := FObj.FindPic(8, 269, 230, 470, '������Χ(δѡ��).bmp',
        clPicOffsetZero, 0.9, 0, x, y);
      // �����δѡ��״̬
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
        iRet := FObj.FindPic(8, 269, 230, 470, '������Χ(ѡ��).bmp',
          clPicOffsetZero, 0.9, 0, x, y);
        // �����ѡ��״̬
        if iRet > -1 then
        begin
          // ���õ�ͼ�ȼ�
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
        '��ͨ.bmp|ð��.bmp|��ʿ.bmp|����.bmp', clPicOffsetZero, 0.9, 0, x, y);
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
    Application.MessageBox(PChar('Ӳ����������ʧ��,������:' + iRet.ToString), '����');
    Application.Terminate;
  end;
  iRet := Obj.DmGuard(1, 'f1');
  if iRet <> 1 then
  begin
    Application.MessageBox(PChar('f1�ܿ���ʧ��,������:' + iRet.ToString), '����');
    Application.Terminate;
  end;
  ChDir(sPath);
  iRet := Obj.DmGuard(1, 'block');
  if iRet <> 1 then
  begin
    Application.MessageBox(PChar('block��������ʧ��,������:' + iRet.ToString), '����');
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
    iRet := FObj.FindPic(80, 553, 270, 592, '����HPҩ��.bmp', clPicOffsetZero,
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
      FMove.StopMove; // ֹͣ�ƶ�
    mmClickCards:
      begin
        FPassGame.ClickCards; // ����
      end;
    mmPassGame:
      begin
        FPassGame.EndSell; // �����
        FSkill.RestetSkills; // ���ü���
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
    if FCheckTimeOut.IsManMoveTimeOut(aManPoint) then // ����������곤ʱ��û�б仯,˵����λ��
    begin
      FMove.StopMove;
      FSkill.DestroyBarrier; // �ƻ�һ���ϰ�
      FMove.RandomMove; // ����ƶ�
    end;
  end;
end;

procedure TGame.LoopHandle;
var
  aLargeMap: TLargeMap;
begin
  CloseGameWindows; // �ر����д���
  FGameData^.RoleInfo := FRoleInfoHandle.GetRoleInfo; // ��ȡ��ɫ��Ϣ,��ȡʧ���׳��쳣
  if FGameData.RoleInfo.Lv <= 50 then
    raise EGame.Create('Lv too low');
  if FGameData.GameConfig.bVIP then // �������������ֵ���ɫ
    FGameData.ManStrColor := clVip
  else
    FGameData.ManStrColor := clStrWhite;
  FCheckTask := TTask.Run(CheckTask); // ���м������
  while (not Terminated) do
  begin
    try
      TTask.CurrentTask.CheckCanceled; // ���
      aLargeMap := FMap.LargeMap; // ��ȡ���ͼ

      case aLargeMap of
        lmUnknown:
          UnknownMapHandle; // δ֪ͼ����
        lmOut:
          OutMapHandle; // ͼ�ڲ���
        lmIn:
          InMapHandle; // ͼ�ڲ���
      end;
      Sleep(GameData.GameConfig.iLoopDelay); // ѭ����ʱ
    except
      on E: EInvalidOp do // �����������
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
  if not OutMapTask.Wait(1000 * 60 * 10) then // ��ʱ����
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

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // ���ò��·��
RegisterGameClass;
RegisterServices('Services/Game', [TGameService.Create(IGameService,
  'GameService')]);

finalization

UnregisterServices('Services/Game', ['GameService']);
CleanupGlobalContainer;

end.
