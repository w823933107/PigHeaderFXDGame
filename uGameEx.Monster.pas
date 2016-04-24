unit uGameEx.Monster;

interface

uses uGameEx.Interf, System.Types, System.Diagnostics, CodeSiteLogging;

type

  TFindMonsterType = (fmtUnknown, fmtColor, fmtPic, fmtSpecialColor, fmtStr,
    fmtBossStr);

  TMonster = class(TGameBase, IMonster)
  private
    const
    // 全局找怪范围
    cGlobalMonsterRect: TRect = (Left: 0; Top: 110; Right: 800; Bottom: 556);
  private
    FManPoint: TPoint;
    FIsFindBoss: Boolean;
    FBossPoint: TPoint;
    FMonsterPoint: TPoint;
    FFindMonsterType: TFindMonsterType;
  private
    function FindMonsterByColor(aRect: TRect): TPoint; // 根据普通颜色找怪物
    function FindMonsterByPic(aRect: TRect): TPoint; // 根据图片找怪物,那个会炸的怪物
    function FindMonsterBySpecialColor(aRect: TRect): TPoint; // 根据特殊颜色找怪物
    function FindMonsterByStr(aRect: TRect): TPoint; // 根据字找怪物
    function FindMonsterByBossStr(aRect: TRect): TPoint; // 根据Boss名字找怪物;
    function GetMonstrStrPoint(aRect: TRect): TPoint; // 获取枪手名字坐标
    // 综合以上函数寻找怪物坐标
    function FindMonster(aRect: TRect): TPoint;
  public
    function GetPoint: TPoint;
    procedure SetManPoint(const value: TPoint);
    function GetIsExistMonster: Boolean;
    function IsArriviedMonster(var aMonsterPoint: TPoint): Boolean; // 返回坐标
  end;

implementation

{ TMonster }

