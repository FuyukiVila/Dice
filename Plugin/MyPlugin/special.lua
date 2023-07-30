require("tool")
require("favor")

msg_order = {
    ["日出"] = "chooseAnswer",
    ["日落"] = "chooseAnswer"
}

--章节实例
Chapter = {
    words = "",
    select = {

    },
    new = function(self, words, select)
        local obj = {}
        setmetatable(obj, self)
        obj.words = words or ""
        obj.select = select
        return obj
    end,
    __index = Chapter,

    --选择支实例
    Select = {
        choice = "",
        favor = 0,
        reply = "",
        nextIndex = 1,
        new = function(self, choice, favor, reply, nextIndex)
            local obj = {}
            setmetatable(obj, self)
            obj.choice = choice or ""
            obj.favor = favor or 0
            obj.reply = reply or ""
            obj.nextIndex = nextIndex
            return obj
        end,
        __index = Chapter.Select
    }
}

--情人节特供
function ValentineDate(msg)
    local res = { change = 0, reply = "" }
end

--圣诞特供
function ChristmasDate(msg)
    local res = { change = 0, reply = "" }
end

--七夕特供
local QixiChapters = {
    sunrise = {
        [1] = Chapter:new("这么早就来找我了吗？那……要一起去看日出吗？"),
        [2] = Chapter:new("（走在山路上）说起来，{nick}喜欢日出的风景还是日落的风景？", {
            Chapter.Select:new("日出", 20, "日出吗？我也喜欢日出，清晨的阳光洒在大地上，万物便有了生机，崭新的一天就此开始了。"),
            Chapter.Select:new("日落", 10, "日落吗……日落也不错哦，夕阳西下，晚霞浸染大地……啊，不好意思，刚才说入迷了！") }),
        [3] = Chapter:new("（山路蜿蜒陡峭，加之杂草丛生，你们小心翼翼地拨开沿路的灌木，一步一步沿着路向上走）"),
        [4] = Chapter:new("小心！（你的脚下突然一滑，就在你的脑袋即将与地面亲密接触的前一刻，你的手臂被拉住了，让你免受了这次不幸）"),
        [5] = Chapter:new("呜……（少女吃力地抓住你的双臂，可以看出她很快要撑不住了，你赶忙调整姿态，站了起来）"),
        [6] = Chapter:new("呼~没事吧……小心点啦，这儿的路上石头比较多，注意脚下，不要被绊倒咯。"),
        [7] = Chapter:new("再往前走一点就是山顶了，加把劲吧，我可不想错过了今天的日出哦~"),
        [8] = Chapter:new("（走到山顶上，万籁俱寂，远处的山峰隐隐约约能看到些许微光，少女走在你的前面，注视着前方）呼~看来我们赶上了。"),
        [9] = Chapter:new("啊，等等！（走了过来，你眼前一黑，眼睛被一只娇嫩的小手挡住了）别睁眼，我数十秒后再睁开。十，九，八，七……"),
        [10] = Chapter:new("四，三，二，一……"),
        [11] = Chapter:new("[CQ:image,file=special\\Qixi\\sunrise.png]")
    }
}

-- galgame
function gal(msg, Chapters, res)
    local index = 1
    while (index <= #Chapters and index >= 1) do
        local chapter = Chapters[index]
        sendMsg(chapter.words, msg.gid, msg.uid)
        sleepTime(4000)
        index = index + 1
        if chapter.select ~= nil then
            local reply = "（请回复其中之一："
            for _, select in ipairs(chapter.select) do
                setUserToday(msg.uid, select.choice, 0)
                reply = reply .. select.choice .. ' '
            end
            reply = reply .. '）'
            sendMsg(reply, msg.gid, msg.uid)
            sleepTime(2000)
            while true do
                for _, select in ipairs(chapter.select) do
                    if getUserToday(msg.uid, select.choice, 0) == 1 then
                        res.change = res.change + select.favor
                        sendMsg(select.reply, msg.gid, msg.uid)
                        sleepTime(4000)
                        index = select.nextIndex or index
                        goto continue
                    end
                end
            end
            ::continue::
        end
    end
    return res
end

function QixiDate(msg)
    local res = { change = 50, reply = "" }
    if tonumber(os.date("%H")) < 8 then
        res = gal(msg, QixiChapters.sunrise, res)
        res.reply = "七夕快乐，{nick}，今年就由我来陪你过吧~"
    elseif tonumber(os.date("%H")) < 18 then

    else

    end
    return res
end

function chooseAnswer(msg)
    setUserToday(msg.uid, msg.fromMsg, 1)
end
