local xiliang = fk.CreateSkill {
  name = "qyt__xiliang",
}

xiliang:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xiliang.name) then
      local cards = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id and
            move.from.phase == Player.Discard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).color == Card.Red and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end
      cards = room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(event:getCostData(self).cards)
    if #ids > 0 then
      local rest = 5 - #player:getPile("zhanggongqi_rice")
      if rest > 4 then
        local cards = room:askToChooseCards(player, {
          target = player, skill_name = xiliang.name, prompt = "#qyt__xiliang-put:::"..rest,
          min = 0, max = rest,
          flag = { card_data = { { xiliang.name, ids } } }
        })
        if #cards > 0 then
          player:addToPile("zhanggongqi_rice", cards, true, xiliang.name)
        end
      end
      if player.dead then return end
      ids = table.filter(ids, function (id)
        return room:getCardArea(id) == Card.DiscardPile
      end)
      if #ids == 0 then return end
      local cards = room:askToChooseCards(player, {
        target = player, skill_name = xiliang.name, prompt = "#qyt__xiliang-prey",
        min = 0, max = #ids,
        flag = { card_data = { { xiliang.name, ids } } }
      })
      if #cards > 0 then
        room:obtainCard(player, cards, true, fk.ReasonJustMove, player, xiliang.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__xiliang"] = "惜粮",
  [":qyt__xiliang"] = "当其他角色于其弃牌阶段弃置一张红色牌后，你可以选择一项：1.将之置为“米”；2.获得之。",
  ["#qyt__xiliang-put"] = "惜粮：选择至多 %arg 张牌置为“米”",
  ["#qyt__xiliang-prey"] = "惜粮：你可以获得其中任意张牌",
  ["qyt__xiliang_put"] = "置为“米”",
}

return xiliang
