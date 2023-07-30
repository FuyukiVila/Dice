--[[
dice!斗地主插件v0.0.1 by 豹猫ocelot
本脚本为试做品，结构较为混乱（遇河搭桥，遇山挖洞），可能将于下个版本重构（咕咕咕）。
玩家挂机跳过检测等功能还没做（懒
bug反馈/建议找qq1226421749

设计思路参考：https://blog.csdn.net/Tang_AHMET/article/details/106783125
参考的函数代码遵循原文的开源协议
]]
msg_order={}
--自定义触发词
join = "加入游戏"
quit = "退出游戏"
init_m = "开始游戏"
look_card = "查看手牌"
choose_pai = "选牌"
return_pai = "取消选牌"
chu_pai = "出牌"
bu_yao = "要不起"
buyao = "不要"
want_dizhu = "抢地主"
d_want_dizhu = "不抢地主"
help_message = "斗地主帮助"
enable = "启用斗地主"
disable = "禁用斗地主"
show_color = false  --是否显示花色

help_info = {--自定义帮助
    "斗地主脚本帮助",
    "玩之前请先加骰娘好友，因为需要用到私聊发牌",
    "开局：三个玩家分别发送“"..join.."”，然后发送“"..init_m.."”",
    "抢地主：发送“"..want_dizhu.."”或“"..d_want_dizhu.."”\n地主牌会自动选中，请先取消选牌后在发送",
    "选牌和出牌：",
    "  看牌：发送“"..look_card.."”",
    "  选牌：发送“"..choose_pai.." 牌1 牌2 牌n”。可使用“"..return_pai.."”将选中的牌放回手牌",
    "  发牌：发送“"..chu_pai.."”，特别的，如果没选牌，可以直接发送“"..chu_pai.." 牌1 牌2 牌n”出牌",
    "  ***参数间请一定用空格隔开,不区分大小写。特殊牌：(大王:dw，小王:xw)",
    "  发送例：想出牌：2 2 2 A",
    "  发送“"..chu_pai.." 2 2 2 A”",
    "  如果你没有大过上家的牌，发送“"..bu_yao.."”",
    "指令“"..quit.."”：退出当前战局。特别的，当游戏开始后，会结束本局并将所有玩家移除。",
    "开关：“"..enable.."”,“"..disable.."”//在本群启用/禁用",
    "dice!斗地主插件v0.0.1 by豹猫ocelot"
}
--[[
    如果你不想修改下方函数结构，可以略过本注释

牌型type：

    1一张
    2一对
    3顺子
    4连对
    5三个
    6三带一
    7三带二
    8四带二
    9飞机
    10炸弹
    11王炸

牌定义：
    十六进制,十位表示花色，个位表示点数
    花色：红黑梅方王(0 - 4)
    点数：A - K(1 - 13)
    牌值：3 - K:3 - 13;A:13;2:15;小王：18;大王：19
    0x01(红桃A)

用到的配置项
--群配置
    "斗地主玩家"--table,记录三位玩家{A,B,C}
    "斗地主玩家数"--num，记录加入了几位玩家
    "斗地主状态"--num，是否开局:0 off;1 on
    "地主牌"--table，地主的三张牌
    "dizhucount"--num,-1：已抢过地主，1~3：正在抢地主
    "出牌指向"--num,1~3：轮到第n个人出牌了
    "不要次数"--num,0-2:等于2的时候下一人出牌且num置为0
    "牌型"--table,{牌型,点数,牌数}
    "斗地主"--bool,是否禁用
--用户配置
    "doudizhu_group"--num，加入了哪里的游戏
    "my_puke_card"--table,手牌
    "puke_cache"--table，选中的牌
    "isdizhu"--num,是不是地主
    "chupai"--num，防止死循环用
]]

function help(msg)
    return table.concat(help_info,"\n")
end
--msg_order[help_message]="help"

function rss(msg)--重置自己
    setUserConf(msg.fromQQ,"doudizhu_group",nil)
    setUserConf(msg.fromQQ,"puke_cache",nil)
    return"ok"
end
function rsg(msg)--重置群
    setGroupConf(msg.fromGroup, "斗地主玩家数",0)
    setGroupConf(msg.fromGroup, "斗地主玩家", player)
    setGroupConf(msg.fromGroup,"斗地主状态",0)
    return"ok"
end

