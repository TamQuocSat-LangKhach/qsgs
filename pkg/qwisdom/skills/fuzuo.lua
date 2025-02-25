local fuzuo = fk.CreateSkill{
  name = "qw__fuzuo",
}

fuzuo:addEffect(fk.PindianCardsDisplayed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuzuo.name) and not player:isKongcheng() and data.from ~= player
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(data.tos)
    table.insert(targets, data.from)
    local ids = table.filter(player:getCardIds("h"), function(id)
      local c = Fk:getCardById(id)
      return not player:prohibitDiscard(c) and c.number < 8
    end)
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      max_card_num = 1, min_card_num = 1, max_num = 1, min_num = 1, skill_name = fuzuo.name,
      prompt = "#qw__fuzuo-card", pattern = tostring(Exppattern{ id = ids }),
      targets = targets,
    })
    if #tos == 1 and #cards == 1 then
      event:setCostData(self, {tos = tos, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards
    local num = Fk:getCardById(cards[1]).number
    room:throwCard(cards, fuzuo.name, player, player)
    room:changePindianNumber(data, to, num, fuzuo.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__fuzuo"] = "辅佐",
  -- 原版：每当其他角色拼点时，你可以弃置一张点数小于8的手牌，让其中一名角色的拼点牌的点数加上这张牌点数的二分之一（向下取整） 
  [":qw__fuzuo"] = "当其他角色发起的拼点亮出拼点牌时，你可以弃置一张点数小于8的手牌，令其中一名角色的拼点牌点数加上你弃置的牌的点数（至多加到13）。",
  ["#qw__fuzuo-card"] = "辅佐：可以弃置一张点数小于8的手牌，令一名参与拼点角色的点数增加",
}

return fuzuo
