unit uGame.Goods;

interface

uses uGame.Interf, System.Types, System.SysUtils;

type
  TGoods = class(TGameBase, IGoods)
  private
    const
    // ȫ����Ѱ��Χ
    rtGlobalSearch: TRect = (Left: 5; Top: 169; Right: 798; Bottom: 587);
  private
    FManPoint: TPoint;
  private
    function GetPointByRect(const aSearch: TRect): TPoint;
    function GetPointByDm: TPoint; // �����ڲ���㷨��ȡ����
    function GetPointByManPoint: TPoint; // ���������������ȡ�������
  public
    procedure SetManPoint(const value: TPoint);
    function GetIsArrivedGoods: Boolean; // �˺���ÿ�ζ�����м�ʱ���
    function GetPoint: TPoint;
    function GetIsExistGoods: Boolean;
    procedure PickupGoods;
  end;

implementation

{ TGoods }

function TGoods.GetIsArrivedGoods: Boolean;
var
  x, y: OleVariant;
  iRet: Integer;
const
  sFirstColor = 'fff000-000000';
  sColor = 'fff000,0|1|fff000,0|2|fff000';
begin
  with rtGlobalSearch do
    iRet := Obj.FindMultiColor(Left, Top, Right, Bottom, sFirstColor, sColor,
      1.0, 0, x, y);
  Result := iRet = 1;

end;

function TGoods.GetIsExistGoods: Boolean;
begin
  Result := not GetPointByRect(Rect(2, 152, 799, 557)).IsZero;
end;

function TGoods.GetPoint: TPoint;

begin
  Result := GetPointByDm;

end;

function TGoods.GetPointByDm: TPoint;
var
  sGoods: string;
  sPoint: string;
  arr: TArray<string>;
const
  sFirstColor = '0000ff-000000';
  sColor = '0000ff,1|0|ff0000,2|0|0000ff,0|1|ff0000,1|1|ff0000,0|2|0000ff,3|3|ff0000';
begin
  Result := TPoint.Zero;
  with rtGlobalSearch do
    sGoods := Obj.FindMultiColorEx(Left, Top, Right, Bottom, sFirstColor,
      sColor, 1.0, 0);
  sPoint := Obj.FindNearestPos(sGoods, 1, FManPoint.x, FManPoint.y);
  arr := sPoint.Split([',']);
  // �ܹ���ȥ70���������ҵ������Ʒ
  if Length(arr) = 2 then
    Result := Point(arr[0].ToInteger(), arr[1].ToInteger());

end;

function TGoods.GetPointByManPoint: TPoint;
var
  rtSearch: TRect;
const
  sFirstColor = '0000ff-000000';
  sColor = '0000ff,1|0|ff0000,2|0|0000ff,0|1|ff0000,1|1|ff0000,0|2|0000ff,3|3|ff0000';
begin
  Result := TPoint.Zero;
  // ���ڽ���ѭ���������ﷶΧѰ��
  if GetIsExistGoods then
  begin
    rtSearch := TRect.Create(
      FManPoint.x - 25,
      FManPoint.y - 25,
      FManPoint.x + 25,
      FManPoint.y + 25);
    while not Terminated do
    begin

      // ���������Ѱ��Χ���˳�
      if (rtSearch.Left <= 0) and (rtSearch.Right >= 800) then
        Break;
      rtSearch.DmNormalizeRect; // �淶����Χ
      Result := GetPointByRect(rtSearch);
      // �ҵ���Ʒ����
      if not Result.IsZero then
        Break;
      // ���췶Χ
      rtSearch.Inflate(25, 25);
      // �Ƿ���Ҫ�����ʱ��
    end;

  end;

end;

function TGoods.GetPointByRect(const aSearch: TRect): TPoint;
var
  x, y: OleVariant;
  iRet: Integer;
const
  sFirstColor = '0000ff-000000';
  sColor = '0000ff,1|0|ff0000,2|0|0000ff,0|1|ff0000,1|1|ff0000,0|2|0000ff,3|3|ff0000';
begin
  Result := TPoint.Zero;
  with aSearch do
    iRet := Obj.FindMultiColor(Left, Top, Right, Bottom, sFirstColor, sColor,
      1.0, 0, x, y);
  if iRet = 1 then
  begin
    Result := Point(x, y);
  end;

end;

procedure TGoods.PickupGoods;
begin
  Obj.KeyPressStr('x', 50);
  Obj.KeyPressStr('x', 50);
end;

procedure TGoods.SetManPoint(const value: TPoint);
begin
  if FManPoint <> value then
    FManPoint := value;
end;

end.
