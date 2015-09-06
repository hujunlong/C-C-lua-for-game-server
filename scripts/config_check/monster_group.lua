local mgs = require('config.monster_group')
local monsters = require('config.monster')

local function check(v)
	for _,m in ipairs(v) do 
		assert(m.pos<=9 and m.pos>=1)
		assert(monsters[m.sid])
	end
end

for id, v in pairs(mgs) do 
	local ret, err = pcall(check, v.monster)
	if not ret then print('id='..id..' has error') print(err) end
end 