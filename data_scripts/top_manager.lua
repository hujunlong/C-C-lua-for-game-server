module ("top_manager", package.seeall)
require('top_db')
global = require('config.global')
local rank = require('config.rank')

local ffi = require('ffi')
local new = ffi.new
local C = ffi.C
local cast = ffi.cast
local sizeof = ffi.sizeof
------------------------------------------------------------------------------------------------------------------------------------------
--const
local kWorshipLevel = 1
local kWorshipSilver = 2
local kWorshipFightingpower = 3
local kWorshipDegreeOfProsperity = 4
local kWorshipGuild = 5
local kUsedWorship = 6
local kIsShow = 1

local guild_worship_list = {} --全部玩家膜拜公会的链表
local other_player_worship_list = {} --全部玩家膜拜其他玩家的链表
local top_data = {} --前100名
local top_silver_old_data = {}
------------------------------------------------------------------------------------------------------------------------------------------
function GetTop(processor_)
	--------------------------------------------------------------------------------------------------------------------------------------
    processor_[C.kGetTop] = function(uid, msg)
        local req = cast('const GetTop&', msg)
		local result = new('GetTopResult')
        
        --获取前100的等级
        if type(top_data) == 'number' then
            print(top_data)
        end
        
        if rank[kWorshipLevel].is_show == kIsShow then
            result.top_level = top_data.top_level
            result.count_level = #top_data.top_level + 1
        end
        
        if rank[kWorshipSilver].is_show == kIsShow then
            result.top_silver = top_data.top_silver
            result.count_silver = #top_data.top_silver + 1
        end
        
        if rank[kWorshipFightingpower].is_show == kIsShow then
            result.top_fightingpower = top_data.top_fightingpower
            result.count_fightingPower = #top_data.top_fightingpower + 1
        end
        
        if rank[kWorshipDegreeOfProsperity].is_show == kIsShow then
            result.top_degree_of_prosperity = top_data.top_degree_of_prosperity
            result.count_degree_of_prosperity = #top_data.top_degree_of_prosperity + 1
        end
        
        if rank[kWorshipGuild].is_show == kIsShow then
            result.top_guild = top_data.top_guild
            if not next(top_data.top_guild) then
                result.count_guild = 0
            else
                result.count_guild = #top_data.top_guild + 1    
            end
        end
         return result,24 + (result.count_level + result.count_silver + result.count_fightingPower + result.count_degree_of_prosperity)*ffi.sizeof(result.top_level[0]) + result.count_guild*ffi.sizeof(result.top_guild[0])
    end
    
    --------------------------------------------------------------------------------------------------------------------------------------
    --自己排名
    processor_[C.kGetPlayerOwnRank] = function(uid, msg)
        local req = cast('const GetPlayerOwnRank&', msg)
		local result = new('GetPlayerOwnRankResult')
        local player_own_rank_data = {}
        player_own_rank_data.player_own_level_rank =  top_db.GetPlayerOwnLevel(uid)
        player_own_rank_data.player_own_fightingpower_rank = top_db.GetPlayerOwnFightingPower(uid)
        player_own_rank_data.player_own_degree_of_prosperity_rank = top_db.GetPlayerOwnDegreeOfProsperity(uid)
        --银币
        for i,player_silver in pairs(top_silver_old_data) do
            if player_silver.player == uid then
                player_own_rank_data.player_own_silver_rank = i
                break
            end
        end
        if not player_own_rank_data.player_own_silver_rank then
            player_own_rank_data.player_own_silver_rank = 0
        end
        
        --公会
        local guild_id = top_db.GetGuild(uid)
        for _,guild_data in pairs(top_data.top_guild) do
            if guild_data.id == guild_id then
                player_own_rank_data.guild_own_rank = guild_data.rank
                break
            end
        end
        result.player_own_level_rank = player_own_rank_data.player_own_level_rank
        result.player_own_silver_rank = player_own_rank_data.player_own_silver_rank
        result.player_own_fightingpower_rank = player_own_rank_data.player_own_fightingpower_rank
        result.player_own_degree_of_prosperity_rank = player_own_rank_data.player_own_degree_of_prosperity_rank
        if not player_own_rank_data.guild_own_rank then
            player_own_rank_data.guild_own_rank = 0
        end
        result.guild_own_rank = player_own_rank_data.guild_own_rank
        return result
    end
    --------------------------------------------------------------------------------------------------------------------------------------
    --自己的膜拜剩余次数与被膜拜次数
    processor_[C.kGetPlayerRemainWorship] = function(uid, msg)
        local req = cast('const GetPlayerRemainWorship&', msg)
		local result = new('GetPlayerRemainWorshipResult')
        local player_worshiped_data = top_db.GetPlayerRemainWorship(uid)
        result.worshiped_level_count = player_worshiped_data.worshiped_level_count
        result.worshiped_silver_count = player_worshiped_data.worshiped_silver_count
        result.worshiped_fightingpower_count = player_worshiped_data.worshiped_fightingpower_count
        result.worshiped_degree_of_prosperity_count = player_worshiped_data.worshiped_degree_of_prosperity_count
        result.remain_worship_count = player_worshiped_data.remain_worship_count
        return result
    end
    --------------------------------------------------------------------------------------------------------------------------------------
    --给别人或者公会添加膜拜
    processor_[C.kGiveOtherAddWorship] = function(uid, msg)
        local req = cast('const GiveOtherAddWorship&', msg)
		local result = new('GiveOtherAddWorshipResult')
        local guild_worship_one = {} 
        local other_player_worship_one = {} 
    
        if req.id <= 0 or req.type <= 0 or req.type > kWorshipGuild then
            result.is_worship_success = false
            return result
        end
        
        if uid == req.id then
            result.result = C.TOP_WORSHIP_THEIR_OWN_ERROR
        end
        
        if req.type == kWorshipGuild then
            if not guild_worship_list[uid] then
                table.insert(guild_worship_one ,{id = req.id,type = req.type} )
                top_db.InsertWorshipList(uid,req.id,req.type)
                guild_worship_list[uid] = guild_worship_one
            else
                if #guild_worship_list[uid] >0 then
                    guild_worship_one = guild_worship_list[uid]
                end
                
                for _,guild_worship_list_ in pairs(guild_worship_list[uid]) do
                    if guild_worship_list_.id == req.id then
                        result.result = C.TOP_GUILD_HAS_WORSHIP_ERROR
                        return result
                    end
                end
                table.insert(guild_worship_one ,{id = req.id,type = req.type} )
                guild_worship_list[uid] = guild_worship_one
                top_db.InsertWorshipList(uid,req.id,req.type)
            end
        else --同一玩家不能膜拜
            if  other_player_worship_list[uid] then
                for _,other_player_worship_ in pairs(other_player_worship_list[uid]) do
                    if other_player_worship_.type == req.type and other_player_worship_.id == req.id then
                        result.result = C.TOP_PLAYER_HAS_WORSHIP_ERROR
                        return result
                    end
                end
                
                if #other_player_worship_list[uid] >0 then
                    other_player_worship_one = other_player_worship_list[uid]
                end
                
                table.insert(other_player_worship_one ,{id = req.id,type = req.type} )
                other_player_worship_list[uid] = other_player_worship_one
                top_db.InsertWorshipList(uid,req.id,req.type)
            else
                table.insert(other_player_worship_one ,{id = req.id,type = req.type} )
                other_player_worship_list[uid] = other_player_worship_one
                top_db.InsertWorshipList(uid,req.id,req.type)
            end
        end
        
        local player_worshiped_data = top_db.GetPlayerRemainWorship(uid)
        local remain_worship_count = player_worshiped_data.remain_worship_count
        if remain_worship_count <= 0 then
            result.is_worship_success = false
            result.result = C.TOP_REMAIN_WORSHIP_ERROR
            return result
        end
        
        player_worshiped_data.remain_worship_count = player_worshiped_data.remain_worship_count - 1
        if req.type == kWorshipLevel then                            --等级排名
            top_db.UpdateDeltaField(req.id,kWorshipLevel)
            UpdateMemoryOfWorshiped(top_data.top_level,req.id)
        elseif req.type == kWorshipSilver then                      --财富排行
            top_db.UpdateDeltaField(req.id,kWorshipSilver)
            UpdateMemoryOfWorshiped(top_data.top_silver,req.id)
        elseif req.type == kWorshipFightingpower then               --战斗力排行 
            top_db.UpdateDeltaField(req.id,kWorshipFightingpower)
            UpdateMemoryOfWorshiped(top_data.top_fightingpower,req.id)
        elseif req.type == kWorshipDegreeOfProsperity  then         --繁荣度排行
            top_db.UpdateDeltaField(req.id,kWorshipDegreeOfProsperity)
            UpdateMemoryOfWorshiped(top_data.top_degree_of_prosperity,req.id)
        elseif req.type == kWorshipGuild  then                        --公会
            top_db.UpdateDeltaField(req.id,kWorshipGuild)
            UpdateMemoryOfWorshiped(top_data.top_guild,req.id)
        end
        result.is_worship_success = true
        top_db.UpdateDeltaField(uid,kUsedWorship)
        
        --添加威望
        local push = new('AddPrestige')
        push.delta = global.top.kAddPrestigeCount
        GlobalSend2Gate(uid,push,sizeof(push))
        return result
    end
    --------------------------------------------------------------------------------------------------------------------------------------
     processor_[C.kGetWorshipList] = function(uid, msg)
        local req = cast('const GetWorshipList&', msg)
		local result = new('GetWorshipListResult')
		local guild_count = 0
		local player_count = 0
		if not guild_worship_list[uid] then
		    guild_count = 0
		else   
            guild_count = #guild_worship_list[uid] 
		end
	         
        if guild_count > 0 then
            for i,guild_worship_ in pairs(guild_worship_list[uid]) do
                result.data[i-1].id = guild_worship_.id
                result.data[i-1].type = guild_worship_.type
            end
        end    
        
        if not other_player_worship_list[uid] then
		    player_count = 0
		else
            player_count = #other_player_worship_list[uid]    
		end
		
        if player_count > 0 then
            for i,other_player_worship_ in pairs(other_player_worship_list[uid]) do
                result.data[i-1 + guild_count].id = other_player_worship_.id
                result.data[i-1 + guild_count].type = other_player_worship_.type
            end
        end
        result.count = guild_count + player_count    
        return result ,8 + result.count*8 
     end
    --------------------------------------------------------------------------------------------------------------------------------------
