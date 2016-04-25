unit SuxinForm;

interface

uses
  uGameEx.Interf, uGameEx.Config,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type

  TConfigForm = class(TForm, IFormService)
    pgc1: TPageControl;
    ts1: TTabSheet;
    rgWndState: TRadioGroup;
    grpBaseSetting: TGroupBox;
    lbl2: TLabel;
    chkAutoRunGuard: TCheckBox;
    edtLoopDelay: TEdit;
    udLoopDelay: TUpDown;
    chkVip: TCheckBox;
    btnResetDefaultConfig: TButton;
    btnSaveConfig: TButton;
    chkLogView: TCheckBox;
    grp1: TGroupBox;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    edtPickUpGoodsTimeOut: TEdit;
    edtFindManTimeOut: TEdit;
    edtManMoveTimeOut: TEdit;
    edtFindMonsterTimeOut: TEdit;
    edtGetInfoTimeOut: TEdit;
    edtInMapTimeOut: TEdit;
    grp2: TGroupBox;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl15: TLabel;
    edtmaxZhuangbeiNum: TEdit;
    edtResetMoveStateInterval: TEdit;
    chkResetMoveState: TCheckBox;
    chkRepair: TCheckBox;
    chkNearAdjustDirection: TCheckBox;
    chkJiabaliWarning: TCheckBox;
    chkWarning: TCheckBox;
    cbbMapLv: TComboBox;
    grp3: TGroupBox;
    lbl12: TLabel;
    lbl13: TLabel;
    edtKuangzhanOffsetY: TEdit;
    edtSilingOffsetY: TEdit;
    stat1: TStatusBar;
    btn1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnResetDefaultConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkLogViewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GameConfigManager: IGameConfigManager;
    procedure SaveConfig;
    procedure LoadConfig(const aGameConfig: TGameConfig);
    procedure Guard;
  end;

implementation

{$R *.dfm}


uses Spring.Container, {QPlugins, qplugins_vcl_messages, qplugins_vcl_formsvc,}
  CodeSiteLogging, uObj;

procedure TConfigForm.btn1Click(Sender: TObject);
begin
Guard;
end;

procedure TConfigForm.btnResetDefaultConfigClick(Sender: TObject);
var
  aConfig: TGameConfig;
begin
  aConfig := TGameConfig.Create;
  LoadConfig(aConfig);
  SaveConfig;
  stat1.Panels[1].Text := 'ResetDefaultConfig';
end;

procedure TConfigForm.btnSaveConfigClick(Sender: TObject);
begin
  SaveConfig;
  stat1.Panels[1].Text := 'SaveConfig';
end;

procedure TConfigForm.chkLogViewClick(Sender: TObject);
begin
  CodeSite.Enabled := chkLogView.Checked;
end;

procedure TConfigForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfig;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  GameConfigManager := GlobalContainer.Resolve<IGameConfigManager>;
  LoadConfig(GameConfigManager.Config); // ∂¡»°≈‰÷√
end;

procedure TConfigForm.FormDestroy(Sender: TObject);
begin
  SaveConfig; // ±£¥Ê≈‰÷√
end;

procedure TConfigForm.FormShow(Sender: TObject);
begin
  LoadConfig(GameConfigManager.Config);
end;

procedure TConfigForm.Guard;
var
  obj: IChargeObj;
  gameConfigMangaer: IGameConfigManager;
  iRet: Integer;
  sPath: string;
begin
  obj := TObjFactory.CreateChargeObj;
  if GameConfigManager.Config.bAutoRunGuard then
  begin
    sPath := GetCurrentDir;
    iRet := obj.DmGuard(1, 'f1');
    if iRet <> 1 then
    begin
      CodeSite.Send('f1∂‹ø™∆Ù ß∞‹');
      MessageBox(0, PChar('f1∂‹ø™∆Ù ß∞‹,¥ÌŒÛ¬Î:' + iRet.ToString), '¥ÌŒÛ', MB_OK);
      Application.Terminate;
    end;
    ChDir(sPath);
    iRet := obj.SetSimMode(2);
    if iRet <> 1 then
    begin
      CodeSite.Send('”≤º˛«˝∂Øº”‘ÿ ß∞‹');
      MessageBox(0, PChar('”≤º˛«˝∂Øº”‘ÿ ß∞‹,¥ÌŒÛ¬Î:' + iRet.ToString), '¥ÌŒÛ', MB_OK);
      Application.Terminate;
    end;
    iRet := obj.DmGuard(1, 'block');
    if iRet <> 1 then
    begin
      CodeSite.Send('block«˝∂Øº”‘ÿ ß∞‹');
      MessageBox(0, PChar('block«˝∂Øº”‘ÿ ß∞‹,¥ÌŒÛ¬Î:' + iRet.ToString), '¥ÌŒÛ', MB_OK);
      Application.Terminate;
    end;
  end;

end;

procedure TConfigForm.LoadConfig(const aGameConfig: TGameConfig);
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
  CodeSite.Enabled := chkLogView.Checked;
end;

procedure TConfigForm.SaveConfig;
var
  aGameConfig: TGameConfig;
begin
  aGameConfig := TGameConfig.Create;
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
  GameConfigManager.Config := aGameConfig; // ±£¥Ê≈‰÷√
end;

initialization

// RegisterFormService('Services/Form', 'Config', TConfigForm, False);

finalization

// UnregisterServices('Services/Form', ['Config']);

end.
