require("tool")

--配置名
switch = "pet_switch"
time = "pet_time"

--常量
Max = 100.00 --最大值

--修改配置
function set_time(msg)
    local num = tonumber(getTarget(msg))
    if math.type(num) == "integer" and num > 0 then
        setAutoConf(msg, time, num)
        return "已将时间周期改为" .. num .. "s"
    end
    return "错误，需要输入正整数"
end
