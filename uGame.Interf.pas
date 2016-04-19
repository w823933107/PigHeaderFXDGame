{
  2016/3/24
  =====================
  *�����ӿ�ֱ���໥Ӧ��,�����ڴ�й¶������,spring���ܲ��������ͷ��໥���õĽӿ�
}
unit uGame.Interf;

interface

uses uObj, System.SysUtils, System.Types, Spring, QWorker;

const
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
  // ��δͨ��
  EBindFailed = class(Exception);
  // ��ɫ��Ϣ��ȡ����
  ERoleInfoFailed = class(Exception);

  TGameConfig = record
    iWndState: Integer; // ����״̬
    bAutoRunGuard: Boolean; // �Զ���������
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

  TStrOffset = record
    str: string;
    OffsetX: Integer;
  end;

  TRoleInfo = record
    Name: string;
    NameWithDec: string;
    MainJob: string;
    // ��ְҵ���
    ExpertJob: string;
    ExpertJobLv: Cardinal;
    ExpertJobCurExp: Cardinal;
    ExpertJobMaxExp: Cardinal;

    Lv: Integer;
    // �������ĵ�ƫ��
    CenterXOffset: TArray<TStrOffset>;
    CenterYOffset: Integer;
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

  TRectHelper = record helper for TRect
    procedure DmNormalizeRect;
  end;

  IGameConfigManager = interface
    ['{5529F901-CBCB-4C16-91CF-B96C314AAB79}']
    procedure SetFileName(aFileName: string);
    procedure SetConfig(const aGameConfig: TGameConfig);
    function GetConfig(): TGameConfig;

    property FileName: string write SetFileName;
    property Config: TGameConfig read GetConfig write SetConfig;
  end;

  // ��Ϸ����潻���ӿ�
  IGame = interface
    ['{712FB04C-4C19-4D05-BF57-3F99D389657E}']
    procedure SetGameConfigManager(const value: IGameConfigManager);

    procedure Start;
    procedure Stop;
    property GameConfigManager: IGameConfigManager write SetGameConfigManager;
  end;




  // ����Ϊ�̵߳���ģʽ

  TGameData = record
    PTerminated: PBoolean;
    Hwnd: Integer;
    Obj: IChargeObj;
    MyObj: TMyObj;
    RoleInfo: TRoleInfo;
    GameConfig: TGameConfig;
    ManStrColor: string;
  end;

  // ����,�ṩ��������
  { TODO -c�Ż� :
    �̳г�һ����,������������ʹ��,
    �Ƴ���ȫ�����ݵ�д��Ȩ��,
    ��ֹ���������޸�ȫ�����ݵ����߼����� }
  TGameBase = class(TInterfacedObject)
  private
    function GetObj: IChargeObj;
    function GetTerminated: Boolean;
    function GetMyObj: TMyObj;
  protected
  //  FJob: PQJob;
    property MyObj: TMyObj read GetMyObj;
    property Obj: IChargeObj read GetObj;
    property Terminated: Boolean read GetTerminated; // �����߳�
  public
    function PrepareTest: Boolean;
    procedure warnning;
    procedure MoveToFixPoint;
    function IsNotHasPilao: Boolean; // �Ƿ�û��ƣ����
    procedure CloseGameWindows;
  end;
  // ---------------һ��Ϊ��Ϸ��Ҫ�Ļ����ӿ�---------------------

  // ��ɫ��Ϣ����ӿ�,������ȡ��ɫ��Ϣ
  IRoleInfoHandle = interface
    ['{196BF2CF-20C9-49A4-8A73-61F03EF830A7}']
    function GetRoleInfo: TRoleInfo;
  end;

  IMap = interface
    ['{A04EE806-211B-4C99-B8A1-171E793E6486}']
    function GetLargeMap: TLargeMap;
    function GetMiniMap: TMiniMap;

    property LargeMap: TLargeMap read GetLargeMap;
    property MiniMap: TMiniMap read GetMiniMap;
  end;

  IMan = interface
    ['{D8B2AA51-B8CC-4930-8F59-958C669AC5F3}']
    function GetPoint: TPoint;
    function GetRect: TRect;
    property Point: TPoint read GetPoint;
    property Rect: TRect read GetRect;

  end;

  IMonster = interface
    ['{703DD800-3F05-4626-87FF-733092C7F2D4}']
    function GetPoint: TPoint;
    procedure SetManPoint(const value: TPoint);
    function GetIsExistMonster: Boolean;
    function GetIsArriviedMonster: Boolean;

    property ManPoint: TPoint write SetManPoint; // Ѱ�ҹ�����������������
    property IsArrviedMonster: Boolean read GetIsArriviedMonster;
    property IsExistMonster: Boolean read GetIsExistMonster;
    property Point: TPoint read GetPoint;

  end;

  IDoor = interface
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

  IDirections = interface
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

  IMove = interface
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

  ISkill = interface
    ['{7A45559A-E38C-4352-AC0E-56E765D701E5}']
    procedure RestetSkills; // ��ʼ����������
    procedure ReleaseSkill;
    procedure DestroyBarrier; // �ƻ��ϰ�
    procedure ReleaseHelperSkill; // ��������,û�е������Ҳ�����ͷŵļ���
  end;

  IGoods = interface
    ['{466FEC32-366D-4AD0-B2EE-D0014B4C3C0E}']
    procedure SetManPoint(const value: TPoint);
    function GetPoint: TPoint;
    function GetIsArrivedGoods: Boolean;
    function GetIsExistGoods: Boolean;

    property ManPoint: TPoint write SetManPoint;
    property Point: TPoint read GetPoint;
    property IsArrivedGoods: Boolean read GetIsArrivedGoods;
    property IsExistGoods: Boolean read GetIsExistGoods;
    procedure PickupGoods;
  end;

  ICheckTimeOut = interface
    ['{83AA4347-B0AC-472F-A60E-E5E66156E003}']
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean;
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
  end;

  TZhuangbeiType = (ztδ֪, zt��ͨ, zt�߼�, ztϡ��, zt����, zt����, zt����, zt��˵, ztʷʫ);

  IBox = interface
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

    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // ��ȡװ���ٷֱ�
    function GetZhuangbeiPercentage: Integer;
  end;

  IPassGame = interface
    ['{77EF1605-C3C3-4D5B-863E-83564AF35D52}']
    procedure Handle;
  end;

  IOutMap = interface
    ['{087DE172-B582-49F8-8CCD-D2F81055C6AE}']
    procedure Handle;
  end;

  // ʹ��ȫ�ֱ���
