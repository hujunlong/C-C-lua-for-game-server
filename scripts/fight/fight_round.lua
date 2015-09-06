local GuaranteeModulus =  0.2   --保底系数

function CreateRoundManager(group_a, group_b, env, this)
    local obj = {}
    
    local winner = 0
    local reason = 0
    local round = 0
    
    --伤害保底值
    local function DamageGuarantee(target)
        return target.level * ( GuaranteeModulus * ( target.level ^ 0.7 ) * ( 1 - GuaranteeModulus ) ) + 5
    end

    --检查英雄状态
    local function InTheState(t)
        return t and next(t)
    end

    --初始化英雄状态
    local function InitHero(hero)
        
        hero.buffs = {}
        hero.states = {}
        
        --玩家本回合能否行动
        hero.CanAction = function()
            return hero.action==false and hero.life~=0
        end
        
        --能否被攻击
        hero.CanBeAttack = function()
            return hero.life~=0
        end
        
        --是否必中
        hero.SurelyBeAttack = function()
            --眩晕状态必中
            if InTheState(hero.states.dizziness) then return true end
            return false
        end
        
        --是否暴击
        hero.SurelyCrit = function()
            --1特殊攻击，2普通攻击 if hero.attack_type==2 then
            
            --黑火药，每第3次普通攻击将必定产生暴击
            if hero.states.round_crit and round % hero.states.round_crit == 0 then return true end
            
            --幸运7，当费奥多尔行动时，如果血量正好个位数为7，那么他的技能将必定暴击。
            if hero.states.luck_crit and hero.life % 10 == hero.states.luck_crit then return true end

            return false
        end
        
        --英雄死亡
        hero.Destroy = function()
            this.buff_manager.ClearHalo(hero.uid)
        end
        
        --需要波动的属性值
        local function Fluctuate(property)
            local value = math.random(hero[property].min, hero[property].max)
            local property_per = property..'_per'
            if hero.states[property_per] then
                if hero.states[property] then
                    return ( value + hero.states[property] ) * ( 1 + hero.states[property_per] )
                else
                    return value * ( 1 + hero.states[property_per] )
                end
            else
                if hero.states[property] then
                    return value + hero.states[property]
                else
                    return value
                end
            end
        end
        
        --取物理攻击属性值
        hero.GetPhysicalAttack = function() return Fluctuate("physical_attack") end
        
        --取魔法攻击属性值
        hero.GetMagicAttack = function() return Fluctuate("magical_attack") end
        
        --取普通属性值
        hero.GetProperty = function(property)
            --玩家基础属性和各种BUFF影响的属性加成
            local property_per = property..'_per'
            if hero.states[property_per] then
                if hero.states[property] then
                    return ( hero[property] + hero.states[property] ) * ( 1 + hero.states[property_per] )
                else
                    return hero[property] * ( 1 + hero.states[property_per] )
                end
            else
                if hero.states[property] then
                    return hero[property] + hero.states[property]
                else
                    return hero[property]
                end
            end
        end
        
        --气槽上限
        if hero.momentum_type~=0 then
            hero.momentum = hero.momentum + 50
            hero.max_momentum = 150
        else
            hero.momentum = 0
            hero.max_momentum = 0
        end
        
        --乱速
        hero.speed = hero.speed * ( math.random(90, 110) / 100 )
        
        --避免重复计算
        hero.damage_guarantee = DamageGuarantee(hero)
    end
    
    --初始化
    for location, hero in pairs(group_a) do
        InitHero(hero)
        hero.uid = location + 100
        hero.location = location
        hero.friends = group_a
        hero.enemies = group_b
        hero.Statistic = this.statistic_manager.AppendStatistic_a
        hero.group_damage_per = env.group_a.group_damage_per
    end
    for location, hero in pairs(group_b) do
        InitHero(hero)
        hero.uid = location + 200
        hero.location = location
        hero.friends = group_b
        hero.enemies = group_a
        hero.Statistic = this.statistic_manager.AppendStatistic_b
        hero.group_damage_per = env.group_b.group_damage_per
        
        if env.type==3 then
            hero.world_boss = true
        end
    end
    
    --队伍是否全部死亡
    local function GroupIsDead(group)
        for _, hero in pairs(group) do
            if hero.life~=0 then
                return false
            end
        end
        return true
    end

    --新回合重置英雄状态
    local function StartNewRound(group)
        for _, hero in pairs(group) do
            hero.action = false
        end
    end
    
    --回合数达到上限时判定输赢
    local function GetFightWinner()
        if env.win_condition==1 then
            --防守方获胜
            winner = 1
        elseif env.win_condition==2 then
            --死亡人数少者获胜
            if this.statistic_manager.GetStatistic_a().dead > this.statistic_manager.GetStatistic_b().dead then
                winner = 0
            else
                winner = 1
            end
        elseif env.win_condition==3 then
            --伤害总量高者获胜
            if this.statistic_manager.GetStatistic_a().hits > this.statistic_manager.GetStatistic_b().hits then
                winner = 0
            else
                winner = 1
            end
        elseif env.win_condition==4 then
            --治疗总量高者获胜
            if this.statistic_manager.GetStatistic_a().heal > this.statistic_manager.GetStatistic_b().heal then
                winner = 0
            else
                winner = 1
            end
        else
            assert(false)
        end
        
        return winner
    end
    
    --战斗是否结束
    function obj.IsFightFinish()
        
        round = round + 1
        
        --有一方全灭则战斗结束
        if GroupIsDead(group_a) then
            winner = 1
            return true
        end
        if GroupIsDead(group_b) then
            winner = 0
            return true
        end
        
        --大于回合数限制战斗结束
        if round>env.round_limit then
            winner = GetFightWinner()
            reason = env.win_condition
            return true
        end
        
        StartNewRound(group_a)
        StartNewRound(group_b)
        
        this.record_manager.NewRound(round)
        return false
    end
    
    --获取出手英雄
    function obj.GetFighter()
        local wait_fighters = {}
        for _,hero in pairs(group_a) do
            if hero.CanAction() then
                table.insert(wait_fighters, hero)
            end
        end
        for _,hero in pairs(group_b) do
            if hero.CanAction() then
                table.insert(wait_fighters, hero)
            end
        end
        
        if not next(wait_fighters) then return nil end
        if GroupIsDead(group_a) then return nil end
        if GroupIsDead(group_b) then return nil end
        
        local max_speed = nil
        local location = nil
        for position, hero in ipairs(wait_fighters) do
            local speed = hero.GetProperty("speed")
            if not max_speed or max_speed < speed then
                max_speed = speed
                location = position
            end
        end
        
        wait_fighters[location].action = true
        return wait_fighters[location]
    end
    
    --获取战斗结果和结束原因
    function obj.GetResult()
        return winner, reason, round
    end
    
    return obj
end
