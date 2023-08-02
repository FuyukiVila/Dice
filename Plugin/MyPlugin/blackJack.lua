--[[
BlackJack插件
By Fuyuki_Vila(QQ 1642421711)
2023/6/22
]]

require("money")
require("tool")

msg_order = {
    ["21点设置"] = "gameSet",
    ["开盘21点"] = "gameStart",
    ["加入"] = "gameJoin",
    ["开始"] = "gameQuickStart",
    ["下注"] = "bet",
    ["强制结束游戏"] = "gameExit",
    ["查看明牌"] = "showCard",
    ["查看底牌"] = "showHoleCard",
    ["要牌"] = "hit",
    ["停牌"] = "stand"
}

local WaitTime = 30 --等待时间
local BetLimit = 5  --最低下注资金

local init_deck = {
    [1] = 16,
    [2] = 16,
    [3] = 16,
    [4] = 16,
    [5] = 16,
    [6] = 16,
    [7] = 16,
    [8] = 16,
    [9] = 16,
    [10] = 16,
    [11] = 16,
    [12] = 16,
    [13] = 16
}

local maxn = 0
function getMaxn(tab, index, res)
    if (index == 1) then
        maxn = 0
    end
    if (index > #tab) then
        if (res <= 21) then
            maxn = math.max(maxn, res)
        end
    else
        if (tab[index] ~= 1) then
            getMaxn(tab, index + 1, res + math.min(tab[index], 10))
        else
            getMaxn(tab, index + 1, res + 1)
            getMaxn(tab, index + 1, res + 11)
        end
    end
end

function numToCard(num)
    if (type(num) ~= "number") then
        return ''
    end
    if (num == 1) then
        return 'A'
    elseif (num == 11) then
        return 'J'
    elseif (num == 12) then
        return 'Q'
    elseif (num == 13) then
        return 'K'
    else
        return num
    end
end

function gameSet(msg)
    if (msg.gid == '') then
        return "私聊窗口不能玩捏×"
    end
    if (getUserConf(msg.fromQQ, "trust", 0) < 4 and not (getGroupConf(msg.fromGroup, "auth#" .. msg.fromQQ, 1) > 1)) then
        return "请让群管理发送该指令×"
    end
    local target = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"21点设置" + 1)
    if (target == "关闭") then
        setGroupConf(msg.gid, "gameSet", 0)
        return "游戏在本群已关闭√"
    elseif (target == "开启") then
        setGroupConf(msg.gid, "gameSet", 1)
        return "游戏在本群已开启√"
    end
end

