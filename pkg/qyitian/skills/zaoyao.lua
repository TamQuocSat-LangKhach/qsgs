local zaoyao = fk.CreateSkill{
  name = "qyt__zaoyao",
  tags = {Skill.Compulsory},
}

zaoyao:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zaoyao.name) and player.phase == Player.Finish and player:getHandcardNum() > 13
  end,
  on_use = function(self, event, target, player, data)
    player:throwAllCards("h")
    if player:isAlive() then
      player.room:loseHp(player, 1, self.name)
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__zaoyao"] = "早夭",
  [":qyt__zaoyao"] = "锁定技，结束阶段开始时，若你的手牌数大于13，你须弃置所有手牌并失去1点体力。",
}

return zaoyao
