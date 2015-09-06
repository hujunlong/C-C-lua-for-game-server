local ffi    = require('ffi')
local C      = ffi.C
local sizeof = ffi.sizeof
local new    = ffi.new
local cast   = ffi.cast
local copy   = ffi.copy

require('db')
require('fight.fight_mgr')

local config = require('config.world_war_config')
local shop = require('config.shop')
local world_war_vip = require('config.world_war_vip')
local world_war_grade = require('config.world_war_grade')

require('world_war_data')
require('world_war_util')
require('world_war_mgr')
require('world_war_schedule')
require('world_war_auto')

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

function CreateWorldWarInstance(sid, uid)
    local obj = {}
    
    local fixed_flag_head_ = new('MqHead', uid, 0, -1)
    
    local this = {}
    this.sid = sid
    this.uid = uid
    
    this.activate = false         --是否激活
    
    if war_info[this.sid] then
        this.info = war_info[this.sid][this.uid]
        if this.info then
            this.activate = true
        end
    end
    
    local manager = CreateWorldWarManager(this)
    
    function obj.open()
    end
    
    --消息处理
    local processor_ = {}
    
    --推送信息
    processor_[C.kPushUserCommonInfo] = function(msg)
        local UserCommonInfo = cast('const UserCommonInfo&', msg)
        
        if not this.info then
            --创建新用户
            if not war_info[this.sid] then war_info[this.sid] = {} end
            war_info[this.sid][this.uid] = {}
            this.info = war_info[this.sid][this.uid]
            
            local nickname = ffi.string(UserCommonInfo.name.str, UserCommonInfo.name.len)
            db.InsertWorldWarInfo(this.uid, this.sid, UserCommonInfo.country, UserCommonInfo.vip, UserCommonInfo.grade, UserCommonInfo.level, nickname)
            
            this.info.rank  = 1200
            this.info.point = 0
            this.info.score = 0
            this.info.count = 0
            this.info.robot = 0
            this.info.auto  = 0
            this.info.vote  = 0
            this.info.time  = 0
            
            war_rank[#war_rank + 1] = {}
            war_rank[#war_rank].server = this.sid
            war_rank[#war_rank].player = this.uid
        end
        
        this.info.camp  = UserCommonInfo.country
        this.info.vip   = UserCommonInfo.vip
        this.info.grade = UserCommonInfo.grade
        this.info.level = UserCommonInfo.level
        this.info.nickname = ffi.string(UserCommonInfo.name.str, UserCommonInfo.name.len)
        
        db.UpdateWorldWarInfo(this.uid, this.sid, {"country", this.info.camp}, {"vip", this.info.vip}, {"grade", this.info.grade}, {"level", this.info.level}, {"nickname", this.info.nickname})
        
        this.activate = true
    end
    
    processor_[C.kPushPlayerInfoChanged] = function(msg)
        local PlayerInfoChanged = cast('const PlayerInfoChanged&', msg)
        
        --玩家离线
        if PlayerInfoChanged.type==4 then
            war_player[this.sid .. ':' .. this.uid] = nil
            
            if war_wait[this.sid] and war_wait[this.sid][this.uid] and war_wait[this.sid][this.uid].last_score then
                local wait_info = war_wait[this.sid][this.uid]
                AppendPersonalReport(this.sid, this.uid, this.info.score - wait_info.last_score, wait_info.reward_prestige, wait_info.winning, wait_info.map)
                wait_info.last_score = nil
                wait_info.reward_prestige = nil
                wait_info.winning = nil
            end
            
            if war_wait[this.sid] then war_wait[this.sid][this.uid] = nil end
            return
        end
        
        --玩家次数改变
        if PlayerInfoChanged.type==5 then
            this.info.count = this.info.count - PlayerInfoChanged.value
            db.UpdateWorldWarInfo(this.uid, this.sid, {"count", this.info.count})
            
            RequestRemoteMethodCall(this.sid, this.uid, C.kWorldWarCount2, world_war_vip[this.info.vip].count - this.info.count)
            return
        end
        
        if this.info then
            local change_type = {"vip", "level", "grade"}
            if change_type[PlayerInfoChanged.type] then
                this.info[ change_type[PlayerInfoChanged.type] ] = PlayerInfoChanged.value
                db.UpdateWorldWarInfo(this.uid, this.sid, {change_type[PlayerInfoChanged.type], PlayerInfoChanged.value})
            end
            
            --VIP变动
            if PlayerInfoChanged.type==1 then
                RequestRemoteMethodCall(this.sid, this.uid, C.kWorldWarCount2, world_war_vip[this.info.vip].count - this.info.count)
            end
        end
    end

    --获取国战基本信息
    processor_[C.kGetWorldWarBaseInfo] = function(msg)
        local result = new('GetWorldWarBaseInfoResult')
        local inner_result = manager.GetWorldWarBaseInfo()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.server_time = os.time()
            result.score = this.info.score
            result.point = this.info.point
            result.time  = this.info.time
            result.count = world_war_vip[this.info.vip].count - this.info.count
            result.robot = this.info.robot + 10 * this.info.auto
            
            if this.info.vote~=0 then
                result.vote = this.info.vote
            else
                result.vote = - world_war_grade[this.info.grade].vote
            end
            
            result.first = (war_term==0) and 1 or 0
            
            local count = 0
            for k,v in pairs(war_map) do
                if not v.retention then
                    result.list[count].map = k
                    result.list[count].country = v.country
                    result.list[count].vote = v["vote"..this.info.camp]
                    
                    count = count + 1
                end
            end
            
            return_length = 24 + count * sizeof(result.list[0])
        end
        return result, return_length
    end
    
    --获取国战新闻
    processor_[C.kGetWorldWarNews] = function(msg)
        local result = new('GetWorldWarNewsResult')
        local inner_result, inner_info = manager.GetWorldWarNews()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.count1 = inner_info[1]
            result.count2 = inner_info[2]
            result.count3 = inner_info[3]
            result.count = 0
            for k,v in pairs(war_running) do
                result.list[result.count].map      = k
                result.list[result.count].attack   = v.attack
                result.list[result.count].defend   = v.defend
                result.list[result.count].progress = math.floor( 100 * v.progress / war_map[k].count + 0.5 )
                
                result.count = result.count + 1
            end
            
            return_length = 8 + result.count * sizeof(result.list[0])
        end
        return result, return_length
    end
    
    --获取国战回放
    processor_[C.kGetWorldWarRecord] = function(msg)
        local result = new('GetWorldWarRecordResult')
        local inner_result = manager.GetWorldWarRecord()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.count = 0
            for _,v in ipairs(war_history) do
                result.list[result.count].map    = v.map
                result.list[result.count].attack = v.attack
                result.list[result.count].defend = v.defend
                result.list[result.count].type   = v.type
                result.list[result.count].time   = v.time
                
                result.count = result.count + 1
                if result.count>=18 then break end
            end
            
            return_length = 8 + result.count * sizeof(result.list[0])
        end
        
        return result, return_length
    end
    
    --获取个人战报
    processor_[C.kGetWorldWarReport] = function(msg)
        local result = new('GetWorldWarReportResult')
        local inner_result, inner_info = manager.GetWorldWarReport()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.count = 0
            for _,v in ipairs(inner_info) do
                result.list[result.count].count = v.count
                result.list[result.count].score = v.score
                result.list[result.count].prestige = v.prestige
                result.list[result.count].map = v.map
                result.list[result.count].time = v.time
                
                result.count = result.count + 1
            end
            
            return_length = 8 + result.count * sizeof(result.list[0])
        end
        return result, return_length
    end
    
    --设置自动参战
    processor_[C.kSetWorldWarAuto] = function(msg)
        local result = new('SetWorldWarAutoResult')
        local inner_result = manager.SetWorldWarAuto()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.status = this.info.robot + 10 * this.info.auto
            return_length = 5
        end
        return result, return_length
    end
    
    --对地区投票
    processor_[C.kSetWorldWarVote] = function(msg)
        local result = new('SetWorldWarVoteResult')
        result.result = manager.SetWorldWarVote(cast('const SetWorldWarVote&', msg).map)
        return result
    end
    
    --进入区域
    processor_[C.kEnterWorldWarMap] = function(msg)
        local result = new('EnterWorldWarMapResult')
        local inner_result, inner_info = manager.EnterWorldWarMap(cast('const EnterWorldWarMap&', msg).map)
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.is_attack = inner_info[1] and 1 or 0
            result.country = inner_info[2]
            result.location = inner_info[3]
            result.born_attack = war_map[inner_info[6]].attack_born_location
            result.born_defend = war_map[inner_info[6]].defend_born_location
            result.progress = inner_info[4]
            result.count = 0
            for _,v in ipairs(inner_info[5]) do
                result.list[result.count].location1 = v.location1
                result.list[result.count].location2 = v.location2
                result.list[result.count].country   = war_map[inner_info[6]].locations[v.location1].country + 10 * war_map[inner_info[6]].locations[v.location2].country
                result.list[result.count].progress  = v.progress
                
                result.count = result.count + 1
                if result.count>=1024 then break end
            end
            
            return_length = 12 + result.count * sizeof(result.list[0])
        end
        return result, return_length
    end
    
    --在地图路点上移动
    processor_[C.kMoveRoadInMap] = function(msg, flag)
        local inner_result, inner_info = manager.MoveRoadInMap(cast('const MoveRoadInMap&', msg).location, flag)
        if inner_result then
            local result = new('MoveRoadInMapResult')
            local return_length = 4
            result.result = inner_result
            if result.result==C.WORLD_WAR_SUCCESS then
                result.location = inner_info
                result.is_fight = 0
                return_length = 6
            end
            return result, return_length
        end
    end
    
    --战场排行榜
    processor_[C.kGetWorldWarTop] = function(msg)
        local page = cast('const GetWorldWarTop&', msg).page
        local result = new('GetWorldWarTopResult')
        local inner_result, inner_info = manager.GetWorldWarTop(page)
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.page_total = inner_info[1]
            result.rank = inner_info[4]
            result.count = 0
            for i=inner_info[2],inner_info[3] do
                local server_id = war_top[i].server
                local player_id = war_top[i].player
                
                if not war_info[server_id][player_id] or not war_server[server_id] then break end
                
                result.list[result.count].nickname = {#war_info[server_id][player_id].nickname, war_info[server_id][player_id].nickname}
                result.list[result.count].server = {#war_server[server_id], war_server[server_id]}
                result.list[result.count].score =  math.abs(war_top[i].reward)
                result.list[result.count].level = war_info[server_id][player_id].level
                result.list[result.count].country = war_info[server_id][player_id].camp
                result.list[result.count].rank = war_top[i].index
                
                result.count = result.count + 1
            end
            
            return_length = 12 + result.count * sizeof(result.list[0])
        end
        return result, return_length
    end
    
    --清除战斗CD
    processor_[C.kClearWorldWarCD] = function(msg, flag)
        manager.ClearWorldWarCD(flag)
    end
    
    --离开地图
    processor_[C.kLeaveWorldWarMap] = function(msg)
        local result = new('LeaveWorldWarMapResult')
        result.result = manager.LeaveWorldWarMap()
        return result
    end
    
    --放弃连战
    processor_[C.kGiveUpWinning] = function(msg)
        local result = new('GiveUpWinningResult')
        result.result = manager.GiveUpWinning()
        return result
    end
    
    --获取国战商店信息
    processor_[C.kGetWorldWarShopInfo] = function(msg)
        local result = new('GetWorldWarShopInfoResult')
        result.count = 0
        for _,prop in pairs(shop[3]) do
            if IsCanBuyProp(prop.map, this.info.camp) then
                result.list[result.count].id = prop.SID
                
                result.count = result.count + 1
                if result.count>=150 then break end
            end
        end
        return result, 8 + result.count * sizeof(result.list[0])
    end
    
    --购买物品
    processor_[C.kBuyWorldWarProps] = function(msg, flag)
        local inner_result = manager.BuyWorldWarProps(cast('const BuyWorldWarProps&', msg).id, flag)
        
        if inner_result then
            local result = new('BuyWorldWarPropsResult')
            result.result = inner_result
            return result, 4
        end
    end
    
    --获取最终位置
    processor_[C.kGetFinalLocation] = function(msg)
        local result = new('GetFinalLocationResult')
        
        local inner_result, inner_info = manager.GetFinalLocation()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.location = inner_info[1]
            result.target = inner_info[2]
            return_length = 6
        end
        return result, return_length
    end
    
    --获取高级军阶信息
    processor_[C.kAdvancedGradeInfo] = function(msg)
        local result = new('AdvancedGradeInfoResult')
        
        local inner_result, inner_info = manager.AdvancedGradeInfo()
        local return_length = 4
        result.result = inner_result
        if result.result==C.WORLD_WAR_SUCCESS then
            result.score = inner_info[1]
            result.count = inner_info[2]
            result.rank = inner_info[3]
            return_length = 16
        end
        return result, return_length
    end
    
    function obj.ProcessMsg(type, flag, msg)
        local func = processor_[type]
        if func then
            local result, result_length = func(msg, flag)
            if result then
                if result.result==C.WORLD_WAR_SUCCESS then
                    result.result = 0
                end
                
                fixed_flag_head_.flag = flag
                fixed_flag_head_.type = result.kType
                C.ZMQSend(connects[sid], fixed_flag_head_, result, result_length or sizeof(result))
            end
        end
    end
    
    return obj
end
