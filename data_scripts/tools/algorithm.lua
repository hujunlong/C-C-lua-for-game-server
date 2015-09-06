module ("algorithm", package.seeall)

function RoundTable(t) --for array
	local r = math.random()
	local sum = 0
	for _,v in ipairs(t) do		
		sum = sum+v.probability
		if sum>=r then return v end  
	end
--	assert(false, 'RoundTable error')
end

function RoundTable4Table(t) --for hash table
	local r = math.random()
	local sum = 0
	for k,probability in pairs(t) do 
		sum = sum+probability
		if sum>=r then return k end
	end
--	assert(false, 'RoundTable4Table error')
end

