local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
require('tools.error_handle')
require('config.town_cfg')
require('db')
--操作时间戳类型
require('data')
require('tools.time')

local global = require('config.global')
local item_cfgs, upgrade_cfgs, merge_cfgs = GetTownCfg()

local function enum(...)
	local enum_t = {}
	for k,v in pairs(...) do enum_t[v] = k end
	return enum_t
end
action_type = enum{"kEverydayReset", "award_arena", "guild_war"}

function CreateWaitableTimerForResetAction(type, strtime, callback)
	local obj = {}
	local timer = nil
	
	function obj.timer()
		C.StopTimer(timer)
		data.SetActionStamp(type, time.ConvertString2time(strtime))
		callback()
		obj.start()
	end
	
	function obj.start()
		local last_time = data.GetActionStamp(type)
		
		if os.time()-last_time>24*3600 then
			data.SetActionStamp(type, time.ConvertString2time(strtime))
			callback()
		end
		--准备下次开始
		local next_time = time.time_to_time(strtime)
		
		if not timer then
			timer = ffi.CreateTimer(obj.timer, next_time)
		else
			C.ResetTimer(timer, next_time)
		end
	end
	
	return obj.start()
end

--创建整点Timer
function CreatePunctualTimer(callback)
	local obj = {}
	local timer = nil
	
	local function GetNextPunctualTime()
		return math.ceil( (os.time() + 1) / 3600 ) * 3600
	end
	function obj.timer()
		C.StopTimer(timer)
		callback()
		obj.start()
	end
	
	function obj.start()
		local next_time = GetNextPunctualTime() - os.time()
		
		if not timer then
			timer = ffi.CreateTimer(obj.timer, next_time)
		else
			C.ResetTimer(timer, next_time)
		end
	end
	
	return obj.start()
end

--创建半个小时的Timer
function CreateHalfTimer(callback)
	local obj = {}
	local timer = nil
	
	local function GetNextHalfTime()
		return math.ceil( (os.time() + 1) / 1800 ) * 1800
	end
	function obj.timer()
		C.StopTimer(timer)
		callback()
		obj.start()
	end
	
	function obj.start()
		local next_time = GetNextHalfTime() - os.time()
		
		if not timer then
			timer = ffi.CreateTimer(obj.timer, next_time)
		else
			C.ResetTimer(timer, next_time)
		end
	end
	
	return obj.start()
end

--全局发送消息
local global_flag_head_ = new('MqHead', 0, 0, -1)
function GlobalSend2Gate(player,msg,len)
    global_flag_head_.aid = player
    global_flag_head_.type = msg.kType
    C.Send2Gate(global_flag_head_, msg, len or sizeof(msg))
end
function GlobalSend2Db(msg, len, uid)
    global_flag_head_.aid = uid or C.kInvalidID
    global_flag_head_.type = msg.kType
    C.Send2Db(global_flag_head_, msg, len or sizeof(msg))
end

function InsertRow2(tbl, ...)
	local fields = {...}
	local insert_row2 = new('InsertRow2', tbl, table.getn(fields), fields)
	GlobalSend2Db( insert_row2 )
end
	
function UpdateField2(tbl, index_filed, id, sub_index_filed, subid, ...)
    local fields = {...}
    local update_field2_ = new('UpdateField2', id, subid, tbl, index_filed, sub_index_filed, table.getn(fields), fields)
    GlobalSend2Db(update_field2_)
end
    
function UpdateOtherField(tbl, id, ...)
    local fields = {...}
    local update_field2_ = new('UpdateField2', id, C.kInvalidID, tbl, C.kfPlayer, 0, table.getn(fields), fields)
    GlobalSend2Db(update_field2_)
end

function UpdateField(tbl, id, ...)
    local fields = {...}
    local update_field_ = new('UpdateField', id, tbl, table.getn(fields), fields)
    GlobalSend2Db(update_field_)
end
    
function UpdateFieldWithSubIndex(uid, tbl, index_filed, index, sub_index_filed, sub_index, ...)
	local fields = {...}
	local update_field_with_subindex_ = new('UpdateFieldWithSubIndex', index, sub_index, tbl, index_filed, sub_index_filed, table.getn(fields), fields)
	local head = new('MqHead', uid, update_field_with_subindex_.kType, -1)
	C.Send2Db(head, update_field_with_subindex_, sizeof(update_field_with_subindex_))
end

