// ��������Ԫ
unit uGameEx.Interf;

interface

uses uObj, System.SysUtils, QWorker, System.Types, Spring,
  CodeSiteLogging, System.Threading, System.SyncObjs;

const
  // ·������
  sDictPath = '.\Dict\Main.txt'; // �����õ��ֿ�·�������õ�ͼƬΪȫ��·��
  sPicPath = '.\Pic'; // ͼƬ·��
  sConfigPath = '.\Config\Config.txt'; // �����ļ�·��
  // ����ֵ
  clWndActive = 'ffffff-000100'; // ���ڵ��ö���ɫֵ
  clWndNoActive = 'aaaaaa-000100'; // ����δ�ö���ɫֵ
  clWndOpen = 'ffffff-000100|aaaaaa-000100'; // ���ڴ򿪵���ɫֵ
  clStrWhite = 'ffffff-000100';
  clStrOffsetZero = '-000100';
  clPicOffsetZero = '000100';
  clVip = 'fadc64-000100'; // ������ɫ
  clNoVip = clStrWhite; // �Ǻ�����ɫ
  // ����״̬
  wsActive = 0;
  wsTop = 1;
  // ��Ϸ����
  gdLeft = 37;
  gdRight = 39;
  gdUp = 38;
  gdDown = 40;
  // ְҵ����
  mjKuangzhanshi = '��սʿ';
  mjYuxuemoshen = '��Ѫħ��';
  mjSilingshushi = '������ʿ';
  mjLinghunshougezhe = '����ո���';

