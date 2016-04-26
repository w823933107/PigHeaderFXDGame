// 本单元用来获取人物所在图
unit uGame.Map;

interface

uses uGame.Interf;

type
  {
    未知地区,外围图外,外围图内
  }

  TMap = class(TGameBase, IMap)
 public
    function GetLargeMap: TLargeMap;
    function GetMiniMap: TMiniMap;

  end;

implementation

{ TMap }

function TMap.GetLargeMap: TLargeMap;
var
  iRet: Integer;
  x, y: OleVariant;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetLargeMap'); {$ENDIF}
  Result := lmUnknown;
  // 最后通过结束后的特征 (F11字)
  iRet := Obj.FindStr(708, 89, 766, 179, 'F11', StrColorOffset('e6c89b'),
    1.0, x, y);;
  if iRet <> -1 then
    Exit(lmIn);
  // 普通杀怪图的特征,翻牌时特征依旧适用
  iRet := Obj.FindStr(658, 2, 713, 29, '根特外围', StrColorOffset('ccc1a7'),
    1.0, x, y);
  if iRet <> -1 then
    Exit(lmIn);
  // 图外的特征
  iRet := Obj.FindStr(633, 14, 714, 67, '根特', StrColorOffset('e6c89b'),
    1.0, x, y);
  if iRet <> -1 then
    Exit(lmOut);
end;

function TMap.GetMiniMap: TMiniMap;
type
  // 定义坐标类
  TMapPos = record
    Map: TMiniMap;
    x, y: Integer;
  end;

const
  // 小地图有9个可识别地图
  MapPosArr: array [0 .. 9] of TMapPos = (
    (Map: mmMain1; x: 779; y: 86),
    (Map: mmMain2; x: 761; y: 86),
    (Map: mmMain3; x: 761; y: 68),
    (Map: mmMain4; x: 761; y: 50),
    (Map: mmMain5; x: 743; y: 50),
    (Map: mmMain6; x: 743; y: 68),
    (Map: mmOther1; x: 779; y: 104),
    (Map: mmOther2; x: 779; y: 122),
    (Map: mmOther3; x: 761; y: 122),
    (Map: mmOther4; x: 761; y: 104)
    );
var
  iRet: Integer;
  I: Integer;
  x, y: OleVariant;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetMiniMap'); {$ENDIF}
  Result := mmUnknown;
  // 寻找图内指针
  // 如果没找到在找BOSS图标,存在BOSS图标说明在BOSS图
  iRet := Obj.FindPic(729, 21, 798, 149, '图内指针.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  if iRet = -1 then
  begin
    iRet := Obj.FindPic(735, 72, 780, 114, 'Boss图标.bmp', clPicOffsetZero, 0.9,
      0, x, y);
    if iRet <> -1 then
      Exit(mmBoss);
  end
  else
  begin
    // 小地图数组内查找坐标所在地图
    for I := Low(MapPosArr) to High(MapPosArr) do
    begin
      if (x = MapPosArr[I].x) and (y = MapPosArr[I].y) then
      begin
        Exit(MapPosArr[I].Map);
      end;
    end;
  end;
  // 如果以上都没找到
  // 寻找翻牌特征(对比右上角红色,匹配返回0,不匹配返回1)
  iRet := Obj.CmpColor(781, 15, StrColorOffset('dc00dc'), 1.0);
  if iRet = 0 then
    Exit(mmClickCards);
  // 寻找通关特征
  // f11没有被装备栏遮住,可认为是通用特征,'是否继续'也可以是通用特征,留待以后追加
  iRet := Obj.FindStr(708, 89, 766, 179, 'F11', StrColorOffset('e6c89b'), 1.0, x, y);
  if iRet <> -1 then
    Exit(mmPassGame);
end;

end.
