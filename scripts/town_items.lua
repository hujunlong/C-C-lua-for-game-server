require('tools.rect')
require('tools.table_ext')
require('config.town_cfg')
local global_cfg = require('config.global')
local sys_define = require('define.actives')
require('main_line')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new

local item_cfgs, upgrade_cfgs, merge_cfgs = GetTownCfg()
local invalid_points = require('config.invalid_points')
local actions = require('define.action_id')

local GetMaxCityhallLevel = GetMaxCityhallLevel


function CreatePlayerTownItems(uid, player)
local me = player
local obj = {}

local items_ = {}
local max_id_ = 0
local items_cd_start_time_ = {}

local InsertRow = me.InsertRow
local UpdateField = me.UpdateField
local DeleteRow = me.DeleteRow

local prosperity_degree = 0
local items_expired_time_ = {}

--inner functions
local function CreateItem(type,kind)
	local item = nil
	if type==C.kFunctionBuilding then
		item = new('FunctionBuildingStatus')
		item.level, item.progress,item.last_reap = 1, 0, 0
	elseif type==C.kBusinessBuilding then
		item = new('BusinessBuildingStatus')
		item.last_reap, item.progress = 0, 0
	elseif type==C.kDecoration then
		item = new('DecorationStatus')
	elseif type==C.kRoad then
		item = new('RoadStatus')
	end
	if item then item.kind,item.aspect=kind,C.kDefaultAspect end
	return item
end

local function Item2Type(item)
	assert(item_cfgs[item.kind], "error kind "..item.kind)
	return item_cfgs[item.kind].type
end

local function IsBulidingComplete(item)
	local cfg = item_cfgs[item.kind]
	return item.progress >= cfg.build_times
end

local function GetCityHallLevel()
	for _,item in pairs(items_) do 
		if item.kind==global_cfg.town.kCityHallKind then return item.level end
	end
end

local function CanUpgrade(item)
	if not IsBulidingComplete(item) then return C.eInvalidOperation end
	local kind = item.kind
	if item_cfgs[kind].type~=C.kFunctionBuilding then return C.eInvalidOperation end
	if kind~=global_cfg.town.kCityHallKind then --非市政厅升级
		local hall_level = GetCityHallLevel()
		if not hall_level then return C.eInvalidOperation end
		if item.level>=hall_level then return C.eLowCityHallLevel end
	else 
		if item.level>=player.GetLevel() then
			return C.eNotMatchDepend 
		end
	end
	return C.eSucceeded
end

local function CheckMergeObjectKind(kind_a, kind_b, object_kind)
	local cfg = merge_cfgs[object_kind]
	return cfg.building_kind_a==kind_a and cfg.building_kind_b==kind_b    or    cfg.building_kind_a==kind_b and cfg.building_kind_b==kind_a
end

local function HasRoadNearBy(x,y,width, height)
	for _,item in pairs(items_) do
		local cfg = item_cfgs[item.kind]
		if cfg.type==C.kRoad and not item.warehoused then
			if rect.IsNearRect(x,y,width,height, item.x, item.y, cfg.occupy.x, cfg.occupy.y) then return true end
		end
	end
end

local function GetNearByBusinessBuildings(x,y,width,height)
	local items = {}
	for _,item in pairs(items_) do
		local cfg = item_cfgs[item.kind]
		if cfg.type==C.kBusinessBuilding and not item.warehoused then
			if rect.IsNearRect(x,y,width,height, item.x, item.y, cfg.occupy.x, cfg.occupy.y) then table.insert(items, item) end
		end
	end	
	return items
end

local function CanPut(kind, x, y, aspect, item_id)
	local cfg = item_cfgs[kind]
	for id,item in pairs(items_) do
		if item_id~=id and not (Item2Type(item)~=C.kFunctionBuilding and item.warehoused) then
			if rect.IsIntersectingRect(x,y,cfg.occupy.x,cfg.occupy.y, item.x, item.y, item_cfgs[item.kind].occupy.x, item_cfgs[item.kind].occupy.y) then
				return false
			end
		end
	end
	for i,point in ipairs(invalid_points) do
		if rect.IsInRect(x, y, cfg.occupy.x, cfg.occupy.y, point.x, point.y) then return false end
	end
	return true
end

local function Kind2DbTable(kind)
	local type = item_cfgs[kind].type
	if type==C.kFunctionBuilding then
		return C.ktFunctionBuilding
	elseif type==C.kBusinessBuilding then
		return C.ktBusinessBuilding
	elseif type==C.kDecoration then
		return C.ktDecoration
	elseif type==C.kRoad then
		return C.ktRoad
	end
