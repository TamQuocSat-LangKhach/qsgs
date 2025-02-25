local extension = Package:new("qyitian")
extension.extensionName = "qsgs"

Fk:loadTranslationTable{
  ["qyitian"] = "神杀-倚天",
  ["qyt"] = "倚天",
}

extension:loadSkillSkels(require("packages.qsgs.pkg.qyitian.skills"))

General:new(extension, "qyt__godcaocao", "god", 3):addSkills { "qyt__guixin", "feiying" }
Fk:loadTranslationTable{
  ["qyt__godcaocao"] = "魏武帝",
  ["#qyt__godcaocao"] = "超世之英杰",
  --["designer:qyt__godcaocao"] = "韩旭",  好像确实是韩旭
  ["illustrator:qyt__godcaocao"] = "狮子猿",
  ["~qyt__godcaocao"] = "盈缩之期，不定在天……",
}

General:new(extension, "qyt__caochong", "wei", 3):addSkills { "qyt__chengxiang", "qyt__conghui", "qyt__zaoyao" }
Fk:loadTranslationTable{
  ["qyt__caochong"] = "曹冲",
  ["#qyt__caochong"] = "早夭的神童",
  ["designer:qyt__caochong"] = "未知",
  ["illustrator:qyt__caochong"] = "未知",
}

General:new(extension, "qyt__zhanghe", "qun", 4):addSkills { "qyt__jueji" }
Fk:loadTranslationTable{
  ["qyt__zhanghe"] = "张儁乂",
  ["#qyt__zhanghe"] = "计谋巧变",
  ["designer:qyt__zhanghe"] = "孔孟老庄胡",
  ["illustrator:qyt__zhanghe"] = "《火凤燎原》",
}

local lukang = General:new(extension, "qyt__lukang", "wu", 4)
lukang:addSkills { "qyt__weiyan", "qyt__kegou" }
lukang:addRelatedSkill("lianying")
Fk:loadTranslationTable{
  ["qyt__lukang"] = "陆抗",
  ["#qyt__lukang"] = "最后的良将",
  ["designer:qyt__lukang"] = "太阳神上",
  ["illustrator:qyt__lukang"] = "火神原画",
  --["cv:qyt__lukang"] = "喵小林",
}

General:new(extension, "qyt__godsimayi", "god", 4):addSkills { "qyt__wuling" }
Fk:loadTranslationTable{
  ["qyt__godsimayi"] = "晋宣帝",
  ["#qyt__godsimayi"] = "祁山的术士",
  ["designer:qyt__godsimayi"] = "tle2009，塞克洛",
  ["illustrator:qyt__godsimayi"] = "梦三国",
  ["cv:qyt__godsimayi"] = "宇文天启",
  ["~qyt__godsimayi"] = "千年恩怨，一笔勾销，历史轮回，转身忘掉",
}

General:new(extension, "qyt__xiahoushi", "wei", 3, 3, General.Female):addSkills { "qyt__lianli", "qyt__tongxin", "qyt__liqian" }
Fk:loadTranslationTable{
  ["qyt__xiahoushi"] = "夏侯涓",
  ["#qyt__xiahoushi"] = "樵采的美人",
  ["designer:qyt__xiahoushi"] = "宇文天启，艾艾艾",
  ["illustrator:qyt__xiahoushi"] = "三国志大战",
  ["cv:qyt__xiahoushi"] = "妙妙",
}

General:new(extension, "qyt__caiwenji", "qun", 3, 3, General.Female):addSkills { "qyt__guihan", "qyt__hujia" }
Fk:loadTranslationTable{
  ["qyt__caiwenji"] = "蔡昭姬",
  ["#qyt__caiwenji"] = "乱世才女",
  ["designer:qyt__caiwenji"] = "冢冢的青藤",
  ["illustrator:qyt__caiwenji"] = "火星时代",
  ["cv:qyt__caiwenji"] = "妙妙",
  ["~qyt__caiwenji"] = "人生几何时，怀忧终年岁……",
}

