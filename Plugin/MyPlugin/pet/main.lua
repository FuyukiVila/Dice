require("pet.setting")
require("pet.stauts.stauts_list")

---开启数值计算后，状态随时间下降
function calculate_start(msg)
    setAutoConf(msg, switch, 1)
    local last_time = os.time()
    sendMsg("已开启数值计算，当前时间周期为" .. getAutoConf(msg, time, 15), msg.gid, msg.uid)
    while getAutoConf(msg, switch, 0) == 1 do
        local now_time = os.time()
        if now_time - last_time >= getAutoConf(msg, time, 15) then
            for _, stauts in ipairs(stauts_list) do
                if type(stauts.change) == "number" then
                    local res = getAutoConf(msg, stauts.name, Max) + stauts.change
                    if not stauts.unlimited then
                        res = math.min(res, Max)
                    end
                    res = math.max(res, 0)
                    res = tonumber(string.format("%.2f", res))
                    setAutoConf(msg, stauts.name, res)
                elseif type(stauts.change) == "function" then
                    local res = getAutoConf(msg, stauts.name, Max) + stauts:change(msg)
                    if not stauts.unlimited then
                        res = math.min(res, Max)
                    end
                    res = math.max(res, 0)
                    res = tonumber(string.format("%.2f", res))
                    setAutoConf(msg, stauts.name, res)
                end
            end
            last_time = now_time
        end
        sleepTime(1000)
    end
end

--关闭数值计算
function calculate_stop(msg)
    setAutoConf(msg, switch, 0)
    return "已关闭数值计算"
end

function show_stauts(msg)
    local reply = "数值计算：" .. getAutoConf(msg, switch, 0) == 0 and "未开启" or "开启"
        .. "，时间周期：" .. getAutoConf(msg, time, 15) .. "s\n"
    for _, stauts in ipairs(stauts_list) do
        reply = reply .. stauts.name .. string.format("：%.2f", getAutoConf(msg, stauts.name, Max))
        if not stauts.unlimited then
            reply = reply .. string.format("/%.2f", Max)
        end
        reply = reply .. '\n'
    end
    return reply
end