function gameStart(msg)
    if (msg.gid == '') then
        return "私聊窗口不能玩捏×"
    end
    if (getGroupConf(msg.gid, "gameSet", 0) == 0) then
        return "本群未开启游戏，请输入《游戏设置开启》指令开启×"
    end
    if (getGroupConf(msg.gid, "gameWait", 0) == 1) then
        return "本群游戏已开始，请等待该轮游戏结束或输入《强制结束游戏》指令关闭游戏进程×"
    end
    if (getUserConf(msg.uid, "money", 0) < BetLimit * 4) then
        return "您的资金不足以开盘×"
    end
    gameExit(msg) --游戏初始化
    setGroupConf(msg.gid, "gameWait", 1)
    sendMsg("本轮游戏即将开始，请在" .. WaitTime .. "s内加入本轮游戏，输入《加入》即可，输入《开始》可直接开始游戏",
        msg.gid, 0)
    eventMsg("加入", msg.gid, msg.uid)
    for _ = 1, WaitTime, 1 do
        if (getGroupConf(msg.gid, "gameWait", 0) == 0) then
            return ""
        end
        if (getGroupConf(msg.gid, "gameStart", 0) == 1 or #getGroupConf(msg.gid, "gameHead", {}) >= 6) then
            break
        end
        sleepTime(1000)
    end
    if (#getGroupConf(msg.gid, "gameHead", {}) < 2) then
        gameExit(msg)
        return "游戏人数不足2人，本轮游戏结束×"
    end
    setGroupConf(msg.gid, "gameStart", 1)
    sendMsg("本轮游戏的庄家是[CQ:at,qq=" .. msg.uid .. "]", msg.gid, 0)
    sleepTime(2000)
    local betMaxn = getUserConf(msg.uid, "money", 0) / 2
    setGroupConf(msg.gid, "betMaxn", betMaxn)
    local gameHead = getGroupConf(msg.gid, "gameHead", {})
    for index, player in ipairs(gameHead) do
        if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
            return ""
        end
        if (index == 1) then
            local gameMoney = getGroupConf(msg.gid, "gameMoney", {})
            table.insert(gameMoney, 0)
            setGroupConf(msg.gid, "gameMoney", gameMoney)
            goto continue
        end
        setGroupConf(msg.gid, "gameTurn", index)
        sendMsg("[CQ:at,qq=" .. player .. "]请下筹码（输入《下注+数字》最少为" ..
            BetLimit .. "，最多为" .. betMaxn .. "），" ..
            WaitTime .. "s后未下注将自动下注最低筹码" .. BetLimit,
            msg.gid, 0)
        for _ = 1, WaitTime, 1 do
            if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
                return ""
            end
            if (#getGroupConf(msg.gid, "gameMoney") >= index) then
                break
            end
            sleepTime(1000)
        end
        if (#getGroupConf(msg.gid, "gameMoney") < index) then
            sendMsg("未下注，已自动为您下注" .. BetLimit, msg.gid, 0)
            local gameMoney = getGroupConf(msg.gid, "gameMoney", {})
            table.insert(gameMoney, BetLimit)
            setGroupConf(msg.gid, "gameMoney", gameMoney)
        end
        :: continue ::
    end
    for _, player in ipairs(gameHead) do
        if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
            return ""
        end
        setUserConf(player, "cards", {})
        drawCard(msg, player)
        drawCard(msg, player)
        eventMsg("查看底牌", msg.gid, player)
        sleepTime(2000)
    end
    eventMsg("查看明牌", msg.gid, msg.uid)
    sleepTime(2000)
    --闲家要牌
    for index, player in ipairs(gameHead) do
        if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
            return ""
        end
        if (index == 1) then
            goto continue
        end
        sendMsg("请闲家[CQ:at,qq=" .. player .. "]选择要牌还是停牌", msg.gid, 0)
        :: again ::
        setGroupConf(msg.gid, "gameTurn", index)
        setUserConf(player, "stand", 0)
        setUserConf(player, "hit", 0)
        if (#getUserConf(player, "cards", {}) >= 5) then
            setUserConf(player, "stand", 1)
            goto continue
        end
        sleepTime(2000)
        sendMsg("请选择《要牌》还是《停牌》，" .. WaitTime .. "s后未选择则默认停牌", msg.gid, 0)
        for _ = 1, WaitTime, 1 do
            if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
                return ""
            end
            if (getUserConf(player, "hit", 0) == 1) then
                goto again
            end
            if (getUserConf(player, "stand", 0) == 1) then
                goto continue
            end
            sleepTime(1000)
        end
        :: continue ::
    end
    --庄家要牌
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return ""
    end
    sendMsg("庄家的底牌是" .. numToCard(getUserConf(msg.uid, "cards", {})[1]), msg.gid, 0)
    sendMsg("请庄家[CQ:at,qq=" .. msg.uid .. "]选择要牌还是停牌", msg.gid, 0)
    :: again ::
    setGroupConf(msg.gid, "gameTurn", 1)
    setUserConf(msg.uid, "stand", 0)
    setUserConf(msg.uid, "hit", 0)
    if (#getUserConf(msg.uid, "cards", {}) >= 5) then
        setUserConf(msg.uid, "stand", 1)
        goto continue
    end
    sleepTime(2000)
    sendMsg("请选择《要牌》还是《停牌》，" .. WaitTime .. "s后未选择则默认停牌", msg.gid, 0)
    for _ = 1, WaitTime, 1 do
        if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
            return ""
        end
        if (getUserConf(msg.uid, "hit", 0) == 1) then
            goto again
        end
        if (getUserConf(msg.uid, "stand", 0) == 1) then
            goto continue
        end
        sleepTime(1000)
    end
    :: continue ::
    --结算
    local res = gameEnd(msg)
    return res
end

function gameQuickStart(msg)
    if (msg.fromMsg ~= "开始") then
        return ""
    end
    if (getGroupConf(msg.gid, "gameSet", 0) == 0) then
        return ""
    end
    if (getGroupConf(msg.gid, "gameStart", 0) == 1) then
        return ""
    end
    if (getGroupConf(msg.gid, "gameWait", 0) == 0) then
        return ""
    end
    setGroupConf(msg.gid, "gameStart", 1)
end

function gameJoin(msg)
    if (msg.fromMsg ~= "加入") then
        return ""
    end
    if (msg.gid == '') then
        return "私聊窗口不能玩捏×"
    end
    if (getGroupConf(msg.gid, "gameWait", 0) == 0) then
        return ""
    end
    if (getGroupConf(msg.gid, "gameStart", 0) == 1) then
        return "本群游戏已开始，请等待该轮游戏结束或输入《强制结束游戏》指令关闭游戏进程×"
    end
    local gameHead = getGroupConf(msg.gid, "gameHead", {})
    if (table.find(gameHead, msg.uid) ~= nil) then
        return "您已加入本轮游戏×"
    end
    if (#gameHead >= 6) then
        return "人数已满×"
    end
    if (getUserConf(msg.uid, "money", 0) < BetLimit) then
        return "资金不足×"
    end
    table.insert(gameHead, msg.uid)
    setGroupConf(msg.gid, "gameHead", gameHead)
    local res = ""
    for _, player in ipairs(gameHead) do
        res = res .. '[CQ:at,qq=' .. player .. '] '
    end
    return "成功加入游戏，当前玩家为：" .. res
end

function gameExit(msg)
    setGroupConf(msg.gid, "gameHead", {})
    setGroupConf(msg.gid, "gameWait", 0)
    setGroupConf(msg.gid, "gameStart", 0)
    setGroupConf(msg.gid, "deck", init_deck)
    setGroupConf(msg.gid, "gameTurn", 0)
    setGroupConf(msg.gid, "gameMoney", {})
    return "游戏已强制结束×"
end

function gameEnd(msg)
    local gameHead = getGroupConf(msg.gid, "gameHead", {})
    local gameMoney = getGroupConf(msg.gid, "gameMoney", {})
    local gameResult = {}
    local res = ""
    local finalMoney = 0
    for index, player in ipairs(gameHead) do
        local cards = getUserConf(player, "cards", {})
        res = res .. "[CQ:at,qq=" .. player .. "]的牌为："
        for i, card in ipairs(cards) do
            res = res .. numToCard(card) .. ' '
        end
        getMaxn(cards, 1, 0)
        res = res .. "最终值为" .. maxn .. ' '
        table.insert(gameResult, maxn)
        if (index ~= 1) then
            if (gameResult[1] == 21 and #getUserConf(gameHead[1], "cards", {}) == 2 and gameResult[index] == 21 and #getUserConf(player, "cards", {}) == 2) then
                res = res .. "俩家黑杰克，平局"
                --庄家黑杰克闲家黑杰克
            elseif (gameResult[1] == 21 and #getUserConf(gameHead[1], "cards", {}) == 2) then
                res = res .. "庄家黑杰克，闲家输，" .. changeMoney(player, -gameMoney[index])
                finalMoney = finalMoney + gameMoney[index]
                --庄家黑杰克
            elseif (gameResult[index] == 21 and #getUserConf(player, "cards", {}) == 2) then
                res = res .. "闲家黑杰克，" .. changeMoney(player, gameMoney[index] * 1.5)
                finalMoney = finalMoney - gameMoney[index] * 1.5
                --闲家黑杰克
            elseif (gameResult[1] > gameResult[index]) then
                res = res .. "闲家输，" .. changeMoney(player, -gameMoney[index])
                finalMoney = finalMoney + gameMoney[index]
                --闲家输
            elseif (gameResult[1] < gameResult[index]) then
                res = res .. "闲家赢，" .. changeMoney(player, gameMoney[index])
                finalMoney = finalMoney - gameMoney[index]
                --闲家赢
            elseif (gameResult[1] == gameResult[index]) then
                res = res .. "平局"
                --平局
            end
        end
        res = res .. '\n'
    end
    res = res .. "庄家" .. changeMoney(msg.uid, finalMoney)
    gameExit(msg)
    return res
end

function bet(msg)
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return "本轮游戏未开始×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) == nil) then
        return "您不是本轮游戏的玩家×"
    end
    if (#getGroupConf(msg.gid, "gameMoney", {}) == #getGroupConf(msg.gid, "gameHead", {})) then
        return "下注已结束×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) ~= getGroupConf(msg.gid, "gameTurn", 0)) then
        return "还没轮到您×"
    end
    local target = getTarget(msg, "下注")
    local gameMoney = getGroupConf(msg.gid, "gameMoney", {})
    local betMaxn = getGroupConf(msg.gid, "betMaxn", 0)
    if (tonumber(target) ~= nil) then
        if (tonumber(target) < BetLimit) then
            return "至少需要下注" .. BetLimit
        elseif (tonumber(target) > betMaxn) then
            return "下注资金不得超过" .. betMaxn
        elseif (getUserConf(msg.uid, "money", 0) < tonumber(target)) then
            return "资金不足×"
        else
            table.insert(gameMoney, tonumber(target))
            setGroupConf(msg.gid, "gameMoney", gameMoney)
            return "您已成功下注" .. target
        end
    end
end

function drawCard(msg, player)
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return "游戏未开始×"
    end
    local cards = getUserConf(player, "cards", {})
    local deck = getGroupConf(msg.gid, "deck", {})
    local sum = table.sum(deck)
    local num = ranint(1, sum)
    local res = 0
    for i, j in ipairs(deck) do
        if (j > 0) then
            res = res + j
            if (res >= num) then
                deck[i] = deck[i] - 1
                setGroupConf(msg.gid, "deck", deck)
                table.insert(cards, i)
                setUserConf(player, "cards", cards)
                return "您抽到的牌是:" .. numToCard(i)
            end
        end
    end
end

function showCard(msg)
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return "游戏未开始×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) == nil) then
        return "您不是本轮游戏的玩家×"
    end
    local gameHead = getGroupConf(msg.gid, "gameHead", {})
    local res = ""
    for _, player in ipairs(gameHead) do
        cards = "底牌 "
        for index, card in ipairs(getUserConf(player, "cards", {})) do
            if (index ~= 1) then
                cards = cards .. numToCard(card) .. " "
            end
        end
        res = res .. '[CQ:at,qq=' .. player .. ']:' .. cards .. '\n'
    end
    return res
end

function showHoleCard(msg)
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return "游戏未开始×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) == nil) then
        return "您不是本轮游戏的玩家×"
    end
    local card = getUserConf(msg.uid, "cards", {})[1]
    sendMsg("您的底牌是:" .. numToCard(card), 0, msg.uid)
end

function hit(msg)
    if (msg.fromMsg ~= "要牌") then
        return ""
    end
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return ""
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) == nil) then
        return "您不是本轮游戏的玩家×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) ~= getGroupConf(msg.gid, "gameTurn", 0)) then
        return "还没轮到您×"
    end
    setUserConf(msg.uid, "hit", 1)
    local res = drawCard(msg, msg.uid)
    return res
end

function stand(msg)
    if (msg.fromMsg ~= "停牌") then
        return ""
    end
    if (getGroupConf(msg.gid, "gameStart", 0) == 0) then
        return ""
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) == nil) then
        return "您不是本轮游戏的玩家×"
    end
    if (table.find(getGroupConf(msg.gid, "gameHead", {}), msg.uid) ~= getGroupConf(msg.gid, "gameTurn", 0)) then
        return "还没轮到您×"
    end
    setUserConf(msg.uid, "stand", 1)
    return "您已停牌"
end
