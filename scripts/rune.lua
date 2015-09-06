--符文
local config = require('config.global')
local action_id = require('define.action_id')
local rune_cfg = require('config.runes')
local rune_upgrade = require('config.rune_upgrade')
local rune_aperture = require('config.rune_aperture')

local ffi = require('ffi')
local C = ffi.C

require('data')
require('tools.table_ext')

local function CheckPosition(level, pos, kind)
    if not level then return nil end
    
    local begin_amount = {0, 50, 100}
    local max_level = 0
    for k,v in pairs(rune_aperture) do
        if level>=k then
            if max_level<k then
                max_level = k
            end
        end
    end
    
    if max_level==0 then return nil end
    
    if kind<1 or kind>3 then return nil end
    
    return pos<=rune_aperture[max_level].amount[kind] and pos>begin_amount[kind]
end

--返回值，判断执行结果
local RESULT = table.enum(13000, {"SUCCESS", "NOT_YET_ACTIVATE", "NOT_ENOUGH_GOLD", "NOT_ENOUGH_COIN", "NOT_ENOUGH_STOVE_SPACE", "NOT_ENOUGH_BAG_SPACE", "NOT_ENOUGH_RUNE_SPACE", "AMOUNT_ERROR", "LOW_TEMPERATURE", "NOT_ENOUGH_T", "CANT_USE_COOLING", "CANT_PICKUP_GARBAGE", "INVALID_RUNE_ID", "BAG_IS_EMPTY", "CANT_MERGE_LOCKED", "INVALID_RUNE_POS", "INVALID_MATERIAL", "NOT_ENOUGH_ENERGY", "RUNE_MAX_LEVEL", "NO_MORE_TIMES", "NO_NEED_BUY"})

