unit uGameEx.CheckTimeOut;

interface

uses uGameEx.Interf, System.Diagnostics, System.Types;

type

  TStopWatchEnum = (
    swManMove,
    swManFind,
    swMonsterFind,
    swInMapPickGoodsOpened, // ֻ�������ſ���,�ڹ涨ʱ���ڽ��м���,��ֹ����
    swInMapPickGoods, // ��ͨ������,�������ſ������߹ر�״̬,��ֹ����,��ʱ��������������
    swInMapLong,
    swOutMapLong);

  // �����������ʱ
  TCheckTimeOut = class(TGameBase, ICheckTimeOut)
  private
    FStopWatchs: array [TStopWatchEnum] of TStopwatch;
    FOldManPoint: TPoint; // ��һ����������
    FOldMiniMap, FOldMiniMapOpened: TMiniMap; // ��һ��С��ͼλ��
    FOldLargeMap: TLargeMap; // ��һ�δ��ͼλ��
    FOldDoorState: Boolean;

  public
    constructor Create();
    procedure ResetManStopWatch;
    function CompareMiniMap(const aMiniMap: TMiniMap): Boolean; // �Ƚ�С��ͼ�Ƿ���ͬ
    function CompareDoorState(aDoorState: Boolean): Boolean;
    // ɱ�ֳɹ����������,���߼����
    function IsManMoveTimeOut(const aManPoint: TPoint): Boolean; // �Ƿ��ƶ���ʱ
    function IsManFindTimeOut(const aManPoint: TPoint): Boolean; // �Ƿ����˳�ʱ
    // �Ƿ��ҹֳ�ʱ
    function IsMonsterFindTimeOut(const aMonsterPoint: TPoint): Boolean;

    function IsInMapPickupGoodsOpenedTimeOut(const aMiniMap: TMiniMap): Boolean;
    function IsInMapPickupGoodsTimeOut(const aMiniMap: TMiniMap): Boolean;
    // �Ƿ���ﳬʱ
    function IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean; // �Ƿ�ͼ�ڳ�ʱ
    function IsOutMapTimeOut(const aLargeMap: TLargeMap): Boolean; // �Ƿ�ͼ�ⳬʱ
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
    FStopWatchs[I] := TStopwatch.Create; // ��ʼ����ʱ��
  end;
end;

function TCheckTimeOut.IsInMapLongTimeOut(const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // ����Ĭ��ֵ
  // �����һ�κ���һ�ε�ͼ��ͬ
  if CompareMiniMap(aMiniMap) then
  begin
    // �Ƿ�����
    if FStopWatchs[swInMapLong].IsRunning then
    begin
      Result := FStopWatchs[swInMapLong].ElapsedMilliseconds >=
        GameData.GameConfig.iInMapTimeOut;
    end
    else
    begin
      FStopWatchs[swInMapLong].Start; // ��ʼ����
    end;
  end
  else
  begin
    FStopWatchs[swInMapLong].Stop;
    FStopWatchs[swInMapLong].Reset; // �ָ�Ĭ��
  end;

end;

function TCheckTimeOut.IsInMapPickupGoodsTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // ����Ĭ��ֵ
  // �����һ�κ���һ�ε�ͼ��ͬ
  if CompareMiniMap(aMiniMap) then
  begin
    // �Ƿ�����
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        (1000 * 60 * 2);
    end
    else
    begin
      FStopWatchs[swInMapPickGoods].Start; // ��ʼ����
    end;
  end
  else
  begin
    FStopWatchs[swInMapPickGoods].Stop;
    FStopWatchs[swInMapPickGoods].Reset; // �ָ�Ĭ��
  end;
end;

function TCheckTimeOut.IsInMapPickupGoodsOpenedTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // ����Ĭ��ֵ
  // �����һ�κ���һ�ε�ͼ��ͬ
  // if FOldMiniMapOpened = aMiniMap then
  // begin
  // �Ƿ�����
  if FStopWatchs[swInMapPickGoodsOpened].IsRunning then
  begin
    Result := FStopWatchs[swInMapPickGoodsOpened].ElapsedMilliseconds >=
      GameData.GameConfig.iPickUpGoodsTimeOut
  end
  else
  begin
    FStopWatchs[swInMapPickGoodsOpened].Start; // ��ʼ����
  end;
  // end
  // else
  // begin
  // FStopWatchs[swInMapPickGoodsOpened].Stop;
  // FStopWatchs[swInMapPickGoodsOpened].Reset; // �ָ�Ĭ��
  // FOldMiniMapOpened := aMiniMap; // ��¼��һ�ε�
  // end;
end;

function TCheckTimeOut.IsManFindTimeOut(const aManPoint: TPoint): Boolean;
begin
  Result := False;
  // δ�ҵ�����,���м�ʱ����
  if aManPoint.IsZero then
  begin
    // ��ʱ�Ѿ�����
    if FStopWatchs[swManFind].IsRunning then
    begin
      // ����Ƿ�ʱ
      Result := FStopWatchs[swManFind].ElapsedMilliseconds >=
        GameData.GameConfig.iFindManTimeOut;
    end
    else
    begin
      FStopWatchs[swManFind].Start; // ��ʼ��ʱ
    end;
  end
  else
  begin
    // �ҵ�����ֹͣ��ʱ
    FStopWatchs[swManFind].Stop;
    FStopWatchs[swManFind].Reset;

  end;
end;

function TCheckTimeOut.IsManMoveTimeOut(const aManPoint: TPoint): Boolean;
begin
  Result := False;
  // �ҵ���������
  if not aManPoint.IsZero then
  begin
    // ���ϴ�����һ����ⳬʱ
    if aManPoint = FOldManPoint then
    begin
      // �������,��ⳬʱ
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
      // ���ϴ����겻��ͬ,ֹͣ��ʱ
      FStopWatchs[swManMove].Stop;
      FStopWatchs[swManMove].Reset;

    end;
    FOldManPoint := aManPoint; // ��¼��ǰ����
  end;
end;

function TCheckTimeOut.IsMonsterFindTimeOut(const aMonsterPoint
  : TPoint): Boolean;
begin
  Result := False;
  // δ���ֹ���
  if aMonsterPoint.IsZero then
  begin
    // �Ƿ�����
    if FStopWatchs[swMonsterFind].IsRunning then
    begin
      // ��ⳬʱ
      Result := FStopWatchs[swMonsterFind].ElapsedMilliseconds >=
        GameData.GameConfig.iFindMonsterTimeOut;

    end
    else
      FStopWatchs[swMonsterFind].Start;
  end
  else
  begin
    // ���ֹ���
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
      // ������ʱ����ʱ��Ϊ10����
      if IsWeak then
        Result := FStopWatchs[swOutMapLong].ElapsedMilliseconds >=
          (1000 * 60 * 10)
      else
        // �������Ϊ3����
        Result := FStopWatchs[swOutMapLong].ElapsedMilliseconds >=
          (1000 * 60 * 3);
    end
    else
      FStopWatchs[swOutMapLong].Start;
  end
  else
  begin
    FStopWatchs[swOutMapLong].Stop; // ��ͼ�ڵ�ʱ��ֹͣ��ʱ
    // FStopWatchs[swOutMapLong].Reset;
  end;

end;

procedure TCheckTimeOut.ResetManStopWatch;
begin
  FStopWatchs[swManMove].Stop;
  FStopWatchs[swManFind].Stop;
end;

end.
