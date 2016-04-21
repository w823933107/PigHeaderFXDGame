library Config;

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
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  SuxinForm in 'SuxinForm.pas' {Form4},
  uGame.Config in 'uGame.Config.pas',
  uGameEx.Interf in 'uGameEx.Interf.pas';

{$R *.res}


function CreateGameForm: TForm;
begin
  Result := TForm4.Create(nil);
end;

exports
  CreateGameForm;

begin

end.
