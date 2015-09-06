--[[

调用战斗系统

require('fight.fight_record')

local fight = CreateFight(group_a, group_b, env)

环境参数：
    env.type           战斗类型
        1 主线， 2 竞技场， 3 世界BOSS， 4 护送， 5 地图遇怪、支线， 6 公会战， 7 国战
        8 领地（野怪） 9 领地（和人打） 10 试炼塔
    
    env.weather 天气
    env.terrain 地形
    
    env.group_a = {
    env.group_b = {
        name        名称
        
        is_monster  = true
        
        array       阵形
        sex         性别
        level       等级
        
        group_damage_per 整个组的伤害加成（另外英雄身上还可以单独有damage_per和hurt_per）
    }

    env.round_limit    战斗回合数限制

    env.win_condition  回合数达到后的胜负判定
        1 防守方获胜
        2 双方死亡人数多少决定胜负
        3 伤害总量的高低决定胜负
        4 治疗总量的高低决定胜负
        
查询结果：
    local winner = fight.GetFightWinner()
    local record, record_len = fight.GetFightRecord()
    local cd = fight.GetFightCD()
    
    local statistics = fight.GetStatistics()
    statistics.group_a.life {dead死亡人数 alive存活人数 hits总伤害 heal总加血 life剩余血量百分比 total总人数}
    statistics.group_b.life {dead死亡人数 alive存活人数 hits总伤害 heal总加血 life剩余血量百分比 total总人数}
    statistics.round {回合数}
]]

local CheckFightArgs = require('fight.fight_check')

require('fight.fight_record')
require('fight.fight_statistic')
require('fight.fight_round')
require('fight.fight_action')
require('fight.fight_buff')
require('fight.fight_skill')

function CreateFight(group_a, group_b, env)
    local obj = {}
    
    --传入相关参数检测
    CheckFightArgs(group_a, group_b, env)
    
    --默认参数
    if not env.round_limit then
        env.round_limit = 20
        env.win_condition = 1
    end
    
    --初始化各种管理器
    local this = {}
    this.statistic_manager = CreateStatisticManager(group_a, group_b, env, this)
    this.round_manager = CreateRoundManager(group_a, group_b, env, this)
    this.record_manager = CreateRecordManager(group_a, group_b, env, this)
    this.action_manager = CreateActionManager(group_a, group_b, env, this)
    this.buff_manager = CreateBuffManager(group_a, group_b, env, this)
    this.skill_manager = CreateSkillManager(group_a, group_b, env, this)
    
    --战斗回合循环
    while not this.round_manager.IsFightFinish() do
        --战斗逻辑循环
        while true  do
            local fighter = this.round_manager.GetFighter()
            if fighter then
                this.action_manager.Action(fighter)
            else
                break
            end
        end
    end
    
    --获取胜利方 {winner, reason}
    function obj.GetFightWinner()
        return this.round_manager.GetResult()
    end
    
    --获取战斗CD {CD}
    function obj.GetFightCD()
        return this.action_manager.GetCD()
    end
    
    --获取战报 {record, record_len}
    function obj.GetFightRecord()
        local record, record_len = ConvertFightRecord(this.record_manager.GetRecord())
        return record, record_len
    end
    
    --获取统计信息 {A组统计, B组统计, 总回合数}
    function obj.GetStatistics()
        local _, _, round = this.round_manager.GetResult()
        return {group_a=this.statistic_manager.GetStatistic_a(), group_b=this.statistic_manager.GetStatistic_b(), round=round}
    end
    
    --
    this.record_manager.SetWinner(obj.GetFightWinner())
    
    return obj
end
