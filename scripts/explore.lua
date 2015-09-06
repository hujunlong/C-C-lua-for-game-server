--地图探索 支线任务


require('tools.vector')
require('tools.struct')
require('fight_helper')
require('fight.fight_mgr')
require('tools.table_ext')
require('tools.algorithm')
require('tools.time')
require('tools.serialize')
require('main_line')

local ffi = require('my_ffi')
local maps = require('config.map')
local boxes_cfg = require('config.treasure_box')
local monster_groups_cfg = require('config.monster_group')
local tasks_cfg = require('config.branch_task')
local task_details = require('config.branch_task_detail')
local actions = require('define.action_id')
local global = require('config.global')
local assistant_task_ids = require('config.assistant_task_id')
local reward_coefficient = require('config.branch_task_reward_coefficient')
local map_task_overview = require('config.branch_task_overview')
local gold_consume_flag = require('define.gold_consume_flag')
local grade_cfgs = require('config.grade')[1]
local gold_cosume = require('define.gold_consume_flag')

local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local GetActivedMaps = GetActivedMaps

for id,task in pairs(tasks_cfg) do 
	if task_details[id] then
		for _,detail in ipairs(task_details[id]) do 
			table.insert(task, detail)
		end
	end
end

function UpdateExplore()
	for id,map in pairs(maps) do
		map.id=id
		map.weather = algorithm.RoundTable4Table(map.weather_probability) or 'rain'
		if id==20200  then map.capital_location=7 
		elseif id==20300 then map.capital_location=31
		elseif id==20400 then map.capital_location=31 end
		for lid, location in pairs(map.locations) do
			location.id = lid
		end
	end

	for id,task in pairs(tasks_cfg) do
		task.id = id
		if task.depend_task then tasks_cfg[task.depend_task].next_task=task end  --处理系列任务，建立链状关系
		if task.type==3 then task.type=2 end  --其他任务归为一大类
		if task.type==2 then task.is_series = true end --系列任务单独标出
	end
end

UpdateExplore()

local function ChangeWorldWeather()
	for _,map in pairs(maps) do
		map.weather = algorithm.RoundTable4Table(map.weather_probability) or 'rain'
	end	
end

ffi.CreateTimer(ChangeWorldWeather, 60)

local online_players = {}
function InitExplore( g_players )
	online_players = g_players
end

function ResetStamina()
	for _, player in pairs(online_players) do
		player.ResetStamina()
	end
	for grade_level, grade in pairs(grade_cfgs) do
		db.ResetStamina(grade_level, grade.stamina_max)
	end
	--local notify = new("ResetStamina")
	--GlobalSend2Gate(-1, notify)
end

local replenish_stamina_interval_ = global.branch_task.kReplenishStaminaInterval
local replenish_time_ = os.time()
local function AllReplenishStamina()
	replenish_time_ = os.time()
	db.ReplenishStamina(global.branch_task.kMaxStaminaTake, replenish_time_)
	for _, player in pairs(online_players) do
		player.ReplenishStamina()
	end
end

ffi.CreateTimer(AllReplenishStamina, replenish_stamina_interval_ )

--宝箱刷新时间定义
local kBoxResetTimePointsDefine = {'9:58', '10:30', '13:23', '16:30', '18:28'}

local saved_map_boxes_of_all_players = {} --用来持续保存所有上线又离线了的玩家的地图上的宝箱状态，服务器重启时会丢失
local saved_map_tasks_of_all_players = {} --用来持续保存所有上线又离线了的玩家的地图上刷出的支线任务，服务器重启时会丢失

local function GetNextBoxResetTime()
	local now = os.time()
	local first = time.ConvertString2time(kBoxResetTimePointsDefine[1])
	local last  = time.ConvertString2time(vector.back(kBoxResetTimePointsDefine))
	if now<=first then
		return first
	elseif now>last then 
		return first+24*60*60  -- + 一天
	else
		local box_reset_time_points = {}
		for _,v in ipairs(kBoxResetTimePointsDefine) do
			table.insert(box_reset_time_points, time.ConvertString2time(v)) 
		end
		for i,t in ipairs(box_reset_time_points) do 
			if now>t and now<=box_reset_time_points[i+1] then return box_reset_time_points[i+1] end
		end
	end
	assert(false)
end

local map_tasks_file = '/tmp/0_map_tasks_467658845_do_not_copy_this_file'
local function SaveMapTasks() --将所有玩家的任务序列化并保存为本地文件
	local str = serialize(saved_map_tasks_of_all_players)
	local f = io.open(map_tasks_file, 'w')
	if not f then print('无法创建支线任务储存文件，请保证程序对/tmp目录有写权限') end
	f:write(str)
	f:close()
end

