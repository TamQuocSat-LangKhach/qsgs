local extension = Package("qwisdom")
extension.extensionName = "qsgs"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["qwisdom"] = "神杀-智包",
  ["qw"] = "智",
}

local xuyou = General(extension, "qw__xuyou", "wei", 3)
local qw__juao = fk.CreateActiveSkill{
  name = "qw__juao",
  anim_type = "control",
  min_card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and #cards > 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    to:addToPile("$qw__juao", effect.cards, false, self.name)
  end,
}
local qw__juao_delay = fk.CreateTriggerSkill{
  name = "#qw__juao_delay",
  mute = true,
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getPile("$qw__juao") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(player:getPile("$qw__juao"))
    room:moveCards({
      ids = cards,
      from = player.id,
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonPrey,
      skillName = "qw__juao",
    })
    data.n = data.n - #cards
  end,
}
qw__juao:addRelatedSkill(qw__juao_delay)
xuyou:addSkill(qw__juao)
local qw__tanlan = fk.CreateTriggerSkill{
  name = "qw__tanlan",
  anim_type = "control",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return data.from and data.from ~= player and not data.from.dead and player:canPindian(data.from)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qw__tanlan-invoke:"..data.from.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from
    local pindian = player:pindian({to}, self.name)
    local winner = pindian.results[to.id].winner
    if winner == player and not player.dead then
      local cards = table.filter({pindian.fromCard:getEffectiveId(), pindian.results[to.id].toCard:getEffectiveId()},
      function(id) return room:getCardArea(id) == Card.DiscardPile end)
      if #cards > 0 then
        room:delay(500)
        room:obtainCard(player, cards, true, fk.ReasonPrey)
      end
    end
  end
}
xuyou:addSkill(qw__tanlan)
local qw__shicai = fk.CreateTriggerSkill{
  name = "qw__shicai",
  events = {fk.PindianResultConfirmed},
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (data.from == player or data.to == player) and data.winner == player
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
xuyou:addSkill(qw__shicai)
Fk:loadTranslationTable{
  ["qw__xuyou"] = "许攸",
  ["#qw__xuyou"] = "恃才傲物",
  ["designer:qw__xuyou"] = "太阳神三国杀",
  ["illustrator:qw__xuyou"] = "三国志大战",

  ["qw__juao"] = "倨傲",
  [":qw__juao"] = "出牌阶段限一次，你可以将至少一张手牌扣置于一名角色的武将牌旁，其下个摸牌阶段摸牌时获得这些牌，且其本阶段的摸牌数减少等量张。",
  ["#qw__juao_delay"] = "倨傲",
  ["$qw__juao"] = "倨傲",
  ["qw__tanlan"] = "贪婪",
  [":qw__tanlan"] = "每当你受到其他角色造成的伤害后，你可以与该角色拼点：若你赢，你获得双方的拼点牌。",
  ["#qw__tanlan-invoke"] = "贪婪：你可以与 %src 拼点",
  ["qw__shicai"] = "恃才",
  [":qw__shicai"] = "锁定技，当你拼点赢时，你摸一张牌。",
}

local jiangwei = General(extension, "qw__jiangwei", "shu", 4)
local qw__yicai = fk.CreateTriggerSkill{
  name = "qw__yicai",
  events = {fk.CardUseFinished},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card:isCommonTrick()
  end,
  on_cost = function (self, event, target, player, data)
    local use = player.room:askForUseCard(player, "slash", "slash", "#qw__yicai-slash", true, {bypass_times = true})
    if use then
      use.extraUse = true
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(self.cost_data)
  end,
}
jiangwei:addSkill(qw__yicai)
local qw__beifa = fk.CreateTriggerSkill{
  name = "qw__beifa",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or not player:isKongcheng() then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not U.askForUseVirtualCard(room, player, "slash", nil, self.name, nil, true, true, true, false) then
      room:useVirtualCard("slash", nil, player, player, self.name, false)
      if not player.dead then
        local x = player.hp - player:getHandcardNum()
        if x > 0 then
          player:drawCards(x, self.name)
        end
      end
    end
  end,
}
jiangwei:addSkill(qw__beifa)
Fk:loadTranslationTable{
  ["qw__jiangwei"] = "姜维",
  ["#qw__jiangwei"] = "天水麒麟",
  ["designer:qw__jiangwei"] = "太阳神三国杀",
  ["illustrator:qw__jiangwei"] = "巴萨小马",

  ["qw__yicai"] = "异才",
  [":qw__yicai"] = "当你使用普通锦囊牌结算结束后，你可以使用一张不计入次数的【杀】。",
  ["#qw__yicai-slash"] = "异才：你可以使用一张【杀】",
  ["qw__beifa"] = "北伐",
  [":qw__beifa"] = "锁定技，当你失去手牌时，若你没有手牌，你选择一项：1.视为使用一张【杀】；2.视为对自己使用一张【杀】（无视合法性限制），然后将手牌摸至与体力值相等。",
}

local jiangwan = General(extension, "qw__jiangwan", "shu", 3)
local qw__houyuan = fk.CreateActiveSkill{
  name = "qw__houyuan",
  anim_type = "support",
  card_num = 2,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and Self.id ~= to_select
  end,
  can_use = function(self, player)
    return #player:getCardIds("he") > 1 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    local to = room:getPlayerById(effect.tos[1])
    if to.dead then return end
    to:drawCards(2, self.name)
  end,
}
jiangwan:addSkill(qw__houyuan)
local qw__chouliang = fk.CreateTriggerSkill{
  name = "qw__chouliang",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and player:getHandcardNum() < 4
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = 4 - player:getHandcardNum()
    local cards = room:getNCards(x)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
    })
    local basic, nonbasic = {},{}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).type == Card.TypeBasic then
        table.insert(basic, id)
      else
        table.insert(nonbasic, id)
      end
    end
    local choices = {}
    if #basic > 0 then table.insert(choices, "basic") end
    if #nonbasic > 0 then table.insert(choices, "non_basic") end
    local _, choice = U.askforChooseCardsAndChoice(player, cards, choices, self.name, "#qw__chouliang-get", nil, 0, 0)
    local get = (choice == "basic") and basic or nonbasic
    room:moveCards({
      ids = get,
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonPrey,
    })
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
}
jiangwan:addSkill(qw__chouliang)
Fk:loadTranslationTable{
  ["qw__jiangwan"] = "蒋琬",
  ["#qw__jiangwan"] = "武侯后继",
  ["designer:qw__jiangwan"] = "太阳神三国杀",
  ["illustrator:qw__jiangwan"] = "Zero",

  ["qw__houyuan"] = "后援",
  [":qw__houyuan"] = "出牌阶段限一次，你可以弃置两张牌并令一名其他角色摸两张牌。",
  ["qw__chouliang"] = "筹粮",
  [":qw__chouliang"] = "结束阶段，你可以亮出牌堆顶X张牌（X为4-你的手牌数），你获得其中的基本牌或非基本牌，将其余牌置入弃牌堆。",
  ["#qw__chouliang-get"] = "筹粮：选择获得其中的基本牌或非基本牌",
}

