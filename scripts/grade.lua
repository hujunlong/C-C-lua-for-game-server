--军阶系统

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local cast = ffi.cast

--初始化英雄激活配置
local grade_cfg, heros_order = require('config.grade')[1],require('config.grade')[2]
local grade_reward = require('config.grade_reward')

local action_id = require('define.action_id')
local assistant_id = require('config.assistant_task_id')
require('data')
require('global_data')

require('fight_power')

function ResetGrade()
    for _,player in pairs(data.GetAllOnlinePlayer()) do
        player.ResetGradeReward()
    end
    data.ResetGradeReward()
end

local grade_level = {}
function GetGradeLevel(uid)
    if not grade_level[uid] and not data.GetOnlinePlayer(uid) then
        --读取数据库
        grade_level[uid] = data.GetGradeLevelFromDB(uid)
    end
    return grade_level[uid] or 0
end

--特殊军阶相关
local world_war_total = 0
local max_grade_level = 0
for i,v in ipairs(grade_cfg) do
    if not v.prestige then
        max_grade_level = i
        break
    end
end

function AdvancedGradeManager(AdvancedGrade)
    world_war_total = AdvancedGrade.total
    
    data.ResetAdvancedGrade()
    
    --重建
    local new_grade_level = {}
    for i=0,AdvancedGrade.count-1 do
        local uid = AdvancedGrade.list[i].uid
        local level = AdvancedGrade.list[i].level
        
        new_grade_level[uid] = level
        
        grade_level[uid] = level
        UpdateOtherField(C.ktGrade, uid, {C.kfLevel, level})
    end
    
    for uid in pairs(grade_level) do
        if not new_grade_level[uid] then
            grade_level[uid] = max_grade_level
        end
    end
    
    for uid,player in pairs(data.GetAllOnlinePlayer()) do
        player.SetGradeLevel(grade_level[uid])
    end
end
----------------------------------------------------------------------------------------

