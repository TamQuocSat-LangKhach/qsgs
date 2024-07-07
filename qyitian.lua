local extension = Package("qyitian")
extension.extensionName = "qsgs"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["qyitian"] = "神杀-倚天",
  ["qyt"] = "倚天",
}

local godcaocao = General(extension, "qyt__godcaocao", "god", 3)
godcaocao:addSkill("feiying")

---@param room Room
local function mkGuixinTable(room)
  -- local lords = Fk.lords
  local tag = {}
  for _, g in ipairs(Fk:getAllGenerals()) do
    -- 假设一个武将只有一个主公技
    --local same_g = Fk:getSameGenerals(g1)
    --for _, g in ipairs(same_g) do
      local lord_skill = table.find(g.skills, function(s)
        return s.lordSkill
      end)
      if lord_skill then
        table.insert(tag, { g.name, lord_skill })
      end
    --end
  end
  room:setTag("qyt_guixin_table", tag)
end

local guixin = fk.CreateTriggerSkill{
  name = "qyt__guixin",
  events = {fk.EventPhaseStart, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return event == fk.Damaged and true or player.phase == Player.Finish
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, { "qyt-change-kingdom",
      "qyt-add-lord-skill", "Cancel" }, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data == "qyt-change-kingdom" then
      local p = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper),
        1, 1, "#qyt__guixin-kingdom", self.name, false)[1]
      local victim = room:getPlayerById(p)
      local kingdoms = table.simpleClone(Fk.kingdoms)
      table.removeOne(kingdoms, victim.kingdom)
      local choice = room:askForChoice(player, kingdoms, self.name, nil, false, Fk.kingdoms)
      room:changeKingdom(victim, choice, true)
    elseif self.cost_data == "qyt-add-lord-skill" then
      if not room:getTag("qyt_guixin_table") then
        mkGuixinTable(room)
      end
      local tab = room:getTag("qyt_guixin_table")
      local skills, generals = {}, {}
      for _, v in ipairs(tab) do
        if not table.find(room.alive_players, function(p)
          return p:hasSkill(v[2])
        end) then
          table.insert(skills, v[2].name)
          table.insert(generals, v[1])
        end
      end
      if #skills == 0 then return end --FIXME
      local result = room:askForCustomDialog(player, self.name,
      "packages/utility/qml/ChooseSkillBox.qml", {
        skills, 1, 1, "#qyt__guixin-choice", generals,
      })
      if result == "" then
        result = { skills[1] }
      else
        result = json.decode(result)
      end
      room:handleAddLoseSkills(player, table.concat(result, "|"), nil)
    end
  end,
}
godcaocao:addSkill(guixin)
Fk:loadTranslationTable{
  ["qyt__godcaocao"] = "魏武帝",
  ["#qyt__godcaocao"] = "超世之英杰",
  --["designer:qyt__godcaocao"] = "韩旭",  好像确实是韩旭
  ["illustrator:qyt__godcaocao"] = "狮子猿",
  --["cv:qyt__godcaocao"] = "倚天の剑",  驾六龙，乘风而行……

  ["qyt__guixin"] = "归心",
  [":qyt__guixin"] = "结束阶段开始时或你受到伤害后，你可以选择一项：1.改变一名角色的势力；2.获得一个未加入游戏的主公技。",
  ["qyt-change-kingdom"] = "改变一名角色的势力",
  ["qyt-add-lord-skill"] = "获得一个未加入游戏的主公技",
  ["#qyt__guixin-choice"] = "归心：选择一个主公技获得，窗口可拖动",
  ["#qyt__guixin-kingdom"] = "归心：选择一名角色，改变其势力",
}

local caochong = General(extension, "qyt__caochong", "wei", 3)
local qyt__chengxiang = fk.CreateTriggerSkill{
  name = "qyt__chengxiang",
  events = {fk.Damaged},
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isNude() and data.card and not data.card:isVirtual()
  end,
  on_trigger = function(self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, data.card.number)
    self:doCost(event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "qyt__chengxiang_active",
      "#qyt__chengxiang-invoke:::"..data.card.number, true)
    if success then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data.cards, self.name, player, player)
    for _, id in ipairs(self.cost_data.targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        if p:isWounded() then
          room:recover{
            who = p,
            num = 1,
            recoverBy = player,
            skillName = self.name
          }
        else
          p:drawCards(2, self.name)
        end
      end
    end
  end,
}
local qyt__chengxiang_active = fk.CreateActiveSkill{
  name = "qyt__chengxiang_active",
  mute = true,
  min_card_num = 1,
  min_target_num = 1,
  card_filter = function(self, to_select, selected)
    if not Self:prohibitDiscard(Fk:getCardById(to_select)) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= Self:getMark("qyt__chengxiang")
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local num = 0
    for _, id in ipairs(selected_cards) do
      num = num + Fk:getCardById(id).number
    end
    return num == Self:getMark("qyt__chengxiang") and #selected < #selected_cards
  end,
  on_use = function(self, room, effect)
  end,
}
local qyt__conghui = fk.CreateTriggerSkill{
  name = "qyt__conghui",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
}
local qyt__zaoyao = fk.CreateTriggerSkill{
  name = "qyt__zaoyao",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and player:getHandcardNum() > 13
  end,
  on_use = function(self, event, target, player, data)
    player:throwAllCards("h")
    player.room:loseHp(player, 1, self.name)
  end,
}
Fk:addSkill(qyt__chengxiang_active)
caochong:addSkill(qyt__chengxiang)
caochong:addSkill(qyt__conghui)
caochong:addSkill(qyt__zaoyao)
Fk:loadTranslationTable{
  ["qyt__caochong"] = "曹冲",
  ["#qyt__caochong"] = "早夭的神童",
  --["designer:qyt__caochong"] = "",
  --["illustrator:qyt__caochong"] = "",
  --["cv:qyt__caochong"] = "",

  ["qyt__chengxiang"] = "称象",
  [":qyt__chengxiang"] = "当你受到伤害后，你可以弃置任意张点数之和与造成伤害的牌的点数相等的牌并选择至多等量的角色，若这些角色："..
  "已受伤，回复1点体力；未受伤，摸两张牌。",
  ["qyt__conghui"] = "聪慧",
  [":qyt__conghui"] = "锁定技，你跳过弃牌阶段。",
  ["qyt__zaoyao"] = "早夭",
  [":qyt__zaoyao"] = "锁定技，结束阶段开始时，若你的手牌数大于13，你须弃置所有手牌并失去1点体力。",
  ["qyt__chengxiang-active"] = "称象",
  ["#qyt__chengxiang-invoke"] = "称象：你可以弃置点数之和为%arg的牌，令至多弃牌数的角色回复体力或摸牌",
}

