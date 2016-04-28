unit uGameEx.Skill;

interface

uses uGameEx.Interf, System.Types, System.Diagnostics;

type
  TSkill = class(TGameBase, ISkill)
  private
    const
    // 大范围
    rtMaxRange: TRect = (Left: 519; Top: 459; Right: 722; Bottom: 592);
    // 小范围
    rtMinRanage: TRect = (Left: 84; Top: 509; Right: 600; Bottom: 557);
  private
    // 通用技能
    procedure NormalX;
  private
    // 狂战技能
    function kzShizizhan: Boolean; // 十字斩
    function kzBenshanji: Boolean; // 崩山击
    function kzBengshanliedizhan: Boolean; // 崩山裂地斩
    function kzNuqibaofa: Boolean; // 怒气爆发
    function kzXuezhikuangbao: Boolean; // 血之狂暴
    function kzSiwangkuangju: Boolean; // 死亡抗拒
    function kzBaozou: Boolean; // 暴走
    function kzXueqizhiren: Boolean; // 血气之刃
    function kzMiehunzhishou: Boolean; // 灭魂之手
    function kzShihunzhishou: Boolean; // 嗜魂之手
    // 狂战组合技能
    procedure kzSetSkill;
  private
    // 死灵技能
    FswQushijiangshi: TStopwatch;
    FIsFindJiangshiTimeOut: Boolean;
    FIsFirstSkills: Boolean;
    function slNigulasi: Boolean; // 尼古拉斯
    function slBaojunbalake: Boolean; // 暴君巴拉克
    function slQushijiangshi: Boolean; // 驱使僵尸
    function slBalakedeyexin: Boolean; // 巴拉克的野心
    function slSilingzhifu: Boolean; // 死灵束缚
    function slBaiguiyexing: Boolean; // 百鬼夜行
    function slSilingzhiyuan: Boolean; // 死灵之怨
    function slSiwangzhizhua: Boolean; // 死亡之爪
    function slBalakedefennu: Boolean; // 巴拉克的愤怒
    function slAnyingzhizhusi: Boolean; // 暗影蜘蛛丝
    function slAnheiyishi: Boolean; // 暗黑仪式
    function slJiangshilaidiya: Boolean; // 僵尸莱迪亚
    function slShaluluanwu: Boolean; // 杀戮乱舞
    // 死灵组合技能
    procedure slSetSkill;
  public

    constructor Create();
    procedure RestetSkills;
    procedure ReleaseSkill;
    function ReleaseHelperSkill: Boolean; // 没有到达怪物也可以释放的技能
    procedure DestroyBarrier; // 破坏障碍
  end;

implementation

{ TSkillMonster }

constructor TSkill.Create();
begin
  FswQushijiangshi := TStopwatch.Create;
  FIsFirstSkills := True;
end;

procedure TSkill.DestroyBarrier;
var
  sRoleName: string;
begin
  sRoleName := GameData.RoleInfo.MainJob;
  if (sRoleName = mjKuangzhanshi) or (sRoleName = mjYuxuemoshen) then
  begin
    // 狂战处理
    kzBenshanji;
    NormalX;
  end
  else
    if (sRoleName = mjSilingshushi) then
  begin
    // 死灵处理
    slSiwangzhizhua;
    slShaluluanwu;
    NormalX;
  end;

end;

function TSkill.kzBaozou: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMinRanage do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '暴走(小).bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '暴走(大).bmp', clPicOffsetZero,
        0.9, 0, x, y);
    end;
    if iRet > -1 then
    begin
      Obj.KeyPressStr(GameData.GameConfig.slBaozou, 50);
      Result := True;
    end;
  end;
end;

function TSkill.kzBengshanliedizhan: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  // 崩山击,劈一下
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '崩山裂地斩.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slBengshanliedizhan, 500);
    Result := True;
  end;

end;

function TSkill.kzBenshanji: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  // 崩山击,劈一下
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '崩山击.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slBengshanji, 50);
    Result := True;
  end;
end;

function TSkill.kzMiehunzhishou: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  // 灭魂之手,吸一段时间,人物不动
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '灭魂之手.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slMiehunzhishou, 300);
    Result := True;
  end;

end;

procedure TSkill.NormalX;
begin
  Obj.KeyPressStr('x', 50);
end;

function TSkill.kzNuqibaofa: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '怒气爆发.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slNuqibaofa, 50);
    Result := True;
  end;

end;

procedure TSkill.kzSetSkill;
var
  i: Integer;
