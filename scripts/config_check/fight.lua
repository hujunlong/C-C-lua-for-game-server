local hero_template = 
{
    type = 1,
    race = 1,
    momentum_type = 3,
    favorite_weapon = {17,18},
    element_relative = {4,4,0},
    attack_range = {min = 3, max = 5},
    normal_attack = 31001,
    special_attack = 31002,
    abillity_bias = 3,
    strength = 8,
    agility = 10,
    intelligence = 12,
    bringup_limit = {strength = 0.8, agility = 1, intelligence = 1.2},
    life = 278,
    life_per_upgrade = 20,
    physical_attack = 60,
    physical_attack_per_upgrade = 10,
    physical_defense = 42,
    physical_defense_per_upgrade = 7,
    magical_attack = 60,
    magical_attack_per_upgrade = 10,
    magical_defense = 42,
    magical_defense_per_upgrade = 7,
    real_damage = 0,
    speed = 160,
    hit = 0.95,
    dodge = 0.05,
    dodge_reduce = 0,
    resistance = 0.05,
    magical_accurate = 0,
    block = 0,
    block_damage_reduction = 0,
    parry = 0,
    counterattack = 0,
    counterattack_damage = 0,
    crit = 0.05,
    toughness = 0,
    crit_damage = 1.5,
    dizziness_resistance = 0,
    sleep_resistance = 0,
    paralysis_resistance = 0,
    charm_resistance = -1,
    silence_resistance = 0,
    detained_resistance = 0,
    ridicule_resistance = 0,
    plain = 0,
    mountain = 0,
    forest = 0,
    lake = 0,
    coastal = 0,
    cave = 0,
    wasteland = 0,
    citadel = 0,
    sunny = 0,
    rain = 0,
    cloudy = 0,
    snow = 0,
    fog = 0,
    quality = 1,
}

local monster_template = 
{
    level = 1,
    exp = 0,
    feat = 0,
    silver = 0,
    race = 4,
    momentum_type = 1,
    element_relative = {0,0,0},
    attack_range = {min = 1, max = 5},
    normal_attack = 31078,
    special_attack = 31079,
    abillity_bias = 1,
    strength = 55,
    agility = 55,
    intelligence = 55,
    life = 1000,
    physical_attack = {min = 1, max = 1},
    physical_defense = 0,
    magical_attack = {min = 1, max = 1},
    magical_defense = 0,
    real_damage = 0,
    speed = 180,
    hit = 0.95,
    dodge = 0.05,
    dodge_reduce = 0,
    resistance = 0,
    magical_accurate = 0,
    block = 0.05,
    block_damage_reduction = 0.2,
    parry = 0.05,
    counterattack = 0,
    counterattack_damage = 0.5,
    crit = 0.1,
    toughness = 0,
    crit_damage = 1.5,
    dizziness_resistance = 0,
    sleep_resistance = 0,
    paralysis_resistance = 0,
    charm_resistance = 0.5,
    silence_resistance = 0.12,
    detained_resistance = 0.2011,
    ridicule_resistance = -1,
    plain = 0.05,
    mountain = 0.05,
    forest = 0.05,
    lake = -0.05,
    coastal = 0,
    cave = -0.1,
    wasteland = 0,
    citadel = 0.1,
    sunny = 0.05,
    rain = 0,
    cloudy = 0,
    snow = -0.05,
    fog = 0,
}

local skill = require('config.skill')
for k,v in pairs(skill) do
    if not v.condition then
        assert(v.distance)
        assert(v.calc)
        assert(v.goal)
        assert(v.lock)
        assert(v.target)
        assert(v.element_relative)
        assert(v.attack_count)
    end
end

local buff = require('config.buff')
for k,v in pairs(buff) do
    assert(v.feature)
    assert(v.overlap)
end

local props = require('config.props')
local hero_cfg = require('config.hero')
for k,v in pairs(hero_cfg) do
    for name,_ in pairs(hero_template) do
        assert(v[name])
    end
    
    for _,element in pairs(v.element_relative) do
        assert(element>=0 and element<=5)
    end
    
    assert(v.attack_range.min)
    assert(v.attack_range.max)
    
    assert(v.bringup_limit.strength)
    assert(v.bringup_limit.agility)
    assert(v.bringup_limit.intelligence)
    
    assert(skill[v.normal_attack])
    assert(skill[v.special_attack])
    
    if v.passive_skill then
        for _,passive_skill in pairs(v.passive_skill) do
            assert(skill[passive_skill])
        end
    end
    
    if v.upgrade then
        assert(v.superior)
        assert(hero_cfg[v.superior])
        assert(v.materials)
        for _,material in ipairs(v.materials) do
            assert(material.kind)
            assert(material.amount)
            assert(material.cost)
            assert(props[material.kind])
        end
    end
end

local monster = require('config.monster')
for k,v in pairs(monster) do
    for name,_ in pairs(monster_template) do
        assert(v[name])
    end
    
    for _,element in pairs(v.element_relative) do
        assert(element>=0 and element<=5)
    end
    
    assert(v.attack_range.min)
    assert(v.attack_range.max)
    
    assert(v.physical_attack.min)
    assert(v.physical_attack.max)
    
    assert(v.magical_attack.min)
    assert(v.magical_attack.max)
    
    assert(v.normal_attack==-1 or skill[v.normal_attack])
    assert(v.special_attack==-1 or skill[v.special_attack])
end
