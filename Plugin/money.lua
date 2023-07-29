msg_order = {
    ["领取低保"] = "getMoney",
    ["我的资金"] = "showMoney",
    ["使用资金双倍卡"] = "useDouble",
    ["使用资金保护卡"] = "useProtect"
}

local MoneyLimit = 20 --低保领取限制
local MoneyTime = 2   --低保领取次数限制
function getMoney(msg)
    if (getUserToday(msg.uid, "getMoney", 0) >= MoneyTime) then
        return "您今天已经领取低保了×"
    end
    if (getUserConf(msg.uid, "money", 0) > MoneyLimit) then
        return "您的资金高于低保条件×"
    end
    setUserToday(msg.uid, "getMoney", getUserToday(msg.uid, "getMoney", 0) + 1)
    setUserConf(msg.uid, "money", getUserConf(msg.uid, "money", 0) + MoneyLimit)
    return "成功领取低保√，玩的愉快~"
end

function showMoney(msg)
    return "您的资金为:" .. getUserConf(msg.uid, "money", 0)
end

function changeMoney(user, change)
    local res = ""
    if (change >= 0) then
        if (getUserConf(user, "doubleMoney", 0) == 1) then
            setUserConf(user, "doubleMoney", 0)
            change = change * 2
            res = res .. "受到双倍卡的影响，本次资金增加翻倍，"
        end
        setUserConf(user, "money", getUserConf(user, "money", 0) + change)
        res = res .. "获得" .. change
    else
        if (getUserConf(user, "protectMoney", 0) == 1) then
            setUserConf(user, "protectMoney", 0)
            change = 0
            res = res .. "受到保护卡的影响，本次不扣除资金"
        end
        setUserConf(user, "money", getUserConf(user, "money", 0) + change)
        res = res .. "失去" .. -change
    end
    return res
end

function useDouble(msg)
    if (getUserConf(msg.uid, "doubleMoneyNum", 0) == 0) then
        return "您没有双倍卡"
    end
    if (getUserConf(msg.uid, "doubleMoney", 0) == 1) then
        return "您已经使用了双倍卡"
    end
    setUserConf(msg.uid, "doubleMoney", 1)
    setUserConf(msg.uid, "doubleMoneyNum", getUserConf(msg.uid, "doubleMoneyNum", 0) - 1)
    return "成功使用双倍卡，下次获得资金翻倍"
end

function useProtect(msg)
    if (getUserConf(msg.uid, "protectMoneyNum", 0) == 0) then
        return "您没有保护卡"
    end
    if (getUserConf(msg.uid, "protectMoney", 0) == 1) then
        return "您已经使用了保护卡"
    end
    setUserConf(msg.uid, "protectMoney", 1)
    setUserConf(msg.uid, "protectMoneyNum", getUserConf(msg.uid, "protectMoneyNum", 0) - 1)
    return "成功使用保护卡，下次失去的资金变为0"
end
