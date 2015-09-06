local global = require('config.global')
module('top_db', package.seeall)
local ffi = require("ffi")
local new = ffi.new
local sizeof = ffi.sizeof
----------------------------------------------------------------------------------------------------------------------------------------------------
--const
local kWorshipLevel = 1
local kWorshipSilver = 2
local kWorshipFightingpower = 3
local kWorshipDegreeOfProsperity = 4
local kWorshipGuild = 5
local kUsedWorship = 6
local kSelectMaxNum = 100 --查询最大值
local kTotalNumber = 1000 --排名前1000名的
----------------------------------------------------------------------------------------------------------------------------------------------------
--
function Initialize(connection)
	conn = connection
	conn:query("set names 'utf8'")
end

----------------------------------------------------------------------------------------------------------------------------------------------------
function RankLevel()
    local nickname = nil
    local res = conn:query('select base_info.player,base_info.level,misc_info.worshiped_level_count ,base_info.silver,misc_info.worshiped_silver_count, misc_info.fight_power,misc_info.worshiped_fightingpower_count,misc_info.degree_of_prosperity,worshiped_degree_of_prosperity_count,base_info.nickname from base_info,misc_info where base_info.player = misc_info.player order by base_info.level desc,misc_info.worshiped_level_count desc limit '..kTotalNumber)

    --查看是否创建了数据
    conn:query('delete  from top_rank')  
    for i,_res in pairs(res) do
        nickname = ffi.string(_res.nickname,ffi.sizeof(_res.nickname))
        conn:query('insert into top_rank(player,rank_level,level_num,worshiped_level_count,rank_silver,silver_num,worshiped_silver_count,rank_fightingpower,fightingpower_num,worshiped_fightingpower_count, rank_degree_of_prosperity,degree_of_prosperity_num,worshiped_degree_of_prosperity_count,nickname) values('.._res.player..','..i..','.._res.level..','.._res.worshiped_level_count..',1001,'.._res.silver..','.._res.worshiped_silver_count..',1001,'.._res.fight_power..','.._res.worshiped_fightingpower_count..',1001,'.._res.degree_of_prosperity..','.._res.worshiped_degree_of_prosperity_count..',\''..nickname..'\')')
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function RankSilver()
    local res = conn:query('select player from top_rank order by silver_num desc,worshiped_silver_count desc limit '..kTotalNumber)

    for i,_res in pairs(res) do
        conn:query('update top_rank set rank_silver = '..i..' where player = '.._res.player)
    end
    return res
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function RankFightingPower()
    local res = conn:query('select player from top_rank order by fightingpower_num desc,worshiped_fightingpower_count desc limit '..kTotalNumber)

    for i,_res in pairs(res) do
        conn:query('update top_rank set rank_fightingpower = '..i..' where player = '.._res.player)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------
