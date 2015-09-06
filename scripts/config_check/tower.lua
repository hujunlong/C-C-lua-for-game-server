local tower_count = require('config.tower_count')
local vip = require('config.vip')
assert(tower_count[0])
assert(#tower_count==#vip)
local max_count
for _,v in pairs(tower_count) do
    assert(v.count)
    max_count = v.count
end

local tower_cost = require('config.tower_cost')
assert(#tower_cost>=max_count)
for _,v in pairs(tower_cost) do
    assert(v.cost)
end


local tower = require('config.tower')

local monster_groups = require('config.monster_group')
local props = require('config.props')

for _,layer in pairs(tower) do
    for _,v in pairs(layer) do
        assert(v.monster)
        assert(v.silver)
        assert(v.exp)
        assert(v.reward_count)
        assert(v.reward)
        assert(#v.reward>=v.reward_count)
        
        assert(monster_groups[v.monster])
        for _,prop in pairs(v.reward) do
            assert(prop.sid)
            assert(prop.probability)
            assert(prop.amount)
            if prop.sid~=0 then
                assert(props[prop.sid])
            end
        end
    end
end