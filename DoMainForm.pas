unit DoMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  IForm = interface
    ['{EBDD9C54-76DD-4D6D-A657-44CB3BC64794}']
    procedure Show;
    procedure Start;
    procedure Stop;
    procedure SaveConfig; // ±£¥Ê≈‰÷√Œƒº˛
  end;

  TForm2 = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    btnConfig: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    hSuxin: HMODULE;
    Start, Stop, FormShow, CreateForm, DestoryForm, SaveConfig: TProcedure;
    FForm: IForm;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}


uses qplugins_vcl_messages;

procedure TForm2.btnConfigClick(Sender: TObject);
begin
  FormShow;

end;

procedure TForm2.btnStartClick(Sender: TObject);
begin
  Start;
  // FForm.Start;
end;

procedure TForm2.btnStopClick(Sender: TObject);
begin
  Stop;
  // FForm.Stop;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  // PluginsManager.Loaders.Add(TQDLLLoader.Create('..\suxin.dll', '.dll'));
  // PluginsManager.Start;
  // FForm := PluginsManager.ById(IForm) as IForm;
  hSuxin := SafeLoadLibrary('..\suxin.dll');
  if hSuxin = 0 then
  begin
    ShowMessage('Running error');
    Application.Terminate;
  end;
  Start := GetProcAddress(hSuxin, 'Start');
  Stop := GetProcAddress(hSuxin, 'Stop');
  FormShow := GetProcAddress(hSuxin, 'FormShow');
  CreateForm := GetProcAddress(hSuxin, 'CreateForm');
  DestoryForm := GetProcAddress(hSuxin, 'DestroyForm');
  SaveConfig := GetProcAddress(hSuxin, 'SaveConfig');
  CreateForm;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  // FForm.SaveConfig;
  SaveConfig;
  // DestoryForm;
end;

end.
