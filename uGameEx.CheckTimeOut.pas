unit uGameEx.CheckTimeOut;

interface

uses uGameEx.Interf, System.Diagnostics, System.Types;

type

  TStopWatchEnum = (
    swManMove,
    swManFind,
    swMonsterFind,
    swInMapPickGoodsOpened, // 只适用于门开启,在规定时间内进行捡物,防止卡关
    swInMapPickGoods, // 普通捡物检测,适用于门开启或者关闭状态,防止包满,长时间捡物捡不起来卡关
    swInMapLong,
    swOutMapLong);

  // 检测各类操作超时
  TCheckTimeOut = class(TGameBase, ICheckTimeOut)
  private
    FStopWatchs: array [TStopWatchEnum] of TStopwatch;
    FOldManPoint: TPoint; // 上一次人物坐标
    FOldMiniMap, FOldMiniMapOpened: TMiniMap; // 上一次小地图位置
    FOldLargeMap: TLargeMap; // 上一次大地图位置
    FOldDoorState: Boolean;

  public
    constructor Create();
    procedure ResetManStopWatch;
    function CompareMiniMap(const aMiniMap: TMiniMap): Boolean; // 比较小地图是否相同
    function CompareDoorState(aDoorState: Boolean): Boolean;
    // 杀怪成功后进行重置,或者捡物等
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean; // 是否移动超时
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean; // 是否找人超时
    // 是否找怪超时
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;

    function IsInMapPickupGoodsOpenedTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    // 是否捡物超时
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean; // 是否图内超时
    function IsOutMapTimeOut(const aLargeMap: TLargeMap): Boolean; // 是否图外超时
  end;

implementation

{ TCheck }

function TCheckTimeOut.CompareDoorState(aDoorState: Boolean): Boolean;
begin
  Result := FOldDoorState = aDoorState;
  if not Result then
  begin
    FStopWatchs[swInMapPickGoodsOpened].Stop;
    FStopWatchs[swInMapPickGoods].Stop;
    FStopWatchs[swInMapLong].Stop;
    FStopWatchs[swManMove].Stop;
    FStopWatchs[swManFind].Stop;
    FStopWatchs[swMonsterFind].Stop;
    FOldDoorState := aDoorState;

    FStopWatchs[swInMapPickGoodsOpened].Reset;
    FStopWatchs[swInMapPickGoods].Reset;
    FStopWatchs[swInMapLong].Reset;
    FStopWatchs[swManMove].Reset;
    FStopWatchs[swManFind].Reset;
    FStopWatchs[swMonsterFind].Reset;
    FOldDoorState := aDoorState;
  end;
end;

function TCheckTimeOut.CompareMiniMap(const aMiniMap: TMiniMap): Boolean;
begin
  Result := FOldMiniMap = aMiniMap;
  if not Result then
  begin
    FStopWatchs[swInMapPickGoodsOpened].Stop;
    FStopWatchs[swInMapPickGoods].Stop;
    FStopWatchs[swInMapLong].Stop;
    FStopWatchs[swManMove].Stop;
    FStopWatchs[swManFind].Stop;
    FStopWatchs[swMonsterFind].Stop;

    FStopWatchs[swInMapPickGoodsOpened].Reset;
    FStopWatchs[swInMapPickGoods].Reset;
    FStopWatchs[swInMapLong].Reset;
    FStopWatchs[swManMove].Reset;
    FStopWatchs[swManFind].Reset;
    FStopWatchs[swMonsterFind].Reset;
    FOldMiniMap := aMiniMap;
  end;
end;

constructor TCheckTimeOut.Create;
var
  I: TStopWatchEnum;
begin
  inherited Create;
  for I := Low(FStopWatchs) to High(FStopWatchs) do
  begin
    FStopWatchs[I] := TStopwatch.Create; // 初始化计时器
  end;
end;

function TCheckTimeOut.IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // 设置默认值
  // 如果上一次和这一次地图相同
  if CompareMiniMap(aMiniMap) then
  begin
    // 是否运行
    if FStopWatchs[swInMapLong].IsRunning then
    begin
      Result := FStopWatchs[swInMapLong].ElapsedMilliseconds >=
        GameData.GameConfig.iInMapTimeOut;
    end
    else
    begin
      FStopWatchs[swInMapLong].Start; // 开始运行
    end;
  end
  else
  begin
    FStopWatchs[swInMapLong].Stop;
    FStopWatchs[swInMapLong].Reset; // 恢复默认
  end;

end;

