local props_cfg = require('config.props')
local close_level = require('config.lucky_draw_close')
local cost_cfg = require('config.lucky_draw_cost')
local reward_cfg = require('config.lucky_draw_reward')
local free_times = require('config.lucky_draw_times')



local function check_reward( reward )
	assert(reward.location and reward.location>=1 and reward.location<=16)
	assert(reward.kind)
	assert(props_cfg[reward.kind])
	assert(reward.weight)
	assert(reward.level)
	assert(reward.level.min and reward.level.max)
	assert(reward.level.min>=0 and reward.level.max>=0 and reward.level.min<=reward.level.max)
end

local function check_cost(cost)
	assert(cost.gold and cost.gold>=0)
end

local function check_times()
	assert(free_times[1])
	assert(free_times[1].times)
end

local function check_level()
	assert(close_level[1])
	assert(close_level[1].level and close_level[1].level>=1)
end

do
	for id, reward in pairs(reward_cfg) do
		local ret, err = pcall(check_reward, reward)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	for id, cost in pairs(cost_cfg) do
		local ret, err = pcall(check_cost, cost)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	local ret, err = pcall(check_times, nil)
	if not ret then print('times has error') print(err) end
end

do
	local ret, err = pcall(check_level, nil)
	if not ret then print('level has error') print(err) end
end