local maps = require'config.map'
require'config_check.define'
local monster_groups = require'config.monster_group'
local boxes = require'config.treasure_box'


local function check(map)
	assert(map.darkmine)
	assert(map.darkmine.min>0 and map.darkmine.max>0)
	assert(map.weather_probability)
	
	local total = 0
	for w,value in pairs(map.weather_probability) do 
		assert(weathers[w])
		assert(value)
		total = total+value
	end
	assert(total==1)
	
	assert(map.mobility_cost>=0)
	if not map.superior_map then assert(map.start_location>0) end
	
	for _,id in ipairs(map.monsters) do
		assert(monster_groups[id])
	end
	for _,id in ipairs(map.box_monsters) do
		assert(monster_groups[id])
	end
	
	for id, location in pairs(map.locations) do 
		assert(#location.adjacent_locations>=1)
		assert(terrains[location.terrain])
		if location.convey2map then
			assert(maps[location.convey2map])
			assert(maps[location.convey2map].locations[location.convey2location])
		end
	end
	
	for id, location in pairs(map.location_groups) do 
		assert(#location.locations>=1)
		assert(location.max_boxes>=1)
		assert(#location.possible_boxes>=1)
		total = 0
		for _,v in ipairs(location.possible_boxes) do 
			assert(boxes[v.sid]) 
			total = total+v.probability
		end
		assert(total==1)
	end
	
end



for id,map in pairs(maps) do 
	local ret, err = pcall(check, map)
	if not ret then print('id='..id..' has error') print(err) end
end