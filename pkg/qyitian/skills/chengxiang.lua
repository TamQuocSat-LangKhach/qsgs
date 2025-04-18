local chengxiang = fk.CreateSkill({
  name = "qyt__chengxiang",
})

chengxiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(chengxiang.name) and not player:isNude() and data.card and data.card.number > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "qyt__chengxiang_active",
      prompt = "#qyt__chengxiang-invoke:::"..data.card.number,
      cancelable = true,
      skip = true,
      extra_data = {qyt__chengxiang_num = data.card.number},
    })
    if success and dat then
      room:sortByAction(dat.targets)
      event:setCostData(self, {cards = dat.cards, tos = dat.targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, chengxiang.name, player, player)
    for _, to in ipairs(event:getCostData(self).tos) do
      if not to.dead then
        if to:isWounded() then
          room:recover{
            who = to,
            num = 1,
            recoverBy = player,
            skillName = chengxiang.name
          }
        else
          to:drawCards(2, chengxiang.name)
        end
      end
    end
  end,
})

Fk:loadTranslationTable{
  ["qyt__chengxiang"] = "称象",
  [":qyt__chengxiang"] = "当你受到伤害后，你可以弃置任意张点数之和与造成伤害的牌的点数相等的牌并选择至多等量的角色，若这些角色："..
  "已受伤，回复1点体力；未受伤，摸两张牌。",
}

return chengxiang