function GradeInteraction(player)
    local obj = {}
    
    --数据保存
    local this = {}
    this.activate = false         --是否激活
    
    --位运算相关
    local function to_bits(n)
        local tbl = {}
        local cnt = 1
        while (n > 0) do
            local last = math.mod(n,2)
            if(last == 1) then
                tbl[cnt] = 1
            else
                tbl[cnt] = 0
            end
                n = (n-last)/2
                cnt = cnt + 1
        end

        return tbl
    end

    local function tbl_to_number(tbl)
        --local n = table.getn(tbl)
        
        local n = 8
        for i = 1, n do
            if not tbl[i] then tbl[i] = 0 end
        end
        
        local rslt = 0
        local power = 1
        for i = 1, n do
            rslt = rslt + tbl[i]*power
            power = power*2
        end

        return rslt
    end

    --获取可以激活的英雄
    local function GetGradeHerosProgress(level, country)
        local progress = 0
        for i=1,level do
            local activation = grade_cfg[i].activation[country]
            if activation then
                progress = progress + #activation
            end
        end
        return progress
    end

    --逆转表
    local function rotate(...)
        local tbl = {}
        for k,v in ipairs(...) do tbl[v] =  k end
        return tbl
    end

    --获取激活英雄信息
    function obj.get_heros_status()
        if this.activate then
            local heros_status = {}
            
            local country = player.GetCountry()
            local hero_progress = GetGradeHerosProgress(this.info.level, country)
            for i=1,hero_progress do
                local hero_id = heros_order[country][i]
                heros_status[hero_id] = this.info.progress[i]==1
            end
            
            return heros_status
        end
    end

    function obj.get_hero_status(hero_id)
        if this.activate then
            local country = player.GetCountry()
            local progress = rotate(heros_order[country])[hero_id]
            if progress then
                return this.info.progress[progress]
            end
        end
    end
    
    -- 获取军阶等级
    function obj.get_grade_level()
        if this.info then
            return this.info.level or 0
        end
        return 0
    end
    
    --重设领奖
    function obj.ResetGradeReward()
        if this.info then
            this.info.reward = 1
        end
    end
    
    --激活军阶功能
    function obj.open()
        if not this.activate and player.GetCountry()~=0 then
            this.activate = true
            player.InsertRow(C.ktGrade, {C.kfLevel, 1})
            
            this.info = {}
            this.info.level = 1
            this.info.progress = to_bits(0)
            this.info.reward = 1
            
            fight_power.CheckFightPowerChange(player.GetUID())
            grade_level[player.GetUID()] = this.info.level
        end
    end
    
    --数据库消息处理
    local db_processor_ = {}
    db_processor_[C.kGradeInfo] = function(msg)
        local info = cast('const GradeInfo&', msg)
        this.info = {}
        this.info.level = info.level
        this.info.progress = to_bits(info.progress)
        this.info.reward = info.reward                --已经领奖为0，可以领奖为正数
        
        grade_level[player.GetUID()] = this.info.level
        
        this.activate = true
    end
    
    --客户端消息处理
    local processor_ = {}
    
    --获取军阶信息
    processor_[C.kGetGradeInfo] = function(msg)
        local result = new('GetGradeInfoReturn', 0)
        local result_length = nil
        
        if this.activate then
            result.result = C.eSucceeded
            result.prestige = player.GetPrestige()
            result.level = this.info.level
            result.count = 0
            
            local country = player.GetCountry()
            local hero_progress = GetGradeHerosProgress(this.info.level, country)
            for k,v in pairs(heros_order[country]) do
                local index = k - 1
                result.heros[index].hero_id = v
                if k>hero_progress then
                    --未开启
                    result.heros[index].status = 0
                else
                    if this.info.progress[k]==1 then
                        --已经激活
                        result.heros[index].status = 1
                    else
                        result.heros[index].status = 2
                    end
                end
                
                result.count = result.count + 1
            end
        else
            result.result = C.GRADE_NOT_ACTIVATE
            result_length = 4
        end
        return result, result_length
    end
    
    --领取军衔奖励
    processor_[C.kGetGradeReward] = function(msg)
        local result = new('GetGradeRewardReturn', 0)
        local result_length = 4
        
        if this.activate then
            --领取今日奖励
            if this.info.reward>0 then
                result.result = C.eSucceeded
                result.silver = grade_cfg[this.info.level].silver_ratio * grade_reward[player.GetLevel()].silver
                
                player.ModifySilver(result.silver)
                player.AssistantCompleteTask(assistant_id.kGradeReward, 0)
                
                this.info.reward = 0
                player.UpdateField(C.ktGrade, C.kInvalidID, {C.kfReward, this.info.reward})
                result_length = nil
            else
                result.result = C.GRADE_NOT_ENOUGH_REWARD
            end
        else
            result.result = C.GRADE_NOT_ACTIVATE
        end
        return result, result_length
    end
    
    --升级官职
    processor_[C.kElevateOfficial] = function(msg)
        --根据威望获取军阶等级
        local function CalcGradeLevel(prestige)
            local level = 0
            
            for i,v in ipairs(grade_cfg) do
                if not v.prestige then break end
                if prestige>=v.prestige then
                    if level<i then level = i end
                end
            end
            
            return level + 1
        end
        
        local result = new('ElevateOfficialReturn', 0)
        
        if this.activate then
            if CalcGradeLevel(player.GetPrestige()) > this.info.level then
                this.info.level = this.info.level + 1
                player.UpdateField(C.ktGrade, C.kInvalidID, {C.kfLevel, this.info.level})
                result.result = C.eSucceeded
                
                grade_level[player.GetUID()] = this.info.level
                
                if player.InTheWorldWar() then
                    PushPlayerChangedToWorldWar(player.GetUID(), 3, this.info.level)
                end
                
                fight_power.CheckFightPowerChange(player.GetUID())
                player.RecordAction(action_id.kGradeLevel, this.info.level)
            else
                result.result = C.GRADE_CANT_UPGRADE_LEVEL
            end
        else
            result.result = C.GRADE_NOT_ACTIVATE
        end
        return result
    end
    
    --激活国家英雄
    processor_[C.kActivateHeros] = function(msg)
        local hero = cast('const ActivateHeros&', msg).hero_id
        local result = new('ActivateHerosReturn', 0)
        
        if this.activate then
            local country = player.GetCountry()
            local hero_progress = GetGradeHerosProgress(this.info.level, country)
            local progress = rotate(heros_order[country])[hero]
            if progress and progress<=hero_progress then
                if not this.info.progress[progress] or this.info.progress[progress]==0 then
                    this.info.progress[progress] = 1
                    
                    player.UpdateField(C.ktGrade, C.kInvalidID, {C.kfProgress, tbl_to_number(this.info.progress)})
                    result.result = C.eSucceeded
                else
                    result.result = C.GRADE_HAVE_ACTIVATE_HERO
                end
            else
                result.result = C.GRADE_CANT_ACTIVATE_HERO
            end
        else
            result.result = C.GRADE_NOT_ACTIVATE
        end
        return result
    end
    
    --外部自动调用的接口
    function obj.ProcessMsgFromDb(type, msg)
        local func = db_processor_[type]
        if func then func(msg) end
    end
    function obj.ProcessMsg(type, msg)
        local func = processor_[type]
        if func then
            return func(msg)
        end
    end

    function obj.CanGetReward()
        if not this.activate then return 0 end
        return this.info.reward>0 and 1 or 0
    end
    
    function obj.SetGradeLevel(level)
        --检查军阶是否变动
        if this.activate and this.info.level~=level then
            this.info.level = level
            
            local result = new('GradeChange')
            result.level = this.info.level
            player.Send2Gate(result)
            
            if player.InTheWorldWar() then
                PushPlayerChangedToWorldWar(player.GetUID(), 3, this.info.level)
            end
            
            fight_power.CheckFightPowerChange(player.GetUID())
        end
    end
    
    return obj
end