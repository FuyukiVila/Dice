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
    for _, num in pairs(tab) do
        if (type(num) == "number") then
            res = res + num
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
