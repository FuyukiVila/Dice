require("money")
require("tool")

local WaitTime = 30 --等待时间
local BetMoney = 10 --下注金额

msg_order = {
    ["开盘俄罗斯轮盘"] = "rouletteStart",
    ["接受挑战"] = "rouletteAccept",
    ["结束俄罗斯轮盘"] = "rouletteExit",
    ["开枪"] = "rouletteShoot"
}

function rouletteStart(msg)
    if (msg.gid == '') then
        return "私聊窗口不能玩捏×"
    end
    if getGroupConf(msg.gid, "rouletteWait", 0) == 1 then
        return "游戏已经开始，请等待游戏结束"
    elseif getUserConf(msg.uid, "money", 0) < 10 then
        return "您的资金不足"
    end
    rouletteExit(msg)
    setGroupConf(msg.gid, "rouletteWait", 1)
    rouletteAccept(msg)
    sendMsg("等待玩家接受挑战", msg.gid, msg.uid)
    for _ = 1, WaitTime, 1 do
        if getGroupConf(msg.gid, "rouletteWait", 0) == 0 then
            return ""
        end
        if #getGroupConf(msg.gid, "roulettePlayer", {}) == 2 then
            break
        end
        sleepTime(1000)
    end
    if #getGroupConf(msg.gid, "roulettePlayer", {}) < 2 then
        rouletteExit(msg)
        return "无人接受挑战，本轮游戏结束"
    end
    setGroupConf(msg.gid, "rouletteStart", 1)
    local bullet = ranint(1, 6)
    local roulettePlayer = getGroupConf(msg.gid, "roulettePlayer", {})
    local money = 10
    sendMsg("本轮的对战双方是[CQ:at,qq=" .. roulettePlayer[1] .. "] [CQ:at,qq=" .. roulettePlayer[2] .. "]",
        msg.gid, msg.uid)
    sleepTime(2000)
    for i = 6, 1, -1 do
        if getGroupConf(msg.gid, "rouletteWait", 0) == 0 then
            return ""
        end
        local index = i % 2 + 1
        sendMsg("请[CQ:at,qq=" .. roulettePlayer[index] .. "]开枪，还有" ..
            i .. "颗子弹，中奖率为" .. string.format("%.2f", 1 / i * 100) .. "%，本次奖池为" .. money,
            msg.gid, msg.uid)
        setUserConf(roulettePlayer[index], "rouletteShoot", 0)
        for _ = 1, WaitTime, 1 do
            if getUserConf(roulettePlayer[index], "rouletteShoot", 0) == 1 then
                break
            end
            sleepTime(1000)
        end
        setUserConf(roulettePlayer[index], "rouletteShoot", 1)
        if i == bullet then
            local winner = roulettePlayer[index % 2 + 1]
            local loser = roulettePlayer[index]
            changeMoney(loser, -money)
            changeMoney(winner, money)
            rouletteExit(msg)
            sendMsg("当你扣动扳机的时候，你感觉脑门一热，下一瞬间，你便倒在了血泊之中……\n第" ..
                6 - i + 1 .. "颗子弹送走了你",
                msg.gid, msg.uid)
            sleepTime(2000)
            local rouletteWin = getUserConf(winner, "rouletteWin", 0) + 1
            setUserConf(winner, "rouletteWin", rouletteWin)
            local rouletteLose = getUserConf(loser, "rouletteLose", 0) + 1
            setUserConf(loser, "rouletteLose", rouletteLose)
            res = "结算：\n    胜者：[CQ:at,qq=" .. winner .. "]\n    累计胜场：" ..
                rouletteWin .. '\n'
            res = res .. "    -------------------\n"
            res = res .. "    败者：[CQ:at,qq=" .. loser .. "]\n    累计败场：" ..
                rouletteLose
            return res
        end
        sendMsg("你扣动了扳机，只听见咔嚓一声，但并未发生什么", msg.gid, msg.uid)
        sleepTime(2000)
        money = money + 10
    end
end

function rouletteAccept(msg)
    if getGroupConf(msg.gid, "rouletteWait", 0) == 0 then
        return ""
    elseif getGroupConf(msg.gid, "rouletteStart", 0) == 1 then
        return "本局游戏已开始"
    elseif table.find(getGroupConf(msg.gid, "roulettePlayer", {}), msg.uid) ~= nil then
        return "您已在游戏当中"
    elseif #getGroupConf(msg.gid, "roulettePlayer", {}) == 2 then
        return "人数已满"
    elseif getUserConf(msg.uid, "money", 0) < 10 then
        return "资金不足"
    end
    local roulettePlayer = getGroupConf(msg.gid, "roulettePlayer", {})
    table.insert(roulettePlayer, msg.uid)
    setGroupConf(msg.gid, "roulettePlayer", roulettePlayer)
end

function rouletteExit(msg)
    setGroupConf(msg.gid, "rouletteWait", 0)
    setGroupConf(msg.gid, "rouletteStart", 0)
    setGroupConf(msg.gid, "roulettePlayer", {})
    return "俄罗斯轮盘结束"
end

function rouletteShoot(msg)
    setUserConf(msg.uid, "rouletteShoot", 1)
end
