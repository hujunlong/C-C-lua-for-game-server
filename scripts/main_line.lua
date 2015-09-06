--主线任务、主线推图、英雄副本

require('my_ffi')
require("tools.algorithm")
require('fight.fight_mgr')
require('fight_helper')
require('tools.struct')
require('tools.table_ext')
require('tools.vector')
require('raiders')
require('fight.save_record')

local chapters = require('config.chapter')
local section_cfgs = require('config.section')
assert(vector.is_vector(section_cfgs))
local boss_section_cfgs = require('config.boss_section')
local task_cfgs = require('config.trunk_task')
local task_details = require('config.trunk_task_detail')
local active_define = require('config.active_define')
local building_upgrade_activation = require('config.building_upgrade_activation')
local default_actived_buildings = require('config.default_actived_buildings')
local actions = require('define.action_id')
local global_config = require('config.global')
local subsystem_define = require('define.actives')
local prop_cfgs = require('config.props')
local map_cfgs = require('config.map')
local gold_cosume = require('define.gold_consume_flag')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

for id,task in pairs(task_cfgs) do --主线任务表的处理，填的激活id直接转换成对应的值
	task.id = id
	local to_active_ids = task.to_active
	if to_active_ids then
		local to_active = {}
		for _,active_id in ipairs(to_active_ids) do 
			table.insert(to_active, active_define[active_id].to_active)
		end
		task.to_active = to_active
		task.to_active_ids = to_active_ids
	end
end

local section_sid_index_map = {}
for index, v in pairs(section_cfgs) do 
	section_sid_index_map[v.sid] = index
end

for _,details in pairs(task_details) do 
	for _,detail in pairs(details) do 
		if detail.section then detail.section=section_sid_index_map[detail.section] end
	end
end
--[[
for _,v in pairs(building_upgrade_activation) do   --建筑物激活配置的处理
	local to_active_ids = v.to_active
	local to_active = {}
	for _,active_id in ipairs(to_active_ids) do 
		table.insert(to_active, active_define[active_id].to_active)
	end
	v.to_active = to_active
	v.to_active_ids = to_active_ids
end
]]
for _,v in pairs(building_upgrade_activation) do --建筑物激活配置的处理
	for _,activation in pairs(v) do
		local to_active_ids = activation.to_active
		local to_active = {}
		for _,active_id in ipairs(to_active_ids) do 
			table.insert(to_active, active_define[active_id].to_active)
		end
		activation.to_active = to_active
		activation.to_active_ids = to_active_ids
	end 
end

local mobility_cost = 5

local ProduceMonstersGroup = ProduceMonstersGroup
local complete_status = -1



local function GetNextTrunkTask(task_id, country)
	for _,task in pairs(task_cfgs) do 
		if task.depend_task==task_id and (not task.country or task.country==country) or (type(task.depend_task)=='table' and vector.find(task.depend_task, task_id)) then
			return task
		end
	end
end

local function GetPrviousTrunkTask(task_id, country)
	assert(task_id, "task_id="..task_id)
	local current_task = task_cfgs[task_id]
	assert(current_task, "task_id="..task_id)
	if current_task.depend_task and type(current_task.depend_task)=='table' then --多个前置任务的情况
		for _,id in ipairs(current_task.depend_task) do
			if task_cfgs[id].country == country then return task_cfgs[id] end
		end
	end
	if current_task.depend_task then return task_cfgs[current_task.depend_task] end
end


local function GetAllActivedItems(buildings_level, task_progress, type, country) --level是市政厅level
	assert(country)
	if country==0 then country=nil end
	local items = {}
	if task_cfgs[task_progress] then
		local task = task_cfgs[1]
		while task do 
			if task.to_active then 
				for _,v in ipairs(task.to_active) do 
					if v[type] then items[v[type]]=true end  ---这样可以避免重复项
				end
			end
			if task.id==task_progress then break end
			task = GetNextTrunkTask(task.id, country)
		end
	end
	
	if buildings_level then 
		for building_kind,v in pairs(building_upgrade_activation) do 
			for level , activation in pairs(v) do
				if buildings_level[building_kind] and buildings_level[building_kind]>=level then 
					for _,v in ipairs(activation.to_active) do 
						if v[type] then items[v[type]]=true end 
					end					
				end
			end
		end
			
