### 样例模板

```lua
--声明表msg_order,初始化时会遍历plugin文件，读取msg_order表中的指令名
--msg_order中的键值对表示 前缀指令->函数名
msg_order = {}
--声明触发词，允许多个触发词对应一个函数
order_word = "触发词"
order_word_1 = "触发词1"
order_word_2 = "触发词2"
--声明指令函数主体，函数名可自定义
function custom_order(msg)
    return "回复语句"
end
msg_order[order_word] = "custom_order"	--value为字符串格式且与指令函数名一致
msg_order[order_word_1] = "custom_order"
msg_order[order_word_2] = "custom_order"
--注意：本手册所提供脚本样例并非固定，仅基于模板化考虑选定该格式。
```

### 文件的字符编码问题

**除lua/js外的文件一律请以utf8编码。**

Windows系统一般使用GBK字符集。Dice!支持utf-8及GBK两种字符集的lua文件，在读写字符串时将自动检测utf-8编码并转换。而出现以下情况时，编码并非二者皆可：

- lua文件相互调用或读写其他文本文件，且字符串含有非ASCII字符时，**关联文件字符集应保持一致**；
- lua文件中需要调用http函数时，**应当与目标网页的编码一致（基本是UTF8）**
- lua文件使用require或os等以文件名为参数的函数，且路径含有非ASCII字符时，**必须使用GBK**；

### loadLua(scriptName)

运行Lua文件，返回目标脚本的返回值
参数使用相对路径且无后缀，根目录为plugin文件夹*(build575+)*或mod内script文件夹*(build575+)*
与Lua自带的require函数不同，目标文件定义的变量会保持生命周期

```lua
loadLua("PC/COC7")
```
输入参数 | 变量类型 | 说明
------- | -------- | --------
lua文件名 | string | 待调用mod/script/文件或plugin/文件

返回值类型 | 说明
--------- | --------
同文件内返回值类型 | 执行指定文件后的返回值

### ranint(low,high)

取随机数
输入参数 | 变量类型 | 说明
------- | -------- | --------
随机区间下限 | number | 整数
随机区间上限 | number | 整数

返回值类型 | 说明
--------- | --------
number | 生成随机数

### getDiceQQ()

取DiceMaid自身账号
返回值类型 | 说明
--------- | --------
string | 取骰子自身账号

### getDiceDir()

取Dice存档目录，用于自行读写文件
返回值类型 | 说明
--------- | --------
string | 取Dice存档目录

### eventMsg(msg, gid, uid)

虚构一条消息进行处理，不计入指令频度。可使用参数列表`eventMsg(msg, gid, uid)`或*(build608+)*参数包形式`eventMsg(pkg)`.

```lua
eventMsg(".rc Rider Kick:70 踢西鹿", msg.gid, msg.uid)
eventMsg({
        fromMsg = ".rc Rider Kick:70 踢西鹿",
        gid = msg.gid,
        uid = msg.uid,
})
```
输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
消息文本/fromMsg | string | 
来源群/gid | number | 可以为空
发送者/uid | number | 

### sendMsg(msg, gid, uid)

可使用参数列表`sendMsg(msg, gid, uid)`或*(build619+)*参数包形式`sendMsg(pkg)`发送.

```lua
sendMsg("早安哟", msg.fromGroup, msg.fromQQ)
```
输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
fwdMsg | string | 待发送消息
gid | number | 私聊时为空
uid | number | 群聊时可以为空
chid | number | 频道id，仅参数包可用

### getUserToday(userID, keyConf, defaultVal)

取用户今日数据项。特别地，配置项为"jrrp"时，所取值同`.jrrp`结果。所有当日数据会在系统时间24时清空。

```lua
getUserToday(msg.uid, "jrrp")
```
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
配置项 | string | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值，为空则返回0

返回值类型 | 说明
--------- | --------
任意 | 待取值

### setUserToday(userID, keyConf, val)

存用户今日数据项

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
配置项 | string | 待存配置项
配置值 | 任意 | 待存入数据

### getUserConf(userID, keyConf, defaultVal)

取用户配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*参数1可以为空，此时遍历所有**记录了该属性**的用户并返回以账号=属性值为键值对的table。

```lua
getUserConf(msg.fromQQ, "favor", 0)
getUserConf(nil, "favor") --返回所有用户的favor列表
```
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
配置项 | string | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值

