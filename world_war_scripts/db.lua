module('db', package.seeall)

local ffi = require('ffi')
local mysql = require('mysql')

local db_addr = "127.0.0.1"
if ffi.os=='Windows' then db_addr="192.168.0.248" end
local conn = mysql:connect( db_addr, "ywxm", "ywxm", "world_war" )
conn:query("set names 'utf8'")

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function InitWorldWar()
    print("Init World War")
    conn:query('DELETE FROM grade_top')
    conn:query('DELETE FROM world_war_country')
    conn:query('DELETE FROM world_war_history')
    conn:query('DELETE FROM world_war_info')
    conn:query('DELETE FROM world_war_location')
    conn:query('DELETE FROM world_war_report')
    conn:query('DELETE FROM world_war_running')
    conn:query('DELETE FROM world_war_server')
    conn:query('DELETE FROM world_war_status')
    conn:query('DELETE FROM world_war_top')
    --conn:query('ALTER TABLE world_war_history AUTO_INCREMENT=1')
    
    conn:query("INSERT INTO world_war_status VALUES('1', '0', '第几期国战')")
    conn:query("INSERT INTO world_war_status VALUES('2', '0', '国战定时器')")
    conn:query("INSERT INTO world_war_status VALUES('3', '0', '国战发奖')")
end

function UpdateWorldWarMap(cfg)
    local res = conn:query('select * from world_war_map')
    local row = res[1]
    if not row then
        --初始化国战服务器数据
        InitWorldWar()
        
        for k,v in pairs(cfg) do
            if not v.retention then
                conn:query('INSERT INTO world_war_map VALUES(' .. k .. ', ' .. v.country .. ', 0, 0, 0)')
                v.vote1 = 0
                v.vote2 = 0
                v.vote3 = 0
            end
        end
    else
        for _,field in ipairs(res) do
            for key,value in pairs(field) do
                cfg[field.map][key] = value
            end
        end
    end
end

function UpdateWorldWarVote(map, country, delta)
    conn:query('UPDATE world_war_map SET vote' .. country .. ' = ' .. delta .. ' where map='..map)
end

function ResetWorldWarVote()
    conn:query('UPDATE world_war_map SET vote1=0,vote2=0,vote3=0')
end

function UpdateWorldWarCountry2(map, country)
    conn:query('UPDATE world_war_map SET country=' .. country .. ' where map='..map)
    conn:query('DELETE FROM world_war_location where map='..map)
    conn:query('DELETE FROM world_war_country where map='..map)
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function GetWorldWarRunning()
    local info = {}
    local res = conn:query('select * from world_war_running')
    for _,row in ipairs(res) do
        info[row.map] = {}
        info[row.map].attack = row.attack
        info[row.map].defend = row.defend
        info[row.map].progress = row.progress
    end
    return info
end

function InsertWorldWarRunning(info)
    conn:query('INSERT INTO world_war_running VALUES(' .. info.map .. ', ' .. info.attack .. ', ' .. info.defend .. ', ' .. info.progress .. ')')
end

function UpdateWorldWarRunning(map,progress)
    conn:query('UPDATE world_war_running SET progress=' .. progress .. ' where map='..map)
end

function ResetWorldWarRunning()
    conn:query('DELETE FROM world_war_country')
    conn:query('DELETE FROM world_war_location')
    conn:query('DELETE FROM world_war_running')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function GetWorldWarInfo()
    local info = {}
    local res = conn:query('select player,server,country,vip,grade,level,rank,point,score,count,robot,auto,vote,time,nickname from world_war_info')
    for _,row in ipairs(res) do
        if not info[row.server] then info[row.server] = {} end
        info[row.server][row.player] = {}
        info[row.server][row.player].server   = row.server
        info[row.server][row.player].camp     = row.country
        info[row.server][row.player].vip      = row.vip
        info[row.server][row.player].grade    = row.grade
        info[row.server][row.player].level    = row.level
        info[row.server][row.player].rank     = row.rank
        info[row.server][row.player].point    = row.point
        info[row.server][row.player].score    = row.score
        info[row.server][row.player].count    = row.count
        info[row.server][row.player].robot    = row.robot
        info[row.server][row.player].auto     = row.auto
        info[row.server][row.player].vote     = row.vote
        info[row.server][row.player].time     = row.time
        info[row.server][row.player].nickname = row.nickname
    end
    return info
end

function InsertWorldWarInfo(uid, sid, camp, vip, grade, level, name)
    conn:query('INSERT INTO world_war_info (player,server,country,vip,grade,level,nickname) VALUES('..uid..','..sid..','..camp..','..vip..','..grade..','..level..',"'..name..'")')
end

function UpdateWorldWarInfo(uid, sid, ...)
    local str = ""
    for k,v in ipairs{...} do
        if k~=1 then
            str = str .. ',' .. v[1] .. '=' .. "'" .. v[2] .. "'"
        else
            str = v[1] .. '=' .. "'" .. v[2] .. "'"
        end
    end
    conn:query('update world_war_info set ' .. str .. ' where player='..uid..' and server='..sid)
