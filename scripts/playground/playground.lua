require("playground.fish")
require("playground.race_dragon")
require("playground.rear_dragon")
require("playground.turntable")
require("playground.prop")
local action_cft = require("define.action_id")

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy


--初始化游乐场,获取在线玩家列表
function InitPlayGround( g_players )
	InitFish( g_players )
	InitRaceDragon( g_players )
	InitTurntable( g_players )
	InitPlaygroundProp( g_players )
end



function CreatePlayGround( player )
	--
	local obj = {}
	local processors_ = {}
	local db_processors_ = {}

	-----
	local player_id  = player.GetUID()
	local pg_info = {}
	pg_info.tickets = 0

	-----
	local fish_ = nil
	local race_ = nil
	local rear_ = nil
	local turn_= nil
	local prop_ = nil



	--
	function obj.IsTicketsEnough( amount )
		return pg_info.tickets>=amount
	end

	--
	function obj.ModifyPlaygroundTickets( amount )
		if amount==nil or (pg_info.tickets+amount<0) then
			return false
		end
		pg_info.tickets = pg_info.tickets + amount
		--成就
		player.RecordAction( action_cft.kPlaygroundGotSpecialTickets, pg_info.tickets, nil)
		--
		player.UpdateField(C.ktPlayground,C.kInvalidID,{C.kfPlaygroundTickets,pg_info.tickets})
		--
		local rscDelta = new('ResourceDelta', pg_info.tickets, amount, C.kTicketsRsc)
		player.Send2Gate(rscDelta)
	end

	function obj.IsPlaygroundPropEnough( prop_kind, amount )
		return prop_.IsPlaygroundPropEnough( prop_kind, amount )
	end

	function obj.ModifyPlaygroundProp( prop_kind, amount )
		return prop_.ModifyPlaygroundProp( prop_kind, amount )
	end


	--获取育龙是否激活
	function obj.IsRearActive()
		return rear_.IsActivte()
	end
	
	--设置育龙所等级
	function obj.SetRearroomLevel( _level )
		return rear_.SetRearroomLevel( _level )
	end

	--孵化龙蛋
	function obj.HatchDragonEgg( egg )
		return rear_.HatchDragonEgg( egg )
	end

	--设置游乐场数据
	--1 	历史名次
	--2		报名状态
	--100 	龙的名字
	function obj.SetPlaygroundInfo( tbl_data )
		if not tbl_data.type then return false end
		if tbl_data.type<100 then
			return rear_.SetDragonInfo( tbl_data.type, tbl_data.id, tbl_data.data )
		elseif tbl_data.type<200 then
			return race_.SetDragonInfo( tbl_data.type, tbl_data.id, tbl_data.data )
		end
	end
	
	function obj.SetDragonInfo( type, dragon_id, data )
		if type<100 then
			return rear_.SetDragonInfo( type, dragon_id, data )
		elseif type<200 then
			return race_.SetDragonInfo( type, dragon_id, data )
		end
	end
	
	--获取龙的信息
	--1 是否拥有此龙
	function obj.GetDragonInfo( type, dragon_id )
		return rear_.GetDragonInfo( type, dragon_id )
	end
	
	--function obj.SetDragonHistoryRank( dragon_id, his_rank )
		--return rear_.SetDragonHistoryRank( dragon_id, his_rank )
	--end

	--function obj.SetDragonSignupState( dragon_id, state )
		--return rear_.SetDragonSignupState( dragon_id, state )
	--end

	--function obj.SetDragonInfo2( dragon_info )
		--return race_.SetDragonInfo( dragon_info )
	--end

	--激活钓鱼功能,			外部调用
	function obj.ActivateFish()
		return fish_.ActivateFish()
	end
	
	--解锁渔场,fishery是1,2,3,...,20			外部调用
	function obj.UnlockFishery( fishery )
		return fish_.UnlockFishery(fishery)
	end

	--激活转轮功能			外部调用
	function obj.ActivateTurntable()
		return turn_.ActivateTurntable()
	end
	
	--激活育龙功能			外部调用
	function obj.ActivateRearDragon()
		return rear_.ActivateRearDragon()
	end
	
	--激活赛龙功能			外部调用
	function obj.ActivateRaceDragon()
		return race_.ActivateRace()
	end
	
	--重置子系统
	--1	转轮
	--2	钓鱼
	--3 游乐场道具
	function obj.ResetPlayground( subsystem )
		if subsystem==1 then
			return turn_.ResetTurntable()
		elseif subsystem==2 then
			return fish_.ResetFished()
		elseif subsystem==3 then
			return prop_.ResetBuyCount()
		else
			return false
		end
	end
	
	function obj.ModifyTurnTimes(value)
		turn_.ModifyTimes(value)
	end
	
	function obj.ModifyFishTimes(delta)
		return fish_.ModifyFishTimes(delta)
	end

	--来自数据库的初始化消息
	db_processors_[C.kInternalPlaygroundInfo] = function(msg)
		local tmp_pg_info = cast('const InternalPlaygroundInfo&',msg)
		pg_info.tickets = tmp_pg_info.tickets
	end

	--获取
	processors_[C.kGetPlaygroundInfo] = function()
		local ret = new('GetPlaygroundInfoResult')
		ret.tickets = pg_info.tickets
		--
		return ret
	end





	local function ProcessMsg(type, msg)
		local f = processors_[type]
		if f then return f(msg) end
	end

	local function ProcessMsgFromDb(type, msg)
		local f = db_processors_[type]
		if f then return f(msg) end
	end




	function obj.ProcessMsgFromDb(type, msg)
		--
		fish_.ProcessMsgFromDb(type, msg)
		race_.ProcessMsgFromDb(type, msg)
		rear_.ProcessMsgFromDb(type, msg)
		turn_.ProcessMsgFromDb(type, msg)
		prop_.ProcessMsgFromDb(type, msg)
		--
		ProcessMsgFromDb(type, msg)
	end

	function obj.ProcessMsg(type, msg)
		local result,bytes = nil,nil
		--
		repeat
			result, bytes = fish_.ProcessMsg(type, msg)
			if result then break end
			result, bytes = race_.ProcessMsg(type, msg)
			if result then break end
			result, bytes = rear_.ProcessMsg(type, msg)
			if result then break end
			result, bytes = turn_.ProcessMsg(type, msg)
			if result then break end
			result, bytes = prop_.ProcessMsg(type, msg)
			if result then break end
			--
			result, bytes = ProcessMsg(type, msg)
		until true
		--
		return result,bytes
	end


	-----
	fish_ = CreateFish( player, obj )
	race_ = CreateRaceDragon ( player, obj )
	rear_ = CreateRearDragon ( player, obj )
	turn_= CreateTurntable( player )
	prop_ = CreatePlaygroundProp( player, obj )


return obj

end
