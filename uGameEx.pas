unit uGameEx;

interface

uses QWorker, uGameEx.Interf, System.SysUtils;

type
  TGame = class(TGamebase)
  private
    FJob: IntPtr;
    procedure DoGame(AJob: PQJob);
  public
    procedure Start; // 配置信息
    procedure Stop;
  end;

implementation

{ TGame }

procedure TGame.DoGame(AJob: PQJob);
  function BindGame: Integer;
  var
    iBind: Integer;
  begin
    Result := Obj.FindWindow('地下城与勇士', '地下城与勇士');
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
  // 作业不存在时执行
  if not Workers.PeekJobState(FJob, JobState) then
  begin
    FJob := Workers.Post(DoGame, nil);
  end;
end;

procedure TGame.Stop;
begin
  Workers.Clear; // 清除所有作业
end;

end.
