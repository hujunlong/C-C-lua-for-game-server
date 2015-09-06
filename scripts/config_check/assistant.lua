local activity_cfg = require('config.assistant_activity')
local tasks_cfg = require('config.assistant_task')
local props_cfg = require('config.props')

local function check_activity()
	local next_activity = nil
	for id,activity in ipairs(activity_cfg) do
		assert(activity.activity)
		assert(activity.activity>0)
		assert(activity.reward)
		for _, reward in pairs(activity.reward) do
			assert(reward.type)
			assert(reward.type<=4 and reward.type>=1)
			assert(reward.detail)
			if reward.type==2 then
				assert( props_cfg[reward.detail] )
			else
				assert( reward.detail>0 )
			end
		end
		next_activity = activity_cfg[id+1]
		if next_activity then 
			assert(next_activity.activity)
			assert(activity.activity<next_activity.activity)
		end
	end
end

local function check_task( task )
	assert(task.amount)
	assert(task.amount>0)
	assert(task.activity)
	assert(task.activity>0)
	assert(task.b_retrieve)
	assert(task.b_retrieve==0 or task.b_retrieve==1)
end

do
	--print('-->check assistant_activity')
	local ret, err = pcall(check_activity)
	if not ret then print('assistant_activity has error') print(err) end
end

do
	--print('-->check assistant_task')
	for id, task in pairs( tasks_cfg ) do
		local ret, err = pcall(check_task, task)
		if not ret then print('id='..id..' has error') print(err) end
	end
end