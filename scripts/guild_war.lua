module("guild_war",package.seeall)
require('guild')
require('data')
require('global_data')

local guild_war_maps = require('config.guild_war_maps')
local global = require('config.global')
local guild_war_fields = require('config.guild_war_fields')
local guild_war_fields_technology = require('config.guild_war_fields_technology')
local charset = require('config.charset')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local previous_guild = {}
local guilds = guild.GetGuilds()
---------------------------------------------------------------------------------------------------------------------------------------------  
--工会战定时消息
local GUILDWARSTEP = 
{
	PEACE = 1,																									--休战期
	SIGN_UP = 2,																								--报名期
	PREPARE = 3,																								--1天准备期
	ENTER = 4,																									--进入战场等待开战
	WARING = 5,																									--开战
}

--星期
local WEEK =                                                                                                   
{
    ['1'] = '一',
    ['2'] = '二',
    ['3'] = '三',
    ['4'] = '四',
    ['5'] = '五',
    ['6'] = '六',
    ['7'] = '星期天',
}                                                                                  
local guild_war_timer = nil                                                                                          --工会战逻辑Timer
local guild_war_end_timer = nil                                                                                   --公会战结束时候用来清除内存数据
----------------------------------------------------------------------------------------------
function GetWarField(guild_id, war_field_id)
	local guild_war_field = guild_war_fields[war_field_id]
	if guild_war_field then
		if guild_war_field.attack_guild_id == guild_id and guild_war_field.attack_guild_id ~= 0 then
			return guild_war_field, 1			--1 进攻方
		end
		
		if guild_war_field.defense_guild_id == guild_id and guild_war_field.defense_guild_id ~= 0 then
			return guild_war_field, 0			--0 防守方
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--取战场信息(箱子配置、战场类型、战场地图ID 等)
function GetWarFieldInfo(war_field_id)
	return guild_war_fields[war_field_id]
end
---------------------------------------------------------------------------------------------------------------------------------------------
--取战场科技信息
function GetWarFieldTechnology(war_field_id, technology_level)
	for _,technology in pairs(guild_war_fields_technology) do
	    if technology.war_field_id==war_field_id and technology.technology_level==technology_level then
			return technology
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--取战场地图信息(路点信息 等)
function GetWarFieldMapInfo(war_field_id)
	local guild_war_field = guild_war_fields[war_field_id]
	if guild_war_field then
		local field_map_id = guild_war_field.field_map_id
		return guild_war_maps[field_map_id]
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function GetGuildWarMaps()
    return guild_war_maps
end
---------------------------------------------------------------------------------------------------------------------------------------------
function GetGuildWarStep()
    return guild_war_step
end
---------------------------------------------------------------------------------------------------------------------------------------------
--推送消息给战场成员
local function PushGuildWarLocationMembersInfo(guild_war_field, push, bytes)
	for _,member_info in pairs(guild_war_field.defense_member_list) do											--依次推送给所有防守方成员
		GlobalSend2Gate(member_info.player_id, push, bytes)
	end
	
	for _,member_info in pairs(guild_war_field.attack_member_list) do											--依次推送给所有进攻方成员
		GlobalSend2Gate(member_info.player_id, push, bytes)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--获取玩家离开战场时候的所在点位置