msg_order["resetgroup"]="rsg"--重置指令，若非配置项错乱（如加入已在，退出已退），请勿解除封印
msg_order["resetself"]="rss"

function enable_f(msg)
    if(msg.fromGroup == '')then
        return "私聊窗口打不了牌哒"
    elseif(getUserConf(msg.fromQQ,"trust",0) < 4 and not (getGroupConf(msg.fromGroup, "auth#"..msg.fromQQ, 1) > 1))then
        return "请让群管理发送该指令×"
    else
        setGroupConf(msg.fromGroup, "斗地主", 1)
        return "已启用斗地主"
    end
end
function disable_f(msg)
    if(msg.fromGroup == '')then
        return "私聊窗口打不了牌哒"
    elseif(getUserConf(msg.fromQQ,"trust",0) < 4 and not (getGroupConf(msg.fromGroup, "auth#"..msg.fromQQ, 1) > 1))then
        return "请让群管理发送该指令×"
    else
        player =  getGroupConf(msg.fromGroup, "斗地主玩家",{})--重置
        for i = 1,3 do--玩家状态置空
            if(player[i] ~= nil)then
                setUserConf(player[i],"doudizhu_group",nil)
                setUserConf(player[i],"puke_cache",nil)
            end
            player[i]=nil
        end
        setGroupConf(msg.fromGroup, "斗地主玩家数",0)
        setGroupConf(msg.fromGroup, "斗地主玩家", {})
        setGroupConf(msg.fromGroup,"斗地主状态",0)--群状态置空
        setGroupConf(msg.fromGroup, "斗地主", 0)--关闭
        return "已禁用斗地主"
    end
end
msg_order[enable]="enable_f"
msg_order[disable]="disable_f"

function join_f(msg)
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    player =  getGroupConf(msg.fromGroup, "斗地主玩家",{})
    p_num = getGroupConf(msg.fromGroup, "斗地主玩家数",0)
    if(msg.fromGroup == '')then
        return"你在私聊窗口加哪呢"
    elseif(getUserConf(msg.fromQQ,"doudizhu_group",msg.fromGroup) ~= msg.fromGroup)then
        return"你想去几个群开盘呢"
    elseif(player[1]==msg.fromQQ or player[2]==msg.fromQQ or player[3]==msg.fromQQ)then
        return"你已经加入了"
    elseif(getGroupConf(msg.fromGroup,"斗地主状态",0) == 1)then
        return"游戏已经开始了"
    elseif(p_num~=3) then
        player[p_num+1] = msg.fromQQ
        setUserConf(msg.fromQQ,"doudizhu_group",msg.fromGroup)
        setGroupConf(msg.fromGroup, "斗地主玩家", player)
        setGroupConf(msg.fromGroup, "斗地主玩家数",p_num+1)--不等于3人时加入玩家队列，玩家数+1
    else
        return "满员啦"
    end
    return "当前玩家："..table.concat(player," ")
end
msg_order[join]="join_f"

function quit_f(msg)
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    player =  getGroupConf(msg.fromGroup, "斗地主玩家",{})
    p_num = getGroupConf(msg.fromGroup, "斗地主玩家数",0)
    if(msg.fromGroup == '')then
        return"你在私聊窗口退哪呢"
    elseif(getUserConf(msg.fromQQ,"doudizhu_group",msg.fromGroup) ~= msg.fromGroup)then
        return"请去\""..getUserConf(msg.fromQQ,"doudizhu_group").."\"群退出"
    elseif((player[1]~=msg.fromQQ or player[2]~=msg.fromQQ or player[3]~=msg.fromQQ)and not getUserConf(msg.fromQQ,"doudizhu_group",nil)) then
        return"{nick}已经离开了"
    elseif(getGroupConf(msg.fromGroup,"斗地主状态",0)==1)then--若游戏已经开始，结束正在进行的游戏
        for i = 1,3 do--玩家状态置空
            setUserConf(player[i],"doudizhu_group",nil)
            setUserConf(player[i],"puke_cache",nil)
            player[i]=nil
        end
        setGroupConf(msg.fromGroup, "斗地主玩家数",0)
        setGroupConf(msg.fromGroup, "斗地主玩家", player)
        setGroupConf(msg.fromGroup,"斗地主状态",0)--群状态置空
        return "游戏已经结束"
    else--游戏未开始，移除当前玩家
        for i = 1,3 do--遍历玩家
            if(player[i]==msg.fromQQ)then--玩家i是当前玩家
                setUserConf(player[i],"doudizhu_group",nil)
                for j = i,3 do--将i后的玩家前移一位（移除i所在的玩家），将玩家i参加的游戏群置空
                    player[j]=player[j+1]
                end
                break--跳出循环
            end
        end
    end
    setGroupConf(msg.fromGroup, "斗地主玩家", player)--保存配置
    setGroupConf(msg.fromGroup, "斗地主玩家数",p_num-1)--玩家-1
    return "当前玩家："..table.concat(player," ")
