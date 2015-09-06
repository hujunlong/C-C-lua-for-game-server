local bringup_cost = require('config.bringup_cost')
for _,v in pairs(bringup_cost) do
    assert(v.bringup1)
    assert(v.bringup2)
    assert(v.bringup3)
    assert(v.bringup4)
    for _,b in pairs(v) do
        assert(b.type)
        assert(b.cost)
    end
end

local bringup_range = require('config.bringup_range')
assert(#bringup_range==4)
for _,v in ipairs(bringup_range) do
    assert(v.lower)
    assert(v.upper)
    assert(v.vip)
    assert(v.vip>=0 and v.vip<=12)
end