function RankDegreeOfProsperity()
    local res = conn:query('select player from top_rank order by degree_of_prosperity_num desc,worshiped_degree_of_prosperity_count desc limit '..kTotalNumber)

    for i,_res in pairs(res) do
        conn:query('update top_rank set rank_degree_of_prosperity = '..i..' where player = '.._res.player)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function GetLevelTop()
    local top_level = {}
    local res = conn:query('select player,rank_level,level_num,worshiped_level_count,nickname from top_rank order by rank_level limit '..kSelectMaxNum)

    for i,_res in pairs(res) do
        local result = new("TopStruct")
        result.rank = _res.rank_level
        result.rank_data = _res.level_num
        result.worshiped_count = _res.worshiped_level_count
        result.id = _res.player
        result.lenth = sizeof(_res.nickname)
        ffi.copy(result.nickname,_res.nickname,result.lenth)
        top_level[i-1] = result 
    end
    return top_level
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function GetSilverTop()
    local top_silver = {}
    local res = conn:query('select player,rank_silver,silver_num,worshiped_silver_count,nickname from top_rank order by rank_silver limit '..kSelectMaxNum)

    for i,_res in pairs(res) do
        local result = new("TopStruct")
        result.rank = _res.rank_silver
        result.rank_data = _res.silver_num
        result.worshiped_count = _res.worshiped_silver_count
        result.id = _res.player
        result.lenth = sizeof(_res.nickname)
        ffi.copy(result.nickname,_res.nickname,result.lenth)
        top_silver[i-1] = result 
    end
    return top_silver
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function GetFightingPowerTop()
    local top_fightingPower = {}
    local res = conn:query('select player,rank_fightingpower,fightingpower_num,worshiped_fightingpower_count,nickname from top_rank order by rank_fightingpower limit '..kSelectMaxNum)

    for i,_res in pairs(res) do
        local result = new("TopStruct")
        result.rank = _res.rank_fightingpower
        result.rank_data = _res.fightingpower_num
        result.worshiped_count = _res.worshiped_fightingpower_count
        result.id = _res.player
        result.lenth = sizeof(_res.nickname)
        ffi.copy(result.nickname,_res.nickname,result.lenth)
        top_fightingPower[i-1] = result 
    end
    return top_fightingPower
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function GetDegreeOfProsperityTop()
    local top_degree_of_prosperity = {}
    local res = conn:query('select player,rank_degree_of_prosperity,degree_of_prosperity_num,worshiped_degree_of_prosperity_count,nickname from top_rank order by rank_degree_of_prosperity limit '..kSelectMaxNum)

    for i,_res in pairs(res) do
        local result = new("TopStruct")
        result.rank = _res.rank_degree_of_prosperity
        result.rank_data = _res.degree_of_prosperity_num
        result.worshiped_count = _res.worshiped_degree_of_prosperity_count
        result.id = _res.player
        result.lenth = sizeof(_res.nickname)
        ffi.copy(result.nickname,_res.nickname,result.lenth)
        top_degree_of_prosperity[i-1] = result 
    end
    return top_degree_of_prosperity
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function GetGuildTop()
    local top_guild = {}
    local res = conn:query("select guild_id,level,name,worshiped_guild_count from guild order by level desc,worshiped_guild_count desc limit "..kSelectMaxNum)

    for i,_res in pairs(res) do
        local result = new("TopStructGuild")
        result.rank = i
        result.rank_data = _res.level
        result.worshiped_count = _res.worshiped_guild_count
        result.id = _res.guild_id
        result.lenth = sizeof(_res.name)
        ffi.copy(result.nickname,_res.name,result.lenth)
        top_guild[i-1] = result 
    end
    return top_guild
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--获取自己玩家等级排名
function GetPlayerOwnLevel(player_id)
     local player_own_level_rank = nil
     local res = conn:query('select rank_level from top_rank where player = '..player_id)
     if not next(res) then
        player_own_level_rank = 0
     else
        player_own_level_rank = res[1].rank_level
     end
     return player_own_level_rank 
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--获取自己银币排名
function GetPlayerOwnSilver(player_id)
    local player_own_silver_rank = nil
    local res = conn:query('select rank_silver from top_rank where player = '..player_id)
    if not next(res) then
        player_own_silver_rank = 0
     else
        player_own_silver_rank = res[1].rank_silver
     end
    return player_own_silver_rank 
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--获取自己战斗力
function GetPlayerOwnFightingPower(player_id)
    local player_own_fightingpower_rank = nil
    local res = conn:query('select rank_fightingpower from top_rank where player = '..player_id)
    if not next(res) then
        player_own_fightingpower_rank = 0
     else
        player_own_fightingpower_rank = res[1].rank_fightingpower
     end
    return player_own_fightingpower_rank
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--获取自己繁荣度
function GetPlayerOwnDegreeOfProsperity(player_id)
    local worshiped_degree_of_prosperity_rank = nil
    
    local res = conn:query('select rank_degree_of_prosperity from top_rank where player = '..player_id)
    if not next(res) then
        worshiped_degree_of_prosperity_rank = 0
     else
        worshiped_degree_of_prosperity_rank = res[1].rank_degree_of_prosperity
     end
     
    return worshiped_degree_of_prosperity_rank
end

