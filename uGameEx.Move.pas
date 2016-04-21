unit uGameEx.Move;

interface

uses uGameEx.Interf, System.SysUtils, System.Diagnostics,
  System.Math, System.Types, CodeSiteLogging, System.Rtti;

type
  TMove = class(TGameBase, IMove)
  private
    FIsLeft, FIsRight, FIsUp, FIsDown: Boolean;
    FStopWatch: TStopwatch;
    FIsFastMove: Boolean;
    procedure Delay;
    procedure ResetKeyState;
  private
    // 延迟创建 ,放在构造函数中会导致内存泄露
    FDirections: IDirections;

  public

    constructor Create();
    destructor Destroy; override;
    procedure Reset;
    procedure MoveToLeft;
    procedure MoveToRight;
    procedure MoveToUp;
    procedure MoveToDown;
    procedure StopMoveLR;
    procedure StopMoveUD;
    procedure Move(const aGameDirections: TGameDirections);
    procedure StopMove;
    procedure RandomMove;
    // 寻找怪物
    procedure MoveToFindMonster(const aManPoint: TPoint;
      const aMiniMap: TMiniMap);
    // 移向怪物
    procedure MoveToMonster(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap);
    // 移向门
    procedure MoveToDoor(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap);
    // 进门
    procedure MoveInDoor(const aKeyCode: Integer);
    // 移向物品
    procedure MoveToGoods(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap);
  end;

implementation

uses Spring.Container;
{ TMove }

constructor TMove.Create;
begin
  FStopWatch := TStopwatch.Create;
  FDirections := GlobalContainer.Resolve<IDirections>;
  // FDirections := GlobalContainer.Resolve<IDirections>;
  FIsFastMove := True;
end;

procedure TMove.Delay;
begin
  Sleep(50);
end;

destructor TMove.Destroy;
begin
  FDirections := nil;
  inherited;
end;

procedure TMove.Move(const aGameDirections: TGameDirections);
begin
  // 每超过30秒进行重新设置按键状态
  if GameData.GameConfig.bResetMoveState then
  begin
    if FStopWatch.IsRunning then
    begin
      if FStopWatch.ElapsedMilliseconds >= GameData.GameConfig.iResetMoveStateInterval
      then
      begin
        CodeSite.Send('按键超过30秒,进行复位');
        StopMove;
        FStopWatch.Reset;
      end;
    end
    else
    begin
      FStopWatch.Start;
    end;
  end;

  case aGameDirections.LR of
    gdUpLeftAndRight:
      StopMoveLR; // 停止左右移动
    gdDownLeft:
      MoveToLeft; // 左移
    gdDownRight:
      MoveToRight; // 右移
  end;
  case aGameDirections.UD of
    gdUpUpAndDown:
      StopMoveUD; // 停止上下移动
    gdDownUp:
      MoveToUp; // 上移
    gdDownDown:
      MoveToDown; // 下移
  end;
  CodeSite.Write('方向', 'LR:' + TRttiEnumerationType.GetName(aGameDirections.LR) +
    ',UD:' + TRttiEnumerationType.GetName(aGameDirections.UD));
end;

procedure TMove.MoveInDoor(const aKeyCode: Integer);
begin
  Obj.KeyDown(aKeyCode);
  Obj.Delay(2000);
  Obj.KeyUp(aKeyCode);
end;

procedure TMove.MoveToDoor(const aManPoint, aDoorPoint: TPoint;
  const aMiniMap: TMiniMap);
var
  aGameDirections: TGameDirections;
  rtMan: TRect;
begin
  // 设置是否快速移动
  rtMan := Rect(aManPoint.X - 100, aManPoint.Y - 100, aManPoint.X + 100,
    aManPoint.Y + 100);
  FIsFastMove := not rtMan.Contains(aDoorPoint);
  // 获取方向
  aGameDirections := FDirections.GetDoorDirections(aManPoint, aDoorPoint,
    aMiniMap);
  // 执行移动
  Move(aGameDirections);
  FIsFastMove := True;
end;

procedure TMove.MoveToDown;
begin
  // 按下了上键
  if FIsUp then
  begin
    Obj.KeyUp(gdUp);
    Delay;
    FIsUp := False;
  end;
  // 没有按下下键
  if not FIsDown then
  begin
    Obj.KeyDown(gdDown);
    Delay;
    FIsDown := True; // 设置按键状态
  end;
end;

procedure TMove.MoveToFindMonster(const aManPoint: TPoint;
  const aMiniMap: TMiniMap);
var
  aGameDirections: TGameDirections;
begin
  aGameDirections := FDirections.GetFindMonsterDirections(aManPoint, aMiniMap);
  Move(aGameDirections);
end;

procedure TMove.MoveToGoods(const aManPoint, aGoodsPoint: TPoint;
  const aMiniMap: TMiniMap);
