json = require("json")
require("tool")

msg_order = { ["来点涩图"] = "getSeTu", ["涩图开关"] = "setSeTu" }

local url = "https://image.anosu.top/pixiv/json?keyword="

function setSeTu(msg)
    if not msg.gid or msg.gid == '' then
        return "私聊窗口不能看涩图捏×"
    end
    if not isUserTrust(msg) then
        return "请让群管理员开启此功能×"
    end
    local target = getTarget(msg)
    if target == "开启" then
        setAutoConf(msg, "setu", 1)
        return "涩图开关开启√"
    elseif target == "关闭" then
        setAutoConf(msg, "setu", 0)
        return "涩图开关关闭×"
    end
end

function getSeTu(msg)
    if getAutoConf(msg, "setu", 0) == 0 then
        return
    end
    local keyword = getTarget(msg)
    if string.find(keyword,"&") then
        return "禁止的符号&"
    end
    local err, res = http.get(url .. keyword)
    if not err then
        return "访问失败×"
    end
    local data = json.decode(res)[1]
    if data.pid == nil then
        return "没有找到涩图×"
    end
    return data.pid .. "\n[CQ:image,url=" .. data.url .. "]"
end
