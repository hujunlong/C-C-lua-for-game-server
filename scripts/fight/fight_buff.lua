local buffs_cfg = require('config.buff')

function CreateBuffManager(group_a, group_b, env, this)
    local obj = {}
    
    --添加buff
    function obj.InsertBuff(skill_buffs, fighter, target, is_init)
        for _,skill_buff in pairs(skill_buffs) do
            local buff_id = skill_buff.id
            local buff = buffs_cfg[buff_id]
            
            --如果buff能够被抵抗，查看对方抗性
            local probability = skill_buff.probability
            if buff.type then
                --抗性
                local resistance = target[buff.type.."_resistance"]
                
                --免疫
                if resistance == -1 then
                    probability = -1
                else
                    probability = probability - resistance
                end
            end
            
            if math.random()<probability then
                if not target.buffs[buff_id] then
                    --新加buff
                    target.buffs[buff_id] = {}
                    target.buffs[buff_id].turn = skill_buff.turn
                    target.buffs[buff_id].overlap = 1
                    
                    --光环类buff
                    if is_init then
                        target.buffs[buff_id].halo = fighter.uid
                    end
                    
                    this.record_manager.NewBuff(target.uid, buff_id, is_init)
                else
                    --追加buff计数
                    target.buffs[buff_id].turn = math.min(target.buffs[buff_id].turn, skill_buff.turn)
                    
                    --叠加上限
                    target.buffs[buff_id].overlap = math.min(target.buffs[buff_id].overlap + 1, buff.overlap)
                end
                
                --解析buff状态
                for name, value in pairs(buff.feature) do
                    this.action_manager.ParseState(buff_id, target, name, value, false)
                end
            end
        end
    end
    
    --清除Buff
    function obj.RemoveBuff(hero, buff_id, is_expire)
        local buff = buffs_cfg[buff_id]
        for name, value in pairs(buff.feature) do
            this.action_manager.ParseState(buff_id, hero, name, value, true)
        end
        
        hero.buffs[buff_id] = nil
        
        this.record_manager.DelBuffFeature(hero.uid, buff_id, is_expire)
    end
    
    --检查Buff是否可以清除
    function obj.ClearHalo(fighter_id)
        local function CheckGroupHalo(group)
            for _, hero in pairs(group) do
                if hero.life~=0 then
                    for buff_id, buff in pairs(hero.buffs) do
                        if buff.halo==fighter_id then obj.RemoveBuff(hero, buff_id, false) end
                    end
                end
            end
        end
        
        CheckGroupHalo(group_a)
        CheckGroupHalo(group_b)
    end
    
    return obj
end