--[[		for hall_level,active in pairs(cityhall_active) do 
			if level>=hall_level then 
				for _,v in ipairs(active.to_active) do 
					if v[type] then items[v[type] ]=true end 
				end
			end
		end
]]		
	end
	
	local ret = {}  
	for id,_ in pairs(items) do vector.push_back(ret, id) end 
	return ret
end

local function GetActiveItemsByBuildingLevel(kind, level)
	local active = building_upgrade_activation[kind] and building_upgrade_activation[kind][level]
	if active then return active.to_active_ids end
end

local function GetActiveItemsByTask(task)
	local task_info = task_cfgs[task]
	if task_info then return task_info.to_active_ids end
end

function GetActivedBuildings(buildings_level, task_progress, country)
	return GetAllActivedItems(buildings_level, task_progress, 'building', country)
end

function GetActivedSubsystems(buildings_level, task_progress, country)
	return GetAllActivedItems(buildings_level, task_progress, 'subsystem', country)
end

function GetActivedSkills(buildings_level, task_progress, country)
	return GetAllActivedItems(buildings_level, task_progress, 'science', country)
end

function GetActivedMaps(buildings_level, task_progress, country)
	local maps = GetAllActivedItems(buildings_level, task_progress, 'map', country)
	local sub_maps = {}
	for id, map in pairs(map_cfgs) do --加入子地图
		if vector.find(maps, map.superior_map) then vector.push_back(sub_maps, id) end
	end
	vector.add(maps, sub_maps)
	return maps
end

function GetMaxCityhallLevel(task_progress, country)
	local levels = GetAllActivedItems(nil, task_progress, 'level', country)
	return vector.max_element(levels) or 500
end

function GetActivedHeros(buildings_level, task_progress, country)
	return GetAllActivedItems(buildings_level, task_progress, 'hero', country)
end

local function MaxAvailableSection(task, country)
	 local task_info = task_cfgs[task]
	 if task_info then
		local s = nil
		repeat 
			s = task_info.section_to_active
			task_info = GetPrviousTrunkTask(task_info.id, country)
		until s or not task_info
		return s or 1
	 end
	 return 1
end

local function MaxAvailableBossSection(max_passed_section, max_passed_boss_section)
	for i=max_passed_section,1,-1 do 
		for id, boss_section in ipairs(boss_section_cfgs) do 
			if vector.find(boss_section.depend_sections,i) then
				if id>max_passed_boss_section then id = max_passed_boss_section+1  end
				return id
			end
		end
	end
	return 0
end

function CreateMainLine(player)   --玩家主线对象创建器

	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local last_passed_section_ = 0
	local last_passed_boss_section_ = 0
	local boss_sections_killing_times_ = {}
	local  used_boss_killing_times_ = 0
	local max_available_section_ = 0
	local current_section_ = 0
	local current_sub_section_ = 0
	local section_reward_ = false
	local scores_ = {}
	local current_task_ = {}
	local task_progress_ = 0
	local section_evaluate_content_ = {remain_life_percent=0, round_count=0} --用来计算副本评价分数
	local fight_cd = 0
	local last_fight_time = 0
	
--gate

	local function EnterSection(section)
			current_section_ = section
			current_sub_section_ = 0
			section_evaluate_content_.remain_life_percent, section_evaluate_content_.round_count = 0,0		
	end
	
	processor_[C.kEnterSection] = function(msg)
		local section = cast('const EnterSection&', msg).id
		local result = new('EnterSectionResult', C.eInvalidOperation)
		if not player.IsMobilityEnough(mobility_cost) then
			result.result = C.eLackResource
		elseif section > max_available_section_ then
			result.result = C.eSectionDisable
		else
			EnterSection(section)
			result.result = C.eSucceeded
		end
		return result
	end

	local function SectionPassedReward(section)
		local rewards = new('SectionPassedReward')
		if not section then return rewards end
		player.ModifyFeat(section.feat)
		rewards.feat = section.feat
		player.AddHeroExp(section.hero_exp)
		player.AddLordExp(section.lord_exp)
		rewards.hero_exp = section.hero_exp
		rewards.lord_exp = section.lord_exp
