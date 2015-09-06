local grade_cfg, heros_order = require('config.grade')[1],require('config.grade')[2]
local grade_reward = require('config.grade_reward')

for k,v in pairs(grade_cfg) do
    if k<13 then assert(v.prestige) end
    assert(v.silver_ratio)
end

for k,v in pairs(grade_reward) do
    assert(v.silver)
end