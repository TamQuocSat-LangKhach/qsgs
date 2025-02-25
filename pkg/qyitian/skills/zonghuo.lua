local zonghuo = fk.CreateSkill {
  name = "qyt__zonghuo",
  tags = {Skill.Compulsory},
}

zonghuo:addEffect(fk.AfterCardUseDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zonghuo.name) and data.card.trueName == "slash" and data.card.name ~= "fire__slash"
  end,
  on_use = function(self, event, target, player, data)
    data:changeCardName("fire__slash")
    data.card.skillName = "fire__slash"
  end,
})


Fk:loadTranslationTable{
  ["qyt__zonghuo"] = "纵火",
  [":qyt__zonghuo"] = "锁定技，当你声明使用【杀】后，若此【杀】不为火【杀】，你将此【杀】改为火【杀】。",
  ["$qyt__zonghuo"] = "（燃烧声）",
}

return zonghuo
