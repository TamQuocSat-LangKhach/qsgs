local yicai = fk.CreateSkill{
  name = "qw__yicai",
}

yicai:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yicai.name) and target == player and data.card:isCommonTrick()
  end,
  on_cost = Util.TrueFunc, -- 不能在on cost询问用牌
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = yicai.name,
      pattern = "slash",
      prompt = "#qw__yicai-slash",
      cancelable = true,
      extra_data = {bypass_times = true},
    })
    if use then
      use.extraUse = true
      player:broadcastSkillInvoke(yicai.name)
      room:notifySkillInvoked(player, yicai.name, "offensive")
      room:useCard(use)
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__yicai"] = "异才",
  [":qw__yicai"] = "当你使用普通锦囊牌结算结束后，你可以使用一张不计入次数的【杀】。",
  ["#qw__yicai-slash"] = "异才：你可以使用一张【杀】",
}

return yicai
