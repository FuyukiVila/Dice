msg_order = {

}

--章节实例
Chapter = {
    words = "",
    select = {

    },
    nextIndex = 0,
    new = function(self, words, nextIndex, select)
        local obj = {}
        setmetatable(obj, self)
        obj.words = words or ""
        obj.nextIndex = nextIndex
        obj.select = select
        return obj
    end,
    __index = Chapter,
}

--选择支实例
Select = {
    choice = "",             --选择支
    affect = function() end, --选择后的影响
    nextIndex = 1,
    new = function(self, choice, affect, nextIndex)
        local obj = {}
        setmetatable(obj, self)
        obj.choice = choice or ""
        obj.affect = affect
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
        index = chapter.nextIndex or index
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
                            select.affect(msg, res)
                        end
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
