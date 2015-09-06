function CreateRecordManager(group_a, group_b, env, this)
    local obj = {}
    
    --初始化
    local record = {}
    
    --队伍信息
    record.teams = {}
    record.teams.teamLeft = {}
    record.teams.teamRight = {}
    
    record.teams.teamLeft.uid = 0
    record.teams.teamLeft.type = env.group_a.is_monster and "monster" or "player"
    record.teams.teamLeft.name = env.group_a.name
    
    record.teams.teamRight.uid = 1
    record.teams.teamRight.type = env.group_b.is_monster and "monster" or "player"
    record.teams.teamRight.name = env.group_b.name
    
    --竞技场、国战战斗等PVP战斗
    if env.type == 2 or env.type == 7 then
        record.teams.teamLeft.sex = env.group_a.sex
        record.teams.teamLeft.array = env.group_a.array
        record.teams.teamLeft.level = env.group_a.level
        
        record.teams.teamRight.sex = env.group_b.sex
        record.teams.teamRight.array = env.group_b.array
        record.teams.teamRight.level = env.group_b.level
        
        --国战还需要显示服务器名字
        if env.type == 7 then
            record.teams.teamLeft.server = env.group_a.server
            record.teams.teamRight.server = env.group_b.server
        end
    end
    
    --天气、地形
    record.battle = {}
    record.battle.terrain = env.terrain
    record.battle.weather = env.weather
    record.battle.type = env.type
    
    --战斗初始化状态
    record.winner = {}
    
    --战斗用到的资源
    record.res = {}
    record.res.fighters = {}
    
    --战斗逻辑
    record.actions = {}
    
    --搜集战斗资源
    local function CollectResource(group, team)
        for location,hero in pairs(group) do
            local fighter = {}
            fighter.sid = hero.id
            fighter.uid = hero.uid
            fighter.level = hero.level
            fighter.location = location
            fighter.hp = hero.life
            fighter.max_hp = hero.max_life
            fighter.mp = hero.momentum
            fighter.max_mp = hero.max_momentum
            fighter.team = team
            table.insert(record.res.fighters, fighter)
        end
    end
    CollectResource(group_a, 0)
    CollectResource(group_b, 1)
    
    --统计战斗技能
    local skills = {}
    local function CollectSkillResource(skill_id)
        skills[skill_id] = true
    end
    
    --统计战斗BUFF
    local buffs = {}
    local function CollectBuffResource(buff_id)
        buffs[buff_id] = true
    end
    
    --初始化一个回合的战报
    function obj.NewRound(round)
        table.insert(record.actions, {type='round', value=round})
    end
    
    --英雄出手一次一个Action
    local action = nil
    function obj.NewAction(fighter_id)
        action = {type='attack', fighter=fighter_id}
        table.insert(record.actions, action)
    end
    
    --设置使用的技能
    function obj.SetSkill(skill_id)
        action.skill = skill_id
        CollectSkillResource(skill_id)
    end
    
    --添加开始改变信息
    function obj.AppendBeforeChange(fighter_id, name, value)
        if not action.befores then action.befores = {} end
        
        table.insert(action.befores, {target=fighter_id, type=name, value=value})
    end
    
    --添加结束改变信息
    function obj.AppendAfterChange(fighter_id, name, value)
        if not action.afters then action.afters = {} end
        
        table.insert(action.afters, {target=fighter_id, type=name, value=value})
    end
    
    --添加反击信息
    local counter_hits = nil
    local counter_time = nil
    function obj.NewCounterAttack(fighter_id, target_id, skill_id)
        CollectSkillResource(skill_id)

        action.counters = {}
        
        counter_hits = {}
        counter_time = 0
        
        local attack = {fighter=fighter_id, target=target_id, skill=skill_id}
        attack.hits = counter_hits

        table.insert(action.counters, attack)
    end
   
    --添加反击属性
    function obj.AppendCounter(target_id, value, debug)
        counter_time = counter_time + 1
        local hit = {times=counter_time, type="comm"}
        hit.attrs = {{target=target_id, type="hp", value=value, debug=debug}}
        table.insert(counter_hits, hit)
    end
    
    --准备伤害目标
    function obj.NewActionAttacks(target, goals)
        action.attacks = {}
        
        for _, target_location in ipairs(target) do
            if not action.targets then
                action.targets = goals[target_location].uid
            else
                action.targets = action.targets .. "," .. goals[target_location].uid
            end
        end
        
    end
    
    --准备具体伤害
    local hits = nil
    local times = nil
    function obj.NewAttack(target_id)
        hits = {}
        times = 0
        table.insert(action.attacks, {hits=hits, target=target_id})
    end
    
    --准备具体打击
    local hit = nil
    function obj.NewAttackHits()
        times = times + 1
        hit = {times=times}
        table.insert(hits, hit)
    end
    
    --设置动作类型
    function obj.SetAttackType(type)
        hit.type = type
    end
    
    --添加伤害信息
    function obj.AppendActionHits(target_id, name, value, debug)
        if not hit.attrs then hit.attrs = {} end
        table.insert(hit.attrs, {target=target_id, type=name, value=value, debug=debug})
    end
    
    --添加一个buff
    function obj.NewBuff(target_id, buff_id, is_init)
        CollectBuffResource(buff_id)
        
        if is_init then
            if not record.inits then record.inits = {} end
            table.insert(record.inits, {target=target_id, type="new_buff", sid=buff_id})
        else
            obj.AppendActionHits(target_id, "new_buff", buff_id, nil)
        end
    end
    
    --添加一个buff效果
    function obj.NewBuffFeature(target_id, buff_id, name, value, debug)
        table.insert(record.actions, {type='new_buff', buff=buff_id, fighter=target_id, attrs={{target=target_id, type=name, value=value, debug=debug}}})
    end
    
    --删除一个buff效果
    function obj.DelBuffFeature(target_id, buff_id, is_expire)
        if is_expire then
            table.insert(record.actions, {type='del_buff', buff=buff_id, target=target_id})
        else
            obj.AppendActionHits(target_id, "del_buff", buff_id, nil)
        end
    end
    
    
    --设置胜利方
    function obj.SetWinner(team)
        record.winner.team = team
    end
    
    --获取战报
    function obj.GetRecord()
        record.res.skills = {}
        record.res.buffs = {}
        for skill_id in pairs(skills) do
            table.insert(record.res.skills, {sid=skill_id})
        end
        for buff_id in pairs(buffs) do
            table.insert(record.res.buffs, {sid=buff_id})
        end
        
        return record
    end
    
    return obj
end