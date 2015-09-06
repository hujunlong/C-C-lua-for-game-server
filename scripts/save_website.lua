local rewards_cfg = require('config.save_website_reward')[1].rewards
local heros_cfg = require('config.hero')
require('config.town_cfg')
local builds_cfg = GetTownCfg()

local ffi = require("ffi")
local C = ffi.C
--local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
--local copy = ffi.copy


function CreateSaveWebsite( player )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	
	local b_got_ = 1
	
	
	processor_[C.kGetSaveWebsiteInfo] = function()
		local result = new('GetSaveWebsiteInfoResult')
		result.exist_reward = 0
		result.amount = 0
		if b_got_==0 then
			result.exist_reward = 1
			for _, reward in pairs(rewards_cfg) do
				result.rewards[result.amount].type = reward.type
				result.rewards[result.amount].kind = reward.kind
				result.rewards[result.amount].amount = reward.amount
				result.amount = result.amount + 1
			end
		end
		return result
	end
	
	processor_[C.kGetSaveWebsiteReward] = function()
		local result = new('GetSaveWebsiteRewardResult',C.eInvalidOperation)
		if b_got_==0 then
			local add_props = {}
			local b_have_prop = false
			local b_error = false
			for _, reward in pairs(rewards_cfg) do
				if reward.type==1 then
					if not add_props[reward.kind] then add_props[reward.kind]=0 end
					add_props[reward.kind] = add_props[reward.kind]+reward.amount
					b_have_prop = true
				elseif reward.type==2 then
					if not builds_cfg[reward.kind] then
						print('error building kind='..reward.kind)
						b_error = true
					end
				elseif reward.type==3 then
					if not heros_cfg[reward.kind] then
						print('error hero kind='..reward.kind)
						b_error = true
					end
				else
					print('unknown reward type for save_website, type='..reward.type)
					b_error = true
					break
				end
			end
			if not b_error then
				if b_have_prop then
					if not player.AddNewProps2Area4Kinds(C.kAreaBag, add_props) then
						result.result = C.eBagLeackSpace
					else
						result.result = C.eSucceeded
					end
				else
					result.result = C.eSucceeded
				end
				if result.result==C.eSucceeded then
					for _, reward in pairs(rewards_cfg) do
						if reward.type==1 then
						elseif reward.type==2 then
							player.AddBuilding(reward.kind)
						elseif reward.type==3 then
							--[[
							暂时没有激活英雄的接口
							保留
							]]
						end
					end
					b_got_ = 1
					player.UpdateField(C.ktSaveWebsite, C.kInvalidID, {C.kfGot,1})
				end
			end
		end
		return result
	end
	
	db_processor_[C.kInternalSaveWebsiteInfo] = function(msg)
		local info = cast('const InternalSaveWebsiteInfo&',msg)
		b_got_ = info.b_got
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