// 注册功能单元,集中管理类的实现
unit uGameEx.RegisterClass;

interface

procedure RegisterGameClass;
procedure UnregisterGameClass;

implementation

uses
  uGameEx.Interf,
  Spring.Container,
  uGameEx.Config, // 配置
  uGameEx.RoleInfo, // 人物信息
  uGameEx.Map, // 地图
  uGameEx.Man, // 人
  uGameEx.Monster, // 怪物
  uGameEx.Door, // 门
  uGameEx.Directions, // 方向
  uGameEx.Move, // 移动
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
