local rune_cfg = require('config.runes')
local rune_aperture = require('config.rune_aperture')
local rune_group = require('config.rune_group')
local rune_upgrade = require('config.rune_upgrade')
local rune_material = require('config.rune_material')


for _,v in pairs(rune_cfg) do
    --assert(v.level)
    assert(v.kind)
    --assert(v.quality)
    assert(v.kind>=1 and v.kind<=4)
    if v.kind~=4 then assert(v.exp) end
    if v.kind==4 then assert(v.price) end
end

for _,v in pairs(rune_aperture) do
    assert(v.amount)
    assert(#v.amount==3)
    assert(v.amount[1]>0 and v.amount[1]<50)
    assert(v.amount[2]>50 and v.amount[2]<100)
    assert(v.amount[3]>100 and v.amount[2]<150)
end

for _,v in pairs(rune_group) do
    assert(v.runes)
    assert(#v.runes>=1)
    
    for _,rune in pairs(v.runes) do
        if type(rune)~='table' then
            assert(rune_cfg[rune])
        else
            assert(rune_cfg[rune[1]])
        end
    end
end

for _,v in pairs(rune_material) do
    assert(v.cost)
    assert(v.probability)
    assert(v.runes)
    
    assert(v.probability>=0 and v.probability<=1)
    
    for _,rune in pairs(v.runes) do
        assert(rune.group)
        assert(rune.probability)
        assert(rune_group[rune.group])
        assert(rune.probability>=0 and rune.probability<=1)
    end
end

for k,v in pairs(rune_upgrade) do
    assert(rune_cfg[k])
    assert(#v==10)
    for i,rune in pairs(v) do
        if i<10 then assert(rune.exp) end
        assert(rune.property)
    end
end

local rune_material = require('config.rune_count')
local vip = require('config.vip')
assert(rune_material[0])
assert(#rune_material==#vip)
for _,v in pairs(rune_material) do
    assert(v.count)
end