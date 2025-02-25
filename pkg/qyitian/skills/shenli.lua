local shenli = fk.CreateSkill({
  name = "qyt__shenli",
  tags = {Skill.Compulsory},
})

shenli:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@qyt__sizhan") > 0 and
      data.card and data.card.trueName == "slash" and player:usedSkillTimes(shenli.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + math.min(player:getMark("@qyt__sizhan"), 3)
  end,
})

Fk:loadTranslationTable{
  ["qyt__shenli"] = "神力",
  [":qyt__shenli"] = "锁定技，每阶段限一次，你于出牌阶段内使用【杀】造成伤害时，此伤害+X（X为当前“死战”标记数，最多为3）。",
}

return shenli
