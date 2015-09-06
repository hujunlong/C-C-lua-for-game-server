require'config.town_cfg'

local item_cfgs, upgrade_cfgs, merge_cfgs = GetTownCfg()

local function check_rewards(rwds)
	if not rwds then return end
	for _,rwd in ipairs(rwds) do 
		assert(rwd.min<=rwd.max)
		assert(rwd.probability<=1 and rwd.probability>0)
		assert(tonumber(rwd.type))
	end
end

local function check_item(kind, item)
	assert(kind>0 and kind==item.kind)
	assert(item.occupy.x>0 and item.occupy.y>0)
	assert(item.prosperity>0)
	assert(item.foundation_energy_cost>=0)
	assert(item.foundation_silver_cost>=0)
		
	if item.type==1 then --功能建筑
		assert(item.build_times>=0)
		assert(item.energy_cost_per_build>0)
		assert(tonumber(item.update_at))
	elseif item.type==2 then --商业建筑
		assert(item.build_times>=0)
		assert(item.energy_cost_per_build>0)
		assert(item.cool_down_seconds>0)
		assert(item.enable_decoration)
		assert(item.foundation_energy_cost>=0)
		assert(item.foundation_silver_cost>=0)
		assert(item.reap_energy_cost>0)
		assert(item.selling_price>0)
	else --装饰和道路 
		if item.type==3 then 
			assert(item.addition>=0)
		end
		assert(item.selling_price>0)
	end
	
	check_rewards(item.complete_reward)
	check_rewards(item.build_reward)
	if item.type== 1 then 
		for _,p in pairs(item.product) do 
			check_rewards(p)
		end
	end
	if item.type==2 then 
		check_rewards(item.product)
	end
end

for kind, item in pairs(item_cfgs) do 
	local ret, err = pcall(check_item, kind, item)
	if not ret then print('id='..kind..' has error') print(err) end	
end