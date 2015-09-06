--玩家领地{逻辑管理}
local ffi = require('ffi')
local new = ffi.new

require('data')
require('global_data')
require('fight.fight_mgr')
require('fight_helper')
local config = require('config.global')
local monster_groups_cfg = require('config.monster_group')
local gold_consume_flag = require('define.gold_consume_flag')

local territory_cfgs = require('config.territory')
local territory_ratio = require('config.territory_ratio')
local territory_resource = require('config.territory_resource')

local territory_data = require('territory_data')
local territory_info = territory_data.GetTerritoryInfo()
local territory_index = territory_data.GetTerritoryIndex()
local territory_player = territory_data.GetTerritoryPlayer()
local territory_wait = territory_data.GetTerritoryWait()

local territory_skins = {}
for vip=0,13 do
    territory_skins[vip] = {[0]=true,[1]=true,[2]=true}
end

local five_day = 5 * 60 * 60 *24

function ResetTerritory()
    for _,v in pairs(territory_player) do
        v.move = 1
        v.grab = 1
        v.robber = 0
        v.assist = 0
    end
    data.ResetTerritory()
end

local function CheckTerritoryEmpty(country, type, page)
    if type~=config.territory.bronze then return end
    
    --能否找到玩家
    local find_player = false
    for _,seral in ipairs(territory_info[country][type][page]) do
        if seral.owner~=0 then
            find_player = true
        end
    end
    
    --本页一个玩家都没有了
    if not find_player and #territory_info[country][type]>1 then
        table.remove(territory_info[country][type], page)
        
        for _,v in pairs(territory_index) do
            if v.country==country and v.type==type and v.page>page then
                v.page = v.page - 1
            end
        end
        
        territory_data.NotifyTerritoryPageChange(country, type, page)
        
        data.ReduceTerritory(country, type, page)
    end
end

--返回值，判断执行结果
local RESULT = table.enum(12300, {"SUCCESS", "NOT_ACTIVATE", "INVALID_TYPE", "INVALID_PAGE", "NO_MORE_TIMES", "INVALID_TARGET", "HAVE_CD_TIME", "NO_RESOURCE", "NO_NEED_CLEAR", "NO_ENOUGH_GOLD", "NO_RIGHT"})

