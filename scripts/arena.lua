--竞技场模块
require('data')
require('fight.fight_mgr')
local config = require('config.global')
local action_id = require('define.action_id')
local reward_cfg = require('config.arena_reward')
local reward_ratio = require('config.arena_reward_ratio')
local arena_count = require('config.arena_count')
local assistant_id = require('config.assistant_task_id')
local gold_consume_flag = require('define.gold_consume_flag')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local copy = ffi.copy

require('fight.save_record')
require('global_data')
require('tools.serialize')

--返回值，判断执行结果
local RESULT = table.enum(12000, {"SUCCESS", "NOT_ENOUGH_GOLD", "NOT_ENOUGH_CHALLENGE_TIMES", "NOT_ENOUGH_BUY_TIMES", "NOT_YET_ACTIVATE", "HAVE_CD_TIME", "INVALID_TARGET", "INVALID_STEP", "CANT_GETBACK_REWARD", "NO_GETBACK_REWARD", "NOT_ENOUGH_REWARD", "NO_NEED_CLEAR_CD"})

--挑战列表个数
local challenge_count = 5

--第一名新闻
local first_place_file = "/tmp/arean_first_place_news_serialized_file"
local first_place_news = loadfile(first_place_file)
if first_place_news then first_place_news = first_place_news() end

