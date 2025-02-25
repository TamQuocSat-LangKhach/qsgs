local yuwen = fk.CreateSkill{
  name = "qw__yuwen",
  tags = {Skill.Compulsory},
}

yuwen:addEffect(fk.GameOverJudge, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuwen.name, false, true) and target == player
  end,
  on_use = function(self, event, target, player, data)
    data.killer = player
  end,
})

Fk:loadTranslationTable{
  ["qw__yuwen"] = "狱刎",
  [":qw__yuwen"] = "锁定技，当你死亡时，伤害来源改为自己。",
}

return yuwen
