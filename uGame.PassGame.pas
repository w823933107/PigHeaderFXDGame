{
  ����:
  ���û�ȡ����ʯ��ȡ���˵ķ�װ���зֽ�,�ɻ�ø߶���ϼ�Ԫ�ؽᾧ
  ��װ�ֽ�,�ϼ�Ԫ�ؽᾧ,�м��ʻ��50W-60����Ҽ�ֵ,�����1Ԫ
  �п��ܻ���������ɵ�150W,�����3Ԫ


  ����:
  *������״̬����ֱ�Ӱ��������򷵻س������
  *�Ӱ���״̬����ֱ�Ӱ���������

}
unit uGame.PassGame;

interface

uses uGame.Interf, Spring, System.Types, System.SysUtils, CodeSiteLogging;

type

  TBox = class(TGameBase, IBox)
  private const
    sNotCheckStrColor = 'ddc593-000000'; // δѡ�е���ɫ
    sCheckStrColor = 'ffffb8'; // ѡ�е���ɫ
    sOffsetStrColor = 'ffffb8-505050'; // װ������˸����ɫ
    sColorZhuangBei��ͨ = 'ffffff';
    sColorZhuangBei�߼� = '68d5ed';
    sColorZhuangBeiϡ�� = 'b36bff';
    sColorZhuangBei���� = 'ff00ff';
    sColorZhuangBei���� = 'b36bff';
    sColorZhuangBei���� = 'ff6666';
    sColorZhuangBei��˵ = 'ff7800';
    sColorZhuangBeiʷʫ = 'ffb400';
    sColorZhuangBeiAll =
      'ffffff-000100|68d5ed-000100|b36bff-000100|ff00ff-000100|ff6666-000100|ff7800-000100|ffb400-000100';
    sColorZhuangBei�޷����� = 'ff3232-000100'; // �޷����׼��޷���������ɫ
    sColorZhuangBei��װ = 'ffffff-000100|ff3232-000100';
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
    // ��ȡװ���ٷֱ�
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
    Result := Obj.FindStr(411, 9, 773, 107, 'װ����', clStrWhite, 1.0, x,
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
  Result := ztδ֪;
  if Obj.FindStr(188, 8, 793, 595, '��ͨ', StrColorOffset(sColorZhuangBei��ͨ), 1.0,
    x, y) <> -1
  then
    Result := zt��ͨ
  else if Obj.FindStr(188, 8, 793, 595, '�߼�', StrColorOffset(sColorZhuangBei�߼�),
    1.0, x, y)
    <> -1 then
    Result := zt�߼�
  else if Obj.FindStr(188, 8, 793, 595, 'ϡ��', StrColorOffset(sColorZhuangBeiϡ��),
    1.0, x, y)
    <> -1 then
    Result := ztϡ��
  else if Obj.FindStr(188, 8, 793, 595, '����', StrColorOffset(sColorZhuangBei����),
    1.0, x, y)
    <> -1 then
    Result := zt����
  else if Obj.FindStr(188, 8, 793, 595, '����', StrColorOffset(sColorZhuangBei����),
    1.0, x, y)
    <> -1 then
    Result := zt����
  else if Obj.FindStr(188, 8, 793, 595, '����', StrColorOffset(sColorZhuangBei����),
    1.0, x, y)
    <> -1 then
    Result := zt����
  else if Obj.FindStr(188, 8, 793, 595, '��˵', StrColorOffset(sColorZhuangBei��˵),
    1.0, x, y)
    <> -1 then
    Result := zt��˵
  else if Obj.FindStr(188, 8, 793, 595, 'ʷʫ', StrColorOffset(sColorZhuangBeiʷʫ),
    1.0, x, y)
    <> -1 then
    Result := ztʷʫ;
end;

function TBox.IsFengZhuang: Boolean;
var
  x, y: OleVariant;
begin
  Result := Obj.FindStr(188, 8, 793, 595, '�޷�����',
    StrColorOffset('808080'), 1.0, x, y) = -1;
  if not Result then
    Result := Obj.FindStr(188, 8, 793, 595, '��װ', clStrWhite, 1.0, x, y) <> -1;
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
  Result := Obj.FindStr(188, 8, 793, 595, '�ƺ�|����|����|����|��ָ|ͷ��|����|��װ|����|Ь',
    clStrWhite, 1.0, x, y) <> -1;
  if not Result then
  begin
    Result := Obj.FindStr(188, 8, 793, 595, '����װ��|ħ��ʯ',
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
    Result := Obj.FindStr(411, 9, 773, 107, 'װ����',
      clStrWhite { ��βʱ���ظ�������,ԭ��������f10��ס�� } , 1.0, x,
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
      Result := Obj.FindStr(472, 221, 535, 324, 'װ��',
        StrColorOffset(sCheckStrColor), 1.0, x, y) <> -1;
      if Result then
        Break;
      if Obj.FindStr(472, 221, 535, 324, 'װ��', sOffsetStrColor, 1.0, x, y)
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
  if Obj.FindStr(428, 345, 775, 556, '����', sNotCheckStrColor, 1.0, x, y) <> -1
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
  sellX, sellY: OleVariant; // '����'������
  // �Ƿ���'����'
  function IsFindSell: Boolean;
  // var
  // x, y: OleVariant;
  begin
    Result := Obj.FindStr(28, 439, 350, 560, '����', StrColorOffset('ddc593'), 1.0,
      sellX, sellY) <> -1;
    inc(sellX, 9);
    dec(sellY, 29);
  end;
// ��װ����
  procedure FenZhuangHandle;
  var
    iRet: Integer;
    x, y: OleVariant;
  begin
    iRet := Obj.FindPic(50, 339, 300, 496, '�����̵�.bmp', clPicOffsetZero,
      0.8, 0, x, y);
    if iRet > -1 then
    begin
      // ����
      if GameData.GameConfig.bJiabaliWarning then
        warnning;
    end;
  end;
// ����װ��
  procedure SellZhuangbei;
  var
    ptMove: TPoint;
  begin
    if FBox.OpenZhuangbei then
    begin
      if FBox.IsFuZhong then
      begin
        // ����
        FBox.ZhengLi;
        // ����װ��
        for ptMove in FBox.Points do
        begin

          Obj.MoveTo(ptMove.x, ptMove.y);
          Sleep(300);

          if not FBox.IsHaveZhuangbei then
          begin
            Break;
          end;
          if FBox.GetZhuangbeiType = zt���� then
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
// �رմ���
  procedure CloseWindows;
  begin
    Obj.KeyPressChar('esc');
    Sleep(500);
    // Obj.KeyPressChar('esc');
    // Sleep(200);
  end;
// ������һ��
  procedure ContinueNext;
  begin
    if IsNotHasPilao then
    begin
      // warnning;
      CodeSite.Send('���س���');
      Obj.KeyPressChar('f12');
      Sleep(1000);
    end;
    CodeSite.Send('������һ��');
    Obj.KeyPressChar('f10');
    Sleep(1000);
  end;
// ����
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
  // ���ֳ���
  // ����Ƿ��з�װ
  // ����Ƿ���
  // ����ִ������
  // �������,�ر����д���
  // ���ִ����һ��

  while not Terminated do
  begin
    if IsFindSell then
    begin
      Sleep(500);
      // ���ֳ���
      // ��װ����
      FenZhuangHandle;
      // ��װ��
      SellZhuangbei;
      // ����װ��
      Repair;
      // �ر����д���
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