General:new(extension, "qyt__luxun", "wu", 3):addSkills { "qyt__shenjun", "qyt__shaoying", "qyt__zonghuo" }
Fk:loadTranslationTable{
  ["qyt__luxun"] = "陆伯言",
  ["#qyt__luxun"] = "玩火的少年",
  ["designer:qyt__luxun"] = "太阳神上，冢冢的青藤",
  ["illustrator:qyt__luxun"] = "真三国无双5",
  ["cv:qyt__luxun"] = "水浒杀",
  ["~qyt__luxun"] = "玩火自焚呐……",
}

General:new(extension, "qyt__zhonghui", "wei", 4):addSkills { "qyt__gongmou" }
Fk:loadTranslationTable{
  ["qyt__zhonghui"] = "钟士季",
  ["#qyt__zhonghui"] = "狠毒的野心家",
  ["designer:qyt__zhonghui"] = "Jr.Wakaran",
  ["illustrator:qyt__zhonghui"] = "战国无双3",
}

General:new(extension, "qyt__jiangwei", "shu", 4):addSkills { "qyt__lexue", "qyt__xunzhi" }
Fk:loadTranslationTable{
  ["qyt__jiangwei"] = "姜伯约",
  ["#qyt__jiangwei"] = "赤胆的贤将",
  ["designer:qyt__jiangwei"] = "Jr.Wakaran，太阳神上",
  ["illustrator:qyt__jiangwei"] = "战国无双3",
  ["cv:qyt__jiangwei"] = "Jr.Wakaran",
  ["~qyt__jiangwei"] = "吾计不成，乃天命也？",
}

General:new(extension, "qyt__jiaxu", "qun", 4):addSkills { "qyt__dongcha", "qyt__dushi" }
Fk:loadTranslationTable{
  ["qyt__jiaxu"] = "贾文和",
  ["#qyt__jiaxu"] = "明哲保身",
  ["designer:qyt__jiaxu"] = "氢弹",
  ["illustrator:qyt__jiaxu"] = "三国豪杰传",
  --["cv:qyt__jiaxu"] = "",
}

General:new(extension, "qyt__dianwei", "wei", 4):addSkills { "qyt__sizhan", "qyt__shenli" }
Fk:loadTranslationTable{
  ["qyt__dianwei"] = "古之恶来",
  ["#qyt__dianwei"] = "不坠悍将",
  ["designer:qyt__dianwei"] = "Jr.Wakaran",
  ["illustrator:qyt__dianwei"] = "《火凤燎原》",
  --["cv:qyt__dianwei"] = "",
}

General:new(extension, "qyt__dengai", "wei", 4):addSkills { "qyt__zhenggong", "qyt__toudu" }
Fk:loadTranslationTable{
  ["qyt__dengai"] = "邓士载",
  ["#qyt__dengai"] = "破蜀首功",
  ["designer:qyt__dengai"] = "Bu懂",
  ["illustrator:qyt__dengai"] = "三国豪杰传",
  ["cv:qyt__dengai"] = "阿澈",
  ["~qyt__dengai"] = "蹇利西南，不利东北，破蜀功高，难以北回……",
}

General:new(extension, "qyt__zhanglu", "qun", 3):addSkills { "qyt__yishe", "qyt__xiliang" }
Fk:loadTranslationTable{
  ["qyt__zhanglu"] = "张公祺",
  ["#qyt__zhanglu"] = "五斗米道",
  ["designer:qyt__zhanglu"] = "背碗卤粉",
  ["illustrator:qyt__zhanglu"] = "真三国友盟",
}

General:new(extension, "qyt__yitianjian", "wei", 4):addSkills { "qyt__zhengfeng", "qyt__zhenwei", "qyt__yitian" }
Fk:loadTranslationTable{
  ["qyt__yitianjian"] = "倚天剑",
  ["#qyt__yitianjian"] = "跨海斩长鲸",
  ["designer:qyt__yitianjian"] = "太阳神上",
  ["illustrator:qyt__yitianjian"] = "轩辕剑",
}

General:new(extension, "qyt__pangde", "wei", 4):addSkills { "qyt__taichen" }
Fk:loadTranslationTable{
  ["qyt__pangde"] = "庞令明",
  ["#qyt__pangde"] = "抬榇之悟",
  ["designer:qyt__pangde"] = "太阳神上",
  ["illustrator:qyt__pangde"] = "三国志大战",
  ["cv:qyt__pangde"] = "乱天乱外",
  ["~qyt__pangde"] = "吾宁死于刀下，岂降汝乎！",
}

return extension