function CreateTerritory(player, this)
    local obj = {}
    local uid = player.GetUID()
    local country = player.GetCountry()

    --圆桌分配
    local function RoundCake(t)
        local probability = math.random()
        for _,v in ipairs(t) do
            if probability<v.probability then
                return v
            else
                probability = probability - v.probability
            end
        end
        
        --
        return nil
    end
    
    --检查是否需要给玩家分配城池
    function obj.CheckDistribute()
        if not territory_index[uid] then
            country = player.GetCountry()
            if country~=0 then
                territory_data.CheckDistribute(country, uid)
            else
                print("CheckDistribute error",uid)
            end
        end
    end
    
    --获取领地基本信息
    function obj.GetTerritoryStatus()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否开启功能
        local info = territory_player[uid]
        if not info then return RESULT.NOT_ACTIVATE end
        
        --没有资源点
        if not territory_index[uid].resource then
            info.time = 0
            info.reap = 0
        end
        
        return RESULT.SUCCESS, {info.move, info.grab, config.territory.can_robber - info.robber, config.territory.can_assist - info.assist, info.move_cd, info.grab_cd, info.kill_cd, info.reap}
    end
    
    --查看领地
    function obj.ViewTerritory(type, page)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查类型
        if not territory_info[country][type] then return RESULT.INVALID_TYPE end
        
        --检查页数
        if not territory_info[country][type][page] then return RESULT.INVALID_PAGE end
        
        territory_wait[uid] = {country=country, type=type, page=page}
        
        return RESULT.SUCCESS, {#territory_info[country][type], territory_info[country][type][page].style, territory_info[country][type][page]}
    end
    
    --定位玩家领地
    function obj.TerritoryGPS()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否开启功能
        local info = territory_index[uid]
        if not info then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS, {info.type, info.page}
    end
    
    --迁移玩家领地
    function obj.MoveTerritory(type, page, index)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查今日是否可以迁移
        local info = territory_player[uid]
        if not info or info.move==0 then return RESULT.NO_MORE_TIMES end
        
        --检查战斗CD
        if not info or info.move_cd>os.time() then return RESULT.HAVE_CD_TIME end
        
        --检查是否挑战本页玩家
        info = territory_index[uid]
        if not info or ( type==info.type and page==info.page ) then return RESULT.INVALID_TARGET end
        
        --不允许挑战低级领地
        if info.type<type then return RESULT.INVALID_TYPE end
        
        --检查类型
        if not territory_info[country][type] then return RESULT.INVALID_TYPE end
        
        --检查页数
        if not territory_info[country][type][page] then return RESULT.INVALID_PAGE end
        
        --检查迁移目标是否合法
        local target = territory_info[country][type][page][index]
        if not target or target.kind~=0 then return RESULT.INVALID_TARGET end
        
        --开始战斗
        local heros_group,array = player.GetHerosGroup()
        local env = {}
        local targets = {}
        
        local target_id = target.owner
        if target_id==0 then
            targets = ProduceMonstersGroup(monster_groups_cfg[territory_cfgs[type].city_monster].monster)
            env = {type=8, weather='cloudy', terrain='plain', group_a={name=player.GetName(),array=array}, group_b={is_monster=true}}
        else
            local array2 = 0
            targets, array2 = data.GetPlayerHerosGroup(target_id)
            env = {type=9, weather='cloudy', terrain='citadel', group_a={name=player.GetName(),sex=player.GetSex(),array=array,level=player.GetLevel()}, group_b={name=data.GetPlayerName(target_id),sex=data.GetPlayerSex(target_id),array=array2,level=data.GetPlayerLevel(target_id)}}
        end
        
        local fight = CreateFight(heros_group, targets, env)
        local record, record_len = fight.GetFightRecord()
        local winner = fight.GetFightWinner()
        
        winner = 1 - winner
        if winner==1 then
            --胜利
            territory_player[uid].move = 0
            territory_player[uid].move_cd = 0
            data.UpdateTerritoryInfo(uid, {"move", territory_player[uid].move}, {"move_cd", territory_player[uid].move_cd})

            --清除资源点
            for _,player_id in ipairs({uid, target_id}) do
                local info_ = territory_index[player_id]
                if info_ and info_.resource then
                    territory_info[country][info_.type][info_.page][info_.resource.seral].owner = 0
                    data.SetTerritoryOwner(country, info_.type, info_.page, info_.resource.seral, 0)
                    
                    territory_index[player_id].resource = nil
                
                    territory_player[player_id].time = 0
                    territory_player[player_id].reap = 0
                    data.UpdateTerritoryInfo(player_id, {"time", territory_player[player_id].time}, {"reap", territory_player[player_id].reap})
                end
            end
            
            --改变城池主人
            territory_info[country][info.type][info.page][info.city.seral].owner = target_id
            data.SetTerritoryOwner(country, info.type, info.page, info.city.seral, target_id)
            
            territory_info[country][type][page][index].owner = uid
            data.SetTerritoryOwner(country, type, page, index, uid)
            
            --改变索引
            if target_id~=0 then
                territory_index[target_id].type = info.type
                territory_index[target_id].page = info.page
                territory_index[target_id].city = {seral=info.city.seral, kind=0}
            end
            territory_data.NotifyTerritoryChange(country, info.type, info.page)
            CheckTerritoryEmpty(country, info.type, info.page)
            
            territory_index[uid].type = type
            territory_index[uid].page = page
            territory_index[uid].city = {seral=index, kind=0}
            territory_data.NotifyTerritoryChange(country, type, page)
        else
            --失败
            territory_player[uid].move_cd = os.time() + config.territory.cd_time
            data.UpdateTerritoryInfo(uid, {"move_cd", territory_player[uid].move_cd})
        end
        
        --通知另外的玩家
        if target_id~=0 then
            local result = new('TerritoryChallenge')
            result.name = player.GetCNickname()
            result.type = 0
            result.succeed = winner
            GlobalSend2Gate(target_id, result)
        end
        
        return RESULT.SUCCESS, {territory_player[uid].move_cd, territory_player[uid].move, winner, record_len, record}
    end
    
    --收取资源
    --[[
    function obj.ReapResource()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否有资源点
        local info = territory_index[uid]
        if not info or not info.resource then return RESULT.NO_RESOURCE end
        
        local resource_type = info.resource.kind
        
        --检查收取CD
        info = territory_player[uid]
        if not info or os.time()<info.reap then return RESULT.REAP_CD end
        
        info.reap = os.time() + territory_resource[resource_type].unit_time
        data.UpdateTerritoryInfo(uid, {"reap", info.reap})
        
        if territory_resource[resource_type].type==1 then
            player.ModifySilver( territory_resource[resource_type].amount * territory_ratio[player.GetLevel()] )
        else
            print("尚未支持的资源收取类型", territory_resource[resource_type].type)
        end
        
        return RESULT.SUCCESS, {territory_resource[resource_type].type, territory_resource[resource_type].amount * territory_ratio[player.GetLevel()] }
    end
    ]]
    
    --争夺资源
    function obj.GrabResource(type, page, index)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end

        --检查今日是否可以争夺资源
        local info = territory_player[uid]
        if not info or info.grab==0 then return RESULT.NO_MORE_TIMES end
        
        --检查战斗CD
        if not info or info.grab_cd>os.time() then return RESULT.HAVE_CD_TIME end
        
        --检查是否挑战本页资源点
        info = territory_index[uid]
        if not info or type~=info.type or page~=info.page then return RESULT.INVALID_TARGET end
        
        --检查迁移目标是否合法
        local target = territory_info[country][type][page][index]
        if not target or not territory_resource[target.kind] then return RESULT.INVALID_TARGET end
        
        --检查保护时间
        local target_id = target.owner
        if target_id~=0 then
            if territory_player[target_id].time + territory_resource[target.kind].guard_time>os.time() then return RESULT.HAVE_CD_TIME end
        end
        
        --开始战斗
        local heros_group,array = player.GetHerosGroup()
        local env = {}
        local targets = {}
        
        if target_id==0 then
            targets = ProduceMonstersGroup(monster_groups_cfg[territory_cfgs[type].resource_monster].monster)
            env = {type=8, weather='cloudy', terrain='plain', group_a={name=player.GetName(),array=array}, group_b={is_monster=true}}
        else
            local array2 = 0
            targets, array2 = data.GetPlayerHerosGroup(target_id)
            env = {type=9, weather='cloudy', terrain='citadel', group_a={name=player.GetName(),sex=player.GetSex(),array=array,level=player.GetLevel()}, group_b={name=data.GetPlayerName(target_id),sex=data.GetPlayerSex(target_id),array=array2,level=data.GetPlayerLevel(target_id)}}
        end
        
        local fight = CreateFight(heros_group, targets, env)
        local record, record_len = fight.GetFightRecord()
        local winner = fight.GetFightWinner()
        
        winner = 1 - winner
        if winner==1 then
            --胜利
            territory_player[uid].grab = 0
            territory_player[uid].grab_cd = 0
            data.UpdateTerritoryInfo(uid, {"grab", territory_player[uid].grab}, {"grab_cd", territory_player[uid].grab_cd})

            --放弃原有资源点
            if info.resource then
                territory_info[info.country][info.type][info.page][info.resource.seral].owner = 0
                data.SetTerritoryOwner(info.country, info.type, info.page, info.resource.seral, 0)
            end
            
            --改变资源点主人
            territory_info[info.country][type][page][index].owner = uid
            data.SetTerritoryOwner(info.country, type, page, index, uid)
            
            --改变索引
            if target_id~=0 then
                territory_index[target_id].resource = nil
                
                territory_player[target_id].time = 0
                territory_player[target_id].reap = 0
                data.UpdateTerritoryInfo(target_id, {"time", territory_player[target_id].time}, {"reap", territory_player[target_id].reap})
            end
            territory_index[uid].resource = {seral=index, kind=target.kind}
            
            --通知改变
            territory_data.NotifyTerritoryChange(country, type, page)
            
            territory_player[uid].time = os.time()
            territory_player[uid].reap = territory_player[uid].time + territory_resource[territory_index[uid].resource.kind].unit_time
            data.UpdateTerritoryInfo(uid, {"time", territory_player[uid].time}, {"reap", territory_player[uid].reap})
        else
            --失败
            territory_player[uid].grab_cd = os.time() + config.territory.cd_time
            data.UpdateTerritoryInfo(uid, {"grab_cd", territory_player[uid].grab_cd})
        end
        
        --通知另外的玩家
        if target_id~=0 then
            local result = new('TerritoryChallenge')
            result.name = player.GetCNickname()
            result.type = 1
            result.succeed = winner
            GlobalSend2Gate(target_id, result)
        end
        
        return RESULT.SUCCESS, {territory_player[uid].grab_cd, territory_player[uid].grab, winner, record_len, record}
    end
    
    --放弃资源
    function obj.DiscardResource()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否有资源点
        local info = territory_index[uid]
        if not info or not info.resource then return RESULT.NO_RESOURCE end
        
        territory_info[country][info.type][info.page][info.resource.seral].owner = 0
        data.SetTerritoryOwner(country, info.type, info.page, info.resource.seral, 0)
        territory_index[uid].resource = nil
        
        territory_player[uid].time = 0
        territory_player[uid].reap = 0
        data.UpdateTerritoryInfo(uid, {"time", territory_player[uid].time}, {"reap", territory_player[uid].reap})
        
        --通知改变
        territory_data.NotifyTerritoryChange(country, territory_index[uid].type, territory_index[uid].page)
        
        return RESULT.SUCCESS
    end
    
    --停止查看领地
    function obj.StopViewTerritory()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        territory_wait[uid] = nil
        
        return RESULT.SUCCESS
    end
    
    --花费金币清除CD
    function obj.ClearTerritoryCD(type)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查类型
        local cd_type = {"move_cd", "grab_cd", "kill_cd"}
        if not cd_type[type] then return RESULT.INVALID_TYPE end
        
        --检查是否需要清除CD
        local info = territory_player[uid]
        if not info or info[cd_type[type]]<os.time() then return RESULT.NO_NEED_CLEAR end
        
        --检查金币是否足够
        if not player.IsGoldEnough(config.territory.clear_gold) then return RESULT.NO_ENOUGH_GOLD end
        
        player.ConsumeGold(config.territory.clear_gold, gold_consume_flag.territory_clear_cd)
        
        territory_player[uid][cd_type[type]] = 0
        data.UpdateTerritoryInfo(uid, {cd_type[type], 0})
        
        return RESULT.SUCCESS
    end
    
    --改变城池外观
    function obj.SetTerritorySkin(type)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否拥有这个权利
        if not territory_skins[player.GetVIPLevel()][type] then return RESULT.NO_RIGHT end
        
        --避免重复设置
        if territory_player[uid].skin~=type then
            
            territory_player[uid].skin = type
            data.UpdateTerritoryInfo(uid, {"skin", type})
            
            --通知改变
            territory_data.NotifyTerritoryChange(country, territory_index[uid].type, territory_index[uid].page)
        end
        
        return RESULT.SUCCESS
    end
    
    
    return obj
end

--定时检查领地信息
function TerritoryTrigger()
    for player_id,player_info in pairs(territory_player) do
        local info = territory_index[player_id]
        
        if not info then
            print("TerritoryTrigger error",player_id)
            break
        end
        
        --资源点产出
        if info.resource and player_info.reap<os.time() and player_info.reap<player_info.time + territory_resource[info.resource.kind].time then
        
            local resource_type = info.resource.kind
            player_info.reap = player_info.reap + territory_resource[resource_type].unit_time
            data.UpdateTerritoryInfo(player_id, {"reap", player_info.reap})
            
            if territory_resource[resource_type].type==1 then
                ModifySilverByUID( player_id, territory_resource[resource_type].amount * territory_ratio[ data.GetPlayerLevel(player_id) ].ratio )
            else
                print("尚未支持的资源收取类型", territory_resource[resource_type].type)
            end
            
            break
        end
        
        --资源点占领超时
        if info.resource then
            local resource_type = info.resource.kind
            if player_info.time + territory_resource[resource_type].time < os.time() then
                territory_info[info.country][info.type][info.page][info.resource.seral].owner = 0
                data.SetTerritoryOwner(info.country, info.type, info.page, info.resource.seral, 0)
                
                territory_index[player_id].resource = nil
                
                --通知改变
                territory_data.NotifyTerritoryChange(info.country, territory_index[player_id].type, territory_index[player_id].page)
                
                player_info.time = 0
                player_info.reap = 0
                data.UpdateTerritoryInfo(player_id, {"time", player_info.time}, {"reap", player_info.reap})
                break
            end
        end
        
        --玩家5天没上线
        if player_info.last_active_time + five_day < os.time() then
            
            --清除城池和资源
            local types = {["city"]=true,["resource"]=true}
            for name,v in pairs(info) do
                if types[name] then
                    territory_info[info.country][info.type][info.page][v.seral].owner = 0
                    data.SetTerritoryOwner(info.country, info.type, info.page, v.seral, 0)
                end
            end
            
            --通知改变
            territory_data.NotifyTerritoryChange(info.country, territory_index[player_id].type, territory_index[player_id].page)
            
            --检查是否需要整理页数
            CheckTerritoryEmpty(info.country, info.type, info.page)
            
            territory_player[player_id] = nil
            territory_index[player_id] = nil
            data.DeleteTerritoryInfo(player_id)
            
            break
        end
    end
end
