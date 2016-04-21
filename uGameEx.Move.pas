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
    // �ӳٴ��� ,���ڹ��캯���лᵼ���ڴ�й¶
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
    // Ѱ�ҹ���
    procedure MoveToFindMonster(const aManPoint: TPoint;
      const aMiniMap: TMiniMap);
    // �������
    procedure MoveToMonster(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap);
    // ������
    procedure MoveToDoor(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap);
    // ����
    procedure MoveInDoor(const aKeyCode: Integer);
    // ������Ʒ
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
  // ÿ����30������������ð���״̬
  if GameData.GameConfig.bResetMoveState then
  begin
    if FStopWatch.IsRunning then
    begin
      if FStopWatch.ElapsedMilliseconds >= GameData.GameConfig.iResetMoveStateInterval
      then
      begin
        CodeSite.Send('��������30��,���и�λ');
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
      StopMoveLR; // ֹͣ�����ƶ�
    gdDownLeft:
      MoveToLeft; // ����
    gdDownRight:
      MoveToRight; // ����
  end;
  case aGameDirections.UD of
    gdUpUpAndDown:
      StopMoveUD; // ֹͣ�����ƶ�
    gdDownUp:
      MoveToUp; // ����
    gdDownDown:
      MoveToDown; // ����
  end;
  CodeSite.Write('����', 'LR:' + TRttiEnumerationType.GetName(aGameDirections.LR) +
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
  // �����Ƿ�����ƶ�
  rtMan := Rect(aManPoint.X - 100, aManPoint.Y - 100, aManPoint.X + 100,
    aManPoint.Y + 100);
  FIsFastMove := not rtMan.Contains(aDoorPoint);
  // ��ȡ����
  aGameDirections := FDirections.GetDoorDirections(aManPoint, aDoorPoint,
    aMiniMap);
  // ִ���ƶ�
  Move(aGameDirections);
  FIsFastMove := True;
end;

procedure TMove.MoveToDown;
begin
  // �������ϼ�
  if FIsUp then
  begin
    Obj.KeyUp(gdUp);
    Delay;
    FIsUp := False;
  end;
  // û�а����¼�
  if not FIsDown then
  begin
    Obj.KeyDown(gdDown);
    Delay;
    FIsDown := True; // ���ð���״̬
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
  // ����Ƿ񿿽���Ʒ,�����Ͳ���,�����߹�ȥ

  rtMan := Rect(aManPoint.X - 100, aManPoint.Y - 100, aManPoint.X + 100,
    aManPoint.Y + 100);
  FIsFastMove := not rtMan.Contains(aGoodsPoint);

  aGameDirections := FDirections.GetGoodsDirections(aManPoint, aGoodsPoint,
    aMiniMap);
  Move(aGameDirections);
  FIsFastMove := True; // �ָ��ܶ�
end;

procedure TMove.MoveToLeft;
begin
  // �����ϼ�
  if FIsRight then
  begin
    Obj.KeyUp(gdRight);
    Delay;
    FIsRight := False;
  end;
  // �������
  if not FIsLeft then
  begin
    if FIsFastMove then
    begin
      Obj.KeyPress(gdLeft); // ת��
      Sleep(120);
      Obj.KeyPress(gdLeft); // ׼����
      Sleep(80);
    end;
    Obj.KeyDown(gdLeft);
    Sleep(50);
    FIsLeft := True; // ���ð���״̬
  end;
end;

procedure TMove.MoveToMonster(const aManPoint, aMonsterPoint: TPoint;
  const aMiniMap: TMiniMap);
var
  aGameDirections: TGameDirections;
begin
  // ��ȡ����
  aGameDirections := FDirections.GetMonsterDirections(aManPoint, aMonsterPoint,
    aMiniMap);
  // ִ���ƶ�
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
  // û�а������
  if not FIsRight then
  begin
    if FIsFastMove then
    begin
      Obj.KeyPress(gdRight); // ת��
      Sleep(120);
      Obj.KeyPress(gdRight); // ׼����
      Sleep(80);
    end;
    Obj.KeyDown(gdRight);
    Delay;
    FIsRight := True; // ���ð���״̬
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
    FIsUp := True; // ���ð���״̬
  end;
end;

procedure TMove.RandomMove;
var
  iType: Integer;
  iLR, iUD: Integer;
  iDelay, iLRDelay, iUDDelay: Integer;
begin
  // ��ȡ���������  0<=x<2;
  Randomize;
  iLR := Random(2); // �����ƶ�����
  Randomize;
  iUD := Random(2); // �����ƶ�����
  Randomize;
  iType := Random(2); // �ƶ���ʽ
  case iType of
    // ��������ͬʱ�ƶ��ķ�ʽ

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
    // �����Һ����µ��ƶ���ʽ
    1:
      begin
        // ������ʱ
        iLRDelay := RandomRange(3000, 4000);
        case iLR of
          0:
            MoveToLeft;
          1:
            MoveToRight;
        end;
        Sleep(iLRDelay); // ��ʱ
        StopMoveLR;
        case iUD of
          0:
            MoveToUp;
          1:
            MoveToDown;
        end;
        // �����ƶ���ʱ
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