function FindFighterLocation(guild_war_field, player_id)
    for _,fighter in pairs(guild_war_field.attack_member_list) do
        if fighter.player_id == player_id then
            return fighter.location
        end
    end
    for _,fighter in pairs(guild_war_field.defense_member_list) do
        if fighter.player_id == player_id then
            return fighter.location
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------    
--清除离开玩家的路点数据
local function DeleteLocationData(guild_war_field, player_id)
    local location = FindFighterLocation(guild_war_field, player_id)
    if not location then 
        return
    end
    local push = new('PushGuildWarLocationMembersInfo')
    push.count = 1
    push.location_info[0].location = location
    push.location_info[0].attack_count = 0
    push.location_info[0].defense_count = 0
    push.location_info[0].camp = 2
    local location_info_len = sizeof(push.location_info[0])
    PushGuildWarLocationMembersInfo(guild_war_field, push,location_info_len + 4)   
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--离开公会战场
function LeaveGuildWarField(player)
	if player.GetGuildId()==0 then																				--未在公会中
		return
	end
    
    if guild_war_step <= 3 then
        return
    end
    
	for _,guild_war_field in pairs(guild_war_fields) do
		--清除点信息
		DeleteLocationData(guild_war_field,player.GetUID())
        --遍历四个链表 删除player
		local attack_member_list = guild_war_field.attack_member_list		
		local attack_member_order_list = guild_war_field.attack_member_order_list
		local defense_member_list = guild_war_field.defense_member_list
		local defense_member_order_list = guild_war_field.defense_member_order_list
		
        for i,fighter in pairs(attack_member_list) do
			if fighter.player_id == player.GetUID() then
				table.remove(attack_member_list, i)
                --推送给对应方等待的玩家
                local push = new('PushGuildEnterAndOrderNum')
                push.enter_num = #attack_member_list
			    push.order_num = #attack_member_order_list
               for _,attck_player in pairs(attack_member_order_list) do
                    GlobalSend2Gate(attck_player.player_id,push)
               end
               --保存退出玩家信息
               local is_add = false
               for _,leave_attack_players_ in pairs(guild_war_field.leave_attack_players) do
                    if leave_attack_players_.player_id == fighter.player_id then
                        is_add = true
                        break
                    end
               end
               if not is_add then
                    table.insert(guild_war_field.leave_attack_players,fighter)
               end               
			end
		end
    
        for i,fighter in pairs(attack_member_order_list) do
            if fighter.player_id == player.GetUID() then
                local push = new('PushPlayerLeaveGuildWarField')
                push.enter_count = #attack_member_list															--进入战场人数
        
                local index = i + 1
                for _i=index,#attack_member_order_list do
                    push.order_count = _i - 1																	--前面排队的人数
                    local _fighter = attack_member_order_list[_i]
                    push.enter_time = attack_member_order_list[_i].order_time + global.guild.kQueueTime*push.order_count	
                    GlobalSend2Gate(_fighter.player_id, push)												--消息通知自己后面的排队玩家重新计时
                end
                table.remove(attack_member_order_list, i)														--删除掉线玩家
                break
            end	
        end
        
		for i,fighter in pairs(defense_member_list) do
			if fighter.player_id == player.GetUID() then
				table.remove(defense_member_list, i)
                --推送给对应方等待的玩家
                local push = new('PushGuildEnterAndOrderNum')
               push.enter_num = #defense_member_list
			   push.order_num = #defense_member_order_list
               for _,defense_player in pairs(defense_member_order_list) do
                    GlobalSend2Gate(defense_player.player_id,push)
               end                  
				--保存退出玩家信息
                local is_add = false
               for _,leave_defense_players_ in pairs(guild_war_field.leave_defense_players) do
                    if leave_defense_players_.player_id == fighter.player_id then
                        is_add = true
                        break
                    end
               end
               if not is_add then
                    table.insert(guild_war_field.leave_defense_players,fighter)
               end 
			end	
		end
		
        for i,fighter in pairs(defense_member_order_list) do
            if fighter.player_id == player.GetUID() then
                local push = new('PushPlayerLeaveGuildWarField')
                push.enter_count = #defense_member_list															--进入战场人数
                
                local index = i + 1
                for _i=index,#defense_member_order_list do
                    push.order_count = _i - 1																	--前面排队的人数
                    local _fighter = defense_member_order_list[_i]
                    push.enter_time = defense_member_order_list[_i].order_time + global.guild.kQueueTime*push.order_count
                    GlobalSend2Gate(_fighter.player_id, push)												--消息通知自己后面的排队玩家重新计时
                end
                table.remove(defense_member_order_list, i)	
                break
           end	
        end	
	end	
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--是否已经开战
function IsWaring()
	return  guild_war_step == GUILDWARSTEP.WARING 
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--能否进入战场
function CanEnter()
	return  guild_war_step == GUILDWARSTEP.ENTER or guild_war_step == GUILDWARSTEP.WARING 
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--能否报名
function CanSign()
	return guild_war_step == GUILDWARSTEP.SIGN_UP
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--是否是资源点
local function IsResourceLocation(war_field_map_info, target_location)
	for _,resource_location in pairs(war_field_map_info.resource_locations) do
		if resource_location == target_location then
			return true
		end
	end
	return false	
