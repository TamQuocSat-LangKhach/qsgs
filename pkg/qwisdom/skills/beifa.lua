local beifa = fk.CreateSkill{
  name = "qw__beifa",
  tags = {Skill.Compulsory},
}

beifa:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(beifa.name) or not player:isKongcheng() then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askToUseVirtualCard(player, {
      name = "slash", skill_name = beifa.name, cancelable = true, prompt = "#qw__beifa-slash",
       extra_data = {bypass_distances = true, bypass_times = true}
    }) then
      local card = Fk:cloneCard("slash")
      card.skillName = beifa.name
      local use = {card = card, from = player, tos = {player}, extraUse = true }
      room:useCard(use)
      if not player.dead then
        local x = player.hp - player:getHandcardNum()
        if x > 0 then
          player:drawCards(x, beifa.name)
        end
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__beifa"] = "北伐",
  [":qw__beifa"] = "锁定技，当你失去手牌时，若你没有手牌，你选择一项：1.视为使用一张【杀】；2.视为对自己使用一张【杀】（无视合法性限制），然后将手牌摸至与体力值相等。",
  ["#qw__beifa-slash"] = "异才：选择你视为使用【杀】的目标，若未选择，则对自己使用【杀】并摸牌",
}

return beifa