end

------------------------------------------------------------------------------------------------------------------------------------------
--global function
------------------------------------------------------------------------------------------------------------------------------------------
function SelectWoshipListTable()
--获取玩家膜拜公会和其他玩家的链表
    guild_worship_list,other_player_worship_list = top_db.SelectWoshipListTable(guild_worship_list,other_player_worship_list)
end
------------------------------------------------------------------------------------------------------------------------------------------
--更改膜拜的内存
function UpdateMemoryOfWorshiped(top_100_type,id)
    for _,top_ in pairs(top_100_type) do
        if top_.id == id then
            top_.worshiped_count = top_.worshiped_count + 1
            break
        end
    end
end
------------------------------------------------------------------------------------------------------------------------------------------
--重置每天的膜拜
function DayWorshipReset()
    top_db.ReSetPlayerWorship()
    top_db.DeleteWoshipListTable()     
    --一天更新一次
    guild_worship_list = {}
    other_player_worship_list = {}
end
------------------------------------------------------------------------------------------------------------------------------------------
function InitTop()
    --获取排名前100的玩家
    if rank[kWorshipLevel].is_show == kIsShow then
        top_data.top_level = top_db.GetLevelTop()
    end
    
    if rank[kWorshipSilver].is_show == kIsShow then
        top_data.top_silver = top_db.GetSilverTop()
    end
    
    if rank[kWorshipFightingpower].is_show == kIsShow then
        top_data.top_fightingpower = top_db.GetFightingPowerTop()
    end
    
    if rank[kWorshipDegreeOfProsperity].is_show == kIsShow then
        top_data.top_degree_of_prosperity = top_db.GetDegreeOfProsperityTop()
    end
    
    if rank[kWorshipGuild].is_show == kIsShow then
        top_data.top_guild = top_db.GetGuildTop() 
    end
