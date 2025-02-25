local juao = fk.CreateSkill{
  name = "qw__juao",
}

juao:addEffect("active", {
  anim_type = "control",
  prompt = "#qw__juao",
  card_num = 2,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and #selected < 2
  end,
  target_filter = function (self, player, to_select, selected, cards)
    return #selected == 0 and #cards == 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local to = effect.tos[1]
    to:addToPile("$qw__juao", effect.cards, false, juao.name, effect.from)
  end,
})

--- 注：$牌堆默认对所有者可见
juao:addEffect("visibility", {
  card_visible = function(self, player, card)
    if player:getPileNameOfId(card.id) == "$qw__juao" then
      return false
    end
  end
})

juao:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getPile("$qw__juao") > 0 and player.phase == Player.Start
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, player:getPile("$qw__juao"), false, fk.ReasonJustMove, player, juao.name)
    player:skip(Player.Draw)
  end,
})


Fk:loadTranslationTable{
  ["qw__juao"] = "倨傲",
  [":qw__juao"] = "出牌阶段限一次，你可以将两张手牌扣置于并一名角色的武将牌旁，该角色下个准备阶段，其获得这些牌并跳过摸牌阶段。",
  ["#qw__juao"] = "倨傲：将两张手牌扣置一名角色武将牌旁，令其下回合获得之并跳过摸牌阶段",
  ["$qw__juao"] = "倨傲",
}

return juao
