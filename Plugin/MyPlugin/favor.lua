require("favor_event")
require("tool")

msg_order = {
    ["春好感度"] = "showMyFavor",
    ["与春互动"] = "interact"
}

function changeFavor(user, change)
    local res = ""
    local old_favor = getUserConf(user, "favor", 0)
    if change >= 0 then
        if getUserConf(user, "doubleFavor", 0) == 1 then
            change = change * 2
            setUserConf(user, "doubleFavor", 0)
            res = res .. "受到好感度双倍卡的效果，本次好感度提升翻倍\n"
        end
        local new_favor = old_favor + change
        res = res .. "好感度变化：" .. old_favor .. "->" .. new_favor
        setUserConf(user, "favor", new_favor)
    else
        local new_favor = old_favor + change
        res = res .. "好感度变化：" .. old_favor .. " -> " .. new_favor
        setUserConf(user, "favor", new_favor)
    end
    return res
end

function showMyFavor(msg)
    return "{self}对{nick}好感度是" .. getUserConf(msg.uid, "favor", 0)
end

function interact(msg)
    local name = getTarget(msg, "与春互动")
    local event = favorEventList[name]
    local res = ""
    if event == nil then
        return "没有这项活动×"
    end
    if getUserToday(msg.uid, event.id, 0) >= event.limit then
        return event.out_limit
    end
    setUserToday(msg.uid, event.id, getUserConf(msg.uid, event.id, 0) + 1)
    if type(event.reply) == "function" then
        res = res .. event:reply(msg) .. '\n'
    else
        res = res .. event.reply .. '\n'
    end
    res = res .. changeFavor(msg.uid, event.change)
    return res
end
