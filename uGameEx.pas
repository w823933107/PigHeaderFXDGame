{
  ���߼���û����������,����һ��ѭ���н���ʵʱ����ж�ִ�е�,
  ����ͨ�غ�Ĳ����ǽ���������,����ִ����ɺ��������ѭ��
}

unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass, QPlugins,
  System.Types;

type

  // ��Ϸ���߼�
  TGame = class(TGamebase)
  private
    FObj: IChargeObj;
    FMyObj: TMyObj;
    FJob: IntPtr;
    FGameData: PGameData;
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
    procedure GameJob(AJob: PQJob); // ���߼���ҵ
    procedure CheckJob(AJob: PQJob); // �����ҵ
    procedure LoopHandle; // ѭ������
    procedure InMapHandle; // ͼ�ڲ���
    procedure OutMapHandle; // ͼ�����
    procedure UnknownMapHandle; // δ֪ͼ����
    procedure CreateGameObjs(aGameData: PGameData); // ��������
    procedure FreeGameObjs;
    procedure DoorClosedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
    procedure DoorOpenedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
  private
    procedure GoToInMap(AJob: PQJob);
    procedure ChangeRole(AJob: PQJob);
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

procedure TGame.ChangeRole(AJob: PQJob);
var
  x, y: OleVariant;
  iRet: Integer;

  procedure SelectMemu;
  begin
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
    oldX := 0;
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
    begin
      iRet := FObj.FindStr(211, 128, 774, 540, '�ƽ�粼��|������|�ʼ���',
        StrColorOffset('f7d65a'), 1.0, x, y);
      if iRet > -1 then
      begin
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
  GameData.RoleInfo := UpdataGameInfo; // ��������������Ϣ
  if (GameData.RoleInfo.MainJob <> mjKuangzhanshi) and
    (GameData.RoleInfo.MainJob <> mjYuxuemoshen) and
    (GameData.RoleInfo.MainJob <> mjSilingshushi) and
    (GameData.RoleInfo.MainJob <> mjLinghunshougezhe)
  then
    warnning;

end;

procedure TGame.CheckJob(AJob: PQJob);
var
  x, y: OleVariant;
  iRet: Integer;
  hGame: Integer;
begin
  while (not Terminated) and (not AJob.IsTerminated) do
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
  // ��������ʼ������
  New(FGameData);
  FObj := TObjFactory.CreateChargeObj;
  FGameData.Obj := FObj;
  GameData := FGameData;
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

procedure TGame.DoorClosedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
var
  ptMan, ptMonster, ptMonsterArrived: TPoint;
begin
  ptMan := aManPoint;
  FMonster.ManPoint := ptMan;
  ptMonster := FMonster.Point; // ��ȡ��������
  // ��ʱ��δ��ù����������Ѱ��
  if FCheckTimeOut.IsMonsterFindTimeOut(ptMonster) then
  begin
    FMove.StopMove;
    FMove.MoveToFindMonster(ptMan, aMiniMap);
    Exit;
  end;
  // �ƶ������
  if not ptMonster.IsZero then
  begin
    if FMonster.IsArriviedMonster(ptMonsterArrived) then
    begin
      // ��������
      if ptMonsterArrived.x < (ptMan.x - 30) then
      begin
        Obj.KeyPressChar('left');
        Sleep(60);
      end
      else
        if ptMonsterArrived.x > (ptMan.x + 30) then
      begin
        Obj.KeyPressChar('right');
        Sleep(60);
      end;

      // �ﵽ����ɱ��
      FMove.StopMove;
      FSkill.ReleaseSkill;
    end
    else
    begin
      FMove.MoveToMonster(ptMan, ptMonster, aMiniMap);
    end;

  end;

end;

procedure TGame.DoorOpenedHandle(aMiniMap: TMiniMap; aManPoint: TPoint);
var
  ptMan, ptDoor, ptGoods: TPoint;
begin
  ptMan := aManPoint;
  // 10s����
  if not FCheckTimeOut.IsInMapPickupGoodsOpenedTimeOut(aMiniMap) then
  begin
    FGoods.ManPoint := ptMan; // �������������Ʒ����
    ptGoods := FGoods.Point;
    if not ptGoods.IsZero then
    begin
      // ����Ʒ������Ʒ,������ִ�н���
      FMove.MoveToGoods(ptMan, ptGoods, aMiniMap);
      Exit;
    end;
  end;
  // ��ʱ����
  FDoor.ManPoint := ptMan;
  FDoor.MiniMap := aMiniMap;
  if FDoor.IsArrviedDoor then // ������,����
  begin
    FMove.StopMove;
    FMove.MoveInDoor(FDoor.KeyCode);
  end
  else
  begin
    ptDoor := FDoor.Point;
    if not ptDoor.IsZero then
    begin
      FMove.MoveToDoor(ptMan, ptDoor, aMiniMap);
    end;
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

