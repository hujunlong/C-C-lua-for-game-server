local seed_cfgs = require('config.tree_seed')
local cost_cfgs = require('config.tree_cost')
local prop_cfgs = require('config.props')
local global_cfg = require('config.global')
local gold_consume_flag = require('define.gold_consume_flag')
local actions = require('define.action_id')


require('global_data')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local Db_UpdateField  = UpdateField
local Db_UpdateField2 = UpdateField2
local Db_InsertRow2 = InsertRow2

local online_players = {}
function InitTree( players )
	online_players = players
end


function ResetTree()
	db.ResetTree(global_cfg.tree.kWaterAmount)
	--
	--local push = new("PushResetTree")
	for _,v_player in pairs( online_players ) do
		--
		if v_player.ResetTree() then
			--GlobalSend2Gate(v_uid, push)
		end
	end
end

--CreateWaitableTimerForResetAction( action_type.reset_tree, global_cfg.tree.kResetTime, ResetTree )

local function GetSeedStatus( uid, seed )
	local cur_time = os.time()
	local seed_cfg = nil
	seed_cfg = seed_cfgs[seed.kind]
	assert( seed_cfg )
	if seed.status==C.kSeedGrowing then
		if seed_cfg.arid_interval then
			if (cur_time-seed.last_water)>=seed_cfg.arid_interval then
				if seed_cfg.arid_interval>=seed.ripe_time then
					seed.status = C.kSeedRipe
					Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid,C.kfTreeLocation,seed.location,
											{C.kfTreeStatus,seed.status})
				else
					seed.status = C.kSeedArid
					seed.ripe_time = seed.ripe_time - seed_cfg.arid_interval
					Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid,C.kfTreeLocation,seed.location,
												{C.kfTreeStatus,seed.status},{C.kfTreeRipeTime,seed.ripe_time})
				end
			elseif (cur_time-seed.last_water)>=seed.ripe_time then
				seed.status = C.kSeedRipe
				Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid,C.kfTreeLocation,seed.location,
									{C.kfTreeStatus,seed.status})
			end
		elseif (cur_time-seed.last_water)>=seed.ripe_time then
			seed.status = C.kSeedRipe
			Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid,C.kfTreeLocation,seed.location,
										{C.kfTreeStatus,seed.status})
		end
	end
end

--[[
	g_trees[uid].player_sex
	g_trees[uid].water_amount
	g_trees[uid].buy_count
	g_trees[uid].seed_amount
	g_trees[uid].log_amount
	g_trees[uid].log_id		--即将被覆盖的id
	g_trees[uid].seeds[location]
	g_trees[uid].logs[i]
	g_trees[uid].visitors[uid]
	g_trees[uid].visit
]]
local g_trees = {}

--如果返回nil,表示此玩家未激活幸运树
local function GetTreeInfo( uid )
	local res = nil
	local tree= g_trees[uid]
	if tree then return tree end
	
	res = db.GetTreeWater( uid )
	if res then
		tree = {}
		tree.player_sex = 0
		tree.water_amount = res.water_amount
		tree.buy_count = res.buy_count
		tree.seed_amount = 0
		tree.log_amount = 0
		tree.log_id = 1
		tree.seeds = {}
		tree.logs = {}
		tree.visitors = {}
		tree.visit = 0
		res = db.GetTreeSeeds( uid )
		if res then
			tree.seed_amount = #res
			local location = 0
			local seed = nil
			for i=1, tree.seed_amount do
				location = res[i].location
				tree.seeds[location] = {}
				seed = tree.seeds[location]
				seed.ripe_time = res[i].ripe_time
				seed.last_water = res[i].last_water
				seed.kind = res[i].kind
				seed.location = location
				seed.watered = res[i].watered
				seed.status = res[i].status
				GetSeedStatus(uid, seed)
			end
		end
		res = db.GetTreeLogs( uid )
		if res then
			tree.log_amount = #res
			for i=1, tree.log_amount do
				tree.logs[i] = {}
				tree.logs[i].id = res[i].id
				local nickname = new('Nickname')
				copy(nickname, res[i].nickname, sizeof(nickname))
				tree.logs[i].name = nickname
				tree.logs[i].time = res[i].time
			end
		end
		if tree.log_amount>=50 then 
			tree.log_id = 1
		else
			tree.log_id = tree.log_amount + 1
		end
		res = db.GetPlayerBaseInfo( uid )
		if res then
			tree.player_sex = res.sex
		end
		g_trees[uid] = tree
	else
		tree = nil
	end
	return tree
