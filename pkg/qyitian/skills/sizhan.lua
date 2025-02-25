local sizhan = fk.CreateSkill({
  name = "qyt__sizhan",
  tags = {Skill.Compulsory},
})

sizhan:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(sizhan.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@qyt__sizhan", data.damage)
    return true
  end,
})

sizhan:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(sizhan.name)
    and player.phase == Player.Finish and player:getMark("@qyt__sizhan") > 0
  end,
  on_use = function(self, event, target, player, data)
    local n = player:getMark("@qyt__sizhan")
    player.room:setPlayerMark(player, "@qyt__sizhan", 0)
    player.room:loseHp(player, n, sizhan.name)
  end,
})

Fk:loadTranslationTable{
  ["qyt__sizhan"] = "死战",
  [":qyt__sizhan"] = "锁定技，当你受到伤害时，防止此伤害并获得等量的“死战”标记；结束阶段，你弃置所有的“死战”标记并失去等量的体力。 ",
  ["@qyt__sizhan"] = "死战",
}

return sizhan
