local reward_cft = require('config.assistant_activity')
local tasks_cfg	  = require('config.assistant_task')
local tasks_id_cfg= require('config.assistant_task_id')
local action_cft = require('define.action_id')
local props_cfg = require('config.props')
local gold_consume_flag = require('define.gold_consume_flag')


require('global_data')

local g_ = require('config.global')

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
--local copy = ffi.copy

local bit = require('bit')


--初始化
local online_players = {}
function InitAssistant( g_players )
	online_players = g_players
end


--重置
function ResetAssistant()
	--
	db.ResetAssistant()
	--
	--local reset_notify = new('NotifyResetAssistant')
	--local tmp_head   = new('MqHead', 0, C.kNotifyResetAssistant, -1)
	--
	for _, v_player in pairs( online_players ) do
		v_player.ResetAssistant()
		--tmp_head.aid = v_uid
		--C.Send2Gate(tmp_head, reset_notify, sizeof(reset_notify) )
	end
end

--CreateWaitableTimerForResetAction( action_type.reset_assistant, g_.assistant.kResetTime, ResetAssistant )


local function UpdateAssistantActivity( uid, activity, draw )
	UpdateField2( C.ktAssistant, C.kfPlayer, uid, 0, C.kInvalidID, {C.kfAssActivity, activity},{C.kfAssDraw, draw} )
end

local g_max_draw = #reward_cft