local function RemoveExpiredTask()
	for uid,map_tasks in pairs(saved_map_tasks_of_all_players) do
		for map, tasks in pairs(map_tasks) do 
			if tasks.next_reset_time<os.time() then end
		end
	end
end

local function ReadMapTasks()
	local f = io.open(map_tasks_file)
	if f then saved_map_tasks_of_all_players = dofile(map_tasks_file) end
end

ReadMapTasks()  --启动的时候加载玩家刷出的任务


function CreateExplore(player)

	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local current_area_ = {}
	local current_location_ = {}
	local encounter_cd_ = 0

	local current_branch_task_ = {}
	local branch_task_progress_ = 0
	local accomplished_tasks_ = {}
	local map_boxes_ = saved_map_boxes_of_all_players[player.GetUID()] or  {}  --存放随机箱子所在的路点,索引依次为区域id，箱子组id、箱子索引
	local map_tasks_ = saved_map_tasks_of_all_players[player.GetUID()] or {}
	
	local last_monsters_group_killed_ = 0

	local fight_cd_ = 0
	local last_fight_time_ = 0
	
	local stamina_ = { replenish_time=0, back_time=0, stamina=0, stamina_take=0 }

	local function GetMaxStamina()
		local grade_level = GetGradeLevel(player.GetUID())
		if grade_level>0 then
			return grade_cfgs[grade_level].stamina_max
		else
			return 0
		end
	end
	
	local function CanMove()
		if stamina_.back_time>os.time() then return false end
		if stamina_.replenish_time~=0 then
			stamina_.replenish_time = 0
			player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
		end
		return true
	end
	
	local function IsStaminaEnough(amount)
		return stamina_.stamina_take>=amount
	end
	
	local function ModifyStamina(delta)
		assert( stamina_.stamina_take+delta >= 0 )
		stamina_.stamina_take = stamina_.stamina_take + delta
		player.UpdateField( C.ktStatus, -1, {C.kfStaminaTake, stamina_.stamina_take} )
		local rscDelta = new('ResourceDelta', stamina_.stamina_take, delta, C.kStaminaTakeRsc)
		player.Send2Gate(rscDelta)
	end
	
	local function ResetArmyStatus(area, location_id)
		if not location_id then location_id = area.capital_location or area.start_location end
		encounter_cd_ = math.random(area.darkmine.min, area.darkmine.max)
		current_area_ = area
		current_location_ = area.locations[location_id]
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfArmyArea, area.id},{C.kfArmyLocation, location_id},{C.kfEncounterCD, encounter_cd_})
	end

	local function ResetEnconterCD()
		encounter_cd_ = math.random(current_area_.darkmine.min, current_area_.darkmine.max)
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfEncounterCD, encounter_cd_})
	end
	
	local function BackToTown()
		current_area_ = nil
		current_location_ = nil
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfArmyArea, 0})
	end

	local function GenerateAreaBoxes()
		local boxes = {}
		for group_id,group in pairs(current_area_.location_groups) do
			local locations = vector.random_chose(group.locations, group.max_boxes)
			local boxes_status = {}
			for i=1,group.max_boxes do --随机选箱子放到数组
				local box = algorithm.RoundTable(group.possible_boxes)
				if not locations[i] then print('map id='..current_area_.id.." group_id="..group_id) end
				assert(locations[i])
				boxes_status[i] = {location=locations[i], sid=box.sid,last_open=nil}
				if math.random()<boxes_cfg[box.sid].monster_probability then
					boxes_status[i].monster_group_id = current_area_.box_monsters[ math.random(1, #current_area_.box_monsters) ] 
				end
			end
			boxes[group_id] = boxes_status
		end
		map_boxes_[current_area_.id] = boxes
	end
	
	local function EnterMapArea(area, location_id)
		ResetArmyStatus(area,location_id)
		ResetEnconterCD()
		player.RecordAction(actions.kEnteredArea, 1, area.id)
		assert(current_area_)
		local boxes = map_boxes_[area.id]
		if not boxes then
			GenerateAreaBoxes()
		end
	end

	local function SetReplenishStamina(extra_time)
		--补充体力
		local cur_time = os.time()
		if stamina_.stamina_take<global.branch_task.kMaxStaminaTake then
			local add_stamina = global.branch_task.kMaxStaminaTake - stamina_.stamina_take
			if add_stamina>stamina_.stamina then add_stamina=stamina_.stamina end
			if stamina_.stamina>0 then
				stamina_.replenish_time = extra_time+cur_time+(replenish_stamina_interval_-(cur_time-replenish_time_))+(add_stamina-1)*replenish_stamina_interval_
			else
				stamina_.replenish_time = 2147483647
			end
			player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
			--
			local push = new('PushStaminaInfo',stamina_.replenish_time,stamina_.stamina,stamina_.stamina_take)
			player.Send2Gate(push)
			return true
		else
			return false
		end
	end
	
	processor_[C.kEnterMapArea] = function(msg)
		local id = cast('const EnterMapArea&', msg).id
		local area = maps[id]
		local result = new('EnterMapAreaResult', C.eInvalidOperation)
		if id~=0 and not CanMove() then return result end
		if area and area==current_area_ then
			result.result = C.eSucceeded
			return result
		end
		
		if area and vector.find(GetActivedMaps(player.FunctionBuildingsLevel(), player.GetLastCompleteTask(), player.GetCountry()), id) then
			result.result = C.eSucceeded
			EnterMapArea(area)
		end
		if id==0 then --回城镇
			BackToTown()
			stamina_.back_time = os.time()+global.branch_task.kBackToTownCostTime*60
			player.UpdateField(C.ktStatus,C.kInvalidID,{C.kfBackTime,stamina_.back_time})
			SetReplenishStamina(global.branch_task.kBackToTownCostTime*60)
			result.result = C.eSucceeded
		end
		return result
	end
	
	--[[local function BackToMainCity()
		local country = player.GetCountry()
		local area = nil
		if country==1 then	area = maps[20200]
		elseif country==2 then area = maps[20300]
		elseif country==3 then area = maps[20400]
		else	return false	end
		EnterMapArea(area)
		ReplenishStamina()
		return true
	end
	
	processor_[C.kBackToMainCity] = function()
		local result = new('BackToMainCityResult',C.eInvalidOperation)
		if BackToMainCity() then result.result = C.eSucceeded end
		return result
	end]]
	
	processor_[C.kClearStaminaCD] = function()
		local result = new('ClearStaminaCDResult',C.eInvalidOperation)
		local remain_time = 0
		local cost_gold = 0
		local cur_time = os.time()
		if stamina_.back_time<=cur_time and stamina_.stamina>0 and stamina_.stamina_take<global.branch_task.kMaxStaminaTake then
			local add_stamina = global.branch_task.kMaxStaminaTake - stamina_.stamina_take
			if add_stamina>stamina_.stamina then add_stamina=stamina_.stamina end
			remain_time = (replenish_stamina_interval_-(cur_time-replenish_time_))+(add_stamina-1)*replenish_stamina_interval_
			cost_gold = math.ceil(remain_time/60)*global.branch_task.kClearStaminaCDCostGold
			if cost_gold<0 then cost_gold=0 end
			if not player.IsGoldEnough(cost_gold) then
				result.result = C.eLackResource
			else
				stamina_.replenish_time = 0
				stamina_.stamina = stamina_.stamina - add_stamina
				stamina_.stamina_take = stamina_.stamina_take + add_stamina
				player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time},{C.kfStamina,stamina_.stamina},{C.kfStaminaTake,stamina_.stamina_take})
				player.ConsumeGold(cost_gold, gold_consume_flag.explore_replenish_stamina_clear_cd)
				local push = new('PushStaminaInfo',stamina_.replenish_time,stamina_.stamina,stamina_.stamina_take)
				player.Send2Gate(push)
				result.result = C.eSucceeded
			end
		end
		return result
	end
	
	processor_[C.kClearBackToTownCD] = function()
		local result = new("ClearBackToTownCDResult",C.eInvalidOperation)
		if stamina_.back_time>os.time() then
			if player.IsGoldEnough(global.branch_task.kClearBackToTownCDCost) then
				result.result = C.eSucceeded
				stamina_.back_time = 0
				player.UpdateField(C.ktStatus,C.kInvalidID,{C.kfBackTime, 0})
				SetReplenishStamina(0)
				player.ConsumeGold(global.branch_task.kClearStaminaCDCostGold, gold_consume_flag.explore_back_to_town_clear_cd)
			else
				result.result = C.eLackResource
			end
		end
		return result
	end
	
	processor_[C.kReplenishStamina] = function()
		local result = new('ReplenishStaminaResult',C.eInvalidOperation)
		if stamina_.back_time<=os.time() then
			if SetReplenishStamina(0) then 
				BackToTown()
				result.result = C.eSucceeded 
			end
		end
		return result
	end

	local function FetchBoxGroupLocations(group)
		local ret={}
		for _,box in ipairs(group) do
			if(not box.last_open) then table.insert(ret,box.location) end
		end
		return ret
	end

	local function IsBoxNeedReset(box)
		local box_reset_time_points = {}
		for _,v in ipairs(kBoxResetTimePointsDefine) do
			table.insert(box_reset_time_points, time.ConvertString2time(v)) 
			table.insert(box_reset_time_points, time.ConvertString2time(v)) 
		end
		local kOneDay = 24*60*60
		local yesterday_last = vector.back(box_reset_time_points)-kOneDay
		vector.push_front(box_reset_time_points, yesterday_last)
		local now = time.GetNearestLastTime(box_reset_time_points, os.time()) --系统当前时间的前一个时间点
		if box.last_open and box.last_open<now then
