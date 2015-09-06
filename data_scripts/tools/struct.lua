module ("struct", package.seeall)
local ffi = require('my_ffi')
local sizeof = ffi.sizeof
local copy = ffi.copy
--[[
function CompundData(dst, ...)
	local len = 0
	for _,v in ipairs{...} do 
		copy(C.MovePtr(dst, len), v, sizeof(v))
		len = len+sizeof(v)
	end
--	print(ffi.string(dst, sizeof(dst)))
	return len
end
--]]


function CompundData(dst, ...)
	local str_all = ''
	for _,v in ipairs{...} do 
		str_all = str_all..ffi.string(v, sizeof(v))
	end
	copy(dst,str_all)
	return #str_all
end

function CompundTableData(dst, t)
	local str_all = ''
	for _,v in ipairs(t) do 
		str_all = str_all..ffi.string(v, sizeof(v))
	end
	copy(dst,str_all)
	return #str_all
end