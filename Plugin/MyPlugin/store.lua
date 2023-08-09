require("tool")

msg_order = {
    [".购买道具"] = "buyStoreGoods",
    [".查看商店"] = "showStoreGoods",
    [".我的道具"] = "showMyGoods",
    [".使用道具"] = "useMyGoods"
}

StoreGoods = {
    id = "",     --商品唯一数量id
    status = "", -- 商品唯一状态id
    price = 0,   --商品价格
    detail = "", -- 商品描述
    limit = 1,   --商品日使用上限
    __index = StoreGoods
}

function StoreGoods:new(id, status, price, detail, limit)
    local obj = {}
    setmetatable(obj, self)
    obj.id = id
    obj.status = status
    obj.price = price
    obj.detail = detail
    obj.limit = limit
    return obj
end

local StoreGoodsList = {
    ["资金双倍卡"] = StoreGoods:new("doubleMoneyNum", "doubleMoney", 30, "使用后下次获得的资金翻倍", 1),
    ["资金保护卡"] = StoreGoods:new("protectMoneyNum", "protectMoney", 30, "使用后下次失去的资金变为0", 1),
    -- ["好感度双倍卡"] = StoreGoods:new("doubleFavorNum", "doubleFavor", 50, "使用后下次增加的好感度翻倍", 1)
}

function buyStoreGoods(msg)
    local goods = getTarget(msg)
    if StoreGoodsList[goods] == nil then
        return "小店并未售卖该商品……"
    end
    if getUserConf(msg.uid, "money", 0) < StoreGoodsList[goods].price then
        return "您并没有足够的钱……"
    end
    changeMoney(msg.uid, -StoreGoodsList[goods].price, true)
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
    local name = getTarget(msg)
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