--			print('one box need reset')
			return true
		end
	end

	processor_[C.kGetMapRandomBoxes] = function()
		local result = new('MapRandomBoxes')
		if current_area_ then
--			print('Get map '..current_area_.id..' boxes')
			local area_box_groups = map_boxes_[current_area_.id]
			if not area_box_groups then
				GenerateAreaBoxes()
				area_box_groups = map_boxes_[current_area_.id]
			end
			for group_id,box_group in pairs(area_box_groups) do
--				print("box count="..table.size(box_group))
				local location_group = current_area_.location_groups[group_id]
				for _,box in ipairs(box_group) do
					if   box.last_open then
						local span = os.time()-box.last_open
						if (location_group.refresh_type==1 and span>=location_group.box_cd) or (IsBoxNeedReset(box)) then
							local new_box_location = vector.random_chose_exclude(location_group.locations, 1, FetchBoxGroupLocations(box_group))[1]
							assert(new_box_location)
							box.location = new_box_location
							local box_sid = algorithm.RoundTable(location_group.possible_boxes).sid
							box.sid = box_sid
							box.last_open = nil
							if math.random()<boxes_cfg[box.sid].monster_probability then
								box.monster_group_id = current_area_.box_monsters[ math.random(1, #current_area_.box_monsters) ] 
							end
						end
					end
				end
			end
    
			local min_cd = GetNextBoxResetTime()-os.time()
			for group_id,box_group in pairs(area_box_groups) do
				local location_group = current_area_.location_groups[group_id]
				for _,box in ipairs(box_group) do
--					print('box@'..box.location)
					result.boxes[result.count] = {box.location, box.last_open}
					result.boxes[result.count].sid = box.sid
					result.count = result.count+1
					if box.last_open and location_group.box_cd then
						local cd = location_group.box_cd - (os.time()-box.last_open)
						if cd<0 then cd=0 end
						if cd<min_cd then min_cd=cd end
						print("min_cd="..min_cd)
					end
				end
			end
			result.refresh_cd = min_cd
		end
		return result
	end

	local function FightWithMonsters(monster_group_id, location)
		local monsters = monster_groups_cfg[monster_group_id].monster
		local monsters_group = ProduceMonstersGroup(monsters)
		local heros_group,array = player.GetHerosGroup()
		local env = {type=5, weather=location.weather or current_area_.weather, terrain=location.terrain or 'lake', group_a={name=player.GetName(),array=array}, group_b={array=1, is_monster=true}}
		
		local fight = CreateFight(heros_group, monsters_group, env)
		local record, record_len = fight.GetFightRecord()
		local winner = fight.GetFightWinner()
		fight_cd_ = fight.GetFightCD()
		
		last_fight_time_ = os.time()
		local win = (winner==0)
		local rwd_count=0, rwds
		if win then
			rwd_count, rwds = MonstersGroupRewards(monsters_group, player)
			last_monsters_group_killed_ = monster_group_id
		end
		local zipped_record =  new('uint8_t[?]', record_len)
		copy(zipped_record,record, record_len)
		return win, zipped_record, rwd_count, rwds
	end

	local function IsCDFinished()
		if os.time()-last_fight_time_ >= fight_cd_ then
			return true
		end
	end
	
	local function EncounterMonsters(monster_group_id, location)
		local encountered_monsters = new('EncounteredMonsters')
		local win,zipped_record,rwd_count, rwds = FightWithMonsters(monster_group_id, location)
--		local zipped_record =  ffi.CompressString(record)
		local total_len = 0
		if not win then
			total_len = struct.CompundData(encountered_monsters, new('int16_t[1]', sizeof(zipped_record)), new('int16_t[1]', 0), zipped_record)
		else
			total_len = struct.CompundData(encountered_monsters, new('int16_t[1]', sizeof(zipped_record)), new('int16_t[1]', rwd_count),  zipped_record, rwds)
			player.RecordAction(actions.kMapMonsterKilled, 1, monster_group_id)
		end
--		player.Send2Gate(encountered_monsters, total_len)
		return encountered_monsters,total_len,win
	end

	processor_[C.kMove2RoadLocation] = function(msg)
		local location_id = cast('const Move2RoadLocation&', msg).location
		local result = new('Move2RoadLocationResult', C.eInvalidOperation)
		if not CanMove() then return result end
		local total_len = 8
		local object_location = current_area_.locations[location_id]
		local cost = current_area_.mobility_cost or 1 + object_location.mobility_cost or 0
		if not IsStaminaEnough(cost) then
			result.result = C.eLackResource
		elseif current_location_ and vector.find(current_location_.adjacent_locations, location_id) then
			current_location_ = current_area_.locations[location_id]
			if current_area_.darkmine and #current_area_.monsters>0 then 
				encounter_cd_ = encounter_cd_-1
				if encounter_cd_==0 then
					local monster_group_id = current_area_.monsters[ math.random(1, #current_area_.monsters) ]
					local em, len = EncounterMonsters(monster_group_id, current_location_)
					result.encountered_monsters = 1
					result.em = em
					total_len = total_len + len
					ResetEnconterCD()
				end
			end
			player.UpdateField(C.ktStatus, C.kInvalidID,{C.kfArmyLocation, location_id},{C.kfEncounterCD, encounter_cd_})
			ModifyStamina(-cost)
			if not IsStaminaEnough(1) then
				--强制回主城
				local push = new('PushForceBackToMainCity')
				player.Send2Gate(push)
			end
			result.result = C.eSucceeded
		end
		return result, total_len
	end

	local function GetBox(area_id,  location)
		local area_box_groups = map_boxes_[area_id]
		for group_id,box_group in pairs(area_box_groups) do
			for _,box in ipairs(box_group) do
				if box.location and box.location==location.id then
					local box_content = boxes_cfg[box.sid]
					return box_content,box
				end
			end
		end
	end

	processor_[C.kOpenCurrentLocationBox] = function()
		local result = new('OpenCurrentLocationBoxResult', C.eInvalidOperation)
		local res_len = 8

		if current_location_ then
			local box_content,box = GetBox(current_area_.id, current_location_)
			if box_content and not box.last_open then
				local em, em_len, win
				if box.monster_group_id then --有宝箱怪
					if not IsCDFinished() then --检查战斗CD
						result.result = C.eWaitCooldown
						return result, res_len
					end
					local monster_group_id = current_area_.box_monsters[ math.random(1, #current_area_.box_monsters) ]
					em, em_len, win = EncounterMonsters(monster_group_id, current_location_)
					if win then player.RecordAction(actions.kBoxMonsterKilledCount, 1) end
				end

				local rwds_count, rewards = 0, new('Reward[8]')
				if not em or win then -- 成功开启，填写奖励
					for _,prop in ipairs(box_content.props) do
						if math.random()<prop.probability then
							rewards[rwds_count] = {C.kPropRsc, prop.kind, prop.amount}
							player.ModifyProp(prop.kind, prop.amount)
							rwds_count = rwds_count+1
						end
					end
					box.last_open = os.time()
					player.RecordAction(actions.kMapBoxOpenedCount, 1)
					player.RecordAction(actions.kMapBoxOpened, 1, box.sid)
				end
				local has_em = em and 1 or 0
				local all_data = {new('Result[1]',C.eSucceeded), new('int16_t[2]', rwds_count, has_em) }
				for i=0,rwds_count-1 do table.insert(all_data, rewards[i]) end
				if em then table.insert(all_data, em) end
				res_len = struct.CompundTableData(result, all_data)
			end
		end
		return result,res_len
	end
	
	processor_[C.kConvey] = function()
		local result = new('ConveyResult', C.eInvalidOperation)
		if not CanMove() then return result end
		if current_location_ and current_location_.convey2map and current_location_.convey2location 
			--子地图不做判断
			and (maps[current_location_.convey2map].superior_map==current_area_.id or vector.find(GetActivedMaps(player.FunctionBuildingsLevel(), player.GetLastCompleteTask(), player.GetCountry()), current_location_.convey2map)) then
			local area = maps[current_location_.convey2map]
			assert(area)
			result.result = C.eSucceeded
			EnterMapArea(area, current_location_.convey2location)
		end
		return result
	end

	local function UpdateTask(task)
			current_branch_task_ = task
			branch_task_progress_ = 1
			player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfBranchTask, task.id}, {C.kfBranchTaskProgress, branch_task_progress_})		
	end
	
	processor_[C.kReceiveTask] = function(msg)
		local task_id = cast('const ReceiveTask&', msg).task
		local result = new('ReceiveTaskResult', C.eInvalidValue)
		local task = tasks_cfg[task_id]
		if task and not accomplished_tasks_[task_id] then
			if map_tasks_[task.map] and vector.find(map_tasks_[task.map].tasks, task_id) then 
				result.result = C.eSucceeded
				UpdateTask(task)
			end
		end
		return result
	end

	processor_[C.kAbandonTask] = function()
		local result = new('AbandonTaskResult')
		result.result = C.eSucceeded
		current_branch_task_ = nil
		branch_task_progress_ = 1
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfBranchTask, current_branch_task_}, {C.kfBranchTaskProgress, branch_task_progress_})
		return result
	end

	processor_[C.kTryCompleteSubTask] = function()
		local result = new('TryCompleteSubTaskResult', C.eInvalidValue)
		local sub_task = current_branch_task_[branch_task_progress_]
		if sub_task and sub_task.location==current_location_.id then
			local killed = false
			if sub_task.action=='event' then
				result.result=C.eSucceeded
			elseif sub_task.action=='kill' then
				local encountered_monsters,total_len,win = EncounterMonsters(sub_task.monster_group, current_location_)
				result.has_encountered_monster = 1
				result.em = encountered_monsters
				result.result=C.eSucceeded
				killed = win
			end
			if result.result==C.eSucceeded and (result.has_encountered_monster==0 or (result.has_encountered_monster==1 and killed) ) then
				branch_task_progress_ = branch_task_progress_+1
				player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfBranchTaskProgress, branch_task_progress_})
			end
		end
		return result
	end

	processor_[C.kSubmitTask] = function(msg)
		local receive_next_task_depend_this = cast('const SubmitTask&', msg).next_task_depend_this
		local result = new('SubmitTaskResult', C.eInvalidOperation)
		if current_branch_task_ and branch_task_progress_ > #current_branch_task_ then
			result.result = C.eSucceeded
			local lord_level = player.GetLevel()
			if current_branch_task_.silver then player.ModifySilver(current_branch_task_.silver*reward_coefficient[current_branch_task_.grade].silver_coefficient*lord_level) end
			if current_branch_task_.feat then player.ModifyFeat(current_branch_task_.feat*reward_coefficient[current_branch_task_.grade].feat_coefficient) end
			if current_branch_task_.lord_exp then player.AddLordExp(current_branch_task_.lord_exp*reward_coefficient[current_branch_task_.grade].lord_exp_coefficient*lord_level) end
			if current_branch_task_.prop then
				for _,p in ipairs(current_branch_task_.prop) do player.ModifyProp(p.kind, p.amount) end
			end
			if current_branch_task_.building_award and current_branch_task_.building_award.acquire then player.AddBuilding(current_branch_task_.building_award.acquire) end
			if current_branch_task_.type==2 then --记录完成了这个一次性任务
				vector.push_back(accomplished_tasks_, current_branch_task_.id)
				player.InsertRow(C.ktBranchTask, {C.kfID, current_branch_task_.id})
			end
			
			
			vector.erase(map_tasks_[current_branch_task_.map].tasks, vector.find(map_tasks_[current_branch_task_.map].tasks, current_branch_task_.id) ) --从事务所任务列表中删除这个任务
			
			player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfBranchTask, 0})
			player.AssistantCompleteTask(assistant_task_ids.kBranchTask)
			player.RecordAction(actions.kCompleteBranchTask, 1, current_branch_task_.id)
			player.RecordAction(actions.kCompleteBranchTaskCount, 1, current_branch_task_.grade_number)
			if current_branch_task_.function_to_activate then 
				local fa = new('FunctionsActived', 1)
				fa.functions[0] = current_branch_task_.function_to_activate
				player.Send2Gate(fa, 2+2) 
			end
			
			if receive_next_task_depend_this then 
				if not player.IsGoldEnough(global.branch_task.kReceiveSeriesTaskCost) then
					result.result = C.eLackResource
				elseif not current_branch_task_.next_task  then
					result.result = C.eInvalidOperation
				else
					player.ConsumeGold(global.branch_task.kReceiveSeriesTaskCost, gold_cosume.branch_task_receive_series_task)
					vector.push_back(map_tasks_[current_branch_task_.map].tasks, current_branch_task_.next_task.id)
					UpdateTask(current_branch_task_.next_task)	
				end 
			else 
				current_branch_task_ = nil
			end
			
		end
		return result
	end
	

	local function SiftTasks(area, type, excepted_tasks)
	
		local function CheckTimeSpan(time_span)
			if time_span.daily then
				local now_hour = os.date('*t', os.time()).hour
				if now_hour>=time_span.begin_hour and now_hour<=time_span.end_hour then return true end
			else
				if os.time()>=time_span.begin_time and os.time()<=time_span.end_time then return true end
			end
		end
		
		local all_tasks = {}
		for id,task in pairs(tasks_cfg) do --选择本区域的所有满足条件的任务
			if (not current_branch_task_ or id~=current_branch_task_.id) and task.map==area and (not type or task.type==type) and not vector.find(accomplished_tasks_, id) then
				if (not task.depend_task or vector.find(accomplished_tasks_, task.depend_task) ) and (not task.hall_level or task.hall_level<=player.GetLevel() ) then
					if (not task.weather or task.weather==maps[area].area) and (not task.depend_building or player.HasFunctionBuilding(task.depend_building)) then
						if (not task.wday or vector.find(task.wday, os.date('*t', os.time()).wday )) and (not task.time_span or CheckTimeSpan(task.time_span)) then
							if not excepted_tasks or not vector.find(excepted_tasks, id) then
								vector.push_back(all_tasks, id)
							end
						end
					end
				end
			end
		end
		return all_tasks
	end
	
	local function RefreshAreaTasks(area)
		local kMaxCount = (current_branch_task_ and current_branch_task_.map==area) and 3 or 4  --如果已经有了一个本地图的任务  就少刷一个
		local ret_tasks = {}
		local once_tasks = SiftTasks(area,1)
		local min_loop_task = map_task_overview[area].min_loop_task_count
		ret_tasks = vector.random_chose(once_tasks, min_loop_task)
		if table.size(ret_tasks)<kMaxCount then --如果数量不足,用其他任务补充
			local need_count = kMaxCount-table.size(ret_tasks)
			local repeat_tasks = SiftTasks(area,nil, ret_tasks)
			vector.add(ret_tasks, vector.random_chose(repeat_tasks, need_count))
		end
		if kMaxCount==3 then --如果已经有了一个本地图的任务  把它插入到原有的位置
			if map_tasks_[area] then
				local pos = vector.find(map_tasks_[area].tasks, current_branch_task_.id)
				if pos then
					table.insert(ret_tasks, pos, current_branch_task_.id)
				else  --直接接取系列任务的下一个可能出现这种情况
					vector.push_back(ret_tasks, current_branch_task_.id)
				end
			else 
				vector.push_back(ret_tasks, current_branch_task_.id)
			end
		end 
		
		return ret_tasks
	end

	processor_[C.kGetAvailableTasks] = function(msg)
		local area = cast('const GetAvailableTasks&', msg).area
		local kMaxCount = 4
		local result = new('AvailableTasks')
		if maps[area] then
			if not map_tasks_[area] or os.time()>=map_tasks_[area].next_reset_time then
				local next_time = nil
				for _,hour in ipairs(global.branch_task.kResetTimePoints) do 
					if time.Time2Today(hour)>os.time() then 
						next_time=time.Time2Today(hour) 
