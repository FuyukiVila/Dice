require("favor_event")
require("tool")

local BotName = "春"

msg_order = {
    [BotName .. "好感度"] = "showMyFavor",
    ["与" .. BotName .. "互动"] = "interact"
}

--好感度变化
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

--查看我的好感度
function showMyFavor(msg)
    return "{self}对{nick}好感度是" .. getUserConf(msg.uid, "favor", 0)
end

--互动
function interact(msg)
    local name = getTarget(msg, "与" .. BotName .. "互动")
    local event = favorEventList[name]
    local res = ""
    if event == nil then
        return "{nick}想对{self}做什么？"
    end
    if type(event.trigger) == "table" then
        local week = tonumber(os.date("%w"))
        local day = tonumber(os.date("%d"))
        local month = tonumber(os.date("%m"))
        local hour = tonumber(os.date("%H"))
        if (event.trigger.day == nil or event.trigger.day[day]) and
            (event.trigger.month == nil or event.trigger.month[month]) and
            (event.trigger.week == nil or event.trigger.week[week]) and
            (event.trigger.hour == nil or event.trigger.hour[hour]) and
            (event.trigger.favor == nil or getUserConf(msg.uid, "favor", 0) >= event.trigger.favor) then

        else
            return event.triggerReply
        end
    elseif type(event.trigger) == "function" then
        if event:trigger(msg) == false then
            return event.triggerReply
        end
    end
    if getUserToday(msg.uid, event.id, 0) >= event.limit then
        return event.outLimitReply
    end
    setUserToday(msg.uid, event.id, getUserToday(msg.uid, event.id, 0) + 1)
    if type(event.reply) == "function" then
        res = res .. event:reply(msg) .. '\n'
    else
        res = res .. event.reply .. '\n'
    end
    res = res .. changeFavor(msg.uid, event.change)
    return res
end
