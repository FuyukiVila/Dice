require("tool")

FavorEvent = {
    id = "",
    change = 0,
    limit = 1,
    reply = nil,
    out_limit = "",
    __index = FavorEvent
}

function FavorEvent:new(id, change, limit, reply, out_limit)
    local obj = {}
    setmetatable(obj, self)
    obj.id = id or nil
    obj.change = change or 0
    obj.limit = limit or 1
    obj.reply = reply or nil
    obj.out_limit = out_limit
    return obj
end

favorEventList = {
    ["摸头"] = FavorEvent:new("pet", 5, 999, "呜……不要把我当小孩子看啦！(ﾉ｀⊿´)ﾉ（气哄哄地盯着）", "躲开≡┏|*´･Д･|┛"),
    ["投喂"] = FavorEvent:new("feed", 5, 999, "给我吃的吗？那我就不客气了Ψ(￣∀￣)Ψ", "已经，吃不下了……"),
    ["购物"] = FavorEvent:new("shop", nil, 999, function(self, msg)
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
    end, "买这么多东西干什么呢？好好吃饭啦……")
}
