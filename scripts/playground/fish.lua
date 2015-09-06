local fishery_cfgs = require('config.fish_fisheries')
local cost_cfgs = require('config.fish_cost')
local fish_cfgs = require('config.fish')
local prop_cfgs = require('config.props')


local global_ = require('config.global')
local actions = require('define.action_id')
local tasks_ = require('config.assistant_task_id')
local gold_consume_flag = require('define.gold_consume_flag')
local bit = require('bit')

require('global_data')
local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy


local online_players = {}
function InitFish( g_players )
	online_players = g_players
end

function ResetFished()
	db.ResetFishingInfo(global_.fish.kTimesEveryDay)
	--local push = new("FishingInfoReset")
	for _,v_player in pairs( online_players ) do
		if v_player.ResetPlayground( 2 ) then
			--v_player.Send2Gate(push)
		end
	end
end

function CreateFish(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local active_ = false
	
	local uid_ = player.GetUID()
	local name_ = player.GetCNickname()
	
	local fish_ = {}
	fish_.fisheries = {}
	fish_.records = {}
	fish_.rewards = {}
	fish_.all_fished = {}
	--[[
		fish_.fish_times
		fish_.gold_times
		fish_.torpedo_times
		fish_.fisheries[]
		fish_.records[fishery][kind] = weight
		fish_.rewards[fishery].normal/gold/torpedo	--can fish fish
		fish_.all_fished[fishery]
		fish_.pull_time
		fish_.fishery
		fish_.rod
		fish_.cost
	]]
	
	local function UpdateTimes()
		player.UpdateField(C.ktFish,C.kInvalidID,{C.kfFishFishTimes,fish_.fish_times},
			{C.kfFishGoldTimes,fish_.gold_times},{C.kfFishTorpedoTimes,fish_.torpedo_times})
	end
	
	local function SaveRecord(fishery, kind, weight)
		if not fish_.records[fishery] then fish_.records[fishery]={} end
		if not fish_.records[fishery][kind] then
			fish_.records[fishery][kind] = weight
			player.InsertRow(C.ktFishRecord,{C.kfFishKind,kind},{C.kfFishWeight,weight})
		elseif fish_.records[fishery][kind]<weight then
			fish_.records[fishery][kind]=weight
			player.UpdateField2(C.ktFishRecord,C.kfPlayer,uid_,C.kfFishKind,kind,{C.kfFishWeight,weight})
		end
	end
	
	local function IsAllFishedInFishery(fishery)
		if not fish_.all_fished[fishery] then
			for kind, fish in pairs(fish_cfgs) do
				if fish.fishery==fishery then
					if not fish_.records[fishery] or not fish_.records[fishery][kind] or fish_.records[fishery][kind]==0 then
						return false
					end
				end
			end
		end
		player.RecordAction(actions.kFishedAllFishInFishery, 1, fishery)
		return true
	end
	
	local function GetActiveFisheries()
		for id, fishery in pairs(fishery_cfgs) do
			if fishery.unlock then
				if fishery.unlock.type==1 then
					if player.IsSectionPassed(fishery.unlock.id) then
						fish_.fisheries[id] = true
					end
				else
					print('unsupported fishery unlock type='..fishery.unlock.type)
				end
			end
		end
	end
	
	local function GetActiveFish( the_fishery, rod_type )
		local active = false
		local all = 0
		local fish_cfg = nil
		local fishery_cfg = fishery_cfgs[the_fishery]
		local all_rewards = nil
		local give_rewards = nil
		
		if fishery_cfg then
			if not fish_.rewards[the_fishery] then fish_.rewards[the_fishery]={} end
			
			if rod_type==C.kNormalFishingRod then
				all_rewards = fishery_cfgs[the_fishery].normal
				fish_.rewards[the_fishery].normal = {}
				give_rewards = fish_.rewards[the_fishery].normal
			elseif rod_type==C.kGoldFishingRod then
				all_rewards = fishery_cfgs[the_fishery].gold
				fish_.rewards[the_fishery].gold = {}
				give_rewards = fish_.rewards[the_fishery].gold
			elseif rod_type==C.kTorpedoBomb then
				all_rewards = fishery_cfgs[the_fishery].torpedo
				fish_.rewards[the_fishery].torpedo = {}
				give_rewards = fish_.rewards[the_fishery].torpedo
			else
				return
			end
			for _, reward in pairs(all_rewards) do
				active = false
				if reward.type==2 then
					fish_cfg = fish_cfgs[reward.kind]
					if fish_cfg then
						if fish_cfg.unlock then
							if fish_cfg.unlock.type==1 then
								if player.IsBranchTaskFinished(fish_cfg.unlock.id) then
									active = true
								end
							else
								print('unsupported fish unlock type='..fish_cfg.unlock.type)
							end
						else
							active = true
						end
					end
				else
					active = true
				end
				if active then
					local give_reward = {}
					give_reward.type = reward.type
					give_reward.kind = reward.kind
					give_reward.probability = reward.probability
					all = all + reward.probability
					table.insert(give_rewards, give_reward)
				end
			end
			for _, reward in pairs(give_rewards) do
				reward.probability = reward.probability/all
			end
		end
	end
	
	-- 0: normal rod
	-- 1: gold
	-- 2: torpedo
	-- return { weight=100*?, amount=? }
	local function GenerateFish( kind )
		local fish_cfg = fish_cfgs[kind]
		if not fish_cfg then return end
		local pro = math.random()
		for _, weight in pairs( fish_cfg.weight) do
			if pro<=weight.probability then
				local unreal_weight = math.random(weight.min*100, weight.max*100)
				local amount = 0
				if fish_cfg.reward_type==1 then		--silver
					amount = math.ceil((unreal_weight/100)*fish_cfg.price)
					player.ModifySilver(amount)
				elseif fish_cfg.reward_type==2 then	--feat
					amount = math.ceil((unreal_weight/100)*fish_cfg.price)
					player.ModifyFeat(amount)
				elseif fish_cfg.reward_type==3 then	--gold
					amount = math.ceil((unreal_weight/100)*fish_cfg.price)
					player.ModifyGold(amount)
				else
					print('fish: torpedo: error fish reward type='..fish_cfg.reward_type)
					return
				end
				SaveRecord(fish_cfg.fishery, kind, unreal_weight)
				--
				player.RecordAction(actions.kFishedFish, 1, kind)
				player.RecordAction(actions.kFishedWeightOfFish, 1, unreal_weight/100)
				--
				if fish_cfg.broadcast then
					local push = new("BC_FishTheFish")
					push.uid = uid_
					copy(push.name,name_,sizeof(name_))
					push.kind = kind
					push.amount = amount
					GlobalSend2Gate(-1, push)
				end
				--
				return { weight=unreal_weight, amount=amount}
			else
				pro = pro-weight.probability
			end
		end
	end
	
	processor_[C.kGetFishingInfo] = function()
		local result = new('GetFishingInfoResult', C.FISH_DISABLE)
		if active_ then
			result.result = C.FISH_SUCCEEDED
			result.fish_times = fish_.fish_times
			result.gold_times = fish_.gold_times
			result.torpedo_times = fish_.torpedo_times
			local fisheries = 0
			GetActiveFisheries()
			for fishery, _ in pairs(fish_.fisheries) do
				fisheries = bit.bor(fisheries, bit.lshift(1,fishery-1))
			end
			result.fisheries = fisheries
		end
		return result
	end
	
	processor_[C.kGetFishKindRecord] = function(msg)
		local result = new('GetFishKindRecordResult',C.FISH_DISABLE)
		local fishery = cast('const GetFishKindRecord&',msg).fishery
		local bytes = 0
		if active_ then
			local active_fish = {}
			if fish_.fisheries[fishery] then
				if fish_.records[fishery] then
					for kind, weight in pairs(fish_.records[fishery]) do
						active_fish[kind] = weight
					end
					for kind, fish_cfg in pairs(fish_cfgs) do
						if fish_cfg.fishery==fishery then
							if not active_fish[kind] then
								if fish_cfg.unlock then
									if player.IsBranchTaskFinished(fish_cfg.unlock.id) then
										active_fish[kind] = 0
									end
								end
							end
						end
					end
				end
				result.amount = 0
				for kind, weight in pairs(active_fish) do
					result.records[result.amount].kind = kind
					result.records[result.amount].weight = weight
					result.amount = result.amount+1
				end
				result.result = C.FISH_SUCCEEDED
				bytes = 8 + result.amount*sizeof(result.records[0])
			else
				result.result = C.FISH_INVALID_VALUE
				bytes = 4
			end
		else
			bytes = 4
		end
		return result, bytes
	end
	
	processor_[C.kThrowTorpedo] = function(msg)
		local result = new('ThrowTorpedoResult',C.FISH_DISABLE)
		local throw = cast('const ThrowTorpedo&', msg)
		if not active_ then return result end
		GetActiveFisheries()
		if fish_.fish_times<5 then
			result.result = C.FISH_NO_TIMES
		elseif not fishery_cfgs[throw.fishery] or not fish_.fisheries[throw.fishery] then
			result.result = C.FISH_INVALID_VALUE
		elseif player.GetVIPLevel()<global_.fish.kNeedVipLevel then
			result.result = C.FISH_LOW_VIP_LEVEL
		else
			local times = fish_.torpedo_times + 1
			local cost = 0
			for _,v_cost in pairs(cost_cfgs) do
				if times>=v_cost.times.min and times<=v_cost.times.max then
					cost = v_cost.torpedo
				end
			end
			if cost==0 then cost=cost_cfgs[#cost_cfgs].torpedo end
			if not player.IsGoldEnough(cost) then
				result.result = C.FISH_GOLD_NOT_ENOUGH
			else
				local pro = 0
				local rewards = {}
				local amount = 0
				GetActiveFish(throw.fishery, C.kTorpedoBomb)
				for i=1, 5 do
					pro = math.random()
					for _, reward in pairs(fish_.rewards[throw.fishery].torpedo) do
						if pro<=reward.probability then
							if reward.type==1 and prop_cfgs[reward.kind] then		  --prop
								amount = amount + 1
								table.insert(rewards, {type=reward.type, kind=reward.kind})
							elseif reward.type==2 then  --fish
								table.insert(rewards, {type=reward.type, kind=reward.kind})
							else
								print('fish: torpedo: error reward type='..reward.type)
							end
							break
						else
							pro = pro - reward.probability
						end
					end
				end
				if player.GetBagSpace()<amount then
					result.result = C.FISH_BAG_LEACK_SPACE
				else
					amount = 0
					for _, reward in pairs(rewards) do
						if reward.type==1 then
							result.rewards[amount].type = reward.type
							result.rewards[amount].kind = reward.kind
							player.ModifyProp(reward.kind, 1)
							amount = amount + 1
							player.RecordAction(actions.kPropGot, 1, reward.kind)
						elseif reward.type==2 then
							local fish = GenerateFish(reward.kind)
							if fish then
								result.rewards[amount].type = reward.type
								result.rewards[amount].kind = reward.kind
								result.rewards[amount].weight = fish.weight
								result.rewards[amount].amount = fish.amount
								amount = amount + 1
							end
						end
					end
					player.ConsumeGold(cost, gold_consume_flag.fish_torpedo)
					result.result = C.FISH_SUCCEEDED
					result.amount = amount
					fish_.fish_times = fish_.fish_times - 5
					fish_.torpedo_times = fish_.torpedo_times + 1
					UpdateTimes()
					--
					IsAllFishedInFishery(throw.fishery)
					player.RecordAction(actions.kFishedTimes, 5)
					for i=1,5 do
						player.AssistantCompleteTask(tasks_.kFished, fish_.fish_times)
					end
				end
			end
		end
		return result
	end
	
	processor_[C.kThrowFishingRod] = function(msg)
		local result = new('ThrowFishingRodResult',C.FISH_DISABLE)
		local throw = cast('const ThrowFishingRod&',msg)
		if not active_ then return result end
		GetActiveFisheries()
		if fish_.fish_times<=0 then
			result.result = C.FISH_NO_TIMES
		elseif not fishery_cfgs[throw.fishery] or throw.rod>C.kGoldFishingRod then
			result.result = C.FISH_INVALID_VALUE
		elseif not fish_.fisheries[throw.fishery] then
			result.result = C.FISH_INVALID_VALUE
		else
			local cost = 0
			if throw.rod==C.kGoldFishingRod then
				local times = 0
				times = fish_.gold_times + 1
				for _,v_cost in pairs(cost_cfgs) do
					if times>=v_cost.times.min and times<=v_cost.times.max then
						cost = v_cost.gold
					end
				end
				if cost==0 then cost=cost_cfgs[#cost_cfgs].gold end
			end
			if not player.IsGoldEnough(cost) then
				result.result = C.FISH_GOLD_NOT_ENOUGH
			else
				fish_.fishery=throw.fishery
				fish_.rod=throw.rod
				fish_.cost = cost
				fish_.pull_time = os.time() + math.random(5,17)
				result.result = C.FISH_SUCCEEDED
				result.time = fish_.pull_time
			end
		end
		return result
	end
	
	processor_[C.kPullFishingRod] = function()
		local result = new('PullFishingRodResult',C.FISH_DISABLE)
		local cur_time = os.time()
		if not active_ then return result end
		if fish_.fish_times<=0 then
			result.result = C.FISH_NO_TIMES
		elseif not fish_.pull_time then
			result.result=C.FISH_INVALID_OPERATION
		elseif cur_time<fish_.pull_time or cur_time>(fish_.pull_time+3) then
			result.result=C.FISH_NOT_IN_TIME
		else
			if not player.IsGoldEnough(fish_.cost) then
				result.result = C.FISH_GOLD_NOT_ENOUGH
			else
				local rewards = nil
				if fish_.rod==C.kNormalFishingRod then
					GetActiveFish(fish_.fishery, C.kNormalFishingRod)
					rewards = fish_.rewards[fish_.fishery].normal
				elseif fish_.rod==C.kGoldFishingRod then
					GetActiveFish(fish_.fishery, C.kGoldFishingRod)
					rewards = fish_.rewards[fish_.fishery].gold
				end
				--
				result.result = C.FISH_INVALID_VALUE
				local pro = math.random()
				for _, reward in pairs(rewards) do
					if pro<=reward.probability then
						if reward.type==1 and prop_cfgs[reward.kind] then  --prop
							if player.IsBagFull() then
								result.result = C.FISH_BAG_LEACK_SPACE
							else
								result.result = C.FISH_SUCCEEDED
								result.reward.type = reward.type
								result.reward.kind = reward.kind
								player.ModifyProp(reward.kind, 1)
								--
								player.RecordAction(actions.kPropGot, 1, reward.kind)
							end
						elseif reward.type==2 then  --fish
							local fish = GenerateFish(reward.kind)
							if fish then
								result.result = C.FISH_SUCCEEDED
								result.reward.type = reward.type
								result.reward.kind = reward.kind
								result.reward.weight = fish.weight
								result.reward.amount = fish.amount
							end
						else
							print('fish: torpedo: error reward type='..reward.type)
						end
						break
					else
						pro = pro - reward.probability
					end
				end
				if result.result==C.FISH_SUCCEEDED then
					fish_.fish_times = fish_.fish_times - 1
					if fish_.rod==C.kGoldFishingRod then
						fish_.gold_times = fish_.gold_times + 1
						player.ConsumeGold(fish_.cost, gold_consume_flag.fish_gold_rod)
					end
					UpdateTimes()
					player.RecordAction(actions.kFishedTimes, 1)
					IsAllFishedInFishery(fish_.fishery)
					player.AssistantCompleteTask(tasks_.kFished, fish_.fish_times)
				end
			end
		end
		return result
	end
	
	db_processor_[C.kFishInfo] = function(msg)
		active_ = true
		local info = cast('const FishInfo&',msg)
		fish_.fish_times = info.fish_times
		fish_.gold_times = info.gold_times
		fish_.torpedo_times = info.torpedo_times
		
		local fish_cfg = nil
		local record = nil
		for i=1, info.amount do
			record = info.records[i-1]
			fish_cfg = fish_cfgs[record.kind]
			if fish_cfg then
				if not fish_.records[fish_cfg.fishery] then fish_.records[fish_cfg.fishery]={} end
				fish_.records[fish_cfg.fishery][record.kind] = record.weight
			end
		end
	end
	
	function obj.ActivateFish()
		if not active_ then
			player.InsertRow(C.ktFish, {C.kfFishFishTimes, global_.fish.kTimesEveryDay})
			fish_.fish_times = global_.fish.kTimesEveryDay
			fish_.gold_times = 0
			fish_.torpedo_times = 0
		end
		active_ = true
	end
	
	function obj.ResetFished()
		if active_ then
			fish_.fish_times = global_.fish.kTimesEveryDay
			fish_.gold_times = 0
			fish_.torpedo_times = 0
		end
		return active_
	end
	
	function obj.ModifyFishTimes(delta)
		if active_ then
			fish_.fish_times = fish_.fish_times + delta
			if fish_.fish_times<0 then fish_.fish_times=0 end
			player.UpdateField(C.ktFish,C.kInvalidID,{C.kfFishFishTimes,fish_.fish_times})
			return true
		else
			return false
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
	
return obj
end