function CreateRune(this, player)
    local obj = {}
    
    --获取背包符文列表
    function obj.GetBagRuneList()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        return RESULT.SUCCESS, this.info_bag
    end
    
    --获取英雄符文列表
    function obj.GetHeroRuneList(hero_id)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        return RESULT.SUCCESS, this.info_hero[hero_id]
    end
    
    --分解包裹中的符文
    function obj.ResolveBagRune(position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        ---检查符文位置是否有效
        local rune = this.info_bag[position]
        if not rune then return RESULT.INVALID_RUNE_POS end
        
        local energy = rune_cfg[rune.type].exp + math.floor( rune.exp * config.treasure.wastage )
        player.RecordAction(action_id.kRuneEnergy, energy)
        
        this.energy = this.energy + energy
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfEnergy, this.energy})
       
        player.DeleteRow(C.ktRuneInfo, rune.rune_id)
        
        this.space_bag = this.space_bag - 1
        this.info_bag[position] = nil
        
        return RESULT.SUCCESS
    end
    
    --锁定符文/解锁符文
    function obj.LockRune(position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查符文位置是否有效
        if not this.info_bag[position] then return RESULT.INVALID_RUNE_POS end
        
        this.info_bag[position].lock = this.info_bag[position].lock==1 and 0 or 1
        player.UpdateField(C.ktRuneInfo, this.info_bag[position].rune_id, {C.kfLocked, this.info_bag[position].lock})
        
        return RESULT.SUCCESS
    end
    
    --改变符文在背包中的位置
    function obj.ChangeBagGrid(position1, position2)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查符文位置是否有效
        if not this.info_bag[position1] then return RESULT.INVALID_RUNE_POS end
        
        if not this.info_bag[position2] then
            --放入新位置
            if position2<=0 or position2>config.treasure.max_space_bag then return RESULT.INVALID_RUNE_POS end
            this.info_bag[position2] = table.clone(this.info_bag[position1])
            this.info_bag[position1] = nil
        
            player.UpdateField(C.ktRuneInfo, this.info_bag[position2].rune_id, {C.kfPosition, position2})
        else
            --交换位置
            this.info_bag[position1],this.info_bag[position2] = table.clone(this.info_bag[position2]),table.clone(this.info_bag[position1])
            player.UpdateField(C.ktRuneInfo, this.info_bag[position1].rune_id, {C.kfPosition, position1})
            player.UpdateField(C.ktRuneInfo, this.info_bag[position2].rune_id, {C.kfPosition, position2})
        end
        
        return RESULT.SUCCESS
    end
    
    --改变符文在英雄身上的位置
    function obj.ChangePosition(rune_id, hero_id, position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        ---检查符文是否有效
        if not this.info_hero[hero_id] or not this.info_hero[hero_id][rune_id] then return RESULT.INVALID_RUNE_ID end
        
        --没有移动
        if this.info_hero[hero_id][rune_id].position==position then return RESULT.SUCCESS end
        
        local hero_level = player.GetHeroLevel(hero_id)
        if position<=0 or not CheckPosition(hero_level,position,rune_cfg[this.info_hero[hero_id][rune_id].type].kind) then return RESULT.INVALID_RUNE_POS end
        
        --目标位置上是否已经有符文
        local flag = 0
        for k,v in pairs(this.info_hero[hero_id]) do
            if v.position==position then
                flag = 1
                
                --交换符文位置
                v.position,this.info_hero[hero_id][rune_id].position = this.info_hero[hero_id][rune_id].position,v.position
                player.UpdateField(C.ktRuneInfo, k, {C.kfPosition, v.position})
                
                break
            end
        end
        
        if flag==0 then
            --移动符文位置
            this.info_hero[hero_id][rune_id].position = position
        end
        
        player.UpdateField(C.ktRuneInfo, rune_id, {C.kfPosition, position})
        return RESULT.SUCCESS
    end
    
    --穿戴符文/脱下符文
    function obj.WearDropRune(rune_id, hero_id, position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        if this.info_hero[hero_id] and this.info_hero[hero_id][rune_id] then
            --符文在英雄身上
            if this.info_bag[position] then
                --目标位置已经存在符文、进行交换位置
                local target_id = this.info_bag[position].rune_id
                this.info_bag[position].position = this.info_hero[hero_id][rune_id].position
                this.info_hero[hero_id][rune_id].rune_id = rune_id
                this.info_hero[hero_id][rune_id].position = nil
                
                this.info_bag[position],this.info_hero[hero_id][target_id] = table.clone(this.info_hero[hero_id][rune_id]), table.clone(this.info_bag[position])
                
                player.UpdateField(C.ktRuneInfo, target_id, {C.kfLocation, hero_id}, {C.kfPosition, this.info_hero[hero_id][target_id].position})
                
                this.info_hero[hero_id][rune_id] = nil
            else
                if position~=0 then return RESULT.INVALID_RUNE_POS end
                if this.space_bag==config.treasure.max_space_bag then return RESULT.NOT_ENOUGH_BAG_SPACE end
                
                --取下符文
                position = this.space_bag + 1
                for i=1,this.space_bag do
                    if not this.info_bag[i] then
                        position = i
                        break
                    end
                end
                
                this.info_hero[hero_id][rune_id].rune_id = rune_id
                this.info_hero[hero_id][rune_id].position = nil
                this.info_bag[position] = table.clone(this.info_hero[hero_id][rune_id])
                
                this.info_hero[hero_id][rune_id] = nil
                this.space_hero = this.space_hero - 1
                this.space_bag = this.space_bag + 1
            end
            
            player.UpdateField(C.ktRuneInfo, rune_id, {C.kfLocation, -1}, {C.kfPosition, position})
        else
            --符文可能在背包中
            local flag = 0
            for k,v in pairs(this.info_bag) do
                if v.rune_id==rune_id then
                    flag = k
                    break
                end
            end
            if flag==0 then return RESULT.INVALID_RUNE_ID end
            
            local target_rune = 0
            if this.info_hero[hero_id] then
                for k,v in pairs(this.info_hero[hero_id]) do
                    if v.position==position then
                        --检查符文是否有效
                        local hero_level = player.GetHeroLevel(hero_id)
                        if position<=0 or not CheckPosition(hero_level,position,rune_cfg[this.info_bag[flag].type].kind) then return RESULT.INVALID_RUNE_POS end
                
                        --目标位置已经存在符文、进行交换位置
                        target_rune = k
                        
                        this.info_bag[flag].position = position
                        this.info_bag[flag].rune_id = nil
                        this.info_hero[hero_id][k].rune_id = k
                        this.info_hero[hero_id][k].position = nil
                        
                        this.info_bag[flag],this.info_hero[hero_id][rune_id] = table.clone(this.info_hero[hero_id][k]), table.clone(this.info_bag[flag])
                        
                        player.UpdateField(C.ktRuneInfo, target_rune, {C.kfLocation, -1}, {C.kfPosition, flag})
                        
                        this.info_hero[hero_id][k] = nil
                        break
                    end
                end
            else
                this.info_hero[hero_id] = {}
            end
            
            if target_rune==0 then
                --检查符文是否有效
                local hero_level = player.GetHeroLevel(hero_id)
                if position<=0 or not CheckPosition(hero_level,position,rune_cfg[this.info_bag[flag].type].kind) then return RESULT.INVALID_RUNE_POS end
                
                --戴上符文
                this.info_bag[flag].position = position
                this.info_bag[flag].rune_id = nil
                this.info_hero[hero_id][rune_id] = table.clone(this.info_bag[flag])
                
                this.info_bag[flag] = nil
                this.space_hero = this.space_hero + 1
                this.space_bag = this.space_bag - 1
            end
            
            player.UpdateField(C.ktRuneInfo, rune_id, {C.kfLocation, hero_id}, {C.kfPosition, position})
        end
    
        return RESULT.SUCCESS, position
    end

    --升级符文
    function obj.UpgradeRune(position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查符文位置是否有效
        if not this.info_bag[position] then return RESULT.INVALID_RUNE_POS end
        
        --检查能量是否足够
        local rune = this.info_bag[position]
        local level = data.GetRuneLevel(rune.type, rune.exp)
        if level>=10 then return RESULT.RUNE_MAX_LEVEL end
        
        local energy = rune_upgrade[rune.type][level].exp - rune.exp
        if energy>this.energy then return RESULT.NOT_ENOUGH_ENERGY end
        
        if level>=9 then
            --满级符文（虽然此时level不为10，加上经验以后就为10级了）
            player.RecordAction(action_id.kRuneGetMaxLevel, 1)
        end
        
        rune.exp = rune.exp + energy
        this.energy = this.energy - energy
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfEnergy, this.energy})
        player.UpdateField(C.ktRuneInfo, rune.rune_id, {C.kfExp, rune.exp})
        
        return RESULT.SUCCESS
    end
    
    --分解所有符文
    function obj.ResolveAllRunes(position)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        --检查背包是否为空
        if this.space_bag<=0 then return RESULT.BAG_IS_EMPTY end
        
        local energy = 0
        for k,v in pairs(this.info_bag) do
            if v.lock==0 and k~=position then
            
                energy = energy + math.floor( rune_cfg[v.type].exp * config.treasure.wastage + v.exp * config.treasure.wastage )
                
                player.DeleteRow(C.ktRuneInfo, v.rune_id)
                
                this.info_bag[k] = nil
                this.space_bag = this.space_bag - 1
            end
        end
        
        player.RecordAction(action_id.kRuneEnergy, energy)
        
        this.energy = this.energy + energy
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfEnergy, this.energy})
        
        return RESULT.SUCCESS
    end
    
    --整理符文背包
    function obj.SortRunes()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        local flag = 0
        
        local temp = {}
        for position in pairs(this.info_bag) do
            temp[#temp + 1] = position
        end
        
        table.sort(temp, function(a,b)
            local runea = this.info_bag[a].type
            local runeb = this.info_bag[b].type
            if rune_cfg[runea].quality == rune_cfg[runeb].quality then
                if rune_cfg[runea].kind == rune_cfg[runeb].kind then
                    if runea==runeb then
                        if this.info_bag[a].exp == this.info_bag[b].exp then
                            return this.info_bag[a].rune_id > this.info_bag[b].rune_id
                        end
                        return this.info_bag[a].exp > this.info_bag[b].exp
                    end
                    return runea > runeb
                end
                return rune_cfg[runea].kind > rune_cfg[runeb].kind
            end
            
            return rune_cfg[runea].quality > rune_cfg[runeb].quality
        end)
        
        for i,position in ipairs(temp) do
            if i~=position then
                obj.ChangeBagGrid(position, i)
                
                for k,v in ipairs(temp) do
                    if v==i then
                        temp[k] = position
                        break
                    end
                end
                temp[i] = i
                
                flag = 1
            end
        end
        
        return RESULT.SUCCESS, flag
    end
    
    --升级英雄身上符文
    function obj.UpgradeRuneOnHero(rune_id, hero_id)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        ---检查符文是否有效
        if not this.info_hero[hero_id] or not this.info_hero[hero_id][rune_id] then return RESULT.INVALID_RUNE_ID end
        
        --检查能量是否足够
        local rune = this.info_hero[hero_id][rune_id]
        local level = data.GetRuneLevel(rune.type, rune.exp)
        if level>=10 then return RESULT.RUNE_MAX_LEVEL end
        
        local energy = rune_upgrade[rune.type][level].exp - rune.exp
        if energy>this.energy then return RESULT.NOT_ENOUGH_ENERGY end
        
        if level>=9 then
            --满级符文（虽然此时level不为10，加上经验以后就为10级了）
            player.RecordAction(action_id.kRuneGetMaxLevel, 1)
        end
        
        rune.exp = rune.exp + energy
        this.energy = this.energy - energy
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfEnergy, this.energy})
        player.UpdateField(C.ktRuneInfo, rune_id, {C.kfExp, rune.exp})
        
        return RESULT.SUCCESS
    end
    
    return obj
end