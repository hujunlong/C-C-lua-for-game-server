local props_ctf = require("config.props")
local base_ctf = require("config.rear_dragon_base")
local action_cft = require("define.action_id")
local tasks_cfg = require('config.assistant_task_id')

local gold_consume_flag = require('define.gold_consume_flag')

local g_ = require('config.global')

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy



function CreateRearDragon( player, playground )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local l_active = false

	----
	local player_id = player.GetUID()
	----

	local rear_rooms = 0	--能养育的龙的最大数量
	local cur_dragons = 0
	local dragons_info = {}



	db_processor_[C.kPlayGroundDragonInfoResult] = function(msg)
		local info = cast("const PlayGroundDragonInfoResult&",msg)

		local d_id = 0
		cur_dragons = info.len
		rear_rooms = info.rooms
		l_active = true
		for i=1,info.len,1 do
			d_id = info.dragon[i-1].dragon_id
			dragons_info[d_id] = {}
			dragons_info[d_id].dragon   = d_id
			dragons_info[d_id].his_rank = info.dragon[i-1].his_rank
			dragons_info[d_id].m_time   = info.dragon[i-1].m_time
			dragons_info[d_id].strength = info.dragon[i-1].strength
			dragons_info[d_id].agility  = info.dragon[i-1].agility
			dragons_info[d_id].intellect= info.dragon[i-1].intellect
			dragons_info[d_id].max_str  = info.dragon[i-1].max_str
			dragons_info[d_id].max_agi  = info.dragon[i-1].max_agi
			dragons_info[d_id].max_int  = info.dragon[i-1].max_int
			dragons_info[d_id].kind	    = info.dragon[i-1].kind
			dragons_info[d_id].sex      = info.dragon[i-1].sex
			dragons_info[d_id].signup   = info.dragon[i-1].signup
			dragons_info[d_id].ch_name  = info.dragon[i-1].ch_name
			if dragons_info[d_id].ch_name==1 then
				dragons_info[d_id].d_name   = ffi.string( info.dragon[i-1].d_name.str, info.dragon[i-1].d_name.len )
			end
		end
	end


	--取龙的列表
	processor_[C.kGetDragonList] = function(msg)
		local ret = new("GetDragonListResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret,4
		else
			ret.result = C.eSucceeded
		end

		local _index = 0
		ret.len = cur_dragons
		ret.rooms = rear_rooms
		for id, v in pairs( dragons_info ) do
			ret.dragon[_index].dragon_id = id
			ret.dragon[_index].his_rank  = v.his_rank
			ret.dragon[_index].m_time    = v.m_time
			ret.dragon[_index].strength  = v.strength
			ret.dragon[_index].agility   = v.agility
			ret.dragon[_index].intellect = v.intellect
			ret.dragon[_index].max_str   = v.max_str
			ret.dragon[_index].max_agi   = v.max_agi
			ret.dragon[_index].max_int   = v.max_int
			ret.dragon[_index].kind      = v.kind
			ret.dragon[_index].sex       = v.sex
			ret.dragon[_index].signup    = v.signup
			ret.dragon[_index].ch_name   = v.ch_name
			if v.ch_name==1 then
				ret.dragon[_index].d_name.len= #v.d_name
				copy(ret.dragon[_index].d_name.str, v.d_name, #v.d_name)
			end
			_index = _index + 1
		end
		local bytes = 8 + sizeof(ret.dragon[0])*_index
		--
		return ret,bytes
	end

	--改名
	processor_[C.kRearDragonChangeName] = function(msg)
		local req = cast("const RearDragonChangeName&",msg)
		local ret = new("RearDragonChangeNameResult",0)
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end

		local dragon = dragons_info[req.dragon_id]
		if dragon==nil then
			--没有此条龙
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		if req.d_name.len>sizeof(req.d_name.str) then
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		--改名
		local d_name = ffi.string( req.d_name.str, req.d_name.len )
		if d_name~=nil and #d_name>=1 then
			if dragon.ch_name==1 then
				--收费改名
				local bEnough = player.IsGoldEnough(g_.rear_dragon.kChangeNameCost)
				if bEnough==true then
					player.ConsumeGold(g_.rear_dragon.kChangeNameCost, gold_consume_flag.rear_dragon_change_name)
				else
					ret.result = C.REAR_DRAGON_NOT_ENOUGH
					return ret
				end
			end
			dragon.ch_name=1
			dragon.d_name = d_name
			db.RearDragonChangeName( req.dragon_id, d_name )
			--
			playground.SetDragonInfo( 100, req.dragon_id, d_name )
			--
			ret.result = C.REAR_DRAGON_SUCCEEDED
		else
			ret.result = C.REAR_DRAGON_INVALID
		end
		return ret
	end

	--培育下一代
	processor_[C.kRearDragonMate] = function(msg)
		local req = cast("const RearDragonMate&",msg)
		local ret = new("RearDragonMateResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret,4
		end

		if cur_dragons>rear_rooms then
			ret.result = C.REAR_DRAGON_ROOM_LIMIT
			return ret
		end

		local dragon1 = dragons_info[req.dragon_fid]
		local dragon2 = dragons_info[req.dragon_mid]
		if dragon1==nil or dragon2==nil then
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		if dragon1.sex==dragon2.sex then
			--搞基
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		local c_time = os.time()
		if dragon1.m_time>c_time or dragon2.m_time>c_time then
			--不到时候
			ret.result = C.REAR_DRAGON_NOT_TIME
			return ret
		else
			--扣掉催化剂
			local agent = props_ctf[req.agent_kind]
			if agent==nil or agent.type~=C.kPropPlaygroundAgent then
				ret.result = C.REAR_DRAGON_INVALID
				return ret
			else
				if player.IsPlaygroundPropEnough( req.agent_kind, 1 ) then
					player.ModifyPlaygroundProp( req.agent_kind, -1 )
				else
					ret.result = C.REAR_DRAGON_LACK_RSC
					return ret
				end
			end
			local n_time = c_time+g_.rear_dragon.kMateIntervalTime
			dragon1.m_time = n_time
			dragon2.m_time = n_time
			UpdateField2(C.ktPlaygroundDragon,C.kfPlayGroundDragon,dragon1.dragon,0,C.kInvalidID,{C.kfPlaygroundMTime,n_time})
			UpdateField2(C.ktPlaygroundDragon,C.kfPlayGroundDragon,dragon2.dragon,0,C.kInvalidID,{C.kfPlaygroundMTime,n_time})
		end

		

		local ds = {}
		ds.as = dragon1.strength + dragon2.strength
		ds.ag = dragon1.agility  + dragon2.agility
		ds.ai = dragon1.intellect+ dragon2.intellect
		ds.r1 = base_ctf[dragon1.kind].rarity
		ds.c1 = dragon1.kind
		ds.r2 = base_ctf[dragon2.kind].rarity
		ds.c2 = dragon2.kind
		ds.h1 = dragon1.his_rank
		ds.h2 = dragon2.his_rank
		ds.all_sai = ds.as + ds.ag + ds.ai
		--
		local probable = {}
		local _index = 1
		local probability = 0
		local satisfied = nil
		for i, v in ipairs( base_ctf ) do
			satisfied = true
			if v.all_sai~=nil then
				if ds.all_sai<v.all_sai[1] or ds.all_sai>v.all_sai[2] then
					satisfied = false
				end
			end

			if v.a_str~=nil then
				if ds.as<v.a_str[1] or ds.as>v.a_str[2] then
					satisfied = false
				end
			end
			if satisfied==true then
				if v.a_agi~=nil then
					if ds.ag<v.a_agi[1] or ds.ag>v.a_agi[2] then
						satisfied = false
					end
				end
			end
			if satisfied==true then
				if v.a_int~=nil then
					if ds.ai<v.a_int[1] or ds.ai>v.a_int[2] then
						satisfied = false
					end
				end
			end
			if satisfied==true then
				if v.f_rarity~=nil then
					satisfied = false
					for _, vv in ipairs( v.f_rarity ) do
						if ds.r1==vv then
							satisfied = true
							break
						end
					end
				end
			end
			if satisfied==true then
				if v.m_rarity~=nil then
					satisfied = false
					for _, vv in ipairs( v.m_rarity ) do
						if ds.r2==vv then
							satisfied = true
							break
						end
					end
				end
			end
			if satisfied==true then
				if v.f_kind~=nil then
					satisfied = false
					for _, vv in ipairs( v.f_kind ) do
						if ds.c1==vv then
							satisfied = true
							break
						end
					end
				end
			end
			if satisfied==true then
				if v.m_kind~=nil then
					satisfied = false
					for _, vv in ipairs( v.m_kind ) do
						if ds.c2==vv then
							satisfied = true
							break
						end
					end
				end
			end
			if satisfied==true then
				if v.f_his_rank~=nil then
					if ds.h1>v.f_his_rank or ds.h1==0 then
						satisfied = false
					end
				end
			end
			if satisfied==true then
				if v.m_his_rank~=nil then
					if ds.h2>v.m_his_rank or ds.h2==0 then
						satisfied = false
					end
				end
			end
			--
			if satisfied==true then
				probable[_index] = {}
				probability = probability + v.pro
				probable[_index].pro = v.pro
				probable[_index].kind = i
				_index = _index + 1
			end
		end

		local mate_kind = nil
		local t_amount = #probable
		if t_amount>0 then
			--
			for _, v in ipairs( probable) do
				v.pro = v.pro/probability
			end

			local tmp = math.random()
			for _, v in ipairs(probable) do
				if tmp<=v.pro then
					--中了
					mate_kind = v.kind
					break
				else
					tmp = tmp - v.pro
				end
			end
			if mate_kind~=nil then

				local new_dragon = {}
				new_dragon.kind   = mate_kind
				new_dragon.strength = math.random( base_ctf[mate_kind].ini_str[1], base_ctf[mate_kind].ini_str[2] )
				new_dragon.agility  = math.random( base_ctf[mate_kind].ini_agi[1], base_ctf[mate_kind].ini_agi[2] )
				new_dragon.intellect= math.random( base_ctf[mate_kind].ini_int[1], base_ctf[mate_kind].ini_int[2] )
				new_dragon.max_str  = math.random( base_ctf[mate_kind].max_str[1], base_ctf[mate_kind].max_str[2] )
				new_dragon.max_agi  = math.random( base_ctf[mate_kind].max_agi[1], base_ctf[mate_kind].max_agi[2] )
				new_dragon.max_int  = math.random( base_ctf[mate_kind].max_int[1], base_ctf[mate_kind].max_int[2] )
				new_dragon.sex      = math.random( 1,2 ) - 1
				new_dragon.player   = player_id
				--
				--成就
				player.RecordAction(action_cft.kRearDragonMateSpecial, new_dragon.kind, nil)
				player.RecordAction(action_cft.kRearDragonStrength, new_dragon.strength, nil)
				player.RecordAction(action_cft.kRearDragonAgility, new_dragon.agility, nil)
				player.RecordAction(action_cft.kRearDragonintelligence, new_dragon.intellect, nil)
				--
				new_dragon.dragon   = db.AddDragon( new_dragon )
				--
				cur_dragons = cur_dragons + 1
				local d_id = new_dragon.dragon
				dragons_info[d_id] = {}
				dragons_info[d_id].dragon   = d_id
				dragons_info[d_id].his_rank = 0
				dragons_info[d_id].m_time   = 0
				dragons_info[d_id].strength = new_dragon.strength
				dragons_info[d_id].agility  = new_dragon.agility
				dragons_info[d_id].intellect= new_dragon.intellect
				dragons_info[d_id].max_str  = new_dragon.max_str
				dragons_info[d_id].max_agi  = new_dragon.max_agi
				dragons_info[d_id].max_int  = new_dragon.max_int
				dragons_info[d_id].kind	    = new_dragon.kind
				dragons_info[d_id].sex      = new_dragon.sex
				dragons_info[d_id].signup   = 0
				dragons_info[d_id].ch_name  = 0
				--
				ret.result = C.REAR_DRAGON_SUCCEEDED
				ret.dragon.dragon_id = new_dragon.dragon
				ret.dragon.his_rank = 0
				ret.dragon.m_time   = 0
				ret.dragon.strength = new_dragon.strength
				ret.dragon.agility  = new_dragon.agility
				ret.dragon.intellect= new_dragon.intellect
				ret.dragon.max_str  = new_dragon.max_str
				ret.dragon.max_agi  = new_dragon.max_agi
				ret.dragon.max_int  = new_dragon.max_int
				ret.dragon.kind     = new_dragon.kind
				ret.dragon.sex      = new_dragon.sex
				ret.dragon.signup   = 0
				ret.dragon.ch_name  = 0
				--print("造龙成功: " .. mate_kind .. "   id: " .. new_dragon.dragon )
			end
		else
			ret.result = C.REAR_DRAGON_MATE_FAILED
			--print("不满足生育条件,没有造龙成功哦")
		end

		return ret
	end

	--喂龙
	processor_[C.kRearDragonFeed] = function(msg)
		local req = cast("const RearDragonFeed&",msg)
		local ret = new("RearDragonFeedResult")
		local tmp = nil
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end

		local dragon = dragons_info[req.dragon_id]
		if dragon==nil then
			--无此龙
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		if dragon.strength>=dragon.max_str and
			dragon.agility>=dragon.max_agi and
			dragon.intellect>=dragon.max_int then
			ret.result = C.REAR_DRAGON_PROPERTY_LIMIT
			return ret
		end

		--
		local food = props_ctf[req.food_kind]
		if food==nil or food.type~=C.kPropPlaygroundFood then
			--没有此种食物
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		else
			--扣掉食物
			if player.IsPlaygroundPropEnough( req.food_kind, 1 ) then
				player.ModifyPlaygroundProp( req.food_kind, -1 )
			else
				ret.result = C.REAR_DRAGON_LACK_RSC
				return ret
			end
		end

		player.AssistantCompleteTask( tasks_cfg.kRearDragonFeed, 999 )
		--判断
		local bSucceeded = false
		if (dragon.strength<=food.pro1.strength or food.pro1.strength==0)
			and (dragon.agility<=food.pro1.agility or food.pro1.agility==0)
			and (dragon.intellect<=food.pro1.intellect or food.pro1.intellect==0) then
			--100%成功
			--
			bSucceeded = true
		elseif (food.pro2.strength==0 or (dragon.strength>food.pro1.strength and dragon.strength<=food.pro2.strength) )
			and (food.pro2.agility==0 or (dragon.agility>food.pro1.agility  and dragon.agility<=food.pro2.agility) )
			and (food.pro2.intellect==0 or (dragon.intellect>food.pro1.intellect and dragon.intellect<=food.pro2.intellect) ) then
			--70%成功
			--
			tmp = math.random(1,100)
			if tmp<=g_.rear_dragon.kFeedProbability2 then
				bSucceeded = true
			end
		elseif (food.pro3.strength==0 or (dragon.strength>food.pro2.strength and dragon.strength<=food.pro3.strength) )
			and (food.pro3.agility==0 or (dragon.agility>food.pro2.agility  and dragon.agility<=food.pro3.agility) )
			and (food.pro3.intellect==0 or (dragon.intellect>food.pro2.intellect and dragon.intellect<=food.pro3.intellect) ) then
			--30%成功
			--
			tmp = math.random(1,100)
			if tmp<=g_.rear_dragon.kFeedProbability3 then
				bSucceeded = true
			end
		else
			--失败
			bSucceeded = false
		end

		if bSucceeded==true then
			tmp = dragon.strength + food.strength
			if tmp>dragon.max_str then
				tmp=dragon.max_str
			elseif tmp<1 then
				tmp = 0
			end
			dragon.strength = tmp
			--
			tmp = dragon.agility + food.agility
			if tmp>dragon.max_agi then
				tmp=dragon.max_agi
			elseif tmp<1 then
				tmp = 0
			end
			dragon.agility  = tmp
			--
			tmp = dragon.intellect + food.intelligence
			if tmp>dragon.max_int then
				tmp = dragon.max_int
			elseif tmp<1 then
				tmp = 0
			end
			dragon.intellect= tmp
			--database
			UpdateField2(C.ktPlaygroundDragon,C.kfPlayGroundDragon,dragon.dragon,0,C.kInvalidID,{C.kfPlaygroundStrength,dragon.strength},{C.kfPlaygroundAgility,dragon.agility},{C.kfPlaygroundIntellect,dragon.intellect})

			ret.result = C.REAR_DRAGON_SUCCEEDED
			ret.strength = dragon.strength
			ret.agility  = dragon.agility
			ret.intellect= dragon.intellect
		else
			ret.result = C.REAR_DRAGON_FEED_FAIL
		end

		--
		return ret
	end

	--重置交配时间
	processor_[C.kRearDragonResetMateTime] = function(msg)
		local req = cast("const RearDragonResetMateTime&", msg)
		local ret = new("RearDragonResetMateTimeResult")
		local tmp = nil
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end

		local dragon = dragons_info[req.dragon_id]
		if dragon==nil then
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		end

		tmp = player.IsGoldEnough(g_.rear_dragon.kResetMateIntervalCost)
		if tmp==true then
			player.ConsumeGold( g_.rear_dragon.kResetMateIntervalCost, gold_consume_flag.rear_dragon_mate_time_reset )
			dragon.m_time = 0
			UpdateField2(C.ktPlaygroundDragon,C.kfPlayGroundDragon,dragon.dragon,0,C.kInvalidID,{C.kfPlaygroundMTime,0})
		else
			ret.result = C.REAR_DRAGON_NOT_ENOUGH
			return ret
		end

		ret.result = C.REAR_DRAGON_SUCCEEDED
		return ret
	end

	--放生
	processor_[C.kRearDragonRelease] = function(msg)
		local req = cast("const RearDragonRelease&",msg)
		local ret = new("RearDragonReleaseResult",0,0)
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end

		local dragon = dragons_info[req.dragon_id]
		if dragon==nil then
			--没有此条龙
			ret.result = C.REAR_DRAGON_INVALID
			return ret
		elseif dragon.signup==1 then
			--正在参与比赛
			ret.result = C.REAR_DRAGON_RACING
			return ret
		end

		cur_dragons = cur_dragons - 1
		dragons_info[req.dragon_id] = nil

		player.DeleteRow(C.ktPlaygroundDragon, req.dragon_id)

		ret.result = C.REAR_DRAGON_SUCCEEDED
		--
		--根据dragon.potential潜力判断放生得到的兑换券数量
		ret.amount = base_ctf[dragon.kind].price
		--
		playground.ModifyPlaygroundTickets( ret.amount )
		--
		return ret

	end

	--孵化龙蛋
	function obj.HatchDragonEgg( egg_kind )
		--
		local notify = new('GetNewDragonNotify')
		--
		if cur_dragons>=rear_rooms then
			return C.REAR_DRAGON_ROOM_LIMIT
		end

		local egg = props_ctf[egg_kind]
		if egg==nil or egg.hatch_kind==nil or egg.type~=C.kPropPlaygroundEgg then
			return C.REAR_DRAGON_INVALID
		end
		--
		local tmp_kind = math.random(1, #egg.hatch_kind)
		tmp_kind = egg.hatch_kind[tmp_kind]
		--
		if base_ctf[tmp_kind]==nil then
			return C.REAR_DRAGON_INVALID
		end
		--
		local new_dragon = {}
		new_dragon.kind   = tmp_kind
		new_dragon.strength = math.random( base_ctf[tmp_kind].ini_str[1], base_ctf[tmp_kind].ini_str[2] )
		new_dragon.agility  = math.random( base_ctf[tmp_kind].ini_agi[1], base_ctf[tmp_kind].ini_agi[2] )
		new_dragon.intellect= math.random( base_ctf[tmp_kind].ini_int[1], base_ctf[tmp_kind].ini_int[2] )
		new_dragon.max_str  = math.random( base_ctf[tmp_kind].max_str[1], base_ctf[tmp_kind].max_str[2] )
		new_dragon.max_agi  = math.random( base_ctf[tmp_kind].max_agi[1], base_ctf[tmp_kind].max_agi[2] )
		new_dragon.max_int  = math.random( base_ctf[tmp_kind].max_int[1], base_ctf[tmp_kind].max_int[2] )
		new_dragon.sex      = math.random( 1,2 ) - 1
		new_dragon.player   = player_id
		--
		new_dragon.dragon   = db.AddDragon( new_dragon )
		--
		cur_dragons = cur_dragons + 1
		local d_id = new_dragon.dragon
		dragons_info[d_id] = {}
		dragons_info[d_id].dragon   = d_id
		dragons_info[d_id].his_rank = 0
		dragons_info[d_id].m_time   = 0
		dragons_info[d_id].strength = new_dragon.strength
		dragons_info[d_id].agility  = new_dragon.agility
		dragons_info[d_id].intellect= new_dragon.intellect
		dragons_info[d_id].max_str  = new_dragon.max_str
		dragons_info[d_id].max_agi  = new_dragon.max_agi
		dragons_info[d_id].max_int  = new_dragon.max_int
		dragons_info[d_id].kind	    = new_dragon.kind
		dragons_info[d_id].sex      = new_dragon.sex
		dragons_info[d_id].signup   = 0
		dragons_info[d_id].ch_name  = 0
		--
		notify.dragon.dragon_id = new_dragon.dragon
		notify.dragon.his_rank = 0
		notify.dragon.m_time   = 0
		notify.dragon.strength = new_dragon.strength
		notify.dragon.agility  = new_dragon.agility
		notify.dragon.intellect= new_dragon.intellect
		notify.dragon.max_str  = new_dragon.max_str
		notify.dragon.max_agi  = new_dragon.max_agi
		notify.dragon.max_int  = new_dragon.max_int
		notify.dragon.kind     = new_dragon.kind
		notify.dragon.sex      = new_dragon.sex
		notify.dragon.signup   = 0
		notify.dragon.ch_name  = 0

		--
		player.Send2Gate( notify )
		--
		return C.REAR_DRAGON_SUCCEEDED
	end

	--设置龙的信息,由赛龙模块调用
	function obj.SetDragonInfo( type, dragon_id, data )
		local dragon = dragons_info[dragon_id]
		if not dragon then	return false end
		if type==1 then
			--设置名次
			dragon.his_rank = data
		elseif type==2 then
			--设置报名状态
			dragon.signup = data
		else
			return false
		end
		return true
	end

	--激活育龙功能
	function obj.ActivateRearDragon()
		if not l_active then
			player.InsertRow(C.ktPlaygroundRearroom,{ C.kfRearrooms, 0 } )
		end
		l_active = true
	end
	
	--获取育龙是否激活
	function obj.IsActivte()
		return l_active
	end
	
	--获取龙的信息
	function obj.GetDragonInfo( type, dragon_id )
		if type==1 then
			if dragons_info[dragon_id] then return true else return false end
		end
	end
	
	--设置育龙所等级
	function obj.SetRearroomLevel( _level )
		if _level<1 or _level>g_.rear_dragon.kRearroomsLimit or _level<rear_rooms then
			return false
		else
			player.UpdateField(C.ktPlaygroundRearroom,C.kInvalidID,{C.kfRearrooms, _level} )
		end
		rear_rooms = _level
		return true
	end


	function obj.ProcessMsgFromDb(type,msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsg(type,msg)
		local f = processor_[type]
		if f then return f(msg) end
	end


return obj

end
