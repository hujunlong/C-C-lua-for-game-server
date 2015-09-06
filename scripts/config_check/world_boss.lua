local boss_cfg = require('config.world_boss')
local boss_level = require('config.world_boss_level')
local monster_cfgs = require('config.monster')

local function CheckTime(str)
    assert(type(str)=='string' and #str==5)
end

for _,v in pairs(boss_cfg) do
    assert(v.enter_time)
    assert(v.start_time)
    assert(v.over_time)
    assert(v.country)
    assert(v.id)
    
    CheckTime(v.enter_time)
    CheckTime(v.start_time)
    CheckTime(v.over_time)
    assert(v.country>=0 and v.country<=3)
    assert(monster_cfgs[v.id])
end

for _,v in pairs(boss_level) do
    assert(v.life)
    assert(v.killer_reward)
    assert(v.silver_limit)
    assert(v.top_reward)
    assert(v.prestige)
    assert(v.prestige_limit)
    assert(#v.top_reward==10)
end

local world_boss_count = require('config.world_boss_count')
local vip = require('config.vip')
assert(world_boss_count[0])
assert(#world_boss_count==#vip)
for _,v in pairs(world_boss_count) do
    assert(v.count)
end