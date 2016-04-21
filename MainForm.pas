unit MainForm;

interface

uses
  uGame.Interf,
  Spring.Container,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type

  IForm = interface
    ['{EBDD9C54-76DD-4D6D-A657-44CB3BC64794}']
    procedure Show;
    procedure Start;
    procedure Stop;
    procedure SaveConfig; // 保存配置文件
  end;

  TForm1 = class(TForm, IForm)
    btnStart: TButton;
    btnStop: TButton;
    btnZhuangbeiPercentage: TButton;
    pgc1: TPageControl;
    ts1: TTabSheet;
    rgWndState: TRadioGroup;
    grpBaseSetting: TGroupBox;
    chkAutoRunGuard: TCheckBox;
    edtLoopDelay: TEdit;
    udLoopDelay: TUpDown;
    lbl2: TLabel;
    chkVip: TCheckBox;
    btnResetDefaultConfig: TButton;
    grp1: TGroupBox;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    edtPickUpGoodsTimeOut: TEdit;
    edtFindManTimeOut: TEdit;
    edtManMoveTimeOut: TEdit;
    edtFindMonsterTimeOut: TEdit;
    edtGetInfoTimeOut: TEdit;
    lbl8: TLabel;
    edtInMapTimeOut: TEdit;
    grp2: TGroupBox;
    lbl9: TLabel;
    edtmaxZhuangbeiNum: TEdit;
    lbl10: TLabel;
    lbl11: TLabel;
    edtResetMoveStateInterval: TEdit;
    chkResetMoveState: TCheckBox;
    chkRepair: TCheckBox;
    chkNearAdjustDirection: TCheckBox;
    chkJiabaliWarning: TCheckBox;
    grp3: TGroupBox;
    edtKuangzhanOffsetY: TEdit;
    edtSilingOffsetY: TEdit;
    lbl12: TLabel;
    lbl13: TLabel;
    btnSaveConfig: TButton;
    stat1: TStatusBar;
    chkWarning: TCheckBox;
    lbl15: TLabel;
    cbbMapLv: TComboBox;
    chkLogView: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnZhuangbeiPercentageClick(Sender: TObject);
    procedure btnResetDefaultConfigClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkLogViewClick(Sender: TObject);
  private
    { Private declarations }

    FGameConfigManager: IGameConfigManager;
    FGameConfig: TGameConfig;
    procedure InitGame; // 初始化游戏

    procedure LoadConfig(const aGameConfig: TGameConfig); // 读取配置文件

    procedure ResetConfig; // 恢复默认配置
  public
    { Public declarations }
    // 更新配置文件
    Game: IGame;
    procedure Start;
    procedure Stop;
    procedure SaveConfig; // 保存配置文件
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


uses CodeSiteLogging, uObj, uGame.PassGame {, qlang};



procedure TForm1.btnStartClick(Sender: TObject);
begin
  Start;
  stat1.Panels[1].Text := 'Start';
  // Left := 0;
  // top := 0;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  Stop;
  stat1.Panels[1].Text := 'Stop';
end;

procedure TForm1.btnZhuangbeiPercentageClick(Sender: TObject);
var
  box: TBox;
begin
  box := TBox.Create;
  try
    if box.PrepareTest then
      ShowMessage(box.GetZhuangbeiPercentage.ToString());
  finally
    box.Free;
  end;
end;

procedure TForm1.chkLogViewClick(Sender: TObject);
begin
  CodeSite.Enabled := chkLogView.Checked;
end;

procedure TForm1.btnResetDefaultConfigClick(Sender: TObject);
begin
  ResetConfig;
  stat1.Panels[1].Text := 'ResetDefault';
end;

procedure TForm1.btnSaveConfigClick(Sender: TObject);
begin
  SaveConfig;
  stat1.Panels[1].Text := 'SaveConfig';
end;

procedure TForm1.FormCreate(Sender: TObject);

  procedure guard;
  var
    iRet: Integer;
    obj: IChargeObj;
  begin
    obj := TObjFactory.CreateChargeObj;
    iRet := obj.SetSimMode(2);
    if iRet <> 1 then
    begin
      ShowMessageFmt('键鼠硬件模拟开启失败,错误码:%d!', [iRet]);
      CodeSite.Send('键鼠硬件模拟开启失败');
      Application.Terminate;

    end;
    if FGameConfigManager.Config.bAutoRunGuard then
    begin
      ChDir(GetCurrentDir);
      obj.DmGuard(1, 'f1');
      iRet := obj.DmGuard(1, 'block');
      if iRet <> 1 then
      begin
        ShowMessageFmt('驱动保护失败,错误码:%d!', [iRet]);
        CodeSite.Send('驱动开启失败');
        Application.Terminate;

      end
      else
      begin
        CodeSite.Send('驱动开启成功');
        stat1.Panels[3].Text := 'Enable';
      end;
    end
    else
      stat1.Panels[3].Text := 'Disable';
  end;

