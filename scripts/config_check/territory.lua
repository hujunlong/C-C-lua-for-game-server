
local monster_groups = require('config.monster_group')
local props = require('config.props')

local territory_style = require('config.territory_style')

for _,v in pairs(territory_style) do
    assert(v[1])
    for _,style in pairs(v) do
        assert(style.kind)
    end
end

local monster_groups = require('config.monster_group')
local territory = require('config.territory')
for _,v in pairs(territory) do
    assert(v.amount)
    assert(v.style)
    assert(v.output)
    assert(v.city_monster)
    assert(v.resource_monster)
    for _,kind in pairs(v.style) do
        assert(territory_style[kind])
    end
    for _,prop in pairs(v.output) do
        assert(prop.probability>0 and prop.probability<=1)
        assert(props[prop.type])
    end
    assert(monster_groups[v.city_monster])
    assert(monster_groups[v.resource_monster])
end

local territory_ratio = require('config.territory_ratio')
for _,v in pairs(territory_ratio) do
    assert(v.ratio)
end

local territory_resource = require('config.territory_resource')
for _,v in pairs(territory_resource) do
    assert(v.time)
    assert(v.guard_time)
    assert(v.type)
    assert(v.unit_time)
    assert(v.amount)
end

--[[
local territory_monster = require('config.territory_monster')
for _,v in pairs(territory_monster) do
    assert(v.city_monster)
    assert(v.resource_monster)
    assert(monster_groups[v.city_monster])
    assert(monster_groups[v.resource_monster])
end
]]

