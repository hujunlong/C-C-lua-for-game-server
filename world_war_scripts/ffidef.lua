local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local cast = ffi.cast
local new = ffi.new

local function load_c_def(file_name)
    ffi.cdef[[
        enum
        {
            kPVPTypeBegin = 12000,
            kGameReturnBegin = 15000,
            kPVPReturnBegin = kGameReturnBegin + 3000,
        };
        
        enum
        {
            kMaxFightRecordLength = 11*1024,
        };
        
        typedef uint16_t StringLength;
        typedef int16_t Type;
        typedef int32_t Result; 

        struct Nickname
        {
            StringLength len;
            char str[18];
        };
        typedef struct Nickname Nickname;
    ]]
    
    local f = io.open(file_name)
    local s = f:read('*all')
    s = s:gsub('#include', '//#include')
    s = s:gsub('}//namespace', '//}//namespace')
    s = s:gsub('namespace',  '//namespace')
    local chunk = 'require("ffi").cdef[[\n' .. s .. '\n]]'
    assert(loadstring(chunk)) ()
end

local function define_c_functions()
    local c_def = ''
    if ffi.os=='Windows' then
        os.execute("cd >cd.temp")
        local f = io.open("cd.temp","r")
        local path = f:read("*a")
        f:close()
        os.remove("cd.temp")
        path = string.sub(path, 1, -19)
        c_def = path .. "scripts\\c_def\\"
    else
        os.execute("pwd >pwd.temp")
        local f = io.open("pwd.temp","r")
        local path = f:read("*a")
        f:close()
        os.remove("pwd.temp")
        path = string.sub(path, 1, -11)
        c_def = path .. "world/c_def/"
    end
    
    load_c_def(c_def .. 'WorldWar.h')

    if ffi.os == "Windows" then
        ffi.cdef[[typedef void (__stdcall *TimerCallback)(int timer_id);]]
    else
        ffi.cdef[[typedef void ( *TimerCallback)(int timer_id);]]
    end
    
    ffi.cdef[[
        typedef int16_t MQType;
        struct MqHead
        {
            int32_t aid; //Associate id
            int16_t type;
            int16_t flag;
        };
        typedef struct MqHead MqHead;

        enum NodeType
        {
            kServer,
            kClient
        };
        
        uint32_t ZMQInit(int aType, const char* apAddress);
        bool ZMQFetch(uint32_t,MqHead& head, void* data, size_t& len);
        void ZMQSend(uint32_t,const MqHead& h, const void* aData, size_t aLen );
        
        void Poll();
        void SleepFor(int ms);
        
        int CreateTimer(TimerCallback cb, int seconds);
        void StopTimer(int timer_id);
        void ResetTimer(int timer_id, int seconds);
        
        enum
        {
            kGameMainTypeBegin = 9000,
            kGameOperationException = kGameMainTypeBegin+998,
        };
        
        struct GameOperationException //操作发生异常时返回，主要作调试用
        {
            static const Type kType = kGameOperationException;
            int16_t operation_type;
            StringLength len;
            char error[2048];
        };
        typedef struct GameOperationException GameOperationException;
    ]]
end
define_c_functions()

function ffi.CreateTimer(cb, seconds)
    return C.CreateTimer(
        function()
            xpcall(cb, 
                function(e)
                    print(e)
                    print(debug.traceback())
                end)
        end,
        seconds)
end