begin
  Randomize;
  i := Random(3); // 0<=x<2
  // 可以对外开放一些非杀怪的组合技能接口

  case i of
    0:
      begin
        NormalX;
        kzXueqizhiren;
        kzBenshanji;
        kzShizizhan;
        kzNuqibaofa;
        kzBengshanliedizhan;
        kzMiehunzhishou;
        kzShihunzhishou;
        NormalX;
      end;
    1:
      begin
        kzBengshanliedizhan;
        kzXueqizhiren;
        NormalX;
        kzBenshanji;
        kzShizizhan;
        kzNuqibaofa;
        NormalX;
      end;
    2:
      begin
        NormalX;
        kzXueqizhiren;
        kzBenshanji;
        kzShizizhan;
        kzNuqibaofa;
        NormalX;
      end;

  end;

end;

function TSkill.slAnheiyishi: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '暗黑仪式.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slAnheiyishi, 50);
    Result := True;
  end;

end;

function TSkill.slAnyingzhizhusi: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '暗影蜘蛛丝.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slAnyingzhizhusi, 50);
    Result := True;
  end;

end;

function TSkill.slBaiguiyexing: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '百鬼夜行.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slBaiguiyexing, 200);
    Obj.KeyPressStr(GameData.GameConfig.slBaiguiyexing, 50);
    Result := True;
  end;

end;

function TSkill.slBalakedefennu: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '巴拉克的愤怒.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slBalakedefennu, 500);
    Result := True;
  end;

end;

function TSkill.slBalakedeyexin: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '巴拉克的野心.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slBalakedeyexin, 100);
    Obj.KeyPressStr(GameData.GameConfig.slBalakedeyexin, 50);
    Result := True;
  end;

end;

function TSkill.slBaojunbalake: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMinRanage do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '暴君巴拉克(小).bmp',
      clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '暗影拳.bmp|杀戮乱舞.bmp',
        clPicOffsetZero, 0.9, 0, x, y);
      if iRet = -1 then
      begin
        iRet := Obj.FindPic(Left, Top, Right, Bottom, '暴君巴拉克.bmp',
          clPicOffsetZero, 0.9, 0, x, y);
        if iRet > -1 then
        begin
          Obj.KeyPressStr(GameData.GameConfig.slBaojunbalake, 50);
          Result := True;
        end;
      end;

    end;

  end;

end;

function TSkill.slJiangshilaidiya: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  iRet := Obj.FindPic(539, 525, 718, 586, '僵尸莱迪亚.bmp', clPicOffsetZero,
    0.9, 0, x, y);
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slJiangshilaidiya, 50);
    Result := True;
  end;

end;

function TSkill.slNigulasi: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  { 先判断是否第一次执行该你能, 再判断是否超过7秒未执行僵尸技能了 }
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '驱使僵尸.bmp|暗影蜘蛛丝.bmp',
      clPicOffsetZero, 0.9, 0, x, y);
    // 没找到以上技能才能执行
    if iRet = -1 then
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '尼古拉斯.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        // 第一次直接按下
        if FIsFirstSkills then
        begin
          Obj.KeyPressStr(GameData.GameConfig.slNigulasi, 100);
          FIsFirstSkills := False;
          Result := True;
        end
        else
        begin
          // 不是第一次,检测是否超时未发现僵尸技能
          if FIsFindJiangshiTimeOut then
          begin
            Obj.KeyPressStr(GameData.GameConfig.slNigulasi, 100);
            Result := True;
          end;
        end;

      end;
    end;

  end;

end;

function TSkill.slQushijiangshi: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  { 先判断是否超过7秒未执行僵尸技能了 }
  Result := False;
  FIsFindJiangshiTimeOut := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '驱使僵尸.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    // 找到
    Obj.KeyPressStr(GameData.GameConfig.slQushijiangshi, 200);
    FswQushijiangshi.Reset;
    Result := True;
  end
  else
  begin
    // 未找到记录超时时间
    if FswQushijiangshi.IsRunning then
    begin
      FIsFindJiangshiTimeOut := FswQushijiangshi.ElapsedMilliseconds >=
        1000 * 9;
    end
    else
    begin
      FswQushijiangshi.Start;
    end;
  end;

end;

procedure TSkill.slSetSkill;
var
  iType: Integer;
