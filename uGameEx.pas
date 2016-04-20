unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils, uObj, Winapi.Windows, QString;

type
  TGame = class(TGamebase, IGame)
  private
    FObj: IChargeObj;
    FJob: IntPtr;
    FGameData: PGameData;
    procedure DoGame(AJob: PQJob); // ���߼�
  private
    procedure SetGameConfigManager(const value: IGameConfigManager);
  public
    constructor Create(const AId: TGuid; AName: QStringW); override;

    destructor Destroy; override;
    procedure Start; // ������Ϣ
    procedure Stop;
  end;

implementation

{ TGame }

constructor TGame.Create(const AId: TGuid; AName: QStringW);
begin
  inherited;
  New(FGameData);
  Obj := TObjFactory.CreateChargeObj;
  Obj.SetDict(0, '.\Main.txt'); // �����ֿ�
  Obj.SetPath('.\Pic'); // ����·��
end;

destructor TGame.Destroy;
begin
  inherited;
  Dispose(FGameData);
end;

procedure TGame.DoGame(AJob: PQJob);
// ����Ϸ
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('���³�����ʿ', '���³�����ʿ');
    if Result = 0 then
      raise Exception.Create('no game running');
    iBind := Obj.BindWindow(Result, 'normal', 'normal', 'normal', 101);
    if iBind <> 1 then
      raise Exception.Create('bind game error');
    Obj.SetWindowState(Result, 1); // ������Ϸ����
  end;

begin
  try
    try
      AJob.Worker.ComNeeded(); // ��ʼ��COM��
      FGameData^.Hwnd := BindGame; // ������Ϸ���ھ��
      while not AJob.IsTerminated do
      begin

        Sleep(20);
      end;
    except
      on E: Exception do
        RunInMainThread(
          procedure
          begin
            MessageBoxW(0, PWideChar(E.Message), '����', MB_OK + MB_ICONWARNING);
          end);
    end;
  finally
    Workers.Clear; // ���������ҵ
  end;
end;

procedure TGame.SetGameConfigManager(const value: IGameConfigManager);
begin

end;

procedure TGame.Start;
var
  JobState: TQJobState;
begin
  // ��ҵ������ʱִ��
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(DoGame, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.Clear; // ���������ҵ
end;

initialization

TObjConfig.ChargeFullPath := '.\Bin\Charge.dll'; // ���ò��·��

finalization

end.
