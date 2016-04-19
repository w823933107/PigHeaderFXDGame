{
  利润:
  利用获取的陨石换取便宜的粉装进行分解,可获得高额的上级元素结晶
  粉装分解,上级元素结晶,有几率获得50W-60几金币价值,人民币1元
  有可能获得流光星陨刀150W,人民币3元


  特征:
  *德利拉状态可以直接按键继续或返回城镇操作
  *加百利状态不可直接按按键操作

}
unit uGame.PassGame;

interface

uses uGame.Interf, Spring, System.Types, System.SysUtils, CodeSiteLogging;

type

  TBox = class(TGameBase, IBox)
  private const
    sNotCheckStrColor = 'ddc593-000000'; // 未选中的颜色
    sCheckStrColor = 'ffffb8'; // 选中的颜色
    sOffsetStrColor = 'ffffb8-505050'; // 装备那闪烁的颜色
    sColorZhuangBei普通 = 'ffffff';
    sColorZhuangBei高级 = '68d5ed';
    sColorZhuangBei稀有 = 'b36bff';
    sColorZhuangBei神器 = 'ff00ff';
    sColorZhuangBei传承 = 'b36bff';
    sColorZhuangBei勇者 = 'ff6666';
    sColorZhuangBei传说 = 'ff7800';
    sColorZhuangBei史诗 = 'ffb400';
    sColorZhuangBeiAll =
      'ffffff-000100|68d5ed-000100|b36bff-000100|ff00ff-000100|ff6666-000100|ff7800-000100|ffb400-000100';
    sColorZhuangBei无法交易 = 'ff3232-000100'; // 无法交易及无法穿戴的颜色
    sColorZhuangBei封装 = 'ffffff-000100|ff3232-000100';
  private
    FBasePoint: TPoint;
    function GetBasePoint: TPoint;
    function GetPoints: Vector<TPoint>;
  public
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

  TPassGame = class(TGameBase, IPassGame)
  private
    FBox: IBox;
  public
    constructor Create();
    destructor Destroy; override;
    procedure Handle;
  end;

  TSell = class(TGameBase)

  end;

implementation

{ TBox }

function TBox.Close: Boolean;

var
  x, y: OleVariant;
begin
  FBasePoint := TPoint.Zero;
  Result := False;
  while not Terminated do
  begin
    Result := Obj.FindStr(411, 9, 773, 107, '装备栏', clStrWhite, 1.0, x,
      y) = -1;
    if not Result then
      Obj.KeyPressStr('i', 500)
    else
      Break;
  end;
end;

function TBox.GetBasePoint: TPoint;
begin
  Result := FBasePoint;
end;

function TBox.GetPoints: Vector<TPoint>;
var
  I, J: Integer;
begin
  for I := 0 to 6 do
  begin
    for J := 0 to 7 do
    begin
      Result.Add(Point(FBasePoint.x + J * 28, FBasePoint.y + I * 28))
    end;
  end;
end;

function TBox.GetZhuangbeiPercentage: Integer;
var
  iNum: Integer;
begin
  // 108  iNum
  // 100  result
  // result=iNum*100/108
  iNum := Obj.GetColorNum(424, 419, 723, 535, 'd62929-111111', 1.0);
  Result := (iNum * 100) div 94;
end;

function TBox.GetZhuangbeiType: TZhuangbeiType;
var
  x, y: OleVariant;
begin
  Result := zt未知;
  if Obj.FindStr(188, 8, 793, 595, '普通', StrColorOffset(sColorZhuangBei普通), 1.0,
    x, y) <> -1
  then
    Result := zt普通
  else if Obj.FindStr(188, 8, 793, 595, '高级', StrColorOffset(sColorZhuangBei高级),
    1.0, x, y)
    <> -1 then
    Result := zt高级
  else if Obj.FindStr(188, 8, 793, 595, '稀有', StrColorOffset(sColorZhuangBei稀有),
    1.0, x, y)
    <> -1 then
    Result := zt稀有
  else if Obj.FindStr(188, 8, 793, 595, '神器', StrColorOffset(sColorZhuangBei神器),
    1.0, x, y)
    <> -1 then
    Result := zt神器
  else if Obj.FindStr(188, 8, 793, 595, '传承', StrColorOffset(sColorZhuangBei传承),
    1.0, x, y)
    <> -1 then
    Result := zt传承
  else if Obj.FindStr(188, 8, 793, 595, '勇者', StrColorOffset(sColorZhuangBei勇者),
    1.0, x, y)
    <> -1 then
    Result := zt勇者
  else if Obj.FindStr(188, 8, 793, 595, '传说', StrColorOffset(sColorZhuangBei传说),
    1.0, x, y)
    <> -1 then
    Result := zt传说
  else if Obj.FindStr(188, 8, 793, 595, '史诗', StrColorOffset(sColorZhuangBei史诗),
    1.0, x, y)
    <> -1 then
    Result := zt史诗;
end;

function TBox.IsFengZhuang: Boolean;
var
  x, y: OleVariant;
begin
  Result := Obj.FindStr(188, 8, 793, 595, '无法交易',
    StrColorOffset('808080'), 1.0, x, y) = -1;
  if not Result then
    Result := Obj.FindStr(188, 8, 793, 595, '封装', clStrWhite, 1.0, x, y) <> -1;
end;

function TBox.IsFuZhong: Boolean;
var
  iCurPer: Integer;
begin
  iCurPer := GetZhuangbeiPercentage;
  Result := iCurPer >= GameData.GameConfig.imaxZhuangbeiNum;
end;

