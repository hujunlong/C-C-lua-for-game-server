require('tools.algorithm')

--local region = {min=1, max=18}
--local proportion = {s=100,a=100,i=100}

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
	if a+b+c==0 then return x,y,z end 
	if 2-(a+b+c)<0.1 then --剩余2个点
		local t = Fix2(math.min(a,b,c), a,b,c)
		x,y,z = t[1]+x,t[2]+y,t[3]+z
	else --剩余1个点
		local t = Fix1(math.max(a,b,c), a,b,c)
		x,y,z = t[1]+x,t[2]+y,t[3]+z
	end
	return x,y,z
end

function EquipmentPropertyGenerate(region, proportion)

	local N = 0

	for i=region.min, region.max do 
		N = N + 1/math.pow(1.618,i)
	end

	local t = {}
	for i=region.min, region.max do 
		t[i] = (1/math.pow(1.618,i))/N
	end

	local total_value = algorithm.RoundTable4Table(t)
	if total_value==0 then return 0,0,0 end
	local s_weight = math.random()*proportion.s
	local i_weight = math.random()*proportion.i
	local a_weight = math.random()*proportion.a
	local total_weight = s_weight + i_weight + a_weight
	local s = total_value*s_weight/total_weight
	local i= total_value*i_weight/total_weight
	local a = total_value*a_weight/total_weight
	--	print(total_value, s,a, i)
	s,i,a = ValuesFix(s,a, i)
	--	print(total_value, s,a, i)
	--	print'\n'
	return s,i,a

end