local zhangjunyi = General(extension, "qyt__zhanghe", "qun", 4)
local qyt__jueji = fk.CreateActiveSkill{
  name = "qyt__jueji",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#qyt__jueji",
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    while not (player.dead or target.dead or player:isKongcheng() or target:isKongcheng()) do
      local pindian = player:pindian({target}, self.name)
      if pindian.results[target.id].winner == player then
        if room:getCardArea(pindian.results[target.id].toCard) == Card.DiscardPile then
          room:delay(1000)
          room:obtainCard(player, pindian.results[target.id].toCard, true, fk.ReasonJustMove)
        end
        if not player.dead then
          player:drawCards(1, self.name)
        end
        if player.dead or target.dead or player:isKongcheng() or target:isKongcheng() then
          break
        else
          if room:askForSkillInvoke(player, self.name, nil, "#qyt__jueji-invoke::"..target.id) then
            player:broadcastSkillInvoke(self.name)
            room:notifySkillInvoked(player, self.name)
            room:doIndicate(player.id, {target.id})
          else
            break
          end
        end
      else
        break
      end
    end
  end,
}
zhangjunyi:addSkill(qyt__jueji)
Fk:loadTranslationTable{
  ["qyt__zhanghe"] = "张儁乂",
  ["#qyt__zhanghe"] = "计谋巧变",
  ["designer:qyt__zhanghe"] = "孔孟老庄胡",
  ["illustrator:qyt__zhanghe"] = "《火凤燎原》",
  --["cv:qyt__zhanghe"] = "",

  ["qyt__jueji"] = "绝汲",
  [":qyt__jueji"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，你获得对方的拼点牌并摸一张牌，然后你可以重复此流程，直到你拼点没赢为止。",
  ["#qyt__jueji"] = "绝汲：你可以拼点，若赢，你获得对方拼点牌并摸一张牌，然后可以重复此流程",
  ["#qyt__jueji-invoke"] = "绝汲：你可以继续发动“绝汲”与 %dest 拼点",
}

local lukang = General(extension, "qyt__lukang", "wu", 4)
local qyt__weiyan = fk.CreateTriggerSkill{
  name = "qyt__weiyan",
  anim_type = "special",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.to == Player.Draw or data.to == Player.Play)
  end,
  on_cost = function(self, event, target, player, data)
    local arg, arg2
    if data.to == Player.Draw then
      arg = "phase_draw"
      arg2 = "phase_play"
    else
      arg = "phase_play"
      arg2 = "phase_draw"
    end
    return player.room:askForSkillInvoke(player, self.name, nil, "#qyt__weiyan-invoke:::"..arg..":"..arg2)
  end,
  on_use = function(self, event, target, player, data)
    if data.to == Player.Draw then
      data.to = Player.Play
    else
      data.to = Player.Draw
    end
  end,
}
local qyt__kegou = fk.CreateTriggerSkill{
  name = "qyt__kegou",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return not table.find(player.room:getOtherPlayers(player), function(p) return p.kingdom == "wu" and p.role ~= "lord" end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "lianying", nil, true, false)
  end,
}
lukang:addSkill(qyt__weiyan)
lukang:addSkill(qyt__kegou)
lukang:addRelatedSkill("lianying")
Fk:loadTranslationTable{
  ["qyt__lukang"] = "陆抗",
  ["#qyt__lukang"] = "最后的良将",
  ["designer:qyt__lukang"] = "太阳神上",
  ["illustrator:qyt__lukang"] = "火神原画",
  --["cv:qyt__lukang"] = "喵小林",

  ["qyt__weiyan"] = "围堰",
  [":qyt__weiyan"] = "你可以将摸牌阶段改为出牌阶段，将出牌阶段改为摸牌阶段。",
  ["qyt__kegou"] = "克构",
  [":qyt__kegou"] = "觉醒技，准备阶段开始时，若你是除主公外唯一的吴势力角色，你减1点体力上限，获得技能〖连营〗。",
  ["#qyt__weiyan-invoke"] = "围堰：即将执行%arg，你可以改为%arg2",
}

Fk:loadTranslationTable{
  ["qyt__godsimayi"] = "晋宣帝",
  ["#qyt__godsimayi"] = "祁山的术士",
  ["designer:qyt__godsimayi"] = "tle2009，塞克洛",
  ["illustrator:qyt__godsimayi"] = "梦三国",
  ["cv:qyt__godsimayi"] = "宇文天启",

  ["qyt__wuling"] = "五灵",
  [":qyt__wuling"] = "准备阶段开始时，你可以选择一种与上回合不同的效果，对所有角色生效直到你下回合开始，你选择的五灵效果不可与上回合重复："..
  "[风]一名角色受到火属性伤害时，此伤害+1。"..
  "[雷]一名角色受到雷属性伤害时，此伤害+1。"..
  "[水]一名角色受【桃】效果影响回复的体力+1。"..
  "[火]一名角色受到的伤害均视为火焰伤害。"..
  "[土]一名角色受到的属性伤害大于1时，防止多余的伤害。",
}

