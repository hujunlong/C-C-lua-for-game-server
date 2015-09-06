--战斗技能

local ProduceDamage = require("fight.skill_calc")
local ROUND = require("fight.skill_round")

--圆桌算法
local function RoundTable(skill, actor, target)
    --必定暴击
    if actor.SurelyCrit() then return ROUND.CRIT end

    --闪避（完全免除一次物理伤害，只有物理攻击会出现闪避）
    local dodge = 0
    if skill.type==1 and not target.SurelyBeAttack() then
        dodge = math.max(target.dodge - actor.dodge_reduce, 0)
    end

    --抵抗（完全免除一次魔法伤害，只有魔法攻击会出现抵抗）
    local resistance = dodge
    if skill.type==2 and not target.SurelyBeAttack() then
        resistance = math.max(target.resistance - actor.magical_accurate, 0) + dodge
    end

    --招架（完全免除一次近战伤害，只有近战攻击会出现招架）
    local parry = resistance
    if skill.type==1 and not target.SurelyBeAttack() then
        parry = math.max(target.parry, 0) + resistance
    end

    --格挡（格挡发动后可以仅受一部分的伤害，只有远程攻击会出现格挡）
    local block = parry
    if skill.distance==2 then
        block = math.max(target.block, 0) + parry
    end
    
    --未命中
    local miss = math.max(1 - actor.hit, 0) + block
    
    --暴击
    local crit = math.max(actor.crit - target.toughness, 0) + miss

    --命中
    --local hit = math.max(actor.hit, 0) + crit

    --生成一个0-1的小数，然后判断操作
    local probability = math.random()

    if probability<=dodge then return ROUND.DODGE end
    if probability<=resistance then return ROUND.RESISTANCE end
    if probability<=parry then return ROUND.PARRY end
    if probability<=block then return ROUND.BLOCK end
    if probability<=miss then return ROUND.MISS end
    if probability<=crit then return ROUND.CRIT end

    return ROUND.HIT   --普通攻击
end

--格挡减伤上限
local function CalcBlock(block)
    return math.max(1 - block, 0.3)
end

---------------------------------------------------------------------------
--注册攻击算法

local FeatureFun = {}

--普通物理攻击
FeatureFun["physical_attack"] = function(skill, fighter, target, env)
    local target_records = {}

    skill.type = 1
    target_records.action = RoundTable(skill, fighter, target)

    local damage = ProduceDamage(skill, fighter, target, env)
    if target_records.action==ROUND.BLOCK then
        target_records.life = damage * CalcBlock(target.block_damage_reduction)
    else
        if target_records.action==ROUND.CRIT then
            target_records.life = damage * fighter.crit_damage
        else
            if target_records.action==ROUND.HIT then
                target_records.life = damage
            end
        end
    end

    return nil, target_records
end


--普通魔法攻击
FeatureFun["magical_attack"] = function(skill, fighter, target, env)
    local target_records = {}

    skill.type = 2
    target_records.action = RoundTable(skill, fighter, target)

    local damage = ProduceDamage(skill, fighter, target, env)
    if target_records.action==ROUND.BLOCK then
        target_records.life = damage * CalcBlock(target.block_damage_reduction)
    else
        if target_records.action==ROUND.CRIT then
            target_records.life = damage * fighter.crit_damage
        else
            if target_records.action==ROUND.HIT then
                target_records.life = damage
            end
        end
    end

    return nil, target_records
end

--加血
FeatureFun["healing"] = function(skill, fighter, target, env)
    local target_records = {}
    target_records.life = fighter.max_life * 0.2
    target_records.action = ROUND.HIT
    return nil, target_records
end

--中毒
FeatureFun["poisoning"] = function(times, fighter, target, env)
    local target_records = {}
    target_records.life = -target.max_life * 0.1 * times
    return nil, target_records
end

--换血
FeatureFun["exchange_life"] = function(skill, fighter, target, env)
    local self_records = {}
    local target_records = {}
    self_records.life, target_records.life = target.life, fighter.lifes
    return self_records, target_records
end

--吸血魔法攻击
FeatureFun["absorb_magical_attack"] = function(skill, fighter, target, env)
    local target_records = {}
    local self_records = {}

    skill.type = 2
    target_records.action = RoundTable(skill, fighter, target)

    local damage = ProduceDamage(skill, fighter, target, env)
    if target_records.action == ROUND.BLOCK then
        target_records.life = damage * CalcBlock(target.block_damage_reduction)
    else
        if target_records.action == ROUND.CRIT then
            target_records.life = damage * fighter.crit_damage
        else
            if target_records.action == ROUND.HIT then
                target_records.life = damage
            end
        end
    end

    if target_records.life then
        self_records.life = -target_records.life * 0.2
    end
    
    return self_records, target_records
end

return FeatureFun
