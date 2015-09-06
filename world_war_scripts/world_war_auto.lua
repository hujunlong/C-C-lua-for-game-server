-- 自动参战
local ffi    = require('ffi')
local C      = ffi.C
local sizeof = ffi.sizeof
local new    = ffi.new
local cast   = ffi.cast
local copy   = ffi.copy

require('db')

local config = require('config.world_war_config')
local world_war_vip = require('config.world_war_vip')

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

--自动战斗主逻辑
local function Fighting(sequence, sid, uid, attcak, winning, target_player, target_location, map_id, location, pos)
    coroutine.yield()

    local target = war_map[map_id].locations[location]

    local wait_info = war_wait[sid][uid]
    local info = war_info[sid][uid]
    local keep = true
    local score = 0
    local prestige = 0

    local weather = target.weather
    if not weather then weather = war_map[map_id].weather end
    
    local heros_group1, heros_info1 = coroutine_queue[sequence].info[1][1], coroutine_queue[sequence].info[1][2]
    local heros_group2, heros_info2 = coroutine_queue[sequence].info[2][1], coroutine_queue[sequence].info[2][2]

    --开始战斗
    local env = 
    {
        type=7, weather=weather, terrain=target.terrain, no_record=true, 
        group_a={server=war_server[sid], name=info.nickname, level=info.level, array=heros_info1.array, sex=heros_info1.sex}, 
        group_b={server=war_server[target_player.sid], name=war_info[target_player.sid][target_player.uid].nickname, level=war_info[target_player.sid][target_player.uid].level, array=heros_info2.array, sex=heros_info2.sex}
    }
    
    local fight = CreateFight(heros_group1, heros_group2, env)
    local winner = fight.GetFightWinner()
    
    winner = 1 - winner
    if winner==0 then
        --失败，直接结束
        keep = false
        if winning==0 then
            score = config.lose_score
        end
        
        prestige = config.prestige_fail
    else
        --胜利
        score = GetScoreByRank(info.rank)

        if not attcak then
            --防守胜利
            target_location.progress = target_location.progress - config.progress
            
            if target_location.progress<=0 then
                target_location.progress = 50
                
                --防守方成功推进一个路点
                war_running[map_id].progress = war_running[map_id].progress - 1
                db.UpdateWorldWarRunning(map_id, war_running[map_id].progress)
                
                target.country = info.camp
                db.UpdateWorldWarCountry3(map_id, location, info.camp)
                
                --如果是多个点连接的情况
                for _,v in ipairs(war_location[map_id]) do
                   if v.location1==location and v.location2~=pos then
                      if war_map[map_id].locations[v.location2].country==info.camp then
                         v.progress = 50
                         db.SetWorldWarLocation(map_id, v.location1, v.location2, v.progress)
                         
                         NotifyLocationChange(map_id, v)
                      end
                   else
                      if v.location2==location and v.location1~=pos then
                         if war_map[map_id].locations[v.location1].country==info.camp then
                            v.progress = 50
                            db.SetWorldWarLocation(map_id, v.location1, v.location2, v.progress)
                            NotifyLocationChange(map_id, v)
                         end
                      end
                   end
                end
                
                UpdateCanFightLocations()
                NotifyMapChange(map_id)
                NotifyLocationTransmit(map_id, location)
                    
                --防守方获得最后胜利
                if war_running[map_id].progress==0 then
                    local news = {map=map_id, attack=war_running[map_id].attack, defend=war_running[map_id].defend, type=2, time=os.time(), term=war_term}
                    InsertRecord(news)
                    
                    war_map[map_id].country = info.camp
                    db.UpdateWorldWarCountry2(map_id, info.camp)
                            
                    StopFightInMap(map_id)
                    keep = false
                end
            end
        else
            --进攻胜利
            target_location.progress = target_location.progress + config.progress
         
            if target_location.progress>=100 then
                target_location.progress = 50
                
                --进攻方成功推进一个路点
                war_running[map_id].progress = war_running[map_id].progress + 1
                db.UpdateWorldWarRunning(map_id, war_running[map_id].progress)
                
                target.country = info.camp
                db.UpdateWorldWarCountry3(map_id, location, info.camp)
                
                --如果是多个点连接的情况
                for _,v in ipairs(war_location[map_id]) do
                   if v.location1==location and v.location2~=pos then
                      if war_map[map_id].locations[v.location2].country==info.camp then
                         v.progress = 50
                         db.SetWorldWarLocation(map_id, v.location1, v.location2, v.progress)
                         
                         NotifyLocationChange(map_id, v)
                      end
                   else
                      if v.location2==location and v.location1~=pos then
                         if war_map[map_id].locations[v.location1].country==info.camp then
                            v.progress = 50
                            db.SetWorldWarLocation(map_id, v.location1, v.location2, v.progress)
                            NotifyLocationChange(map_id, v)
                         end
                      end
                   end
                end
                
                UpdateCanFightLocations()
                NotifyMapChange(map_id)
                NotifyLocationTransmit(map_id, location)
                
                if war_running[map_id].progress==war_map[map_id].count then
                    local news = {map=map_id, attack=war_running[map_id].attack, defend=war_running[map_id].defend, type=1, time=os.time(), term=war_term}
                    InsertRecord(news)
                    
                    war_map[map_id].country = info.camp
                    db.UpdateWorldWarCountry2(map_id, info.camp)
                    
                    StopFightInMap(map_id)
                    keep = false
                end
            end
        end
        
        --写入数据库
        db.SetWorldWarLocation(map_id, target_location.location1, target_location.location2, target_location.progress)
        NotifyLocationChange(map_id, target_location)
        
        if winning~=0 then
            --连战
            info.score = info.score + winning + 1
            info.point = info.point + winning + 1
            
            prestige = config.prestige_extra
        else
            prestige = config.prestige_reward
        end
        
        winning = winning + 1
        if winning>=config.winning_max then
            --连胜上限达到
            keep = false
        end
    end
    
    info.rank, war_info[target_player.sid][target_player.uid].rank = GetNewRank(info.rank, war_info[target_player.sid][target_player.uid].rank, winner)
    info.score = info.score + score
    info.point = info.point + score
    db.UpdateWorldWarInfo(uid, sid, {"rank", info.rank}, {"score", info.score}, {"point", info.point})
    
    --更改挑战目标Rank
    db.UpdateWorldWarInfo(target_player.uid, target_player.sid, {"rank", war_info[target_player.sid][target_player.uid].rank})
    
    RequestRemoteMethodCall(sid, uid, C.kRewardPrestige, prestige)
    
    wait_info.reward_prestige = wait_info.reward_prestige + prestige
    wait_info.auto_winning = winning
    wait_info.auto_map = map_id
    
    if keep then
        --连胜，继续战斗
        CreateFighting(sid, uid, info.camp, winning)
    else
        --自动战斗状态改变
        info.count = info.count + 1
        info.auto = info.auto + 1
        info.time = os.time() + config.cd_time2
        if info.auto==config.auto_max then
            info.robot = 0
            info.auto = 0
            db.UpdateWorldWarInfo(uid, sid, {"count", info.count}, {"auto", info.auto}, {"time", info.time}, {"robot", info.robot})
        else
            db.UpdateWorldWarInfo(uid, sid, {"count", info.count}, {"auto", info.auto}, {"time", info.time})
        end
        
        --推送因为自动战斗的状态改变
        local result = new("AutoFightingStatus")
        result.score = info.score
        result.point = info.point
        result.time = info.time
        result.robot = info.robot
        result.count = world_war_vip[info.vip].count - info.count
        result.auto_count = info.auto
        
        local FightingStatusHead = new('MqHead', uid, result.kType, -1)
        C.ZMQSend(connects[sid], FightingStatusHead, result, sizeof(result))
        
        RequestRemoteMethodCall(sid, uid, C.kWorldWarCount1, world_war_vip[info.vip].count - info.count)
        
        AppendPersonalReport(sid, uid, info.score - wait_info.last_score, wait_info.reward_prestige, wait_info.auto_winning, wait_info.auto_map)
        wait_info.last_score = nil
        wait_info.reward_prestige = nil
        wait_info.auto_winning = nil
        wait_info.auto_map = nil
    end
