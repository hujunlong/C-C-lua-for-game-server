local ffi = require("ffi")
local C = ffi.C
require('tools.error_handle')

local function Task_ConvertString2time( atype, atime_str )
	--
	local date,year,month,day,wday,hour,min,sec,cur_time
	local dst_time,interval_time
	--
	cur_time = os.time()
	--
	if atype==1 then
		--
		date = os.date("*t", cur_time)

		hour = string.sub(atime_str, 1, 2)
		min  = string.sub(atime_str, 4, 5)
		sec  = string.sub(atime_str, 7, 8)
		dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min, sec = sec})
		if dst_time<cur_time then
			dst_time = dst_time + 86400 - cur_time
		else
			dst_time = dst_time - cur_time
		end
		interval_time = 86400
		--
	elseif atype==2 then
		--
		date = os.date("*t", cur_time)

		wday = string.sub(atime_str, 1, 1)
		hour = string.sub(atime_str, 3, 4)
		min  = string.sub(atime_str, 6, 7)
		sec  = string.sub(atime_str, 9,10)
		dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min, sec = sec})
		if date.wday == 1 then
			date.wday = 7
		else
			date.wday = date.wday - 1
		end
		dst_time = dst_time + 86400*( wday - date.wday )
		if dst_time<cur_time then
			dst_time = dst_time + 604800 - cur_time	--7天
		else
			dst_time = dst_time - cur_time
		end
		interval_time = 604800
		--
	elseif atype==3 then
		--
		year  = string.sub(atime_str, 1, 4)
		month = string.sub(atime_str, 6, 7)
		day   = string.sub(atime_str, 9,10)
		hour  = string.sub(atime_str,12,13)
		min   = string.sub(atime_str,15,16)
		sec   = string.sub(atime_str,18,19)
		dst_time = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		if dst_time<cur_time then
			dst_time=0
		else
			dst_time = dst_time - cur_time
		end
		interval_time = -1
		--
	else
		print(" unknown time type , in tasks_sch.lua " )
		dst_time=0
		interval_time=0
	end

	return dst_time,interval_time
end


--atype	 atime_str<24小时制,日期和钟点不足2位的用0占位,比如00:00, 2012-09-02;;;可以带秒,例如 18:30:22>
--1 	 每天'18:30'(每天下午6点30);;;;
--2 	 每周'1 20:50'(每周1晚上8点50)
--3 	 指定日期'2012-09-12 13:30'(9月12号下午1点30,,),被执行之后会自动StopTimer
--返回值 调用方如果不需要手动停止任务,可以不需要返回值

local function CreateTaskSch( atype, atime_str, task_func )
	--
	local obj		= {}
	local task_sch = {}
	--task_sch.timer	= 1
	--task_sch.trigger  = 1
	--task_sch.interval = 1
	--task_sch.func     = 1
	--task_sch.type		= 1
	--
	--任务触发器
	local function TaskTrigger( )
		--
		if task_sch.trigger~=0 then
			--
			task_sch.timer = ffi.CreateTimer( TaskTrigger, task_sch.trigger )
			task_sch.trigger = 0
			return task_sch.timer
		elseif task_sch.interval~=0 then
			--
			if task_sch.type==3	then
				task_sch.func()
				task_sch.interval = 0
				C.StopTimer( task_sch.timer )
				return nil
			else
				C.ResetTimer( task_sch.timer, task_sch.interval )
				task_sch.interval = 0
				task_sch.func()
			end
		else
			--
			task_sch.func()
		end
	end

	local dst_time,interval_time = Task_ConvertString2time( atype, atime_str )
	if dst_time==0 then
		return nil
	end

	task_sch.trigger  = dst_time
	task_sch.interval = interval_time
	task_sch.func	  = task_func
	task_sch.type	  = atype

	obj.timer = TaskTrigger()

	--需要停止任务时调用
	function obj.StopTimer( )
		C.StopTimer( task_sch.timer )
	end
return obj
end

--每日
function CreateTaskSch_Day( atime_str, task_func )
	return CreateTaskSch( 1,atime_str, task_func )
end

--每周
function CreateTaskSch_Week( atime_str, task_func )
	return CreateTaskSch( 2, atime_str, task_func )
end

--指定日期
function CreateTaskSch_Specified( atime_str, task_func )
	return CreateTaskSch( 3, atime_str, task_func )
end
