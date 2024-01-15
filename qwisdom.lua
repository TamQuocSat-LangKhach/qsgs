local extension = Package("qwisdom")
extension.extensionName = "qsgs"

Fk:loadTranslationTable{
  ["qwisdom"] = "智包",
  ["qw"] = "智",
}

Fk:loadTranslationTable{
  ["qw__xuyou"] = "许攸",
  ["qw__juao"] = "倨傲",
  [":qw__juao"] = "出牌阶段限一次，你可以将两张手牌背面向上置于一名角色武将牌上，其下个回合的准备阶段获得这些牌并跳过摸牌阶段。",
  ["qw__tanlan"] = "贪婪",
  [":qw__tanlan"] = "当你受到其他角色造成的伤害后，你可以与伤害来源拼点：若你赢，你获得双方的拼点牌。",
  ["qw__shicai"] = "恃才",
  [":qw__shicai"] = "锁定技，若你发起拼点且你拼点赢后，或其他角色向你发起拼点且拼点没赢后，你摸一张牌。",
}

Fk:loadTranslationTable{
  ["qw__jiangwei"] = "姜维",
  ["qw__yicai"] = "异才",
  [":qw__yicai"] = "当你使用一张非延时类锦囊时，你可以使用一张【杀】。",
  ["qw__beifa"] = "北伐",
  [":qw__beifa"] = "锁定技，当你失去最后的手牌时，视为你对一名其他角色使用了一张【杀】，若不能如此做，则视为你对自己使用了一张【杀】。 ",
}

Fk:loadTranslationTable{
  ["qw__jiangwan"] = "蒋琬",
  ["qw__houyuan"] = "后援",
  [":qw__houyuan"] = "出牌阶段限一次，你可以弃置两张手牌并令一名其他角色摸两张牌。",
  ["qw__chouliang"] = "筹粮",
  [":qw__chouliang"] = "结束阶段，若你手牌少于三张，你可以亮出牌堆顶4-X张牌（X为你的手牌数），你获得其中的基本牌，将其余牌置入弃牌堆。",
}

Fk:loadTranslationTable{
  ["qw__sunce"] = "孙策",
  ["qw__bawang"] = "霸王",
  [":qw__bawang"] = "当你使用【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为你对至多两名角色各使用一张不计入次数的【杀】。",
  ["qw__weidai"] = "危殆",
  [":qw__weidai"] = "主公技，当你需要使用一张【酒】时，你可以令其他吴势力角色将一张♠2~9的手牌置入弃牌堆，你将此牌当【酒】使用。",
}

Fk:loadTranslationTable{
  ["qw__zhangzhao"] = "张昭",
  ["qw__longluo"] = "笼络",
  [":qw__longluo"] = "结束阶段，你可以令一名其他角色摸你于本回合弃牌阶段弃置牌数的牌。",
  ["qw__fuzuo"] = "辅佐",
  [":qw__fuzuo"] = "当其他角色拼点时，你可以弃置一张点数小于8的手牌，令其中一名角色拼点牌的点数加上这张牌点数的一半（向下取整）。",
  ["qw__jincui"] = "尽瘁",
  [":qw__jincui"] = "当你死亡时，可选择一名角色，令该角色摸三张牌或者弃置三张牌。",
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
      room:handleAddLoseSkills(player, "qw__jiehuo", nil, true, false)
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
