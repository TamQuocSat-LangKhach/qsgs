local gushou = fk.CreateSkill{
  name = "qw__gushou",
}

gushou:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(gushou.name) and target == player and player.phase == Player.NotActive and data.card.type == Card.TypeBasic
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, gushou.name)
  end,
})

gushou:addEffect(fk.CardResponding, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(gushou.name) and target == player and player.phase == Player.NotActive and data.card.type == Card.TypeBasic
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, gushou.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__gushou"] = "固守",
  [":qw__gushou"] = "当你于回合外使用或打出一张基本牌时，你可以摸一张牌。",
}

return gushou
