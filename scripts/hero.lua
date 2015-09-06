require('tools.table_ext')
require('my_ffi')
require('data')
require('fight_power')

local prop_cfgs = require('config.props')
local hero_cfgs = require('config.hero')
local lv_exp_map = require('config.hero_level_exp')
local actions = require('define.action_id')
local gold_consume_flag = require('define.gold_consume_flag')

local kMaxLevel = #lv_exp_map+1

local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local bringup_cost = require('config.bringup_cost')
local bringup_range = require('config.bringup_range')

local kHat,kFrock,kTrousers,kShoes,kMantle,kJewelry =1,2,3,4,5,6
local equip_map = {}
equip_map[kHat]=C.klHat
equip_map[kFrock]=C.klFrock
equip_map[kTrousers]=C.klTrousers
equip_map[kShoes]=C.klShoes
equip_map[kMantle]=C.klMantle
equip_map[kJewelry]=C.klJewelry
for i=10,18 do  equip_map[i]=C.klMainHand end
equip_map[19] = C.klDeputyHand

--请勿缓存与ID有关数据，因为ID会发生改变
local function CreateHero(player, id, level, status, location, exp, bringup)
	local obj = {}
    
	function obj.Dismiss()
		local result = C.eInvalidOperation
		if status==C.kHeroInGroup then
			status = C.kHeroDismissed
			location = 0
			player.UpdateField(C.ktHero, id, {C.kfStatus, C.kHeroDismissed}, {C.kfLocation, 0})
			result = C.eSucceeded
            fight_power.CheckFightPowerChange(player.GetUID())
		end
		return result
	end

	function obj.Recruit()
		local result = C.eInvalidOperation
		if status==C.kHeroDismissed then
			result = C.eSucceeded
			player.UpdateField(C.ktHero, id, {C.kfStatus, C.kHeroInGroup})
		elseif status==C.kHeroDisable then
			result = C.eSucceeded
			player.InsertRow(C.ktHero, {C.kfID, id}, {C.kfLevel,1}, {C.kfStatus, C.kHeroInGroup}, {C.kfExp, 0})
		end
		if result==C.eSucceeded then
			status = C.kHeroInGroup
			player.RecordAction(actions.kHeroRecruited, 1, id)
			fight_power.CheckFightPowerChange(player.GetUID())
		end
		return result
	end

	function obj.status()
		return status
	end

	function obj.level()
		return level
	end

     function obj.ShouldAddExp(delta)
        local Train_level = player.GetTrainingGroundLevel()
        if Train_level == nil then
           Train_level = 0
        end
        
       if level >= kMaxLevel or level > Train_level then return 0 end
			local totalExp = exp + delta
            local level_exp = 0
            for i = level,Train_level do
                level_exp = lv_exp_map[i].exp + level_exp
                if totalExp < level_exp then
                    return delta
                end
            end
           delta = level_exp - exp -1
       return delta
    end

 function obj.AddExp(delta)
        delta = obj.ShouldAddExp(delta)
        if delta == 0 then
            return
        end
		local tmp_level = level
		while delta>0 do
			local exp_for_next_level = lv_exp_map[tmp_level].exp
			if exp_for_next_level then
				if exp+delta<exp_for_next_level then
					exp = exp+delta
					delta = 0
				else
					delta = delta - (exp_for_next_level-exp)
					exp = 0
					tmp_level = tmp_level+1
				end
			else
				exp = 0
				delta = 0
			end
		end
		if tmp_level > player.GetLevel() then
			tmp_level=player.GetLevel()
			exp = 0
		end
		if tmp_level>level then
			level = tmp_level
			player.UpdateField(C.ktHero, id, {C.kfLevel, level})
            player.RecordAction(actions.kHeroLevel, level, id)
			local push = new('HeroLevelUp')
            push.hero = id
            push.level = level
	    push.exp = exp
            player.Send2Gate(push)
		end
		player.UpdateField(C.ktHero, id, {C.kfExp, exp})
	end

	function obj.location(new_value)
		if new_value then
			location = new_value
			player.UpdateField(C.ktHero, id, {C.kfLocation, new_value})
		else
			return location
		end
	end

	local function CanEquip(kind, location)
		local ret = { result=C.eInvalidOperation, take_off={ amount=0 } }
		local prop_cfg = prop_cfgs[kind]
		if prop_cfg and prop_cfg.sub_type then
			local sub_type = prop_cfg.sub_type
			if sub_type<=6 then
				if equip_map[sub_type]==location then
					ret.result = C.eSucceeded
				end
			elseif sub_type>=10 and sub_type<=19 then
				if not hero_cfgs[id].favorite_weapon then return ret end
				local hero_favorite = {}
				local b_favorite = false
				for _, tmp_type in pairs( hero_cfgs[id].favorite_weapon ) do
					if tmp_type==22 then   --武器大师
						b_favorite = true
						hero_favorite.type1 = true
						break
					elseif (sub_type==10 and tmp_type==20)	then--双持单手剑
						b_favorite = true
						hero_favorite.type2 = true
					elseif (sub_type==17 and tmp_type==21) then--双持匕首
						b_favorite = true
						hero_favorite.type3 = true
					elseif sub_type==tmp_type then	--类型匹配
						b_favorite = true
						hero_favorite.type4 = true
					end
				end
				if not b_favorite then
					return ret		--不喜欢这武器
				end
				local props_equips
				local prop
				if sub_type>=11 and sub_type<=18 and sub_type~=17 then--双手装备
					if equip_map[sub_type]~=location then
						return ret		--位置不正确
					end
					props_equips = player.GetHeroEquipments( id )
					if props_equips[C.klMainHand] then
						ret.take_off.amount = ret.take_off.amount + 1
					end
					if props_equips[C.klDeputyHand] then
						ret.take_off.amount = ret.take_off.amount + 1
						ret.take_off.id = props_equips[C.klDeputyHand][3]	--额外脱掉副手装备
					end
				elseif sub_type==19 then	--盾牌,副手
					if equip_map[sub_type]~=location then
						return ret		--位置不正确
					end
					props_equips = player.GetHeroEquipments( id )
					if props_equips[C.klMainHand] then
						prop = props_equips[C.klMainHand][1]
						local tmp_cfg = prop_cfgs[prop.kind]
						if not tmp_cfg then return ret end
						if tmp_cfg.sub_type>=11 and tmp_cfg.sub_type<=18 and tmp_cfg.sub_type~=17 then
							ret.take_off.amount = ret.take_off.amount + 1
							ret.take_off.id = props_equips[C.klMainHand][3]		--双手武器,要脱掉
						end
					end
					if props_equips[C.klDeputyHand] then
						ret.take_off.amount = ret.take_off.amount + 1
					end
				elseif sub_type==10 or sub_type==17 then	--单手剑or匕首
					if equip_map[sub_type]~=location then	--检查是否装备到主手
						if location==C.klDeputyHand then	--是否装备到副手
							if sub_type==10 then
								if not (hero_favorite.type1 or hero_favorite.type2) then
									return ret		--不是武器大师,不双持剑
								end
							else
								if not (hero_favorite.type1 or hero_favorite.type3) then
									return ret		--不是武器大师,不双持匕首
								end
							end
						else
							return ret		--不是装备到主副手,非法的
						end
						--检查主手装备
						props_equips = player.GetHeroEquipments( id )
						if props_equips[C.klMainHand] then
							prop = props_equips[C.klMainHand][1]
							local tmp_cfg = prop_cfgs[prop.kind]
							if not tmp_cfg then return ret end
							if tmp_cfg.sub_type>=11 and tmp_cfg.sub_type<=18 and tmp_cfg.sub_type~=17 then
								ret.take_off.amount = ret.take_off.amount + 1
								ret.take_off.id = props_equips[C.klMainHand][3]		--双手武器,要脱掉
							end
						end
						if props_equips[C.klDeputyHand] then
							ret.take_off.amount = ret.take_off.amount + 1
						end
					else	--装备到主手
						props_equips = player.GetHeroEquipments( id )
						if props_equips[C.klMainHand] then
							ret.take_off.amount = ret.take_off.amount + 1
						end
					end
				end
				ret.result = C.eSucceeded
			else
				print('unknow sub_type: ' .. sub_type )
			end
		end
		return ret
	end


	function obj.Equip(prop_kind, location)
		local res = { result=C.eInvalidOperation }
		local prop_cfg = prop_cfgs[prop_kind]
		if  prop_cfg.required_level and prop_cfg.required_level>level then
			res.result = C.eLowHeroLevel
		else
			res = CanEquip(prop_kind, location)
		end
		return res
	end

	function obj.ToHero4Client(hero)
		hero.status = status
		hero.level = level
		hero.exp = exp
		hero.id = id
		hero.location = location
	end
    
    --培养上限
    local function GetBringupLimit(property)
        return math.floor(20 + level * 2 * hero_cfgs[id].bringup_limit[property])
    end
    
	--培养
	function obj.Bringupproperty4Client(property)
		property.cur.agility = bringup.agility
		property.cur.intelligence =  bringup.intelligence
		property.cur.strength = bringup.strength

		property.max.strength = GetBringupLimit("strength")
		property.max.agility = GetBringupLimit("agility")
		property.max.intelligence = GetBringupLimit("intelligence")

		if bringup.changes_agility~=0 or bringup.changes_intelligence~=0 or bringup.changes_strength~=0 then
			property.no_saved=1
			property.changes.agility = bringup.changes_agility
			property.changes.intelligence = bringup.changes_intelligence
			property.changes.strength = bringup.changes_strength
		else
			property.no_saved=0
			property.changes.agility=0
			property.changes.intelligence=0
			property.changes.strength=0
		end
	end

	function obj.ApplyBringup(bringup_changes,type)
        
        --随机属性算法，读取bringup_range表
        local function BringUpRandom(current, limit)
            local delta = math.random(bringup_range[type].lower, bringup_range[type].upper)
            
            --下限
            if current + delta < 0 then
                delta = 0 - current
            end
            
            --上限
            if current + delta > limit then
                delta = limit - current
            end
            
            --培养值为0
            if type~=4 and current==0 then
                delta = math.random(1, 3)
            end
            
            return delta
        end
        
        --应用培养
        local function BringUp()
            if bringup.strength==GetBringupLimit("strength") and bringup.agility==GetBringupLimit("agility") and bringup.intelligence==GetBringupLimit("intelligence") then
                return
            end
            local cost = bringup_cost[player.GetLevel()]
            if player.GetVIPLevel()>=bringup_range[type].vip and cost then
                cost = cost["bringup"..type]
                if cost then
                    --扣钱
                    if cost.type==1 then
                        if not player.IsSilverEnough(cost.cost) then return false end
                        player.ModifySilver(-cost.cost)
                    else
                        if not player.IsGoldEnough(cost.cost) then return false end
                        player.ConsumeGold(cost.cost, gold_consume_flag["hero_bringup"..type])
                    end
                    
                    --随机属性
                    bringup.changes_strength = BringUpRandom(bringup.strength, GetBringupLimit("strength"))
                    bringup.changes_agility = BringUpRandom(bringup.agility, GetBringupLimit("agility"))
                    bringup.changes_intelligence = BringUpRandom(bringup.intelligence, GetBringupLimit("intelligence"))
                    
                    player.RecordAction(actions.kHeroBringup, 1, type)
                    return true
                end
            end
        end
        
		if player.CanBringUp() and BringUp() then
			bringup_changes.strength = bringup.changes_strength
			bringup_changes.agility = bringup.changes_agility
			bringup_changes.intelligence = bringup.changes_intelligence
			--更新数据库
			local where_fields={{C.kfPlayer,player.GetUID()},{C.kfID,id}}
			local br = new('BringupBin',bringup.strength,bringup.agility,bringup.intelligence,bringup.changes_strength,bringup.changes_agility,bringup.changes_intelligence)
			player.UpdateBinaryStringField(C.ktHero, #where_fields, where_fields, C.kfBringupBin, sizeof(br), br)
		end
	end

	function obj.AcceptBringup(type)
		
		if type==1 and (bringup.changes_agility~=0 or bringup.changes_intelligence~=0 or bringup.changes_strength~=0) then
			bringup.strength = bringup.strength + bringup.changes_strength
			bringup.agility = bringup.agility + bringup.changes_agility
			bringup.intelligence = bringup.intelligence + bringup.changes_intelligence
		end

		bringup.changes_agility = 0
		bringup.changes_intelligence = 0
		bringup.changes_strength = 0
		

		--更新数据库
		local where_fields={{C.kfPlayer,player.GetUID()},{C.kfID,id}}
		local br = new('BringupBin',bringup.strength,bringup.agility,bringup.intelligence,0,0,0)
		player.UpdateBinaryStringField(C.ktHero, #where_fields, where_fields, C.kfBringupBin, sizeof(br), br)

		fight_power.CheckFightPowerChange(player.GetUID())
		return C.eSucceeded
	end

	function obj.GetProperty()
		local property = data.GetProperty( hero_cfgs[id], bringup, level, id, player.GetHeroEquipments(id), player.GetRunesProperty(id), GetGradeLevel(player.GetUID()))
		return property
	end

	function obj.ChangeHeroID(new_id)
		id = new_id
	end
	
    return obj

end

return CreateHero
