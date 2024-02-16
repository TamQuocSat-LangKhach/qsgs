local extension = Package("qyitian")
extension.extensionName = "qsgs"

Fk:loadTranslationTable{
  ["qyitian"] = "倚天",
  ["qyt"] = "倚天",
}

Fk:loadTranslationTable{
  ["qyt__godcaocao"] = "魏武帝",
  ["qyt__guixin"] = "归心",
  [":qyt__guixin"] = "结束阶段开始时，你可以选择一项：1.改变一名其他角色的势力；2.获得一个未加入游戏的武将牌上的主公技。",
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
    local num = 0
    for _, id in ipairs(selected) do
      num = num + Fk:getCardById(id).number
    end
    return num + Fk:getCardById(to_select).number <= Self:getMark("qyt__chengxiang")
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
  ["qyt__weiyan"] = "围堰",
  [":qyt__weiyan"] = "你可以将摸牌阶段改为出牌阶段，将出牌阶段改为摸牌阶段。",
  ["qyt__kegou"] = "克构",
  [":qyt__kegou"] = "觉醒技，准备阶段开始时，若你是除主公外唯一的吴势力角色，你减1点体力上限，获得技能〖连营〗。",
  ["#qyt__weiyan-invoke"] = "围堰：即将执行%arg，你可以改为%arg2",
}

Fk:loadTranslationTable{
  ["qyt__godsimayi"] = "晋宣帝",
  ["qyt__wuling"] = "五灵",
  [":qyt__wuling"] = "准备阶段开始时，你可以选择一种与上回合不同的效果，对所有角色生效直到你下回合开始，你选择的五灵效果不可与上回合重复："..
  "[风]一名角色受到火属性伤害时，此伤害+1。"..
  "[雷]一名角色受到雷属性伤害时，此伤害+1。"..
  "[水]一名角色受【桃】效果影响回复的体力+1。"..
  "[火]一名角色受到的伤害均视为火焰伤害。"..
  "[土]一名角色受到的属性伤害大于1时，防止多余的伤害。",
}

