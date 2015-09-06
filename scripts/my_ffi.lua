local ffi = require('ffi')
local C = ffi.C
require('tools.error_handle')

print (jit.version)

--if ffi.os=='Windows' then os.execute('chcp 65001') end

--setmetatable(_G, {__newindex = function(_,n) print('Attempt to write to undeclared variable '..n,2) end,
--	__index = function(_,n) print('Attempt to read undeclared variable '..n,2) end, })

local function load_c_def(file_name)
	local f = io.open(file_name)
	local s = f:read('*all')
	s = s:gsub('#include', '//#include')
	s = s:gsub('}//namespace', '//}//namespace')
	s = s:gsub('namespace',  '//namespace')
	local chunk = 'require("ffi").cdef[[\n' .. s .. '\n]]'
	assert(loadstring(chunk)) ()
end

local function load_all_c_defs()
	load_c_def('c_def/define.h')
	load_c_def('c_def/game_def.h')
	load_c_def('c_def/town.h')
	load_c_def('c_def/mq.h')
	load_c_def('c_def/internal.h')
	load_c_def('c_def/map.h')
	load_c_def('c_def/pvp.h')
	load_c_def('c_def/WorldWar.h')
	load_c_def('c_def/misc.h')
	load_c_def('c_def/data.h')
	load_c_def('c_def/society.h')
	load_c_def('c_def/playgroud.h')
	load_c_def('c_def/broadcast.h')
	load_c_def('c_def/GM.h')
	print 'All C structors are ok!'
end

local function define_c_functions()
	if ffi.os=='Windows' then
		ffi.cdef[[ typedef void (__stdcall *TimerCallback)(int timer_id);]]
	else
		ffi.cdef[[typedef void ( *TimerCallback)(int timer_id);]]
	end

	ffi.cdef[[
		void Send2Db(MqHead& head, void* data, int len);
		void Send2Gate(MqHead& head, void* data, int len);
		void Send2WorldWar(MqHead& head, void* data, int len);
		void Send2GM( const MqHead& head, void* data, int len );
		void Send2Interact( const MqHead& head, void* data, int len );
		void* MovePtr( void* ptr, int offset );

		enum NodeType
		{
			kServer,
			kClient
		};
	
		int CreateTimer(TimerCallback cb, int seconds);
		void StopTimer(int timer_id);
		void ResetTimer(int timer_id, int seconds);
	]]
	print('c functions defined!')
end

load_all_c_defs()
define_c_functions()

function ffi.CreateTimer(cb, seconds)
	local function CallBack()
		xpcall(cb, ErrorHandle)
	end
	return ffi.C.CreateTimer(CallBack, seconds)
end

return ffi


