module ("vector", package.seeall)
require('tools.table_ext')

function front(v)
	return v[1]
end

function back(v)
	return v[#v]
end

function push_front(vec, val)
	table.insert(vec, 0)
	for i=#vec,2,-1 do
		vec[i] = vec[i-1]
	end
	vec[1] = val
end

function push_back(vec, val)
	table.insert(vec, val)
end

function erase(vec, index)
	local len = #vec
	assert(index>0 and index<=len)
	for i=index,len-1 do 
		vec[i] = vec[i+1]
	end
	vec[len] = nil
end

function size(vec)
	return #vec
end

function is_vector(vec)
	local size = 0
	for _ in pairs(vec) do size=size+1 end
	return size==#vec
end

function add(v1, v2)
	for i,val in ipairs(v2) do
		table.insert(v1, val)
	end
end

function find(vector, value)
	for i,v in ipairs(vector) do 
		if v==value then return i end
	end
end

function random_one(t)
	return t[math.random(1, #t)]
end

function random_chose(t, n)
	t = table.clone(t) --very important
		
	local ret = {}
	if #t<n then n = #t end

	for _=1,n do
		r = math.random(#t)
		table.insert(ret, table.remove(t, r))
	end
	return ret
end

function random_chose_exclude(t, n, exp_t)
	return random_chose(minus(t, exp_t), n)
end


--a吞并b中自己没有的元素
function absorb(a,b)
    for _,v in ipairs(b) do 
		if not find(a,v) then table.insert(a,v) end
	end
end

function minus(a,b)
	local ret = {}
	for _,va in ipairs(a) do 
		if not find(b,va) then table.insert(ret, va) end
	end
	return ret
end

function max_element(vec)
	if #vec==0 then return nil end
	local max = vec[1]
	for _,value in ipairs(vec) do 
		if value>max then max=value end
	end
	return max
end

function min_element(vec)
	if #vec==0 then return nil end
	local min = vec[1]
	for _,value in ipairs(vec) do 
		if value<min then min=value end
	end
	return min
end