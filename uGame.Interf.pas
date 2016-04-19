{
  2016/3/24
  =====================
  *修正接口直接相互应用,导致内存泄露的问题,spring可能不能正常释放相互引用的接口
}
unit uGame.Interf;

interface

uses uObj, System.SysUtils, System.Types, Spring, QWorker;

const
  clWndActive = 'ffffff-000100'; // 窗口的置顶颜色值
  clWndNoActive = 'aaaaaa-000100'; // 窗口未置顶颜色值
  clWndOpen = 'ffffff-000100|aaaaaa-000100'; // 窗口打开的颜色值
  clStrWhite = 'ffffff-000100';
  clStrOffsetZero = '-000100';
  clPicOffsetZero = '000100';
  clVip = 'fadc64-000100'; // 黑钻颜色
  clNoVip = clStrWhite; // 非黑钻颜色
  // 窗口状态
  wsActive = 0;
  wsTop = 1;
  // 游戏方向
  gdLeft = 37;
  gdRight = 39;
  gdUp = 38;
  gdDown = 40;
  // 职业类型
  mjKuangzhanshi = '狂战士';
  mjYuxuemoshen = '狱血魔神';
  mjSilingshushi = '死灵术士';
  mjLinghunshougezhe = '灵魂收割者';

type
  // 绑定未通过
  EBindFailed = class(Exception);
  // 角色信息获取错误
  ERoleInfoFailed = class(Exception);

  TGameConfig = record
    iWndState: Integer; // 窗口状态
    bAutoRunGuard: Boolean; // 自动启动保护
    iLoopDelay: Integer; // 循环延时,降低CPU占用率
    bVIP: Boolean; // 黑钻
    iPickUpGoodsTimeOut: Integer; // 捡物超时
    iFindManTimeOut: Integer; // 找人超时
    iManMoveTimeOut: Integer; // 人物移动操作,比如卡障碍了
    iFindMonsterTimeOut: Integer; // 找怪超时
    iGetInfoTimeOut: Integer; // 获取角色信息超时时间
    sMoveGoodsKeyCode: string; // 移动物品键码
    imaxZhuangbeiNum: Integer; // 重量百分比
    iResetMoveStateInterval: Integer; // 重置移动状态的间隔
    bResetMoveState: Boolean; // 是否重置移动时间
    bRepair: Boolean; // 是否修复装备
    iInMapTimeOut: Integer; // 在图内超时
    iKuangzhanOffsetY: Integer; // 狂战Y偏移
    iSilingOffsetY: Integer; // 死灵Y偏移
    bNearAdjustDirection: Boolean; // 附近怪调整方向
    bJiabaliWarning: Boolean;
    bWarning: Boolean;
    iMapLv: Integer;
    bLogView: Boolean;
    // 技能配置
    // 狂战技能
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

    // 死灵技能
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
    // 副职业相关
    ExpertJob: string;
    ExpertJobLv: Cardinal;
    ExpertJobCurExp: Cardinal;
    ExpertJobMaxExp: Cardinal;

    Lv: Integer;
    // 人物中心点偏移
    CenterXOffset: TArray<TStrOffset>;
    CenterYOffset: Integer;
  end;

  TGameDirectionLR = (
    gdUpLeftAndRight, // 弹起左右
    gdDownLeft, // 按下左
    gdDownRight // 按下右
    );
  TGameDirectionUD = (
    gdUpUpAndDown, // 弹起上下
    gdDownUp, // 按下上
    gdDownDown // 按下下
    );

  TGameDirections = record
    LR: TGameDirectionLR; // 左右
    UD: TGameDirectionUD; // 上下
  end;

  TLargeMap = (lmUnknown, lmOut, lmIn);
  TMiniMap = (
    mmUnknown, // 未知图
    mmBoss, // Boss图
    mmClickCards, // 翻牌图
    mmPassGame, // 通关图
    mmMain1,
    mmMain2,
    mmMain3,
    mmMain4,
    mmMain5,
    mmMain6,
    // 其他不必须走的图 从第一图往下左上
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

  // 游戏与界面交互接口
  IGame = interface
    ['{712FB04C-4C19-4D05-BF57-3F99D389657E}']
    procedure SetGameConfigManager(const value: IGameConfigManager);

    procedure Start;
    procedure Stop;
    property GameConfigManager: IGameConfigManager write SetGameConfigManager;
  end;




  // 设置为线程单例模式

  TGameData = record
    PTerminated: PBoolean;
    Hwnd: Integer;
    Obj: IChargeObj;
    MyObj: TMyObj;
    RoleInfo: TRoleInfo;
    GameConfig: TGameConfig;
    ManStrColor: string;
  end;

  // 基类,提供基础服务
  { TODO -c优化 :
    继承出一个类,供基础服务功能使用,
    移除对全局数据的写入权限,
    防止服务类乱修改全局数据导致逻辑混乱 }
  TGameBase = class(TInterfacedObject)
  private
    function GetObj: IChargeObj;
    function GetTerminated: Boolean;
    function GetMyObj: TMyObj;
  protected
  //  FJob: PQJob;
    property MyObj: TMyObj read GetMyObj;
    property Obj: IChargeObj read GetObj;
    property Terminated: Boolean read GetTerminated; // 控制线程
  public
    function PrepareTest: Boolean;
    procedure warnning;
    procedure MoveToFixPoint;
    function IsNotHasPilao: Boolean; // 是否没有疲勞了
    procedure CloseGameWindows;
  end;
  // ---------------一下为游戏必要的基础接口---------------------

  // 角色信息处理接口,用来获取角色信息
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

    property ManPoint: TPoint write SetManPoint; // 寻找怪物依赖于人物坐标
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
    property KeyCode: Integer read GetKeyCode; // 按键
    property Point: TPoint read GetPoint;
    property IsOpen: Boolean read GetIsOpen;
  end;

  IMove = interface;

  IDirections = interface
    ['{0D3C96E4-81E9-4FF6-AA0C-0DEAB0A79731}']
    // procedure SetMove(const value: IMove);

    // 获取走向怪物需要的方向
    function GetMonsterDirections(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // 获取寻找怪物需要的方向
    function GetFindMonsterDirections(const aManPoint: TPoint;
      aMiniMap: TMiniMap): TGameDirections;
    // 获取走向门需要的方向
    function GetDoorDirections(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // 获取走向物品需要的方向
    function GetGoodsDirections(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // property Move: IMove write SetMove;

  end;

  IMove = interface
    ['{6906F8ED-0F14-4D25-8BA3-379A99BCA1C3}']
    procedure Reset; // 恢复按键状态,防止卡键
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
      const aMiniMap: TMiniMap); // 移向怪物
    procedure MoveToDoor(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap); // 移向门
    procedure MoveInDoor(const aKeyCode: Integer); // 进门
    procedure MoveToGoods(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap);
  end;

  ISkill = interface
    ['{7A45559A-E38C-4352-AC0E-56E765D701E5}']
    procedure RestetSkills; // 初始化技能数据
    procedure ReleaseSkill;
    procedure DestroyBarrier; // 破坏障碍
    procedure ReleaseHelperSkill; // 辅助技能,没有到达怪物也可以释放的技能
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

  TZhuangbeiType = (zt未知, zt普通, zt高级, zt稀有, zt神器, zt传承, zt勇者, zt传说, zt史诗);

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
    // 获取装备百分比
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

  // 使用全局变量
var
  GameData: TGameData;
  // 字的颜色值设置,防止在其他电脑中颜色偏移问题
  // 可拓展在配置文件中设置
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
  iRet := Obj.FindPic(297, 545, 423, 565, '无疲劳.bmp', clPicOffsetZero,
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
  hHwnd := Obj.FindWindow('地下城与勇士', '地下城与勇士');
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
    hMp3 := Obj.Play('报警.mp3');
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
    iRet := Obj.FindStr(0, 0, 800, 600, '关闭|返回城镇', StrColorOffset('ddc593'),
      1.0, x, y);
    if iRet > -1 then
    begin
      Obj.MoveTo(x, y);
      Sleep(100);
      Obj.LeftClick;
      Sleep(200);
      MoveToFixPoint;
    end;
    iRet := Obj.FindPic(0, 0, 800, 600, '叉.bmp|叉(小).bmp', clPicOffsetZero, 0.9,
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
  NormalizeRect; // 常规化
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
