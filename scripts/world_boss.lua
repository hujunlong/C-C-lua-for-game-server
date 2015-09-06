--世界BOSS系统
local config = require('config.global')
local action_id = require('define.action_id')
local gold_consume_flag = require('define.gold_consume_flag')
require('achievement')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

local online_players = {}
function WorldBossInitialize(all_players)
    online_players = all_players
end

require('data')
require('global_data') 
local boss_cfg = require('config.world_boss')
local boss_level = require('config.world_boss_level')
local boss_count = require('config.world_boss_count')
data.GetWorldBossInfo(boss_cfg, boss_level)

local boss_max_level = 0
for _ in pairs(boss_level) do
    boss_max_level = _
end

--战斗相关
local monster_cfgs = require('config.monster')
require('tools.table_ext')
require('tools.time')

local assistant_id = require('config.assistant_task_id')

function ResetWorldBossInfo()
    for _,v in pairs(boss_cfg) do v.dead = 0 end
    data.ResetWorldBossInfo()
end

--BOSS状态
local boss_status = 0          --当前BOSS状态，0代表无BOSS，1等待中，2代表进行中，3代表BOSS已经死亡
local boss_progress = 0        --当前BOSS进度，0代表无BOSS

--boss战运行时状态
local world_boss_running = {}
local world_boss_hurt = {}              --伤害统计
local world_boss_killer = nil           --最后一击
local challenger_count = 0              --当前人数

--BOSS阵位
local boss_group = {}

