local tongxin = fk.CreateSkill({
  name = "qyt__tongxin",
})

tongxin:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(tongxin.name) and (target:getMark("@@qyt__lianli_from") ~= 0 or target:getMark("@@qyt__lianli_to") ~= 0)
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.damage do
      self:doCost(event, target, player, data)
      if not player:hasSkill(tongxin.name) or event:isCancelCost(self) or table.every(player.room.alive_players, function (p)
        return p:getMark("@@qyt__lianli_from") == 0 and p:getMark("@@qyt__lianli_to") == 0
      end) then break end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#qyt__tongxin-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and (p:getMark("@@qyt__lianli_from") ~= 0 or p:getMark("@@qyt__lianli_to") ~= 0) then
        room:doIndicate(player.id, {p.id})
        p:drawCards(1, self.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__tongxin"] = "同心",
  [":qyt__tongxin"] = "当一名处于连理状态的角色受到1点伤害后，你可以令处于连理状态的角色各摸一张牌。",
  ["#qyt__tongxin-invoke"] = "同心：是否令所有处于连理状态的角色各摸一张牌？",
}


return tongxin
