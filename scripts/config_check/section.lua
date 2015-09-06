local sections = require('config.section')
local monster_groups = require('config.monster_group')
local props = require('config.props')
require('config_check.define')

local function check(section)
	assert(#section.monster==1 or #section.monster==3)
	assert(section.feat >=0)
	assert(section.hero_exp>=0)
	assert(section.lord_exp>=0)
	assert(section.silver>=0)
	if section.props then
		for _,prop in ipairs(section.props)	do 
			assert(prop.probability>0 and prop.probability<=1)
			assert(props[prop.kind])
		end
	end
	assert(#section.weather==1 or #section.weather==3)
	for _,w in ipairs(section.weather) do 
		assert(weathers[w])
	end
	assert(#section.terrain==1 or #section.terrain==3)
	for _,t in ipairs(section.terrain) do 
		assert(terrains[t])
	end
end

for id, section in pairs(sections) do 
	local ret, err = pcall(check, section)
	if not ret then print('id='..id..' has error') print(err) end
end