require("pet.setting")

--自定义函数
health_change = function(self, msg)
    local res = 0.50
    if getAutoConf(msg, "饱食度", Max) <= 0.00 then
        res = res - 2.00
    end
    if getAutoConf(msg, "口渴度", Max) <= 0.00 then
        res = res - 2.00
    end
    if getAutoConf(msg, "心情", Max) <= 0.00 then
        res = res - 1.00
    end
    return res
end

exp_change = function(self, msg)
    if getAutoConf(msg, "健康度", Max) <= 0.00 then
        return -1.00
    end
    if getAutoConf(msg, "饱食度", Max) <= 0.00 or getAutoConf(msg, "口渴度", Max) <= 0.00 or getAutoConf(msg, "心情", Max) <= 0.00 then
        return 0.00
    end
    return 1.00
end
