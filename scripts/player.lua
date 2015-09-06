--玩家单人的所有逻辑

require('town')
require('data')
require('global_data')
require('prop')
require('heros_manager')
require('guild_manager')
require('guild_war_manager')
require('main_line')
require('explore')
require('tools.time')
require('my_ffi')
require('arena_interaction')
require('treasure_interaction')
require('escort')
require('escort_interaction')
require('grade')
require('playground.playground')
require('achievement')
require('world_boss')
require('guild_war')
require('assistant')
require('auction_interaction')
require('raiders')
require('fight_power')
require('territory_interaction')
require('config.town_cfg')
require('tree')
require('tower')
require('reward_for_days_ago')
require('save_website')
require('lucky_draw')
require('check_in_every_day')
require('check_in_accumulate')
local config = require('config.global')
local lv_exp_map = require('config.lord_level_exp')
local vip_gold = require('config.vip')
local actions = require('define.action_id')
local buy_resource_cost = require('config.buy_resource_cost')
local buy_resource_count = require('config.buy_resource_count')
local alchemy_reward = require('config.alchemy_reward')
local alchemy_count = require('config.alchemy_count')
local alchemy_cost = require('config.alchemy_cost')
local science_cfg = require('config.science')
local science_map = require('config.science_map')
local actives = require('define.actives')
local assistant_id = require('config.assistant_task_id')
local rune_count = require('config.rune_count')
local gold_consume_flag = require('define.gold_consume_flag')
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local kMaxEnergy = config.kMaxEnergy
local kMaxMobility = config.kMaxMobility
local country_count = data.GetCountryCount()


--tools
local function Random(probability)
	return math.random() < probability
end

local science_array_ = {}
for id,skill in pairs(science_cfg) do
    if science_map[id].type==3 then
        science_array_[id] = skill[1].gain.array
    end
end

