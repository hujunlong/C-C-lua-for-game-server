module("guild",package.seeall)
require('global_data')

local guild_skills = require('config.guild_skills')
local guild_heavensents2 = require('config.guild_heavensents2')
local guild_exp_map = require('config.guild_exp')
local charset = require('config.charset')
local global = require('config.global')
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local copy = ffi.copy


local guilds={}						     
local sort_guilds_info={}			
local last_guild_id=0				
local online_players = nil			
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取在线玩家列表
function GetOnlinePlayers()
	return online_players
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--按公会等级和会标框排序
local function SortFunc(guild_info1,guild_info2)
	if guild_info1.icon_frame > guild_info2.icon_frame then
		return true
	elseif guild_info1.icon_frame == guild_info2.icon_frame then
		if guild_info1.level > guild_info2.level then
			return true
		elseif guild_info1.level == guild_info2.level then
			if guild_info1.guild_id < guild_info2.guild_id then
				return true
			end
		else
			return false
		end
	else
		return false
	end
	return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会列表前调用,按排序后列表发送给前端
function SortGuilds()
	table.sort(sort_guilds_info,SortFunc)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--通过排名取公会信息
function GetGuildInfoFromSortGuilds(idx)
	return sort_guilds_info[idx]
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会总数
function GetGuildsCount()
	-- notes: 公会总数不能取 #guilds
	return #sort_guilds_info
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--从数据库初始化公会列表,并排序
function InitGuilds(g_players)
	online_players = g_players
	--读取数据库
	last_guild_id = db.GetGuildsInfo(guilds)
	--初始相关链表
	for _,guild in pairs(guilds) do
		guild.invite_members={}								--公会邀请列表
		guild.delate_members={}								--公会弹劾会长列表
		guild.news={}										--公会News
		table.insert(sort_guilds_info,guild.guild_info)	--公会信息排序列表( notes: 是guild.guild_info ,不是guild)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会相关数据
