--竞技场交互【客户端、数据库】

require('data')
require('grade')
require('global_data')
require('tools.time')

local config = require('config.global')
local action_id = require('define.action_id')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

--全局信息
local arena_info = data.GetAllArenaInfo()

local arena_rank = {}
for rank,v in ipairs(arena_info) do
    arena_rank[v.player] = rank
end

require('arena')

--竞技场发奖
local function AwardArena()
    for rank,v in ipairs(arena_info) do
        v.reward = rank
    end
    data.RewardArenaInfo()
    
    local result = new('ArenaReward')
    GlobalSend2Gate(-1, result)
end
CreateWaitableTimerForResetAction(action_type.award_arena, config.arena.reward_time, AwardArena)

--竞技场重置
function ResetArena()
    for _,v in ipairs(arena_info) do
        if v.info then
            v.info.count = 0
            v.info.buy_count = 0
        end
    end
    data.ResetArenaInfo()
end

function ArenaInteraction(player)
    local obj = {}
    
    local uid = player.GetUID()
    
    --数据保存
    local this = {}
    this.info = {}               --个人竞技场信息
    this.history = {}            --竞技场历史记录
    
    --激活竞技场
    function obj.open()
        --是否激活了竞技场
        if not arena_rank[uid] then
            arena_info[#arena_info + 1] = {}
            arena_info[#arena_info].player = uid
            arena_info[#arena_info].reward = 0
            arena_info[#arena_info].win_count = 0
            
            player.InsertRow(C.ktArenaInfo, {C.kfRank, #arena_info})

            arena_rank[uid] = #arena_info
            this.info.time = 0
            this.info.count = 0
            this.info.buy_count = 0
            
            arena_info[#arena_info].info = this.info
            arena_info[#arena_info].history = this.history
            
            if #arena_info<=100 then
                player.RecordAction(action_id.kArenaRank, 1)
            end
        end
    end
    
    --获取信息
    function obj.get_rank()
        return arena_rank[uid]
    end
    
    local instance = CreateArena(player, this, arena_info, arena_rank)
    
    --数据库消息处理
    local db_processor_ = {}
    
    db_processor_[C.kArenaInfo] = function(msg)
        local db_arena_info = cast('const ArenaInfo&', msg)
        this.info.time = db_arena_info.time
        this.info.count = db_arena_info.count
        this.info.buy_count = db_arena_info.buy_count
        
        arena_info[arena_rank[uid]].info = this.info
    end
    db_processor_[C.kArenaHistory] = function(msg)
        local arena_history = cast('const ArenaHistoryList&', msg)
        this.history = new('ArenaHistoryList')
        copy(this.history, arena_history, sizeof(arena_history))
        if this.history.count~=0 then
            if arena_rank[uid] then
                arena_info[arena_rank[uid]].history = this.history
            else
                print("some error found kArenaHistory",uid)
            end
        end
    end
    db_processor_[C.kArenaChallenge] = function(msg)
        local arena_challenge = cast('const ArenaChallengeList&', msg)
        for i=0,arena_challenge.count-1 do
            local result = new('PushOccurredChallenge')
            result.nickname = data.data.GetCPlayerName(arena_challenge.list[i].challenger)
            result.rank_change = arena_challenge.list[i].rank_change
            result.war_id = arena_challenge.list[i].war_id
            
            result.fight_record_bytes = 0
            
            player.Send2Gate(result, sizeof(result) - C.kMaxFightRecordLength)
        end
    end
    
    
    --客户端消息处理
    local processor_ = {}
    
    processor_[C.kGetArenaInfo] = function(msg)
        local result = new('GetArenaInfoReturn', 0)
        local inner_result, inner_info = instance.get_info()
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.rank = inner_info[1]
            result.time = inner_info[2]
            result.remain_count = inner_info[3]
            result.win_count = inner_info[4]
            result.reward = inner_info[5]
            result.grade = GetGradeLevel(uid)
            result.buy_count = inner_info[6]
        end
        return result
    end
    
    processor_[C.kGetChallengeList] = function(msg)
        local result = new('GetChallengeListReturn', 0)
        local list_count = 0
        local inner_result, inner_info = instance.get_challenge_list()
        
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            for i=#inner_info,1,-1 do
                local v = inner_info[i]
                if not arena_info[v] then break end
                
                result.list[list_count].rank = v
                result.list[list_count].player = arena_info[v].player
                
                local base_info = data.GetPlayerBaseInfo(arena_info[v].player)
                if not base_info then break end
                
                result.list[list_count].nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
                result.list[list_count].level = base_info.game_info.level
                result.list[list_count].grade = GetGradeLevel(arena_info[v].player)
                
                list_count = list_count + 1
            end
        end
        
        result.list_count = list_count
        
        local result_length = 8 + list_count * sizeof(result.list[0])
        return result, result_length
    end
    
    processor_[C.kGetWarReport] = function(msg)
        local result = new('GetWarReportReturn', 0)
        local inner_result, inner_info = instance.get_war_report()
        result.war_count = 0
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            for k=0,inner_info.count-1 do
                result.list[k].target = inner_info.list[k].target_id
                result.list[k].nickname = data.GetCPlayerName(inner_info.list[k].target_id)
                result.list[k].initiative = inner_info.list[k].initiative
                result.list[k].winner = inner_info.list[k].winner
                result.list[k].rank_change = inner_info.list[k].rank_change
                result.list[k].war_id = inner_info.list[k].war_id
                result.list[k].time = inner_info.list[k].time
            end
            result.war_count = inner_info.count
        end
        
        local result_length = 8 + result.war_count * sizeof(result.list[0])
        return result, result_length
    end
    
    processor_[C.kGetRankingTop] = function(msg)
        local result = new('GetRankingTopReturn', 0)
        local list_count = 0
        local inner_result, inner_info = instance.get_ranking_top()
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            for _,v in pairs(inner_info) do
                if not arena_info[v] then break end
                
                result.list[list_count].rank = v
                result.list[list_count].player = arena_info[v].player
                
                local base_info = data.GetPlayerBaseInfo(arena_info[v].player)
                if not base_info then break end
                
                result.list[list_count].nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
                result.list[list_count].level = base_info.game_info.level
                result.list[list_count].grade = GetGradeLevel(arena_info[v].player)
                
                list_count = list_count + 1
            end
        end
        
        result.list_count = list_count
        
        local result_length = 8 + list_count * sizeof(result.list[0])
        return result, result_length
    end
    
    processor_[C.kClearCDTime] = function(msg)
        local result = new('ClearCDTimeReturn', 0)
        local inner_result, inner_info = instance.clear_cd_time()
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.time = inner_info
        end
        return result
    end
    
    processor_[C.kBuyChallengeTimes] = function(msg)
        local result = new('BuyChallengeTimesReturn', 0)
        local inner_result, inner_info = instance.buy_count()
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.remain_count = inner_info[1]
            result.buy_count = inner_info[2]
        end
        return result
    end
    
    processor_[C.kGetRankReward] = function(msg)
        local result = new('GetRankRewardReturn', 0)
        local inner_result, inner_info = instance.get_rank_reward()
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.silver = inner_info[1]
            result.prestige = inner_info[2]
        end
        return result
    end
    
    processor_[C.kStartChallenge] = function(msg)
        local result = new('StartChallengeReturn', 0)
        local inner_result, inner_info = instance.start_challenge(cast('const StartChallenge&', msg).target_rank)
        local result_length = 4
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.victory = inner_info[1]
            result.silver = inner_info[2]
            result.prestige = inner_info[3]
            
            result.fight_record_bytes = inner_info[4]
            copy(result.fight_record, inner_info[5], result.fight_record_bytes)
            
            result_length = sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        return result, result_length
    end
    
    processor_[C.kGetFirstPlace] = function(msg)
        local result = new('GetFirstPlaceResult', 0)
        local inner_result, inner_info = instance.GetFirstPlace()
        local result_length = 4
        result.result = inner_result
        if result.result==C.ARENA_SUCCESS then
            result.time = inner_info[1]
            
            if result.time==0 then
                result_length = 8
            else
                
                result.winner = {#inner_info[2], inner_info[2]}
                result.loser = {#inner_info[3], inner_info[3]}
            
                result_length = 48
            end
        end
        return result, result_length
    end
    
    --外部自动调用的接口
    function obj.ProcessMsgFromDb(type, msg)
        local func = db_processor_[type]
        if func then func(msg) end
    end
    function obj.ProcessMsg(type, msg)
        local func = processor_[type]
        if func then
            local result, result_length = func(msg)
            if result.result==C.ARENA_SUCCESS then
                result.result = 0
            end
            return result, result_length
        end
    end
    
    function obj.CanGetReward()
        if not arena_info[arena_rank[uid]] then return 0 end
        return arena_info[arena_rank[uid]].reward==0 and 0 or 1
    end
    
    function obj.AppendArenaHistory(player_id, initiative, winner, rank, war_id, time)
        --修改最近战报
        for k=this.history.count-1,0,-1 do
            if k~=4 then
                this.history.list[k+1].target_id = this.history.list[k].target_id
                this.history.list[k+1].initiative = this.history.list[k].initiative
                this.history.list[k+1].winner = this.history.list[k].winner
                this.history.list[k+1].rank_change = this.history.list[k].rank_change
                this.history.list[k+1].war_id = this.history.list[k].war_id
                this.history.list[k+1].time = this.history.list[k].time
            end
        end

        this.history.list[0].target_id = player_id
        this.history.list[0].initiative = initiative
        this.history.list[0].winner = winner
        this.history.list[0].rank_change = rank
        this.history.list[0].war_id = war_id
        this.history.list[0].time = time
        
        if this.history.count~=5 then this.history.count = this.history.count + 1 end
    end
    
    --修改次数
    function obj.ModifyCount(delta)
        this.info.count = this.info.count - delta
        player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfCount, this.info.count})
    end
    
    return obj
end
