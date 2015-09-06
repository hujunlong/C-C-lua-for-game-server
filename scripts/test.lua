require('tools.algorithm')
require('tools.vector')
require('tools.table_ext')
require('math')
--[[
local region = {min=1, max=18}
local proportion = {s=100,a=200,i=300}

local N = 0

for i=region.min, region.max do 
	N = N + 1/math.pow(1.618,i)
end

local t = {}
for i=region.min, region.max do 
	t[i] = (1/math.pow(1.618,i))/N
end


local function Fix2(n, ...)
	local t = {...}
	for i,v in ipairs(t) do 
		if v==n then t[i]=0 else t[i]=1 end
	end
	return t
end

local function Fix1(n, ...)
	local t = {...}
	for i,v in ipairs(t) do 
		if v==n then t[i]=1 else t[i]=0 end
	end
	return t
end

local function ValuesFix(x,y,z)
	local x,a = math.modf(x)
	local y,b = math.modf(y)
	local z,c = math.modf(z)
	if 2-(a+b+c)<0.1 then 
		local t = Fix2(math.min(a,b,c), a,b,c)
		x,y,z = t[1]+x,t[2]+y,t[3]+z
	else
		local t = Fix1(math.max(a,b,c), a,b,c)
		x,y,z = t[1]+x,t[2]+y,t[3]+z
	end
	return x,y,z
end

--local total_proportion = proportion.s + proportion.i + proportion.a
--[[
for i=0,1000 do
	local total_value = algorithm.RoundTable4Table(t)
	local s_weight = math.random()*proportion.s
	local i_weight = math.random()*proportion.i
	local a_weight = math.random()*proportion.a
	local total_weight = s_weight + i_weight + a_weight
	local s = total_value*s_weight/total_weight
	local i= total_value*i_weight/total_weight
	local a = total_value*a_weight/total_weight
	print(total_value, s,a, i)
	s,i,a = ValuesFix(s,a, i)
	print(total_value, s,a, i)
	print'\n'
end
]]


local function pt(t,ff,c)
	for k,v in pairs(t) do print(k,v) end
end

 local function err(x)
	local loc = 464
	y.z = x
end

 local function ddf(uip)
--	print(uip)
	local local2 = 'dfdf'
	err(local2, 45, 57)
end

local function error_handle()
	print(debug.traceback())
	for i=2,99 do 
		local info = debug.getinfo(i)
		if not info then break end
--		if not info.name then break end
		print('stack '..i)
		print('name:', info.name)
		print('namewhat:', info.namewhat)
		print('source:', info.source)
		print('short_src:', info.short_src)
		print('lastlinedefined:', info.lastlinedefined)
		print('what:', info.what)
		print('nups:', info.nups)
		print('activelines:', info.activelines)
		print('func:', info.func)
		
		print(info.short_src..':'..info.lastlinedefined..': in function "'..info.name..'"')
		
		for j=1,99 do 
			local name, value = debug.getlocal(i, j)
			if not name then break end
			print(name, value)
		end
		
--		print('upvalues----')
		local func = debug.getinfo(i).func
		for j=1,99 do 
			local name, value = debug.getupvalue(func, j)
			if not name then break end
			print(name, value)
		end
		
		print('')
	end
end

--local ret, err_str= xpcall(ddf, error_handle, 'test')
--if not ret then print('err_str---' .. err_str)
--end

local t = {1,2,3,4,5}
table.insert(t, 3, 999)
for k,v in pairs(t) do print(k,v) end