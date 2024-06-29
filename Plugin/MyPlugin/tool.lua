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


-- ---@param user string
-- ---@param group string
-- ---@param command string
-- ---@param timeLimit integer
-- ---@param condition table {user = {}, group = {}}
-- ---@param args string
-- function waitCommand(user, group, command, timeLimit, condition, args)
--     if user == nil or user == "" or command == nil or command == "" then
--         error("user/command should not be empty")
--     end
--     timeLimit = timeLimit or 30
--     exec = function(msg)
--         if (msg.uid ~= user) then
--             return
--         end
--         local value = getTarget(msg, args)
--         if (value ~= nil) then
--             setUserConf(user, command, value)
--         end
--     end
--     msg_order[command] = "exec"
--     for _ in 1, timeLimit, 1 do
--         for _, con in pairs(condition.user) do
--             if ~getUserConf(user, con) then
--                 return
--             end
--         end
--         for _, con in pairs(condition.group) do
--             if ~getUserConf(group, con) then
--                 return
--             end
--         end
--         if getUserConf(user, command, nil) then
--             msg_order[command] = nil
--             return getUserConf(user, command)
--         end
--     end
--     msg_order[command] = nil
--     return nil
-- end

-- function exec() end
