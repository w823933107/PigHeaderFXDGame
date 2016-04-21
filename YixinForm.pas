unit YixinForm;

interface

uses uGameEx.Interf, CodeSiteLogging,
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
    GameService: IGameService;
    // ConfigForm: IQFormService;
    ConfigForm: IFormService;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}


procedure TForm3.btn1Click(Sender: TObject);
begin
  ConfigForm.Show;
end;

procedure TForm3.btn2Click(Sender: TObject);
begin
  GameService.Start;
end;

procedure TForm3.btn3Click(Sender: TObject);
begin
  GameService.Stop;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  CreateForm: TCreateForm;
  CreateGameService: TCreateGameService;
  hDll: THandle;
begin
  ReportMemoryLeaksOnShutdown := Boolean(DebugHook);
  hDll := SafeLoadLibrary('pigheader.dll');
  if hDll > 0 then
  begin
    CreateForm := GetProcAddress(hDll, 'CreateConfigForm');
    CreateGameService := GetProcAddress(hDll, 'CreateGameService');
    if Assigned(CreateForm) and Assigned(CreateGameService) then
    begin
      ConfigForm := CreateForm(Application.Handle);
      GameService := CreateGameService;
      GameService.Prepare;
      if GameService.Guard then
        stat1.Panels[1].Text := 'Enable'
      else
        stat1.Panels[1].Text := 'Disable';
    end;
  end;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  CodeSite.Send('FormDestory');
end;

initialization

finalization


end.
