unit uGameEx.RegisterClass;

interface

procedure RegisterGameClass;
procedure UnregisterGameClass;

implementation

uses
  uGameEx.Interf,
  Spring.Container,
  uGameEx.Config, // ����
  uGameEx, // �ܲ���
  uGameEx.RoleInfo, // ������Ϣ
  uGameEx.Map, // ��ͼ
  uGameEx.Man, // ��
  uGameEx.Monster, // ����
  uGameEx.Door, // ��
  uGameEx.Directions, // ����
  uGameEx.Move, // �ƶ�
  uGameEx.Skill,
  uGameEx.Goods
    ;

procedure RegisterGameClass;
begin
  // CodeSite.Send('ע����Ϸ����');
  GlobalContainer.RegisterType<IGame,TGame>;
  GlobalContainer.RegisterType<IGameConfigManager,TGameConfigManagerJson>;
  GlobalContainer.RegisterType<IRoleInfoHandle,TRoleInfoHandle>;
  GlobalContainer.RegisterType<IMap,TMap>;
  GlobalContainer.RegisterType<IMan,TMan>;
  GlobalContainer.RegisterType<IMonster,TMonster>;
  GlobalContainer.RegisterType<IDoor,TDoor>;
  GlobalContainer.RegisterType<IDirections,TDirections>;
  GlobalContainer.RegisterType<IMove,TMove>;
  GlobalContainer.RegisterType<ISkill,TSkill>;
  GlobalContainer.RegisterType<IGoods,TGoods>;
  GlobalContainer.Build;
end;

procedure UnregisterGameClass;
begin
  // CodeSite.Send('ж����Ϸ����');
  GlobalContainer.Kernel.Registry.UnregisterAll;
end;

initialization



finalization



end.