end

function CreateTree( player )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local active_ = false
	local uid_ = player.GetUID()
	local name_ = player.GetCNickname()
	local tree_ = {}		--幸运树信息
	
	--[[
		seeds_[]
		--.kind
		--.pro
	]]
	local seeds_ = {}

	local function GetTreeBaseData()
		seeds_ = {}
		local locations = {}
	
		for _, seed_cfg in pairs(seed_cfgs) do
			local level = player.GetLevel()
			if level>=seed_cfg.level.min and level<=seed_cfg.level.max then
				if not locations[seed_cfg.location] then
					locations[seed_cfg.location] = {}
					locations[seed_cfg.location].seeds = {}
					locations[seed_cfg.location].all = 0
				end
				locations[seed_cfg.location].all = locations[seed_cfg.location].all + seed_cfg.probability
				local seed = {}
				seed.kind = seed_cfg.kind
				seed.pro = seed_cfg.probability
				table.insert( locations[seed_cfg.location].seeds, seed )
			end
		end
		for pos, location in pairs( locations ) do
			for _, v_seed in pairs( location.seeds ) do
				v_seed.pro = v_seed.pro/location.all
			end
			seeds_[pos] = location.seeds
		end
	end

	local function ModifyGodWater(delta)
		tree_.water_amount = tree_.water_amount + delta
		player.UpdateField(C.ktTreeWater,C.kInvalidID, {C.kfTreeWaterAmount, tree_.water_amount})
	end
	
	local function ModifyRipeTime()
	end
	
	local function VisitTree(visit_uid)
		if tree_.visit~=0 then g_trees[tree_.visit].visitors[uid_]=nil end
		tree_.visit = visit_uid
		g_trees[visit_uid].visitors[uid_] = 1
	end

	local function ExitTree()
		if tree_.visit~=0 then g_trees[tree_.visit].visitors[uid_]=nil end
		tree_.visit = 0
	end
	
	local function PushSeedStatus( tree, seed )
		local push = new("PushSeedStatus")
		push.seed.ripe_time = seed.ripe_time
		push.seed.last_water = seed.last_water
		push.seed.kind = seed.kind
		push.seed.location = seed.location
		push.seed.watered = seed.watered
		push.seed.status = seed.status
		for uid, _ in pairs( tree.visitors ) do
			if online_players[uid] then
				GlobalSend2Gate( uid, push )
			else
				tree.visitors[uid] = nil
			end
		end
	end
	
	local function PushAndSaveVisitLog( uid, tree )
		local push = new("PushVisitLog")
		copy(push.log.name, name_, sizeof(name_))
		push.log.time = os.time()
		--
		if uid~=uid_ then
		if tree.log_amount<50 then
			tree.log_amount=tree.log_amount+1
			Db_InsertRow2(C.ktTreeLog, {C.kfPlayer,uid},{C.kfTreeId,tree.log_id},
							{C.kfTreeUid,uid_},{C.kfTreeTime,push.log.time})
		else
			Db_UpdateField2(C.ktTreeLog,C.kfPlayer,uid,C.kfTreeId,tree.log_id,
							{C.kfTreeUid,uid_},{C.kfTreeTime,push.log.time})
		end
		if not tree.logs[tree.log_id] then tree.logs[tree.log_id] = {} end
		tree.logs[tree.log_id].id = tree.log_id
		local nickname = new('Nickname')
		copy(nickname, name_, sizeof(nickname))
		tree.logs[tree.log_id].name = nickname
		tree.logs[tree.log_id].time = push.log.time
		if tree.log_id>=50 then
			tree.log_id=1
		else
			tree.log_id = tree.log_id + 1
		end
		end
		--
		for v_uid, _ in pairs( tree.visitors ) do
			if online_players[v_uid] then
				GlobalSend2Gate( v_uid, push )
			else
				tree.visitors[v_uid] = nil
			end
		end
	end

	local function CreateNewSeed( location, seed_status )
		local pro = 0
		local cur_time = os.time()
		local seed_cfg = nil
		local seed = nil
		pro = math.random()
		for _, v_seed in pairs( seeds_[location] ) do
			if v_seed.pro>=pro then
				seed_cfg = seed_cfgs[v_seed.kind]
				local b_insert = false
				if not tree_.seeds[location] then
					b_insert=true
					tree_.seeds[location] = {}
					tree_.seeds[location].watered = 0
				end
				seed = tree_.seeds[location]
				seed.ripe_time = seed_cfg.ripe_time
				seed.last_water = cur_time
				seed.kind = seed_cfg.kind
				seed.location = location
				seed.watered = 0
				if not seed_status then
					seed.status = C.kSeedGrowing
				else
					seed.status = seed_status
				end
				if b_insert then
					player.InsertRow(C.ktTreeSeed,{C.kfTreeKind,seed_cfg.kind},{C.kfTreeLocation,location},{C.kfTreeWatered,seed.watered},
								{C.kfTreeStatus, C.kSeedGrowing},{C.kfTreeRipeTime,seed_cfg.ripe_time},{C.kfTreeLastWater,cur_time})
				else
					Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid_,C.kfTreeLocation,seed.location,{C.kfTreeWatered,seed.watered},
								{C.kfTreeKind,seed_cfg.kind},{C.kfTreeStatus, C.kSeedGrowing},{C.kfTreeRipeTime,seed_cfg.ripe_time},{C.kfTreeLastWater,cur_time})
				end
				break
			else
				pro = pro - v_seed.pro
			end
		end
	end
	
	local function PickFruit(seed)
		local location = seed.location
		local seed_cfg = seed_cfgs[seed.kind]
		assert(seed_cfg)
		if seed_cfg.reward_type==1 then	--道具
			if prop_cfgs[seed_cfg.prop_kind] then
				if not player.AddNewProps2Area4Kind(C.kAreaBag, seed_cfg.prop_kind, seed_cfg.amount) then
					return C.eBagLeackSpace
				end
			else
				print('tree: error prop_kind='..seed_cfg.prop_kind)
			end
		elseif seed_cfg.reward_type==2 then	--银币
			player.ModifySilver( seed_cfg.amount )
		elseif seed_cfg.reward_type==3 then	--经验
			player.AddLordExp( seed_cfg.amount )
		elseif seed_cfg.reward_type==4 then	--功绩
			player.ModifyFeat( seed_cfg.amount )
		else
			print('error reward_type='..seed_cfg.reward_type)
		end
		CreateNewSeed(location)
		PushSeedStatus(tree_, tree_.seeds[location])
		--
		if seed_cfg.broadcast then
			local push = new("BC_PickTheSeed")
			push.uid = uid_
			copy(push.name,name_,sizeof(name_))
			push.kind = seed_cfg.kind
			GlobalSend2Gate(-1, push)
		end
		player.RecordAction(actions.kGotFruitForTree, 1, seed_cfg.kind)
		return C.eSucceeded
	end
	
	processor_[C.kGetTreeWater] = function()
		local result = new("GetTreeWaterResult",C.eSucceeded, tree_.water_amount or 0, tree_.buy_count or 0)
		if not active_ then result.result = C.eFunctionDisable end
		return result
	end
	
	processor_[C.kGetTreeSeeds] = function(msg)
		local result = new("GetTreeSeedsResult")
		if not active_ then result.result = C.eFunctionDisable return result,4 end
		local bytes = 0
		local uid = cast("const GetTreeSeeds&",msg).uid
		local tree = nil
		tree = GetTreeInfo(uid)
		if tree then
			result.result = C.eSucceeded
			result.amount = tree.seed_amount
			local index = 0
			for location, seed in pairs(tree.seeds) do
				result.seeds[index].ripe_time = seed.ripe_time
				result.seeds[index].last_water = seed.last_water
				result.seeds[index].kind = seed.kind
				result.seeds[index].location = location
				result.seeds[index].watered = seed.watered
				GetSeedStatus( uid, seed )
				result.seeds[index].status = seed.status
				index = index+1
			end
			bytes = 8 + sizeof(result.seeds[0])*tree.seed_amount
			--
			VisitTree(uid)
		else
			result.result = C.eInvalidOperation
			bytes = 4
		end
		return result, bytes
	end
	
	processor_[C.kGetTreeLogs] = function(msg)
		local result = new("GetTreeLogsResult")
		if not active_ then result.result = C.eFunctionDisable return result,4 end
		local bytes = 0
		local uid = cast("const GetTreeLogs&",msg).uid
		local tree = nil
		tree = GetTreeInfo(uid)
		if tree then
			result.result = C.eSucceeded
			result.sex = tree.player_sex
			result.amount = tree.log_amount
			for i=1, tree.log_amount do
				copy( result.logs[i-1].name, tree.logs[i].name, sizeof(tree.logs[i].name))
				result.logs[i-1].time = tree.logs[i].time
			end
			bytes = 8 + sizeof(result.logs[0])*tree.log_amount
			--
			VisitTree(uid)
		else
			result.result = C.eInvalidOperation
			bytes = 4
		end
		return result, bytes
	end
	
	processor_[C.kExitTree] = function()
		local result = new("ExitTreeResult",C.eSucceeded)
		if not active_ then result.result = C.eFunctionDisable return result end
		ExitTree()
		return result
	end
	
	processor_[C.kWaterTree] = function(msg)
		local water = cast("const WaterTree&",msg)
		local result = new("WaterTreeResult",C.eInvalidOperation)
		if not active_ then result.result = C.eFunctionDisable return result end
		local tree = GetTreeInfo(water.uid)
		if not tree or not tree.seeds[water.location] then
			result.result = C.eInvalidOperation
			return result 
		end
		local seed = tree.seeds[water.location]
		local seed_cfg = seed_cfgs[seed.kind]
		GetSeedStatus(water.uid, seed)
		if water.type==C.kWaterGod then
			if water.uid==uid_ then
				if seed_cfg.water_times>seed.watered and tree.water_amount>0 and seed.status==C.kSeedGrowing then
					ModifyGodWater(-1)
					seed.ripe_time = seed.ripe_time - 4*3600
					if seed.ripe_time<0 then seed.ripe_time=0 end
					seed.watered = seed.watered+1
					Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid_,C.kfTreeLocation,seed.location,{C.kfTreeRipeTime,seed.ripe_time},{C.kfTreeWatered,seed.watered})
					GetSeedStatus(uid_, seed)
					PushSeedStatus( tree, seed )
					result.result = C.eSucceeded
				--else
					--其它的都是非法的
				end
			--else
				--result.result = C.eInvalidOperation
			end
		elseif water.type==C.kWaterGodByBuy then
			local vip = player.GetVIPLevel()
			if water.uid==uid_ then
				if tree_.water_amount>=1 then
					if seed_cfg.water_times>seed.watered and tree.water_amount>0 and seed.status==C.kSeedGrowing then
						ModifyGodWater(-1)
						seed.ripe_time = seed.ripe_time - 4*3600
						if seed.ripe_time<0 then seed.ripe_time=0 end
						seed.watered = seed.watered+1
						Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid_,C.kfTreeLocation,seed.location,{C.kfTreeRipeTime,seed.ripe_time},{C.kfTreeWatered,seed.watered})
						GetSeedStatus(uid_, seed)
						PushSeedStatus( tree, seed )
						
						result.result = C.eSucceeded
					end
				elseif vip>=1 then
					local cost = 0
					if (tree_.buy_count+1)>=#cost_cfgs then
						cost = cost_cfgs[#cost_cfgs].cost
					else
						cost = cost_cfgs[tree_.buy_count+1].cost
					end
					if player.IsGoldEnough(cost) then
						if seed_cfg.water_times>seed.watered and seed.status==C.kSeedGrowing then
							tree_.buy_count = tree_.buy_count+1
							player.UpdateField(C.ktTreeWater,C.kInvalidID,{C.kfTreeBuyCount,tree_.buy_count})
							seed.ripe_time = seed.ripe_time - 4*3600
							if seed.ripe_time<0 then seed.ripe_time=0 end
							seed.watered = seed.watered+1
							Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,uid_,C.kfTreeLocation,seed.location,{C.kfTreeRipeTime,seed.ripe_time},{C.kfTreeWatered,seed.watered})
							GetSeedStatus(uid_, seed)
							PushSeedStatus( tree, seed )
							player.ConsumeGold(cost, gold_consume_flag.tree_buy_god_water)
							result.result = C.eSucceeded
						end
					else
						result.result = C.eLackResource
					end
				else
					result.result = C.eLowVipLevel
				end
			end
		elseif water.type==C.kWaterNormal then
			if seed.status==C.kSeedArid then
				if water.uid~=uid_ then
					player.ModifySilver( seed_cfg.silver )
				end
				seed.status = C.kSeedGrowing
				seed.last_water = os.time()
				seed.ripe_time = seed.ripe_time - seed_cfg.water_dec_time
				if seed.ripe_time<0 then seed.status=C.kSeedRipe end
				--
				Db_UpdateField2(C.ktTreeSeed,C.kfPlayer,water.uid,C.kfTreeLocation,seed.location,
								{C.kfTreeStatus,seed.status},{C.kfTreeRipeTime,seed.ripe_time},{C.kfTreeLastWater,seed.last_water})
				--
				PushSeedStatus( tree, seed )
				PushAndSaveVisitLog( water.uid, tree )
				result.result = C.eSucceeded
			--else
				--result.result = C.eInvalidOperation
			end
		else
			result.result = C.eInvalidValue
		end
		return result
	end
	
	processor_[C.kPickFruit] = function(msg)
		local result = new("PickFruitResult",C.eInvalidOperation)
		if not active_ then result.result = C.eFunctionDisable return result end
		local location = cast("const PickFruit&",msg).location
		local seed = tree_.seeds[location]
		if seed then
			GetSeedStatus(uid_, seed)
			if seed.status==C.kSeedRipe then
				result.result = PickFruit(seed)
			--else
				--result.result = C.eInvalidOperation
			end
		end
		return result
	end
	
	db_processor_[C.kInternalTreeInfo] = function(msg)
		active_ = true
		
		if g_trees[uid_] then tree_=g_trees[uid_] end
		
		local info = cast("const InternalTreeInfo&",msg)
		tree_.seeds = {}
		tree_.logs = {}
		tree_.visit = 0
		tree_.visitors = {}
		tree_.player_sex = player.GetSex()
		tree_.water_amount = info.water_amount
		tree_.buy_count = info.buy_count
		tree_.seed_amount = info.seed_amount
		tree_.log_amount = info.log_amount
		if tree_.log_amount>=50 then 
			tree_.log_id = 1
		else
			tree_.log_id = tree_.log_amount + 1
		end
		local location = 0

		local seed = nil
		for i=1, tree_.seed_amount do
			location = info.seeds[i-1].location
			tree_.seeds[location] = {}
			seed = tree_.seeds[location]
			seed.ripe_time = info.seeds[i-1].ripe_time
			seed.last_water = info.seeds[i-1].last_water
			seed.kind = info.seeds[i-1].kind
			seed.location = info.seeds[i-1].location
			seed.watered = info.seeds[i-1].watered
			seed.status = info.seeds[i-1].status
			GetSeedStatus( uid_, seed )
		end
		--
		for v_location, _ in pairs( seeds_ ) do
			if not tree_.seeds[v_location] then
				tree_.seed_amount = tree_.seed_amount + 1
				CreateNewSeed(v_location)
			end
		end
		--
		for i=1, tree_.log_amount do
			tree_.logs[i] = {}
			tree_.logs[i].id = info.logs[i-1].id
			local nickname = new('Nickname')
			copy(nickname, info.logs[i-1].name, sizeof(nickname))
			tree_.logs[i].name = nickname
			tree_.logs[i].time = info.logs[i-1].time
		end
		g_trees[uid_] = tree_
	end
	
	local function CreateNewTree()
		
		tree_.player_sex = player.GetSex()
		tree_.water_amount = global_cfg.tree.kWaterAmount
		tree_.buy_count = 0
		tree_.seed_amount = #seeds_
		tree_.log_amount = 0
		tree_.log_id = 1
		tree_.seeds = {}
		tree_.logs = {}
		tree_.visitors = {}
		tree_.visit = 0
		
		player.InsertRow(C.ktTreeWater,{C.kfTreeWaterAmount,tree_.water_amount})
		
		GetTreeBaseData()
		for location, _ in pairs( seeds_ ) do
			CreateNewSeed(location, C.kSeedRipe)
		end
		g_trees[uid_] = tree_
	end
	
	function obj.ModifyWaterCount(value)
		if active_ then
			local count = tree_.water_amount+value
			if count<0 then
				value = 0-tree_.water_amount
			elseif count>255 then
				value = 255-tree_.water_amount
			end
			ModifyGodWater(value)
			return true
		else
			return false
		end
	end
	
	function obj.ActivateTree()
		if active_==false then
			CreateNewTree()
			active_ = true
		end
	end
	
	function obj.ResetTree()
		if active_ then
			for _, seed in pairs( tree_.seeds ) do
				seed.watered = 0
			end
			tree_.water_amount = global_cfg.tree.kWaterAmount
			tree_.buy_count = 0
		end
		return active_
	end
	
	function obj.OnLordLevelup()
		if not active_ then return end
		
		GetTreeBaseData()
		for v_location, _ in pairs( seeds_ ) do
			if not tree_.seeds[v_location] then
				tree_.seed_amount = tree_.seed_amount + 1
				CreateNewSeed(v_location)
			end
		end
	end
	
	function obj.ProcessMsgFromDb(type, msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsg(type, msg)
		local f = processor_[type]
		if f then return f(msg) end
	end
	
	
	GetTreeBaseData()
	
return obj
end