program ��ܰ;

uses
  Vcl.Forms,
  YixinForm in 'YixinForm.pas' {Form3},
  ClientClassesUnit1 in 'ClientClassesUnit1.pas',
  ClientModuleUnit1 in 'ClientModuleUnit1.pas' {ClientModule1: TDataModule},
  ServiceFunc in 'ServiceFunc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TClientModule1, ClientModule1);
  Application.Run;
end.
