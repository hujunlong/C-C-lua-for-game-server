function CreateActionManager(group_a, group_b, env, this)
    local obj = {}
    
    local cd = 0
    
    --检查英雄状态
    local function InTheState(t)
        return t and next(t)
    end

    --获取战斗距离，结果应该是 1 - 5
    local distance = {1,1,1,2,2,2,3,3,3}
    local function GetDistance(position1,position2)
        return distance[position1] + distance[position2] - 1
    end
    
    --消除一回合buff
    local function ClearBuff(hero)
        for id, buff in pairs(hero.buffs) do
            if buff.turn>0 then
                buff.turn = buff.turn - 1
            end
            
            if buff.turn==0 then
                this.buff_manager.RemoveBuff(hero, id, true)
            end
        end
    end
    
    --气槽恢复（普通攻击一回合）
    local function RestoreMomentum(hero)
        if hero.life~=0 and hero.momentum_type~=0 then
            local restore_momentum = nil
            if hero.momentum_type==1 then
                --怒气
                restore_momentum = 25
            elseif hero.momentum_type==2 then
                --能量
                restore_momentum = 25
            elseif hero.momentum_type==3 then
                --魔法
                restore_momentum = 35
            else
                assert(false)
            end
            
            restore_momentum = math.min(hero.max_momentum - hero.momentum, restore_momentum)
            if restore_momentum~=0 then
                hero.momentum = hero.momentum + restore_momentum
                this.record_manager.AppendAfterChange(hero.uid, 'mp', restore_momentum)
            end
        end
    end
    
    --英雄行为逻辑
    function obj.Action(fighter)
        --眩晕状态、瘫痪状态、睡眠状态 中不能行动
        if InTheState(fighter.states.dizziness) or InTheState(fighter.states.paralysis) or InTheState(fighter.states.sleep) then
            RestoreMomentum(fighter)
            ClearBuff(fighter)
            return
        end
        
        --每回合回血
        if fighter.states.add_life_per then
            for id, value in pairs(fighter.states.add_life_per) do
                local add_life = math.ceil(fighter.max_life * value)
                
                fighter.Statistic('heal', add_life)
                
                fighter.life = math.min(fighter.max_life, fighter.life + add_life)
                
                this.record_manager.NewBuffFeature(fighter.uid, id, "hp", add_life, fighter.life)
            end
        end
        
        --处于中毒状态
        if fighter.states.poison then
            for id in pairs(fighter.states.poison) do
                --如果毒死直接跳出
                if this.skill_manager.ExecutePoisonBuff(fighter, id) then return end
            end
        end
        
        --出手一次增加0.4秒CD
        cd = cd + 0.4
        
        this.record_manager.NewAction(fighter.uid)
        
        --检查气槽值是否大于100
        if fighter.momentum>=100 then
            --特殊攻击
            this.record_manager.SetSkill(fighter.special_attack)
            
            this.record_manager.AppendBeforeChange(fighter.uid, 'mp', -fighter.momentum)
            fighter.momentum = 0
            
            
            this.skill_manager.ExecuteInitiativeSkill(fighter, fighter.special_attack)
        else
            --普通攻击
            this.record_manager.SetSkill(fighter.normal_attack)
            
            this.skill_manager.ExecuteInitiativeSkill(fighter, fighter.normal_attack)
            RestoreMomentum(fighter)
        end
        
        ClearBuff(fighter)
    end
    
    --获取战斗CD
    function obj.GetCD()
        return cd
    end
    
    --伤害加成效果
    function obj.CalculateHurtEffect(value, addition, skill, fighter, target, is_enemy)
        
        --世界BOSS只使用真实伤害
        if fighter.world_boss then
            return -fighter.real_damage
        end
        
        value = value * (
         1
         + (fighter.momentum_per or 0 )             --攻击方气槽攻击提升百分比
         + (fighter.group_damage_per or 0 )         --整个组的伤害加成（公会战、世界BOSS等可用）
         + (fighter.damage_per or 0 )               --攻击方单个英雄的伤害加成（阵形）
         + (target.hurt_per or 0)                   --被攻击方单个英雄的受伤加成（阵形）
         + (target.states.weakness_per or 0 )       --被攻击方虚弱状态百分比 
         + (target.states.behurt_effect_per or 0 )  --被攻击方伤害效果加倍(晴天下索尼娅将额外受到5%的伤害)
        )
        * addition --技能伤害百分比
        
        --攻击距离校正
        if is_enemy then
            local dist = GetDistance(fighter.location, target.location)
            if fighter.attack_range.min > dist or fighter.attack_range.max < dist then
                value = value * 0.8
            end
        end
        
        --物理近战压制
        if fighter.states.physical_hits_debases and skill.type==1 then
            for _,physical_hits_debases_per in pairs(fighter.states.physical_hits_debases) do
                if physical_hits_debases_per>0 then
                    value = value * ( 1 - physical_hits_debases_per )
                    break
                end
            end
        end
        
        --真实攻击加成
        value = value - fighter.real_damage
        
        return value
    end
    
    --血量的最终计算
    function obj.CalculateLife(value, addition, skill, fighter, target, is_enemy)
        if value < 0 then
            --减血计算
            value = obj.CalculateHurtEffect(value, addition, skill, fighter, target, is_enemy)
            
            --取整(伤害为负数 用floor)
            value = math.floor(value)
            
            --伤害统计
            fighter.Statistic('hits', value)
        else
            --加血计算
            value = value * (
                1
                + (fighter.momentum_per or 0)
                + (target.states.heal_life_effect_per or 0)
                )

            --取整(治疗为正数 用ceil)
            value = math.ceil(value)
            
            --治疗统计
            fighter.Statistic('heal', value)
        end
        
        target.life = target.life + value
        
        this.record_manager.AppendActionHits(target.uid, "hp", value, target.life)
        
        --挨打
        if value < 0 then
            
            --挨打时气槽上涨
            if target.momentum_type~=0 then
                local restore_momentum = 25
                if target.momentum_type==1 then
                    --怒气
                    restore_momentum = 30
                end
                
                restore_momentum = math.min(restore_momentum, target.max_momentum - target.momentum)
                if restore_momentum~=0 then
                    target.momentum = target.momentum + restore_momentum
                    this.record_manager.AppendActionHits(target.uid, "mp", restore_momentum)
                end
            end
            
            --睡眠被打醒
            if target.states.sleep then
                for id in pairs(target.states.sleep) do
                    this.buff_manager.RemoveBuff(target, id, false)
                end
            end
            
            --攻击方吸血
            if fighter.states.vampire_per then
                local heal = math.ceil(-value * fighter.states.vampire_per)
                fighter.life = math.min(fighter.life + heal, fighter.max_life)
                
                fighter.Statistic('heal', heal)
                this.record_manager.AppendActionHits(fighter.uid, "hp", heal, fighter.life)
            end
            
            --攻击方嗜血
            if fighter.states.sanguinary_per then
                local heal = math.ceil(fighter.life * fighter.states.sanguinary_per)
                fighter.life = math.min(fighter.life + heal, fighter.max_life)
                
                fighter.Statistic('heal', heal)
                this.record_manager.AppendActionHits(fighter.uid, "hp", heal, fighter.life)
            end
        end
        
        --加血超过上限
        target.life = math.min(target.life, target.max_life)
        target.life = math.max(target.life, 0)
        
        --目标死亡
        if target.life == 0 then
            target.Destroy()
        end
    end
    
    --状态解析
    function obj.ParseState(id, target, name, value, delete)
        
        local function SetStateProperty()
            if not target.states[name] then target.states[name] = 0 end
            if delete then
                target.states[name] = target.states[name] - value
            else
                target.states[name] = target.states[name] + value
            end
        end
        
        local function SetState()
            if not target.states[name] then target.states[name] = {} end
            if delete then
                target.states[name][id] = nil
            else
                target.states[name][id] = value
            end
        end
        
        --修改基础属性
        if target[name] or target[name.."_per"] then
            return SetStateProperty()
        else
            local i, j = string.find(name, "state_")
            if i==1 and j==6 then
                name = string.sub(name, 7)
                
                if name=="add_life_per" or name=="dizziness" or name=="sleep" or name=="paralysis" or name=="physical_hits_debases" then
                    return SetState()
                else
                    return SetStateProperty()
                end
            else
                assert(false)
            end
        end
        
    end
    
    return obj
end