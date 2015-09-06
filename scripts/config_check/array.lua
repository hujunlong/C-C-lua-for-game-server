local array = require('config.array')

for k,v_ in pairs(array) do

    for _,v in pairs(v_) do
        --assert(v.level)
        assert(v.pos)
        --assert(v.gain)
        assert(v.speed)
    end
end