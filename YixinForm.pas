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
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnGuardClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GameService: IGameService;
    ConfigForm: TForm;
    hdll: HMODULE;
    procedure Updata;
    procedure LoadLib;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}


uses Data.DBXJSONCommon, ClientModuleUnit1, Spring.Utils, System.Threading,
  LoadForm;

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

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GameService := nil;
  ConfigForm.Free;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Updata;
  LoadLib;
  TTask.Run(
    procedure
    begin
      if GameService.Guard then
      begin
        stat1.Panels[1].Text := 'Enable';
        btnGuard.Enabled := False;
      end
      else
        stat1.Panels[1].Text := 'Disable';
    end);

end;

procedure TForm3.LoadLib;
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
  Application.MessageBox('加载失败', '提示');
  Application.Terminate;

end;

procedure TForm3.Updata;
var
  stream: TBytesStream;
  curVersion: string;
  task: ITask;
  suc: Boolean;
begin
  curVersion := TFileVersionInfo.GetVersionInfo('pigheader.dll').FileVersion;
  if not ClientModule1.ServerMethods1Client.GetReleaseVersion(curVersion) then
  begin
    suc := False;
    ShowMessage('有新版本需要更新');
    task := TTask.Run(
      procedure
      begin
        stream := (TDBXJSONTools.JSONToStream
          (ClientModule1.ServerMethods1Client.GetDllFile)) as TBytesStream;
        stream.SaveToFile('.\pigheader.dll');
        stream.Free;
        suc := True;
      end);
    form2 := TForm2.Create(nil);
    form2.Show;
    while not suc do
    begin
      Application.ProcessMessages;
      Sleep(10);
    end;
    form2.Free;
    ShowMessage('更新完毕');
    ClientModule1.SQLConnection1.Close;
  end;
  stat1.Panels[2].Text := curVersion; // 设置版本信息
end;

initialization

finalization


end.
