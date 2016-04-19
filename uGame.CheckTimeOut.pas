unit uGame.CheckTimeOut;

interface

uses uGame.Interf, System.Diagnostics, System.Types;

type
  // �����������ʱ
  TCheckTimeOut = class(TGameBase, ICheckTimeOut)
  type
    TStopWatchEnum = (swManMove, swManFind, swMonsterFind, swInMapPickGoods,
      swInMapLong);
  private
    FStopWatchs: array [TStopWatchEnum] of TStopwatch;
    FOldManPoint: TPoint; // ��һ����������
    FOldMiniMap: TMiniMap;
  public
    constructor Create();
    // ɱ�ֳɹ����������,���߼����
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
  Result := False; // ����Ĭ��ֵ
  // �����һ�κ���һ�ε�ͼ��ͬ
  if FOldMiniMap = aMiniMap then
  begin
    // �Ƿ�����
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        GameData.GameConfig.iInMapTimeOut;
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
  FOldMiniMap := aMiniMap; // ��¼��ǰ��ͼ

end;

function TCheckTimeOut.IsInMapPickupGoodsTimeOut(
  const aMiniMap: TMiniMap): Boolean;
begin
  Result := False; // ����Ĭ��ֵ
  // �����һ�κ���һ�ε�ͼ��ͬ
  if FOldMiniMap = aMiniMap then
  begin
    // �Ƿ�����
    if FStopWatchs[swInMapPickGoods].IsRunning then
    begin
      Result := FStopWatchs[swInMapPickGoods].ElapsedMilliseconds >=
        GameData.GameConfig.iPickUpGoodsTimeOut
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
  FOldMiniMap := aMiniMap; // ��¼��ǰ��ͼ
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

end.
