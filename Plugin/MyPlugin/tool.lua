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
