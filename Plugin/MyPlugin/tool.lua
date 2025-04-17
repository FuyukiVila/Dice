---@param str string
function getAtQQ(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

function getTarget(msg, arg)
    arg = arg or "^[%s]*(.-)[%s]*$";
    return string.match(msg.suffix, arg)
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

function isUserTrust(msg)
    if (getUserConf(msg.uid, "trust", 0) < 4 and not (getGroupConf(msg.gid, "auth#" .. msg.uid, 1) > 1)) then
        return false
    end
    return true
end

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end