end

local function CancelAutoFighting(sid, uid)
    local info = war_info[sid][uid]
    info.robot = 0
    info.auto = 0
    info.time = info.time - config.cd_time2
    db.UpdateWorldWarInfo(uid, sid, {"auto", info.auto}, {"time", info.time}, {"robot", info.robot})
    
    --推送自动战斗的状态改变
    local result = new("AutoFightingStatus")
    result.score = info.score
    result.point = info.point
    result.time = info.time
    result.robot = info.robot
    result.count = world_war_vip[info.vip].count - info.count
    result.auto_count = info.auto
    
    local FightingStatusHead = new('MqHead', uid, result.kType, -1)
    C.ZMQSend(connects[sid], FightingStatusHead, result, sizeof(result))
    
    --
    if war_wait[sid] and war_wait[sid][uid] and war_wait[sid][uid].reward_prestige then
        local wait_info = war_wait[sid][uid]
        AppendPersonalReport(sid, uid, info.score - wait_info.last_score, wait_info.reward_prestige, wait_info.auto_winning, wait_info.auto_map)
        
        wait_info.last_score = nil
        wait_info.reward_prestige = nil
        wait_info.auto_winning = nil
        wait_info.auto_map = nil
    end
end

--
function CreateFighting(sid, uid, camp, winning)
    local locations = GetCanFightLocations(camp)
    
    if not locations then
        return CancelAutoFighting(sid, uid)
    end
    
    local map = locations.map
    local loc = locations.target
    local pos = locations.location
    
    local attcak = war_running[map].attack==camp
    local target_player = GetRankTarget(sid, uid, war_map[map].locations[loc].country)
    local target_location = nil
    for i,v in ipairs(war_location[map]) do
        if v.location1==pos and v.location2==loc then
            target_location = war_location[map][i]
            break
        else
            if v.location2==pos and v.location1==loc then
                target_location = war_location[map][i]
                break
            end
        end
    end
    
    if not target_location or not target_player then
        return CancelAutoFighting(sid, uid)
    end
    

    --发送查询请求，完成后自动调用协程
    local co_mgr = {co=coroutine.create(Fighting), rely=2, info={}, time=os.time()}
    coroutine.resume(co_mgr.co, c_sequence, sid, uid, attcak, winning, target_player, target_location, map, loc, pos)
    coroutine_queue[c_sequence] = co_mgr
    
    RequestPlayerGroup(sid, uid, c_sequence, 1)
    RequestPlayerGroup(target_player.sid, target_player.uid, c_sequence, 2)

    c_sequence = c_sequence + 1
end

--
local delay = 1
local function AutoFighting()
    --延迟10秒开始自动战斗，用来等待连接的心跳建立
    delay = delay + 1
    if delay<10 then
        return
    else
        delay = 10
    end
    
    for sid,_info in pairs(war_info) do
        for uid,info in pairs(_info) do
            if info.count<world_war_vip[info.vip].count then
                if info.robot==1 and info.auto<config.auto_max and info.time<=os.time() then
                    --
                    if not war_wait[sid] then war_wait[sid] = {} end
                    if not war_wait[sid][uid] then war_wait[sid][uid] = {} end
                    
                    local wait_info = war_wait[sid][uid]
                    wait_info.last_score = info.score
                    wait_info.reward_prestige = 0
                    wait_info.auto_winning = 0
                    wait_info.auto_map = 0
                    
                    --创建战斗
                    info.time = os.time() + config.cd_time2
                    CreateFighting(sid, uid, info.camp, 0)
                end
            else
                if info.robot==1 then
                    --取消自动战斗
                    info.time = os.time() + config.cd_time2
                    CancelAutoFighting(sid, uid)
                end
            end
        end
    end
end

ffi.CreateTimer(AutoFighting, 1)