begin
  Randomize;
  iType := Random(3);
  case iType of
    0:
      begin
        NormalX;
        slShaluluanwu; // 杀戮乱舞Z
        slSiwangzhizhua; // 死亡之爪
        slBalakedeyexin; // 暴君巴拉克的野心
        slBalakedefennu; // 暴君巴拉克的愤怒
        slSilingzhifu; // 死灵束缚
        slSilingzhiyuan; // 死灵之怨
        slBaiguiyexing; // 百鬼夜行
        slJiangshilaidiya; // 僵尸莱迪亚
      end;
    1:
      begin
        slBalakedefennu; // 暴君巴拉克的愤怒
        NormalX;
        slShaluluanwu; // 杀戮乱舞Z
        slSiwangzhizhua; // 死亡之爪
        slSilingzhifu; // 死灵束缚
        slSilingzhiyuan; // 死灵之怨
        slBaiguiyexing; // 百鬼夜行
        slJiangshilaidiya; // 僵尸莱迪亚
      end;
    2:
      begin
        slBalakedeyexin; // 暴君巴拉克的野心
        NormalX;
        slShaluluanwu; // 杀戮乱舞Z
        slSiwangzhizhua; // 死亡之爪
        slSilingzhifu; // 死灵束缚
        slSilingzhiyuan; // 死灵之怨
        slBaiguiyexing; // 百鬼夜行
        slJiangshilaidiya; // 僵尸莱迪亚
      end;
  end;

end;

function TSkill.slShaluluanwu: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '杀戮乱舞.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slShaluluanwu, 50);
    Result := True;
  end;

end;

function TSkill.slSilingzhifu: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '死灵之缚.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slSilingzhifu, 50);
    Result := True;
  end;

end;

function TSkill.slSilingzhiyuan: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '死灵之怨.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slSilingzhiyuan, 100);
    Result := True;
  end;

end;

function TSkill.slSiwangzhizhua: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '死亡之爪.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slSiwangzhizhua, 100);
    Result := True;
  end;

end;

function TSkill.kzShihunzhishou: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '嗜魂之手.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slShihunzhishou, 100);
    Result := True;
  end;

end;

function TSkill.kzShizizhan: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '十字斩.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slShizizhan, 50);
    Result := True;
  end;

end;

function TSkill.kzSiwangkuangju: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '死亡抗拒.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slSiwangkangju, 50);
    Result := True;
  end;

end;

function TSkill.ReleaseHelperSkill: Boolean;
var
  sRoleName: string;
begin
  Result := False;
  sRoleName := GameData.RoleInfo.MainJob;
  if (sRoleName = mjKuangzhanshi) or (sRoleName = mjYuxuemoshen) then
  begin
    // 狂战处理
    if kzSiwangkuangju or kzBaozou or kzXuezhikuangbao then
      Result := True;
  end
  else
    if (sRoleName = mjSilingshushi) or (sRoleName = mjLinghunshougezhe) then
  begin
    // 死灵处理
    // slNigulasi; // 先执行这个
    // slQushijiangshi; // 再执行这个次序不可逆 ,因为有时间检测
    // slBaojunbalake;
    // slAnyingzhizhusi;
    // slAnheiyishi;
    if slNigulasi or slQushijiangshi or slBaojunbalake or slAnyingzhizhusi or slAnheiyishi
    then
      Result := True;
  end;

end;

procedure TSkill.ReleaseSkill;
var
  sRoleName: string;
begin
  sRoleName := GameData.RoleInfo.MainJob;
  if (sRoleName = mjKuangzhanshi) or (sRoleName = mjYuxuemoshen) then
  begin
    // 狂战处理
    kzSetSkill;
  end
  else
    if (sRoleName = mjSilingshushi) or (sRoleName = mjLinghunshougezhe) then
  begin
    // 死灵处理
    slSetSkill;
  end;
end;

procedure TSkill.RestetSkills;
begin
  FIsFirstSkills := True;
  FswQushijiangshi.Stop;
  FswQushijiangshi.Reset;
end;

function TSkill.kzXueqizhiren: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '血气之刃.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    Obj.KeyPressStr(GameData.GameConfig.slXueqizhiren, 100);
    Result := True;
  end;

end;

function TSkill.kzXuezhikuangbao: Boolean;
var
  iRet: Integer;
  x, y: OleVariant;
begin
  Result := False;
  with rtMinRanage do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '血之狂暴(小).bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '血之狂暴(大).bmp',
        clPicOffsetZero,
        0.9, 0, x, y);
    end;
    if iRet > -1 then
    begin
      Obj.KeyPressStr(GameData.GameConfig.slXuezhikuangbao, 50);
      Result := True;
    end;
  end;

end;

initialization


finalization


end.
