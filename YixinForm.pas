unit YixinForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type

  IGameService = interface
    ['{2BE5BFB6-1647-461E-A668-F34A3331FBAC}']
    procedure Start;
    procedure Stop;
    function Guard(): Boolean;
  end;

  TCreateForm = function(aHwnd: THandle): TForm;
  TCreateGameService = function: IGameService;

  TForm3 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    stat1: TStatusBar;
    btnGuard: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnGuardClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GameService: IGameService;
    ConfigForm: TForm;
    hdll: HMODULE;
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

procedure TForm3.btnGuardClick(Sender: TObject);
begin
  if GameService.Guard then
  begin
    stat1.Panels[1].Text := 'Enable';
    btnGuard.Enabled := False;
  end
  else
    stat1.Panels[1].Text := 'Disable';
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  CreateForm: TCreateForm;
  CreateGameService: TCreateGameService;
label error;
begin
  hdll := SafeLoadLibrary('pigheader.dll');
  if hdll = 0 then
    goto error;
  CreateForm := GetProcAddress(hdll, 'CreateForm');
  CreateGameService := GetProcAddress(hdll, 'CreateGameService');
  if (not Assigned(CreateForm)) or (not Assigned(CreateGameService)) then
    goto error;
  ConfigForm := CreateForm(Application.Handle);
  GameService := CreateGameService;
  Exit;
error:
  Application.MessageBox('º”‘ÿ ß∞‹', 'Ã· æ');
  Application.Terminate;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  GameService := nil;
  ConfigForm.Free;
end;

initialization

finalization


end.