特殊配置项 | 说明
--------- | --------
trust | 用户信任（仅4以下可编辑）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
name* | 用户账号昵称（只读）
nick* | 全局称呼（备取账号昵称）
nick#`群号`* | 特定群内的称呼（备取群名片->全局称呼->账号昵称）
nn* | 全局nn
nn#`群号`* | 特定群内的nn


### setUserConf(userID, keyConf, val)

存用户配置项
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
配置项 | string | 待存配置项
配置值 | 任意 | 待存入数据

### getGroupConf(groupID, keyConf, defaultVal)

取群配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*群号可以为空，此时遍历所有**记录了该属性**的群并返回以群号=属性值为键值对的table。

```lua
getGroupConf(msg.fromQQ, "rc房规", 0)
```
输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | number | 
配置项 | string | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值

特殊配置项 | 说明
--------- | --------
name* | 群名称（只读）
size* | 群人数（只读）
maxsize* | 群规模（只读）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
members | 群用户列表
admins | 群管理列表
card#`群员账号`* | 群名片
auth#`群员账号`* | 群权限（只读） 1-群员;2-管理;3-群主
lst#`群员账号`* | 最后发言时间（只读） [时间戳，秒]

### setGroupConf(groupID, keyConf, val)

存群配置项
输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | number | 
配置项 | string | 待存配置项
配置值 | 任意 | 待存入数据

### getPlayerCard(userID, groupID)

取指定群内绑定的角色卡（整张）
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
群号 | string | 为空或未绑定则取默认卡

### getPlayerCardAttr(userID, groupID, keyAttr, defaultVal)

取角色卡属性

```lua
getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "理智", val_default)
```
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
群号 | number | 
属性名 | string | 待取属性
候补值 | 任意 | 属性不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取属性

### setPlayerCardAttr(userID, groupID, keyConf, val)

存角色卡属性
输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | number | 
群号 | number | 
属性名 | string | 待存属性
属性值 | 任意 | 待存数据

### mkDirs(pathDir)

输入参数 | 变量类型 | 说明
------- | -------- | --------
文件夹路径 | string | 递归创建该文件夹

### sleepTime(ms)
输入参数 | 变量类型 | 说明
------- | -------- | --------
等待毫秒数 | number | 

### http

*(build590+)*

#### http.get

输入参数 | 变量类型 | 说明
------- | -------- | --------
待访问url | string | 若含须转义字符须用urlEncode转义

返回值 | 变量类型 | 说明
----- | -------- | --------
连接是否成功 | boolean | 
网页返回内容 | string | 访问失败则返回错误原因

#### http.post

输入参数 | 变量类型 | 说明
------- | -------- | --------
待访问url | string | 若含须转义字符须用urlEncode转义
post数据 | string | (build634+)如为table则自动序列化为json格式
header | string | (build606+)可省略，默认Content-Type: application/json，(build629+)如为table将自动拼接

返回值 | 变量类型 | 说明
----- | -------- | --------
连接是否成功 | boolean | 
网页返回内容 | string | 访问失败则返回错误原因

#### http.urlEncode

将url中须转义的字符进行转义。

输入参数 | 变量类型 | 说明
------- | -------- | --------
待编码url | string | 

返回值 | 变量类型 | 说明
----- | -------- | --------
编码后url | string | 

#### http.urlDecode

还原url中转义的字符。

输入参数 | 变量类型 | 说明
------- | -------- | --------
待解码url | string | 

返回值 | 变量类型 | 说明
----- | -------- | --------
解码后url | string | 

## 附录：Dice预置JavaScript原型及全局函数

*(build640+)*

### Actor原型

*(build644+)* **角色卡Actor**。

#### rollDice(exp)

调用角色卡的默认骰*(__DefaultDice)*及默认掷骰表达式*(__DefaultDiceExp)*进行掷骰，返回table记录掷骰结果。

输入参数 | 变量类型 | 说明
------- | -------- | --------
掷骰表达式 | string | 

返回值字段 | 字段类型 | 说明
--------- | -------- | --------
expr | String | 规范化后的表达式
sum | Number | 掷骰结果（表达式合法时）
expansion | String | 掷骰展开式（表达式合法时）
error | Number | 错误类型（表达式非法时）

### log(info[,notice_level])

发送日志

输入参数 | 变量类型 | 说明
------- | -------- | --------
日志内容 | String | 待输出日志内容
通知窗口级别 | Number | 选填，若空则只输出到框架日志界面

### getDiceID()

取DiceMaid自身账号

返回值类型 | 说明
--------- | --------
Number | 取骰子自身账号

### getDiceDir()

取Dice存档目录，用于自行读写文件

