local jiehuo = fk.CreateSkill{
  name = "qw__jiehuo",
  tags = {Skill.Wake},
}

jiehuo:addEffect(fk.AfterCardsMove, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(jiehuo.name) and player:usedSkillTimes(jiehuo.name, Player.HistoryGame) == 0
    and data.extra_data and data.extra_data.qw__jiehuoCount
  end,
  can_wake = function (self, event, target, player, data)
    return data.extra_data and data.extra_data.qw__jiehuoCount >= 7
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@qw__jiehuo", 0)
    room:changeMaxHp(player, -1)
    if player:isAlive() then
      room:handleAddLoseSkills(player, "qw__shien")
    end
  end,
})

jiehuo:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    return player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.skillName == "qw__shouye" and move.moveReason == fk.ReasonDraw then
        n = n + #move.moveInfo
      end
    end
    if n > 0 then
      player.room:addPlayerMark(player, "qw__jiehuo", n)
      n = player:getMark("qw__jiehuo")
      data.extra_data = data.extra_data or {}
      data.extra_data.qw__jiehuoCount = n
      if player:usedSkillTimes(jiehuo.name, Player.HistoryGame) == 0 and player:hasSkill(jiehuo.name, true) then
        player.room:setPlayerMark(player, "@qw__jiehuo", n)
      end
    end
  end,
})

jiehuo:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@qw__jiehuo", 0)
end)

Fk:loadTranslationTable{
  ["qw__jiehuo"] = "解惑",
  [":qw__jiehuo"] = "觉醒技，当你发动〖授业〗令其他角色摸牌不少于7张后，你减1点体力上限，获得技能〖师恩〗。",
  ["@qw__jiehuo"] = "解惑",
  ["$qw__jiehuo1"] = "",
  ["$qw__jiehuo2"] = "",
}

return jiehuo
