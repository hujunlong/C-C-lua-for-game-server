local ffi    = require('ffi')
local C      = ffi.C
local sizeof = ffi.sizeof
local new    = ffi.new
local cast   = ffi.cast
local copy   = ffi.copy

require('db')

local config = require('config.world_war_config')
local world_war_vip = require('config.world_war_vip')
local world_war_rank = require('config.world_war_rank')

local war_player = GetWarPlayer()
local war_map = GetWarMap()
local war_top = GetWarTop()
local war_info = GetWarInfo()
local war_running = GetWarRunning()
local war_history = GetWarHistory()
local war_location = GetWarLocation()
local war_server = GetWarServer()
local war_rank = GetWarRank()
local war_wait = GetWarWait()
local grade_top  = GetGradeTop()

--
local function ConvertString2time(strTime)
    local date = os.date("*t", os.time())

    local colon = string.find(strTime, ":")
    local hour = string.sub(strTime, 0, colon - 1)
    local min = string.sub(strTime, colon + 1)

    return os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min})
end

--判断时间是否跨天
local function IsTimeInSameDay(time, strtime)
    return ConvertString2time(strtime) - time <= 60*60*24
end

--获取时间差，忽略天数
local function time_to_time(strTime)
    
    local time = ConvertString2time(strTime) - os.time()
    
    if time<=0 then time = time + 60*60*24 end
    return time
end

function CreateWaitableTimer(type, strtime, callback)
    local obj = {}
    local timer = nil
    
    function obj.timer()
        C.StopTimer(timer)
        db.SetWorldWarStatus(type, ConvertString2time(strtime))
        callback()
        obj.start()
    end
    
    function obj.start()
        local last_time = db.GetWorldWarStatus(type)
        if not IsTimeInSameDay(last_time, strtime) then
            db.SetWorldWarStatus(type, ConvertString2time(strtime))
            callback(true)
        end
        --准备下次开始
        local next_time = time_to_time(strtime)
        
        if not timer then
            timer = ffi.CreateTimer(obj.timer, next_time)
        else
            C.ResetTimer(timer, next_time)
        end
    end
    
    return obj.start()
end

--创建整点Timer
function CreatePunctualTimer(callback)
    local obj = {}
    local timer = nil
    
    local function GetNextPunctualTime()
        return math.ceil( (os.time() + 1) / 3600 ) * 3600
    end
    function obj.timer()
        C.StopTimer(timer)
        callback()
        obj.start()
    end
    
    function obj.start()
        local next_time = GetNextPunctualTime() - os.time()
        
        if not timer then
            timer = ffi.CreateTimer(obj.timer, next_time)
        else
            C.ResetTimer(timer, next_time)
        end
    end
    
    return obj.start()
end

--创建半个小时的Timer
--[[
function CreateHalfTimer(callback)
    local obj = {}
    local timer = nil
    
    local function GetNextHalfTime()
        return math.ceil( (os.time() + 1) / 1800 ) * 1800
    end
    function obj.timer()
        C.StopTimer(timer)
        callback()
        obj.start()
    end
    
    function obj.start()
        local next_time = GetNextHalfTime() - os.time()
        
        if not timer then
            timer = ffi.CreateTimer(obj.timer, next_time)
        else
            C.ResetTimer(timer, next_time)
        end
    end
    
    return obj.start()
end
]]

--插入战事回报
function InsertRecord(news)
    local max_history = #war_history==0 and 1 or war_history[#war_history].history + 1
    news.history = max_history
    table.insert(war_history, news)
    
    db.InsertWorldWarRecord(news)
    
    --清除多余的历史记录
    if #war_history>18 then
        db.DeleteWorldWarRecord(table.remove(war_history, 1).history)
    end
end

--发送玩家战斗信息请求
function RequestPlayerGroup(sid, uid, sequence, id)
    local GetPlayerGroup = new('GetPlayerGroup')
    GetPlayerGroup.id = id
    local GetPlayerGroupHead = new('MqHead', uid, GetPlayerGroup.kType, sequence)
    C.ZMQSend(connects[sid], GetPlayerGroupHead, GetPlayerGroup, sizeof(GetPlayerGroup))
