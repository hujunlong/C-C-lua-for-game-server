local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local copy = ffi.copy

require('db')
require('world_war_util')

local config = require('config.world_war_config')

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
local grade_top = GetGradeTop()

--传入国家，世界地图，获取该国家可攻击地图
local function GetAttackMaps(map, country)
    local function GetCountryRegion(m)
        local country_map = {}
        country_map[1] = {}
        country_map[2] = {}
        country_map[3] = {}

        for k,v in pairs(m) do
            table.insert(country_map[v.country], k)
        end
        return country_map
    end
    
    local region = GetCountryRegion(map)[country]
    
    local adjacent_maps = {}
    for _,map_id in ipairs(region) do
        for _,adjacent in ipairs(map[map_id].adjacent_maps) do
            adjacent_maps[adjacent] = adjacent
        end
    end
    
    local attack_maps = {}
    for map_id in pairs(adjacent_maps) do
        if map[map_id].country~=country and not map[map_id].retention then
            attack_maps[#attack_maps + 1] = map_id
        end
    end
    
    return attack_maps
end

--深度复制table
local function clone(t)
    if type(t) ~= 'table' then return t end
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = clone(v)
        end
        res[k] = v
    end
    return res
end

--传入世界地图，获取所有可攻击地图
--[[
local function GetAllAttackMaps(map)
    local can_attack_maps = {}
    for i=1,3 do
        for _,map_id in ipairs(GetAttackMaps(war_map, i)) do
            can_attack_maps[map_id] = true
        end
    end
    
    local attack_maps = {}
    for map_id in pairs(can_attack_maps) do
        attack_maps[#attack_maps + 1] = map_id
    end
    
    return attack_maps
end
]]


local function MakeAdvancedGrade()
    if war_term==0 then return end
    
    --生成排行榜
    MakeEmpty(grade_top)
    db.ResetGradeTop()
    
    table.sort(war_rank, SortScore)
    local last_score = nil
    local last_rank = nil
    for i,v in ipairs(war_rank) do
        if war_info[v.server][v.player].score~=0 then
            grade_top[#grade_top + 1] = {}
            grade_top[#grade_top].server = v.server
            grade_top[#grade_top].player = v.player
            
            if not last_score or last_score>war_info[v.server][v.player].score then
                last_score = war_info[v.server][v.player].score
                last_rank = i
            end
            grade_top[#grade_top].rank = last_rank
            --grade_top[#grade_top].reward = last_score
            grade_top[#grade_top].index = i
            
            db.InsertGradeTop(grade_top[#grade_top])
        end
    end
    
    for sid,handle in ipairs(connects) do
        GetAdvancedGrade(sid)
    end
end
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- 定时任务

--每天的任务
local function EverydayMission()
    --清除CD、重置挑战次数
    for _,info in pairs(war_info) do
        for _,v in pairs(info) do
            v.count = 0
            --v.auto = 0
            --v.time = 0
        end
    end
    db.ResetWorldWarInfo()
    
    NotifyStartNewDay()
end

--星期一任务   
local function MondayMission()
    --产生特殊军阶
    MakeAdvancedGrade()
    
    --清除国家贡献
    for _,info in pairs(war_info) do
        for _,v in pairs(info) do
            v.score = 0
        end
    end
    db.ResetWorldWarScore()
    
    if war_term~=0 then
        --整理上周运行信息
        for k,v in pairs(war_running) do
            if v.progress~=0 and v.progress~=war_map[k].count then
                local victory = true
                
                if v.progress>war_map[k].count/2 then
                    victory = true
                else
                    if v.progress<war_map[k].count/2 then
                        victory = false
                    else
                        --个数相等时，遍历每个路点计算总进度
                        local attack_progress = 0
                        local defend_progress = 0
                        for _,loc in ipairs(war_location[k]) do
                            attack_progress = attack_progress + loc.progress
                            defend_progress = defend_progress + 100 - loc.progress
                        end
                        
                        victory = attack_progress>defend_progress
                    end
                end
                
                if victory then
                    --进攻胜利
                    war_map[k].country = v.attack
                    db.UpdateWorldWarCountry2(k, v.attack)
                    
                    local news = {map=k, attack=v.attack, defend=v.defend, type=1, time=os.time(), term=war_term}
                    InsertRecord(news)
                else
                    --进攻失败
                    local news = {map=k, attack=v.attack, defend=v.defend, type=2, time=os.time(), term=war_term}
                    InsertRecord(news)
                end
            end
        end
    end
        
    --清除上周战场信息
    db.ResetWorldWarRunning()
    
    --根据投票插入本周信息
    local votes = {}
    local function AddVote(country, map_id, maps)
        local function InTable(t, f)
            for _,v in ipairs(t) do
                if v==f then return true end
            end
            return false
        end
        local attack_maps = GetAttackMaps(war_map, country)
        if InTable(attack_maps, map_id) then
            table.insert(votes, {value=maps["vote"..country], index=country, map=map_id})
        end
    end
    for k,v in pairs(war_map) do
        if not v.retention then
            AddVote(1, k, v)
            AddVote(2, k, v)
            AddVote(3, k, v)
        end
    end
    
    table.sort(votes,function(a,b) return a.value>b.value end)
    
    MakeEmpty(war_running)
    MakeEmpty(war_location)
    for _=1,3 do
        if #votes==0 then break end
        
        --生成大地图信息
        local info = {map=votes[1].map, attack=votes[1].index, defend=war_map[votes[1].map].country, progress=war_map[votes[1].map].count/2}
        war_running[votes[1].map] = info
        db.InsertWorldWarRunning(info)
        
        local news = {map=votes[1].map, attack=votes[1].index, defend=war_map[votes[1].map].country, type=0, time=os.time(), term=war_term}
        InsertRecord(news)
        
        --生成路点详细信息
        if war_map[info.map].locations then
            local traveled = {}
            local countrys = {info.attack, info.defend}
            for k,v in pairs(war_map[info.map].locations) do
                
                local locations = {}
                locations.map = info.map
                locations.location1 = k
                locations.country = countrys[v.default + 1]
                
                v.country = locations.country
                
                traveled[k] = true
                
                for _,adjacent in pairs(v.adjacent_locations) do
                    --not war_map[info.map].locations[adjacent].born and 
                    if not traveled[adjacent] then
                        
                        locations.location2 = adjacent
                        
                        locations.progress = 50
                        --[[
                        if v.default~=war_map[info.map].locations[adjacent].default then
                            --交战路点
                            locations.progress = 50
                        else
                            locations.progress = war_map[info.map].locations[adjacent].default==0 and 100 or 0
                        end
                        ]]
                        
                        db.InsertWorldWarLocation(locations)
                        
                        if not war_location[info.map] then war_location[info.map] = {} end
                        table.insert(war_location[info.map], clone(locations))
                    end
                end
                
                db.InsertWorldWarCountry(locations)
            end
        end
        
        --清理该国家投票权
        local i = 1
        while true do
            if not votes[i] then break end
            if votes[i].map==info.map or votes[i].index==info.attack then
                table.remove(votes, i)
            else
                i = i + 1
            end
        end
    end
    
    --清除投票信息
    for _,v in pairs(war_map) do
        v.vote1 = 0
        v.vote2 = 0
        v.vote3 = 0
    end
    for _,info in pairs(war_info) do
        for _,v in pairs(info) do
            v.vote = 0
        end
    end
    db.ResetWorldWarVote()
    db.ResetWorldWarVote2()
    
    --周数+1
    war_term = war_term + 1
    db.SetWorldWarStatus(status_type.world_war_term, war_term)
    
    NotifyWorldWarBegin()
    UpdateCanFightLocations()
end

--MondayMission()
local function MissionDispatcher(today)
    EverydayMission()
    if today==1 then
        MondayMission()
    end
end

local function WorldWarTimer(fixed)
    --无视修复信息
    if fixed then return end
    
    MissionDispatcher((os.date("*t").wday - 2)%7 + 1)
end

CreateWaitableTimer(status_type.world_war_timer, config.reset_time, WorldWarTimer)

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- 定时生成随机天气

local function RoundWeaher(array)
    if not array then return end
    local probability = math.random()
    
    for _,v in pairs(array) do
        if probability<v then
            return _
        else
            probability = probability - v
        end
    end
end

local function WeatherGenerate()
    for _,v in pairs(war_map) do
        v.weather = RoundWeaher(v.weather_probability)
    end
end
WeatherGenerate()

CreatePunctualTimer(WeatherGenerate)

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- 中午12点刷新排名，准备发奖

local function Award()
    if war_term==0 then return end
    
    --生成排行榜
    MakeEmpty(war_top)
    db.ResetWorldWarTop()
    
    table.sort(war_rank, SortScore)
    local last_score = nil
    local last_rank = nil
    for i,v in ipairs(war_rank) do
        if war_info[v.server][v.player].score~=0 then
            war_top[#war_top + 1] = {}
            war_top[#war_top].server = v.server
            war_top[#war_top].player = v.player
            
            if not last_score or last_score>war_info[v.server][v.player].score then
                last_score = war_info[v.server][v.player].score
                last_rank = i
            end
            war_top[#war_top].rank = last_rank
            war_top[#war_top].reward = last_score
            war_top[#war_top].index = i
            
            db.InsertWorldWarTop(war_top[#war_top])
        end
    end
end

CreateWaitableTimer(status_type.world_war_award, config.award_time, Award)
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- 心跳检测
local send = 1
local verify = 0

local function HeartBeat()
    if send==1 then
        --发送消息
        verify = math.random(0,0xffffff)
        local result = new('ServerHeartBeat', verify)
        local head = new('MqHead', 0, result.kType, -1)
        
        for sid,handle in ipairs(connects) do
            C.ZMQSend(handle, head, result, sizeof(result))
        end
        
        send = 0
    else
        --检查消息
        for sid,status in ipairs(connects_status) do
            if status.verify == verify then
                status.connect = true
            else
                status.connect = false
                if war_wait[sid] then
                    for uid in pairs(war_wait[sid]) do
                        war_player[sid .. ':' .. uid] = nil
                    end
                    
                    war_wait[sid] = nil
                end
            end
        end
        
        --清理超时协程
        for k,co_mgr in pairs(coroutine_queue) do
            if os.time()-co_mgr.time>10 then
                print("清理超时协程")
                coroutine_queue[k] = nil
            end
        end
        
        send = 1
    end
end

ffi.CreateTimer(HeartBeat, 2)
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- 调试信息
--[[
local function debug_info()
    local count = 0
    for _,co in pairs(coroutine_queue) do
        count = count + 1
        
        print("协程挂起时间",os.time()-co.time)
    end
    
    print()
    print("挂起的协程数量", count)
    
    count = 0
    for _,server in pairs(war_wait) do
        for _ in pairs(server) do
            count = count + 1
        end
    end
    print("等待国战消息通知的玩家数量", count)
end
ffi.CreateTimer(debug_info, 60)
]]
