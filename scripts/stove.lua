--熔炉
local config = require('config.global')
local action_id = require('define.action_id')
local rune_cfg = require('config.runes')
local rune_material = require('config.rune_material')
local runes_group = require('config.rune_group')
local rune_count = require('config.rune_count')
local gold_consume_flag = require('define.gold_consume_flag')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new

local assistant_id = require('config.assistant_task_id')
require('data')
require('global_data')

local function RoundRunesGroup(array,key)
    local probability = math.random()
    for _,v in ipairs(array) do
        if probability<v.probability then
            return v[key]
        else
            probability = probability - v.probability
        end
    end
    
    --
    return nil
end

local function RoundRune(array, level)
    while true do
        local rune_type = array[ math.random(1, #array) ]
        if type(rune_type)~='table' then
            return rune_type
        else
            if level>=rune_type[2] then
                return rune_type[1]
            end
        end
    end
end

--符文专用位运算
function rune_to_bits(n)
    local tbl = {}
    tbl[1] = 1
    local cnt = 2
    while (n > 0) do
        local last = math.mod(n,2)
        if(last == 1) then
            tbl[cnt] = 1
        else
            tbl[cnt] = 0
        end
            n = (n-last)/2
            cnt = cnt + 1
    end
    
    for i = cnt, 5 do
        tbl[i] = 0
    end

    return tbl
end

function runes_to_number(tbl)
    local n = 5
    for i = 2, n do
        if not tbl[i] then tbl[i] = 0 end
    end
    
    local rslt = 0
    local power = 1
    for i = 2, n do
        rslt = rslt + tbl[i]*power
        power = power*2
    end

    return rslt
end

--返回值，判断执行结果
local RESULT = table.enum(13000, {"SUCCESS", "NOT_YET_ACTIVATE", "NOT_ENOUGH_GOLD", "NOT_ENOUGH_COIN", "NOT_ENOUGH_STOVE_SPACE", "NOT_ENOUGH_BAG_SPACE", "NOT_ENOUGH_RUNE_SPACE", "AMOUNT_ERROR", "LOW_TEMPERATURE", "NOT_ENOUGH_T", "CANT_USE_COOLING", "CANT_PICKUP_GARBAGE", "INVALID_RUNE_ID", "BAG_IS_EMPTY", "CANT_MERGE_LOCKED", "INVALID_RUNE_POS", "INVALID_MATERIAL", "NOT_ENOUGH_ENERGY", "RUNE_MAX_LEVEL", "NO_MORE_TIMES", "NO_NEED_BUY"})

function CreateStove(this, player)
    local obj = {}

    --获取熔炉状态
    function obj.GetStoveStatus()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        return RESULT.SUCCESS
    end
    
    --获取熔炉中符文列表
    function obj.GetStoveRuneList()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        return RESULT.SUCCESS, this.info_stove
    end
    
    --点击材料
    function obj.ClickMaterial(material)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查是否还有空闲空间
        if this.space_stove>=config.treasure.max_space_stove then return RESULT.NOT_ENOUGH_STOVE_SPACE end
        
        --检查是否可以点亮
        if this.status[material]~=1 then return RESULT.INVALID_MATERIAL end
        
        --检查银币是否足够
        local silver_cost = rune_material[material].cost
        if not player.IsSilverEnough(silver_cost) then return RESULT.NOT_ENOUGH_COIN end
        
        --检查数据库空间是否足够
        if this.space_stove + this.space_bag + this.space_hero >= config.treasure.max_space then return RESULT.NOT_ENOUGH_RUNE_SPACE end
        
        --
        player.AssistantCompleteTask(assistant_id.kGetRune, 999)
        player.RecordAction(action_id.kRuneUseMaterial, 1, material)
        
        --开始操作
        if material~=1 then this.status[material] = 0 end
        if material~=5 then
            if math.random()<rune_material[material].probability then
                this.status[material+1] = 1
            end
        end
        player.ModifySilver(-silver_cost)
        
        --
        this.max_id = this.max_id + 1
        this.space_stove = this.space_stove + 1
        local rune_group = runes_group[ RoundRunesGroup(rune_material[material].runes,'group') ].runes
        local rune_type = RoundRune(rune_group, player.GetLevel())
        this.info_stove[this.max_id] = {}
        this.info_stove[this.max_id].type = rune_type
        this.info_stove[this.max_id].position = this.space_stove
        
        player.RecordAction(action_id.kRuneGetSpecial, 1, rune_type)
        
        if rune_cfg[rune_type].notify then
            local GetRune = new('GetRune')
            GetRune.name = player.GetCNickname()
            GetRune.uid = player.GetUID()
            GetRune.rune = rune_type
            GlobalSend2Gate(-1, GetRune)
        end
        
        player.InsertRow(C.ktRuneInfo, {C.kfID, this.max_id}, {C.kfType, rune_type})
        
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfStatus, runes_to_number(this.status)})
        
        return RESULT.SUCCESS, {this.max_id, rune_type}
    end
    
    --拾取符文
    function obj.PickupRunes(count,runes)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查参数是否正确
        if not count or count<=0  or count>this.space_stove then return RESULT.AMOUNT_ERROR end
        
        --检查是否还有空闲空间
        if count + this.space_bag>config.treasure.max_space_bag then return RESULT.NOT_ENOUGH_BAG_SPACE end
        
        for i=0,count-1 do
            local rune_id = runes[i]
            if rune_id~=0 and this.info_stove[rune_id] then
                --是否在拾取垃圾
                if rune_cfg[this.info_stove[rune_id].type].kind==4 then return RESULT.CANT_PICKUP_GARBAGE end
                
                local free_grid = this.space_bag + 1
                for p=1,this.space_bag do
                    if not this.info_bag[p] then
                        free_grid = p
                        break
                    end
                end
                
                this.space_stove = this.space_stove - 1
                this.space_bag = this.space_bag + 1
                
                this.info_bag[free_grid] = {}
                this.info_bag[free_grid].type = this.info_stove[rune_id].type
                this.info_bag[free_grid].rune_id = rune_id
                this.info_bag[free_grid].lock = 0
                this.info_bag[free_grid].exp = 0
                
                this.info_stove[rune_id] = nil
                
                player.UpdateField(C.ktRuneInfo, rune_id, {C.kfLocation, -1}, {C.kfPosition, free_grid})
            else
                return RESULT.INVALID_RUNE_ID
            end
        end
    
        return RESULT.SUCCESS
    end
    
    --出售/分解符文
    function obj.ResolveRunes(count,runes)
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查参数是否正确
        if not count or count<=0 or count>this.space_stove then return RESULT.AMOUNT_ERROR end
        
        --检查参数是否正确
        local flag1 = false
        local flag2 = false
        for i=0,count-1 do
            local rune_id = runes[i]
            if not this.info_stove[rune_id] then
                return RESULT.INVALID_RUNE_ID
            else
                local rune = this.info_stove[rune_id]
                if rune_cfg[rune.type].kind==4 then
                    flag1 = true
                else
                    flag2 = true
                end
            end
        end
        
        if flag1 and flag2 then return RESULT.INVALID_RUNE_ID end
        
        --开始处理
        local energy = 0
        local silver = 0
        for i=0,count-1 do
            local rune_id = runes[i]
            if this.info_stove[rune_id] then
                local rune = this.info_stove[rune_id]
                if rune_cfg[rune.type].kind==4 then
                    --垃圾售出
                    silver = silver + rune_cfg[rune.type].price
                else
                    --变成能量
                    local exp = rune_cfg[rune.type].exp
                    player.RecordAction(action_id.kRuneEnergy, exp)
                    
                    energy = energy + exp
                end
                
                this.space_stove = this.space_stove - 1
                this.info_stove[rune_id] = nil
                player.DeleteRow(C.ktRuneInfo, rune_id)
            else
                return RESULT.INVALID_RUNE_ID
            end
        end
        
        if energy~=0 then
            this.energy = this.energy + energy
            player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfEnergy, this.energy})
        end
        
        if silver~=0 then
            player.ModifySilver(silver)
        end
        
        return RESULT.SUCCESS
    end
    
    --直接激活赤金
    function obj.GoldActivation()
        --检查是否开启功能
        if not this.activate then return RESULT.NOT_YET_ACTIVATE end
        
        --检查金币是否足够
        if not player.IsGoldEnough(config.treasure.gold_price) then return RESULT.NOT_ENOUGH_GOLD end
        
        --检查是否还有购买次数
        if rune_count[player.GetVIPLevel()].count < player.GetVIPCount(4) then return RESULT.NO_MORE_TIMES end

        --检查是否需要购买
        if this.status[4]==1 then return RESULT.NO_NEED_BUY end
        
        player.ConsumeGold(config.treasure.gold_price, gold_consume_flag.rune_gold_activation)
        
        this.status[4] = 1
        
        player.AddVIPCount(4)
        
        player.UpdateField(C.ktRuneStatus, C.kInvalidID, {C.kfStatus, runes_to_number(this.status)})
        
        return RESULT.SUCCESS
    end
    
    
    return obj
end