function GetGuilds()
    return guilds
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会相关数据
function GetGuild(guild_id)
    return guilds[guild_id]
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取新公会id,建立新公会时使用
function GetNewGuildId()
	return last_guild_id + 1
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--通过公会ID取公会信息
function GetGuildInfo(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		return guild.guild_info
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会成员总数
function GetGuildMembersCount(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_members_info = guild.members_info
		if guild_members_info then
			return #guild_members_info
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--根据公会等级取会阶上限
function GetGradeLevelMax(guild_id)
	return 3 + AddGradeLevelMax(guild_id)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会战利品仓库
function GetGuildGiving(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		return guild.giving
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加一个新的公会
function InsertGuildInfo(new_guild_id,guild_info,player_id)
	last_guild_id = new_guild_id

	--新公会添加到列表
	guilds[new_guild_id]={}
	guilds[new_guild_id].guild_info = guild_info
	
	--新公会添加到排序列表
	table.insert(sort_guilds_info,guild_info)
	
	--初始化公会成员列表(公会创始人)
	guilds[new_guild_id].members_info = {}
	InsertGuildMemeberInfo(new_guild_id,player_id,1,charset.guild_grade1_name)

	--初始化新公会会阶信息(新建公会为3个会阶)
	guilds[new_guild_id].grades_info = {}
	InsertGuildGradeInfo(new_guild_id,1,charset.guild_grade1_name,new("Authority",1,1,1,1,1,1,1,1))
	InsertGuildGradeInfo(new_guild_id,2,charset.guild_grade2_name,new("Authority",1,1,1,1))
	InsertGuildGradeInfo(new_guild_id,100,charset.guild_grade100_name,new("Authority",1))
	
	--初始化申请、邀请列表
	local guild = guilds[new_guild_id]
	guild.invite_members={}								--公会邀请列表
	guild.delate_members={}								--公会弹劾会长列表
	guild.news={}										--公会News
	guild.giving={}										--公会战利品仓库
	guild.apply_members = {}                           --创建申请列表
    RemoveAllApplyMembers(player_id)                   --删除玩家的所有申请
    RemoveAllInvite(player_id)                         --删除所有的玩家邀请
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--初始化新公会会阶信息(对应 公会、会阶、会阶名、权限)
function InsertGuildGradeInfo(guild_id,grade_level,grade_name,grade_authority)
	local guild = guilds[guild_id]
	if guild then
		local guild_grades_info = guild.grades_info
		if guild_grades_info then
			local guild_grade_info = new("GuildGradeInfo",grade_level, #grade_name, grade_name)
			ffi.copy(guild_grade_info.authority, grade_authority, sizeof(grade_authority))	
			guild_grades_info[grade_level] = guild_grade_info
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--更新公会会阶信息(会阶名、权限))
function UpdateGuildGradeInfo(guild_id,grade_level,grade_info)
	local guild = guilds[guild_id]
	if guild then
		local guild_grades_info = guild.grades_info
		if guild_grades_info then
			local guild_grade_info = guild_grades_info[grade_level]
			if guild_grade_info then
				ffi.copy(guild_grade_info,grade_info,sizeof(grade_info))
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--解散工会
function DisbandGuild(guild_id)
	local guild = guilds[guild_id]
	if guild then
		--重置base_info公会字段
		local guild_members_info = guild.members_info
		if guild_members_info then
			for _,guild_member_info in pairs(guild_members_info) do
				local player = online_players[guild_member_info.player_id]
				if player then
					player.SetGuildId(0)
				end
			end
		end
        for _,guild_member_info_ in pairs(guild_members_info) do
            UpdateField2(C.ktBaseInfo,C.kfPlayer,guild_member_info_.player_id,0,C.kInvalidID,{C.kfGuildId,0}) 
        end
        
		--移除排序列表
		for i,sort_guild_info in pairs(sort_guilds_info) do
			if sort_guild_info.guild_id == guild_id then
				table.remove(sort_guilds_info,i)
			end
		end
		guilds[guild_id] = nil
        DeleteGuildInfo(guild_id)
        
        --删除guild_member_info  guild_application guild_icon
        db.DisbandGuild(guild_id)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取新会长ID(7天内在线且贡献最高)
function GetNewGuildLeaderInfo(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_members_info = guild.members_info
		if guild_members_info then
			local new_leader_info = nil
			for _,guild_member_info in pairs(guild_members_info) do
				if guild_member_info.grade_level ~= 1 and os.time()-guild_member_info.online_state < 7*24*60*60 then		--不是老会长,7天内登陆过
					if not new_leader_info then
						new_leader_info = guild_member_info
					else
						if new_leader_info.guild_offer < guild_member_info.guild_offer then
							new_leader_info=guild_member_info
						end
					end
				end
			end
			return new_leader_info
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--通过公会名查找公会(检查公会名是否被使用)
function FindGuildByName(name)
	for _,guild in pairs(guilds) do
		local guild_info = guild.guild_info
		if guild_info then
			local guild_name = ffi.string(guild_info.guild_name, guild_info.guild_name_len)
			if guild_name == name then
				return guild_info
			end
		end
	end
    return nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取会长信息
function GetGuildLeaderInfo(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_members_info = guild.members_info
		if guild_members_info then
			for _,guild_member_info in pairs(guild_members_info) do
				if guild_member_info.grade_level == 1  then
					return guild_member_info
				end
			end
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--更新新会长的名字
function UpdateGuildLeaderName(guild_id,leader,nickname)
	local guild = guilds[guild_id]
	if guild then
		local nickname_len = #nickname
	
		local guild_info = guild.guild_info
		if guild_info then
			guild_info.leader = leader
			guild_info.leader_name_len = nickname_len
			copy(guild_info.leader_name,nickname,nickname_len)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加公会新闻
function AddGuildNews(guild_id,triger_name,triger_name_len,news_type,news_content)
	local guild = guilds[guild_id]
	if guild then
		local guild_news = guild.news
		if guild_news then
        if #guild_news== global.guild.kGuildNewMax then table.remove(guild_news, 1) end   --表示添加20条上限数据
			
			local news = {}
			news.time = os.time()
			news.triger_name_len = triger_name_len
			news.triger_name = triger_name
			news.type = news_type
			news.content = news_content
			
			table.insert(guild_news, news)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取本公会新闻
function GetGuildNews(guild_id)
   	local guild = guilds[guild_id]
	if guild then
		return guild.news
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--四舍五入
local function Rounding(x)
    local y = x
    if x<=0 then
        return math.ceil(x)
    end
    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    if y - x >= 0.5 then
        return x + 1
    else
        return x
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--根据威望计算算公会经验
--威望是影响玩家给予公会经验的唯一属性(公会活跃度和经验通过威望转换)
function AddGuildExp(guild_id,player_id,exp)
	local guild = guilds[guild_id]
	if not guild then
		return
	end
    exp = Rounding(exp/10)
    --最低加1点公会经验
    if exp == 0 then 
        exp = 1
    end
	
    --自己贡献经验
	local member_info = GetGuildMemeberInfo(guild_id,player_id)
	if member_info then
		member_info.guild_offer = member_info.guild_offer + exp
		UpdateOtherField(C.ktGuildMemberInfo, player_id,{C.kfGuildOffer, member_info.guild_offer})
		AddGuildNews(guild_id,member_info.member_name,member_info.member_name_len,1,exp)
	end
    
	local guild_info = guild.guild_info
	if guild_info then
		guild_info.activity_exp = guild_info.activity_exp + exp 				--公会活跃度(目前实现 增加的活跃度=公会贡献)
		UpdateField2(C.ktGuild, C.kfGuildId, guild_id, 0,C.kInvalidID,{C.kfActivityExp, guild_info.activity_exp})
		--更新公会等级跟经验
        local max_level = #guild_exp_map 
        if guild_info.level >= max_level then
            return
        end
		local upgrade_exp = guild_exp_map[guild_info.level].exp  --cur_exp_map
		guild_info.exp = guild_info.exp + exp 								--公会经验
        if guild_info.exp >= upgrade_exp then
            while guild_info.exp > 0 do
                --升一级
                if guild_info.exp >= upgrade_exp then
                    guild_info.exp = guild_info.exp - upgrade_exp
                else
                    break    
                end    
                
                guild_info.level = guild_info.level + 1
                
                if guild_info.level < 20 then
                    upgrade_exp = guild_exp_map[guild_info.level].exp
                else
                    guild_info.exp = 0    
                end    
            end
            UpdateField2(C.ktGuild, C.kfGuildId, guild_id, 0, C.kInvalidID, {C.kfLevel, guild_info.level}, {C.kfExp, guild_info.exp})
      
            --如果有新会阶,添加相应权限
            local grade_level_max = GetGradeLevelMax(guild_id)
            local grade_level_count = 0
            for k,v in pairs(guild.grades_info) do
                grade_level_count = grade_level_count + 1
            end
         
            for i = grade_level_count,grade_level_max-1 do
                InsertNewGuildGradeInfo(guild_id,i,charset.guild_new_grade_name)
                InsertGuildGradeInfo(guild_id,i,charset.guild_new_grade_name,new("Authority",1,0,0,0,0,0))
            end
        else
            UpdateField2(C.ktGuild, C.kfGuildId, guild_id, 0, C.kInvalidID, {C.kfLevel, guild_info.level}, {C.kfExp, guild_info.exp})
        end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取成员会阶等级
function GetGuildMemeberGradeLevel(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_members_info = guild.members_info
		if guild_members_info then
			for _,guild_member_info in pairs(guild_members_info) do
				if guild_member_info.player_id == player_id then
					return guild_member_info.grade_level
				end
			end
		end
	end
	return 100	--(没取到，默认返回100-会员)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--更新成员会阶等级
function SetGuildMemberGradeLevel(guild_id,player_id,grade_level)
	local guild = guilds[guild_id]
	if guild then 
		local guild_members_info = guild.members_info
		local guild_grades_info = guild.grades_info
		if guild_members_info and guild_grades_info then
			local guild_grade_info = guild_grades_info[grade_level]
			if guild_grade_info then
				for _,guild_member_info in pairs(guild_members_info) do
					if guild_member_info.player_id == player_id then
						--更新会阶等级
						guild_member_info.grade_level = grade_level
						--更新会阶名
						ffi.fill(guild_member_info.grade_name, sizeof(guild_member_info.grade_name))
						guild_member_info.grade_name_len = guild_grade_info.grade_name_len
						ffi.copy(guild_member_info.grade_name, guild_grade_info.grade_name, guild_grade_info.grade_name_len)
						return
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取指定等级会阶信息
function GetGuildGradeInfo(guild_id,guild_grade_level)
	local guild = guilds[guild_id]
	if guild then 
		local guild_grades_info = guild.grades_info
		if guild_grades_info then
			return guild_grades_info[guild_grade_level]
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取所有会阶信息
function GetGuildGradesInfo(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		return guild.grades_info
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取成员对应会阶权限
function GetGuildGradeAuthority(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then
		local member_grade_level = GetGuildMemeberGradeLevel(guild_id,player_id)	
		local guild_grade_info = GetGuildGradeInfo(guild_id,member_grade_level)
		if guild_grade_info then
			return guild_grade_info.authority
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--公会发言
function CheckAuthorityTalkWith(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.talk_with == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--升降会员
function CheckAuthorityChangeGrade(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.change_grade == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--招收成员
function CheckAuthorityInviteMember(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.invite_member == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--开除成员
function CheckAuthorityKickoutMember(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.kickout_member == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--编辑公告
function CheckAuthorityEditCallBoard(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.edit_call_board == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--编辑会标
function CheckAuthorityEditIcon(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.edit_icon == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--战场报名
function CheckAuthoritysignGuildWar(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.sign_guild_war == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--分配仓库物品
function CheckAuthorityPrizeGuildGiving(guild_id,player_id)
	local authority = GetGuildGradeAuthority(guild_id,player_id)
	if authority then
		return authority.prize_guild_giving == 1
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--成员管理相关
--取单个公会成员信息
function GetGuildMemeberInfo(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_members_info = guild.members_info
		if guild_members_info then
			for _,guild_member_info in pairs(guild_members_info) do
				if guild_member_info.player_id == player_id then
					return guild_member_info
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取所有公会成员信息
function GetGuildMembersInfo(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		return guild.members_info
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取公会成员上限
function GetGuildMembersMaxCount(guild_id)
	return global.guild.kGuildBaseMember + AddMembersMaxCount(guild_id)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--移除公会成员
function RemoveGuildMember(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_members_info = guild.members_info
		if guild_members_info then
			for i,guild_member_info in pairs(guild_members_info) do
				if guild_member_info.player_id == player_id then
					return table.remove(guild_members_info,i)
				end
			end
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加一个新公会成员信息
function InsertGuildMemeberInfo(guild_id,player_id,grade_level,grade_name)
	local guild = guilds[guild_id]
	if guild then 
		local guild_members_info = guild.members_info
		if guild_members_info then
			--grade_level,grade_name需要直接传入,如果直接从数据库读取,因异步操作可能还未写入读取出错
			local guild_member_info = db.GetNewGuildMemeberInfo(player_id,grade_level,#grade_name,grade_name)
			table.insert(guild_members_info,guild_member_info)
            return guild_member_info
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--清除邀请超时成员
local function RemoveTimeOutInviteMembers(guild_invite_members)
	for i,invite_member in pairs(guild_invite_members) do
		if os.time() - invite_member.invite_time > global.guild.kGuildInviteOutTime then
			table.remove(guild_invite_members,i)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加到邀请成员列表
function AddInviteMember(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_invite_members = guild.invite_members
		if guild_invite_members then
			--移除超时邀请
			RemoveTimeOutInviteMembers(guild_invite_members)
			--添加到列表
			local invite_member={}
			invite_member.player_id=player_id
			invite_member.invite_time=os.time()
			table.insert(guild_invite_members,invite_member)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--验证邀请成员
function IsInInviteList(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_invite_members = guild.invite_members
		if guild_invite_members then
			RemoveTimeOutInviteMembers(guild_invite_members)
			for _,guild_invite_member in pairs(guild_invite_members) do
				if guild_invite_member.player_id == player_id then
					return true
				end
			end
		end
	end
	return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--邀请成员列表移除
function RemoveInviteMembers(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_invite_members = guild.invite_members
		if guild_invite_members then
			for i,invite_member in pairs(guild_invite_members) do
				if invite_member.player_id == player_id then
					table.remove(guild_invite_members,i)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--玩家异常掉线或者关闭窗口删除玩家所要的邀请
function RemoveAllInvite(player_id)
    for _,guild in pairs(guilds) do
        if guild then 
            local guild_invite_members = guild.invite_members
            if guild_invite_members then
                for i,invite_member in pairs(guild_invite_members) do
                    if invite_member.player_id == player_id then
                        table.remove(guild_invite_members,i)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--根据名字取邀请玩家信息
function GetInvitePlayerInfo(name)
	for _,player in pairs(online_players) do
		if player.GetName() == name then
			return player.GetUID(),player.GetGuildId()
		end
	end
	return nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--工会人数是否已满
function CanAddMember(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_members_info = guild.members_info
		if guild_members_info then
			local cur_members_count = #guild_members_info
			local max_members_count = GetGuildMembersMaxCount(guild_id)
			return cur_members_count < max_members_count
		end
	end
	return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--申请列表相关处理
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--清除申请超时成员
local function RemoveTimeOutApplyMembers(guild_apply_members)
	for i,apply_member in pairs(guild_apply_members) do
		if os.time() - apply_member.time > global.guild.kGuildInviteOutTime then
			table.remove(guild_apply_members,i)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--是否已经申请过本公会
function IsInApplyList(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_apply_members = guild.apply_members
		if guild_apply_members then
			--移除超时申请
			RemoveTimeOutApplyMembers(guild_apply_members)
			for _,apply_member in pairs(guild_apply_members) do
				if apply_member.player_id == player_id then
					return true
				end
			end
		end
	end
	return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加到申请列表
function AddGuildApplyMember(guild_id,player_id,player_level,player_name)
	local guild = guilds[guild_id]
	if guild then 
		local guild_apply_members = guild.apply_members
		if #guild_apply_members > 0 then
			RemoveTimeOutApplyMembers(guild_apply_members)
		end	
        local apply_member={}
        apply_member.guild_id = guild_id
        apply_member.player_id=player_id
        apply_member.player_level=player_level
        apply_member.time=os.time()
        apply_member.player_name=player_name
        table.insert(guild.apply_members,apply_member)
        db.InsertApplication(guild_id,player_id,player_level,player_name,apply_member.time)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--从申请列表移除(拒绝)
function  RemoveApplyMembers(guild_id,player_id) 
guild = guilds[guild_id]
    if guild then 
        local guild_apply_members = guild.apply_members
        db.DeleteApplication(guild_id,player_id) 
        if guild_apply_members then
            for i,apply_member in pairs(guild_apply_members) do
                if apply_member.player_id == player_id then
                    table.remove(guild_apply_members,i)
                end
            end
        end
    end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--从申请列表移除(同意)
function  RemoveAllApplyMembers(player_id) 
	db.DeleteApplication(0,player_id)
	for _,guild in pairs(guilds) do 
        if guild then 
            local guild_apply_members = guild.apply_members
            if guild_apply_members then
                for i,apply_member in pairs(guild_apply_members) do
                    if apply_member.player_id == player_id then
                        table.remove(guild_apply_members,i)
                    end
                end
            end 
        end 
    end   
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取申请成员总数
function GetGuildApplyMembersCount(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_apply_members = guild.apply_members
		if guild_apply_members then
			--移除超时申请
			RemoveTimeOutApplyMembers(guild_apply_members)
	
			return #guild_apply_members
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取申请成员列表
function GetGuildApplyMembers(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_apply_members = guild.apply_members
		if guild_apply_members then
			RemoveTimeOutApplyMembers(guild_apply_members)
			return guild_apply_members
		end
	end		
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取离线玩家公会ID
function GetOfflinePlayerGuildId(player_id)
	return db.GetOfflinePlayerGuildId(player_id)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--弹劾会长列表相关处理
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--是否已经弹劾过会长
function IsInDelateList(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_delate_members = guild.delate_members
		if guild_delate_members then
			for _,apply_member in pairs(guild_delate_members) do
				if apply_member.player_id == player_id then
					return true
				end
			end
		end
	end
	return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--添加到弹劾列表
function AddGuildDelateMember(guild_id,player_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_delate_members = guild.delate_members
		if guild_delate_members then
            for _,id in pairs(guild_delate_members) do
                if id == player_id then
                    return
                end
            end
			table.insert(guild_delate_members,player_id)
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--取弹劾成员总数
function GetGuildDelateMembersCount(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_delate_members = guild.delate_members
		if next(guild_delate_members) then
			return #guild_delate_members
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--弹劾成功或者会长主动转让后清除弹劾列表
function ResetDelateMemberList(guild_id)
	local guild = guilds[guild_id]
	if guild then
		local guild_delate_members = guild.delate_members
		if guild_delate_members then
			guild.delate_members = {}
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--公会技能加成
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--公会人数提升（根据公会等级取成员上限）
function AddMembersMaxCount(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local count = 0
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_guild_member then
						count = count + guild_skill.add_guild_member
					end
				end
			end
			return count
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--公会会阶增加
function AddGradeLevelMax(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local count = 0
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_guild_grade then
						count = count + guild_skill.add_guild_grade
					end
				end
			end
			return count
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--事务所中出现高级别任务几率提升
function AddHighLevelTaskPercent(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local percent = 0
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_high_level_task_per then
						percent = guild_skill.add_high_level_task_per
					end
				end
			end
			return percent
		end
	end
	return 0	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--符文熔炼时获得的符能增加
function AddRuneEnergyPercent(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local percent = 0
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_rune_energy_per then
						percent = guild_skill.add_rune_energy_per
					end
				end
			end
			return percent
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--宝石合成时暴击几率增加
function AddCompoundGemPercent(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local percent = 0
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_compound_gem_per then
						percent = guild_skill.add_compound_gem_per
					end
				end
			end
			return percent
		end
	end
	return 0
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--获得活力增加
function AddEnergy(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local add_energy_mobility_per
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_energy_mobility_per then
						add_energy_mobility_per = guild_skill.add_energy_mobility_per
					end
				end
			end
			if add_energy_mobility_per then
				return percent.energy
			end
		end
	end
	return 0	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--获得行动力增加
function AddMobility(guild_id)
	local guild = guilds[guild_id]
	if guild then 
		local guild_info = guild.guild_info
		if guild_info then
			local add_energy_mobility_per
			for _,guild_skill in pairs(guild_skills) do
				if guild_skill.active_level<=guild_info.level then
					if guild_skill.add_energy_mobility_per then
						add_energy_mobility_per = guild_skill.add_energy_mobility_per
					end
				end
			end
			if add_energy_mobility_per then
				return percent.mobility
			end
		end
	end
	return 0
end


----------------------------------------------------------
--公会天赋加成
----------------------------------------------------------

local function FindHeavensent2(id,level)
	for _,guild_heavensent2 in pairs(guild_heavensents2) do
		if guild_heavensent2.id==id and guild_heavensent2.level==level then
			return guild_heavensent2
		end
	end
end

local function GetHeavensentValue(key)
	local guild_info = guilds_info[guild_id]
	if guild_info then
		local heavensent = guild_info.heavensent
		for i=1,10 do													--遍历天赋加点
			local hs = heavensent[i]
			if hs.level~=0 then
				local heavensent = FindHeavensent2(hs.id,hs.level)		--寻找符合的条件
				if heavensent and heavensent[key] then
					return heavensent[key]
				end
			end
		end
	end
	return 0	
end

--主线银币加成
function AddMainLineSilverPercent(guild_id)
	return GetHeavensentValue("add_add_main_line_silver_per")
	--[[
	local guild_info = guilds_info[guild_id]
	if guild_info then
		local heavensent = guild_info.heavensent
		for i=1,10 do					
			local hs = heavensent[i]
			if hs.level~=0 then
				local heavensent = FindHeavensent2(hs.id,hs.level)
				if heavensent and heavensent.add_add_main_line_silver_per then
					return heavensent.add_add_main_line_silver_per
				end
			end
		end
	end
	return 0
	--]]
end

--支线银币加成
function AddSubLineSilverPercent(guild_id)
	return GetHeavensentValue("add_sub_main_line_silver_per")
end

--城建中收钱的冷却时间减少
function SubTownCDPercent(guild_id)
	return GetHeavensentValue("add_sub_town_cd_per")
end

--英雄打怪经验增加
function AddHeroExpPercent(guild_id)
	return GetHeavensentValue("add_hero_exp_per")
end

--领主经验增加（在次要升级体系中增加）
function AddPlayerExpPercent(guild_id)
	return GetHeavensentValue("add_player_exp_per")
end

--科技升级花费的金钱减少
function SubTechlologyCostPercent(guild_id)
	return GetHeavensentValue("sub_techlology_cost_per")
end

--锻造中花费的金钱减少
function SubStrengthenCostPercent(guild_id)
	return GetHeavensentValue("sub_strengthen_cost_per")
end

--英雄伤害提升（仅出现在工会战中） TODO --add
function AddHeroHurtPerPercent(guild_id)
	return GetHeavensentValue("add_player_exp_per")
end

--英雄防御提升（仅出现在工会战中） TODO  --add
function AddHeroDefensePerPercent(guild_id)
	return GetHeavensentValue("add_player_exp_per")
end

--功绩获得提升
function AddFeatPerPercent(guild_id)
	return GetHeavensentValue("add_feat_per")
end

--商店（部分商店）购买物品减少花费
function SubBuyItemCostPercent(guild_id)
	return GetHeavensentValue("sub_buy_item_cost")
end

--商店出售物品增加收入
function AddSellItemIncomePercent(guild_id)
	return GetHeavensentValue("add_sell_item_income")
end

