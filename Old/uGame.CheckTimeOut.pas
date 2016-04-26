unit uGame.CheckTimeOut;

interface

uses uGame.Interf, System.Diagnostics, System.Types;

type
  // 检测各类操作超时
  TCheckTimeOut = class(TGameBase, ICheckTimeOut)
  type
    TStopWatchEnum = (swManMove, swManFind, swMonsterFind, swInMapPickGoods,
      swInMapLong);
  private
    FStopWatchs: array [TStopWatchEnum] of TStopwatch;
    FOldManPoint: TPoint; // 上一次人物坐标
    FOldMiniMap: TMiniMap;
  public
    constructor Create();
    // 杀怪成功后进行重置,或者捡物等
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean;
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
  end;

implementation

{ TCheck }

constructor TCheckTimeOut.Create;
var
  I: TStopWatchEnum;
begin
  inherited Create;
  for I := Low(FStopWatchs) to High(FStopWatchs) do
  begin
    FStopWatchs[I] := TStopwatch.Create;
  end;
end;

function TCheckTimeOut.IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // 设置默认值
  // 如果上一次和这一次地图相同
  if FOldMiniMap = aMiniMap then
  begin
    // 是否运行
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        GameData.GameConfig.iInMapTimeOut;
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
  FOldMiniMap := aMiniMap; // 记录当前地图

end;

function TCheckTimeOut.IsInMapPickupGoodsTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // 设置默认值
  // 如果上一次和这一次地图相同
  if FOldMiniMap = aMiniMap then
  begin
    // 是否运行
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        GameData.GameConfig.iPickUpGoodsTimeOut
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
  FOldMiniMap := aMiniMap; // 记录当前地图
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

end.
