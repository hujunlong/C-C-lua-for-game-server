--战斗目标

--获取攻击序列（获取到的结果是序号 2 5 8 , 1 4 7 , 3 6 9）
local function GetAttackArray(position)
    --构造攻击顺序
    local row = (position-1)%3 + 1
    if row==1 then return {1,4,7,2,5,8,3,6,9} end
    if row==2 then return {2,5,8,1,4,7,3,6,9} end
    if row==3 then return {3,6,9,2,5,8,1,4,7} end
    assert(false)
end

--获取攻击序列，后方优先（逆序）
local function GetAttackArrayRev(position)
    local queue = GetAttackArray(position)
    for i=1,9,3 do
        queue[i+2], queue[i] = queue[i], queue[i+2]
    end
    return queue
end

local AttackDirection = {GetAttackArray, GetAttackArrayRev}
local function GetLockArray(location, goals, is_front)
    for _,position in pairs(AttackDirection[is_front](location)) do
        if goals[position] and goals[position].CanBeAttack() then
            return position
        end
    end
    return 0
end

local function LockFromFront(fighter_location, goals)
    return GetLockArray(fighter_location, goals, 1)
end

local function LockFromBack(fighter_location, goals)
    return GetLockArray(fighter_location, goals, 2)
end

local function LockSelf(fighter_location, goals)
    return fighter_location
end

local function LockLifeLower(fighter_location, goals)
    local life_min = 0
    local position = nil
    for location,target in pairs(goals) do
        if target.CanBeAttack() then
            local life_per = target.GetProperty('life')/target.GetProperty('max_life')
            if life_min==0 or life_per<life_min then
                life_min = life_per
                position = location
            end
        end
    end
    return position
end

local function LockLifeHigher(fighter_location, goals)
    local life_max = 0
    local position = nil
    for location,target in pairs(goals) do
        if target.CanBeAttack() then
            local life_per = target.GetProperty('life')/target.GetProperty('max_life')
            if life_per>life_max then
                life_max = life_per
                position = location
            end
        end
    end
    return position
end

local function LockSpeedLower(fighter_location, goals)
    local speed_min = 0
    local position = nil
    for location,target in pairs(goals) do
        if target.CanBeAttack() then
            if speed_min==0 or target.GetProperty('speed')<speed_min then
                speed_min = target.GetProperty('speed')
                position = location
            end
        end
    end
    return position
end

local function LockSpeedHigher(fighter_location, goals)
    local speed_max = 0
    local position = nil
    for location,target in pairs(goals) do
        if target.CanBeAttack() then
            if target.GetProperty('speed')>speed_max then
                speed_max = target.GetProperty('speed')
                position = location
            end
        end
    end
    return position
end

local function UnLock(fighter_location, goals)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

--单体攻击
local function MonoAttackTarget(lock_target, goals)
    return {lock_target}
end

--全体攻击
local function WholeAttackTarget(lock_target, goals)
    local targets = {}
    for position,fighter in pairs(goals) do
        if fighter.CanBeAttack() then
            table.insert(targets, position)
        end
    end
    return targets
end

--随机
local function RandomTable(t, n)
    local ret = {}
    if #t<n then n = #t end

    for _=1,n do
        r = math.random(#t)
        table.insert(ret, table.remove(t, r))
    end
    return ret
end

--随机个数
local function RandomAttackTarget1(lock_target, goals, target_args)
    return RandomTable(WholeAttackTarget(lock_target, goals), target_args)
end

--随机范围
local function RandomAttackTarget2(lock_target, goals, target_args)
    return RandomTable(WholeAttackTarget(lock_target, goals), math.random(target_args[1], target_args[2]))
end

--横排（从玩家的角度）
local function VerticalAttackTarget(lock_target, goals)
    local targets = {}

    while (lock_target-1)%3~=0 do
        lock_target = lock_target - 1
    end

    for _ = 1, 3 do
        if goals[lock_target] and goals[lock_target].CanBeAttack() then table.insert(targets, lock_target) end
        lock_target = lock_target + 1
    end

    return targets
end

--贯通攻击
local function GetThrough(lock_target, goals, number, lock)
    local targets = {}

    table.insert(targets, lock_target)
    
    if lock==2 then
        for _ = 2,number do
            lock_target = lock_target - 3
            if goals[lock_target] and goals[lock_target].CanBeAttack() then table.insert(targets, lock_target) end
        end
    else
        for _ = 2,number do
            lock_target = lock_target + 3
            if goals[lock_target] and goals[lock_target].CanBeAttack() then table.insert(targets, lock_target) end
        end
    end

    return targets
end

--贯通2个
local function ThroughAttackTarget(lock_target, goals, lock)
    return GetThrough(lock_target, goals, 2, lock)
end

--竖排（贯通全部）
local function HorizontalAttackTarget(lock_target, goals, lock)
    return GetThrough(lock_target, goals, 3, lock)
end

--十字（爆炸）
local function CrossAttackTarget(lock_target, goals)
    local targets = {}

    if goals[lock_target] and goals[lock_target].CanBeAttack() then table.insert(targets, lock_target) end
    if goals[lock_target+1] and goals[lock_target+1].CanBeAttack() then table.insert(targets, lock_target+1) end
    if goals[lock_target-1] and goals[lock_target-1].CanBeAttack() then table.insert(targets, lock_target-1) end
    if goals[lock_target+3] and goals[lock_target+3].CanBeAttack() then table.insert(targets, lock_target+3) end
    if goals[lock_target-3] and goals[lock_target-3].CanBeAttack() then table.insert(targets, lock_target-3) end

    return targets
end

--寻找指定种族
local function FindAppointRace(lock_target, goals, target_args)
    local targets = {}
    for position,fighter in pairs(goals) do
        if fighter.race==target_args and fighter.CanBeAttack() then
            table.insert(targets, position)
        end
    end
    
    return targets
end

---------------------------------------------------------------------------
--取锁定目标
--传入锁定参数，返回目标链表

local function GetTarget(skill, fighter_location, goals)
    if skill.goal==1 then
        local targets = {}
        table.insert(targets, fighter_location)
        return targets
    end

    --内置函数表
    local lock_function = {LockFromFront, LockFromBack, LockSelf, LockLifeLower, LockLifeHigher, LockSpeedLower, LockSpeedHigher, UnLock}
    local target_function = {MonoAttackTarget, RandomAttackTarget1, RandomAttackTarget2, VerticalAttackTarget, ThroughAttackTarget, HorizontalAttackTarget, CrossAttackTarget, WholeAttackTarget, FindAppointRace}

    local lock_target = lock_function[skill.lock](fighter_location, goals)
    
    --如果没找到锁定目标
    if lock_target==0 then return {} end

    return target_function[skill.target](lock_target, goals, skill.target_arg, skill.lock)
end

return GetTarget

