msg_order = {
    ["打工"] = "work",
    ["同意"] = "accept",
    ["拒绝"] = "refuse"
}

local workLimit = 2

local getAtQQ = function(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

function atQQ(qq)
    if (tonumber(qq) ~= nil) then
        return "[CQ:at,qq=" .. qq .. "]"
    end
    return ""
end

function work(msg)
    if (msg.gid == "") then
        return "私聊窗口不能打工捏×"
    end
    if (getUserToday(msg.uid, "work", 0) >= workLimit) then
        return "您今天不能再打工了×"
    end
    if (getUserConf(msg.uid, "work", 0) >= 20) then
        return "这么有钱还打工？"
    end
    local boss = getAtQQ(string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"打工" + 1))
    if (tonumber(boss) == nil) then
        return ""
    end
    if (getUserConf(boss, "money", 0) < 50) then
        return "老板也没钱捏×"
    end
    setUserToday(msg.uid, "work", getUserToday(msg.uid, "work", 0) + 1)
    setUserConf(boss, "request", 1)
    setUserConf(boss, "accept", 0)
    setUserConf(boss, "refuse", 0)
    sendMsg(atQQ(msg.uid) .. "向" .. atQQ(boss) .. "发起打工请求，请在30s内回复《同意》或《拒绝》，否则默认拒绝",
        msg.gid, 0)
    for i = 1, 30, 1 do
        if (getUserConf(boss, 'refuse', 0) == 1) then
            setUserConf(boss, "request", 0)
            local res
            if (ranint(1, 100) <= 5) then
                res = "老板很中意你，你变成了老板的星怒，并将一半的财产给了你"
                local money = getUserConf(boss, "money", 0)
                setUserConf(boss, "money", money / 2)
                setUserConf(msg.uid, "money", getUserConf(msg.uid, "money", 0) + money / 2)
                return res
            else
                res = drawDeck(0, msg.uid, "_work")
                local money = getUserConf(boss, "money", 0)
                local getMoney = ranint(10, math.min(100, money * 2))
                res = res .. "你为老板创造了" .. getMoney .. "的价值\n"
                local r = ranint(1, 100)
                if r <= 5 then
                    res = res .. "老板大发慈悲，把钱都给了你"
                    addMoney(msg.uid, getMoney)
                elseif r <= 20 then
                    res = res .. "老板将60%的利润给了你"
                    addMoney(msg.uid, getMoney * 0.6)
                    addMoney(boss, getMoney * 0.4)
                elseif r <= 60 then
                    res = res .. "老板将30%的利润给了你"
                    addMoney(msg.uid, getMoney * 0.3)
                    addMoney(boss, getMoney * 0.7)
                elseif r <= 95 then
                    res = res .. "你干的不错，但是老板只给了你10%的利润"
                    addMoney(msg.uid, getMoney * 0.1)
                    addMoney(boss, getMoney * 0.9)
                else
                    res = res .. "你干的不错，但是老板拖欠工资了"
                    addMoney(boss, getMoney)
                end
                return res
            end
        elseif (getUserConf(boss, 'accept', 0) == 1) then
            setUserConf(boss, "request", 0)
            return "你的简历被扔进人才市场了"
        end
        sleepTime(1000)
    end
    setUserConf(boss, "request", 0)
    return "你的简历被扔进人才市场了"
end

function accept(msg)
    if (getUserConf(msg.uid, "request", 0) == 0) then
        return ""
    end
    setUserConf(msg.uid, "accept", 1)
end

function refuse(msg)
    if (getUserConf(msg.uid, "request", 0) == 0) then
        return ""
    end
    setUserConf(msg.uid, "refuse", 1)
end

function addMoney(user, add)
    setUserConf(user, "money", getUserConf(user, "money", 0) + add)
end