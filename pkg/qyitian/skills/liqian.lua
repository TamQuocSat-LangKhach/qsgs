local liqian = fk.CreateSkill({
  name = "qyt__liqian",
  tags = {Skill.Compulsory},
})


--- 获取理应成为的势力
---@param player ServerPlayer
local getCorretKingdom = function (player)
  local room = player.room
  if player:hasSkill(liqian.name) then
    local targets = table.connect(player:getTableMark("@@qyt__lianli_from"), player:getTableMark("@@qyt__lianli_to"))
    for _, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        return p.kingdom
      end
    end
    return "wei"
  end
  return player.kingdom
end

-- 准备阶段结束时检测一次技能“连理”是否发动
liqian:addEffect(fk.EventPhaseEnd, {
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(liqian.name) and player.phase == Player.Start then
      return player.kingdom ~= getCorretKingdom(player)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, getCorretKingdom(player), true)
  end,
})

-- 防止修改势力
liqian:addEffect(fk.BeforePropertyChange, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(liqian.name) and target == player then
      return data.kingdom and data.kingdom ~= getCorretKingdom(player)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.kingdom = getCorretKingdom(player)
  end,
})

-- “连理”对象变更势力后，你也跟着变
liqian:addEffect(fk.AfterPropertyChange, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(liqian.name) and target ~= player and data.results["kingdomChange"] then
      return player.kingdom ~= getCorretKingdom(player)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, getCorretKingdom(player), true)
  end,
})

-- “连理”对象死亡时检测一次
liqian:addEffect(fk.Deathed, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(liqian.name) and (data.extra_data or Util.DummyTable).qyt__liqian_check then
      return player.kingdom ~= getCorretKingdom(player)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, getCorretKingdom(player), true)
  end,
})

Fk:loadTranslationTable{
  ["qyt__liqian"] = "离迁",
  [":qyt__liqian"] = "锁定技，若你处于连理状态，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏。",
}


return liqian
