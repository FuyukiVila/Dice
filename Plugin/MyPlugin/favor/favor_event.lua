require("tool")
require("favor_special")
require("favor_tool")
require("favor_event_trigger")
require("favor_event_reply")

msg_order = {
    ["查看日程安排"] = "showFavorEvent"
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
    obj.outLimitReply = outLimitReply or ""
    return obj
end

favorEventList = {
    ["摸头"] = FavorEvent:new("pet", "每天记得摸摸{self}哦", 5, nil, nil, 1, "呜……不要把我当小孩子看啦！(ﾉ｀⊿´)ﾉ（气哄哄地盯着）", "躲开≡┏|*´･Д･|┛"),
    ["投喂"] = FavorEvent:new("feed", "每天记得投喂{self}哦", 5, nil, nil, 1, "给我吃的吗？那我就不客气了Ψ(￣∀￣)Ψ", "已经，吃不下了……"),
    ["购物"] = FavorEvent:new("shop", "周末记得带{self}去逛逛街啦~", nil, { week = { [6] = true, [0] = true } }, "商场还没开门呢……周末再来吧", 2, shopReply, "买这么多东西干什么呢？好好吃饭啦……"),
    ["看日出"] = FavorEvent:new("sunrise", "早上5点，要一起去看日出吗？", 10, { hour = { [5] = true } }, "还没到日出的时候呢，再等等吧", 1, "春，曙为最[CQ:image,file=favor\\sunrise.png]", "日出，很漂亮呢……"),
    ["吃早餐"] = FavorEvent:new("breakfast", "早餐的黄金时间是7:00-9:00，要记得按时吃早餐哦~", 10, breakfastTrigger, nil, 1, "铛铛~新鲜出炉的面包，趁热吃吧~", "你还想吃几顿早餐？"),
    ["茶会"] = FavorEvent:new("teaParty", "每天下午14:00到17:00是茶会时间，记得来参加哦~", 10, teaPartyTrigger, nil, 1, "要来杯红茶吗，还是说一块巧克力蛋糕？[CQ:image,file=favor\\tea_party.png]", "今天的茶会，喜欢吗？"),
    ["拔呆毛"] = FavorEvent:new("daimao", "不……不许拔呆毛！", -5, { favor = 5 }, "你想做什么？(σ｀д′)σ（举枪）", 5, "咕啊！我的呆毛(ﾉД`)（已黑化）", "呆毛……呆毛被拔光了……"),
    --["过圣诞节"] = FavorEvent:new("Christmas", "要是没人陪你过圣诞节的话，就让我来陪你过吧~", 30,
    --        { month = { [12] = true }, day = { [25] = true } }, "这不是还没到圣诞节呢，还是说，你现在就想过圣诞节？",
    --        1, function(self, msg)
    --            local res = ChristmasDate(msg)
    --            self.change = res.change or 0
    --            return res.reply or ""
    --        end, "又想再来一次吗？真是的，贪心的孩子可不好呢"),
    --["过情人节"] = FavorEvent:new("Valentine", "情人节没人陪吗？那……我来陪你好了。", nil,
    --        function(self, msg)
    --            if os.date("%m.%d") ~= "2.14" then
    --                self.triggerReply = "还没到情人节呢，不要贪心哦~"
    --                return false
    --            elseif (getUserConf(msg.uid, "favor", 0) < 200) then
    --                self.triggerReply = "果然……还是算了吧……（跑开）\n" .. changeFavor(msg.uid, -20)
    --                return false
    --            end
    --            return true
    --        end, nil, 1, function(self, msg)
    --            local res = ValentineDate(msg)
    --            self.change = res.change or 0
    --            return res.reply or ""
    --        end, "美好的时光总是如此短暂，明年，我们再一起约会吧~"),
    --["过七夕节"] = FavorEvent:new("Qixi", "七夕节要陪你去约会吗~", nil,
    --        { month = { [8] = true }, day = { [22] = true } }, "还没到七夕节呢，再等等吧~", 3,
    --        function(self, msg)
    --            local res = QixiDate(msg)
    --            self.change = res.change or 0
    --            return res.reply or ""
    --        end, "七夕是一场美丽的邂逅，但是时间却是短暂的")
}

function showFavorEvent(msg)
    local res = "与春的日程安排有：\n"
    for name, event in pairs(favorEventList) do
        res = res .. "名称：" .. name .. "    描述：" .. event.detail .. '\n'
    end
    return res
end
