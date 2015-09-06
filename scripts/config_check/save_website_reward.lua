local rewards_cfg = require('config.save_website_reward')
local props_cfg = require('config.props')
local heros_cfg = require('config.hero')
require('config.town_cfg')
local builds_cfg = GetTownCfg()

local function check_reward( rewards )
	for _, reward in pairs(rewards.rewards) do
		assert(reward.type and reward.type<=3)
		assert(reward.kind)
		assert(reward.amount)
		if reward.type==1 then
			assert(props_cfg[reward.kind])
		elseif reward.type==2 then
			assert(builds_cfg[reward.kind])
		elseif reward.type==3 then
			assert(heros_cfg[reward.kind])
		end
	end
end

local ret, err = pcall(check_reward, rewards_cfg[1])
if not ret then print('id=1 has error') print(err) end
