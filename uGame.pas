// ��Ϸ���߼�
unit uGame;

interface

uses uGame.Interf, uObj, QWorker, Spring.Container,
  System.SysUtils, Winapi.Windows, System.Types, System.Rtti,
  System.Diagnostics;

// ��Ϸ�����߼���
type
  TGame = class(TGameBase, IGame)
  private
    FJobHwnd: IntPtr;
    // FJob: PQJob;
    // FGameData:TGameData;
    FTerminated: Boolean; // ������Ҫ��һ�� FPTerminated: PBoolean;
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
    procedure CreateObjInterf; // ��������ӿ�
    procedure DestoryObjInterf; // ���ٶ���ӿ�
  private
    procedure MainProc(AJob: PQJob);
    procedure GameInit; // ��Ϸ��ʼ������
    procedure GameLoop; // ��Ϸѭ��
    procedure GameFinal; // ��Ϸ��β������
    procedure GameFinalMust; // ��Ϸ���������ִ�еĲ���,�쳣����Ҳ��Ҫִ��
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindPic(38, 42, 617, 531, '���Ͻ�.bmp', clPicOffsetZero,
        0.8, 0, x, y);
      if iRet > -1 then
      begin
        oldX := x; // ��¼��һ������
        Break;
      end;
      Sleep(500);
    end;
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindStr(211, 128, 774, 540, '�ƽ�粼��|������|�ʼ���',
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
  GameData.RoleInfo := UpdataGameInfo; // ��������������Ϣ
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
end;

constructor TGame.Create;
begin
  FObj := TObjFactory.CreateChargeObj;
  // ����·�����ֿ�
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
    iRet := FObj.FindStr(0, 0, 800, 600, '���������ж�', clStrWhite, 1.0, x, y);
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
      CodeSite.Send('ͼ�����');
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
      CodeSite.Send('ͼ�ڲ���');
      InMapHandle(FMap.MiniMap); // ͼ�ڲ���
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
  Workers.Post(CheckGame, nil); // Ͷ��һ�������ҵ
  while not FTerminated do
  begin
    CodeSite.Send('�߳�������');
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
  // �򿪴��ͼ
  procedure OpenLargeMap;
  begin
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
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
    while not AJob.IsTerminated do
    begin
      iRet := FObj.FindPic(8, 269, 230, 470,
        '��ͨ.bmp|ð��.bmp|��ʿ.bmp|����.bmp', clPicOffsetZero, 0.9, 0, x, y);
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
// �ſ���״̬����
  procedure DoorOpenDo;
  var
    ptMan, ptDoor, ptGoods: TPoint;
  begin
    // ����ͨ�ؽ�����,BOSS�ŵ���ɫҲ����ʾ����,������Ҫ�ж��Ƿ���ɱ�ֹؿ�
    // �ڵ���ͼ�ڳ�ʱ����
    if FCheckTimeOut.IsInMapLongTimeOut(aMiniMap) then
    begin
      warnning;
    end;

    ptMan := FMan.Point;
    // �ƶ���ʱ
    if FCheckTimeOut.IsManMoveTimeOut(ptMan) then
    begin
      CodeSite.Send('�����ƶ���ʱ,��������ƶ�');
      FSkill.DestroyBarrier;
      FMove.RandomMove;
      Exit;
    end;
    // ���ֳ�ʱ
    if FCheckTimeOut.IsManFindTimeOut(ptMan) then
    begin
      CodeSite.Send('���������ȡ��ʱ,ִ������ƶ�');
      FMove.RandomMove;
      Exit;
    end;
    // ����û�г�ʱ
    FGoods.ManPoint := ptMan;
    if not FCheckTimeOut.IsInMapPickupGoodsTimeOut(aMiniMap) then
    begin
      CodeSite.Send('����û�г�ʱ');
      if FGoods.IsArrivedGoods then
      begin
        CodeSite.Send('�ﵽ��Ʒ,����');
        FMove.StopMove;
        FGoods.PickupGoods;
        Exit;
      end
      else
      begin
        CodeSite.Send('û�е�����Ʒ');
        ptGoods := FGoods.Point;
        if not ptGoods.IsZero then
        begin
          CodeSite.Send('������Ʒ');
          FMove.MoveToGoods(ptMan, ptGoods, aMiniMap);
          Exit;
        end;
      end;

    end;

    // �ҵ���������
    if not ptMan.IsZero then
    begin
      // ��ʼ��Doorֻд����
      FDoor.ManPoint := ptMan;
      FDoor.MiniMap := aMiniMap;
      if FDoor.IsArrviedDoor then
      begin
        // ������,ִ�н��Ų���
        CodeSite.Send('�����Ÿ���,ִ�н���');
        FMove.StopMove; // ֹͣ�ƶ�
        FMove.MoveInDoor(FDoor.KeyCode);
        Exit;
      end;

      ptDoor := FDoor.Point;
      if not ptDoor.IsZero then
      begin
        // �ҵ�������,�����ƶ�
        CodeSite.Send('�ѻ�ȡ������,ִ���ƶ�');
        FMove.MoveToDoor(ptMan, ptDoor, aMiniMap);
      end
      else
      begin
        CodeSite.Send('�������ȡʧ��');
      end;
    end;
  end;
// �Źر�״̬����
  procedure DoorCloseDo;
  var
    ptMonster, ptMan: TPoint;
  begin
    // ������ط�ֹͣ�ƶ�
    if (aMiniMap in [mmClickCards, mmPassGame]) then
    begin
      FMove.StopMove;
      Exit;
    end;

    FSkill.ReleaseHelperSkill; // �ͷŸ�������

    ptMan := FMan.Point;
    // ���������Ʒ��һ����Ʒ
    if FGoods.IsArrivedGoods then
    begin
      FMove.StopMove;
      FGoods.PickupGoods;
    end;
    // �ƶ���ʱ
    if FCheckTimeOut.IsManMoveTimeOut(ptMan) then
    begin
      CodeSite.Send('�����ƶ���ʱ,��������ƶ�');
      FSkill.DestroyBarrier; // �ƻ��ϰ���һ��
      FMove.RandomMove;
      Exit;
    end;

    // ���ֳ�ʱ
    if FCheckTimeOut.IsManFindTimeOut(ptMan) then
    begin
      CodeSite.Send('���������ȡ��ʱ,ִ������ƶ�');
      FMove.RandomMove;
      Exit;
    end;
    if not ptMan.IsZero then
    begin
      ptMonster := FMonster.Point;
      if FCheckTimeOut.IsMonsterFindTimeOut(ptMonster) then
      begin
        CodeSite.Send('���������ȡ��ʱ,ִ��Ѱ��');
        FMove.MoveToFindMonster(ptMan, aMiniMap);
        Exit;
      end;
      if not ptMonster.IsZero then
      begin
        // �ҵ�����������ƶ�
        FMonster.ManPoint := ptMan;
        if FMonster.IsArrviedMonster then
        begin
          // �������,ɱ��
          CodeSite.Send('�������,ֹͣ�ƶ�,����ɱ��');
          CodeSite.Write('�Ƿ񵽴����', '��');
          FMove.StopMove; // ֹͣ�ƶ�
          // ��������������﷽��
          // �������
          if GameData.GameConfig.bNearAdjustDirection then
          begin
            if (ptMan.x < ptMonster.x - 80) then
              Obj.KeyPressChar('left')
            else
              if ptMan.x > ptMonster.x + 80 then
              Obj.KeyPressChar('right');
            Sleep(50);
          end;
          FSkill.ReleaseSkill; // ɱ��
        end
        else
        begin
          CodeSite.Write('�Ƿ񵽴����', '��');
          CodeSite.Send('���������ȡ�ɹ�,ִ���������');
          FMove.MoveToMonster(ptMan, ptMonster,
            aMiniMap);
        end;

      end;
    end;

  end;
// ����
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
        '��1.bmp|�ƽ���5.bmp|�ƽ���5Ex.bmp|˫���ƽ���5.bmp', clPicOffsetZero,
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
// ��Ѫ
  procedure AddHp;
  var
    iRet: Integer;
    x, y: OleVariant;
  begin
    iRet := FObj.CmpColor(37, 558, 'bb1111-333333', 1.0);
    if iRet = 1 then
    begin
      iRet := FObj.FindPic(80, 553, 270, 592, '����HPҩ��.bmp', clPicOffsetZero,
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
  // �������ڵ�ͼִ�в���

  CodeSite.Write('����ͼ', TRttiEnumerationType.GetName(aMiniMap));
  CloseGameWindows;
  if not(aMiniMap in [mmUnknown, mmPassGame, mmClickCards]) then
  begin
    AddHp;
    if FDoor.IsOpen then
    begin
      CodeSite.Send('�ſ���ʱ�Ĳ���');
      DoorOpenDo; // �����Ĳ���
    end
    else
    begin
      CodeSite.Send('�Źر�ʱ�Ĳ���');
      DoorCloseDo; // �رյĲ���
    end;
  end
  else
  begin

    FMove.StopMove; // �˴�����Ҫ�ƶ�
    if aMiniMap = mmPassGame then
    begin
      FPassGame.Handle;
      FSkill.RestetSkills; // ���ü���
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
  CodeSite.Send('��ͨ���߳̽�������');
end;

procedure TGame.GameFinalMust;
begin
  CodeSite.Send('�̱߳�����������');
  // �жϴ����Ƿ��ö�
  if FObj.GetWindowState(GameData.Hwnd, 5) = 1 then
    // if GameData.GameConfig.WndState = 1 then
    FObj.SetWindowState(GameData.Hwnd, 9); // ����ȡ���ö�
  DestoryObjInterf;
end;

procedure TGame.GameInit;
  function BindGame: Integer;
  var
    lBind: Integer;
  begin
    Result := FObj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if Result = 0 then
      raise EBindFailed.Create('��Ϸ���ڲ�����!');
    lBind := FObj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if lBind <> 1 then
      raise EBindFailed.CreateFmt('��ʧ��,������:%d', [lBind]);
    // ������ö�����
    case GameData.GameConfig.iWndState of
      0:
        FObj.SetWindowState(Result, 1);
      1:
        begin
          // ���ö�û��Ч��,�����ȼ���һ��
          FObj.SetWindowState(Result, 1);
          FObj.SetWindowState(Result, 8);
        end;
    else
      FObj.SetWindowState(Result, 1); // Ĭ�ϼ���
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
  CreateObjInterf; // ��������ӿ�
  GameData.PTerminated := @FTerminated;
  GameData.Obj := FObj;
  GameData.MyObj := FMyObj;
  GameData.GameConfig := FGameConfigManager.Config; // ����������Ϣ,����������������Ϣ
  GameData.Hwnd := BindGame; // ���ð󶨴��ھ��
  GameData.RoleInfo := UpdataGameInfo; // ���ý�ɫ��Ϣ
  GameData.ManStrColor := UpdataManStrColor;
end;

procedure TGame.MainProc(AJob: PQJob);
begin
  try
    try
      // FJob := AJob;
      CodeSite.Send('��Ϸ�߳�');
      // RegisterGameClass; // ע����Ϸ������
      AJob.Worker.ComNeeded(); // ֧��COM

      GameInit; // ��ʼ����Ϸ
      GameLoop; // ��Ϸѭ��
      GameFinal; // �������
    except
      on E: EBindFailed do
      begin
        MessageBoxW(0, PChar(E.Message), '����', MB_OK + MB_ICONWARNING);
        raise;
      end;
      on E: ERoleInfoFailed do
      begin
        MessageBoxW(0, PChar(E.Message), '����', MB_OK + MB_ICONWARNING);
        raise;
      end;
      else
        raise;
    end;
  finally
    GameFinalMust; // ������е��������
    // UnregisterGameClass; // ж�ع���
    FIsRunning := False;
    FTerminated := False;
    CodeSite.Send('�߳��ѽ���');
  end;

end;

procedure TGame.OutMapHandle;
// �Ƿ�����
  function IsWeak: Boolean;
  var
    x, y: OleVariant;
    iRet: Integer;
  begin
    iRet := Obj.FindPic(242, 488, 800, 569, '����.bmp', clPicOffsetZero,
      0.9, 0, x, y);
    Result := iRet > -1;
  end;

var
  hGotoInMap, hChangeRole: IntPtr;
begin
  CloseGameWindows;
  FMove.StopMove; // ֹͣ�ƶ�
  // �������еȴ�
  if IsWeak then
  begin
    // warnning;
    Sleep(1000);
  end
  else
  begin
    // ���������ƣ��
    if IsNotHasPilao then
    begin
      // Ͷ�Ļ���ɫ��ҵ,���ȴ����
      hChangeRole := Workers.Post(ChangeRole, nil);
      if Workers.WaitJob(hChangeRole, 1000 * 60 * 2, False) = wrTimeout then
      begin
        Workers.ClearSingleJob(hChangeRole); // �ȴ����,������ֹͣ
        warnning;
      end;
    end
    else
    begin
      // Ͷ�Ľ�ͼ��ҵ,���ȴ����
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
  // FJobHwnd := Workers.Post(MainProc, nil); // Ͷ����Ϸ��Ҫ����
  // end
  // else
  // begin
  // MessageBoxW(0, '������������,��ȴ�ֹͣ���ٴ�����!', '����', MB_OK + MB_ICONWARNING);
  // Exit;
  // end;

  CodeSite.Send('start');
  if FIsRunning and (not Terminated) then // �������˳�
  begin
    MessageBoxW(0, '������������,��ȴ�ֹͣ���ٴ�����!', '����', MB_OK + MB_ICONWARNING);
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
