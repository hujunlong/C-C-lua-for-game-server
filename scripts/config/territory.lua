local cfgs = {}

cfgs[1] = 
{
    amount = 2,
    style = {1,2,3},
    output = {{type = 1, amount = 2500, probability = 0.48}, {type = 2, amount = 5, probability = 0.04}, {type = 3, amount = 54, probability = 0.08}},
    city_monster = 60004,
    resource_monster = 60008,
}

cfgs[2] = 
{
    amount = 2,
    style = {4,5,6},
    output = {{type = 1, amount = 2500, probability = 0.48}, {type = 2, amount = 5, probability = 0.04}, {type = 3, amount = 54, probability = 0.08}},
    city_monster = 60003,
    resource_monster = 60007,
}

cfgs[3] = 
{
    amount = 4,
    style = {7,8,9},
    output = {{type = 1, amount = 2500, probability = 0.48}, {type = 2, amount = 5, probability = 0.04}, {type = 3, amount = 54, probability = 0.08}},
    city_monster = 60002,
    resource_monster = 60006,
}

cfgs[4] = 
{
    amount = -1,
    style = {10,11,12},
    output = {{type = 1, amount = 2500, probability = 0.48}, {type = 2, amount = 5, probability = 0.04}, {type = 3, amount = 54, probability = 0.08}},
    city_monster = 60001,
    resource_monster = 60005,
}

return cfgs