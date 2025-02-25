local weidai = fk.CreateSkill{
  name = "qw__weidai",
  tags = {Skill.Lord},
}

weidai:addEffect("viewas", {
  mute = true,
  prompt = "#qw__weidai",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if #cards ~= 0 then return nil end
    local c = Fk:cloneCard("analeptic")
    c.skillName = weidai.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    player:broadcastSkillInvoke(weidai.name)
    room:notifySkillInvoked(player, weidai.name, player.dying and "defensive" or "offensive")
    for _, to in ipairs(room:getOtherPlayers(player)) do
      if to.kingdom == "wu" and to:isAlive() then
        local cards = room:askToCards(to, {
          min_num = 1, max_num = 1, skill_name = weidai.name, include_equip = false, cancelable = true,
          pattern = ".|2~9|spade|hand", prompt = "#qw__weidai-ask:"..player.id,
        })
        if #cards > 0 then
          room:moveCards({
            from = to,
            ids = cards,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
            proposer = to,
          })
          room:doIndicate(to.id, {player.id})
          local to_use = Fk:cloneCard("analeptic")
          if room:getCardArea(cards[1]) == Card.DiscardPile then
            to_use:addSubcard(cards[1])
          end
          to_use.skillName = weidai.name
          use.card = to_use
          return
        end
      end
    end
    if Fk.currentResponsePattern == nil then
      room:setPlayerMark(player, "qw__weidai-failed-phase", 1)
    end
    return self.name
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qw__weidai-failed-phase") == 0 and player:canUse(Fk:cloneCard("analeptic"))
    and table.find(Fk:currentRoom().alive_players, function(to)
      return to ~= player and to.kingdom == "wu"
    end)
  end,
  enabled_at_response = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function(to)
      return to ~= player and to.kingdom == "wu"
    end)
  end,
})

Fk:loadTranslationTable{
  ["qw__weidai"] = "危殆",
  [":qw__weidai"] = "主公技，当你需要使用一张【酒】时，你可以令其他吴势力角色选择是否将一张♠2~9的手牌置入弃牌堆，若其如此做，你将此牌当【酒】使用。",
  ["#qw__weidai-ask"] = "危殆：你可以展示一张♠2~9的手牌，令 %src 将之当【酒】使用",
  ["#qw__weidai"] = "危殆：询问吴势力角色将♠2~9的手牌置入弃牌堆，若有人如此做，你将其当【酒】使用",
}

return weidai