--		print(section_evaluate_content_.remain_life_percent, #section.monster)
		return rewards
	end
	
	local function CalcSectionPassedScore(section)
		local more_round = section_evaluate_content_.round_count - #section.monster*3 --这里假设一组怪应该3回合打完
		if more_round<0 then more_round=0 end
		if more_round>10 then more_round=10 end
		local score = section_evaluate_content_.remain_life_percent/100/#section.monster*50 + 50-more_round*5
		if score<1 then score=1 end
		return score
	end
	
	local function GetSectionPassedBoxReward(section, sell_prop)
		local rewards = new('SectionPassedBoxReward')
		if section then
			player.ModifySilver(section.silver)
			rewards.silver = section.silver
			if math.random()<=section.gold.probability then
				player.ModifyGold(section.gold.amount)
				rewards.gold = section.gold.amount
			end
			local prop_got = section.props and algorithm.RoundTable(section.props)
			if prop_got then
				rewards.prop = prop_got.kind
				if sell_prop then
					player.ModifySilver(prop_cfgs[prop_got.kind].sale_price)
				else
					 if not player.IsBagFull() then 
						rewards.prop_id = player.ModifyProp(prop_got.kind, 1) or 0
					 end
				end
			end		
			
		end
		return rewards
	end
	
	processor_[C.kGetSectionPassedBoxReward] = function()
		local section = section_cfgs[current_section_]
		local ret = GetSectionPassedBoxReward(section)
		if current_section_==last_passed_boss_section_ then --第一次通关
			local bc = new('SectionRewardGot', player.GetUID())
			bc.name = player.GetCNickname()
			bc.section_index = current_section_
			if ret.prop>0 then 
				bc.reward = {C.kPropRsc, ret.prop, 1}
				player.Send2Gate(bc)
			end
			if ret.gold>0 then 
				bc.reward = {C.kGoldRsc, 0, ret.gold}
				player.Send2Gate(bc)				
			end
		end
		current_section_ = 0 --置为0就无法再取了
		return ret
	end
	
	local function IsPerfectSection(score)
		return score>=70
	end
	
	local function IsPerfectChapter(section)
		for _,chapter in pairs(chapters) do 
			if chapter.head>=section and chapter.tail<=section then 
				for i=chapter.head,chapter.tail do 
					if i~=section and (not scores_[i] or not IsPerfectChapter(scores_[i]) ) then return false end
				end
				return true
			end
		end
	end

	processor_[C.kChallengeSubSection] = function()
		local result = new('ChallengeSubSectionResult', C.eInvalidOperation)
		local section = section_cfgs[current_section_]
		local heros_group,array = player.GetHerosGroup()

		if section and current_sub_section_ < #section.monster and not table.empty(heros_group) then
			result.result = C.eSucceeded
		end
		if os.time()-last_fight_time < fight_cd then result.result = C.eWaitCooldown end    
		if current_sub_section_==0 then
			if not player.IsMobilityEnough(mobility_cost) then result.result=C.eLackResource end
		end
		
		local total_len = sizeof('Result')
		if result.result == C.eSucceeded then
			local monsters_group = ProduceMonstersGroup(section.monster[current_sub_section_+1])
			local env = {type=1, weather=section.weather[current_sub_section_+1], terrain=section.terrain[current_sub_section_+1], 
					group_a={name=player.GetName(),array=array}, group_b={is_monster=true}}
			
			local fight = CreateFight(heros_group, monsters_group, env)
			local record, record_len = fight.GetFightRecord()
			local winner = fight.GetFightWinner()
			local time = fight.GetFightCD()
		
            --攻略记录
			if current_section_ > last_passed_section_  and winner==0 then 
				local record_id = SaveBattleRecord(record, record_len)
				raiders.InsertRaiders(raiders.RAIDERS_TYPE.MAIN_LINE, current_section_, current_sub_section_+1, player.GetUID(), record_id, player.GetLevel())
			end
            
			fight_cd = time+4
	--		print("fight_cd="..fight_cd)
			last_fight_time = os.time()
			local zipped_record =  new('uint8_t[?]', record_len)
			copy(zipped_record,record, record_len)
			if winner==0 then --战胜
				local rewards_count, rewards = MonstersGroupRewards(monsters_group, player)
				total_len = struct.CompundData(result, new('Result[1]', result.result), new('bool[1]', true), new('int8_t[1]', rewards_count), new('int16_t[1]', sizeof(zipped_record)), rewards, zipped_record )
			else --战败
				total_len = struct.CompundData(result, new('Result[1]', result.result), new('bool[1]', false), new('int8_t[1]', 0), new('int16_t[1]', sizeof(zipped_record)), zipped_record )
			end
			local passed = (winner==0)
			if passed then
				if current_sub_section_==0 then player.ModifyMobility(-mobility_cost) end
				current_sub_section_ = current_sub_section_+1
				section_evaluate_content_.remain_life_percent = section_evaluate_content_.remain_life_percent + fight.GetStatistics().group_a.life
				section_evaluate_content_.round_count = section_evaluate_content_.round_count + fight.GetStatistics().round
				if current_sub_section_ >= #section.monster then --通关了
					player.RecordAction(actions.kPassedSection, 1, current_section_)
					section_reward_ = true
					local score = CalcSectionPassedScore(section)
					if IsPerfectSection(score) then
						player.RecordAction(actions.kPerfectChapter, 1, current_section_)
					end  --完美通关
					if current_section_ > last_passed_section_ then
					--下个进度
--						last_passed_section_ = current_section_
--						player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfPassedSection, last_passed_section_})
						player.InsertRow(C.ktSection, {C.kfID,current_section_}, {C.kfScore, score} )
						scores_[current_section_] = score
					else
						if scores_[current_section_]  and score>scores_[current_section_] then
							scores_[current_section_] = score
							player.UpdateField(C.ktSection, current_section_, {C.kfScore, score})
						end
					end
				end    --通关了
			end
		end
		return result, total_len
	end

	processor_[C.kGetSectionPassedReward] = function()
		if section_reward_ then
			section_reward_ = false
			local result = SectionPassedReward(section_cfgs[current_section_]) 
			result.score = CalcSectionPassedScore(section_cfgs[current_section_])
			return result
		end
	end

	processor_[C.kMopUpSection] = function(msg)
		local section = cast('const MopUpSection&', msg).id
		local sell_prop = cast('const MopUpSection&', msg).auto_sell_prop

		local result = new('MopUpSectionResult', C.eInvalidOperation)
		local monster_groups = section_cfgs[section] and section_cfgs[section].monster
		local total_len = sizeof('Result')
		if section>last_passed_section_ or not monster_groups then
			result.result = C.eSectionNotPassed
		elseif not player.IsMobilityEnough(mobility_cost) then
			result.result = C.eLackResource
		elseif not sell_prop and player.IsBagFull() then
			result.result = C.eSucceeded
			result.bag_full = true
			total_len = total_len+1
		else
			local t = {new('Result[1]', C.eSucceeded), new('bool[1]', false), new('int8_t[1]', #monster_groups)}
			for _,group in ipairs(monster_groups) do
				local count, rwds = MonstersGroupRewards(ProduceMonstersGroup(group), player, sell_prop)
				table.insert(t, new('int8_t[1]',count))
				table.insert(t, rwds)
			end
			table.insert(t, SectionPassedReward(section_cfgs[section]))
			table.insert(t, GetSectionPassedBoxReward(section_cfgs[section], sell_prop))
			total_len = struct.CompundTableData(result, t)
--			total_len = struct.CompundData(result, new('Result[1]', C.eSucceeded), new('int8_t[1]', monster_group_count), SectionPassedReward(section_cfgs[section]))
			player.ModifyMobility(-mobility_cost)
		end
		return result,total_len
	end

	processor_[C.kGetSectionScores] = function()
--		local get_section_scores = cast('const GetSectionScores&', msg)
		local result = new('GetSectionScoresResult')
		for i=1,last_passed_section_ do
			result.scores[i] = scores_[i] or 0
		end
		result.max_index = last_passed_section_ or 0
		return result, 2+result.max_index+1
	end
	
	local function IsTaskComplete()		
		if not task_details[current_task_.id] then return false end
		local detail = task_details[current_task_.id][task_progress_]
		if not detail then return false end
		local action = detail.action
		assert(action)
		if action=='choose_country' then return player.GetCountry()>0 end
		
--		if ffi.os~='Windows' then return true end
		
		if action=='plot' or action=='cg' or action=='section_plot' or action=='section_complete_plot' then 
			return true
		elseif action=='pass' then
			return detail.section==current_section_ and detail.sub_section==current_sub_section_
		elseif action=='build' then
			if player.HasFunctionBuilding(detail.kind) then return true end
		elseif action=='upgrade_building' then
			if player.GetBuildingLevel(detail.kind)>1 then return true end
		elseif action=='train' then
			return true
		elseif action=='buy' then
			return player.HasPropInBag()
		elseif action=="equip" then
			return true
		elseif action=='strengthen' then
			return player.GetEquipmentStrengthenTimes()>=3
		elseif action=='upgrade_fight_skill' then
			return true
		elseif action=='recruit' then
			return player.GetHero(detail.kind)
		elseif action=='upgrade_array_skill' then
			return true
		elseif action=='put_hero_to_array' then
			return true
		elseif action=='choose_country' then
			return player.GetCountry()>0
		elseif action=='upgrade_science_level' then
			return true
		end
	end
	
	local function IsCurrentSubTaskPassSection()
		if not task_details[current_task_.id] then return false end
		local detail = task_details[current_task_.id][task_progress_]
		if not detail then return false end
		return detail.action	== 'pass'
	end
	
	local function Up2NextTask(next)
		if not next then return end
		current_task_=next 
		task_progress_ = 1
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfTrunkTask, next.id}, {C.kfTrunkTaskProgress, 1})
		max_available_section_ = MaxAvailableSection(current_task_.id, player.GetCountry())
	end
	
	local function OpenBuildingOrFunction()
		if current_task_.function_to_active.building then player.ActiveBuilding(current_task_.function_to_active.building) 
		elseif current_task_.function_to_active.subsystem then player.FunctionActive(current_task_.function_to_active.subsystem) end	
	end
	
	local function NotifyActive2Player(active_items)
		if not active_items then return end
		local active_functions = new('FunctionsActived', #active_items)
		for i,id in ipairs(active_items) do 
			active_functions.functions[i-1] = id
			local to_active = active_define[id].to_active
			if to_active.science then 
				player.ActivateSkill(to_active.science) 
			elseif to_active.subsystem then
				player.ActivateSubSystem(to_active.subsystem) 
			elseif to_active.building then
				--[[
				--卯哥说这里写的不对，屏蔽掉，在town里面添加激活功能
				if to_active.buiding==global_config.town.kArenaKind then player.ActivateSubSystem(subsystem_define.kSubSystemArena) 
				elseif to_active.building==global_config.town.kTreasureHouseKind then player.ActivateSubSystem(subsystem_define.kSubSystemRune) 
				elseif to_active.building==global_config.town.kAuctionKind then player.ActivateSubSystem(subsystem_define.kSubSystemAuction) 
				elseif to_active.building==global_config.town.kTowerKind then player.ActivateSubSystem(subsystem_define.kSubSystemTower) 
				elseif to_active.building==global_config.town.kFishKind then player.ActivateSubSystem(subsystem_define.kSubSystemFish)
				elseif to_active.building==global_config.town.kDragonHouseKind then player.ActivateSubSystem(subsystem_define.kSubSystemRearDragon)
				elseif to_active.building==global_config.town.kOfficeKind then player.ActivateSubSystem(subsystem_define.kSubSystemExplore)
				end
				]]
			end
		end
		player.Send2Gate(active_functions, 2+active_functions.count*2)
	end
	
	processor_[C.kTryCompleteTrunkTask] = function()
		local result = new('TryCompleteTrunkTaskResult', C.eInvalidOperation)
		if current_task_.level and current_task_.level>player.GetLevel() then
			result.result = C.eLowLevel
		elseif IsTaskComplete() then
			if IsCurrentSubTaskPassSection() then 
				last_passed_section_ = current_section_
				player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfPassedSection, last_passed_section_})
			end
			task_progress_ = task_progress_+1
			if task_progress_>table.size(task_details[current_task_.id]) then  --一个任务完成了
				if current_task_.function_to_active then OpenBuildingOrFunction() end --完成任务可能激活新功能或新建筑
				if current_task_.silver then player.ModifySilver(current_task_.silver) end
				if current_task_.feat then player.ModifyFeat(current_task_.feat) end
				if current_task_.lord_exp then player.AddLordExp(current_task_.lord_exp) end
			--发送要开启的功能给客户端
				NotifyActive2Player(GetActiveItemsByTask(current_task_.id))
			--试图跳到下一个任务
				local next = GetNextTrunkTask(current_task_.id, player.GetCountry())		
				if next then Up2NextTask(next) end
			else --完成了任务的一个节点
				player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfTrunkTaskProgress, task_progress_})
			end
			result.result = C.eSucceeded
		end
		return result
	end

	processor_[C.kGetActivedFunctions] = function(msg)
		local type = cast('GetActivedFunctions&', msg).type
		local items = {}
		local buildings_level,task = player.FunctionBuildingsLevel(), obj.GetLastCompleteTask()
		local country = player.GetCountry()
		if type==C.kBuidingActive then
			items = GetActivedBuildings(buildings_level, task, country)
			vector.add(items, default_actived_buildings)
			vector.add(items, player.GetBrachTaskActivatedBuilidings())
		elseif type==C.kSubsystemActive then
			items = GetActivedSubsystems(buildings_level, task, country)
		elseif type==C.kMaxCityhallLevelActive then
			items = {GetMaxCityhallLevel(task, country)}
		elseif type==C.kMapActive then
			items = GetActivedMaps(buildings_level,task, country)
		elseif type==C.kSkillActive then
			items = GetActivedSkills(buildings_level,task, country)
		end
		local result = new('ActivedFunctions',#items)
		for i,item in ipairs(items) do 
			result.values[i-1] = item 
		end
		return result, 2+result.count*2
	end
	
	processor_[C.kGetBossSectionStatus] = function()
		local result = new('BossSectionStatus')
		result.max_avaialbe_section = MaxAvailableBossSection(last_passed_section_, last_passed_boss_section_) or 0
		result.max_times = global_config.boss_section.kMaxKillingTimes[player.GetVIPLevel()]
		result.used_times = used_boss_killing_times_
		for i,times in pairs(boss_sections_killing_times_) do 
			if i<sizeof(result.killing_times) then result.killing_times[i] = times end
		end
		return result
	end
	
	function obj.ModifyBossSectionAvailableTimes(times)
		local used_times = global_config.boss_section.kMaxKillingTimes[player.GetVIPLevel()] - times
		if used_times<0 then used_times=0 end
		used_boss_killing_times_ = used_times
	end
	
	local function DealBossSectionRewards(section)
		local rewards = new('BossSectionRewards')
		if section.feat then 
			rewards.feat=section.feat 
			player.ModifyFeat(rewards.feat)
		end
		if section.silver then 
			rewards.silver=section.silver 
			player.ModifySilver(rewards.silver)
		end
		if section.gold and math.random()<section.gold.probability then
			rewards.gold=section.gold.amount 
			player.ModifyGold(rewards.gold)
		end
		if section.heroexp then 
			rewards.hero_exp=section.heroexp
			player.AddHeroExp(rewards.hero_exp)			
		end
		if section.round_table_prop then 
			rewards.prop = algorithm.RoundTable(section.round_table_prop).kind
			player.ModifyProp(rewards.prop, 1)
		end
		return rewards
	end
	
	processor_[C.kChallengeBossSection] = function(msg)
		local cbs = cast('const ChallengeBossSection&', msg)
		local result = new('ChallengeBossSectionResult', C.eInvalidOperation)
		local total_len = 4
		local max_section = MaxAvailableBossSection(last_passed_section_, last_passed_boss_section_)

		local killing_times = boss_sections_killing_times_[cbs.index]
		if not (max_section and cbs.index<=max_section) then
		elseif os.time()-last_fight_time < fight_cd then result.result = C.eWaitCooldown 
		elseif used_boss_killing_times_>= global_config.boss_section.kMaxKillingTimes[player.GetVIPLevel()] and not cbs.second_time then
		elseif killing_times and (killing_times>=2 or not cbs.second_time and killing_times>=1) then --检查击杀次数
		elseif cbs.second_time and not player.IsGoldEnough(global_config.boss_section.kSecondKillingPrice) then
			result.result = C.eLackResource
		else 
			result.result = C.eSucceeded
		end
		if result.result ==C.eSucceeded then 
			local section = boss_section_cfgs[cbs.index]
			local monsters_group = ProduceMonstersGroup(section.monsters)
			local heros_group,array = player.GetHerosGroup()
			local env = {type=1, weather='rain', terrain='lake', group_a={name=player.GetName(),array=array}, group_b={is_monster=true}}

			
			local fight = CreateFight(heros_group, monsters_group, env)
			local record, record_len = fight.GetFightRecord()
			local winner = fight.GetFightWinner()
			local time = fight.GetFightCD()
			
			fight_cd = time+3
			last_fight_time = os.time()
			local zipped_record =  new('uint8_t[?]', record_len)
			copy(zipped_record,record, record_len)
			if winner==0 then
				if cbs.index > last_passed_boss_section_ then  --首次击杀
					last_passed_boss_section_ = cbs.index
					player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfPassedBossSection, last_passed_boss_section_})
					local bc = new('BossSectionPassed', player.GetUID())
					bc.name = player.GetCNickname()
					bc.section_index = cbs.index
					player.Send2Gate(bc)
				end
				local rewards_count, rewards = MonstersGroupRewards(monsters_group, player)
				total_len = struct.CompundData(result, new('Result[1]', result.result), new('bool[1]', true), new('int8_t[1]', rewards_count), new('int16_t[1]', sizeof(zipped_record)), 
					rewards, zipped_record, DealBossSectionRewards(section))
				player.RecordAction(actions.kKillBoss, 1)
				boss_sections_killing_times_[cbs.index] = (boss_sections_killing_times_[cbs.index] or 0) +1
				if not cbs.second_time then
					used_boss_killing_times_=used_boss_killing_times_+1
					player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfBossKillingTimes, used_boss_killing_times_})
					player.InsertRow(C.ktBossSection, {C.kfID, cbs.index}, {C.kfTimes, 1})
				else 
					player.UpdateField(C.ktBossSection, cbs.index, {C.kfTimes, 2})
					player.ConsumeGold(global_config.boss_section.kSecondKillingPrice, gold_cosume.boss_section_second_killing)
				end
				--攻略记录
				local record_id = SaveBattleRecord(record, record_len)
				raiders.InsertRaiders(raiders.RAIDERS_TYPE.BOSS_SECTION, cbs.index, 1, player.GetUID(), record_id, player.GetLevel())
			else
				total_len = struct.CompundData(result, new('Result[1]', result.result), new('bool[1]', false), new('int8_t[1]', 0), new('int16_t[1]', sizeof(zipped_record)), zipped_record )
			end			
		end
		return result, total_len
	end

