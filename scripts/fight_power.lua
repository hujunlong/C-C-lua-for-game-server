--战斗力计算

module('fight_power', package.seeall)

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new

require('data')
require('global_data')

--计算玩家英雄战斗力
function GetHeroFightPower(p)
    local attack_power = (
            (p.physical_attack.max + p.physical_attack.min)/20 + 
            (p.magical_attack.max + p.magical_attack.min)/20 + 
            p.real_damage/10
        ) * (
            p.hit + p.magical_accurate + p.resistance + p.crit * p.crit_damage + p.counterattack + p.counterattack_damage/10
        )
    
    local defense_power = (
            (p.life)/20 + 
            (p.physical_defense + p.magical_defense)/7
        ) * (
            1 + p.dodge + p.resistance + p.toughness + p.parry + p.block * p.block_damage_reduction +
            (p.dizziness_resistance + p.sleep_resistance + p.paralysis_resistance + p.charm_resistance + p.silence_resistance + p.detained_resistance + p.ridicule_resistance)/7 +
            (p.plain + p.mountain + p.forest + p.lake + p.coastal + p.cave + p.wasteland + p.citadel)/8 +
            (p.sunny + p.rain + p.cloudy + p.snow + p.fog)/5
        )
    
    return math.ceil(attack_power + defense_power)
end

--获取玩家战斗力
function GetPlayerFightPower(player_id)
    local sum = 0
    
    local heros_group = data.GetPlayerHerosGroup(player_id)
    for _,hero_property in pairs(heros_group) do
        sum = sum + GetHeroFightPower(hero_property)
    end
    
    return sum
end

--战力缓存
local power_cache = {}

--初始化在线玩家缓存
function Initialize(player_id)
    power_cache[player_id] = GetPlayerFightPower(player_id)
    
    UpdateOtherField(C.ktMiscInfo, player_id, {C.kfFightPower, power_cache[player_id]})
end

--从缓存中获取战力
function GetCachedPower(player_id)
    if not power_cache[player_id] then Initialize(player_id) end
    return power_cache[player_id]
end

--通知玩家英雄战斗力变化【各个系统调用所用】
function CheckFightPowerChange(player_id)
    local power = GetPlayerFightPower(player_id)
    local delta = power - power_cache[player_id]
    if delta~=0 then
        power_cache[player_id] = power
        UpdateOtherField(C.ktMiscInfo, player_id, {C.kfFightPower, power_cache[player_id]})
        
        --通知总战力变化
        local player = data.GetOnlinePlayer(player_id)
        if player then
            local rscDelta = new('ResourceDelta', power, delta, C.kPowerRsc)
            player.Send2Gate(rscDelta)
        end
    end
end

--[[
这些系统可能影响战力

培养、装备强化、宝石镶嵌、属性转移、英雄升级、装备、科技升级、阵形更换、宝具
直接购买装备到英雄身上、军阶
]]