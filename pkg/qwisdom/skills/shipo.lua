local shipo = fk.CreateSkill{
  name = "qw__shipo",
}

shipo:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shipo.name) and #target:getCardIds("j") > 0 and target.phase == Player.Judge and #player:getCardIds("he") > 1
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askToDiscard(player, {
      min_num = 2, max_num = 2, include_equip = true, cancelable = true, skip = true, pattern = ".", skill_name = shipo.name,
      prompt = "#qw__shipo-card::"..target.id,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self), self.name, player, player)
    local cards = target:getCardIds("j")
    if #cards > 0 and not player.dead then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, shipo.name)
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__shipo"] = "识破",
  [":qw__shipo"] = "一名角色判定阶段开始时，你可以弃置两张牌，获得其判定区内的所有牌。",
  ["#qw__shipo-card"] = "识破：你可以弃置两张牌，获得 %dest 判定区内的所有牌",
}

return shipo
