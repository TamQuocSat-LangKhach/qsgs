local dongcha = fk.CreateSkill({
  name = "qyt__dongcha",
  tags = {Skill.Compulsory},
})

dongcha:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(dongcha.name) and player.phase == Player.Start and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = player.room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#qyt__dongcha-choose",
      skill_name = dongcha.name,
      cancelable = true,
      no_indicate = true,
    })[1]
    if to then
      event:setCostData(self, {to = to.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "qyt__dongcha-turn", event:getCostData(self).to)
  end,
})

dongcha:addEffect("visibility", {
  card_visible = function(self, player, card)
    local owner = Fk:currentRoom():getCardOwner(card.id)
    if owner and owner.id == player:getMark("qyt__dongcha-turn") and table.contains(owner.player_cards[Player.Hand], card.id) then
      return true
    end
  end,
})


Fk:loadTranslationTable{
  ["qyt__dongcha"] = "洞察",
  [":qyt__dongcha"] = "准备阶段，你可以秘密选择一名其他角色，其所有手牌对你可见直到回合结束。",
  ["#qyt__dongcha-choose"] = "洞察：秘密选择一名角色，本回合其手牌对你可见",
}

return dongcha
