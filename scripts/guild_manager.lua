require('guild')
require('data')
local guild_frames = require('config.guild_frames')
local guild_heavensents1 = require('config.guild_heavensents1')
local charset = require('config.charset')
local global = require('config.global')
local guild_war_fields = require('config.guild_war_fields')
local gold_consume_flag = require('define.gold_consume_flag')
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy
--ConstData
local kEditCallBoardLen = 200*3
local kGuildNameLen = 24
local kPlayerNameLen = 18
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
local guilds = guild.GetGuilds()
function CreateGuildManager(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--创建公会
	processor_[C.kCreateGuild] = function(msg)
		local req = cast('const CreateGuild&', msg)
		local result = new('CreateGuildResult')
		local cost = global.guild.kCreateGuildCost
        
        if req.len>kGuildNameLen then										--err名字超长
			result.result = C.SOCIETY_OVERLONG_GUILD_NAME
			return result
		end
        
        if req.len <= 0 then									--非法数据操作
			result.result = C.SOCIETY_ERROR
			return result
		end
        
        if player.GetGuildId()~=0 then							--err已经有公会了
			result.result = C.SOCIETY_ALREADY_IN_GUILD
			return result
		end

        if player.GetCityHallLevel() < global.guild.kGuildLevel then
            result.result = C.SOCIETY_LEVEL_ERROR
            return result
		end
        
        local guild_name = ffi.string(req.name, req.len)
        assert(type( guild_name)=="string")
        guild_name = string.match(guild_name,"^%s*(.-)%s*$")
        
		if not player.IsSilverEnough(cost) then			    --err消耗银币检查
			result.result = C.SOCIETY_NOT_ENOUGH_SILVER
			return result
		end

		if guild.FindGuildByName(guild_name) then				--公会名已经在使用
			result.state = 1
			return result
		end
        
		--过滤特殊字符
		for i=1,string.len(guild_name) do
		local sub_str = string.sub(guild_name,i,i)
		local ascii_num = string.byte(sub_str)
			if 	(0 <= ascii_num and ascii_num <= 47) or  (58 <= ascii_num and ascii_num <= 64)  or (91  <= ascii_num and ascii_num <= 96) or (123 <= ascii_num and ascii_num <= 127) then
				result.result = C.SOCIETY_ERROR
				return result
			end
		end
		player.ModifySilver(-cost)		                        --扣除银币

		local new_guild_id = guild.GetNewGuildId()				--新公会id
		local guild_icon = math.random(1,5)					--新公会会标

		--更新数据库
		InsertGuildInfo(new_guild_id, player.GetUID(), guild_icon, guild_name, charset.guild_grade1_name, charset.guild_grade2_name, charset.guild_grade100_name)

		--更新内存
		player.SetGuildId(new_guild_id)
		local player_name = player.GetName()
		local guild_info=new("GuildInfo", new_guild_id, 1, player.GetUID(), #player_name, player_name, guild_icon, 1, 0, 0, 0, 0, #guild_name, guild_name)
		local hs = guild_info.heavensent
		for i=0,9 do
			hs[i].id=i+1
		end
		guild.InsertGuildInfo(new_guild_id, guild_info, player.GetUID())
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--编辑公告
	processor_[C.kEditCallBoard] = function(msg)
		local req = cast('const EditCallBoard&', msg)
		local result = new('EditCallBoardResult')
        local req_len = 0
        
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if req.len > kEditCallBoardLen then	                 --err公告超长
			result.result = C.SOCIETY_OVERLONG_CALLBOARD
			return result
		end
            
		if req.len == 0 then                                    --前端未添加'\0'
		    req_len = req.len + 1
        else
            req_len = req.len 
		end
		
		if not guild.CheckAuthorityEditCallBoard(player.GetGuildId(),player.GetUID()) then
			result.state = 2								
			return result
		end
		
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		if guild_info then
			--更新数据库
			local call_board = ffi.string(guild_info.call_board, sizeof(guild_info.call_board))
			local req_call_board = ffi.string(req.content, sizeof(req.content))
			if call_board ~= req_call_board then
                local where_fields={{C.kfGuildId, player.GetGuildId()}}
                player.UpdateStringField2(C.ktGuild, #where_fields, where_fields, C.kfCallBoard, req_len, req.content)
                --更新内存
                guild_info.call_board_len = req_len
                copy(guild_info.call_board, req.content, req_len)
            end
		end
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取公会列表
	processor_[C.kGetGuildList] = function(msg)
		local req = cast('const GetGuildList&', msg)
		local result = new('GuildList')

		local guilds_count = guild.GetGuildsCount()
		local pages = math.ceil(guilds_count/7)
        local count = 0
		result.pages = pages
		--取公会列表前先排序
		guild.SortGuilds()
		if req.page <= pages then
			for i=1,7 do
				local guild_info = guild.GetGuildInfoFromSortGuilds((req.page-1)*7 + i)		--通过排名取公会信息
				if guild_info then
					local guild_info_tidy = result.guild_info_tidy[count]
					guild_info_tidy.guild_id = guild_info.guild_id
					guild_info_tidy.level = guild_info.level
					guild_info_tidy.icon = guild_info.icon
					guild_info_tidy.icon_frame = guild_info.icon_frame
					guild_info_tidy.is_applying = guild.IsInApplyList(guild_info.guild_id, player.GetUID()) and 1 or 0
					guild_info_tidy.member_cur = guild.GetGuildMembersCount(guild_info.guild_id)
					guild_info_tidy.member_max = guild.GetGuildMembersMaxCount(guild_info.guild_id)
					guild_info_tidy.leader = guild_info.leader
					guild_info_tidy.leader_name_len = guild_info.leader_name_len
					copy(guild_info_tidy.leader_name,guild_info.leader_name,guild_info.leader_name_len)
					guild_info_tidy.guild_name_len = guild_info.guild_name_len
					copy(guild_info_tidy.guild_name,guild_info.guild_name,guild_info.guild_name_len)
					count = count + 1
				end
			end
			result.count = count
		end
		return result,8+count*(sizeof(result.guild_info_tidy[0]))
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--申请公会
	processor_[C.kApplyGuild] = function(msg)
		local req = cast('const ApplyGuild&', msg)
		local result = new('ApplyGuildResult')

		if player.GetGuildId()~=0 then									--err已经在公会里了
			result.result = C.SOCIETY_ALREADY_IN_GUILD
			return result
		end

		if req.guild_id == 0 then										--err传入数据错误
			result.result = C.SOCIETY_ERROR
			return result
		end

		if guild.IsInApplyList(req.guild_id,player.GetUID()) then		--err已经在申请队列了
			result.result = C.SOCIETY_ALREADY_IN_GUILD_APPLY_LIST
			return result
		end
		
		local guild_info = guild.GetGuildInfo(req.guild_id)
		if not guild_info then											--申请的公会不存在或已解散
			result.state = 1
			return result
		end

		if guild.GetGuildApplyMembersCount(req.guild_id)>100 then		--公会申请列表已满
			result.state = 2
			return result
		end
        
        if player.GetCityHallLevel() < global.guild.kGuildLevel then  
			result.state = 3
			return result
        end 

		--更新内存与数据库
		guild.AddGuildApplyMember(req.guild_id,player.GetUID(),player.GetLevel(),player.GetName())
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--退出公会
	processor_[C.kLeaveGuild] = function(msg)
		local result = new('LeaveGuildResult')
        
		if player.GetGuildId() == 0 then
			result.result = C.SOCIETY_NO_IN_GUILD					
			return result
		end
		
		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())==1 then
			result.result = C.SOCIETY_YOU_ARE_LEADER					
			return result
		end
		
		
		--公会战内存与数据库
        obj.DeleteGuildWarMember(player.GetUID())
        
		--更新公会数据库
		LeaveGuild(player.GetUID())
        --更新公会内存
        guild.RemoveGuildMember(player.GetGuildId(), player.GetUID())
        player.SetGuildId(0)
       
       --告诉前端更新成员列表
        local push = new('PushDeleteGuildMember')
        push.player_id = player.GetUID()
        local online_players = guild.GetOnlinePlayers()
		for player_id,_ in pairs(online_players) do
			if player.GetUID() ~= player_id then
				GlobalSend2Gate(player_id,push)
			end
        end
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--邀请玩家加入公会
	processor_[C.kInviteGuildMember] = function(msg)
		local req = cast('const InviteGuildMember&', msg)
		local result = new('InviteGuildMemberResult')

        if req.player_name_len > kPlayerNameLen or req.player_name_len <= 0  then				--err名字超长或者非法制
			result.result = C.SOCIETY_OVERLONG_GUILD_NAME
			return result
		end
        
		if player.GetGuildId() == 0 then
			result.result = C.SOCIETY_NO_IN_GUILD		--未在公会中
			return result
		end

		if not guild.CheckAuthorityInviteMember(player.GetGuildId(),player.GetUID()) then
			result.state = 2							--权限不够
			return result
		end

		local invite_player_name = ffi.string(req.player_name, req.player_name_len)
		local invite_player_id,invite_player_guild_id = guild.GetInvitePlayerInfo(invite_player_name)
		if not invite_player_id then
			result.state = 3							--未找到邀请玩家或邀请玩家不在线
			return result
		end
		
		if guild.IsInInviteList(player.GetGuildId(),invite_player_id) then
			result.state = 4							--邀请对象已经在邀请列表
			return result
		end
            
		if invite_player_guild_id ~= 0 then
			result.state = 5							--邀请玩家已拥有公会
			return result
		end
		
		if data.GetOnlinePlayer(invite_player_id).GetCityHallLevel() < global.guild.kGuildLevel then
			result.state = 6							--邀请玩家等级不够
			return result
		end

		--更新内存
		guild.AddInviteMember(player.GetGuildId(),invite_player_id)
        
		--推送信息给邀请玩家
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		if guild_info then
			local push = new('PushInviteGuildMember')
			push.player_id = player.GetUID()
			local player_name = player.GetName()
			push.player_name_len = #player_name
			copy(push.player_name, player_name, #player_name)
			
			push.guild_id = player.GetGuildId()
			push.guild_name_len = guild_info.guild_name_len
			copy(push.guild_name, guild_info.guild_name, guild_info.guild_name_len)
			GlobalSend2Gate(invite_player_id,push)
		end
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--回复公会邀请
	processor_[C.kReplyGuildInvite] = function(msg)
		local req = cast('const ReplyGuildInvite&', msg)
		local result = new('ReplyGuildInviteResult')
		if req.agree==1 then							--同意邀请
        
			local guild_info = guild.GetGuildInfo(req.guild_id)
			if not guild.IsInInviteList(req.guild_id,player.GetUID()) then
				result.state = 1						--不在邀请队列（超时或非法数据）
				return result
			end

            if player.GetGuildId()~=0 then
				result.state = 2						--已经在公会中
				return result
			end

			if not guild.CanAddMember(req.guild_id) then
				result.state = 3 						--公会成员已满
				return result
			end
            
            if not guild_info then						--公会不存在或已解散
				result.state = 4
				return result
			end
            
            --添加公会数据库与内存
			JoinGuild(player.GetUID(),req.guild_id)
			local member_info = guild.InsertGuildMemeberInfo(req.guild_id,player.GetUID(),100,charset.guild_grade100_name)
            player.SetGuildId(req.guild_id)
            
            --添加公会战对应的数据
            obj.InsertGuildWarMemberInfo(req.guild_id,player.GetUID())
            
            --告诉前端更新成员列表
            local push = new('PushAddGuildMember')
            push.info = member_info
            local online_players = guild.GetOnlinePlayers()
            for player_id,_ in pairs(online_players) do
				if player_id ~= player.GetUID() then
					GlobalSend2Gate(player_id,push)
				end
            end
		else
			result.state = 6
		end
		
        --移除邀请列表
			guild.RemoveInviteMembers(req.guild_id,player.GetUID())
            
		--推送信息给邀请玩家
		local online_players = guild.GetOnlinePlayers()
		local reply_player = online_players[req.player_id]
		if reply_player then
			local player_name = player.GetName()
			local push = new('PushReplyGuildInvite')
			push.player_name_len = #player_name
			copy(push.player_name,player_name,#player_name)
			push.agree = req.agree
			GlobalSend2Gate(req.player_id,push)		
		end
        
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取公会申请成员列表
	processor_[C.kGetGuildApplyMemberList] = function(msg)
		local result = new('GuildApplyMemberList')

		if player.GetGuildId() == 0 then
			result.result = C.SOCIETY_NO_IN_GUILD		--未在公会中
			return result
		end

		if not guild.CheckAuthorityInviteMember(player.GetGuildId(),player.GetUID()) then
			result.state = 2							--权限不够
			return result
		end

		local guild_apply_members = guild.GetGuildApplyMembers(player.GetGuildId())
		if guild_apply_members then
			local count = 0
			for i,guild_apply_member in pairs(guild_apply_members) do
				local guild_apply_member_info = result.guild_apply_member_info[i-1]
				guild_apply_member_info.player_id = guild_apply_member.player_id
				guild_apply_member_info.player_level = guild_apply_member.player_level
				guild_apply_member_info.player_name_len = #guild_apply_member.player_name
				copy(guild_apply_member_info.player_name,guild_apply_member.player_name,#guild_apply_member.player_name)
				count = count + 1
			end
			result.count = count
		end

		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--回复公会申请
	processor_[C.kReplyGuildApply] = function(msg)
		local req = cast('const ReplyGuildApply&', msg)
		local result = new('ReplyGuildApplyResult')
		if player.GetGuildId() == 0 then
			result.result = C.SOCIETY_NO_IN_GUILD		--未在公会中
			return result
		end

		if not guild.CheckAuthorityInviteMember(player.GetGuildId(),player.GetUID()) then
			result.state = 2							--权限不够
			return result
		end

		if not guild.IsInApplyList(player.GetGuildId(),req.player_id) then
			result.state = 3							--已经不在申请列表了(超时或者已经被其他管理员操作)
			return result
		end
		
		local online_players = guild.GetOnlinePlayers()
		local reply_player = online_players[req.player_id]
		
		if req.agree==1 then							--同意申请
			local reply_player_guild_id=0

			if reply_player then
				--申请对象在线,可以直接取出公会ID判断
				reply_player_guild_id = reply_player.GetGuildId()
			else
				--申请对象离线
				reply_player_guild_id = guild.GetOfflinePlayerGuildId(req.player_id)
			end

            local guild_member_info = nil
			if reply_player_guild_id ~= 0 then
				result.state = 4			--回复对象已经在公会中
			else
				if guild.CanAddMember(player.GetGuildId()) then
					--更新数据库
					JoinGuild(req.player_id,player.GetGuildId())
                    guild.RemoveAllApplyMembers(req.player_id) --删除所有的申请
					--更新内存
					guild_member_info = guild.InsertGuildMemeberInfo(player.GetGuildId(),req.player_id,100,charset.guild_grade100_name)
                    --添加到公会战中
                    obj.InsertGuildWarMemberInfo(player.GetGuildId(),req.player_id)
					if reply_player then	--如果在线
						reply_player.SetGuildId(player.GetGuildId())
					end
				else
					result.state = 5		--公会成员已满
				end
			end
            
            --告诉前端更新成员列表
            local push = new('PushAddGuildMember')
            push.info = guild_member_info
            local online_players = guild.GetOnlinePlayers()
            for player_id,_ in pairs(online_players) do
				if player_id ~= req.player_id then
					GlobalSend2Gate(player_id,push)
				end
            end
		else
	        guild.RemoveApplyMembers(player.GetGuildId(),req.player_id)
		end

		if reply_player then
			local guild_info = guild.GetGuildInfo(player.GetGuildId())
			if guild_info then
				local push = new('PushReplyGuildApply',player.GetGuildId(),req.agree,guild_info.guild_name_len)
				copy(push.guild_name,guild_info.guild_name,guild_info.guild_name_len)
				GlobalSend2Gate(req.player_id,push)
			end
		end
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--改变成员会阶等级
	processor_[C.kChangeGuildMemberGrade] = function(msg)
		local req = cast('const ChangeGuildMemberGrade&', msg)
		local result = new('ChangeGuildMemberGradeResult')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if player.GetUID()==req.player_id then
			result.result = C.SOCIETY_ACTION_ERR				--无法对自己操作
			return result
		end
		
		if not guild.CheckAuthorityChangeGrade(player.GetGuildId(),player.GetUID()) then
			result.state = 2									--权限不够
			return result
		end	

		local self_grade_level = guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())			--自己会阶
		local change_player_grade_level = guild.GetGuildMemeberGradeLevel(player.GetGuildId(),req.player_id)	--目标会阶
		
		if self_grade_level >= change_player_grade_level then
			result.state = 2									--权限不够,自己会阶比目标低,无法修改对方会阶
			return result
		end

		local new_grade_level=0
		local guild_level_max = guild.GetGradeLevelMax(player.GetGuildId())			--公会当前总会阶数
		
		if req.state == 1 then									--提升目标会阶
			if change_player_grade_level == 100 then
				new_grade_level = guild_level_max - 1			--普通会员为0，提升到次阶
			else
				new_grade_level = change_player_grade_level - 1
				if new_grade_level == self_grade_level then
					result.state = 2							--权限不够,无法提升到自己同阶
					return result
				end
			end
		else													--降阶
			if change_player_grade_level == 100 then
				result.result = C.SOCIETY_BEINGLESS_GRADE_LEVEL	--不存在的公会权限,已经不能再降了
				return result
			else
				new_grade_level = change_player_grade_level + 1
				if new_grade_level >= guild_level_max then		--超过公会最大会阶等级
					new_grade_level = 100
				end
			end
		end

		--更新数据库
		player.UpdateOtherField(C.ktGuildMemberInfo, req.player_id, {C.kfGuildGradeLevel, new_grade_level})

		--更新内存
		guild.SetGuildMemberGradeLevel(player.GetGuildId(), req.player_id, new_grade_level)
		
		--推送信息给玩家
		local guild_id = player.GetGuildId()
        local push = new('PushChangeGuildMemberGrade')
		push.grade_level = new_grade_level
		local grade_name = guilds[guild_id].grades_info[new_grade_level].grade_name
		push.grade_name_len = guilds[guild_id].grades_info[new_grade_level].grade_name_len
		push.grade_name = grade_name
		push.grade_authority = guilds[guild_id].grades_info[new_grade_level].authority
		GlobalSend2Gate(req.player_id,push)
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--弹劾公会会长
	processor_[C.kDelateGuildLeader] = function(msg)
		local req = cast('const DelateGuildLeader&', msg)
		local result = new('DelateGuildLeaderResult')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD					--未在公会中
			return result
		end
		
		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())==1 then
			result.result = C.SOCIETY_YOU_ARE_LEADER				--会长不能弹劾自己
			return result
		end
		
		local guild_leader_info = guild.GetGuildLeaderInfo(player.GetGuildId())
		if guild_leader_info then
			local online_players = guild.GetOnlinePlayers()
			if online_players[guild_leader_info.player_id] then	--会长在线,不能弹劾
				result.result = C.SOCIETY_DELATE_GUILD_LEADER
				return result
			else
				if os.time() - guild_leader_info.online_state < 30*24*60*60 then
					result.result = C.SOCIETY_DELATE_GUILD_LEADER	--会长离线时间未满一个月,不能弹劾
					return result
				end
			end
			
			if guild.IsInDelateList(player.GetGuildId(),player.GetUID()) then	--err已经在弹劾队列了
				result.result = C.SOCIETY_ALREADY_IN_GUILD_DELATE_LIST
				return result
			end
			
			if guild.GetGuildDelateMembersCount(player.GetGuildId())>=4 then	--弹劾成功,会长替换(满5个人就弹劾)
				--更新数据库
				local new_guild_leader_info = guild.GetNewGuildLeaderInfo(player.GetGuildId())				--7天内在线且贡献最高玩家
				if new_guild_leader_info then
					player.UpdateOtherField(C.ktGuildMemberInfo, guild_leader_info.player_id, {C.kfGuildGradeLevel, 2})		--原会长降为副会长
					player.UpdateOtherField(C.ktGuildMemberInfo, new_guild_leader_info.player_id, {C.kfGuildGradeLevel, 1})
					player.UpdateField2(C.ktGuild, C.kfGuildId, player.GetGuildId(), 0, C.kInvalidID, {C.kfLeader, new_guild_leader_info.player_id})
					
					--更新内存
					guild.SetGuildMemberGradeLevel(player.GetGuildId(), guild_leader_info.player_id, 2)
					guild.SetGuildMemberGradeLevel(player.GetGuildId(), new_guild_leader_info.player_id, 1)
					local leader_nickname = ffi.string(new_guild_leader_info.member_name, new_guild_leader_info.member_name_len)
					guild.UpdateGuildLeaderName(player.GetGuildId(), new_guild_leader_info.player_id, leader_nickname)	--更新内存数据库的会长名
					
					--重置弹劾列表
					guild.ResetDelateMemberList(player.GetGuildId())
					return result
				end
			else
				--更新内存
				guild.AddGuildDelateMember(player.GetGuildId(),player.GetUID())
				return result	
			end
		end
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--会长转让
	processor_[C.kTransferGuildLeader] = function(msg)
		local req = cast('const TransferGuildLeader&', msg)
		local result = new('TransferGuildLeaderResult')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD								--自己不在公会中
			return result
		end
		
		if player.GetUID()==req.player_id then
			result.result = C.SOCIETY_ACTION_ERR								--无法对自己操作
			return result
		end
		
		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER						--不是会长
			return result
		end

		local new_guild_leader_info = guild.GetGuildMemeberInfo(player.GetGuildId(),req.player_id)
		if not new_guild_leader_info then
			result.state= 1														--成员不存在
			return result
		end
		
		--更新数据库
		player.UpdateField(C.ktGuildMemberInfo, -1, {C.kfGuildGradeLevel, 2})	--降级为副会长
		player.UpdateOtherField(C.ktGuildMemberInfo, req.player_id, {C.kfGuildGradeLevel, 1})	--目标升降为会长
		player.UpdateField2(C.ktGuild, C.kfGuildId, player.GetGuildId(), 0, C.kInvalidID, {C.kfLeader, req.player_id})
		
		--更新内存
		guild.SetGuildMemberGradeLevel(player.GetGuildId(), player.GetUID(), 2)
		guild.SetGuildMemberGradeLevel(player.GetGuildId(), req.player_id, 1)
		local leader_nickname = ffi.string(new_guild_leader_info.member_name, new_guild_leader_info.member_name_len)
		guild.UpdateGuildLeaderName(player.GetGuildId(), req.player_id, leader_nickname)		--更新内存数据库的会长名
		
		--推送信息给新会长
		local push = new('PushTransferGuildLeader')
		GlobalSend2Gate(req.player_id,push)	

		--重置弹劾列表
		guild.ResetDelateMemberList(player.GetGuildId())
		
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--踢出公会
	processor_[C.kKickoutGuildMember] = function(msg)
		local req = cast('const KickoutGuildMember&', msg)
		local result = new('KickoutGuildMemberResult')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if player.GetUID()==req.player_id then
			result.result = C.SOCIETY_ACTION_ERR				--无法对自己操作
			return result
		end
	
		if not guild.CheckAuthorityKickoutMember(player.GetGuildId(),player.GetUID()) then
			result.state = 2									--权限不够
			return result
		end
		
		local self_grade_level = guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())			--自己会阶
		local change_player_grade_level = guild.GetGuildMemeberGradeLevel(player.GetGuildId(),req.player_id)	--目标会阶
		
		if self_grade_level >= change_player_grade_level then
			result.state = 2									--权限不够,无法踢自己同级或者比自己高级的
			return result
		end
		
		if self_grade_level == 100 then
			result.state = 2									--权限不够,其他会阶都比自己高
			return result
		end

        --删除公会战数据
        obj.DeleteGuildWarMember(req.player_id)
        
		--更新数据库
		LeaveGuild(req.player_id)
		--更新内存
        guild.RemoveGuildMember(player.GetGuildId(),req.player_id)
        
		local online_players = guild.GetOnlinePlayers()
		local kick_player = online_players[req.player_id]

		if kick_player then
			kick_player.SetGuildId(0)
			--推送信息给被踢玩家
			local guild_info = guild.GetGuildInfo(player.GetGuildId())
			if guild_info then
				local push = new('PushKickoutGuildMember')
				push.guild_name_len = guild_info.guild_name_len
				copy(push.guild_name,guild_info.guild_name,guild_info.guild_name_len)
				GlobalSend2Gate(req.player_id,push)
			end
		end
        --告诉前端更新成员列表
        local push = new('PushDeleteGuildMember')
		push.player_id = req.player_id
        local online_players = guild.GetOnlinePlayers()
		for player_id,_ in pairs(online_players) do
			if player_id ~= req.player_id then
				GlobalSend2Gate(player_id,push)
			end
        end
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--解散公会
	processor_[C.kDisbandGuild] = function(msg)
		local req = cast('const DisbandGuild&', msg)
		local result = new('DisbandGuildResult')
   
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end

		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER		--权限不够
			return result
		end
 
      
         for _,guild_war_field in ipairs(guild_war_fields) do 
            if  guild_war_field.guild_id == player.GetGuildId() then
                result.result = C.SOCIETY_GUILD_WAR		            --拥有战场领地不能解散工会
                return result
            end
            
            for _,id in pairs(guild_war_field.sign_list) do
                if player.GetGuildId() == id then
                    result.result = C.SOCIETY_GUILD_QUEUE
                    return result
                end
            end
            
             for j,guild_id in ipairs(guild_war_field.sign_list) do 
                if guild_id == player.GetGuildId() then
                    table.remove(guild_war_field.sign_list,j)
                end
            end
            
         end
        
		local guild_members_info = guild.GetGuildMembersInfo(player.GetGuildId())
		local online_players = guild.GetOnlinePlayers()
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		
        if guild_members_info and online_players and guild_info then
			local push = new('PushGuildDisbanded')
			push.guild_name_len = guild_info.guild_name_len
			copy(push.guild_name,guild_info.guild_name,guild_info.guild_name_len)
			
			for _,guild_member_info in pairs(guild_members_info) do
				if online_players[guild_member_info.player_id] then
					--推送信息给公会在线玩家
					GlobalSend2Gate(guild_member_info.player_id,push)	
				end
                db.SendMail(guild_member_info.player_id, os.time(),charset.guild_war_mail_str1,charset.disbandGuild, nil, true)        
			end
		end
		
		--更新数据库
		DeleteGuildInfo(player.GetGuildId())
		--更新内存
		guild.DisbandGuild(player.GetGuildId())
		
		return result	
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取公会信息
	processor_[C.kGetGuildMainInfo] = function(msg)
		local req = cast('const GetGuildMainInfo&', msg)
		local result = new('GuildMainInfo')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end

		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		if guild_info then
			--计算cur/max
			guild_info.member_cur = guild.GetGuildMembersCount(guild_info.guild_id)
			guild_info.member_max = guild.GetGuildMembersMaxCount(guild_info.guild_id)
			copy(result.guild_info,guild_info,sizeof(guild_info))
			return result, 4+sizeof(guild_info)-sizeof(guild_info.call_board)+guild_info.call_board_len
		end
	
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取公会成员列表
	processor_[C.kGetGuildMemberList] = function(msg)
		local req = cast('const GetGuildMemberList&', msg)
		local result = new('GuildMemberList')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中USE
			return result
		end

		local count = 0
        local guild_members_info = guild.GetGuildMembersInfo(player.GetGuildId())
            local online_players = guild.GetOnlinePlayers()
            if guild_members_info and online_players then
                for i,guild_member_info in pairs(guild_members_info) do
                    local member_info = result.guild_member_info[i-1]
                    copy(member_info,guild_member_info,sizeof(guild_member_info))
                    if online_players[member_info.player_id] then
                        member_info.online_state = 0
                    end
                    member_info.member_level = data.GetPlayerLevel(member_info.player_id)
                       local guild_grade_info = guild.GetGuildGradeInfo(player.GetGuildId(),member_info.grade_level)
                    if guild_grade_info then
                        member_info.grade_name_len = guild_grade_info.grade_name_len
                        copy(member_info.grade_name, guild_grade_info.grade_name, guild_grade_info.grade_name_len)
                    end
                    result.guild_member_info[i-1].member_level = data.GetPlayerLevel(result.guild_member_info[i-1].player_id)
                    count = count + 1
                end
            end
		result.count = count 
 		return result,12+count*sizeof(result.guild_member_info[0])
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取自己会阶对应权利
	processor_[C.kGetGuildAuthority] = function(msg)
		local result = new('GuildAuthority')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		local authority = guild.GetGuildGradeAuthority(player.GetGuildId(),player.GetUID())
		if authority then
			copy(result.authority,authority, sizeof(authority))
		end

		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取所有会阶信息管理
	processor_[C.kGetGuildGradesInfo] = function(msg)
		local req = cast('const GetGuildGradesInfo&', msg)
		local result = new('GuildGradesInfo')

		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end

		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER		--权限不够
			return result
		end

		local count = 0
		local guild_grades_info = guild.GetGuildGradesInfo(player.GetGuildId())
		for _,guild_grade_info in pairs(guild_grades_info) do
			local grade_info = result.grade_info[count]
			copy(grade_info,guild_grade_info,sizeof(guild_grade_info))
			count = count+1
		end
		result.count = count
		
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--会长保存会阶信息
	processor_[C.kSaveGuildGradeInfo] = function(msg)
		local req = cast('const SaveGuildGradeInfo&', msg)
		local result = new('SaveGuildGradeInfoResult')
        
		if req.grade_info.grade_name_len>24 or req.grade_info.grade_name_len <= 0 then				--err名字超长或者非法数据
			result.result = C.SOCIETY_ERROR
			return result
		end	
        
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end

		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER		--不是会长
			return result
		end
	
		--更新数据库
        local where_fields={{C.kfGuildId, player.GetGuildId()},{C.kfGuildGradeLevel, req.grade_info.grade_level}}
		player.UpdateBinaryStringField(C.ktGuildAuthority, #where_fields, where_fields, C.kfGradeAuthority, sizeof(req.grade_info.authority), req.grade_info.authority)
		local grade_name = ffi.string(req.grade_info.grade_name, req.grade_info.grade_name_len)
		player.UpdateStringField2(C.ktGuildAuthority, #where_fields, where_fields, C.kfGradeName, #grade_name, grade_name)
		--给对应会阶改变后发个通知
        local push = new('PushGuildGradesInfo')
        push.authority =req.grade_info.authority
        for _,member in pairs(guilds[player.GetGuildId()].members_info) do
             if member.grade_level == req.grade_info.grade_level then
                GlobalSend2Gate(member.player_id, push)
             end
        end
		--更新内存
		guild.UpdateGuildGradeInfo(player.GetGuildId(),req.grade_info.grade_level,req.grade_info)
		
		return result
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--升级会标框
	processor_[C.kUpgradeGulildIconFrame] = function(msg)
		local result = new('UpgradeGulildIconFrameResult')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if not guild.CheckAuthorityEditIcon(player.GetGuildId(),player.GetUID()) then
			result.state = 2									--权限不够
			return result
		end
		
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		local guild_frame = guild_frames[guild_info.icon_frame]

		if guild_info.icon_frame == #guild_frames then
			result.state = 3 --已经是最高级别
			return result
		end
		
		local cost = guild_frame.need_gold
		
		if not player.IsGoldEnough(cost) then					--err消耗金币检查
			result.result = C.SOCIETY_NOT_ENOUGH_GOLD
			return result
		end
		
		player.ConsumeGold(cost,gold_consume_flag.guild_upgrade_monogram_box)
		
		local new_icon_frame = guild_info.icon_frame + 1
		
		--更新数据库
		player.UpdateField2(C.ktGuild, C.kfGuildId, player.GetGuildId(), 0, C.kInvalidID, {C.kfIconFrame, new_icon_frame})		
		--更新内存
		guild_info.icon_frame = new_icon_frame

		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--上传会标
	processor_[C.kUploadGulildIcon] = function(msg)
		local req = cast('const UploadGulildIcon&', msg)
		local result = new('UploadGulildIconResult')
        
        if req.icon_bin_len > 1024*20 or req.icon_bin_len <= 0 then
            result.result = C.SOCIETY_ERROR				       --未在公会中
			return result
        end
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if not guild.CheckAuthorityEditIcon(player.GetGuildId(),player.GetUID()) then
			result.state = 2									--权限不够
			return result
		end
	
		local cost = global.guild.kUploadGulildIconCost
		if not player.IsGoldEnough(cost) then					--金币检查
			result.result = C.SOCIETY_NOT_ENOUGH_GOLD
			return result
		end
		
		player.ConsumeGold(cost,gold_consume_flag.guild_upgrade_icon)		--扣除金币		
    

        local guild_info = guild.GetGuildInfo(player.GetGuildId())
        --改内存
        local guild_id = player.GetGuildId()
        player.InsertIconBin(player.GetGuildId(),req.icon_bin_len,req.icon_bin) --插入guild_ico 
        local custom_icon_bin = ffi.string(req.icon_bin, req.icon_bin_len)
        guilds[guild_id].custom_icon = {}
        guilds[guild_id].custom_icon.icon_bin = custom_icon_bin
        guilds[guild_id].custom_icon.icon_bin_len = custom_icon_bin.len(custom_icon_bin)
         UpdateField2(C.ktGuild, C.kfGuildId, player.GetGuildId(), 0, C.kInvalidID, {C.kfIcon, guild_info.icon}) --更改guild中玩家选择图标
         guild_info.icon = 100        
        return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --获取更改上传会标
	processor_[C.kGetGulildIcons] = function(msg)
		local req = cast('const GetGulildIcons&', msg)
		local result = new('GulildIcons')
        if guilds[req.guild_id].custom_icon.icon_bin_len then
            ffi.copy(result.icon_bin,guilds[req.guild_id].custom_icon.icon_bin,guilds[req.guild_id].custom_icon.icon_bin_len)
		    result.icon_bin_len = guilds[req.guild_id].custom_icon.icon_bin_len
        else
            result.icon_bin = ''
		    result.icon_bin_len = 0
        end
		return result
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--保存选择会标
	processor_[C.kSaveGulildUseIcon] = function(msg)
		local req = cast('const SaveGulildUseIcon&', msg)
		local result = new('SaveGulildUseIconResult')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		if not guild.CheckAuthorityEditIcon(player.GetGuildId(),player.GetUID()) then
			result.state = 2									--权限不够
			return result
		end	
        --更改数据库
        local guild_id = player.GetGuildId()
        db.UpdateGuildIcons(guild_id,req.icon)
        local guild_info = guild.GetGuildInfo(player.GetGuildId())
        guild_info.icon = req.icon
		return result
	end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--取公会新闻
	processor_[C.kGetGuildNews] = function(msg)
		local req = cast('const GetGuildNews&', msg)
		local result = new('GuildNews')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD				--未在公会中
			return result
		end
		
		local count = 0
		local guild_news = guild.GetGuildNews(player.GetGuildId())
		for i,news in pairs(guild_news) do
			local gnews = result.gnews[i-1]
			copy(gnews.triger_name,news.triger_name,news.triger_name_len)
			gnews.triger_name_len = news.triger_name_len
			gnews.time = news.time
			gnews.type = news.type
			gnews.content = news.content

			count = count + 1
		end
		result.count = count

		return result,12+count*(sizeof( result.gnews[0]))
	end
    
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	--保存天赋加点
	processor_[C.kSaveGuildHeavensent] = function(msg)
		local req = cast('const SaveGuildHeavensent&', msg)
		local result = new('SaveGuildHeavensentResult')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD							--自己不在公会中
			return result
		end

		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER					--不是会长
			return result
		end
		
		if req.count~=10 then		--此值默认应该为10
			result.result = C.SOCIETY_ERROR									--err非法数据操作，传入数据错误
			return result
		end
		
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		if guild_info then
		
			local hs_count=0
			local req_hs = req.heavensent
			
			for i=0,9 do
				local check_hs = req_hs[i]
				hs_count = hs_count + check_hs.level
				
				if check_hs.id~=i+1 then
					result.result = C.SOCIETY_UNKNOW_HEAVENSENT					--未知的天赋加点
					return result
				end
		
				local ghs = guild_heavensents1[check_hs.id]
				if not ghs then
					result.result = C.SOCIETY_UNKNOW_HEAVENSENT					--未知的天赋加点
					return result
				end
				
				if check_hs.level~=0 then
					if ghs.active_level>guild_info.level then
						result.result = C.SOCIETY_HEAVENSENT_LEVEL_ERR			--公会等级不够不能加点
						return result
					end		
					
					if check_hs.level>ghs.level_max then
						result.result = C.SOCIETY_HEAVENSENT_LEVEL_ERR			--天赋加点超过最大等级限制
						return result
					end
					
					local need_prepare_heavensent = ghs.need_prepare_heavensent
					if need_prepare_heavensent then		
						local prepare_hs = req_hs[need_prepare_heavensent.prepare-1]
						if (not prepare_hs) or (prepare_hs.level<need_prepare_heavensent.level) then
							result.result = C.SOCIETY_HEAVENSENT_PREPARE_ERR	--天赋加点前置错位
							return result
						end
					end
				end
			end
			
			if hs_count > math.floor(guild_info.level/2) then
				result.result = C.SOCIETY_HEAVENSENT_LEVEL_ERR					--天赋加点超过最大等级限制
				return result
			end
			
			
			--更新数据库
			local where_fields={{C.kfGuildId, player.GetGuildId()}}
			player.UpdateBinaryStringField(C.ktGuild, #where_fields, where_fields, C.kfHeavensent, sizeof(req.heavensent), req.heavensent)	

			--更新内存
			local guild_info = guild.GetGuildInfo(player.GetGuildId())
			ffi.copy(guild_info.heavensent, req.heavensent, sizeof(req.heavensent))
		
		end
		
		return result
	end

	--重置天赋加点
	processor_[C.kResetGuildHeavensent] = function(msg)
		local req = cast('const ResetGuildHeavensent&', msg)
		local result = new('ResetGuildHeavensentResult')
		
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD							--自己不在公会中
			return result
		end

		if guild.GetGuildMemeberGradeLevel(player.GetGuildId(),player.GetUID())~=1 then
			result.result = C.SOCIETY_YOU_ARE_NOT_LEADER					--不是会长
			return result
		end
		
		local cost=global.guild.kResetGuildHeavensentCost
		if not player.IsGoldEnough(cost) then								--err消耗金币检查
			result.result = C.SOCIETY_NOT_ENOUGH_GOLD
			return result
		end
		
		player.ConsumeGold(cost,gold_consume_flag.guild_resert_talent)		--扣除金币
		
		
		--更新数据库
		local new_heavensent = new('NewHeavensent')
		local hs = new_heavensent.heavensent
		for i=0,9 do
			hs[i].id=i+1
		end
		
		local where_fields={{C.kfGuildId, player.GetGuildId()}}
		player.UpdateBinaryStringField(C.ktGuild, #where_fields, where_fields, C.kfHeavensent, sizeof(new_heavensent), new_heavensent)	
		
		--更新内存
		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		ffi.copy(guild_info.heavensent, new_heavensent, sizeof(new_heavensent))

		return result
	end
	
    
    --取天赋加点
	processor_[C.kGetGuildHeavensent] = function(msg)
		local req = cast('const GetGuildHeavensent&', msg)
		local result = new('GuildHeavensent')
		if player.GetGuildId()==0 then
			result.result = C.SOCIETY_NO_IN_GUILD							--未在公会中
			return result
		end

		local guild_info = guild.GetGuildInfo(player.GetGuildId())
		if guild_info then
			result.count=10
			ffi.copy(result.heavensent, guild_info.heavensent, sizeof(guild_info.heavensent))
		end
		return result
	end
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --插入到公会战中
	function obj.InsertGuildWarMemberInfo(req_guild_id,player_id)
        for i,guild_war_filed in pairs(guild_war_fields) do
            if guild_war_filed.guild_id == req_guild_id then
                local add_player = {}
                add_player.is_get_member_box = 0 --不能领取
                add_player.player_id = player_id
                add_player.war_field_offer = 0 --贡献为0
                table.insert(guild_war_filed.members_info,add_player)
                GlobalInsertRow(C.ktGuildWarMemberInfo, {C.kfPlayer,player_id},{C.kfGuildId, req_guild_id},{C.kfWarFieldId,i},{C.kfWarFieldOffer,0},{C.kfIsGetMemberBox,0})
            end  
        end
    end
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --删除公会战成员表相关信息
    function obj.DeleteGuildWarMember(player_id)
        for _,guild_war_field in ipairs(guild_war_fields) do
            for i,member in pairs(guild_war_field.members_info) do
                if member.player_id == player_id then
                    table.remove(guild_war_field.members_info,i) --内存
                    db.DeleteGuildWarMemberInfo(player_id,player.GetGuildId()) --数据库
                end
            end
        end
    end
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	function obj.ProcessMsgFromDb(type, msg)
		local func = db_processor_[type]
		if func then return func(msg) end
	end
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	function obj.ProcessMsg(type, msg)
		local func = processor_[type]
		if func then return func(msg) end
	end
    return obj
end
