msg_order = {
    [".购买道具"] = "buyStoreGoods",
    [".查看商店"] = "showStoreGoods"
}

-- StoreGoods = {
--     __index = {
--         name = "",
--         price = 0,
--         new = function(name, price)
--             local t = {}
--             setmetatable(t, StoreGoods)
--             t.name = name
--             t.price = price
--             return t
--         end
--     }
-- }

local StoreGoodsList = {
    ["资金双倍卡"] = { id = "doubleMoneyNum", price = 30 },
    ["资金保护卡"] = { id = "protectMoneyNum", price = 30 }
}

function buyStoreGoods(msg)
    local goods = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"下注" + 1)
    if StoreGoodsList[goods] == nil then
        return "小店并未售卖该商品……"
    end
    if getUserConf(msg.uid, "money", 0) < StoreGoodsList[goods].price then
        return "您并没有足够的钱……"
    end
    setUserConf(msg.uid, "money", getUserConf(msg.uid, "money", 0) - StoreGoodsList[goods].price)
    setUserConf(msg.uid, StoreGoodsList[goods].id, getUserConf(msg.uid, StoreGoodsList[goods].id, 0) + 1)
    return "感谢购买"..goods.."，祝您生活愉快~"
end

function showStoreGoods(msg)
    local res = "小店售卖的商品有：\n"
    for name, goods in pairs(StoreGoodsList) do
        res = res .. name .. " " .. goods.price .. "$\n"
    end
    return res
end
