local wuling = fk.CreateSkill{
  name = "qyt__wuling",
}

---@param choice string @ 填五灵类型则添加，否则删除
---@param player ServerPlayer
local updataBanner = function (choice, player)
  local room = player.room
  local tag = room.tag["qyt__wuling_record"] or {}
  if choice:startsWith("qyt__wuling") then
    table.insert(tag, {choice, player.id})
  else
    for i = #tag, 1, -1 do
      if tag[i][2] == player.id then
        table.remove(tag, i)
      end
    end
  end
  room.tag["qyt__wuling_record"] = tag
  room:setBanner("@[:]qyt__wuling", #tag == 0 and 0 or table.map(tag, function(t) return t[1] end))
end

local audioMap = {"qyt__wuling_wind", "qyt__wuling_thunder", "qyt__wuling_water", "qyt__wuling_fire", "qyt__wuling_earth"}

wuling:addEffect(fk.EventPhaseStart, {
  mute = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wuling.name) and target == player and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"qyt__wuling_wind", "qyt__wuling_thunder", "qyt__wuling_water", "qyt__wuling_fire", "qyt__wuling_earth", "Cancel"}
    local last = player.tag["qyt__wuling_last"]
    if type(last) == "table" then
      for _, v in ipairs(last) do
        table.removeOne(choices, v)
      end
    end
    local choice = player.room:askToChoice(player, {
      choices = choices, skill_name = wuling.name, detailed = true,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local choice = event:getCostData(self)
    local room = player.room
    player:broadcastSkillInvoke(wuling.name, table.indexOf(audioMap, choice))
    room:notifySkillInvoked(player, wuling.name, "control")
    room:addTableMark(player, "qyt__wuling-turn", choice)
    updataBanner(choice, player)
  end,
})

-- 回合结束时，记录本次发动选项，若未发动，清空记录
wuling:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return player == target
  end,
  on_refresh = function (self, event, target, player, data)
    player.tag["qyt__wuling_last"] = player:getTableMark("qyt__wuling-turn")
  end,
})

wuling:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return player == target
  end,
  on_refresh = function (self, event, target, player, data)
    updataBanner("", player)
  end,
})

wuling:addLoseEffect(function (self, player)
  updataBanner("", player)
end)

wuling:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return player == target and data.damageType == fk.FireDamage
    and table.contains(player.room:getBanner("@[:]qyt__wuling") or Util.DummyTable, "qyt__wuling_wind")
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(wuling.name, 1)
    player.room:notifySkillInvoked(player, wuling.name, "negative")
    local n = #table.filter(player.room:getBanner("@[:]qyt__wuling"), function (v)
      return v == "qyt__wuling_wind"
    end)
    data:changeDamage(n)
  end,
  on_cost = Util.TrueFunc,
  is_delay_effect = true,
  mute = true,
})

wuling:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return player == target and data.damageType == fk.ThunderDamage
    and table.contains(player.room:getBanner("@[:]qyt__wuling") or Util.DummyTable, "qyt__wuling_thunder")
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(wuling.name, 2)
    player.room:notifySkillInvoked(player, wuling.name, "negative")
    local n = #table.filter(player.room:getBanner("@[:]qyt__wuling"), function (v)
      return v == "qyt__wuling_thunder"
    end)
    data:changeDamage(n)
  end,
  on_cost = Util.TrueFunc,
  is_delay_effect = true,
  mute = true,
})

wuling:addEffect(fk.PreHpRecover, {
  can_trigger = function (self, event, target, player, data)
    return player == target and data.card and data.card.trueName == "peach"
    and table.contains(player.room:getBanner("@[:]qyt__wuling") or Util.DummyTable, "qyt__wuling_water")
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(wuling.name, 3)
    player.room:notifySkillInvoked(player, wuling.name, "defensive")
    local n = #table.filter(player.room:getBanner("@[:]qyt__wuling"), function (v)
      return v == "qyt__wuling_water"
    end)
    data.num = data.num + n
  end,
  on_cost = Util.TrueFunc,
  is_delay_effect = true,
  mute = true,
})

wuling:addEffect(fk.PreDamage, {
  can_trigger = function (self, event, target, player, data)
    return player == target and data.damageType ~= fk.FireDamage
    and table.contains(player.room:getBanner("@[:]qyt__wuling") or Util.DummyTable, "qyt__wuling_fire")
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(wuling.name, 4)
    player.room:notifySkillInvoked(player, wuling.name, "negative")
    data.damageType = fk.FireDamage
  end,
  on_cost = Util.TrueFunc,
  is_delay_effect = true,
  mute = true,
})

wuling:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return player == target and data.damageType ~= fk.NormalDamage and data.damage > 1
    and table.contains(player.room:getBanner("@[:]qyt__wuling") or Util.DummyTable, "qyt__wuling_earth")
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(wuling.name, 5)
    player.room:notifySkillInvoked(player, wuling.name, "defensive")
    data:changeDamage(1 - data.damage)
  end,
  on_cost = Util.TrueFunc,
  is_delay_effect = true,
  mute = true,
})

Fk:loadTranslationTable{
  ["qyt__wuling"] = "五灵",
  [":qyt__wuling"] = "准备阶段开始时，你可以选择一种与上回合选择不同的效果，对所有角色生效直到你下回合开始："..
  "<br>[风]任意角色受到火属性伤害时，此伤害+1。"..
  "<br>[雷]任意角色受到雷属性伤害时，此伤害+1。"..
  "<br>[水]任意角色受【桃】效果影响回复的体力+1。"..
  "<br>[火]任意角色受到的伤害均视为火焰伤害。"..
  "<br>[土]任意角色受到的属性伤害大于1时，减至1点。",
  ["qyt__wuling_wind"] = "风",
  ["qyt__wuling_thunder"] = "雷",
  ["qyt__wuling_water"] = "水",
  ["qyt__wuling_fire"] = "火",
  ["qyt__wuling_earth"] = "土",
  [":qyt__wuling_wind"] = "任意角色受到火属性伤害时，此伤害+1",
  [":qyt__wuling_thunder"] = "任意角色受到雷属性伤害时，此伤害+1",
  [":qyt__wuling_water"] = "任意角色受【桃】效果影响回复的体力+1",
  [":qyt__wuling_fire"] = "任意角色受到的伤害均视为火焰伤害",
  [":qyt__wuling_earth"] = "任意角色受到的属性伤害大于1时，减至1点",
  ["@[:]qyt__wuling"] = "五灵",

  ["$qyt__wuling1"] = "长虹贯日，火舞旋风。",
  ["$qyt__wuling2"] = "追云逐电，雷动九天。",
  ["$qyt__wuling3"] = "云销雨霁，彩彻区明。",
  ["$qyt__wuling4"] = "举火燎天，星沉地动。",
  ["$qyt__wuling5"] = "大地光华，承天载物。",
}

return wuling
