--战斗公式（伤害计算）


--获取气槽相克关系
local momentum_ratio = 
{
    [0] = {[0]=0, 0, 0, 0}, -- 无气槽
    {[0]=0, 0, 0.2, -0.2}, -- 力量（怒气）
    {[0]=0, -0.2, 0, 0.2}, -- 敏捷（能量）
    {[0]=0, 0.2, -0.2, 0}, -- 智利（魔力）
}
local function MomentumRestriction(hero1, hero2)
    return momentum_ratio[hero1.momentum_type][hero2.momentum_type]
end


--获取元素相克关系

-- 相同元素，所有比例为负
local negative =
{
--      ○   ○○ ○○○
    {0.10, 0.15, 0.20},  --○
    {0.10, 0.15, 0.20},  --○○
    {0.10, 0.15, 0.20},  --○○○
}

-- 相克元素，获得加成
local positive =
{
--      ●   ●● ●●●
    {0.10, 0.10, 0.10},  --●
    {0.15, 0.15, 0.15},  --●●
    {0.20, 0.20, 0.20},  --●●●
}

-- 0无，1火焰，2自然，3水，4光，5暗
local RestrictionTable = {2, 3, 1, 5, 4}
local function GetRestriction(ele)
    return RestrictionTable[ele]
end

local element_cache = {}
local function ElementRestriction(hero1_element_relative, hero2_element_relative)
    
    if not hero1_element_relative.cache then hero1_element_relative.cache = hero1_element_relative[1] * 100 + hero1_element_relative[2] * 10 + hero1_element_relative[3] end
    if not hero2_element_relative.cache then hero2_element_relative.cache = hero2_element_relative[1] * 100 + hero2_element_relative[2] * 10 + hero2_element_relative[3] end
    
    if element_cache[hero1_element_relative.cache] and element_cache[hero1_element_relative.cache][hero2_element_relative.cache] then return element_cache[hero1_element_relative.cache][hero2_element_relative.cache] end
    
    local elements1 = {[0]=0, 0, 0, 0, 0, 0}
    local elements2 = {[0]=0, 0, 0, 0, 0, 0}

    --填充数组
    for i = 1, 3 do
        index1 = hero1_element_relative[i]
        index2 = hero2_element_relative[i]
        elements1[index1] = elements1[index1] + 1
        elements2[index2] = elements2[index2] + 1
    end

    --计算结果
    if not element_cache[hero1_element_relative.cache] then element_cache[hero1_element_relative.cache] = {} end
    element_cache[hero1_element_relative.cache][hero2_element_relative.cache] = 0

    --统计个数
    for i = 1, 5 do
        local ele1 = elements1[i]
        if ele1~=0 then
            local ele2 = elements2[i]
            local ele_res2 = elements2[GetRestriction(i)]
            if ele2~=0 then
                element_cache[hero1_element_relative.cache][hero2_element_relative.cache] = element_cache[hero1_element_relative.cache][hero2_element_relative.cache] - negative[ ele1 ][ ele2 ]
            end

            if ele_res2~=0 then
                element_cache[hero1_element_relative.cache][hero2_element_relative.cache] = element_cache[hero1_element_relative.cache][hero2_element_relative.cache] + positive[ ele1 ][ ele_res2 ]
            end
        end

    end

    return element_cache[hero1_element_relative.cache][hero2_element_relative.cache]
end

--物理伤害，返回伤害值
local function GetPhysicalDamage(hero1, hero2)
    return hero1.GetPhysicalAttack() - hero2.GetProperty('physical_defense')
end

--魔法伤害，返回伤害值
local function GetMagicDamage(hero1, hero2)
    return hero1.GetMagicAttack() - hero2.GetProperty('magical_defense')
end

local function ProduceDamage(skill, hero1, hero2, env)
    --兵种、属性（元素）、地形、气候、阵形修正
    --local kindRestraintModulus = GetkindRestraintModulus(hero1, hero2)
    local ElementRestraintModulus = ElementRestriction(skill.element_relative, hero2.element_relative)
    local MomentumRestraintModulus = MomentumRestriction(hero1, hero2)
    
    local GeographyRestraintModulus = hero1.GetProperty(env.terrain)
    local WeatherRestraintModulus = hero1.GetProperty(env.weather)
    local FormationRestraintModulus = 0

    -- 一级属性修正，力量差距
    local difference

    if skill.type==1 then
         difference = GetPhysicalDamage(hero1, hero2)
    else
        if skill.type~=2 then error('the skill exec wrong in ProduceDamage.') end
        difference = GetMagicDamage(hero1, hero2)
    end

    local damage =  difference
    --* ( 1 + kindRestraintModulus )
    * ( 1 + ElementRestraintModulus + MomentumRestraintModulus )
    * ( 1 + GeographyRestraintModulus + WeatherRestraintModulus + FormationRestraintModulus )

    return -math.max(damage, hero2.damage_guarantee)
end

return ProduceDamage