end

local function AddItem2Db(id, kind, x, y)
	InsertRow( Kind2DbTable(kind), {C.kfID,id}, {C.kfKind,kind}, {C.kfX, x}, {C.kfY, y} )
end

local function CalcAddtion(item, enable)
	if not enable then return 0 end
	local total = 0
	local item_width, item_height = item_cfgs[item.kind].occupy.x, item_cfgs[item.kind].occupy.y
	for id,other in pairs(items_) do
		local cfg = item_cfgs[other.kind]
		if cfg.addition then
			local x,y,w,h = rect.ExpandRect(other.x, other.y, cfg.occupy.x, cfg.occupy.y, 3)
			if rect.IsIntersectingRect(x,y,w,h, item.x,item.y,item_width,item_height) then total = total+cfg.addition end
		end
	end
	return total
end

local function ActivateSubsystem(kind)
	local cfg = global_cfg.town
	if kind==cfg.kArenaKind then
		player.ActivateSubSystem(sys_define.kSubSystemArena)
	elseif kind==cfg.kTreasureHouseKind then
		player.ActivateSubSystem(sys_define.kSubSystemRune)
	elseif kind==cfg.kAuctionKind then
		player.ActivateSubSystem(sys_define.kSubSystemAuction)
	elseif kind==cfg.kMilitaryKind then
		player.ActivateSubSystem(sys_define.kSubSystemWorldWar)
	elseif kind==cfg.kTowerKind then
		player.ActivateSubSystem(sys_define.kSubSystemTower)
	elseif kind==cfg.kFishKind then
		player.ActivateSubSystem(sys_define.kSubSystemFish)
	elseif kind==cfg.kDragonHouseKind then
		player.ActivateSubSystem(sys_define.kSubSystemRearDragon)
	elseif kind==cfg.kTreeKind then
		player.ActivateSubSystem(sys_define.kSubSystemTree)
	elseif kind==cfg.kPlaygroundKind then
		player.ActivateSubSystem(sys_define.kSubSystemTurntable)
	end
end


local function OnBuildingComplete(item)
	player.BuildingLevelup(item.kind, 1)
	ActivateSubsystem(item.kind)
	player.Send2Gate(new('TownProsperityDegree', obj.CalcProsperityDegree()))
	me.RecordAction(actions.kFoundationCount,1)
	local type = Item2Type(item)
	me.RecordAction(actions.kBuildingTotalAmout, obj.Count(type), type)
	local count = obj.CountWithKind(item.kind)
	player.RecordAction(actions.kBuildingAmout, count, item.kind) 
end

--others
function obj.GetItem(id)
	return items_[id]
end

function obj.HasBuilding(kind)
	for _,item in pairs(items_) do 
		if item.kind==kind then return true end
	end
	return false
end

function obj.GetBuildingLevel(kind)
	for _,item in pairs(items_) do 
       if item.kind==kind then
            if  IsBulidingComplete(item) then
                return item.level
            else
                return 0
            end 
       end
	end
end

function obj.FindBuildingByKind(kind)
	for _,item in pairs(items_) do 
		if item.kind==kind then return item end
	end
end

--for db
function obj.AddItem(item, type)
    items_[item.id] = item
    if item.id>max_id_ then max_id_=item.id end
	items_cd_start_time_[item.id] = os.time()
end

--gate
function obj.GetAllItems()
	local ret = {}
        for k,item in pairs(items_) do
            table.insert(ret,item)
        end
	return ret
end

function obj.Count(btype)
	if not btype then return table.size(items_) end
	local count = 0
	for _,item in pairs(items_) do 
		if Item2Type(item)==btype then count=count+1 end
	end
	return count
end

function obj.CountWithKind(kind)
	local count = 0
	for _,item in pairs(items_) do 
		if item.kind==kind then count=count+1 end
	end
	return count	
end

function obj.ProduceNewBuilding(kind, x, y)
	local cfg = item_cfgs[kind]
	local item = CreateItem(cfg.type, kind)
	if not item then return  end
	max_id_ = max_id_+1
	item.id, item.kind, item.x, item.y, item.aspect = max_id_, kind, x or 0, y or 0, C.kDefaultAspect
	obj.AddItem(item, cfg.type)
	AddItem2Db(item.id, item.kind, item.x, item.y)
	if not cfg.build_times or cfg.build_times==0 then
		OnBuildingComplete(item)
	end
	return item