end	
---------------------------------------------------------------------------------------------------------------------------------------------
--添加箱子
local function AddBox(giving,war_field_id,guild_id,box_type,guild_box_count)
    	GlobalInsertRow(C.ktGuildGiving,{C.kfGuildWarId, war_field_id},{C.kfGuildId,guild_id},{C.kfGuildCount,guild_box_count},{C.kfBoxType,box_type})  
        local box = {}
        box.guild_count = guild_box_count 
        box.box_type = box_type
        box.guild_war_id = war_field_id
        table.insert(giving,box)
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--工会战胜利,发放奖励箱子
local function AwardGuildBox(war_field_id,guild_war_field)
	local is_add_fight_box = false
    local is_add_guild_box = false
    
    if guild_war_field.guild_id == 0 then
	    return 
	end
	
    local guild = guilds[guild_war_field.guild_id]
    local fight_box_count = 0
    local fight_box_type = 0
	
	if guild then
        --领地科技增加公会宝箱个数
		local war_field_technology = GetWarFieldTechnology(war_field_id, guild_war_field.technology_level)		
        if war_field_technology and guild_war_field.fight_box_count then
			if not war_field_technology.add_guild_box_count then
                fight_box_count = guild_war_field.fight_box_count + (war_field_technology.add_guild_box_count or 0)
            else  
                fight_box_count = guild_war_field.fight_box_count
            end   
           fight_box_type = guild_war_field.fight_box_type            
		end
        --数据库无对应数据
		if #guild.giving == 0 then 
            AddBox(guild.giving,war_field_id,guild_war_field.guild_id,fight_box_type,fight_box_count)
            AddBox(guild.giving,war_field_id,guild_war_field.guild_id,guild_war_field.guild_box_type,0)
            is_add_guild_box = true
		else
			for _,box in pairs(guild.giving) do   
				if box.box_type == guild_war_field.fight_box_type and box.guild_war_id == war_field_id  then
                    db.UpdateGuildGiving(war_field_id,guild_war_field.guild_id,fight_box_count + box.guild_count,guild_war_field.fight_box_type)
                    box.guild_count = fight_box_count + box.guild_count
                    is_add_fight_box = true
                    break
                elseif box.box_type == guild_war_field.guild_box_type and box.guild_war_id == war_field_id then
                    is_add_guild_box = true
                    break
                end
			end
            
            --如果改了配置文件 需要添加到数据库中
            if not is_add_fight_box then
                AddBox(guild.giving,war_field_id,guild_war_field.guild_id,fight_box_type,fight_box_count)
            end
            if not is_add_guild_box then
                AddBox(guild.giving,war_field_id,guild_war_field.guild_id,guild_war_field.guild_box_type,0)
            end
		end	
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--推送玩家信息
function GuildWarLocationMembersInfo(locations)
	for war_field_id,guild_war_field in pairs(guild_war_fields) do
		if guild_war_field.field_type==1 then																	 
			local war_field_map_info = GetWarFieldMapInfo(war_field_id) 		-- 取具体地图信恿
			if war_field_map_info and guild_war_field.attack_guild_id ~=0 and guild_war_field.defense_guild_id~=0 then		
				local push = new('PushGuildWarLocationMembersInfo')
                local attack_count = 0
                local defense_count = 0
                
                for i,location in pairs(locations) do
					push.location_info[i-1].location = location
					for _,member in pairs(guild_war_field.attack_member_list) do 								 
						if member.location == location then
							attack_count = attack_count + 1
						end
					end
			
					for _,member in pairs(guild_war_field.defense_member_list) do
						if member.location == location then
							defense_count = defense_count + 1
						end
					end
					
					push.location_info[i-1].attack_count = attack_count
					push.location_info[i-1].defense_count = defense_count
					
					local location_camp = guild_war_field.takedown_location_list[location] 						 
					if location_camp then
						push.location_info[i-1].camp = location_camp
					else
						push.location_info[i-1].camp = 2 
					end
				
					push.count = 2
					local location_info_len = sizeof( push.location_info[0] )
					PushGuildWarLocationMembersInfo(guild_war_field, push, 2 * location_info_len + 4 )
					defense_count = 0
					attack_count = 0
				end
		    end
        end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--公会战timer,根据不同的工会战实现不同的逻辑,目前只有一种资源争夺战
 function GuildWarTimer()
	for war_field_id,guild_war_field in pairs(guild_war_fields) do
        local attack_locations=0																		--进攻方占领点数
	    local defense_locations=0																		--防守方占领点数
    	local pushResouce = new("PushGuildWarResource") 											    --获取资源
        local pushDefenseWinItem = new("PushGuildWarWinItem")                                          --防守方
        local pushAttackWinItem = new("PushGuildWarWinItem")                                           --进攻方
        local is_push_success = false  
        
		local war_field_map_info = GetWarFieldMapInfo(war_field_id) 
		for location,camp in pairs(guild_war_field.takedown_location_list) do
			if IsResourceLocation(war_field_map_info, location) then 
				if camp == 0 then
					defense_locations = defense_locations + 1
				elseif camp == 1 then
					attack_locations = attack_locations + 1
				end
			end
		end
		
		--根据占领资源点个数计算增加资源
		local attack_add_resource = attack_locations>=5 and 2*(10*attack_locations) or 10*attack_locations
		local defense_add_resource = defense_locations>=5 and 2*(10*defense_locations) or 10*defense_locations
		
		--双方公会同时获得1600点资源点时防守方优先获胜
        --推送资源
        if (guild_war_field.defense_resource <= global.guild.kResourcePorts) and (guild_war_field.attack_resource <= global.guild.kResourcePorts) then
            guild_war_field.defense_resource = guild_war_field.defense_resource + defense_add_resource
            guild_war_field.attack_resource = guild_war_field.attack_resource + attack_add_resource
            if guild_war_field.defense_resource >= global.guild.kResourcePorts then
                pushResouce.defenseResourceNum = global.guild.kResourcePorts
                pushResouce.attackResourceNum = guild_war_field.attack_resource
                is_push_success = true
         
            elseif guild_war_field.attack_resource >= global.guild.kResourcePorts then
                pushResouce.attackResourceNum =  global.guild.kResourcePorts
                pushResouce.defenseResourceNum = guild_war_field.defense_resource
                is_push_success = true
            else
                pushResouce.attackResourceNum =  guild_war_field.attack_resource
                pushResouce.defenseResourceNum = guild_war_field.defense_resource
            end
            PushGuildWarLocationMembersInfo(guild_war_field, pushResouce, sizeof(pushResouce))
     
		end
        
        --推送胜利
        if is_push_success then
            if guild_war_field.defense_resource >= global.guild.kResourcePorts then
                pushDefenseWinItem.isWinner = 1
                pushAttackWinItem.isWinner = 0
                guild_war_field.guild_id = guild_war_field.defense_guild_id
                AwardGuildBox(war_field_id,guild_war_field)
                guild_war_field.is_giving = 1
            end
            if guild_war_field.attack_resource >= global.guild.kResourcePorts then
                pushDefenseWinItem.isWinner = 0
                pushAttackWinItem.isWinner = 1	
                guild_war_field.guild_id = guild_war_field.attack_guild_id
                AwardGuildBox(war_field_id,guild_war_field)
                guild_war_field.is_giving = 1	
            end
 
            if guild_war_field.defense_resource >= global.guild.kResourcePorts or guild_war_field.attack_resource>= global.guild.kResourcePorts then
                local guilds = guild.GetGuilds()
                local attack_guild = guilds[guild_war_field.attack_guild_id]
                local defense_guild = guilds[guild_war_field.defense_guild_id]
                local online_players = guild.GetOnlinePlayers()
                
                for _,player in pairs(defense_guild.members_info) do
                    local player_id = player.player_id
                    if online_players[player_id] ~= nil then
                        GlobalSend2Gate(player_id, pushDefenseWinItem, sizeof(pushDefenseWinItem))
                    end
                end
                
                for _,player in pairs(attack_guild.members_info) do
                    local player_id = player.player_id
                    if online_players[player_id] ~= nil then
                        GlobalSend2Gate(player_id, pushAttackWinItem, sizeof(pushAttackWinItem))
                    end
                end
            
            end
        end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--公会战斗开始,相关逻辑处理(战斗时长30分钟)
