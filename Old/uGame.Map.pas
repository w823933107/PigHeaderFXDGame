// ����Ԫ������ȡ��������ͼ
unit uGame.Map;

interface

uses uGame.Interf;

type
  {
    δ֪����,��Χͼ��,��Χͼ��
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
  // ���ͨ������������� (F11��)
  iRet := Obj.FindStr(708, 89, 766, 179, 'F11', StrColorOffset('e6c89b'),
    1.0, x, y);;
  if iRet <> -1 then
    Exit(lmIn);
  // ��ͨɱ��ͼ������,����ʱ������������
  iRet := Obj.FindStr(658, 2, 713, 29, '������Χ', StrColorOffset('ccc1a7'),
    1.0, x, y);
  if iRet <> -1 then
    Exit(lmIn);
  // ͼ�������
  iRet := Obj.FindStr(633, 14, 714, 67, '����', StrColorOffset('e6c89b'),
    1.0, x, y);
  if iRet <> -1 then
    Exit(lmOut);
end;

function TMap.GetMiniMap: TMiniMap;
type
  // ����������
  TMapPos = record
    Map: TMiniMap;
    x, y: Integer;
  end;

const
  // С��ͼ��9����ʶ���ͼ
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
  // Ѱ��ͼ��ָ��
  // ���û�ҵ�����BOSSͼ��,����BOSSͼ��˵����BOSSͼ
  iRet := Obj.FindPic(729, 21, 798, 149, 'ͼ��ָ��.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  if iRet = -1 then
  begin
    iRet := Obj.FindPic(735, 72, 780, 114, 'Bossͼ��.bmp', clPicOffsetZero, 0.9,
      0, x, y);
    if iRet <> -1 then
      Exit(mmBoss);
  end
  else
  begin
    // С��ͼ�����ڲ����������ڵ�ͼ
    for I := Low(MapPosArr) to High(MapPosArr) do
    begin
      if (x = MapPosArr[I].x) and (y = MapPosArr[I].y) then
      begin
        Exit(MapPosArr[I].Map);
      end;
    end;
  end;
  // ������϶�û�ҵ�
  // Ѱ�ҷ�������(�Ա����ϽǺ�ɫ,ƥ�䷵��0,��ƥ�䷵��1)
  iRet := Obj.CmpColor(781, 15, StrColorOffset('dc00dc'), 1.0);
  if iRet = 0 then
    Exit(mmClickCards);
  // Ѱ��ͨ������
  // f11û�б�װ������ס,����Ϊ��ͨ������,'�Ƿ����'Ҳ������ͨ������,�����Ժ�׷��
  iRet := Obj.FindStr(708, 89, 766, 179, 'F11', StrColorOffset('e6c89b'), 1.0, x, y);
  if iRet <> -1 then
    Exit(mmPassGame);
end;

end.
