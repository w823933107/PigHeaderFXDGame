unit uGameEx.Door;

interface

uses uGameEx.Interf, System.Types, CodeSiteLogging;

type
  TDoor = class(TGameBase, IDoor)
  private
    FMiniMap: TMiniMap;
    FManPoint: TPoint;
  public
    // 只写数据设置
    procedure SetMiniMap(const value: TMiniMap);
    procedure SetManPoint(const value: TPoint);

    function GetIsOpen: Boolean;
    function GetIsClose: Boolean;
    function GetPoint: TPoint;
    function GetKeyCode: Integer;
    function GetIsArrviedDoor: Boolean;

  end;

implementation

{ TDoor }

function TDoor.GetIsArrviedDoor: Boolean;
var
  ptDoor: TPoint;
begin
  Result := False;
  ptDoor := GetPoint;
  // 找到门坐标
  if not ptDoor.IsZero then
  begin
    // 判断人物是否在圆圈内
    Result := TPoint.PointInCircle(FManPoint, ptDoor, 30);
  end;
end;

function TDoor.GetIsClose: Boolean;
var
  x, y: OleVariant;
const
  sColorDoorClose = 'fff700-000100'; // 门关闭时的颜色
begin
  Result := Obj.FindColorBlock(0, 0, 800, 600, sColorDoorClose, 1.0, 40, 8,
    5, x, y) = 1;

end;

function TDoor.GetIsOpen: Boolean;
const
  sColorDoorOpen = '5ac500-000100|00ff00-000100'; // 门开启时的颜色
  sColor = '00ff00-000100|5ac500-000100,1|0|00ff00-000100|5ac500-000100,0|1|00ff00-000100|5ac500-000100,1|1|00ff00-000100|5ac500-000100';
var
  x, y: OleVariant;
begin
  Result := False;
  if Obj.FindColorBlock(0, 0, 800, 600, sColorDoorOpen, 1.0, 40, 8, 5, x, y) = 1
  then
    // 多点查找门开启的颜色值
    // if Obj.FindMultiColor(0, 0, 800, 600, sColorDoorOpen, sColor, 1.0, 0, x,
    // y) = 1 then
    Result := True
  else
    // 查找问号,找到了说明门开了
    if Obj.FindPic(719, 23, 798, 144, '问号.bmp', clPicOffsetZero, 0.9, 0, x, y)
      <> -1 then
      Result := True;
end;

function TDoor.GetKeyCode: Integer;
begin
  case FMiniMap of
    mmMain1:
      Result := gdLeft;
    mmMain2:
      Result := gdUp;
    mmMain3:
      Result := gdUp;
    mmMain4:
      Result := gdLeft;
    mmMain5:
      Result := gdDown;
    mmMain6:
      Result := gdDown;
    mmOther1:
      Result := gdUp;
    mmOther2:
      Result := gdUp;
    mmOther3:
      Result := gdUp;
    mmOther4:
      Result := gdUp;
  else
    // 默认往左
    Result := gdLeft;
  end;
end;

function TDoor.GetPoint: TPoint;
var
  x, y: OleVariant;
  iRet: Integer;
begin
  Result := TPoint.Zero;
  case FMiniMap of
    mmMain1:
      begin
        iRet := Obj.FindPic(457, 43, 719, 240, '那.bmp', clPicOffsetZero,
          1.0, 0, x, y);
        if iRet > -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-463, 266);
        end;
      end;
    mmMain2:
      begin
        // 先找'J',找不到再去寻找左边的'还'字
        iRet := Obj.FindPic(39, 113, 736, 423, 'J.bmp', clPicOffsetZero,
          1.0, 0, x, y);
        if iRet > -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-300, 165);
        end
        else
        begin
          iRet := Obj.FindPic(54, 43, 623, 212, '还.bmp', clPicOffsetZero,
            1.0, 0, x, y);
          if iRet > -1 then
          begin
            Result := TPoint.Create(x, y);
            Result.Offset(-108, 275);
          end;
        end;
      end;
    mmMain3:
      begin
        // 先找'H',找不到再去寻找第一个'还'字
        // 找H
        iRet := Obj.FindPic(4, 26, 798, 440, 'H.bmp', clPicOffsetZero, 1.0,
          0, x, y);
        if iRet > -1
        then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(305, 170);
        end
        else
        begin
          // 找一个'还'字
          iRet := Obj.FindPic(244, 30, 644, 336, '还.bmp', clPicOffsetZero,
            1.0, 0, x, y);
          if iRet > -1 then
          begin
            Result := TPoint.Create(x, y);
            Result.Offset(344, 296);
          end;
        end;
      end;
    mmMain4:
      begin
        // 第二个希字
        iRet := Obj.FindPic(82, 128, 629, 266, '希.bmp', clPicOffsetZero,
          1.0, 0, x, y);
        if iRet > -1
        then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-302, 280);
        end;
      end;
    mmMain5:
      begin
        // 第一个'那'字
        iRet := Obj.FindPic(253, 67, 498, 282, '那.bmp', clPicOffsetZero,
          1.0, 0, x, y);
        if iRet > -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-10, 387);
        end;
      end;
    mmMain6:
      begin
        // 第一个'希'字
        iRet := Obj.FindPic(442, 61, 797, 247, '希.bmp', clPicOffsetZero,
          1.0, 0, x, y);
        if iRet <> -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-35, 375);
        end;

      end;
    mmOther1:
      begin
        // 第一个'希'字
        iRet := Obj.FindPic(168, 31, 621, 121, '希.bmp', clPicOffsetZero, 1.0,
          0, x, y);
        if iRet <> -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(347, 282);
        end;
      end;
    mmOther2:
      begin
        // 第一个'H'字
        iRet := Obj.FindPic(177, 187, 645, 387, 'H.bmp', clPicOffsetZero, 1.0,
          0, x, y);
        if iRet <> -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(293, 141);
        end;
      end;
    mmOther3:
      begin
        // 右边'希'字
        iRet := Obj.FindPic(325, 26, 799, 236, '希.bmp', clPicOffsetZero, 1.0,
          0, x, y);
        if iRet <> -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-110, 284);
        end;
      end;
    mmOther4:
      begin
        // 第一个'希'字
        iRet := Obj.FindPic(142, 25, 449, 227, '希.bmp', clPicOffsetZero, 1.0,
          0, x, y);
        if iRet <> -1 then
        begin
          Result := TPoint.Create(x, y);
          Result.Offset(-113, 284);
        end;
      end;
  end;

end;

procedure TDoor.SetManPoint(const value: TPoint);
begin
  if value <> FManPoint then
    FManPoint := value;
end;

procedure TDoor.SetMiniMap(const value: TMiniMap);
begin
  if FMiniMap <> value then
    FMiniMap := value;

end;

initialization


finalization


end.
