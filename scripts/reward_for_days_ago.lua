local global_ = require('config.global')

local ffi = require('ffi')
local C = ffi.C
--local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
--local copy = ffi.copy

--初始化
local online_players = {}
function InitRewardForDaysAgo( players )
	online_players = players
end


function ResetRewardForDaysAgo()
	local sql = 'update reward_for_days_ago set `got`=0'
	GlobalSend2Db(new('ExcuteSqlDirectly',#sql, sql), 2+#sql)
	--
	for _, player in pairs(online_players) do
		player.ResetRewardForDaysAgo()
	end
end


function CreateRewardForDaysAgo(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local reward_ = {}
	reward_.reg_time = 0
	reward_.got = 0
	
	local function CanGetReward()
		if reward_.got==0 then
			local cur_time = os.time()
			if (cur_time-reward_.reg_time)>(3*24*3600) then
				return false
			end
			local reg_date = os.date('*t', reward_.reg_time)
			local cur_date = os.date('*t', cur_time)
			if reg_date.year==cur_date.year then
				if (cur_date.yday-reg_date.yday)<3 then
					return true
				end
			elseif (cur_date.year-reg_date.year)>1 then
				return false
			else
				local first_day_time = 24*3600-(reward_.reg_time-os.time({year=reg_date.year,month=reg_date.month,day=reg_date.day,hour=0,min=0,sec=0}))
				if (cur_time-reward_.reg_time)<=(2*24*3600+first_day_time) then
					return true
				end
			end
		end
		return false
	end
	
	processor_[C.kGetDaysAgoInfo] = function()
		local result = new('GetDaysAgoInfoResult',0,0)
		if CanGetReward() then
			result.amount = global_.kGoldForDaysAgo
			result.exist_reward = 1
		end
		return result
	end
	
	processor_[C.kGetRewardDaysAgo] = function()
		local result = new('GetRewardDaysAgoResult')
		if CanGetReward() then
			reward_.got = 1
			player.UpdateField(C.ktRewardForDaysAgo, C.kInvalidID, {C.kfGot,1})
			result.result = C.eSucceeded
			player.AddRechargedGold(global_.kGoldForDaysAgo)
		else
			result.result = C.eInvalidOperation
		end
		return result
	end
	
	db_processor_[C.kInternalRewardDaysAgoInfo] = function(msg)
		local info = cast('const InternalRewardDaysAgoInfo&', msg)
		reward_.reg_time = info.reg_time
		reward_.got = info.got
	end
	
	function obj.Reset()
		reward_.got = 0
	end
	
	function obj.ProcessMsgFromDb(type, msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsg(type, msg)
		local f = processor_[type]
		if f then return f(msg) end
	end
return obj
end