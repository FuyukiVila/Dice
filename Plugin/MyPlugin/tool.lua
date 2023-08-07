---@param str string
function getAtQQ(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

---@param msg userdata
function getTarget(msg)
    return string.match(msg.suffix, "^[%s]*(.-)[%s]*$")
end

---@param list table
function table.sum(list)
    local res = 0
    for _, num in pairs(list) do
        if (type(num) == "number") then
            res = res + num
        end
    end
    return res
end

---@param list table
function table.find(list, value)
    for k, v in pairs(list) do
        if (v == value) then
            return k
        end
    end
    return nil
end
