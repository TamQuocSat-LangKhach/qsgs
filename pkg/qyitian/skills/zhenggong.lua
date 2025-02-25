local zhenggong = fk.CreateSkill({
  name = "qyt__zhenggong",
  tags = {Skill.Compulsory},
})

zhenggong:addEffect(fk.BeforeTurnStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and
      not target:insideExtraTurn() and player.faceup
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhenggong.name, prompt = "#qyt__zhenggong-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    player:gainAnExtraTurn(true)
    if not player.dead then
      player:turnOver()
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__zhenggong"] = "争功",
  [":qyt__zhenggong"] = "其他角色的额定回合开始前，若你的武将牌正面朝上，你可以获得一个额外的回合，此回合结束后，你将武将牌翻面。",
  ["#qyt__zhenggong-invoke"] = "争功：%dest 的回合即将开始，你可以发动“争功”抢先执行一个回合！",
  ["@@qyt__zhenggong"] = "争功",
  ["$qyt__zhenggong"] = "不肯屈人后，看某第一功！",
}

return zhenggong