----------------------------------------------------------------------------------------------------------------------------------------------------
--获取自己公会排名
function GetGuild(player_id)
    local res = conn:query('select guild_id from base_info where player = '..player_id)
    if not next(res)  then
        return 0
    else
        return res[1].guild_id 
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--获取玩家的膜拜次数
function GetPlayerRemainWorship(player_id)
    local player_worshiped_data = {}
    local res = conn:query('select worshiped_degree_of_prosperity_count,worshiped_level_count,worshiped_silver_count,worshiped_fightingpower_count,used_worship_count from misc_info where player = '..player_id)
    if not next(res) then
        player_worshiped_data.worshiped_level_count = 0
        player_worshiped_data.worshiped_silver_count = 0
        player_worshiped_data.worshiped_fightingpower_count = 0
        player_worshiped_data.worshiped_degree_of_prosperity_count = 0
        player_worshiped_data.remain_worship_count = 0
    else
        player_worshiped_data.worshiped_level_count = res[1].worshiped_level_count
        player_worshiped_data.worshiped_silver_count = res[1].worshiped_silver_count
        player_worshiped_data.worshiped_fightingpower_count = res[1].worshiped_fightingpower_count
        player_worshiped_data.worshiped_degree_of_prosperity_count = res[1].worshiped_degree_of_prosperity_count
        player_worshiped_data.remain_worship_count = global.top.kMaxWorshipCount -res[1].used_worship_count
    end
    return player_worshiped_data
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--添加对应玩的膜拜次数
function UpdateDeltaField(id,type)
   
    if kWorshipLevel == type then
         conn:query('update misc_info set worshiped_level_count = (worshiped_level_count + 1) where player = '..id)
    elseif kWorshipSilver == type then
         conn:query('update misc_info set worshiped_silver_count = (worshiped_silver_count + 1) where player = '..id)
    elseif kWorshipFightingpower == type then
         conn:query('update misc_info set worshiped_fightingpower_count = (worshiped_fightingpower_count + 1) where player = '..id)
    elseif kWorshipDegreeOfProsperity == type then
         conn:query('update misc_info set worshiped_degree_of_prosperity_count = (worshiped_degree_of_prosperity_count + 1) where player = '..id)
    elseif kWorshipGuild == type then
         conn:query('update guild set worshiped_guild_count = (worshiped_guild_count + 1) where guild_id = '..id)
    elseif kUsedWorship == type then
         conn:query('update misc_info set used_worship_count = (used_worship_count + 1) where player = '..id)
    else
        print('update misc_info type error')
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------
 function ReSetPlayerWorship()
    conn:query('update misc_info set used_worship_count = 0')
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function InsertWorshipList(player_id,worshiped_id,type)
    conn:query('insert player_worship_list(player,worshiped_id,type) values('..player_id..','..worshiped_id..','..type..')')
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function DeleteWoshipListTable()
    conn:query('delete from player_worship_list')
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function ResetWorship()
    conn:query('update misc_info set worshiped_silver_count = 0,worshiped_fightingpower_count = 0,worshiped_degree_of_prosperity_count =0,worshiped_level_count = 0')
    conn:query('update top_rank set worshiped_silver_count = 0,worshiped_fightingpower_count = 0,worshiped_degree_of_prosperity_count =0,worshiped_level_count = 0')
    conn:query('update guild set worshiped_guild_count = 0')
end
----------------------------------------------------------------------------------------------------------------------------------------------------
function SelectWoshipListTable()
    local guild_worship_list = {}
    local other_player_worship_list = {}
    local res = conn:query('Select player, worshiped_id, type from player_worship_list')
    local buff_worship_guild = {}
    local buff_worship_player = {}
    for _,worship_data in pairs(res) do
        if worship_data.type == kWorshipGuild then
            buff_worship_guild[worship_data.player] = {}
        else
            buff_worship_player[worship_data.player] = {}
        end
    end
    for _,_res in pairs(res) do
        if _res.type == kWorshipGuild  then
            table.insert(buff_worship_guild[_res.player],{id = _res.worshiped_id,type = _res.type})
        else
            table.insert(buff_worship_player[_res.player],{id = _res.worshiped_id,type = _res.type})
        end
    end
    guild_worship_list = buff_worship_guild
    other_player_worship_list = buff_worship_player
    return guild_worship_list,other_player_worship_list
end
----------------------------------------------------------------------------------------------------------------------------------------------------