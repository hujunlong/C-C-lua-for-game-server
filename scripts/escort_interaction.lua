--护送交互【客户端、数据库】

require('data')
require('global_data')
require('tools.time')
local config = require('config.global')
local action_id = require('define.action_id')
require('achievement')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local cast = ffi.cast
local sizeof = ffi.sizeof
local copy = ffi.copy

local online_players = {}
function EscortInitialize(all_players)
    online_players = all_players
end

--全局信息
local escort_info = data.GetAllEscortInfo()
local escort_road = data.GetAllEscortRoad()
local escort_news = {}

function GetEscortInfoByUID(uid)
    for _,v in ipairs(escort_info) do
        if v.player==uid then return v end
    end
end

local escort_cfg = require('config.escort_transport')
require('escort')

function EscortInteraction(player)
    local obj = {}
    
    --数据保存
    local this = {}
    this.activate = false         --是否激活
    this.online_players = online_players
    
    local instance = CreateEscort(this, player, escort_info, escort_road,escort_news)
    
    --数据库消息处理
    local db_processor_ = {}
    db_processor_[C.kEscortInfo] = function(msg)
        local db_escort_info = cast('const EscortInfo&', msg)
        
        this.road = escort_road[player.GetUID()]
        if this.road then
            this.road.ready = true
            escort_road[player.GetUID()].road = this.road
        end
    
        this.info = GetEscortInfoByUID(player.GetUID())
        this.info.count = db_escort_info.count
        this.info.intercept = db_escort_info.intercept
        this.info.transport = db_escort_info.transport
        this.info.time = db_escort_info.time
        this.info.refresh = db_escort_info.refresh
        
        this.activate = true
    end
    db_processor_[C.kEscortReward] = function(msg)
        local escort_reward = cast('const EscortRewardList&', msg)
        for i=0,escort_reward.count-1 do
            local result = new('PushEscortReward')
            result.isOnline = 0
            result.isHelper = escort_reward.list[i].help
            result.count = escort_reward.list[i].count
            result.type = escort_reward.list[i].transport
            result.silver = escort_reward.list[i].silver
            result.prestige = escort_reward.list[i].prestige
            
            player.Send2Gate(result)
        end
    end
    db_processor_[C.kEscortRobbed] = function(msg)
        local escort_robbed = cast('const EscortRobbedList&', msg)
        for i=0,escort_robbed.count-1 do
            local result = new('PushEscortBeRobed')
            result.isHelper = escort_robbed.list[i].help
            result.type = escort_robbed.list[i].transport
            result.victory = escort_robbed.list[i].winner
            result.silver = escort_robbed.list[i].silver
            result.prestige = escort_robbed.list[i].prestige
            result.nickname = data.GetCPlayerName(escort_robbed.list[i].robber)
            
            result.fight_record_bytes = 0
            
            player.Send2Gate(result, sizeof(result) - C.kMaxFightRecordLength)
        end
    end
    
    --开启
    function obj.open()
        if not this.activate then
            player.InsertRow(C.ktEscortInfo, {C.kfCount, 0})
            
            local info = {}
            info.player = player.GetUID()
            info.defend_count = 0
            info.defend_total = 0
            info.win_count = 0
            info.score = 0
            info.auto_accept = 0
            table.insert(escort_info, info)

            this.info = info
            this.info.count = 0
            this.info.intercept = 0
            this.info.transport = 1
            this.info.time = 0
            this.info.refresh = 0
        
            this.activate = true
        end
    end
    
    --客户端消息处理
    local processor_ = {}
    
    --获取护送状态
    processor_[C.kGetEscortStatus] = function(msg)
        local result = new('GetEscortStatusReturn', 0)
        local inner_result, inner_info = instance.GetEscortStatus()
        result.result = inner_result
        if result.result==C.ESCORT_SUCCESS then
            result.escort_count = inner_info[1]
            result.defend_count = inner_info[2]
            result.intercept_count = inner_info[3]
            result.auto_accept = this.info.auto_accept
            result.time = inner_info[4]
            result.type = this.info.transport
            result.refresh = this.info.refresh
            result.rob_time = inner_info[5]
        end
        return result
    end
    
    --获取护送新闻
    processor_[C.kGetEscortNews] = function(msg)
        local result = new('GetEscortNewsReturn', 0)
        result.count = 0
        local inner_result, inner_info = instance.GetEscortNews()
        result.result = inner_result
        if result.result==C.ESCORT_SUCCESS then
            for _,news in pairs(escort_news) do
                result.list[result.count].isRob = news.isRob and 1 or 0
                result.list[result.count].type = news.type
                if news.isRob then
                    result.list[result.count].news.looter.looter = data.GetCPlayerName(news.looter)
                    result.list[result.count].news.looter.escort = data.GetCPlayerName(news.escort)
                    result.list[result.count].news.looter.silver = news.silver
                    result.list[result.count].news.looter.prestige = news.prestige
                else
                    result.list[result.count].news.escort.escort = data.GetCPlayerName(news.escort)
                end
                result.count = result.count + 1
            end
        end
        
        return result, 8 + result.count * sizeof(result.list[0])
    end
    
    --进入护送区域
    processor_[C.kEnterEscortPlace] = function(msg)
        local result = new('EnterEscortPlaceReturn', 0)
        result.result = instance.EnterEscortPlace()
        return result
    end
    
    --退出护送区域
    processor_[C.kLeaveEscortPlace] = function(msg)
        local result = new('EnterEscortPlaceReturn', 0)
        result.result = instance.LeaveEscortPlace()
        return result
    end
    
    --获取护送区域信息
    processor_[C.kGetEscortInfo] = function(msg)
        local result = new('GetEscortInfoReturn', 0)
        result.count = 0
        result.result = instance.GetEscortInfo()
        if result.result==C.ESCORT_SUCCESS then
            for id,road in pairs(escort_road) do
                result.list[result.count].id = id
                result.list[result.count].time = os.time() - road.time
                result.list[result.count].type = road.transport
                
                result.count = result.count + 1
                if result.count>=512 then break end
            end
        end
        
        return result, 8 + result.count * sizeof(result.list[0])
    end
    
    --设置自动应答
    processor_[C.kSetAutoAccept] = function(msg)
        local result = new('SetAutoAcceptReturn', 0)
        result.result = instance.SetAutoAccept(cast('const SetAutoAccept&', msg).type)
        return result
    end
    
    --刷新交通工具
    processor_[C.kRefreshTransport] = function(msg)
        local result = new('RefreshTransportReturn', 0)
        local inner_result, inner_info = instance.RefreshTransport()
        result.result = inner_result
         if result.result==C.ESCORT_SUCCESS then
            result.type = inner_info
         end
        return result
    end
    
    --开始护送
    processor_[C.kStartEscort] = function(msg)
        local result = new('StartEscortReturn', 0)
        result.result = instance.StartEscort()
        return result
    end
    
    --护送详细信息
    processor_[C.kGetEscortInfoDetail] = function(msg)
        local result = new('GetEscortInfoDetailReturn', 0)
        local inner_result, inner_info = instance.GetEscortInfoDetail(cast('const GetEscortInfoDetail&', msg).uid)
        result.result = inner_result
        if result.result==C.ESCORT_SUCCESS then
            result.info.nickname = {inner_info[1].role.nickname.len, inner_info[1].role.nickname.str}
            result.info.level = inner_info[1].game_info.level
            result.info.type = inner_info[2].transport
            result.info.count = inner_info[3]
            if inner_info[2].guardian~=0 then
                local base_info = data.GetPlayerBaseInfo(inner_info[2].guardian)
                result.info.guard_nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
                result.info.guard_level = base_info.game_info.level
            else
                result.info.guard_level = 0
            end
            
            result.info.silver = inner_info[4]
            result.info.prestige = inner_info[5]
            
            return result
        end
    end
    
    --护卫排行榜
    processor_[C.kGetEscortRank] = function(msg)
        local result = new('GetEscortRankReturn', 0)
        local inner_result, inner_info = instance.GetEscortRank(cast('const GetEscortRank&', msg).page)
        result.result = inner_result
         if result.result==C.ESCORT_SUCCESS then
            --按照积分、护卫次数、等级排序
            table.sort(escort_info, function(a,b)
                if a.score == b.score then
                    if a.defend_total == b.defend_total then
                        local player_a = data.GetPlayerBaseInfo(a.player)
                        local player_b = data.GetPlayerBaseInfo(b.player)
                        if player_a.game_info.level == player_b.game_info.level then
                            return a.player < b.player
                        else
                            return player_a.game_info.level > player_b.game_info.level
                        end
                    else
                        return a.defend_total > b.defend_total 
                    end
                else
                    return a.score > b.score 
                end
            end)
    
            result.page_count = inner_info[1]
            result.count = 0
            for i=inner_info[2],inner_info[3] do
                local EscortRank = escort_info[i]
                local base_info = data.GetPlayerBaseInfo(EscortRank.player)
                
                result.list[result.count].id = EscortRank.player
                result.list[result.count].nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
                result.list[result.count].rank = inner_info[2] + result.count
                result.list[result.count].level = base_info.game_info.level
                result.list[result.count].total = EscortRank.defend_total
                result.list[result.count].count = config.escort.can_defend - EscortRank.defend_count
                result.list[result.count].accept = EscortRank.auto_accept
                result.list[result.count].score = EscortRank.score
            
                result.count = result.count + 1
            end
         end
        return result, 12 + result.count * sizeof(result.list[0])
    end
    
    --打劫
    processor_[C.kRobEscort] = function(msg)
        local target = cast('const RobEscort&', msg).player
        local result = new('RobEscortReturn', 0)
        local inner_result, inner_info = instance.RobEscort(target)
        result.result = inner_result
        local result_length = 4
        if result.result==C.ESCORT_SUCCESS then
            result.rob_time = inner_info[1]
            result.victory = inner_info[2]
            local base_info = data.GetPlayerBaseInfo(target)
            result.nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
            result.silver = inner_info[3]
            result.prestige = inner_info[4]
            
            result.fight_record_bytes = inner_info[5]
            copy(result.fight_record, inner_info[6], result.fight_record_bytes)
            
            result_length = sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        
        return result, result_length
    end
    
    --发起邀请
    processor_[C.kInviteEscortRequest] = function(msg)
        local result = new('InviteEscortRequestResultReturn', 0)
        local inner_result, inner_info = instance.InviteEscortRequest(cast('const InviteEscortRequest&', msg).player)
        result.result = inner_result
        if result.result==C.ESCORT_SUCCESS then
            result.agree = inner_info
        end
        
        return result
    end
    
    --回应邀请
    processor_[C.kInviteEscortRespond] = function(msg)
        local InviteRespond = cast('const InviteEscortRespond&', msg)
        local result = new('InviteEscortRespondResultReturn', 0)
        local inner_result, inner_info = instance.InviteEscortRespond(InviteRespond.player, InviteRespond.agree)
        result.result = inner_result
        if result.result==C.ESCORT_SUCCESS then
            result.status = inner_info
        end
        
        return result
    end
    
    --清除打劫CD
    processor_[C.kClearEscortCD] = function(msg)
        local result = new('ClearEscortCDResult', 0)
        result.result = instance.ClearEscortCD()
        return result
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
            if result and result.result==C.ESCORT_SUCCESS then
                result.result = 0
            end
            return result, result_length
        end
    end
    
    return obj
