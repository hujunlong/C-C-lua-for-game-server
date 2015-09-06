module('time', package.seeall)

function ConvertString2time(strTime)
	local date = os.date("*t", os.time())

	local colon = string.find(strTime, ":")
	local hour = string.sub(strTime, 0, colon - 1)
	local min = string.sub(strTime, colon + 1)

	return os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min})
end

function ParseTime(time_str)
	local colon = string.find(time_str, ":")
	local hour = string.sub(time_str, 0, colon - 1)
	local min = string.sub(time_str, colon+1, colon+2)
	local second = string.sub(time_str, colon+4)
	return tonumber(hour), tonumber(min), tonumber(second)
end


function IsTimeInInterval(time, time1, time2)
	time1 = ConvertString2time(time1)
	time2 = ConvertString2time(time2)
	return time<=time2 and time>=time1 or time<=time1 and time>=time2
end

function GetNextTime(time)
	time = ConvertString2time(time) - os.time()

	if time<=0 then time = time + 60*60*24 end

	return time
end

function GetNearestLastTime(time_array, time)
	local tmp = nil
	for i,v in ipairs(time_array) do
		tmp = v
		if i<#time_array and time>=v and time<time_array[i+1] then break end
	end
	return tmp
end

--判断时间是否跨天
function IsTimeInSameDay(time, strtime)
    return ConvertString2time(strtime) - time <= 60*60*24
end


--把一个时间点（小时与分）转化为今天的一个时刻（整数）
function Time2Today(hour, minute) 
	local date = os.date("*t", os.time())
	date.hour = hour
	date.min = minute or 0
	date.sec = 0
	return os.time(date)
end

--获取时间差，忽略天数
function time_to_time(strTime)
    local date = os.date("*t", os.time())
    
    local colon = string.find(strTime, ":")
    local hour = string.sub(strTime, 0, colon - 1)
    local min = string.sub(strTime, colon + 1)

    local dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min})
    
    local time = dst_time - os.time()
    
    if time<=0 then time = time + 60*60*24 end
    return time
end



--格式化时间差
function format_time(time)
    local str = ""
    
    if time>86400 then time = time%86400 end
    local hour = math.floor(time/60/60)
    local min = math.floor(time%3600/60)
    local sec = math.floor(time%60)
    
    if hour~=0 then
        str = str .. hour ..'小时'
    end
    if min~=0 then
        str = str .. min ..'分'
    end
    if sec~=0 then
        str = str .. sec ..'秒'
    end
    return  str
end