end

--远程方法调用
function RequestRemoteMethodCall(sid, uid, method, value)
    local RemoteMethodCall = new('RemoteMethodCall')
    RemoteMethodCall.value = value
    RemoteMethodCall.method = method
    local RemoteMethodCallHead = new('MqHead', uid, RemoteMethodCall.kType, -1)
    C.ZMQSend(connects[sid], RemoteMethodCallHead, RemoteMethodCall, sizeof(RemoteMethodCall))
end

--最近的复活点
function GetRebornLocation(map, pos, attcak, camp)
    for _,v in ipairs(war_map[map].locations[pos].reborns) do
        if war_map[map].locations[v.location].country==camp then
            return v.location
        end
    end
    print("GetRebornLocation error")
    if attcak then
        return war_map[map].attack_born_location
    else
        return war_map[map].defend_born_location
    end
end

--Rank算法
function GetNewRank(Ra, Rb, win)
    local Ea = 1/(1 + 10^((Rb-Ra)/400) )
    local k = Ra<1500 and 96 or 32
    local trim = win==1 and math.floor or math.ceil
    local delta = trim( k * ( win - Ea) )
    return math.max(Ra + delta, 0), math.max(Rb - delta, 0)
end

--胜利后获得积分
local rank_score = {}
for k,v in pairs(world_war_rank) do
    rank_score[#rank_score + 1] = {rank=k,score=v.score}
end

table.sort(rank_score, function(a,b) return a.rank<b.rank end)

function GetScoreByRank(rank)
    for i,v in ipairs(rank_score) do
        if rank<v.rank then
            return rank_score[i - 1].score
        end
    end

    return rank_score[#rank_score].score
end

--针对国家贡献排序
function SortScore(a,b)
    local _info_a = war_info[a.server][a.player]
    local _info_b = war_info[b.server][b.player]
    if _info_a.score == _info_b.score then
        if _info_a.level == _info_b.level then
            if a.server == b.server then
                return a.player < b.player
            end
            
            return a.server < b.server
        end
        
        return _info_a.level > _info_b.level
    end
    
    return _info_a.score > _info_b.score
end

--针对Rank值排序
function SortRank(a,b)
    local _info_a = war_info[a.server][a.player]
    local _info_b = war_info[b.server][b.player]
    
    if _info_a.rank == _info_b.rank then
        return SortScore(a,b)
    end
    
    return _info_a.rank > _info_b.rank
end

--寻找敌对玩家
function GetRankTarget(sid, uid, camp)
    local function BuildTargets(rank)
        local targets = {}
        local top = rank - 1
        local low = rank + 1
        
        while war_rank[top] or war_rank[low] do
            
            if war_rank[top] then targets[#targets + 1] = top end
            if war_rank[low] then targets[#targets + 1] = low end
            
            top = top - 1
            low = low + 1
        end
        
        return targets
    end
    
    --对排名排序
    table.sort(war_rank, SortRank)
    local rank = nil
    for i,v in ipairs(war_rank) do
        if v.server==sid and v.player==uid then
            rank = i
            break
        end
    end
    
    --
    if not rank then return end
    
    local target_player = {}
    
    for _,i in ipairs(BuildTargets(rank)) do
        if connects_status[war_rank[i].server].connect and war_info[war_rank[i].server][war_rank[i].player].camp==camp then
            target_player[#target_player + 1] = {sid=war_rank[i].server, uid=war_rank[i].player}
            
            if #target_player>=5 then break end
        end
    end
    
    return target_player[ math.random(1, #target_player) ]
end

--获取清除CD需要的金币        
function GetCDCost(time)
    local min = math.ceil( (time - os.time())/60 )
    
    if min<=0 then return 0 end
    if min<10 then return 2 end
    if min<25 then return 4 end
    if min<40 then return 6 end
    if min<50 then return 8 end
    return 10
end

--最短路径
local function ShortestPath(graph, src)
    local INF = 1/0         --无穷大
    
    local function ExtractMin(dist, path)
        local minDist = INF
        local nearest = nil
        for v,_ in pairs(path) do
            if dist[v] < minDist then
                minDist = dist[v]
                nearest = v
            end
        end
        return nearest
    end
    
    local dist = {}        --距离
    local prev = {}        --路径如何到达
    local path = {}        --已经完成扫描的路径
    
    for i in pairs(graph) do
        path[i] = true
        dist[i] = INF        --不可到达
    end
    
    dist[src] = 0
    
    while true do
        local u = ExtractMin(dist, path)
        if not u then break end
        
        path[u] = nil
        for _,v in ipairs(graph[u].adjacent_locations) do
            local alt = dist[u] + 1
            if not dist[v] or (alt < dist[v]) then
                dist[v] = alt
                prev[v] = u
            end
        end
    end
    
    return dist     --return dist, prev
end

function InitWorldWarMap(maps)
    for _,map in pairs(maps) do
        if map.locations then
            --需要加入的数据
            map.count = 0
            map.attack_born_location = nil
            map.defend_born_location = nil
            map.reborn_locations = {}
            
            --找出出生点、复活点
            for k,location in pairs(map.locations) do
                if location.born then
                    if location.default==0 then
                        --1攻方
                        map.attack_born_location = k
                    else
                        --0守方
                        map.defend_born_location = k
                    end
                else
                    map.count = map.count + 1
                end
                
                if location.reborn then
                    map.reborn_locations[#map.reborn_locations + 1] = k
                end
            end
            
            --给出最近的复活点
            for k,location in pairs(map.locations) do
                local dist = ShortestPath(map.locations, k)
                
                --找出每个点的距离
                location.dist = dist
                
                location.reborns = {}
                for _,reborn in ipairs(map.reborn_locations) do
                    --if reborn~=k then
                    location.reborns[#location.reborns + 1] = {}
                    location.reborns[#location.reborns].location = reborn
                    location.reborns[#location.reborns].distance = dist[reborn]
                    --end
                end
                
                table.sort(location.reborns, function(a, b) return a.distance < b.distance end)
            end
        end
    end
end
InitWorldWarMap(war_map)

--是否可购买的道具
function IsCanBuyProp(map, camp)
    if map==1 then return true end
    
    return war_map[map].country==camp
end

--通知路点改变
function NotifyLocationChange(map, info)
    local result = new('WorldWarLocationChange')
    result.map = map
    result.location1 = info.location1
    result.location2 = info.location2
    result.progress = info.progress
    result.country = war_map[map].locations[info.location1].country + 10 * war_map[map].locations[info.location2].country
    
    local LocationChangeHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            if v.map==map then
                LocationChangeHead.aid = uid
                C.ZMQSend(connects[sid], LocationChangeHead, result, sizeof(result))
            end
        end
    end
end

--通知大地图改变
function NotifyMapChange(map)
    local result = new('WorldWarMapChange')
    result.map = map
    result.attack = war_running[map].attack
    result.defend = war_running[map].defend
    result.progress = math.floor( 100 * war_running[map].progress / war_map[map].count + 0.5 )
    
    local MapChangeHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            --if v.map==map then
                MapChangeHead.aid = uid
                C.ZMQSend(connects[sid], MapChangeHead, result, sizeof(result))
            --end
        end
    end
end

--通知路点传送
function NotifyLocationTransmit(map, location)
    local function GetNearestLocaiton(locations)
        local min = nil
        local index = nil
        for i,v in ipairs(locations) do
            local dist = war_map[map].locations[location].dist[v.location]
            if not min or min>dist then
                min = dist
                index = i
            end
        end
        
        return index
    end
    
    local result = new('LocationTransmit')
    result.map = map
    
    local LocationTransmitHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            if v.map==map then
                local flag = false
                
                --玩家所处路点被攻陷
                if v.pos==location then
                    result.reason = 0
                    
                    local locations = GetFightLocations(v.map, war_info[sid][uid].camp)
                    local index = GetNearestLocaiton(locations)
                    
                    if index then
                        result.target = locations[index].target
                        result.location = locations[index].location
                        
                        flag = true
                    end
                end
                
                --玩家目标点被攻破
                if v.loc==location then
                    result.reason = 1
                    
                    local locations = GetFightLocations(v.map, war_info[sid][uid].camp)
                    local index = GetNearestLocaiton(locations)
                    
                    if index then
                        result.target = locations[index].target
                        result.location = locations[index].location
                        
                        flag = true
                    end
                end
                
                if flag then
                    v.loc = result.target
                    v.pos = result.location
                    
                    LocationTransmitHead.aid = uid
                    C.ZMQSend(connects[sid], LocationTransmitHead, result, sizeof(result))
                end
            end
        end
    end
end

--通知大地图投票改变
function NotifyMapVoteChange(map, camp, delta, total)
    local result = new('MapVoteChange')
    result.map = map
    result.delta = delta
    result.vote = total
    
    local MapVoteChangeHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            if war_info[sid][uid].camp==camp then
                MapVoteChangeHead.aid = uid
                C.ZMQSend(connects[sid], MapVoteChangeHead, result, sizeof(result))
            end
        end
    end
end

--通知一期国战开始
function NotifyWorldWarBegin()
    local result = new('WorldWarBegin')
    
    local WorldWarBeginHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            v.map = nil
            WorldWarBeginHead.aid = uid
            C.ZMQSend(connects[sid], WorldWarBeginHead, result, sizeof(result))
        end
    end
end

--通知新的一天开始了
function NotifyStartNewDay()
    local result = new('StartNewDay')
    
    local StartNewDayHead = new('MqHead', 0, result.kType, -1)
    
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            StartNewDayHead.aid = uid
            result.count = world_war_vip[war_info[sid][uid].vip].count
            C.ZMQSend(connects[sid], StartNewDayHead, result, sizeof(result))
        end
    end
end

--战斗结束后踢出所有玩家
function StopFightInMap(map)
    for sid,player in pairs(war_wait) do
        for uid,v in pairs(player) do
            if v.map==map then
                v.map = nil
            end
        end
    end
    
    return map
end

--获取可攻击路点
local can_fight_locations = {}
function UpdateCanFightLocations()
    can_fight_locations = {}
    
    --
    local can_attacked_locations = {}
    local can_defended_locations = {}
    for map,info in pairs(war_running) do
        if war_location[map] and info.progress~=0 and info.progress~=war_map[map].count then
            local locations = {}
            for _,v in pairs(war_location[map]) do
                if war_map[map].locations[v.location1].country~=war_map[map].locations[v.location2].country then
                    locations[v.location1] = 1
                    locations[v.location2] = 1
                end
            end
            for k in pairs(locations) do
                if war_running[map].attack~=war_map[map].locations[k].country then
                    table.insert(can_attacked_locations, {map, k})
                else
                    table.insert(can_defended_locations, {map, k})
                end
            end
        end
    end
    
    --
    local function GetCanFightLocations(camp)
        local locations = {}
        
        for _,location in ipairs(can_attacked_locations) do
            if war_running[location[1]].attack==camp then
                for _,v in ipairs(war_map[location[1]].locations[location[2]].adjacent_locations) do
                    if war_map[location[1]].locations[v].country==camp and not war_map[location[1]].locations[location[2]].born then
                        table.insert(locations, {map=location[1], target=location[2], location=v})
                    end
                end
            end
        end
        
        for _,location in ipairs(can_defended_locations) do
            if war_running[location[1]].defend==camp then
                for _,v in ipairs(war_map[location[1]].locations[location[2]].adjacent_locations) do
                    if war_map[location[1]].locations[v].country==camp and not war_map[location[1]].locations[location[2]].born then
                        table.insert(locations, {map=location[1], target=location[2], location=v})
                    end
                end
            end
        end
        
        return locations
    end
    
    can_fight_locations[1] = GetCanFightLocations(1)
    can_fight_locations[2] = GetCanFightLocations(2)
    can_fight_locations[3] = GetCanFightLocations(3)
end
UpdateCanFightLocations()

--随机获取一个可攻击目标
function GetCanFightLocations(camp)
    local locations = can_fight_locations[camp]
    
    return locations[ math.random(1, #locations) ]
end

--获取地图可攻击路点
function GetFightLocations(map, camp)
    local locations = can_fight_locations[camp]
    local ret = {}
    
    for _,v in ipairs(locations) do
        if v.map==map then
            ret[#ret + 1] = v
        end
    end
    return ret
end

--获取特殊军阶信息
local grade_cfg, heros_order = require('config.grade')[1],require('config.grade')[2]
local max_grade_level = 0
for k,v in pairs(grade_cfg) do
    if not v.prestige then
        max_grade_level = k
        break
    end
end
function GetAdvancedGrade(sid)

    local result = new('AdvancedGradeResult')
    result.total = #grade_top
    result.count = 0
    
    local tong_shuai = math.ceil(#grade_top*15/100)         --统帅        14
    local yuan_shuai = math.ceil(#grade_top*10/100)         --元帅        15
    local da_yuan_shuai = math.ceil(#grade_top*5/100)       --大元帅      16
    
    for i=1,tong_shuai do
        if grade_top[i].server==sid then
            result.list[result.count].uid = grade_top[i].player
            result.list[result.count].rank = grade_top[i].rank
            
            if i<=da_yuan_shuai then
                result.list[result.count].level = max_grade_level + 3
            elseif i<=yuan_shuai then
                result.list[result.count].level = max_grade_level + 2
            elseif i<=tong_shuai then
                result.list[result.count].level = max_grade_level + 1
            end
            
            result.count = result.count + 1
            if result.count>=2048 then break end
        end
    end
    
    local head = new('MqHead', 0, result.kType, -1)
    C.ZMQSend(connects[sid], head, result, 12 + result.count * sizeof(result.list[0]))
end

--添加个人战报
function AppendPersonalReport(sid, uid, score, prestige, winning, map)
    local report = {player=uid, server=sid, count=winning, score=score, prestige=prestige, map=map, time = os.time()}
    
    if war_wait[sid] and war_wait[sid][uid] and war_wait[sid][uid].report then
        if #war_wait[sid][uid].report>50 then
            db.DeleteWorldWarReport(table.remove(war_wait[sid][uid].report, 1).report)
        end
        
        db.InsertWorldWarReport(report)
        table.insert(war_wait[sid][uid].report, report)
    else
        db.InsertWorldWarReport(report)
    end
    
    local result = new('WorldWarReport_')
    result.count = winning
    result.score = score
    result.prestige = prestige
    result.map = map
    result.time = report.time
    local head = new('MqHead', uid, result.kType, -1)
    C.ZMQSend(connects[sid], head, result, sizeof(result))
    
    if winning>=3 then
        local WorldWarNotice = new('WorldWarNotice')
        WorldWarNotice.nickname = {#war_info[sid][uid].nickname, war_info[sid][uid].nickname}
        WorldWarNotice.server = {#war_server[sid], war_server[sid]}
        WorldWarNotice.country = war_info[sid][uid].camp
        WorldWarNotice.count = winning
        
        local WorldWarNoticeHead = new('MqHead', 0, WorldWarNotice.kType, -1)
        
        for sid_,player in pairs(war_wait) do
            for uid_,v in pairs(player) do
                if v.map==map then
                    WorldWarNoticeHead.aid = uid_
                    C.ZMQSend(connects[sid_], WorldWarNoticeHead, WorldWarNotice, sizeof(WorldWarNotice))
                end
            end
        end
    end
end
