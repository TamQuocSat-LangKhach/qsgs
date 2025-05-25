local lexue = fk.CreateSkill({
  name = "qyt__lexue",
})

lexue:addEffect("active", {
  mute = true,
  prompt = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return "#qyt__lexue-active"
    else
      local mark = player:getMark("@qyt__lexue-turn")
      if mark == 0 then return " " end
      return "#qyt__lexue-viewas:::"..mark[1]..":"..mark[2]
    end
  end,
  can_use = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return true
    else
      local mark = player:getMark("@qyt__lexue-turn")
      if mark ~= 0 then
        local card = Fk:cloneCard(mark[2])
        return player:canUse(card) and not player:prohibitUse(card)
      end
    end
  end,
  card_filter = function (self, player, to_select, selected)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return false
    else
      local mark = player:getMark("@qyt__lexue-turn")
      return #selected == 0 and mark ~= 0 and
      Fk:getCardById(to_select):getSuitString(true) == mark[1]
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
    elseif #selected_cards == 1 then
      local mark = player:getMark("@qyt__lexue-turn")
      if mark == 0 then return false end
      local card = Fk:cloneCard(mark[2])
      card:addSubcards(selected_cards)
      card.skillName = self.name
      if card.skill:getMinTargetNum(player) == 0 then
        return false
      else
        return card.skill:targetFilter(player, to_select, selected, selected_cards, card)
      end
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return #selected_cards == 0 and #selected == 1
    elseif #selected_cards == 1 then
      local mark = player:getMark("@qyt__lexue-turn")
      if mark == 0 then return false end
      local card = Fk:cloneCard(mark[2])
      card.skillName = self.name
      card:addSubcards(selected_cards)
      if player:canUse(card) and not player:prohibitUse(card) then
        return card.skill:feasible(player, selected, selected_cards, card)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:notifySkillInvoked(player, self.name)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 1 then
      player:broadcastSkillInvoke(self.name, 1)
      local target = effect.tos[1]
      local card = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = lexue.name,
        cancelable = false,
        pattern = ".|.|.|hand",
        prompt = "#qyt__lexue-show:"..player.id,
      })
      target:showCards(card)
      if player.dead then return end
      card = Fk:getCardById(card[1])
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        room:setPlayerMark(player, "@qyt__lexue-turn", {card:getSuitString(true), card.name})
      end
      if table.contains(target:getCardIds("h"), card.id) then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
      end
    else
      local mark = player:getMark("@qyt__lexue-turn")
      local card = Fk:cloneCard(mark[2])
      card:addSubcards(effect.cards)
      card.skillName = self.name
      player:broadcastSkillInvoke(self.name, card.type == Card.TypeBasic and 2 or 3)
      local use = {
        from = player,
        tos = effect.tos,
        card = card,
      }
      room:useCard(use)
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__lexue"] = "乐学",
  [":qyt__lexue"] = "出牌阶段限一次，你可以令一名其他角色展示一张手牌，你获得之。若为基本牌或普通锦囊牌，本回合出牌阶段，你可以将相同花色的牌"..
  "当此牌使用。",
  ["#qyt__lexue-show"] = "乐学：请展示一张手牌，令 %src 获得",
  ["#qyt__lexue-active"] = "乐学：令一名其他角色展示一张手牌",
  ["#qyt__lexue-viewas"] = "乐学：你可以将一张 %arg 牌当【%arg2】使用",
  ["@qyt__lexue-turn"] = "乐学",

  ["$qyt__lexue1"] = "勤习出奇策，乐学生妙计。",
  ["$qyt__lexue2"] = "此乃五虎上将之勇！",
  ["$qyt__lexue3"] = "此乃诸葛武侯之智。",
}

return lexue
