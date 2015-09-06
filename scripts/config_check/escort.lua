local escort_cfg = require('config.escort_transport')
local escort_ratio = require('config.escort_ratio')

for k,v in pairs(escort_cfg) do
    assert(v.time)
    assert(v.silver)
    assert(v.prestige)
    assert(v.probability)
end

assert(#escort_cfg==5)

for k,v in pairs(escort_ratio) do
    assert(v.ratio)
end