end
msg_order[quit]="quit_f"

function init(msg)--初始化（洗牌，发牌）
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    if(msg.fromGroup == '')then
        return"请去群里发送"
    elseif(getGroupConf(msg.fromGroup,"斗地主状态",0)==1)then return "已经开了" 
    elseif(getGroupConf(msg.fromGroup, "斗地主玩家数",0) ~= 3)then
        return "人还不齐呢,快去摇人"
    end
    player =  getGroupConf(msg.fromGroup, "斗地主玩家",{})
    cards = newCards()--取牌
    for i = 1,ranint(2,5) do--随机洗牌2~5次
        cards = shuffle(cards)--洗牌
    end
    playercard = sendCards(cards)--分牌
    setUserConf(player[1],"my_puke_card",sort(playercard[1]))
    setUserConf(player[2],"my_puke_card",sort(playercard[2]))
    setUserConf(player[3],"my_puke_card",sort(playercard[3]))--发牌
    setUserConf(player[1],"puke_cache",{})
    setUserConf(player[2],"puke_cache",{})
    setUserConf(player[3],"puke_cache",{})--删除已选的牌
    setGroupConf(msg.fromGroup,"地主牌",sort(playercard[4]))--存地主牌
    eventMsg("查看手牌", msg.fromGroup, player[1])
    sleepTime(1000)
    eventMsg("查看手牌", msg.fromGroup, player[2])
    sleepTime(1000)
    eventMsg("查看手牌", msg.fromGroup, player[3])--给玩家看自己的手牌
    setGroupConf(msg.fromGroup,"斗地主状态",1)--游戏开始
    setGroupConf(msg.fromGroup, "dizhucount", 1)--可以抢地主了
    return "请抢地主"
end
msg_order[init_m]="init"

