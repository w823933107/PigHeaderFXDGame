library suxin;

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
  QWorker,
  windows,
  MainForm in 'MainForm.pas' {Form1};

{$R *.res}


procedure CreateForm;
begin
  Form1 := TForm1.Create(nil);
end;

procedure DestoryForm;
begin
  Form1.Free;
end;

procedure FormShow;
begin
  Form1.Show;
end;

procedure Start;
begin
  Form1.Start;
end;

procedure Stop;
begin
  Form1.Stop;
end;

procedure SaveConfig;
begin
  Form1.SaveConfig;
end;

exports
  FormShow,
  Start,
  Stop,
  CreateForm,
  DestoryForm,
  SaveConfig;

begin
  // Workers.Post(
  // procedure(AJob: PQJob)
  // begin
  // Form1 := TForm1.Create(nil);
  // Form1.ShowModal;
  // Form1.Free;
  // FreeLibraryAndExitThread(HInstance,0);
  // end, nil);

end.
