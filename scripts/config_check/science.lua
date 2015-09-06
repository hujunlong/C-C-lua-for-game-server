local science_cfg = require('config.science')
local science_map = require('config.science_map')

for k,v in pairs(science_cfg) do
    assert(science_map[k])
    
    for i,science in pairs(v) do
        assert(science.level)
        if i~=1 then assert(science.feat) end
        assert(science.gain)
    end
end