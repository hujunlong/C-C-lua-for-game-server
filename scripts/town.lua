require('config.town_cfg')
require('town_items')
require('tools.vector')
require('main_line')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local cast = ffi.cast
local new = ffi.new

local GetActivedBuildings = GetActivedBuildings

local item_cfgs, upgrade_cfgs, merge_cfgs = GetTownCfg()
local global_config = require('config.global')
local default_actived_buildings = require('config.default_actived_buildings')
local actions = require('define.action_id')
local science_cfg = require('config.science')
local unlock_cost = require('config.unlock_town_block_cost')
local assistant_task_ids = require('config.assistant_task_id')
local commercial_building_upgrades = require('config.commercial_building_upgrades')
local gold_consume_flag = require('define.gold_consume_flag')
local kMaxBuildingCount = {[C.kFunctionBuilding]=C.kMaxFunctionBuildings, [C.kBusinessBuilding]=C.kMaxBusinessBuildings, [C.kDecoration]=C.kMaxDecorations, [C.kRoad]=C.kMaxRoads}
local kBuildingType2StrunctName = {[C.kFunctionBuilding]="FunctionBuildingStatus", [C.kBusinessBuilding]="BusinessBuildingStatus", [C.kDecoration]="DecorationStatus", [C.kRoad]="RoadStatus"}

--local const data
local kCommonUpgradeType = 1
local kGoldUpgradeType = 2
local kResetTime = 1262275200
local function DetectBankId()
    for i,bank in pairs(upgrade_cfgs) do
        if bank[1].silver_upper_limit ~= nil and bank[2].silver_upper_limit ~= nil then
            return i
        end
    end
    print("get bank level error\n")
end

local function DetectCommerceId()
    for j,commerce in pairs(upgrade_cfgs) do
        if commerce[1].add_silver ~= nil and commerce[2].add_silver then
            return j
        end
    end
    print("get commerce level error\n")
end

local bank_id = DetectBankId()
local commerce_id = DetectCommerceId()

local function GetItemCfg(kind)
	return item_cfgs[kind]
end

local function GetUpdateCfg(item)
	if GetItemCfg(item.kind).type == C.kFunctionBuilding then
		return upgrade_cfgs[item.kind] and upgrade_cfgs[item.kind][item.level]
	end
end

local function GetMergeNeeded(target_kind)
	return merge_cfgs[target_kind]
end

local function IsNearBlock(blocks, index)
	for i=0,35 do --土地为6*6个大格子
		if blocks.block_status[i]>0 then
			if index==i-6 or index==i+6 or (index==i-1 and i%6~=0) or (index==i+1 and i%6~=5)	 then
				return true
			end
		end
	end
end

local function CountUnlockedBlocks(blocks)
	local count = 0
	for i=0,35 do --土地为6*6个大格子
		if blocks.block_status[i]>0 then count=count+1 end
	end
	return count
end


function CreateTown(uid, player)
	local me = player
	local obj = {}
--	local base_info_ = nil
--	local props_ = {}
--	local skills_level_ = {}
	local processor_ = {}
	local db_processor_ = {}

	local items_ = CreatePlayerTownItems(uid,player)
	local todb_head_ = new("MqHead", uid)

	local blocks_ = new('TownBlocks')

--Inner methods

	local function Send2Db(msg)
		todb_head_.type = msg.kType
		C.Send2Db(todb_head_, msg, sizeof(msg))
	end

	local function DealReap(item)
		cfg = item_cfgs[item.kind]

		if cfg.type==C.kFunctionBuilding then
			return me.DealRewards(cfg.product[item.level])
		elseif cfg.type==C.kBusinessBuilding then
			return me.DealRewards(cfg.product)
		end
	end


	local function CheckResourceNeeded(res)
		if res.silver and not me.IsSilverEnough(res.silver) then return false end
		if res.energy and not me.IsEnergyEnough(res.energy) then return false end
		for i,val in ipairs(res) do
			if me.IsPropEnough(val.kind, val.amount) then return false end
		end
		return true
	end

	local function ReduceResourceNeeded(res)
		if res.silver then me.ModifySilver(-res.silver) end
		if res.energy then me.ModifyEnergy(-res.energy) end
		for i,val in ipairs(res) do
			me.ModifyProp(val.kind, -val.amount)
		end
	end

	local function AddItem(type, data)
		if type==C.kRoadStatus then
				name = 'RoadStatus'
		elseif type==C.kBusinessBuildingStatus then
				name = 'BusinessBuildingStatus'
		elseif type==C.kFunctionBuildingStatus then
				name = 'FunctionBuildingStatus'
		elseif type==C.kDecorationStatus then
                name = 'DecorationStatus'
		end
		local item = new(name)
		ffi.copy(item, data, sizeof(item))
		items_.AddItem(item)
	end

	local function GetReap(item, cfg)
		if cfg.type==C.kFunctionBuilding then
			return me.DealRewards(cfg.product[item.level])
		elseif cfg.type==C.kBusinessBuilding then
			return me.DealRewards(cfg.product)
		end
	end
	
	local function CanUnlockMoreBlock()
		local max_blocks_to_unlock = 36
		local unlocked_blocks = CountUnlockedBlocks(blocks_)
		local skill_level = player.GetSkills()[global_config.town.kUnlockBlockSkillID]
		if not skill_level then return false end
		return unlocked_blocks<max_blocks_to_unlock and unlocked_blocks < science_cfg[global_config.town.kUnlockBlockSkillID][skill_level].gain.unlock_block+9
	end