type
  EGame = Exception;

  IFormService = interface
    ['{B44D6B79-9508-45A7-90E9-392074533F5D}']
    function ShowModal: Integer;
    procedure Show;
  end;

  IGameService = interface
    ['{2BE5BFB6-1647-461E-A668-F34A3331FBAC}']
    procedure Prepare;
    procedure Start;
    procedure Stop;
    function Guard(): Boolean;
    procedure SetHandle(const aHandle: THandle);
  end;

  TCreateForm = function(aHandle: THandle): IFormService;
  TCreateGameService = function: IGameService;

  TRectHelper = record helper for TRect
    procedure DmNormalizeRect;
  end;

  // ��Ϸ����
  TGameConfig = record
    iWndState: Integer; // ����״̬
    iLoopDelay: Integer; // ѭ����ʱ,����CPUռ����
    bVIP: Boolean; // ����
    iPickUpGoodsTimeOut: Integer; // ���ﳬʱ
    iFindManTimeOut: Integer; // ���˳�ʱ
    iManMoveTimeOut: Integer; // �����ƶ�����,���翨�ϰ���
    iFindMonsterTimeOut: Integer; // �ҹֳ�ʱ
    iGetInfoTimeOut: Integer; // ��ȡ��ɫ��Ϣ��ʱʱ��
    sMoveGoodsKeyCode: string; // �ƶ���Ʒ����
    imaxZhuangbeiNum: Integer; // �����ٷֱ�
    iResetMoveStateInterval: Integer; // �����ƶ�״̬�ļ��
    bResetMoveState: Boolean; // �Ƿ������ƶ�ʱ��
    bRepair: Boolean; // �Ƿ��޸�װ��
    iInMapTimeOut: Integer; // ��ͼ�ڳ�ʱ
    iKuangzhanOffsetY: Integer; // ��սYƫ��
    iSilingOffsetY: Integer; // ����Yƫ��
    bNearAdjustDirection: Boolean; // �����ֵ�������
    bJiabaliWarning: Boolean;
    bWarning: Boolean;
    iMapLv: Integer;
    bLogView: Boolean;
    // ��������
    // ��ս����
    slBengshanji,
      slShizizhan,
      slBengshanliedizhan,
      slNuqibaofa,
      slXuezhikuangbao,
      slSiwangkangju,
      slBaozou,
      slMiehunzhishou,
      slShihunzhishou,
      slXueqizhiren,
    // ���鼼��
    slBaiguiyexing,
      slSilingzhifu,
      slQushijiangshi,
      slBalakedeyexin,
      slNigulasi,
      slBaojunbalake,
      slSilingzhiyuan,
      slSiwangzhizhua,
      slBalakedefennu,
      slAnyingzhizhusi,
      slAnheiyishi,
      slJiangshilaidiya,
      slShaluluanwu
      : string;
    class function Create: TGameConfig; static;
  end;

  // �ֺ�ƫ��
  TStrOffset = record
    str: string;
    OffsetX: Integer;
  end;

  PRoleInfo = ^TRoleInfo;

  TRoleInfo = record
    Name: string;
    NameWithDec: string;
    MainJob: string;
    // ��ְҵ���
    ExpertJob: string; // ��ְҵ
    ExpertJobLv: Cardinal; // ��ְҵ�ȼ�
    ExpertJobCurExp: Cardinal; // ��ְҵ��ǰ����
    ExpertJobMaxExp: Cardinal; // ��ְҵ�����
    Lv: Integer; // �ȼ�
    // �������ĵ�ƫ��
    CenterXOffset: TArray<TStrOffset>; // x��ƫ������
    CenterYOffset: Integer; // y��ƫ��
  end;

  PGameData = ^TGameData;

  TGameData = record
    Obj: IChargeObj;
    MyObj: TMyObj;
    Hwnd: Integer; // ���ھ��
    GameConfig: TGameConfig;
    RoleInfo: TRoleInfo;
    ManStrColor: string; // ����������ɫ
    Terminated: Boolean;
  end;

  TGameDirectionLR = (
    gdUpLeftAndRight, // ��������
    gdDownLeft, // ������
    gdDownRight // ������
    );
  TGameDirectionUD = (
    gdUpUpAndDown, // ��������
    gdDownUp, // ������
    gdDownDown // ������
    );

  TGameDirections = record
    LR: TGameDirectionLR; // ����
    UD: TGameDirectionUD; // ����
  end;

  TLargeMap = (lmUnknown, lmOut, lmIn);
  TMiniMap = (
    mmUnknown, // δ֪ͼ
    mmBoss, // Bossͼ
    mmClickCards, // ����ͼ
    mmPassGame, // ͨ��ͼ
    mmMain1,
    mmMain2,
    mmMain3,
    mmMain4,
    mmMain5,
    mmMain6,
    // �����������ߵ�ͼ �ӵ�һͼ��������
    mmOther1,
    mmOther2,
    mmOther3,
    mmOther4
    );

  IGameConfigManager = interface
    ['{5529F901-CBCB-4C16-91CF-B96C314AAB79}']
    procedure SetFileName(aFileName: string);
    procedure SetConfig(const aGameConfig: TGameConfig);
    function GetConfig(): TGameConfig;

    property FileName: string write SetFileName;
    property Config: TGameConfig read GetConfig write SetConfig;
  end;

  IGameBase = interface
    ['{5CC9C6B8-BC5B-4313-84C6-AE82751781AA}']
    procedure SetGameData(aGameData: PGameData);
  end;

  // �����Բ������,����֧�ֲ�����
  TGameBase = class(TInterfacedObject)
  private
    class var FLock: TCriticalSection;
    class constructor Create();
    class destructor Destroy;
  private
    FGameData: PGameData;
    function GetObj: IChargeObj;
    function GetTerminated: Boolean;
    function GetMyObj: TMyObj;
  protected

    // ����
    procedure Warnning;
    // �رմ���
    procedure CloseGameWindows;
    // �ƶ����̶���
    procedure MoveToFixPoint;
    // ����ƫɫ,���������-�Ͳ�������
    function StrColorOffset(color: string): string;
    // ������Ϸȫ������
    procedure SetGameData(aGameData: PGameData); virtual;
    // �Ƿ���ƣ��
    function IsHavePilao: Boolean;
    function IsWeak: Boolean;
    function IsWeakInMap: Boolean;
  public
    property Terminated: Boolean read GetTerminated; // ���߳��Ƿ�Ҫ����ֹ
    property GameData: PGameData read FGameData write SetGameData; // ȫ����Ϣ
    property MyObj: TMyObj read GetMyObj;
    property Obj: IChargeObj read GetObj;
  end;

  // ---------------һ��Ϊ��Ϸ��Ҫ�Ļ����ӿ�---------------------

  // ��ɫ��Ϣ����ӿ�,������ȡ��ɫ��Ϣ
  IRoleInfoHandle = interface(IGameBase)
    ['{196BF2CF-20C9-49A4-8A73-61F03EF830A7}']
    function GetRoleInfo: TRoleInfo;
  end;

  IMap = interface(IGameBase)
    ['{A04EE806-211B-4C99-B8A1-171E793E6486}']
    function GetLargeMap: TLargeMap;
    function GetMiniMap: TMiniMap;

    property LargeMap: TLargeMap read GetLargeMap;
    property MiniMap: TMiniMap read GetMiniMap;
  end;

  IMan = interface(IGameBase)
    ['{D8B2AA51-B8CC-4930-8F59-958C669AC5F3}']
    function GetPoint: TPoint;
    function GetRect: TRect;
    property Point: TPoint read GetPoint;
    property Rect: TRect read GetRect;

  end;

  IMonster = interface(IGameBase)
    ['{703DD800-3F05-4626-87FF-733092C7F2D4}']
    function GetPoint: TPoint;
    procedure SetManPoint(const value: TPoint);
    function GetIsExistMonster: Boolean;
    // function GetIsArriviedMonster: Boolean;

    function IsArriviedMonster(var aMonsterPoint: TPoint): Boolean;
    property ManPoint: TPoint write SetManPoint; // Ѱ�ҹ�����������������
    // property IsArrviedMonster: Boolean read GetIsArriviedMonster;
    property IsExistMonster: Boolean read GetIsExistMonster;
    property Point: TPoint read GetPoint;

  end;

  IDoor = interface(IGameBase)
    ['{9D2AD64F-AB22-44B3-8E75-5DF71746F99D}']
    function GetIsOpen: Boolean;
    function GetPoint: TPoint;
    function GetKeyCode: Integer;
    procedure SetMiniMap(const value: TMiniMap);
    function GetIsArrviedDoor: Boolean;
    procedure SetManPoint(const value: TPoint);

    property ManPoint: TPoint write SetManPoint;
    property MiniMap: TMiniMap write SetMiniMap;
    property IsArrviedDoor: Boolean read GetIsArrviedDoor;
    property KeyCode: Integer read GetKeyCode; // ����
    property Point: TPoint read GetPoint;
    property IsOpen: Boolean read GetIsOpen;
  end;

  IMove = interface;

  IDirections = interface(IGameBase)
    ['{0D3C96E4-81E9-4FF6-AA0C-0DEAB0A79731}']
    // procedure SetMove(const value: IMove);

    // ��ȡ���������Ҫ�ķ���
    function GetMonsterDirections(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // ��ȡѰ�ҹ�����Ҫ�ķ���
    function GetFindMonsterDirections(const aManPoint: TPoint;
      aMiniMap: TMiniMap): TGameDirections;
    // ��ȡ��������Ҫ�ķ���
    function GetDoorDirections(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // ��ȡ������Ʒ��Ҫ�ķ���
    function GetGoodsDirections(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // property Move: IMove write SetMove;

  end;

  IMove = interface(IGameBase)
    ['{6906F8ED-0F14-4D25-8BA3-379A99BCA1C3}']
    procedure Reset; // �ָ�����״̬,��ֹ����
    procedure MoveToLeft;
    procedure MoveToRight;
    procedure MoveToUp;
    procedure MoveToDown;
    procedure StopMoveLR;
    procedure StopMoveUD;
    procedure StopMove;
    procedure Move(const aGameDirectios: TGameDirections);

    procedure RandomMove;
    procedure MoveToFindMonster(const aManPoint: TPoint;
      const aMiniMap: TMiniMap);
    procedure MoveToMonster(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap); // �������
    procedure MoveToDoor(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap); // ������
    procedure MoveInDoor(const aKeyCode: Integer); // ����
    procedure MoveToGoods(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap);
  end;

  ISkill = interface(IGameBase)
    ['{7A45559A-E38C-4352-AC0E-56E765D701E5}']
    procedure RestetSkills; // ��ʼ����������
    procedure ReleaseSkill;
    procedure DestroyBarrier; // �ƻ��ϰ�
    function ReleaseHelperSkill: Boolean; // ��������,û�е������Ҳ�����ͷŵļ���
  end;

  IGoods = interface(IGameBase)
    ['{466FEC32-366D-4AD0-B2EE-D0014B4C3C0E}']
    procedure SetManPoint(const value: TPoint);
    function GetPoint: TPoint;
    function GetIsArrivedGoods: Boolean;
    function GetIsExistGoods: Boolean;

    property ManPoint: TPoint write SetManPoint;
    property Point: TPoint read GetPoint;
    property IsArrivedGoods: Boolean read GetIsArrivedGoods; // ��������ɫʶ���Ƿ񵽴���Ʒ��
    property IsExistGoods: Boolean read GetIsExistGoods;
    procedure PickupGoods;
  end;

  ICheckTimeOut = interface(IGameBase)
    ['{83AA4347-B0AC-472F-A60E-E5E66156E003}']
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean;
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;
    function IsInMapPickupGoodsOpenedTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsOutMapTimeOut(const aLargeMap: TLargeMap): Boolean;
    function CompareDoorState(aDoorState: Boolean): Boolean; // ����ŵ�״̬,�ڲ��������ü�ʱ��
    function CompareMiniMap(const aMiniMap: TMiniMap): Boolean; // �Ƚ�С��ͼ�Ƿ���ͬ
    procedure ResetManStopWatch;
    procedure ResetOutMapStopWatch;
  end;

  TZhuangbeiType = (ztδ֪, zt��ͨ, zt�߼�, ztϡ��, zt����, zt����, zt����, zt��˵, ztʷʫ);

  IBox = interface(IGameBase)
    ['{B21ED922-69DD-49EA-A5EA-8870A2221014}']
    function GetBasePoint: TPoint;
    function GetPoints: Vector<TPoint>;
    function Open: Boolean;
    function Close: Boolean;
    function OpenZhuangbei: Boolean;
    procedure ZhengLi;
    function GetZhuangbeiType: TZhuangbeiType;
    function IsFuZhong: Boolean;
    function IsFengZhuang: Boolean;
    function IsHaveZhuangbei: Boolean;
    function GetIsfuzhongByPic: Boolean;
    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // ��ȡװ���ٷֱ�
    function GetZhuangbeiPercentage: Integer;
  end;

  IPassGame = interface(IGameBase)
    ['{77EF1605-C3C3-4D5B-863E-83564AF35D52}']
    procedure EndSell;
    procedure ClickCards;
  end;

  IOutMap = interface(IGameBase)
    ['{087DE172-B582-49F8-8CCD-D2F81055C6AE}']
    procedure Handle;
  end;

implementation


{ TGameConfig }

class function TGameConfig.Create: TGameConfig;
begin
  Result.iWndState := 0;
  Result.iLoopDelay := 20;
  Result.bVIP := True;
  Result.slBengshanji := 's';
  Result.slShizizhan := 'a';
  Result.slBengshanliedizhan := 'd';
  Result.slNuqibaofa := 'g';
  Result.slXuezhikuangbao := 'y';
  Result.slSiwangkangju := 't';
  Result.slBaozou := 'r';
  Result.slMiehunzhishou := 'e';
  Result.slShihunzhishou := 'q';
  Result.slXueqizhiren := 'w';
  Result.bVIP := True;
  Result.iPickUpGoodsTimeOut := 1000 * 10; // 10s
  Result.iFindManTimeOut := 3000; // 3s
  Result.iManMoveTimeOut := 6000; // 6s
  Result.iFindMonsterTimeOut := 3000; // 3s
  Result.iGetInfoTimeOut := 1000 * 30; // 30s
  Result.sMoveGoodsKeyCode := '3';
  Result.imaxZhuangbeiNum := 70;
  Result.iResetMoveStateInterval := 3000 * 10; // 30s
  Result.bResetMoveState := True;
  Result.bRepair := False;
  Result.iInMapTimeOut := 1000 * 60 * 3; // 3m
  Result.slBaiguiyexing := 'q';
  Result.slSilingzhifu := 'w';
  Result.slBalakedeyexin := 'e';
  Result.slQushijiangshi := 'r';
  Result.slNigulasi := 't';
  Result.slBaojunbalake := 'y';
  Result.slSilingzhiyuan := 'a';
  Result.slSiwangzhizhua := 's';
  Result.slBalakedefennu := 'd';
  Result.slAnyingzhizhusi := 'f';
  Result.slAnheiyishi := 'g';
  Result.slJiangshilaidiya := 'h';
  Result.slShaluluanwu := 'z';
  Result.iKuangzhanOffsetY := 172;
  Result.iSilingOffsetY := 178;
  Result.bNearAdjustDirection := True;
  Result.bJiabaliWarning := False;
  Result.bWarning := True;
  Result.iMapLv := 1;
  Result.bLogView := False;
end;

{ TGameBase }

procedure TGameBase.CloseGameWindows;
var
  hJob: THandle;
  task: ITask;
begin
  task := TTask.Run(
    procedure
    var
      iRet: Integer;
      x, y: OleVariant;
    begin
      while not Terminated do
      begin
        TTask.CurrentTask.CheckCanceled;
        iRet := Obj.FindStr(0, 0, 800, 600, '���������ж�', clStrWhite, 1.0, x, y);
        if iRet > -1 then // ����������ж���ô��ִ�йرմ���
          break;
        iRet := Obj.FindStr(0, 0, 800, 600, '�ر�|���س���', StrColorOffset('ddc593'),
          1.0, x, y);
        if iRet > -1 then
        begin
          Obj.MoveTo(x, y);
          sleep(100);
          Obj.LeftClick;
          sleep(200);
          MoveToFixPoint;
          continue;
        end;
        iRet := Obj.FindPic(0, 0, 800, 600, '��.bmp|��(С).bmp', clPicOffsetZero,
          0.9,
          0, x, y);
        if iRet > -1 then
        begin
          Obj.MoveTo(x, y);
          sleep(100);
          Obj.LeftClick;
          sleep(200);
          MoveToFixPoint;
          continue;
        end;
        break;
      end;

    end);
  if not task.Wait(1000 * 60) then
    task.Cancel;
end;

class constructor TGameBase.Create;
begin
  TGameBase.FLock := TCriticalSection.Create;
end;

class destructor TGameBase.Destroy;
begin
  TGameBase.FLock.Free;
end;

function TGameBase.GetMyObj: TMyObj;
begin
  Result := FGameData^.MyObj;
end;

function TGameBase.GetObj: IChargeObj;
begin
  Result := FGameData^.Obj;
end;

function TGameBase.GetTerminated: Boolean;
begin
  Result := FGameData.Terminated;
end;

function TGameBase.IsHavePilao: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  iRet := Obj.FindPic(297, 545, 423, 565, '��ƣ��.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  Result := iRet = -1; // �Ҳ���û��ƣ�͵�ͼƬ���滹��ƣ��

end;

function TGameBase.IsWeak: Boolean;
var
  x, y: OleVariant;
  iRet: Integer;
begin
  Result := False;
  CloseGameWindows;
  iRet := Obj.FindPic(242, 488, 800, 569, '����.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  if iRet > -1 then
    Result := True
  else
  begin
    iRet := Obj.FindStr(9, 514, 67, 577, '100', clStrWhite, 1.0, x, y);
    Result := iRet = -1;
  end;
end;

function TGameBase.IsWeakInMap: Boolean;
var
  x, y: OleVariant;
  iRet: Integer;
begin
  Result := False;
  iRet := Obj.FindPic(242, 488, 800, 569, '����.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  Result := iRet > -1;

end;

procedure TGameBase.MoveToFixPoint;
begin
  Obj.MoveTo(5, 592);
  Obj.Delays(100, 120);
  Obj.LeftClick;
  Obj.Delays(150, 180);
end;

procedure TGameBase.SetGameData(aGameData: PGameData);
begin
  FGameData := aGameData;
end;

function TGameBase.StrColorOffset(color: string): string;
begin
  if not color.Contains('-') then
    Result := color + clStrOffsetZero;
end;

procedure TGameBase.Warnning;
var
  task: ITask;
begin
  FLock.Acquire;
  task := TTask.Run(
    procedure
    var
      hPlay: THandle;
      sw, swLong: TStopWatch;

    begin
      if GameData.GameConfig.bWarning then
      begin
        hPlay := Obj.Play('wife.mp3');
        sw := TStopWatch.StartNew; // ��ʱ
        swLong := TStopWatch.StartNew;
        while (not Terminated) do
        begin
          TTask.CurrentTask.CheckCanceled;
          if swLong.ElapsedMilliseconds >= (1000 * 60 * 10) then
          begin
            Obj.Stop(hPlay); // ����10����ֹͣ����
            sleep(100);
            break;
          end;
          if sw.ElapsedMilliseconds >= (1000 * 60 * 3) then
          begin
            Obj.Stop(hPlay);
            sleep(100);
            hPlay := Obj.Play('wife.mp3');
            sw.Reset; // ����
          end;
          sleep(500);
        end;
        sleep(200);
        Obj.Stop(hPlay);
      end
      else
      begin
        while not Terminated do
        begin
          sleep(1000);
          TTask.CurrentTask.CheckCanceled;
        end;
      end;
    end);
  task.Wait();
  FLock.Release;
end;

{ TRectHelper }

procedure TRectHelper.DmNormalizeRect;
begin
  if Left < 0 then
    Left := 0;
  if Left >= 800 then
    Left := 800 - 10;
  if Right <= 0 then
    Right := 0 + 10;
  if Right > 800 then
    Right := 800;
  if Top < 0 then
    Top := 0;
  if Top >= 600 then
    Top := 600 - 10;
  if Bottom <= 0 then
    Bottom := 0 + 10;
  if Bottom > 600 then
    Bottom := 600;
  NormalizeRect; // ���滯
end;

end.
