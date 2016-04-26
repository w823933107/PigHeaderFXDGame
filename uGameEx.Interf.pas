// 基础服务单元
unit uGameEx.Interf;

interface

uses uObj, System.SysUtils, QWorker, System.Types, Spring,
  CodeSiteLogging, System.Threading, System.SyncObjs;

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

  // 游戏配置
  TGameConfig = record
    iWndState: Integer; // 窗口状态
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
    MyObj: TMyObj;
    Hwnd: Integer; // 窗口句柄
    GameConfig: TGameConfig;
    RoleInfo: TRoleInfo;
    ManStrColor: string; // 人物名字颜色
    Terminated: Boolean;
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

  // 基础自插件服务,方便支持插件框架
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

    // 报警
    procedure Warnning;
    // 关闭窗口
    procedure CloseGameWindows;
    // 移动到固定点
    procedure MoveToFixPoint;
    // 设置偏色,如果包含了-就不做处理
    function StrColorOffset(color: string): string;
    // 设置游戏全局数据
    procedure SetGameData(aGameData: PGameData); virtual;
    // 是否有疲劳
    function IsHavePilao: Boolean;
    function IsWeak: Boolean;
    function IsWeakInMap: Boolean;
  public
    property Terminated: Boolean read GetTerminated; // 主线程是否被要求终止
    property GameData: PGameData read FGameData write SetGameData; // 全局信息
    property MyObj: TMyObj read GetMyObj;
    property Obj: IChargeObj read GetObj;
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
    // function GetIsArriviedMonster: Boolean;

    function IsArriviedMonster(var aMonsterPoint: TPoint): Boolean;
    property ManPoint: TPoint write SetManPoint; // 寻找怪物依赖于人物坐标
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
    function ReleaseHelperSkill: Boolean; // 辅助技能,没有到达怪物也可以释放的技能
  end;

  IGoods = interface(IGameBase)
    ['{466FEC32-366D-4AD0-B2EE-D0014B4C3C0E}']
    procedure SetManPoint(const value: TPoint);
    function GetPoint: TPoint;
    function GetIsArrivedGoods: Boolean;
    function GetIsExistGoods: Boolean;

    property ManPoint: TPoint write SetManPoint;
    property Point: TPoint read GetPoint;
    property IsArrivedGoods: Boolean read GetIsArrivedGoods; // 依赖于颜色识别是否到达物品的
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
    function CompareDoorState(aDoorState: Boolean): Boolean; // 检测门的状态,内部用来重置计时器
    function CompareMiniMap(const aMiniMap: TMiniMap): Boolean; // 比较小地图是否相同
    procedure ResetManStopWatch;
    procedure ResetOutMapStopWatch;
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
    function GetIsfuzhongByPic: Boolean;
    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // 获取装备百分比
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
        iRet := Obj.FindStr(0, 0, 800, 600, '网络连接中断', clStrWhite, 1.0, x, y);
        if iRet > -1 then // 如果是网络中断那么不执行关闭窗口
          break;
        iRet := Obj.FindStr(0, 0, 800, 600, '关闭|返回城镇', StrColorOffset('ddc593'),
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
        iRet := Obj.FindPic(0, 0, 800, 600, '叉.bmp|叉(小).bmp', clPicOffsetZero,
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
  iRet := Obj.FindPic(297, 545, 423, 565, '无疲劳.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  Result := iRet = -1; // 找不到没有疲劳的图片表面还有疲劳

end;

function TGameBase.IsWeak: Boolean;
var
  x, y: OleVariant;
  iRet: Integer;
begin
  Result := False;
  CloseGameWindows;
  iRet := Obj.FindPic(242, 488, 800, 569, '虚弱.bmp', clPicOffsetZero,
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
  iRet := Obj.FindPic(242, 488, 800, 569, '虚弱.bmp', clPicOffsetZero,
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
        sw := TStopWatch.StartNew; // 计时
        swLong := TStopWatch.StartNew;
        while (not Terminated) do
        begin
          TTask.CurrentTask.CheckCanceled;
          if swLong.ElapsedMilliseconds >= (1000 * 60 * 10) then
          begin
            Obj.Stop(hPlay); // 超出10分钟停止报警
            sleep(100);
            break;
          end;
          if sw.ElapsedMilliseconds >= (1000 * 60 * 3) then
          begin
            Obj.Stop(hPlay);
            sleep(100);
            hPlay := Obj.Play('wife.mp3');
            sw.Reset; // 重置
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
  NormalizeRect; // 常规化
end;

end.
