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

print([[
delimiter $$
drop procedure if exists create_player  $$
create procedure create_player(_id int , _name char(6), _sex int)
begin
		insert into base_info (player,nickname, sex, progress, gold, silver) values(_id, _name, _sex,1, 100, 1000000);
		insert into town (player,blocks) values(_id, 0x000000000000000000000000000e0f000000001415000000000000000000000000000000);
		insert into prop_setting (player,bag_grids_count,warehouse_grids_count) values(_id,20,20);
		insert into hero (player,id,location) values(_id,17,2);
		insert into hero (player,id,location) values(_id,21,5);
		insert into skill (player,id,level) values(_id,12,1);
		insert into status(player) values(_id);
		insert into settings (player) values(_id);
		insert into prop (player, id, location, amount, kind, area) values(_id, 1, 3,1,39,3);
		insert into equipment (player, id, hero, equiped) values(_id,1,17,1);
		insert into prop (player, id, location, amount, kind, area) values(_id, 2, 3,1,41,3);
		insert into equipment (player, id, hero,equiped) values(_id,2,21,1);
		]]
)

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

print[[
end $$
DELIMITER ;
]]

