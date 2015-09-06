--护送系统

require('data')
require('fight.fight_mgr')
local config = require('config.global')
local action_id = require('define.action_id')
local gold_consume_flag = require('define.gold_consume_flag')
require('achievement')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local copy = ffi.copy

local escort_cfg = require('config.escort_transport')
local escort_ratio = require('config.escort_ratio')
local assistant_id = require('config.assistant_task_id')

local escort_wait = {}

--返回值，判断执行结果
local RESULT = table.enum(12200, {"SUCCESS", "NOT_ACTIVATE", "NOT_ENOUGH_GOLD", "ON_THE_TOP", "NO_MORE_TIMES", "ON_THE_WAY", "INVALID_TRANSPORT", "INVALID_PAGE", "INVALID_TARGET", "DONT_NEED_CLEAR"})

function CreateEscort(this, player, escort_info, escort_road,escort_news)
    local obj = {}
    
    local uid = player.GetUID()
    
    --获取保护比例
    local function GetLevelRatio(level_diff)
        if level_diff<=5 then
            return 1
        else
            if level_diff<=10 then
                return 0.8 - (level_diff-5)*0.1
            else
                return 0.2
            end
        end
    end
    
    --获取护送状态
    function obj.GetEscortStatus()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        local time = 0
        if this.road and this.road.ready then
            time = this.road.time + escort_cfg[this.road.transport].time
        end
        
        return RESULT.SUCCESS, {config.escort.can_escort - this.info.count, config.escort.can_defend - this.info.defend_count, config.escort.can_intercept - this.info.intercept, time, this.info.time}
    end
    
    --获取护送新闻
    function obj.GetEscortNews()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS
    end
    
    --进入护送区域
    function obj.EnterEscortPlace()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        escort_wait[uid] = true
        
        return RESULT.SUCCESS
    end
    
    --退出护送区域
    function obj.LeaveEscortPlace()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        escort_wait[uid] = nil
        
        return RESULT.SUCCESS
    end
    
    --获取护送区域信息
    function obj.GetEscortInfo()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS
    end
    
    --设置自动应答
    function obj.SetAutoAccept(transport)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查交通工具是否正确
        --if transport<1 or transport>5 then
        if transport~=4 then
            this.info.auto_accept = 0
        else
            this.info.auto_accept = transport
        end
        player.UpdateField(C.ktEscortInfo, C.kInvalidID, {C.kfAutoAccept, transport})
        
        return RESULT.SUCCESS
    end
    
    --刷新交通工具
    function obj.RefreshTransport()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否需要刷新
        if this.info.transport==5 then return RESULT.ON_THE_TOP end
        
        --检查元宝是否足够
        local gold = config.escort.price * (this.info.refresh + 1)
        if not player.IsGoldEnough(gold) then return RESULT.NOT_ENOUGH_GOLD end
        
        player.ConsumeGold(gold, gold_consume_flag.escort_refresh)
        
        if math.random()<escort_cfg[this.info.transport].probability then
            this.info.transport = this.info.transport + 1
        else
            this.info.transport = 1
        end
        
        --保存改变到数据库
        this.info.refresh = this.info.refresh + 1
        player.UpdateField(C.ktEscortInfo, C.kInvalidID, {C.kfTransport, this.info.transport}, {C.kfRefresh, this.info.refresh})
        
        return RESULT.SUCCESS, this.info.transport
    end
    
    
    --开始护送
    function obj.StartEscort()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否还有护送次数
        if config.escort.can_escort - this.info.count <= 0 then return RESULT.NO_MORE_TIMES end
        
        --检查是否正在护送
        if this.road and this.road.ready then return RESULT.ON_THE_WAY end
        
        --插入新闻
        if this.info.transport>=4 then
            if #escort_news==5 then table.remove(escort_news, 1) end
            
            local news = {}
            news.isRob = false
            news.type = this.info.transport
            news.escort = uid
            
            table.insert(escort_news, news)
            
            obj.PushEscortNews(news)
        end
        
        --插入丝绸之路
        escort_road[uid] = {}
        this.road = escort_road[uid]
        this.road.ready = true
        escort_road[uid].road = this.road
        this.road.transport = this.info.transport
        
        this.road.guardian = 0
        if this.info.invite_respond then
            if os.time()-this.info.invite_respond.time<=config.escort.timeout then
                local info = GetEscortInfoByUID(this.info.invite_respond.guardian)
                if info and info.defend_count<config.escort.can_defend then
                    this.road.guardian = this.info.invite_respond.guardian
                    
                    info.defend_count = info.defend_count + 1
                    info.defend_total = info.defend_total + 1
                    player.UpdateOtherField(C.ktEscortInfo, this.road.guardian, {C.kfDefendCount, info.defend_count}, {C.kfDefendTotal, info.defend_total})
                    
                    local result = new('PushEscortInviteResult')
                    result.count = config.escort.can_defend - info.defend_count
                    GlobalSend2Gate(this.road.guardian, result)
                    
                    RecordOfflinePlayerAction(this.road.guardian, action_id.kEscortHelp, 1)
                end
            end
        end
        
        this.road.time = os.time()
        this.road.count = 0
        this.road.looter1 = 0
        this.road.looter2 = 0
        this.road.silver = escort_cfg[this.road.transport].silver * escort_ratio[ player.GetLevel() ].ratio
        this.road.prestige = escort_cfg[this.road.transport].prestige
        player.InsertRow(C.ktEscortRoad, {C.kfTransport, this.road.transport}, {C.kfGuardian, this.road.guardian}, {C.kfTime, this.road.time}, {C.kfSilver, this.road.silver}, {C.kfPrestige, this.road.prestige})
        obj.PushEscortInfo(this.road)
        
        --改变统计信息
        this.info.transport = 1
        this.info.count = this.info.count + 1
        player.UpdateField(C.ktEscortInfo, C.kInvalidID, {C.kfCount, this.info.count}, {C.kfTransport, this.info.transport})
        
        player.AssistantCompleteTask(assistant_id.kEscort, config.escort.can_escort - this.info.count)
        player.RecordAction(action_id.kEscort, 1)
        player.RecordAction(action_id.kEscortTool, 1, this.road.transport)
        
        return RESULT.SUCCESS
    end
    
    --护送详细信息
    function obj.GetEscortInfoDetail(target_id)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        local detail_info = escort_road[target_id]
        local base_info = data.GetPlayerBaseInfo(target_id)
        if not detail_info or not base_info then return RESULT.INVALID_TARGET end
        
        local silver = 0
        local prestige = 0
        
        local count = detail_info.count
        if detail_info.looter1==uid or detail_info.looter2==uid then count = 3 end
        if detail_info.guardian==uid then count = 4 end
        
        if target_id==uid then
            silver = this.road.silver
            prestige = this.road.prestige
        else
            if count==4 then
                local score_ratio = {0,3,6}
                local prestige_ratio = {0,0.5,1}
                silver = score_ratio[detail_info.count + 1]
                prestige = escort_cfg[detail_info.transport].prestige * prestige_ratio[detail_info.count + 1]
            else
                if count<2 then
                    local ratio = GetLevelRatio( player.GetLevel() - base_info.game_info.level )
                    silver = math.floor( escort_cfg[detail_info.transport].silver * escort_ratio[ base_info.game_info.level ].ratio * 0.2 * ratio )
                    prestige = math.floor( escort_cfg[detail_info.transport].prestige * 0.2 * ratio )
                end
            end
        end
        
        return RESULT.SUCCESS, {base_info, detail_info, count, silver, prestige}
    end
    
    --护卫排行榜
    function obj.GetEscortRank(page)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查页数是否正确
        local page_total = math.ceil(#escort_info/10)
        if page<1 or page>page_total then return RESULT.INVALID_PAGE end
        
        local begin = 1+(page-1)*10
        local over = 10+(page-1)*10
        
        if over>#escort_info then over = #escort_info end
        
        return RESULT.SUCCESS, {page_total, begin, over}
    end
    
    --打劫
    function obj.RobEscort(target)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查冷却时间
        if this.info.time>os.time() then return RESULT.INVALID_TARGET end
        
        --检查是否还有打劫次数
        if config.escort.can_intercept - this.info.intercept <= 0 then return RESULT.NO_MORE_TIMES end
        
        --检查目标是否正确
        local road_info = escort_road[target]
        local stat_info = GetEscortInfoByUID(uid)
        local base_info = data.GetPlayerBaseInfo(target)
        if not road_info or not stat_info or not base_info then return RESULT.INVALID_TARGET end
        
        --检查是否已经被打劫过2次
        if road_info.count >= 2 then return RESULT.NO_MORE_TIMES end
        
        --检查是否已经被打劫过
        if road_info.looter1==uid or road_info.looter2==uid then return RESULT.NO_MORE_TIMES end
        
        --是否是监守自盗
        if road_info.guardian==uid then return RESULT.INVALID_TARGET end
        
        --是否有帮手
        local target_id = road_info.guardian
        if target_id==0 then target_id = target end
        
        player.RecordAction(action_id.kEscortRob, 1)
        
        local silver = 0
        local prestige = 0
            
        --开始战斗
        local heros_group,array = player.GetHerosGroup()
        local heros_group2,array2 = data.GetPlayerHerosGroup(target_id)
        local env = {type=4, weather='sunny', terrain='wasteland', group_a={name=player.GetName(),array=array}, group_b={name=data.GetPlayerName(target_id),array=array2}}
        
        local fight = CreateFight(heros_group, heros_group2, env)
        local record, record_len = fight.GetFightRecord()
        local winner = fight.GetFightWinner()
        
        this.info.time = os.time() + config.escort.cd_time
        
        winner = 1 - winner
        if winner==1 then
            if road_info.guardian~=0 then
                RecordOfflinePlayerAction(uid, action_id.kEscortRobHelp, 1)
            end
            
            --胜利
            this.info.win_count = this.info.win_count + 1
            
            stat_info.win_count = 0
            
            local ratio = GetLevelRatio( player.GetLevel() - base_info.game_info.level )
            silver = math.floor( escort_cfg[road_info.transport].silver * escort_ratio[ base_info.game_info.level ].ratio * 0.2 * ratio )
            prestige = math.floor( escort_cfg[road_info.transport].prestige * 0.2 * ratio )
            
            player.ModifySilver(silver)
            player.ModifyPrestige(prestige)
            
            --信息改变
            this.info.intercept = this.info.intercept + 1
            
            road_info.count = road_info.count + 1
            road_info.silver = road_info.silver - silver
            road_info.prestige = road_info.prestige - prestige
            
            player.UpdateOtherField(C.ktEscortRoad, target, {C.kfCount, road_info.count}, {C.kfSilver, road_info.silver}, {C.kfPrestige, road_info.prestige})
            
            if road_info.count==0 then
                road_info.looter1 = uid
                player.UpdateOtherField(C.ktEscortRoad, target, {C.kfLooter1, uid})
            else
                road_info.looter2 = uid
                player.UpdateOtherField(C.ktEscortRoad, target, {C.kfLooter2, uid})
            end
            
            if road_info.guardian~=0 then
                player.RecordAction(action_id.kEscortRobHelp, 1)
            end
            
            --插入新闻
            if #escort_news==5 then table.remove(escort_news, 1) end
            
            local news = {}
            news.isRob = true
            news.type = road_info.transport
            news.looter = uid
            news.escort = target
            news.silver = silver
            news.prestige = prestige
            
            table.insert(escort_news, news)
            
            obj.PushEscortNews(news)
        else
            --失败
            this.info.win_count = 0

            stat_info.win_count = stat_info.win_count + 1
        end
        
        player.UpdateField(C.ktEscortInfo, C.kInvalidID, {C.kfTime, this.info.time}, {C.kfWinCount, this.info.win_count}, {C.kfIntercept, this.info.intercept})
        player.UpdateOtherField(C.ktEscortInfo, target, {C.kfWinCount, stat_info.win_count})
        
        --发送给相关人员
        local result = new('PushEscortBeRobed')
        result.isHelper = 0
        result.type = road_info.transport
        result.victory = 1 - winner
        result.silver = silver
        result.prestige = prestige
        result.nickname = player.GetCNickname()
        
        result.fight_record_bytes = record_len
        copy(result.fight_record, record, result.fight_record_bytes)
        
        local target_player = this.online_players[target]
        if target_player then
            --被打劫者在线
            
            target_player.Send2Gate(result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes)
        else
            --被打劫者不在线，写入到数据库中保存
            GlobalInsertRow(C.ktEscortRobbed, {C.kfPlayer, target}, {C.kfRobber, uid}, {C.kfTransport, road_info.transport}, {C.kfWinner, winner}, {C.kfSilver, silver}, {C.kfPrestige, prestige})
        end
        
        if road_info.guardian ~= 0 then
            local guardian_player = this.online_players[road_info.guardian]
            if guardian_player then
                --护卫者在线
                result.isHelper = 1
                
                guardian_player.Send2Gate(result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes)
            else
                --护卫者不在线，写入到数据库中保存
                if winner==1 then
                    GlobalInsertRow(C.ktEscortRobbed, {C.kfPlayer, road_info.guardian}, {C.kfRobber, uid}, {C.kfHelp, 1}, {C.kfTransport, road_info.transport}, {C.kfSilver, silver}, {C.kfPrestige, prestige})
                else
                    GlobalInsertRow(C.ktEscortRobbed, {C.kfPlayer, road_info.guardian}, {C.kfRobber, uid}, {C.kfHelp, 1}, {C.kfTransport, road_info.transport}, {C.kfWinner, winner})
                end
            end
        end
        
        return RESULT.SUCCESS, {this.info.time, winner, silver, prestige, record_len, record}
    end
    
    --发起邀请
    function obj.InviteEscortRequest(target)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if target==uid then return RESULT.SUCCESS, 1 end
        
        local info = GetEscortInfoByUID(target)
        if not info then return RESULT.SUCCESS, 2 end
        
        if info.defend_count>=config.escort.can_defend then return RESULT.SUCCESS, 3 end
        
        if info.auto_accept>this.info.transport then return RESULT.SUCCESS, 4 end
            
        if not this.online_players[target] then
            --玩家不在线
            if info.auto_accept==0 then return RESULT.SUCCESS, 5 end
        end
        
        if info.auto_accept==0 then
            --等待在线玩家回应
            if not this.info.invite or os.time()-this.info.invite.time>config.escort.timeout then
                this.info.invite = {}
                this.info.invite.guardian = target
                this.info.invite.time = os.time()
                
                local result = new('PushEscortInviteRequest')
                result.id = uid
                result.nickname = player.GetCNickname()
                result.type = this.info.transport
                GlobalSend2Gate(target, result)
            end
            
            return RESULT.SUCCESS, 6
        end

        --自动同意护送
        this.info.invite_respond = {}
        this.info.invite_respond.guardian = target
        this.info.invite_respond.time = os.time()
        
        return RESULT.SUCCESS, 0
    end
    
    --回应邀请
    function obj.InviteEscortRespond(target,agree)
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        local info = GetEscortInfoByUID(target)
        if not info or not info.invite or info.invite.guardian~=uid then return RESULT.SUCCESS, 1 end
        
        if os.time()-info.invite.time>config.escort.timeout then return RESULT.SUCCESS, 2 end
        
        if escort_road[target] then return RESULT.SUCCESS, 3 end
        
        if agree==1 then
            info.invite_respond = {}
            info.invite_respond.guardian = uid
            info.invite_respond.time = os.time()
        end
        
        local result = new('PushEscortInviteRespond')
        result.nickname = player.GetCNickname()
        result.agree = agree==1 and 1 or 0
        GlobalSend2Gate(target, result)
        
        return RESULT.SUCCESS, 0
    end
    
    --清除打劫CD
    function obj.ClearEscortCD()
        --检查是否开启护送功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查冷却时间
        if this.info.time<=os.time() then return RESULT.DONT_NEED_CLEAR end
        
        --检查是否还有打劫次数
        if config.escort.can_intercept - this.info.intercept <= 0 then return RESULT.DONT_NEED_CLEAR end
        
        --检查元宝是否足够
        local gold = math.ceil( (this.info.time - os.time())/60 ) * config.escort.clear_cd_price
        if not player.IsGoldEnough(gold) then return RESULT.NOT_ENOUGH_GOLD end
        
        player.ConsumeGold(gold, gold_consume_flag.escort_clear_cd)
        
        this.info.time = 0
        
        --保存改变到数据库
        player.UpdateField(C.ktEscortInfo, C.kInvalidID, {C.kfTime, this.info.time})
        
        return RESULT.SUCCESS
    end
    
    --推送信息
    function obj.PushEscortNews(news)
        local result = new('PushEscortNews')
        result.news.isRob = news.isRob and 1 or 0
        result.news.type = news.type
        if news.isRob then
            result.news.news.looter.looter = data.GetCPlayerName(news.looter)
            result.news.news.looter.escort = data.GetCPlayerName(news.escort)
            result.news.news.looter.silver = news.silver
            result.news.news.looter.prestige = news.prestige
        else
            result.news.news.escort.escort = data.GetCPlayerName(news.escort)
        end
        for player_id,_ in pairs(escort_wait) do
            if not this.online_players[player_id] then
                escort_wait[player_id] = nil
            else
                GlobalSend2Gate(player_id, result)
            end
        end
    end
    
    function obj.PushEscortInfo(road)
        local result = new('PushEscortInfo')

        result.info.id = uid
        result.info.time = os.time() - road.time
        result.info.type = road.transport
            
        for player_id,_ in pairs(escort_wait) do
            if not this.online_players[player_id] then
                escort_wait[player_id] = nil
            else
                GlobalSend2Gate(player_id, result)
            end
        end
    end
    
    return obj
end

function EscortDestroy(uid)
    escort_wait[uid] = nil
end