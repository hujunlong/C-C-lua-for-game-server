local prop_cfgs = require('config.props')
local reward_cfgs = require('config.check_in_every_day')

local function check_reward( reward )
	if reward.reward1 then
		for _, t_reward in pairs(reward.reward1) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	if reward.reward2 then
		for _, t_reward in pairs(reward.reward2) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	if reward.reward3 then
		for _, t_reward in pairs(reward.reward3) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	if reward.reward4 then
		for _, t_reward in pairs(reward.reward4) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	if reward.reward5 then
		for _, t_reward in pairs(reward.reward5) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	if reward.reward6 then
		for _, t_reward in pairs(reward.reward6) do
			assert(t_reward.kind and t_reward.amount and t_reward.probability)
			assert(prop_cfgs[t_reward.kind])
		end
	end
	assert(reward.level and reward.level.min and reward.level.max and reward.level.min<=reward.level.max)
	assert(reward.days)
end



do
	for id, reward in pairs(reward_cfgs) do
		local ret, err = pcall(check_reward, reward)
		if not ret then print('id='..id..' has error') print(err) end
	end
end