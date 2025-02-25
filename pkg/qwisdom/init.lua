local extension = Package:new("qwisdom")
extension.extensionName = "qsgs"

Fk:loadTranslationTable{
  ["qwisdom"] = "神杀-智包",
  ["qw"] = "智",
}

extension:loadSkillSkels(require("packages.qsgs.pkg.qwisdom.skills"))

General:new(extension, "qw__xuyou", "wei", 3):addSkills { "qw__juao", "qw__tanlan", "qw__shicai" }
Fk:loadTranslationTable{
  ["qw__xuyou"] = "许攸",
  ["#qw__xuyou"] = "恃才傲物",
  ["designer:qw__xuyou"] = "太阳神三国杀",
  ["illustrator:qw__xuyou"] = "三国志大战",
}

General:new(extension, "qw__jiangwei", "shu", 4):addSkills { "qw__yicai", "qw__beifa" }
Fk:loadTranslationTable{
  ["qw__jiangwei"] = "姜维",
  ["#qw__jiangwei"] = "天水麒麟",
  ["designer:qw__jiangwei"] = "太阳神三国杀",
  ["illustrator:qw__jiangwei"] = "巴萨小马",
}

General:new(extension, "qw__jiangwan", "shu", 3):addSkills { "qw__houyuan", "qw__chouliang" }
Fk:loadTranslationTable{
  ["qw__jiangwan"] = "蒋琬",
  ["#qw__jiangwan"] = "武侯后继",
  ["designer:qw__jiangwan"] = "太阳神三国杀",
  ["illustrator:qw__jiangwan"] = "Zero",
}

General:new(extension, "qw__sunce", "wu", 4):addSkills { "qw__bawang", "qw__weidai" }
Fk:loadTranslationTable{
  ["qw__sunce"] = "孙策",
  ["#qw__sunce"] = "江东的小霸王",
  ["designer:qw__sunce"] = "太阳神三国杀",
  ["illustrator:qw__sunce"] = "永恒之轮",
}

General:new(extension, "qw__zhangzhao", "wu", 3):addSkills { "qw__longluo", "qw__fuzuo", "qw__jincui" }
Fk:loadTranslationTable{
  ["qw__zhangzhao"] = "张昭",
  ["#qw__zhangzhao"] = "东吴重臣",
  ["designer:qw__zhangzhao"] = "太阳神三国杀",
  ["illustrator:qw__zhangzhao"] = "三国志大战",
}

-- 原版4血
General:new(extension, "qw__huaxiong", "qun", 6):addSkills { "qw__badao", "qw__wenjiu" }
Fk:loadTranslationTable{
  ["qw__huaxiong"] = "华雄",
  ["#qw__huaxiong"] = "心高命薄",
  ["designer:qw__huaxiong"] = "太阳神三国杀",
  ["illustrator:qw__huaxiong"] = "三国志大战",
}

General:new(extension, "qw__tianfeng", "qun", 3):addSkills { "qw__shipo", "qw__gushou", "qw__yuwen" }
Fk:loadTranslationTable{
  ["qw__tianfeng"] = "田丰",
  ["#qw__tianfeng"] = "甘冒虎口",
  ["designer:qw__tianfeng"] = "太阳神三国杀",
  ["illustrator:qw__tianfeng"] = "小矮米",
}

local simahui = General:new(extension, "qw__simahui", "qun", 4)
simahui:addSkills { "qw__shouye", "qw__jiehuo" }
simahui:addRelatedSkill("qw__shien")
Fk:loadTranslationTable{
  ["qw__simahui"] = "司马徽",
  ["#qw__simahui"] = "水镜先生",
  ["designer:qw__simahui"] = "太阳神三国杀",
  ["illustrator:qw__simahui"] = "小仓",
}

return extension
