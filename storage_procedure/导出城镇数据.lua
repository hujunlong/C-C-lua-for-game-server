local ffi    = require('ffi')
local C      = ffi.C
local sizeof = ffi.sizeof
local cast   = ffi.cast
local new    = ffi.new

local mysql = require('mysql')


local db_addr = "127.0.0.1"
if ffi.os=='Windows' then db_addr="192.168.0.248" end
local conn = mysql:connect( db_addr, "ywxm", "ywxm", "game" )
conn:query("set names 'utf8'")


function GetTownDataByUID(uid, table)
    local res = conn:query('select * from '.. table ..' where player='..uid)
	
    for _,row in ipairs(res) do
		local str = 'INSERT INTO `'.. table ..'` ('
	    for k,_ in pairs(row) do
		    str = str .. "`"..k.."`" .. ', '
		end
		str = string.sub(str, 0, -3) ..') VALUES ('
		
	    for _,v in pairs(row) do
			if _=='player' then
				str = str .. '_uid, '
			else
				str = str .. "'"..v.."'" .. ', '
			end
		    
		end
		str = string.sub(str, 0, -3) ..');'
		
		print(str)
	end
end

GetTownDataByUID(1010, "business_building")
GetTownDataByUID(1010, "decoration")
GetTownDataByUID(1010, "function_building")
GetTownDataByUID(1010, "road")