procedure TGame.GameJob(AJob: PQJob);
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
      // AJob.Worker.ComNeeded(); // ��ʼ��COM�� ,�ƺ�������֮���޷������˳�������
      FGameData^.GameConfig := FGameConfigManager.Config; // ��ȡ�����ļ�
      FGameData^.Hwnd := BindGame; // ������Ϸ���ھ��
      FGameData^.Job := AJob; // �������̵߳���ҵ����
      CreateGameObjs(FGameData); // ������Ҫʹ�õĶ���
      LoopHandle; // ѭ������
    except
      on E: EGame do
      // MessageBox(0, PWideChar(E.Message), '����', MB_OK);
      begin
        Application.MessageBox(PWideChar(E.Message), '����');
        CodeSite.Send('error operator');
      end;

    end;
  finally
    CodeSite.Send('start to clear ');
    FreeGameObjs;
    // ���������ҵ ,���ú��ƺ�������ȷִ��
  end;
end;

procedure TGame.GoToInMap(AJob: PQJob);
var
  iRet: Integer;
  x, y: OleVariant;
  // �򿪴��ͼ
  procedure OpenLargeMap;
  begin
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
    while (not AJob.IsTerminated) and (not Terminated) do
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
  end;
end;

procedure TGame.InMapHandle;
// ��Ѫ
  procedure HpHandle;
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
    if FCheckTimeOut.IsManFindTimeOut(aManPoint) then // ��������괫�������г�ʱ���
    begin
      FMove.StopMove;
      FMove.RandomMove; // ����ƶ�
      Exit;
    end;
    if not aManPoint.IsZero then
    begin
      if FCheckTimeOut.IsManMoveTimeOut(aManPoint) then // ����������곤ʱ��û�б仯,˵����λ��
      begin
        FMove.StopMove;
        FSkill.DestroyBarrier; // �ƻ�һ���ϰ�
        FMove.RandomMove; // ����ƶ�
      end
      else
        Result := True;
    end;
  end;

  procedure PickupGoods(aMiniMap: TMiniMap);
  begin
   // if not FCheckTimeOut.IsInMapPickupGoodsTimeOut(aMiniMap) then
   // begin
      if FGoods.IsArrivedGoods then
      begin
        FMove.StopMove;
        FGoods.PickupGoods;
      end;
   // end;
  end;

var
  aMiniMap: TMiniMap;
  ptMan: TPoint;
begin
  aMiniMap := FMap.MiniMap; // ��ȡС��ͼ
  case aMiniMap of
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
    CloseGameWindows; // �ر����д���
    HpHandle; // Ѫ����
    FSkill.ReleaseHelperSkill; // �ͷŸ�������
    if not GetManPoint(ptMan) then // ��ȡ��������
    begin
      Exit;
    end;

    // ͼ�ܳ�ʱ��û�б仯��,���б���
    if FCheckTimeOut.IsInMapLongTimeOut(aMiniMap) then
    begin
      warnning;
    end;
    // ��������
    if IsWeak then
    begin
      warnning;
    end;
    PickupGoods(aMiniMap); // ����
    if FDoor.IsOpen then
    begin
      DoorOpenedHandle(aMiniMap, ptMan)
    end
    else
    begin
      DoorClosedHandle(aMiniMap, ptMan);
    end;

  end;

end;

procedure TGame.LoopHandle;
var
  aLargeMap: TLargeMap;
begin
  CloseGameWindows; // �ر����д���
  FGameData.RoleInfo := FRoleInfoHandle.GetRoleInfo; // ��ȡ��ɫ��Ϣ,��ȡʧ���׳��쳣
  if FGameData.GameConfig.bVIP then
    FGameData.ManStrColor := clVip
  else
    FGameData.ManStrColor := clStrWhite;
  Workers.Post(CheckJob, nil); // Ͷ��һ���������
  while (not Terminated) do
  begin

    aLargeMap := FMap.LargeMap; // ��ȡ���ͼ
    if FCheckTimeOut.IsOutMapTimeOut(aLargeMap) then // ����Ƿ���ͼ�ⳬʱ
      warnning;
    case aLargeMap of
      lmUnknown:
        UnknownMapHandle; // δ֪ͼ����
      lmOut:
        OutMapHandle; // ͼ�ڲ���
      lmIn:
        InMapHandle; // ͼ�ڲ���
    end;
    Sleep(GameData.GameConfig.iLoopDelay); // ѭ����ʱ
  end;
end;

procedure TGame.OutMapHandle;
var
  hChangeRole, hGotoInMap: THandle;
begin
  CloseGameWindows; // �ر����д���
  FMove.StopMove;
  // �������еȴ�
  if IsWeak then
  begin
    // warnning;
    Sleep(1000);
  end
  else
  begin
    // ���������ƣ��
    if not IsHavePilao then
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

procedure TGame.Start;
var
  JobState: TQJobState;
begin
  // ��ҵ������ʱִ��
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(GameJob, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.ClearSingleJob(FJob);
  Workers.Clear; // ���������ҵ
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

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // ���ò��·��
RegisterGameClass;
RegisterServices('Services/Game', [TGameService.Create(IGameService,
  'GameService')]);

finalization

UnregisterServices('Services/Game', ['GameService']);
CleanupGlobalContainer;

end.