function CreateArena(player, this, arena_info, arena_rank)
    local obj = {}
    
    local uid = player.GetUID()
    
    --挑战阶梯规则
    local challenge_step_cfg = {[100]=1, [200]=2, [500]=3, [1000]=5, [2000]=10, [5000]=20, [10000]=50, outside=50}
    local function get_challenge_step(rank)
        local step = 0
        for k,v in pairs(challenge_step_cfg) do
            if tonumber(k) and rank<=k then
                if step==0 or step>v then step = v end
            end
        end

        if step==0 then step = challenge_step_cfg.outside end
        return step
    end


    --获取竞技场信息
    function obj.get_info()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        local info = arena_info[arena_rank[uid]]

        return RESULT.SUCCESS, {arena_rank[uid], this.info.time, config.arena.max_count - this.info.count, info.win_count, info.reward~=0 and 1 or 0, arena_count[player.GetVIPLevel()].count - this.info.buy_count}
    end

    --获取挑战列表
    function obj.get_challenge_list()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        local targets = {}
        local rank = arena_rank[uid]
        if rank<challenge_count+1 then
            targets = {6, 5, 4, 3, 2, 1}
            table.remove(targets, challenge_count + 2 - rank)
        else
            local last_rank = rank - get_challenge_step(rank)
            for _=1,challenge_count do
                table.insert(targets, last_rank)
                last_rank = last_rank - get_challenge_step(last_rank)
            end
        end
        return RESULT.SUCCESS, targets
    end

    --获取最近5场战报
    function obj.get_war_report()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        return RESULT.SUCCESS, this.history
    end

    --获取排行榜【前10名玩家】
    function obj.get_ranking_top()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        local targets = {}
        for i=1,10 do
            targets[i] = i
        end
        return RESULT.SUCCESS, targets
    end

    --清除当前CD
    function obj.clear_cd_time()
        local function get_clear_gold(time)
            time = time - os.time()
            if time<=0 then return 0 end        --超过CD时间不需要清除CD

            return math.ceil(time/60) * config.arena.clear_cd_price
        end
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        local clear_need_gold = get_clear_gold(this.info.time)

        --检查是否需要清除CD
        if clear_need_gold==0 or this.info.count>=config.arena.max_count then return RESULT.NO_NEED_CLEAR_CD end

        --检查元宝是否足够
        if not player.IsGoldEnough(clear_need_gold) then return RESULT.NOT_ENOUGH_GOLD end

        player.ConsumeGold(clear_need_gold, gold_consume_flag.arena_clear_cd)
        this.info.time = 0

        --保存改变到数据库
        player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfTime, this.info.time})

        return RESULT.SUCCESS, this.info.time
    end

    --购买挑战次数
    function obj.buy_count()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        --检查元宝是否足够
        local cost = config.arena.buy_times_price * (this.info.buy_count + 1)
        if not player.IsGoldEnough(cost) then return RESULT.NOT_ENOUGH_GOLD end

        --检查VIP等级可买次数
        if this.info.buy_count>=arena_count[player.GetVIPLevel()].count then return RESULT.NOT_ENOUGH_BUY_TIMES end

        player.ConsumeGold(cost, gold_consume_flag.arena_buy_count)
        this.info.count = this.info.count - 1
        this.info.buy_count = this.info.buy_count + 1

        --保存改变到数据库
        player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfCount, this.info.count}, {C.kfBuyCount, this.info.buy_count})
        player.AssistantSetRemainTimes(assistant_id.kArenaChallenge, config.arena.max_count - this.info.count)

        return RESULT.SUCCESS, { config.arena.max_count - this.info.count, arena_count[player.GetVIPLevel()].count - this.info.buy_count }
    end

    --获取排名奖励
    function obj.get_rank_reward()
        local function GetReward(rank)
            local index = 1
            
            for i,v in ipairs(reward_cfg) do
                if rank<v.rank[1] or v.rank[2]==-1 then
                    index = i - 1
                    break
                end
            end
            
            local diff = rank - reward_cfg[index].rank[1]
            return reward_cfg[index].silver - diff * reward_cfg[index].silver_decrease, reward_cfg[index].prestige - diff * reward_cfg[index].prestige_decrease
        end
        
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        local info = arena_info[arena_rank[uid]]

        --检查是否可以领取奖励
        if info.reward==0 then return RESULT.NOT_ENOUGH_REWARD end

        local silver, prestige = GetReward(info.reward)
        
        silver = silver * reward_ratio[ player.GetLevel() ].ratio
        
        player.ModifySilver(silver)
        player.ModifyPrestige(prestige)

        info.reward = 0
        player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfReward, info.reward})

        return RESULT.SUCCESS, {silver, prestige}
    end
    
    --开始挑战
    function obj.start_challenge(target_rank)
        local function InTable(t, f)
            for _,v in ipairs(t) do
                if v==f then return true end
            end
            return false
        end
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end

        --检查目标是否合法
        local target_id = arena_info[target_rank].player
        if not target_id then return RESULT.INVALID_TARGET end

        --检查CD
        if this.info.time>os.time() then return RESULT.HAVE_CD_TIME end

        --检查次数
        if this.info.count>=config.arena.max_count then return RESULT.NOT_ENOUGH_CHALLENGE_TIMES end

        --检查梯度是否正确1
        local self_rank = arena_rank[uid]
        if target_rank==self_rank or target_id==uid then return RESULT.INVALID_STEP end

        --检查梯度是否正确2
        local _, targets = obj.get_challenge_list()
        if not InTable(targets, target_rank) then return RESULT.INVALID_STEP end

        local src_info = arena_info[self_rank]
        local dst_info = arena_info[target_rank]

        --开始战斗
        local heros_group,array = player.GetHerosGroup()
        local heros_group2,array2 = data.GetPlayerHerosGroup(target_id)
        
        local env = {type=2, weather='cloudy', terrain='citadel', group_a={name=player.GetName(),sex=player.GetSex(),array=array,level=player.GetLevel()}, group_b={name=data.GetPlayerName(target_id),sex=data.GetPlayerSex(target_id),array=array2,level=data.GetPlayerLevel(target_id)}}
        local fight = CreateFight(heros_group, heros_group2, env)
        local record, record_len = fight.GetFightRecord()
        local winner = fight.GetFightWinner()
        local war_id = SaveBattleRecord(record, record_len)

        --信息改变
        local time = os.time()
        
        local rank_change1 = 0
        local rank_change2 = 0
        this.info.count = this.info.count + 1

        local silver = data.GetPlayerLevel(target_id) * 10
        local prestige = 5
        

        winner = 1 - winner
        if winner==1 then
            --如果胜利，改变排名
            src_info.win_count = src_info.win_count + 1
            dst_info.win_count = 0
            
            player.RecordAction(action_id.kArenaWinning, src_info.win_count)
            
            --连胜通知
            if src_info.win_count>=5 then
                local ArenaWinner = new('ArenaWinner')
                ArenaWinner.name = player.GetCNickname()
                ArenaWinner.uid = uid
                ArenaWinner.count = src_info.win_count
                GlobalSend2Gate(-1, ArenaWinner)
            end
            
            silver = data.GetPlayerLevel(target_id) * 20
            prestige = 10
            player.ModifySilver(silver)
            player.ModifyPrestige(prestige)

            if self_rank > target_rank then
                rank_change1 = target_rank
                rank_change2 = -self_rank

                arena_info[target_rank], arena_info[self_rank] = arena_info[self_rank], arena_info[target_rank]
                arena_rank[uid], arena_rank[target_id] = target_rank, self_rank
                self_rank, target_rank = target_rank, self_rank

                player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfRank, self_rank})
                player.UpdateOtherField(C.ktArenaInfo, target_id, {C.kfRank, target_rank})
                
                --名次
                if self_rank<=3 then
                    local ArenaTop = new('ArenaTop')
                    ArenaTop.winner = player.GetCNickname()
                    ArenaTop.loser = data.GetCPlayerName(target_id)
                    ArenaTop.uid1 = uid
                    ArenaTop.uid2 = target_id
                    ArenaTop.rank = self_rank
                    GlobalSend2Gate(-1, ArenaTop)
                
                    --第一名新闻保存
                    if self_rank==1 then
                        first_place_news = {}
                        first_place_news.time = time
                        first_place_news.winner = player.GetName()
                        first_place_news.loser = data.GetPlayerName(target_id)
                        
                        --保存到文件
                        local str = serialize(first_place_news)
                        local f = io.open(first_place_file, 'w')
                        f:write(str)
                        f:close()
                    end
                end
            end
        else
            src_info.win_count = 0
            dst_info.win_count = dst_info.win_count + 1
            
            player.ModifySilver(silver)
            player.ModifyPrestige(prestige)
            
            this.info.time = time + config.arena.cd_time
        end
        
        if self_rank<=100 then
            player.RecordAction(action_id.kArenaRank, 1)
        end
        
        player.AssistantCompleteTask(assistant_id.kArenaChallenge, config.arena.max_count - this.info.count)

        --保存改变到数据库
        player.InsertRow(C.ktArenaHistory, {C.kfTarget,target_id}, {C.kfWinner, winner}, {C.kfRankSelf, rank_change1}, {C.kfRankTarget, rank_change2}, {C.kfWarID, war_id}, {C.kfTime, time})
        player.UpdateField(C.ktArenaInfo, C.kInvalidID, {C.kfTime, this.info.time}, {C.kfCount, this.info.count}, {C.kfWinCount, src_info.win_count})
        player.UpdateOtherField(C.ktArenaInfo, target_id, {C.kfWinCount, dst_info.win_count})
        
        --刷新最近战报
        player.AppendArenaHistory(target_id, 1, winner, rank_change1, war_id, time)
        
        --对方虽然打输了，但是排名未变
        local rank_change = rank_change2
        if rank_change2==0 and winner==1 then
            rank_change = 1
        end
            
        --发送消息到对方
        local target_player = data.GetOnlinePlayer(target_id)
        if target_player then
            --被挑战者在线
            
            --刷新最近战报
            target_player.AppendArenaHistory(uid, 0, 1 - winner, rank_change2, war_id, time)
        
            --发送改变消息
            local result = new('PushOccurredChallenge')
            result.nickname = player.GetCNickname()
            
            result.rank_change = rank_change
            
            result.war_id = war_id
            result.fight_record_bytes = record_len
            copy(result.fight_record, record, result.fight_record_bytes)
            GlobalSend2Gate(target_id, result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes)
        else
            --被挑战者不在线，写入到数据库中保存
            GlobalInsertRow(C.ktArenaChallenge, {C.kfPlayer, target_id}, {C.kfChallenger, uid}, {C.kfRankChange, rank_change}, {C.kfWarID, war_id})
        end

        return RESULT.SUCCESS, {winner, silver, prestige, record_len, record}
    end

    --获取第一名新闻
    function obj.GetFirstPlace()
        --检查是否开启了竞技场
        if not arena_rank[uid] then return RESULT.NOT_YET_ACTIVATE end
        
        if not first_place_news then
            return RESULT.SUCCESS, {0}
        end

        return RESULT.SUCCESS, {first_place_news.time, first_place_news.winner, first_place_news.loser}
    end
    
    return obj
end
