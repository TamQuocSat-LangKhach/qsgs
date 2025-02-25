local shaoying = fk.CreateSkill {
  name = "qyt__shaoying",
}

shaoying:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shaoying.name) and data.damageType == fk.FireDamage then
      local tars = (data.extra_data or Util.DummyTable).qyt__shaoying_tars or Util.DummyTable
      return table.find(player.room.alive_players, function(p)
        return data.to:distanceTo(p) == 1 or table.contains(tars, p.id)
      end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tars = (data.extra_data or Util.DummyTable).qyt__shaoying_tars or Util.DummyTable
    local targets = table.filter(room.alive_players, function(p)
      return data.to:distanceTo(p) == 1 or table.contains(tars, p.id)
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      prompt = "#qyt__shaoying-ask:" .. data.to.id,
      targets = targets,
      skill_name = self.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:broadcastPlaySound("./packages/hegemony/audio/card/" .. (player.gender == General.Male and "male" or "female" ) .."/burning_camps") -- 依赖国战
    local to = event:getCostData(self).tos[1]
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|heart,diamond",
    }
    room:judge(judge)
    if judge.card and judge.card.color == Card.Red and not to.dead then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = self.name,
      }
    end
  end,
})

shaoying:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and data.damageEvent.damageType == fk.FireDamage
  end,
  on_refresh = function(self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function(p) return data.damageEvent.to:distanceTo(p) == 1 end)
    if #targets == 0 then return end
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.qyt__shaoying_tars = table.map(targets, Util.IdMapper)
  end,
})

Fk:loadTranslationTable{
  ["qyt__shaoying"] = "烧营",
  [":qyt__shaoying"] = "当你对一名角色A造成火焰伤害后，你可选择A距离为1的一名角色B，判定，若为红色，你对B造成1点火焰伤害。",
  -- 原版："当你对一名不处于连环状态的角色A造成火焰伤害扣减体力前，你可选择A距离为1的一名角色B，此伤害结算完毕后，你进行一次判定：若结果为红色，你对B造成1点火焰伤害。",
  ["#qyt__shaoying-ask"] = "烧营：你可选择 %src 距离为1的一名角色，判定，若为红色，你对其造成1点火焰伤害",

  ["$qyt__shaoying1"] = "烈焰升腾，万物尽毁！",
  ["$qyt__shaoying2"] = "以火应敌，贼人何处逃窜？",
}

return shaoying