--Gate
	processor_[C.kGetMyTown] = function()
		local ret = new('GetMyTownReturn')
		ret.block_status = blocks_.block_status
		ret.max_hall_level = GetMaxCityhallLevel(player.GetLastCompleteTask(), player.GetCountry())
		ret.prosperity_degree = items_.CalcProsperityDegree()
		return ret
	end
--[[
	processor_[C.kGetTownItem] = function(msg)
		local id = cast('const GetTownItem&', msg).id
		local item = items_.GetItem(id)
		return item
	end
]]	
	processor_[C.kGetMyTownBuildings] = function(msg)
		local type = cast('const GetMyTownBuildings&', msg).type
		local ret = new('MyTownBuildings')
		local count = 0
		local max_count = kMaxBuildingCount[type]
		if not max_count then return end
		for _,item in ipairs(items_.GetAllItems()) do 
			if item_cfgs[item.kind].type==type then 
				count = count+1
			end
		end
		if count>max_count then count=max_count end
		ret.count = count
		local new_str = string.format('%s[%d]', kBuildingType2StrunctName[type], count)
		local buildings = new(new_str)
		for _,item in ipairs(items_.GetAllItems()) do 
			if item_cfgs[item.kind].type==type then 
				buildings[count-1] = item
				if count==0 then break end
				count = count-1
			end		
		end	
		ffi.copy(ret.data, buildings, sizeof(buildings))
		return ret, 2+sizeof(buildings)
	end
	
	processor_[C.kFoundation] = function(msg)
		local fd = ffi.cast('const Foundation&', msg)
		local ret = ffi.new('FoundationResult', C.eInvalidValue, 0, fd)
		local cfg = GetItemCfg(fd.kind)
		if not cfg then return ret end
		local actived_buildings = GetActivedBuildings(items_.FunctionBuildingsLevel(), player.GetLastCompleteTask(), player.GetCountry())
		if not vector.find(actived_buildings, fd.kind) and not vector.find(default_actived_buildings, fd.kind) 
			and not vector.find(player.GetBrachTaskActivatedBuilidings(), fd.kind) then 
				ret.result = C.eFunctionDisable
				return ret
		end
		if not me.IsSilverEnough(cfg.foundation_silver_cost) or not me.IsEnergyEnough(cfg.foundation_energy_cost) then
			ret.result = C.eLackResource
			return ret
		end
		ret.result,item = items_.Foundation(fd,cfg)
		if ret.result==C.eSucceeded then
			ret.id = item.id
			me.ModifySilver( -cfg.foundation_silver_cost )
			me.ModifyEnergy( -cfg.foundation_energy_cost )
		end
		return ret
	 end

	processor_[C.kBuild] = function(msg)
		local build = cast('const Build&', msg)
		local item = items_.GetItem(build.id)
		local ret = new('BuildResult', C.eInvalidValue, build.id)
		if item then
			local cfg = GetItemCfg(item.kind)
			if cfg and me.IsEnergyEnough(cfg.energy_cost_per_build) then
				local result,complete = items_.Build(build, cfg)
				if result then
					ret.result = C.eSucceeded
					me.ModifyEnergy(-cfg.energy_cost_per_build)
					local expired_rewards = complete and cfg.complete_reward or cfg.build_reward
					if expired_rewards then
						local rewards = me.DealRewards(expired_rewards)
						ret.count = table.getn(rewards)
						ret.rewards = rewards
					end
				end
			end
		end
		return ret
	end

	processor_[C.kMove] = function(msg)
		return items_.Move( cast('const Move&', msg) )
	end

	processor_[C.kUpgrade] = function(msg)
		local upgrade = cast('const Upgrade&', msg)
		local item = items_.GetItem(upgrade.id)
		local cfg = GetUpdateCfg(item)
		local ret = new('UpgradeResult', C.eInvalidValue, upgrade.id)
		if not cfg then
			return ret
		end

		if CheckResourceNeeded(cfg) then
			ret.result = items_.Upgrade(item)
			if ret.result==C.eSucceeded  then
				ReduceResourceNeeded(cfg)
				me.BuildingLevelup(item.kind, item.level)
				if cfg.lord_exp then 
					ret.lord_exp = cfg.lord_exp
					me.AddLordExp(cfg.lord_exp)
				end
				 
				--成就相关
				player.RecordAction(actions.kBuidingLevel, item.level, item.kind)
				player.RecordAction(actions.kBuidingUpgradeCount, 1)
			end
		else
			ret.result = C.eLackResource
		end
		return ret
	end

	processor_[C.kMerge] = function(msg)
		local merge = cast('const Merge&', msg)
		local ret = new('MergeResult', C.eInvalidValue, merge)
		local needed = GetMergeNeeded(merge.target_kind)
		if not needed then 
		elseif CheckResourceNeeded(needed) then
