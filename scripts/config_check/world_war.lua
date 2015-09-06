local world_war_map = require('config.world_war_map')

for _,v in pairs(world_war_map) do
    assert(v.country)
    assert(v.adjacent_maps)
    assert(v.weather_probability)
    assert(v.locations)
    
    for k,loc in pairs(v.locations) do
        assert(loc.adjacent_locations)
        assert(loc.terrain)
        assert(loc.born~=nil)
        assert(loc.reborn~=nil)
        assert(loc.default)
    end
end

local world_war_grade = require('config.world_war_grade')
local grade = require('config.grade')[1]
assert(#world_war_grade==#grade)
for _,v in pairs(world_war_grade) do
    assert(v.vote)
end

local world_war_rank = require('config.world_war_rank')
for _,v in pairs(world_war_rank) do
    assert(v.score)
end

local world_war_vip = require('config.world_war_vip')
local vip = require('config.vip')
assert(world_war_vip[0])
assert(#world_war_vip==#vip)
for _,v in pairs(world_war_vip) do
    assert(v.count)
end