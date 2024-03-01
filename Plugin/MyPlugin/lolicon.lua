json = require("json")
require("tool")
url = "https://api.lolicon.app/setu/v2"

msg_order = {
    ["来点色图"] = "get_setu",
    ["来点涩图"] = "get_setu",
    ["涩图设置"] = "set_setu",
}

function get_setu(msg)
    if getAutoConf(msg, "setu_setting") == 0 then
        return
    end
    local target = getTarget(msg)
    if target == nil or target == "" then
        local err, resp = http.get(url)
        if not err then
            return "出现错误，请稍后再试"
        end
        return string.format("标题:\n作者:%s\nPID:%s\n[CQ:image,url=%s]", data.title, data.author, data.pid, data.url)
    end
end

function set_setu(msg)
    local target = getTarget(msg)
    if target == "开启" then
        setAutoConf(msg, "setu_setting", 1)
        return "已开启本群涩图"
    end
    if target == "关闭" then
        setAutoConf(msg, "setu_setting", 0)
        return "已关闭本群涩图"
    end
    -- return "参数错误：\n开启：开启本群涩图\n关闭：关闭本群涩图"
end