local xiahoujuan = General(extension, "qyt__xiahoushi", "wei", 3, 3, General.Female)
local qyt__lianli = fk.CreateTriggerSkill{
  name = "qyt__lianli",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.find(player.room.alive_players, function(p)
        return p.gender == General.Male
      end)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    self:doCost(event, target, player, data)
    if self.cancel_cost and player:hasSkill("qyt__liqian") and player.kingdom ~= "wei" then  --耦！
      Fk.skills["qyt__liqian"]:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function(p)
      return p.gender == General.Male
    end)
    local to = player.room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#qyt__lianli-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local mark = U.getMark(player, "@@qyt__lianli_from")
    table.insertIfNeed(mark, to.id)
    room:setPlayerMark(player, "@@qyt__lianli_from", mark)
    mark = U.getMark(to, "@@qyt__lianli_to")
    table.insertIfNeed(mark, player.id)
    room:setPlayerMark(to, "@@qyt__lianli_to", mark)
    room:handleAddLoseSkills(to, "qyt__lianli_slash&", nil, false, true)
  end,

  refresh_events = {fk.TurnStart, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if target == player then
      if event == fk.TurnStart then
        return player:getMark("@@qyt__lianli_from") ~= 0
      else
        return table.find(player.room.alive_players, function(p)
          return table.contains(U.getMark(p, "@@qyt__lianli_to"), player.id)
        end)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@qyt__lianli_from", 0)
    for _, p in ipairs(room.alive_players) do
      local mark2 = U.getMark(p, "@@qyt__lianli_to")
      if table.contains(mark2, player.id) then
        table.removeOne(mark2, player.id)
        if #mark2 == 0 then
          mark2 = 0
        end
        room:setPlayerMark(p, "@@qyt__lianli_to", mark2)
        if mark2 == 0 then
          room:handleAddLoseSkills(p, "-qyt__lianli_slash&", nil, false, true)
        end
      end
    end
  end,
}
local qyt__lianli_delay = fk.CreateTriggerSkill{
  name = "#qyt__lianli_delay",
  mute = true,
  events = {fk.AskForCardUse, fk.AskForCardResponse},
  can_trigger = function(self, event, target, player, data)
    return target == player and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      (data.extraData == nil or data.extraData.qyt__lianli_ask == nil) and
      table.find(player.room.alive_players, function(p)
        return table.contains(U.getMark(p, "@@qyt__lianli_to"), player.id)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "qyt__lianli", nil, "#qyt__lianli_jink")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isAlive() and table.contains(U.getMark(player, "@@qyt__lianli_from"), p.id) then
        local cardResponded = room:askForResponse(p, "jink", "jink", "#qyt__lianli_delay-ask:"..player.id, true, {qyt__lianli_ask = true})
        if cardResponded then
          room:responseCard({
            from = p.id,
            card = cardResponded,
            skipDrop = true,
          })

          if event == fk.AskForCardUse then
            data.result = {
              from = player.id,
              card = Fk:cloneCard("jink"),
            }
            data.result.card:addSubcards(room:getSubcardsByRule(cardResponded, { Card.Processing }))
            data.result.card.skillName = self.name

            if data.eventData then
              data.result.toCard = data.eventData.toCard
              data.result.responseToEvent = data.eventData.responseToEvent
            end
          else
            data.result = Fk:cloneCard("jink")
            data.result:addSubcards(room:getSubcardsByRule(cardResponded, { Card.Processing }))
            data.result.skillName = self.name
          end
          return true
        end
      end
    end
  end,
}
local qyt__lianli_slash = fk.CreateViewAsSkill{
  name = "qyt__lianli_slash&",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#qyt__lianli_slash",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if #cards ~= 0 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    if use.tos then
      room:doIndicate(player.id, TargetGroup:getRealTargets(use.tos))
    end

    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(U.getMark(player, "@@qyt__lianli_to"), p.id) then
        local cardResponded = room:askForResponse(p, "slash", "slash", "#qyt__lianli_slash-ask:"..player.id, true)
        if cardResponded then
          room:responseCard({
            from = p.id,
            card = cardResponded,
            skipDrop = true,
          })
          use.card = cardResponded
          return
        end
      end
    end

    room:setPlayerMark(player, "qyt__lianli_slash-failed-phase", 1)
    return self.name
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qyt__lianli_slash-failed-phase") == 0 and player:getMark("@@qyt__lianli_to") ~= 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@@qyt__lianli_to") ~= 0
  end,
}
local qyt__tongxin = fk.CreateTriggerSkill{
  name = "qyt__tongxin",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (target:getMark("@@qyt__lianli_from") ~= 0 or target:getMark("@@qyt__lianli_to") ~= 0)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if i > 1 and (self.cancel_cost or not player:hasSkill(self)) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#qyt__tongxin-invoke") then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and (p:getMark("@@qyt__lianli_from") ~= 0 or p:getMark("@@qyt__lianli_to") ~= 0) then
        room:doIndicate(player.id, {p.id})
        p:drawCards(1, self.name)
      end
    end
  end,
}
local qyt__liqian = fk.CreateTriggerSkill{
  name = "qyt__liqian",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.AfterSkillEffect, fk.AfterPropertyChange},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:hasSkill("qyt__lianli", true) then
      if event == fk.AfterSkillEffect and data == qyt__lianli then
        local mark = U.getMark(player, "@@qyt__lianli_from")
        return player.kingdom ~= player.room:getPlayerById(mark[#mark]).kingdom
      elseif event == fk.AfterPropertyChange then
        return target.kingdom ~= player.kingdom and table.contains(U.getMark(player, "@@qyt__lianli_from"), target.id)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterSkillEffect or event == fk.AfterPropertyChange then
      local mark = U.getMark(player, "@@qyt__lianli_from")
      local to = room:getPlayerById(mark[#mark])
      room:changeKingdom(player, to.kingdom, true)
    else
      room:changeKingdom(player, "wei", true)
    end
  end,
}
qyt__lianli:addRelatedSkill(qyt__lianli_delay)
Fk:addSkill(qyt__lianli_slash)
xiahoujuan:addSkill(qyt__lianli)
xiahoujuan:addSkill(qyt__tongxin)
xiahoujuan:addSkill(qyt__liqian)
Fk:loadTranslationTable{
  ["qyt__xiahoushi"] = "夏侯涓",
  ["#qyt__xiahoushi"] = "樵采的美人",
  ["designer:qyt__xiahoushi"] = "宇文天启，艾艾艾",
  ["illustrator:qyt__xiahoushi"] = "三国志大战",
  ["cv:qyt__xiahoushi"] = "妙妙",

  ["qyt__lianli"] = "连理",
  [":qyt__lianli"] = "准备阶段开始时，你可以选择一名男性角色，你与其进入连理状态直到你下回合开始：其可以替你使用或打出【闪】，"..
  "你可以替其使用或打出【杀】。",
  ["qyt__tongxin"] = "同心",
  [":qyt__tongxin"] = "当一名处于连理状态的角色受到1点伤害后，你可以令处于连理状态的角色各摸一张牌。",
  ["qyt__liqian"] = "离迁",
  [":qyt__liqian"] = "锁定技，若你处于连理状态，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏。",
  ["qyt__lianli_slash&"] = "连理",
  [":qyt__lianli_slash&"] = "连理角色可以替你使用或打出【杀】。",
  ["#qyt__lianli-choose"] = "连理：选择一名男性角色，你与其进入连理状态",
  ["@@qyt__lianli_from"] = "连理",
  ["@@qyt__lianli_to"] = "连理",
  ["#qyt__lianli_slash-ask"] = "连理：是否替 %src 使用或打出【杀】？",
  ["#qyt__lianli_slash"] = "连理：是否令连理角色替你使用或打出【杀】？",
  ["#qyt__lianli_delay-ask"] = "连理：是否替 %src 使用或打出【闪】？",
  ["#qyt__lianli_jink"] = "连理：是否令连理角色替你使用或打出【闪】？",
  ["#qyt__tongxin-invoke"] = "同心：是否令所有处于连理状态的角色各摸一张牌？",
}

local caizhaoji = General(extension, "qyt__caiwenji", "qun", 3, 3, General.Female)
local qyt__guihan = fk.CreateActiveSkill{
  name = "qyt__guihan",
  anim_type = "control",
  card_num = 2,
  target_num = 1,
  prompt = "#qyt__guihan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getHandcardNum() > 1
  end,
  card_filter = function(self, to_select, selected)
    if #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
      not Self:prohibitDiscard(Fk:getCardById(to_select)) then
      if #selected == 0 then
        return Fk:getCardById(to_select).color == Card.Red
      else
        return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
      end
    end
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    room:swapSeat(player, target)
  end,
}
local qyt__hujia = fk.CreateTriggerSkill{
  name = "qyt__hujia",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qyt__hujia-invoke:::"..0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    while not player.dead do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|heart,diamond",
      }
      room:judge(judge)
      if judge.card.color == Card.Red and not player.dead then
        n = n + 1
        room:obtainCard(player.id, judge.card, true, fk.ReasonJustMove)
        if not player.dead and n == 3 then
          player:turnOver()
        end
      else
        break
      end
      if player.dead or not room:askForSkillInvoke(player, self.name, nil, "#qyt__hujia-invoke:::"..n) then
        break
      end
    end
  end,
}
caizhaoji:addSkill(qyt__guihan)
caizhaoji:addSkill(qyt__hujia)
Fk:loadTranslationTable{
  ["qyt__caiwenji"] = "蔡昭姬",
  ["#qyt__caiwenji"] = "乱世才女",
  ["designer:qyt__caiwenji"] = "冢冢的青藤",
  ["illustrator:qyt__caiwenji"] = "火星时代",
  ["cv:qyt__caiwenji"] = "妙妙",

  ["qyt__guihan"] = "归汉",
  [":qyt__guihan"] = "出牌阶段限一次，你可以弃置两张花色相同的红色手牌并选择一名其他角色，与其交换位置。",
  ["qyt__hujia"] = "胡笳",
  [":qyt__hujia"] = "结束阶段开始时，你可以进行判定：若结果为红色，你获得此判定牌，然后你可以重复此流程；若达到三次，你将武将牌翻面。",
  ["#qyt__hujia-invoke"] = "胡笳：你可以判定，若为红色则获得之，达到三张后翻面（已获得%arg张）",
  ["#qyt__guihan"] = "归汉：弃置两张花色相同的红色手牌，与一名角色交换位置",

  ["$qyt__guihan"] = "雁南征兮欲寄边心，雁北归兮为得汉音。",
  ["$qyt__hujia"] = "北风厉兮肃泠泠，胡笳动兮边马鸣。",
  ["~qyt__caiwenji"] = "人生几何时，怀忧终年岁……",
}

local luboyan = General(extension, "qyt__luxun", "wu", 3)

local shenjun = fk.CreateTriggerSkill{
  name = "qyt__lbyshenjun",
  events = {fk.GameStart, fk.EventPhaseStart, fk.DamageInflicted},
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.GameStart then return true
    elseif player ~= target then return false end
    if event == fk.EventPhaseStart then
      return player.phase == Player.Start
    else
      return data.from and player:compareGenderWith(data.from, true) and data.damageType ~= fk.ThunderDamage
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageInflicted then
      room:notifySkillInvoked(player, self.name, "defensive")
      return true
    end
    room:notifySkillInvoked(player, self.name, "special")
    local choices = {"male", "female"}
    if event == fk.EventPhaseStart then
      local gender
      if player.gender == General.Male then gender = "male"
      elseif player.gender == General.Female then gender = "female" end
      table.removeOne(choices, gender)
    end
    local choice = room:askForChoice(player, choices, self.name, "#qyt__lbyshenjun-choose")
    room:setPlayerProperty(player, "gender", choice == "male" and General.Male or General.Female)
    room:sendLog{
      type = "#qyt__lbyshenjun_log",
      from = player.id,
      arg = choice,
    }
    room:setPlayerMark(player, "@!qixi_" .. choice, 1) -- 依赖 gamemode 七夕模式
    room:setPlayerMark(player, "@!qixi_" .. (choice == "male" and "female" or "male"), 0)
  end,
}

local qyt__shaoying = fk.CreateTriggerSkill{
  name = "qyt__shaoying",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damageType == fk.FireDamage and 
      data.to:isAlive() and table.find(player.room.alive_players, function(p) return data.to:distanceTo(p) == 1 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return data.to:distanceTo(p) == 1 end), Util.IdMapper)
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#qyt__shaoying-ask:" .. data.to.id, self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:broadcastPlaySound("./packages/hegemony/audio/card/" .. (player.gender == General.Male and "male" or "female" ) .."/burning_camps") -- 依赖国战
    local target = room:getPlayerById(self.cost_data)
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|heart,diamond",
    }
    room:judge(judge)
    if judge.card.color == Card.Red and not target.dead and not player.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = self.name,
      }
    end
  end,
}