function UpdateDeltaFieldWithSubIndex(uid, tbl, index_filed, index, sub_index_filed, sub_index, feild, delta)
	if delta==0 then return end
	local update = new('UpdateDeltaFieldWithSubIndex', index, sub_index, tbl, index_filed, sub_index_filed, feild, delta)
	local head = new('MqHead', uid, update.kType)
	C.Send2Db(head, update, sizeof(update))
end
	
function GlobalInsertRow(tbl, ...)
    local fields = {...}
    GlobalSend2Db( new('InsertRow2', tbl, table.getn(fields), fields) )
end

function GlobalDeleteRow(table, uid, id )
	local delete_row_ = new('DeleteRow', table, id)
	GlobalSend2Db(delete_row_, sizeof(delete_row_), uid)
end

function UpdateDeltaField(tbl, index_name, index, field, val, uid)
    local update_delta_field_ = new('UpdateDeltaField', index, tbl, index_name, field, val)
    GlobalSend2Db(update_delta_field_, sizeof(update_delta_field_), uid)
end


function AddGoldByUID(uid, delta)
	assert(delta>0)
	--在线玩家
	local p = data.GetOnlinePlayer(uid)
	if p then
		return p.AddGold(delta)
	end
	
    UpdateDeltaField(C.ktBaseInfo, C.kfPlayer, uid, C.kfGold, delta)
end

function ModifySilverByUID(uid, delta)
	--在线玩家
	local p = data.GetOnlinePlayer(uid)
	if p then
		return p.ModifySilver(delta)
	end
	
	--限制玩家银币多少
    if delta > 0 then
        local bank_level,player_own_silver =  db.ModifySilverByUID(uid,global.town.kBankKind)
        local top_silver = upgrade_cfgs[global.town.kBankKind][bank_level].silver_upper_limit   
    
        if top_silver <= player_own_silver then
            delta = 0
        elseif top_silver <= (player_own_silver + delta) then
            delta = top_silver - player_own_silver
        end
    end
	
	if delta~=0 then
		UpdateDeltaField(C.ktBaseInfo, C.kfPlayer, uid, C.kfSilver, delta)
	end
end

function ModifyPrestigeByUID(uid, delta)
	--在线玩家
	local p = data.GetOnlinePlayer(uid)
	if p then
		return p.ModifyPrestige(delta)
	end
	
    --工会经验
    local base_info = data.GetPlayerBaseInfo(uid)
    local game_info = base_info.game_info
    if game_info.guild_id~=0 then    --有公会
        guild.AddGuildExp(game_info.guild_id, uid, delta)
    end
    
    UpdateDeltaField(C.ktBaseInfo, C.kfPlayer, uid, C.kfPrestige, delta)
end

--function this.SqlQuery(sql)
--	Send2Db( new('SqlQuery', #sql, sql) )
--end
--建立工会
function InsertGuildInfo(guild_id, leader, guild_icon, guild_name, guild_grade1_name, guild_grade2_name, guild_grade100_name)
	GlobalSend2Db( new('InsertGuild', guild_id, leader, guild_icon, #guild_name, guild_name, #guild_grade1_name, guild_grade1_name, #guild_grade2_name, guild_grade2_name, #guild_grade100_name, guild_grade100_name) )
end

--解散工会
function DeleteGuildInfo(guild_id)
	GlobalSend2Db( new('DeleteGuild', guild_id) )
end

--插入新会阶
function InsertNewGuildGradeInfo(guild_id, new_grade_name_level, new_grade_name)
	GlobalSend2Db( new('InsertNewGuildGrade', guild_id, new_grade_name_level, #new_grade_name, new_grade_name) )
end

--离开公会
function LeaveGuild(player_id)
	GlobalSend2Db( new('MemberLeaveGuild', player_id) )
end

--加入公会
function JoinGuild(player_id, guild_id)
	GlobalSend2Db( new('MemberJoinGuild', player_id, guild_id) )
end    

--占领公会领地
function UpdateGuildWarFiles(id,guild_id,technology_level,technology_exp)
    GlobalSend2Db( new('GuildWarFiles',id,guild_id,technology_level,technology_exp) )
end
--
function DeleteGuildRow(table,guild_id,war_field_id)
    GlobalSend2Db( new('DeleteGuildRow',table,guild_id,war_field_id))
end

function UpdatePlayerAction(player, id, kind, max, value)
	local sql = string.format('call update_action(%d, %d, %d, %d, %d)', player, id, kind, max, value)
	GlobalSend2Db( new('ExcuteSqlDirectly', #sql, sql), 2 + #sql )
end