--			ret.result = items_.Merge(merge)
			local result,item =  items_.Merge(merge)
			ret.result = result
			if ret.result==C.eSucceeded and item then
				ReduceResourceNeeded(needed)
				ret.new_item = item.id
			end
		else
			ret.result = C.eLackResource
		end
		return ret
	end

	processor_[C.kReap] = function(msg)
		local reap = cast('const Reap&', msg)
		local item = items_.GetItem(reap.id)
		local ret = new('ReapResult', C.eInvalidValue, reap.id)
        if item == nil then
            return ret
        end
		local cfg = item_cfgs[item.kind]
		if cfg.type~=C.kFunctionBuilding and cfg.type~=C.kBusinessBuilding then
			return ret
		end
		if cfg.reap_energy_cost then
			if not me.IsEnergyEnough(cfg.reap_energy_cost) then 
				ret.result = C.eLackResource
				return ret
			end
		end
   
		local result,addition = items_.Reap(item, cfg)
		ret.result = result
		if result==C.eSucceeded and addition then
			if cfg.reap_energy_cost then me.ModifyEnergy(-cfg.reap_energy_cost) end
			local rewards = GetReap(item, cfg)		
			if not rewards then
				ret.result = C.eInvalidOperation
				return ret
			end
			for i,rwd in ipairs(rewards) do
				if rwd.type==C.kSilverRsc then
                        --商业建筑加成写数据库
                        local add_percent = 0
                        if cfg.type == C.kBusinessBuilding  then
                            if commerce_id == nil then
                                print("get commerce_id error\n")
                                return 
                            end
                            local level = obj.GetBuildingLevel(commerce_id)
                            if level ~= nil and level ~= 0 then
                               add_percent =  upgrade_cfgs[commerce_id][level].add_silver 
                            end    
                        end
					local extra_silver = rwd.amount*(addition + add_percent)
					if extra_silver>0 then me.ModifySilver(extra_silver) end
					rwd.amount = rwd.amount + extra_silver
					me.RecordAction(actions.kReapAmount, rwd.amount)
					me.RecordAction(actions.kDecorationEffect, addition*100)
				end
			end
			ret.count = table.getn(rewards)
			ret.rewards = rewards
			me.RecordAction(actions.kReapCount,1)
			me.AssistantCompleteTask(assistant_task_ids.kReapBuilding)
		end
		return ret
	end


	processor_[C.kSell] = function(msg)
		local sell = cast("const Sell&", msg)
		local result = new("SellResult", C.eInvalidValue, sell.id)
		local item = items_.GetItem(sell.id)
		if not item then return result  end
		local cfg = GetItemCfg(item.kind)
		if not cfg.available_for_sale then return result end
		local price = cfg.selling_price
		if price and price>0 then
			result.result = C.eSucceeded
			items_.Sell(item)
			me.ModifySilver(price)
		end
		return result
	end

	processor_[C.kGetTownBlocks] = function()
		return blocks_
	end

	processor_[C.kUnlockTownBlock] = function(msg)
		local unlock = cast('const UnlockTownBlock&', msg)
		local index = unlock.block_index
		local result = new('UnlockTownBlockResult', C.eInvalidOperation, index)
		if not CanUnlockMoreBlock() then
			result.result = C.eLowLevel
		elseif index>=0 and index<=35 and IsNearBlock(blocks_,index) then
				local cost = unlock_cost[CountUnlockedBlocks(blocks_)-9+1]
				if (unlock.pay_type==0 and player.IsSilverEnough(cost.silver)) or (unlock.pay_type==1 and player.IsGoldEnough(cost.gold)) then
				blocks_.block_status[index] = index+1  --置为非零表示这个格子已经开了
				result.result = C.eSucceeded
				Send2Db(blocks_)
				if unlock.pay_type==0 then
					player.ModifySilver(-cost.silver)
				elseif unlock.pay_type==1 then 
					player.ConsumeGold(cost.gold) 
				end
			else
				result.result = C.eLackResource
			end
		end
		return result
	end
	
	processor_[C.kGetTownProsperityDegree] = function()
		return new('TownProsperityDegree', items_.CalcProsperityDegree())
	end
	
	processor_[C.kGetBuildingExpireTime] = function(msg)
		local id = cast('const GetBuildingExpireTime&', msg).id
		local ret = new('GetBuildingExpireTimeResult')
		local item =  items_.GetItem(id)
		if item then 
			ret.time = items_.GetItemExpiredTime(id) or 0
		end
		return ret
	end

    processor_[C.kGetCommercialBuildingInfo] = function()
		local result = new('GetCommercialBuildingInfoResult')
        local building_home = global_config.town.kBuildingHomes
        local open_num = 0
        local level = obj.GetBuildingLevel(building_home)
        if not level then
            level = 0
        end
        for i,_commercial_building_upgrades in pairs(commercial_building_upgrades) do
           if level >= _commercial_building_upgrades.synthesis_building_level  then
                open_num = open_num + 1
                local synthesis_after_building_id = _commercial_building_upgrades.synthesis_after_building_id
                local is_only_building = item_cfgs[synthesis_after_building_id].unique
                if items_.HasBuilding(synthesis_after_building_id) and is_only_building then
                    result.building_info[i-1].is_only_building_have = 0
                else
                    result.building_info[i-1].is_only_building_have = 1   
                end
    
            end
        end
        result.open_num = open_num
        return result, 8 + sizeof(result.building_info[0])*open_num
	end
    
    local function ModifyBuildingMemoryInfo(base_id,upgrade_building_id,id)
        local item = items_.GetItem(id)
        if not item then
            assert(false,'ModifyBuildingMemoryInfo() error')
        end
        
        if item.kind == base_id then
            item.kind = upgrade_building_id
            item.last_reap = kResetTime
        end
    end
    
    --type 1普通 2直接融合
    processor_[C.kFusionUpgrade] = function(msg)
        local req = cast('const FusionUpgrade&', msg)
        local result = new('FusionUpgradeResult')
        
        for _,_commercial_building_upgrades in pairs(commercial_building_upgrades) do 
           
           local material = {}
            if _commercial_building_upgrades.synthesis_building_upgrades_id == req.base_id and _commercial_building_upgrades.synthesis_after_building_id == req.upgrade_building_id then
                for _,material_ in pairs(_commercial_building_upgrades) do
                    if type(material_) == 'table' then
                        table.insert(material,material_)
                    end
                end
                
                if req.type == kCommonUpgradeType then
                    
                    for _,material_ in pairs(material) do
                        local material_num  = material_.material_num
                        local material_id = material_.material_id
                        local own_material_num = me.HavePropAmount(material_id)
                        if own_material_num < material_num then
                            result.result = C.eLackResource
                            return result
                        end
                    end
  
                    for _,material_ in pairs(material) do
                        me.ModifyProp(material_.material_id,-material_.material_num)
                    end
                    
                    local synthesis_after_building_id = _commercial_building_upgrades.synthesis_after_building_id
                    ModifyBuildingMemoryInfo(_commercial_building_upgrades.synthesis_building_upgrades_id,_commercial_building_upgrades.synthesis_after_building_id,req.id)
                    me.UpdateField(C.ktBusinessBuilding, req.id, {C.kfKind,synthesis_after_building_id},{C.kfLastReap,C.kInvalidID} )
                    result.is_success = 1
                    return result
                    
                elseif req.type == kGoldUpgradeType then
                    local gold_count = 0
                    for _,material_ in pairs(material) do
                        local own_material_num = me.HavePropAmount(material_.material_id)
                        if material_.material_num > own_material_num then
                            gold_count = gold_count + (material_.material_num - own_material_num)*material_.cost_gold
                        end
                    end
                   
                    if not me.IsGoldEnough(gold_count) then								
                        result.result = C.eLackResource
                        return result
                    end
                    me.ConsumeGold(gold_count,gold_consume_flag.town_buy_material)
                    
                    for _,material_ in pairs(material) do
                        me.ModifyProp(material_.material_id,-material_.material_num)
                    end
                    
                    local synthesis_after_building_id = _commercial_building_upgrades.synthesis_after_building_id
                    ModifyBuildingMemoryInfo(_commercial_building_upgrades.synthesis_building_upgrades_id,_commercial_building_upgrades.synthesis_after_building_id,req.id)
                    me.UpdateField(C.ktBusinessBuilding, req.id, {C.kfKind,synthesis_after_building_id},{C.kfLastReap,C.kInvalidID} )
                    result.is_success = 1
                    return result
                else
                    result.result = C.eInvalidValue
                    return result    
                end
            end
        end
    end
    
    
    processor_[C.kGetTownItem] = function(msg)
		local id = cast('const GetTownItem&', msg).id
		local item = items_.GetItem(id)
		assert(item)
		return item
	end
 --DB

	db_processor_[C.kFunctionBuildingStatus] = function(msg)
		AddItem(C.kFunctionBuildingStatus, msg)
	end

	db_processor_[C.kBusinessBuildingStatus] = function(msg)
		AddItem(C.kBusinessBuildingStatus, msg)
	end

	db_processor_[C.kDecorationStatus] = function(msg)
		AddItem(C.kDecorationStatus, msg)
	end

	db_processor_[C.kRoadStatus] = function(msg)
		AddItem(C.kRoadStatus, msg)
	end

	db_processor_[C.kTownBlocks] = function(msg)
		ffi.copy(blocks_, msg, sizeof(blocks_))
	end
	
	db_processor_[C.kTownWarehouse] = function(msg)
		local tw = cast('const TownWarehouse&', msg)
		for i=0,tw.count-1 do 
			items_.SetItemExpiredTime(tw.items[i].id, tw.items[i].expired_time)
		end
	end


	--object
	function obj.HasFunctionBuilding(kind)
		return items_.HasBuilding(kind)
	end
	
	function obj.GetBuildingLevel(kind)
		return items_.GetBuildingLevel(kind)
	end
	
	function obj.GetTrainingGroundLevel()
		local building = items_.FindBuildingByKind(global_config.town.kTrainingGroundKind)
		if building then return building.level end
	end
	
	function obj.GetSmithyLevel()
		local building =  items_.FindBuildingByKind(global_config.town.kSmithyKind)
		if building then return building.level end		
	end
	
	function obj.GetSkillMuseumLevel()
		local building =  items_.FindBuildingByKind(global_config.town.kSkillMuseum)
		if building then return building.level end		
	end
	
	function obj.GetCityHallLevel()
		local building = items_.FindBuildingByKind(global_config.town.kCityHallKind)
		if building then return building.level end
	end
	
	function obj.Expand2BigTown()
		local to_open = {6,7,8, 0xc, 0xd, 0xe, 0x12, 0x13, 0x14}
		for _,index in ipairs(to_open) do 
			blocks_.block_status[index] = index+1
		end
		Send2Db(blocks_)
	end
	
	function obj.AddBuilding(kind)
		local item = items_.ProduceNewBuilding(kind)
		assert(item)
		local w = new('Warehousing', item.id)
		items_.Warehousing(w)
		local bg = new('BuildingGot', item.id, item.kind)
		player.Send2Gate(bg)
	end
	
	function obj.FunctionBuildingsLevel()
		return items_.FunctionBuildingsLevel()
	end

	function obj.ProcessMsgFromDb(type,msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsgFromGate(type,msg)
		local f = processor_[type]
		if f then return f(msg) end
	end
    
    function obj.BankTopSilver()
        if bank_id ~= nil then
            local bank_level = obj.GetBuildingLevel(bank_id)
            return upgrade_cfgs[bank_id][bank_level].silver_upper_limit   
        else
            return 0
        end
    end
    
    function obj.PropsCleanAllBuildingCd()
        for _,item in ipairs(items_.GetAllItems()) do 
			if item_cfgs[item.kind].type  == C.kBusinessBuilding then 
				item.last_reap = kResetTime
			end
		end
        me.UpdateField(C.ktBusinessBuilding,C.kInvalidID,{C.kfLastReap,C.kInvalidID} )
    end
    
	function obj.RunOnce()
	end
	
	function obj.OnPlayerEnterSucceeded()
		items_.ActiveBuildingFunctions()
	end
    
	return obj

end

