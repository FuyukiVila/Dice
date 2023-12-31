msg_order = {
    ["领取低保"] = "getMoney",
    ["我的资金"] = "showMoney"
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
    changeMoney(msg.uid, MoneyLimit, true)
    return "成功领取低保√，玩的愉快~"
end

function showMoney(msg)
    return "您的资金为:" .. math.ceil(getUserConf(msg.uid, "money", 0))
end

---@param user number
---@param change number
function changeMoney(user, change, switch)
    local res = ""
    if (change >= 0) then
        if ((switch == false or switch == nil) and getUserConf(user, "doubleMoney", 0) == 1) then
            setUserConf(user, "doubleMoney", 0)
            change = change * 2
            res = res .. "受到双倍卡的影响，本次资金增加翻倍，"
        end
        setUserConf(user, "money", math.ceil(getUserConf(user, "money", 0) + change))
        res = res .. "获得" .. change .. "资金"
    else
        if ((switch == false or switch == nil) and getUserConf(user, "protectMoney", 0) == 1) then
            setUserConf(user, "protectMoney", 0)
            change = 0
            res = res .. "受到保护卡的影响，本次不扣除资金"
        end
        setUserConf(user, "money", math.ceil(getUserConf(user, "money", 0) + change))
        res = res .. "失去" .. -change .. "资金"
    end
    return res
end