--db
	db_processor_[C.kSectionScores] = function(msg)
		local scores = cast('const SectionScores&', msg)
		for i=0,sizeof(scores.scores)-1 do
			if scores.scores[i]>0 then scores_[i] = scores.scores[i] end
		end
	end

	db_processor_[C.kPlayerBaseInfo] = function(msg)
		local player_info = cast('const PlayerBaseInfo&', msg)
		if player_info.game_info.progress==1 then EnterSection(1) end
	end

	db_processor_[C.kPlayerStatus] = function(msg)
		local status = cast('const PlayerStatus&', msg)
		current_task_ = task_cfgs[status.current_trunk_task]
		assert(current_task_, "Invalid task id "..status.current_trunk_task)
		if current_task_ then
			task_progress_ = status.trunk_task_progress
			if not (task_details[current_task_.id] and task_details[current_task_.id][task_progress_]) then  --配置信息错误补救
				task_progress_ = 1
			end
		end
		last_passed_section_ = status.passed_section
		last_passed_boss_section_ = status.passed_boss_section
		max_available_section_ = MaxAvailableSection(obj.GetLastCompleteTask(), player.GetCountry())
		used_boss_killing_times_ = status.boss_killing_times
	end
	
	db_processor_[C.kBossesKillingTimes] = function(msg)
		local killing_times = cast('const BossesKillingTimes&', msg)
		for i=1,sizeof(killing_times.killing_times)-1 do --第一个是值0，所以跳过
			if killing_times.killing_times[i]>0 then boss_sections_killing_times_[i] = killing_times.killing_times[i] end
		end
	end
