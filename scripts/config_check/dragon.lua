local time_cfg = require("config.race_dragon_time")
local limit_cfg = require("config.race_dragon_limit")
local reward_cfg = require("config.race_dragon_reward")
local coe_cfg = require("config.race_dragon_reward_coefficient")
local props_cfg = require("config.props")
local base_cfg = require("config.rear_dragon_base")

local function check_time( time )
	assert( time.sign_up )
	assert( time.guess )
	assert( time.frozen )
	assert( time.final )
	assert( time.clearing )
	assert( time.sign_up.wday and time.sign_up.wday>=1 and time.sign_up.wday<=7 )
	assert( time.sign_up.time )
	assert( time.guess.wday and time.guess.wday>=1 and time.guess.wday<=7 )
	assert( time.guess.time )
	assert( time.frozen.wday and time.frozen.wday>=1 and time.frozen.wday<=7 )
	assert( time.frozen.time )
	assert( time.final.wday and time.final.wday>=1 and time.final.wday<=7 )
	assert( time.final.time )
	assert( time.clearing.wday and time.clearing.wday>=1 and time.clearing.wday<=7 )
	assert( time.clearing.time )
end

local function check_limit( limit )
	assert( limit.limit )
end

local function check_reward( reward )
	assert( reward.rank and reward.rank[1] and reward.rank[2] )
	if reward.rank[2]~=-1 then
		assert( reward.rank[1]<=reward.rank[2] )
	end
	assert( reward.cardinal )
	assert( reward.prestige )
end

local function check_coe( coe )
	assert( coe.coefficient )
end

local function check_base( base )
	assert( base.rarity )
	assert( base.max_str )
	assert( base.max_str[1] and base.max_str[2] and base.max_str[1]<=base.max_str[2] )
	assert( base.max_agi )
	assert( base.max_agi[1] and base.max_agi[2] and base.max_agi[1]<=base.max_agi[2] )
	assert( base.max_int )
	assert( base.max_int[1] and base.max_int[2] and base.max_int[1]<=base.max_int[2] )
	assert( base.ini_str )
	assert( base.ini_str[1] and base.ini_str[2] and base.ini_str[1]<=base.ini_str[2] )
	assert( base.ini_agi )
	assert( base.ini_agi[1] and base.ini_agi[2] and base.ini_agi[1]<=base.ini_agi[2] )
	assert( base.ini_int )
	assert( base.ini_int[1] and base.ini_int[2] and base.ini_int[1]<=base.ini_int[2] )
	assert( base.price )
	if base.all_sai then
		assert( base.all_sai[1] and base.all_sai[2] and base.all_sai[1]<=base.all_sai[2] )
	end
	if base.a_str then
		assert( base.a_str[1] and base.a_str[2] and base.a_str[1]<=base.a_str[2] )
	end
	if base.a_agi then
		assert( base.a_agi[1] and base.a_agi[2] and base.a_agi[1]<=base.a_agi[2] )
	end
	if base.a_int then
		assert( base.a_int[1] and base.a_int[2] and base.a_int[1]<=base.a_int[2] )
	end
	if base.f_kind then
		for _, kind in pairs( base.f_kind ) do
			assert( base_cfg[kind] )
		end
	end
	if base.m_kind then
		for _, kind in pairs( base.m_kind ) do
			assert( base_cfg[kind] )
		end
	end
	if base.f_his_rank then assert( base.f_his_rank>0 ) end
	if base.m_his_rank then assert( base.m_his_rank>0 ) end
	assert( base.pro )
end




do
	--print('-->check race time')
	for id, time in pairs(time_cfg) do
		local ret, err = pcall(check_time, time)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check race guess limit')
	for id, limit in pairs(limit_cfg) do
		local ret, err = pcall(check_limit, limit)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check race reward')
	local next_reward = nil
	for id, reward in pairs(reward_cfg) do
		next_reward = reward_cfg[id+1]
		if next_reward then
			if not (reward.rank and reward.rank[2] and next_reward.rank and next_reward.rank[1] and reward.rank[2]<next_reward.rank[1]) then
				print('id='..id..' has error')
				break
			end
		end
		local ret, err = pcall(check_reward, reward)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check race coefficient')
	for id, coe in pairs(coe_cfg) do
		local ret, err = pcall(check_coe, coe)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check dragon base')
	for id, base in pairs(base_cfg) do
		local ret, err = pcall(check_base, base)
		if not ret then print('id='..id..' has error') print(err) end
	end
end