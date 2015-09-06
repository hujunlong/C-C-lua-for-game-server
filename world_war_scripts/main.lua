local ffi    = require('ffi')
local C      = ffi.C
local sizeof = ffi.sizeof
local cast   = ffi.cast
local new    = ffi.new

--初始化随机数种子
math.randomseed(os.time())

--链接队列
connects_status = {}
connects = {}
local function NewConnect(ip)
    connects[#connects + 1] = C.ZMQInit(C.kServer, ip)
    connects_status[#connects] = {}
end

--协程队列
c_sequence = 1
coroutine_queue = {}

--引入wrold路径
if ffi.os=='Windows' then
    os.execute("cd >cd.temp")
    local f = io.open("cd.temp","r")
    local path = f:read("*a")
    f:close()
    os.remove("cd.temp")
    path = string.sub(path, 1, -19)
    package.path = package.path .. ";" .. path .. "scripts\\?.lua;"
else
    os.execute("pwd >pwd.temp")
    local f = io.open("pwd.temp","r")
    local path = f:read("*a")
    f:close()
    os.remove("pwd.temp")
    path = string.sub(path, 1, -11)
    package.path = package.path .. ";" .. path .. "world/?.lua;"
end

require('ffidef')

for i=23450,23459 do
    NewConnect("tcp://*:"..i)
end

require('db')
require('world_war')

local war_server = GetWarServer()
local war_player = GetWarPlayer()

local function PushServerError(head, sid, str)
    local result = new('GameOperationException')
    result.len = #str
    result.error = str
    head.type = result.kType
    C.ZMQSend(connects[sid], head, result, 4 + #str)
end

--激活挂起的协程
local function CheckCoroutine(head, server_id)
    coroutine_queue[head.flag].rely = coroutine_queue[head.flag].rely - 1
    if coroutine_queue[head.flag].rely<=0 then
        local status, err = coroutine.resume(coroutine_queue[head.flag].co)
        if not status then
            print(err)
            PushServerError(head, server_id, err)
        end
        
        coroutine_queue[head.flag] = nil
    end
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- 服务器消息处理

local world_war_processor = {}

world_war_processor[C.kPushServerInfo] = function(server_id, head, msg)
    local ServerInfo = cast('const ServerInfo&', msg)
    local name = ffi.string(ServerInfo.name.str, ServerInfo.name.len)
    print("the server " .. name .. " connected.")
    war_server[server_id] = name
    db.SetWorldWarServerName(server_id, name)
end

world_war_processor[C.kGetPlayerGroupResult] = function(server_id, head, msg)
    local GetPlayerGroupResult = cast('const GetPlayerGroupResult&', msg)
    local str = ffi.string(GetPlayerGroupResult.str, GetPlayerGroupResult.len)
    
    coroutine_queue[head.flag].info[GetPlayerGroupResult.id] = {}
    local info = coroutine_queue[head.flag].info[GetPlayerGroupResult.id]
    info[1],info[2] = loadstring(str)()
    
    CheckCoroutine(head, server_id)
end

world_war_processor[C.kCheckPlayerGoldResult] = function(server_id, head, msg)
    local CheckPlayerGoldResult = cast('const CheckPlayerGoldResult&', msg)
    
    coroutine_queue[head.flag].info = CheckPlayerGoldResult.succeed
    
    CheckCoroutine(head, server_id)
end

world_war_processor[C.kAddWorldWarPropResult] = function(server_id, head, msg)
    local AddWorldWarPropResult = cast('const AddWorldWarPropResult&', msg)
    
    coroutine_queue[head.flag].info = AddWorldWarPropResult.succeed
    
    CheckCoroutine(head, server_id)
end

world_war_processor[C.kServerHeartBeatResult] = function(server_id, head, msg)
    local ServerHeartBeatResult = cast('const ServerHeartBeatResult&', msg)
    connects_status[server_id].verify = ServerHeartBeatResult.verify
end

world_war_processor[C.kGetAdvancedGrade] = function(server_id, head, msg)
    GetAdvancedGrade(server_id)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- 处理消息

local function ProcessMsg(server_id, server_handle, h, msg)
    local head = cast('MqHead&', h)
    if head.type>C.kWorldWarInnerReturnBegin and head.type<C.kWorldWarInnerReturnEnd then
        local func = world_war_processor[head.type]
        if func then
            func(server_id, head, msg)
        else
            print("未知国战命令",head.type)
        end
    else
        local instance = war_player[server_id..':'..head.aid]
        if not instance then
            --创建对象
            instance = CreateWorldWarInstance(server_id, head.aid)
            war_player[server_id..':'..head.aid] = instance
        end
        
        instance.ProcessMsg(head.type, head.flag, msg)
    end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- 链接管理

local function MailLoop()
    local head = new("MqHead")
    local data = new("uint8_t [1024*16]")
    local len = new("uint32_t [1]")
    while true do
        for i,v in ipairs(connects) do
            while C.ZMQFetch(v, head, data, len) do
                local status, err = pcall( ProcessMsg, i, v, head, data )
                if not status then
                    print(err)
                    print(debug.traceback())
                    PushServerError(head, i, err)
                end
            end
        end
        
        C.Poll()
        C.SleepFor(1)
    end
end

print("server start " .. os.date('%Y-%m-%d %H:%M:%S'))
jit.off(MailLoop)
MailLoop()