Fk:loadTranslationTable{
  ["qyt__xiahoushi"] = "夏侯涓",
  ["qyt__lianli"] = "连理",
  [":qyt__lianli"] = "准备阶段开始时，你可以选择一名男性角色，你与其进入“连理”状态直到你下回合开始：其可以替你使用或打出【闪】，你可以替其使用或打出【杀】。",
  ["qyt__tongxin"] = "同心",
  [":qyt__tongxin"] = "当一名处于“连理”状态的角色受到1点伤害后，你可以令处于“连理”状态的角色各摸一张牌。",
  ["qyt__liqian"] = "离迁",
  [":qyt__liqian"] = "锁定技，若你处于连理状态，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏。",
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
    if #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip then
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

local luboyan = General(extension, "qyt__luxun", "wu", 3, 3, General.Bigender)

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

Fk:loadTranslationTable{
  ["qyt__zhonghui"] = "钟士季",
  ["qyt__gongmou"] = "共谋",
  [":qyt__gongmou"] = "结束阶段，你可以选择一名其他角色，其于其下个摸牌阶段摸牌后，将X张手牌交给你（X为你与其手牌数的较小值），然后你将X张手牌交给其。",
}

Fk:loadTranslationTable{
  ["qyt__jiangwei"] = "姜伯约",
  ["qyt__lexue"] = "乐学",
  [":qyt__lexue"] = "出牌阶段限一次，你可以令一名其他角色展示一张手牌：若为基本牌或普通锦囊牌，本回合你可以将与相同花色的牌当此牌使用或打出，"..
  "否则你获得之。",
  ["qyt__xunzhi"] = "殉志",
  [":qyt__xunzhi"] = "出牌阶段，你可以摸三张牌，然后变身为游戏外的一名蜀势力武将，若如此做，此回合结束时你死亡。",
}

Fk:loadTranslationTable{
  ["qyt__jiaxu"] = "贾文和",
  ["qyt__dongcha"] = "洞察",
  [":qyt__dongcha"] = "准备阶段，你可以秘密选择一名其他角色，其所有手牌对你可见直到回合结束。",
  ["qyt__dushi"] = "毒士",
  [":qyt__dushi"] = "锁定技，当你死亡时，杀死你的角色获得〖崩坏〗。",
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
    return target == player and player:hasSkill(self) and not player.faceup and not player:isKongcheng()
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
    player:turnOver()
    if player.dead then return end
    local success, dat = room:askForUseActiveSkill(player, "qyt__toudu_viewas", "#qyt__toudu-slash", false)
    if success then
      local card = Fk:cloneCard("slash")
      card.skillName = self.name
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
    end
  end,
}
local qyt__toudu_viewas = fk.CreateViewAsSkill{
  name = "qyt__toudu_viewas",
  card_filter = function(self, to_select, selected)
    return false
  end,
  view_as = function(self, cards)
    local card = Fk:cloneCard("slash")
    card.skillName = "qyt__toudu"
    return card
  end,
}
local qyt__toudu_targetmod = fk.CreateTargetModSkill{
  name = "#qyt__toudu_targetmod",
  distance_limit_func =  function(self, player, skill, card)
    if card and table.contains(card.skillNames, "qyt__toudu") then
      return 999
    end
  end,
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, "qyt__toudu")
  end,
}
Fk:addSkill(qyt__toudu_viewas)
qyt__toudu:addRelatedSkill(qyt__toudu_targetmod)
dengshizai:addSkill(qyt__zhenggong)
dengshizai:addSkill(qyt__toudu)
Fk:loadTranslationTable{
  ["qyt__dengai"] = "邓士载",
  ["qyt__zhenggong"] = "争功",
  [":qyt__zhenggong"] = "其他角色的额定回合开始前，若你的武将牌正面朝上，你可以获得一个额外的回合，此回合结束后，你将武将牌翻面。",
  ["qyt__toudu"] = "偷渡",
  [":qyt__toudu"] = "当你受到伤害后，若你的武将牌背面朝上，你可以弃置一张牌并翻面，然后视为使用一张无距离限制的【杀】。",
  ["#qyt__zhenggong-invoke"] = "争功：%dest 的回合即将开始，你可以发动“争功”抢先执行一个回合！",
  ["@@qyt__zhenggong"] = "争功",
  ["#qyt__toudu-invoke"] = "偷渡：你可以弃置一张牌并翻面，视为使用一张无距离限制的【杀】",
  ["qyt__toudu_viewas"] = "偷渡",
  ["#qyt__toudu-slash"] = "偷渡：视为使用一张无距离限制的【杀】",

  ["$qyt__zhenggong"] = "不肯屈人后，看某第一功！",
  ["$qyt__toudu"] = "攻其不意，掩其无备。",
  ["~qyt__dengai"] = "蹇利西南，不利东北，破蜀功高，难以北回……",
}

Fk:loadTranslationTable{
  ["qyt__zhanglu"] = "张公祺",
  ["qyt__yishe"] = "义舍",
  [":qyt__yishe"] = "出牌阶段，你可以将至少一张手牌置于你的武将牌上，称为“米”（“米”至多五张），或获得至少一张“米”；"..
  "其他角色的出牌阶段限两次，其可以选择一张“米”，你可以将之交给其。",
  ["qyt__xiliang"] = "惜粮",
  [":qyt__xiliang"] = "当其他角色于其弃牌阶段弃置一张红色牌后，你可以选择一项：1.将之置为“米”；2.获得之。",
}

local yitianjian = General(extension, "qyt__yitianjian", "wei", 4)
local qyt__zhengfeng = fk.CreateAttackRangeSkill{
  name = "qyt__zhengfeng",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    if from:hasSkill(self) and not from:getEquipment(Card.SubtypeWeapon) then
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
        return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == 1  --FIXME: some skills(eg.gongqi, meibu) add attackrange directly!
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
Fk:loadTranslationTable{
  ["qyt__pangde"] = "庞令明",
  ["qyt__taichen"] = "抬榇",
  [":qyt__taichen"] = "出牌阶段，你可以失去1点体力或弃置一张武器牌，依次弃置你攻击范围内的一名角色区域内的两张牌。",
  ["#qyt__taichen"] = "抬榇：选择一张武器牌或直接点“确定”失去1点体力，依次弃置一名角色区域内两张牌",

  ["$qyt__taichen"] = "良将不惧死以苟免，烈士不毁节以求生！",
  ["~qyt__pangde"] = "吾宁死于刀下，岂降汝乎！",
}

return extension
