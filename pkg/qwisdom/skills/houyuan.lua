local houyuan = fk.CreateSkill{
  name = "qw__houyuan",
}

houyuan:addEffect("active", {
  prompt = "#qw__houyuan",
  anim_type = "support",
  card_num = 2,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2 and table.contains(player.player_cards[Player.Hand], to_select)
    and not player:prohibitDiscard(to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and player ~= to_select and #selected_cards == 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:throwCard(effect.cards, self.name, player, player)
    if to.dead then return end
    to:drawCards(2, houyuan.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__houyuan"] = "后援",
  [":qw__houyuan"] = "出牌阶段限一次，你可以弃置两张手牌并令一名其他角色摸两张牌。",
  ["#qw__houyuan"] = "后援：弃置两张手牌，令一名其他角色摸两张牌",
}

return houyuan
