unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows,
  Spring.Container, CodeSiteLogging, Vcl.Forms, uGameEx.RegisterClass;

type
  // ��Ϸ���߼�
  TGame = class(TGamebase)
  private
    FObj: IChargeObj;
    FJob: IntPtr;
    FGameData: PGameData;
  private
    FGameConfigManager: IGameConfigManager;
    FMap: IMap;
    FMove: IMove;
  private
    procedure GameJob(AJob: PQJob); // ���߼���ҵ
    procedure CheckJob(AJob: PQJob); // �����ҵ
    procedure LoopHandle; // ѭ������
    procedure InMapHandle; // ͼ�ڲ���
    procedure OutMapHandle; // ͼ�����
    procedure UnknownMapHandle; // λ��ͼ����
    procedure CreateGameObjs(aGameData: PGameData); // ��������
  public
    constructor Create();
    destructor Destroy; override;
    procedure Start; // ������Ϣ
    procedure Stop;
    procedure SetApplicationHanlde(aHandle: THandle);
    function Guard(): Boolean;
  end;

  // Ϊ��֧�ֲ��,�������ٴη�װ
  TGameService = class(TInterfacedObject, IGameService)
  private
    FGame: TGame;
  public
    destructor Destroy; override;
    procedure SetHandle(const aHandle: THandle);
    procedure Prepare; // ���ڲ��ֹ��ܷ��ڲ���Ĺ��Ӻ����лᵼ�³���ס������,����ֻ��������
    procedure Start; // ��ʼ
    function Guard: Boolean; // ��������˱�������true,���򷵻�false
    procedure Stop; // ֹͣ
  end;

implementation


{ TGame }

procedure TGame.CheckJob(AJob: PQJob);
var
  x, y: OleVariant;
  iRet: Integer;
  hGame: Integer;
begin
  while not AJob.IsTerminated do
  begin
    // ���ͻ����Ƿ����
    hGame := FObj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if hGame = 0 then
      warnning;
    // �������״̬
    iRet := FObj.FindStr(0, 0, 800, 600, '���������ж�', clStrWhite, 1.0, x, y);
    if iRet > -1 then
      warnning;
    // ��ⴰ�ڼ���״̬
    if FObj.GetWindowState(hGame, 1) = 0 then
      FObj.SetWindowState(hGame, 1);
    Sleep(2000);
  end;

end;

constructor TGame.Create;
begin
  New(FGameData);
  Obj := TObjFactory.CreateChargeObj;
  Obj.SetDict(0, sDictPath); // �����ֿ�
  Obj.SetPath(sPicPath); // ����·��
  // // �������ù�����
  FGameConfigManager := GlobalContainer.Resolve<IGameConfigManager>;
end;

procedure TGame.CreateGameObjs(aGameData: PGameData);
begin
  FMap := GlobalContainer.Resolve<IMap>;
  FMap.SetGameData(aGameData);
  FMove := GlobalContainer.Resolve<IMove>;
  FMove.SetGameData(aGameData);
end;

destructor TGame.Destroy;
begin
  Dispose(FGameData);
  FGameConfigManager := nil;
  inherited;
  CodeSite.Send('TGame Destory');
end;

procedure TGame.GameJob(AJob: PQJob);
// ����Ϸ
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if Result = 0 then
      raise EGame.Create('no game running');
    iBind := Obj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if iBind <> 1 then
      raise EGame.Create('bind game error');
    Obj.SetWindowState(Result, 1); // ������Ϸ����
  end;

begin
  try
    try
      CodeSite.Send('start to run');
      AJob.Worker.ComNeeded(); // ��ʼ��COM�� ,�ƺ�������֮���޷������˳�������
      FGameData^.GameConfig := FGameConfigManager.Config; // ��ȡ�����ļ�
      FGameData^.Hwnd := BindGame; // ������Ϸ���ھ��
      FGameData^.Job := AJob; // �������̵߳���ҵ����
      GameData := FGameData; // ���浽��ǰ����,Ϊ�˷�ֹ���������ʹ�ö�������
      CreateGameObjs(FGameData); // ������Ҫʹ�õĶ���
      LoopHandle; // ѭ������
    except
      on E: EGame do
      // MessageBox(0, PWideChar(E.Message), '����', MB_OK);
      begin
        Application.MessageBox(PWideChar(E.Message), '����');
        CodeSite.Send('error operator');
      end;
    end;
  finally
    CodeSite.Send('start to clear ');
    // Workers.Clear;
    // ���������ҵ ,���ú��ƺ�������ȷִ��
  end;
end;

function TGame.Guard(): Boolean;
var
  iRet: Integer;
  sPath: string;
begin
  Result := False;
  sPath := GetCurrentDir;
  if FGameConfigManager.Config.bAutoRunGuard then
  begin
    iRet := Obj.SetSimMode(2);
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('Ӳ����������ʧ��,������:' + iRet.ToString), '����');
      Application.Terminate;
    end;
    iRet := Obj.DmGuard(1, 'f1');
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('f1�ܿ���ʧ��,������:' + iRet.ToString), '����');
      Application.Terminate;
    end;
    ChDir(sPath); // ��������·��
    iRet := Obj.DmGuard(1, 'block');
    if iRet <> 1 then
    begin
      Application.MessageBox(PChar('block��������ʧ��,������:' + iRet.ToString), '����');
      Application.Terminate;
    end;
    Result := True;
  end;
end;

procedure TGame.InMapHandle;
begin
  case FMap.MiniMap of
    mmUnknown:
      begin

      end;
    mmClickCards:
      ;
    mmPassGame:
      ;
  else

  end;

end;

procedure TGame.LoopHandle;

begin
  Workers.Post(CheckJob, nil);
  while not Terminated do
  begin
    CloseGameWindows; // �ر����д���
    case FMap.LargeMap of
      lmUnknown:
        UnknownMapHandle;
      lmOut:
        OutMapHandle;
      lmIn:
        InMapHandle;
    end;
    Sleep(GameData.GameConfig.iLoopDelay); // ѭ����ʱ
  end;
end;

procedure TGame.OutMapHandle;
begin

end;

procedure TGame.SetApplicationHanlde(aHandle: THandle);
begin
  Application.Handle := aHandle;
end;

procedure TGame.Start;
var
  JobState: TQJobState;
begin
  // ��ҵ������ʱִ��
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(GameJob, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.Clear; // ���������ҵ
end;

procedure TGame.UnknownMapHandle;
begin

end;

{ TGameService }

destructor TGameService.Destroy;
begin
  FGame.Free;
  inherited;
end;

function TGameService.Guard: Boolean;
begin
  Result := FGame.Guard;
end;

procedure TGameService.Prepare;
begin
  FGame := TGame.Create;
end;

procedure TGameService.SetHandle(const aHandle: THandle);
begin
  Application.Handle := aHandle;
end;

procedure TGameService.Start;
begin
  FGame.Start;
end;

procedure TGameService.Stop;
begin
  FGame.Stop;
end;

initialization

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // ���ò��·��
RegisterGameClass;
// RegisterServices('Services/Game', [TGameService.Create(IGameService,
// 'GameService')]);

finalization

// UnregisterServices('Services/Game', ['GameService']);
CleanupGlobalContainer;

end.