local sunce = General(extension, "qw__sunce", "wu", 4)
local qw__bawang = fk.CreateTriggerSkill{
  name = "qw__bawang",
  anim_type = "offensive",
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" then
      local to = player.room:getPlayerById(data.to)
      return player:canPindian(to)
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qw__bawang-invoke:"..data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:getPlayerById(data.to)
    local pindian = player:pindian({to}, self.name)
    local winner = pindian.results[to.id].winner
    if winner and winner == player and not player.dead and not player:prohibitUse(Fk:cloneCard("slash")) then
      local targets = table.filter(room:getOtherPlayers(player), function (p) return not player:isProhibited(p, Fk:cloneCard("slash"))  end)
      if #targets == 0 then return false end
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2, "#qw__bawang-slash", self.name, true)
      if #tos > 0 then
        room:useVirtualCard("slash", nil, player, table.map(tos, Util.Id2PlayerMapper), self.name, true)
      end
    end
  end,
}
sunce:addSkill(qw__bawang)
local qw__weidai = fk.CreateViewAsSkill{
  name = "qw__weidai$",
  anim_type = "offensive",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if #cards ~= 0 then return nil end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "wu" then
        local cards = room:askForCard(p, 1, 1, false, self.name, true, ".|2~9|spade", "#qw__weidai-ask:"..player.id)
        if #cards > 0 then
          room:moveCards({
            from = p.id,
            ids = cards,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
          })
          room:doIndicate(p.id, {player.id})
          local to_use = Fk:cloneCard("analeptic")
          to_use:addSubcards(cards)
          to_use.skillName = self.name
          use.card = to_use
          return
        end
      end
    end
    room:setPlayerMark(player, "qw__weidai-failed-phase", 1)
    return self.name
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qw__weidai-failed-phase") == 0 and player:canUse(Fk:cloneCard("analeptic"))
    and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p.kingdom == "wu"
    end)
  end,
  enabled_at_response = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p.kingdom == "wu"
    end)
  end,
}
sunce:addSkill(qw__weidai)
Fk:loadTranslationTable{
  ["qw__sunce"] = "孙策",
  ["#qw__sunce"] = "江东的小霸王",
  ["designer:qw__sunce"] = "太阳神三国杀",
  ["illustrator:qw__sunce"] = "永恒之轮",

  ["qw__bawang"] = "霸王",
  [":qw__bawang"] = "当你使用【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为对至多两名角色使用一张不计入次数的【杀】。",
  ["#qw__bawang-invoke"] = "霸王：你可以与 %src 拼点，若你赢，你可视为你对至多两名角色使用【杀】",
  ["#qw__bawang-slash"] = "霸王：可以视为对至多两名角色使用【杀】",
  ["qw__weidai"] = "危殆",
  [":qw__weidai"] = "主公技，当你需要使用一张【酒】时，你可以令其他吴势力角色选择是否将一张♠2~9的手牌置入弃牌堆，若其如此做，你将此牌当【酒】使用。",
  ["#qw__weidai-ask"] = "危殆：你可以展示一张♠2~9的手牌，令 %src 将之当【酒】使用",
}