function TMonster.FindMonster(aRect: TRect): TPoint;
begin
  repeat
    Result := TPoint.Zero;
    FFindMonsterType := fmtUnknown;
    FMonsterPoint := TPoint.Zero;
    Result := FindMonsterByBossStr(aRect);
    // 寻找Boss
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtBossStr;
      Break;
    end;
    // 寻找字怪
    Result := FindMonsterByStr(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtStr;
      Break;
    end;

    // 寻找普通颜色怪
    Result := FindMonsterByColor(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtColor;
      Break;
    end;

    // 寻找图片怪
    Result := FindMonsterByPic(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtPic;
      Break;
    end;

    // 寻找特殊颜色怪
    Result := FindMonsterBySpecialColor(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtSpecialColor;
      Break;
    end;

  until (True);
  FMonsterPoint := Result;
end;

function TMonster.FindMonsterByBossStr(aRect: TRect): TPoint;
var
  iIndex: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  iIndex := Obj.FindStr(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom, '', '',
    1.0, x, y);
  if iIndex <> -1 then
  begin
    // 偏移x
    case iIndex of
      0:
        Inc(x, 58); // 领
      1:
        Inc(x, 42); // 主
      2:
        Inc(x, 17); // 纵
      3:
        Inc(x, 3); // 火
      4:
        Inc(x, -11); // 犯
      5:
        Inc(x, -23); // 本
      6:
        Inc(x, -33); // 汀
      7:
        Inc(x, -46); // 克

    end;
    Inc(y, 43); // 偏移y
    Result := Point(x, y);
  end;

end;

function TMonster.FindMonsterByColor(aRect: TRect): TPoint;

const
  sNormalColor = '6b00f7-303030'; // 普通怪颜色
  // 坐标颜色点集合
  // sColors =
  // '6b00f7-303030,1|0|6b00f7-303030,2|0|6b00f7-303030,1|1|6b00f7-303030';
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  // iRet := Obj.FindMultiColor(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
  // sNormalColor, sColors,
  // 1.0, 0, x, y);
  iRet := Obj.FindColorBlock(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
    sNormalColor, 1.0, 60, 12, 5, x, y);
  if iRet = 1 then
  begin
    Result := Point(x, y);
  end;

end;

function TMonster.FindMonsterByPic(aRect: TRect): TPoint;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  iRet := Obj.FindPic(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
    '机器(左).bmp|机器(右).bmp', clPicOffsetZero, 0.9, 0, x, y);
  if iRet > -1 then
  begin
    Result := Point(x + 10, y + 44);
  end;

end;

function TMonster.FindMonsterBySpecialColor(aRect: TRect): TPoint;
const
  sColor = 'ff0094-303030';
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  iRet := Obj.FindColorBlock(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
    sColor,
    1.0, 8, 8, 60, x, y);
  if iRet = 1 then
  begin
    Result := Point(x, y);
  end;

end;

function TMonster.FindMonsterByStr(aRect: TRect): TPoint;
const
  sName = '炙|炎|魔|团|员';
  sColor = 'b3b3b3';
  sNameEx = '我们是|无法地|带的弹|药手';
  sColorEx = clStrWhite;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  iRet := Obj.FindStr(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom, sName,
    StrColorOffset(sColor), 1.0, x, y);
  if iRet > -1 then
  begin
    case iRet of
      0:
        Inc(x, 20); // 炙
      1:
        Inc(x, 7); // 炎
      2:
        Inc(x, -6); // 魔
      3:
        Inc(x, -18); // 团
      4:
        Inc(x, -44); // 员
    end;
    Inc(y, 172); // 加上y的偏差
    Result := Point(x, y);
  end
  else
  begin
    iRet := Obj.FindStr(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
      sNameEx,
      StrColorOffset(sColorEx), 1.0, x, y);
    if iRet > -1 then
    begin
      case iRet of
        0: { 我们是|无法地|带的弹|药手 }
          Inc(x, 42); // 我们是
        1:
          Inc(x, 4); // 无法地
        2:
          Inc(x, -29); // 带的弹
        3:
          Inc(x, -63); // 药手
      end;
      Inc(y, 189);
      Result := Point(x, y);
    end;

  end;
end;

function TMonster.IsArriviedMonster(var aMonsterPoint: TPoint): Boolean;
var
  rtSearch: TRect;
  ptMonster: TPoint;
begin
  Result := False;
  // 先设置下寻找机枪手的范围,因为伤害厉害要优先杀死
  rtSearch := Rect(FManPoint.x - 170, FManPoint.y - 80, FManPoint.x + 170,
    FManPoint.y + 40);
  // rtSearch := Rect(FManPoint.x - 180, FManPoint.y - 100, FManPoint.x + 180,
  // FManPoint.y + 50);
  // 设置机枪手范围
  rtSearch.Offset(0, -170);
  // rtSearch.Inflate(60, 40);
  rtSearch.DmNormalizeRect;
  CodeSite.Send('人物搜索机枪手怪物范围', rtSearch);
  { TODO -c优化 : 是否到达怪物,搜寻类型不同,需要优化 }
  // ptMonster := FindMonsterByStr(rtSearch);   //这是个BUG,他获取的是枪手脚底怪物坐标,本身已经偏移了
  ptMonster := GetMonstrStrPoint(rtSearch);
  if ptMonster.IsZero then
  begin
    // 还原范围
    rtSearch.Offset(0, 170);
    // rtSearch.Inflate(-60, -40);
    rtSearch.DmNormalizeRect;
    // 如果范围内没找到怪物,那么寻找字和图的怪物坐标,看看是否在范围内
    ptMonster := FindMonster(rtSearch);
    if ptMonster.IsZero then
    begin
      CodeSite.Send('人物范围内未搜索到怪物,执行范围坐标对比');
      ptMonster := FindMonster(cGlobalMonsterRect);
      // 如果找到坐标
      if not ptMonster.IsZero then
      begin
        if rtSearch.Contains(ptMonster) then
        begin
          CodeSite.Send('对比成功,怪物坐标在人物范围内');
          Result := True;
        end
        else
          CodeSite.Send('对比失败,怪物坐标未在人物范围内');
      end;
    end
    else
    begin
      CodeSite.Send('人物坐标范围内搜索到怪物');
      Result := True;
    end;
  end
  else
  begin
    CodeSite.Send('人物坐标范围内搜索到机枪手怪物范围');
    Result := True;
  end;
  if Result then
    aMonsterPoint := ptMonster
  else
    aMonsterPoint := TPoint.Zero;
end;

function TMonster.GetIsExistMonster: Boolean; // 0, 110, 800, 556

begin
  Result := not FindMonster(cGlobalMonsterRect).IsZero; // 非0返回true
end;

function TMonster.GetMonstrStrPoint(aRect: TRect): TPoint;
const
  sName = '炙|炎|魔|团|员';
  sColor = 'b3b3b3';
  sNameEx = '我们是|无法地|带的弹|药手';
  sColorEx = clStrWhite;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := TPoint.Zero;
  iRet := Obj.FindStr(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom, sName,
    StrColorOffset(sColor), 1.0, x, y);
  if iRet > -1 then
  begin
    Result.x := x;
    Result.y := y;
  end
  else
  begin
    iRet := Obj.FindStr(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom,
      sNameEx, StrColorOffset(sColor), 1.0, x, y);
    if iRet > -1 then
    begin
      Result.x := x;
      Result.y := y;
    end;
  end;
end;

function TMonster.GetPoint: TPoint;

var
  rtSearch: TRect;
begin
  repeat
    Result := TPoint.Zero;
    // 是否存在怪物
    if GetIsExistMonster then
    begin
      // 是否发现Boss或者机枪手
      if FFindMonsterType in [fmtBossStr, fmtStr] then
      begin
        Result := FMonsterPoint;
        Break;
      end;

      // 进行人物往外扩展寻怪
      // 设置搜索初始化范围
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
        Result := FindMonster(rtSearch);
        // 找到怪物跳出
        if not Result.IsZero then
          Break;
        // 拉伸范围
        rtSearch.Inflate(25, 25);
        // 是否需要添加延时呢
      end;
    end;
  until (True);
  CodeSite.Write('怪物坐标', Result);
end;

procedure TMonster.SetManPoint(const value: TPoint);
begin
  FManPoint := value;
end;

initialization


finalization


end.
