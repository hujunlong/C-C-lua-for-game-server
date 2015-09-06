--国战可配置参数

local cfgs = 
{
    --普通战斗CD时间
    cd_time1 = 30,
    
    --自动战斗CD时间
    cd_time2 = 5 * 60,
    
    --每次推进进度
    progress = 2,
    
    --自动战斗最多次数
    auto_max = 5,
    
    --连胜最大次数
    winning_max = 10,
    
    --战斗失败积分
    lose_score = 2,
    
    --重置时间（其中周一执行统计操作）
    reset_time = "00:00",
    
    --发奖时间
    award_time = "12:00",
    
    --望在第1战胜利获得N点
    prestige_reward = 5,
    
    --每额外胜利一场获得M点
    prestige_extra = 2,
    
    --第一场失利获得X点
    prestige_fail = 1,
}

return cfgs