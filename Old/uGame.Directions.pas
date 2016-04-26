// ������ ,�漰���ϰ���Ļ�ȡ
// ����Ԫ��Ҫ����ά��
unit uGame.Directions;

interface

uses uGame.Interf, System.Types, CodeSiteLogging, System.SysUtils;

type
  TDirections = class(TGameBase, IDirections)
  private
    // Ѱ�ҹ��﷽��
    FIsArrivedLeft: Boolean;
    FIsArrviedRight: Boolean;
    FIsArrvideUp: Boolean;
    FIsArrvideDown: Boolean;

    FTargetPoint: TPoint; // Ŀ������,�����Ա�Ŀ�����ϰ��ķ���
  private
    FManRect: TRect; // ���ﷶΧ
    procedure CreateManRect(const aManPoint: TPoint);

  private
    // ��ȡĿ�����ϰ��ķ���
    function GetTargetDirection(const aTarget: TPoint;
      const aBarrierRect: TRect): string;
    // �ϰ������ķ���
    procedure BarrierGameDirections(const aManPoint: TPoint;
      const aMiniMap: TMiniMap;
      var aGameDirections: TGameDirections);
    // ÿ��ͼ���ϰ�����
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
    // ��ȡ���﷽��
    function GetMonsterDirections(const aManPoint, aMonsterPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // ��ȡѰ�ҹ��﷽��
    function GetFindMonsterDirections(const aManPoint: TPoint;
      aMiniMap: TMiniMap): TGameDirections;
    // ��ȡ�ŷ���
    function GetDoorDirections(const aManPoint, aDoorPoint: TPoint;
      const aMiniMap: TMiniMap): TGameDirections;
    // ��ȡ��Ʒ����
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
  r1, // ��������Ǹ�
  r2, // �����ұ�
  r2_1, // �����ұߴ���
  r3, // �����±�
  r4, // �������
  r4_1, // ������ߴ���
  r5, // �����ұ�
  r5_1, // �����ұߴ���
  r6, // �����ϱ�
  r7 // �����±�
    : TRect;
begin
  // �ұߵ�����
  iRet := Obj.FindPic(457, 43, 719, 240, '��.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // ��������Ǹ�
    r1 := TRect.Create(x - 210, y + 193, x - 110, y + 287);
    // �����ұ��Ǹ�
    r2 := TRect.Create(x - 131, y + 173, x - 27, y + 287);
    r2_1 := TRect.Create(x - 131, y + 173, x - 41, y + 253);
    // �����±��Ǹ�
    r3 := TRect.Create(x - 154, y + 280, x - 67, y + 297);
    // ��������Ǹ�
    r4 := TRect.Create(x - 93, y + 322, x + 42, y + 419);
    // ������ߴ���
    r4_1 := TRect.Create(x - 63, y + 330, x + 22, y + 419);
    // �����ұ��Ǹ�
    r5 := TRect.Create(x, y + 296, x + 97, y + 419);
    r5_1 := TRect.Create(x, y + 298, x + 85, y + 400);
    // �����ϱ��Ǹ�
    r6 := TRect.Create(x - 70, y + 322, x + 113, y + 345);
    // ������±�
    r7 := TRect.Create(x, y + 419, x + 115, y + 438);
  end;
  if iRet = -1 then
    Exit;
{$REGION '�����ϲ�����'}
  // ������߲���
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin

              end;
            gdDownUp:
              begin
                // ֻ��,����Ϊ����
                aGameDirections.LR := gdDownLeft;
              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin
          // ����Ĳ��������账���
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ�� ,����������
                aGameDirections.LR := gdDownLeft;
              end;
            gdDownUp:
              begin
                // ����,��������
                aGameDirections.LR := gdDownRight;
                aGameDirections.UD := gdDownDown;

              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�����ұߴ���'}
  // �����ұ߲���
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ�������⴦��
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
                // ����
                // ֻ�������⴦��
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
                // ����
                // ֻ�������⴦��
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�����±ߴ���'}
  // �����±��Ǹ�
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ���� ,��������
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±���ߴ���'}
  // ��������Ǹ�
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
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
                // ֻ��
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
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
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
                // ����
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
                // ����
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

{$REGION '�±��ұߴ���'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
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
                // ֻ��
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
                // ֻ����
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
                // ����
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
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;

{$ENDREGION}

{$REGION '�±��ϱߴ���'}
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
                aGameDirections.LR := gdDownLeft; // Ĭ������
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;

{$ENDREGION}
{$REGION '�±��±ߴ���'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('1ͼ,�����ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
                aGameDirections.LR := gdDownLeft; // Ĭ������
              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
    CodeSite.Send('1ͼ,�����ϰ��Ҳ�����');
    case aGameDirections.LR of
    gdUpLeftAndRight:
    begin
    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // ����
    end;
    gdDownUp:
    begin
    // ֻ��

    end;
    gdDownDown:
    begin
    // ֻ��
    end;
    end;
    end;
    gdDownLeft:
    begin

    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // ֻ����
    end;
    gdDownUp:
    begin
    // ����
    end;
    gdDownDown:
    begin
    // ����
    end;
    end;
    end;
    gdDownRight:
    begin
    case aGameDirections.UD of
    gdUpUpAndDown:
    begin
    // ֻ��

    end;
    gdDownUp:
    begin
    // ����

    end;
    gdDownDown:
    begin
    // ����

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
  r1, // �������
  r2, // �����ұ�
  r2_1, // �����ұߴ���
  r3, // �����±�
  r4, // �ұ����
  r5, // �ұ��ұ�
  r6, // �ұ��ϱ�
  r7, // ������
  r8, // ����ұ�
  r9 // ����ϱ�
    : TRect;
  iRet: Integer;
begin
  // ����'J',�Ҳ�����ȥѰ����ߵ�'��'��
  iRet := Obj.FindPic(39, 113, 736, 423, 'J.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // �������
    r1 := TRect.Create(x - 40, y + 55, x + 63, y + 164);
    // �����ұ�
    r2 := TRect.Create(x + 63, y + 55, x + 133, y + 164);
    r2_1 := TRect.Create(x + 21, y + 53, x + 107, y + 164);
    // �����±�
    r3 := TRect.Create(x + 17, y + 154, x + 118, y + 173);

    // �������
    r4 := TRect.Create(x + 338, y + 320, x + 415, y + 400);
    // �����ұ�
    r5 := TRect.Create(x + 408, y + 300, x + 482, y + 399);
    // �����±�
    r6 := TRect.Create(x + 350, y + 285, x + 457, y + 330);
    // �������
    r7 := TRect.Create(x - 437, y + 300, x - 394, y + 396);
    // �����ұ�
    r8 := TRect.Create(x - 382, y + 299, x - 308, y + 397);
    // �����±�
    r9 := TRect.Create(x - 436, y + 262, x - 349, y + 306);
  end
  else
  begin
    iRet := Obj.FindPic(54, 43, 623, 212, '��.bmp', clPicOffsetZero,
      1.0, 0, x, y);
    if iRet > -1 then
    begin
      // �������
      r1 := TRect.Create(x + 145, y + 199, x + 249, y + 293);
      // �����ұ�
      r2 := TRect.Create(x + 240, y + 184, x + 335, y + 293);
      r2_1 := TRect.Create(x + 240, y + 184, x + 297, y + 293);
      // �����±�
      r3 := TRect.Create(x + 198, y + 271, x + 304, y + 298);
      // �������
      r4 := TRect.Create(x + 534, y + 438, x + 605, y + 523);
      // �����ұ�
      r5 := TRect.Create(x + 600, y + 425, x + 653, y + 520);
      // �����±�
      r6 := TRect.Create(x + 541, y + 428, x + 640, y + 455);
      // �������
      r7 := TRect.Create(x - 254, y + 425, x - 178, y + 523);
      // �����ұ�
      r8 := TRect.Create(x - 185, y + 429, x - 120, y + 518);
      // �����ϱ�
      r9 := TRect.Create(x - 252, y + 392, x - 106, y + 436);
    end;
  end;
  if iRet = -1 then
    Exit;
{$REGION '�ϱ����'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��ұ�'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����
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
                // ����
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
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��±�'}
  // ��ʱδ����
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ����'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ��ұ�'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ��ϱ�'}
  // δ����
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '������'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '����ұ�'}
  if r8.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '����ϱ�'}
  // δ����
  if r9.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
  r1, // �м��ϱ�
  r1_1, // �м��ϱߴ���,�����ұ�������ǲ���
  r2, // �м��±�
  r3, // �м��ұ�
  r3_1, // �м��ұߴ���
  r4, // �ϱ����
  r4_1,
    r5, // �ϱ��ұ�
  r6, // �ϱ��±�
  rUp, // �ϱ߷�Χ
  rDown // �±߷�Χ
    : TRect;
  iRet: Integer;
  function IsUp: Boolean;
  begin
    Result := False;
    if not FTargetPoint.IsZero then
      Result := rUp.Contains(FTargetPoint);
    CodeSite.Send('Ŀ�����ϱ�', Result);
  end;
  function IsDown: Boolean;
  begin
    Result := False;
    if not FTargetPoint.IsZero then
      Result := rDown.Contains(FTargetPoint);
    CodeSite.Send('Ŀ�����±�', Result);
  end;

begin
  // ����'H',�Ҳ�����ȥѰ�ҵ�һ��'��'��
  iRet := Obj.FindPic(4, 26, 798, 440, 'H.bmp', clPicOffsetZero, 1.0, 0, x, y);
  // ��ͼ������,��Ҫ�жϹ������Ʒ�Ƿ����ϰ���Χ��
  if iRet > -1 then
  begin

    rUp := Rect(x - 443, y + 38, x + 420, y + 270);
    rDown := Rect(x - 443, y + 282, x + 420, y + 530);
    // �м��ϱ�
    r1 := TRect.Create(x - 411, y + 142, x + 200, y + 299);
    // �м��ϱߴ���,�����ұ�������ǲ���
    r1_1 := TRect.Create(x - 21, y + 210, x + 60, y + 299);
    // �м��±�
    r2 := TRect.Create(x - 427, y + 297, x + 110, y + 339);
    // �м��ұ�
    r3 := TRect.Create(x + 50, y + 213, x + 159, y + 313);
    r3_1 := TRect.Create(x + 50, y + 213, x + 138, y + 313);
    // �ϱ����
    r4 := TRect.Create(x + 10, y + 69, x + 110, y + 134);
    r4_1 := TRect.Create(x + 24, y + 69, x + 110, y + 134);
    // �ϱ��ұ�
    r5 := TRect.Create(x + 106, y + 45, x + 181, y + 144);
    // �ϱ��±�
    // r6 := TRect.Create(x + 50, y + 219, x + 120, y + 265);

  end
  else
  begin
    iRet := Obj.FindPic(244, 30, 644, 336, '��.bmp', clPicOffsetZero,
      1.0, 0, x, y);
    if iRet > -1 then
    begin
      rUp := Rect(x - 405, y + 189, x + 443, y + 382);
      rDown := Rect(x - 405, y + 411, x + 443, y + 569);
      // �м��ϱ�
      r1 := TRect.Create(x - 389, y + 283, x + 318, y + 426);
      r1_1 := TRect.Create(x + 22, y + 338, x + 100, y + 426);
      // �м��±� ,�޷���ȡ��
      // �м��ұ� ,�޷���ȡ��
      // �ϱ����
      r4 := TRect.Create(x + 43, y + 187, x + 147, y + 268);
      r4_1 := TRect.Create(x + 80, y + 187, x + 147, y + 268);
      // �ϱ��ұ�
      r5 := TRect.Create(x + 139, y + 167, x + 221, y + 267);
      // �ϱ��±�
      // r6 := TRect.Create(x + 50, y + 219, x + 120, y + 265);

    end;
  end;
  if iRet = -1 then
    Exit;
{$REGION '�м��ϰ��ϱ�'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����
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
{$REGION '�м��±�'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('2ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
                if IsUp then
                begin
                  aGameDirections.LR := gdDownRight;
                end;
              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
                if IsUp then
                begin
                  aGameDirections.LR := gdDownRight;
                end;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}

{$REGION '�б��ұ�'}
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����
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
                // ����
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
                // ����
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
                // ֻ��
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ����'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
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
                // ����
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
                // ����
                aGameDirections.LR := gdDownLeft;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��ұ�'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('3ͼ,�����ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
  // �ڶ���ϣ��
  iRet := Obj.FindPic(82, 128, 629, 266, 'ϣ.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // �ϱ����
    r1 := TRect.Create(x + 93, y + 188, x + 142, y + 249);
    // �ϱ��ұ�
    r2 := TRect.Create(x + 277, y + 185, x + 353, y + 244);
    // �ϱ��±�
    r3 := TRect.Create(x + 134, y + 244, x + 306, y + 265);
    // �±����
    r4 := TRect.Create(x + 193, y + 336, x + 280, y + 405);
    // �±��ұ�
    r5 := TRect.Create(x + 295, y + 340, x + 350, y + 404);
    // �±��ϱ�
    r6 := TRect.Create(x + 229, y + 321, x + 318, y + 354);

  end;
  if iRet = -1 then
    Exit;
{$REGION '�ϱ����'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��ұ�'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�����±�'}
  // δ����
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±����'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±��ұ�'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±��ϱ�'}
  // δ����
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('4ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
  r1, // �ϱ����
  r2, // �ϱ��ұ�
  r3, // �ϱ��±�
  r4, // ������
  r4_1, // �����ߴ���
  r5, // ����ұ�
  r5_1, // ����ұߴ���
  r6, // ����ϱ�
  r7, // ����±�
  r8, // �ұ����
  r9, // �ұ��ϱ�
  r9_1, // �ұ��ϱߴ���
  r10 // �ұ��±�
    : TRect;
  iRet: Integer;
begin
  // ��һ��'��'��
  iRet := Obj.FindPic(253, 67, 498, 282, '��.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // ���Ͻ��Ǹ������ӵ�,����Ҫ����
    // �ϱ����
    r1 := TRect.Create(x - 66, y + 161, x + 11, y + 234);
    // �ϱ��ұ�
    r2 := TRect.Create(x + 116, y + 167, x + 198, y + 228);
    // �ϱ��±�
    r3 := TRect.Create(x - 36, y + 228, x + 189, y + 256);
    // ���±����
    r4 := TRect.Create(x - 307, y + 286, x - 191, y + 405);
    r4_1 := TRect.Create(x - 271, y + 286, x - 191, y + 405);
    // ���±��ұ�
    r5 := TRect.Create(x - 194, y + 277, x - 94, y + 429);
    r5_1 := TRect.Create(x - 194, y + 277, x - 127, y + 429);
    // ���±��ϱ�
    r6 := TRect.Create(x - 254, y + 255, x - 158, y + 294);
    // ���±��±�
    r7 := TRect.Create(x - 225, y + 406, x - 132, y + 425);
    // ���±����
    r8 := TRect.Create(x + 256, y + 343, x + 352, y + 426);
    // ���±��ϱ�
    r9 := TRect.Create(x + 293, y + 312, x + 444, y + 359);
    r9_1 := TRect.Create(x + 293, y + 327, x + 444, y + 359);
    // ���±��±�
    r10 := TRect.Create(x + 301, y + 374, x + 450, y + 434);
  end;
  if iRet = -1 then
    Exit;
{$REGION '�ϱ����'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��ұ�'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��±�'}
  // δ����
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '������'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
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
                // ֻ��
                aGameDirections.LR := gdDownLeft;
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                if r4_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownLeft;
                  aGameDirections.UD := gdDownDown; // Ĭ������

                end
                else
                begin
                  aGameDirections.UD := gdDownDown; // Ĭ������
                end;

              end;
            gdDownUp:
              begin
                // ����
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
                // ����
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
{$REGION '����ұ�'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
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
                // ֻ��
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
                // ֻ����
                if r5_1.IntersectsWith(FManRect) then
                begin
                  aGameDirections.LR := gdDownRight;
                  aGameDirections.UD := gdDownUp; // Ĭ������
                end
                else
                begin
                  aGameDirections.UD := gdDownUp; // Ĭ������
                end;
              end;
            gdDownUp:
              begin
                // ����
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
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '����ϱ�'}
  if r6.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
                aGameDirections.LR := gdDownRight; // Ĭ������
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '����±�'}
  if r7.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
                aGameDirections.LR := gdDownRight; // Ĭ������
              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ����'}
  if r8.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
                aGameDirections.UD := gdDownDown; // ��ȷ��,����Ϊ����
              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ��ϱ�'}
  if r9.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����

              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ұ��±�'}
  if r10.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('5ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
                aGameDirections.LR := gdDownLeft;
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdUpUpAndDown;
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
  r1, // �ϱ����
  r1_1, // �ϱ���ߴ���
  r2, // �ϱ��ұ�
  r2_1, // �ϱ��ұߴ���
  r3, // �ϱ��±�
  r4, // �±����
  r4_1, // �±���ߴ���
  r5, // �±��ұ�
  r6, // �±��ϱ�
  r7 // �±��±�
  // r8,
  // r9
    : TRect;
  iRet: Integer;
begin
  // ��һ��'ϣ'��
  iRet := Obj.FindPic(442, 61, 797, 247, 'ϣ.bmp', clPicOffsetZero, 1.0,
    0, x, y);
  if iRet > -1 then
  begin
    // �ϱ����
    // r1 := TRect.Create(x - 287, y + 198, x - 182, y + 309);
    r1 := TRect.Create(x - 266, y + 198, x - 182, y + 309);
    // �ϱ��ұ�
    r2 := TRect.Create(x - 205, y + 180, x - 85, y + 300);
    r2_1 := TRect.Create(x - 205, y + 180, x - 113, y + 300);
    // �ϱ��±�
    r3 := TRect.Create(x - 211, y + 277, x - 138, y + 306);
    // �±������Ϊ�ײ����ɹ����ϰ�,ֻ�ܴӶ����ƹ�ȥ
    // �±����
    r4 := TRect.Create(x - 479, y + 409, x - 297, y + 515);
    r4_1 := TRect.Create(x - 381, y + 409, x - 297, y + 515);
    // �±��ұ�
    r5 := TRect.Create(x - 310, y + 391, x - 240, y + 514);
    // �±��ϱ�
    r6 := TRect.Create(x - 347, y + 405, x - 294, y + 403);
    // �±��±�
    // r7 := TRect.Create(x - 354, y + 472, x - 258, y + 518);
    // // ������Ǹ������
    // r8 := TRect.Create(x - 457, y + 482, x - 398, y + 521);
    // // ���ұ��Ǹ������
    // r9 := TRect.Create(x - 303, y + 478, x - 233, y + 531);
  end;
  if iRet = -1 then
    Exit;
{$REGION '�ϱ����'}
  if r1.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��

              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����
                aGameDirections.UD := gdDownDown;
              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��ұ�'}
  if r2.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
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
                // ֻ����
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
                // ����
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
                // ����
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
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�ϱ��±�'}
  // δ����
  if r3.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6ͼ,���ϰ��²�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±����'}
  if r4.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6ͼ,���ϰ��󲿴���');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��
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
                // ֻ��
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
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��
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
                // ����
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
                // ����
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
{$REGION '�±��ұ�'}
  if r5.IntersectsWith(FManRect) then
  begin
    CodeSite.Send('6ͼ,���ϰ��Ҳ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
                aGameDirections.UD := gdDownUp;
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
                aGameDirections.UD := gdDownUp;
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

              end;
          end;
        end;
    end;
  end;
{$ENDREGION}
{$REGION '�±��ϱ�'}
  if r6.IntersectsWith(FManRect) then
  begin
    // δ����,����Ҫ����
    CodeSite.Send('6ͼ,���ϰ��ϲ�����');
    case aGameDirections.LR of
      gdUpLeftAndRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ����
              end;
            gdDownUp:
              begin
                // ֻ��

              end;
            gdDownDown:
              begin
                // ֻ��
              end;
          end;
        end;
      gdDownLeft:
        begin

          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ����
              end;
            gdDownUp:
              begin
                // ����
              end;
            gdDownDown:
              begin
                // ����
              end;
          end;
        end;
      gdDownRight:
        begin
          case aGameDirections.UD of
            gdUpUpAndDown:
              begin
                // ֻ��

              end;
            gdDownUp:
              begin
                // ����

              end;
            gdDownDown:
              begin
                // ����

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
  // ��һ��'ϣ'��
  iRet := Obj.FindPic(168, 31, 621, 121, 'ϣ.bmp', clPicOffsetZero, 1.0,
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
  // ��һ��'H'��
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
  // �ұ�'ϣ'��
  iRet := Obj.FindPic(325, 26, 799, 236, 'ϣ.bmp', clPicOffsetZero, 1.0,
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
  // ��һ��'ϣ'��
  iRet := Obj.FindPic(142, 25, 449, 227, 'ϣ.bmp', clPicOffsetZero, 1.0,
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
  // �������,����,
  if aManPoint.x < aDoorPoint.x then
    Result.LR := gdDownRight
  else
    // �����ұ�,����
    Result.LR := gdDownLeft;
  // �����ϱ� ,����
  if aManPoint.y < aDoorPoint.y then
    Result.UD := gdDownDown
  else
    // �����±�,����
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
    // �������
    FIsArrivedLeft := True;
    FIsArrviedRight := False;
  end
  else
    if aManPoint.x >= 620 then
  begin
    // �����ұ�
    FIsArrviedRight := True;
    FIsArrivedLeft := False;

  end;

  if aManPoint.x <= 400 then
  begin
    // �������
    // �Ѿ���������,��ô��������
    if FIsArrivedLeft then
      Result.LR := gdDownRight
    else
      // û�е�����������
      Result.LR := gdDownLeft;
  end
  else
  begin
    // �����ұ�
    // �Ѿ������ұ�,��������
    if FIsArrviedRight then
      Result.LR := gdDownLeft
    else
      // δ�����ұ�,��������
      Result.LR := gdDownRight;
  end;

  if aManPoint.y <= 380 then
  begin
    // �����ϱ�
    FIsArrvideUp := True;
    FIsArrvideDown := False;
  end
  else
    if aManPoint.y >= 550 then
  begin
    // �����±�
    FIsArrvideDown := True;
    FIsArrvideUp := True;
  end;

  if aManPoint.y <= 410 then
  begin
    // �����ϱ�
    if FIsArrvideUp then
      // �����ϱ�����
      Result.UD := gdDownDown
    else
      // δ��������
      Result.UD := gdDownUp;
  end
  else
  begin
    // �����±�
    if FIsArrvideDown then
      // �����±�����
      Result.UD := gdDownUp
    else
      // δ�����±�����
      Result.UD := gdDownDown;
  end;
  FTargetPoint := TPoint.Zero;
  CreateManRect(aManPoint);
  BarrierGameDirections(aManPoint, aMiniMap, Result);
end;

function TDirections.GetGoodsDirections(const aManPoint, aGoodsPoint: TPoint;
  const aMiniMap: TMiniMap): TGameDirections;
begin
  // �������
  if aManPoint.x < aGoodsPoint.x then
    Result.LR := gdDownRight
  else
    Result.LR := gdDownLeft;
  // �����ϱ�
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
  // �������
  if aManPoint.x < aMonsterPoint.x then
    Result.LR := gdDownRight
  else
    Result.LR := gdDownLeft;
  // �����ϱ�
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