local zhangzhao = General(extension, "qw__zhangzhao", "wu", 3)
local qw__longluo = fk.CreateTriggerSkill{
  name = "qw__longluo",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish and #player.room.alive_players > 1 then
      local room = player.room
      local n = 0
      local phase_ids = {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
        if e.data[2] == Player.Discard then
          table.insert(phase_ids, {e.id, e.end_id})
        end
        return false
      end, Player.HistoryTurn)
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        local in_discard = false
        for _, ids in ipairs(phase_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_discard = true
            break
          end
        end
        if in_discard then
          for _, move in ipairs(e.data) do
            if move.from == player.id and move.moveReason == fk.ReasonDiscard then
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
        self.cost_data = n
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local n = self.cost_data
    local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1, "#qw__longluo-choose:::"..n, self.name, true)
    if #tos > 0 then
      self.cost_data = {tos[1], n}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    to:drawCards(self.cost_data[2], self.name)
  end,
}
zhangzhao:addSkill(qw__longluo)
local qw__fuzuo = fk.CreateTriggerSkill{
  name = "qw__fuzuo",
  anim_type = "control",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player:isKongcheng() and data.from ~= player
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(data.tos)
    table.insert(targets, data.from)
    local ids = table.filter(player:getCardIds("h"), function(id)
      local c = Fk:getCardById(id)
      return not player:prohibitDiscard(c) and c.number < 8
    end)
    local tos, cards = room:askForChooseCardsAndPlayers(player, 1, 1, table.map(targets, Util.IdMapper), 1, 1, tostring(Exppattern{ id = ids }), "#qw__fuzuo-card", self.name, true, true)
    if #tos == 1 and #cards == 1 then
      self.cost_data = {tos = tos, cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toId = self.cost_data.tos[1]
    local number = Fk:getCardById(self.cost_data.cards[1]).number
    room:throwCard(self.cost_data.cards, self.name, player, player)
    if toId == data.from.id then
      data.fromCard.number = math.min(13, data.fromCard.number + number)
    else
      data.results[toId].toCard.number = math.min(13, data.results[toId].toCard.number + number)
    end
  end,
}
zhangzhao:addSkill(qw__fuzuo)
local qw__jincui = fk.CreateTriggerSkill{
  name = "qw__jincui",
  anim_type = "support",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local p = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#qw__jincui-choose", self.name, true)
    if #p > 0 then
      self.cost_data = {tos = p}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local choices = {"draw3"}
    if not to:isNude() then table.insert(choices, "discard3") end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw3" then
      to:drawCards(3, self.name)
    else
      room:askForDiscard(to, 3, 3, true, self.name, false)
    end
  end,
}
zhangzhao:addSkill(qw__jincui)
Fk:loadTranslationTable{
  ["qw__zhangzhao"] = "张昭",
  ["#qw__zhangzhao"] = "东吴重臣",
  ["designer:qw__zhangzhao"] = "太阳神三国杀",
  ["illustrator:qw__zhangzhao"] = "三国志大战",

  ["qw__longluo"] = "笼络",
  [":qw__longluo"] = "结束阶段，你可以令一名其他角色摸数量等于你于本回合弃牌阶段弃置牌数的牌。",
  ["#qw__longluo-choose"] = "笼络：你可以令一名其他角色摸 %arg 张牌",
  ["qw__fuzuo"] = "辅佐",
  [":qw__fuzuo"] = "当其他角色发起的拼点亮出拼点牌时，你可以弃置一张点数小于8的手牌，令其中一名角色的拼点牌点数加上你弃置的牌的点数（至多加到13）。",
  ["#qw__fuzuo-card"] = "辅佐：可以弃置一张点数小于8的手牌，令一名参与拼点角色的点数增加",
  ["qw__jincui"] = "尽瘁",
  [":qw__jincui"] = "当你死亡时，可选择一名其他角色，令该角色摸三张牌或者弃置三张牌。",
  ["#qw__jincui-choose"] = "尽瘁：可以令一名其他角色摸三张牌或者弃置三张牌",
  ["discard3"] = "弃置三张牌",
}

local huaxiong = General(extension, "qw__huaxiong", "qun", 4)
local qw__badao = fk.CreateTriggerSkill{
  name = "qw__badao",
  anim_type = "offensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and data.card.color == Card.Black
  end,
  on_cost = function (self, event, target, player, data)
    local use = player.room:askForUseCard(player, "slash", "slash", "#qw__badao-use", true)
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(self.cost_data)
  end,
}
huaxiong:addSkill(qw__badao)
local qw__wenjiu = fk.CreateTriggerSkill{
  name = "qw__wenjiu",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.TargetConfirmed, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" then
      return data.card.color == (event == fk.TargetConfirmed and Card.Red or Card.Black)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.TargetConfirmed then
      data.disresponsive = true
      room:notifySkillInvoked(player, self.name, "negative")
    else
      data.additionalDamage = (data.additionalDamage or 0) + 1
      room:notifySkillInvoked(player, self.name, "offensive")
    end
  end,
}
huaxiong:addSkill(qw__wenjiu)
Fk:loadTranslationTable{
  ["qw__huaxiong"] = "华雄",
  ["#qw__huaxiong"] = "心高命薄",
  ["designer:qw__huaxiong"] = "太阳神三国杀",
  ["illustrator:qw__huaxiong"] = "三国志大战",

  ["qw__badao"] = "霸刀",
  [":qw__badao"] = "当你成为黑色的【杀】的目标后，你可以使用一张【杀】。",
  ["#qw__badao-use"] = "霸刀：你可以使用一张【杀】",
  ["qw__wenjiu"] = "温酒",
  [":qw__wenjiu"] = "锁定技，你使用黑色【杀】造成伤害+1，你不能响应红色【杀】。",
}

local tianfeng = General(extension, "qw__tianfeng", "qun", 3)
local qw__shipo = fk.CreateTriggerSkill{
  name = "qw__shipo",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and #target:getCardIds("j") > 0 and target.phase == Player.Judge and #player:getCardIds("he") > 1
  end,
  on_cost = function (self, event, target, player, data)
    local card = player.room:askForDiscard(player, 2, 2, true, self.name, true, ".", "#qw__shipo-card::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    local cards = target:getCardIds("j")
    if #cards > 0 and not player.dead then
      room:moveCards{
        from = target.id,
        ids = cards,
        to = player.id,
        toArea = Card.PlayerHand,
        proposer = player.id,
        moveReason = fk.ReasonPrey,
      }
    end
  end,
}
tianfeng:addSkill(qw__shipo)
local qw__gushou = fk.CreateTriggerSkill{
  name = "qw__gushou",
  anim_type = "drawcard",
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.NotActive and data.card.type == Card.TypeBasic
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
tianfeng:addSkill(qw__gushou)
local qw__yuwen = fk.CreateTriggerSkill{
  name = "qw__yuwen",
  frequency = Skill.Compulsory,
  events = {fk.BeforeGameOverJudge},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self,false,true) and target == player and data.damage
  end,
  on_use = function(self, event, target, player, data)
    data.damage.from = player
  end,
}
tianfeng:addSkill(qw__yuwen)
Fk:loadTranslationTable{
  ["qw__tianfeng"] = "田丰",
  ["#qw__tianfeng"] = "甘冒虎口",
  ["designer:qw__tianfeng"] = "太阳神三国杀",
  ["illustrator:qw__tianfeng"] = "小矮米",

  ["qw__shipo"] = "识破",
  [":qw__shipo"] = "一名角色判定阶段开始时，你可以弃置两张牌，获得其判定区内的所有牌。",
  ["#qw__shipo-card"] = "识破：你可以弃置两张牌，获得 %dest 判定区内的所有牌",
  ["qw__gushou"] = "固守",
  [":qw__gushou"] = "当你于回合外使用或打出一张基本牌时，你可以摸一张牌。",
  ["qw__yuwen"] = "狱刎",
  [":qw__yuwen"] = "锁定技，当你死亡时，伤害来源改为自己。",
}

local simahui = General(extension, "qw__simahui", "qun", 4)
local qw__shouye = fk.CreateActiveSkill{
  name = "qw__shouye",
  anim_type = "support",
  card_num = 1,
  min_target_num = 1,
  max_target_num = 2,
  prompt= "#qw__shouye",
  can_use = function(self, player)
    if not player:isKongcheng() then
      if player:usedSkillTimes("qw__jiehuo", Player.HistoryPhase) > 0 then
        return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
      else
        return true
      end
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and
      Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    return #selected < 2 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:sortPlayersByAction(effect.tos)
    for _, id in ipairs(effect.tos) do
      local target = room:getPlayerById(id)
      if not target.dead then
        target:drawCards(1, self.name)
        room:addPlayerMark(player, self.name, 1)
      end
    end
  end,
}
local qw__jiehuo = fk.CreateTriggerSkill{
  name = "qw__jiehuo",
  frequency = Skill.Wake,
  events = {fk.AfterSkillEffect},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.name == "qw__shouye"
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("qw__shouye") > 6
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:handleAddLoseSkills(player, "qw__shien", nil, true, false)
    end
  end,
}
local qw__shien = fk.CreateTriggerSkill{
  name = "qw__shien",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and data.card:isCommonTrick()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name, nil, "#qw__shien-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(target.id, {player.id})
    player:drawCards(1, self.name)
  end,
}
simahui:addSkill(qw__shouye)
simahui:addSkill(qw__jiehuo)
simahui:addRelatedSkill(qw__shien)
Fk:loadTranslationTable{
  ["qw__simahui"] = "司马徽",
  ["#qw__simahui"] = "水镜先生",
  ["designer:qw__simahui"] = "太阳神三国杀",
  ["illustrator:qw__simahui"] = "小仓",

  ["qw__shouye"] = "授业",
  [":qw__shouye"] = "出牌阶段，你可以弃置一张红色手牌，令至多两名其他角色各摸一张牌。若你发动过〖解惑〗，此技能每阶段限一次。",
  ["qw__jiehuo"] = "解惑",
  [":qw__jiehuo"] = "觉醒技，当你发动〖授业〗令其他角色摸牌不少于7张后，你减1点体力上限，获得技能〖师恩〗。",
  ["qw__shien"] = "师恩",
  [":qw__shien"] = "其他角色使用非延时锦囊时，可以令你摸一张牌。",
  ["#qw__shouye"] = "授业：你可以弃置一张红色手牌，令至多两名其他角色各摸一张牌",
  ["#qw__shien-invoke"] = "师恩：是否令 %src 摸一张牌？",
}

return extension
