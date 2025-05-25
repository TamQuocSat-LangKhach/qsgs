local taichen = fk.CreateSkill{
  name = "qyt__taichen",
}

taichen:addEffect("active", {
  anim_type = "offensive",
  max_card_num = 1,
  target_num = 1,
  can_use = Util.TrueFunc,
  prompt = "#qyt__taichen",
  card_filter = function (self, player, to_select, selected)
    return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isAllNude() and
      player:inMyAttackRange(to_select, nil, selected_cards)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if #effect.cards > 0 then
      room:throwCard(effect.cards, taichen.name, player, player)
    else
      room:loseHp(player, 1, taichen.name)
    end
    for i = 1, 2, 1 do
      if player.dead or target.dead or target:isAllNude() then return end
      local id = room:askToChooseCard(player, {
        target = target, skill_name = taichen.name, flag = "hej"
      })
      room:throwCard(id, taichen.name, target, player)
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__taichen"] = "抬榇",
  [":qyt__taichen"] = "出牌阶段，你可以失去1点体力或弃置一张武器牌，依次弃置你攻击范围内的一名角色区域内的两张牌。",
  ["#qyt__taichen"] = "抬榇：选择一张武器牌或直接点“确定”失去1点体力，依次弃置一名角色区域内两张牌",
}

return taichen
