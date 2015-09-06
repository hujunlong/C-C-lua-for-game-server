local A,B,C,D,S = 'A', 'B', 'C', 'D', 'S'
local cfg = {}

cfg[S] = 
{
    quality = S,
    lord_exp_coefficient = 3,
    silver_coefficient = 3,
    feat_coefficient = 3,
}

cfg[A] = 
{
    quality = A,
    lord_exp_coefficient = 2,
    silver_coefficient = 2,
    feat_coefficient = 2,
}

cfg[B] = 
{
    quality = B,
    lord_exp_coefficient = 1.5,
    silver_coefficient = 1.5,
    feat_coefficient = 1.5,
}

cfg[C] = 
{
    quality = C,
    lord_exp_coefficient = 1,
    silver_coefficient = 1,
    feat_coefficient = 1,
}

cfg[D] = 
{
    quality = D,
    lord_exp_coefficient = 0.8,
    silver_coefficient = 0.8,
    feat_coefficient = 0.8,
}

return cfg