local qyt__zonghuo = fk.CreateTriggerSkill{
  name = "qyt__zonghuo",
  anim_type = "offensive",
  events = { fk.AfterCardUseDeclared },
  frequency = Skill.Compulsory,
  can_trigger = function(self, _, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and data.card.name ~= "fire__slash"
  end,
  on_use = function(self, _, _, _, data)
    local card = Fk:cloneCard("fire__slash")
    card.skillName = self.name
    card:addSubcard(data.card)
    data.card = card
  end,
}

luboyan:addSkill(shenjun)
luboyan:addSkill(qyt__shaoying)
luboyan:addSkill(qyt__zonghuo)

Fk:loadTranslationTable{
  ["qyt__luxun"] = "陆伯言",
  ["#qyt__luxun"] = "玩火的少年",
  ["designer:qyt__luxun"] = "太阳神上，冢冢的青藤",
  ["illustrator:qyt__luxun"] = "真三国无双5",
  ["cv:qyt__luxun"] = "水浒杀",

  ["qyt__lbyshenjun"] = "神君",
  [":qyt__lbyshenjun"] = "锁定技，游戏开始时，你选择自己的性别为男或女；准备阶段开始时，你须改变性别；当你受到异性角色造成的非雷电伤害时，你防止之。",
  ["qyt__shaoying"] = "烧营",
  [":qyt__shaoying"] = "当你对一名角色A造成火焰伤害后，你可选择A距离为1的一名角色B，判定，若为红色，你对B造成1点火焰伤害。", -- 郭修化
  -- "当你对一名不处于连环状态的角色A造成火焰伤害扣减体力前，你可选择A距离为1的一名角色B，此伤害结算完毕后，你进行一次判定：若结果为红色，你对B造成1点火焰伤害。",
  ["qyt__zonghuo"] = "纵火",
  [":qyt__zonghuo"] = "锁定技，当你声明使用【杀】后，若此【杀】不为火【杀】，你将此【杀】改为火【杀】。",

  ["#qyt__lbyshenjun-choose"] = "神君：选择你的性别",
  ["#qyt__lbyshenjun_log"] = "%from 性别改为 %arg",
  ["#qyt__shaoying-ask"] = "烧营：你可选择 %src 距离为1的一名角色，判定，若为红色，你对其造成1点火焰伤害",
  ["male"] = "男性",
  ["female"] = "女性",

  ["$qyt__shaoying1"] = "烈焰升腾，万物尽毁！",
  ["$qyt__shaoying2"] = "以火应敌，贼人何处逃窜？",
  ["$qyt__zonghuo"] = "（燃烧声）",
  ["~qyt__luxun"] = "玩火自焚呐……",
}

local zhongshiji = General(extension, "qyt__zhonghui", "wei", 4)
local qyt__gongmou = fk.CreateTriggerSkill{
  name = "qyt__gongmou",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#qyt__gongmou-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local mark = U.getMark(to, "@@qyt__gongmou")
    table.insertIfNeed(mark, player.id)
    room:setPlayerMark(to, "@@qyt__gongmou", mark)
  end,
}
local qyt__gongmou_delay = fk.CreateTriggerSkill{
  name = "#qyt__gongmou_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw and player:getMark("@@qyt__gongmou") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = U.getMark(player, "@@qyt__gongmou")
    room:sortPlayersByAction(mark)
    for _, id in ipairs(mark) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:doIndicate(p.id, {player.id})
        p:broadcastSkillInvoke("qyt__gongmou")
        room:notifySkillInvoked(p, "qyt__gongmou", "control")
        local n = math.min(player:getHandcardNum(), p:getHandcardNum())
        if n > 0 then
          local cards = room:askForCard(player, n, n, false, "qyt__gongmou", false, ".", "#qyt__gongmou-give::"..p.id..":"..n)
          room:moveCardTo(cards, Card.PlayerHand, p, fk.ReasonGive, "qyt__gongmou", "", false, player.id)
          if player.dead then break end
          if not p.dead then
            n = math.min(n, p:getHandcardNum())
            if n > 0 then
              cards = room:askForCard(p, n, n, false, "qyt__gongmou", false, ".", "#qyt__gongmou-give::"..player.id..":"..n)
              room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, "qyt__gongmou", "", false, p.id)
            end
          end
        end
      end
    end
    room:setPlayerMark(player, "@@qyt__gongmou", 0)
  end,
}
qyt__gongmou:addRelatedSkill(qyt__gongmou_delay)
zhongshiji:addSkill(qyt__gongmou)
Fk:loadTranslationTable{
  ["qyt__zhonghui"] = "钟士季",
  ["#qyt__zhonghui"] = "狠毒的野心家",
  ["designer:qyt__zhonghui"] = "Jr.Wakaran",
  ["illustrator:qyt__zhonghui"] = "战国无双3",
  --["cv:qyt__zhonghui"] = "",

  ["qyt__gongmou"] = "共谋",
  [":qyt__gongmou"] = "结束阶段，你可以选择一名其他角色，其下个摸牌阶段结束时，将X张手牌交给你，然后你将X张手牌交给其（X为你与其手牌数的较小值）。",
  ["#qyt__gongmou-choose"] = "共谋：选择一名角色，其下个摸牌阶段结束时，你与其交换若干张手牌",
  ["@@qyt__gongmou"] = "共谋",
  ["#qyt__gongmou-give"] = "共谋：请交给 %dest %arg张手牌",
}