--						print('next time', os.date('%x %X', next_time))
						break
					end
				end
				if not next_time then next_time = time.Time2Today(global.branch_task.kResetTimePoints[1])+24*60*60 end  --设置为明天的第一个时间点
				map_tasks_[area] = {tasks=RefreshAreaTasks(area), next_reset_time=next_time}
				saved_map_tasks_of_all_players[player.GetUID()] = map_tasks_
				SaveMapTasks()
			end
			result.next_reset_time = map_tasks_[area].next_reset_time
			for _,id in ipairs(map_tasks_[area].tasks) do 
				if not vector.find(accomplished_tasks_, id) then
					result.tasks[result.count] = id
					result.count = result.count+1
				end
				if result.count>=kMaxCount then break end
			end
			if (current_branch_task_ and current_branch_task_.map==area) then
				local b = false
				for i=0, result.count do 
					if result.tasks[i] == current_branch_task_.id then b=true end
				end
				if not b then
					result.tasks[result.count] = current_branch_task_.id
					result.count = result.count+1
				end
			end
		end
		return result
	end
	
	processor_[C.kResetAvailableTasks] = function(msg)
		local area = cast('const ResetAvailableTasks&', msg).map
		local result = new('ResetAvailableTasksResult', C.eInvalidOperation)
		if not player.IsGoldEnough(global.branch_task.kRefreshTasksCost) then
			result.result = C.eLackResource
		elseif map_tasks_[area] then 
			map_tasks_[area].tasks = RefreshAreaTasks(area)
			saved_map_tasks_of_all_players[player.GetUID()] = map_tasks_
			SaveMapTasks()
			player.ConsumeGold(global.branch_task.kRefreshTasksCost, gold_cosume.branch_task_refresh_task)
			result.result = C.eSucceeded
		end
		return result
	end

	processor_[C.kGetArmyLocation] = function()
		local result = new('ArmyLocation', current_area_ and current_area_.id or 0, current_location_ and current_location_.id or 0)
		return result
	end
	
	processor_[C.kGetStamina] = function()
		local result = new('GetStaminaResult', stamina_.replenish_time, stamina_.back_time, 0,stamina_.stamina, global.branch_task.kMaxStaminaTake, stamina_.stamina_take)
		return result
	end

	db_processor_[C.kPlayerStatus] = function(msg)
		local status = cast('const PlayerStatus&', msg)
		current_area_ = maps[status.army_area]
		if current_area_ then current_location_ = current_area_.locations[status.army_location] end
		encounter_cd_ = status.encounter_cd
		current_branch_task_ = tasks_cfg[status.current_branch_task]
		branch_task_progress_ = status.branch_task_progress
		stamina_.replenish_time = status.replenish_time
		stamina_.back_time = status.back_time
		stamina_.stamina = status.stamina
		stamina_.stamina_take = status.stamina_take
		local cur_time = os.time()
		if ((stamina_.replenish_time~=0 and stamina_.replenish_time<cur_time) or stamina_.replenish_time==2147483647) and stamina_.stamina>0 then
			if stamina_.stamina_take<global.branch_task.kMaxStaminaTake then
				local add_stamina = global.branch_task.kMaxStaminaTake - stamina_.stamina_take
				if add_stamina>stamina_.stamina then add_stamina=stamina_.stamina end
				if stamina_.back_time>cur_time then
					local extra_time = 0
					for i=0,math.huge do
						if (cur_time+replenish_stamina_interval_*i)>=stamina_.back_time then
							extra_time = cur_time+replenish_stamina_interval_*i - stamina_.back_time
							break
						end
					end
					stamina_.replenish_time = extra_time+stamina_.back_time+(add_stamina-1)*replenish_stamina_interval_
				else
					stamina_.replenish_time = cur_time+(replenish_stamina_interval_-(cur_time-replenish_time_))+(add_stamina-1)*replenish_stamina_interval_
				end
			else
				stamina_.replenish_time = 0
			end
			player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
		end
	end
	
	db_processor_[C.kAccomplishedBranchTasks] = function(msg)
		local tasks = cast('const AccomplishedBranchTasks&', msg)
		for i=0,tasks.count-1 do 
			if tasks_cfg[tasks.tasks[i]].type ~= 1 then
				vector.push_back(accomplished_tasks_, tasks.tasks[i])
			end
		end
	end

	function obj.GetTaskStatus()
		return current_branch_task_ and current_branch_task_.id or 0,
			current_branch_task_ and current_branch_task_[branch_task_progress_] and current_branch_task_[branch_task_progress_].super_id or 0,
			branch_task_progress_
	end
	
	function obj.GetActivedHeros()
		local ret = {}
		for _,id in ipairs(accomplished_tasks_) do 
			if tasks_cfg[id] and tasks_cfg[id].hero_to_activate then 
				vector.push_back(ret, tasks_cfg[id].hero_to_activate)
			end
		end
		return ret
	end
	
	function obj.GetActivedBuilding()
		local ret = {}
		for _,id in ipairs(accomplished_tasks_) do 
			if tasks_cfg[id] and tasks_cfg[id].building_award then
				local kind = tasks_cfg[id].building_award.activate
				if kind then vector.push_back(ret, kind) end
			end
		end
		return ret
	end
	
	function obj.Destroy()
		saved_map_boxes_of_all_players[player.GetUID()] = map_boxes_
		saved_map_tasks_of_all_players[player.GetUID()] = map_tasks_
	end

	function obj.IsBranchTaskFinished(task_id)
		return vector.find(accomplished_tasks_, task_id)
	end
	
	function obj.ModifyStaminaTake(value)
		local tmp_value = stamina_.stamina_take+value
		if tmp_value<0 then
			value = 0-stamina_.stamina_take
		end
		ModifyStamina(value)
	end
	
	function obj.ReplenishStamina()
		--补充体力
		local b_push = false
		if stamina_.back_time<=replenish_time_ and not current_area_ then
			if stamina_.stamina>0 and stamina_.stamina_take<global.branch_task.kMaxStaminaTake then
				b_push = true
				stamina_.stamina = stamina_.stamina-1
				stamina_.stamina_take = stamina_.stamina_take + 1
				if stamina_.stamina_take>=global.branch_task.kMaxStaminaTake then
					b_push = true
					stamina_.replenish_time = 0
					player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
				elseif stamina_.stamina<1 then
					stamina_.replenish_time = 2147483647
					player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
				elseif stamina_.replenish_time==2147483647 or stamina_.replenish_time<replenish_time_ then
					local add_stamina = global.branch_task.kMaxStaminaTake - stamina_.stamina_take
					if add_stamina>stamina_.stamina then add_stamina=stamina_.stamina end
					stamina_.replenish_time = replenish_time_+add_stamina*replenish_stamina_interval_
					player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfReplenishTime,stamina_.replenish_time})
				end
			end
			if b_push then
				local push = new('PushStaminaInfo',stamina_.replenish_time,stamina_.stamina,stamina_.stamina_take)
				player.Send2Gate(push)
			end
		end
	end
	
	function obj.ResetStamina()
		stamina_.stamina = GetMaxStamina()
		--stamina_.stamina_take = global.branch_task.kMaxStaminaTake
	end
	
	function obj.ActiveExplore()
		--只有在激活有调用
		stamina_.stamina = GetMaxStamina()
		stamina_.stamina_take = global.branch_task.kMaxStaminaTake
		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfStamina,stamina_.stamina},{C.kfStaminaTake,stamina_.stamina_take})
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
