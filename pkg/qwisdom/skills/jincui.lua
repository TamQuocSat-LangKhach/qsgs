local jincui = fk.CreateSkill{
  name = "qw__jincui",
}

jincui:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jincui.name, false, true) and target == player
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, skill_name = jincui.name, prompt = "#qw__jincui-choose",
      targets = player.room.alive_players,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choices = {"draw3"}
    if not to:isNude() then table.insert(choices, "discard3") end
    local choice = room:askToChoice(player, {choices = choices, skill_name = jincui.name})
    if choice == "draw3" then
      to:drawCards(3, self.name)
    else
      room:askToDiscard(to, {min_num = 3, max_num = 3, cancelable = false, include_equip = true, skill_name = jincui.name})
    end
  end,
})

Fk:loadTranslationTable{
  ["qw__jincui"] = "尽瘁",
  [":qw__jincui"] = "当你死亡时，可选择一名其他角色，令该角色摸三张牌或者弃置三张牌。",
  ["#qw__jincui-choose"] = "尽瘁：可以令一名其他角色摸三张牌或者弃置三张牌",
  ["discard3"] = "弃置三张牌",
}

return jincui
