unit uGameEx.PassGame;

interface

uses uGameEx.Interf, Spring, System.Types, System.SysUtils, CodeSiteLogging,
  QWorker;

type

  TBox = class(TGameBase, IBox)
  private const
    sNotCheckStrColor = 'ddc593-000000'; // 未选中的颜色
    sCheckStrColor = 'ffffb8'; // 选中的颜色
    sOffsetStrColor = 'ffffb8-505050'; // 装备那闪烁的颜色
    sColorZhuangBei普通 = 'ffffff';
    sColorZhuangBei高级 = '68d5ed';
    sColorZhuangBei稀有 = 'b36bff';
    sColorZhuangBei神器 = 'ff00ff';
    sColorZhuangBei传承 = 'b36bff';
    sColorZhuangBei勇者 = 'ff6666';
    sColorZhuangBei传说 = 'ff7800';
    sColorZhuangBei史诗 = 'ffb400';
    sColorZhuangBeiAll =
      'ffffff-000100|68d5ed-000100|b36bff-000100|ff00ff-000100|ff6666-000100|ff7800-000100|ffb400-000100';
    sColorZhuangBei无法交易 = 'ff3232-000100'; // 无法交易及无法穿戴的颜色
    sColorZhuangBei封装 = 'ffffff-000100|ff3232-000100';
  private
    FBasePoint: TPoint;
    function GetBasePoint: TPoint;
    function GetPoints: Vector<TPoint>;
  public
    function Open: Boolean;
    function Close: Boolean;
    function OpenZhuangbei: Boolean;
    procedure ZhengLi;
    function GetZhuangbeiType: TZhuangbeiType; // 获取装备类型
    function IsFuZhong: Boolean; // 依据百分比和配置文件检测
    function IsFengZhuang: Boolean; // 是封装
    function IsHaveZhuangbei: Boolean;

    property BasePoint: TPoint read GetBasePoint;
    property Points: Vector<TPoint> read GetPoints;
    // 获取装备百分比
    function GetZhuangbeiPercentage: Integer;
    function GetIsfuzhongByPic: Boolean; // 依据图片检测是否负重
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
    Result := Obj.FindStr(411, 9, 773, 107, '装备栏', clStrWhite, 1.0, x,
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
  iRet := Obj.FindPic(424, 419, 723, 535, '负重条.bmp', clPicOffsetZero,
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
  Result := zt未知;
  if Obj.FindStr(188, 8, 793, 595, '普通', StrColorOffset(sColorZhuangBei普通), 1.0,
    x, y) <> -1
  then
    Result := zt普通
  else if Obj.FindStr(188, 8, 793, 595, '高级', StrColorOffset(sColorZhuangBei高级),
    1.0, x, y)
    <> -1 then
    Result := zt高级
  else if Obj.FindStr(188, 8, 793, 595, '稀有', StrColorOffset(sColorZhuangBei稀有),
    1.0, x, y)
    <> -1 then
    Result := zt稀有
  else if Obj.FindStr(188, 8, 793, 595, '神器', StrColorOffset(sColorZhuangBei神器),
    1.0, x, y)
    <> -1 then
    Result := zt神器
  else if Obj.FindStr(188, 8, 793, 595, '传承', StrColorOffset(sColorZhuangBei传承),
    1.0, x, y)
    <> -1 then
    Result := zt传承
  else if Obj.FindStr(188, 8, 793, 595, '勇者', StrColorOffset(sColorZhuangBei勇者),
    1.0, x, y)
    <> -1 then
    Result := zt勇者
  else if Obj.FindStr(188, 8, 793, 595, '传说', StrColorOffset(sColorZhuangBei传说),
    1.0, x, y)
    <> -1 then
    Result := zt传说
  else if Obj.FindStr(188, 8, 793, 595, '史诗', StrColorOffset(sColorZhuangBei史诗),
    1.0, x, y)
    <> -1 then
    Result := zt史诗;
end;

function TBox.IsFengZhuang: Boolean;
var
  x, y: OleVariant;
begin
  Result := Obj.FindStr(188, 8, 793, 595, '无法交易',
    StrColorOffset('808080'), 1.0, x, y) = -1;
  if not Result then
    Result := Obj.FindStr(188, 8, 793, 595, '封装', clStrWhite, 1.0, x, y) <> -1;
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
  Result := Obj.FindStr(188, 8, 793, 595, '称号|武器|手镯|项链|戒指|头肩|上衣|下装|腰带|鞋',
    clStrWhite, 1.0, x, y) <> -1;
  if not Result then
  begin
    Result := Obj.FindStr(188, 8, 793, 595, '辅助装备|魔法石',
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
    Result := Obj.FindStr(411, 9, 773, 107, '装备栏',
      clStrWhite { 结尾时会重复打开两次,原因特征被f10挡住了 } , 1.0, x,
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
      Result := Obj.FindStr(472, 221, 535, 324, '装备',
        StrColorOffset(sCheckStrColor), 1.0, x, y) <> -1;
      if Result then
        Break;
      if Obj.FindStr(472, 221, 535, 324, '装备', sOffsetStrColor, 1.0, x, y)
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
  if Obj.FindStr(428, 345, 775, 556, '整理', sNotCheckStrColor, 1.0, x, y) <> -1
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
          '牌1.bmp|黄金卡牌5.bmp|黄金卡牌5Ex.bmp|双倍黄金卡牌5.bmp', clPicOffsetZero,
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
      CodeSite.Send('返回城镇');
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
      CodeSite.Send('继续下一关');
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
  // 发现出售
  // 检测是否有粉装
  // 检测是否负重
  // 负重执行卖物
  // 卖物完毕,关闭所有窗口
  // 点击执行下一关
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
          // 发现出售
          // 粉装处理
          FenZhuangHandle;
          // 卖装备
          SellZhuangbei;
          // 修理装备
          Repair;
          // 关闭所有窗口
          CloseWindowsByEsc;
          CloseGameWindows;
        end
        else
        begin
          ContinueNext;
          OutputDebugString('----------------跳出啊----------------------');
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
  OutputDebugString('------------------完成任务了------');

end;

procedure TPassGame.FenZhuangHandle;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  iRet := Obj.FindPic(50, 339, 300, 496, '秘密商店.bmp', clPicOffsetZero,
    0.8, 0, x, y);
  if iRet > -1 then
  begin
    // 报警
    if GameData.GameConfig.bJiabaliWarning then
      warnning;
  end;
end;

function TPassGame.IsFindSell: Boolean;
begin
  Result := Obj.FindStr(28, 439, 350, 560, '出售', StrColorOffset('ddc593'), 1.0,
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
      // 整理
      FBox.ZhengLi;
      // 出售装备
      for ptMove in FBox.Points do
      begin

        Obj.MoveTo(ptMove.x, ptMove.y);
        Sleep(300);

        if not FBox.IsHaveZhuangbei then
        begin
          Break;
        end;
        if FBox.GetZhuangbeiType = zt神器 then
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
