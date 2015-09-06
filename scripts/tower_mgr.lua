--试炼塔
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local copy = ffi.copy

require('global_data')
require('fight.fight_mgr')
require('fight_helper')
require('tools.table_ext')

local monster_groups_cfg = require('config.monster_group')
local gold_consume_flag = require('define.gold_consume_flag')

local tower_cfgs = require('config.tower')
local tower_count = require('config.tower_count')
local tower_cost = require('config.tower_cost')

--返回值，判断执行结果
local RESULT = table.enum(13300, {"SUCCESS", "NOT_ACTIVATE", "INVALID_TOWER", "ALREADY_RESET", "NO_RESET_TIMES", "NO_ENOUGH_GOLD", "ONLY_MOPUP", "CANT_MOPUP", "ON_THE_CD_TIME", "BAG_IS_FULL"})

function CreateTowerManager(player, this)
    local obj = {}

    local function DropReward(tower, layer, is_mopup)
        
        --圆桌分配
        local function RoundCake(t)
            local probability = math.random()
            for _,v in ipairs(t) do
                if probability<v.real_probability then
                    return _, v
                else
                    probability = probability - v.real_probability
                end
            end
            
            --
            return nil
        end
        
        --if player.GetBagSpace()<tower_cfgs[tower][layer].reward_count then return false end

        local result = new('TowerReward')
        result.silver = tower_cfgs[tower][layer].silver
        result.exp = tower_cfgs[tower][layer].exp
        result.tower = tower
        result.layer = layer
        result.mopup = is_mopup and 1 or 0
        
        player.ModifySilver(result.silver)
        player.AddHeroExp(result.exp)
        
        local reward_props = {}
        local temp_reward = table.deep_clone( tower_cfgs[tower][layer].reward )
        for _=1,tower_cfgs[tower][layer].reward_count do
            local sum = 0
            for _,v in ipairs(temp_reward) do
                sum = sum + v.probability
            end
            
            for _,v in ipairs(temp_reward) do
                v.real_probability = v.probability/sum
            end
            
            local index, reward = RoundCake(temp_reward)
            table.remove(temp_reward, index)
            if reward.sid~=0 then
                if not reward_props[reward.sid] then reward_props[reward.sid] = 0 end
                reward_props[reward.sid] = reward_props[reward.sid] + reward.amount
            end
        end
        
        result.count = 0
        for k,v in pairs(reward_props) do
            result.list[result.count].sid = k
            result.list[result.count].amount = v
            
            result.count = result.count + 1
            player.ModifyProp(k, v)
        end
        
        return false, result, 12 + result.count * sizeof(result.list[0])
    end
    
    function obj.GetTowerInfo()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        return RESULT.SUCCESS, {this.tower, this.layer, this.refresh, this.status, this.time, this.suspend}
    end
    
    function obj.ResetTower(tower)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查进度
        if tower<1 or tower>this.tower then return RESULT.INVALID_TOWER end
        if this.tower==tower and this.layer==0 then return RESULT.INVALID_TOWER end
        
        --检查是否需要刷新
        if this.status~=0 then return RESULT.ALREADY_RESET end
        
        --检查是否还有重置次数
        if this.refresh>=tower_count[player.GetVIPLevel()].count then return RESULT.NO_RESET_TIMES end
        
        --检查金币是否足够
        if not player.IsGoldEnough( tower_cost[this.refresh + 1].cost ) then return RESULT.NO_ENOUGH_GOLD end
        
        player.ConsumeGold( tower_cost[this.refresh + 1].cost, gold_consume_flag.tower_refresh )
        
        this.refresh = this.refresh + 1
        this.status = tower
        player.UpdateField(C.ktTower, C.kInvalidID, {C.kfStatus, this.status}, {C.kfRefresh, this.refresh})
        
        return RESULT.SUCCESS
    end
    
    function obj.FightTower()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否可以战斗
        if this.status~=0 then return RESULT.ONLY_MOPUP end
        
        --检查战斗CD
        if os.time()<this.time then return RESULT.ON_THE_CD_TIME end
        
        --检查极限
        if this.tower==#tower_cfgs and this.layer==#tower_cfgs[this.tower] then return RESULT.INVALID_TOWER end
        
        --检查背包
        --if player.GetBagSpace()<tower_cfgs[this.tower][this.layer + 1].reward_count then return RESULT.BAG_IS_FULL end
        
        --开始战斗
        local heros_group,array = player.GetHerosGroup()
        local targets = ProduceMonstersGroup(monster_groups_cfg[tower_cfgs[this.tower][this.layer + 1].monster].monster)
        local env = {type=10, weather='cloudy', terrain='plain', group_a={name=player.GetName(),array=array}, group_b={is_monster=true}}
        
		local fight = CreateFight(heros_group, targets, env)
        local record, record_len = fight.GetFightRecord()
        local winner = fight.GetFightWinner()
		local time = fight.GetFightCD()
        
        winner = 1 - winner
        if winner==1 then
            --胜利
            
            this.layer = this.layer + 1
            
            --发放奖励
            local failed, result, result_length = DropReward(this.tower, this.layer, false)
            local PushTowerReward = new('PushTowerReward')
            PushTowerReward.count = 1
            copy(PushTowerReward.list[0], result, result_length)
            GlobalSend2Gate(player.GetUID(), PushTowerReward, 4 + result_length)
            
            if this.tower~=#tower_cfgs and this.layer==#tower_cfgs[this.tower] then
                --全服通告
                local TowerNotify = new('TowerNotify')
                TowerNotify.name = player.GetCNickname()
                TowerNotify.uid = player.GetUID()
                TowerNotify.tower = this.tower
                GlobalSend2Gate(-1, TowerNotify)
                
                --打下一个塔
                this.tower = this.tower + 1
                this.layer = 0
                player.UpdateField(C.ktTower, C.kInvalidID, {C.kfTower, this.tower}, {C.kfLayer, this.layer})
                
            else
                player.UpdateField(C.ktTower, C.kInvalidID, {C.kfLayer, this.layer})
            end
        else
            --失败
            this.time = os.time() + time
            player.UpdateField(C.ktTower, C.kInvalidID, {C.kfTime, this.time})
        end
        
        return RESULT.SUCCESS, {this.tower, this.layer, winner, this.time, record_len, record}
    end
    
    function obj.MopupTower()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_ACTIVATE end
        
        --检查是否可以扫荡
        if this.status==0 then return RESULT.CANT_MOPUP end
        
        local min_layer = this.suspend==0 and 1 or this.suspend
        local max_layer = this.status<this.tower and #tower_cfgs[this.status] or this.layer
        
        --检查背包
        --if player.GetBagSpace()<tower_cfgs[this.status][min_layer].reward_count then return RESULT.BAG_IS_FULL end
        
        local buffer = ''
        local count = 0
        
        this.suspend = 0
        for layer=min_layer,max_layer do
            local failed, result, result_length = DropReward(this.status, layer, true)
            if failed then
                this.suspend = layer
                break
            end
            
            buffer = buffer .. ffi.string(result, result_length)
            count = count + 1
        end
        
        buffer = ffi.string(new('uint32_t[1]', count), 4) .. buffer
        local PushTowerReward = new('PushTowerReward')
        copy(PushTowerReward, buffer, #buffer)
        GlobalSend2Gate(player.GetUID(), PushTowerReward, #buffer)
        
        if this.suspend~=0 then
            --发生了中断
            player.UpdateField(C.ktTower, C.kInvalidID, {C.kfSuspend, this.suspend})
        else
            this.status = 0
            player.UpdateField(C.ktTower, C.kInvalidID, {C.kfStatus, this.status}, {C.kfSuspend, this.suspend})
        end
        
        return RESULT.SUCCESS, this.suspend
    end
    
    return obj
end