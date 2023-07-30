require("tool")

msg_order = {
    ["查看事件日程"] = "showFavorEvent"
}

FavorEvent = {
    id = "",                                                                                 --事件唯一id
    detail = "",                                                                             --事件描述
    change = 0,                                                                              --好感度改变大小
    trigger = { week = {}, day = {}, month = {}, hour = {}, favor = nil } or function() end, --事件触发条件
    triggerReply = "",                                                                       --事件未达成触发条件时的回复
    limit = 1,                                                                               --事件每日触发次数限制
    reply = "" or function() end,                                                            --事件触发的回复
    outLimitReply = "",                                                                      --超出限制回复
    __index = FavorEvent
}

--创建事件实例
function FavorEvent:new(id, detail, change, trigger, triggerReply, limit, reply, outLimitReply)
    local obj = {}
    setmetatable(obj, self)
    obj.id = id or nil
    obj.detail = detail or ""
    obj.change = change or 1
    obj.trigger = trigger or nil
    obj.triggerReply = triggerReply or ""
    obj.limit = limit or 1
    obj.reply = reply or ""
    obj.outLimitReply = outLimitReply
    return obj
end

favorEventList = {
    ["摸头"] = FavorEvent:new("pet", "每天记得摸摸{self}哦", 5, nil, nil, 1, "呜……不要把我当小孩子看啦！(ﾉ｀⊿´)ﾉ（气哄哄地盯着）", "躲开≡┏|*´･Д･|┛"),
    ["投喂"] = FavorEvent:new("feed", "每天记得投喂{self}哦", 5, nil, nil, 1, "给我吃的吗？那我就不客气了Ψ(￣∀￣)Ψ", "已经，吃不下了……"),
    ["购物"] = FavorEvent:new("shop", "周末记得带{self}去逛逛街啦~", nil, { week = { [6] = true, [0] = true } }, "商场还没开门呢……周末再来吧",
        2, function(self, msg)
            local money = getUserConf(msg.uid, "money", 0)
            if money < 40 then
                self.change = 1
                return "实在没钱就别逛街了，好好吃饭啦……"
            elseif money < 80 then
                self.change = 10
                setUserConf(msg.uid, "money", money - 20)
                return "这件衣服给我买的吗……很合身，谢谢！"
            elseif money < 160 then
                self.change = 20
                setUserConf(msg.uid, "money", money - 40)
                return "好漂亮的花，这是特地为我买的吗？"
            else
                self.change = 30
                setUserConf(msg.uid, "money", money - 80)
                return "这么贵的宝石……我会好好珍藏的！ヾ(๑╹◡╹)ﾉ\""
            end
        end, "买这么多东西干什么呢？好好吃饭啦……"),
    ["吃早餐"] = FavorEvent:new("breakfast", "早餐的黄金时间是7点到8点，要记得按时吃早餐哦~", 10,
        function(self, msg)
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
        end, nil, 1, "铛铛~新鲜出炉的面包，趁热吃吧~", "你还想吃几顿早餐？"),
    ["拔呆毛"] = FavorEvent:new("daimao", "不……不许拔呆毛！", -5, { favor = 5 }, "你想做什么？(σ｀д′)σ（举枪）", 5, "咕啊！我的呆毛(ﾉД`)（已黑化）", "呆毛……呆毛被拔光了……"),
    ["过圣诞节"] = FavorEvent:new("Christmas", "要是没人陪你过圣诞节的话，就让我来陪你过吧~", 30,
        { month = { [12] = true }, day = { [25] = true } }, "这不是还没到圣诞节呢，还是说，你现在就想过圣诞节？",
        1, "圣诞快乐！新的一年我们也一起开心相处吧~", "又想再来一次吗？真是的，贪心的孩子可不好呢")
}

function showFavorEvent(msg)
    local res = "与春的日程安排有：\n"
    for name, event in pairs(favorEventList) do
        res = res .. name .. ' ' .. event.detail .. '\n'
    end
    return res
end