local jiangboyue = General(extension, "qyt__jiangwei", "shu", 4)
local qyt__lexue = fk.CreateActiveSkill{
  name = "qyt__lexue",
  anim_type = "special",
  card_num = function(self)
    if Self:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return 0
    else
      return 1
    end
  end,
  prompt = function(self)
    if Self:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return "#qyt__lexue-active"
    else
      return "#qyt__lexue-viewas:::"..U.ConvertSuit(Self:getMark("qyt__lexue_suit-turn"), "int", "sym")..
        ":"..Fk:translate(Self:getMark("qyt__lexue_name-turn"))
    end
  end,
  can_use = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return true
    else
      if player:getMark("qyt__lexue_name-turn") ~= 0 then
        local card = Fk:cloneCard(player:getMark("qyt__lexue_name-turn"))
        return player:canUse(card) and not player:prohibitUse(card)
      end
    end
  end,
  card_filter = function(self, to_select, selected)
    if Self:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return false
    else
      return #selected == 0 and Fk:getCardById(to_select).suit == Self:getMark("qyt__lexue_suit-turn")
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if Self:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
    elseif #selected_cards == 1 then
      local card = Fk:cloneCard(Self:getMark("qyt__lexue_name-turn"))
      card.skillName = self.name
      if card.skill:getMinTargetNum() == 0 then
        return false
      else
        return card.skill:targetFilter(to_select, selected, selected_cards, card)
      end
    end
  end,
  feasible = function(self, selected, selected_cards)
    if Self:usedSkillTimes(self.name, Player.HistoryPhase) <= 0 then
      return #selected_cards == 0 and #selected == 1
    else
      local card = Fk:cloneCard(Self:getMark("qyt__lexue_name-turn"))
      card.skillName = self.name
      card:addSubcards(selected_cards)
      if Self:canUse(card) and not Self:prohibitUse(card) then
        return #selected_cards == 1 and card.skill:feasible(selected, selected_cards, Self, card)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) <= 1 then
      local target = room:getPlayerById(effect.tos[1])
      local card = room:askForCard(target, 1, 1, false, self.name, false, ".|.|.|hand", "#qyt__lexue-show:"..player.id)
      target:showCards(card)
      if player.dead then return end
      card = Fk:getCardById(card[1])
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        room:setPlayerMark(player, "@qyt__lexue-turn", Fk:translate(card:getSuitString(true)).." "..Fk:translate(card.name))
        room:setPlayerMark(player, "qyt__lexue_suit-turn", card.suit)
        room:setPlayerMark(player, "qyt__lexue_name-turn", card.name)
      end
      if room:getCardOwner(card) == target and room:getCardArea(card) == Card.PlayerHand then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
      end
    else
      local use = {
        from = player.id,
        tos = table.map(effect.tos, function (id) return {id} end),
        card = Fk:cloneCard(player:getMark("qyt__lexue_name-turn")),
      }
      use.card:addSubcards(effect.cards)
      use.card.skillName = self.name
      room:useCard(use)
    end
  end,
}
local qyt__xunzhi = fk.CreateActiveSkill{
  name = "qyt__xunzhi",
  anim_type = "special",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  prompt = "#qyt__xunzhi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:drawCards(3, self.name)
    local generals = room:findGenerals(function(g)
      return Fk.generals[g].kingdom == "shu"
    end, 999)
    local result = room:askForCustomDialog(player, self.name, "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
      generals,
      {"OK"},
      "#qyt__xunzhi-choose",
      {},
      1,
      1,
      {player.general, player.deputyGeneral},
    })
    local general = ""
    if result == "" then
      general = "jiangwei"
    else
      local reply = json.decode(result)
      if reply.choice == "OK" then
        general = reply.cards[1]
      else
        general = "jiangwei"
      end
    end
    table.removeOne(room.general_pile, general)
    local isDeputy = false
    if player.deputyGeneral ~= nil and player.deputyGeneral == "qyt__jiangwei" then
      isDeputy = true
    end
    if player:getMark(self.name) == 0 then
      room:setPlayerMark(player, "qyt__xunzhi", {isDeputy and player.deputyGeneral or player.general, isDeputy})
    end
    room:setPlayerProperty(player, isDeputy and "deputyGeneral" or "general", general)
    if not isDeputy and player.kingdom ~= "shu" then
      room:changeKingdom(player, "shu", true)
    end
    local skills = {}
    local newGeneral = Fk.generals[general] or Fk.generals["blank_shibing"]
    for _, name in ipairs(newGeneral:getSkillNameList(player.role == "lord")) do
      local s = Fk.skills[name]
      if not s.relate_to_place or (s.relate_to_place == "m" and not isDeputy) or (s.relate_to_place == "d" and isDeputy) then
        table.insertIfNeed(skills, name)
      end
    end
    for _, s in ipairs(Fk.generals[player.general].skills) do
      if #s.attachedKingdom > 0 then
        if table.contains(s.attachedKingdom, player.kingdom) then
          table.insertIfNeed(skills, s.name)
        else
          if table.contains(skills, s.name) then
            table.removeOne(skills, s.name)
          else
            table.insertIfNeed(skills, "-"..s.name)
          end
        end
      end
    end
    if player.deputyGeneral ~= "" then
      for _, s in ipairs(Fk.generals[player.deputyGeneral].skills) do
        if #s.attachedKingdom > 0 then
          if table.contains(s.attachedKingdom, player.kingdom) then
            table.insertIfNeed(skills, s.name)
          else
            if table.contains(skills, s.name) then
              table.removeOne(skills, s.name)
            else
              table.insertIfNeed(skills, "-"..s.name)
            end
          end
        end
      end
    end
    room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false)
  end,
}
local qyt__xunzhi_delay = fk.CreateTriggerSkill{
  name = "#qyt__xunzhi_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("qyt__xunzhi", Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:killPlayer{
      who = player.id,
    }
  end,

  refresh_events = {fk.BeforeGameOverJudge},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("qyt__xunzhi") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("qyt__xunzhi")
    if mark[2] then
      room:setPlayerProperty(player, "deputyGeneral", mark[1])
    else
      room:setPlayerProperty(player, "general", mark[1])
    end
  end,
}
qyt__xunzhi:addRelatedSkill(qyt__xunzhi_delay)
jiangboyue:addSkill(qyt__lexue)
jiangboyue:addSkill(qyt__xunzhi)
Fk:loadTranslationTable{
  ["qyt__jiangwei"] = "姜伯约",  --两个技能都挺重量级的
  ["#qyt__jiangwei"] = "赤胆的贤将",
  ["designer:qyt__jiangwei"] = "Jr.Wakaran，太阳神上",
  ["illustrator:qyt__jiangwei"] = "战国无双3",
  ["cv:qyt__jiangwei"] = "Jr.Wakaran",

  ["qyt__lexue"] = "乐学",
  [":qyt__lexue"] = "出牌阶段限一次，你可以令一名其他角色展示一张手牌，你获得之。若为基本牌或普通锦囊牌，本回合出牌阶段，你可以将相同花色的牌"..
  "当此牌使用。",
  ["qyt__xunzhi"] = "殉志",
  [":qyt__xunzhi"] = "限定技，出牌阶段，你可以摸三张牌，然后变身为游戏外的一名蜀势力武将（保留原有的技能），若如此做，此回合结束时你死亡。",
  ["#qyt__lexue-show"] = "乐学：请展示一张手牌，令 %src 获得",
  ["#qyt__lexue-active"] = "乐学：令一名其他角色展示一张手牌",
  ["#qyt__lexue-viewas"] = "乐学：你可以将一张%arg牌当【%arg2】使用",
  ["@qyt__lexue-turn"] = "乐学",
  ["#qyt__xunzhi"] = "殉志：摸三张牌并变身为一名蜀势力武将，本回合结束时死亡！",
  ["#qyt__xunzhi-choose"] = "殉志：选择要变身的武将",
}

