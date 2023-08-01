shopReply = function(self, msg)
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
end
