function getAtQQ(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

function getTarget(msg, prefix)
    return string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #prefix + 1)
end

function table.sum(tab)
    local res = 0
    for _, card in pairs(tab) do
        if (type(card) == "number") then
            res = res + card
        end
    end
    return res
end

function table.find(tab, fv)
    for key, value in pairs(tab) do
        if (value == fv) then
            return key
        end
    end
    return nil
end

--好感度变化
function changeFavor(user, change)
    local res = ""
    local old_favor = getUserConf(user, "favor", 0)
    if change >= 0 then
        if getUserConf(user, "doubleFavor", 0) == 1 then
            change = change * 2
            setUserConf(user, "doubleFavor", 0)
            res = res .. "受到好感度双倍卡的效果，本次好感度提升翻倍\n"
        end
        local new_favor = old_favor + change
        res = res .. "好感度变化：" .. old_favor .. " -> " .. new_favor
        setUserConf(user, "favor", new_favor)
    else
        local new_favor = old_favor + change
        res = res .. "好感度变化：" .. old_favor .. " -> " .. new_favor
        setUserConf(user, "favor", new_favor)
    end
    return res
end
