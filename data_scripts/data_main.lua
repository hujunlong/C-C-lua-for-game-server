local ffi = require('my_ffi')
require('top_manager')
require('player')
require('tools.task_sch')
require('top_db')
------------------------------------------------------------------------------------------------------------------------------------------
local sizeof = ffi.sizeof
local new = ffi.new
local C = ffi.C
local cast = ffi.cast
local copy = ffi.copy
local processor_ = {}

------------------------------------------------------------------------------------------------------------------------------------------
processor_[C.kGetOtherPlayerOverviewInfo] = function(uid, msg)
	local target_id = cast('const GetOtherPlayerOverviewInfo&', msg).uid
	if uid==target_id then return end
	local res = new('OtherPlayerOverviewInfo', player.GetOverviewInfo(target_id))
	return res
end
------------------------------------------------------------------------------------------------------------------------------------------
processor_[C.kGetOtherPlayerBuildings] = function(uid, msg)
	local get = cast('const GetOtherPlayerBuildings&', msg)
	if uid==get.uid then return end
	local res = new('OtherPlayerBuildings')
	local count,data,len = player.GetOtherPlayerBuildings(get.uid, get.type)
	if count then 
		res.count = count
		copy(res.data, data, len)
	end
	return res, 2+len
end
------------------------------------------------------------------------------------------------------------------------------------------
processor_[C.kGetOtherPlayerTownInfo] = function(uid, msg)
	local get = cast('const GetOtherPlayerTownInfo&', msg)
	if uid==get.uid then return end
	return player.GetOtherPlayerTownInfo(get.uid)
end
------------------------------------------------------------------------------------------------------------------------------------------
function ProcessMsgFromGate(h, msg, len)
	local head = cast('MqHead&', h)
	local uid = head.aid
	local f = processor_[head.type]
	if f then 
		local res,res_len = f(uid, msg)
		if res then
			head.type = res.kType
			C.Send2Gate(head, res, res_len or sizeof(res))
		end
	end	
end
------------------------------------------------------------------------------------------------------------------------------------------

--初始化排名数据库表
    top_manager.GetTop(processor_)
    top_manager.UpdateRankDataTable()
    top_manager.InitTop()--第一次获取
    top_manager.SelectWoshipListTable()--初始化玩家膜拜的内存

local function ReSetPlayerWorship()
    --从新数据库排序
    top_manager.UpdateRankDataTableExceptSilver()
    --重置每天的膜拜数据
    top_manager.DayWorshipReset()
    --初始化
    top_manager.InitTopExceptSilver()
end
CreateTaskSch_Day("23:00",ReSetPlayerWorship)
------------------------------------------------------------------------------------------------------------------------------------------
local function ReSetWeekSilver()
    --更新银币排序
    top_manager.UpdateRankDataTableSilver()
    --初始化
    top_manager.InitSilverTop()
    --清除所有的膜拜
    top_db.ResetWorship()
end
CreateTaskSch_Week("7 00:00",ReSetWeekSilver)
------------------------------------------------------------------------------------------------------------------------------------------
function RunOnce()
end
------------------------------------------------------------------------------------------------------------------------------------------




