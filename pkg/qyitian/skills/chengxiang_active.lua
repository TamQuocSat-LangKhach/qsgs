local chengxiang_active = fk.CreateSkill({
  name = "qyt__chengxiang_active",
})

chengxiang_active:addEffect("active", {
  mute = true,
  min_card_num = 1,
  min_target_num = 1,
  card_filter = function (self, player, to_select, selected)
    if not player:prohibitDiscard(Fk:getCardById(to_select)) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= (self.qyt__chengxiang_num or -1)
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    local num = 0
    for _, id in ipairs(selected_cards) do
      num = num + Fk:getCardById(id).number
    end
    return num == (self.qyt__chengxiang_num or -1) and #selected < #selected_cards
  end,
})

Fk:loadTranslationTable{
  ["qyt__chengxiang"] = "称象",
  [":qyt__chengxiang"] = "当你受到伤害后，你可以弃置任意张点数之和与造成伤害的牌的点数相等的牌并选择至多等量的角色，若这些角色："..
  "已受伤，回复1点体力；未受伤，摸两张牌。",
}

return chengxiang_active
