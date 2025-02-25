local chouliang = fk.CreateSkill{
  name = "qw__chouliang",
}

chouliang:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and player:getHandcardNum() < 4
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = 4 - player:getHandcardNum()
    local cards = room:getNCards(x)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player,
      skillName = chouliang.name,
    })
    local basic = table.filter(cards, function(id)
      return Fk:getCardById(id).type == Card.TypeBasic and room:getCardArea(id) == Card.Processing
    end)
    if player:isAlive() and #basic > 0 then
      room:delay(600)
      room:obtainCard(player, basic, true, fk.ReasonJustMove, player, chouliang.name)
    end
    room:cleanProcessingArea(cards, chouliang.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__chouliang"] = "筹粮",
  [":qw__chouliang"] = "结束阶段，你可以亮出牌堆顶X张牌（X为4-你的手牌数），你获得其中的基本牌，将其余的牌置入弃牌堆。 ",
}

return chouliang