local jiawenhe = General(extension, "qyt__jiaxu", "qun", 4)
local qyt__dongcha = fk.CreateActiveSkill{
  name = "qyt__dongcha",
  card_num = 999,
  target_num = 0,
  expand_pile = function()
    return U.getMark(Self, "qyt__dongcha")
  end,
  card_filter = function (self, to_select)
    return table.contains(U.getMark(Self, "qyt__dongcha"), to_select)
  end,
  can_use =function (self, player, card, extra_data)
    return #U.getMark(player, "qyt__dongcha") ~= 0
  end,
}
local qyt__dongcha_trigger = fk.CreateTriggerSkill{
  name = "#qyt__dongcha_trigger",
  mute = true,
  events = {fk.EventPhaseStart},
  main_skill = qyt__dongcha,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#qyt__dongcha-choose", self.name, true, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("qyt__dongcha")
    room:notifySkillInvoked(player, "qyt__dongcha", "control")
    local to = room:getPlayerById(self.cost_data)
    room:setPlayerMark(player, "qyt__dongcha-turn", to.id)
    player:addBuddy(to)
  end,

  refresh_events = {fk.StartPlayCard},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("qyt__dongcha-turn") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("qyt__dongcha-turn"))
    if to.dead or to:isKongcheng() then
      room:setPlayerMark(player, "qyt__dongcha", 0)
    else
      room:setPlayerMark(player, "qyt__dongcha", to:getCardIds("h"))
    end
  end,
}
local qyt__dongcha_delay = fk.CreateTriggerSkill{
  name = "#qyt__dongcha_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("qyt__dongcha-turn") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(player:getMark("qyt__dongcha-turn"))
    player:removeBuddy(to)
  end,
}
local qyt__dushi = fk.CreateTriggerSkill{
  name = "qyt__dushi",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and data.damage and data.damage.from and
      not data.damage.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.damage.from.id})
    room:handleAddLoseSkills(data.damage.from, "benghuai", nil, true, false)
  end,
}
qyt__dongcha:addRelatedSkill(qyt__dongcha_trigger)
qyt__dongcha:addRelatedSkill(qyt__dongcha_delay)
jiawenhe:addSkill(qyt__dongcha)
jiawenhe:addSkill(qyt__dushi)
Fk:loadTranslationTable{
  ["qyt__jiaxu"] = "贾文和",
  ["#qyt__jiaxu"] = "明哲保身",
  ["designer:qyt__jiaxu"] = "氢弹",
  ["illustrator:qyt__jiaxu"] = "三国豪杰传",
  --["cv:qyt__jiaxu"] = "",

  ["qyt__dongcha"] = "洞察",
  [":qyt__dongcha"] = "准备阶段，你可以秘密选择一名其他角色，其所有手牌对你可见直到回合结束。",
  ["qyt__dushi"] = "毒士",
  [":qyt__dushi"] = "锁定技，当你死亡时，杀死你的角色获得〖崩坏〗。",
  ["#qyt__dongcha-choose"] = "洞察：秘密选择一名角色，本回合其手牌对你可见",
}

