library pigheader;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Vcl.Forms,
  System.SysUtils,
  System.Classes,
  uGameEx.Interf in 'uGameEx.Interf.pas',
  uGameEx in 'uGameEx.pas',
  uGameEx.RoleInfo in 'uGameEx.RoleInfo.pas',
  uGameEx.Config in 'uGameEx.Config.pas',
  uGameEx.Man in 'uGameEx.Man.pas',
  uGameEx.Monster in 'uGameEx.Monster.pas',
  uGameEx.Door in 'uGameEx.Door.pas',
  uGameEx.Map in 'uGameEx.Map.pas',
  uGameEx.Directions in 'uGameEx.Directions.pas',
  uGameEx.Move in 'uGameEx.Move.pas',
  uGameEx.Goods in 'uGameEx.Goods.pas',
  uGameEx.Skill in 'uGameEx.Skill.pas',
  uObj in 'uObj.pas',
  uGameEx.RegisterClass in 'uGameEx.RegisterClass.pas',
  SuxinForm in 'SuxinForm.pas' {ConfigForm} ,
  uGameEx.PassGame in 'uGameEx.PassGame.pas';

{$R *.res}


function CreateGameService: IGameService;
begin
  Result := TGame.Create;
end;

function CreateForm(aHwnd: THandle): TForm;
begin
  Application.Handle := aHwnd;
  Result := TConfigForm.Create(Application);
end;

exports
  CreateGameService,
  CreateForm;

begin
  ReportMemoryLeaksOnShutdown := Boolean(DebugHook);

end.
