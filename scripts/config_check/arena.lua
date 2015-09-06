local reward_cfg = require('config.arena_reward')
local reward_ratio = require('config.arena_reward_ratio')

for k,v in pairs(reward_cfg) do
    assert(v.rank)
    assert(v.silver)
    assert(v.prestige)
    assert(v.silver_decrease)
    assert(v.prestige_decrease)
    
    assert(#v.rank==2)
end

for k,v in pairs(reward_ratio) do
    assert(v.ratio)
end

local arena_count = require('config.arena_count')
local vip = require('config.vip')
assert(arena_count[0])
assert(#arena_count==#vip)
for _,v in pairs(arena_count) do
    assert(v.count)
end