function look_my_card(msg)--查看手牌
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 and #msg.fromGroup > 2 then return"" end
    my_puke = getUserConf(msg.fromQQ,"my_puke_card")
    cache_puke = getUserConf(msg.fromQQ,"puke_cache",{})--读取参数
    real_puke = {}
    real_puke_c = {}
    if(not my_puke or #my_puke == 0)then
        return "你没有牌"
    elseif(#cache_puke > 0)then--玩家选过牌
        for i = 1,#my_puke do
            real_puke[i] = getCardReal(my_puke[i])--将牌由16进制存储型转换为字符串
        end
        for i = 1,#cache_puke do
            real_puke_c[i] = getCardReal(cache_puke[i])
        end
        sendMsg("手牌："..table.concat(real_puke," ").."\n已选："..table.concat(real_puke_c," "), 0, msg.fromQQ)
    else--玩家没选牌
        local real_puke = {}
        for i = 1,#my_puke do
            real_puke[i] = getCardReal(my_puke[i])
        end
        sendMsg("手牌："..table.concat(real_puke," "), 0, msg.fromQQ)
    end
end
msg_order[look_card]="look_my_card"

function choose_card(msg)--选牌
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 and #msg.fromGroup > 2 then return"" end
    cache = getUserConf(msg.fromQQ,"puke_cache",{})
    my_puke = getUserConf(msg.fromQQ,"my_puke_card",nil)
    for word in string.gmatch(msg.fromMsg, "%a+") do --匹配字符
        if(word == choose_pai or word == chu_pai or word == nil)then--跳过触发词
            goto Label1
        end
        for i = 1,#my_puke do--遍历手牌
            if(cardtoValue(word) == getCardValue(my_puke[i]))then--如果牌i与触发词word类型相同，取出该牌并跳出循环
                card = table.remove(my_puke,i)
                table.insert(cache,card)
                break
            end
        end
        :: Label1 ::
    end
    for word in string.gmatch(msg.fromMsg, "%d+") do --匹配数字
        if(word == choose_pai or word == chu_pai or word == nil)then
            goto Label2
        end
        for i = 1,#my_puke do
            if(cardtoValue(word) == getCardValue(my_puke[i]))then
                card = table.remove(my_puke,i)
                table.insert(cache,card)
                break
            end
        end
        :: Label2 ::
    end
    setUserConf(msg.fromQQ,"puke_cache",cache)
    setUserConf(msg.fromQQ,"my_puke_card",my_puke)
    look_my_card(msg)--调用看牌
end
msg_order[choose_pai]="choose_card"

function return_card(msg)--取消选择
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 and #msg.fromGroup > 2 then return"" end
    cache = getUserConf(msg.fromQQ,"puke_cache",{})
    my_puke = getUserConf(msg.fromQQ,"my_puke_card",nil)
    while (#cache>0) do--放回手牌直到选中区没有牌
        local card = table.remove(cache)
        table.insert(my_puke,card)
    end
    setUserConf(msg.fromQQ,"puke_cache",{})
    setUserConf(msg.fromQQ,"my_puke_card",sort(my_puke))--排序并放回
    look_my_card(msg)
end
msg_order[return_pai]="return_card"

function chu_pai_f(msg)--出牌！！
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    if(msg.fromGroup == '')then
        return"请去群里发送"
    elseif(getGroupConf(msg.fromGroup, "斗地主状态")==0)then
        return"请先开局"
    elseif(getGroupConf(msg.fromGroup,"dizhucount")~=-1)then
        return"请先抢地主"
    end
    ctpc = {}
    player = getGroupConf(msg.fromGroup, "斗地主玩家",{})
    cache = getUserConf(msg.fromQQ,"puke_cache",{})
    tpc = getGroupConf(msg.fromGroup, "牌型",{})--上家的牌型
    ctpc[1] = getCardsType(cache)--牌型种类1
    ctpc[2] = getCardsPoint(cache)--副牌点数2
    ctpc[3] = #cache--副牌长度3（1 2 3本次出牌的牌型）
    cp = getGroupConf(msg.fromGroup, "出牌指向")
    cc = getGroupConf(msg.fromGroup, "不要次数")
    if(not isplayer(msg.fromQQ,msg.fromGroup))then
        return "你没有参与游戏"
    elseif(player[cp]~=msg.fromQQ)then--未选牌的出牌
        return "请先等待"..player[cp].."出牌"
    elseif(not cache or #cache==0 and getUserConf(msg.fromQQ,"chupai",0)==0)then--未选牌且未循环
            choose_card(msg)--先选牌
            setUserConf(msg.fromQQ,"chupai",1)--设为已循环
            eventMsg(chu_pai, msg.fromGroup, msg.fromQQ)--再重新执行出牌
            return ""
    end
    setUserConf(msg.fromQQ,"chupai",0)--设为未循环
    if(cc == 2 and ctpc[1] ~= 12)then--先手（其余两位要不起且牌型正确）
        tpc[1] = ctpc[1]
        tpc[2] = ctpc[2]
        tpc[3] = ctpc[3]
        setGroupConf(msg.fromGroup, "牌型",tpc)--直接记录为上家牌
        setUserConf(msg.fromQQ,"puke_cache",{})--清除选中
        setGroupConf(msg.fromGroup, "不要次数",0)--重置不要次数
        if(cp==3)then--轮到下家出牌
            setGroupConf(msg.fromGroup, "出牌指向",1)
        else
            setGroupConf(msg.fromGroup, "出牌指向",cp+1)
        end
        local real_puke = {}
        for i = 1,#cache do--将存储的十六进制牌转换成人类语言
            real_puke[i] = getCardReal(cache[i])
        end
        if(#(getUserConf(msg.fromQQ,"my_puke_card")) == 0)then--检测到牌出完了,重置
            for i = 1,3 do
                setUserConf(player[i],"doudizhu_group",nil)
                setUserConf(player[i],"puke_cache",nil)
                player[i]=nil
            end
            setGroupConf(msg.fromGroup, "斗地主玩家数",0)
            setGroupConf(msg.fromGroup, "斗地主玩家", player)
            setGroupConf(msg.fromGroup,"斗地主状态",0)
            return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ").."\f{nick}赢了"
        else 
            if(#(getUserConf(msg.fromQQ,"my_puke_card")) > 5)then
                return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ")
            else
                return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ").."\f{nick}还剩"..#(getUserConf(msg.fromQQ,"my_puke_card")).."张牌了"
            end
        end
    elseif(cc~=2)then--后手
        if(isCardRight(tpc,ctpc))then--牌型点数大于上家且正确
            tpc[1] = ctpc[1]
            tpc[2] = ctpc[2]
            tpc[3] = ctpc[3]
            setGroupConf(msg.fromGroup, "牌型",tpc)--保存为上家
            setUserConf(msg.fromQQ,"puke_cache",{})
            setGroupConf(msg.fromGroup, "不要次数",0)
            if(cp==3)then
                setGroupConf(msg.fromGroup, "出牌指向",1)
            else
                setGroupConf(msg.fromGroup, "出牌指向",cp+1)
            end
                local real_puke = {}
                for i = 1,#cache do
                    real_puke[i] = getCardReal(cache[i])
                end
            if(#(getUserConf(msg.fromQQ,"my_puke_card")) == 0)then--检测到牌出完了,重置
                for i = 1,3 do--重置玩家配置
                    setUserConf(player[i],"doudizhu_group",nil)
                    setUserConf(player[i],"puke_cache",nil)
                    player[i]=nil
                end
                setGroupConf(msg.fromGroup, "斗地主玩家数",0)
                setGroupConf(msg.fromGroup, "斗地主玩家", player)--重置群配置
                setGroupConf(msg.fromGroup,"斗地主状态",0)
                return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ").."\f{nick}赢了"
            else 
                if(#(getUserConf(msg.fromQQ,"my_puke_card")) > 5)then
                    return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ")
                else
                    return "{nick}出牌："..toCardType(tpc[1])..table.concat(real_puke," ").."\f{nick}还剩"..#(getUserConf(msg.fromQQ,"my_puke_card")).."张牌了"
                end
            end
        end
    end
    return "错误，请重新选择"
end
msg_order[chu_pai]="chu_pai_f"

function buyao_f(msg)--要不起
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    if(getGroupConf(msg.fromGroup, "斗地主状态")==0)then
        return""
    elseif(getGroupConf(msg.fromGroup,"dizhucount")~=-1)then
        return""
    end
    cc = getGroupConf(msg.fromGroup, "不要次数")
    cp = getGroupConf(msg.fromGroup, "出牌指向")
    player = getGroupConf(msg.fromGroup, "斗地主玩家",{})
    if(cc==2)then
        if(player[cp]~=msg.fromQQ)then
            return "请等待"..player[cp].."发牌"
        else
            return "到你出牌啦"
        end
    elseif(player[cp]~=msg.fromQQ)then
        return "请先等待上家"..player[cp].."出牌"
    elseif(cp==3)then
        setGroupConf(msg.fromGroup, "出牌指向",1)
    else
        setGroupConf(msg.fromGroup, "出牌指向",cp+1)
    end
    setGroupConf(msg.fromGroup, "不要次数",getGroupConf(msg.fromGroup, "不要次数")+1)
    return "{nick}不要"
end
msg_order[bu_yao]="buyao_f"
msg_order[buyao]="buyao_f"

function get_dizhu(msg)--抢地主
    if getGroupConf(msg.fromGroup, "斗地主", 0) == 0 then return"" end
    if(msg.fromGroup == '')then
        return"请去群里发送"
    elseif(getGroupConf(msg.fromGroup, "斗地主状态",0)==0)then
        return""
    end
    i = getGroupConf(msg.fromGroup, "dizhucount")--指向第i个玩家
    player = getGroupConf(msg.fromGroup, "斗地主玩家")
    dizhucard = sort(getGroupConf(msg.fromGroup,"地主牌"))
    if(getGroupConf(msg.fromGroup,"斗地主状态",1)==0)then 
        return "请先开局" 
    elseif(i==-1)then
        return ""
    elseif(not isplayer(msg.fromQQ,msg.fromGroup))then
        return "你没有参与游戏"
    elseif(player[i]~=msg.fromQQ)then
        return "请先等待上家"..player[i].."回应"
    end
    if(want_dizhu == msg.fromMsg or i>=3)then--抢地主
        if(i>=3 and d_want_dizhu==msg.fromMsg)then--第三次不要地主则把地主牌给第一个玩家
            setGroupConf(msg.fromGroup, "dizhucount", 1)--设为第一个玩家
            eventMsg("抢地主", msg.fromGroup, player[1])--假装第一个玩家要地主
            return "{nick}不要地主啦"--你得跟他说他不是
        end
        setUserConf(msg.fromQQ, "isdizhu", 1)
        setUserConf(msg.fromQQ, "puke_cache", dizhucard)
        local real_puke = {}--将地主牌放入缓冲区（手牌）
        for i = 1,#dizhucard do
            real_puke[i] = getCardReal(dizhucard[i])
        end
        setGroupConf(msg.fromGroup, "dizhucount", -1)
        setGroupConf(msg.fromGroup, "出牌指向", i)
        setGroupConf(msg.fromGroup, "不要次数", 2)
        return "地主是{nick}的啦，".."地主牌："..table.concat(real_puke," ")
    else
        setGroupConf(msg.fromGroup, "dizhucount", i+1)
        return "{nick}不要地主啦"
    end
end
msg_order[want_dizhu]="get_dizhu"
msg_order[d_want_dizhu]="get_dizhu"

function newCards()
    return
    {
        0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,
        0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,
        0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,
        0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,
        0x41,0x42
    }
end

function isplayer(qq,group)
    player = getGroupConf(group, "斗地主玩家",{})
    for i = 1,3 do
        if(player[i]==qq)then
            return true
        end
    end
    return false
end
function getCardReal(card)--求花色点数
    color = getCardColor(card)
    point = getCardPoint(card)
    if(color == 0)then
        color_s = "红桃"
    elseif(color == 1)then
        color_s = "黑桃"
    elseif(color == 2)then
        color_s = "方块"
    elseif(color == 3)then
        color_s = "黑梅"
    elseif(isJoker)then
        if(point == 1)then
            return "小王"
        elseif(point == 2)then
            return "大王"
        end
    end
    if(point == 1)then
        point_s = "A"
    elseif(point >= 2 and point <= 10)then
        point_s = point
    elseif(point == 11)then
        point_s = "J"
    elseif(point == 12)then
        point_s = "Q"
    elseif(point == 13)then
        point_s = "K"
    end
    if(show_color)then
        return color_s..point_s
    else
        return point_s
    end
end

function getCardColor(card)-- 求牌的花色
    return math.floor(card / 0x10)
end

function getCardPoint(card)--求点数
    return card % 0x10
end

function isJoker(card)--判断王牌
    return 4 == getCardColor(card)
end

function getCardValue(card)--求牌的牌值
    local point = getCardPoint(card) -- 获得点数
    if isJoker(card) then -- 如果是王牌
        if 1 == point then-- 0x41小王
            return 18
        else
            return 19
        end
    end
    if 1 == point then -- A
        return 14
    elseif 2 == point then -- 2
        return 16
    else
        return point -- 3 - K
    end
end

function shuffle(allCards)--洗牌
    for i = 1,#allCards do
        local j = ranint(1,#allCards)
        n=allCards[i]
        allCards[i]=allCards[j]
        allCards[j]=n
    end
    return allCards
end

function sendCards(allCards)--发牌
    local handCards = {}
    for i = 1,3 do
        handCards[i] = {}
        for j = 1,17 do
            local card = table.remove(allCards)
            table.insert(handCards[i],card)
        end
    end
    handCards[4] = {}
    for i = 1,3 do
        local card = table.remove(allCards)
        table.insert(handCards[4],card)
    end
    return handCards
end

function sort(handCards)--副牌排序
    table.sort(handCards,function(card1,card2)
        local value1 = getCardValue(card1)
        local value2 = getCardValue(card2)
        local color1 = getCardColor(card1)
        local color2 = getCardColor(card2)
        -- 先比较牌值
        if value1 ~= value2 then
            return value1 > value2
        else
            -- 再比较花色
            return color1 > color2
        end
    end)
    return handCards
end
--以下为出牌判断函数
-------------------------------
local CardsType = 
{
    -- 键值对 = 值
    Single = 1, -- 单张
    DuiZi = 2, -- 对子
    ShunZi = 3, -- 顺子
    LianDui = 4, -- 连对
    Three = 5, -- 三张
    ThreeTakeOne = 6, -- 三带一
    ThreeTakeTwo = 7, -- 三带二
    FourTakeTwo = 8, -- 四带二
    FeiJi = 9, -- 三张（333444）/三张带一（33344455/33344445）/三带二（3334445566）
    Boom = 10, -- 炸弹
    BoomBoom = 11, -- 王炸
    None = 12 -- 不符合牌型
}
--记牌器：将选中的牌转换成（牌值对应数量的键值对）
function toCardMap(selectedCards)
    local map = {}
    -- 键值size对应选中牌的数量
    map.size = #selectedCards
    for i = 1,20 do
        map[i] = 0
    end
    for i = 1,#selectedCards do
        local value = getCardValue(selectedCards[i])
        map[value] = map[value] + 1
    end
    return map
end
--判断是否是单张
function isSingle(cards) -- cards：记牌后的结果
    return 1 == cards.size
end
--判断是否是对子
function isDuiZi(cards)
    -- 判断张数
    if cards.size ~= 2 then
        return false
    end
    -- 遍历所有的牌值对应的数量，如果不等于0，判断是否等于2
    for i = 1,20 do
        local cardNum = cards[i] -- 得到当前牌值对应的数量
        if cardNum ~= 0 then
            return 2 == cardNum
        end
    end
end
--判断是否是顺子
function isShunZi(cards)
    if cards.size < 5 then
        return false
    end
    for i = 1,20 do
        local cardNum = cards[i]
        if 1 == cardNum then
            -- 遍历从i开始到i+cards.size - 1对应的数量都为1
            for j = 1,cards.size - 1 do
                local cardNum = cards[i + j]
                if cardNum ~= 1 then
                    return false
                end
            end
            return true -- 整个循环完成，返回true
        end
    end
    return false
end
--判断是否是连对
function isLianDui(cards)
    if cards.size%2 ~=0 or cards.size<6 then
        return false
    end
    for i = 1,20 do
        local cardNum = cards[i]
        if 2 == cardNum then
            -- 遍历
            for j = 1,cards.size/2-1  do
                local cardNum = cards[i + j]
                if cardNum ~= 2 then
                    return false
                end
            end
           return true
        end
    end
    return false
end
--判断是否是三张
function isThree(cards)
    if cards.size~=3 then
        return false
    end

    for i=1,20 do
        local cardNum=cards[i]
        if cardNum ==3 then
            return true
        end
    end
    return false
end
--判断是否是三带一
function ThreeTakeOne(cards)
    if cards.size~=4 then
        return false
    end
local issingle=0
local isThree=0
    for i=1,20 do
        local cardNum=cards[i]
        if cardNum ==3 then
            isThree=isThree+1
        end
        if cardNum == 1 then
        issingle=issingle+1
        end
    end
    if issingle==1 and isThree==1 then
        return true
    else
        return false
    end
end
--判断是否是三带二
function ThreeTakeTwo(cards)
    if cards.size~=5 then
        return false
    end
local istwo=false
local isThree=false
    for i=1,20 do
        local cardNum=cards[i]
        if cardNum ==3 then
            isThree=true
        end
        if cardNum == 2 then
            istwo=true
        end
    end
    if istwo==true and isThree==true then
        return true
    else
        return false
    end
end
--判断是否是四带二
function FourTakeTwo(cards)
    if cards.size~=6 then
        return false
    end
local istwo=false
local isfour=false
    for i=1,20 do
        local cardNum=cards[i]
        if cardNum ==4 then
            isfour=true
        end
        if cardNum == 2 then
             istwo=true
        end
    end
    if istwo==true and isfour==true then
        return true
    else
        return false
    end
end
--判断是否是飞机
function FeiJi(cards)
     if cards.size < 6 then
        return false
    end
    -- 3 * n(333444) --666888
    if cards.size % 3 == 0 then
        local feijiLength = cards.size / 3 -- 飞机的总长度
        local length = 0 -- 记录的长度
        for i = 1,20 do
            local cardNum = cards[i]
            if 3 == cardNum then
                length = length + 1 -- 飞机数量+1
                if feijiLength == length then
                    return true
                end
            else
                length = 0
            end
        end
    end
    -- (3 + 1)* n(33344456 / 33334445 / 33334444/555666777333)
    if cards.size % 4 == 0 then
        local feijiLength = cards.size / 4 -- 飞机的总长度
        local length = 0 -- 记录的长度
        for i = 1,20 do
            local cardNum = cards[i]
            if cardNum >= 3 then
                length = length + 1 -- 飞机数量+1
                if feijiLength == length then
                    return true
                end
            else
                length = 0
            end
        end
    end
    -- (3 + 2)* n(3334445566)
    if cards.size % 5 == 0 then
        local feijiLength = cards.size / 5
        local length = 0
        for i = 1,20 do
            local cardNum = cards[i]
            if 3 == cardNum then
                length = length + 1
                if feijiLength == length then
                    -- 从i往后到20，所有的牌值对应的数量不能1和3
                    for j = i + 1,20 do
                        local cardNum = cards[j]
                        if 1 == cardNum or 3 == cardNum then
                            return false
                        end
                    end
                    return true -- 后面的牌对应的数量没有出现1和3
                end
            else -- 0 1 2 4
                if 1 == cardNum then -- 当出现数量为1
                    return false
                end
                if length > 0 then -- 之前已经出现了3张
                    return false
                end
            end
        end
    end
    return false
end
--判断是否是炸弹
function Boom(cards)
    if cards.size~=4 then
        return false
    end
    for i=1,20 do
        local cardNum=cards[i]
        if cardNum ==4 then
           return true
        end      
    end
    return false
end
--判断是否是王炸
function BoomBoom(cards)
    if cards.size~=2 then
        return false
    end
    local cardNum1=cards[18]
    local cardnum2=cards[19]
    if cardNum1==1 and cardnum2 ==1 then
        return true
    else
        return false
    end
end
--获取牌的类型
function getCardsType(selectedCards) -- 获取选中牌的类型
    local cards = toCardMap(selectedCards) -- 转为记牌器
    --单张
    if isSingle(cards) then
        return CardsType.Single
    end
    --对子
    if isDuiZi(cards) then
        return CardsType.DuiZi
    end
    --顺子
    if isShunZi(cards) then
        return CardsType.ShunZi
    end
    --连队
    if isLianDui(cards) then
        return CardsType.LianDui
    end
    --三张
    if isThree(cards) then
        return CardsType.Three
    end
    --三带一
    if ThreeTakeOne(cards) then
        return CardsType.ThreeTakeOne
    end
    --三带二
    if ThreeTakeTwo(cards) then
        return CardsType.ThreeTakeTwo
    end
    --四带二
    if FourTakeTwo(cards) then
        return CardsType.FourTakeTwo
    end
    --飞机
    if FeiJi(cards) then
        return CardsType.FeiJi
    end
    --炸弹
    if Boom(cards) then
        return CardsType.Boom
    end
    --王炸
    if BoomBoom(cards) then
        return CardsType.BoomBoom
    end
    --不符合
    return CardsType.None
end
function getCardsPoint(cardss)
    local cards = toCardMap(cardss)
    cardnum = 0
    cardtype = 0
    for i=1,20 do
        if (cardnum<cards[i] and cardtype<i) then
           cardnum = cards[i]
           cardtype = i
        end      
    end
    return cardtype
end
function isCardRight(last,this)
    if(last[1]==this[1] and last[3] == this[3])then
        if(last[2]<this[2])then
            return true
        end
    elseif(this[1]==10)then
        if(last[2]<this[2] or last[1]<this[1])then
            return true
        end
    elseif(this[1]==11)then
        return true
    end
    return false
end
function toCardType(type)
    if(type == 1)then
        return "一张"
    elseif(type == 2)then
        return "一对"
    elseif(type == 3)then
        return "顺子："
    elseif(type == 4)then
        return "连对："
    elseif(type == 5)then
        return "三个"
    elseif(type == 6)then
        return "三带一："
    elseif(type == 7)then
        return "三带二："
    elseif(type == 8)then
        return "四带二："
    elseif(type == 9)then
        return "飞机："
    elseif(type == 10)then
        return "炸弹："
    elseif(type == 11)then
        return "王炸："
    end
end

function cardtoValue(word)
    if(word == "A" or word == "a")then
        point = 0x01
    elseif(word == "2")then
        point = 0x02
    elseif(word == "3")then
        point = 0x03
    elseif(word == "4")then
        point = 0x04
    elseif(word == "5")then
        point = 0x05
    elseif(word == "6")then
        point = 0x06
    elseif(word == "7")then
        point = 0x07
    elseif(word == "8")then
        point = 0x08
    elseif(word == "9")then
        point = 0x09
    elseif(word == "10")then
        point = 0x0a
    elseif(word == "J" or word == "j")then
        point = 0x0b
    elseif(word == "Q" or word == "q")then
        point = 0x0c
    elseif(word == "K" or word == "k")then
        point = 0x0d
    elseif(word == "xw" or word == "xw")then
        point = 0x41
    elseif(word == "dw" or word == "dw")then
        point = 0x42
    else
        point = 0x00
    end
    return getCardValue(point)
end