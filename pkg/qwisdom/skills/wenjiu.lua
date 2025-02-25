local wenjiu = fk.CreateSkill{
  name = "qw__wenjiu",
  tags = {Skill.Compulsory},
}

wenjiu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wenjiu.name) and target == player and data.card.trueName == "slash"
    and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

wenjiu:addEffect(fk.TargetConfirmed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wenjiu.name) and target == player and data.card.trueName == "slash"
    and data.card.color == Card.Red
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsive = true
  end,
})

Fk:loadTranslationTable{
  ["qw__wenjiu"] = "温酒",
  [":qw__wenjiu"] = "锁定技，你使用黑色的【杀】造成的伤害+1，你无法响应红色【杀】 ",
}

return wenjiu
