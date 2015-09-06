
local stage_award = require('config.stage_award')

local props = require('config.props')

for _,stage in pairs(stage_award) do
    for i,v in pairs(stage) do
        assert(v.sid)
        if i==0 then
            assert(v.achievement==nil)
        else
            assert(v.achievement)
        end
        assert(v.reward_type)
        assert(v.rewards)
        
        
        assert(v.reward_type>=1 and v.reward_type<=5)
        if v.reward_type==5 then
            for _,prop in pairs(v.rewards) do
                assert(prop.kind)
                assert(prop.amount)
                assert(props[prop.kind])
            end
        end
    end
end