function CreatePlayer(uid, play_base_info)

	local this = {}
	local base_info_ = nil
	local role_ = nil
	local play_base_info_ = nil
	local status_ = nil
	local vip_count_ = nil
	local skills_level_ = {}
	local uid_ = uid
	local fixed_flag_head_ = new('MqHead', uid_, 0, -1)
	local processors_ = {}
	local db_processors_ = {}
	local gm_processors_ = {}
	local town_ = nil
	local prop_ = nil
	local hero_mng_ = nil
	local main_line_ = nil --主线
	local explore_ = nil --支线
	local arena_ = nil --竞技场
	local treasure_ = nil
	local guild_mng_ = nil
	local guild_war_mng_ = nil
	local grade_ = nil
	local escort_ = nil
	local playground_ = nil
	local world_boss_ = nil
	local achievement_ = nil
	local world_war_ = nil
	local assistant_ = nil
	local auction_ = nil
	local territory_ = nil
	local tree_ = nil
	local tower_ = nil
	local reward_for_days_ago_ = nil
	local save_website_ = nil
	local lucky_draw_ = nil
	local check_in_every_day_ = nil
	local check_in_accumulate_ = nil
	local accepted_player_msg_ = false

	local client_setting_len_ = 0
	local client_setting_ = new("uint8_t [256]")
	
	local recommend_country_ = 0

	local actived_functions_ = {}

	local function SetPlayerInfo(player_info)
		play_base_info_ = new('PlayerBaseInfo')
		copy(play_base_info_, player_info, sizeof(play_base_info_))
		base_info_ = play_base_info_.game_info
		role_ = play_base_info_.role
	end

	SetPlayerInfo(play_base_info)

	local function Send2Db(msg, len)
		fixed_flag_head_.type = msg.kType
		C.Send2Db(fixed_flag_head_, msg, len or sizeof(msg))
	end

	function this.Send2Gate(msg, len)
		fixed_flag_head_.type = msg.kType
		C.Send2Gate(fixed_flag_head_, msg, len or sizeof(msg))
	end

	local function Send2WorldWar(type, flag, msg, len)
        local flag_head = new('MqHead', uid_, type, flag)
		C.Send2WorldWar(flag_head, msg, len)
	end
	
	local function Send2Interact(msg)
		fixed_flag_head_.type = msg.kType
		C.Send2Interact(fixed_flag_head_, msg, sizeof(msg))
	end

	function this.GetUID() return uid_ end

	function this.GetSkills() return skills_level_ end

	function this.GetCityHallLevel() return town_.GetCityHallLevel() or 1 end  --市政厅等级
	function this.GetLevel() return base_info_.level end --领主等级
	
	function this.GetVIPLevel()
        for level,need in ipairs(vip_gold) do
            if base_info_.recharged_gold<need.gold then
                return level - 1
            end
        end

        return 12
    end

    function this.GetVIPCount(type)
        --插入新数据
        if not vip_count_ then
            vip_count_ = {0, 0, 0, 0}

            this.InsertRow(C.ktVIPCount, {C.kfEnergy, 0})
        end

        if type then return vip_count_[type] end
        return vip_count_
    end

    function this.AddVIPCount(type, delta)
        local kType = {C.kfEnergy, C.kfMobility, C.kfAlchemy, C.kfRune}

        delta = delta or 1
        if kType[type] then
            vip_count_[type] = vip_count_[type] + delta
            UpdateDeltaField(C.ktVIPCount, C.kfPlayer, uid, kType[type], delta)
        else
            print("wrong vipcount type",type)
        end
    end

    function this.ResetVIPCount() vip_count_ = {0, 0, 0, 0} end
    
    function this.ResetTower() tower_.Reset() end
    
    function this.ResetGradeReward() grade_.ResetGradeReward() end
    
    function this.SetGradeLevel(level) grade_.SetGradeLevel(level) end

	function this.GetRechargedGold() return base_info_.recharged_gold end

	function this.GetPrestige() return base_info_.prestige end

	function this.GetArenaRank() return arena_.get_rank() end
	
	function this.AppendArenaHistory(player_id, initiative, winner, rank, war_id, time) arena_.AppendArenaHistory(player_id, initiative, winner, rank, war_id, time) end

	function this.GetCountry() return base_info_.country end

	function this.GetName() return ffi.string(role_.nickname.str, role_.nickname.len) end
	
	function this.GetCNickname() return role_.nickname end

	function this.GetSex() return role_.sex end

	function this.GetBaseInfo() return base_info_ end

	function this.GetStatus() return status_ end

	function this.GetPlayerBaseInfo() return play_base_info_ end

	function this.GetGuildId() return base_info_.guild_id end

	function this.InTheWorldWar() return world_war_ end

	function this.GetProps() return prop_.GetProps() end

	function this.MoveProps(id) return prop_.MoveProps(id) end
	
	function this.UseProps(id, amount) return prop_.UseProps(id, amount) end
	
	function this.AddProps() return prop_.AddProps() end

	function this.AddAttach(id, kind, amount) return prop_.AddAttach(id, kind, amount) end

	function this.SetGuildId(guild_id)
		base_info_.guild_id =  guild_id
	end

	function this.GetCurrentTask() return main_line_.GetTaskStatus() end

	function this.GetLastCompleteTask() return main_line_.GetLastCompleteTask() end

	function this.GetRunesProperty(hero_id) return treasure_.GetRunesProperty(hero_id)  end

	function this.GetHeroEquipments(hero_id) return prop_.GetHeroEquipments(hero_id) end
    
    function this.GetSilver() return base_info_.silver end

	function this.InsertRow(tbl, ...)
		local fields = {...}
		Send2Db( new('InsertRow', tbl, table.getn(fields), fields) )
	end

	function this.InsertRow2(tbl, ...)
		local fields = {...}
		Send2Db( new('InsertRow2', tbl, table.getn(fields), fields) )
	end

	function this.UpdateField(tbl, id, ...)
		local fields = {...}
		local update_field_ = new('UpdateField', id, tbl, table.getn(fields), fields)
		Send2Db(update_field_)
	end

	function this.UpdateField2(tbl, index_filed, id, sub_index_filed, subid, ...)
		local fields = {...}
		local update_field2_ = new('UpdateField2', id, subid, tbl, index_filed, sub_index_filed, table.getn(fields), fields)
		Send2Db(update_field2_)
	end

	function this.UpdateOtherField(tbl, id, ...)
		this.UpdateField2(tbl, C.kfPlayer, id, 0, C.kInvalidID, ...)
	end

	function this.UpdateStringField(tbl, id, filed, str, len)
		local update = new('UpdateStringField', id, tbl, filed, len)
		assert(len<=sizeof(update.str))
		copy(update.str, str, len)
		Send2Db(update)
	end

	function this.UpdateStringField2(tbl, where_len, where_fields, set_filed, set_val_len, set_val_str)
		local update = new('UpdateStringField2', tbl, where_len, where_fields, set_filed, set_val_len)
		assert(set_val_len<=sizeof(update.set_val_str))
		copy(update.set_val_str, set_val_str, set_val_len)
		Send2Db(update)
	end

	function this.UpdateBinaryStringField(tbl, where_len, where_fields, set_filed, set_val_len, set_val_str)
		local update = new('UpdateBinaryStringField', tbl, where_len, where_fields, set_filed, set_val_len)
		assert(set_val_len<=sizeof(update.set_val_str))
		copy(update.set_val_str, set_val_str, set_val_len)
		Send2Db(update)
	end

	function this.InsertIconBin(guild_id, icon_bin_len, icon_bin)
		local replace = new('ReplaceIconBin', guild_id, icon_bin_len)
		copy(replace.icon_bin, icon_bin, icon_bin_len)
		Send2Db(replace)
	end

    function this.InserGuildApplication(guild_id,player_id,time,player_name,player_level)
        local replace = new('GuildApplication', guild_id,player_id,time,player_name,player_level)
		Send2Db(replace)
    end

	function this.UpdateFieldWithSubIndex(tbl, index_filed, index, sub_index_filed, sub_index, ...)
		local fields = {...}
		local update_field_with_subindex_ = new('UpdateFieldWithSubIndex', index, sub_index, tbl, index_filed, sub_index_filed, table.getn(fields), fields)
		Send2Db(update_field_with_subindex_)
	end

	function this.DeleteRow(table, id)
		local delete_row_ = new('DeleteRow', table, id)
		Send2Db(delete_row_)
	end
	
	function this.ExcuteSqlDirectly(sql)
		local exe_sql = new('ExcuteSqlDirectly',#sql, sql)
		Send2Db(exe_sql, 2 + #sql)
	end

	function this.IsGoldEnough(amount)
		return base_info_.gold >= amount
	end

	function this.ModifyGold(delta, ignore_achievement)
		assert(base_info_.gold + delta>=0)
		assert(assert~=0)
		base_info_.gold = base_info_.gold + delta
		this.UpdateField( C.ktBaseInfo, -1,  {C.kfGold, base_info_.gold} )
		local rscDelta = new('ResourceDelta', base_info_.gold, delta, C.kGoldRsc)
		this.Send2Gate(rscDelta)
        if delta<0 then
            this.RecordAction(actions.kGoldCost, -delta)
        elseif not ignore_achievement then
            this.RecordAction(actions.kGoldGot, delta)
        end
	end

	function this.AddGold(amount)
		assert(amount>=0)
		this.ModifyGold(amount)
	end
	
	function this.ConsumeGold(amount, flag) --flag define/gold_consume_flag.lua中定义
		assert(amount>=0)
		if amount==0 then return end
		this.ModifyGold(-amount)
		if flag then this.InsertRow(C.ktConsumeRecord, {C.kfID, flag}, {C.kfAmount, amount}, {C.kfTime, os.time()}) end
	end

    function this.OnVipLevelChanged()
        --向国战服务器推送等级改变
        if this.InTheWorldWar() then
            PushPlayerChangedToWorldWar(this.GetUID(), 1, this.GetVIPLevel())
        end
        
        this.AssistantSetRemainTimes(assistant_id.kEnergy, buy_resource_cost[this.GetVIPCount(1) + 1].cost - this.GetVIPCount(1))
        this.AssistantSetRemainTimes(assistant_id.kMobility, buy_resource_cost[this.GetVIPCount(2) + 1].cost - this.GetVIPCount(2))
        this.AssistantSetRemainTimes(assistant_id.kAlchemy, alchemy_count[this.GetVIPLevel()].count - this.GetVIPCount(3))
    end

    function this.AddRechargedGold(delta)
        assert(delta>0)
        local old_vip = this.GetVIPLevel()
        base_info_.recharged_gold = base_info_.recharged_gold + delta
        this.UpdateField( C.ktBaseInfo, -1,  {C.kfRechargedGold, base_info_.recharged_gold} )
        
        --VIP等级发生变化
        if this.GetVIPLevel()~=old_vip then this.OnVipLevelChanged() end
        
        local rscDelta = new('ResourceDelta', base_info_.recharged_gold, delta, C.kRechargedGold)
        this.Send2Gate(rscDelta)
        
        this.ModifyGold(delta, true)
    end
	
    function this.AddLordExp(delta)
        assert(delta>=0)
        if delta<=0 then return end
        local old_lord_experience = base_info_.lord_experience
        local old_exp = base_info_.level
        if lv_exp_map[base_info_.level] then
            local exp_for_next_level = lv_exp_map[base_info_.level].exp
            base_info_.lord_experience = base_info_.lord_experience + delta
            if base_info_.lord_experience >= exp_for_next_level then
                if base_info_.lord_experience >= exp_for_next_level then
                    while base_info_.lord_experience > 0 do
                        --升一级
                        if base_info_.lord_experience >= exp_for_next_level then
                            base_info_.lord_experience = base_info_.lord_experience - exp_for_next_level
                        else
                            break    
                        end    
                        
                        base_info_.level = base_info_.level + 1
                        --添加到成就
                        this.RecordAction(actions.kLordLevel,base_info_.level)
                        if base_info_.level <= config.kMaxLordLevel then
                            exp_for_next_level = lv_exp_map[base_info_.level].exp
                        else
                            base_info_.lord_experience = 0 
                            base_info_.level = config.kMaxLordLevel
                            
                            --计算好delta供前端使用
                            delta = 0
                            for i = old_exp,config.kMaxLordLevel-1 do
                                delta = lv_exp_map[i].exp + delta
                            end
                            delta = (delta - old_lord_experience )<=0 and 0 or (delta - old_lord_experience )                             
                        end    
                    end
                    this.UpdateField(C.ktBaseInfo, -1, {C.kfLevel, base_info_.level})
                    main_line_.OnLordLevelUp(base_info_.level)
                    tree_.OnLordLevelup()
                    local notify = new('NotifyPlayerInfoChange',C.kLevelChange,uid_,base_info_.level)
                    Send2Interact(notify)
                    --向国战服务器推送等级改变
                    if this.InTheWorldWar() then
                        PushPlayerChangedToWorldWar(this.GetUID(), 2, base_info_.level)
                    end
                end
            end
            this.UpdateField(C.ktBaseInfo, -1, {C.kfExp, base_info_.lord_experience})
            local rscDelta = new('ResourceDelta', base_info_.lord_experience, delta, C.kLordExpRsc)
            this.Send2Gate(rscDelta)
        end
    end

	function this.IsPrestigeEnough(amount)
		return base_info_.prestige >= amount
	end
	
	function this.ModifyPrestige(delta)
        assert(delta>=0)
        assert(base_info_.prestige + delta >= 0)
		base_info_.prestige = base_info_.prestige + delta
		this.UpdateField( C.ktBaseInfo, -1,  {C.kfPrestige, base_info_.prestige} )
		local rscDelta = new('ResourceDelta', base_info_.prestige, delta, C.kPrestigeRsc)
		this.Send2Gate(rscDelta)
		if base_info_.guild_id~=0 then	--有公会
			guild.AddGuildExp(base_info_.guild_id,uid,delta)
		end
	end

	function this.IsSilverEnough(amount)
		return base_info_.silver >= amount
	end

	function this.ModifySilver(delta, special)
	    --限制玩家银币多少
        if delta > 0 then
            local top_silver = town_.BankTopSilver()
            if top_silver <= base_info_.silver then
                delta = 0
            elseif top_silver <= (base_info_.silver + delta) then
                delta = top_silver - base_info_.silver
            end
        end
		assert(base_info_.silver + delta >= 0)
		base_info_.silver = base_info_.silver + delta
		this.UpdateField( C.ktBaseInfo, -1,  {C.kfSilver, base_info_.silver} )
		local rscDelta = new('ResourceDelta', base_info_.silver, delta, C.kSilverRsc)
		this.Send2Gate(rscDelta)
		if not special then
			if delta<0 then this.RecordAction(actions.kSilverCost, -delta)
			elseif delta>0 then this.RecordAction(actions.kSilverGot, delta) end
		end
	end
	
	function this.GMModifySilver(delta)
        assert(base_info_.silver + delta >= 0)
		base_info_.silver = base_info_.silver + delta
		this.UpdateField( C.ktBaseInfo, -1,  {C.kfSilver, base_info_.silver} )
		local rscDelta = new('ResourceDelta', base_info_.silver, delta, C.kSilverRsc)
		this.Send2Gate(rscDelta)
		if delta<0 then this.RecordAction(actions.kSilverCost, -delta)
		elseif delta>0 then this.RecordAction(actions.kSilverGot, delta) end
	end

	function this.IsEnergyEnough(amount)
		return base_info_.energy >= amount
	end

	function this.ModifyEnergy(delta)
		assert(base_info_.energy + delta >= 0)
		base_info_.energy = base_info_.energy + delta
		this.UpdateField( C.ktBaseInfo, -1,  {C.kfEnergy, base_info_.energy} )
		local rscDelta = new('ResourceDelta', base_info_.energy, delta, C.kEnergyRsc)
		this.Send2Gate(rscDelta)
	end
    
    --科技激活
	function this.ActivateSkill(id)
		if not skills_level_[id] then
			skills_level_[id] = 1
			this.InsertRow(C.ktSkill, {C.kfID, id}, {C.kfLevel, 1})
			
			this.RecordAction(actions.kArrayLevel, skills_level_[id], id)
            
            fight_power.CheckFightPowerChange(this.GetUID())
		end
	end

	--培养开关
	local can_open_BringUp = false
	function this.BringUp_open()
        can_open_BringUp = true
	end
	
	function this.CanBringUp()
		return can_open_BringUp
	end
	
	--炼金开关
	local can_open_Alchemy = false
	function this.Alchemy_open()
        can_open_Alchemy = true
	end
	
	function this.CanAlchemy()
		return can_open_Alchemy
	end
	
	
	--国战开关
	local can_open_WorldWar = false
	function this.WorldWar_open()
        can_open_WorldWar = true
	end
	
	function this.CanWorldWar()
		return can_open_WorldWar
	end
	
	
	function this.ActivateSubSystem(id)
        if id==actives.kSubSystemEscort then
            escort_.open()
        elseif id==actives.kSubSystemTerritory then
            territory_.open()
        elseif id==actives.kSubSystemBringUp then
            this.BringUp_open()
        elseif id==actives.kSubSystemAlchemy then
            this.Alchemy_open()
        elseif id==actives.kSubSystemWorldBoss then
            world_boss_.open()
        elseif id==actives.kSubSystemTower then
            tower_.open()
        elseif id==actives.kSubSystemGrade then
            grade_.open()
        elseif id==actives.kSubSystemArena then
            arena_.open()
        elseif id==actives.kSubSystemRune then
            treasure_.open()
        elseif id==actives.kSubSystemWorldWar then
			this.WorldWar_open()
        elseif id==actives.kSubSystemAuction then
            auction_.open()
		elseif id==actives.kSubSystemBigTown then
			town_.Expand2BigTown()
		elseif id==actives.kSubSystemTrain then
--			hero_mng_.OpenTrain()
		elseif id==actives.kSubSystemFish then
			playground_.ActivateFish()
		elseif id==actives.kSubSystemRearDragon then
			playground_.ActivateRearDragon()
		elseif id==actives.kSubSystemTurntable then
			playground_.ActivateTurntable()
		elseif id==actives.kSubSystemStrengthen then
			prop_.ActiveFunction(1)
		elseif id==actives.kSubSystemInlay then
			prop_.ActiveFunction(2)
		elseif id==actives.kSubSystemCompoundGem then
			prop_.ActiveFunction(3)
		elseif id==actives.kSubSystemPropMigrate then
			prop_.ActiveFunction(4)
		elseif id==actives.kSubSystemExplore then
			explore_.ActiveExplore()
		elseif id==actives.kSubSystemTree then
			tree_.ActivateTree()
        end
	end

	function this.GetHeroLevel(id)
		return hero_mng_.GetHeroLevel(id)
	end

	function this.AddHeroExp(delta)
		assert(delta>=0)
		if delta<=0 then return end
		hero_mng_.AddInGroupHerosExp(delta)
	end

	function this.IsMobilityEnough(amount)
		return base_info_.mobility>=amount
	end

	function this.ModifyMobility(delta)
--		if base_info_.mobility+delta >400 then return end
		if base_info_.mobility + delta<0 then  
			print(string.format('mobility:%d,delta:%d', base_info_.mobility, delta))
		end
		assert(base_info_.mobility + delta >= 0)
		base_info_.mobility = base_info_.mobility + delta
		this.UpdateField( C.ktBaseInfo, -1, {C.kfMobility, base_info_.mobility} )
		local rscDelta = new('ResourceDelta', base_info_.mobility, delta, C.kMobilityRsc)
		this.Send2Gate(rscDelta)
	end

	function this.IsFeatEnough(amount)
		return base_info_.feat >= amount
	end

	function this.ModifyFeat(delta)
		base_info_.feat = base_info_.feat + delta
		this.UpdateField( C.ktBaseInfo, C.kInvalidID, {C.kfFeat, base_info_.feat} )
		local rscDelta = new('ResourceDelta', base_info_.feat, delta, C.kFeatRsc)
		this.Send2Gate(rscDelta)
	end

	function this.IsResourceEnough(type, amount)
		if type==C.kGoldRsc then
			return this.IsGoldEnough(amount)
		elseif type==C.kSilverRsc then
			return this.IsSilverEnough(amount)
		elseif type==C.kEnergyRsc then
			return this.IsEnergyEnough(amount)
		elseif type==C.kFeatRsc then
			return this.IsFeatEnough(amount)
		else 
			assert(false)
		end
		return false
	end

	function this.AddReward(rwd)
		assert(rwd.amount>=0)
		if rwd.type==C.kGoldRsc then
			this.AddGold(rwd.amount)
		elseif rwd.type==C.kSilverRsc then
			this.ModifySilver(rwd.amount)
		elseif rwd.type==C.kEnergyRsc then
			this.ModifyEnergy(rwd.amount)
		elseif rwd.type==C.kPropRsc then
			this.ModifyProp(rwd.kind, rwd.amount)
		elseif rwd.type==C.kFeatRsc then
			this.ModifyFeat(rwd.amount)
		elseif rwd.type==C.kPrestigeRsc then
			this.ModifyPrestige(rwd.amount)
		elseif rwd.type==C.kLordExpRsc then
			this.AddLordExp(rwd.amount)
		elseif rwd.type==C.kMobilityRsc then
			this.ModifyMobility(rwd.amount)
		elseif rwd.type==C.kTrainTimes then
			this.ModifyTrainNum(rwd.amount)
		elseif rwd.type==C.kArenaTimes then
			arena_.ModifyCount(rwd.amount)
		elseif rwd.type==C.kFishTimes then
			playground_.ModifyFishTimes(rwd.amount)
		elseif rwd.type==C.kLuckyTimes then
			playground_.ModifyTurnTimes(rwd.amount)
		elseif rwd.type==C.kTreewaterTimes then
			tree_.ModifyWaterCount(rwd.amount)
		elseif rwd.type==C.kCooldownReset then
			this.CooldownReset()
		else 
			assert(false)
		end
	end

	function this.DealRewards(expired_rewards)
--		assert( table.getn(expired_rewards)<=5 )
		if expired_rewards then
			local rewards = {}
			for i,val in ipairs(expired_rewards) do
				if Random(val.probability) then
					local rwd = new( 'Reward', val.type, val.kind or 0, math.random(val.min, val.max) )
					table.insert(rewards, rwd)
					this.AddReward(rwd)
				end
			end
			return rewards
		end
	end

	function this.ReplenishStatus()
		if not base_info_ then return end
		if base_info_.energy<kMaxEnergy then
			this.ModifyEnergy(1)
		end
		if base_info_.mobility<kMaxMobility then
			this.ModifyMobility(1)
		end
	end

--英雄相关
	function this.GetHerosGroup()
		return hero_mng_.GetHerosGroup()
	end

	function this.GetHero(id)
		return hero_mng_.GetHero(id)
	end

	function this.GetHeroLevel( id )
		return hero_mng_.GetHeroLevel( id )
	end

	function this.GetArmySimpleInfo()
		return hero_mng_.GetArmySimpleInfo()
	end

	function this.GetAvailableCountryHeros()
		local heros = {}
		local available_heros = grade_.get_heros_status()
		if available_heros then
			for id,available in pairs(available_heros) do
				if available then table.insert(heros, id) end
			end
		end
		return heros
	end

	function this.IsCountryHeroAvailable(hero_id)
		return grade_.get_hero_status(hero_id)==1
	end

	function this.GetHeroCount()
		return hero_mng_.GetHeroCount()
	end
	
	function this.GetBrachTaskActivatedHeros()
		return explore_.GetActivedHeros()
	end

    function this.UpdateTrainNum()
        hero_mng_.UpdateTrainNum()
    end
    
    function this.ResetBuyTrainNum()
        hero_mng_.ResetBuyTrainNum()
    end
    
    --改变英雄ID
    function this.ChangeHeroID(hero_id, new_id)
        treasure_.ChangeHeroID(hero_id, new_id)
        prop_.TransferEquipment2Hero(hero_id, new_id)
    end
    
--城镇建筑物相关
	function this.BuildingLevelup(building_kind, level)
		if building_kind==config.town.kDragonHouseKind then
			playground_.SetRearroomLevel(level)
		end
		main_line_.OnBuildingLevelUp(building_kind, level)
	end

	function this.GetTrainingGroundLevel()
		return town_.GetTrainingGroundLevel() 
	end

	function this.GetSmithyLevel()
		return town_.GetSmithyLevel() or 0
	end

	function this.GetSkillMuseumLevel()
		return town_.GetSkillMuseumLevel() or 0
	end

	function this.HasFunctionBuilding(kind)
		return town_.HasFunctionBuilding(kind)
	end

	function this.GetBuildingLevel(kind)
		return town_.GetBuildingLevel(kind) or 0
	end

	function this.ActiveBuilding(kind)
		return town_.ActiveBuilding(kind)
	end

	function this.AddBuilding(kind) --添加一个建筑
		town_.AddBuilding(kind)
	end

	function this.FunctionBuildingsLevel()
		return town_.FunctionBuildingsLevel()
	end
	
	function this.GetBrachTaskActivatedBuilidings()
		return explore_.GetActivedBuilding()
	end
	
-- 道具
	function this.PropsTraceBegin()
		return prop_.PropsTraceBegin()	--这里的返回值,直接传给PropsTraceEnd
	end
	
	function this.PropsTraceEnd( trace )
		prop_.PropsTraceEnd( trace )
	end
	
	function this.HasPropInBag()
		return prop_.HasPropInBag()
	end

	function this.GetEquipmentStrengthenTimes()
		return prop_.GetEquipmentStrengthenTimes()
	end

	function this.GetEquipment(id)
		return prop_.GetEquipment4Client(id)
	end
	
	function this.IsPropEnough(kind, amount)
		return prop_.IsEnough(kind, amount)
	end

	function this.HavePropAmount( kind )
		return prop_.HavePropAmount( kind )
	end

	function this.ModifyProp(kind, delta)
		return prop_.ModifyAmount(kind, delta)
	end

	function this.IsBagFull()
		return prop_.IsBagFull()
	end
	
	function this.GetBagSpace()
		return prop_.GetBagSpace()
	end

	--包包未被占用的空格子
	function this.BagUnoccupied()
		return prop_.BagUnoccupied()
	end
	
	function this.ModifyPropById(id, amount)
		return prop_.ModifyPropById(id, amount)
	end
	
	function this.AddNewProps2Area4Kind(area, kind, amount)
		return prop_.AddNewProps2Area4Kind(area, kind, amount)
	end
	
	function this.AddNewProps2Area4Kinds(area, props)
		return prop_.AddNewProps2Area4Kinds(area, props)
	end
	
	function this.AddNewEquip2Area(area, kind, location, level, strength, agility, intelligence, hero_id)
		return prop_.AddNewEquip2Area(area, kind, location, level, strength, agility, intelligence, hero_id)
	end

--游乐场
	function this.IsPlaygroundPropEnough( prop_kind, amount )
		return playground_.IsPlaygroundPropEnough( prop_kind, amount )
	end

	function this.ModifyPlaygroundProp( prop_kind, amount )
		return playground_.ModifyPlaygroundProp( prop_kind, amount )
	end
	
	function this.ResetPlayground( subsystem )
		return playground_.ResetPlayground( subsystem )
	end
	
	function this.SetPlaygroundInfo( tbl_data )
		return playground_.SetPlaygroundInfo( tbl_data )
	end

--成就
	function this.RecordAction(action_id, amount, para) --para非必须
		achievement_.Record(action_id, amount, para)
	end

--助手
	function this.ResetAssistant()
		return assistant_.ResetAssistant()
	end

	function this.AssistantCompleteTask( task_id, remain_times )		--完成某任务
		return assistant_.CompleteTask( task_id, remain_times )
	end
	
	function this.AssistantActivityTask( task_id )		--激活任务
		return assistant_.ActivityTask( task_id )
	end
	
	function this.AssistantSetRemainTimes( task_id, remain_times )	--设置剩余次数,比如竞技场本来没有挑战次数了,玩家再次购买了次数
		return assistant_.SetRemainTimes( task_id, remain_times )
	end
	
-- 主线
	function this.ResetBossSection()
		return main_line_.ResetBossSection()
	end
	
	function this.IsTrunkTaskFinished(id)
		return main_line_.IsTaskFinished(id)
	end
	
	function this.IsSectionPassed(index)
		return main_line_.IsSectionPassed(index)
	end
	
-- 支线
	function this.ResetStamina()
		return explore_.ResetStamina()
	end
	
	function this.ReplenishStamina()
		return explore_.ReplenishStamina()
	end
	
	function this.IsBranchTaskFinished(task_id)
		return explore_.IsBranchTaskFinished(task_id)
	end
--幸运树
	function this.ResetTree()
		return tree_.ResetTree()
	end
	
	function this.ResetRewardForDaysAgo()
		return reward_for_days_ago_.Reset()
	end
	
	function this.ResetLuckyDraw()
		return lucky_draw_.Reset()
	end
---------------------------	processors

	processors_[C.kSelectCountry] = function(msg)
		local country = cast("const SelectCountry&", msg).country
		local result = new("SelectCountryResult", C.eInvalidOperation)
		if base_info_.country<=0 and country>=1 and country<=3 then
			base_info_.country=country
			result.result = C.eSucceeded
			this.UpdateField(C.ktBaseInfo, C.kInvalidID, {C.kfCountry,country})
			country_count[country] = country_count[country] + 1
			if country==recommend_country_ then --推荐国家奖励
				prop_.ModifyAmount(config.kCountrySelectReward, 1)
			end
		end
		return result
	end

    processors_[C.kBuyGameResource] = function(msg)
        local type = cast("const BuyGameResource&", msg).type
        local result = new('BuyGameResourceResult', C.eInvalidOperation)
        if type==C.kEnergyRsc then
            --购买能量
            
            --是否超过上限
            if base_info_.energy<kMaxEnergy then
            
                --检查是否还有购买次数
                local can_buy_count = buy_resource_count[this.GetVIPLevel()].count
                if can_buy_count>this.GetVIPCount(1) then
                    --检查金币是否足够
                    local cost = buy_resource_cost[this.GetVIPCount(1) + 1].cost
                    if this.IsGoldEnough(cost) then

                        this.ModifyEnergy(config.kAddEnergy)
                        this.ConsumeGold(cost, gold_consume_flag.energy)

                        this.AddVIPCount(1)

                        result.result = C.eSucceeded
                        result.count = can_buy_count - this.GetVIPCount(1)
                        result.use_count = this.GetVIPCount(1)

                        this.AssistantCompleteTask(assistant_id.kEnergy, result.count)
                    end
                end
            end
        elseif type==C.kMobilityRsc then
            --购买行动力
            
            --是否超过上限
            if base_info_.mobility<kMaxMobility then

                --检查是否还有购买次数
                local can_buy_count = buy_resource_count[this.GetVIPLevel()].count
                if can_buy_count>this.GetVIPCount(2) then
                    --检查金币是否足够
                    local cost = buy_resource_cost[this.GetVIPCount(2) + 1].cost
                    if this.IsGoldEnough(cost) then

                        this.ModifyMobility(config.kAddMobility)
                        this.ConsumeGold(cost, gold_consume_flag.mobility)

                        this.AddVIPCount(2)

                        result.result = C.eSucceeded
                        result.count = can_buy_count - this.GetVIPCount(2)
                        result.use_count = this.GetVIPCount(2)

                        this.AssistantCompleteTask(assistant_id.kMobility, result.count)
                    end
                end
            end
        elseif type==C.kAlchemyRsc then
            --使用炼金术
			
            --检查是否还有购买次数
            local can_buy_count = alchemy_count[this.GetVIPLevel()].count
            if this.CanAlchemy() and can_buy_count>this.GetVIPCount(3) then

                --检查金币是否足够
                local cost = alchemy_cost[this.GetVIPCount(3) + 1].cost
                if this.IsGoldEnough(cost) then

                    this.ModifySilver( alchemy_reward[this.GetLevel()].silver )
                    this.ConsumeGold(cost, gold_consume_flag.alchemy)

                    this.AddVIPCount(3)

                    result.result = C.eSucceeded
                    result.count = can_buy_count - this.GetVIPCount(3)
                    result.use_count = this.GetVIPCount(3)

                    this.AssistantCompleteTask(assistant_id.kAlchemy, result.count)
                end
            end
        end
        return result
    end

	processors_[C.kBuyEquip2Hero] = function(msg)
		local buy = cast('const BuyEquip2Hero&',msg)
		local result = new('BuyEquip2HeroResult',C.eInvalidOperation, 0)
		local res = prop_.BuyProp2Location(buy, true)
		if res.result==C.eSucceeded then
			res = hero_mng_.Equip(buy.hero_id, buy.location, res.prop_kind)
			if res.result==C.eSucceeded then
				if res.take_off.amount==0 then
					res = prop_.BuyProp2Location(buy)
					result.result = res.result
					if result.result==C.eSucceeded then
						result.id = res.prop_id
					end
				else
					result.result = C.eOccupy
				end
			else
			end
		end
		return result
	end
	
	processors_[C.kEquipHero] = function(msg)
		local result = new('EquipHeroResult', C.eInvalidValue)
		local euip_hero = cast('const EquipHero&', msg)
		local prop,equip = prop_.GetEquipment(euip_hero.prop)
		--print('id='..euip_hero.prop..',kind='..prop.kind..',tar_location='..euip_hero.location)
		if prop and equip and prop.area==C.kAreaBag then
			local res = hero_mng_.Equip(euip_hero.hero, euip_hero.location, prop.kind)
			result.result = res.result
			if result.result==C.eSucceeded then
				result.result = prop_.Move2Hero(euip_hero, res.take_off)
			end
		end
		return result
	end

	processors_[C.kTakeOff] =function(msg)
		local result = new('TakeOffResult', C.eInvalidValue)
		local take_off = cast('const TakeOff&', msg)
		result.result,location = prop_.MoveFromHero(take_off)
		return result
	end

	processors_[C.kGetPlayerBaseInfo] = function()
		base_info_.array = hero_mng_.array()
		base_info_.vip = this.GetVIPLevel()
		base_info_.progress = main_line_.GetMaxAailableSection()
		base_info_.power = fight_power.GetCachedPower(this.GetUID())
		return new('PlayerBaseInfo', {role_, base_info_} )
	end

	processors_[C.kGetTaskStatus] = function()
		local trunk_task, sub_trunk_task, trunk_task_progress = main_line_.GetTaskStatus()
		local branch_task, sub_branch_task, branch_task_progress = explore_.GetTaskStatus()
		return new("TaskStatus", trunk_task or 0, branch_task or 0, sub_trunk_task, trunk_task_progress, sub_branch_task, branch_task_progress)
	end

    processors_[C.kGetSystemConfig] = function()
        local result = new('GetConfigResult')
        copy(result.str, client_setting_, client_setting_len_)
        return result, client_setting_len_
    end

    processors_[C.kSetSystemConfig] = function(msg, len)
        local SetConfig = cast('const SetConfig&', msg)
        client_setting_len_ = math.min(256, len)
        copy(client_setting_, SetConfig.str, client_setting_len_)

        local where_fields={{C.kfPlayer,this.GetUID()}}
        this.UpdateBinaryStringField(C.ktSettings, #where_fields, where_fields, C.kfSetting, client_setting_len_, client_setting_)
        
        return new('SetConfigResult')
    end

	processors_[C.kGetActivedFunctions] = function()
		local result = new('ActivedFunctions', 0)
		for _,id in ipairs(actived_functions_) do
			result.functions[result.count] = id
			result.count = result.count+1
		end
		return result
	end

    processors_[C.kGetRecommendCountry] = function()
        local result = new('RecommendCountry', 1)
        local min = math.min(country_count[1], country_count[2], country_count[3])
        for i,v in ipairs(country_count) do
            if v==min then
                result.country = i
                break
            end
        end
		recommend_country_ = result.country
        return result
    end

    processors_[C.kGetSkillsLevel] = function()
        result = new('SkillsLevel', 0)
        result.count = 0
        for id,level in pairs(skills_level_) do
            result.values[result.count] = {id, level}
            result.count = result.count + 1
        end

        return result, 2 + result.count * sizeof(result.values[0])
    end

    processors_[C.kGetArraysLevel] = function()
        result = new('ArraysLevel', 0)
        result.count = 0
        for id,level in pairs(skills_level_) do
            if science_array_[id] then
                result.values[result.count] = {science_array_[id], level}
                result.count = result.count + 1
            end
        end

        return result, 2 + result.count * sizeof(result.values[0])
    end

    --科技升级
    processors_[C.kUpgradeSkill] = function(msg)
        local id = cast('const UpgradeSkill&', msg).sid
        local result = new('UpgradeSkillResult', C.eInvalidOperation)
        local current_level = skills_level_[id]
        local cfg = science_cfg[id]
        if current_level and cfg and cfg[current_level+1] then
            local feat = cfg[current_level+1].feat
            if this.GetSkillMuseumLevel() < cfg[current_level+1].level then
                result.result = C.eLowLevel
            elseif not this.IsResourceEnough(C.kFeatRsc, feat) then
                result.result = C.eLackResource
            else
                skills_level_[id] = current_level+1

                this.UpdateField(C.ktSkill, id, {C.kfLevel, skills_level_[id]})
                this.ModifyFeat(-feat)
                result.result = C.eSucceeded

                this.RecordAction(actions.kArrayLevel, skills_level_[id], id)
                
                fight_power.CheckFightPowerChange(this.GetUID())
            end
        end
        return result
    end

    processors_[C.kGetVIPSurplusCount] = function(msg)
        local result = new('VIPSurplusCount')

        result.count[0] = buy_resource_count[this.GetVIPLevel()].count - this.GetVIPCount(1)
        result.count[1] = buy_resource_count[this.GetVIPLevel()].count - this.GetVIPCount(2)
        result.count[2] = alchemy_count[this.GetVIPLevel()].count - this.GetVIPCount(3)
        result.count[3] = rune_count[this.GetVIPLevel()].count - this.GetVIPCount(4)

        result.use_count[0] = this.GetVIPCount(1)
        result.use_count[1] = this.GetVIPCount(2)
        result.use_count[2] = this.GetVIPCount(3)
        result.use_count[3] = this.GetVIPCount(4)

        return result
    end

    processors_[C.kGetRewardStatus] = function(msg)
        local result = new('RewardStatus')

        result.arena = arena_.CanGetReward()
        result.grade = grade_.CanGetReward()

        return result
    end

    processors_[C.kViewFightRecord] = function(msg, len, flag)
        local result = new('QueryFightRecord', cast('const ViewFightRecord&', msg).war_id)

        local flag_head = new('MqHead', uid_, result.kType, flag)
        C.Send2Db(flag_head, result, sizeof(result))
    end

    processors_[C.kGetRaiders] = function(msg, len, flag)
        local GetRaiders = cast('const GetRaiders&', msg)

        local result = new('Raiders')
        result.count, info = raiders.GetRaiders(GetRaiders.type, GetRaiders.id, GetRaiders.sub_id)

        for i =0,result.count-1 do
            local base_info = data.GetPlayerBaseInfo(info[i+1].player)

            result.list[i].nickname = {base_info.role.nickname.len, base_info.role.nickname.str}
            result.list[i].level = info[i+1].level
            result.list[i].war_id = info[i+1].record

            if i>=4 then break end
        end

        return result, 4 + result.count * sizeof(result.list[0])
    end

    --添加从data过来增加威望的数据
    processors_[C.kAddPrestige] = function(msg, len, flag)
        local req = cast('const AddPrestige&', msg)
        this.ModifyPrestige(req.delta)
    end
    
	local function ProcessMsg(type, msg, len, flag)
		local f = processors_[type]
		if f then return f(msg, len, flag) end
	end

	db_processors_[C.kPlayerStatus] = function(msg)
		local status = cast('const PlayerStatus&', msg)
		status_ = new('PlayerStatus')
		copy(status_, status, sizeof(status))

		local span = os.time() - status.last_active_time
		this.UpdateField(C.ktStatus, C.kInvalidID, {C.kfLastActiveTime, os.time()})
		if span<0 then return end


		if base_info_.energy<kMaxEnergy then
			local energy2add = span/(5*60)
			if energy2add>(kMaxEnergy-base_info_.energy) then
				base_info_.energy=kMaxEnergy
			else
				base_info_.energy = base_info_.energy+energy2add
			end
		end

		if base_info_.mobility<kMaxMobility then
			local mob2add = span/(5*60)
			if mob2add>(kMaxEnergy-base_info_.mobility) then
				base_info_.mobility=kMaxMobility
			else
				base_info_.mobility = base_info_.mobility+mob2add
			end
		end

		this.UpdateField(C.ktBaseInfo, C.kInvalidID, {C.kfEnergy, base_info_.energy}, {C.kfMobility, base_info_.mobility})
	end

	db_processors_[C.kClientConfig] = function(msg)
		local ClientConfig = cast('const ClientConfig&', msg)
	    client_setting_len_ = ClientConfig.len
	    copy(client_setting_, ClientConfig.config, client_setting_len_)
	end

	db_processors_[C.kUserEnterSucceeded] = function()
		accepted_player_msg_ = true
		main_line_.OnPlayerEnterSucceeded()
		town_.OnPlayerEnterSucceeded()
		data.PlayerEnter(uid_)
		fight_power.Initialize(uid_)
	end

    db_processors_[C.kSkills] = function(msg)
        local skills = cast('const Skills&', msg)
		for i=0, skills.count-1 do
            skills_level_[skills.skills[i].id] = skills.skills[i].level
		end
    end

    db_processors_[C.kVIPCount] = function(msg)
        local VIPCount = cast('const VIPCount&', msg)
        vip_count_ = {}
        table.insert(vip_count_, VIPCount.energy)
        table.insert(vip_count_, VIPCount.mobility)
        table.insert(vip_count_, VIPCount.alchemy)
        table.insert(vip_count_, VIPCount.rune)
    end

    db_processors_[C.kQueryFightRecordResult] = function(msg)
        local QueryFightRecordResult = cast('const QueryFightRecordResult&', msg)

        local result = new('FightRecord')
        result.fight_record_bytes = QueryFightRecordResult.len
        copy(result.fight_record, QueryFightRecordResult.str, result.fight_record_bytes)

        local flag_head = new('MqHead', uid_, result.kType, QueryFightRecordResult.flag)
        C.Send2Gate(flag_head, result, sizeof(result) - C.kMaxFightRecordLength + result.fight_record_bytes)
    end

	local function ProcessMsgFromDb(type, msg)
		local f = db_processors_[type]
		if f then return f(msg) end
	end

-------------GM
    gm_processors_[C.kModifyPlayerResource] = function(msg)
        local result = {result=C.kGMSucceced}

        local IsResTypeEnough = {gold=this.IsGoldEnough, silver=this.IsSilverEnough, energy=this.IsEnergyEnough, mobility=this.IsMobilityEnough, feat=this.IsFeatEnough, prestige=this.IsPrestigeEnough}
        local ModifyResType = {gold=this.ModifyGold, silver=this.GMModifySilver, energy=this.ModifyEnergy, mobility=this.ModifyMobility, recharged=this.AddRechargedGold, feat=this.ModifyFeat, 
								prestige=this.ModifyPrestige, turntable=playground_.ModifyTurnTimes, godwater=tree_.ModifyWaterCount, staminatake=explore_.ModifyStaminaTake, 
								boss_section_count=main_line_.ModifyBossSectionAvailableTimes, arena=arena_.ModifyCount, world_war=this.ModifyWorldWarCount,train_num = this.ModifyTrainNum}
        
        if IsResTypeEnough[msg.type] then
            if msg.value<0 then
                --判断是否够减
                if IsResTypeEnough[msg.type](-msg.value) then
                    ModifyResType[msg.type]( msg.value )
                else
                    result.result = C.kGMLacked
                end
            else
                --加东西不会失败
                ModifyResType[msg.type]( msg.value )
            end
        else
            if ModifyResType[msg.type] then
                ModifyResType[msg.type]( msg.value )
            else
                --未完待续
                result.result = C.kGMInvalid
            end
        end

        return result
    end
	
	gm_processors_[C.kGMModifyProp] = function(msg)
		local result = {result=C.kGMSucceced}
		if prop_.DeletePropAmount(msg.id, msg.amount)~=C.kGMSucceced then
			result.result = C.kGMInvalid
		end
		return result
	end

    local function ProcessGMMsg(head, msg)
        local f = gm_processors_[head.type]
        if f then
            return f(msg)
        else
            --没有提供这个方法
            return {result=C.kGMUnknown}
        end
    end
-------------------------------------

	function this.IsPlayerReady()
		return accepted_player_msg_
	end
    
    function this.ModifyWorldWarCount(delta)
        PushPlayerChangedToWorldWar(uid_, 5, delta)
    end
    
    function this.ModifyTrainNum(delta)
        hero_mng_.AddTrainNum(delta)
    end
    
    function this.CooldownReset()
        town_.PropsCleanAllBuildingCd()
    end
    
	function this.ProcessGateMsg(head, msg, len)
		if not accepted_player_msg_ then
--			print('not logined, type='..head.type)
			return
		end
		local result, bytes = nil,nil
		repeat
            --国战消息跳转
            if head.type>C.kWorldWarGateBegin and head.type<C.kWorldWarGateEnd and this.GetCountry()~=0 then
			
				if not this.CanWorldWar() then break end

                --首次进入国战服务器时推送玩家基本信息
                if not world_war_ then
                    --发送玩家常用信息
                    local PushMsg = new('UserCommonInfo')
                    PushMsg.country = this.GetCountry()
                    PushMsg.vip = this.GetVIPLevel()
                    PushMsg.grade = GetGradeLevel(uid_)
                    PushMsg.level = this.GetLevel()
                    PushMsg.name = {role_.nickname.len, role_.nickname.str}
                    Send2WorldWar(PushMsg.kType, -1, PushMsg, sizeof(PushMsg) )
                    world_war_ = true
                end

                --转发消息
                Send2WorldWar(head.type, head.flag, msg, len)

                break
            end
            
			result,bytes = main_line_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = town_.ProcessMsgFromGate(head.type, msg)
			if result then break end
			result,bytes = prop_.ProcessMsg(head.type, msg, head.flag)
			if result then break end
			result,bytes = hero_mng_.ProcessMsg(head.type, msg)
			if result then break end

			result,bytes = explore_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = arena_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = treasure_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = guild_mng_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = guild_war_mng_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = grade_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = escort_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = playground_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = achievement_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = world_boss_.ProcessMsg(head.type, msg, head.flag)
			if result then break end
			result,bytes = assistant_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = auction_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = territory_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = tree_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = tower_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = reward_for_days_ago_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = save_website_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = lucky_draw_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = check_in_every_day_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = check_in_accumulate_.ProcessMsg(head.type, msg)
			if result then break end
			result,bytes = ProcessMsg(head.type, msg, len, head.flag)
			
		until true
		if not result then return end
		assert(not bytes or bytes<=sizeof(result))
		head.type = result.kType
		C.Send2Gate(head, result, bytes or sizeof(result))
		assert(head.type>=C.kGameReturnBegin)
	end

	function this.ProcessDbMsg(type, msg, flag)
		town_.ProcessMsgFromDb(type,msg)
		prop_.ProcessMsgFromDb(type, msg, flag)
		hero_mng_.ProcessMsgFromDb(type, msg)
		main_line_.ProcessMsgFromDb(type, msg)
		explore_.ProcessMsgFromDb(type, msg)
		arena_.ProcessMsgFromDb(type, msg)
		treasure_.ProcessMsgFromDb(type, msg)
		guild_mng_.ProcessMsgFromDb(type, msg)
		guild_war_mng_.ProcessMsgFromDb(type, msg)
		grade_.ProcessMsgFromDb(type, msg)
		escort_.ProcessMsgFromDb(type, msg)
		playground_.ProcessMsgFromDb(type,msg)
		achievement_.ProcessMsgFromDb(type,msg)
		assistant_.ProcessMsgFromDb(type,msg)
		auction_.ProcessMsgFromDb(type,msg)
		tree_.ProcessMsgFromDb(type,msg)
		tower_.ProcessMsgFromDb(type,msg)
		territory_.ProcessMsgFromDb(type,msg)
		reward_for_days_ago_.ProcessMsgFromDb(type,msg)
		save_website_.ProcessMsgFromDb(type,msg)
		lucky_draw_.ProcessMsgFromDb(type,msg)
		check_in_every_day_.ProcessMsgFromDb(type,msg)
		check_in_accumulate_.ProcessMsgFromDb(type,msg)
		ProcessMsgFromDb(type,msg)
	end

	function this.ProcessGMMsg(head,msg)
		return ProcessGMMsg(head,msg)
	end

	function this.Destroy()
		guild_war.LeaveGuildWarField(this)
		prop_.Destroy()
		explore_.Destroy()
		this.UpdateField(C.ktStatus, C.kInvalidID, {C.kfLastLogoutTime, 0} )

		EscortDestroy(this.GetUID())
		WorldBossDestroy(this.GetUID())

		if this.InTheWorldWar() then
			PushPlayerChangedToWorldWar(this.GetUID(), 4, 0)
		end
		
        guild.RemoveAllInvite(this.GetUID())--删除玩家所要申请请求
		auction_.Destroy()
		
		territory_.UpdateLastActiveTime() --退出也算更新
	end
	
	function this.UpdateLastActiveTime()
		territory_.UpdateLastActiveTime()
	end
	
--子系统的创建

	town_ = CreateTown(uid, this)
	prop_ = CreatePropManager(this)
	hero_mng_ = CreateHeroManager(this)
	hero_mng_.array(base_info_.array)
	main_line_ = CreateMainLine(this)
	explore_ = CreateExplore(this)
	arena_ = ArenaInteraction(this)
	treasure_ = TreasureInteraction(this)
	guild_mng_ = CreateGuildManager(this)
	guild_war_mng_ = CreateGuildWarManager(this)
	grade_ = GradeInteraction(this)
	escort_ = EscortInteraction(this)
	playground_ = CreatePlayGround(this)
	world_boss_ = CreateWorldBoss(this)
	achievement_ = CreateAchievement(this)
	assistant_ = CreateAssistant(this)
	auction_ = AuctionInteraction(this)
	territory_ = TerritoryInteraction(this)
	tree_ = CreateTree(this)
	tower_ = CreateTower(this)
	reward_for_days_ago_ = CreateRewardForDaysAgo(this)
	save_website_ = CreateSaveWebsite(this)
	lucky_draw_ = CreateLuckyDraw(this)
	check_in_every_day_ = CreateCheckInEveryDay(this)
	check_in_accumulate_ = CreateCheckInAccumulate(this)
	return this
end
