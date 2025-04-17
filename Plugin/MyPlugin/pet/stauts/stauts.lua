stauts = {
    name = "",
    change = 0.0,
    unlimited = nil
}

---@param name string
function stauts:new(name, change, unlimited)
    local obj = {}
    setmetatable(obj, self)
    obj.name = name
    obj.change = change
    return obj
end