--这个文件的作用是生成一个伪ffi模块，让scite的luainspect插件能够正常识别C++中定义的常量和函数以及ffi本身的函数
local file_name = 'ffi.lua'
os.remove(file_name)
local f = io.open(file_name, 'w')
s = [[
module ('ffi', package.seeall)

local ffi = 
{
	C = {
]]

f:write(s)

function load_keywords(file)
	local fkey = io.open(file)
	local s = fkey:read('*all')
	local words = {}
	string.gsub(s,'%a%w+', function (w) if #w>3 then words[w]=0  end  end)
	for w,_ in pairs(words) do
		if string.match(w, '%u') and (string.find(w,'k')==1 or string.find(w,'e')==1) then f:write(w..'=0,\n') end
	end
end

load_keywords('c_def/define.h')
load_keywords('c_def/game_def.h')
load_keywords('c_def/town.h')
load_keywords('c_def/mq.h')
load_keywords('c_def/internal.h')
load_keywords('c_def/map.h')
load_keywords('c_def/pvp.h')
load_keywords('c_def/data.h')
load_keywords('c_def/misc.h')
load_keywords('c_def/playgroud.h')
load_keywords('c_def/society.h')
load_keywords('c_def/broadcast.h')

s = [[
}

}


function ffi.cast(ref_type_string, pvoid) return {} end

function ffi.new(type_string, ...) return {} end

function ffi.copy(pvoid_dst, pvoid_src, len) return end

function ffi.sizeof(cdata) return 0 end



function ffi.C.Send2Db(head, body, len)  end

function ffi.C.Send2Gate(head, body, len)  end

function ffi.C.Send2WorldWar(head, body, len)  end

function ffi.C.Send2GM(head, body, len)  end

function ffi.C.Send2Interact(head, body, len)  end

function ffi.C.CreateTimer(callback, seconds) end

function ffi.C.DeleteTimer(timer_id) end

function CompressString(str) return buf,len end
		
return ffi
]]

f:write(s)