local guzhielai = General(extension, "qyt__dianwei", "wei", 4)
local qyt__sizhan = fk.CreateTriggerSkill{
  name = "qyt__sizhan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.DamageInflicted then
        return true
      else
        return player.phase == Player.Finish and player:getMark("@qyt__sizhan") > 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageInflicted then
      room:addPlayerMark(player, "@qyt__sizhan", data.damage)
      return true
    else
      local n = player:getMark("@qyt__sizhan")
      room:setPlayerMark(player, "@qyt__sizhan", 0)
      room:loseHp(player, n, self.name)
    end
  end,
}
local qyt__shenli = fk.CreateTriggerSkill{
  name = "qyt__shenli",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@qyt__sizhan") > 0 and
      data.card and data.card.trueName == "slash" and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + math.min(player:getMark("@qyt__sizhan"), 3)
  end,
}
guzhielai:addSkill(qyt__sizhan)
guzhielai:addSkill(qyt__shenli)
Fk:loadTranslationTable{
  ["qyt__dianwei"] = "古之恶来",
  ["#qyt__dianwei"] = "不坠悍将",
  ["designer:qyt__dianwei"] = "Jr.Wakaran",
  ["illustrator:qyt__dianwei"] = "《火凤燎原》",
  --["cv:qyt__dianwei"] = "",

  ["qyt__sizhan"] = "死战",
  [":qyt__sizhan"] = "锁定技，当你受到伤害时，防止此伤害并获得等量的“死战”标记；结束阶段，你弃置所有的“死战”标记并失去等量的体力。 ",
  ["qyt__shenli"] = "神力",
  [":qyt__shenli"] = "锁定技，每阶段限一次，你于出牌阶段内使用【杀】造成伤害时，此伤害+X（X为当前“死战”标记数，最多为3）。",
  ["@qyt__sizhan"] = "死战",
}

local dengshizai = General(extension, "qyt__dengai", "wei", 4)
local qyt__zhenggong = fk.CreateTriggerSkill{
  name = "qyt__zhenggong",
  anim_type = "special",
  events = {fk.BeforeTurnStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and
      not target:insideExtraTurn() and player.faceup
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qyt__zhenggong-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    player:gainAnExtraTurn(true)
    player:turnOver()
  end,
}
local qyt__toudu = fk.CreateTriggerSkill{
  name = "qyt__toudu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player.faceup and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#qyt__toudu-invoke", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if player.dead then return end
    player:turnOver()
    if player.dead then return end
    U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#qyt__toudu-slash", false, true, true, true)
  end,
}
dengshizai:addSkill(qyt__zhenggong)
dengshizai:addSkill(qyt__toudu)
Fk:loadTranslationTable{
  ["qyt__dengai"] = "邓士载",
  ["#qyt__dengai"] = "破蜀首功",
  ["designer:qyt__dengai"] = "Bu懂",
  ["illustrator:qyt__dengai"] = "三国豪杰传",
  ["cv:qyt__dengai"] = "阿澈",

  ["qyt__zhenggong"] = "争功",
  [":qyt__zhenggong"] = "其他角色的额定回合开始前，若你的武将牌正面朝上，你可以获得一个额外的回合，此回合结束后，你将武将牌翻面。",
  ["qyt__toudu"] = "偷渡",
  [":qyt__toudu"] = "当你受到伤害后，若你的武将牌背面朝上，你可以弃置一张牌并翻面，然后视为使用一张无距离限制的【杀】。",
  ["#qyt__zhenggong-invoke"] = "争功：%dest 的回合即将开始，你可以发动“争功”抢先执行一个回合！",
  ["@@qyt__zhenggong"] = "争功",
  ["#qyt__toudu-invoke"] = "偷渡：你可以弃置一张牌并翻面，视为使用一张无距离限制的【杀】",
  ["#qyt__toudu-slash"] = "偷渡：视为使用一张无距离限制的【杀】",

  ["$qyt__zhenggong"] = "不肯屈人后，看某第一功！",
  ["$qyt__toudu"] = "攻其不意，掩其无备。",
  ["~qyt__dengai"] = "蹇利西南，不利东北，破蜀功高，难以北回……",
}

local zhanggongqi = General(extension, "qyt__zhanglu", "qun", 3)
local qyt__yishe = fk.CreateActiveSkill{
  name = "qyt__yishe",
  anim_type = "special",
  card_num = 1,
  target_num = 0,
  prompt = "#qyt__yishe",
  expand_pile = "zhanggongqi_rice",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand or Self:getPileNameOfId(to_select) == "zhanggongqi_rice"
  end,
  feasible = function (self, selected, selected_cards)
    local to_put = table.filter(selected_cards, function(id)
      return Fk:currentRoom():getCardArea(id) == Card.PlayerHand
    end)
    local to_get = table.filter(selected_cards, function(id)
      return Self:getPileNameOfId(id) == "zhanggongqi_rice"
    end)
    return #selected_cards > 0 and #Self:getPile("zhanggongqi_rice") - #to_get + #to_put < 6
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to_put  = table.filter(effect.cards, function(id)
      return room:getCardArea(id) == Card.PlayerHand
    end)
    local to_get = table.filter(effect.cards, function(id)
      return player:getPileNameOfId(id) == "zhanggongqi_rice"
    end)
    U.swapCardsWithPile(player, to_put, to_get, self.name, "zhanggongqi_rice", true)
  end,
}
local qyt__yishe_active = fk.CreateActiveSkill{
  name = "qyt__yishe&",
  anim_type = "special",
  card_num = 0,
  target_num = 0,
  prompt = "#qyt__yishe-active",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:hasSkill("qyt__yishe") and #p:getPile("zhanggongqi_rice") > 0
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = table.find(room:getOtherPlayers(player), function(p)
      return p:hasSkill(qyt__yishe, true) and #p:getPile("zhanggongqi_rice") > 0
    end)
    if not target then return end
    target:broadcastSkillInvoke("qyt__yishe")
    room:doIndicate(player.id, {target.id})
    local ids = target:getPile("zhanggongqi_rice")
    local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name, "#qyt__yishe-choose", {}, 1, 1)
    if room:askForSkillInvoke(target, "qyt__yishe", nil,
      "#qyt__yishe-give::"..player.id..":"..Fk:getCardById(cards[1], true):toLogString()) then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, "", true, target.id)
    end
  end,
}
local qyt__yishe_trigger = fk.CreateTriggerSkill{
  name = "#qyt__yishe_trigger",

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill("qyt__yishe", true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return target == player and data.name == "qyt__yishe" and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("qyt__yishe", true) end)
    else
      return target == player and player:hasSkill("qyt__yishe", true, true) and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("qyt__yishe", true) end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:handleAddLoseSkills(p, "qyt__yishe&", nil, false, true)
      end
    else
      for _, p in ipairs(room:getOtherPlayers(player, true, true)) do
        room:handleAddLoseSkills(p, "-qyt__yishe&", nil, false, true)
      end
    end
  end,
}
local qyt__xiliang = fk.CreateTriggerSkill{
  name = "qyt__xiliang",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id and
            player.room:getPlayerById(move.from).phase == Player.Discard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).color == Card.Red and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    if #ids > 0 then
      local choices = {"qyt__xiliang_put", "prey"}
      if #player:getPile("zhanggongqi_rice") > 4 then
        table.remove(choices, 1)
      end
      local cards, result = U.askforChooseCardsAndChoice(player, ids, choices, self.name,
        "#qyt__xiliang-choose", {}, 1, #ids)
      print(cards, result)
      if result == "qyt__xiliang_put" then
        local n = #player:getPile("zhanggongqi_rice") + #cards - 5
        if n > 0 then
          ids = {}
          for i = #cards, 6, -1 do
            table.insert(ids, cards[i])
            table.remove(cards, i)
          end
          player:addToPile("zhanggongqi_rice", cards, true, self.name, player.id)
          if not player.dead then
            ids = U.moveCardsHoldingAreaCheck(room, ids)
            if #ids > 0 then
              room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, self.name, "", true, player.id)
            end
          end
        else
          player:addToPile("zhanggongqi_rice", cards, true, self.name, player.id)
        end
      else
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, "", true, player.id)
      end
    end
  end,
}
Fk:addSkill(qyt__yishe_active)
qyt__yishe:addRelatedSkill(qyt__yishe_trigger)
zhanggongqi:addSkill(qyt__yishe)
zhanggongqi:addSkill(qyt__xiliang)
Fk:loadTranslationTable{
  ["qyt__zhanglu"] = "张公祺",
  ["#qyt__zhanglu"] = "五斗米道",
  ["designer:qyt__zhanglu"] = "背碗卤粉",
  ["illustrator:qyt__zhanglu"] = "真三国友盟",
  --["cv:qyt__zhanglu"] = "",

  ["qyt__yishe"] = "义舍",
  [":qyt__yishe"] = "出牌阶段限一次，你可以将任意张手牌与任意张“米”交换（“米”至多五张）；其他角色的出牌阶段限两次，"..
  "其可以选择一张“米”，你可以将之交给其。",
  ["qyt__xiliang"] = "惜粮",
  [":qyt__xiliang"] = "当其他角色于其弃牌阶段弃置一张红色牌后，你可以选择一项：1.将之置为“米”；2.获得之。",
  ["qyt__yishe&"] = "义舍",
  [":qyt__yishe&"] = "出牌阶段限两次，你可以选择一张“米”，张公祺可以将之交给你。",
  ["#qyt__yishe"] = "义舍：选择任意张手牌置为“米”，选择任意张“米”获得（“米”至多五张）",
  ["zhanggongqi_rice"] = "米",
  ["#qyt__yishe-active"] = "义舍：选择一张“米”，张公祺可以将之交给你",
  ["#qyt__yishe-choose"] = "义舍：选择你想获得的“米”",
  ["#qyt__yishe-give"] = "义舍：是否允许 %dest 获得%arg？",
  ["#qyt__xiliang-choose"] = "惜粮：选择将这些牌置为“米”或获得之",
  ["qyt__xiliang_put"] = "置为“米”",
}

