require("favor_event")
require("tool")
require("favor_tool")

msg_order = {
    ["与" .. BotName .. "互动"] = "interact"
}

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
        if (event.trigger.day == nil or table.find(event.trigger.day, day)) and
            (event.trigger.month == nil or table.find(event.trigger.month, month)) and
            (event.trigger.week == nil or table.find(event.trigger.week, week)) and
            (event.trigger.hour == nil or table.find(event.trigger.hour, hour)) and
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
    elseif type(event.reply) == "string" then
        res = res .. event.reply .. '\n'
    end
    res = res .. changeFavor(msg.uid, event.change)
    return res
end
