local shenjun = fk.CreateSkill {
  name = "qyt__shenjun",
  tags = {Skill.Compulsory},
}

local function useShenjun(player, event)
  local room = player.room
  local choices = {"male", "female"}
  if event == fk.EventPhaseStart then
    local gender
    if player.gender == General.Male then gender = "male" -- 故意的
    elseif player.gender == General.Female then gender = "female" end
    table.removeOne(choices, gender)
  end
  local choice = room:askForChoice(player, choices, shenjun.name, "#qyt__shenjun-choose")
  room:setPlayerProperty(player, "gender", choice == "male" and General.Male or General.Female)
  room:sendLog{
    type = "#qyt__shenjun_log",
    from = player.id,
    arg = choice,
  }
  room:setPlayerMark(player, "@!qixi_" .. choice, 1) -- 依赖 gamemode 七夕模式
  room:setPlayerMark(player, "@!qixi_" .. (choice == "male" and "female" or "male"), 0)
end

shenjun:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shenjun.name)
  end,
  on_use = function(self, event, target, player, data)
    useShenjun(player, event)
  end,
})

shenjun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shenjun.name) and target == player and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    useShenjun(player, event)
  end,
})

shenjun:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shenjun.name) and target == player and
    data.from and player:compareGenderWith(data.from, true) and data.damageType ~= fk.ThunderDamage
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

Fk:loadTranslationTable{
  ["qyt__shenjun"] = "神君",
  [":qyt__shenjun"] = "锁定技，游戏开始时，你选择自己的性别为男或女；准备阶段开始时，你须改变性别；当你受到异性角色造成的非雷电伤害时，你防止之。",
  ["#qyt__shenjun-choose"] = "神君：选择你的性别",
  ["#qyt__shenjun_log"] = "%from 性别改为 %arg",
}

return shenjun
