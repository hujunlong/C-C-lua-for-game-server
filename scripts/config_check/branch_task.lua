local tasks = require'config.branch_task'

local function check(id, t)
	if t.depend_task then assert(tasks[t.depend_task]) end
end

for id,v in pairs(tasks) do 
	local ret, err = pcall(check, id, v)
	if not ret then print('id='..id..' has error') print(err) end
end