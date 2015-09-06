require('global_data')
local global_ = require('config.global')
local reward_ = require('config.turntable')
local cost_ = require('config.turntable_cost')
local ratio_ = require('config.turntable_ratio')

local action_ = require('define.action_id')
local tasks_ = require('config.assistant_task_id')

local gold_consume_flag = require('define.gold_consume_flag')

require('global_data')

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local bit = require('bit')


--初始化
local online_players = {}
function InitTurntable( players )
	online_players = players
end



--重置转轮
function ResetTurntable()
	db.ResetTurntableInfo( global_.turntable.kTimesEveryDay )
	--
	--local push = new('ResetTurntableInfo')
	for v_uid, v_player in pairs( online_players ) do
		if v_player.ResetPlayground( 1 ) then
			--GlobalSend2Gate(v_uid, push )
		end
	end
end

--CreateWaitableTimerForResetAction( action_type.reset_turn, global_.turntable.kResetTime, ResetTurntable )


function CreateTurntable( player )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local active_ = false
	local turntable_ = {}
	local name_ = player.GetCNickname()
	local uid_ = player.GetUID()
	
	local function UpdateTurntable()
		player.UpdateField(C.ktTurntable,C.kInvalidID,
			{C.kfTurnReTimes,turntable_.re_times},{C.kfTurnCurPoint,turntable_.cur_point},
			{C.kfTurnResult,turntable_.result},{C.kfTurnShouldReturn,turntable_.should_return})
	end
	
	local function UpdateTimes()
		player.UpdateField(C.ktTurntable,C.kInvalidID,{C.kfTurnTimes,turntable_.times})
	end
	
	local function UpdateReTimes()
		player.UpdateField(C.ktTurntable,C.kInvalidID,{C.kfTurnReTimes,turntable_.re_times})
	end
	
	local function UpdateTurnResult()
		player.UpdateField(C.ktTurntable,C.kInvalidID,
			{C.kfTurnCurPoint,turntable_.cur_point},{C.kfTurnResult,turntable_.result},
			{C.kfTurnShouldReturn,turntable_.should_return})
	end
	
	local function RestartTurntable()
		turntable_.result = 0
		turntable_.results = {0,0,0,0,0,0,0,0}
		turntable_.cells = -2
		turntable_.turn_times = 0
		turntable_.should_return = 0
		
		local t = { 1, 2, 3, 4, 5, 6, 7, 8 }
		local pos = 0
		local cur_point = 0
		for i=1,2 do
			pos = math.random(1,#t)
			cur_point = t[pos]
			turntable_.results[cur_point] = 1
			turntable_.result = bit.bor(turntable_.result, bit.lshift(1,cur_point-1))
			turntable_.cells = turntable_.cells+1
			turntable_.cur_point = cur_point
			table.remove(t, pos)
		end
		UpdateTurntable()
	end
	
	local function TurnTurntable()
		local point = 0
		point = math.random(1,8)
		turntable_.cur_point = point
		if turntable_.results[point]==1 then
			turntable_.should_return = 1
		else
			turntable_.should_return = 0
			turntable_.results[point] = 1
			turntable_.result = bit.bor(turntable_.result, bit.lshift(1,point-1))
			turntable_.cells = turntable_.cells+1
		end
		UpdateTurnResult()
	end
	
	processor_[C.kGetTurntableInfo] = function()
		local result = new('GetTurntableInfoResult')
		if not active_ then result.result = C.TURNTABLE_DISABLE return result end
		result.result = C.TURNTABLE_SUCCEEDED
		result.results = turntable_.result
		result.re_times = turntable_.re_times
		result.cur_point = turntable_.cur_point
		result.times = turntable_.times
		result.should_return = turntable_.should_return
		return result
	end
	
	processor_[C.kTurnTurntable] = function()
		local result = new("TurnTurntableResult")
		if not active_ then result.result = C.TURNTABLE_DISABLE return result end
		result.result = C.TURNTABLE_SUCCEEDED
		if turntable_.turn_times==0 then
			if turntable_.times<=0 then
				result.result = C.TURNTABLE_NO_TIMES
				return result
			end
			turntable_.times = turntable_.times-1
			UpdateTimes()
			--小助手
			player.AssistantCompleteTask( tasks_.kTurntable, turntable_.times )
		elseif turntable_.cells>=6 then
			result.result = C.TURNTABLE_SHOULD_GET_REWARD
			return result
		end
		
		if turntable_.should_return==0 then		--正常
			TurnTurntable()
			turntable_.turn_times = turntable_.turn_times + 1
		elseif turntable_.should_return==1 then	--重转
			local cost = -1
			if cost_[turntable_.re_times+1] then
				cost = cost_[turntable_.re_times+1].cost
			else
				cost = cost_[#cost_].cost
			end
			if player.IsGoldEnough(cost) then
				player.ConsumeGold(cost, gold_consume_flag.turntable_return)
				TurnTurntable()
				turntable_.re_times = turntable_.re_times+1
				UpdateReTimes()
			else
				result.result = C.TURNTABLE_GOLD_NOT_ENOUGH
			end
		end
		if turntable_.cells>=6 then
			--成就
			player.RecordAction( action_.kTurntableMaxReward, 1, nil )
			--全服通告
			local push = new("TurntableMaxReward")
			push.uid = uid_
			copy(push.name,name_,sizeof(name_))
			GlobalSend2Gate(-1, push)
		end
		result.results = turntable_.result
		result.cur_point = turntable_.cur_point
		return result
	end
	
	processor_[C.kGetRewardTurntable] = function()
		local result = new("GetRewardTurntableResult",C.TURNTABLE_SUCCEEDED)
		if not active_ then result.result = C.TURNTABLE_DISABLE return result end
		local amount = 0
		local build_level = player.GetBuildingLevel(global_.town.kPlaygroundKind)
		if build_level and build_level>0 then
			local ratio = ratio_[build_level].ratio
			if not ratio then ratio=ratio_[#ratio_].ratio end
			if turntable_.turn_times==1 and turntable_.should_return==1 then
				amount = math.ceil(reward_[1].amount*ratio)
				result.amount = amount
				player.ModifyFeat( amount )
				--
				RestartTurntable()
			elseif turntable_.cells>0 then
				amount = math.ceil(reward_[turntable_.cells+1].amount*ratio)
				result.amount = amount
				player.ModifyFeat( amount )
				--
				RestartTurntable()
			else
				result.result = C.TURNTABLE_INVALIDOPERATION
			end
		else
			result.result = C.TURNTABLE_INVALIDOPERATION
		end
		return result
	end
	
	db_processor_[C.kInternalTurntableInfo] = function(msg)
		active_ = true
		local info = cast("const InternalTurntableInfo&",msg)
		turntable_.result = info.result
		turntable_.re_times = info.re_times
		turntable_.times = info.times
		turntable_.turn_times = -2
		turntable_.cur_point = info.cur_point
		turntable_.should_return = info.should_return
		turntable_.results = {}
		turntable_.cells = -2
		
		local tmp_val = turntable_.result
		for i=1,8 do
			turntable_.results[i] = bit.band( tmp_val, 1 )
			if turntable_.results[i]==1 then 
				turntable_.turn_times=turntable_.turn_times+1
				turntable_.cells = turntable_.cells+1
			end
			tmp_val = bit.rshift(tmp_val,1)
		end
		if turntable_.turn_times==0 and turntable_.should_return==1 then
			turntable_.turn_times = 1
		end
	end
	
	function obj.ModifyTimes(times)
		if active_ then
			turntable_.times = turntable_.times+times
			if turntable_.times<0 then
				turntable_.times=0
			elseif turntable_.times>255 then
				turntable_.times=255
			end
			UpdateTimes()
			return true
		else
			return false
		end
	end
	
	function obj.ActivateTurntable()
		if not active_ then
			turntable_.times = global_.turntable.kTimesEveryDay
			turntable_.re_times = 0
			player.InsertRow(C.ktTurntable,{C.kfTurnTimes,turntable_.times},{C.kfTurnReTimes,0},
								{C.kfTurnCurPoint,0},{C.kfTurnResult,0},{C.kfTurnShouldReturn,0})
			RestartTurntable()
		end
		active_ = true
	end
	
	function obj.ResetTurntable()
		if active_ then
			turntable_.times = global_.turntable.kTimesEveryDay
			turntable_.re_times = 0
		end
		return active_
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