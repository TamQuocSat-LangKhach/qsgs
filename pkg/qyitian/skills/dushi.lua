local dushi = fk.CreateSkill({
  name = "qyt__dushi",
  tags = {Skill.Compulsory},
})

dushi:addEffect(fk.Death, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and data.killer and data.killer:isAlive()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(data.killer, "benghuai")
  end,
})

Fk:loadTranslationTable{
  ["qyt__dushi"] = "毒士",
  [":qyt__dushi"] = "锁定技，当你死亡时，杀死你的角色获得〖崩坏〗。",
}

return dushi
