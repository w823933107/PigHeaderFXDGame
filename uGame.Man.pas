unit uGame.Man;

interface

uses uGame.Interf, System.Types;

type
  TMan = class(TGameBase, IMan)
  private
    FPoint: TPoint;
  public
    function GetPoint: TPoint;
    function GetRect: TRect;
  end;

implementation

uses CodeSiteLogging;
{ TMan }

function TMan.GetPoint: TPoint;
var
  sManName: string;
  iRet: Integer;
  arrOffsetX: TArray<TStrOffset>;
  x, y: OleVariant;
begin
  FPoint := TPoint.Zero;
  sManName := GameData.RoleInfo.NameWithDec;
  arrOffsetX := GameData.RoleInfo.CenterXOffset;
  iRet := Obj.FindStr(0, 135, 800, 600, sManName, GameData.ManStrColor,
    1.0, x, y);
  if iRet > -1 then
  begin
    FPoint.x := x + arrOffsetX[iRet].OffsetX;
    FPoint.y := y + GameData.RoleInfo.CenterYOffset;
  end;
  Result := FPoint;
  CodeSite.Write('ÈËÎï×ø±ê', Result);
end;

function TMan.GetRect: TRect;
const
  iWith = 46;
  iHeight = 30;
begin
  Result := TRect.Empty;
  Result := TRect.Create(
    FPoint.x - iWith,
    FPoint.y - iHeight,
    FPoint.x + iWith,
    FPoint.y + iHeight);
  CodeSite.Write('ManRect', Result);
end;

end.
