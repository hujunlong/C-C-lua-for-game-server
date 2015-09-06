local tasks = require'config.trunk_task'
local actives = require'config.active_define'
local sections = require'config.section'
local building_upgrade_activation = require'config.building_upgrade_activation'
local details = require'config.trunk_task_detail'
require'tools.vector'

local function check(id, t)
	assert(t.silver>0)
	assert(t.feat>0)
	assert(t.lord_exp>0)
	if t.to_active then
		for _,id in ipairs(t.to_active) do 
			assert(actives[id])
		end
	end
	if t.section_to_active then
		assert(sections[t.section_to_active])
	end
	if t.depend_task then 
		if tonumber(t.depend_task) then 
			assert(tasks[t.depend_task])
		else --然后是多个的情况
			for _,id in ipairs(t.depend_task) do 
				assert(tasks[id])
			end
		end
	end
	assert(details[id])
end

local function GetNextTrunkTask(task_id)
	for _,task in pairs(tasks) do 
		if task.depend_task==task_id or (type(task.depend_task)=='table' and vector.find(task.depend_task, task_id)) then
			return task
		end
	end
end

local function GetPrviousTrunkTask(task_id, country)
	assert(task_id, "task_id="..task_id)
	local current_task = tasks[task_id]
	assert(current_task, "task_id="..task_id)
	if current_task.depend_task and type(current_task.depend_task)=='table' then --多个前置任务的情况
		for _,id in ipairs(current_task.depend_task) do
			if tasks[id].country == country then return tasks[id] end
		end
	end
	if current_task.depend_task then return tasks[current_task.depend_task] end
end

assert(tasks[1])  --id为1的任务必须为首个任务
assert(not tasks[1].depend_task)

local last_task = nil

--基本检查
for id,v in pairs(tasks) do 
	v.id=id
	if GetNextTrunkTask(id) then
		local ret, err = pcall(check, id, v)
		if not ret then print('id='..id..' has error') print(err) end
	else
		assert(not last_task)
		last_task = v
	end
end

--连续性检查
local tmp_task = last_task 
while tmp_task~=tasks[1] do 
	local t = GetPrviousTrunkTask(tmp_task.id, 1)
	if t then tmp_task = t 
	else print(tmp_task.id) assert(false) end
end
assert(tmp_task==tasks[1])

tmp_task = last_task 
while tmp_task~=tasks[1] do 
	local t = GetPrviousTrunkTask(tmp_task.id, 2)
	if t then tmp_task = t 
	else print(tmp_task.id) assert(false) end
end

tmp_task = last_task 
while tmp_task~=tasks[1] do 
	local t = GetPrviousTrunkTask(tmp_task.id, 3)
	if t then tmp_task = t 
	else print(tmp_task.id) assert(false) end
end

--建筑物激活
for _,v in pairs(building_upgrade_activation) do 
	for _, v in pairs(v) do 
		for _,id in ipairs(v.to_active) do 
			assert(actives[id])
		end
	end
end


