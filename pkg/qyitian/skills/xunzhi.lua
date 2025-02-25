local xunzhi = fk.CreateSkill({
  name = "qyt__xunzhi",
  tags = {Skill.Limited},
})

xunzhi:addEffect("active", {
  card_num = 0,
  target_num = 0,
  prompt = "#qyt__xunzhi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:drawCards(3, xunzhi.name)
    if player.dead then return end
    local generals = {}
    for name, general in pairs(Fk.generals) do
      if general.kingdom == "shu" and Fk:canUseGeneral(name) then
        table.insert(generals, name)
      end
    end
    local result = room:askToCustomDialog(player, {
      skill_name = xunzhi.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        generals,
        {"OK"},
        "#qyt__xunzhi-choose",
        {},
        1,
        1,
        {player.general, player.deputyGeneral},
      },
    })
    local general = ""
    if result == "" then
      general = "jiangwei"
    else
      local reply = json.decode(result)
      if reply.choice == "OK" then
        general = reply.cards[1]
      else
        general = "jiangwei"
      end
    end
    table.removeOne(room.general_pile, general)
    local isDeputy = false
    if player.deputyGeneral ~= nil and player.deputyGeneral == "qyt__jiangwei" then
      isDeputy = true
    end
    if player:getMark(self.name) == 0 then
      room:setPlayerMark(player, "qyt__xunzhi", {isDeputy and player.deputyGeneral or player.general, isDeputy})
    end
    room:setPlayerProperty(player, isDeputy and "deputyGeneral" or "general", general)
    if not isDeputy then
      if player.gender ~= Fk.generals[general].gender then
        player.gender = Fk.generals[general].gender
        room:notifyProperty(player, player, "general")
      end
      if player.kingdom ~= "shu" then
        room:changeKingdom(player, "shu", true)
      end
    end
    local skills = {}
    local newGeneral = Fk.generals[general] or Fk.generals["blank_shibing"]
    local isLord = (player.role == "lord" and player.role_shown and room:isGameMode("role_mode"))
    for _, name in ipairs(newGeneral:getSkillNameList(isLord)) do
      local s = Fk.skills[name]
      if not (isDeputy and s:hasTag(Skill.MainPlace)) or not (not isDeputy and s:hasTag(Skill.DeputyPlace)) then
        table.insertIfNeed(skills, name)
      end
    end
    for _, s in ipairs(Fk.generals[player.general].skills) do
      if #s.attachedKingdom > 0 then
        if table.contains(s.attachedKingdom, player.kingdom) then
          table.insertIfNeed(skills, s.name)
        else
          if table.contains(skills, s.name) then
            table.removeOne(skills, s.name)
          else
            table.insertIfNeed(skills, "-"..s.name)
          end
        end
      end
    end
    if player.deputyGeneral ~= "" then
      for _, s in ipairs(Fk.generals[player.deputyGeneral].skills) do
        if #s.attachedKingdom > 0 then
          if table.contains(s.attachedKingdom, player.kingdom) then
            table.insertIfNeed(skills, s.name)
          else
            if table.contains(skills, s.name) then
              table.removeOne(skills, s.name)
            else
              table.insertIfNeed(skills, "-"..s.name)
            end
          end
        end
      end
    end
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
  end,
})

xunzhi:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(xunzhi.name, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:killPlayer{
      who = player,
    }
  end,
  is_delay_effect = true,
  mute = true,
})

xunzhi:addEffect(fk.TurnEnd, {
  refresh_events = {fk.BeforeGameOverJudge},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("qyt__xunzhi") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("qyt__xunzhi")
    if mark[2] then
      room:setPlayerProperty(player, "deputyGeneral", mark[1])
    else
      room:setPlayerProperty(player, "general", mark[1])
    end
  end,
})


Fk:loadTranslationTable{
  ["qyt__xunzhi"] = "殉志",
  [":qyt__xunzhi"] = "限定技，出牌阶段，你可以摸三张牌，然后变身为游戏外的一名蜀势力武将（受禁将方案限制；保留原有的技能），若如此做，此回合结束时你死亡。",
  ["#qyt__xunzhi"] = "殉志：摸三张牌并变身为一名蜀势力武将，本回合结束时死亡！",
  ["#qyt__xunzhi-choose"] = "殉志：选择要变身的武将",
  ["$qyt__xunzhi1"] = "丞相，计若不成，维亦无悔！",
  ["$qyt__xunzhi2"] = "蜀汉英烈，忠魂佑我！",
}

return xunzhi