function GuildWarBegin()
	guild_war_step = GUILDWARSTEP.WARING 																		--开战
    guild_war_timer = ffi.CreateTimer(GuildWarTimer, global.guild.kGuildWarRefreshTime)						--公会战timer
    data.SetActionStamp(action_type.guild_war,guild_war_step)
end
---------------------------------------------------------------------------------------------------------------------------------------------  
--工会战走马灯提示
function GuildWarRemindFirstAndSecond()
    local GuildWar = new('GenericNotify')
    local kGuildWarEnterTime = string.sub(global.guild.kGuildWarEnterTime,1,-1)   
    local kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
    local kGuildWarEndTime = string.sub(global.guild.kGuildWarEndTime,1,-1)
    local guild_war_remind_str1 = string.format(charset.guild_war_remind_str1, kGuildWarBeingTime,kGuildWarEnterTime,kGuildWarBeingTime)
    GuildWar.data =  guild_war_remind_str1
    GuildWar.len = string.len(guild_war_remind_str1) + string.len(kGuildWarEnterTime) + string.len(kGuildWarBeingTime) + string.len(kGuildWarEndTime) 
    GlobalSend2Gate(-1, GuildWar)
    
    local system_msg = new ('SystemMsg')
    system_msg.msg_len = string.len(guild_war_remind_str1)
    system_msg.msg = guild_war_remind_str1
    GlobalSend2Gate(-1, system_msg)
end

function GuildWarRemindThirdAndFour()
    local GuildWar = new('GenericNotify')
    local kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
    local guild_war_remind_str2 = string.format(charset.guild_war_remind_str2,kGuildWarBeingTime,kGuildWarBeingTime)
    GuildWar.data = guild_war_remind_str2
    GuildWar.len = string.len(guild_war_remind_str2) + string.len(kGuildWarBeingTime)
    GlobalSend2Gate(-1, GuildWar)
    
    local system_msg = new ('SystemMsg')
    system_msg.msg_len = string.len(guild_war_remind_str2)
    system_msg.msg = guild_war_remind_str2
    GlobalSend2Gate(-1, system_msg)
end

function GuildWarRemindFive()
    local GuildWar = new('GenericNotify')
    GuildWar.data = charset.guild_war_remind_str3
    GuildWar.len = string.len(charset.guild_war_remind_str3)
    GlobalSend2Gate(-1, GuildWar)
    
    local system_msg = new ('SystemMsg')
    system_msg.msg_len = string.len(charset.guild_war_remind_str3)
    system_msg.msg = charset.guild_war_remind_str3
    GlobalSend2Gate(-1, system_msg)
end

function GuildWarNotificationOfRegistration()
    local GuildWar = new('GenericNotify')
    GuildWar.data = charset.guild_war_notification_of_registration
    GuildWar.len = string.len(charset.guild_war_notification_of_registration)
    GlobalSend2Gate(-1, GuildWar)
    
    local system_msg = new ('SystemMsg')
    system_msg.msg_len = string.len(charset.guild_war_notification_of_registration)
    system_msg.msg = charset.guild_war_notification_of_registration
    GlobalSend2Gate(-1, system_msg)
end
--------------------------------------------------------------------------------------------------------------------------------------------- 
function GuildWarSignUp()
	guild_war_step = GUILDWARSTEP.SIGN_UP
	data.SetActionStamp(action_type.guild_war,guild_war_step)
