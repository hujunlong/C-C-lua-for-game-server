--宝具系统【包含熔炉和符文】

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

require('data')
require('fight_power')

local config = require('config.global')
local rune_upgrade = require('config.rune_upgrade')
local rune_count = require('config.rune_count')
require('stove')
require('rune')


function TreasureInteraction(player)
    local obj = {}
    
    --数据保存
    local this = {}
    this.activate = false         --是否激活
    this.info_stove = {}
    this.info_bag = {}
    this.info_hero = {}
    this.space_stove = 0
    this.space_bag = 0
    this.space_hero = 0
    local stove_instance = CreateStove(this, player)
    local rune_instance = CreateRune(this, player)
    
    --激活符文功能
    function obj.open()
        if not this.activate then
            this.activate = true
            
            player.InsertRow(C.ktRuneStatus, {C.kfStatus, 0})

            this.status = rune_to_bits(0)
            this.max_id = 0
            this.energy = 0
        end
    end
    
    --获取英雄符文加成
    function obj.GetRunesProperty(hero_id)
        if not this.info_hero[hero_id] then return {} end
        
        local propertys = {}
        for _,v in pairs(this.info_hero[hero_id]) do
            local property = rune_upgrade[v.type][data.GetRuneLevel(v.type, v.exp)].property
            for i,j in pairs(property) do
                if not propertys[i] then propertys[i] = 0 end
                propertys[i] = propertys[i] + j
            end
        end
        return propertys
    end
    
    --数据库消息处理
    local db_processor_ = {}
    db_processor_[C.kRuneStatus] = function(msg)
        local RuneStatus = cast('const RuneStatus&', msg)
        this.status = rune_to_bits( RuneStatus.status )
        this.max_id = RuneStatus.max_id
        this.energy = RuneStatus.energy
        this.activate = true
    end
    
    --按照符文ID重新整理数据
    db_processor_[C.kRuneInfoStove] = function(msg)
        local rune_info_stove = cast('const RuneInfoStoveList&', msg)
        this.space_stove = rune_info_stove.count
        for i=0,this.space_stove - 1 do
            local rune_id = rune_info_stove.list[i].rune_id
            this.info_stove[rune_id] = {}
            this.info_stove[rune_id].type = rune_info_stove.list[i].type
        end
    end
    
    --按照符文位置重新整理数据
    db_processor_[C.kRuneInfoBag] = function(msg)
        local rune_info_bag = cast('const RuneInfoHeroList&', msg)
        this.space_bag = rune_info_bag.count
        for i=0,this.space_bag - 1 do
            local position = rune_info_bag.list[i].position
            this.info_bag[position] = {}
            this.info_bag[position].rune_id = rune_info_bag.list[i].rune_id
            this.info_bag[position].type = rune_info_bag.list[i].type
            this.info_bag[position].lock = rune_info_bag.list[i].lock
            this.info_bag[position].exp = rune_info_bag.list[i].exp
        end
    end
    
    --按照英雄ID、符文ID重新整理数据
    db_processor_[C.kRuneInfoHero] = function(msg)
        local rune_info_hero = cast('const RuneInfoHeroList&', msg)
        this.space_hero = rune_info_hero.count
        for i=0,this.space_hero - 1 do
            local hero_id = rune_info_hero.list[i].location
            local rune_id = rune_info_hero.list[i].rune_id
            if not this.info_hero[hero_id] then this.info_hero[hero_id] = {} end
            this.info_hero[hero_id][rune_id] = {}
            this.info_hero[hero_id][rune_id].type = rune_info_hero.list[i].type
            this.info_hero[hero_id][rune_id].position = rune_info_hero.list[i].position
            this.info_hero[hero_id][rune_id].lock = rune_info_hero.list[i].lock
            this.info_hero[hero_id][rune_id].exp = rune_info_hero.list[i].exp
        end
    end
    
    --客户端消息处理
    local processor_ = {}
    
    processor_[C.kGetStoveStatus] = function(msg)
        local result = new('GetStoveStatusReturn', 0)
        local inner_result = stove_instance.GetStoveStatus()
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS then
            result.status = runes_to_number(this.status)
            result.count = rune_count[player.GetVIPLevel()].count - player.GetVIPCount(4)
        end
        return result
    end
    
    processor_[C.kGetStoveRunes] = function(msg)
        local result = new('GetStoveRunesReturn', 0)
        local list_count = 0
        local inner_result, inner_info = stove_instance.GetStoveRuneList()
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS then
            result.bag_count = this.space_bag
            
            local temp = {}
            for k,v in pairs(inner_info) do
                temp[#temp + 1] = {id=k, type=v.type}
            end
            table.sort(temp, function(a,b) return a.id<b.id end)
            
            for _,v in ipairs(temp) do
                result.rune_list[list_count].rune_id = v.id
                result.rune_list[list_count].rune_type = v.type
                list_count = list_count + 1
            end
        end
        result.list_count = list_count
        
        local result_length = 12 + result.list_count * sizeof(result.rune_list[0])
        return result, result_length
    end
    
    processor_[C.kClickMaterial] = function(msg)
        local result = new('ClickMaterialReturn', 0)
        local inner_result, inner_info = stove_instance.ClickMaterial(cast('const ClickMaterial&', msg).material)
        result.result = inner_result 
        if result.result==C.RUNE_SUCCESS then
            result.rune_id = inner_info[1]
            result.rune_type = inner_info[2]
            result.status = runes_to_number(this.status)
        end
        return result
    end
    
    processor_[C.kPickupRunes] = function(msg)
        local PickupRunes = cast('const PickupRunes&', msg)
        local result = new('PickupRunesReturn', 0)
        result.result = stove_instance.PickupRunes(PickupRunes.runes_count,PickupRunes.runes_id)
        return result
    end
    
    processor_[C.kResolveRunes] = function(msg)
        local ResolveRunes = cast('const ResolveRunes&', msg)
        local result = new('ResolveRunesReturn', 0)
        result.result = stove_instance.ResolveRunes(ResolveRunes.runes_count,ResolveRunes.runes_id)
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
        end
        return result
    end
    
    processor_[C.kGetBagRunes] = function(msg)
        local result = new('GetBagRunesReturn', 0)
        local list_count = 0
        local inner_result, inner_info = rune_instance.GetBagRuneList()
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
            for k,v in pairs(inner_info) do
                result.rune_list[list_count].rune_id = v.rune_id
                result.rune_list[list_count].rune_type = v.type
                result.rune_list[list_count].position = k
                result.rune_list[list_count].lock = v.lock
                result.rune_list[list_count].exp = v.exp
                list_count = list_count + 1
            end
        end
        result.list_count = list_count

        local result_length = 12 + result.list_count * sizeof(result.rune_list[0])
        return result, result_length
    end
    
    processor_[C.kGetHeroRunes] = function(msg)
        local result = new('GetHeroRunesReturn', 0)
        local list_count = 0
        local inner_result, inner_info = rune_instance.GetHeroRuneList(cast('const GetHeroRunes&', msg).hero_id)
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS and inner_info then
            for k,v in pairs(inner_info) do
                result.rune_list[list_count].rune_id = k
                result.rune_list[list_count].rune_type = v.type
                result.rune_list[list_count].position = v.position
                result.rune_list[list_count].exp = v.exp
                list_count = list_count + 1
            end
        end
        result.list_count = list_count

        local result_length = 8 + result.list_count * sizeof(result.rune_list[0])
        return result, result_length
    end
    
    processor_[C.kResolveBagRune] = function(msg)
        local result = new('ResolveBagRuneReturn', 0)
        result.result = rune_instance.ResolveBagRune(cast('const ResolveBagRune&', msg).position)
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
        end
        return result
    end
    
    processor_[C.kLockRune] = function(msg)
        local result = new('LockRuneReturn', 0)
        result.result = rune_instance.LockRune(cast('const LockRune&', msg).position)
        return result
    end
    
    processor_[C.kChangeRuneInBag] = function(msg)
        local ChangeRuneInBag = cast('const ChangeRuneInBag&', msg)
        local result = new('ChangeRuneInBagReturn', 0)
        result.result = rune_instance.ChangeBagGrid(ChangeRuneInBag.old_position, ChangeRuneInBag.new_position)
        return result
    end
    
    processor_[C.kChangeRuneOnHero] = function(msg)
        local ChangeRuneOnHero = cast('const ChangeRuneOnHero&', msg)
        local result = new('ChangeRuneOnHeroReturn', 0)
        result.result = rune_instance.ChangePosition(ChangeRuneOnHero.rune_id, ChangeRuneOnHero.hero_id, ChangeRuneOnHero.position)
        return result
    end
    
    processor_[C.kWearDropRune] = function(msg)
        local WearDropRune = cast('const WearDropRune&', msg)
        local result = new('WearDropRuneReturn', 0)
        local inner_result, inner_info = rune_instance.WearDropRune(WearDropRune.rune_id, WearDropRune.hero_id, WearDropRune.position)
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS then
            result.position = inner_info
            fight_power.CheckFightPowerChange(player.GetUID())
        end
        return result
    end
    
    processor_[C.kUpgradeRune] = function(msg)
        local result = new('UpgradeRuneReturn', 0)
        result.result = rune_instance.UpgradeRune(cast('const UpgradeRune&', msg).position)
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
        end
        return result
    end
    
    processor_[C.kResolveAllRunes] = function(msg)
        local result = new('ResolveAllRunesReturn', 0)
        result.result = rune_instance.ResolveAllRunes(cast('const ResolveAllRunes&', msg).position)
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
        end
        return result
    end
    
    processor_[C.kGoldActivation] = function(msg)
        local result = new('GoldActivationReturn', 0)
        result.result = stove_instance.GoldActivation()
        if result.result==C.RUNE_SUCCESS then
            result.status = runes_to_number(this.status)
            result.count = rune_count[player.GetVIPLevel()].count - player.GetVIPCount(4)
        end
        return result
    end
    
    processor_[C.kSortRunes] = function(msg)
        local result = new('SortRunesResult', 0)
        local inner_result, inner_info = rune_instance.SortRunes()
        result.result = inner_result
        if result.result==C.RUNE_SUCCESS then
            result.changed = inner_info
        end
        return result
    end
    
    processor_[C.kUpgradeRuneOnHero] = function(msg)
        local UpgradeRuneOnHero = cast('const UpgradeRuneOnHero&', msg)
        local result = new('UpgradeRuneOnHeroResult', 0)
        result.result = rune_instance.UpgradeRuneOnHero(UpgradeRuneOnHero.rune_id, UpgradeRuneOnHero.hero_id)
        if result.result==C.RUNE_SUCCESS then
            result.energy = this.energy
        end
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
            if result.result==C.RUNE_SUCCESS then
                result.result = 0
            end
            return result, result_length
        end
    end
    
    --改变英雄ID
    function obj.ChangeHeroID(hero_id, new_id)
        this.info_hero[new_id] = this.info_hero[hero_id]
        this.info_hero[hero_id] = nil
        data.ChangeRuneHeroID(player.GetUID(), hero_id, new_id)
    end
    
    return obj
end