var
  aGameDirections: TGameDirections;
  rtMan: TRect;
begin
  // 检测是否靠近物品,靠近就不跑,慢慢走过去

  rtMan := Rect(aManPoint.X - 100, aManPoint.Y - 100, aManPoint.X + 100,
    aManPoint.Y + 100);
  FIsFastMove := not rtMan.Contains(aGoodsPoint);

  aGameDirections := FDirections.GetGoodsDirections(aManPoint, aGoodsPoint,
    aMiniMap);
  Move(aGameDirections);
  FIsFastMove := True; // 恢复跑动
end;

procedure TMove.MoveToLeft;
begin
  // 按下上键
  if FIsRight then
  begin
    Obj.KeyUp(gdRight);
    Delay;
    FIsRight := False;
  end;
  // 按下左键
  if not FIsLeft then
  begin
    if FIsFastMove then
    begin
      Obj.KeyPress(gdLeft); // 转身
      Sleep(120);
      Obj.KeyPress(gdLeft); // 准备跑
      Sleep(80);
    end;
    Obj.KeyDown(gdLeft);
    Sleep(50);
    FIsLeft := True; // 设置按键状态
  end;
end;

procedure TMove.MoveToMonster(const aManPoint, aMonsterPoint: TPoint;
  const aMiniMap: TMiniMap);
var
  aGameDirections: TGameDirections;
begin
  // 获取方向
  aGameDirections := FDirections.GetMonsterDirections(aManPoint, aMonsterPoint,
    aMiniMap);
  // 执行移动
  Move(aGameDirections);
end;

procedure TMove.MoveToRight;
begin
  if FIsLeft then
  begin
    Obj.KeyUp(gdLeft);
    Delay;
    FIsLeft := False;
  end;
  // 没有按下左键
  if not FIsRight then
  begin
    if FIsFastMove then
    begin
      Obj.KeyPress(gdRight); // 转身
      Sleep(120);
      Obj.KeyPress(gdRight); // 准备跑
      Sleep(80);
    end;
    Obj.KeyDown(gdRight);
    Delay;
    FIsRight := True; // 设置按键状态
  end;
end;

procedure TMove.MoveToUp;
begin
  if FIsDown then
  begin
    Obj.KeyUp(gdDown);
    Delay;
    FIsDown := False;
  end;
  if not FIsUp then
  begin
    Obj.KeyDown(gdUp);
    Delay;
    FIsUp := True; // 设置按键状态
  end;
end;

procedure TMove.RandomMove;
var
  iType: Integer;
  iLR, iUD: Integer;
  iDelay, iLRDelay, iUDDelay: Integer;
begin
  // 获取随机数种子  0<=x<2;
  Randomize;
  iLR := Random(2); // 左移移动方向
  Randomize;
  iUD := Random(2); // 上下移动方向
  Randomize;
  iType := Random(2); // 移动方式
  case iType of
    // 左右上下同时移动的方式

    0:
      begin
        case iLR of
          0:
            MoveToLeft;
          1:
            MoveToRight
        end;
        case iUD of
          0:
            MoveToUp;
          1:
            MoveToDown;
        end;
        iDelay := RandomRange(3000, 4000);
        Sleep(iDelay);
        StopMove;
      end;
    // 先左右后上下的移动方式
    1:
      begin
        // 设置延时
        iLRDelay := RandomRange(3000, 4000);
        case iLR of
          0:
            MoveToLeft;
          1:
            MoveToRight;
        end;
        Sleep(iLRDelay); // 延时
        StopMoveLR;
        case iUD of
          0:
            MoveToUp;
          1:
            MoveToDown;
        end;
        // 设置移动延时
        iUDDelay := RandomRange(3000, 4000);
        Sleep(iUDDelay);
        StopMoveUD;
      end;
  end;
end;

procedure TMove.Reset;
begin
  FIsLeft := False;
  FIsRight := False;
  FIsDown := False;
  FIsUp := False;
end;

procedure TMove.ResetKeyState;
begin
  FIsLeft := False;
  FIsRight := False;
  FIsUp := False;
  FIsDown := False;
end;

procedure TMove.StopMove;
begin
  Obj.KeyUp(gdLeft);
  Sleep(50);
  Obj.KeyUp(gdRight);
  Sleep(50);
  Obj.KeyUp(gdDown);
  Sleep(50);
  Obj.KeyUp(gdUp);
  Sleep(50);
  ResetKeyState;
end;

procedure TMove.StopMoveLR;
begin
  Obj.KeyUp(gdLeft);
  Delay;
  Obj.KeyUp(gdRight);
  Delay;
  FIsLeft := False;
  FIsRight := False;

end;

procedure TMove.StopMoveUD;
begin
  Obj.KeyUp(gdUp);
  Delay;
  Obj.KeyUp(gdDown);
  Delay;
  FIsUp := False;
  FIsDown := False;
end;

initialization


finalization


end.