function CreateAssistant( player )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}

	----
	local player_id = player.GetUID()
	----

	local l_activity = 0
	local l_draw = 0
	local l_tasks = {}
	
	local function ModifyActivity( detla )
		if detla<1 then	return false	end
		l_activity = l_activity + detla
		UpdateAssistantActivity( player_id, l_activity, l_draw )
		local rscDelta = new('ResourceDelta', l_activity, detla, C.kActivityRsc)
		player.Send2Gate(rscDelta)
		return true
	end

	local function InnerActivityTask( task_id )
		if not task_id then return false end
		local task_cfg = tasks_cfg[task_id]
		if not task_cfg then return false end
		local task_info = l_tasks[task_id]
		if not task_info then
			l_tasks[task_id] = {}
			l_tasks[task_id].times = 0
			l_tasks[task_id].b_retrieve = 0
			l_tasks[task_id].times_back = 0
			l_tasks[task_id].remain_times = 0
		else
			return false
		end
		db.ModifyAssistantTask( player_id, task_id, 0, 0, 0, 0 )
	end
	
	local function InnerCompleteTask( task_id, remain_times )
		if not remain_times then remain_times=9 end
		if not task_id then return false end
		local task_cfg = tasks_cfg[task_id]
		if not task_cfg then return false end
		local task_info = l_tasks[task_id]
		if not task_info then
			l_tasks[task_id] = {}
			l_tasks[task_id].times = 1
			l_tasks[task_id].b_retrieve = 0
			l_tasks[task_id].times_back = 0
			l_tasks[task_id].remain_times = 0
			task_info = l_tasks[task_id]
		else
			task_info.times = task_info.times + 1
			task_info.remain_times = remain_times
		end
		if task_info.times<=task_cfg.amount then
			ModifyActivity( task_cfg.activity )
		end
		db.ModifyAssistantTask( player_id, task_id, task_info.times, task_info.b_retrieve, task_info.times_back, task_info.remain_times )
		return true
	end
	
	local function InnerSetRemainTimes( task_id, remain_times )
		if not task_id then return false end
		local task_cfg = tasks_cfg[task_id]
		if not task_cfg then return false end
		local task_info = l_tasks[task_id]
		if not task_info then
			return false
		else
			task_info.remain_times = remain_times
		end
		db.ModifyAssistantTask( player_id, task_id, task_info.times, task_info.b_retrieve, task_info.times_back, task_info.remain_times )
		return true
	end

	db_processor_[C.kUserEnterSucceeded] = function(msg)
		InnerCompleteTask( tasks_id_cfg.kLogin, 0 )
	end

	db_processor_[C.kInternalAssistantInfo] = function(msg)
		local info = cast("const InternalAssistantInfo&",msg)
		l_activity = info.activity
		l_draw = info.draw
		local task
		for i=1, info.amount do
			task = info.tasks[i-1]
			l_tasks[task.task_id] = {}
			l_tasks[task.task_id].times = task.times
			l_tasks[task.task_id].b_retrieve = task.b_retrieve
			l_tasks[task.task_id].times_back = task.times_back
			l_tasks[task.task_id].remain_times = task.remain_times
		end
	end

	--当重置之后,客户端应该立即再次发送获取
	processor_[C.kGetAssistantInfo] = function(msg)
		local ret = new("GetAssistantInfoResult")
		ret.activity = l_activity
		ret.draw = l_draw
		local amount = 0
		local task
		for task_id, v in pairs( l_tasks ) do
			task = tasks_cfg[task_id]
			if task then
				ret.tasks[amount].task_id = task_id
				if task.b_retrieve==1 and v.b_retrieve==1 and v.times_back==0 and v.remain_times>0 then
					ret.tasks[amount].b_retrieve = 1
				else
					ret.tasks[amount].b_retrieve = 0
				end
				ret.tasks[amount].times = v.times
				amount = amount + 1
			end
		end
		ret.amount = amount
		local bytes = 8 + sizeof(ret.tasks[0])*amount
		--
		return ret,bytes
	end

	processor_[C.kAssistantGetReward] = function(msg)
		local index = cast('const AssistantGetReward&',msg).index
		local ret = new("AssistantGetRewardResult",C.eInvalidValue)
		if index>=1 and index<=g_max_draw then
			local tmp_value = bit.lshift(1, index-1)
			if (bit.band(l_draw, tmp_value))==0 then
				local tmp_amount = 0
				local reward = reward_cft[index]
				if reward and l_activity>=reward.activity then
					if reward.reward then
						for _, v in ipairs( reward.reward ) do
							if v.type==2 then
								tmp_amount = tmp_amount + 1
							end
						end
						if tmp_amount<=player.BagUnoccupied() then
							for _, v in ipairs( reward.reward) do
								if v.type==1 then
									player.ModifySilver( v.detail)
								elseif v.type==2 then
									if not props_cfg[v.detail] then
										print('prop_kind:' .. v.detail .. ' not exist')
										return ret
									end
									player.ModifyProp( v.detail, 1)
								elseif v.type==3 then
									player.ModifyPrestige( v.detail )
								elseif v.type==4 then
									player.ModifyFeat( v.detail )
								end
							end
							l_draw = bit.bor(l_draw, tmp_value)
							UpdateAssistantActivity( player_id, l_activity, l_draw )
							ret.result = C.eSucceeded
						else
							ret.result = C.eBagLeackSpace
						end
					end
				end
			end
		end
		return ret
	end

	processor_[C.kRetrieveAssistantTask] = function(msg)
		local ret = new('RetrieveAssistantTaskResult')
		local task_id = cast('const RetrieveAssistantTask&',msg).task_id
		local task_cfg = tasks_cfg[task_id]
		local task_info = l_tasks[task_id]
		if not task_cfg or not task_info
			or task_cfg.b_retrieve==0
			or task_info.times<task_cfg.amount
			or task_info.b_retrieve==0
			or task_info.times_back~=0 
			or task_info.remain_times<1 then
				ret.result = C.eInvalidValue
				return ret
		end
		if player.IsGoldEnough( g_.assistant.kRetrieveTaskCostGold ) then
			player.ConsumeGold( g_.assistant.kRetrieveTaskCostGold, gold_consume_flag.assistant_retrieve )
			task_info.times = task_info.times_back
			task_info.b_retrieve = 0
			db.ModifyAssistantTask( player_id, task_id, task_info.times, 0, task_info.times_back, task_info.remain_times )
			ret.result = C.eSucceeded
		else
			ret.result = C.eLackResource
		end
		return ret
	end

	--完成任务
	function obj.CompleteTask( task_id, remain_times )
		return InnerCompleteTask( task_id, remain_times )
	end
	
	--激活任务
	function obj.ActivityTask( task_id )
		return InnerActivityTask( task_id )
	end
	
	--设置剩余次数
	function obj.SetRemainTimes( task_id, remain_times )
		InnerSetRemainTimes( task_id, remain_times )
	end

	function obj.ResetAssistant()
		l_activity = 0
		l_draw = 0
		for _, v in pairs( l_tasks ) do
			v.times_back = v.times
			v.b_retrieve = 1
			v.times = 0
			v.remain_times = 99
		end
	end

	function obj.ProcessMsgFromDb(type,msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsg(type,msg)
		local f = processor_[type]
		if f then return f(msg) end
	end

return obj
end

function AssistantActivityTask4Offline( uid, task_id )
	local player = online_players[uid]
	if player then
		return player.AssistantActivityTask( task_id )
	end
	if not task_id then return false end
	local task_cfg = tasks_cfg[task_id]
	if not task_cfg then return false end
	local task_info = db.GetAssistandTask(uid, task_id)
	if task_info then
		return false
	end
	db.ModifyAssistantTask( uid, task_id, 0, 0, 0, 0 )
	return true
end

function AssistantCompleteTask4Offline( uid, task_id, remain_times )
	local player = online_players[uid]
	if player then
		return player.AssistantCompleteTask( task_id, remain_times )
	end
	if not remain_times then remain_times=9 end
	if not task_id then return false end
	local task_cfg = tasks_cfg[task_id]
	if not task_cfg then return false end
	local task_info = db.GetAssistantTask(uid, task_id)
	if not task_info then
		task_info = {}
		task_info.times = 1
		task_info.b_retrieve = 0
		task_info.times_back = 0
		task_info.remain_times = 0
	else
		task_info.times = task_info.times + 1
		task_info.remain_times = remain_times
	end
	if task_info.times<=task_cfg.amount then
		local act_info = db.GetAssistantActivity( uid )
		if not act_info then return false end
		act_info.activity = act_info.activity + task_cfg.activity
		UpdateAssistantActivity( uid, act_info.activity, act_info.draw )
	end
	db.ModifyAssistantTask( uid, task_id, task_info.times, task_info.b_retrieve, task_info.times_back, task_info.remain_times )
	return true
end

function AssistantSetRemainTimes4Offline( uid, task_id, remain_times )
	local player = online_players[uid]
	if player then
		return player.AssistantSetRemainTimes( task_id, remain_times )
	end
	if not task_id then return false end
	local task_cfg = tasks_cfg[task_id]
	if not task_cfg then return false end
	local task_info = db.GetAssistantTask(uid, task_id)
	if not task_info then
		return false
	else
		task_info.remain_times = remain_times
	end
	db.ModifyAssistantTask( uid, task_id, task_info.times, task_info.b_retrieve, task_info.times_back, task_info.remain_times )
	return true
end