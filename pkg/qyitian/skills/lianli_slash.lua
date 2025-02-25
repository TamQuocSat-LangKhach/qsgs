local lianli = fk.CreateSkill {
  name = "qyt__lianli_slash&",
}

lianli:addEffect("viewas", {
  prompt = "#qyt__lianli_slash",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = lianli.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    if use.tos then
      room:doIndicate(player.id, use.tos)
    end

    for _, pid in ipairs(player:getTableMark("@@qyt__lianli_to")) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        local cardResponded = room:askToResponse(p, {
          skill_name = lianli.name,
          pattern = "slash",
          prompt = "#qyt__lianli_slash-ask:"..player.id,
          cancelable = true,
        })
        if cardResponded then
          room:responseCard({
            from = p,
            card = cardResponded,
            skipDrop = true,
          })

          use.card:addSubcards(room:getSubcardsByRule(cardResponded, { Card.Processing }))
          return
        end
      end
    end

    room:setPlayerMark(player, "qyt__lianli_slash-phase", 1)
    return lianli.name
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qyt__lianli_slash-phase") == 0 and player:getMark("@@qyt__lianli_to") ~= 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@@qyt__lianli_to") ~= 0
  end,
})

Fk:loadTranslationTable{
  ["qyt__lianli_slash&"] = "连理",
  [":qyt__lianli_slash&"] = "连理角色可以替你使用或打出【杀】。",
  ["#qyt__lianli_slash-ask"] = "连理：是否替 %src 使用或打出【杀】？",
  ["#qyt__lianli_slash"] = "连理：选择【杀】的目标，请求连理角色替你使用或打出【杀】",
}

return lianli