begin
  ReportMemoryLeaksOnShutdown := Boolean(DebugHook);
  InitGame;
  guard;
  // LangManager.ActiveIndex := 1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SaveConfig;
end;

procedure TForm1.InitGame;
begin
  // TObjConfig.GetF2GuardRealDir('猪头鲁路修版');
  TObjConfig.ChargeFullPath := '..\Bin\Charge.dll';
  // RegisterGameClass; // 注册游戏功能
  FGameConfigManager := GlobalContainer.Resolve<IGameConfigManager>; // 创建配置管理器
  FGameConfigManager.FileName := '..\Config\GameConfig.txt';
  Game := GlobalContainer.Resolve<IGame>; // 创建游戏
  Game.GameConfigManager := FGameConfigManager; // 传递配置管理器
  LoadConfig(FGameConfigManager.Config);
  CodeSite.Enabled := chkLogView.Checked;
  // UnregisterGameClass; // 卸载所有注册功能
end;

procedure TForm1.LoadConfig(const aGameConfig: TGameConfig);
begin
  with aGameConfig do
  begin
    rgWndState.ItemIndex := iWndState;
    chkAutoRunGuard.Checked := bAutoRunGuard;
    edtLoopDelay.Text := iLoopDelay.ToString();
    chkVip.Checked := bVIP;
    edtPickUpGoodsTimeOut.Text := iPickUpGoodsTimeOut.ToString();
    edtFindManTimeOut.Text := iFindManTimeOut.ToString();
    edtGetInfoTimeOut.Text := iGetInfoTimeOut.ToString;
    edtManMoveTimeOut.Text := iManMoveTimeOut.ToString();
    edtmaxZhuangbeiNum.Text := imaxZhuangbeiNum.ToString();
    edtResetMoveStateInterval.Text := iResetMoveStateInterval.ToString();
    chkResetMoveState.Checked := bResetMoveState;
    chkRepair.Checked := bRepair;
    edtInMapTimeOut.Text := iInMapTimeOut.ToString();
    edtKuangzhanOffsetY.Text := iKuangzhanOffsetY.ToString();
    edtSilingOffsetY.Text := iSilingOffsetY.ToString();
    chkNearAdjustDirection.Checked := bNearAdjustDirection;
    chkJiabaliWarning.Checked := bJiabaliWarning;
    chkWarning.Checked := bWarning;
    cbbMapLv.ItemIndex := iMapLv;
    chkLogView.Checked := bLogView;
  end;
end;

procedure TForm1.ResetConfig;
var
  aGameConfig: TGameConfig;
begin
  aGameConfig := TGameConfig.Create;
  FGameConfigManager.Config := aGameConfig; // 保存至文件
  LoadConfig(aGameConfig); // 界面读取配置
end;

procedure TForm1.SaveConfig;
var
  aGameConfig: TGameConfig;
begin
  aGameConfig := TGameConfig.Create; // 必须进行初始化
  aGameConfig.iWndState := rgWndState.ItemIndex;
  aGameConfig.bAutoRunGuard := chkAutoRunGuard.Checked;
  aGameConfig.iLoopDelay := string(edtLoopDelay.Text).ToInteger;
  aGameConfig.bVIP := chkVip.Checked;
  aGameConfig.iPickUpGoodsTimeOut := string(edtPickUpGoodsTimeOut.Text)
    .ToInteger;
  aGameConfig.iFindManTimeOut := string(edtFindManTimeOut.Text).ToInteger;
  aGameConfig.iGetInfoTimeOut := string(edtGetInfoTimeOut.Text).ToInteger;
  aGameConfig.iManMoveTimeOut := string(edtManMoveTimeOut.Text).ToInteger;
  aGameConfig.imaxZhuangbeiNum := string(edtmaxZhuangbeiNum.Text).ToInteger;
  aGameConfig.iResetMoveStateInterval := string(edtResetMoveStateInterval.Text)
    .ToInteger();
  aGameConfig.bResetMoveState := chkResetMoveState.Checked;
  aGameConfig.bRepair := chkRepair.Checked;
  aGameConfig.iInMapTimeOut := string(edtInMapTimeOut.Text).ToInteger;
  aGameConfig.iKuangzhanOffsetY := string(edtKuangzhanOffsetY.Text).ToInteger;
  aGameConfig.iSilingOffsetY := string(edtSilingOffsetY.Text).ToInteger;
  aGameConfig.bNearAdjustDirection := chkNearAdjustDirection.Checked;
  aGameConfig.bJiabaliWarning := chkJiabaliWarning.Checked;
  aGameConfig.bWarning := chkWarning.Checked;
  aGameConfig.iMapLv := cbbMapLv.ItemIndex;
  aGameConfig.bLogView := chkLogView.Checked;
  FGameConfigManager.Config := aGameConfig; // 保存配置
end;

procedure TForm1.Start;
begin
  // UpdataConfig; // 开始游戏前更新配置文件
  SaveConfig;
  Game.Start;
end;

procedure TForm1.Stop;
begin
  Game.Stop;
end;



initialization




finalization




end.
