module('db', package.seeall)
local ffi = require("ffi")
local C = ffi.C
local cast= ffi.cast
local new = ffi.new
local sizeof = ffi.sizeof
local guild_skills = require('config.guild_skills')
local charset = require('config.charset')
local conn = nil

--ConstData
local kApplicationGuildTimeOut = 24*3600

function Initialize(connection)
	conn = connection
	conn:query("set names 'utf8'")
end

--取离线玩家信息
function ReadOfflinePlayerInfo(player)
	local res = conn:query('select * from base_info where player=' .. player)
	local row = res[1]

	if row then
		local nickname = ffi.string(row.nickname, sizeof(row.nickname))
		local base_info = new('PlayerBaseInfo')
		base_info.role = {player, {#nickname, nickname}, row.sex, 0}
		base_info.game_info = {player, row.gold, row.silver, row.feat, row.prestige, row.energy,row.mobility, row.exp, row.level, row.progress, row.country, row.array, row.vip, 0, row.guild_id}
		return base_info
	end
	assert(false,string.format("ReadOfflinePlayerInfo error id=%d", player))
end

--取战场归属地
function GuildWarFields(id)
local res = conn:query('select guild_id  from guild_war_fields where id =' .. id)
return res[1].guild_id
end

--获取报名列表
function ReadGuildMapSignList(war_field_id)
	local info = {}
	local res = conn:query('select guild_id from guild_map_sign_list where war_field_id = '..war_field_id)
    for k,row in ipairs(res) do
        info[k] = row.guild_id
    end
	return info
end

--插入报名列表
function InsertGuildMapSignList(guild_id,war_field_id)
conn:query('INSERT INTO guild_map_sign_list(guild_id, war_field_id) VALUES(' .. guild_id .. ', ' ..war_field_id..')' )
end

function UpdateDeltaField(guild_count,guild_id,box_type)
conn:query('update guild_giving set guild_count = guild_count+'..guild_count..' where guild_id = '..guild_id..' and box_type = '..box_type)
end
--取离线英雄信息(等级、位置、培养属性)
function ReadOfflineHeroInfo(player, hero_id)
	local res = conn:query('select level,location,bringup_bin from hero where player='..player..' and id='..hero_id)
	local row = res[1]
	if row then
		local row_bringup_bin = ffi.cast('const BringupBin&', row.bringup_bin)
		local row_bringup={}
		row_bringup.strength = row_bringup_bin.strength
		row_bringup.agility = row_bringup_bin.agility
		row_bringup.intelligence = row_bringup_bin.intelligence
		return {level=row.level,location=row.location, bringup=row_bringup}
	end
	assert(false,string.format("ReadOfflineHeroInfo error player=%d id=%d", player, hero_id))
end

local function Row2Equipment4Client(row)
		local equip = new("Equipment4Client")
		equip.level = row.level
		equip.base_strength = row.strength
		equip.base_agility = row.agility
		equip.base_intelligence = row.intelligence
		ffi.copy(equip.holes, row.holes, sizeof(equip.holes))
		ffi.copy(equip.gems, row.gems, sizeof(equip.gems))
		return equip
end

--取离线英雄装备信息( prop, equip )
function ReadOfflineHeroEquipment(player, hero_id)
	local res = conn:query('select prop.id, prop.kind, prop.location, prop.amount, equipment.level, equipment.strength, equipment.agility, equipment.intelligence,equipment.holes, equipment.gems from prop,equipment where prop.id=equipment.id and prop.player=equipment.player and prop.area=3 and prop.player=' .. player .. ' and equipment.hero=' .. hero_id)

	local equips = {  }
	for _,row in ipairs(res) do
		local prop = new("Prop4Client")
		prop.id = row.id
		prop.kind = row.kind
		prop.location = row.location
		prop.amount = row.amount

		local equip = Row2Equipment4Client(row)

		equips[row.location] = { prop, equip }
	end
	return equips
end

function ReadPlayerEquipment(player, prop_id)
	local res = conn:query('select * from equipment where player='..player..' and id='..prop_id)
	if res and res[1] then
		local row = res[1]
		return Row2Equipment4Client(row)
	end
end


--初始化公会信息
--所有公会信息都在guilds里面
--local guild = guilds[guild_id]	--通过公会ID索引
--guild.guild_info 					--公会信息(公会名,公会等级 ...)
--guild.members_info				--公会成员信息
--guild.grades_info					--公会会阶信息
--guild.giving						--公会战场的战利品信息
--apply_members                     --申请玩家列表
function GetGuildsInfo(guilds)
	local last_guild_id=0
	local res = conn:query_m('call GetGuildsInfo()')
	for _,row in pairs(res[1]) do
		local leader_name = ffi.string(row.nickname, sizeof(row.nickname))
		local guild_name = ffi.string(row.name, sizeof(row.name))
		local call_board = ffi.string(row.call_board, sizeof(row.call_board))
		local call_board_len = #call_board
		local guild_info = {}
	    guild_info=new("GuildInfo",row.guild_id, row.level, row.leader, #leader_name, leader_name, row.icon, row.icon_frame, row.exp, row.activity_exp, 0, 0, #guild_name, guild_name)
		ffi.copy(guild_info.heavensent, row.heavensent, sizeof(row.heavensent))
		guild_info.call_board_len0 = call_board_len
		guild_info.call_board_len = call_board_len
		ffi.copy(guild_info.call_board, call_board, call_board_len)
  
		guilds[row.guild_id] = {}							--初始化一个公会
		guilds[row.guild_id].guild_info = guild_info		--关联公会信息
        last_guild_id=row.guild_id
	end
    
    --删除超时玩家申请
	conn:query('delete from guild_application where time <'..(os.time()-kApplicationGuildTimeOut) )
        
	for guild_id,_ in pairs(guilds) do
		local res = conn:query_m('call GetGuildMembersInfo(' .. guild_id .. ')')
		local guild_members_info={}
        
        --公会成员数据
		for _,row in pairs(res[1]) do
			local member_name = ffi.string(row.nickname, sizeof(row.nickname))
			local grade_name = ffi.string(row.grade_name, sizeof(row.grade_name))
			local guild_member_info
			if row.last_logout_time ~= nil then
			    guild_member_info = new("GuildMemberInfo",row.player, row.level, row.sex, row.guild_offer, row.guild_grade_level, 0, #grade_name, grade_name, row.last_logout_time, #member_name, member_name,0,0)
			    table.insert(guild_members_info,guild_member_info)
			else
                guild_member_info = new("GuildMemberInfo",row.player, row.level, row.sex, row.guild_offer, row.guild_grade_level, 0, #grade_name, grade_name, 0, #member_name, member_name,0,0)
			    table.insert(guild_members_info,guild_member_info)
			end
		end
		guilds[guild_id].members_info = guild_members_info
        
		--公会会阶信息
		res = conn:query('SELECT guild_grade_level,grade_name,grade_authority FROM guild_authority WHERE guild_id = ' .. guild_id .. ' ORDER BY guild_grade_level')
		local guild_grades_info={}
		for _,row in pairs(res) do
			local grade_name = ffi.string(row.grade_name, sizeof(row.grade_name))
			local guild_grade_info = new("GuildGradeInfo",row.guild_grade_level, #grade_name, grade_name)
			ffi.copy(guild_grade_info.authority, row.grade_authority, sizeof(row.grade_authority))
			guild_grades_info[row.guild_grade_level]=guild_grade_info
		end
        guilds[guild_id].grades_info = guild_grades_info
        
        --获取公会的申请列表
		res = conn:query('SELECT player_id,time,player_name ,player_level from guild_application where guild_id = '..guild_id)
		local apply_members = {}
		local apply_member = {}
		for _,row in pairs(res) do
		    apply_member.player_id = row.player_id
		    apply_member.time = row.time
		    apply_member.player_level = row.player_level
			apply_member.player_name= ffi.string(row.player_name, sizeof(row.player_name))
			table.insert(apply_members,apply_member)
		end
	    guilds[guild_id].apply_members = apply_members

        --公会箱子
       local buff_giving = {}
        local res = conn:query('select box_type, guild_count,guild_war_id from guild_giving where guild_id = '..guild_id)
        if #res ~= 0 then
            for j,value in pairs(res) do
                table.insert(buff_giving,value)
            end
        end
        guilds[guild_id].giving = buff_giving

		--如果直接修改公会等级,初始化时添加对应会阶
		local count = 0
		for _,guild_skill in pairs(guild_skills) do
			if guild_skill.active_level<=guilds[guild_id].guild_info.level then
				if guild_skill.add_guild_grade then
					count = count + guild_skill.add_guild_grade
				end
			end
		end
		local grade_level_max = count + 3
		local grade_level_count = 0
		for k,v in pairs(guild_grades_info) do
			grade_level_count = grade_level_count + 1
		end
		while grade_level_count < grade_level_max do
			InsertNewGuildGradeInfo(guild_id,grade_level_count,charset.guild_new_grade_name)
			local guild_grade_info = new("GuildGradeInfo",grade_level_count, #charset.guild_new_grade_name, charset.guild_new_grade_name)
			guild_grade_info.authority.talk_with = 1
			guild_grades_info[grade_level_count]=guild_grade_info
			grade_level_count = grade_level_count + 1
		end
        guilds[guild_id].grades_info = guild_grades_info	
	end
	return last_guild_id
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-----删除公会战报名列表
function DeleteSighList()
    conn:query('delete from guild_map_sign_list')
end

----删除战败公会的数据
function DeleteGuild(war_field_id)
conn:query('delete from guild_war_member_info where  war_field_id = '..war_field_id)
end
-----查询战场被哪些公会所占领
function SelectWarFields(war_field_id)
	local res = conn:query('select guild_id from guild_war_fields where id = '..war_field_id)
	if res[1].guild_id == 0 or res[1].guild_id == nil then
		return 0
	else
		return res[1].guild_id
	end
end

--
function InsertApplication(guild_id,player_id,player_level,player_name,time)
conn:query('insert into guild_application(guild_id,player_id,player_level,time,player_name) values('..guild_id..','..player_id..','..player_level..','..time..',\''..player_name..'\')')
end

function DeleteApplication(guild_id ,player_id)
    if guild_id ~= 0 then
        conn:query('delete from guild_application where player_id = '..player_id..' and guild_id = '..guild_id)
    else
        conn:query('delete from guild_application where player_id = '..player_id)
    end
end
----查询更新下来的会标
function GetGulildIcons(guild_id)
 local res = conn:query('select icon_bin from  guild_icon where guild_id = '..guild_id)
     if res[1] ~= nil then
        return res[1].icon_bin
    else
        return 0
    end
end

function UpdateGuildIcons(guild_id,icon)
  conn:query('update guild set icon = '..icon..' where guild_id = '..guild_id)
end
-----查询工会战的公会每天自动领取的宝箱
function SelectBoxNumber(guild_id,box_type)
	local res = conn:query('select guild_count from guild_giving where guild_id = '..guild_id..' and box_type = '..box_type)
	if res == 0 then
		return 0
	else
		return res[1]
	end
end

--更新所有的玩家的购买次数置0
function UpdateBuyTrainNum()
    conn:query('update train set buy_num = 0')
end
function GetGuildGiving(guild_war_id,guild_id,box_type)
     local res = conn:query('select guild_count from  guild_giving where guild_id = '..guild_id..' and box_type ='..box_type)
    for _,row in ipairs(res) do
        return row.guild_count
    end
end

--[[
--获取进攻防守方公会
function SelectBatterGuildId(war_field_id)
     local res = conn:query('select guild_id,battle_type from guild_war_buff where war_field_id = '..war_field_id)
     local battle_guild = {}
    for _,row in ipairs(res) do
            table.insert(battle_guild,row)
    end
    return battle_guild
end
--]]

--获取英雄购买训练次数和训练
function getTrainNum(playerId) --玩家id 英雄id
    local row = conn:query('select train_num,buy_num,add_count_time,buy_last_train_time from train where player = '..playerId)
    if row[1] == nil then
	    return 0,0,0,0
    end
    return row[1].train_num,row[1].buy_num,row[1].add_count_time,row[1].buy_last_train_time
    end

--初始化战场信息
function GetGuildWarFieldInfoFromDB(war_field_id)
	--从数据库查询当前战场的 占领公会、科技、陷阱等信息
	local res = conn:query('SELECT guild_id,technology_level,technology_exp FROM guild_war_fields WHERE id = ' .. war_field_id)
	local row=res[1]
	if row then
		--查询成功
		local war_field_info = {}
		war_field_info.guild_id = row.guild_id
		war_field_info.technology_level = row.technology_level
		war_field_info.technology_exp = row.technology_exp
		return war_field_info
	else
		--没有查到,添加一条纪录(服务器启动时,采用同步INSERT)
		conn:query( 'INSERT INTO guild_war_fields(id, guild_id, technology_level) VALUES(' .. war_field_id .. ', ' .. ' 0, 1)' )
		local war_field_info = {}
		war_field_info.guild_id = 0
		war_field_info.technology_level = 1
		war_field_info.technology_exp = 0
		return war_field_info
	end
end

--初始化战场占领公会成员信息
function GetGuildWarFieldMemberInfoFromDB(war_field_id)
	local res = conn:query('select player,war_field_offer,is_get_member_box from guild_war_member_info where war_field_id = '..war_field_id)
	local row=res[1]

	local members_info={}
	for _,row in pairs(res) do
		local member_info = {}
		member_info.player_id = row.player
		member_info.war_field_offer = row.war_field_offer
		member_info.is_get_member_box = row.is_get_member_box
		table.insert(members_info, member_info)
	end
	return members_info
end

--公会新增加一个成员,读取成员详细信息
function GetNewGuildMemeberInfo(player_id,grade_level,grade_name_len,grade_name)
	local res = conn:query( 'SELECT base_info.nickname,base_info.sex,base_info.level,status.last_logout_time FROM base_info,status WHERE base_info.player=status.player and base_info.player=' .. player_id )
	local row = res[1]
	if row.last_logout_time == nil then
	    row.last_logout_time = 0
	end
	if row then
		local member_name = ffi.string(row.nickname, sizeof(row.nickname))
		local guild_member_info = new("GuildMemberInfo",player_id, row.level, row.sex, 0, grade_level, 0, grade_name_len, grade_name, row.last_logout_time, #member_name, member_name, 0, 0)
		return guild_member_info
	end
end

--取离线玩家的公会ID
function GetOfflinePlayerGuildId(player_id)
	local res = conn:query('SELECT guild_id FROM base_info WHERE player=' .. player_id)
	local row = res[1]
	if row then
		return row.guild_id
	end
end
--更新公会宝箱数量
function UpdateGuildGiving(guild_war_id,guild_id,guild_count,box_type)
    conn:query('update guild_giving set guild_count = '..guild_count..' where guild_war_id ='..guild_war_id..' and guild_id='..guild_id..' and box_type='..box_type)
end

--重置每日领取领地成员宝箱标志(每天0:00 触发一次,采用同步UPDATE)
function ResetGetMemberBox()
	conn:query('UPDATE guild_war_member_info set is_get_member_box=0')
end

--更新每日公会宝箱奖励(每天0:00 触发一次,采用同步REPLACE,后期可以改成异步)
function ReplaceGuildBox(guild_id,item_id,item_count)
	conn:query('REPLACE INTO guild_giving(guild_id,item_id,item_count) VALUES('..guild_id..','..item_id..','..item_count..')')
end

--[[
SELECT prop.id, prop.kind, equipment.level, equipment.gems
FROM prop, equipment
WHERE prop.id = equipment.id
AND prop.area =3
AND prop.player =2
AND equipment.player =2
AND equipment.hero =2]]


function ResetFishingInfo( times )
	conn:query('update fish set gold_times=0, torpedo_times=0, fish_times=' .. times)
end

function GetRaceDragonLastSeason()
	local res = conn:query('select ifnull(_season, 0) as r_season from (select max( season ) as _season from playground_race_history) as dt')
	if #res~=0 then
		local season = res[1]
		return season.r_season
	end
	return nil
end

function GetDragon( id )
	local res = conn:query('select * from playground_dragon where dragon=' .. id)
	if #res~=0 then
		local row = res[1]
		return row
	end
	return nil
end

function RaceDragonSignup( player_id, dragon_id )
	conn:query_m('call RaceDragonSignup(' .. player_id .. ',' .. dragon_id .. ')')
end

function IsHasSignupDragon()
	local res = conn:query('select dragon from playground_race_signup limit 1')
	if #res~=0 then
		return true
	end
	return false
end

function GetSignupDragon()
	local res = conn:query('select `order`,dragon,player,strength,agility,intellect,his_rank from playground_race_signup')
	if #res~=0 then
		return res
	end
	return nil
end

function GetToptenDragon()
	local res = conn:query('select `order`,b.dragon,a.player,d_state,a.kind,b.strength,b.agility,b.intellect,raceway,a.his_rank,a.ch_name,d_name,nickname as p_name \
from playground_dragon as a ,playground_race_signup as b,base_info as c where a.dragon=b.dragon and b.raceway!=0 and b.player=c.player limit 10')
	if #res~=0 then
		return res
	end
	return nil
end

function SaveRaceDragonMassRank( dragon_id, rank, his_rank )
	if his_rank==0 or rank<his_rank then
		UpdateField2( C.ktPlaygroundDragon, C.kfPlayGroundDragon, dragon_id, 0, C.kInvalidID,{C.kfPlaygroundHisRank,rank})
	end
	UpdateField2(C.ktPlaygroundSignup,C.kfPlayGroundDragon, dragon_id,0,C.kInvalidID,{C.kfPlaygroundRank,rank})
	--conn:query_m('call SaveRaceDragonMassSelectRank(' .. dragon_id .. ',' .. rank .. ',' .. his_rank .. ')')
end

function SaveRaceDragonToptenRank( season, info )
	if info.d_name==nil then
		info.d_name = ""
	end
	conn:query_m('call SaveRaceDragonToptenRank(' .. season .. ',' .. info.dragon .. ',' .. info.player .. ',' .. info.rank .. ',' .. info.his_rank .. ',' .. info.raceway .. ','
					.. info.live1 .. ',' .. info.live2 .. ',' .. info.speed .. ',' .. info.kind .. ',' .. info.ch_name .. ',"' .. info.d_name .. '")')
end

function IsHasToptenRank( season )
	local res = conn:query('select season from playground_race_history where season='.. season .. ' limit 1')
	if #res~=0 then
		return true
	end
	return false
end

function GetRaceDragonToptenRank( season )
	local res = conn:query('select season,rank,dragon,raceway,live1,live2,speed,kind,ch_name,d_name,nickname as p_name from playground_race_history as a, base_info as b where season='
							.. season .. ' and a.player=b.player order by rank')
	if #res~=0 then
		return res
	end
	return nil
end

function SaveRaceDragonToptenInfo( dragon_id, d_state, raceway )
	UpdateField2(C.ktPlaygroundSignup,C.kfPlayGroundDragon, dragon_id,0,C.kInvalidID,{C.kfPlaygroundDState,d_state},{C.kfPlaygroundRaceway,raceway})
	--conn:query('update playground_race_signup set d_state=' .. d_state .. ',raceway=' .. raceway .. ' where dragon=' .. dragon_id )
end

function GetRaceDragonGuessInfo()
	local res = conn:query_m('call GetRaceDragonGuessInfo()')
	if #res~=0 then
		local row = res[1][1]
		return row
	end
	return nil
end

function GetRaceDragonGuessInfoFinal( )
	local res = conn:query('select player,guess,money from playground_race_guess')
	if #res~=0 then
		return res
	end
	return nil
end

function GetRaceDragonSignupInfoFinal( nums )
	local res
	if nums==-1 then
		res = conn:query('select a.player,a.level from base_info as a,playground_race_signup as b where a.player=b.player order by b.rank')
	else
		res = conn:query('select a.player,a.level from base_info as a,playground_race_signup as b where a.player=b.player order by b.rank limit ' .. nums)
	end
	if #res~=0 then
		return res
	end
	return nil
end

function DelRaceDragonInfo()
	conn:query('delete from playground_race_signup')
	conn:query('delete from playground_race_guess')
	--conn:query('update playground_race_signup set rank=0 where rank<11')
end

function ResetRaceDragonSignupState()
	conn:query('update playground_dragon set signup=0')
end

function RearDragonChangeName( dragon_id, d_name )
	local tmp_name = conn:escape( d_name )
	conn:query_m('call RearDragonChangeName(' .. dragon_id .. ',"' .. tmp_name .. '")' )
end

function AddDragon( new_dragon )
	local res = conn:query_m('call AddDragon(' .. new_dragon.player    .. ','
										  .. new_dragon.kind      .. ','
										  .. new_dragon.sex       .. ','
										  .. new_dragon.strength  .. ','
										  .. new_dragon.agility	  .. ','
										  .. new_dragon.intellect .. ','
										  .. new_dragon.max_str   .. ','
										  .. new_dragon.max_agi   .. ','
										  .. new_dragon.max_int   .. ')')
	if #res~=0 then
		return res[1][1].dragon
	end
	return nil
end

function ResetTurntableInfo( times )
	conn:query('update turntable set re_times=0,times=' .. times)
end

function ModifyPlaygroundProp( uid, kind, amount, buy_count )
	conn:query_m('call ModifyPlaygroundProp(' .. uid .. ',' .. kind .. ',' .. amount .. ',' .. buy_count .. ')')
end

function ResetPlaygroundPropBuyCount()
	conn:query('update playground_props set buy_count=0')
end

function ResetAssistant()
	conn:query('update assistant set activity=0,draw=0')
	conn:query('update assistant_task set times_back=times')
	conn:query('update assistant_task set times=0,b_retrieve=1,remain_times=99')
end

--function UpdateAssistantActivity( uid, activity, draw )
	--conn:query('update assistant set activity=' .. activity .. ',`draw`=' .. draw .. ' where player=' .. uid)
--end

function ModifyAssistantTask( uid, task_id, times, b_retrieve, times_back, remain_times )
	conn:query_m('call ModifyAssistantTask('..uid..','..task_id..','..times..','..b_retrieve..','..times_back..','..remain_times..')')
end

function GetAssistantActivity( uid )
	local res = conn:query('select * from assistant where player='..uid)
	if #res~=0 then
		return res[1]
	end
	return nil
end

function GetAssistantTask( uid, task_id )
	local res = conn:query('select * from assistant_task where player='..uid..' and task_id='..task_id)
	if #res~=0 then
		return res[1]
	end
	return nil
end

function ResetStamina( grade_level, stamina )
	conn:query('update status set stamina='..stamina.. ' where player in (select player from grade where level='..grade_level..')')
end

function ReplenishStamina(stamina_take_max, time)
	conn:query('update status set stamina=stamina-1,stamina_take=stamina_take+1 where army_area=0 and back_time<='..time..' and stamina>0 and stamina_take<'..stamina_take_max)
end

function GetTreeWater( uid )
	local res = conn:query('select * from tree_water where player='..uid)
	if #res~=0 then
		return res[1]
	end
	return nil
end

function GetTreeSeeds( uid )
	local res = conn:query('select * from tree_seed where player='..uid)
	if #res~=0 then
		return res
	end
	return nil
end

function GetTreeLogs( uid )
	local res = conn:query('select bi.nickname,log.`time`,log.`id` from tree_log as log inner join base_info as bi on bi.player=log.uid where log.player='..uid..' order by log.`time` asc')
	if #res~=0 then
		return res
	end
	return nil
end

function GetPlayerBaseInfo(uid)
	local res = conn:query('select * from base_info where player='..uid)
	if #res~=0 then
		return res[1]
	end
	return nil
end

function ResetTree( water )
	conn:query('update tree_water set buy_count=0,water_amount='..water)
	conn:query('update tree_seed set watered=0')
end

function GetProp(uid, id)
	local res = conn:query('select uuid,kind,amount from prop where player='..uid..' and id='..id)
	if #res~=0 then
		return res[1]
	end
	return nil
end

function GetMailAttachment( uid, mail_id )
	local res = nil
	res = conn:query_m('call GetMailAttachments('..uid..','..os.time()..','..mail_id..')')
	if #res~=0 then
		return res[1][1].attach
	end
	return nil
end

function Binary2HexString( in_data, in_len )
	--
	local out_data = '0x'
	local l_data = cast("const unsigned char*",in_data)
	for i=1,in_len,1 do
		out_data = out_data .. string.format("%.2x",l_data[i-1])
	end
	return out_data
end

function UpdateMailAttachments( uid, mail_id, b_has_attach, attachs )
	local tmp_attachs, in_len
	if b_has_attach==1 then
		in_len = 4 + 16*attachs.amount
		tmp_attachs = Binary2HexString( attachs, in_len )
		if not tmp_attachs then
			return false
		end
		conn:query('update mail set attach='..tmp_attachs..
					' where player='..uid..' and mail_id='..mail_id)
	else
		conn:query('update mail set has_attach=0 where player='..uid..' and mail_id='..mail_id)
	end
	return true
end


function SendMail( recv_id, cur_time, subject, content, attachment, b_notify )
	--附件格式参见internal.h里的MailAttachments
	--b_notify: true.会通知玩家有新邮件,你需要判断玩家是否在线,   false or nil.不通知
	local has_attach
	local tmp_attach
	local in_len
	if not attachment or attachment.amount==0 then
		has_attach = 0
		tmp_attach = 0
	else
		if attachment.amount>8 then
			return false
		else
			in_len = 4 + 16*attachment.amount
		end
		has_attach = 1
		tmp_attach = Binary2HexString( attachment, in_len )
		if not tmp_attach then
			return false
		end
	end
	local tmp_subject = conn:escape( subject )
	local tmp_content = conn:escape( content )
	local res = conn:query_m('call SendMail(' .. recv_id .. ',0,'.. cur_time .. ',1,' .. has_attach .. ',\"system\",\"' .. tmp_subject .. '\",\"' .. tmp_content .. '\",' .. tmp_attach .. ')')
	if #res~=0 then
		local result
		if res[1][1].result==1 then
			result = C.eSucceeded
		else
			result = C.eMailsOverFlowWithAttach
		end
		if b_notify then
			local head = new("MqHead", recv_id, C.kNotifyOfNewMail, -1)
			local notify = new("NotifyOfNewMail",result)
			C.Send2Interact(head, notify, sizeof(notify))
		end
		if result==C.eSucceeded then
			return true
		else
			return false
		end
	end
	return false
end

function ModifySilverByUID(uid,type)
    local level_result = conn:query('select level from  function_building where player = '..uid..' and kind = '..type)
    local bank_level = level_result[1].level
    
    local silver_result = conn:query('select silver from base_info where player = '..uid)
    local silver = silver_result[1].silver
    return bank_level,silver
end

--解散工会后的数据库删除
function DisbandGuild(guild_id)
    conn:query_m('delete from guild_application where guild_id = '..guild_id)
    conn:query_m('delete from guild_icon where guild_id = '..guild_id)
    conn:query_m('delete from guild_member_info where guild_id = '..guild_id)
end

--删除公会
function DeleteGuildWarMemberInfo(player_id,guild_id)
    conn:query_m('delete from guild_war_member_info where player ='..player_id..' and guild_id = '..guild_id)
end
