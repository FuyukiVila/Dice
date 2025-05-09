local json = require("json")

---@class GroupManager
local GroupManager = {
    host = nil,
    port = nil,
    token = nil,
}
GroupManager.__index = GroupManager

---@param host string|nil
---@param port number|nil
---@param token string|nil
---@return GroupManager
function GroupManager:new(host, port, token)
    local obj = {}
    setmetatable(obj, self)
    obj.host = host or "localhost"
    obj.port = port or 14430
    obj.token = token or ""
    return obj
end

function GroupManager:__tostring()
    return string.format("GroupManager: {host: %s, port: %d, token: %s}", self.host, self.port, self.token)
end

---@param endpoint string
---@return string
function GroupManager:_getUrl(endpoint)
    return string.format("http://%s:%d/%s", self.host, self.port, endpoint)
end

---@return table
function GroupManager:_buildHeader()
    return {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. self.token,
    }
end

---@param endpoint string
---@param payload table
---@return boolean, string
function GroupManager:_execute(endpoint, payload)
    local url = self:_getUrl(endpoint)
    local header = self:_buildHeader()
    local ok, response = http.post(url, json.encode(payload), header)
    if not ok then
        log(response)
        return false, response
    end
    local data = json.decode(response)
    if data.status ~= "ok" then
        log(data.message)
        return false, data.message
    end
    return true, response
end

---设置群备注
---@param group_id number|string
---@param remark string
---@return table|nil
function GroupManager:set_group_mark(group_id, remark)
    local path = "set_group_mark"
    local data = {
        group_id = group_id,
        remark = remark,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---群踢人
---@param group_id number|string
---@param user_id number|string
---@return table|nil
function GroupManager:set_group_kick(group_id, user_id)
    local path = "set_group_kick"
    local data = {
        group_id = group_id,
        user_id = user_id,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---群禁言
---@param group_id number|string
---@param user_id number|string
---@param duration number|nil
---@return table|nil
function GroupManager:set_group_ban(group_id, user_id, duration)
    local path = "set_group_ban"
    local data = {
        group_id = group_id,
        user_id = user_id,
        duration = duration or 60,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---全体禁言
---@param group_id number|string
---@param duration number|nil
---@return table|nil
function GroupManager:set_group_whole_ban(group_id, duration)
    local path = "set_group_whole_ban"
    local data = {
        group_id = group_id,
        duration = duration or 60,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---设置群管理
---@param group_id number|string
---@param user_id number|string
---@param enable boolean|nil
---@return table|nil
function GroupManager:set_group_admin(group_id, user_id, enable)
    local path = "set_group_admin"
    local data = {
        group_id = group_id,
        user_id = user_id,
        enable = enable or false,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---退群
---@param group_id number|string
---@param is_dismiss boolean|nil
---@return table|nil
function GroupManager:set_group_leave(group_id, is_dismiss)
    local path = "set_group_leave"
    local data = {
        group_id = group_id,
        is_dismiss = is_dismiss or true,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

---设置群公告
---@param group_id number|string
---@param content string
---@param image string|nil
---@param pinned boolean
---@return table|nil
function GroupManager:send_group_notice(group_id, content, image, pinned)
    local path = "_send_group_notice"
    local data = {
        group_id = group_id,
        content = content,
        image = image,
        pinned = pinned and 1 or 0,
    }
    local ok, response = self:_execute(path, data)
    if not ok then
        return nil
    end
    return json.decode(response)
end

return GroupManager