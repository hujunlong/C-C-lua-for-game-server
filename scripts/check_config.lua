local ffi = require('ffi')

ffi.cdef[[
	const char* GetCurrentPath();
	const char* GetDirectoryFiles(const char* fullpath);
]]

local function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            if nFindStartIndex<=string.len(szFullString) then
                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            end
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        if string.len(nSplitArray[nSplitIndex])==0 then
            nSplitArray[nSplitIndex] = nil
            nSplitIndex = nSplitIndex - 1
        end
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray, table.getn(nSplitArray)
end

--获取目录下的lua文件
local ext = ffi.load('luaext')
local path = ffi.string(ext.GetCurrentPath()) .. '/config_check'
--print(path)
local files = Split( ffi.string( ext.GetDirectoryFiles(path)), ',')
local lua_files = {}
for _,filename in ipairs(files) do 
	if string.find(filename, '.lua') then table.insert(lua_files, filename) end
end

--for _,file in ipairs(lua_files) do print(file) end

for _,file in ipairs(lua_files) do
	dofile(file)
end