--获取排行榜前10
local function GetTop10(t, name)
    local temp = {}
    for k,v in pairs(t) do
        if v[name]~=0 then
            temp[#temp + 1] = {}
            temp[#temp].key = k
            temp[#temp].value = v
        end
    end
    
    table.sort(temp,
        function(a,b)
            return a.value[name] > b.value[name]
        end
    )
    
    local result = {}
    for i=1, math.min(10,#temp) do
        result[#result + 1] = temp[i].key
    end
    
    return result
end

--通知BOSS排行榜
local function NotifyWorldBossTop(uid)
    local result = new('WorldBossBoard')
    
    local top_hurt = GetTop10(world_boss_running, 'hurt_total')
    
    result.count = 0
    for i=1,#top_hurt do
        result.list[result.count].nickname = data.GetCPlayerName(top_hurt[i])
        result.list[result.count].hurt = world_boss_running[top_hurt[i]].hurt_total
        result.count = result.count + 1
    end
    
    if uid then
        GlobalSend2Gate(uid, result, 4 + result.count * sizeof(result.list[0]))
    else
        for player_id,status in pairs(world_boss_running) do
            if online_players[player_id] and status.enter then
                GlobalSend2Gate(player_id, result, 4 + result.count * sizeof(result.list[0]))
            end
        end
    end
end

--通知BOSS血量
local function NotifyWorldBossLife()
    if not next(world_boss_hurt) then return end
    
    local result = new('WorldBossHurt')
    
    result.life = boss_cfg[boss_progress].life
    result.count = 0
    for i=1,#world_boss_hurt do
        result.list[result.count] = world_boss_hurt[i]
        result.count = result.count + 1
        if result.count>=512 then break end
    end
    
    local temp_hurt = {}
    for i=result.count + 1,#world_boss_hurt do
        temp_hurt[#temp_hurt + 1] = world_boss_hurt[i]
    end
    world_boss_hurt = temp_hurt
    
    for player_id,status in pairs(world_boss_running) do
        if online_players[player_id] and status.enter then
            GlobalSend2Gate(player_id, result, 8 + result.count * 4)
        end
    end
    
    --这里有个优化，把血量改变和排行榜变化做在一起了
    --但是如果一个玩家新登录，则需要离开给他推送一个排行榜
    NotifyWorldBossTop(nil)
end

--重设BOSS状态
local function ResetWorldBoss(IsKill)
    IsKill = IsKill and 1 or 0
    
    local level = math.min( boss_cfg[boss_progress].level + IsKill, boss_max_level)
    boss_cfg[boss_progress].level = level
    boss_cfg[boss_progress].dead = IsKill
    boss_cfg[boss_progress].life = boss_level[level].life
    boss_cfg[boss_progress].max_life = boss_level[level].life
    data.SetWorldBossInfo(boss_progress, level, IsKill)
end

--统计最终发奖
local function SendWorldBossCollectReward()
    for player_id,status in pairs(world_boss_running) do
        if online_players[player_id] then
            local result = new('WorldBossCollectReward')
            result.silver = status.silver_total
            result.prestige = status.prestige_total
            result.silver_extra = status.silver_extra or 0
            GlobalSend2Gate(player_id, result)
        end
    end
end

--发奖公示
local function SendWorldBossFinalReward(level, boss_id)
    
    local function SendRealWorldBossFinalReward(top)
        local result = new('WorldBossReward')
        for rank,player_id in ipairs(top) do
            local silver = boss_level[level].top_reward[rank]
            world_boss_running[player_id].top_reward = silver
            local player = online_players[player_id]
            if player then
                player.ModifySilver(silver)
                
                result.silver = silver
                GlobalSend2Gate(player_id, result)
            else
                --不在线
                ModifySilverByUID(player_id, silver)
            end
        end
    end
    
    --前十名发奖
    local top_hurt = GetTop10(world_boss_running, 'hurt_total')
    
    SendRealWorldBossFinalReward(top_hurt)
    
    --发奖公告
    local result = new('WorldBossFinalReward')
    result.life = boss_level[level].life
    result.killer = 0
    result.sid = boss_id
    result.count = 1
    
    --最后一击
    if world_boss_killer then
        result.killer = 1
        result.list[0].nickname = data.GetCPlayerName(world_boss_killer)
        result.list[0].uid = world_boss_killer
        result.list[0].hurt = world_boss_running[world_boss_killer].hurt_total
        result.list[0].silver = world_boss_running[world_boss_killer].silver_extra
    end
    
    --排名奖励（仅显示3个）
    for i=1,math.min(#top_hurt,3) do
        result.list[i].nickname = data.GetCPlayerName(top_hurt[i])
        result.list[i].uid = top_hurt[i]
        result.list[i].hurt = world_boss_running[top_hurt[i]].hurt_total
        result.list[i].silver = world_boss_running[top_hurt[i]].top_reward
        result.count = result.count + 1
    end
    
    GlobalSend2Gate(-1, result, 8 + result.count * sizeof(result.list[0]))
    
    --成就
    for player_id,status in pairs(world_boss_running) do
        RecordOfflinePlayerAction(player_id, action_id.kBOSShurt, math.floor( status.hurt_total * 100 / boss_level[level].life ) )
    end
end

--通知BOSS挑战人数改变
local function NotifyWorldBossChallengerCount(delta)
    challenger_count = challenger_count + delta
    
    --
    local result = new('WorldBossChallengerCount')
    result.count = challenger_count
    
    for player_id,status in pairs(world_boss_running) do
        if online_players[player_id] and status.enter then
            GlobalSend2Gate(player_id, result)
        end
    end
end

--
function CreateWorldBoss(player)
    local obj = {}
    
    local uid = player.GetUID()
    
    --数据保存
    local this = {}
    this.activate = false         --是否激活
    
    function obj.open()
        this.activate = true
    end
    
    --客户端消息处理
    local processor_ = {}
    
    --获取世界BOSS信息
    processor_[C.kGetWorldBossInfo] = function(msg)
        local result = new('GetWorldBossInfoReturn', 0)
        local return_length = 4
        if this.activate then
            result.count = 0
            for _,cfg in ipairs(boss_cfg) do
                if cfg.country==0 or cfg.country==player.GetCountry() then
                    result.list[result.count].enter_time = time.ConvertString2time(cfg.enter_time)
                    result.list[result.count].start_time = time.ConvertString2time(cfg.start_time)
                    result.list[result.count].over_time = time.ConvertString2time(cfg.over_time)
                    result.list[result.count].level = cfg.level
                    result.list[result.count].dead = cfg.dead
                    result.list[result.count].sid = _
                    result.list[result.count].id = cfg.id
                    
                    result.count = result.count + 1
                end
            end
            return_length = 8 + result.count * sizeof(result.list[0])
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        return result, return_length
    end
    
    --进入世界BOSS区域
    processor_[C.kEnterWorldBoss] = function(msg)
        local result = new('EnterWorldBossReturn', 0)
        if this.activate then
            if boss_progress~=0 and (boss_cfg[boss_progress].country==0 or boss_cfg[boss_progress].country==player.GetCountry()) then
                result.life = boss_cfg[boss_progress].life
                result.max_life = boss_cfg[boss_progress].max_life
                if not world_boss_running[uid] then
                    player.RecordAction(action_id.kBOSSJoin, 1)
                    
                    world_boss_running[uid] = {}
                    world_boss_running[uid].enter = true
                    world_boss_running[uid].time = 0
                    world_boss_running[uid].hurt_total = 0
                    world_boss_running[uid].silver_total = 0
                    world_boss_running[uid].prestige_total = 0
                    world_boss_running[uid].reborn = 0
                    world_boss_running[uid].gain = 0
                    
                    NotifyWorldBossChallengerCount(1)
                else
                    if not world_boss_running[uid].enter then
                        world_boss_running[uid].enter = true
                        
                        NotifyWorldBossChallengerCount(1)
                    end
                end
                
                result.time = world_boss_running[uid].time
                result.hurt = world_boss_running[uid].hurt_total
                result.count = boss_count[player.GetVIPLevel()].count - world_boss_running[uid].reborn
                
                NotifyWorldBossTop(uid)
            else
                result.result = C.BOSS_NOT_YET_BEGIN
            end
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        return result
    end
    
    --离开世界BOSS区域
    processor_[C.kLeaveWorldBoss] = function(msg)
        local result = new('LeaveWorldBossReturn', 0)
        if this.activate then
            if world_boss_running[uid] then
                if world_boss_running[uid].enter then
                    NotifyWorldBossChallengerCount(-1)
                end
                
                world_boss_running[uid].enter = false
            end
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        return result
    end
    
    --攻击BOSS
    processor_[C.kAttackWorldBoss] = function(msg, flag)
        local result = new('AttackWorldBossReturn', 0)
        local return_length = 4
        if this.activate then
            if boss_progress~=0 then
                if boss_status==2 then
                    if world_boss_running[uid] and world_boss_running[uid].enter then
                        if world_boss_running[uid].time<=os.time() then
                            local heros_group,array = player.GetHerosGroup()
                            
                            boss_group[5].momentum = 0
                            local env = {type=3, weather='cloudy', terrain='plain', group_a={group_damage_per=world_boss_running[uid].gain, name=player.GetName(),array=array}, group_b={is_monster=true}}
                            
                            local fight = CreateFight(heros_group, boss_group, env)
                            local record, record_len = fight.GetFightRecord()
                            local winner = fight.GetFightWinner()
                            
                            local hurt = 0 - fight.GetStatistics().group_a.hits
                            local silver = math.ceil(hurt/20)
                            local prestige = boss_level[boss_cfg[boss_progress].level].prestige
                            
                            --奖励上限检查
                            if world_boss_running[uid].silver_total + silver > boss_level[boss_cfg[boss_progress].level].silver_limit then
                                silver = boss_level[boss_cfg[boss_progress].level].silver_limit - world_boss_running[uid].silver_total
                            end
                            if world_boss_running[uid].prestige_total + prestige > boss_level[boss_cfg[boss_progress].level].prestige_limit then
                                prestige = boss_level[boss_cfg[boss_progress].level].prestige_limit - world_boss_running[uid].prestige_total
                            end
                            
                            world_boss_running[uid].gain = 0
                            
                            --最后一击奖励
                            if winner==0 then
                                world_boss_running[uid].silver_extra = boss_level[boss_cfg[boss_progress].level].killer_reward
                                silver = silver + world_boss_running[uid].silver_extra
                                
                                hurt = boss_cfg[boss_progress].life
                            end
                            
                            --统计
                            world_boss_hurt[#world_boss_hurt + 1] = hurt
                            boss_cfg[boss_progress].life = boss_cfg[boss_progress].life - hurt
                            world_boss_running[uid].hurt_total = world_boss_running[uid].hurt_total + hurt
                            world_boss_running[uid].silver_total = world_boss_running[uid].silver_total + silver
                            world_boss_running[uid].prestige_total = world_boss_running[uid].prestige_total + prestige
                            world_boss_running[uid].time = os.time() + config.world_boss.cd_time
                            
                            --准备发送结果
                            result.killer = 0
                            result.time = world_boss_running[uid].time
                            result.hurt = hurt
                            result.hurt_total = world_boss_running[uid].hurt_total
                            result.silver = silver
                            result.prestige = prestige
                            result.fight_record_bytes = record_len
                            copy(result.fight_record, record, result.fight_record_bytes)
                            
                            player.AssistantCompleteTask(assistant_id.kWorldBoss, 999)
                            
                            --最后一击，通知全服务器，并且发奖
                            if winner==0 then
                                NotifyWorldBossLife()
                                
                                --把BOSS打死了
                                world_boss_killer = uid
                                result.killer = 1
                                
                                player.RecordAction(action_id.kBOSSKiller, boss_progress)
                                player.ModifySilver(silver)
                                player.ModifyPrestige(prestige)
                                
                                local fixed_flag_head_ = new('MqHead', player.GetUID(), result.kType, flag)
                                C.Send2Gate(fixed_flag_head_, result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes)
                                
                                local level = boss_cfg[boss_progress].level
                                local boss_id = boss_progress
                                
                                ResetWorldBoss(true)
                                --不等待定时器立刻刷新状态
                                boss_status = 3
                                boss_progress = 0
                                
                                GlobalSend2Gate(-1, new('WorldBossDead'))
                                
                                SendWorldBossCollectReward()
                                SendWorldBossFinalReward(level, boss_id)
                                
                                --因为以前提前发送返回，后续流程不再继续
                                return
                            end
                            
                            player.ModifySilver(silver)
                            player.ModifyPrestige(prestige)
                            
                            return_length = sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
                        else
                            result.result = C.BOSS_ON_THE_CD_TIME
                        end
                    else
                        result.result = C.BOSS_NOT_YET_ENTER
                    end
                else
                    if boss_status==1 then
                        result.result = C.BOSS_NOT_YET_REAL_BEGIN
                    else
                        result.result = C.BOSS_BOSS_ALREADY_DEAD
                    end
                end
            else
                result.result = C.BOSS_NOT_YET_BEGIN
            end
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        
        return result, return_length
    end
    
    --减少CD
    processor_[C.kReduceWorldBossCD] = function(msg)
        local result = new('ReduceWorldBossCDReturn', 0)
        if this.activate then
            if boss_status==2 and world_boss_running[uid] and world_boss_running[uid].enter and world_boss_running[uid].time>os.time() then
                local cost = math.ceil( ( world_boss_running[uid].time - os.time() )/config.world_boss.reduce_cd_time ) * config.world_boss.reduce_cd_gold
                if player.IsGoldEnough(cost) then
                    player.ConsumeGold(cost, gold_consume_flag.world_boss_clear_cd)
                    world_boss_running[uid].time = 0
                    result.time = world_boss_running[uid].time
                else
                    result.result = C.BOSS_NOT_ENOUGH_GOLD
                end
            else
                result.result = C.BOSS_DONT_NEED_REDUCE_CD
            end
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        return result
    end

    --不死鸟复活
    processor_[C.kPhoenixNirvana] = function(msg)
        local result = new('PhoenixNirvanaReturn', 0)
        if this.activate then
            if world_boss_running[uid].reborn<boss_count[player.GetVIPLevel()].count then
                if boss_status==2 and world_boss_running[uid] and world_boss_running[uid].enter and world_boss_running[uid].time>os.time() then
                    local cost = config.world_boss.reborn_price
                    if player.IsGoldEnough(cost) then
                        player.ConsumeGold(cost, gold_consume_flag.world_boss_phoenix_nirvana)
                        world_boss_running[uid].gain = 1
                        world_boss_running[uid].time = 0
                        world_boss_running[uid].reborn = world_boss_running[uid].reborn + 1
                        result.time = world_boss_running[uid].time
                        result.count = boss_count[player.GetVIPLevel()].count - world_boss_running[uid].reborn
                    else
                        result.result = C.BOSS_NOT_ENOUGH_GOLD
                    end
                else
                    result.result = C.BOSS_DONT_NEED_REDUCE_CD
                end
            else
                result.result = C.BOSS_NO_MORE_TIMES
            end
        else
            result.result = C.BOSS_NOT_YET_ACTIVATE
        end
        return result
    end
    
    --外部自动调用的接口
    function obj.ProcessMsg(type, msg, flag)
        local func = processor_[type]
        if func then return func(msg, flag) end
    end
    
    return obj
end


--通知做好挑战BOSS准备
local function NotifyWorldBossPrepare(_boss)
    --创建BOSS对象
    local boss = table.deep_clone(monster_cfgs[boss_cfg[_boss].id])
    boss.id = boss_cfg[_boss].id
    boss.life = boss_cfg[_boss].life
    boss.level = boss_cfg[_boss].level
    boss.max_life = boss_cfg[_boss].max_life
    boss.momentum = 0
    boss_group[5] = boss
    
    --
    world_boss_running = {}
    world_boss_hurt = {}
    world_boss_killer = nil
    challenger_count = 0

    --
    local result = new('WorldBossPrepare')
    GlobalSend2Gate(-1, result)
end

--通知BOSS可以挑战
local function NotifyWorldBossBegin()
    local result = new('WorldBossBegin')
    GlobalSend2Gate(-1, result)
end

--通知BOSS挑战结束【时间到】
local function NotifyWorldBossEnd()
    --
    ResetWorldBoss(false)
    SendWorldBossCollectReward()
    --
    local result = new('WorldBossEnd')
    GlobalSend2Gate(-1, result)
end

--定期检查BOSS状态，查看是否开启、死亡等
function CheckBossStatus()

    --BOSS战进行中
    if boss_status==2 then
        NotifyWorldBossLife()
    end
    
    local status = 0
    local progress = 0
    for boss,cfg in ipairs(boss_cfg) do
        local enter_time = time.ConvertString2time(cfg.enter_time)
        local start_time = time.ConvertString2time(cfg.start_time)
        local over_time = time.ConvertString2time(cfg.over_time)
        
        local time = os.time()
        if time>enter_time and time<over_time then
            if boss_progress==0 and cfg.dead==0 then
                NotifyWorldBossPrepare(boss)
            end
            progress = boss
            if time<start_time then
                status = 1
            else
                if cfg.dead==0 then
                    if boss_status~=2 then
                        NotifyWorldBossBegin()
                    end
                    status = 2
                else
                    status = 3
                    progress = 0
                end
            end
            break
        end
    end
    
    if boss_progress~=0 and progress==0 and boss_status==2 then
        NotifyWorldBossEnd()
        SendWorldBossFinalReward(boss_cfg[boss_progress].level, boss_progress)
    end
    boss_status = status
    boss_progress = progress
end

--玩家离线
function WorldBossDestroy(uid)
    if world_boss_running[uid] then
        if world_boss_running[uid].enter then
            NotifyWorldBossChallengerCount(-1)
        end

        world_boss_running[uid].enter = false
    end
end