function TBox.IsHaveZhuangbei: Boolean;
var
  x, y: OleVariant;
begin
  Result := Obj.FindStr(188, 8, 793, 595, '称号|武器|手镯|项链|戒指|头肩|上衣|下装|腰带|鞋',
    clStrWhite, 1.0, x, y) <> -1;
  if not Result then
  begin
    Result := Obj.FindStr(188, 8, 793, 595, '辅助装备|魔法石',
      StrColorOffset('ff3232'), 1.0, x, y) <> -1;
  end;
end;

function TBox.Open: Boolean;
var
  x, y: OleVariant;
begin
  Result := False;
  FBasePoint := TPoint.Zero;
  while not Terminated do
  begin
    Result := Obj.FindStr(411, 9, 773, 107, '装备栏',
      clStrWhite { 结尾时会重复打开两次,原因特征被f10挡住了 } , 1.0, x,
      y) <> -1;
    if not Result then
      Obj.KeyPressStr('i', 500)
    else
    begin
      FBasePoint := TPoint.Create(x, y);
      FBasePoint.Offset(-94 + 13, 214 + 13);
      Break;
    end;
  end;

end;

function TBox.OpenZhuangbei: Boolean;
var
  x, y: OleVariant;
begin
  Result := False;
  if Open then
  begin
    while not Terminated do
    begin
      Result := Obj.FindStr(472, 221, 535, 324, '装备',
        StrColorOffset(sCheckStrColor), 1.0, x, y) <> -1;
      if Result then
        Break;
      if Obj.FindStr(472, 221, 535, 324, '装备', sOffsetStrColor, 1.0, x, y)
        <> -1
      then
      begin
        Obj.MoveTo(x, y);
        Sleep(200);
        Obj.LeftClick;
        Sleep(500);
        MoveToFixPoint;
      end;

    end;

  end;

end;

procedure TBox.ZhengLi;
var
  x, y: OleVariant;
begin
  if Obj.FindStr(428, 345, 775, 556, '整理', sNotCheckStrColor, 1.0, x, y) <> -1
  then
  begin
    Obj.MoveTo(x, y);
    Obj.LeftClick;
    Sleep(100);
    Obj.LeftClick;
    Sleep(500);
  end;
end;

{ TPassGame }

constructor TPassGame.Create;
begin
  FBox := TBox.Create;
end;

destructor TPassGame.Destroy;
begin
  FBox := nil;
  inherited;
end;

procedure TPassGame.Handle;
var
  sellX, sellY: OleVariant; // '出售'的坐标
  // 是否发现'出售'
  function IsFindSell: Boolean;
  // var
  // x, y: OleVariant;
  begin
    Result := Obj.FindStr(28, 439, 350, 560, '出售', StrColorOffset('ddc593'), 1.0,
      sellX, sellY) <> -1;
    inc(sellX, 9);
    dec(sellY, 29);
  end;
// 粉装处理
  procedure FenZhuangHandle;
  var
    iRet: Integer;
    x, y: OleVariant;
  begin
    iRet := Obj.FindPic(50, 339, 300, 496, '秘密商店.bmp', clPicOffsetZero,
      0.8, 0, x, y);
    if iRet > -1 then
    begin
      // 报警
      if GameData.GameConfig.bJiabaliWarning then
        warnning;
    end;
  end;
// 出售装备
  procedure SellZhuangbei;
  var
    ptMove: TPoint;
  begin
    if FBox.OpenZhuangbei then
    begin
      if FBox.IsFuZhong then
      begin
        // 整理
        FBox.ZhengLi;
        // 出售装备
        for ptMove in FBox.Points do
        begin

          Obj.MoveTo(ptMove.x, ptMove.y);
          Sleep(300);

          if not FBox.IsHaveZhuangbei then
          begin
            Break;
          end;
          if FBox.GetZhuangbeiType = zt神器 then
          begin
            Continue;
          end;
          Obj.LeftDown;
          Sleep(200);
          Obj.MoveTo(sellX, sellY);
          Sleep(200);
          Obj.LeftUp;
          Sleep(200);
          Obj.LeftDoubleClick;
          Sleep(200);
        end;
      end;
    end;
  end;
// 关闭窗口
  procedure CloseWindows;
  begin
    Obj.KeyPressChar('esc');
    Sleep(500);
    // Obj.KeyPressChar('esc');
    // Sleep(200);
  end;
// 继续下一关
  procedure ContinueNext;
  begin
    if IsNotHasPilao then
    begin
      // warnning;
      CodeSite.Send('返回城镇');
      Obj.KeyPressChar('f12');
      Sleep(1000);
    end;
    CodeSite.Send('继续下一关');
    Obj.KeyPressChar('f10');
    Sleep(1000);
  end;
// 修理
  procedure Repair;
  begin
    if GameData.GameConfig.bRepair then
    begin
      Obj.KeyPressChar('s');
      Sleep(100);
      Obj.KeyDownChar('enter');
      Sleep(500);
    end;
  end;

begin
  // 发现出售
  // 检测是否有粉装
  // 检测是否负重
  // 负重执行卖物
  // 卖物完毕,关闭所有窗口
  // 点击执行下一关

  while not Terminated do
  begin
    if IsFindSell then
    begin
      Sleep(500);
      // 发现出售
      // 粉装处理
      FenZhuangHandle;
      // 卖装备
      SellZhuangbei;
      // 修理装备
      Repair;
      // 关闭所有窗口
      CloseWindows;
      CloseGameWindows;
    end
    else
    begin
      ContinueNext;
      Break;
    end;
  end;
end;

end.
