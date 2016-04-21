unit YixinForm;

interface

uses uGameEx.Interf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type

  // IGame = interface
  // ['{03606AA3-1082-484B-B503-AA2069EF6C7E}']
  // procedure Start;
  // procedure Stop;
  // function Guard: Boolean;
  // end;

  TForm3 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    stat1: TStatusBar;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Game: IGame;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}


procedure TForm3.btn1Click(Sender: TObject);
type
  TMyFunc = function: TForm;
var
  hDll: THandle;
  GameForm: TForm;
  CreateGameForm: TMyFunc;
begin
  hDll := SafeLoadLibrary('Config.dll');
  if hDll > 0 then
  begin
    CreateGameForm := GetProcAddress(hDll, 'CreateGameForm');
    if Assigned(CreateGameForm) then
    begin
      GameForm := CreateGameForm;
      GameForm.Left := Self.Left;
      GameForm.Top := Self.Top;
      GameForm.ShowModal;
      GameForm.Free;
    end;
    FreeLibrary(hDll);
  end;

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
var
  hDll: THandle;
type
  TMyFunc = function: IGame;
var
  CreateGameObj: TMyFunc;
begin
  // hDll := SafeLoadLibrary('pigheader.dll');
  // if hDll > 0 then
  // begin
  // CreateGameObj := GetProcAddress(hDll, 'CreateGameObj');
  // if Assigned(CreateGameObj) then
  // begin
  // Game := CreateGameObj;
  // Game.SetApplicationHanlde(Application.Handle);
  // if Game.Guard then
  // stat1.Panels[1].Text := 'Enable'
  // else
  // stat1.Panels[1].Text := 'Disable';
  //
  // end;
  // end;

end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  // PluginsManager.Stop;
end;

end.
