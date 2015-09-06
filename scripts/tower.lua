--试炼塔
local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

local tower_cfgs = require('config.tower')

require('tower_mgr')

function CreateTower(player)
    local obj = {}
    
    --
    local this = {}
    this.activate = false
    
    local instance = CreateTowerManager(player, this)
    
    --激活功能
    function obj.open()
        if not this.activate then
            this.activate = true
            
            player.InsertRow(C.ktTower, {C.kfStatus, 0})
            
            this.tower = 1
            this.layer = 0
            this.refresh = 0
            this.status = 0
            this.suspend = 0
            this.time = 0
        end
    end
    
    --每日重置
    function obj.Reset()
        this.refresh = 0
    end
    
    
    --数据库消息处理
    local db_processor_ = {}
    db_processor_[C.kTowerInfo] = function(msg)
        local db_tower_info = cast('const TowerInfo&', msg)
        this.tower = db_tower_info.tower
        this.layer = db_tower_info.layer
        this.refresh = db_tower_info.refresh
        this.status = db_tower_info.status
        this.suspend = db_tower_info.suspend
        this.time = db_tower_info.time
        
        this.activate = true
        
        if this.tower~=#tower_cfgs and tower_cfgs[this.tower] and this.layer==#tower_cfgs[this.tower] then
            this.tower = this.tower + 1
            this.layer = 0
            player.UpdateField(C.ktTower, C.kInvalidID, {C.kfTower, this.tower}, {C.kfLayer, this.layer})
        end
    end
    
    
    --客户端消息处理
    local processor_ = {}
    
    --
    processor_[C.kGetTowerInfo] = function(msg)
        local result = new('GetTowerInfoResult', 0)
        local inner_result, inner_info = instance.GetTowerInfo()
        result.result = inner_result
        if result.result==C.TOWER_SUCCESS then
            result.tower = inner_info[1]
            result.layer = inner_info[2]
            result.refresh = inner_info[3]
            result.status = inner_info[4]
            result.time = inner_info[5]
            result.suspend = inner_info[6]
        end
        return result
    end
    
    --
    processor_[C.kResetTower] = function(msg)
        local result = new('ResetTowerResult', 0)
        local ResetTower = cast('const ResetTower&', msg)
        local inner_result, inner_info = instance.ResetTower(ResetTower.tower)
        result.result = inner_result
        if result.result==C.TOWER_SUCCESS then
            --
        end
        return result
    end
    
    --
    processor_[C.kFightTower] = function(msg)
        local result = new('FightTowerResult', 0)
        local inner_result, inner_info = instance.FightTower()
        result.result = inner_result
        if result.result==C.TOWER_SUCCESS then
            result.tower = inner_info[1]
            result.layer = inner_info[2]
            result.succeed = inner_info[3]
            result.time = inner_info[4]
            result.fight_record_bytes = inner_info[5]
            copy(result.fight_record, inner_info[6], result.fight_record_bytes)
            
            return result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        return result
    end
    
    --
    processor_[C.kMopupTower] = function(msg)
        local result = new('MopupTowerResult', 0)
        local inner_result, inner_info = instance.MopupTower()
        result.result = inner_result
        if result.result==C.TOWER_SUCCESS then
            result.suspend = inner_info==0 and 0 or 1
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
            if result.result==C.TOWER_SUCCESS then
                result.result = 0
            else
                result_length = 4
            end
            return result, result_length
        end
    end
    
    return obj
end