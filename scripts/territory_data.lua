--玩家领地{数据管理}
local ffi = require('ffi')
local new = ffi.new

require('data')
require('global_data')

local config = require('config.global')

local territory_cfgs = require('config.territory')
local territory_style = require('config.territory_style')
local territory_info, territory_index = data.GetTerritory()
local territory_player = data.GetTerritoryInfo()
local territory_wait = {}
--[[
--数据描述
--territory_info[row.country][row.type][row.page][row.seral]= {kind=row.kind, owner=row.owner}
--territory_index[row.owner] = {country=row.country, type=row.type, page=row.page}
-- .city = {seral=row.seral, kind=row.kind}
-- .resource = {seral=row.seral, kind=row.kind}
--territory_player[uid]={skin=row.skin, move=row.move, grab=row.grab, robber=row.robber, assist=row.assist, time=row.time, reap=row.reap,
                          move_cd=row.move_cd, grab_cd=row.grab_cd, kill_cd=row.kill_cd, last_active_time=row.last_active_time}
]]

local bronze = config.territory.bronze

--高级领地初始化
local adjust_flag = false
for type,cfgs in ipairs(territory_cfgs) do
    if cfgs.amount~=-1 then
        --国家
        for country=1,3 do
            --页数
            for page=1,cfgs.amount do
                --随机选择一个风格
                local style = cfgs.style[ math.random(1, #cfgs.style) ]
                
                --插入一页
                for seral,styles in ipairs(territory_style[style]) do
                    if not territory_info[country] then territory_info[country] = {} end
                    if not territory_info[country][type] then territory_info[country][type] = {} end
                    if not territory_info[country][type][page] then territory_info[country][type][page] = {style=style} end
                    
                    if not territory_info[country][type][page][seral] then
                        data.InsertTerritory(country, type, page, style, seral, styles.kind)
                        territory_info[country][type][page][seral] = {kind=styles.kind, owner=0}
                        adjust_flag = true
                    end
                end
            end
        end
    end
end
if adjust_flag then
    print("adjust territory count")
end

--青铜领地补全
for country=1,3 do
    if not territory_info[country][bronze] then territory_info[country][bronze] = {} end
end

--
local obj = {}

--获取领地信息
function obj.GetTerritoryInfo()
    return territory_info
end
function obj.GetTerritoryIndex()
    return territory_index
end
function obj.GetTerritoryPlayer()
    return territory_player
end
function obj.GetTerritoryWait()
    return territory_wait
end


--通知正在查看的玩家领地信息发生改变
function obj.NotifyTerritoryChange(country, type, page)
    local result = new('TerritoryChange')
    
    for player_id,v in pairs(territory_wait) do
        if v.country==country and v.type==type and v.page==page then
            GlobalSend2Gate(player_id, result)
        end
    end
end

--通知正在查看的玩家领地页数发生改变
function obj.NotifyTerritoryPageChange(country, type, page)
    local result = new('TerritoryPage')
    
    result.total = #territory_info[country][type]
    for player_id,v in pairs(territory_wait) do
        if v.country==country and v.type==type then
            if v.page>page then
                v.page = v.page - 1
            end
            
            result.page = v.page
            GlobalSend2Gate(player_id, result)
        end
    end
end

--分配领地
function obj.CheckDistribute(country, uid)

    --在当前页面中寻找空余位置
    local function FindFreeSpace()
        local page = #territory_info[country][bronze]
        if page==0 then return nil end
        
        for index,seral in ipairs(territory_info[country][bronze][page]) do
            if seral and seral.kind==0 and seral.owner==0 then
                return page, index
            end
        end
        
        return nil
    end
    
    --把城池分配给玩家
    local function SetOwner(page, seral)
        territory_info[country][bronze][page][seral].owner = uid
        territory_index[uid] = {country=country, type=bronze, page=page}
        territory_index[uid].city = {seral=seral, kind=0}
        
        --修改数据库
        data.SetTerritoryOwner(country, bronze, page, seral, uid)
        
        territory_player[uid] = {skin=0, move=1, grab=1, robber=0, assist=0, time=0, reap=0, move_cd=0, grab_cd=0, kill_cd=0, last_active_time=os.time()}
        data.InsertTerritoryInfo(uid)
        
        obj.NotifyTerritoryChange(country, bronze, page)
    end
    
    --插入新的一页
    local function AddNewPage()
        --随机选择一个风格
        local style = territory_cfgs[bronze].style[ math.random(1, #territory_cfgs[bronze].style) ]
        
        --插入一页
        local page = #territory_info[country][bronze] + 1
        territory_info[country][bronze][page] = {style = style}
        for seral,styles in ipairs(territory_style[style]) do
            territory_info[country][bronze][page][seral] = {kind=styles.kind, owner=0}
            data.InsertTerritory(country, bronze, page, style, seral, styles.kind)
        end
        
        obj.NotifyTerritoryPageChange(country, bronze, page)
    end
    
    --找出空余空间，如果空间不足插入新的一页再次寻找
    local page, seral = FindFreeSpace()
    if not page then
        AddNewPage()
        
        page, seral = FindFreeSpace()
        if page then
            SetOwner(page, seral)
        else
            print("CheckDistribute发生异常")
        end
    else
        SetOwner(page, seral)
    end
end

return obj