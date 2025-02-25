local jueji = fk.CreateSkill({
  name = "qyt__jueji",
})

jueji:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#qyt__jueji",
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    while not (player.dead or target.dead or not player:canPindian(target)) do
      local pindian = player:pindian({target}, self.name)
      if pindian.results[target.id].winner ~= player then break end
      if room:getCardArea(pindian.results[target.id].toCard) == Card.DiscardPile then
        room:delay(600)
        room:obtainCard(player, pindian.results[target.id].toCard, true, fk.ReasonJustMove)
      end
      if not player.dead then
        player:drawCards(1, self.name)
      end
      if player.dead or target.dead or not player:canPindian(target) or not
       room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#qyt__jueji-invoke::"..target.id}) then break end
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "control", {target.id})
      room:doIndicate(player.id, {target.id})
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__jueji"] = "绝汲",
  [":qyt__jueji"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，你获得对方的拼点牌并摸一张牌，然后你可以重复此流程，直到你拼点没赢为止。",
  ["#qyt__jueji"] = "绝汲：你可以拼点，若赢，你获得对方拼点牌并摸一张牌，然后可以重复此流程",
  ["#qyt__jueji-invoke"] = "绝汲：你可以继续发动“绝汲”与 %dest 拼点",
}

return jueji