var
  GameData: TGameData;
  // �ֵ���ɫֵ����,��ֹ��������������ɫƫ������
  // ����չ�������ļ�������
function StrColorOffset(color: string): string;
procedure RegisterGameClass;
procedure UnregisterGameClass;

implementation

{$INCLUDE RegisterFunc.INC}


function StrColorOffset(color: string): string;
begin
  if not color.Contains('-') then
    Result := color + clStrOffsetZero;
end;
{ TGameBase }

function TGameBase.GetTerminated: Boolean;
begin
  Result := GameData.PTerminated^;
end;

function TGameBase.IsNotHasPilao: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  iRet := Obj.FindPic(297, 545, 423, 565, '��ƣ��.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  Result := iRet > -1;
end;

procedure TGameBase.MoveToFixPoint;
begin
  Obj.MoveTo(20, 30);
  Sleep(100);
end;

function TGameBase.PrepareTest: Boolean;
var
  hHwnd: Integer;
  iRet: Integer;
begin
  Result := False;
  GameData.Obj := TObjFactory.CreateChargeObj;
  GameData.GameConfig := TGameConfig.Create;
  Obj.SetDict(0, '.\Dict\Main.txt');
  Obj.SetPath('.\Pic');
  hHwnd := Obj.FindWindow('���³�����ʿ', '���³�����ʿ');
  if hHwnd > 0 then
  begin
    GameData.Hwnd := hHwnd;
    iRet := Obj.BindWindow(hHwnd, 'normal', 'normal', 'normal', 101);
    Result := iRet = 1;

  end;
end;

procedure TGameBase.warnning;
var
  stopwatch: TStopwatch;
  hMp3: THandle;
begin
  if GameData.GameConfig.bWarning then
  begin
    hMp3 := Obj.Play('����.mp3');
    stopwatch := TStopwatch.StartNew;
    while not Terminated do
    begin
      if stopwatch.ElapsedMilliseconds >= 1000 * 60 * 10 then
        Break;
      Sleep(100);
    end;
    Obj.Stop(hMp3);
  end;

end;

procedure TGameBase.CloseGameWindows;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  // ddc593-000000
  while not Terminated do
  begin
    iRet := Obj.FindStr(0, 0, 800, 600, '�ر�|���س���', StrColorOffset('ddc593'),
      1.0, x, y);
    if iRet > -1 then
    begin
      Obj.MoveTo(x, y);
      Sleep(100);
      Obj.LeftClick;
      Sleep(200);
      MoveToFixPoint;
    end;
    iRet := Obj.FindPic(0, 0, 800, 600, '��.bmp|��(С).bmp', clPicOffsetZero, 0.9,
      0, x, y);
    if iRet > -1 then
    begin
      Obj.MoveTo(x, y);
      Sleep(100);
      Obj.LeftClick;
      Sleep(200);
      MoveToFixPoint;
    end;
    Sleep(100);
  end;
end;

function TGameBase.GetMyObj: TMyObj;
begin
  Result := GameData.MyObj;
end;

function TGameBase.GetObj: IChargeObj;
begin
  Result := GameData.Obj;
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

{ TGameConfig }

class function TGameConfig.Create: TGameConfig;
begin
  Result.iWndState := 0;
  Result.bAutoRunGuard := False;
  Result.iLoopDelay := 20;
  Result.bVIP := False;
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
  Result.bVIP := False;
  Result.iPickUpGoodsTimeOut := 10000;
  Result.iFindManTimeOut := 3000;
  Result.iManMoveTimeOut := 3000;
  Result.iFindMonsterTimeOut := 3000;
  Result.iGetInfoTimeOut := 10000;
  Result.sMoveGoodsKeyCode := '3';
  Result.imaxZhuangbeiNum := 70;
  Result.iResetMoveStateInterval := 30000;
  Result.bResetMoveState := True;
  Result.bRepair := True;
  Result.iInMapTimeOut := 1000 * 60 * 3;
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
  Result.bNearAdjustDirection := False;
  Result.bJiabaliWarning := True;
  Result.bWarning := True;
  Result.iMapLv := 1;
  Result.bLogView := True;
end;

initialization

RegisterGameClass;

finalization

CleanupGlobalContainer;

end.
