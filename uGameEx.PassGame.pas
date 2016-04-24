unit uGameEx.PassGame;

interface

uses uGameEx.Interf, Spring, System.Types, System.SysUtils, CodeSiteLogging,
  QWorker;

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
    function GetZhuangbeiType: TZhuangbeiType; // ��ȡװ������
    function IsFuZhong: Boolean; // ���ݰٷֱȺ������ļ����
    function IsFengZhuang: Boolean; // �Ƿ�װ
    function IsHaveZhuangbei: Boolean;

    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // ��ȡװ���ٷֱ�
    function GetZhuangbeiPercentage: Integer;
    function GetIsfuzhongByPic: Boolean; // ����ͼƬ����Ƿ���
  end;

  TPassGame = class(TGameBase, IPassGame)
  private
    FBox: IBox;
    FSellX, FSellY: OleVariant;
  private
    function IsFindSell: Boolean;
    procedure FenZhuangHandle;
    procedure SellZhuangbei;
    procedure ContinueNext;
    procedure Repair;
    procedure CloseWindowsByEsc;
  public
    constructor Create();
    procedure SetGameData(aGameData: PGameData); override;
    destructor Destroy; override;
    procedure EndSell;
    procedure ClickCards;
  end;

implementation

uses Spring.Container, windows, System.Threading;
{ TBox }

function TBox.Close: Boolean;

var
  x, y: OleVariant;
begin
  FBasePoint := TPoint.Zero;
  Result := False;
  while (not Terminated) do
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

function TBox.GetIsfuzhongByPic: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  iRet := Obj.FindPic(424, 419, 723, 535, '������.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  Result := iRet > -1;

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
  while (not Terminated) do
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
    while (not Terminated) do
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

procedure TPassGame.ClickCards;
var
  hJob: THandle;
begin
  hJob := Workers.Post(
    procedure(AJob: PQJob)
    var
      x, y: OleVariant;
      iRet: Integer;
      bIsClick: Boolean;
      I: Integer;
    begin
      bIsClick := False;
      while (not Terminated) and (not AJob.IsTerminated) do
      begin
        iRet := Obj.FindPic(6, 25, 483, 559,
          '��1.bmp|�ƽ���5.bmp|�ƽ���5Ex.bmp|˫���ƽ���5.bmp', clPicOffsetZero,
          0.9, 0, x, y);
        if iRet > -1 then
        begin
          bIsClick := True;
          Obj.MoveTo(x - 40, y + 37);
          Sleep(100);
          Obj.LeftClick;
          Sleep(200);
        end
        else
        begin
          if bIsClick then
          begin
            Sleep(1000);
            Obj.KeyDownChar('3');
            Sleep(200);
            Obj.KeyUpChar('3');
            Sleep(1000);
            for I := 0 to 30 do
            begin
              Obj.KeyPressChar('x');
              Sleep(80);
            end;
            Exit;
          end;
        end;

      end;
    end, nil);
  if Workers.WaitJob(hJob, 1000 * 60, False) = wrTimeout then
  begin
    Workers.ClearSingleJob(hJob);
    warnning;
  end;
end;

procedure TPassGame.CloseWindowsByEsc;
begin
  Obj.KeyPressChar('esc');
  Sleep(500);
end;

procedure TPassGame.ContinueNext;
var
  Map: IMap;
begin
  Map := globalcontainer.Resolve<IMap>;
  Map.SetGameData(GameData);
  if not IsHavePilao then
  begin
    // warnning;
    while (not Terminated) do
    begin
      CodeSite.Send('���س���');
      Obj.KeyPressChar('f12');
      Sleep(1000);
      if Map.LargeMap = lmOut then
        Break;
    end;
  end
  else
  begin
    while (not Terminated) do
    begin
      CodeSite.Send('������һ��');
      Obj.KeyPressChar('f10');
      Sleep(1000);
      if Map.MiniMap = mmMain1 then
        Break;
    end;
  end;
end;

constructor TPassGame.Create;
begin
  FBox := TBox.Create;
end;

destructor TPassGame.Destroy;
begin
  FBox := nil;
  inherited;
end;

procedure TPassGame.EndSell;
var
  hJob: THandle;
  task: ITask;
begin
  // ���ֳ���
  // ����Ƿ��з�װ
  // ����Ƿ���
  // ����ִ������
  // �������,�ر����д���
  // ���ִ����һ��
  // hJob := Workers.Post(
  // procedure(AJob: PQJob)
  // //  begin

  task := TTask.Run(
    procedure
    begin
      while (not Terminated) do
      begin
        TTask.CurrentTask.CheckCanceled;
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
          CloseWindowsByEsc;
          CloseGameWindows;
        end
        else
        begin
          ContinueNext;
          OutputDebugString('----------------������----------------------');
          Exit;
        end;

      end;
    end);
  // task.Start;
  if not task.Wait(1000 * 60 * 2) then
  begin
    task.Cancel;
    warnning;
  end;
  // end, nil);

  // if Workers.WaitJob(hJob, 1000 * 60 , False) = wrTimeout then
  // begin
  // Workers.ClearSingleJob(hJob);
  // warnning;
  // end;
  OutputDebugString('------------------���������------');

end;

procedure TPassGame.FenZhuangHandle;
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

function TPassGame.IsFindSell: Boolean;
begin
  Result := Obj.FindStr(28, 439, 350, 560, '����', StrColorOffset('ddc593'), 1.0,
    FSellX, FSellY) <> -1;
  inc(FSellX, 9);
  dec(FSellY, 29);
end;

procedure TPassGame.Repair;
begin
  if GameData.GameConfig.bRepair then
  begin
    Obj.KeyPressChar('s');
    Sleep(100);
    Obj.KeyDownChar('enter');
    Sleep(500);
  end;
end;

procedure TPassGame.SellZhuangbei;
var
  ptMove: TPoint;
begin
  if FBox.OpenZhuangbei then
  begin
    if FBox.GetIsfuzhongByPic then
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
        Obj.MoveTo(FSellX, FSellY);
        Sleep(200);
        Obj.LeftUp;
        Sleep(200);
        Obj.LeftDoubleClick;
        Sleep(200);
      end;
    end;
  end;
end;

procedure TPassGame.SetGameData(aGameData: PGameData);
begin
  inherited;
  FBox.SetGameData(aGameData);
end;

end.
