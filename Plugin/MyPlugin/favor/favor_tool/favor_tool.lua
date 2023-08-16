BotName = "春"

--查看我的好感度
function showMyFavor(msg)
    return "{self}对{nick}好感度有" .. getUserConf(msg.uid, "favor", 0) .. '哦'
end

--好感度变化
---@param user number
---@param change number
function changeFavor(user, change)
    local res = ""
    local old_favor = getUserConf(user, "favor", 0)
    if change >= 0 then
        if getUserConf(user, "doubleFavor", 0) == 1 then
            change = change * 2
            setUserConf(user, "doubleFavor", 0)
            res = res .. "受到好感度双倍卡的效果，本次好感度提升翻倍\n"
        end
        local new_favor = math.ceil(old_favor + change)
        res = res .. "好感度变化：" .. old_favor .. " -> " .. new_favor
        setUserConf(user, "favor", new_favor)
    else
        local new_favor = math.ceil(old_favor + change)
        res = res .. "好感度变化：" .. old_favor .. " -> " .. new_favor
        setUserConf(user, "favor", new_favor)
    end
    return res
end
