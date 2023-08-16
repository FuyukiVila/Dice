require("money")
require("tool")
require("favor.favor_tool")

shopReply = function(self, msg)
    local money = getUserConf(msg.uid, "money", 0)
    local favor = getUserConf(msg.uid, "favor", 0)
    if favor >= 200 and ranint(1, 100) <= 20 then
        self.change = 30
        return "一直以来的关照辛苦了，这是我给你买的礼物哦~\n" .. changeMoney(msg.uid, 40, true)
    end
    if money < 40 then
        self.change = 1
        return "实在没钱就别逛街了，好好吃饭啦……"
    elseif money < 80 then
        self.change = 10
        changeMoney(msg.uid, -20, true)
        return "这件衣服给我买的吗……很合身，谢谢！"
    elseif money < 160 then
        self.change = 20
        changeMoney(msg.uid, -40, true)
        return "好漂亮的花，这是特地为我买的吗？"
    else
        self.change = 30
        changeMoney(msg.uid, -80, true)
        return "这么贵的宝石……我会好好珍藏的！ヾ(๑╹◡╹)ﾉ\""
    end
end

petReply = function(self, msg)
    local favor = getUserConf(msg.uid, "favor", 0)
    if favor < 50 then
        return "呜……不要把我当小孩子看啦！(ﾉ｀⊿´)ﾉ（气哄哄地盯着）"
    else
        return "手法还不赖嘛，那就给你点奖励吧~\n" .. changeMoney(msg.uid, 10, true)
    end
end

teaPartyReply = function(self, msg)
    local favor = getUserConf(msg.uid, "favor", 0)
    local res = "[CQ:image,file=favor\\tea_party.png]"
    local teaPartyTime = getUserConf(getDiceQQ(), "teaPartyTime", 0)
    local teaPartyMember = getUserToday(getDiceQQ(), "teaPartyMember", {})
    if getUserToday(getDiceQQ(), "teaParty", 0) == 0 then
        setUserToday(getDiceQQ(), "teaParty", 1)
        teaPartyTime = teaPartyTime + 1
        setUserConf(getDiceQQ(), "teaPartyTime", teaPartyTime)
    end
    if table.find(teaPartyMember, msg.uid) == nil then
        table.insert(teaPartyMember, msg.uid)
    end
    setUserToday(getDiceQQ(), "teaPartyMember", teaPartyMember)
    if favor >= 200 and ranint(1, 100) <= 50 then
        self.change = 20
        res = "来，张嘴，啊~" .. res
    else
        self.change = 10
        res = "要来杯红茶吗，还是说一块巧克力蛋糕？" .. res
    end
    res = res .. "今天来参加茶会的朋友有：\n"
    for _, member in ipairs(teaPartyMember) do
        res = res .. getUserConf(member, "nick", "") .. " "
    end
    res = res .. "\n\n已经举办了" .. teaPartyTime .. "场茶会\n"
    return res
end
