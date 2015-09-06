local alchemy_reward = require('config.alchemy_reward')
for _,v in pairs(alchemy_reward) do
    assert(v.silver)
end

local alchemy_count = require('config.alchemy_count')
local vip = require('config.vip')
assert(alchemy_count[0])
assert(#alchemy_count==#vip)
local max_count
for _,v in pairs(alchemy_count) do
    assert(v.count)
    max_count = v.count
end

local alchemy_cost = require('config.alchemy_cost')
assert(#alchemy_cost>=max_count)
for _,v in pairs(alchemy_cost) do
    assert(v.cost)
end