local yitianjian = General(extension, "qyt__yitianjian", "wei", 4)
local qyt__zhengfeng = fk.CreateAttackRangeSkill{
  name = "qyt__zhengfeng",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    if from:hasSkill(self) and #from:getEquipments(Card.SubtypeWeapon) == 0 then
      return from.hp - 1
    end
    return 0
  end,
}
local qyt__zhenwei = fk.CreateTriggerSkill{
  name = "qyt__zhenwei",
  anim_type = "drawcard",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.name == "jink" and data.toCard and data.toCard.trueName == "slash" and
      data.responseToEvent.from == player.id and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qyt__zhenwei-invoke:::"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, data.card, true, fk.ReasonJustMove)
  end,
}
local qyt__yitian = fk.CreateTriggerSkill{
  name = "qyt__yitian",
  anim_type = "defensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and string.find(data.to.general, "caocao")
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qyt__yitian-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {data.to.id})
    data.damage = data.damage - 1
  end,
}
yitianjian:addSkill(qyt__zhengfeng)
yitianjian:addSkill(qyt__zhenwei)
yitianjian:addSkill(qyt__yitian)
Fk:loadTranslationTable{
  ["qyt__yitianjian"] = "倚天剑",
  ["#qyt__yitianjian"] = "跨海斩长鲸",
  ["designer:qyt__yitianjian"] = "太阳神上",
  ["illustrator:qyt__yitianjian"] = "轩辕剑",
  --["cv:qyt__yitianjian"] = "",

  ["qyt__zhengfeng"] = "争锋",
  [":qyt__zhengfeng"] = "锁定技，若你的装备区没有武器牌，你的攻击范围为X（X为你的体力值）。",
  ["qyt__zhenwei"] = "镇威",
  [":qyt__zhenwei"] = "当你使用【杀】被【闪】抵消时，你可以获得处理区里的此【闪】。",
  ["qyt__yitian"] = "倚天",
  [":qyt__yitian"] = "联动技，当你对曹操造成伤害时，你可以令该伤害-1。",
  ["#qyt__zhenwei-invoke"] = "镇威：你可以获得处理区里的此%arg",
  ["#qyt__yitian-invoke"] = "倚天：你可以令你对%dest造成的伤害-1",
}

local panglingming = General(extension, "qyt__pangde", "wei", 4)
local qyt__taichen = fk.CreateActiveSkill{
  name = "qyt__taichen",
  anim_type = "offensive",
  max_card_num = 1,
  target_num = 1,
  can_use = Util.TrueFunc,
  prompt = "#qyt__taichen",
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isAllNude() then
      if #selected_cards == 0 or Fk:currentRoom():getCardArea(selected_cards[1]) ~= Player.Equip then
        return Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
      else
        return Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select), 1 - Fk:getCardById(selected_cards[1]).attack_range)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, player, player)
    else
      room:loseHp(player, 1, self.name)
    end
    for i = 1, 2, 1 do
      if player.dead or target.dead or target:isAllNude() then return end
      local id = room:askForCardChosen(player, target, "hej", self.name)
      room:throwCard({id}, self.name, target, player)
    end
  end,
}
panglingming:addSkill(qyt__taichen)
panglingming:addSkill("mashu")
Fk:loadTranslationTable{
  ["qyt__pangde"] = "庞令明",
  ["#qyt__pangde"] = "抬榇之悟",
  ["designer:qyt__pangde"] = "太阳神上",
  ["illustrator:qyt__pangde"] = "三国志大战",
  ["cv:qyt__pangde"] = "乱天乱外",

  ["qyt__taichen"] = "抬榇",
  [":qyt__taichen"] = "出牌阶段，你可以失去1点体力或弃置一张武器牌，依次弃置你攻击范围内的一名角色区域内的两张牌。",
  ["#qyt__taichen"] = "抬榇：选择一张武器牌或直接点“确定”失去1点体力，依次弃置一名角色区域内两张牌",

  ["$qyt__taichen"] = "良将不惧死以苟免，烈士不毁节以求生！",
  ["~qyt__pangde"] = "吾宁死于刀下，岂降汝乎！",
}

return extension
