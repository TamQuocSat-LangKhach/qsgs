local toudu = fk.CreateSkill({
  name = "qyt__toudu",
})

toudu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(toudu.name) and not player.faceup and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      skill_name = toudu.name,
      include_equip = true,
      cancelable = true,
      prompt = "#qyt__toudu-invoke",
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, toudu.name, player, player)
    if player.dead then return end
    player:turnOver()
    if player.dead then return end
    player.room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = toudu.name,
      prompt = "#qyt__toudu-slash",
      extra_data = {bypass_distances = true, bypass_times = true},
      cancelable = false,
    })
  end,
})

Fk:loadTranslationTable{
  ["qyt__toudu"] = "偷渡",
  [":qyt__toudu"] = "当你受到伤害后，若你的武将牌背面朝上，你可以弃置一张牌并翻面，然后视为使用一张无距离限制的【杀】。",
  ["#qyt__toudu-invoke"] = "偷渡：你可以弃置一张牌并翻面，视为使用一张无距离限制的【杀】",
  ["#qyt__toudu-slash"] = "偷渡：视为使用一张无距离限制的【杀】",
  ["$qyt__toudu"] = "攻其不意，掩其无备。",
}

return toudu
