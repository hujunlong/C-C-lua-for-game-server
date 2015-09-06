require('guild')
require('data')
require('guild_war')
require('tools.task_sch')
require('global_data')
local global = require('config.global')
local guild_war_fields = require('config.guild_war_fields')
local guild_war_maps = require('config.guild_war_maps')
local charset = require('config.charset')
local assistant_task = require('config.assistant_task_id')
local gold_consume_flag = require('define.gold_consume_flag')


local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy
local sizeof = ffi.sizeof

local guilds = guild.GetGuilds()
------------------------------------------------------------------------------------------------------------------
function CreateGuildWarManager(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	--------------------------------------------------------------------------------------------------------------
	--本公会是否已经报名参加这个战场
	local function IsSigned(war_field_sign_list)
		for _,guild_id in pairs(war_field_sign_list) do
			if guild_id == player.GetGuildId() then
				return true
			end
		end
		return false
	end
    --------------------------------------------------------------------------------------------------------------
   	--能够打的公会战场
	processor_[C.kCanGuildWarFileMap] = function(msg)
		local req = cast('const CanGuildWarFileMap&', msg)
		local result = new('ResultCanGuildWarFileMap')
        local count = 0
        for _,guild_war_field in pairs(guild_war_fields) do
            local map = result.map[count]
            if guild_war_field.attack_guild_id == player.GetGuildId()  then
                map = 1
                count = count + 1
            elseif guild_war_field.defense_guild_id == player.GetGuildId() then
                map = 1
                count = count + 1
            else
                map = 0
                count = count + 1
            end
        end
		return result,8+count*4
	end	
    --------------------------------------------------------------------------------------------------------------
	--取占领公会
	processor_[C.kGetGuildWarFieldList] = function(msg)
		local req = cast('const GetGuildWarFieldList&', msg)
		local result = new('GuildWarFieldList')
		
		local count = 0
		for i,guild_war_field in pairs(guild_war_fields) do
			local war_field_tidy = result.war_fields_tidy[count]
			war_field_tidy.war_field_id = i												--战场ID
			if guild_war_field.guild_id ~= 0  and (guilds[guild_war_field.guild_id]) then
                  war_field_tidy.guild_id = guild_war_field.guild_id		--占领公会ID
                  local guild_info = guild.GetGuildInfo(war_field_tidy.guild_id)
                  war_field_tidy.guild_name_len = guild_info.guild_name_len
                  copy(war_field_tidy.guild_name, guild_info.guild_name, guild_info.guild_name_len)
             else
			    war_field_tidy.guild_id = 0
            end
            
			war_field_tidy.is_signed = IsSigned(guild_war_field.sign_list) and 1 or 0	--本公会是否已经报名参加这个战场			
			war_field_tidy.technology_level = guild_war_field.technology_level			--领地科技
			
			count = count + 1
			if count >= 10 then														    --超过数据定义最大上限,需要调整结构定义
				result.count = count
				return result,4+count*sizeof(result.war_fields_tidy[0])
			end			
		end
		result.count = count
		return result,4+count*sizeof(result.war_fields_tidy[0])
	end
	--------------------------------------------------------------------------------------------------------------
	--取公会战场报名列表	
	processor_[C.kGetGuildWarFieldSignList] = function(msg)
		local req = cast('const GetGuildWarFieldSignList&', msg)
		local result = new('GuildWarFieldSignList')
   
		local guild_war_field = guild_war_fields[req.war_field_id]
		if not guild_war_field then
			result.result = C.SOCIETY_ERROR												--非法数据,未找到对应战场
			return result
		end
		
		local count = 0
		for _,guild_id in pairs(guild_war_field.sign_list) do
			local sign_info = result.war_fields_sign_info[count]
			sign_info.guild_id = guild_id
			local guild_info = guild.GetGuildInfo(guild_id)
			
			if guild_info then
				sign_info.guild_name_len = guild_info.guild_name_len
				copy(sign_info.guild_name, guild_info.guild_name, guild_info.guild_name_len)
				sign_info.activity_exp = guild_info.activity_exp
			end

			count = count + 1
			if count >= 100 then														--超过数据定义最大上限,需要调整结构定义
				result.count = count
				return result,4+count*sizeof(result.war_fields_sign_info[0])	
			end
		end
		result.count = count
		return result,4+count*sizeof(result.war_fields_sign_info[0])	
	end
	--------------------------------------------------------------------------------------------------------------
	--公会战场报名
	processor_[C.kSignGuildWar] = function(msg)
		local req = cast('const SignGuildWar&', msg)
		local result = new('SignGuildWarResult') 
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		if not guild.CheckAuthoritysignGuildWar(player.GetGuildId(),player.GetUID()) then
			result.state = 2															--权限不够
			return result	
		end	
	
		if not guild_war.CanSign() then
			result.result = C.SOCIETY_NOT_THE_TIME										--现在不能报名
			return result
		end
	
		if guild_war.IsInWarFieldSignList(req.war_field_id, guild_war_fields[req.war_field_id].guild_id) then
			result.state = 3															--已经在报名链表
			return result
		end
		
		 if guild_war_fields[req.war_field_id].guild_id == player.GetGuildId() then
            result.state = 4
            return result
        end
		
		local count = 0
		for _,guild_war_field in pairs(guild_war_fields) do
			for _,guild_id in pairs(guild_war_field.sign_list) do
				if guild_id == player.GetGuildId() then
					count = count + 1
				end
			end  
		end
		
		if count >= 1 then
			result.state = 1															--每星期只能报1个战场
			return result
		end
		
		local guild_war_field = guild_war_fields[req.war_field_id]
		if guild_war_field then
			for _,guild_id in pairs(guild_war_field.sign_list) do
				if guild_id == player.GetGuildId() then
					result.result = C.SOCIETY_ALREADY_IN_SING_LIST						--本周已经报过名了
					return result
				end
			end
			table.insert(guild_war_field.sign_list,player.GetGuildId())
			GlobalInsertRow(C.ktGuildMapSignList, {C.kfGuildId, player.GetGuildId()}, {C.kfWarFieldId, req.war_field_id})
			return result
		end
	end
	--------------------------------------------------------------------------------------------------------------
    --相同数据添加到一起
    local function SameAddTotal(guild_id,result_giving)
        local is_add = false
        local count = 0
        local guild_giving = guild.GetGuildGiving(guild_id)
        if #guild_giving > 0 then
            for _,giving_ in pairs(guild_giving) do
                if count == 0 then
                    is_add = false
                end
                for i= 0,count-1 do
                    if result_giving[i].item_id == giving_.box_type then
                        result_giving[i].item_count = result_giving[i].item_count + giving_.guild_count
                        is_add = true
                        break
                    end
                end
                if not is_add and giving_.guild_count >0 then
                    result_giving[count].item_id = giving_.box_type
                    result_giving[count].item_count = giving_.guild_count
                    count = count + 1
                end
			end    
        end
        return count
    end
    --------------------------------------------------------------------------------------------------------------
	--取公会仓库物品列表(目前只有战场奖励的箱子)
	processor_[C.kGetGuildGivingList] = function(msg)
		local req = cast('const GetGuildGivingList&', msg)
		local result = new('GuildGivingList')
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		--相同数据添加到一起
        local count = SameAddTotal(player.GetGuildId(),result.giving)
		result.count = count
		return result,12+count*sizeof(result.giving[0])
	end
	--------------------------------------------------------------------------------------------------------------
	--分配公会战利品
	processor_[C.kPrizeGuildGiving] = function(msg)
		local req = cast('const PrizeGuildGiving&', msg)
		local result = new('PrizeGuildGivingResult')
        
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
	                
		if not guild.CheckAuthorityPrizeGuildGiving(player.GetGuildId(),player.GetUID()) then
			result.state = 2															--权限不够
			return result
		end
		
		local guild_giving = guild.GetGuildGiving(player.GetGuildId())
		local result_guild = new('GuildGivingList')
		local count = SameAddTotal(player.GetGuildId(),result_guild.giving)
		if guild_giving then
            local item_count = 0
            --判断物品是否足够
			for i = 0,count-1 do
               if result_guild.giving[i].item_id == req.item_id then
                   item_count = result_guild.giving[i].item_count
                    break 
               end
             end  
           if item_count < req.count then
                result.state = 1
                return result
           end
            --分发物品
            local ma = new("MailAttachments")
            ma.amount=1
            ma.attach[0].attach_id = 1
            ma.attach[0].extracted = 0
            ma.attach[0].type = C.kPropRsc
            ma.attach[0].kind = req.item_id
            ma.attach[0].amount = 1
            local content = string.format(charset.guild_war_Send_box, charset.guild_war_mail_str1)
            for i = 0,req.count-1 do
                db.SendMail(req.player_id[i], os.time(),charset.guild_war_mail_str1,content, ma, true)
            end
            
            --更改内存与数据库
            local req_count = req.count
            for _,guild_giving_ in pairs(guild_giving) do
                if guild_giving_.box_type == req.item_id then
                    if guild_giving_.guild_count >= req_count then
                        guild_giving_.guild_count = guild_giving_.guild_count - req_count
                        UpdateField2(C.ktGuildGiving, C.kfBoxType, req.item_id,C.kfGuildWarId,guild_giving_.guild_war_id,{C.kfGuildCount, guild_giving_.guild_count})
                        break
                    else
                        req_count = req_count - guild_giving_.guild_count
                        guild_giving_.guild_count = 0
                        UpdateField2(C.ktGuildGiving, C.kfBoxType, req.item_id,C.kfGuildWarId,guild_giving_.guild_war_id,{C.kfGuildCount, 0})
                    end
                end
            end
         
		end
		return result
	end		
	--------------------------------------------------------------------------------------------------------------
	--领地捐赠
	processor_[C.kEndowGuildWarField] = function(msg)
		local req = cast('const EndowGuildWarField&', msg)
		local result = new('EndowGuildWarFieldResult')
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		local war_field_info = guild_war.GetWarFieldInfo(req.war_field_id)
		
		if not war_field_info then
			result.result = C.SOCIETY_ERROR												--没有对应战场信息
			return result
		end
		
		if war_field_info.guild_id ~= player.GetGuildId() then
			result.result = C.SOCIETY_ERROR												--没有占领该战场
			return result
		end
			
		local member_info = {}	
		for _,_member_info in pairs(war_field_info.members_info) do
			if _member_info.player_id == player.GetUID() then
				member_info = _member_info
				break
			end
		end
		
		local add_exp = 0
		if req.endow_type == 0 then													--捐赠银币
			
			if not player.IsSilverEnough(req.endow_count) then						--err消耗银币检查
				result.result = C.SOCIETY_NOT_ENOUGH_SILVER
				return result
			end
			
			player.ModifySilver(-req.endow_count)										--扣除银币				
			
			if req.endow_count < 10 then												--小于10银币,什么都不变
                result.technology_level = war_field_info.technology_level
                result.technology_exp = war_field_info.technology_exp
                result.war_field_offer = member_info.war_field_offer
                return result
			end
            add_exp = math.floor(req.endow_count/10)
			if (req.endow_count / 10) - add_exp >= 0.5 then 
            add_exp = add_exp + 1
            end
		else																			--捐赠金币
		
			if not player.IsGoldEnough(req.endow_count) then							--err消耗金币检查
				result.result = C.SOCIETY_NOT_ENOUGH_GOLD
				return result
			end
			add_exp = req.endow_count*10
			player.ConsumeGold(req.endow_count,gold_consume_flag.guild_war_donate)		--扣除金币	
													
		end
		
		member_info.war_field_offer = add_exp + member_info.war_field_offer
		UpdateField2(C.ktGuildWarMemberInfo, C.kfPlayer, player.GetUID(), C.kfWarFieldId, req.war_field_id, {C.kfWarFieldOffer, member_info.war_field_offer})
		--------------------------------------------------------------------------------------------------------------
		--科技升级
		while add_exp>0 do
			local war_field_technology = guild_war.GetWarFieldTechnology(req.war_field_id, war_field_info.technology_level)	
			if war_field_technology and war_field_technology.exp then
				if war_field_info.technology_exp + add_exp < war_field_technology.exp then
					war_field_info.technology_exp = war_field_info.technology_exp + add_exp
					add_exp = 0
				else
					add_exp = add_exp - (war_field_technology.exp - war_field_info.technology_exp)
					war_field_info.technology_exp = 0
					war_field_info.technology_level = war_field_info.technology_level + 1
				end
			else
				war_field_info.exp = 0
				add_exp = 0
			end
		end
		--更新数据库
		UpdateField2(C.ktGuilWarFields, C.kfID, req.war_field_id, 0, C.kInvalidID, {C.kfTechnologyLevel, war_field_info.technology_level}, {C.kfTechnologyExp, war_field_info.technology_exp})
	
		result.technology_level = war_field_info.technology_level
		result.technology_exp = war_field_info.technology_exp
		result.war_field_offer = member_info.war_field_offer
        
        --调用小助手接口
        player.AssistantCompleteTask(assistant_task.kGuildTerritoryDonations, 9)
		return result
	end
	--------------------------------------------------------------------------------------------------------------
	--取领地信息
	processor_[C.kGetGuildWarFieldInfo] = function(msg)
		local req = cast('const GetGuildWarFieldInfo&', msg)
		local result = new('GuildWarFieldInfo')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		local war_field_info = guild_war.GetWarFieldInfo(req.war_field_id)
		if not war_field_info then
			result.result = C.SOCIETY_ERROR												--没有对应战场信息
			return result
		end
	
		if war_field_info.guild_id ~= player.GetGuildId() then
			result.result = C.SOCIETY_ERROR												--没有占领该战场
			return result
		end

		result.technology_level = war_field_info.technology_level
		result.technology_exp = war_field_info.technology_exp
        
        for _,member in pairs(war_field_info.members_info) do
           if member.player_id == player.GetUID() then
                if member.is_get_member_box == 1   then
                    result.is_get_member_box = 1
                    break 
                elseif member.is_get_member_box == 0 then
                    result.is_get_member_box = 0
                    break
                end
            end
       end
       
		local members_info = war_field_info.members_info
		for _,member_info in pairs(members_info) do
			if member_info.player_id == player.GetUID() then
				result.war_field_offer = member_info.war_field_offer
				return result
			end
		end
	   result.war_field_offer = 0
	   return result
	end		
	--------------------------------------------------------------------------------------------------------------
	--领取领地每日奖励
	processor_[C.kGetGuildWarFieldMemberReward] = function(msg)
		local req = cast('const GetGuildWarFieldMemberReward&', msg)
		local result = new('GuildWarFieldMemberReward')
		
        local ma = new("MailAttachments")
        ma.amount=1
        ma.attach[0].attach_id = 1
        ma.attach[0].extracted = 0
        ma.attach[0].type = C.kPropRsc
        ma.attach[0].kind = guild_war_fields[req.war_field_id].member_box_type
        ma.attach[0].amount = 1
                
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		local war_field_info = guild_war.GetWarFieldInfo(req.war_field_id)
		if not war_field_info then
			result.result = C.SOCIETY_ERROR												--没有对应战场信息
			return result
		end
		
		if war_field_info.guild_id ~= player.GetGuildId() then
			result.result = C.SOCIETY_ERROR												--没有占领该战场
			return result
		end

		result.member_box_type = war_field_info.member_box_type
		
		local member_info = {}	
		for _,_member_info in pairs(war_field_info.members_info) do
			if _member_info.player_id == player.GetUID() then
				member_info = _member_info
                break
			end
		end
        
        if next(member_info) == nil then
            result.result = C.SOCIETY_ERROR                                         --数据错误
            return
        end

        if member_info.is_get_member_box == 0 then 
            result.result = C.SOCIETY_GUILD_WAR_IS_ENCOURAGEMENT						--玩家已经领取奖励
			return result
        end
      
		--0-999领取1个，1000-领取2个，2000-3499领取3个,3500-5499领取4个，5500-∞领取5个
		local war_field_offer = member_info.war_field_offer
		local count = 0
		if war_field_offer>=0 and war_field_offer<=999 then
			count = 1
		elseif war_field_offer>=1000 and war_field_offer<=1999 then
			count = 2
		elseif war_field_offer>=2000 and war_field_offer<=3499 then
			count = 3
		elseif war_field_offer>=3500 and war_field_offer<=5499 then
			count = 4
		elseif war_field_offer>=5500 then
			count = 5
		end

        result.member_box_count = count
        player.ModifyProp(result.member_box_type, count) 							--背包加物品
        member_info.is_get_member_box = 0											--标记为已经领取
        
        --更新数据库
        UpdateField2(C.ktGuildWarMemberInfo, C.kfPlayer, player.GetUID(), C.kfWarFieldId, req.war_field_id, {C.kfIsGetMemberBox, 0})
        db.SendMail(player.GetUID(), os.time(),charset.guild_war_mail_str1,charset.guild_war_time_box, ma, true)
        return result
	end
    --------------------------------------------------------------------------------------------------------------
	--取参加公会战成员列表
	local function GetWarFieldMembers(war_field_info, camp) --0-防守方 1-进攻方
	    if camp==1 then
			return war_field_info.attack_member_list, war_field_info.attack_member_order_list
		elseif camp == 0 then
			return war_field_info.defense_member_list, war_field_info.defense_member_order_list
		else
			return nil
		end
	end
	--------------------------------------------------------------------------------------------------------------
	--自己工会是否参战
	processor_[C.kIsGuildInWar] = function(msg)
		local req = cast('const IsGuildInWar&', msg)
		local result = new('IsGuildInWarResult')
		if player.GetGuildId()~=0 then
			local count = 0
			local guild_id = player.GetGuildId() or 0
			for war_field_id,guild_war_field in pairs(guild_war_fields) do
				if guild_war_field.attack_guild_id == guild_id and guild_war_field.defense_guild_id~=0 then
					result.war_field_list[count] = war_field_id
					count = count + 1
				elseif guild_war_field.defense_guild_id == guild_id and guild_war_field.attack_guild_id~=0 then
					result.war_field_list[count] = war_field_id
					count = count + 1
				end
			end
			result.count = count
			result.guild_war_time = Task_ConvertString2time(global.guild.kGuildWarBeingTime,0) 
			return result
		end
	end		
	
	--------------------------------------------------------------------------------------------------------------
	--是否到达可以进入战场的时间
	function Task_ConvertString2time(begin_time_str, space_time)--战斗刚开始准备时间  间隔时间秒计算
    --[[
        local date,wday,hour,min,sec
        local cur_time = os.time()
		date = os.date("*t", cur_time)
		wday = string.sub(begin_time_str, 1, 1)
		hour = string.sub(begin_time_str, 3, 4)
		min  = string.sub(begin_time_str, 6, 7)
		sec  = string.sub(begin_time_str, 9,10)
		dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min, sec = sec})
		
		if date.wday == 1 then         --外国时间跟中国星期统一
			date.wday = 7
		else
			date.wday = date.wday - 1
		end
		
		wday = string.format("%d",wday)
		date.wday = string.format("%d",date.wday)
			
		if space_time ~= 0 then  
			if wday ~= date.wday then
				return 0                     --0表示不是相同一天
			end
			
			if date.wday == wday and dst_time < cur_time and  (dst_time + space_time) > cur_time then
				return 1
			else
				return 0
			end
		else --计算具体时间用来
			if wday == date.wday then
				return dst_time
			elseif wday > date.wday then
				return dst_time + (wday - date.wday)*86400
			else 
				return dst_time + (7 + date.wday - wday)*86400
			end
		end
        --]]
        
        local date,hour,min,sec
        local cur_time = os.time()
		date = os.date("*t", cur_time)
        hour = string.sub(begin_time_str, 1, 2)
		min  = string.sub(begin_time_str, 4, 5)
		sec  = string.sub(begin_time_str, 7, 8)
		dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min, sec = sec})
		return dst_time
    end
	--判断前端工会战图标显示
	processor_[C.kGuildWarBeginTime] = function(msg)
 		local req = cast('const GetGuildWarBeginTime&', msg)
		local result = new('GuildWarBeginTimeResult')
		local count = 0
        local begin_war_time = Task_ConvertString2time(global.guild.kGuildWarEnterTime,0)  
        local end_war_time = Task_ConvertString2time(global.guild.kGuildWarEndTime,0)
        local now_time  =  os.time()
		if player.GetGuildId()~=0 then
            for _,guild_war_field in pairs(guild_war_fields) do
                if guild_war_field.attack_guild_id == player.GetGuildId() or guild_war_field.defense_guild_id == player.GetGuildId() then
                    if  now_time > begin_war_time and now_time < end_war_time and guild_war_field.is_giving ~= 1 then
                        count = count + 1
                    end    
                end
            end
		end
		if count == 0 then
			result.begin_time = 0
			else
			result.begin_time = 1
		end
		return result
	end	
    --------------------------------------------------------------------------------------------------------------
	--战斗开始前取工会战进入成员个数
	processor_[C.kGetGuildWarFieldFigtersCount] = function(msg)
		local req = cast('const GetGuildWarFieldFigtersCount&', msg)
		local result = new('GuildWarFieldFigtersCount')	
	
    	if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		local war_field_info, camp = guild_war.GetWarField(player.GetGuildId(), req.war_field_id)
		if (not war_field_info) or (not camp) then
			result.result = C.SOCIETY_GUILD_NOT_IN_WAR									--公会没有参加该战场
			return result
		end
		
		if not guild_war.CanEnter() then
			result.result = C.SOCIETY_NOT_THE_TIME									--还未到进入时间,不能取人数
			return result
		end
		
		player.war_field_id = req.war_field_id
		local enter_list, _ = GetWarFieldMembers(war_field_info, camp)
		
		if enter_list then
			result.enter_count = #enter_list											--已经进入人数
			result.camp = camp															--0-防守方 1-进攻方
			return result
		end
	end
	--------------------------------------------------------------------------------------------------------------
    local function FindPlayer(list,player_id)
        for _,list_player in pairs(list) do
            if list_player.player_id == player_id then
                return true
            else
                return false
            end
        end
    end
    
    local function OrderPlayerInfo(order_player,list)
        for i,attack_player in pairs(list) do
            if attack_player.player_id == order_player.player_id then
                order_player.buff_heal_hp_buy_num = attack_player.buff_heal_hp_buy_num			--buff恢复包购买次数
                order_player.buff_add_attack_buy_num = attack_player.buff_add_attack_buy_num	--buff伤害加深购买次数
                order_player.kill_count = attack_player.kill_count						--击杀次数
                order_player.dead_count = attack_player.dead_count						--死亡次数
                order_player.hits_count = attack_player.hits_count						--伤害总数
                order_player.group_damage_per = attack_player.group_damage_per 
                table.remove(list,i)
            end
        end
    end
    --------------------------------------------------------------------------------------------------------------
	--进入工会战场
	processor_[C.kEnterGuildWarField] = function(msg)
		local req = cast('const EnterGuildWarField&', msg)
		local result = new('EnterGuildWarFieldResult')
	
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD										--未在公会中
			return result
		end
		
		local war_field_info, camp = guild_war.GetWarField(player.GetGuildId(), req.war_field_id)
		if (not war_field_info) or (not camp) then
			result.result = C.SOCIETY_GUILD_NOT_IN_WAR									--公会没有参加该战场
			return result
		end
		
		if not guild_war.CanEnter() then
			 result.result = C.SOCIETY_NOT_THE_TIME										--还未到进入时间,不能取人数
			 return result
		end
		
		player.war_field_id = req.war_field_id 
		local enter_list, order_list = GetWarFieldMembers(war_field_info, camp)
		local war_field_map_info = guild_war.GetWarFieldMapInfo(req.war_field_id)
        
		if war_field_map_info then
            local order_player={}
			if guild_war.IsWaring()  then
				--已经开战了(8:00后),加入排队链表
				order_player.player_id = player.GetUID()
                order_player.player_name = player.GetName()
				order_player.player_guild_id = player.GetGuildId()
                order_player.order_time = os.time()									--开始排队时间
				order_player.win_count = 0												--统计每次移动胜利次数(不同于击杀次数)
				order_player.heal_hp = 0												--统计每次移动buff回复的血量
				order_player.buff_heal_hp = 0											--buff总+血量
				order_player.buff_heal_hp_buy_num = 0				                    --buff恢复包购买次数
				order_player.buff_add_attack_buy_num = 0		                        --buff伤害加深购买次数
				order_player.kill_count = 0												--击杀次数
				order_player.dead_count = 0												--死亡次数
				order_player.hits_count = 0												--伤害总数
				order_player.location = (camp==1 and war_field_map_info.attack_born_location or war_field_map_info.defense_born_location) --所在战场位置(默认为出身点)
				order_player.last_move_time=0											--最近一次移动时间
				order_player.enter_count = #enter_list
				order_player.order_count = #order_list + 1
				order_player.is_guild_waring = 1
                order_player.first_order_time = (order_list[1] and order_list[1].order_time) or os.time()   
				order_player.enter_time = Task_ConvertString2time(global.guild.kGuildWarEnterTime,0)
				order_player.begin_time = Task_ConvertString2time(global.guild.kGuildWarBeingTime,0)
				order_player.end_time =   Task_ConvertString2time(global.guild.kGuildWarEndTime,0)
                
                if not FindPlayer(order_list,player.GetUID()) then
                    table.insert(order_list, order_player)
                end
                
                 --中途退出添加进来
                OrderPlayerInfo(order_player,war_field_info.leave_attack_players)
                OrderPlayerInfo(order_player,war_field_info.leave_defense_players)

				result.enter_count = #enter_list
				result.order_count = #order_list
				result.buff_heal_hp_buy_num = order_player.buff_heal_hp_buy_num
				result.buff_add_attack_buy_num = order_player.buff_add_attack_buy_num
				result.is_guild_waring = 1	
				result.first_order_time = (order_list[1] and order_list[1].order_time) or os.time()
				result.location = order_player.location
				result.enter_time = Task_ConvertString2time(global.guild.kGuildWarEnterTime,0)
				result.begin_time = Task_ConvertString2time(global.guild.kGuildWarBeingTime,0)
				result.end_time =   Task_ConvertString2time(global.guild.kGuildWarEndTime,0)
                result.wait_time = global.guild.kQueueTime
			else
				local enter_player={}
				enter_player.player_id = player.GetUID()
                enter_player.player_name = player.GetName()
				enter_player.player_guild_id = player.GetGuildId()
				enter_player.order_time = 0
				enter_player.win_count = 0
				enter_player.heal_hp = 0							        			            --统计每次移动buff回复的血量
				enter_player.buff_heal_hp = 0											            --buff总+血量
				enter_player.buff_heal_hp_buy_num = 0				                                --buff恢复包购买次数
				enter_player.buff_add_attack_buy_num = 0		                                    --buff伤害加深购买次数
                enter_player.kill_count = 0
				enter_player.dead_count = 0
				enter_player.hits_count = 0
				enter_player.location = (camp==1 and war_field_map_info.attack_born_location or war_field_map_info.defense_born_location) --所在战场位置(默认为出身点)
				enter_player.last_move_time=0
				enter_player.is_guild_waring = 0
				enter_player.enter_count = #enter_list 
				enter_player.order_count = 0
                local is_find = false
                for _,enter_player_ in pairs(enter_list) do
                   if  enter_player_.player_id == player.GetUID() then
                        is_find = true
                    end
                end
                
                if not is_find then
                    OrderPlayerInfo(enter_player,war_field_info.leave_attack_players)
                    OrderPlayerInfo(enter_player,war_field_info.leave_defense_players)
                    table.insert(enter_list, enter_player)
				end
                
				result.enter_count = #enter_list
				result.order_count = 0
				result.is_guild_waring = 0	
				result.first_order_time = 0
				result.buff_heal_hp_buy_num = enter_player.buff_heal_hp_buy_num
				result.buff_add_attack_buy_num = enter_player.buff_add_attack_buy_num
				result.location = enter_player.location
			    result.enter_time = Task_ConvertString2time(global.guild.kGuildWarEnterTime,0)
				result.begin_time = Task_ConvertString2time(global.guild.kGuildWarBeingTime,0)
				result.end_time =   Task_ConvertString2time(global.guild.kGuildWarEndTime,0)
			end
			return result	
		end
	end
	--------------------------------------------------------------------------------------------------------------
	--离开工会战场
	processor_[C.kLeaveGuildWarField] = function(msg)
		local req = cast('const LeaveGuildWarField&', msg)
		local result = new('LeaveGuildWarFieldResult')
		guild_war.LeaveGuildWarField(player)
		return result
	end
	--------------------------------------------------------------------------------------------------------------
	--player为玩家对象,不是ID
   function FindFighter(war_field_info, player)
		for _,fighter in pairs(war_field_info.attack_member_list) do
		    if fighter.player_id == player.GetUID() then
				return fighter
			end
		end
		
		for _,fighter in pairs(war_field_info.defense_member_list) do
		    if fighter.player_id == player.GetUID() then
				return fighter
			end
		end
	end
	--------------------------------------------------------------------------------------------------------------
	--是否是相邻点	
	local function IsAdjacentLocation(cur_location, target_location)
		for _,adjacent in pairs(cur_location.adjacent_locations) do
			if adjacent == target_location then
				return true
			end
		end
		return false
	end
	--------------------------------------------------------------------------------------------------------------
	--是否是出身点
	local function IsBornLocation(war_field_map_info, target_location)
		return war_field_map_info.attack_born_location == target_location or war_field_map_info.defense_born_location == target_location
	end
    --------------------------------------------------------------------------------------------------------------
	--是否是复活点	
	local function IsRebornLocation(war_field_map_info, target_location)
		for _,reborn_location in pairs(war_field_map_info.reborn_locations) do
			if reborn_location == target_location then
				return true
			end
		end
		return false		
	end
	--------------------------------------------------------------------------------------------------------------
	--取指定点敌军链表
	local function GetLocationEnemyList(war_field_info, camp, target_location)
		local enemy_member_list = (camp==1 and war_field_info.defense_member_list) or war_field_info.attack_member_list
		local location_enemy_list = {}
		for _,enemy_member in pairs(enemy_member_list) do
            for _,reborn_location_ in pairs(guild_war_maps[war_field_info.field_map_id].reborn_locations) do
                if reborn_location_ == target_location then
                    return location_enemy_list
                end
            end
            
			if enemy_member.location == target_location then
				table.insert(location_enemy_list, enemy_member)
			end
		end
		return location_enemy_list
	end
	--------------------------------------------------------------------------------------------------------------
	local function ShortestPath(graph, src)
        local function ExtractMin(dist, trace)
            local minDist = 1.0e9
            local nearest = nil
            for v,_ in pairs(trace) do
                if (dist[v] < minDist) then
                    minDist = dist[v]
                    nearest = v
                end
            end
            return nearest
        end
        local dist = {}        --距离
        local path = {}        --路径
        local trace = {}        --已经完成的路径
        for i in pairs(graph) do
            trace[i] = true
            dist[i] = 1.0e9        --不可到达
        end
        
        dist[src] = 0
        
        while true do
            local u = ExtractMin(dist, trace)
            if (u == nil) then
                return path, dist
            end
            
            trace[u] = nil
            for _,v in ipairs(graph[u].adjacent_locations) do
                local alt = dist[u] + 1
                if not dist[v] or (alt < dist[v]) then
                    dist[v] = alt
                    path[v] = u
                end
            end
        end
    end
    --------------------------------------------------------------------------------------------------------------
    --取最近复活点
    local function GetShort(war_field_map_info,dist)
        local _sort_idstance = 100000
        for _,reborn_port in pairs(war_field_map_info.reborn_locations) do
            for i,sort_idstance in pairs(dist) do
                if i == reborn_port and sort_idstance > 100000 then
                    for _,next_port in pairs(war_field_map_info.locations[reborn_port].adjacent_locations) do
                        if _sort_idstance > dist[next_port] then
                            _sort_idstance = dist[next_port]
                        end
                    end
                     dist[reborn_port] = _sort_idstance + 1
                end
            end
        end
    end
    --------------------------------------------------------------------------------------------------------------
	local function GetRebornLocation(war_field_map_info, k)
		 for _,map in pairs(guild_war_maps) do
            if map.locations then
                --给出最近的复活点
                local _,dist = ShortestPath(map.locations, k)
                GetShort(war_field_map_info,dist)
                --找出每个点的距离             
                 local sort_idstance = 100000
                 local witch_port = 0
                 for i,_idstance in pairs(dist) do
                    for _,port in pairs(war_field_map_info.reborn_locations) do
                        if port == i  then
                            if sort_idstance > _idstance then
                                witch_port = port
                                sort_idstance = _idstance
                            end    
                        end
                    end
                 end
                 return witch_port
            end
        end
	end
	--------------------------------------------------------------------------------------------------------------
	--进攻方与防守方的公会名字
	processor_[C.kGetGuildWarFighterName] = function(msg)
		local req = cast('const GetGuildWarFighterName&', msg)
		local result = new('GuildWarFighterNamerResult')
		guild_war_field = guild_war_fields[req.war_field_id]
				
        if guild_war_field.defense_guild_id ~= 0  then
            local defenseid = guild_war_field.defense_guild_id
            local guild = guilds[defenseid]
            result.defense_id = defenseid
            local defenseItemName = guild.guild_info.guild_name
            local defenseItemIcon = guild.guild_info.icon
            copy(result.defenseItemName, defenseItemName,guild.guild_info.guild_name_len)
            result.defense_icon = defenseItemIcon  
            result.defenseItemNameLenth = guild.guild_info.guild_name_len     
        end    
        
        if guild_war_field.attack_guild_id ~= 0  then
            local attackid = guild_war_field.attack_guild_id
            result.attack_id = attackid
			local guild = guilds[attackid]
			local attackItemName = guild.guild_info.guild_name
			local attackItemIcon = guild.guild_info.icon
			copy(result.attackItemName, attackItemName,guild.guild_info.guild_name_len)
			result.attack_icon = attackItemIcon
			result.attackItemNameLenth = guild.guild_info.guild_name_len
        end
        
		result.defenseResourceNum = guild_war_field.defense_resource
		result.attackResourceNum = guild_war_field.attack_resource
		
		return result
	end
	--------------------------------------------------------------------------------------------------------------
    --移动过程中的错误信息
    local function MoveErrorHanding(war_field_id)
        local error_msg = nil
        if player.GetGuildId()==0 then
            error_msg = C.SOCIETY_NO_IN_GUILD										--未在公会中
            return error_msg
        end
        local war_field_info, camp = guild_war.GetWarField(player.GetGuildId(), war_field_id)
        if (not war_field_info) or (not camp) then
            error_msg = C.SOCIETY_GUILD_NOT_IN_WAR									--公会没有参加该战场
            return error_msg
        end		

        if not guild_war.IsWaring() then
            error_msg = C.SOCIETY_NOT_THE_TIME										--还未到开战时间
            return error_msg
        end
        return error_msg,war_field_info, camp
    end
    --------------------------------------------------------------------------------------------------------------
    --判断是否可以移动
    local function JudgeMove(war_field_technology,war_field_info,war_field_map_info,fighter,cur_location,req_location)
        local isCanMove = nil
        local move_cd = war_field_info.move_cd									--公会科技减少冷却时间
        if war_field_technology.sub_move_cd then
            move_cd = move_cd - war_field_technology.sub_move_cd
        end
        
        local now = os.time()
        if now - fighter.last_move_time <= move_cd then
            isCanMove = 0
        else
            isCanMove = 1
        end
  
        if not IsAdjacentLocation(cur_location, req_location) or IsRebornLocation(war_field_map_info,req_location) then
           isCanMove = 0
        end
        
        if fighter.is_dead == 1 then
            isCanMove = 1
        end
        return isCanMove
    end
    --------------------------------------------------------------------------------------------------------------
    --路点判断
    local function JudgePoint(war_field_map_info,war_field_info,fighter,location,camp)
        local locations = {}
        local cur_location = war_field_map_info.locations[fighter.location]		--当前所在路点信息
        local location_enemy_list = {}
        if cur_location then
            --如果从出身点、复活点开始移动, 重新取英雄数据
            if IsBornLocation(war_field_map_info,fighter.location) or IsRebornLocation(war_field_map_info, fighter.location) then
                fighter.group, fighter.array = player.GetHerosGroup()
                fighter.life_percent = 100
            end
            locations[1] = fighter.location
            fighter.location = location
            fighter.is_dead = 0	                                                    
            fighter.last_move_time = os.time()
            --取目标点的敌人链表
            location_enemy_list = GetLocationEnemyList(war_field_info, camp, location)
        end
        locations[2] = location
        return locations,location_enemy_list
    end
    --------------------------------------------------------------------------------------------------------------
    --战斗信息
    local function GuildWarFightingResult(fighter,enemy)
        local fight_weather = 'rain'
        local fight_terrain = 'lake'
        local env = {type=6, weather=fight_weather, terrain=fight_terrain, group_a={group_damage_per =fighter.group_damage_per, name=player.GetName(),array=fighter.array}, group_b={group_damage_per =enemy.group_damage_per,name=enemy.player_name, array=enemy.array}}
        local fighter_total_hp = 0
        local enemy_total_hp = 0
        
        for _,hero in pairs(fighter.group) do  --总血量
            fighter_total_hp = hero.max_life + fighter_total_hp
        end
        
        for _,hero in pairs(enemy.group) do  --总血量
            enemy_total_hp = hero.max_life + enemy_total_hp
        end
        
		local fight = CreateFight(fighter.group, enemy.group, env)
		local winner = fight.GetFightWinner()
        fight_info = fight.GetStatistics()
        return fight_info,winner,fighter_total_hp,enemy_total_hp
    end
    --------------------------------------------------------------------------------------------------------------
    --给指定队伍分配血量,返回剩余血量
