require('data')
require('global_data')
require('tools.vector')

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local stage_award_cfgs = require('config.stage_award')

local achievement_cfgs = nil
local action2achivement = nil
local all_accomplished_achievements = data.GetAllAccomplishedAchievements()

function UpdateAchievement()
	local achievement_package = 'config.achievement'
	package.loaded[achievement_package] = nil
	achievement_cfgs = require(achievement_package)
	action2achivement = {}
	for id, arch in pairs(achievement_cfgs) do 
		if not action2achivement[arch.action] then
			action2achivement[arch.action] = {id}
		else
			table.insert(action2achivement[arch.action], id)
		end
		if not arch.kind then arch.kind=0 end
	end
end

UpdateAchievement()


function CreateAchievement(player)

	local obj = {}
	local processor_ = {}
	local db_processor_ = {}
	local accomplished_achievements_ = {}
	local actions_ = {}
    local stage_award = {}
	
	--function
	local function AccomplishAchievement(id, no_notify)
		if not accomplished_achievements_[id] then
			accomplished_achievements_[id] = os.time()
			player.InsertRow(C.ktAchievement, {C.kfID, id}, {C.kfTime, os.time()})
			if no_notify or achievement_cfgs[id].hide then return end
			local notify = new("AchievementAccomplished", id)
			player.Send2Gate(notify)
			if not vector.find(all_accomplished_achievements, id) then
				vector.push_back(all_accomplished_achievements, id)
				local first = new('AchievementFirstAccomplish', player.GetUID(), player.GetCNickname(), id)
				player.Send2Gate(first)
			end
		end
	end
	
	local function IsActionUsed(aid, kind)
		local archivements = action2achivement[aid]
		if archivements then
			for _,arch_id in ipairs(archivements) do 
				if achievement_cfgs[arch_id].kind==kind and not accomplished_achievements_[arch_id] then return true end  --该action有关联成就并且成就未完成
			end
		end
	end
	
	-- from player
	processor_[C.kGetAllAchievements] = function()
		local all_achievements = new('AllAchievements')
		for id,time in pairs(accomplished_achievements_) do 
			if not achievement_cfgs[id].hide then
				all_achievements.achievements[all_achievements.count] = {id, 0, achievement_cfgs[id].amount or achievement_cfgs[id].max_value, time}
				all_achievements.count = all_achievements.count+1
			end
		end
		for id,v in pairs(actions_) do  --加入未完成的成就, 从记录的action数据转换
			for kind,action in pairs(v) do 
				local ach_ids = action2achivement[id]
				if not ach_ids then break end
				for _,ach_id in ipairs(ach_ids) do 
					local ach = achievement_cfgs[ach_id]
					if ach.kind==kind then
						if ach.amount then  --需要的是总量
							if action.value and action.value>0 then
								local max_amount = achievement_cfgs[ach_id].amount
								if action.value>=max_amount then AccomplishAchievement(ach_id, true) end
								if not accomplished_achievements_[ach_id] then
									all_achievements.achievements[all_achievements.count] = {ach_id, 0, action.value>max_amount and max_amount or action.value, 0}
									all_achievements.count = all_achievements.count+1		
								end					
							end
						elseif ach.max_value then  --  需要的是最大值
							if action.max and action.max>0 and not accomplished_achievements_[ach_id] then 
								local max_value = achievement_cfgs[ach_id].max_value
								if  action.max>=max_value then 
									AccomplishAchievement(ach_id, true) 
									all_achievements.achievements[all_achievements.count] = {ach_id, 0, max_value, os.time()}
									all_achievements.count = all_achievements.count+1
								else 
									all_achievements.achievements[all_achievements.count] = {ach_id, 0, action.max, 0}
									all_achievements.count = all_achievements.count+1									
								end

							end
						end
					end
				end
			end
		end
		return all_achievements, 4+all_achievements.count*12
	end
    
    local function IsPassedStage(stage)
        for i=1,#stage_award_cfgs[stage] do
            if not accomplished_achievements_[ stage_award_cfgs[stage][i].achievement ] then return false end
        end
        return true
    end
    
    processor_[C.kGetStageAwardInfo] = function()
        
        local function GetStageStatus(stage, phase)
            
            if phase==0 then
                if IsPassedStage(stage) then
                    return ( stage_award[stage] and stage_award[stage][phase] ) and 2 or 1
                else
                    return 0
                end
            else
                if accomplished_achievements_[ stage_award_cfgs[stage][phase].achievement ] then
                    return ( stage_award[stage] and stage_award[stage][phase] ) and 2 or 1
                else
                    return 0
                end
            end
        end
        
        local stage_award_info = new('StageAwardInfo', 0)
        
        for stage,v in pairs(stage_award_cfgs) do
            for phase,cfg in pairs(v) do
                stage_award_info.list[stage_award_info.count].sid = cfg.sid
                stage_award_info.list[stage_award_info.count].stage = stage
                stage_award_info.list[stage_award_info.count].phase = phase
                stage_award_info.list[stage_award_info.count].status = GetStageStatus(stage, phase)
                stage_award_info.count = stage_award_info.count + 1
            end
        end
        
        return stage_award_info, 4 + stage_award_info.count * sizeof(stage_award_info.list[0])
    end

    processor_[C.kGetStageAward] = function(msg)
        local GetStageAward = cast("const GetStageAward&", msg)
        local stage = GetStageAward.stage
        local phase = GetStageAward.phase
        local result = new('StageAwardResult', C.eInvalidOperation)
        
        if stage_award_cfgs[stage] and stage_award_cfgs[stage][phase] then
            if phase==0 then
                if IsPassedStage(stage) and (not stage_award[stage] or not stage_award[stage][phase] ) then
                    result.result = C.eSucceeded
                end
            else
                if accomplished_achievements_[ stage_award_cfgs[stage][phase].achievement ] and (not stage_award[stage] or not stage_award[stage][phase] ) then
                    result.result = C.eSucceeded
                end
            end
        end
        
        if result.result == C.eSucceeded then
            player.InsertRow(C.ktStageAward, {C.kfStage, stage}, {C.kfPhase, phase})
            
            if not stage_award[stage] then stage_award[stage] = {} end
            stage_award[stage][phase] = true
            
            if stage_award_cfgs[stage][phase].reward_type==1 then
                player.ModifySilver(stage_award_cfgs[stage][phase].rewards)
            elseif stage_award_cfgs[stage][phase].reward_type==2 then
                player.AddGold(stage_award_cfgs[stage][phase].rewards)
            elseif stage_award_cfgs[stage][phase].reward_type==3 then
                player.ModifyPrestige(stage_award_cfgs[stage][phase].rewards)
            elseif stage_award_cfgs[stage][phase].reward_type==4 then
                player.ModifyFeat(stage_award_cfgs[stage][phase].rewards)
            elseif stage_award_cfgs[stage][phase].reward_type==5 then
                for _,reward in ipairs(stage_award_cfgs[stage][phase].rewards) do
                    player.ModifyProp(reward.kind, reward.amount)
                end
            else
                assert(false)
            end
        end
        
        return result
    end