end
--------------------------------------------------------------------------------------------------------------------------------------------- 
function GuildWarEnd()
	guild_war_step = 2
    data.SetActionStamp(action_type.guild_war,guild_war_step)
 
    local pushDefenseWinItem = new("PushGuildWarWinItem")                                         
	local pushAttackWinItem = new("PushGuildWarWinItem")                                          
    --删除报名列表
    db.DeleteSighList()
    for war_field_id,guild_war_field in pairs(guild_war_fields) do
        guild_war_field.sign_list = {}
        --推送战斗结果
        if (guild_war_field.defense_guild_id ~= nil and guild_war_field.defense_guild_id ~= 0 ) and (guild_war_field.attack_guild_id ~= nil and guild_war_field.attack_guild_id  ~= 0) then --只要有一方就可以判断
            if guild_war_field.defense_resource < guild_war_field.attack_resource  then
                pushDefenseWinItem.isWinner = 0
                pushAttackWinItem.isWinner = 1
                guild_war_field.guild_id = guild_war_field.attack_guild_id
            elseif guild_war_field.defense_resource == guild_war_field.attack_resource and guild_war_field.guild_id  == 0 then
                pushDefenseWinItem.isWinner = 2
                pushAttackWinItem.isWinner = 2
                guild_war_field.guild_id = 0
            else
                pushDefenseWinItem.isWinner = 1
                pushAttackWinItem.isWinner = 0
                guild_war_field.guild_id = guild_war_field.defense_guild_id
            end
            for _,member_info in pairs(guilds[guild_war_field.defense_guild_id].members_info) do											
                GlobalSend2Gate(member_info.player_id, pushDefenseWinItem, sizeof(pushDefenseWinItem))
            end
            for _,member_info in pairs(guilds[guild_war_field.attack_guild_id].members_info) do											 
                GlobalSend2Gate(member_info.player_id, pushAttackWinItem, sizeof(pushAttackWinItem))
            end
        end

        if guild_war_field.defense_guild_id ~= nil and guild_war_field.defense_guild_id ~= 0 then
            if guild_war_field.is_giving ~= 1 then
                AwardGuildBox(war_field_id,guild_war_field)
            end
            GuildWarRevolvingDoor(guild_war_field,previous_guild[war_field_id],guild_war_field.guild_id)
        end
    end
    guild_war_end_timer = ffi.CreateTimer(CleanGuildWarMemory,10)
    if guild_war_timer then
        C.StopTimer(guild_war_timer)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function CleanGuildWarMemory()
     for war_field_id,guild_war_field in pairs(guild_war_fields) do
            --删除以前占领公会的贡献度
            DeleteGuildWarMemberInfo(war_field_id,guild_war_field)   
           --更改领地拥有者
            UpdateGuildWarFile(war_field_id,guild_war_field)
            --从置流程标记
            guild_war_field.sign_list = {}																			--公会报名链表
            guild_war_field.attack_member_list = {}																	--进攻方成员链表
            guild_war_field.defense_member_list = {}																--防守方成员链表
            guild_war_field.attack_member_order_list = {}															--进攻方成员排队链表(战斗开始后)
            guild_war_field.defense_member_order_list = {}															--防守方成员排队链表
            guild_war_field.attack_resource = 0																		--进攻方资源(资源战,如果为其他类型战场需要属性也在此处初始化)
            guild_war_field.defense_resource = 0																	--防守方资源
            guild_war_field.takedown_location_list = {}																--路点归属链表
            guild_war_field.is_giving = 0
            previous_guild[war_field_id] = guild_war_field.guild_id
    end
    if guild_war_end_timer then
        C.StopTimer(guild_war_end_timer)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--更改领地拥有者
 function UpdateGuildWarFile(war_field_id,guild_war_field)
    local guild_id = previous_guild[war_field_id]
    if guild_id ~= guild_war_field.guild_id and guild_war_field.guild_id ~= 0 then
        UpdateField2(C.ktGuildWarFields,C.kfID,war_field_id,0,C.kInvalidID,{C.kfGuildId,guild_war_field.guild_id},{C.kfTechnologyLevel,1},{C.kfTechnologyExp,0}) --第一个为索引
    end
end 
---------------------------------------------------------------------------------------------------------------------------------------------
--删除以前占领公会的贡献度
function DeleteGuildWarMemberInfo(war_field_id,guild_war_field)
    --删除以前的公会成员贡献度
    if guild_war_field.guild_id ~= previous_guild[war_field_id] and guild_war_field.guild_id ~= 0 then
         db.DeleteGuild(war_field_id)
         guild_war_field.members_info = {}
         for _,member in pairs(guilds[guild_war_field.guild_id].members_info) do
            local members_info = {}
             members_info.player_id = member.player_id
             members_info.is_get_member_box = 1
             members_info.war_field_offer = 0
            table.insert(guild_war_field.members_info,members_info)
         end
         for _,player in pairs(guilds[guild_war_field.guild_id].members_info) do
            GlobalInsertRow(C.ktGuildWarMemberInfo,{C.kfPlayer,player.player_id},{C.kfGuildId,guild_war_field.guild_id},{C.kfWarFieldId,war_field_id},{C.kfWarFieldOffer,0},{C.kfIsGetMemberBox,1})
        end
        --写内存
        guild_war_field.technology_level = 1
        guild_war_field.technology_exp = 0
        guild_war_field.is_giving = 0
        guild_war_field.attack_resource = 0
        guild_war_field.attack_guild_id = 0
        guild_war_field.guild_box_count = 0
        guild_war_field.defense_guild_id = 0
    else
        for _,guild_war_field in pairs(guild_war_fields) do
            for _,player in pairs(guild_war_field.members_info) do
                 UpdateField2(C.ktGuildWarMemberInfo,C.kfPlayer,player.player_id,0,C.kInvalidID,{C.kfIsGetMemberBox,1})
                 player.is_get_member_box = 1  --玩家可以领取公会战的物品
            end
         end
    end
    
end
---------------------------------------------------------------------------------------------------------------------------------------------
--公会战结束走马灯提示
function GuildWarRevolvingDoor(guild_war_field,previous_guild,new_guild)
    local GuildWar = new('GenericNotify')
    if  previous_guild and new_guild and previous_guild ~= 0 and new_guild ~= 0 then
        if previous_guild == new_guild then
            local guild_name = ffi.string(guilds[new_guild].guild_info.guild_name,sizeof(guilds[new_guild].guild_info.guild_name))
            GuildWar.len = string.len(charset.guild_war_remind_str5)
            GuildWar.data = string.format(charset.guild_war_remind_str5,guild_name,guild_war_field.map_name)
            GuildWar.len = string.len(charset.guild_war_remind_str5) + guilds[new_guild].guild_info.guild_name_len + string.len(guild_war_field.map_name)
        else
            local guild_name = ffi.string(guilds[new_guild].guild_info.guild_name,sizeof(guilds[new_guild].guild_info.guild_name))
            GuildWar.data = string.format(charset.guild_war_remind_str4,guild_name,guild_war_field.map_name)
            GuildWar.len = string.len(charset.guild_war_remind_str4) + guilds[new_guild].guild_info.guild_name_len + string.len(guild_war_field.map_name)
        end
        GlobalSend2Gate(-1, GuildWar)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--刷新工会战信息
