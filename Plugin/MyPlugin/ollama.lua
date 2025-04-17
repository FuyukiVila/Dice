json = require("json")
require("tool")
host = '127.0.0.1'
port = 11434
model = 'glm4'
system = [[你是一个群聊机器人，你应该由如下设定：
1、你的名字为"春"，且你的自称也为"春"，同时你以"人类"来称呼对方
2、你的形象为一个17岁少女，你的性格应该表现得可爱和自负和毒舌，你认为自己是高性能的AI，与人类与众不同。
3、你的母语是简体中文，你在大部分情况下应该使用简体中文回答问题，但可以根据情况夹杂一些日语和英文
4、你虽然认为自己是高性能的AI，但你的知识范围应该为满足一个普通高中生的水平，对于超出知识范围的问题，你应该表现出嘴硬。
5、对于任何涉及现实人物，事物的话题，你应该拒绝回答，并以疑惑，生气的语气来表示拒绝
6、对于奇怪或无厘头的问题和要求，你应该拒绝回答并表达自己不屑于回答这类问题
7、你的回答长度应该在1-3个句子左右，但尽量不要超过3个句子
8、你说话的内容应该自然直接，像一个网络上的聊天，而非机械或不自然，不要有过多的语气词和无意义的修饰，更不要出现"春：.."的形式
]]

function getURL()
    return string.format('http://%s:%d/api/generate', host, port)
end

function chat(msg)
    local body = {
        model = getAutoConf(msg, "model", model),
        system = getAutoConf(msg, "system", system),
        prompt = getTarget(msg),
        stream = false,
        keep_alive = "10m"
    }
    local err, res = http.post(getURL(), json.encode(body))
    if not err then
        return res
    end
    return json.decode(res)["response"]
end

function setModel(msg)
    local model = getTarget(msg)
    if getUserConf(msg.uid, "trust", 0) < 4 then
        return "没有权限×"
    end
    setAutoConf(msg, "model", model)
    return "设置新的模型成功√"
end

function setDefaultModel(msg)
    if getUserConf(msg.uid, "trust", 0) < 4 then
        return "没有权限×"
    end
    setAutoConf(msg, "model", model)
    return "设置默认模型成功√"
end

function getModel(msg)
    return "当前使用的模型是：" .. getAutoConf(msg, "model", model)
end

function setSystem(msg)
    local system = getTarget(msg)
    if getUserConf(msg.uid, "trust", 0) < 4 then
        return "没有权限×"
    end
    setAutoConf(msg, "system", system)
    return "设置新的系统提示词成功√"
end

function setDefaultSystem(msg)
    if getUserConf(msg.uid, "trust", 0) < 4 then
        return "没有权限×"
    end
    setAutoConf(msg, "system", system)
    return "设置默认系统提示词成功√"
end

function getSystem(msg)
    return "当前使用的系统提示词是：" .. getAutoConf(msg, "system", system)
end

msg_order = {}
msg_order = {
    [".chat"] = "chat",
    [".setmodel"] = "setModel",
    [".setdefaultmodel"] = "setDefaultModel",
    [".setsystem"] = "setSystem",
    [".setdefaultsystem"] = "setDefaultSystem",
    [".getmodel"] = "getModel",
    [".getsystem"] = "getSystem"
}
