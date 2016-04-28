unit uGameEx.Skill;

interface

uses uGameEx.Interf, System.Types, System.Diagnostics;

type
  TSkill = class(TGameBase, ISkill)
  private
    const
    // ��Χ
    rtMaxRange: TRect = (Left: 519; Top: 459; Right: 722; Bottom: 592);
    // С��Χ
    rtMinRanage: TRect = (Left: 84; Top: 509; Right: 600; Bottom: 557);
  private
    // ͨ�ü���
    procedure NormalX;
  private
    // ��ս����
    function kzShizizhan: Boolean; // ʮ��ն
    function kzBenshanji: Boolean; // ��ɽ��
    function kzBengshanliedizhan: Boolean; // ��ɽ�ѵ�ն
    function kzNuqibaofa: Boolean; // ŭ������
    function kzXuezhikuangbao: Boolean; // Ѫ֮��
    function kzSiwangkuangju: Boolean; // ��������
    function kzBaozou: Boolean; // ����
    function kzXueqizhiren: Boolean; // Ѫ��֮��
    function kzMiehunzhishou: Boolean; // ���֮��
    function kzShihunzhishou: Boolean; // �Ȼ�֮��
    // ��ս��ϼ���
    procedure kzSetSkill;
  private
    // ���鼼��
    FswQushijiangshi: TStopwatch;
    FIsFindJiangshiTimeOut: Boolean;
    FIsFirstSkills: Boolean;
    function slNigulasi: Boolean; // �����˹
    function slBaojunbalake: Boolean; // ����������
    function slQushijiangshi: Boolean; // ��ʹ��ʬ
    function slBalakedeyexin: Boolean; // �����˵�Ұ��
    function slSilingzhifu: Boolean; // ��������
    function slBaiguiyexing: Boolean; // �ٹ�ҹ��
    function slSilingzhiyuan: Boolean; // ����֮Թ
    function slSiwangzhizhua: Boolean; // ����֮צ
    function slBalakedefennu: Boolean; // �����˵ķ�ŭ
    function slAnyingzhizhusi: Boolean; // ��Ӱ֩��˿
    function slAnheiyishi: Boolean; // ������ʽ
    function slJiangshilaidiya: Boolean; // ��ʬ������
    function slShaluluanwu: Boolean; // ɱ¾����
    // ������ϼ���
    procedure slSetSkill;
  public

    constructor Create();
    procedure RestetSkills;
    procedure ReleaseSkill;
    function ReleaseHelperSkill: Boolean; // û�е������Ҳ�����ͷŵļ���
    procedure DestroyBarrier; // �ƻ��ϰ�
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
    // ��ս����
    kzBenshanji;
    NormalX;
  end
  else
    if (sRoleName = mjSilingshushi) then
  begin
    // ���鴦��
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '����(С).bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '����(��).bmp', clPicOffsetZero,
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
  // ��ɽ��,��һ��
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��ɽ�ѵ�ն.bmp', clPicOffsetZero,
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
  // ��ɽ��,��һ��
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��ɽ��.bmp', clPicOffsetZero,
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
  // ���֮��,��һ��ʱ��,���ﲻ��
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '���֮��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, 'ŭ������.bmp', clPicOffsetZero,
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
  // ���Զ��⿪��һЩ��ɱ�ֵ���ϼ��ܽӿ�

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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '������ʽ.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��Ӱ֩��˿.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '�ٹ�ҹ��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '�����˵ķ�ŭ.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '�����˵�Ұ��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '����������(С).bmp',
      clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '��Ӱȭ.bmp|ɱ¾����.bmp',
        clPicOffsetZero, 0.9, 0, x, y);
      if iRet = -1 then
      begin
        iRet := Obj.FindPic(Left, Top, Right, Bottom, '����������.bmp',
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
  iRet := Obj.FindPic(539, 525, 718, 586, '��ʬ������.bmp', clPicOffsetZero,
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
  { ���ж��Ƿ��һ��ִ�и�����, ���ж��Ƿ񳬹�7��δִ�н�ʬ������ }
  Result := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��ʹ��ʬ.bmp|��Ӱ֩��˿.bmp',
      clPicOffsetZero, 0.9, 0, x, y);
    // û�ҵ����ϼ��ܲ���ִ��
    if iRet = -1 then
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, '�����˹.bmp', clPicOffsetZero,
        0.9, 0, x, y);
      if iRet > -1 then
      begin
        // ��һ��ֱ�Ӱ���
        if FIsFirstSkills then
        begin
          Obj.KeyPressStr(GameData.GameConfig.slNigulasi, 100);
          FIsFirstSkills := False;
          Result := True;
        end
        else
        begin
          // ���ǵ�һ��,����Ƿ�ʱδ���ֽ�ʬ����
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
  { ���ж��Ƿ񳬹�7��δִ�н�ʬ������ }
  Result := False;
  FIsFindJiangshiTimeOut := False;
  with rtMaxRange do
  begin
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��ʹ��ʬ.bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet > -1 then
  begin
    // �ҵ�
    Obj.KeyPressStr(GameData.GameConfig.slQushijiangshi, 200);
    FswQushijiangshi.Reset;
    Result := True;
  end
  else
  begin
    // δ�ҵ���¼��ʱʱ��
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
        slShaluluanwu; // ɱ¾����Z
        slSiwangzhizhua; // ����֮צ
        slBalakedeyexin; // ���������˵�Ұ��
        slBalakedefennu; // ���������˵ķ�ŭ
        slSilingzhifu; // ��������
        slSilingzhiyuan; // ����֮Թ
        slBaiguiyexing; // �ٹ�ҹ��
        slJiangshilaidiya; // ��ʬ������
      end;
    1:
      begin
        slBalakedefennu; // ���������˵ķ�ŭ
        NormalX;
        slShaluluanwu; // ɱ¾����Z
        slSiwangzhizhua; // ����֮צ
        slSilingzhifu; // ��������
        slSilingzhiyuan; // ����֮Թ
        slBaiguiyexing; // �ٹ�ҹ��
        slJiangshilaidiya; // ��ʬ������
      end;
    2:
      begin
        slBalakedeyexin; // ���������˵�Ұ��
        NormalX;
        slShaluluanwu; // ɱ¾����Z
        slSiwangzhizhua; // ����֮צ
        slSilingzhifu; // ��������
        slSilingzhiyuan; // ����֮Թ
        slBaiguiyexing; // �ٹ�ҹ��
        slJiangshilaidiya; // ��ʬ������
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, 'ɱ¾����.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '����֮��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '����֮Թ.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '����֮צ.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '�Ȼ�֮��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, 'ʮ��ն.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, '��������.bmp', clPicOffsetZero,
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
    // ��ս����
    if kzSiwangkuangju or kzBaozou or kzXuezhikuangbao then
      Result := True;
  end
  else
    if (sRoleName = mjSilingshushi) or (sRoleName = mjLinghunshougezhe) then
  begin
    // ���鴦��
    // slNigulasi; // ��ִ�����
    // slQushijiangshi; // ��ִ��������򲻿��� ,��Ϊ��ʱ����
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
    // ��ս����
    kzSetSkill;
  end
  else
    if (sRoleName = mjSilingshushi) or (sRoleName = mjLinghunshougezhe) then
  begin
    // ���鴦��
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, 'Ѫ��֮��.bmp', clPicOffsetZero,
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
    iRet := Obj.FindPic(Left, Top, Right, Bottom, 'Ѫ֮��(С).bmp', clPicOffsetZero,
      0.9, 0, x, y);
  end;
  if iRet = -1 then
  begin
    with rtMaxRange do
    begin
      iRet := Obj.FindPic(Left, Top, Right, Bottom, 'Ѫ֮��(��).bmp',
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
