unit UpdataServerForm;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses QPlugins, qplugins_loader_lib;

procedure TForm1.FormCreate(Sender: TObject);
begin
  PluginsManager.Loaders.Add(TQDLLLoader.Create('.\', '.dll'));
  PluginsManager.Start;
end;

end.
