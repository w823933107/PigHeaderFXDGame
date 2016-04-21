// 基础服务单元
unit uGameEx.Interf;

interface

uses uObj, System.SysUtils, QWorker, System.Types, Spring,
  CodeSiteLogging, QPlugins;

const
  // 路径配置
  sDictPath = '.\Dict\Main.txt'; // 先设置的字库路径在设置的图片为全局路径
  sPicPath = '.\Pic'; // 图片路径
  sConfigPath = '.\Config\Config.txt'; // 配置文件路径
  // 常量值
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
  EGame = Exception;

  TRectHelper = record helper for TRect
    procedure DmNormalizeRect;
  end;

  // 游戏配置
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

  // 字和偏移
  TStrOffset = record
    str: string;
    OffsetX: Integer;
  end;

  PRoleInfo = ^TRoleInfo;

  TRoleInfo = record
    Name: string;
    NameWithDec: string;
    MainJob: string;
    // 副职业相关
    ExpertJob: string; // 副职业
    ExpertJobLv: Cardinal; // 副职业等级
    ExpertJobCurExp: Cardinal; // 副职业当前经验
    ExpertJobMaxExp: Cardinal; // 副职业最大经验
    Lv: Integer; // 等级
    // 人物中心点偏移
    CenterXOffset: TArray<TStrOffset>; // x轴偏移数组
    CenterYOffset: Integer; // y轴偏移
  end;

  PGameData = ^TGameData;

  TGameData = record
    Obj: IChargeObj;
    Hwnd: Integer; // 窗口句柄
    GameConfig: TGameConfig;
    RoleInfo: TRoleInfo;
    ManStrColor: string[30];
    Job: PQJob;
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

  IGameService = interface
    ['{2BE5BFB6-1647-461E-A668-F34A3331FBAC}']
    procedure Prepare;
    procedure Start;
    procedure Stop;
    function Guard(): Boolean;
  end;

  // 游戏与界面交互接口
  IGame = interface(IGameBase)
    ['{03606AA3-1082-484B-B503-AA2069EF6C7E}']
    procedure Init;
    procedure Start;
    procedure Stop;
    procedure SetApplicationHanlde(aHandle: THandle);
    function Guard(): Boolean;
  end;

  // 基础自插件服务,方便支持插件框架
  TGameBase = class(TInterfacedObject)
  private
    FObj: IChargeObj;
    FMyObj: TMyObj;
    FGameData: PGameData;
    procedure SetObj(value: IChargeObj);
    function GetJob: PQJob;
    procedure SetJob(const value: PQJob);
    function GetTerminated: Boolean;
  protected

    // 报警
    procedure Warnning;
    // 关闭窗口
    procedure CloseGameWindows;
    // 移动到固定点
    procedure MoveToFixPoint;
    // 设置偏色,如果包含了-就不做处理
    function StrColorOffset(color: string): string;
    procedure SetGameData(aGameData: PGameData);
  public
    destructor Destroy; override;
    property Terminated: Boolean read GetTerminated;
    property GameData: PGameData read FGameData write SetGameData; // 全局信息
    property MyObj: TMyObj read FMyObj;
    property Obj: IChargeObj read FObj write SetObj;
    property Job: PQJob read GetJob write SetJob;
  end;

  // ---------------一下为游戏必要的基础接口---------------------

  // 角色信息处理接口,用来获取角色信息
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
    function GetIsArriviedMonster: Boolean;

    property ManPoint: TPoint write SetManPoint; // 寻找怪物依赖于人物坐标
    property IsArrviedMonster: Boolean read GetIsArriviedMonster;
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
    property KeyCode: Integer read GetKeyCode; // 按键
    property Point: TPoint read GetPoint;
    property IsOpen: Boolean read GetIsOpen;
  end;

  IMove = interface;

  IDirections = interface(IGameBase)
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

  IMove = interface(IGameBase)
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

  ISkill = interface(IGameBase)
    ['{7A45559A-E38C-4352-AC0E-56E765D701E5}']
    procedure RestetSkills; // 初始化技能数据
    procedure ReleaseSkill;
    procedure DestroyBarrier; // 破坏障碍
    procedure ReleaseHelperSkill; // 辅助技能,没有到达怪物也可以释放的技能
  end;

  IGoods = interface(IGameBase)
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

  ICheckTimeOut = interface(IGameBase)
    ['{83AA4347-B0AC-472F-A60E-E5E66156E003}']
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean;
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
  end;

  TZhuangbeiType = (zt未知, zt普通, zt高级, zt稀有, zt神器, zt传承, zt勇者, zt传说, zt史诗);

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

    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // 获取装备百分比
    function GetZhuangbeiPercentage: Integer;
  end;

  IPassGame = interface(IGameBase)
    ['{77EF1605-C3C3-4D5B-863E-83564AF35D52}']
    procedure Handle;
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
  Result.iGetInfoTimeOut := 1000 * 30;
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

{ TGameBase }

procedure TGameBase.CloseGameWindows;
var
  hJob: THandle;
begin
  hJob := Workers.Post(
    procedure(AJob: PQJob)
    var
      iRet: Integer;
      x, y: OleVariant;
    begin
      while not AJob.IsTerminated do
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
        iRet := Obj.FindPic(0, 0, 800, 600, '叉.bmp|叉(小).bmp', clPicOffsetZero,
          0.9,
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
    end, nil);
  if Workers.WaitJob(hJob, 1000 * 30, False) = wrTimeout then
  begin
    Warnning;
  end;
  // ddc593-000000

end;

destructor TGameBase.Destroy;
begin
  FObj := nil;
  FMyObj.Free;
  inherited;
end;

function TGameBase.GetJob: PQJob;
begin
  Result := GameData.Job;
end;

function TGameBase.GetTerminated: Boolean;
begin
  Result := Job.IsTerminated;
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

procedure TGameBase.SetJob(const value: PQJob);
begin
  GameData.Job := value;
end;

procedure TGameBase.SetObj(value: IChargeObj);
begin
  if not Assigned(FObj) then
  begin
    FObj := value;
    FMyObj := TObjFactory.CreateMyObj(FObj);
  end;
end;

function TGameBase.StrColorOffset(color: string): string;
begin
  if not color.Contains('-') then
    Result := color + clStrOffsetZero;
end;

procedure TGameBase.Warnning;
begin
  Workers.Post(
    procedure(AJob: PQJob)
    begin

    end, nil);
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

end.
