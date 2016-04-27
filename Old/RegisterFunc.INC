uses
  CodeSitelogging,
  Spring.Container,
  uGame.Config, // ����
  uGame, // �ܲ���
  uGame.Info, // ������Ϣ
  uGame.Map, // ��ͼ
  uGame.Man, // ��
  uGame.Monster, // ����
  uGame.Door, // ��
  uGame.Directions, // ����
  uGame.Move, // �ƶ�
  uGame.Skill,
  uGame.CheckTimeOut,
  uGame.Goods,
  uGame.PassGame,
  uGame.OutMap
    ;

procedure RegisterGameClass;
begin
 // CodeSite.Send('ע����Ϸ����');
  GlobalContainer.RegisterType<TGame>;
  GlobalContainer.RegisterType<TGameConfigManagerJson>;
  GlobalContainer.RegisterType<TRoleInfoHandle>;
  GlobalContainer.RegisterType<TMap>;
  GlobalContainer.RegisterType<TMan>;
  GlobalContainer.RegisterType<TMonster>;
  GlobalContainer.RegisterType<TDoor>;
  GlobalContainer.RegisterType<TDirections>;
  GlobalContainer.RegisterType<TMove>;
  GlobalContainer.RegisterType<TSkill>;
  GlobalContainer.RegisterType<TCheckTimeOut>;
  GlobalContainer.RegisterType<TGoods>;
  GlobalContainer.RegisterType<TBox>;
  GlobalContainer.RegisterType<TPassGame>;
  GlobalContainer.RegisterType<TOutMap>;
  GlobalContainer.Build;
end;

procedure UnregisterGameClass;
begin
  CodeSite.Send('ж����Ϸ����');
  GlobalContainer.Kernel.Registry.UnregisterAll;
end;