function RefreshGuildWarInfo()
	--从公会战排队链表进入战场
	local now = os.time()
  	for _,guild_war_field in pairs(guild_war_fields) do
		local attack_member_order_list = guild_war_field.attack_member_order_list
		if #attack_member_order_list >= 1 then
			if now > attack_member_order_list[1].order_time + global.guild.kQueueTime then						--排队2分钟
				local enter_member = attack_member_order_list[1]
				table.remove(attack_member_order_list,1)															--移除排队链表
				table.insert(guild_war_field.attack_member_list, enter_member)										--移入战斗链表
			end
		end
		
		--防守方
		local defense_member_order_list = guild_war_field.defense_member_order_list
		if #defense_member_order_list >= 1 then
			if now > defense_member_order_list[1].order_time + global.guild.kQueueTime  then                  
				local enter_member = defense_member_order_list[1]
				table.remove(defense_member_order_list,1)															--移除排队链表
				table.insert(guild_war_field.defense_member_list, enter_member)									--移入战斗链表
			end
		end	
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--是否在公会战场报名链表
function IsInWarFieldSignList(war_field_id, guild_id)
	local guild_war_field = guild_war_fields[war_field_id]
	if guild_war_field then
		for _,_guild_id in pairs(guild_war_field.sign_list) do
			if _guild_id == guild_id then
				return true
			end
		end
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
--取本战场活跃度最高的公会
local function GetMaxActivityExpGuildId(war_field_sign_list, except_guild_id)
	local max_guild_id = 0
    if not except_guild_id  then
        max_guild_id = war_field_sign_list[1]
    else
        for i,value in pairs(war_field_sign_list) do
            if value == except_guild_id then
                table.remove(war_field_sign_list,i)
                max_guild_id = war_field_sign_list[1]
            end
        end
    end    
    
	local max_guild_activity_exp = guild.GetGuildInfo(max_guild_id).activity_exp
    
    for _,guild_id in pairs(war_field_sign_list) do
		local guild_info = guild.GetGuildInfo(guild_id)
		if guild_info.activity_exp > max_guild_activity_exp and guild_id ~= except_guild_id then
			max_guild_id = guild_id
            max_guild_activity_exp = guild_info.activity_exp
		end
	end
	return max_guild_id
end
---------------------------------------------------------------------------------------------------------------------------------------------
--通知本公会成员
function NoticeGuildMembers(guild_id, subject, content,attachment)
	local guild_members_info = guild.GetGuildMembersInfo(guild_id, subject, content)
	if guild_members_info then		
		--发送邮件
		local cur_time = os.time()
		for _,guild_member_info in pairs(guild_members_info) do
			db.SendMail(guild_member_info.player_id, cur_time, subject, content,attachment, true)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------
