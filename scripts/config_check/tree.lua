local props_cfg = require('config.props')
local seed_cfg = require('config.tree_seed')
local cost_cfg = require('config.tree_cost')

local function check_seed( seed )
	assert(seed.kind)
	assert(seed.location and seed.location>0 and seed.location<=10)
	assert(seed.probability)
	assert(seed.reward_type and seed.reward_type>=1 and seed.reward_type<=4)
	if seed.reward_type==1 then
		assert(seed.prop_kind and props_cfg[seed.prop_kind])
	end
	assert(seed.amount)
	assert(seed.ripe_time)
	assert(seed.silver)
	assert(seed.water_dec_time)
	assert(seed.water_times)
end

local function check_cost(cost)
	assert(cost.cost)
end

do
	--print('-->check tree seed')
	for id, seed in pairs(seed_cfg) do
		local ret, err = pcall(check_seed, seed)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check tree cost')
	for id, cost in pairs(cost_cfg) do
		local ret, err = pcall(check_cost, cost)
		if not ret then print('id='..id..' has error') print(err) end
	end
end