local function DispatchHp(hp,fighter_group)
   for _,fighter in pairs(fighter_group) do
        local need_hp = fighter.max_life - fighter.life
        if hp >= need_hp then
            hp = hp - need_hp
            fighter.life = fighter.max_life
        else
             fighter.life = fighter.life + hp
             return 0
        end
    end
    return hp
end
    --------------------------------------------------------------------------------------------------------------
    local function AddBuff(war_field_info,war_field_technology,fighter,fighter_total_hp,group_life_percent)
        local life_percent = 0
        local can_heal_hp = 0
        local coefficient = global.guild.kGuildWarCoefficient
        if fighter.buff_heal_hp_buy_num ~= 0 then
            if player.GetGuildId() == war_field_info.guild_id then
                if war_field_technology.add_heal_hp_per then			--公会技能增加血量恢复上限
                    coefficient = coefficient + war_field_technology.add_heal_hp_per
                end
            end
            
            local total_add_hp = fighter_total_hp * coefficient		--buff能治疗的血量
            if (100 - group_life_percent) > coefficient*100 then
                can_heal_hp = total_add_hp
                fighter.life_percent = group_life_percent + coefficient*100
                life_percent = group_life_percent + coefficient*100
            else
                can_heal_hp =  fighter_total_hp*(100 - group_life_percent)/100
                fighter.life_percent = 100
                life_percent = 100
            end
        
            local left_hp = DispatchHp(can_heal_hp,fighter.group)
            local heal_hp = can_heal_hp - left_hp
            fighter.heal_hp = heal_hp
        else
            return group_life_percent,can_heal_hp
        end
        return life_percent,can_heal_hp
    end
    --------------------------------------------------------------------------------------------------------------
	--战场移动
	processor_[C.kGuildWarMove] = function(msg)
		local req = cast('const GuildWarMove&', msg)
		local result = new('GuildWarMoveResult')
		
        --错误判断
        local error_msg,war_field_info, camp = MoveErrorHanding(req.war_field_id)
        local vesting = camp
        if error_msg then
            result.result = error_msg
            return result
        end
        
		local fighter = FindFighter(war_field_info, player)							--自己在战场的信息
        local war_field_map_info = guild_war.GetWarFieldMapInfo(req.war_field_id)		 
        local cur_location = war_field_map_info.locations[fighter.location]			 
        
		local war_field_technology = guild_war.GetWarFieldTechnology(req.war_field_id , war_field_info.technology_level)	--取战场地图科技信息
        --判断能否移动
        result.isCanMove = JudgeMove(war_field_technology,war_field_info,war_field_map_info,fighter,cur_location,req.location)
		if result.isCanMove == 0 then
             result.result = C.SOCIETY_ERROR	
            return result
        end
        --locations 里面保存移动前后点
        local locations,location_enemy_list = JudgePoint(war_field_map_info,war_field_info,fighter,req.location,camp)
       
        --战斗结果
        for i,enemy in pairs(location_enemy_list) do
            result.is_fighting = 0
            local fight_info,winner,fighter_total_hp,enemy_total_hp = GuildWarFightingResult(fighter,enemy)
            if winner==1 then
                do
                    local group_life_percent = fight_info.group_b.life
                    local life_percent_,can_heal_hp_ = AddBuff(war_field_info,war_field_technology,enemy,enemy_total_hp,group_life_percent)
                    --自己战败,回到复活点(离开复活点时候再重新取英雄属性)
                    result.is_fighting = 1
                    result.is_dead = 1	
                    result.reborn_location = GetRebornLocation(war_field_map_info,req.location)
                    result.life_percent = 0			                                --当前队剩余血量
                    result.win_count = 0
                    result.heal_hp = 0								                --buff回复的血量
                    
                    fighter.win_count = fighter.win_count + 0											--胜利次数
                    fighter.dead_count = fighter.dead_count + 1						--死亡次数
                    fighter.hits_count = fighter.hits_count + math.abs(fight_info.group_a.hits)--伤害总数
                    fighter.location = result.reborn_location	                    --复活点
                    fighter.life_percent = 100
                    fighter.is_dead = 1
                    vesting = (camp==1 and 0 ) or 1
                    
                    --敌人战胜,buff恢复血量
                    local push = new('PushGuildWarLocationFightersInfo')
                    
                    push.is_dead = 0
                    push.life_percent = life_percent_
                    push.win_count = enemy.win_count + 1
                    push.reborn_location = 0
                    push.heal_hp = can_heal_hp_
                    
                    enemy.win_count = enemy.win_count + 1
                    enemy.kill_count = enemy.kill_count + 1							           --击杀次数
                    enemy.hits_count = enemy.hits_count + math.abs(fight_info.group_b.hits)   --伤害总数
                    enemy.life_percent = push.life_percent
                    GlobalSend2Gate(enemy.player_id ,push)
                    break
                end

            else
                local group_life_percent = fight_info.group_a.life
                local life_percent_,can_heal_hp_ = AddBuff(war_field_info,war_field_technology,fighter,fighter_total_hp,group_life_percent)
                do
                    --己方战胜,通知敌方回到复活点
                    vesting = camp
                    local push = new('PushGuildWarLocationFightersInfo')
                    enemy.dead_count = enemy.dead_count + 1							--死亡次数
                    enemy.hits_count = enemy.hits_count + math.abs(fight_info.group_b.hits)	--伤害总数	
                    enemy.win_count = enemy.win_count + 0	
                    enemy.is_dead = 1
                    enemy.win_count = 0
                    enemy.life_percent = 100
                    
                    push.is_dead = 1
                    push.reborn_location = GetRebornLocation(war_field_map_info,req.location)--己方camp==1为进攻方时,敌方为防守方,敌方复活点为defense_born_location
                    push.life_percent = 0
                    push.win_count = enemy.win_count
                    push.heal_hp = 0
                    GlobalSend2Gate(enemy.player_id, push)

                    fighter.win_count = fighter.win_count + 1
                    fighter.heal_hp = 0
                    fighter.kill_count = fighter.kill_count + 1						--击杀次数
                    fighter.hits_count = fighter.hits_count + math.abs(fight_info.group_a.hits)--伤害总数	
                    fighter.life_percent = life_percent_
                    
                    result.is_fighting = 1
                    result.win_count = fighter.win_count
                    result.is_dead = 0
                    result.reborn_location = 0
                    result.life_percent = life_percent_
                    result.heal_hp = can_heal_hp_  
                end
            end
        end
    if #location_enemy_list == 0 then
        result.life_percent = fighter.life_percent
    end
    war_field_info.takedown_location_list[req.location] = vesting		 --无敌方成员,占领该点
    guild_war.GuildWarLocationMembersInfo(locations)
    return result

	end
	--------------------------------------------------------------------------------------------------------------
	--购买战场BUFF
	processor_[C.kBuyGuildWarBuff] = function(msg)
		local req = cast('const BuyGuildWarBuff&', msg)
		local result = new('BuyGuildWarBuffResult')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD						    				--未在公会中
			return result
		end
		
		local war_field_info, camp = guild_war.GetWarField(player.GetGuildId(), req.war_field_id)
		if (not war_field_info) or (not camp) then
			result.result = C.SOCIETY_GUILD_NOT_IN_WAR										--公会没有参加该战场
			return result
		end
		
		if req.buff_type == 1 then
			local fighter = FindFighter(war_field_info, player)							--自己在战场的信息, 传入player为玩家对象,不是ID
			if fighter then
				if fighter.buff_heal_hp_buy_num >= 1 then
					result.result = C.SOCIETY_BUY_ERROR										--超过购买上限,只能购买1次
					return result
				end
                local cost=global.guild.kBuyGuildWarBuff1Cost								--恢复包
                if not player.IsGoldEnough(cost) then										--err消耗金币检查
                    result.result = C.SOCIETY_NOT_ENOUGH_GOLD
                    return result
                end
                player.ConsumeGold(cost,gold_consume_flag.guild_war_buy_buff)				--扣除金币
				fighter.buff_heal_hp = global.guild.kGuildWarBuff1HealHp					--恢复包血量初始化
				fighter.buff_heal_hp_buy_num = fighter.buff_heal_hp_buy_num + 1
			end
		elseif req.buff_type == 2 then
			local fighter = FindFighter(war_field_info, player)	
			if fighter then	
				local buff_add_attack_buy_num = 1
				if fighter.buff_add_attack_buy_num >= 3 then
					result.result = C.SOCIETY_BUY_ERROR										--超过购买上限,只能购买3次
					return result
				end
				
				local cost=0																--购买需要花费金钱
				if fighter.buff_add_attack_buy_num==0 then
					cost = global.guild.kBuyGuildWarBuff2Times1Cost
				elseif fighter.buff_add_attack_buy_num==1 then
					cost = global.guild.kBuyGuildWarBuff2Times2Cost
				elseif fighter.buff_add_attack_buy_num==2 then
					cost = global.guild.kBuyGuildWarBuff2Times3Cost
				else
					assert(false,"logic err")
				end
				
				if not player.IsGoldEnough(cost) then										--err消耗金币检查
					result.result = C.SOCIETY_NOT_ENOUGH_GOLD
					return result
				end

				player.ConsumeGold(cost,gold_consume_flag.guild_war_buy_harm)				--扣除金币
				fighter.buff_add_attack_buy_num = fighter.buff_add_attack_buy_num + buff_add_attack_buy_num		
                if fighter.buff_add_attack_buy_num == 1 then
                    fighter.group_damage_per = global.guild.kFirstAddDamagePre
                elseif fighter.buff_add_attack_buy_num == 2 then
                    fighter.group_damage_per = global.guild.kSecondAddDamagePre
                elseif fighter.buff_add_attack_buy_num == 3 then
                    fighter.group_damage_per = global.guild.kThirdAddDamagePre
                end
			end
		end
		return result
	end
    --------------------------------------------------------------------------------------------------------------
	--取战场路点信息
	processor_[C.kGetGuildWarLocationInfo] = function(msg)
		local req = cast('const GetGuildWarLocationInfo&', msg)
		local result = new('GuildWarLocationInfo')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD											--未在公会中
			return result
		end
		
		local war_field_id = player.war_field_id
		local guild_war_field = guild_war_fields[war_field_id]--warfield[player.war_field_id].guild_war_field
        local attack_member_list = guild_war_field.attack_member_list
		local defense_list = guild_war_field.defense_member_list 
		local attack_member_order_list = guild_war_field.attack_member_order_list
		local defense_member_order_list = guild_war_field.defense_member_order_list
        --获取各个玩家路点信息
        local push = new('PushGuildWarLocationMembersInfo')
        local guild_war_maps = guild_war.GetGuildWarMaps()
        local locations = guild_war_maps[10000+war_field_id].locations
        local j = 0
        for i,location in pairs(locations) do
            push.location_info[j].location = i
            local attack_count = 0
            local defense_count = 0
            for _,member in pairs(guild_war_field.attack_member_list) do 								 
                if member.location == i then
                    attack_count = attack_count + 1
                end
            end
    
            for _,member in pairs(guild_war_field.defense_member_list) do
                if member.location == i then 
                    defense_count = defense_count + 1
                end
            end
            
            local location_camp = guild_war_field.takedown_location_list[i] 
            if defense_count ~= 0 or attack_count ~= 0 or location_camp then
                push.location_info[j].attack_count = attack_count
                push.location_info[j].defense_count = defense_count
                if location_camp then
                    push.location_info[j].camp = location_camp
                else
                    push.location_info[j].camp = 2 
                end
                j = j + 1
            end

        end
            push.count = #locations
            GlobalSend2Gate(player.GetUID(), push)
        
        --推送给对应排队的玩家
        for _,fighter in pairs(attack_member_list) do
            if fighter.player_id == player.GetUID() then
                local push = new('PushGuildEnterAndOrderNum')
               push.enter_num = #attack_member_list
			   push.order_num = #attack_member_order_list
               for _,attck_player in pairs(attack_member_order_list) do
                    GlobalSend2Gate(attck_player.player_id,push)
               end
            end
        end
        
       for _,fighter in pairs(defense_list) do
            if fighter.player_id == player.GetUID() then
                local push = new('PushGuildEnterAndOrderNum')
               push.enter_num = #defense_list
			   push.order_num = #defense_member_order_list
               for _,deffense_player in pairs(defense_member_order_list) do
                    GlobalSend2Gate(deffense_player.player_id,push)
               end
            end
        end
       
		if not war_field_id then
			result.result = C.SOCIETY_GUILD_NOT_IN_WAR										--公会没有参战
			return result
		end
		
		local attack_count = 0
		for _,fighter in pairs(attack_member_list) do
		    if req.location == fighter.location then
				attack_count = attack_count + 1
			end
		end

		local defense_count = 0	
		for _,fighter in pairs(defense_list) do
		    if req.location == fighter.location then
				defense_count = defense_count + 1
			end
		end
		
		result.attack_count = attack_count
		result.defense_count = defense_count
		return result
	end
	--------------------------------------------------------------------------------------------------------------
	--取战场数据
	processor_[C.kGetGuildWarFightersInfo] = function(msg)
		local req = cast('const GetGuildWarFightersInfo&', msg)
		local result = new('GuildWarFightersInfo')
		
		if player.GetGuildId()==0 then	
			result.result = C.SOCIETY_NO_IN_GUILD											--未在公会中
			return result
		end
		
		local war_field_info = guild_war.GetWarFieldInfo(player.war_field_id)
		if not war_field_info then
			result.result = C.SOCIETY_GUILD_NOT_IN_WAR										--没有对应战场信息
			return result
		end
		
		local count = 0
		--进攻方
		local attack_count = 0
		for _,fighter in pairs(war_field_info.attack_member_list) do
			local attack_fighters = result.fighters[count]
			local guildId = fighter.player_guild_id
			local member_info = guild.GetGuildMemeberInfo(guildId,fighter.player_id)		--这里主要是用来取成员名字
			
			if member_info then
				attack_fighters.player_name_len = member_info.member_name_len;				--成员名
				copy(attack_fighters.player_name, member_info.member_name, member_info.member_name_len)
				attack_fighters.kill_count = fighter.kill_count		   						--击杀
				attack_fighters.dead_count = fighter.dead_count								--死亡
				attack_fighters.hits_count = fighter.hits_count								--造成伤害
				attack_fighters.GuildId = guildId
                attack_count = attack_count + 1
				count = count + 1
			end
		end
        
        --进攻方离开链表
        for _,fighter in pairs(war_field_info.leave_attack_players) do
			local attack_fighters = result.fighters[count]
			local guildId = fighter.player_guild_id
			local member_info = guild.GetGuildMemeberInfo(guildId,fighter.player_id)		--这里主要是用来取成员名字
			
			if member_info then
				attack_fighters.player_name_len = member_info.member_name_len;				--成员名
				copy(attack_fighters.player_name, member_info.member_name, member_info.member_name_len)
				attack_fighters.kill_count = fighter.kill_count		   						--击杀
				attack_fighters.dead_count = fighter.dead_count								--死亡
				attack_fighters.hits_count = fighter.hits_count								--造成伤害
				attack_fighters.GuildId = guildId
                attack_count = attack_count + 1
				count = count + 1
			end
		end
        
		result.attack_count = attack_count													--进攻方成员个数
		--防守方
		local defense_count = 0
		for _,fighter in pairs(war_field_info.defense_member_list) do
			local defense_fighters = result.fighters[count]
			local guildId = fighter.player_guild_id
			local member_info = guild.GetGuildMemeberInfo(fighter.player_guild_id, fighter.player_id)
			
			if member_info then
				defense_fighters.player_name_len = member_info.member_name_len;
				copy(defense_fighters.player_name, member_info.member_name, member_info.member_name_len)
				defense_fighters.kill_count = fighter.kill_count
				defense_fighters.dead_count = fighter.dead_count
				defense_fighters.hits_count = fighter.hits_count
				defense_fighters.GuildId = guildId
				defense_count = defense_count + 1
				count = count + 1
			end		
		end
        
        --防守离开链表
        for _,fighter in pairs(war_field_info.leave_defense_players) do
			local defense_fighters = result.fighters[count]
			local guildId = fighter.player_guild_id
			local member_info = guild.GetGuildMemeberInfo(fighter.player_guild_id, fighter.player_id)
			
			if member_info then
				defense_fighters.player_name_len = member_info.member_name_len;
				copy(defense_fighters.player_name, member_info.member_name, member_info.member_name_len)
				defense_fighters.kill_count = fighter.kill_count
				defense_fighters.dead_count = fighter.dead_count
				defense_fighters.hits_count = fighter.hits_count
				defense_fighters.GuildId = guildId
				defense_count = defense_count + 1
				count = count + 1
			end		
		end
        
		result.defense_count = defense_count
		return result, 12 + sizeof(result.fighters[0])*(attack_count+defense_count)
	end
	
    --------------------------------------------------------------------------------------------------------------
    processor_[C.kGuildWarCanBuyHarm] = function(msg)
        local req = cast('const GuildWarCanBuyHarm&', msg)
		local result = new('GuildWarCanBuyHarmResult')
        local vip_level = player.GetVIPLevel()
        if vip_level >= global.guild.kGuildWarCanBuyHarmVip then
            result.isCanBuyHarm = 1
        else
             result.isCanBuyHarm = 0
        end
       return result
    end
    --------------------------------------------------------------------------------------------------------------
     processor_[C.kGuildWarCanBuyBuff] = function(msg)
        local req = cast('const GuildWarCanBuyBuff&', msg)
		local result = new('GuildWarCanBuyBuffResult')
        local vip_level = player.GetVIPLevel()
        if vip_level >= global.guild.kGuildWarCanBuyBuffVip then
            result.isCanBuyBuff = 1
        else
             result.isCanBuyBuff = 0
        end
       return result
    end
    --------------------------------------------------------------------------------------------------------------
	function obj.ProcessMsgFromDb(type, msg)
		local func = db_processor_[type]
		if func then func(msg) end
	end
    --------------------------------------------------------------------------------------------------------------
	function obj.ProcessMsg(type, msg)
		local func = processor_[type]
		if func then return func(msg) end
	end
    return obj
end
------------------------------------------------------------------------------------------------------------------