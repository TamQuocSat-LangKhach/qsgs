local conghui = fk.CreateSkill{
  name = "qyt__conghui",
  tags = {Skill.Compulsory},
}

conghui:addEffect(fk.EventPhaseChanging, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(conghui.name) and data.phase == Player.Discard and not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    data.skipped = true
  end,
})

Fk:loadTranslationTable{
  ["qyt__conghui"] = "聪慧",
  [":qyt__conghui"] = "锁定技，你跳过弃牌阶段。",
}

return conghui
