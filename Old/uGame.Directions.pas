// 处理方向 ,涉及到障碍物的获取
// 本单元需要着重维护
unit uGame.Directions;

interface

uses uGame.Interf, System.Types, CodeSiteLogging, System.SysUtils;

type
  TDirections = class(TGameBase, IDirections)
  private
    // 寻找怪物方向
    FIsArrivedLeft: Boolean;
    FIsArrviedRight: Boolean;
    FIsArrvideUp: Boolean;
    FIsArrvideDown: Boolean;

    FTargetPoint: TPoint; // 目标坐标,用来对比目标在障碍的方向
  private
    FManRect: TRect; // 人物范围
    procedure CreateManRect(const aManPoint: TPoint);

  private
    // 获取目标在障碍的方向
    function GetTargetDirection(const aTarget: TPoint;
      const aBarrierRect: TRect): string;
    // 障碍处理后的方向
    procedure BarrierGameDirections(const aManPoint: TPoint;
      const aMiniMap: TMiniMap;
      var aGameDirections: TGameDirections);
    // 每个图的障碍处理
    procedure BarrierGameDirections_Boss(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main1(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main2(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main3(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main4(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main5(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Main6(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Other1(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Other2(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Other3(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
    procedure BarrierGameDirections_Other4(const aManPoint: TPoint;
      var aGameDirections: TGameDirections);
  public
    // 获取怪物方向
    function GetMonsterDirections(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // 获取寻找怪物方向
    function GetFindMonsterDirections(const aManPoint: TPoint;
      aMiniMap: TMiniMap): TGameDirections;
    // 获取门方向
    function GetDoorDirections(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // 获取物品方向
    function GetGoodsDirections(const aManPoint, aGoodsPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;

  public
    destructor Destroy; override;
  end;

implementation


{ TDirections }

procedure TDirections.BarrierGameDirections(const aManPoint: TPoint;
  const aMiniMap: TMiniMap; var aGameDirections: TGameDirections);
begin
  case aMiniMap of
    mmBoss:
      begin
        BarrierGameDirections_Boss(aManPoint, aGameDirections);
      end;
    mmMain1:
      begin
        BarrierGameDirections_Main1(aManPoint, aGameDirections);
      end;
    mmMain2:
      begin
        BarrierGameDirections_Main2(aManPoint, aGameDirections);
      end;
    mmMain3:
      begin
        BarrierGameDirections_Main3(aManPoint, aGameDirections);
      end;
    mmMain4:
      begin
        BarrierGameDirections_Main4(aManPoint, aGameDirections);
      end;
    mmMain5:
      begin
        BarrierGameDirections_Main5(aManPoint, aGameDirections);
      end;
    mmMain6:
      begin
        BarrierGameDirections_Main6(aManPoint, aGameDirections);
      end;
    mmOther1:
      begin
        BarrierGameDirections_Other1(aManPoint, aGameDirections);
      end;
    mmOther2:
      begin
        BarrierGameDirections_Other2(aManPoint, aGameDirections);
      end;
    mmOther3:
      begin
        BarrierGameDirections_Other3(aManPoint, aGameDirections);
      end;
    mmOther4:
      begin
        BarrierGameDirections_Other4(aManPoint, aGameDirections);
      end;
  end;
end;

procedure TDirections.BarrierGameDirections_Boss(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
begin

end;

procedure TDirections.BarrierGameDirections_Main1(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  iRet: Integer;
  r1, // 上面左边那个
  r2, // 上面右边
  r2_1, // 上面右边处理
  r3, // 上面下边
  r4, // 下面左边
  r4_1, // 下面左边处理
  r5, // 下面右边
  r5_1, // 下面右边处理
  r6, // 下面上边
  r7 // 下面下边
    : TRect;
begin
  // 右边的那字
  iRet := Obj.FindPic(457, 43, 719, 240, '那.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // 上面左边那个
    r1 := TRect.Create(x - 210, y + 193, x - 110, y + 287);
    // 上面右边那个
    r2 := TRect.Create(x - 131, y + 173, x - 27, y + 287);
    r2_1 := TRect.Create(x - 131, y + 173, x - 41, y + 253);
    // 上面下边那个
    r3 := TRect.Create(x - 154, y + 280, x - 67, y + 297);
    // 下面左边那个
    r4 := TRect.Create(x - 93, y + 322, x + 42, y + 419);
    // 下面左边处理
    r4_1 := TRect.Create(x - 63, y + 330, x + 22, y + 419);
    // 下面右边那个
    r5 := TRect.Create(x, y + 296, x + 97, y + 419);
    r5_1 := TRect.Create(x, y + 298, x + 85, y + 400);
    // 下面上边那个
    r6 := TRect.Create(x - 70, y + 322, x + 113, y + 345);
    // 下面的下边
    r7 := TRect.Create(x, y + 419, x + 115, y + 438);
  end;
  if iRet = -1 then
    Exit;
{$REGION '上面上部处理'}
  // 上面左边部分
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin

              end;
            gdDownUp:
              begin
                // 只上,设置为左上
                aGameDirections.LR := gdDownLeft;
              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin
          // 往左的操作是无需处理的
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右 ,设置往左下
                aGameDirections.LR := gdDownLeft;
              end;
            gdDownUp:
              begin
                // 右上,设置往下
                aGameDirections.LR := gdDownRight;
                aGameDirections.UD := gdDownDown;

              end;
            gdDownDown:
              begin
                // 右下
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上面右边处理'}
  // 上面右边部分
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 只下
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end;
              end;
          end;
        end;
      gdDownLeft:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左特殊处理
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownUp:
              begin
                // 左上
                // 只往左特殊处理
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownDown:
              begin
                // 左下
                // 只往左特殊处理
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上面下边处理'}
  // 上面下边那个
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中上障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上 ,设置往左
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边左边处理'}
  // 下面左边那个
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中下障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 只下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
            gdDownUp:
              begin
                // 右上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 右下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin
                end;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}

{$REGION '下边右边处理'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中下障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 只下
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
            gdDownUp:
              begin
                // 左上
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 左下
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;

{$ENDREGION}

{$REGION '下边上边处理'}
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中下障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                aGameDirections.LR := gdDownLeft; // 默认往左
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;

{$ENDREGION}
{$REGION '下边下边处理'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1图,中下障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                aGameDirections.LR := gdDownLeft; // 默认往左
              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;

{$ENDREGION}
  (*
    {$REGION ''}
    if r2.Contains(aManPoint) then
    begin
    CodeSite.Send('1图,中上障碍右部处理');
    case aGameDirections.LR of
    gdUpLeftAndRight:
    begin
    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // 不动
    end;
    gdDownUp:
    begin
    // 只上

    end;
    gdDownDown:
    begin
    // 只下
    end;
    end;
    end;
    gdDownLeft:
    begin

    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // 只往左
    end;
    gdDownUp:
    begin
    // 左上
    end;
    gdDownDown:
    begin
    // 左下
    end;
    end;
    end;
    gdDownRight:
    begin
    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // 只右

    end;
    gdDownUp:
    begin
    // 右上

    end;
    gdDownDown:
    begin
    // 右下

    end;
    end;
    end;
    end;
    end;
    {$ENDREGION}
  *)
end;

procedure TDirections.BarrierGameDirections_Main2(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  r1, // 上面左边
  r2, // 上面右边
  r2_1, // 上面右边处理
  r3, // 上面下边
  r4, // 右边左边
  r5, // 右边右边
  r6, // 右边上边
  r7, // 左边左边
  r8, // 左边右边
  r9 // 左边上边
    : TRect;
  iRet: Integer;
begin
  // 先找'J',找不到再去寻找左边的'还'字
  iRet := Obj.FindPic(39, 113, 736, 423, 'J.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // 上面左边
    r1 := TRect.Create(x - 40, y + 55, x + 63, y + 164);
    // 上面右边
    r2 := TRect.Create(x + 63, y + 55, x + 133, y + 164);
    r2_1 := TRect.Create(x + 21, y + 53, x + 107, y + 164);
    // 上面下边
    r3 := TRect.Create(x + 17, y + 154, x + 118, y + 173);

    // 右面左边
    r4 := TRect.Create(x + 338, y + 320, x + 415, y + 400);
    // 右面右边
    r5 := TRect.Create(x + 408, y + 300, x + 482, y + 399);
    // 右面下边
    r6 := TRect.Create(x + 350, y + 285, x + 457, y + 330);
    // 左面左边
    r7 := TRect.Create(x - 437, y + 300, x - 394, y + 396);
    // 左面右边
    r8 := TRect.Create(x - 382, y + 299, x - 308, y + 397);
    // 左面下边
    r9 := TRect.Create(x - 436, y + 262, x - 349, y + 306);
  end
  else
  begin
    iRet := Obj.FindPic(54, 43, 623, 212, '还.bmp', clPicOffsetZero,
      1.0, 0, x, y);
    if iRet > -1 then
    begin
      // 上面左边
      r1 := TRect.Create(x + 145, y + 199, x + 249, y + 293);
      // 上面右边
      r2 := TRect.Create(x + 240, y + 184, x + 335, y + 293);
      r2_1 := TRect.Create(x + 240, y + 184, x + 297, y + 293);
      // 上面下边
      r3 := TRect.Create(x + 198, y + 271, x + 304, y + 298);
      // 右面左边
      r4 := TRect.Create(x + 534, y + 438, x + 605, y + 523);
      // 右面右边
      r5 := TRect.Create(x + 600, y + 425, x + 653, y + 520);
      // 右面下边
      r6 := TRect.Create(x + 541, y + 428, x + 640, y + 455);
      // 左面左边
      r7 := TRect.Create(x - 254, y + 425, x - 178, y + 523);
      // 左面右边
      r8 := TRect.Create(x - 185, y + 429, x - 120, y + 518);
      // 左面上边
      r9 := TRect.Create(x - 252, y + 392, x - 106, y + 436);
    end;
  end;
  if iRet = -1 then
    Exit;
{$REGION '上边左边'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 右上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边右边'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownUp:
              begin
                // 左上
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;

              end;
            gdDownDown:
              begin
                // 左下
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边下边'}
  // 暂时未处理
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,上障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边左边'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,右障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边右边'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,右障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边上边'}
  // 未处理
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,右障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边左边'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,左障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边右边'}
  if r8.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,左障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 左上

              end;
            gdDownDown:
              begin
                // 左下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边上边'}
  // 未处理
  if r9.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,左障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
end;

procedure TDirections.BarrierGameDirections_Main3(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  r1, // 中间上边
  r1_1, // 中间上边处理,就是右边特殊的那部分
  r2, // 中间下边
  r3, // 中间右边
  r3_1, // 中间右边处理
  r4, // 上边左边
  r4_1,
    r5, // 上边右边
  r6, // 上边下边
  rUp, // 上边范围
  rDown // 下边范围
    : TRect;
  iRet: Integer;
  function IsUp: Boolean;
  begin
    Result := False;
    if not FTargetPoint.IsZero then
      Result := rUp.Contains(FTargetPoint);
    CodeSite.Send('目标在上边', Result);
  end;
  function IsDown: Boolean;
  begin
    Result := False;
    if not FTargetPoint.IsZero then
      Result := rDown.Contains(FTargetPoint);
    CodeSite.Send('目标在下边', Result);
  end;

begin
  // 先找'H',找不到再去寻找第一个'还'字
  iRet := Obj.FindPic(4, 26, 798, 440, 'H.bmp', clPicOffsetZero, 1.0, 0, x, y);
  // 此图教特殊,需要判断怪物和物品是否在障碍范围内
  if iRet > -1 then
  begin

    rUp := Rect(x - 443, y + 38, x + 420, y + 270);
    rDown := Rect(x - 443, y + 282, x + 420, y + 530);
    // 中间上边
    r1 := TRect.Create(x - 411, y + 142, x + 200, y + 299);
    // 中间上边处理,就是右边特殊的那部分
    r1_1 := TRect.Create(x - 21, y + 210, x + 60, y + 299);
    // 中间下边
    r2 := TRect.Create(x - 427, y + 297, x + 110, y + 339);
    // 中间右边
    r3 := TRect.Create(x + 50, y + 213, x + 159, y + 313);
    r3_1 := TRect.Create(x + 50, y + 213, x + 138, y + 313);
    // 上边左边
    r4 := TRect.Create(x + 10, y + 69, x + 110, y + 134);
    r4_1 := TRect.Create(x + 24, y + 69, x + 110, y + 134);
    // 上边右边
    r5 := TRect.Create(x + 106, y + 45, x + 181, y + 144);
    // 上边下边
    // r6 := TRect.Create(x + 50, y + 219, x + 120, y + 265);

  end
  else
  begin
    iRet := Obj.FindPic(244, 30, 644, 336, '还.bmp', clPicOffsetZero,
      1.0, 0, x, y);
    if iRet > -1 then
    begin
      rUp := Rect(x - 405, y + 189, x + 443, y + 382);
      rDown := Rect(x - 405, y + 411, x + 443, y + 569);
      // 中间上边
      r1 := TRect.Create(x - 389, y + 283, x + 318, y + 426);
      r1_1 := TRect.Create(x + 22, y + 338, x + 100, y + 426);
      // 中间下边 ,无法获取到
      // 中间右边 ,无法获取到
      // 上边左边
      r4 := TRect.Create(x + 43, y + 187, x + 147, y + 268);
      r4_1 := TRect.Create(x + 80, y + 187, x + 147, y + 268);
      // 上边右边
      r5 := TRect.Create(x + 139, y + 167, x + 221, y + 267);
      // 上边下边
      // r6 := TRect.Create(x + 50, y + 219, x + 120, y + 265);

    end;
  end;
  if iRet = -1 then
    Exit;
{$REGION '中间障碍上边'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3图,中障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if IsDown then
                begin
                  if r1_1.IntersectsWith(FManRect) then
                  begin
                    aGameDirections.UD := gdDownUp;
                    aGameDirections.LR := gdDownRight;
                  end
                  else
                  begin
                    aGameDirections.LR := gdDownRight;
                  end;
                end;
              end;

          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
                if IsDown then
                begin
                  if r1_1.IntersectsWith(FManRect) then
                  begin
                    aGameDirections.LR := gdDownRight;
                    aGameDirections.UD := gdDownUp;
                  end
                  else
                  begin
                    aGameDirections.LR := gdDownRight;
                  end;
                end;

              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下
                if IsDown then
                begin
                  if r1_1.IntersectsWith(FManRect) then
                  begin
                    aGameDirections.UD := gdDownUp;
                  end
                  else
                  begin

                  end;
                end;

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '中间下边'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2图,中障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if IsUp then
                begin
                  aGameDirections.LR := gdDownRight;
                end;
              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
                if IsUp then
                begin
                  aGameDirections.LR := gdDownRight;
                end;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
              end;
            gdDownUp:
              begin
                // 右上
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}

{$REGION '中边右边'}
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3图,中障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if r3_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                if r3_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
            gdDownUp:
              begin
                // 左上
                if r3_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 左下
                if r3_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边左边'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3图,上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownUp:
              begin
                // 右上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownDown:
              begin
                // 右下
                aGameDirections.LR := gdDownLeft;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边右边'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3图,中上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 左上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
end;

procedure TDirections.BarrierGameDirections_Main4(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  r1, r2, r3, r4, r5, r6: TRect;
  iRet: Integer;
begin
  // 第二个希字
  iRet := Obj.FindPic(82, 128, 629, 266, '希.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // 上边左边
    r1 := TRect.Create(x + 93, y + 188, x + 142, y + 249);
    // 上边右边
    r2 := TRect.Create(x + 277, y + 185, x + 353, y + 244);
    // 上边下边
    r3 := TRect.Create(x + 134, y + 244, x + 306, y + 265);
    // 下边左边
    r4 := TRect.Create(x + 193, y + 336, x + 280, y + 405);
    // 下边右边
    r5 := TRect.Create(x + 295, y + 340, x + 350, y + 404);
    // 下边上边
    r6 := TRect.Create(x + 229, y + 321, x + 318, y + 354);

  end;
  if iRet = -1 then
    Exit;
{$REGION '上边左边'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 右上
                aGameDirections.UD := gdDownUp;
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边右边'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 左上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上面下边'}
  // 未处理
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,上障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边左边'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,下障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边右边'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,下障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边上边'}
  // 未处理
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4图,下障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
end;

procedure TDirections.BarrierGameDirections_Main5(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  r1, // 上边左边
  r2, // 上边右边
  r3, // 上边下边
  r4, // 左边左边
  r4_1, // 左边左边处理
  r5, // 左边右边
  r5_1, // 左边右边处理
  r6, // 左边上边
  r7, // 左边下边
  r8, // 右边左边
  r9, // 右边上边
  r9_1, // 右边上边处理
  r10 // 右边下边
    : TRect;
  iRet: Integer;
begin
  // 第一个'那'字
  iRet := Obj.FindPic(253, 67, 498, 282, '那.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // 左上角那个是无视的,不需要处理
    // 上边左边
    r1 := TRect.Create(x - 66, y + 161, x + 11, y + 234);
    // 上边右边
    r2 := TRect.Create(x + 116, y + 167, x + 198, y + 228);
    // 上边下边
    r3 := TRect.Create(x - 36, y + 228, x + 189, y + 256);
    // 左下边左边
    r4 := TRect.Create(x - 307, y + 286, x - 191, y + 405);
    r4_1 := TRect.Create(x - 271, y + 286, x - 191, y + 405);
    // 左下边右边
    r5 := TRect.Create(x - 194, y + 277, x - 94, y + 429);
    r5_1 := TRect.Create(x - 194, y + 277, x - 127, y + 429);
    // 左下边上边
    r6 := TRect.Create(x - 254, y + 255, x - 158, y + 294);
    // 左下边下边
    r7 := TRect.Create(x - 225, y + 406, x - 132, y + 425);
    // 右下边左边
    r8 := TRect.Create(x + 256, y + 343, x + 352, y + 426);
    // 右下边上边
    r9 := TRect.Create(x + 293, y + 312, x + 444, y + 359);
    r9_1 := TRect.Create(x + 293, y + 327, x + 444, y + 359);
    // 右下边下边
    r10 := TRect.Create(x + 301, y + 374, x + 450, y + 434);
  end;
  if iRet = -1 then
    Exit;
{$REGION '上边左边'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 右上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边右边'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // 左上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边下边'}
  // 未处理
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,上障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边左边'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,左障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 只下
                aGameDirections.LR := gdDownLeft;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownDown; // 默认往下

                end
                else
                begin
                  aGameDirections.UD := gdDownDown; // 默认往下
                end;

              end;
            gdDownUp:
              begin
                // 右上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;

              end;
            gdDownDown:
              begin
                // 右下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边右边'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,左障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 只下
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownUp; // 默认向上
                end
                else
                begin
                  aGameDirections.UD := gdDownUp; // 默认向上
                end;
              end;
            gdDownUp:
              begin
                // 左上
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 左下
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边上边'}
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,上障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                aGameDirections.LR := gdDownRight; // 默认往右
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '左边下边'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,左障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                aGameDirections.LR := gdDownRight; // 默认往右
              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边左边'}
  if r8.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,右障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                aGameDirections.UD := gdDownDown; // 不确定,设置为往下
              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边上边'}
  if r9.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,右障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if r9_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdUpUpAndDown;
                end
                else
                begin
                  aGameDirections.LR := gdDownLeft;
                end;

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左

              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
                if r9_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.UD := gdUpUpAndDown;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '右边下边'}
  if r10.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5图,右障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                aGameDirections.LR := gdDownLeft;
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
end;

procedure TDirections.BarrierGameDirections_Main6(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  r1, // 上边左边
  r1_1, // 上边左边处理
  r2, // 上边右边
  r2_1, // 上边右边处理
  r3, // 上边下边
  r4, // 下边左边
  r4_1, // 下边左边处理
  r5, // 下边右边
  r6, // 下边上边
  r7 // 下边下边
  // r8,
  // r9
    : TRect;
  iRet: Integer;
begin
  // 第一个'希'字
  iRet := Obj.FindPic(442, 61, 797, 247, '希.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // 上边左边
    // r1 := TRect.Create(x - 287, y + 198, x - 182, y + 309);
    r1 := TRect.Create(x - 266, y + 198, x - 182, y + 309);
    // 上边右边
    r2 := TRect.Create(x - 205, y + 180, x - 85, y + 300);
    r2_1 := TRect.Create(x - 205, y + 180, x - 113, y + 300);
    // 上边下边
    r3 := TRect.Create(x - 211, y + 277, x - 138, y + 306);
    // 下边这个视为底部不可过的障碍,只能从顶部绕过去
    // 下边左边
    r4 := TRect.Create(x - 479, y + 409, x - 297, y + 515);
    r4_1 := TRect.Create(x - 381, y + 409, x - 297, y + 515);
    // 下边右边
    r5 := TRect.Create(x - 310, y + 391, x - 240, y + 514);
    // 下边上边
    r6 := TRect.Create(x - 347, y + 405, x - 294, y + 403);
    // 下边下边
    // r7 := TRect.Create(x - 354, y + 472, x - 258, y + 518);
    // // 下左边那个特殊的
    // r8 := TRect.Create(x - 457, y + 482, x - 398, y + 521);
    // // 下右边那个特殊的
    // r9 := TRect.Create(x - 303, y + 478, x - 233, y + 531);
  end;
  if iRet = -1 then
    Exit;
{$REGION '上边左边'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6图,上障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边右边'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6图,上障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;
              end;
            gdDownUp:
              begin
                // 左上
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownDown;
                end
                else
                begin
                  aGameDirections.UD := gdDownDown;
                end;

              end;
            gdDownDown:
              begin
                // 左下
                if r2_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                end
                else
                begin

                end;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '上边下边'}
  // 未处理
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6图,上障碍下部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边左边'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6图,下障碍左部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 只下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
            gdDownUp:
              begin
                // 右上
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                end
                else
                begin

                end;
              end;
            gdDownDown:
              begin
                // 右下
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownUp;
                end
                else
                begin
                  aGameDirections.UD := gdDownUp;
                end;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边右边'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6图,下障碍右部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '下边上边'}
  if r6.IntersectsWith(FManRect) then
  begin
    // 未处理,可能要处理
    CodeSite.Send('6图,上障碍上部处理');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 不动
              end;
            gdDownUp:
              begin
                // 只上

              end;
            gdDownDown:
              begin
                // 只下
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只往左
              end;
            gdDownUp:
              begin
                // 左上
              end;
            gdDownDown:
              begin
                // 左下
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // 只右

              end;
            gdDownUp:
              begin
                // 右上

              end;
            gdDownDown:
              begin
                // 右下

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
end;

procedure TDirections.BarrierGameDirections_Other1(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  iRet: Integer;
begin
  // 第一个'希'字
  iRet := Obj.FindPic(168, 31, 621, 121, '希.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin

  end;
  if iRet = -1 then
    Exit;
end;

procedure TDirections.BarrierGameDirections_Other2(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  iRet: Integer;
begin
  // 第一个'H'字
  iRet := Obj.FindPic(177, 187, 645, 387, 'H.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin

  end;
  if iRet = -1 then
    Exit;

end;

procedure TDirections.BarrierGameDirections_Other3(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  iRet: Integer;
begin
  // 右边'希'字
  iRet := Obj.FindPic(325, 26, 799, 236, '希.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin

  end;
  if iRet = -1 then
    Exit;

end;

procedure TDirections.BarrierGameDirections_Other4(const aManPoint: TPoint;
  var aGameDirections: TGameDirections);
var
  x, y: OleVariant;
  iRet: Integer;
begin
  // 第一个'希'字
  iRet := Obj.FindPic(142, 25, 449, 227, '希.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin

  end;
  if iRet = -1 then
    Exit;

end;

procedure TDirections.CreateManRect(const aManPoint: TPoint);
begin
  FManRect := Rect(aManPoint.x - 10, aManPoint.y - 10, aManPoint.x + 10,
    aManPoint.y + 10);
end;

destructor TDirections.Destroy;
begin
  inherited;
end;

function TDirections.GetDoorDirections(const aManPoint,
  aDoorPoint: TPoint; const aMiniMap: TMiniMap): TGameDirections;
begin
  // 人在左边,往右,
  if aManPoint.x < aDoorPoint.x then
    Result.LR := gdDownRight
  else
    // 人在右边,往左
    Result.LR := gdDownLeft;
  // 人在上边 ,往下
  if aManPoint.y < aDoorPoint.y then
    Result.UD := gdDownDown
  else
    // 人在下边,往上
    Result.UD := gdDownUp;
  FTargetPoint := aDoorPoint;
  CreateManRect(aManPoint);
  BarrierGameDirections(aManPoint, aMiniMap, Result);
end;

function TDirections.GetFindMonsterDirections(const aManPoint: TPoint;
  aMiniMap: TMiniMap): TGameDirections;
begin
  if aManPoint.x <= 100 then
  begin
    // 到达左边
    FIsArrivedLeft := True;
    FIsArrviedRight := False;
  end
  else
    if aManPoint.x >= 620 then
  begin
    // 到达右边
    FIsArrviedRight := True;
    FIsArrivedLeft := False;

  end;

  if aManPoint.x <= 400 then
  begin
    // 靠近左边
    // 已经到达过左边,那么设置向右
    if FIsArrivedLeft then
      Result.LR := gdDownRight
    else
      // 没有到达过左边向左
      Result.LR := gdDownLeft;
  end
  else
  begin
    // 靠近右边
    // 已经到达右边,设置向左
    if FIsArrviedRight then
      Result.LR := gdDownLeft
    else
      // 未到达右边,设置向右
      Result.LR := gdDownRight;
  end;

  if aManPoint.y <= 380 then
  begin
    // 到达上边
    FIsArrvideUp := True;
    FIsArrvideDown := False;
  end
  else
    if aManPoint.y >= 550 then
  begin
    // 到达下边
    FIsArrvideDown := True;
    FIsArrvideUp := True;
  end;

  if aManPoint.y <= 410 then
  begin
    // 靠近上边
    if FIsArrvideUp then
      // 到达上边往下
      Result.UD := gdDownDown
    else
      // 未到达往上
      Result.UD := gdDownUp;
  end
  else
  begin
    // 靠近下边
    if FIsArrvideDown then
      // 到达下边往上
      Result.UD := gdDownUp
    else
      // 未到达下边往下
      Result.UD := gdDownDown;
  end;
  FTargetPoint := TPoint.Zero;
  CreateManRect(aManPoint);
  BarrierGameDirections(aManPoint, aMiniMap, Result);
end;

function TDirections.GetGoodsDirections(const aManPoint, aGoodsPoint: TPoint;
  const aMiniMap: TMiniMap): TGameDirections;
begin
  // 人在左边
  if aManPoint.x < aGoodsPoint.x then
    Result.LR := gdDownRight
  else
    Result.LR := gdDownLeft;
  // 人在上边
  if aManPoint.y < aGoodsPoint.y then
    Result.UD := gdDownDown
  else
    Result.UD := gdDownUp;
  FTargetPoint := aGoodsPoint;
  CreateManRect(aManPoint);
  BarrierGameDirections(aManPoint, aMiniMap, Result);

end;

function TDirections.GetMonsterDirections(const aManPoint,
  aMonsterPoint: TPoint; const aMiniMap: TMiniMap): TGameDirections;
begin
  // 人在左边
  if aManPoint.x < aMonsterPoint.x then
    Result.LR := gdDownRight
  else
    Result.LR := gdDownLeft;
  // 人在上边
  if aManPoint.y < aMonsterPoint.y then
    Result.UD := gdDownDown
  else
    Result.UD := gdDownUp;
  FTargetPoint := aMonsterPoint;
  CreateManRect(aManPoint);
  BarrierGameDirections(aManPoint, aMiniMap, Result);

end;

function TDirections.GetTargetDirection(const aTarget: TPoint;
  const aBarrierRect: TRect): string;
begin
  Result := '';
  if aTarget.x < aBarrierRect.Left then
    Result := Result + 'left';
  if aTarget.x > aBarrierRect.Right then
    Result := Result + 'right';
  if aTarget.y < aBarrierRect.Top then
    Result := Result + 'top';
  if aTarget.y > aBarrierRect.Bottom then
    Result := Result + 'bottom';

end;

end.
