require("money")
require("tool")
require("favor_tool")

teaPartyOutLimitReply = function(self, msg)
    local res = "今天的茶会，喜欢吗？\n"
    local teaPartyMember = getUserToday(getDiceQQ(), "teaPartyMember", {})
    local teaPartyTime = getUserConf(getDiceQQ(), "teaPartyTime", 0)
    res = res .. "今天来参加茶会的朋友有：\n"
    for _, member in ipairs(teaPartyMember) do
        res = res .. getUserConf(member, "nick", "") .. " "
    end
    res = res .. "\n\n已经举办了" .. teaPartyTime .. "场茶会\n"
    return res
end
