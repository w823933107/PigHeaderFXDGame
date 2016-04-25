program “’‹∞;

uses
  Vcl.Forms,
  YixinForm in 'YixinForm.pas' {Form3},
  uGameEx in 'uGameEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