end

function obj.Foundation(fd, cfg)
	if cfg.unique and obj.HasBuilding(fd.kind) then return C.eBuildingIsUnique end
	if not CanPut(fd.kind,fd.x,fd.y,nil,nil) or table.size(items_)>=3000 then return C.eOccupy end
--[[	if cfg.type==C.kBusinessBuilding and not HasRoadNearBy(fd.x, fd.y, cfg.occupy.x, cfg.occupy.y) then
		return C.eNotNearByRoad
	end		]]
	for id,item in pairs(items_) do
		if cfg.type==C.kFunctionBuilding and item.kind==fd.kind then return C.eOccupy end
	end
	local item = obj.ProduceNewBuilding(fd.kind, fd.x, fd.y)
	if not item then return C.eInvalidValue end
	if item then 
		if (cfg.type==C.kFunctionBuilding or cfg.type==C.kBusinessBuilding) and IsBulidingComplete(item)  then
			item.progress=100
			UpdateField( Kind2DbTable(item.kind), item.id, {C.kfProgress, item.progress} )
		end  --这个是为了防止以后配置改了建造次数，而造成已完成的建筑变为未完成
	end
	return C.eSucceeded,item
end

function obj.Warehousing(warehousing)
	local result = new('WarehousingResult', C.eInvalidValue, warehousing.id)
	local item = items_[warehousing.id]
	if item and Item2Type(item)~=C.kFunctionBuilding then
		item.warehoused,result.result = true,C.eSucceeded
		UpdateField(Kind2DbTable(item.kind), item.id, {C.kfWarehoused,1}, {C.kfX,-10} )
		player.RecordAction(actions.kWarehousingBuilding,1)
		player.Send2Gate(new('TownProsperityDegree', obj.CalcProsperityDegree()))
		player.InsertRow(C.ktTownWarehouse, {C.kfID, item.id}, {C.kfExpireTime, os.time()+7*24*3600})
		obj.SetItemExpiredTime(item.id, os.time()+7*24*3600)
	end
	return result
end

function obj.Build(build, cfg)
	local result = false
	local complete = false
	local item = items_[build.id]
	if item and item.progress and cfg.build_times and item.progress<cfg.build_times then
		item.progress = item.progress+1
		result = true
		complete = IsBulidingComplete(item)
		if complete then item.progress=100 end  --这个是为了防止以后配置改了建造次数，而造成已完成的建筑变为未完成
		UpdateField( Kind2DbTable(item.kind), item.id, {C.kfProgress, item.progress} )
		if complete then
			OnBuildingComplete(item)
		end
	end
	return result, complete
end

function obj.Move(move)
	local result = new('MoveResult', C.eInvalidValue, move.id, move.x, move.y, move.aspect)
	local item = items_[move.id]
	if item then
		if CanPut(item.kind, move.x, move.y, move.aspect, item.id) then
			if item.x~=move.x or item.y~=move.y then player.RecordAction(actions.kMoveBuilding,1) end --这是一次移动
			if item.aspect~=move.aspect then player.RecordAction(actions.kRotateBuilding,1)  end -- 这是一次旋转
			item.x,item.y,item.aspect = move.x,move.y,move.aspect
			if Item2Type(item)~=C.kFunctionBuilding and item.warehoused then  --从仓库移出
				item.warehoused = false
				UpdateField(Kind2DbTable(item.kind), item.id, {C.kfWarehoused,0} )
				player.Send2Gate(new('TownProsperityDegree', obj.CalcProsperityDegree()))
				DeleteRow(C.ktTownWarehouse, item.id)
				items_expired_time_[item.id] = nil
			end
			UpdateField( Kind2DbTable(item.kind), item.id, {C.kfX,item.x}, {C.kfY,item.y}, {C.kfAspect, item.aspect} )
			result.result = C.eSucceeded
		else
			result.result = C.eOccupy
		end
	end
	return result
end

local function WarehouseOccupy()  --仓库已占用的容量
	local count = 0
	for _,item in pairs(items_) do 
		if Item2Type(item)~=C.kFunctionBuilding and item.warehoused then 
			count = count+1
		end
	end
	return count
end

function obj.Upgrade(item)
	local ret = CanUpgrade(item, player.GetLastCompleteTask()) 
	if ret==C.eSucceeded then
		item.level = item.level+1
		UpdateField(Kind2DbTable(item.kind), item.id,  {C.kfLevel,item.level} )
		player.Send2Gate(new('TownProsperityDegree', obj.CalcProsperityDegree()))
	end
	return ret
