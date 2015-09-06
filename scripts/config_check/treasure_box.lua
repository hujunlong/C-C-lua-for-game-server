
local boxes = require'config.treasure_box'
local prop_cfgs = require'config.props'

local function check(box)
	assert(box.monster_probability>=0 and box.monster_probability<=1)
	for _, prop in ipairs(box.props) do 
		assert(prop_cfgs[prop.kind])
		assert(tonumber(prop.amount))
		assert(prop.probability<=1)
	end
end


for id,v in pairs(boxes) do 
	local ret, err = pcall(check, v)
	if not ret then print('id='..id..' has error') print(err) end
end