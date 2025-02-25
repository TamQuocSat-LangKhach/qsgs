local guixin = fk.CreateSkill({
  name = "qyt__guixin",
})

---@param player ServerPlayer
local function doGuixin(player, choice)
  local room = player.room
  if choice == "qyt-change-kingdom" then
    local victim = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = "qyt__guixin",
      prompt = "#qyt__guixin-kingdom",
      cancelable = false,
    })[1]
    local kingdoms = table.simpleClone(Fk.kingdoms)
    table.removeOne(kingdoms, victim.kingdom)
    choice = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = "qyt__guixin",
      all_choices = Fk.kingdoms,
    })
    room:changeKingdom(victim, choice, true)
  else
    local tag = room:getTag("qyt_guixin_table")
    if tag == nil then
      tag = {}
      local lord_skills = {}
      for _, g in ipairs(Fk:getAllGenerals()) do
        for _, sname in ipairs(g:getSkillNameList(true)) do
          local s = Fk.skills[sname]
          if s and s:hasTag(Skill.Lord) and table.insertIfNeed(lord_skills, sname) then
            table.insert(tag, { g.name, sname })
          end
        end
      end
      room:setTag("qyt_guixin_table", tag)
    end
    local skills, generals = {}, {}
    for _, v in ipairs(tag) do
      if not table.find(room.alive_players, function(p)
        return p:hasSkill(v[2], true)
      end) then
        table.insert(skills, v[2])
        table.insert(generals, v[1])
      end
    end
    if #skills == 0 then return end --FIXME
    local result = room:askToCustomDialog(player,
    {skill_name = "qyt__guixin", qml_path = "packages/utility/qml/ChooseSkillBox.qml",
    extra_data = { skills, 1, 1, "#qyt__guixin-choice", generals }})
    local skill = skills[1]
    if result ~= "" then
      skill = json.decode(result)[1]
    end
    room:handleAddLoseSkills(player, skill)
  end
end

guixin:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(guixin.name) then
      return player.phase == Player.Finish
    end
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askToChoice(player, {choices = {"qyt-change-kingdom", "qyt-add-lord-skill", "Cancel"}, skill_name = self.name})
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    doGuixin(player, event:getCostData(self))
  end,
})

guixin:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(guixin.name)
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askToChoice(player, {choices = {"qyt-change-kingdom", "qyt-add-lord-skill", "Cancel"}, skill_name = self.name})
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    doGuixin(player, event:getCostData(self))
  end,
})

Fk:loadTranslationTable{
  ["qyt__guixin"] = "归心",
  [":qyt__guixin"] = "结束阶段开始时或你受到伤害后，你可以选择一项：1.改变一名角色的势力；2.获得一个未加入游戏的主公技。",
  ["qyt-change-kingdom"] = "改变一名角色的势力",
  ["qyt-add-lord-skill"] = "获得一个未加入游戏的主公技",
  ["#qyt__guixin-choice"] = "归心：选择一个主公技获得，窗口可拖动",
  ["#qyt__guixin-kingdom"] = "归心：选择一名角色，改变其势力",

  ["$qyt__guixin1"] = "挟天子以令诸侯，握敕令以制四方！",
  ["$qyt__guixin2"] = "天下人才，皆入我麾下！",
}

return guixin