function TCheckTimeOut.IsInMapPickupGoodsTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // 设置默认值
  // 如果上一次和这一次地图相同
  if CompareMiniMap(aMiniMap) then
  begin
    // 是否运行
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        (1000 * 60 * 2);
    end
    else
    begin
      FStopWatchs[swInMapPickGoods].Start; // 开始运行
    end;
  end
  else
  begin
    FStopWatchs[swInMapPickGoods].Stop;
    FStopWatchs[swInMapPickGoods].Reset; // 恢复默认
  end;
end;

function TCheckTimeOut.IsInMapPickupGoodsOpenedTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // 设置默认值
  // 如果上一次和这一次地图相同
  // if FOldMiniMapOpened = aMiniMap then
  // begin
  // 是否运行
  if FStopWatchs[swInMapPickGoodsOpened].IsRunning then
  begin
    Result := FStopWatchs[swInMapPickGoodsOpened].ElapsedMilliseconds >=
      GameData.GameConfig.iPickUpGoodsTimeOut
  end
  else
  begin
    FStopWatchs[swInMapPickGoodsOpened].Start; // 开始运行
  end;
  // end
  // else
  // begin
  // FStopWatchs[swInMapPickGoodsOpened].Stop;
  // FStopWatchs[swInMapPickGoodsOpened].Reset; // 恢复默认
  // FOldMiniMapOpened := aMiniMap; // 记录上一次的
  // end;
end;

function TCheckTimeOut.IsManFindTimeOut(const aManPoint: TPoint): Boolean;
begin
  Result := False;
  // 未找到人物,进行计时操作
  if aManPoint.IsZero then
  begin
    // 计时已经运行
    if FStopWatchs[swManFind].IsRunning then
    begin
      // 检测是否超时
      Result := FStopWatchs[swManFind].ElapsedMilliseconds >=
        GameData.GameConfig.iFindManTimeOut;
    end
    else
    begin
      FStopWatchs[swManFind].Start; // 开始计时
    end;
  end
  else
  begin
    // 找到人物停止计时
    FStopWatchs[swManFind].Stop;
    FStopWatchs[swManFind].Reset;

  end;
end;

function TCheckTimeOut.IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
begin
  Result := False;
  // 找到人物坐标
  if not aManPoint.IsZero then
  begin
    // 和上次坐标一样检测超时
    if aManPoint = FOldManPoint then
    begin
      // 如果运行,检测超时
      if FStopWatchs[swManMove].IsRunning then
      begin
        Result := FStopWatchs[swManMove].ElapsedMilliseconds >=
          GameData.GameConfig.iManMoveTimeOut;
      end
      else
        FStopWatchs[swManMove].Start;

    end
    else
    begin
      // 和上次坐标不相同,停止计时
      FStopWatchs[swManMove].Stop;
      FStopWatchs[swManMove].Reset;

    end;
    FOldManPoint := aManPoint; // 记录当前坐标
  end;
end;

function TCheckTimeOut.IsMonsterFindTimeOut(const aMonsterPoint
  : TPoint): Boolean;
begin
  Result := False;
  // 未发现怪物
  if aMonsterPoint.IsZero then
  begin
    // 是否运行
    if FStopWatchs[swMonsterFind].IsRunning then
    begin
      // 检测超时
      Result := FStopWatchs[swMonsterFind].ElapsedMilliseconds >=
        GameData.GameConfig.iFindMonsterTimeOut;

    end
    else
      FStopWatchs[swMonsterFind].Start;
  end
  else
  begin
    // 发现怪物
    FStopWatchs[swMonsterFind].Stop;
    FStopWatchs[swMonsterFind].Reset;
  end;

end;

function TCheckTimeOut.IsOutMapTimeOut(const aLargeMap: TLargeMap): Boolean;
begin
  Result := False;
  if aLargeMap = lmOut then
  begin
    if FStopWatchs[swOutMapLong].IsRunning then
    begin
      // 虚弱的时候检测时间为10分钟
      if IsWeak then
        Result := FStopWatchs[swOutMapLong].ElapsedMilliseconds >=
          (1000 * 60 * 10)
      else
        // 正常检测为3分钟
        Result := FStopWatchs[swOutMapLong].ElapsedMilliseconds >=
          (1000 * 60 * 3);
    end
    else
      FStopWatchs[swOutMapLong].Start;
  end
  else
  begin
    FStopWatchs[swOutMapLong].Stop; // 在图内的时候停止计时
    // FStopWatchs[swOutMapLong].Reset;
  end;

end;

procedure TCheckTimeOut.ResetManStopWatch;
begin
  FStopWatchs[swManMove].Stop;
  FStopWatchs[swManFind].Stop;
end;

end.