end

function ResetWorldWarInfo()
    --conn:query('update world_war_info set count=0,auto=0,time=0')
    conn:query('update world_war_info set count=0')
end

function ResetWorldWarScore()
    conn:query('update world_war_info set score=0')
end

function ResetWorldWarVote2()
    conn:query('update world_war_info set vote=0')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function InsertWorldWarCountry(info)
    conn:query('INSERT INTO world_war_country VALUES(' .. info.map .. ', ' .. info.location1 .. ', ' .. info.country .. ')')
end

function UpdateWorldWarCountry3(map,location,country)
    conn:query('UPDATE world_war_country SET country=' .. country .. ' where map='..map..' and location='..location)
end

function UpdateWorldWarCountry1(map)
    local res = conn:query("select * from world_war_country")
    for _,row in ipairs(res) do
        map[row.map].locations[row.location].country = row.country
    end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function GetWorldWarStatus(key)
    local res = conn:query('select value from world_war_status where `key`='..key)
    local row = res[1]
    if not row then return 0 end

    return row.value
end

function SetWorldWarStatus(key,value)
    conn:query('UPDATE world_war_status SET value=' .. value .. ' where `key`='..key)
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function GetWorldWarServer()
    local info = {}
    local res = conn:query("select * from world_war_server")
    for _,row in ipairs(res) do
        info[row.id] = row.name
    end
    return info
end

function SetWorldWarServerName(id,name)
    conn:query('replace into world_war_server VALUES(' ..id..',"'..name..'")')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function GetWorldWarRecord()
    local info = {}
    local res = conn:query('select * from world_war_history ORDER BY history ASC')
    for _,row in ipairs(res) do
        table.insert(info, row)
    end
    return info
end

function DeleteWorldWarRecord(history_id)
    conn:query('DELETE FROM world_war_history where history='..history_id)
end

function InsertWorldWarRecord(news)
    conn:query('INSERT INTO world_war_history VALUES(' .. news.history .. ', ' .. news.map .. ', ' .. news.attack .. ', ' .. news.defend .. ', ' .. news.type .. ', ' .. news.time .. ', ' .. news.term .. ')')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function GetWorldWarLocation()
    local info = {}
    local res = conn:query('select * from world_war_location')
    for _,row in ipairs(res) do
        if not info[row.map] then info[row.map] = {} end
        table.insert(info[row.map], row)
    end
    return info
end

function SetWorldWarLocation(map,location1,location2,progress)
    conn:query('UPDATE world_war_location SET progress=' .. progress .. ' where map='..map ..' and ( (location1='..location1..' and location2='..location2..') or (location2='..location1..' and location1='..location2..') )')
end

function InsertWorldWarLocation(info)
    conn:query('INSERT INTO world_war_location VALUES(' .. info.map .. ', ' .. info.location1 .. ', ' .. info.location2 .. ', ' .. info.progress .. ')')
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function GetWorldWarTop()
    local info = {}
    local res = conn:query('select * from world_war_top ORDER BY `index` ASC')
    for _,row in ipairs(res) do
        table.insert(info, row)
    end
    return info
end

function InsertWorldWarTop(info)
    conn:query('INSERT INTO world_war_top VALUES(' .. info.server .. ', ' .. info.player .. ', ' .. info.rank .. ', ' .. info.reward .. ', ' .. info.index ..')')
end

function ResetWorldWarTop()
    conn:query('DELETE FROM world_war_top')
end

--[[
function UpdateWorldWarTop(sid,uid,reward)
    conn:query('update world_war_top set reward=' .. reward .. ' where player='..uid..' and server='..sid)
end
]]

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function GetGradeTop()
    local info = {}
    local res = conn:query('select * from grade_top ORDER BY `index` ASC')
    for _,row in ipairs(res) do
        table.insert(info, row)
    end
    return info
end

function InsertGradeTop(info)
    conn:query('INSERT INTO grade_top VALUES(' .. info.server .. ', ' .. info.player .. ', ' .. info.rank .. ', ' .. info.index ..')')
end

function ResetGradeTop()
    conn:query('DELETE FROM grade_top')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local function GetReportSequence()
    local res = conn:query('SELECT IFNULL(MAX(report),0) as max_id FROM world_war_report')
    return res[1].max_id
end
local report_id = GetReportSequence()

function GetWorldWarReport(sid, uid)
    local info = {}
    local res = conn:query('select * from world_war_report where player='..uid..' and server='..sid..' ORDER BY report ASC')
    for _,row in ipairs(res) do
        table.insert(info, row)
    end
    return info
end

function DeleteWorldWarReport(report_id_)
    conn:query('DELETE FROM world_war_report where report='..report_id_)
end

function InsertWorldWarReport(info)
    report_id = report_id + 1
    
    info.report = report_id
    
    conn:query('INSERT INTO world_war_report VALUES(' .. info.report .. ', ' .. info.player .. ', ' .. info.server .. ', ' .. info.count .. ', ' .. info.map .. ', ' .. info.score .. ', ' .. info.prestige.. ', ' .. info.time ..')')
end

