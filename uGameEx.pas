unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils;

type
  TGame = class(TGamebase)
  private
    FJob: IntPtr;
    procedure DoGame(AJob: PQJob);
  public
    procedure Start; // ������Ϣ
    procedure Stop;
  end;

implementation

{ TGame }

procedure TGame.DoGame(AJob: PQJob);
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
  end;

begin
  BindGame;
  while not AJob.IsTerminated do
  begin

  end;
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

end.
