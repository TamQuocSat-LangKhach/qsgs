local shouye = fk.CreateSkill{
  name = "qw__shouye",
}

shouye:addEffect("active", {
  anim_type = "support",
  card_num = 1,
  min_target_num = 1,
  max_target_num = 2,
  prompt = "#qw__shouye",
  can_use = function(self, player)
    return player:usedSkillTimes("qw__jiehuo", Player.HistoryGame) == 0 or player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and
      table.contains(player.player_cards[Player.Hand], to_select) and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected < 2 and to_select ~= player and #selected_cards == 1
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    room:throwCard(effect.cards, self.name, player, player)
    for _, to in ipairs(effect.tos) do
      if not to.dead then
        to:drawCards(1, shouye.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__shouye"] = "授业",
  [":qw__shouye"] = "出牌阶段，你可以弃置一张红色手牌，令至多两名其他角色各摸一张牌。若你发动过〖解惑〗，此技能每阶段限一次。",
  ["#qw__shouye"] = "授业：弃置一张红色手牌，令至多两名其他角色各摸一张牌",
}

return shouye
