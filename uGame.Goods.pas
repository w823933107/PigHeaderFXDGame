unit uGame.Goods;

interface

uses uGame.Interf, System.Types, System.SysUtils;

type
  TGoods = class(TGameBase, IGoods)
  private
    const
    // 全局搜寻范围
    rtGlobalSearch: TRect = (Left: 5; Top: 169; Right: 798; Bottom: 587);
  private
    FManPoint: TPoint;
  private
    function GetPointByRect(const aSearch: TRect): TPoint;
    function GetPointByDm: TPoint; // 依赖于插件算法获取坐标
    function GetPointByManPoint: TPoint; // 依赖于人物坐标获取最近坐标
  public
    procedure SetManPoint(const value: TPoint);
    function GetIsArrivedGoods: Boolean; // 此函数每次都会进行计时检测
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
  // 总共花去70毫秒左右找到最近物品
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
  // 存在进行循环扩充人物范围寻找
  if GetIsExistGoods then
  begin
    rtSearch := TRect.Create(
      FManPoint.x - 25,
      FManPoint.y - 25,
      FManPoint.x + 25,
      FManPoint.y + 25);
    while not Terminated do
    begin

      // 如果超出搜寻范围就退出
      if (rtSearch.Left <= 0) and (rtSearch.Right >= 800) then
        Break;
      rtSearch.DmNormalizeRect; // 规范化范围
      Result := GetPointByRect(rtSearch);
      // 找到物品跳出
      if not Result.IsZero then
        Break;
      // 拉伸范围
      rtSearch.Inflate(25, 25);
      // 是否需要添加延时呢
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