end

function obj.Merge(merge)
	local result = C.eInvalidValue
	local item = nil
	item_a,item_b = items_[merge.id],items_[merge.other]
	if not item_a or not item_b or not IsBulidingComplete(item_a) or not IsBulidingComplete(item_b) then
		return C.eInvalidOperation
	end
	if CheckMergeObjectKind(item_a.kind, item_b.kind, merge.target_kind) then
		items_[merge.id],items_[merge.other] = nil,nil
		DeleteRow(C.ktBusinessBuilding, merge.id)
		DeleteRow(C.ktBusinessBuilding, merge.other)
		result = C.eSucceeded
		item = CreateItem(C.kBusinessBuilding, merge.target_kind)
		max_id_ = max_id_+1
		item.x,item.y,item.id = merge.x,merge.y,max_id_
		item.progress = 0
		obj.AddItem(item, item_cfgs[item.kind])
		AddItem2Db(item.id, item.kind, item.x, item.y)
	end
	return result,item
end

local function CanReapFuntionBuilding(item,cfg)
	local update_hour = cfg.update_at
	if update_hour<0 then return false end
	local fake_last_reap = os.date('*t', item.last_reap-update_hour*60*60)
	local fake_now = os.date("*t", os.time()-update_hour*60*60)
	if fake_last_reap.day<fake_now.day or fake_last_reap.month<fake_now.month or fake_last_reap.year<fake_now.year then
		return true
	end
end

function obj.Reap(item, cfg)
	if not IsBulidingComplete(item)  then return C.eInvalidOperation end
	if cfg.type==C.kBusinessBuilding and not item.warehoused  then
	    if item.last_reap > os.time() then
	        item.last_reap = 0
	    end
		if os.time()-item.last_reap<item_cfgs[item.kind].cool_down_seconds then
			return C.eWaitCooldown
		end
--[[		if not HasRoadNearBy(item.x, item.y, cfg.occupy.x, cfg.occupy.y) then
			return C.eNotNearByRoad
		end	
]]		items_cd_start_time_[item.id] = os.time()
		item.last_reap = os.time()
		UpdateField(C.ktBusinessBuilding, item.id, {C.kfLastReap,0} )
		return C.eSucceeded,CalcAddtion(item, cfg.enable_decoration)
	elseif cfg.type==C.kFunctionBuilding  then
		if not CanReapFuntionBuilding(item, cfg) then
			return C.eWaitCooldown
		end
		item.last_reap = os.time()
		UpdateField(C.ktFunctionBuilding, item.id, {C.kfLastReap,0} )
		return C.eSucceeded,0
	end
end

function obj.Sell(item)
	items_[item.id] = nil
	items_cd_start_time_[item.id] = nil
	DeleteRow(Kind2DbTable(item.kind), item.id)
	player.Send2Gate(new('TownProsperityDegree', obj.CalcProsperityDegree()))
end

function obj.CalcProsperityDegree()
	local val = 0
	for _,item in pairs(items_) do
		if upgrade_cfgs[item.kind] then
			val = val + upgrade_cfgs[item.kind][item.level].prosperity
		else
			val = val + item_cfgs[item.kind].prosperity
		end
	end
	if val~=prosperity_degree then 
		prosperity_degree = val
		player.UpdateField(C.ktMiscInfo, C.kInvalidID, {C.kfDegreeOfProsperity, val})
	end
	return val
end

function obj.FunctionBuildingsLevel()
	local ret = {}
	for _,item in pairs(items_) do
		if item_cfgs[item.kind].type==C.kFunctionBuilding and IsBulidingComplete(item) then
			ret[item.kind] = item.level
		end
	end
	return ret
end

function obj.SetItemExpiredTime(id, time)
	if time<os.time() and items_[id] then --已过期
		DeleteRow(Kind2DbTable(items_[id].kind), id)
		DeleteRow(C.ktTownWarehouse, id)
		items_[id] = nil
	else 
		items_expired_time_[id] = time
	end
end

function obj.GetItemExpiredTime(id)
	return items_expired_time_[id]
end

function obj.ActiveBuildingFunctions()
	for _,item in pairs(items_) do
		if item_cfgs[item.kind].type==C.kFunctionBuilding and IsBulidingComplete(item) then
			ActivateSubsystem(item.kind)
		end
	end	
end

return obj

end





