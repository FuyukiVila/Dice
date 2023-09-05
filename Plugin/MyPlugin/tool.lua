---@param str string
function getAtQQ(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

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
---@param value any
function table.find(list, value)
    for k, v in pairs(list) do
        if (v == value) then
            return k
        end
    end
    return nil
end

---@param conf string
function setDiceConf(conf, value)
    value = value or 0
    setUserConf(getDiceQQ(), conf, value)
end

---@param conf string
function getDiceConf(conf, default)
    return getUserConf(getDiceQQ(), conf, default)
end

---@param conf string
function setAutoConf(msg, conf, value)
    if msg.gid and msg.gid ~= "" then
        setGroupConf(msg.gid, conf, value)
    else
        setUserConf(msg.uid, conf, value)
    end
end

---@param conf string
function getAutoConf(msg, conf, default)
    if msg.gid and msg.gid ~= "" then
        return getGroupConf(msg.gid, conf, default)
    else
        return getUserConf(msg.uid, conf, default)
    end
end
