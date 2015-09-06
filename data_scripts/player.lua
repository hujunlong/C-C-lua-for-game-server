module('player', package.seeall)
local ffi = require"my_ffi"
local db = require"db"
local C = ffi.C

function GetOverviewInfo(uid)
	local sql = string.format([[select base_info.level, function_building.level as cityhall_level, misc_info.degree_of_prosperity from base_info,function_building,misc_info
	where base_info.player=%d and misc_info.player=%d and function_building.player=%d and function_building.kind=1007]], uid, uid, uid)
	local res = db:query(sql)
	if res and res[1] then
		local row = res[1]
		local res = db:query('select rank from arena_info where player='..uid)
		local rank = 0
		if res and res[1] then 
			rank = res[1].rank
		end
		return row.level, row.cityhall_level,  rank, row.degree_of_prosperity
	end	  
end 

local kBuildingType2TableName = {[C.kFunctionBuilding]='function_building', [C.kBusinessBuilding]='business_building', [C.kDecoration]='decoration', [C.kRoad]='road'}
local kBuildingType2StrunctName = {[C.kFunctionBuilding]="FunctionBuildingStatus", [C.kBusinessBuilding]="BusinessBuildingStatus", [C.kDecoration]="DecorationStatus", [C.kRoad]="RoadStatus"}
local kMaxBuildingCount = {[C.kFunctionBuilding]=C.kMaxFunctionBuildings, [C.kBusinessBuilding]=C.kMaxBusinessBuildings, [C.kDecoration]=C.kMaxDecorations, [C.kRoad]=C.kMaxRoads}

function GetOtherPlayerBuildings(uid, building_type)
	local table_name = kBuildingType2TableName[building_type]
	if table_name then 
		local sql = string.format("select * from %s where player=%d", table_name, uid)
		local res = db:query(sql)
		if res then
			local max_building_count =  kMaxBuildingCount[building_type]
			local count =0
			local new_str = string.format('%s[%d]', kBuildingType2StrunctName[building_type], max_building_count)
			local data = ffi.new(new_str)
			if building_type==C.kFunctionBuilding then
				for i,row in ipairs(res) do 
					data[count] = {row.id, row.kind, row.x, row.y, row.aspect, row.level, row.progress}
					count = count+1
					if i>=max_building_count then break end
				end
			elseif building_type==C.kBusinessBuilding then 
				for i,row in ipairs(res) do 
					if row.warehoused == 0 then
						data[count] = {row.id, row.kind, row.x, row.y, row.aspect, row.warehoused, row.progress}
						count = count+1
						if i>=max_building_count then break end
					end
				end				
			elseif building_type==C.kDecoration or building_type==C.kRoad then
				for i,row in ipairs(res) do 
					if row.warehoused == 0 then
						data[count] = {row.id, row.kind, row.x, row.y, row.aspect, row.warehoused}
						count = count+1
						if i>=max_building_count then break end
					end
				end					
			end
			return count, data, ffi.sizeof(kBuildingType2StrunctName[building_type])*count
		end
	end
end

function GetOtherPlayerTownInfo(uid)
	local info = ffi.new('OtherPlayerTownInfo')
	local sql = 'select degree_of_prosperity from misc_info where player='..uid
	local res = db:query(sql)
	if res and res[1] then 
		info.prosperity_degree = res[1].degree_of_prosperity
	end
	sql = 'select blocks from town where player='..uid
	res = db:query(sql)
	if res and res[1] then 
		local blocks = res[1].blocks
		ffi.copy(info.block_status, blocks, ffi.sizeof(info.block_status))
	end	
	return info
end