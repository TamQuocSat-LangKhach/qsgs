local badao = fk.CreateSkill{
  name = "qw__badao",
}

badao:addEffect(fk.TargetConfirmed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(badao.name) and target == player and data.card.trueName == "slash" and data.card.color == Card.Black
  end,
  on_cost = Util.TrueFunc, -- 不能在on cost询问用牌
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = badao.name,
      pattern = "slash",
      prompt = "#qw__badao-slash",
      cancelable = true,
      extra_data = {bypass_times = true},
    })
    if use then
      use.extraUse = true
      player:broadcastSkillInvoke(badao.name)
      room:notifySkillInvoked(player, badao.name, "offensive")
      room:useCard(use)
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__badao"] = "霸刀",
  [":qw__badao"] = "当你成为黑色的【杀】的目标后，你可以使用一张【杀】。",
  ["#qw__badao-slash"] = "霸刀：你可以使用一张【杀】",
}

return badao
