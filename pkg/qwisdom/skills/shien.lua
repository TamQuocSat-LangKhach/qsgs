local shien = fk.CreateSkill{
  name = "qw__shien",
}

shien:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shien.name) and target ~= player and data.card:isCommonTrick()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(target, {skill_name = shien.name, prompt = "#qw__shien-invoke:"..player.id})
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(target.id, {player.id})
    player:drawCards(1, shien.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__shien"] = "师恩",
  [":qw__shien"] = "其他角色使用非延时锦囊时，可以令你摸一张牌。",
  ["#qw__shien-invoke"] = "师恩：是否令 %src 摸一张牌？",
}

return shien
