local skills_cfg = require('config.skill')

local GetTarget = require("fight.skill_target")
local FeatureFun = require("fight.skill_feature")
local ProduceDamage = require("fight.skill_calc")

local ROUND = require("fight.skill_round")
local action_names = {[ROUND.HIT]="comm", [ROUND.MISS]="miss", [ROUND.DODGE]="dodge", [ROUND.RESISTANCE]="resistance", [ROUND.PARRY]="parry", [ROUND.BLOCK]="block", [ROUND.CRIT]="crit"}

function CreateSkillManager(group_a, group_b, env, this)
    local obj = {}
    
    --执行被动技能
    function obj.ExecutePassiveSkill(fighter, skill_id)
        local skill = skills_cfg[skill_id]
        
        if not skill.condition then return end
        
        local can_execute = false
        if skill.condition==4 then
            --战斗开始触发
            can_execute = true
        elseif skill.condition==5 then
            --与水有关天气&地形
            if env.weather=='rain' or env.terrain=='lake' then
                can_execute = true
            end
        elseif skill.condition==6 then
            --晴天天气
            if env.weather=='sunny' then
                can_execute = true
            end
        elseif skill.condition==7 then
            --平原&城塞地形
            if env.terrain=='plain' or env.terrain=='citadel' then
                can_execute = true
            end
        end
        
        if not can_execute then return end
        
        --被动技能触发BUFF光环
        if skill.buff then
            if skill.goal==1 or skill.goal==2 then
                --友方 自己
                for _, target_location in ipairs(GetTarget(skill, fighter.location, fighter.friends)) do
                    this.buff_manager.InsertBuff(skill.buff, fighter, fighter.friends[target_location], true)
                end
            elseif skill.goal==3 then
                --敌方
                for _, target_location in ipairs(GetTarget(skill, fighter.location, fighter.enemies)) do
                    this.buff_manager.InsertBuff(skill.buff, fighter, fighter.enemies[target_location], true)
                end
            elseif skill.goal==4 then
                --全体
                assert(false)
            else
                assert(false)
            end
        end
    end
    
    --执行技能
    local function ExecuteSkill(fighter, goals, skill, skill_id, is_enemy)
        
        local target = GetTarget(skill, fighter.location, goals)
        this.record_manager.NewActionAttacks(target, goals)
        
        local hit = false
    
        for _, target_location in ipairs(target) do
            this.record_manager.NewAttack(goals[target_location].uid)
            if skill.calc then
                for _, attack_per in ipairs(skill.attack_count) do
                    this.record_manager.NewAttackHits()
                    
                    --攻击伤害计算
                    local self_records, target_records = FeatureFun[skill.calc](skill, fighter, goals[target_location], env)
                    
                    --有己方的变动
                    if self_records then
                        for name, value in pairs(self_records) do
                            if name=='life' then
                                this.action_manager.CalculateLife(value, attack_per, skill, fighter, fighter, false)
                            elseif name=='action' then
                                --this.record_manager.SetAttackType(action_names[value])
                            else
                                assert(false)
                                --this.action_manager.ParseState(skill_id, target, name, value, false)
                            end
                        end
                    end
                    
                    --有敌方的变动
                    if target_records then
                        for name, value in pairs(target_records) do
                            if name=='life' then
                                this.action_manager.CalculateLife(value, attack_per, skill, fighter, goals[target_location], true)
                            elseif name=='action' then
                                this.record_manager.SetAttackType(action_names[value])
                                
                                if value==ROUND.HIT or value==ROUND.BLOCK or value==ROUND.CRIT then
                                    hit = true
                                end
                            else
                                assert(false)
                                --this.action_manager.ParseState(skill_id, target, name, value, false)
                            end
                        end
                    end
                end
            end
            
            --追加buff
            if skill.buff then
                if not skill.calc or hit then
                    this.buff_manager.InsertBuff(skill.buff, fighter, goals[target_location], false)
                end
            end
            
            --反击
            if is_enemy and hit and #target==1 and goals[target_location].life>0 then
                if math.random()<goals[target_location].counterattack then
                    local target_skill = skills_cfg[goals[target_location].normal_attack]
                    if not target_skill.type then
                        if target_skill.calc=="physical_attack" then
                            target_skill.type = 1
                        elseif target_skill.calc=="magical_attack" then
                            target_skill.type = 2
                        end
                    end
                    
                    if target_skill.type then
                        this.record_manager.NewCounterAttack(goals[target_location].uid, fighter.uid, goals[target_location].normal_attack)
                        for _, attack_per in ipairs(target_skill.attack_count) do
                            local value = ProduceDamage(target_skill, goals[target_location], fighter, env) * goals[target_location].counterattack_damage
                            
                            value = this.action_manager.CalculateHurtEffect(value, attack_per, target_skill, goals[target_location], fighter, true)
                            
                            --取整(伤害为负数 用floor)
                            value = math.floor(value)
                            
                            fighter.life = fighter.life + value
                            
                            this.record_manager.AppendCounter(fighter.uid, value, fighter.life)
                            
                            fighter.life = math.max(fighter.life, 0)
                            
                            --目标死亡
                            if fighter.life == 0 then
                                fighter.Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
    
    --执行主动技能
    function obj.ExecuteInitiativeSkill(fighter, skill_id)
        local skill = skills_cfg[skill_id]
        if skill.goal==1 or skill.goal==2 then
            --友方 自己
            ExecuteSkill(fighter, fighter.friends, skill, skill_id, false)
        elseif skill.goal==3 then
            --敌方
            ExecuteSkill(fighter, fighter.enemies, skill, skill_id, true)
        elseif skill.goal==4 then
            --全体
            assert(false)
        else
            assert(false)
        end
    end
    
    --中毒
    function obj.ExecutePoisonBuff(fighter, buff_id)
        local _, target_records = FeatureFun["poisoning"](fighter.buffs[buff_id].overlap, fighter, fighter, env)
        
        local value = math.floor(target_records.life)
        fighter.life = fighter.life + value
        
        this.record_manager.NewBuffFeature(fighter.uid, buff_id, "hp", value, fighter.life)
        
        --伤害统计
        fighter.Statistic('hits', value)
        
        --目标死亡
        if fighter.life <= 0 then
            fighter.life = 0
            fighter.Destroy()
            return true
        end
        
        return false
    end
    
    --初始化
    local function Init(group)
        for _, hero in pairs(group) do
            if hero.passive_skill then
                for _,skill_id in ipairs(hero.passive_skill) do
                    obj.ExecutePassiveSkill(hero, skill_id)
                end
            end
        end
    end
    
    Init(group_a)
    Init(group_b)
    return obj
end