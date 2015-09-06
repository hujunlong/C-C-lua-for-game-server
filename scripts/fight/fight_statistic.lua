function CreateStatisticManager(group_a, group_b, env, this)
    local obj = {}
    
    local statistic_a = {hits=0, heal=0}
    local statistic_b = {hits=0, heal=0}
    
    --统计
    local function GetStatistic(group)
        local max_life = 0
        local cur_life = 0
        
        local total = 0
        local alive = 0
        local dead = 0
        for _, hero in pairs(group) do
            --统计血量
            max_life = max_life + hero.max_life
            cur_life = cur_life + hero.life
            
            --统计人数
            total = total + 1
            if hero.life==0 then
                dead = dead + 1
            else
                alive = alive + 1
            end
        end
        return cur_life * 100 / max_life, total, alive, dead
    end
    
    --获取A组战斗统计
    function obj.GetStatistic_a()
        if not statistic_a.life then
            statistic_a.life, statistic_a.total, statistic_a.alive, statistic_a.dead = GetStatistic(group_a)
        end
        return statistic_a
    end
    
    --获取B组战斗统计
    function obj.GetStatistic_b()
        if not statistic_b.life then
            statistic_b.life, statistic_b.total, statistic_b.alive, statistic_b.dead = GetStatistic(group_b)
        end
        return statistic_b
    end
    
    --A组追加统计添加
    function obj.AppendStatistic_a(name, value)
        statistic_a[name] = statistic_a[name] + value
    end
    
    --B组追加统计添加
    function obj.AppendStatistic_b(name, value)
        statistic_b[name] = statistic_b[name] + value
    end
    
    return obj
end