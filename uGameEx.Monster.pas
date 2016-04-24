unit uGameEx.Monster;

interface

uses uGameEx.Interf, System.Types, System.Diagnostics, CodeSiteLogging;

type

  TFindMonsterType = (fmtUnknown, fmtColor, fmtPic, fmtSpecialColor, fmtStr,
    fmtBossStr);

  TMonster = class(TGameBase, IMonster)
  private
    const
    // ȫ���ҹַ�Χ
    cGlobalMonsterRect: TRect = (Left: 0; Top: 110; Right: 800; Bottom: 556);
  private
    FManPoint: TPoint;
    FIsFindBoss: Boolean;
    FBossPoint: TPoint;
    FMonsterPoint: TPoint;
    FFindMonsterType: TFindMonsterType;
  private
    function FindMonsterByColor(aRect: TRect): TPoint; // ������ͨ��ɫ�ҹ���
    function FindMonsterByPic(aRect: TRect): TPoint; // ����ͼƬ�ҹ���,�Ǹ���ը�Ĺ���
    function FindMonsterBySpecialColor(aRect: TRect): TPoint; // ����������ɫ�ҹ���
    function FindMonsterByStr(aRect: TRect): TPoint; // �������ҹ���
    function FindMonsterByBossStr(aRect: TRect): TPoint; // ����Boss�����ҹ���;
    function GetMonstrStrPoint(aRect: TRect): TPoint; // ��ȡǹ����������
    // �ۺ����Ϻ���Ѱ�ҹ�������
    function FindMonster(aRect: TRect): TPoint;
  public
    function GetPoint: TPoint;
    procedure SetManPoint(const value: TPoint);
    function GetIsExistMonster: Boolean;
    function IsArriviedMonster(var aMonsterPoint: TPoint): Boolean; // ��������
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
    // Ѱ��Boss
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtBossStr;
      Break;
    end;
    // Ѱ���ֹ�
    Result := FindMonsterByStr(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtStr;
      Break;
    end;

    // Ѱ����ͨ��ɫ��
    Result := FindMonsterByColor(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtColor;
      Break;
    end;

    // Ѱ��ͼƬ��
    Result := FindMonsterByPic(aRect);
    if not Result.IsZero then
    begin
      FFindMonsterType := fmtPic;
      Break;
    end;

    // Ѱ��������ɫ��
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
    // ƫ��x
    case iIndex of
      0:
        Inc(x, 58); // ��
      1:
        Inc(x, 42); // ��
      2:
        Inc(x, 17); // ��
      3:
        Inc(x, 3); // ��
      4:
        Inc(x, -11); // ��
      5:
        Inc(x, -23); // ��
      6:
        Inc(x, -33); // ͡
      7:
        Inc(x, -46); // ��

    end;
    Inc(y, 43); // ƫ��y
    Result := Point(x, y);
  end;

end;

function TMonster.FindMonsterByColor(aRect: TRect): TPoint;

const
  sNormalColor = '6b00f7-303030'; // ��ͨ����ɫ
  // ������ɫ�㼯��
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
    '����(��).bmp|����(��).bmp', clPicOffsetZero, 0.9, 0, x, y);
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
  sName = '��|��|ħ|��|Ա';
  sColor = 'b3b3b3';
  sNameEx = '������|�޷���|���ĵ�|ҩ��';
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
        Inc(x, 20); // ��
      1:
        Inc(x, 7); // ��
      2:
        Inc(x, -6); // ħ
      3:
        Inc(x, -18); // ��
      4:
        Inc(x, -44); // Ա
    end;
    Inc(y, 172); // ����y��ƫ��
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
        0: { ������|�޷���|���ĵ�|ҩ�� }
          Inc(x, 42); // ������
        1:
          Inc(x, 4); // �޷���
        2:
          Inc(x, -29); // ���ĵ�
        3:
          Inc(x, -63); // ҩ��
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
  // ��������Ѱ�һ�ǹ�ֵķ�Χ,��Ϊ�˺�����Ҫ����ɱ��
  rtSearch := Rect(FManPoint.x - 170, FManPoint.y - 80, FManPoint.x + 170,
    FManPoint.y + 40);
  // rtSearch := Rect(FManPoint.x - 180, FManPoint.y - 100, FManPoint.x + 180,
  // FManPoint.y + 50);
  // ���û�ǹ�ַ�Χ
  rtSearch.Offset(0, -170);
  // rtSearch.Inflate(60, 40);
  rtSearch.DmNormalizeRect;
  CodeSite.Send('����������ǹ�ֹ��ﷶΧ', rtSearch);
  { TODO -c�Ż� : �Ƿ񵽴����,��Ѱ���Ͳ�ͬ,��Ҫ�Ż� }
  // ptMonster := FindMonsterByStr(rtSearch);   //���Ǹ�BUG,����ȡ����ǹ�ֽŵ׹�������,�����Ѿ�ƫ����
  ptMonster := GetMonstrStrPoint(rtSearch);
  if ptMonster.IsZero then
  begin
    // ��ԭ��Χ
    rtSearch.Offset(0, 170);
    // rtSearch.Inflate(-60, -40);
    rtSearch.DmNormalizeRect;
    // �����Χ��û�ҵ�����,��ôѰ���ֺ�ͼ�Ĺ�������,�����Ƿ��ڷ�Χ��
    ptMonster := FindMonster(rtSearch);
    if ptMonster.IsZero then
    begin
      CodeSite.Send('���ﷶΧ��δ����������,ִ�з�Χ����Ա�');
      ptMonster := FindMonster(cGlobalMonsterRect);
      // ����ҵ�����
      if not ptMonster.IsZero then
      begin
        if rtSearch.Contains(ptMonster) then
        begin
          CodeSite.Send('�Աȳɹ�,�������������ﷶΧ��');
          Result := True;
        end
        else
          CodeSite.Send('�Ա�ʧ��,��������δ�����ﷶΧ��');
      end;
    end
    else
    begin
      CodeSite.Send('�������귶Χ������������');
      Result := True;
    end;
  end
  else
  begin
    CodeSite.Send('�������귶Χ����������ǹ�ֹ��ﷶΧ');
    Result := True;
  end;
  if Result then
    aMonsterPoint := ptMonster
  else
    aMonsterPoint := TPoint.Zero;
end;

function TMonster.GetIsExistMonster: Boolean; // 0, 110, 800, 556

begin
  Result := not FindMonster(cGlobalMonsterRect).IsZero; // ��0����true
end;

function TMonster.GetMonstrStrPoint(aRect: TRect): TPoint;
const
  sName = '��|��|ħ|��|Ա';
  sColor = 'b3b3b3';
  sNameEx = '������|�޷���|���ĵ�|ҩ��';
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
    // �Ƿ���ڹ���
    if GetIsExistMonster then
    begin
      // �Ƿ���Boss���߻�ǹ��
      if FFindMonsterType in [fmtBossStr, fmtStr] then
      begin
        Result := FMonsterPoint;
        Break;
      end;

      // ��������������չѰ��
      // ����������ʼ����Χ
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
        Result := FindMonster(rtSearch);
        // �ҵ���������
        if not Result.IsZero then
          Break;
        // ���췶Χ
        rtSearch.Inflate(25, 25);
        // �Ƿ���Ҫ�����ʱ��
      end;
    end;
  until (True);
  CodeSite.Write('��������', Result);
end;

procedure TMonster.SetManPoint(const value: TPoint);
begin
  FManPoint := value;
end;

initialization


finalization


end.
