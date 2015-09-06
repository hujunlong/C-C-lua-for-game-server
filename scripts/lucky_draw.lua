local prop_cfgs = require('config.props')
local cost_cfgs = require('config.lucky_draw_cost')
local reward_cfgs = require('config.lucky_draw_reward')


local free_times_ = require('config.lucky_draw_times')[1].times
local close_level_ = require('config.lucky_draw_close')[1].level


local gold_consume_flag = require('define.gold_consume_flag')

local ffi = require('ffi')
local C = ffi.C
--local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
--local copy = ffi.copy

--初始化
local online_players = {}
function InitLuckyDraw( players )
	online_players = players
end


function ResetLuckyDraw()
	local sql = 'update lucky_draw set `times`=0'
	GlobalSend2Db(new('ExcuteSqlDirectly',#sql, sql), 2+#sql)
	--
	for _, player in pairs(online_players) do
		player.ResetLuckyDraw()
	end
end

local rewards_ = {}

local function CalcRewardProbability()
	local all = 0
	for _, reward in pairs(reward_cfgs) do
		all = all + reward.weight
	end
	for _, reward in pairs(reward_cfgs) do
		rewards_[reward.location] = {}
		rewards_[reward.location].probability = reward.weight/all
		rewards_[reward.location].kind = reward.kind
		rewards_[reward.location].level = reward.level
	end
end

CalcRewardProbability()

function CreateLuckyDraw(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local lucky_draw_ = {}
	lucky_draw_.times = 0
	
	
	processor_[C.kGetLuckyDrawInfo] = function()
		local result = new('GetLuckyDrawInfoResult')
		result.times = lucky_draw_.times
		return result
	end
	
	processor_[C.kDoLuckyDraw] = function()
		local result = new('DoLuckyDrawResult',C.eLackResource)
		if player.GetLevel()>close_level_ then
			result.result = C.eFunctionDisable
		elseif player.IsBagFull() then
			result.result = C.eBagFull
		else
			local gold_times = lucky_draw_.times - free_times_
			local cost_gold = -1
			if gold_times>=0 then
				for _, cost_cfg in pairs(cost_cfgs) do
					if (gold_times+1)>=cost_cfg.times.min and (gold_times+1)<=cost_cfg.times.max then
						cost_gold = cost_cfg.gold
					end
				end
				if cost_gold==-1 then
					cost_gold = cost_cfgs[#cost_cfgs].gold
				end
			end
			result.result = C.eSucceeded
			if cost_gold>0 then
				if not player.IsGoldEnough(cost_gold) then
					result.result = C.eLackResource
				end
			end
			if result.result==C.eSucceeded then
				local probability = math.random()
				local level = 0
				local kind = 0
				for location, reward in pairs(rewards_) do
					if reward.probability>=probability then
						if not prop_cfgs[reward.kind] then
							print('error prop kind='..reward.kind..' in lucky_draw')
							return
						end
						result.location = location
						level = math.random(reward.level.min, reward.level.max)
						kind = reward.kind
						break
					else
						probability = probability - reward.probability
					end
				end
				local equip_id = player.AddNewEquip2Area(C.kAreaBag, kind, nil, level, nil, nil, nil, nil)
				if equip_id then
					if cost_gold>0 then
						player.ConsumeGold(cost_gold, gold_consume_flag.lucky_draw_lottery)
					end
					result.result = C.eSucceeded
					result.equip_id = equip_id
					lucky_draw_.times = lucky_draw_.times + 1
					player.UpdateField(C.ktLuckyDraw, C.kInvalidID, {C.kfTimes,lucky_draw_.times})
				else
					result.result = C.eInvalidValue
				end
			end
		end
		return result
	end
	
	
	db_processor_[C.kInternalLuckyDrawInfo] = function(msg)
		local info = cast('const InternalLuckyDrawInfo&',msg)
		lucky_draw_.times = info.times
	end
	
	function obj.Reset()
		lucky_draw_.times = 0
	end
	
	function obj.ProcessMsgFromDb(type, msg)
		local f = db_processor_[type]
		if f then return f(msg) end
	end

	function obj.ProcessMsg(type, msg)
		local f = processor_[type]
		if f then return f(msg) end
	end
return obj
end