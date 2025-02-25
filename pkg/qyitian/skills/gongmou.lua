local gongmou = fk.CreateSkill {
  name = "qyt__gongmou",
}

gongmou:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(gongmou.name) and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = player.room:getOtherPlayers(player, false),
      prompt = "#qyt__gongmou-choose",
      cancelable = true,
      skill_name = gongmou.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:addTableMarkIfNeed(to, "@@qyt__gongmou", player.id)
  end,
})

gongmou:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw and player:getMark("@@qyt__gongmou") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.map(player:getTableMark("@@qyt__gongmou"), Util.Id2PlayerMapper)
    room:sortByAction(tos)
    for _, from in ipairs(tos) do
      ---@cast from ServerPlayer
      if not from.dead then
        room:doIndicate(from.id, {player.id})
        from:broadcastSkillInvoke("qyt__gongmou")
        room:notifySkillInvoked(from, "qyt__gongmou", "control")
        local n = math.min(player:getHandcardNum(), from:getHandcardNum())
        if n > 0 then
          local cards = room:askToCards(player, {
            min_num = n,
            max_num = n,
            cancelable = false,
            include_equip = false,
            pattern = ".|.|.|hand",
            prompt = "#qyt__gongmou-give::"..from.id..":"..n,
            skill_name = gongmou.name,
          })
          room:moveCardTo(cards, Card.PlayerHand, from, fk.ReasonGive, gongmou.name, "", false, player)
          if player.dead then break end
          if not from.dead then
            n = math.min(n, from:getHandcardNum())
            if n > 0 then
              cards = room:askToCards(from, {
                min_num = n,
                max_num = n,
                cancelable = false,
                include_equip = false,
                pattern = ".|.|.|hand",
                prompt = "#qyt__gongmou-give::"..player.id..":"..n,
                skill_name = gongmou.name,
              })
              room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, gongmou.name, "", false, from)
              if player.dead then break end
            end
          end
        end
      end
    end
    room:setPlayerMark(player, "@@qyt__gongmou", 0)
  end,
}, {is_delay_effect = true})


Fk:loadTranslationTable{
  ["qyt__gongmou"] = "共谋",
  [":qyt__gongmou"] = "结束阶段，你可以选择一名其他角色，其下个摸牌阶段结束时，将X张手牌交给你，然后你将等量张手牌交给其（X为你与其手牌数的较小值）。",
  ["#qyt__gongmou-choose"] = "共谋：选择一名角色，其下个摸牌阶段结束时，你与其交换若干张手牌",
  ["@@qyt__gongmou"] = "共谋",
  ["#qyt__gongmou-give"] = "共谋：请交给 %dest %arg张手牌",
}

return gongmou
