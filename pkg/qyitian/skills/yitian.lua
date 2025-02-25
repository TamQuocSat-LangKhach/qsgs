local yitian = fk.CreateSkill{
  name = "qyt__yitian",
  --tags = 联动技
}

yitian:addEffect(fk.DamageCaused, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yitian.name) and
    (string.find(data.to.general, "caocao") or string.find(data.to.deputyGeneral, "caocao"))
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = yitian.name, prompt = "#qyt__yitian-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
  end,
})

Fk:loadTranslationTable{
  ["qyt__yitian"] = "倚天",
  [":qyt__yitian"] = "联动技，当你对曹操造成伤害时，你可以令该伤害-1。",
  ["#qyt__yitian-invoke"] = "倚天：你可以令你对 %dest 造成的伤害-1",
}

return yitian
