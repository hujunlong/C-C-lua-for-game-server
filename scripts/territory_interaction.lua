--玩家领地{交互管理}
local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

local config = require('config.global')

require('territory')

local territory_resource = require('config.territory_resource')

local territory_data = require('territory_data')
local territory_player = territory_data.GetTerritoryPlayer()

function TerritoryInteraction(player)
    local obj = {}
    
    --数据保存
    local this = {}
    this.activate = false         --是否激活
    
    local instance = CreateTerritory(player, this)
    
    --激活功能
    function obj.open()
        if not this.activate then
            instance.CheckDistribute()
            this.activate = true
        end
    end
    
    --数据库消息处理
    local db_processor_ = {}
    db_processor_[C.kTerritoryOffline] = function(msg)
        local territory_offline = cast('const TerritoryOffline&', msg)
        local result = new('TerritoryTimeout')
        result.time = territory_offline.time
        player.Send2Gate(result)
    end
    
    --客户端消息处理
    local processor_ = {}
    
    --获取领地基本信息
    processor_[C.kGetTerritoryStatus] = function(msg)
        local result = new('GetTerritoryStatusResult', 0)
        local inner_result, inner_info = instance.GetTerritoryStatus()
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.can_move = inner_info[1]
            result.can_grab = inner_info[2]
            result.rob_count = inner_info[3]
            result.assist = inner_info[4]
            result.move_cd = inner_info[5]
            result.grab_cd = inner_info[6]
            result.kill_cd = inner_info[7]
            result.reap_cd = inner_info[8]
        end
        return result
    end
    
    --查看领地
    processor_[C.kViewTerritory] = function(msg)
        local result = new('ViewTerritoryResult', 0)
        local view = cast('const ViewTerritory&', msg)
        local inner_result, inner_info = instance.ViewTerritory(view.type, view.page)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.page = inner_info[1]
            result.style = inner_info[2]
            
            result.city_count = 0
            result.resource_count = 0
            for seral,v in ipairs(inner_info[3]) do
                if v.kind==0 then
                    if result.city_count<10 then
                        result.city_list[result.city_count].index = seral
                        result.city_list[result.city_count].type = v.kind
                        result.city_list[result.city_count].busy = v.owner==0 and 0 or 1
                        if v.owner~=0 then
                            result.city_list[result.city_count].bandits = config.territory.can_robber - territory_player[v.owner].robber
                            result.city_list[result.city_count].id = v.owner
                            result.city_list[result.city_count].type = territory_player[v.owner].skin
                            result.city_list[result.city_count].name = data.GetCPlayerName(v.owner)
                        end
                        
                        result.city_count = result.city_count + 1
                    end
                else
                    if result.resource_count<10 then
                        result.resource_list[result.resource_count].index = seral
                        result.resource_list[result.resource_count].type = v.kind
                        result.resource_list[result.resource_count].busy = v.owner==0 and 0 or 1
                        if v.owner~=0 then
                            result.resource_list[result.resource_count].id = v.owner
                            result.resource_list[result.resource_count].name = data.GetCPlayerName(v.owner)
                            result.resource_list[result.resource_count].time = territory_player[v.owner].time + territory_resource[v.kind].time
                            result.resource_list[result.resource_count].guard_time = territory_player[v.owner].time + territory_resource[v.kind].guard_time
                        end
                        
                        result.resource_count = result.resource_count + 1
                    end
                end
            end
        end
        return result
    end
    
    --定位玩家领地
    processor_[C.kTerritoryGPS] = function(msg)
        local result = new('TerritoryGPSResult', 0)
        local inner_result, inner_info = instance.TerritoryGPS()
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.type = inner_info[1]
            result.page = inner_info[2]
        end
        return result
    end
    
    --迁移玩家领地
    processor_[C.kMoveTerritory] = function(msg)
        local result = new('MoveTerritoryResult', 0)
        local move = cast('const MoveTerritory&', msg)
        local inner_result, inner_info = instance.MoveTerritory(move.type, move.page, move.index)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.move_cd = inner_info[1]
            result.can_move = inner_info[2]
            result.succeed = inner_info[3]
            result.fight_record_bytes = inner_info[4]
            copy(result.fight_record, inner_info[5], result.fight_record_bytes)
            
            return result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        return result
    end
    
    --收取资源
    --[[
    processor_[C.kReapResource] = function(msg)
        local result = new('ReapResourceResult', 0)
        local inner_result, inner_info = instance.ReapResource()
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.type = inner_info[1]
            result.amount = inner_info[2]
        end
        return result
    end
    ]]
    
    --争夺资源
    processor_[C.kGrabResource] = function(msg)
        local result = new('GrabResourceResult', 0)
        local grab = cast('const GrabResource&', msg)
        local inner_result, inner_info = instance.GrabResource(grab.type, grab.page, grab.index)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.grab_cd = inner_info[1]
            result.can_grab = inner_info[2]
            result.succeed = inner_info[3]
            result.fight_record_bytes = inner_info[4]
            copy(result.fight_record, inner_info[5], result.fight_record_bytes)
            
            return result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        return result
    end
    
    --放弃资源
    processor_[C.kDiscardResource] = function(msg)
        local result = new('DiscardResourceResult', 0)
        local inner_result, inner_info = instance.DiscardResource()
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            --
        end
        return result
    end
    
    --剿灭强盗
    --[[
    processor_[C.kKillBandits] = function(msg)
        local result = new('KillBanditsResult', 0)
        local kill = cast('const KillBandits&', msg)
        local inner_result, inner_info = instance.KillBandits(kill.type, kill.page, kill.index)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            result.kill_cd = inner_info[1]
            result.assist = inner_info[2]
            result.succeed = inner_info[3]
            result.type = inner_info[4]
            result.value = inner_info[5]
            result.fight_record_bytes = inner_info[6]
            copy(result.fight_record, inner_info[7], result.fight_record_bytes)
            
            return result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes
        end
        return result
    end
    ]]
    
    --停止查看领地
    processor_[C.kStopViewTerritory] = function(msg)
        local result = new('StopViewTerritoryResult', 0)
        local inner_result, inner_info = instance.StopViewTerritory()
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            --
        end
        return result
    end
    
    --花费金币清除CD
    processor_[C.kClearTerritoryCD] = function(msg)
        local result = new('ClearTerritoryCDResult', 0)
        local clear = cast('const ClearTerritoryCD&', msg)
        local inner_result, inner_info = instance.ClearTerritoryCD(clear.type)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            --
        end
        return result
    end
    
    --改变城池外观
    processor_[C.kSetTerritorySkin] = function(msg)
        local result = new('SetTerritorySkinResult', 0)
        local skin = cast('const SetTerritorySkin&', msg)
        local inner_result, inner_info = instance.SetTerritorySkin(skin.type)
        result.result = inner_result
        if result.result==C.TERRITORY_SUCCESS then
            --
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
            if result.result==C.TERRITORY_SUCCESS then
                result.result = 0
            else
                result_length = 4
            end
            return result, result_length
        end
    end
    
    function obj.UpdateLastActiveTime()
        if territory_player[player.GetUID()] then
            territory_player[player.GetUID()].last_active_time = os.time()
        end
    end
    
    return obj
end