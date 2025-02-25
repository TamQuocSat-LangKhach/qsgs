local yishe_other = fk.CreateSkill({
  name = "qyt__yishe&",
})

yishe_other:addEffect("active", {
  anim_type = "special",
  card_num = 0,
  target_num = 0,
  prompt = "#qyt__yishe-active",
  can_use = function (self, player)
    return player:usedSkillTimes(yishe_other.name, Player.HistoryPhase) < 2 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:hasSkill("qyt__yishe") and #p:getPile("zhanggongqi_rice") > 0
      end)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p:hasSkill("qyt__yishe", true) and #p:getPile("zhanggongqi_rice") > 0
    end)
    if #targets == 0 then return end
    local target = targets[1]
    if #targets > 1 then
      target = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        prompt = "#qyt__yishe-choose",
        skill_name = "qyt__yishe",
        targets = targets,
        cancelable = false,
      })[1]
    end
    target:broadcastSkillInvoke("qyt__yishe")
    room:doIndicate(player.id, {target.id})
    local ids = target:getPile("zhanggongqi_rice")
    local get = room:askToChooseCard(player, {
      target  = target,
      skill_name = "qyt__yishe",
      flag = { card_data = { { "zhanggongqi_rice", ids } } },
      prompt = "#qyt__yishe-card",
    })
    if room:askToSkillInvoke(target, {
      skill_name = "qyt__yishe",
      prompt = "#qyt__yishe-give::"..player.id..":"..Fk:getCardById(get):toLogString()
    }) then
      room:moveCardTo(get, Card.PlayerHand, player, fk.ReasonGive, "qyt__yishe", "", true, target)
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__yishe&"] = "义舍",
  [":qyt__yishe&"] = "出牌阶段限两次，你可以选择一张“米”，张公祺可以将之交给你。",
  ["#qyt__yishe-active"] = "义舍：选择一张“米”，张公祺可以将之交给你",
  ["#qyt__yishe-choose"] = "义舍：选择一名有“米”角色，询问获得其一张“米”",
  ["#qyt__yishe-card"] = "义舍：选择你想获得的“米”",
  ["#qyt__yishe-give"] = "义舍：是否允许 %dest 获得%arg？",
}

return yishe_other
