local monster_cfgs = require('config.monster')
local prop_cfgs = require('config.props')
require('tools.table_ext')
require('tools.algorithm')

local ffi = require('my_ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

function ProduceMonstersGroup(monsters)
	local group = {}
	for _,monster in ipairs(monsters) do 
		local monster_property = table.deep_clone(monster_cfgs[monster.sid])
		monster_property.id = monster.sid
		monster_property.max_life = monster_property.life
		monster_property.momentum = 0
		group[monster.pos] = monster_property
	end
	return group
end

function MonstersGroupRewards(monsters_group, player, sell_prop)
	local rewards = {heroexp=0, silver=0, feat=0, props={}}
	for _,monster in pairs(monsters_group) do 
		rewards.heroexp = rewards.heroexp+monster.exp
		rewards.silver = rewards.silver+monster.silver
		rewards.feat = rewards.feat+monster.feat
		if monster.prop then
			for _,prop in ipairs(monster.prop) do
				if math.random()<prop.probability then 
					rewards.props[prop.kind] = (rewards.props[prop.kind] or 0) + prop.amount
				end
			end
		end
		if monster.round_table_prop then
			local got_prop = algorithm.RoundTable(monster.round_table_prop)
			if got_prop then
				rewards.props[got_prop.kind] = got_prop.amount 
			end
		end
	end
	local count = 3+table.size(rewards.props)
	local rwds = new('Reward[?]', count)
	rwds[0] = {C.kHeroExpRsc,0,rewards.heroexp}
	rwds[1] = {C.kSilverRsc,0,rewards.silver}
	rwds[2] = {C.kFeatRsc,0,rewards.feat}
	player.AddHeroExp(rewards.heroexp)
	player.ModifySilver(rewards.silver)
	player.ModifyFeat(rewards.feat)
	local i = 3 
	for kind, amount in pairs(rewards.props) do 
		if sell_prop then
			player.ModifySilver(prop_cfgs[kind].sale_price*amount)
		else
			if not player.IsBagFull() then
				player.ModifyProp(kind, amount) 
			else
				break
			end
		end		
		rwds[i] = {C.kPropRsc, kind, amount}
		i = i+1
	end
	return count, rwds
end