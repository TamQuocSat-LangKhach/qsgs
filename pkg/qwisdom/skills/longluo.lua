local longluo = fk.CreateSkill{
  name = "qw__longluo",
}

longluo:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(longluo.name) and player.phase == Player.Finish and #player.room.alive_players > 1 then
      local room = player.room
      local n = 0
      local phase_ids = {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
        if e.data.phase == Player.Discard and e.end_id then
          table.insert(phase_ids, {e.id, e.end_id})
        end
        return false
      end, Player.HistoryTurn)
      if #phase_ids == 0 then return false end
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        if table.find(phase_ids, function (ids) return e.id > ids[1] and e.id < ids[2] end) then
          for _, move in ipairs(e.data) do
            if move.from == player and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  n = n + 1
                end
              end
            end
          end
        end
        return false
      end, Player.HistoryTurn)
      if n > 0 then
        event:setCostData(self, {n = n})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local n = event:getCostData(self).n
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, skill_name = longluo.name, cancelable = true,
      targets = player.room:getOtherPlayers(player, false), prompt = "#qw__longluo-choose:::"..n,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos, n = n})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    to:drawCards(event:getCostData(self).n, longluo.name)
  end,
})

Fk:loadTranslationTable{
  ["qw__longluo"] = "笼络",
  [":qw__longluo"] = "结束阶段，你可以令一名其他角色摸数量等于你于本回合弃牌阶段弃置牌数的牌。",
  ["#qw__longluo-choose"] = "笼络：你可以令一名其他角色摸 %arg 张牌",
}

return longluo
