uses
  CodeSitelogging,
  Spring.Container,
  uGame.Config, // 配置
  uGame, // 总操作
  uGame.Info, // 人物信息
  uGame.Map, // 地图
  uGame.Man, // 人
  uGame.Monster, // 怪物
  uGame.Door, // 门
  uGame.Directions, // 方向
  uGame.Move, // 移动
  uGame.Skill,
  uGame.CheckTimeOut,
  uGame.Goods,
  uGame.PassGame,
  uGame.OutMap
    ;

procedure RegisterGameClass;
begin
 // CodeSite.Send('注册游戏功能');
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
  CodeSite.Send('卸载游戏功能');
  GlobalContainer.Kernel.Registry.UnregisterAll;
end;