------

	function obj.OnLordLevelUp(level)
		local next = GetNextTrunkTask(current_task_.id, player.GetCountry())
		if next and next.level and next.level<=level then 
			Up2NextTask(next)
		end
--		NotifyActive2Player(GetActiveItemsByLevel(level))
	end
	
	function obj.OnBuildingLevelUp(kind, level)
		NotifyActive2Player(GetActiveItemsByBuildingLevel(kind, level))
	end

	function obj.GetTaskStatus()
		return current_task_ and current_task_.id or 0, 0, task_progress_
	end
	
	function obj.GetMaxAailableSection()
		return max_available_section_
	end
	
	function obj.GetLastCompleteTask()
		if task_progress_==complete_status then 
			return current_task_.id 
		else 
			if not current_task_.id then print("player="..player.GetUID()) end
			local previous_task = GetPrviousTrunkTask( current_task_.id, player.GetCountry())
			return previous_task and previous_task.id or 0 
		end
	end
	
	function obj.IsTaskFinished(id)
		local last = obj.GetLastCompleteTask()
		while last and last>1 do
			if last==id then return true end
			local t = GetPrviousTrunkTask( last, player.GetCountry())	
			last = t and t.id or nil
		end
	end
	
	function obj.IsSectionPassed(index)
		return last_passed_section_>=index
	end
	
	function obj.ResetBossSection()
		used_boss_killing_times_ = 0
		boss_sections_killing_times_ = {}
	end
	
	function obj.OnPlayerEnterSucceeded()
		local builidings_level = player.FunctionBuildingsLevel()
		local task = obj.GetLastCompleteTask()
		local country = player.GetCountry()
		for _,id in ipairs(GetActivedSkills(builidings_level, task, country)) do player.ActivateSkill(id) end
		for _,id in ipairs(GetActivedSubsystems(builidings_level, task, country)) do
            if id==subsystem_define.kSubSystemWorldBoss or 
                id==subsystem_define.kSubSystemGrade or
                id==subsystem_define.kSubSystemTerritory or
                id==subsystem_define.kSubSystemEscort or
				id==subsystem_define.kSubSystemAlchemy or 
				id==subsystem_define.kSubSystemBringUp or
				id==subsystem_define.kSubSystemStrengthen or
				id==subsystem_define.kSubSystemInlay or
				id==subsystem_define.kSubSystemCompoundGem or
				id==subsystem_define.kSubSystemPropMigrate
            then
                player.ActivateSubSystem(id) 
            end
		end
--[[		转移到城建系统激活
		if player.HasFunctionBuilding(global_config.town.kAuctionKind) then player.ActivateSubSystem(subsystem_define.kSubSystemAuction) end
		if player.HasFunctionBuilding(global_config.town.kMilitaryKind) then player.ActivateSubSystem(subsystem_define.kSubSystemWorldWar) end
		if player.HasFunctionBuilding(global_config.town.kFishKind) then player.ActivateSubSystem(subsystem_define.kSubSystemFish) end
		if player.HasFunctionBuilding(global_config.town.kDragonHouseKind) then player.ActivateSubSystem(subsystem_define.kSubSystemRearDragon) end
		if player.HasFunctionBuilding(global_config.town.kTowerKind) then player.ActivateSubSystem(subsystem_define.kSubSystemTower) end
		if player.HasFunctionBuilding(global_config.town.kTreeKind) then player.ActivateSubSystem(subsystem_define.kSubSystemTree) end
	]]
	end

	function obj.ProcessMsgFromDb(type, msg)
		local func = db_processor_[type]
		if func then func(msg) end
	end

	function obj.ProcessMsg(type, msg)
		local func = processor_[type]
		if func then return func(msg) end
	end

	return obj
end
