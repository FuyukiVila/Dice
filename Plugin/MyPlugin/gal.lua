msg_order = {

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
}

--选择支实例
Select = {
    choice = "",
    affect = 0 or function()
    end,
    reply = "",
    nextIndex = 1,
    new = function(self, choice, affect, reply, nextIndex)
        local obj = {}
        setmetatable(obj, self)
        obj.choice = choice or ""
        obj.affect = affect or 0
        obj.reply = reply or ""
        obj.nextIndex = nextIndex
        return obj
    end,
    __index = Select
}

-- galgame
function gal(msg, Chapters, res)
    local index = 1
    while (index <= #Chapters and index >= 1) do
        local chapter = Chapters[index]
        sendMsg(chapter.words, msg.gid, msg.uid)
        index = index + 1
        if chapter.select ~= nil then
            local reply = "（请回复其中之一："
            for _, select in ipairs(chapter.select) do
                setUserToday(msg.uid, select.choice, 0)
                msg_order[select.choice] = "chooseSelect"
                reply = reply .. select.choice .. ' '
            end
            reply = reply .. '）'
            sendMsg(reply, msg.gid, msg.uid)
            sleepTime(2000)
            while true do
                for _, select in ipairs(chapter.select) do
                    if getUserToday(msg.uid, select.choice, 0) == 1 then
                        if type(select.affect) == "function" then
                            select.affect(msg)
                        elseif type(select.affect) == "number" then
                            res.favor = res.favor + select.affect
                        end
                        sendMsg(select.reply, msg.gid, msg.uid)
                        sleepTime(5000)
                        index = select.nextIndex or index
                        goto continue
                    end
                end
            end
            :: continue ::
        end
        sleepTime(5000)
    end
    return res
end

function chooseSelect(msg)
    setUserToday(msg.uid, msg.fromMsg, 1)
end