返回值类型 | 说明
--------- | --------
String | 取Dice存档目录

### eventMsg(msg, gid, uid)

虚构一条消息进行处理，不计入指令频度。可使用参数列表`eventMsg(msg, gid, uid)`或*(build608+)*参数包形式`eventMsg(pkg)`.

```lua
eventMsg(".rc Rider Kick:70 踢", msg.gid, msg.uid)
eventMsg({
        fromMsg = ".rc Rider Kick:70 踢",
        gid = msg.gid,
        uid = msg.uid,
})
```

输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
消息文本/fromMsg | String | 
来源群/gid | Number | 可以为空
发送者/uid | Number | 

### sendMsg(msg, gid, uid)

可使用参数列表`sendMsg(msg, gid, uid)`或*(build619+)*参数包形式`sendMsg(pkg)`发送.

```lua
sendMsg("早安哟", msg.fromGroup, msg.fromQQ)
```

输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
fwdMsg | String | 待发送消息
gid | Number | 私聊时为空
uid | Number | 群聊时可以为空
chid | Number | 频道id，仅参数包可用

### getUserToday(userID, keyConf, defaultVal)

取用户今日数据项。特别地，配置项为"jrrp"时，所取值同`.jrrp`结果。所有当日数据会在系统时间24时清空。

```lua
getUserToday(msg.uid, "jrrp")
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值，为空则返回0

返回值类型 | 说明
--------- | --------
任意 | 待取值

### setUserToday(userID, keyConf, val)

存用户今日数据项

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据

### getUserAttr(userID, keyConf, defaultVal)

取用户配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*参数1可以为空，此时遍历所有**记录了该属性**的用户并返回以账号=属性值为键值对的table。

```lua
getUserConf(msg.fromQQ, "favor", 0)
getUserConf(nil, "favor") --返回所有用户的favor列表
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值


特殊配置项 | 说明
--------- | --------
trust | 用户信任（仅4以下可编辑）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
name | *用户账号昵称（只读）
nick | *全局称呼（备取账号昵称）
nick#`群号` | *特定群内的称呼（备取群名片->全局称呼->账号昵称）
nn | *全局nn
nn#`群号` | *特定群内的nn


### setUserAttr(userID, keyConf, val)

存用户配置项

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据

### getGroupAttr(groupID, keyConf, defaultVal)

取群配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*群号可以为空，此时遍历所有**记录了该属性**的群并返回以群号=属性值为键值对的table。

```lua
getGroupConf(msg.fromQQ, "rc房规", 0)
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值

特殊配置项 | 说明
--------- | --------
name | *群名称（只读）
size | *群人数（只读）
maxsize | *群规模（只读）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
members | 群用户列表
admins | 群管理列表
card#`群员账号` | *群名片
auth#`群员账号` | *群权限（只读） 1-群员;2-管理;3-群主
lst#`群员账号` | *最后发言时间（只读） [时间戳，秒]

### setGroupAttr(groupID, keyConf, val)

存群配置项

输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据

## 附录：Dice预置Python类及模块函数

*(build639+)*Dice!2.7.0总计预置dicemaid模块19条函数，4条context方法。dicemaid模块已在初始化时import，故可以如全局函数般调用。

### Actor类

*(build644+)* **角色卡Actor**。

#### rollDice(exp)

调用角色卡的默认骰*(__DefaultDice)*及默认掷骰表达式*(__DefaultDiceExp)*进行掷骰，返回table记录掷骰结果。

输入参数 | 变量类型 | 说明
------- | -------- | --------
掷骰表达式 | string | 

返回值字段 | 字段类型 | 说明
--------- | -------- | --------
expr | String | 规范化后的表达式
sum | Number | 掷骰结果（表达式合法时）
expansion | String | 掷骰展开式（表达式合法时）
error | Number | 错误类型（表达式非法时）

### log(info[,notice_level])

发送日志

输入参数 | 变量类型 | 说明
------- | -------- | --------
日志内容 | String | 待输出日志内容
通知窗口级别 | Number | 选填，若空则只输出到框架日志界面

### getDiceID()

取DiceMaid自身账号

返回值类型 | 说明
--------- | --------
Number | 取骰子自身账号

### getDiceDir()

取Dice存档目录，用于自行读写文件

返回值类型 | 说明
--------- | --------
String | 取Dice存档目录

### eventMsg(msg, gid, uid)

虚构一条消息进行处理，不计入指令频度。可使用参数列表`eventMsg(msg, gid, uid)`或*(build608+)*参数包形式`eventMsg(pkg)`.

```lua
eventMsg(".rc Rider Kick:70 踢", msg.gid, msg.uid)
eventMsg({
        fromMsg = ".rc Rider Kick:70 踢",
        gid = msg.gid,
        uid = msg.uid,
})
```

输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
消息文本/fromMsg | String | 
来源群/gid | Number | 可以为空
发送者/uid | Number | 


### sendMsg(msg, gid, uid)

可使用参数列表`sendMsg(msg, gid, uid)`或*(build619+)*参数包形式`sendMsg(pkg)`发送.

```lua
sendMsg("早安哟", msg.fromGroup, msg.fromQQ)
```

输入参数/pkg子项 | 变量类型 | 说明
---------------- | -------- | --------
fwdMsg | String | 待发送消息
gid | Number | 私聊时为空
uid | Number | 群聊时可以为空
chid | Number | 频道id，仅参数包可用


### getUserToday(userID, keyConf, defaultVal)

取用户今日数据项。特别地，配置项为"jrrp"时，所取值同`.jrrp`结果。所有当日数据会在系统时间24时清空。

```lua
getUserToday(msg.uid, "jrrp")
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值，为空则返回0


