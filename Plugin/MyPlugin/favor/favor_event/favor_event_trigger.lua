require("money")
require("tool")
require("favor.favor_tool.favor_tool")

breakfastTrigger = function(self, msg)
    local hour = tonumber(os.date("%H"))
    if hour < 7 then
        self.triggerReply = "早餐时间还没到呢"
        return false
    elseif hour > 8 then
        self.triggerReply = "已经过了早餐时间了，昨晚是不是又熬夜了？"
        return false
    else
        return true
    end
end

teaPartyTrigger = function(self, msg)
    local hour = tonumber(os.date("%H"))
    if hour < 14 then
        self.triggerReply = "茶会还在准备当中，再等等吧。"
        return false
    elseif hour > 17 then
        self.triggerReply = "茶会已经结束了，记得参加明天的茶会哦~"
        return false
    else
        return true
    end
end
