local prop_cfgs = require('config.props')
local fishery_cfgs = require('config.fish_fisheries')
local cost_cfgs = require('config.fish_cost')
local fish_cfgs = require('config.fish')

local function check_fishery( fishery )
	assert(fishery.normal)
	assert(fishery.gold)
	assert(fishery.torpedo)
	assert(fishery.unlock and fishery.unlock.type and fishery.unlock.id)
	local rewards = nil
	for i=1,3 do
		if i==1 then
			rewards = fishery.normal
		elseif i==2 then
			rewards = fishery.gold
		else
			rewards = fishery.torpedo
		end
		for _, reward in pairs(rewards) do
			assert(reward.type and reward.kind and reward.probability)
			if reward.type==1 then
				assert(prop_cfgs[reward.kind])
			elseif reward.type==2 then
				assert(fish_cfgs[reward.kind])
			else
				assert(false)
			end
		end
	end
end

local function check_fish( fish )
	assert(fish.rare and fish.reward_type and fish.fishery)
	assert(fish.price)
	assert(fish.weight)
	for _, weight in pairs(fish.weight) do
		assert(weight.min and weight.max and weight.probability)
		assert(weight.min<=weight.max)
	end
	assert(fishery_cfgs[fish.fishery])
end

local function check_cost( cost )
	assert( cost.times and cost.gold and cost.torpedo )
	assert( cost.times.min and cost.times.max )
	assert( cost.times.min<=cost.times.max )
end

do
	--print('-->check fish fisheies')
	for id, fishery in pairs(fishery_cfgs) do
		local ret, err = pcall(check_fishery, fishery)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check fish')
	for id, fish in pairs( fish_cfgs ) do
		local ret, err = pcall(check_fish, fish)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check fish cost')
	for id, cost in pairs(cost_cfgs) do
		local ret, err = pcall(check_cost, cost)
		if not ret then print('id='..id..' has error') print(err) end
	end
end