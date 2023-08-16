FavorEvent = {
    id = "",                                                                                 --事件唯一id
    detail = "",                                                                             --事件描述
    trigger = { week = {}, day = {}, month = {}, hour = {}, favor = nil } or function() end, --事件触发条件
    triggerReply = "" or function() end,                                                     --事件未达成触发条件时的回复
    limit = 1,                                                                               --事件每日触发次数限制
    reply = "" or function() end,                                                            --事件触发的回复
    change = 0,                                                                              --好感度改变大小
    outLimitReply = "" or function() end,                                                    --超出限制回复
    __index = FavorEvent
}

---创建事件实例
---@param id string
---@param detail string
---@param limit number
---@param change number
function FavorEvent:new(id, detail, trigger, triggerReply, limit, reply, change, outLimitReply)
    local obj = {}
    setmetatable(obj, self)
    obj.id = id or nil
    obj.detail = detail or ""
    obj.trigger = trigger or nil
    obj.triggerReply = triggerReply or ""
    obj.limit = limit or 1
    obj.reply = reply or ""
    obj.change = change or 1
    obj.outLimitReply = outLimitReply or ""
    return obj
end
