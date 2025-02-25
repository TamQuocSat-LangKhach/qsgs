local weiyan = fk.CreateSkill{
  name = "qyt__weiyan",
}

weiyan:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weiyan.name) and (data.phase == Player.Draw or data.phase == Player.Play)
  end,
  on_cost = function(self, event, target, player, data)
    local arg, arg2
    if data.phase == Player.Draw then
      arg = "phase_draw"
      arg2 = "phase_play"
    else
      arg = "phase_play"
      arg2 = "phase_draw"
    end
    return player.room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#qyt__weiyan-invoke:::"..arg..":"..arg2})
  end,
  on_use = function(self, event, target, player, data)
    data.phase = (data.phase == Player.Draw) and Player.Play or Player.Draw
  end,
})

Fk:loadTranslationTable{
  ["qyt__weiyan"] = "围堰",
  [":qyt__weiyan"] = "你可以将摸牌阶段改为出牌阶段，将出牌阶段改为摸牌阶段。",
  ["#qyt__weiyan-invoke"] = "围堰：你可以将即将进入的【%arg】改为【%arg2】",
}

return weiyan
