local guihan = fk.CreateSkill({
  name = "qyt__guihan",
})

guihan:addEffect("active", {
  prompt = "#qyt__guihan",
  card_num = 2,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    if not player:prohibitDiscard(Fk:getCardById(to_select)) and #selected < 2
      and table.contains(player.player_cards[Player.Hand], to_select) then
      if #selected == 0 then
        return Fk:getCardById(to_select).color == Card.Red
      else
        return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
      end
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 2 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, self.name, player, player)
    room:swapSeat(player, effect.tos[1])
  end,
})

Fk:loadTranslationTable{
  ["qyt__guihan"] = "归汉",
  [":qyt__guihan"] = "出牌阶段限一次，你可以弃置两张花色相同的红色手牌并选择一名其他角色，与其交换位置。",
  ["#qyt__guihan"] = "归汉：弃置两张花色相同的红色手牌，与一名角色交换位置",
  ["$qyt__guihan"] = "雁南征兮欲寄边心，雁北归兮为得汉音。",
}

return guihan
