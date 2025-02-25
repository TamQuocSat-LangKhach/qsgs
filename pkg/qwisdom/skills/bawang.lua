local bawang = fk.CreateSkill{
  name = "qw__bawang",
}

bawang:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(bawang.name) and data.card.trueName == "slash" then
      local to = data.to
      return player:canPindian(to)
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = bawang.name, prompt = "#qw__bawang-invoke:"..data.to.id}) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local pindian = player:pindian({to}, self.name)
    if pindian.results[to].winner == player and not player.dead then
      local card = Fk:cloneCard("slash")
      card.skillName = bawang.name
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return player:canUseTo(card, p, {bypass_distances = true, bypass_times = true})
      end)
      if #targets == 0 then return false end
      local tos = room:askToChoosePlayers(player, {
        targets = targets, min_num = 1, max_num = 2, cancelable = true, skill_name = bawang.name,
        prompt = "#qw__bawang-slash",
      })
      if #tos > 0 then
        room:useCard{card = card, tos = tos, from = player, extraUse = true}
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__bawang"] = "霸王",
  [":qw__bawang"] = "当你使用【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为对至多两名角色使用一张不计入次数的【杀】。",
  ["#qw__bawang-invoke"] = "霸王：你可以与 %src 拼点，若你赢，你可视为你对至多两名角色使用【杀】",
  ["#qw__bawang-slash"] = "霸王：选择至多两名角色，视为对他们使用【杀】",
}

return bawang
