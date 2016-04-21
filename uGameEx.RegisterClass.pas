unit uGameEx.RegisterClass;

interface

procedure RegisterGameClass;
procedure UnregisterGameClass;

implementation

uses
  uGameEx.Interf,
  Spring.Container,
  uGameEx.Config, // 配置
  uGameEx, // 总操作
  uGameEx.RoleInfo, // 人物信息
  uGameEx.Map, // 地图
  uGameEx.Man, // 人
  uGameEx.Monster, // 怪物
  uGameEx.Door, // 门
  uGameEx.Directions, // 方向
  uGameEx.Move, // 移动
  uGameEx.Skill,
  uGameEx.Goods
    ;

procedure RegisterGameClass;
begin
  // CodeSite.Send('注册游戏功能');
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
  // CodeSite.Send('卸载游戏功能');
  GlobalContainer.Kernel.Registry.UnregisterAll;
end;

initialization



finalization



end.
