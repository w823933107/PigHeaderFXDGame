program “’‹∞;

uses
  Vcl.Forms,
  YixinForm in 'YixinForm.pas' {Form3},
  ClientModuleUnit1 in 'ClientModuleUnit1.pas' {ClientModule1: TDataModule},
  ServiceFunc in 'ServiceFunc.pas',
  LoadForm in 'LoadForm.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TClientModule1, ClientModule1);
  Application.Run;
end.
