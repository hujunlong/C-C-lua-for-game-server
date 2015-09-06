local reward_cfgs = require('config.check_in_every_day')
local prop_cfgs = require('config.props')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy


local function enum(...)
	local enum_t = {}
	for k,v in pairs(...) do enum_t[v] = k end
	return enum_t
end
local kValue_ = enum{"kCantCheckIn", "kSucceeded", "kShouldRestart" }

function CreateCheckInEveryDay(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local uid_ = player.GetUID()
	
	local active_ = false
	
	local check_in_ = new('InternalCheckInEveryDayInfo')
	local rewards_ = check_in_.rewards
	
	local function UpdateRewards2Db()
		local where_fields={{C.kfPlayer, uid_}}
		player.UpdateStringField2(C.ktCheckInEveryDay, #where_fields, where_fields, C.kfRewards, sizeof(rewards_), rewards_)
	end
	
	local function GenerateRewards()
		local level = player.GetLevel()
		local probability = 0
		for _, rewards in pairs(reward_cfgs) do
			if level>=rewards.level.min and level<=rewards.level.max then
				if rewards.reward1 then
					rewards_[rewards.days-1].rewards[0].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward1) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[0].kind = reward.kind
							rewards_[rewards.days-1].rewards[0].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
				if rewards.reward2 then
					rewards_[rewards.days-1].rewards[1].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward2) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[1].kind = reward.kind
							rewards_[rewards.days-1].rewards[1].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
				if rewards.reward3 then
					rewards_[rewards.days-1].rewards[2].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward3) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[2].kind = reward.kind
							rewards_[rewards.days-1].rewards[2].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
				if rewards.reward4 then
					rewards_[rewards.days-1].rewards[3].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward4) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[3].kind = reward.kind
							rewards_[rewards.days-1].rewards[3].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
				if rewards.reward5 then
					rewards_[rewards.days-1].rewards[4].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward5) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[4].kind = reward.kind
							rewards_[rewards.days-1].rewards[4].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
				if rewards.reward6 then
					rewards_[rewards.days-1].rewards[5].kind = 0
					probability = math.random()
					for _, reward in pairs(rewards.reward6) do
						if reward.probability>=probability then
							rewards_[rewards.days-1].rewards[5].kind = reward.kind
							rewards_[rewards.days-1].rewards[5].amount = reward.amount
						else
							probability = probability - reward.probability
						end
					end
				end
			end
		end
		UpdateRewards2Db()
	end
	
	
	local function ActiveCheckIn()
		player.InsertRow(C.ktCheckInEveryDay)
		GenerateRewards()
		check_in_.time = 0
		check_in_.days = 0
	end
	
	local function CalcCheckInTime(cur_time)
		local check_date = os.date('*t', check_in_.time)
		local cur_date = os.date('*t', cur_time)
		if check_date.year==cur_date.year and check_date.yday==cur_date.yday then
			return kValue_.kCantCheckIn
		else
			local first_day_time = 24*3600-(check_in_.time-os.time({year=check_date.year,month=check_date.month,day=check_date.day,hour=0,min=0,sec=0}))
			if (cur_time-check_in_.time)>(24*3600+first_day_time) then
				return kValue_.kShouldRestart
			else
				return kValue_.kSucceeded
			end
		end
	end
	
	processor_[C.kGetCheckInEveryDayInfo] = function()
		local result = new('GetCheckInEveryDayInfoResult')
		if not active_ then
			ActiveCheckIn()
			active_ = true
		end
		local cur_time = os.time()
		local t_result = CalcCheckInTime(cur_time)
		if t_result~=kValue_.kCantCheckIn then
			if check_in_.days>=5 then
				GenerateRewards()
				check_in_.days = 0
				player.UpdateField(C.ktCheckInEveryDay, C.kInvalidID, {C.kfDays, check_in_.days})
			elseif t_result==kValue_.kShouldRestart then
				check_in_.days = 0
				player.UpdateField(C.ktCheckInEveryDay, C.kInvalidID, {C.kfDays, check_in_.days})
			end
		end
		copy(result, check_in_, sizeof(check_in_))
		return result
	end
	
	processor_[C.kDoCheckInEveryDay] = function()
		local result = new('DoCheckInEveryDayResult',C.eInvalidOperation)
		if active_ then
			local cur_time = os.time()
			local t_result = CalcCheckInTime(cur_time)
			if t_result==kValue_.kCantCheckIn then
				return result
			elseif t_result==kValue_.kShouldRestart then
				check_in_.days = 0
			end
			local check_days = 0
			if check_in_.days<=4 then
				check_days = check_in_.days + 1
			else
				GenerateRewards()
				check_days = 1
			end
			local t_rewards = rewards_[check_days-1].rewards
			local add_rewards = {}
			for i=0, 5 do
				if t_rewards[i].kind~=0 then
					if prop_cfgs[t_rewards[i].kind] then
						if not add_rewards[t_rewards[i].kind] then add_rewards[t_rewards[i].kind]=0 end
						add_rewards[t_rewards[i].kind] = add_rewards[t_rewards[i].kind] + t_rewards[i].amount
					else
						print('error prop kind='..t_rewards[i].kind..' in check_in_every_day')
						return result
					end
				end
			end
			if player.AddNewProps2Area4Kinds(C.kAreaBag, add_rewards) then
				result.result = C.eSucceeded
				result.time = cur_time
				check_in_.days = check_days
				check_in_.time = cur_time
				player.UpdateField(C.ktCheckInEveryDay, C.kInvalidID, {C.kfDays, check_in_.days}, {C.kfTime, check_in_.time})
			else
				result.result = C.eBagLeackSpace
			end
		end
		return result
	end
	
	
	db_processor_[C.kInternalCheckInEveryDayInfo] = function(msg)
		active_ = true
		local info = cast('const InternalCheckInEveryDayInfo&',msg)
		copy(check_in_, info, sizeof(info))
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