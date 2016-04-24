// ע�Ṧ�ܵ�Ԫ,���й������ʵ��
unit uGameEx.RegisterClass;

interface

procedure RegisterGameClass;
procedure UnregisterGameClass;

implementation

uses
  uGameEx.Interf,
  Spring.Container,
  uGameEx.Config, // ����
  uGameEx.RoleInfo, // ������Ϣ
  uGameEx.Map, // ��ͼ
  uGameEx.Man, // ��
  uGameEx.Monster, // ����
  uGameEx.Door, // ��
  uGameEx.Directions, // ����
  uGameEx.Move, // �ƶ�
  uGameEx.Skill,
  uGameEx.Goods,
  uGameEx.CheckTimeOut,
  uGameEx.PassGame
    ;

procedure RegisterGameClass;
begin
  GlobalContainer.RegisterType<IGameConfigManager, TGameConfigManagerJson>;
  GlobalContainer.RegisterType<IRoleInfoHandle, TRoleInfoHandle>;
  GlobalContainer.RegisterType<IMap, TMap>;
  GlobalContainer.RegisterType<IMan, TMan>;
  GlobalContainer.RegisterType<IMonster, TMonster>;
  GlobalContainer.RegisterType<IDoor, TDoor>;
  GlobalContainer.RegisterType<IDirections, TDirections>;
  GlobalContainer.RegisterType<IMove, TMove>;
  GlobalContainer.RegisterType<ISkill, TSkill>;
  GlobalContainer.RegisterType<IGoods, TGoods>;
  GlobalContainer.RegisterType<ICheckTimeOut, TCheckTimeOut>;
  GlobalContainer.RegisterType<IPassGame, TPassGame>;

  GlobalContainer.Build;
end;

procedure UnregisterGameClass;
begin
  GlobalContainer.Kernel.Registry.UnregisterAll;
end;

initialization


finalization


end.
