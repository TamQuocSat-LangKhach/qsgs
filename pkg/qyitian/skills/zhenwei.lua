local zhenwei = fk.CreateSkill{
  name = "qyt__zhenwei",
}

zhenwei:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhenwei.name) and data.card.name == "jink" and data.toCard and data.toCard.trueName == "slash" and
      data.responseToEvent.from == player and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhenwei.name, prompt = "#qyt__zhenwei-invoke:::"..data.card:toLogString(),
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, zhenwei.name)
  end,
})

Fk:loadTranslationTable{
  ["qyt__zhenwei"] = "镇威",
  [":qyt__zhenwei"] = "当你使用【杀】被【闪】抵消时，你可以获得处理区里的此【闪】。",
  ["#qyt__zhenwei-invoke"] = "镇威：你可以获得处理区里的此%arg",
}

return zhenwei
