local zhengfeng = fk.CreateSkill({
  name = "qyt__zhengfeng",
  tags = {Skill.Compulsory},
})

zhengfeng:addEffect("atkrange", {
  fixed_func = function (self, player)
    if player:hasSkill(zhengfeng.name) and #player:getEquipments(Card.SubtypeWeapon) == 0 then
      return player.hp
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__zhengfeng"] = "争锋",
  [":qyt__zhengfeng"] = "锁定技，若你的装备区没有武器牌，你的攻击范围为X（X为你的体力值）。",
}

return zhengfeng
