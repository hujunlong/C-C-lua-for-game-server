local prop_cfgs = require('config.props')
local reward_cfgs = require('config.check_in_accumulate_condition')
local condition_cfg = require('config.check_in_accumulate_condition')
local heros_cfg = require('config.hero')
require('config.town_cfg')
local builds_cfg = GetTownCfg()

assert(condition_cfg[1] and condition_cfg[1].gold)

local function check_reward( reward )
	if reward.reward1 then
		for _, t_reward in pairs(reward.reward1) do
			assert(t_reward.type and t_reward.kind and t_reward.amount)
			if t_reward.type==1 then
				assert(heros_cfg[t_reward.kind])
			elseif t_reward.type==2 then
				assert(builds_cfg[t_reward.kind])
			elseif t_reward.type==3 then
				assert(prop_cfgs[t_reward.kind])
			else
				print('error type='..t_reward.type)
			end
		end
	end
	if reward.reward2 then
		for _, t_reward in pairs(reward.reward2) do
			assert(t_reward.type and t_reward.kind and t_reward.amount)
			if t_reward.type==1 then
				assert(heros_cfg[t_reward.kind])
			elseif t_reward.type==2 then
				assert(builds_cfg[t_reward.kind])
			elseif t_reward.type==3 then
				assert(prop_cfgs[t_reward.kind])
			else
				print('error type='..t_reward.type)
			end
		end
	end
	if reward.reward3 then
		for _, t_reward in pairs(reward.reward3) do
			assert(t_reward.type and t_reward.kind and t_reward.amount)
			if t_reward.type==1 then
				assert(heros_cfg[t_reward.kind])
			elseif t_reward.type==2 then
				assert(builds_cfg[t_reward.kind])
			elseif t_reward.type==3 then
				assert(prop_cfgs[t_reward.kind])
			else
				print('error type='..t_reward.type)
			end
		end
	end
end



do
	for id, reward in pairs(reward_cfgs) do
		local ret, err = pcall(check_reward, reward)
		if not ret then print('id='..id..' has error') print(err) end
	end
end