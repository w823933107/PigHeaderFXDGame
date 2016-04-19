program ÖíÍ·Â³Â·ÐÞ°æ;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  uGame.Config in 'uGame.Config.pas',
  uGame.Directions in 'uGame.Directions.pas',
  uGame.Door in 'uGame.Door.pas',
  uGame.Goods in 'uGame.Goods.pas',
  uGame.Info in 'uGame.Info.pas',
  uGame.Interf in 'uGame.Interf.pas',
  uGame.Map in 'uGame.Map.pas',
  uGame.Monster in 'uGame.Monster.pas',
  uGame in 'uGame.pas',
  uObj in 'uObj.pas',
  uGame.Move in 'uGame.Move.pas',
  uGame.Man in 'uGame.Man.pas',
  uGame.Skill in 'uGame.Skill.pas',
  uGame.CheckTimeOut in 'uGame.CheckTimeOut.pas',
  uGame.PassGame in 'uGame.PassGame.pas',
  uGame.OutMap in 'uGame.OutMap.pas',
  uGameEx in 'uGameEx.pas',
  uGameEx.Interf in 'uGameEx.Interf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
