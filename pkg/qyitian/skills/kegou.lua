local kegou = fk.CreateSkill {
  name = "qyt__kegou",
  tags = {Skill.Wake},
}

kegou:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kegou.name) and
      player:usedSkillTimes(kegou.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return not table.find(player.room:getOtherPlayers(player, false), function(p) return p.kingdom == "wu" and p.role ~= "lord" end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player:isAlive() then
      room:handleAddLoseSkills(player, "lianying", nil, true, false)
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__kegou"] = "克构",
  [":qyt__kegou"] = "觉醒技，准备阶段开始时，若你是除主公外唯一的吴势力角色，你减1点体力上限，获得技能〖连营〗。",
}

return kegou
