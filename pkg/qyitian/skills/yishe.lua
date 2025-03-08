local yishe = fk.CreateSkill({
  name = "qyt__yishe",
  attached_skill_name = "qyt__yishe&",
})

yishe:addEffect("active", {
  prompt = "#qyt__yishe",
  expand_pile = "zhanggongqi_rice",
  can_use = function(self, player)
    return player:usedSkillTimes(yishe.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand or player:getPileNameOfId(to_select) == "zhanggongqi_rice"
  end,
  feasible = function (self, player, selected, selected_cards)
    local to_put = table.filter(selected_cards, function(id)
      return Fk:currentRoom():getCardArea(id) == Card.PlayerHand
    end)
    local to_get = table.filter(selected_cards, function(id)
      return player:getPileNameOfId(id) == "zhanggongqi_rice"
    end)
    return #selected_cards > 0 and #player:getPile("zhanggongqi_rice") - #to_get + #to_put < 6
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to_put  = table.filter(effect.cards, function(id)
      return room:getCardArea(id) == Card.PlayerHand
    end)
    local to_get = table.filter(effect.cards, function(id)
      return player:getPileNameOfId(id) == "zhanggongqi_rice"
    end)
    room:swapCardsWithPile(player, to_put, to_get, yishe.name, "zhanggongqi_rice", true)
  end,
})

Fk:loadTranslationTable{
  ["qyt__yishe"] = "义舍",
  [":qyt__yishe"] = "出牌阶段限一次，你可以将任意张手牌与任意张“米”交换（“米”至多五张）；其他角色的出牌阶段限两次，其可以选择一张“米”，你可以将之交给其。",
  -- 原版：出牌阶段，你可以将至少一张手牌置于你的武将牌上称为“米”（“米”不能多于五张）或获得至少一张“米”；其他角色的出牌阶段限两次，其可选择一张“米”，你可以将之交给其。 
  ["#qyt__yishe"] = "义舍：选择任意张手牌置为“米”，选择任意张“米”获得（“米”至多五张）",
  ["zhanggongqi_rice"] = "米",
}

return yishe
