unit YixinForm;

interface

uses QPlugins, qplugins_vcl_messages,
  qplugins_formsvc, qplugins_loader_lib,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  IFormService = interface
    ['{B44D6B79-9508-45A7-90E9-392074533F5D}']
    function ShowModal: Integer;
    procedure Show;
  end;

  IGameService = interface
    ['{2BE5BFB6-1647-461E-A668-F34A3331FBAC}']
    procedure Prepare;
    procedure Start;
    procedure Stop;
    function Guard(): Boolean;
    procedure SetHandle(const aHandle: THandle);
  end;

  TCreateForm = function(aHandle: THandle): IFormService;
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
  private
    { Private declarations }
  public
    { Public declarations }
    GameService: IGameService;
    ConfigForm: IQFormService;
    // ConfigForm: IFormService;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}


uses ClientModuleUnit1;

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
  procedure UpdataModule;
  var
    Version: TQVersion;
    releaseVersion: Byte;
    stream: TBytesStream;
    FileBytes: TBytes;
    aVer: IQVersion;
  begin
    // ClientModule1.SQLConnection1.Open;
    aVer := (PluginsManager.ById(IQVersion) as IQVersion);
    aVer.GetVersion(Version);
//    if not ClientModule1.ServerMethods1Client.GetReleaseVersion(releaseVersion)
//    then
//    begin
//      PluginsManager.Stop;
//      ClientModule1.ServerMethods1Client.GetDllFile.ToBytes(FileBytes, 0);
//      DeleteFile('pigheader.dll');
//      stream := TBytesStream.Create(FileBytes);
//      try
//        stream.SaveToFile('pigheader.dll');
//      finally
//        stream.Free;
//      end;
//      ClientModule1.SQLConnection1.Connected := False;
//      ShowMessage('已更新程序,请重新启动程序');
//      Application.Terminate;
   // end;
    ClientModule1.SQLConnection1.Close;
  end;

begin
  ReportMemoryLeaksOnShutdown := Boolean(DebugHook);
  PluginsManager.Loaders.Add
    (TQDLLLoader.Create('.\', '.dll'));
  PluginsManager.Start;
  UpdataModule;
  GameService := PluginsManager.ById(IGameService) as IGameService;
  ConfigForm := PluginsManager.ByPath('Services/Form/Config') as IQFormService;
  GameService.Prepare;

end;

initialization

finalization


end.
