--[[
几个api实例，但是目的并不是为了检验api的可行性。
by 简律纯(QQA2C29K9)
2022/9/11
]]
msg_order = {}

local filter_spec_chars = function(s)
    local ss = {}
    for k = 1, #s do
        local c = string.byte(s, k)
        if not c then break end
        if (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
            if not string.char(c):find("%w") then
                table.insert(ss, string.char(c))
            end
        elseif c >= 228 and c <= 233 then
            local c1 = string.byte(s, k + 1)
            local c2 = string.byte(s, k + 2)
            if c1 and c2 then
                local a1, a2, a3, a4 = 128, 191, 128, 191
                if c == 228 then
                    a1 = 184
                elseif c == 233 then
                    a2, a4 = 190, c1 ~= 190 and 191 or 165
                end
                if c1 >= a1 and c1 <= a2 and c2 >= a3 and c2 <= a4 then
                    k = k + 2
                    table.insert(ss, string.char(c, c1, c2))
                end
            end
        end
    end
    return table.concat(ss)
end

local getAtQQ = function(str)
    local n = tonumber(str)
    if (n) then
        return str
    else
        return string.match(str, "%d+")
    end
end

function throw(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"丢" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/diu.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["丢"] = "throw"

function fabulous(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"赞" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/zan.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["赞"] = "fabulous"

function climb(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"爬" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/paa.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["爬"] = "climb"

function run(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"跑" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/pao.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["跑"] = "run"

function cpdd(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"cpdd" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我" or target == msg.fromQQ) then
            return "{nick}你在想什么？"
        elseif(target == "") then
            return "{self}不知道{nick}喜欢谁"
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/xie.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["cpdd"] = "cpdd"

function xin(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"比心" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/xin.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["比心"] = "xin"

function qian(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"牵" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我" or target == msg.fromQQ) then
            pic = "https://xiaobai.klizi.cn/API/ce/qian.php?qq=" .. getDiceQQ() .. "&qq1=" .. msg.uid
            return "[CQ:image,url=" .. pic .. "]"
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/qian.php?qq=" .. msg.fromQQ .. "&qq1=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["牵"] = "qian"

function bishi(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"鄙视" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/bishi.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["鄙视"] = "bishi"

function need(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"你可能需要" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/need.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["你可能需要"] = "need"

function chi(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"吃" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/gif/chi.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["吃"] = "chi"

function bite(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"啃" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/gif/bite.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["啃"] = "bite"

function pat(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"拍" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/gif/pat.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["拍"] = "pat"

function hammer(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"锤" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/gif/hammer.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["锤"] = "hammer"

function tian(msg)
    local tgt = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", #"舔" + 1)
    local target = getAtQQ(tgt)
    if (tgt ~= "") then
        if (tgt == "我") then
            target = msg.fromQQ
        elseif (target == "") then
            return ""
        end
        local pic = "https://xiaobai.klizi.cn/API/ce/tian.php?qq=" .. target
        return "[CQ:image,url=" .. pic .. "]"
    else
        return ""
    end
end

msg_order["舔"] = "tian"