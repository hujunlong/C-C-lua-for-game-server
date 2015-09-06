local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local config = require('config.global')
local action_id = require('define.action_id')
local assistant_id = require('config.assistant_task_id')
local gold_consume_flag = require('define.gold_consume_flag')
require('data')
require('global_data')
require('assistant')

local online_players = {}
function WorldWarInitialize(all_players)
    online_players = all_players
end

local world_war_processor = {}

world_war_processor[C.kGetPlayerGroup] = function(head, msg)
    local function serialize(t)
        if type(t)~="table" then return tostring(t) end
        
        local mark={}
        local assign={}

        local function ser_table(tbl,parent)
            mark[tbl]=parent
            local tmp={}
            for k,v in pairs(tbl) do
                local key= type(k)=="number" and "["..k.."]" or k
                if type(v)=="table" then
                    local dotkey= parent..(type(k)=="number" and key or "."..key)
                    if mark[v] then
                        table.insert(assign,dotkey.."="..mark[v])
                    else
                        table.insert(tmp, key.."="..ser_table(v,dotkey))
                    end
                elseif type(v)=="number" then
                    table.insert(tmp, key.."="..v)
                end
            end
            return "{"..table.concat(tmp,",").."}"
        end

        return ser_table(t,"ret") .. table.concat(assign," ")
    end
    
    local GetPlayerGroup = cast('const GetPlayerGroup&', msg)
    local heros_group,array = data.GetPlayerHerosGroup(head.aid)
    local str = "do local ret1=" .. serialize(heros_group) .. " ret2=" .. serialize({array=array,sex=data.GetPlayerSex(head.aid)}) .. " return ret1,ret2 end"
    
    if #str<14*1024 then
        local result = new('GetPlayerGroupResult')
        result.id = GetPlayerGroup.id
        result.len = #str
        result.str = str
        
        head.type = result.kType
        C.Send2WorldWar(head, result, 4 + result.len)
    else
        print("serialize too large")
    end
end

world_war_processor[C.kCheckPlayerGold] = function(head, msg)
    local CheckPlayerGold = cast('const CheckPlayerGold&', msg)
    
    local result = new('CheckPlayerGoldResult')
    
    local player = online_players[head.aid]
    if player and player.IsGoldEnough(CheckPlayerGold.gold) then
        player.ConsumeGold(CheckPlayerGold.gold, gold_consume_flag.world_war_clear_cd)
        result.succeed = 1
    else
        result.succeed = 0
    end
    
    head.type = result.kType
    C.Send2WorldWar(head, result, sizeof(result))
end

world_war_processor[C.kAddWorldWarProp] = function(head, msg)
    local AddWorldWarProp = cast('const AddWorldWarProp&', msg)
    
    local result = new('AddWorldWarPropResult')
    local player = online_players[head.aid]
    if player and not player.IsBagFull() then
        player.ModifyProp(AddWorldWarProp.kind, AddWorldWarProp.amount)
        result.succeed = 1
    else
        result.succeed = 0
    end
    
    head.type = result.kType
    C.Send2WorldWar(head, result, sizeof(result))
end

world_war_processor[C.kServerHeartBeat] = function(head, msg)
    local ServerHeartBeat = cast('const ServerHeartBeat&', msg)
    
    local result = new('ServerHeartBeatResult', ServerHeartBeat.verify)
    
    head.type = result.kType
    C.Send2WorldWar(head, result, sizeof(result))
end

world_war_processor[C.kAdvancedGradeResult] = function(head, msg)
    local AdvancedGrade = cast('const AdvancedGradeResult&', msg)
    AdvancedGradeManager(AdvancedGrade)
end

world_war_processor[C.kRemoteMethodCall] = function(head, msg)
    local RemoteMethodCall = cast('const RemoteMethodCall&', msg)
    
    if RemoteMethodCall.method == C.kWorldWarCount1 then
        AssistantCompleteTask4Offline(head.aid, assistant_id.kWorldWar, RemoteMethodCall.value)
    elseif RemoteMethodCall.method == C.kWorldWarCount2 then
        AssistantSetRemainTimes4Offline(head.aid, assistant_id.kWorldWar, RemoteMethodCall.value)
    elseif RemoteMethodCall.method == C.kRewardPrestige then
        ModifyPrestigeByUID(head.aid, RemoteMethodCall.value)
    else
        --
        print("未知国战调用", RemoteMethodCall.method)
    end
end

function PushPlayerChangedToWorldWar(uid, type, value)
    local result = new('PlayerInfoChanged')
    result.type = type
    result.value = value
    
    local head = new('MqHead', uid, result.kType, -1)
    C.Send2WorldWar(head, result, sizeof(result))
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function GetWorldWarServerAddress()
    return config.world_war.address
end

function RegisterWorldWar()
    --注册本服务器到国战服务器

    local ServerInfo = new('ServerInfo')
    local global_flag_head_ = new('MqHead', 0, 0, -1)

    ServerInfo.name = {#config.world_war.name, config.world_war.name}
    global_flag_head_.aid = C.kInvalidID
    global_flag_head_.type = ServerInfo.kType
    C.Send2WorldWar(global_flag_head_, ServerInfo, sizeof(ServerInfo))

    --获取本周国战信息
    local GetAdvancedGrade = new('GetAdvancedGrade')
    global_flag_head_.type = GetAdvancedGrade.kType
    C.Send2WorldWar(global_flag_head_, GetAdvancedGrade, sizeof(GetAdvancedGrade))
end

function ProcessMsgFromWorldWar(h,msg,len)
    local head = cast('MqHead&', h)
    if head.type>C.kWorldWarInnerBegin and head.type<C.kWorldWarInnerEnd then
        --发送给服务器的消息
        local func = world_war_processor[head.type]
        if func then func(head, msg) end
    else
        --转发给玩家
        local player = online_players[head.aid]
        if player then
            C.Send2Gate(head, msg, len)
        end
    end
end

