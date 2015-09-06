local details = require'config.trunk_task_detail'
local sections = require'config.section'
local heros = require'config.hero'
local sciences = require'config.science'
 require'config.town_cfg'
 local buildings = GetTownCfg()
 
require'tools.vector'

local section_sid_index_map = {}
for index, v in pairs(sections) do 
	section_sid_index_map[v.sid] = index
end
for _,details in pairs(details) do 
	for _,detail in pairs(details) do 
		if detail.section then detail.section=section_sid_index_map[detail.section] end
	end
end

local function check(_,v)
	assert(vector.is_vector(v))
	for _,v in ipairs(v) do 
		assert(v.action)
		if v.section then assert(sections[v.section]) end
		if v.action=='build' then
			assert(buildings[v.kind])
		elseif v.action=='pass' then
			assert(v.sub_section==1 or v.sub_section==3)
		elseif v.action=='upgrade_building' or v.action=='build' then
			assert(buildings[v.kind])
		elseif v.action=='recruit' or v.action=='put_hero_to_array' then
			assert(heros[v.kind])
		elseif v.action=='upgrade_science_level' then
			assert(sciences[v.kind][v.level])
--		elseif v.action=='' then
		end
	end
end

for id,v in pairs(details) do 
	local ret, err = pcall(check, id, v)
	if not ret then print('id='..id..' has error') print(err) end
end