end

    
--检查护送是否完成
function EscortReward()
    for uid,road in pairs(escort_road) do
        if road.time + escort_cfg[road.transport].time < os.time() then
            --发送给护送者
            local player = online_players[uid]
            if player then
                --在线直接发送
                local result = new('PushEscortReward')
                result.isOnline = 1
                result.isHelper = 0
                result.count = road.count
                result.type = road.transport
                result.silver = road.silver
                result.prestige = road.prestige
                
                player.ModifySilver(road.silver)
                player.ModifyPrestige(road.prestige)
                
                player.Send2Gate(result)
            else
                ModifySilverByUID(uid, road.silver)
                ModifyPrestigeByUID(uid, road.prestige)
                
                --离线，先保存到数据库
                GlobalInsertRow(C.ktEscortReward, {C.kfPlayer, uid}, {C.kfTransport, road.transport}, {C.kfCount, road.count}, {C.kfHelp, 0}, {C.kfSilver, road.silver}, {C.kfPrestige, road.prestige})
            end
            
            --发送给护卫者
            if road.guardian~=0 then
                local guardian = online_players[road.guardian]
                
                local score_ratio = {0, 3, 6}
                local prestige_ratio = {0, 0.5, 1}
                
                local score = score_ratio[3 - road.count]
                local prestige = escort_cfg[road.transport].prestige * prestige_ratio[3 - road.count]
                
                --修改积分
                if score~=0 then
                    local info = GetEscortInfoByUID(road.guardian)
                    if info then
                        info.score = info.score + score
                        
                        UpdateOtherField(C.ktEscortInfo, road.guardian, {C.kfScore, info.score})
                    end
                end
                
                if guardian then
                    --在线直接发送
                    local result = new('PushEscortReward')
                    result.isOnline = 1
                    result.isHelper = 1
                    result.count = road.count
                    result.type = road.transport
                    result.silver = score
                    result.prestige = prestige
                    
                    if prestige~=0 then guardian.ModifyPrestige(prestige) end
                    
                    guardian.Send2Gate(result)
                else
                    --
                    if prestige~=0 then
                        ModifyPrestigeByUID(road.guardian, prestige)
                    end
                    
                    --离线，先保存到数据库
                    GlobalInsertRow(C.ktEscortReward, {C.kfPlayer, road.guardian}, {C.kfTransport, road.transport}, {C.kfCount, road.count}, {C.kfHelp, 1}, {C.kfSilver, score}, {C.kfPrestige, prestige})
                end
            end
            
            if road.count==0 then
                RecordOfflinePlayerAction(uid, action_id.kEscortNoRob, 1)
                
                if road.guardian~=0 then
                    RecordOfflinePlayerAction(uid, action_id.kEscortWithHelp, 1)
                    RecordOfflinePlayerAction(road.guardian, action_id.kEscortHelpEx, 1)
                end
            end
            
            if road.guardian~=0 and road.count==2 then
                RecordOfflinePlayerAction(uid, action_id.kEscortWithHelpEx, 1)
            end
            
            --清除在丝绸之路上的人
            if escort_road[uid].road then escort_road[uid].road.ready = nil end
            escort_road[uid] = nil
            data.DeleteEscortRoad(uid)
            
            break
        end
    end
end

function ResetEscort()
    for _,v in ipairs(escort_info) do
        v.count = 0
        v.defend_count = 0
        v.intercept = 0
        v.refresh = 0
    end
    data.ResetEscortInfo()
end
