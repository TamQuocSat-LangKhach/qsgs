local lianli = fk.CreateSkill({
  name = "qyt__lianli",
})

lianli:addLoseEffect(function (self, player)
  local room = player.room
  for _, pid in ipairs(player:getTableMark("@@qyt__lianli_from")) do
    local p = room:getPlayerById(pid)
    room:removeTableMark(p, "@@qyt__lianli_to", player.id)
    if p:getMark("@@qyt__lianli_to") == 0 then
      room:handleAddLoseSkills(p, "-qyt__lianli_slash&", nil, false, true)
    end
  end
  room:setPlayerMark(player, "@@qyt__lianli_from", 0)
end)

lianli:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.find(player.room.alive_players, function(p)
        return p.gender == General.Male and p ~= player
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function(p)
      return p.gender == General.Male and p ~= player
    end)
    local tos = player.room:askToChoosePlayers(player,
    {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = self.name,
      cancelable = true,
      prompt = "#qyt__lianli-choose",
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMarkIfNeed(to, "@@qyt__lianli_to", player.id)
    room:addTableMarkIfNeed(player, "@@qyt__lianli_from", to.id)
    room:handleAddLoseSkills(to, "qyt__lianli_slash&", nil, false, true)
  end,
})

lianli:addEffect(fk.AskForCardResponse, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return not player.dead and
      (data.cardName == "jink" or Exppattern:Parse(data.pattern):matchExp("jink")) and
      (data.extraData == nil or data.extraData.qyt__lianli_ask == nil) and
      table.contains(target:getTableMark("@@qyt__lianli_from"), player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local respond = room:askToResponse(player, {
      skill_name = self.name,
      pattern = "jink",
      prompt = "#qyt__lianli-jink-resp:"..target.id,
      cancelable = true,
      extra_data = {qyt__lianli_ask = true},
    })
    if respond then
      respond.skipDrop = true
      room:responseCard(respond)
      local new_card = Fk:cloneCard("jink")
      new_card.skillName = self.name
      new_card:addSubcards(room:getSubcardsByRule(respond.card, { Card.Processing }))
      data.result = new_card
      return true
    end
  end,
}, {is_delay_effect = true})

lianli:addEffect(fk.AskForCardUse, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return not player.dead and
      (Exppattern:Parse(data.pattern):matchExp("jink")) and
      table.contains(target:getTableMark("@@qyt__lianli_from"), player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local respond = room:askToResponse(player, {
      skill_name = self.name,
      pattern = "jink",
      prompt = "#qyt__lianli-jink-use:"..target.id,
      cancelable = true,
      extra_data = {qyt__lianli_ask = true},
    })
    if respond then
      respond.skipDrop = true
      room:responseCard(respond)
      local new_card = Fk:cloneCard("jink")
      new_card.skillName = self.name
      new_card:addSubcards(room:getSubcardsByRule(respond.card, { Card.Processing }))
      data.result = {
        from = target.id,
        card = new_card,
        tos = {}
      }
      if data.eventData then
        data.result.toCard = data.eventData.toCard
        data.result.responseToEvent = data.eventData.responseToEvent
      end
      return true
    end
  end,
})

lianli:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@qyt__lianli_from") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local skel = self:getSkeleton()
    if skel then
      skel:onLose(player, false)
    end
  end,
})

-- “连理”对象死亡时，清除连理来源的标记
lianli:addEffect(fk.BuryVictim, {
  can_refresh = function (self, event, target, player, data)
    return target == player and target:getMark("@@qyt__lianli_to") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(target:getTableMark("@@qyt__lianli_to")) do
      room:removeTableMark(room:getPlayerById(pid), "@@qyt__lianli_from", target.id)
    end
    room:setPlayerMark(target, "@@qyt__lianli_to", 0)
    room:handleAddLoseSkills(target, "-qyt__lianli_slash&", nil, false, true)
    data.extra_data = data.extra_data or {}
    data.extra_data.qyt__liqian_check = true
  end,
})

Fk:loadTranslationTable{
  ["qyt__lianli"] = "连理",
  [":qyt__lianli"] = "准备阶段开始时，你可以选择一名男性角色，你与其进入连理状态直到你下回合开始：其可以替你使用或打出【闪】，"..
  "你可以替其使用或打出【杀】。",
  ["#qyt__lianli-choose"] = "连理：选择一名男性角色，你与其进入连理状态",
  ["@@qyt__lianli_to"] = "连理",
  ["@@qyt__lianli_from"] = "连理",
  ["#qyt__lianli-jink-resp"] = "连理：你可以为 %src 打出一张【闪】",
  ["#qyt__lianli-jink-use"] = "连理：你可以为 %src 使用一张【闪】",

  ["$qyt__lianli1"] = "连理并蒂，比翼不移。",
  ["$qyt__lianli2"] = "陟彼南山，言采其樵。未见君子，忧心惙惙。",
}

return lianli