-- from db
	db_processor_[C.kAccomplishedAchievements] = function(msg)
		local achievements = cast("const AccomplishedAchievements&",msg)
		for i=0,achievements.count-1 do 
			accomplished_achievements_[achievements.records[i].id] = achievements.records[i].time
			assert(achievements.records[i].time>0)
		end
	end
	
	db_processor_[C.kActions] = function(msg)
		local actions_db = cast('const Actions&', msg)
		for i=0, actions_db.count-1 do
			local record = actions_db.records[i]
			if not actions_[record.id] then actions_[record.id]={} end
			actions_[record.id][record.kind] = {value=record.value, max=record.max}
		end		
	end
    
	db_processor_[C.kStageAward] = function(msg)
		local stage_award_db = cast('const StageAward&', msg)
		for i=0, stage_award_db.count-1 do
			local stage = stage_award_db.list[i].stage
			local phase = stage_award_db.list[i].phase
			
			if not stage_award[stage] then stage_award[stage] = {} end
			stage_award[stage][phase] = true
		end
	end
	
	
	
	function obj.Record(aid, value, para) --动作的id以及关联的值,para为附加的参数，表示英雄、物品等的kind
		if value==0 then return end
		local kind = para or 0
		if not IsActionUsed(aid,kind) then return end
		
		if not actions_[aid] then actions_[aid]={} end
		if not actions_[aid][kind] then 
			actions_[aid][kind] = {value=value, max=value}
			player.InsertRow(C.ktAction, {C.kfID, aid}, {C.kfValue, value}, {C.kfMax, value}, {C.kfKind, kind})
		else
			local record = actions_[aid][kind]
			record.value = record.value+value
			if value>record.max then
				record.max=value 
				player.UpdateFieldWithSubIndex(C.ktAction, C.kfID, aid, C.kfKind, kind, {C.kfValue, record.value}, {C.kfMax, record.max})
			else 
				player.UpdateFieldWithSubIndex(C.ktAction, C.kfID, aid, C.kfKind, kind, {C.kfValue, record.value})
			end
			
		end
		
		--接下来看看是否有成就完成了
		local archivements = action2achivement[aid]
		if archivements then
			for _,arch_id in ipairs(archivements) do 
				local arch = achievement_cfgs[arch_id]
				if not accomplished_achievements_[arch_id] and arch.kind==kind then
					local action_record = actions_[aid][kind]
					if arch.amount and action_record.value>=arch.amount then AccomplishAchievement(arch_id) 
					elseif arch.max_value and action_record.max>=arch.max_value then AccomplishAchievement(arch_id) end
				end
			end
		end
	end
	
	function obj.ProcessMsgFromDb(type, msg)
		local func = db_processor_[type]
		if func then func(msg) end
	end

	function obj.ProcessMsg(type, msg)
		local func = processor_[type]
		if func then return func(msg) end
	end
	
	return obj
end


function RecordOfflinePlayerAction(player, aid, value, para)
--	assert(not data.IsPlayerOnline(player))
--	UpdateDeltaField(C.ktAction, C.kfID, )
	local p = data.GetOnlinePlayer(aid)
	if p then
		p.RecordAction(aid,value,para)
	else
--		UpdateDeltaFieldWithSubIndex(player, C.ktAction, C.kfID, aid, C.kfKind, para or 0, C.kfValue, value)
		UpdatePlayerAction(player, aid, para or 0, value, value)
	end
end