end
------------------------------------------------------------------------------------------------------------------------------------------
function InitSilverTop()
    if rank[kWorshipSilver].is_show == kIsShow then
        top_data.top_silver = {}
        top_data.top_silver = top_db.GetSilverTop()
    end
end
------------------------------------------------------------------------------------------------------------------------------------------
function InitTopExceptSilver()
    --获取排名前100的玩家
    if rank[kWorshipLevel].is_show == kIsShow then
        top_data.top_level = top_db.GetLevelTop()
    end
        
    if rank[kWorshipFightingpower].is_show == kIsShow then
        top_data.top_fightingpower = top_db.GetFightingPowerTop()
    end
    
    if rank[kWorshipDegreeOfProsperity].is_show == kIsShow then
        top_data.top_degree_of_prosperity = top_db.GetDegreeOfProsperityTop()
    end
    
    if rank[kWorshipGuild].is_show == kIsShow then
        top_data.top_guild = top_db.GetGuildTop() 
    end
end
------------------------------------------------------------------------------------------------------------------------------------------
--更新排名数据库表
function UpdateRankDataTable()
    top_db.RankLevel()
    top_silver_old_data = {}
    top_silver_old_data = top_db.RankSilver()
    top_db.RankFightingPower()
    top_db.RankDegreeOfProsperity()
end
------------------------------------------------------------------------------------------------------------------------------------------
--更新排名数据库表除银币外
function UpdateRankDataTableExceptSilver()
    top_db.RankLevel()
    top_db.RankFightingPower()
    top_db.RankDegreeOfProsperity()
end
------------------------------------------------------------------------------------------------------------------------------------------
function UpdateRankDataTableSilver()
    top_silver_old_data = {}
    top_silver_old_data = top_db.RankSilver()
end
------------------------------------------------------------------------------------------------------------------------------------------
local global_flag_head_ = new('MqHead', 0, 0, -1)
function GlobalSend2Gate(player,msg,len)
    global_flag_head_.aid = player
    global_flag_head_.type = msg.kType
    C.Send2Gate(global_flag_head_, msg, len or sizeof(msg))
end
------------------------------------------------------------------------------------------------------------------------------------------