local cfg_shop = require('config.shop')[4]
local cfg_props = require('config.props')

local gold_consume_flag = require('define.gold_consume_flag')

require('global_data')
local g_ = require('config.global')

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy


--初始化
local online_players = {}
function InitPlaygroundProp( g_players )
	online_players = g_players
end


--

--重置购买数次
function ResetPlaygroundPropBuyCount()
	
	db.ResetPlaygroundPropBuyCount()
	--local tmp_notify = new('NotifyPlaygourndPropReset')
	--local h		  = new('MqHead', 0, C.kNotifyPlaygourndPropReset, -1)
	--
	for _, v_player in pairs( online_players ) do

		if v_player.ResetPlayground( 3 ) then
			--h.aid = v_uid
			--C.Send2Gate(h, tmp_notify, sizeof(tmp_notify) )
		end
	end
end

--CreateWaitableTimerForResetAction( action_type.playground_prop, g_.playground_prop.kResetTime, ResetPlaygroundPropBuyCount )


function CreatePlaygroundProp( player, playground )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}

	----
	local player_id = player.GetUID()
	----

	local my_props = {}
	local prop_amount = 0


	db_processor_[C.kInternalPlaygroundProps] = function(msg)
		local tmp_props = cast('const InternalPlaygroundProps&', msg)
		if tmp_props.amount>0 then
			--
			prop_amount = tmp_props.amount
			--
			local tmp_prop = 0
			for i1=1, tmp_props.amount, 1 do
				tmp_prop = tmp_props.prop[i1-1].kind
				my_props[tmp_prop] = {}
				my_props[tmp_prop].amount = tmp_props.prop[i1-1].amount
				my_props[tmp_prop].buy_count = tmp_props.prop[i1-1].buy_count
			end
		else
			prop_amount = 0
		end
	end

	processor_[C.kGetPlaygroundPropsInfo] = function(msg)
		--
		local ret = new('GetPlaygroundPropsInfoResult')
		if not playground.IsRearActive() then
			ret.result = C.eFunctionDisable
			return ret,4
		else
			ret.result = C.eSucceeded
		end
		ret.amount = prop_amount
		--
		local tmp_index = 0
		for v_kind, v in pairs( my_props ) do
			ret.prop[tmp_index].kind = v_kind
			ret.prop[tmp_index].amount = v.amount
			ret.prop[tmp_index].buy_count = v.buy_count
			tmp_index = tmp_index + 1
		end
		local bytes = 8 + sizeof(ret.prop[0])*tmp_index
		--
		return ret,bytes
	end

	--购买东西
	processor_[C.kPlaygroundPropBuy] = function(msg)
		--
		local buy = cast('const PlaygroundPropBuy&', msg)
		local ret = new('PlaygroundPropBuyResult')
		if not playground.IsRearActive() then
			ret.result = C.eFunctionDisable
			return ret
		end
		--
		local buy_prop = cfg_shop[buy.prop_index]
		if buy_prop==nil then
			ret.result = C.PP_INVALID
			return ret
		end
		--
		--if player.GetLevel()<buy_prop.level then
			--ret.result = C.eLowLevel
		if buy_prop.coin_type==1 and not player.IsSilverEnough(buy_prop.price) then
			ret.result = C.PP_LackResource
		elseif buy_prop.coin_type==4 and not player.IsGoldEnough(buy_prop.price) then
			ret.result = C.PP_LackResource
		elseif buy_prop.coin_type==5 and not playground.IsTicketsEnough(buy_prop.price) then
			ret.result = C.PP_LackResource
		else
			local tmp_prop = cfg_props[buy_prop.prop_kind]
			if tmp_prop==nil then
				ret.result = C.PP_INVALID
			else
				--vip金币食物
				local vip_level = player.GetVIPLevel()
				if buy_prop.coin_type==4 and tmp_prop.type==C.kPropPlaygroundFood then
					if buy_prop.limit<0 then
						--不限量金币购买
						if vip_level<g_.playground_prop.kGoldBuyFoodNeedVipLevel then
							ret.result = C.PP_LOW_VIP_LEVEL
							return ret
						end
					else--限量的
						if vip_level<g_.playground_prop.kGoldBuyLimitFoodNeedVipLevel then
							ret.result = C.PP_LOW_VIP_LEVEL
							return ret
						elseif my_props[buy_prop.prop_kind]~=nil and my_props[buy_prop.prop_kind].buy_count>=buy_prop.limit then
							ret.result = C.PP_LIMIT_BUY_COUNT
							return ret
						end
					end
				end
				--食物数量限制
				if tmp_prop.type==C.kPropPlaygroundFood then
					if my_props[buy_prop.prop_kind]~=nil then
						if my_props[buy_prop.prop_kind].amount>=99 then
							ret.result = C.PP_AMOUNT_LIMIT
							return ret
						end
					end
				end
				if tmp_prop.type==C.kPropPlaygroundFood or tmp_prop.type==C.kPropPlaygroundAgent then
					--食物 or 催化剂
					if my_props[buy_prop.prop_kind]==nil then
						my_props[buy_prop.prop_kind] = {}
						my_props[buy_prop.prop_kind].buy_count = 0
						prop_amount = prop_amount + 1
						my_props[buy_prop.prop_kind].amount = 1
					else
						my_props[buy_prop.prop_kind].amount = my_props[buy_prop.prop_kind].amount + 1
					end
					my_props[buy_prop.prop_kind].buy_count = my_props[buy_prop.prop_kind].buy_count + 1
					--
					db.ModifyPlaygroundProp( player_id, buy_prop.prop_kind, my_props[buy_prop.prop_kind].amount, my_props[buy_prop.prop_kind].buy_count )
					--
					ret.result = C.PP_SUCCEEDED
					--
				elseif tmp_prop.type==C.kPropPlaygroundEgg then
					--龙蛋
					ret.result = playground.HatchDragonEgg( buy_prop.prop_kind )
				else
					--暂时不支持的类型
					print('购买道具类型: ' .. tmp_prop.type .. ', kind=' .. buy_prop.prop_kind .. ', 还未支持')
					ret.result = C.PP_INVALID
				end
				if ret.result==C.PP_SUCCEEDED then
					if buy_prop.coin_type==1 then
						player.ModifySilver( buy_prop.price )
					elseif buy_prop.coin_type==4 then
						player.ConsumeGold( buy_prop.price, gold_consume_flag.playground_buy_prop )
					elseif buy_prop.coin_type==5 then
						playground.ModifyPlaygroundTickets( -buy_prop.price )
					else
						print('不支持此种此货币...')
						ret.result = C.PP_INVALID
					end
				end
			end
		end
		--
		return ret
	end

	--出售东西
	processor_[C.kPlaygroundPropSell] = function(msg)
	end

	--
	function obj.IsPlaygroundPropEnough( prop_kind, amount )
		if my_props[prop_kind]==nil then
			return false
		elseif my_props[prop_kind].amount>=amount then
			return true
		else
			return false
		end
	end

	--修改道具
	function obj.ModifyPlaygroundProp( prop_kind , amount )
		--
		if cfg_props[prop_kind]==nil then
			return false
		end
		--
		if my_props[prop_kind]==nil then
			my_props[prop_kind] = {}
			my_props[prop_kind].amount = 0
			my_props[prop_kind].buy_count = 0
			if amount>0 then
				prop_amount = prop_amount + 1
			end
		end
		--
		if (my_props[prop_kind].amount+amount)<0 then
			return false
		else
			my_props[prop_kind].amount = my_props[prop_kind].amount + amount
			db.ModifyPlaygroundProp( player_id, prop_kind, my_props[prop_kind].amount, my_props[prop_kind].buy_count )
			return true
		end
	end

	function obj.ResetBuyCount()
		for v_kind, v in pairs( my_props ) do
			v.buy_count = 0
		end
		return playground.IsRearActive()
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
