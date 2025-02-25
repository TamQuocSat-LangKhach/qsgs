local tanlan = fk.CreateSkill{
  name = "qw__tanlan",
}

tanlan:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(tanlan.name) then
      return data.from and data.from ~= player and not data.from.dead and player:canPindian(data.from)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = tanlan.name, prompt = "#qw__tanlan-invoke:"..data.from.id}) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from
    local pindian = player:pindian({to}, self.name)
    if pindian.results[to].winner == player and not player.dead then
      local get = {}
      local card = pindian.fromCard
      if card and room:getCardArea(card:getEffectiveId()) == Card.DiscardPile then
        table.insert(get, card:getEffectiveId())
      end
      card = pindian.results[to].toCard
      if card and room:getCardArea(card:getEffectiveId()) == Card.DiscardPile then
        table.insert(get, card:getEffectiveId())
      end
      if #get > 0 then
        room:delay(500)
        room:obtainCard(player, get, true, fk.ReasonPrey, player, tanlan.name)
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__tanlan"] = "贪婪",
  [":qw__tanlan"] = "每当你受到其他角色造成的伤害后，你可以与该角色拼点：若你赢，你获得双方的拼点牌。",
  ["#qw__tanlan-invoke"] = "贪婪：你可以与 %src 拼点，若你赢，你获得双方拼点牌",
}

return tanlan