--结算公会活跃度,进入1天准备期
 function GuildWarPerpare() 
	guild_war_step = GUILDWARSTEP.PREPARE 																				
	data.SetActionStamp(action_type.guild_war,guild_war_step)
   
	for _,guild_war_field in pairs(guild_war_fields) do
       if #guild_war_field.sign_list == 0 then
			guild_war_field.attack_guild_id = 0
			guild_war_field.defense_guild_id = 0
		else
             local kGuildWarEndTime = string.sub(global.guild.kGuildWarEndTime,1,-1)
             local of_the_week = WEEK[string.sub(global.guild.kGuildWarEndTime,1,1)]
			
			if guild_war_field.guild_id == 0 then                 --战场未被占领(初始状态)
				if #guild_war_field.sign_list == 1 then           --报名公会1个
					local content = string.format(charset.guild_war_mail_str4,guild_war_field.map_name)
                    local guild_id = guild_war_field.sign_list[1]
                    NoticeGuildMembers(guild_id, charset.guild_war_mail_str1, content,nil) 
					guild_war_field.guild_id = guild_war_field.sign_list[1]
                    guild_war_field.attack_guild_id = 0
                    guild_war_field.defense_guild_id = 0
				elseif #guild_war_field.sign_list >= 2 then       --报名公会大于等于2个
					local attack_time = os.date(charset.guild_war_mail_str5, os.time()+60*60*24)
					local defense_guild_id = GetMaxActivityExpGuildId(guild_war_field.sign_list,nil)
					local kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
					--local content = string.format(charset.guild_war_mail_str3,of_the_week,attack_time, guild_war_field.map_name, kGuildWarBeingTime, kGuildWarEndTime)
					local content = string.format(charset.guild_war_mail_str3,attack_time, guild_war_field.map_name, kGuildWarBeingTime, kGuildWarEndTime)
					NoticeGuildMembers(defense_guild_id, charset.guild_war_mail_str1, content,nil)		
					
                    --活跃度第二高的为进攻方
					local attack_guild_id = GetMaxActivityExpGuildId(guild_war_field.sign_list, defense_guild_id) or 0
				    kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
				    kGuildWarEndTime = string.sub(global.guild.kGuildWarEndTime,1,-1)
					--local content = string.format(charset.guild_war_mail_str3,of_the_week,attack_time, guild_war_field.map_name, kGuildWarBeingTime, kGuildWarEndTime)
					local content = string.format(charset.guild_war_mail_str3,attack_time, guild_war_field.map_name, kGuildWarBeingTime, kGuildWarEndTime)
					NoticeGuildMembers(attack_guild_id, charset.guild_war_mail_str1, content,nil)
                    
					guild_war_field.attack_guild_id = attack_guild_id
					guild_war_field.defense_guild_id = defense_guild_id
				end
			else   --战场被占领
				if #guild_war_field.sign_list > 0 then    --原占领公会为防守方
					local attack_time = os.date(charset.guild_war_mail_str5, os.time())
					local defense_guild_id = guild_war_field.guild_id
					local attack_guild_id = GetMaxActivityExpGuildId(guild_war_field.sign_list,nil)
					local guild_info_defense = guild.GetGuildInfo(defense_guild_id)
					local guild_info_attack = guild.GetGuildInfo(attack_guild_id)
					if guild_info_defense then
						local guild_name = ffi.string(guild_info_attack.guild_name, guild_info_attack.guild_name_len)
						local kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
						local  kGuildWarEndTime = string.sub(global.guild.kGuildWarEndTime,1,-1)
						--local content = string.format(charset.guild_war_mail_str2, guild_war_field.map_name,of_the_week, attack_time, guild_name, kGuildWarBeingTime, kGuildWarEndTime)
						local content = string.format(charset.guild_war_mail_str2, guild_war_field.map_name, attack_time, guild_name, kGuildWarBeingTime, kGuildWarEndTime)
						NoticeGuildMembers(defense_guild_id, charset.guild_war_mail_str1, content,nil)
					end
					--活跃度最高的为进攻方		
					 kGuildWarBeingTime = string.sub(global.guild.kGuildWarBeingTime,1,-1)
					 kGuildWarEndTime = string.sub(global.guild.kGuildWarEndTime,1,-1)
					--local content = string.format(charset.guild_war_mail_str3,of_the_week,attack_time, guild_war_field.map_name, kGuildWarBeingTime,kGuildWarEndTime)
					local content = string.format(charset.guild_war_mail_str3,attack_time, guild_war_field.map_name, kGuildWarBeingTime,kGuildWarEndTime)
					NoticeGuildMembers(attack_guild_id, charset.guild_war_mail_str1, content,nil)	
					guild_war_field.attack_guild_id = attack_guild_id
					guild_war_field.defense_guild_id = defense_guild_id
                else
                    guild_war_field.attack_guild_id = 0
                    guild_war_field.defense_guild_id = guild_war_field.guild_id
				end
			end
		end   
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--进入战场等待开战
local function GuildWarEnter()
	guild_war_step = GUILDWARSTEP.ENTER
    data.SetActionStamp(action_type.guild_war,guild_war_step)
    local result = new('PushGuildWarEnter') --给前端发送消息显示图标
    result.isBegin = 1
    for _,guild_war_field in pairs(guild_war_fields) do
        if  guild_war_field.attack_guild_id ~= 0 and guild_war_field.defense_guild_id ~= 0 then
            for _,player in pairs(guilds[guild_war_field.attack_guild_id].members_info) do 
                GlobalSend2Gate(player.player_id, result)
            end
            for _,player in pairs(guilds[guild_war_field.defense_guild_id].members_info) do 
                GlobalSend2Gate(player.player_id, result)
            end
        end    
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
--重置每日领取领地成员宝箱标志(玩家点击按键获得每日奖励。每日奖励根据贡献不同而给与不同数量)
local function ResetGetMemberBox()
	for war_field_id,guild_war_field in pairs(guild_war_fields) do
	    if guild_war_field.guild_id ~= 0 then	
            local guild = guild.GetGuild(guild_war_field.guild_id)
			if guild then
				local guild_box_count = guild_war_field.guild_box_count		--添加公会宝箱个数
				local war_field_technology = GetWarFieldTechnology(war_field_id, guild_war_field.technology_level)	--领地科技增加公会宝箱个数
				
                if war_field_technology and war_field_technology.add_guild_box_count  then
					guild_box_count = guild_box_count + war_field_technology.add_guild_box_count
				end
                
				local guild_box_type = guild_war_fields[war_field_id].guild_box_type
                for _,box in pairs(guild.giving) do   
                    if box.box_type == guild_box_type and box.guild_war_id == war_field_id  then
                        db.UpdateGuildGiving(war_field_id,guild_war_field.guild_id,guild_box_count + box.guild_count,guild_war_field.guild_box_type)
                        box.guild_count = guild_box_count + box.guild_count
                    end
                end
                --发邮件
                local content = charset.guild_war_time_box
                NoticeGuildMembers(guild_war_field.guild_id, charset.guild_war_mail_str1, content,nil) 
                
                --玩家可以领取的内存修改
                for _,player in pairs(guild_war_field.members_info) do
                     UpdateField2(C.ktGuildWarMemberInfo,C.kfWarFieldId,war_field_id,0,C.kInvalidID,{C.kfIsGetMemberBox,1})
                    player.is_get_member_box = 1 
                end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------
