unit YixinForm;

interface

uses uGameEx.Interf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type

  TForm3 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    stat1: TStatusBar;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Game: IGameService;

  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}


uses QPlugins, qplugins_vcl_messages, qplugins_formsvc, qplugins_loader_lib,
  CodeSiteLogging;

procedure TForm3.btn1Click(Sender: TObject);
var
  ConfigForm: IQFormService;
begin
  ConfigForm := PluginsManager.ByPath('Services/Form/Config') as IQFormService;
  ConfigForm.ShowModal();
end;

procedure TForm3.btn2Click(Sender: TObject);
begin
  Game.Start;
end;

procedure TForm3.btn3Click(Sender: TObject);
begin
  Game.Stop;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := Boolean(DebugHook);
  PluginsManager.Loaders.Add
    (TQDLLLoader.Create(ExtractFilePath(Application.ExeName), '.dll'));
  PluginsManager.Start;
  Game := PluginsManager.ById(IGameService) as IGameService;
  Game.Prepare;
  if Game.Guard then
    stat1.Panels[1].Text := 'Enable'
  else
    stat1.Panels[1].Text := 'Disable';
  CodeSite.Enabled := False;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  CodeSite.Send('FormDestory');
end;

initialization

finalization


end.
