require("favor.favor_event.favor_special")
require("favor.favor_event.favor_event_trigger")
require("favor.favor_event.favor_event_reply")
require("favor.favor_event.favor_event_outLimitReply")
require("favor.favor_event.FavorEvent")

favorEventList = {
    ["摸头"] = FavorEvent:new("pet", "每天记得摸摸{self}哦", nil, nil, 1, petReply, 5, "躲开≡┏|*´･Д･|┛"),
    ["投喂"] = FavorEvent:new("feed", "每天记得投喂{self}哦", nil, nil, 1, "给我吃的吗？那我就不客气了Ψ(￣∀￣)Ψ", 5, "已经，吃不下了……"),
    ["购物"] = FavorEvent:new("shop", "周末记得带{self}去逛逛街啦~", { week = { 6, 0 } }, "商场还没开门呢……周末再来吧", 2, shopReply, 1, "买这么多东西干什么呢？好好吃饭啦……"),
    ["看日出"] = FavorEvent:new("sunrise", "早上5点，要一起去看日出吗？", { hour = { 5 } }, "还没到日出的时候呢，再等等吧", 1, "春，曙为最[CQ:image,file=favor\\sunrise.png]", 20, "日出，很漂亮呢……"),
    ["吃早餐"] = FavorEvent:new("breakfast", "早餐的黄金时间是7:00-9:00，要记得按时吃早餐哦~", breakfastTrigger, nil, 1, "铛铛~新鲜出炉的面包，趁热吃吧~", 10, "你还想吃几顿早餐呀？"),
    ["茶会"] = FavorEvent:new("teaParty", "每天下午14:00到17:00是茶会时间，记得来参加哦~", teaPartyTrigger, nil, 1, teaPartyReply, 10, teaPartyOutLimitReply),
    ["拔呆毛"] = FavorEvent:new("daimao", "不……不许拔呆毛！", { favor = 5 }, "你想做什么？(σ｀д′)σ（举枪）", 5, "咕啊！我的呆毛(ﾉД`)（已黑化）", -5, "呆毛……呆毛被拔光了……")
}