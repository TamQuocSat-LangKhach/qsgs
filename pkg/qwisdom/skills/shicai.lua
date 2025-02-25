local shicai = fk.CreateSkill{
  name = "qw__shicai",
  tags = {Skill.Compulsory},
}

shicai:addEffect(fk.PindianResultConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shicai.name) and (data.from == player or data.to == player) and data.winner == player
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, shicai.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__shicai"] = "恃才",
  [":qw__shicai"] = "锁定技，当你拼点赢时，你摸一张牌。",
}

return shicai
