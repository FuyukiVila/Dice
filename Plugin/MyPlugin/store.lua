require("tool")

msg_order = {
    [".购买道具"] = "buyStoreGoods",
    [".查看商店"] = "showStoreGoods",
    [".我的道具"] = "showMyGoods",
    [".使用道具"] = "useMyGoods"
}

-- StoreGoods = {
--     __index = {
--         id = "",
--         price = 0,
--         new = function(id, price)
--             local t = {}
--             setmetatable(t, StoreGoods)
--             t.id = id
--             t.price = price
--             return t
--         end
--     }
-- }

local StoreGoodsList = {
    ["资金双倍卡"] = { id = "doubleMoneyNum", status = "doubleMoney", price = 30, detail = "使用后下次获得的资金翻倍", limit = 1 },
    ["资金保护卡"] = { id = "protectMoneyNum", status = "protectMoney", price = 30, detail = "使用后下次失去的资金变为0", limit = 1 }
}

function buyStoreGoods(msg)
    local goods = getTarget(msg, ".购买道具")
    if StoreGoodsList[goods] == nil then
        return "小店并未售卖该商品……"
    end
    if getUserConf(msg.uid, "money", 0) < StoreGoodsList[goods].price then
        return "您并没有足够的钱……"
    end
    setUserConf(msg.uid, "money", getUserConf(msg.uid, "money", 0) - StoreGoodsList[goods].price)
    setUserConf(msg.uid, StoreGoodsList[goods].id, getUserConf(msg.uid, StoreGoodsList[goods].id, 0) + 1)
    return "感谢购买" .. goods .. "，祝您生活愉快~"
end

function showStoreGoods(msg)
    local res = "小店售卖的商品有：\n"
    for name, goods in pairs(StoreGoodsList) do
        res = res .. name .. " " .. goods.price .. "$ " .. goods.detail .. " 日使用上限为" .. goods.limit .. '\n'
    end
    return res
end

function showMyGoods(msg)
    local res = "您现在拥有的道具有：\n"
    for name, goods in pairs(StoreGoodsList) do
        if (getUserConf(msg.uid, goods.id, 0) > 1) then
            res = res .. name .. ' ×' .. getUserConf(msg.uid, goods.id, 0) .. '\n'
        end
    end
    return res
end

function useMyGoods(msg)
    local name = getTarget(msg, "使用道具")
    local goods = StoreGoodsList[name]
    if (goods == nil) then
        return "该道具不存在×"
    elseif (getUserConf(msg.uid, goods.id, 0) == 0) then
        return "您没有该道具×"
    elseif (getUserConf(msg.uid, goods.status, 0) == 1) then
        return "您已经使用过该道具了×"
    elseif (getUserToday(msg.uid, goods.status, 0) >= goods.limit) then
        return "您今天使用该道具的次数已达上限×"
    end
    setUserToday(msg.uid, goods.status, getUserToday(msg.uid, goods.status, 0) + 1)
    setUserConf(msg.uid, goods.id, getUserConf(msg.uid, goods.id, 0) - 1)
    setUserConf(msg.uid, goods.status, 1)
    return "成功使用" .. name .. "，" .. goods.detail
end
