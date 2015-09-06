--攻略管理
module('raiders', package.seeall)

require('data')

RAIDERS_TYPE = {MAIN_LINE=1, BOSS_SECTION=2, TOWER=3}

local raiders_info = data.GetRaidersInfo()

--添加记录
function InsertRaiders(type, id, sub_id, player, record, level)
    if not raiders_info[type] then raiders_info[type] = {} end
    if not raiders_info[type][id] then raiders_info[type][id] = {} end
    if not raiders_info[type][id][sub_id] then raiders_info[type][id][sub_id] = {} end
    
    local raiders = raiders_info[type][id][sub_id]
    local found = nil
    for i,v in ipairs(raiders) do
        if v.player==player then
            found = i
            break
        end
    end
    
    if not found then
        if #raiders>=5 then
			if type==RAIDERS_TYPE.MAIN_LINE and id<=5 then return end
            --删除老记录
            local info = table.remove(raiders, 1)
            data.DeleteRaiders(type, id, sub_id, info.player)
            data.DeleteBattle(info.record)
        end
        
        --新建一条记录
        table.insert(raiders, {player=player, record=record, level=level, time=os.time()})
        data.InsertRaiders(type, id, sub_id, raiders[#raiders])
    else
        --修改已有记录
        data.DeleteBattle(raiders[found].record)
        
        raiders[found].record = record
        raiders[found].level = level
        raiders[found].time = os.time()
        data.UpdateRaiders(type, id, sub_id, raiders[found])
    end
end

--获取攻略，返回【攻略数量，攻略】
function GetRaiders(type, id, sub_id)
    if not raiders_info[type] then return 0 end
    if not raiders_info[type][id] then return 0 end
    if not raiders_info[type][id][sub_id] then return 0 end
    
    if #raiders_info[type][id][sub_id]>5 then
        print("攻略数量超多 ", type, id, sub_id)
    end
    
    return #raiders_info[type][id][sub_id], raiders_info[type][id][sub_id]
end
