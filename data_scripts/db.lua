module('db', package.seeall)
require('top_db')

local ffi = require('my_ffi')
local mysql = require('tools.mysql')

local sizeof = ffi.sizeof
local new = ffi.new
local C = ffi.C
local cast = ffi.cast


local conn 
if ffi.os=='Windows' then 
    conn = mysql:connect( "192.168.0.248", "ywxm", "ywxm", "game" )
else
    conn = mysql:connect( "127.0.0.1", "ywxm", "ywxm", "game" )
end

top_db.Initialize(conn)
if conn then print('succeeded to connect to db') end

conn:query("set names 'utf8'")




function KeepAlive()
    conn:query('select now();')
end

ffi.CreateTimer(KeepAlive, 60*60) --隔一段时间访问一次数据库，防断线  select now();


return conn


