require("tool")
json = require("json")

local url <const> = 'https://codeforces.com/api/'

msg_order = {
    ["视监"] = "getUserInfo",
    ["今日比赛"] = "getContestNotice",
    ["订阅比赛"] = "bookContestNotice",
    ["退订比赛"] = "unbookContestNotice"
}

task_call = {
    contest_notice = "contestNotice"
}

notice_head = ".send notice 7 "

function getUserInfo(msg)
    local uerId = getTarget(msg)
    local url = url .. 'uWser.info?handles=' .. uerId
    local err, res = http.get(url)
    if not err then
        return "没有找到该用户×"
    end
    local data = json.decode(res).result[1]
    return string.format("[CQ:image,url=%s]ID:%s\nRating:%d\nMaxRating:%d\nRank:%s\nMaxRank:%s",
        data.titlePhoto, data.handle, data.rating or 0, data.maxRating or 0, data.rank or "Unrated",
        data.maxRank or "Unrated")
end

function printChat(msg)
    if(msg.fromGroup=="")then
        return "QQ "..msg.fromQQ
    else
        return "group "..msg.fromGroup
    end
end

function bookContestNotice(msg)
    setGroupConf(msg.gid, "contestNotice", 1)
    eventMsg(".admin notice " .. printChat(msg) .. " +7", 0, getDiceQQ())
    return "已订阅{self}的codeforces比赛通知服务√"
end

function unbookContestNotice(msg)
    setGroupConf(msg.gid, "contestNotice", 0)
    eventMsg(".admin notice " .. printChat(msg) .. " -7", 0, getDiceQQ())
    return "已退订{self}的codeforces比赛通知服务√"
end


function contestNotice()
    local url = url .. "contest.list?gym=false"
    local contestUrl = "codeforces.com/contests/"
    local err, res = http.get(url)
    local now = os.date("*t")
    if not err then
        return
    end
    local data = json.decode(res).result
    local notice = "今日比赛:\n"
    for index, contest in ipairs(data) do
        if contest.phase == "FINISHED" then
            break
        end
        local startTime = os.date("*t", contest.startTimeSeconds)
        if now.day == startTime.day then
            notice = notice..string.format("%s\n%s\n开始时间 %d:%d:%d\n",
            contest.name, contestUrl..contest.id, startTime.hour, startTime.min, startTime.sec)
        end
    end
    if notice == "今日比赛:\n" then
        return
    end
    eventMsg(notice_head .. notice, 0, getDiceQQ())
end

function getContestNotice(msg)
    if msg.fromMsg ~= "今日比赛" or msg.gid == "" or getGroupConf(msg.gid, "contestNotice", 0) == 0 then
        return
    end
    local url = url .. "contest.list?gym=false"
    local contestUrl = "codeforces.com/contests/"
    local err, res = http.get(url)
    local now = os.date("*t")
    if not err then
        return
    end
    local data = json.decode(res).result
    local notice = "今日比赛:\n"
    for index, contest in ipairs(data) do
        if contest.phase == "FINISHED" then
            break
        end
        local startTime = os.date("*t", contest.startTimeSeconds)
        if now.day == startTime.day then
            notice = notice .. string.format("%s\n%s\n开始时间 %s\n",
                contest.name, contestUrl .. contest.id, os.date("%H:%M:%S", contest.startTimeSeconds))
        end
    end
    return notice
end