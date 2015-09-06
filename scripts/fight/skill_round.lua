--圆桌规则
local ROUND =
{
    DODGE = 1,                --闪避 （完全免除一次物理伤害）
    RESISTANCE = 2,           --抵抗 （完全免除一次魔法伤害）
    PARRY = 3,                --招架 （完全免除一次近战伤害）
    BLOCK = 4,                --格挡 （格挡发动后可以仅受一部分的伤害）
    CRIT = 5,                 --暴击 
    HIT = 6,                  --命中 （普通攻击）
    MISS = 7,                 --未命中 （普通攻击）
}

return ROUND
