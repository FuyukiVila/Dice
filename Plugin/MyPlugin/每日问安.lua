--问安样例脚本
--使用《署名—非商业性使用—相同方式共享 4.0 协议国际版》（CC BY-NC-SA 4.0）进行授权https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.zh-Hans
--加载后请手动设置定时任务
--作者:安研色Shiki
msg_order = {}
task_call = {
    good_morning="good_morning",
    good_afternoon="good_afternoon",
    good_evening="good_evening",
    good_night="good_night",
}
notice_head = ".send notice 6 "
function table_draw(tab)
    if(#tab==0)then return "" end
    return tab[ranint(1,#tab)]
end
morning_word = "早安~兰草花已经开满了！"
morning_voice = "goodmorning.wav"
afternoon_word = "下午好~要来杯下午茶吗？"
afternoon_voice = "goodafternoon.wav"
evening_word = "晚上好~夜来香攀进了你的窗帘……"
evening_voice = "goodevening.wav"
night_word = "晚安~今晚也做个好梦~"
night_voice = "goodnight.wav"
function good_morning()
    eventMsg(notice_head..morning_word, 0, getDiceQQ())
    eventMsg(notice_head.."[CQ:record,file="..morning_voice.."]",0,getDiceQQ())
end
function good_afternoon()
    eventMsg(notice_head..afternoon_word, 0, getDiceQQ())
    eventMsg(notice_head.."[CQ:record,file="..afternoon_voice.."]", 0, getDiceQQ())
end
function good_evening()
    eventMsg(notice_head..evening_word, 0, getDiceQQ())
    eventMsg(notice_head.."[CQ:record,file="..evening_voice.."]", 0, getDiceQQ())
end
function good_night()
    eventMsg(notice_head..night_word, 0, getDiceQQ())
    eventMsg(notice_head.."[CQ:record,file="..night_voice.."]", 0, getDiceQQ())
end

function printChat(msg)
    if(msg.fromGroup=="")then
        return "QQ "..msg.fromQQ
    else
        return "group "..msg.fromGroup
    end
end

function book_alarm_call(msg)
    eventMsg(".admin notice "..printChat(msg).." +6", 0, getDiceQQ())
    return "已订阅{self}的定时早午晚安服务√"
end
function unbook_alarm_call(msg)
    eventMsg(".admin notice "..printChat(msg).." -6", 0, getDiceQQ())
    return "已退订{self}的定时早午晚安服务√"
end
msg_order["订阅问安"]="book_alarm_call"
msg_order["退订问安"]="unbook_alarm_call"