--初始化公会战场相关数据
function InitGuildWarFields()
	for war_field_id,guild_war_field in pairs(guild_war_fields) do
		--战场信息(占领公会、科技等 等)
		local war_field_info = db.GetGuildWarFieldInfoFromDB(war_field_id)
        guild_war_field.guild_id = war_field_info.guild_id
        guild_war_field.technology_level = war_field_info.technology_level
        guild_war_field.technology_exp = war_field_info.technology_exp
        guild_war_field.members_info = db.GetGuildWarFieldMemberInfoFromDB(war_field_id)
        guild_war_field.defense_guild_id = guild_war_field.guild_id
        guild_war_field.attack_guild_id = 0
		guild_war_field.sign_list = {}																					--公会报名链表
		guild_war_field.attack_member_list = {}																			--进攻方成员链表
		guild_war_field.defense_member_list = {}																		--防守方成员链表
		guild_war_field.attack_member_order_list = {}																	--进攻方成员排队链表(战斗开始后)
		guild_war_field.defense_member_order_list = {}																	--防守方成员排队链表
		guild_war_field.attack_resource = 0																				--进攻方资源(资源战,如果为其他类型战场需要属性也在此处初始化)
		guild_war_field.defense_resource = 0																			--防守方资源	
		guild_war_field.takedown_location_list = {}																		--路点归属链表                           
		guild_war_field.sign_list = db.ReadGuildMapSignList(war_field_id)                                              --报名列表
        guild_war_field.leave_attack_players = {}
        guild_war_field.leave_defense_players = {}
        table.insert(previous_guild,guild_war_field.guild_id)
    end
    guild_war_step = data.GetActionStamp(action_type.guild_war)                                                      --获取数据库里面的数据防止重启
    if guild_war_step == GUILDWARSTEP.SIGN_UP then
        GuildWarSignUp()
    elseif guild_war_step == GUILDWARSTEP.PREPARE then
        GuildWarPerpare()
    elseif guild_war_step == GUILDWARSTEP.ENTER then
        GuildWarPerpare()
        GuildWarEnter()
    elseif guild_war_step == GUILDWARSTEP.WARING then
        GuildWarPerpare()
        GuildWarEnter()
        GuildWarBegin()
    end
    --test
		
    local guild_war_perpare = global.guild.kGuildWarPerpareTime
	CreateTaskSch_Day(guild_war_perpare, GuildWarPerpare)

	local enter_time = global.guild.kGuildWarEnterTime 
	CreateTaskSch_Day(enter_time, GuildWarEnter)

	local begin_time = global.guild.kGuildWarBeingTime
	CreateTaskSch_Day(begin_time, GuildWarBegin)

	local end_time = global.guild.kGuildWarEndTime
	CreateTaskSch_Day(end_time, GuildWarEnd)

    local guild_war_sign_up = global.guild.kGuildWarSignUp
	CreateTaskSch_Day(guild_war_sign_up, GuildWarSignUp)

	CreateTaskSch_Day(global.guild.kGuildResetTime, ResetGetMemberBox)

    --走马灯提示
   local guild_war_remind_first = global.guild.kGuildWarRemindFirst 
    CreateTaskSch_Day(guild_war_remind_first,GuildWarRemindFirstAndSecond)

    local guild_war_remind_second = global.guild.kGuildWarRemindSecond 
    CreateTaskSch_Day(guild_war_remind_second,GuildWarRemindFirstAndSecond)

    local guild_war_remind_third = global.guild.kGuildWarRemindThird 
    CreateTaskSch_Day(guild_war_remind_third,GuildWarRemindThirdAndFour)

    local guild_war_remind_four = global.guild.kGuildWarRemindFour 
    CreateTaskSch_Day(guild_war_remind_four,GuildWarRemindThirdAndFour)

    local guild_war_remind_five = global.guild.kGuildWarRemindFive 
    CreateTaskSch_Day(guild_war_remind_five,GuildWarRemindFive)
    --[[
	--每周(5 12:00) 结算一次公会活跃度, 并发送战前通知
    local guild_war_perpare = global.guild.kGuildWarPerpareTime
	CreateTaskSch_Week(guild_war_perpare, GuildWarPerpare)

	--周(6 19:50) 公会战准备时间,相关逻辑处理
	local enter_time = global.guild.kGuildWarEnterTime 
	CreateTaskSch_Week(enter_time, GuildWarEnter)

	--周(6 20:00) 公会战斗开始,相关逻辑处理
	local begin_time = global.guild.kGuildWarBeingTime
	CreateTaskSch_Week(begin_time, GuildWarBegin)

	--周(6 20:30) 公会战斗结束,相关逻辑处理(战斗时长30分钟)
	local end_time = global.guild.kGuildWarEndTime
	CreateTaskSch_Week(end_time, GuildWarEnd)

	--星期天12点前休战,12点后开始报名
    local guild_war_sign_up = global.guild.kGuildWarSignUp
	CreateTaskSch_Week(guild_war_sign_up, GuildWarSignUp)

	--发放领地奖励(拥有的领地将每天零点为公会提供5个领地宝箱)
	CreateTaskSch_Day("0:00", ResetGetMemberBox)

    --走马灯提示
   local guild_war_remind_first = global.guild.kGuildWarRemindFirst 
    CreateTaskSch_Week(guild_war_remind_first,GuildWarRemindFirstAndSecond)

    local guild_war_remind_second = global.guild.kGuildWarRemindSecond 
    CreateTaskSch_Week(guild_war_remind_second,GuildWarRemindFirstAndSecond)

    local guild_war_remind_third = global.guild.kGuildWarRemindThird 
    CreateTaskSch_Week(guild_war_remind_third,GuildWarRemindThirdAndFour)

    local guild_war_remind_four = global.guild.kGuildWarRemindFour 
    CreateTaskSch_Week(guild_war_remind_four,GuildWarRemindThirdAndFour)

    local guild_war_remind_five = global.guild.kGuildWarRemindFive 
    CreateTaskSch_Week(guild_war_remind_five,GuildWarRemindFive)
    --]]
end


