require('db')

local function enum(...)
    local enum_t = {}
    for k,v in pairs(...) do enum_t[v] = k end
    return enum_t
end

status_type = enum{"world_war_term", "world_war_timer", "world_war_award"}

local war_player = {}

local war_map = require('config.world_war_map')
db.UpdateWorldWarMap(war_map)
db.UpdateWorldWarCountry1(war_map)

local grade_top    = db.GetGradeTop()
local war_top      = db.GetWorldWarTop()
local war_info     = db.GetWorldWarInfo()
local war_running  = db.GetWorldWarRunning()
local war_history  = db.GetWorldWarRecord()
local war_location = db.GetWorldWarLocation()
local war_server   = db.GetWorldWarServer()
war_term = db.GetWorldWarStatus(status_type.world_war_term)

--玩家rank排名
local war_rank = {}
for sid,info in pairs(war_info) do
    for uid in pairs(info) do
        war_rank[#war_rank + 1] = {}
        war_rank[#war_rank].server = sid
        war_rank[#war_rank].player = uid
    end
end

--进入地图玩家队列
local war_wait = {}

function GetWarPlayer() return war_player end
function GetWarMap() return war_map end
function GetGradeTop() return grade_top end
function GetWarTop() return war_top end
function GetWarInfo() return war_info end
function GetWarRunning() return war_running end
function GetWarHistory() return war_history end
function GetWarLocation() return war_location end
function GetWarServer() return war_server end
function GetWarRank() return war_rank end
function GetWarWait() return war_wait end
--function GetWarTerm() return war_term end

--清除表数据，并且保持引用生效
function MakeEmpty(t)
    for k in pairs(t) do
        t[k] = nil
    end
end
