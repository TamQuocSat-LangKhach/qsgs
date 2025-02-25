local hujia = fk.CreateSkill {
  name = "qyt__hujia",
}

hujia:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hujia.name) and player.phase == Player.Finish
  end,
  can_wake = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#qyt__hujia-invoke:::"..0})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    while not player.dead do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|heart,diamond",
      }
      room:judge(judge)
      if judge.card and judge.card.color == Card.Red and not player.dead then
        n = n + 1
        room:obtainCard(player.id, judge.card, true, fk.ReasonJustMove, player.id, hujia.name)
        if not player.dead and n == 3 then
          player:turnOver()
        end
      else
        break
      end
      if player.dead or not room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#qyt__hujia-invoke:::"..n}) then
        break
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__hujia"] = "胡笳",
  [":qyt__hujia"] = "结束阶段开始时，你可以进行判定：若结果为红色，你获得此判定牌，然后你可以重复此流程；若达到三次，你将武将牌翻面。",
  ["#qyt__hujia-invoke"] = "胡笳：你可以判定，若为红色则获得之，达到三张后翻面（已获得%arg张）",
  ["$qyt__hujia"] = "北风厉兮肃泠泠，胡笳动兮边马鸣。",
}

return hujia