返回值类型 | 说明
--------- | --------
任意 | 待取值


### setUserToday(userID, keyConf, val)

存用户今日数据项

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据


### getUserAttr(userID, keyConf, defaultVal)

取用户配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*参数1可以为空，此时遍历所有**记录了该属性**的用户并返回以账号=属性值为键值对的table。

```lua
getUserConf(msg.fromQQ, "favor", 0)
getUserConf(nil, "favor") --返回所有用户的favor列表
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值

特殊配置项 | 说明
--------- | --------
trust | 用户信任（仅4以下可编辑）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
name | *用户账号昵称（只读）
nick | *全局称呼（备取账号昵称）
nick#`群号` | *特定群内的称呼（备取群名片->全局称呼->账号昵称）
nn | *全局nn
nn#`群号` | *特定群内的nn

### setUserAttr(userID, keyConf, val)

存用户配置项

输入参数 | 变量类型 | 说明
------- | -------- | --------
用户账号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据


### getGroupAttr(groupID, keyConf, defaultVal)

取群配置，配置项带\*标记表示会另行计算而非调用存储数据。*(build613+)*群号可以为空，此时遍历所有**记录了该属性**的群并返回以群号=属性值为键值对的table。

```lua
getGroupConf(msg.fromQQ, "rc房规", 0)
```

输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | Number | 
配置项 | String | 待取配置项
候补值 | 任意 | 配置项不存在时返回该值

返回值类型 | 说明
--------- | --------
任意 | 待取值

特殊配置项 | 说明
--------- | --------
name | *群名称（只读）
size | *群人数（只读）
maxsize | *群规模（只读）
firstCreate | 用户记录创建（初次使用）时间 [时间戳，秒]
lastUpdate | 用户记录最后更新时间 [时间戳，秒]
members | 群用户列表
admins | 群管理列表
card#`群员账号` | *群名片
auth#`群员账号` | *群权限（只读） 1-群员;2-管理;3-群主
lst#`群员账号` | *最后发言时间（只读） [时间戳，秒]

### setGroupAttr(groupID, keyConf, val)

存群配置项

输入参数 | 变量类型 | 说明
------- | -------- | --------
群号 | Number | 
配置项 | String | 待存配置项
配置值 | 任意 | 待存入数据

## 附录：自定义指令常用的Lua正则匹配

解析参数时，可使用`msg.suffix`来略过指令前缀匹配的部分，从之后的字符开始匹配。

```lua
--前缀匹配且指令参数为消息余下部分时，去除前后两端的空格
local rest = msg.suffix:match("^[%s]*(.-)[%s]*$")

--指令参数为单项整数时，直接用%d+表示匹配一个或多个数字，未输入数字时匹配失败返回nil
local cnt = string.match(msg.suffix,"%d+")

--同上，%d*表示匹配0或任意个数字，未输入数字时匹配成功返回空字符串""
--该匹配模式需要确保数字之前的其他字符已被排除
local cnt = string.match(msg.suffix,"%d*")

--参数使用空格分隔且不限数目，遍历匹配
local item,rest = "",string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#order_select_name+1)
if(rest == "")then
    return "请输入参数"
end
local items = {}
repeat
    item,rest = string.match(rest,"^([^%s]*)[%s]*(.-)$")
    table.insert(items, item)
until(rest=="")
