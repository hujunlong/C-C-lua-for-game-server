local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local copy = ffi.copy

require('db')

local config = require('config.world_war_config')
local shop = require('config.shop')
local world_war_vip = require('config.world_war_vip')
local world_war_grade = require('config.world_war_grade')

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

function CreateWorldWarManager(this)
    local obj = {}
    
    local fixed_flag_head_ = new('MqHead', this.uid, 0, -1)
    
    --玩家全局信息
    if not war_wait[this.sid] then war_wait[this.sid] = {} end
    if not war_wait[this.sid][this.uid] then war_wait[this.sid][this.uid] = {} end
    
    local wait_info = war_wait[this.sid][this.uid]
    wait_info.attack = nil
    wait_info.map = nil
    wait_info.pos = nil
    wait_info.loc = nil
    
    wait_info.report = db.GetWorldWarReport(this.sid, this.uid)
    
    --连胜次数
    local winning = 0
    
    --返回值，判断执行结果
    local function enum(...)
        local enum_t = {}
        
        for k,v in pairs(...) do
            enum_t[v] = 12300 + k
        end
        return enum_t
    end
    local RESULT = enum{"SUCCESS", "NOT_ACTIVATE", "NOT_ENOUGH_VOTE", "INVALID_MAP", "INVALID_LOCATION", "INVALID_PAGE", "NO_ENOUGH_GOLD", "HAVE_CD_TIME", "NO_NEED_CLEAR_CD", "NO_MORE_TIMES", "INVALID_PROPS", "NO_MORE_SCORE", "BAG_FULL", "NO_TOP_RANK", "NO_ENOUGH_DATA", "CANT_ATTACK_BORN", "NOT_ON_THE_MAP"}
    
    local function UpdateField(...)
        db.UpdateWorldWarInfo(this.uid, this.sid, ...)
    end
    
    local function InTable(t, f)
        for _,v in ipairs(t) do
            if v==f then return true end
        end
        return false
    end
        
    --获取国战基本信息
    function obj.GetWorldWarBaseInfo()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS
    end
    
    --获取国战新闻
    function obj.GetWorldWarNews()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        local count = {}
        count[1] = 0
        count[2] = 0
        count[3] = 0
        
        for _,v in pairs(war_map) do
            count[v.country] = count[v.country] + 1
        end
        
        return RESULT.SUCCESS, count
    end
    
    --获取国战回放
    function obj.GetWorldWarRecord()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS
    end
    
    --获取个人战报
    function obj.GetWorldWarReport()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS, wait_info.report
    end
    
    --设置自动参战
    function obj.SetWorldWarAuto()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if war_term~=0 and this.info.count<world_war_vip[this.info.vip].count and wait_info.map==nil and GetCanFightLocations(this.info.camp) then
            this.info.robot = 1 - this.info.robot
            UpdateField({"robot", this.info.robot})
            
            if this.info.time<=os.time() then
                this.info.auto = 0
                UpdateField({"auto", this.info.auto})
            end
        end
        
        return RESULT.SUCCESS
    end
    
    --对地区投票
    function obj.SetWorldWarVote(map)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if this.info.vote~=0 then return RESULT.NOT_ENOUGH_VOTE end
        
        if not war_map[map] or war_map[map].retention then return RESULT.INVALID_MAP end
        
        local vote_country = "vote" .. this.info.camp
        local delta = world_war_grade[this.info.grade].vote
        war_map[map][vote_country] = war_map[map][vote_country] + delta
        
        this.info.vote = map
        UpdateField({"vote", this.info.vote})
        db.UpdateWorldWarVote(map, this.info.camp, war_map[map][vote_country])
        
        NotifyMapVoteChange(map, this.info.camp, delta, war_map[map][vote_country])
        
        return RESULT.SUCCESS
    end
    
    --进入区域
    function obj.EnterWorldWarMap(map)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if not war_running[map] then return RESULT.INVALID_MAP end
        
        if war_running[map].progress==0 or war_running[map].progress==war_map[map].count then return RESULT.INVALID_MAP end
        
        if war_running[map].attack~=this.info.camp and war_running[map].defend~=this.info.camp then return RESULT.INVALID_MAP end
        
        wait_info.map = map
        winning = 0
        
        wait_info.attack = war_running[map].attack==this.info.camp
        if wait_info.attack then
            local reborns = {}
            --reborns[#reborns + 1] = war_map[map].attack_born_location
            
            for _,i in ipairs(war_map[map].reborn_locations) do
                if war_map[map].locations[i].country==this.info.camp then
                    reborns[#reborns + 1] = i
                end
            end

            wait_info.pos = reborns[ math.random(1, #reborns) ]
            
            return RESULT.SUCCESS,{wait_info.attack, war_running[map].defend, wait_info.pos, math.floor( 100 * war_running[map].progress / war_map[map].count + 0.5 ), war_location[map], map}
        else
            local reborns = {}
            --reborns[#reborns + 1] = war_map[map].defend_born_location
            
            for _,i in ipairs(war_map[map].reborn_locations) do
                if war_map[map].locations[i].country==this.info.camp then
                    reborns[#reborns + 1] = i
                end
            end
            
            wait_info.pos = reborns[ math.random(1, #reborns) ]
            
            return RESULT.SUCCESS,{wait_info.attack, war_running[map].attack, wait_info.pos, math.floor( 100 * war_running[map].progress / war_map[map].count + 0.5 ), war_location[map], map}
        end
    end
    
    --在地图路点上移动
    function obj.MoveRoadInMap(location, flag)
    
        --战斗协程
        local function Fighting(sequence, client_flag, target_player, target_location)
            coroutine.yield()
            
            local target = war_map[wait_info.map].locations[location]
            local score = 0
            local prestige = 0
            
            local weather = target.weather
            if not weather then weather = war_map[wait_info.map].weather end
            
            local heros_group1, heros_info1 = coroutine_queue[sequence].info[1][1], coroutine_queue[sequence].info[1][2]
            local heros_group2, heros_info2 = coroutine_queue[sequence].info[2][1], coroutine_queue[sequence].info[2][2]
            
            --开始战斗
            local env = 
            {   
                type=7, weather=weather, terrain=target.terrain, 
                group_a={server=war_server[this.sid], name=war_info[this.sid][this.uid].nickname, level=war_info[this.sid][this.uid].level, array=heros_info1.array, sex=heros_info1.sex}, 
                group_b={server=war_server[target_player.sid], name=war_info[target_player.sid][target_player.uid].nickname, level=war_info[target_player.sid][target_player.uid].level, array=heros_info2.array, sex=heros_info2.sex}
            }
            
            local fight = CreateFight(heros_group1, heros_group2, env)
            local winner = fight.GetFightWinner()
            local record, record_len = fight.GetFightRecord()
            
            this.info.time = os.time() + config.cd_time1
            winner = 1 - winner
            
            if winner==1 then
                --胜利
                score = GetScoreByRank(this.info.rank)
                
                --
                wait_info.loc = location
                local pos = wait_info.pos
                
                if not wait_info.attack then
                    --防守胜利
                    target_location.progress = target_location.progress - config.progress
                    
                    if target_location.progress<=0 then
                        target_location.progress = 50
                        
                        --防守方成功推进一个路点
                        war_running[wait_info.map].progress = war_running[wait_info.map].progress - 1
                        db.UpdateWorldWarRunning(wait_info.map, war_running[wait_info.map].progress)
                        
                        target.country = this.info.camp
                        db.UpdateWorldWarCountry3(wait_info.map, location, this.info.camp)
                        
                        --如果是多个点连接的情况
                        for _,v in ipairs(war_location[wait_info.map]) do
                            if v.location1==location and v.location2~=wait_info.pos then
                                if war_map[wait_info.map].locations[v.location2].country==this.info.camp then
                                    v.progress = 50
                                    db.SetWorldWarLocation(wait_info.map, v.location1, v.location2, v.progress)
                                    
                                    NotifyLocationChange(wait_info.map, v)
                                end
                            else
                                if v.location2==location and v.location1~=wait_info.pos then
                                    if war_map[wait_info.map].locations[v.location1].country==this.info.camp then
                                        v.progress = 50
                                        db.SetWorldWarLocation(wait_info.map, v.location1, v.location2, v.progress)
                                        NotifyLocationChange(wait_info.map, v)
                                    end
                                end
                            end
                        end
                        
                        UpdateCanFightLocations()
                        NotifyMapChange(wait_info.map)
                        NotifyLocationTransmit(wait_info.map, location)
                        
                        --防守方获得最后胜利
                        if war_running[wait_info.map].progress==0 then
                            local news = {map=wait_info.map, attack=war_running[wait_info.map].attack, defend=war_running[wait_info.map].defend, type=2, time=os.time(), term=war_term}
                            InsertRecord(news)
                            
                            war_map[wait_info.map].country = this.info.camp
                            db.UpdateWorldWarCountry2(wait_info.map, this.info.camp)
                            
                            wait_info.map = StopFightInMap(wait_info.map)
                        end
                    end
                else
                    --进攻胜利
                    target_location.progress = target_location.progress + config.progress
                    
                    if target_location.progress>=100 then
                        target_location.progress = 50
                        
                        --进攻方成功推进一个路点
                        war_running[wait_info.map].progress = war_running[wait_info.map].progress + 1
                        db.UpdateWorldWarRunning(wait_info.map, war_running[wait_info.map].progress)
                        
                        target.country = this.info.camp
                        db.UpdateWorldWarCountry3(wait_info.map, location, this.info.camp)
                        
                        --如果是多个点连接的情况
                        for _,v in ipairs(war_location[wait_info.map]) do
                            if v.location1==location and v.location2~=wait_info.pos then
                                if war_map[wait_info.map].locations[v.location2].country==this.info.camp then
                                    v.progress = 50
                                    db.SetWorldWarLocation(wait_info.map, v.location1, v.location2, v.progress)
                                    
                                    NotifyLocationChange(wait_info.map, v)
                                end
                            else
                                if v.location2==location and v.location1~=wait_info.pos then
                                    if war_map[wait_info.map].locations[v.location1].country==this.info.camp then
                                        v.progress = 50
                                        db.SetWorldWarLocation(wait_info.map, v.location1, v.location2, v.progress)
                                        NotifyLocationChange(wait_info.map, v)
                                    end
                                end
                            end
                        end
                        
                        UpdateCanFightLocations()
                        NotifyMapChange(wait_info.map)
                        NotifyLocationTransmit(wait_info.map, location)
                        
                        --进攻方获得最后胜利
                        if war_running[wait_info.map].progress==war_map[wait_info.map].count then
                            local news = {map=wait_info.map, attack=war_running[wait_info.map].attack, defend=war_running[wait_info.map].defend, type=1, time=os.time(), term=war_term}
                            InsertRecord(news)
                            
                            war_map[wait_info.map].country = this.info.camp
                            db.UpdateWorldWarCountry2(wait_info.map, this.info.camp)
                            
                            wait_info.map = StopFightInMap(wait_info.map)
                        end
                    end
                end
                
                --写入数据库
                db.SetWorldWarLocation(wait_info.map, target_location.location1, target_location.location2, target_location.progress)
                NotifyLocationChange(wait_info.map, target_location)
                
                if winning~=0 then
                    --连战
                    this.info.score = this.info.score + winning + 1
                    this.info.point = this.info.point + winning + 1
                    
                    prestige = config.prestige_extra
                else
                    this.info.count = this.info.count + 1
                    
                    prestige = config.prestige_reward
                    
                    RequestRemoteMethodCall(this.sid, this.uid, C.kWorldWarCount1, world_war_vip[this.info.vip].count - this.info.count)
                    
                    wait_info.last_score = this.info.score
                    wait_info.reward_prestige = 0
                end
                
                wait_info.reward_prestige = wait_info.reward_prestige + prestige
                
                winning = winning + 1
                wait_info.winning = winning
                if winning>=config.winning_max then
                    --把玩家送至复活点
                    wait_info.pos = GetRebornLocation(wait_info.map, pos, wait_info.attack, this.info.camp)
                    
                    wait_info.loc = nil
                    
                    AppendPersonalReport(this.sid, this.uid, this.info.score + score - wait_info.last_score, wait_info.reward_prestige, wait_info.winning, wait_info.map)
                    wait_info.last_score = nil
                    wait_info.reward_prestige = nil
                    wait_info.winning = nil
                end
            else
                --失败
                if winning==0 then
                    this.info.count = this.info.count + 1
                    score = config.lose_score
                    
                    RequestRemoteMethodCall(this.sid, this.uid, C.kWorldWarCount1, world_war_vip[this.info.vip].count - this.info.count)
                end
                
                prestige = config.prestige_fail
                
                --
                wait_info.winning = winning
                wait_info.reward_prestige = wait_info.reward_prestige + prestige
                AppendPersonalReport(this.sid, this.uid, this.info.score + score - wait_info.last_score, wait_info.reward_prestige, wait_info.winning, wait_info.map)
                wait_info.last_score = nil
                wait_info.reward_prestige = nil
                wait_info.winning = nil
                
                --把玩家送至复活点
                wait_info.pos = GetRebornLocation(wait_info.map, wait_info.pos, wait_info.attack, this.info.camp)
                winning = 0
                
                wait_info.loc = nil
            end
            
            this.info.rank, war_info[target_player.sid][target_player.uid].rank = GetNewRank(this.info.rank, war_info[target_player.sid][target_player.uid].rank, winner)
            this.info.score = this.info.score + score
            this.info.point = this.info.point + score
            
            --写入数据库
            UpdateField({"rank", this.info.rank}, {"count", this.info.count}, {"score", this.info.score}, {"point", this.info.point}, {"time", this.info.time})
            
            --更改挑战目标Rank
            db.UpdateWorldWarInfo(target_player.uid, target_player.sid, {"rank", war_info[target_player.sid][target_player.uid].rank})
            
            
            RequestRemoteMethodCall(this.sid, this.uid, C.kRewardPrestige, prestige)
            
            --
            local result = new('MoveRoadInMapResult', 0)
            result.location = wait_info.pos
            result.is_fight = 1
            result.victory  = winner
            result.count    = world_war_vip[this.info.vip].count - this.info.count
            result.score    = score
            result.prestige = prestige
            result.time     = this.info.time
            result.winning  = winning
            
            result.fight_record_bytes = record_len
            copy(result.fight_record, record, result.fight_record_bytes)
            
            fixed_flag_head_.flag = client_flag
            fixed_flag_head_.type = result.kType
            C.ZMQSend(connects[this.sid], fixed_flag_head_, result, sizeof(result) - C.kMaxFightRecordLength + record_len)
            
            --连胜次数达到上限
            if winning>=config.winning_max then winning = 0 end
        end
        
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查地图是否合法
        if not wait_info.map or not war_location[wait_info.map] then return RESULT.INVALID_MAP end
        
        --检查地图是否合法
        if war_running[wait_info.map].progress==0 or war_running[wait_info.map].progress==war_map[wait_info.map].count then return RESULT.INVALID_MAP end
        
        --检查路点是否合法
        if not InTable(war_map[wait_info.map].locations[wait_info.pos].adjacent_locations, location) then return RESULT.INVALID_LOCATION end
        
        --找出两个出生点
        local self_born_location = wait_info.attack and war_map[wait_info.map].attack_born_location or war_map[wait_info.map].defend_born_location
        local else_born_location = wait_info.attack and war_map[wait_info.map].defend_born_location or war_map[wait_info.map].attack_born_location
        
        --检查路点是否连接出生点
        if location==self_born_location then
            wait_info.pos = location
            return RESULT.SUCCESS, wait_info.pos
        end
        
        --检查目标点是否是对方复活点
        if location==else_born_location then return RESULT.CANT_ATTACK_BORN end
        
        local target_location = nil
        for i,v in ipairs(war_location[wait_info.map]) do
            if v.location1==wait_info.pos and v.location2==location then
                target_location = war_location[wait_info.map][i]
                break
            else
                if v.location2==wait_info.pos and v.location1==location then
                    target_location = war_location[wait_info.map][i]
                    break
                end
            end
        end
        --检查路点是否合法
        if not target_location then return RESULT.INVALID_LOCATION end
        
        local target = war_map[wait_info.map].locations[location]

        if target.country~=this.info.camp then
            
            --连胜移动到其它点
            if wait_info.loc~=location then winning=0 end
            
            --检查战斗CD
            if winning==0 and this.info.time>os.time() then return RESULT.HAVE_CD_TIME end
            
            --检查战斗次数
            if winning==0 and this.info.count>=world_war_vip[this.info.vip].count then return RESULT.NO_MORE_TIMES end
        
            --首先往上寻找敌对玩家
            local target_player = GetRankTarget(this.sid, this.uid, target.country)
            
            if not target_player then return RESULT.NO_ENOUGH_DATA end
            
            --发送查询请求，完成后自动调用协程
            local co_mgr = {co=coroutine.create(Fighting), rely=2, info={}, time=os.time()}
            coroutine.resume(co_mgr.co, c_sequence, flag, target_player, target_location)
            coroutine_queue[c_sequence] = co_mgr
            
            RequestPlayerGroup(this.sid, this.uid, c_sequence, 1)
            RequestPlayerGroup(target_player.sid, target_player.uid, c_sequence, 2)
        
            c_sequence = c_sequence + 1
            return
        else
            --未发生战斗
            wait_info.pos = location
            winning = 0
        end
        
        return RESULT.SUCCESS, wait_info.pos
    end
    
    --战场排行榜
    local top_rank = nil
    local function GetSelfTopRank()
        for i,top in ipairs(war_top) do
            if top.server==this.sid and top.player==this.uid then return top.index end
        end
        
        return 0
    end
    
    function obj.GetWorldWarTop(page)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查页数是否正确
        local page_total = math.min( math.ceil(#war_top/10), 50 )
        
        if page_total==0 then return RESULT.NO_TOP_RANK end
        
        if page<1 or page>page_total then return RESULT.INVALID_PAGE end
        
        local begin = 1 + (page-1)*10
        local over = 10 + (page-1)*10
        
        if over>#war_top then over = #war_top end
        
        top_rank = top_rank or GetSelfTopRank()
        
        return RESULT.SUCCESS, {page_total, begin, over, top_rank}
    end
    
    --清除战斗CD
    function obj.ClearWorldWarCD(flag)
        
        --检查是否开启功能
        if not this.activate then
            local result = new('ClearWorldWarCDResult')
            result.result = RESULT.NOT_ACTIVATE
            fixed_flag_head_.flag = flag
            fixed_flag_head_.type = result.kType
            
            C.ZMQSend(connects[this.sid], fixed_flag_head_, result, sizeof(result))
            return
        end
        
        local function ClearCD(sequence, client_flag)
            coroutine.yield()
            local result = new('ClearWorldWarCDResult')
            if coroutine_queue[sequence].info==1 then
                this.info.time = 0
                UpdateField({"time", this.info.time})
                
                result.result = 0
            else
                result.result = RESULT.NO_ENOUGH_GOLD
            end
            
            fixed_flag_head_.flag = client_flag
            fixed_flag_head_.type = result.kType
            C.ZMQSend(connects[this.sid], fixed_flag_head_, result, sizeof(result))
        end
        
        local cost = GetCDCost(this.info.time)
        if cost==0 or this.info.count>=world_war_vip[this.info.vip].count or not GetCanFightLocations(this.info.camp) or winning~=0 then
            local result = new('ClearWorldWarCDResult')
            result.result = RESULT.NO_NEED_CLEAR_CD
            fixed_flag_head_.flag = flag
            fixed_flag_head_.type = result.kType
            
            C.ZMQSend(connects[this.sid], fixed_flag_head_, result, sizeof(result))
            return
        end
        
        local co_mgr = {co=coroutine.create(ClearCD), rely=1, info=nil, time=os.time()}
        coroutine.resume(co_mgr.co, c_sequence, flag)
        coroutine_queue[c_sequence] = co_mgr
        
        local CheckPlayerGold = new('CheckPlayerGold')
        CheckPlayerGold.gold = cost
        fixed_flag_head_.flag = c_sequence
        fixed_flag_head_.type = CheckPlayerGold.kType
        C.ZMQSend(connects[this.sid], fixed_flag_head_, CheckPlayerGold, sizeof(CheckPlayerGold))
        
        c_sequence = c_sequence + 1
        return
    end
    
    --离开地图
    function obj.LeaveWorldWarMap()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if war_wait[this.sid] then
            war_wait[this.sid][this.uid] = {}
            wait_info = war_wait[this.sid][this.uid]
        end
        
        winning = 0
        
        return RESULT.SUCCESS
    end
    
    --放弃连战
    function obj.GiveUpWinning()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if wait_info.last_score then
            AppendPersonalReport(this.sid, this.uid, this.info.score - wait_info.last_score, wait_info.reward_prestige, winning, wait_info.map)
            wait_info.last_score = nil
            wait_info.reward_prestige = nil
        end
        
        winning = 0
        
        return RESULT.SUCCESS
    end
    
    --购买物品
    function obj.BuyWorldWarProps(sid, flag)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查道具ID是否合法
        local goods = nil
        for _,prop in pairs(shop[3]) do
            if prop.SID==sid and IsCanBuyProp(prop.map, this.info.camp) then
                goods = prop
                break
            end
        end
        
        if not goods then return RESULT.INVALID_PROPS end
        
        --检查积分是否足够
        if goods.coin_type~=3 or this.info.point<goods.price then return RESULT.NO_MORE_SCORE end
        
        --先减去战场点数
        this.info.point = this.info.point - goods.price
        
        local function AddProps(sequence, client_flag)
            coroutine.yield()
            local result = new('BuyWorldWarPropsResult')
            if coroutine_queue[sequence].info==1 then
                result.result = 0
                result.point = this.info.point
            else
                this.info.point = this.info.point + goods.price
                result.result = RESULT.BAG_FULL
            end
            
            --写入数据库
            UpdateField({"point", this.info.point})
            
            fixed_flag_head_.flag = client_flag
            fixed_flag_head_.type = result.kType
            C.ZMQSend(connects[this.sid], fixed_flag_head_, result, sizeof(result))
        end
        
        local co_mgr = {co=coroutine.create(AddProps), rely=1, info=nil, time=os.time()}
        coroutine.resume(co_mgr.co, c_sequence, flag)
        coroutine_queue[c_sequence] = co_mgr
        
        local AddWorldWarProp = new('AddWorldWarProp')
        AddWorldWarProp.kind = goods.prop_kind
        AddWorldWarProp.amount = goods.amount
        
        fixed_flag_head_.flag = c_sequence
        fixed_flag_head_.type = AddWorldWarProp.kType
        C.ZMQSend(connects[this.sid], fixed_flag_head_, AddWorldWarProp, sizeof(AddWorldWarProp))
        
        c_sequence = c_sequence + 1
    end
    
    --获取最终位置
    function obj.GetFinalLocation()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        if not wait_info.map then return RESULT.NOT_ON_THE_MAP end
        
        return RESULT.SUCCESS, {wait_info.pos or 0, wait_info.loc or 0}
    end
    
    --获取高级军阶信息
    function obj.AdvancedGradeInfo()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        top_rank = top_rank or GetSelfTopRank()
        return RESULT.SUCCESS, {this.info.score, #war_top, top_rank}
    end
    
    return obj
end