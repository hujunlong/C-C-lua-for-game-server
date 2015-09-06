local prop_cfgs = require('config.props')
local reward_cfgs = require('config.check_in_accumulate')
local condition_gold_ = require('config.check_in_accumulate_condition')[1].gold
local hero_cfgs = require('config.hero')
require('config.town_cfg')
local build_cfgs = GetTownCfg()


local ffi = require('ffi')
local C = ffi.C
--local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
--local copy = ffi.copy


local function enum(...)
	local enum_t = {}
	for k,v in pairs(...) do enum_t[v] = k end
	return enum_t
end
local kValue_ = enum{"kCantCheckIn", "kSucceeded" }

function CreateCheckInAccumulate(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local active_ = false
	
	local check_in_ = {}
	check_in_.time = 0
	check_in_.days = 0
	
	local function ActiveCheckIn()
		player.InsertRow(C.ktCheckInAccumulate)
		active_ = true
	end
	
	local function CalcCheckInTime(cur_time)
		local check_date = os.date('*t', check_in_.time)
		local cur_date = os.date('*t', cur_time)
		if check_date.year==cur_date.year and check_date.yday==cur_date.yday then
			return kValue_.kCantCheckIn
		else
			return kValue_.kSucceeded
		end
	end
	
	local function GetRewardInDay(add_props, other_rewards, days)
		local reward = nil
		reward = reward_cfgs[days].reward1
		if reward then
			if reward.type==3 then
				if not prop_cfgs[reward.kind] then
					print('error prop kind='..reward.kind)
					return
				end
				if not add_props[reward.kind] then add_props[reward.kind]=0 end
				add_props[reward.kind] = add_props[reward.kind] + reward.amount
			elseif reward.type==2 then
				if not build_cfgs[reward.kind] then
					print('error building kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			elseif reward.type==1 then
				if not hero_cfgs[reward.kind] then
					print('error hero kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			end
		end
		reward = reward_cfgs[days].reward2
		if reward then
			if reward.type==3 then
				if not prop_cfgs[reward.kind] then
					print('error prop kind='..reward.kind)
					return
				end
				if not add_props[reward.kind] then add_props[reward.kind]=0 end
				add_props[reward.kind] = add_props[reward.kind] + reward.amount
			elseif reward.type==2 then
				if not build_cfgs[reward.kind] then
					print('error building kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			elseif reward.type==1 then
				if not hero_cfgs[reward.kind] then
					print('error hero kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			end
		end
		reward = reward_cfgs[days].reward3
		if reward then
			if reward.type==3 then
				if not prop_cfgs[reward.kind] then
					print('error prop kind='..reward.kind)
					return
				end
				if not add_props[reward.kind] then add_props[reward.kind]=0 end
				add_props[reward.kind] = add_props[reward.kind] + reward.amount
			elseif reward.type==2 then
				if not build_cfgs[reward.kind] then
					print('error building kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			elseif reward.type==1 then
				if not hero_cfgs[reward.kind] then
					print('error hero kind='..reward.kind)
					return
				end
				local other_reward = {type=reward.type, kind=reward.kind, amount=reward.amount}
				table.insert(other_rewards, other_reward)
			end
		end
	end
	
	processor_[C.kGetCheckInAccumulateInfo] = function()
		local result = new('GetCheckInAccumulateInfoResult')
		if not active_ then
			ActiveCheckIn()
		end
		result.time = check_in_.time
		result.days = check_in_.days
		return result
	end
	
	processor_[C.kGetCheckInAccumulateReward] = function(msg)
		local result = new('GetCheckInAccumulateRewardResult')
		if not active_ then
			ActiveCheckIn()
		end
		local cur_time = os.time()
		local b_direct = cast('const GetCheckInAccumulateReward&',msg).b_direct
		local add_props = {}
		local other_rewards = {}
		local days = 0
		if check_in_.days<7 then
			if b_direct==1 then
				if player.GetRechargedGold()>=condition_gold_ then
					for i=(check_in_.days+1), 7 do
						GetRewardInDay(add_props, other_rewards, i)
					end
					days = 7
				else
					result.result = C.eInvalidOperation
					return result
				end
			else
				if CalcCheckInTime(cur_time)==kValue_.kCantCheckIn then
					result.result = C.eInvalidOperation
					return result
				else
					GetRewardInDay(add_props, other_rewards, check_in_.days+1)
					days = check_in_.days + 1
				end
			end
			local b_have_prop = false
			for _, _ in pairs(add_props) do
				b_have_prop = true
				break
			end
			if b_have_prop then
				if player.AddNewProps2Area4Kinds(C.kAreaBag, add_props) then
					result.result = C.eSucceeded
				else
					result.result = C.eBagLeackSpace
				end
			else
				result.result = C.eSucceeded
			end
			if result.result==C.eSucceeded then
				for _, reward in pairs(other_rewards) do
					if reward.type==1 then
						--
						--英雄
						--
					elseif reward.type==2 then
						player.AddBuilding(reward.kind)
					else
						print('error reward type='..reward.type)
					end
				end
				result.result = C.eSucceeded
				result.time = cur_time
				check_in_.days = days
				check_in_.time = cur_time
				player.UpdateField(C.ktCheckInAccumulate, C.kInvalidID, {C.kfTime,cur_time}, {C.kfDays, check_in_.days})
			end
		else
			result.result = C.eFunctionDisable
		end
		return result
	end
	
	db_processor_[C.kInternalCheckInAccumulateInfo] = function(msg)
		active_ = true
		local info = cast('const InternalCheckInAccumulateInfo&',msg)
		check_in_.time = info.time
		check_in_.days = info.days
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