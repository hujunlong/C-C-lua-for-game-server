require('my_ffi')
require('tools.vector')
require('tools.table_ext')
require('main_line')
require('data')
require('fight_power')

local CreateHero = require('hero')
local hero_cfgs = require('config.hero')
local condition_for_recruit_heros = require('config.condition_for_recruit_heros')
local science_cfg = require('config.science')
local science_map = require('config.science_map')
local array_cfgs = require('config.array')
local global = require('config.global')
local training = require('config.train')
local train_buy_cost = require('config.train_buy_cost')
local train_level_silver = require('config.train_level_silver')
local train_crit_probability = require('config.train_crit_probability')
local gold_consume_flag = require('define.gold_consume_flag')
 
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy
local GetActivedHeros = GetActivedHeros

local kOrdinaryTrain = 1            --普通训练
local kGoldTrain = 2
local kStrengthenTrain = 3
local kMaxIngroupHeroCount = 10

local science_array_ = {}
for id,skill in pairs(science_cfg) do
    if science_map[id].type==3 then
        science_array_[skill[1].gain.array] = id
    end
end
    
function CreateHeroManager(player)
    local me = player
    local obj = {}
    local heros_ = {}
    local array_ = 0
    local arrays_ = 0
    local db_processor_ = {}
    local processor_ = {}
    local train_data = {}
    
    local function CountIngroupHeros()
        local count = 0
        for id,hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup then count=count+1 end
        end
        return count
    end

    local function GetHerosOnArray()
        local count = 0
        for _,hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup then
                if hero.location()>0 then count = count + 1 end
            end
        end
        return count
    end

    local function HasSameHero(hero_id)
        if heros_[hero_id] then return false end
        for hero in pairs(heros_) do
            if hero_cfgs[hero].type==hero_cfgs[hero_id].type then return true end
        end
        return false
    end

    local function AllRecruitableHeros()
        local aviable_heros = GetActivedHeros(player.FunctionBuildingsLevel(), player.GetLastCompleteTask(), player.GetCountry())
        vector.add(aviable_heros, global.hero.kOriginalHeros)
        vector.add(aviable_heros, player.GetBrachTaskActivatedHeros())
        vector.add(aviable_heros, player.GetAvailableCountryHeros())
        
        local temp = {}
        for _,hero_id in ipairs(aviable_heros) do
            if not HasSameHero(hero_id) then
                temp[hero_id] = true
            end
        end
        for hero_id,hero in pairs(heros_) do
            if hero.status()==C.kHeroDismissed then
                temp[hero_id] = true
            else --if hero.status()==C.kHeroInGroup then
                temp[hero_id] = nil
            end
        end
        
        aviable_heros = {}
        for hero_id in pairs(temp) do
            aviable_heros[#aviable_heros + 1] = hero_id
        end
        
        return aviable_heros
    end
    
    local function Recruitable(hero_id)
        local aviable_heros = AllRecruitableHeros()
        if vector.find(aviable_heros, hero_id) then
            return true
        end
    end

    -------------------------------------------------------------------
	--取整数
	-------------------------------------------------------------------
	local function GetIntPart(x)
		if x<=0 then
			return math.ceil(x)
		end
		if math.ceil(x) == x then
			x = math.ceil(x)
		else
			x = math.ceil(x) - 1
		end
		return x
	end
    
    local function UpdateTrainState()
        local vip_level = player.GetVIPLevel()
        local comeback_time = global.hero_train.comeback_time   --间隔时间
   
       if not next(train_data) then
            return
       end
        
        if  os.time() < train_data.add_count_time then
            train_data.add_count_time = os.time()
        end
  
        train_data.buff_befor_add_available_train_count = train_data.available_train_count 
        local time_available_train_count = ( os.time() - train_data.add_count_time )/comeback_time
        time_available_train_count = GetIntPart(time_available_train_count)
        local max_available_train_count = training[vip_level].max_available_train_count --玩家最大上限
        train_data.max_available_train_count = max_available_train_count
        
        if train_data.available_train_count >= max_available_train_count then
            train_data.available_train_count = train_data.available_train_count
        elseif (train_data.available_train_count < max_available_train_count) and (time_available_train_count + train_data.available_train_count >= max_available_train_count) then    --数据库没达到上限
            train_data.available_train_count = max_available_train_count
        else
            train_data.available_train_count  = time_available_train_count + train_data.available_train_count
        end
        
        train_data.remain_used_buy_count= training[vip_level].max_buy_count - train_data.used_buy_count  --剩余购买次数
        train_data.time_available_train_count = time_available_train_count
        train_data.comeback_time = comeback_time   
    end
    
    --添加修改训练次数接口供GM调用
    function obj.AddTrainNum(add_num)
        if add_num < 0 and add_num >1000 then
            print('add train number error')
            return 
        end
        train_data.available_train_count = train_data.available_train_count + add_num

        push = new('PushTrainNum')
        push.available_train_count = train_data.available_train_count
        push.max_available_train_count = train_data.max_available_train_count
        push.used_buy_count = train_data.used_buy_count
        push.remain_buy_count = train_data.remain_used_buy_count
        GlobalSend2Gate(player.GetUID(), push)
        
        UpdateField2(C.ktTrain,C.kfPlayer,player.GetUID(),0,C.kInvalidID,{C.kfTrainNum,train_data.available_train_count}) 
end
    
    processor_[C.kRecruitHero] = function(msg)
        local id = cast('const RecruitHero&', msg).hero
        local result = new('RecruitHeroResult', C.eInvalidValue)
        local cfg = hero_cfgs[id]
        local hero = heros_[id]
        
        if not cfg then
            return result
        end
        
        if CountIngroupHeros() >= kMaxIngroupHeroCount then
            result.result = C.eGroupFull
            return result
        end
        
        if hero then
            if hero.status()==C.kHeroDismissed then
                result.result = hero.Recruit()
                return result
            else
                result.result = C.eLackResource
                return result
            end
        end
        
        local condition = condition_for_recruit_heros[id]
        
        if not condition or not player.IsSilverEnough(condition.silver) then
            result.result = C.eLackResource
            return result
        end
        
        if Recruitable(id) then
            local bringup={strength=0,agility=0,intelligence=0,changes_strength=0,changes_agility=0,changes_intelligence=0}
            heros_[id] = CreateHero(me, id, 1, C.kHeroDisable,0,0,bringup)
            result.result = heros_[id].Recruit()
            if result.result==C.eSucceeded then
                player.ModifySilver(-condition.silver) 
                player.Send2Gate(new('HeroRecruited', player.GetUID(), player.GetCNickname(), id))
            end
        end

        return result
    end

    processor_[C.kDismissHero] = function(msg)
        local id = cast('const DismissHero&', msg).hero
        local result = new('DismissHeroResult', C.eInvalidValue)
        if GetHerosOnArray()<=1 then
            local hero = heros_[id]
            if not hero or hero.location()>0 then
                result.result = 13
            else
                result.result = hero.Dismiss()
            end
        else
            local hero = heros_[id]
            if hero then result.result = hero.Dismiss() end
        end
        return result
    end

    processor_[C.kGetHerosRecruitable] = function()
        local result = new('GetHerosRecruitableResult', 0)
        for _,id in pairs(AllRecruitableHeros()) do
            local hero = heros_[id]
            if (not hero) or (hero and hero.status()==C.kHeroDismissed) then
                result.heros[result.count] = {id, heros_[id] and heros_[id].status()==C.kHeroDismissed}
                result.count = result.count+1
            end
        end
        return result
    end

    processor_[C.kGetMyHeros] = function()
        local result = new('MyHeros',0)
        for id,hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup and hero.location()>0 then
                result.heros[result.count] = id
                result.count = result.count + 1
            end
        end
        for id,hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup and hero.location()==0 then
                result.heros[result.count] = id
                result.count = result.count + 1
            end
        end
        return result, 4 + result.count
    end

    processor_[C.kGetMyHeroProperty] = function(msg)
        local id = cast('const GetMyHeroProperty&', msg).id
        local property = new("MyHeroProperty")
        local hero = heros_[id]
        if hero then
            hero.ToHero4Client(property.hero)
			local p = obj.GetHeroproperty(id)
			property.hero.hp  = p.life
			property.hero.agility = p.agility
			property.hero.intelligence = p.intelligence
			property.hero.strength = p.strength
			property.hero.speed = p.speed
			property.hero.power = fight_power.GetHeroFightPower(p)
        end
        return property
    end

    --培养
    processor_[C.kGetBringupProperty] = function(msg)
        local id = cast('const GetBringupProperty&', msg).id
        local property = new("BringupProperty")
        local hero = heros_[id]
        if hero then
            hero.Bringupproperty4Client(property)
        end
        return property
    end

    processor_[C.kApplyBringup] = function(msg)
        local request = cast('const ApplyBringup&', msg)
        local property = new("ApplyBringupResult")
        local hero = heros_[request.id]
        if hero then
            hero.ApplyBringup(property.bringup, request.type)
        end
        return property
    end

    processor_[C.kAcceptBringup] = function(msg)
        local request = cast('const AcceptBringup&', msg)
        local property = new("AcceptBringupResult")
        local hero = heros_[request.id]
        if hero then
            property.result = hero.AcceptBringup(request.type)
        end
        return property
    end

    processor_[C.kGetHeroArray] = function(msg)
        local array_id = cast('const GetHeroArray&', msg).array_id
        local result = new('GetHeroArrayResult', C.eInvalidValue)
        if array_id==array_ then

            local list_count = 0
            for id,hero in pairs(heros_) do
                if hero.status()==C.kHeroInGroup then
                    local location = hero.location()
                    if location>0 then
                        result.heros[list_count].id = id
                        result.heros[list_count].location = location
                        list_count = list_count + 1
						if list_count>=5 then break end
                    end
                end
            end

            result.result = C.eSucceeded
        else
            local array = arrays_[array_id]
            if array then
                local list_count = 0
                for id,location in pairs(array) do
                    if heros_[id] and heros_[id].status()==C.kHeroInGroup then
                        result.heros[list_count].id = id
                        result.heros[list_count].location = location
                        list_count = list_count + 1
						if list_count>=5 then break end
                    end
                end
            end
            result.result = C.eSucceeded
        end
        return result
    end
  
    processor_[C.kChangeHeroArray] = function(msg)
        local array_id = cast('const ChangeHeroArray&', msg).array_id
        local result = new('ChangeHeroArrayResult', C.eInvalidValue)
        local array = array_cfgs[array_id]
        if array and array_id~=array_ and arrays_[array_id] and table.size(arrays_[array_id])>=1 then
            --保存当前阵形
            if not arrays_[array_] then player.InsertRow(C.ktArray, {C.kfID, array_}) end
            arrays_[array_] = {}

            for id,hero in pairs(heros_) do
                if hero.status()==C.kHeroInGroup then
                    local location = hero.location()
                    if location>0 then arrays_[array_][id] = location end
                end
            end

            local save_arrays_count = 0
            local save_arrays = new('db_array')
            for id,location in pairs(arrays_[array_]) do
                if save_arrays_count>4 then
                    print("save_arrays_count error")
                    break
                end
                save_arrays.heros[save_arrays_count].id = id
                save_arrays.heros[save_arrays_count].location = location
                save_arrays_count = save_arrays_count + 1
            end
            player.UpdateStringField(C.ktArray, array_, C.kfArray, save_arrays, sizeof(save_arrays))

            --切换到当前阵形
            array_ = array_id
            for id,hero in pairs(heros_) do
                if hero.status()==C.kHeroInGroup then
                    local location = arrays_[array_id][id]
                    if location then
                        hero.location(location)
                    else
                        if hero.location()~=0 then hero.location(0) end
                    end
                end
            end

            player.UpdateField(C.ktBaseInfo, C.kInvalidID, {C.kfArray, array_id})
            result.result = C.eSucceeded
            
            fight_power.CheckFightPowerChange(player.GetUID())
        end
        return result
    end

    local function SwapLocation(hero, location)
        local target_hero
        for _,tmp in pairs(heros_) do
            if tmp.location()==location then target_hero=tmp break end
        end
        if target_hero then
            target_hero.location(hero.location())
        end
        hero.location(location)
    end

    processor_[C.kChangeHeroLocation] = function(msg)
        local change = cast('const ChangeHeroLocation&', msg)
        local result = new('ChangeHeroLocationResult', C.eInvalidValue)

        if not array_cfgs[change.array_id] or not science_array_[array_] or not player.GetSkills()[science_array_[array_]] then return result end

        local hero = heros_[change.hero]
        if hero and hero.status()==C.kHeroInGroup then
            if change.array_id==array_ then
                --改变当前阵形
                if change.location<=0 then
                    if GetHerosOnArray()>1 then
                        hero.location(0)
                        result.result = C.eSucceeded
                    end
                else
                    local array = array_cfgs[array_]
                    if array and ( vector.find(array[player.GetSkills()[science_array_[array_]]].pos, change.location)) then
                        SwapLocation(hero,change.location)
                        result.result = C.eSucceeded
                    end
                end
            else
                --改变其它阵形
                if not arrays_[change.array_id] then
                    arrays_[change.array_id] = {}
                    player.InsertRow(C.ktArray, {C.kfID, change.array_id})
                end

                if change.location<=0 then
                    --if TableLen(arrays_[change.array_id])>1 then
                        arrays_[change.array_id][change.hero] = nil
                        result.result = C.eSucceeded
                    --end
                else
                    local array = array_cfgs[change.array_id]
                    if array and ( vector.find(array[player.GetSkills()[science_array_[change.array_id]]].pos, change.location)) then
                        local already_exist = 0
                        for id,location in pairs(arrays_[change.array_id]) do
                            if location==change.location then
                                already_exist = id
                                break
                            end
                        end

                        if already_exist~=0 then
                            arrays_[change.array_id][already_exist] = arrays_[change.array_id][change.hero]
                            arrays_[change.array_id][change.hero] = change.location
                        else
                            arrays_[change.array_id][change.hero] = change.location
                        end

                        result.result = C.eSucceeded
                    end
                end

                if result.result == C.eSucceeded then
                    --保存到数据库
                    local save_arrays_count = 0
                    local save_arrays = new('db_array')
                    for id,location in pairs(arrays_[change.array_id]) do
                        if save_arrays_count>4 then
                            print("save_arrays_count error")
                            break
                        end
                        save_arrays.heros[save_arrays_count].id = id
                        save_arrays.heros[save_arrays_count].location = location
                        save_arrays_count = save_arrays_count + 1
                    end
                    player.UpdateStringField(C.ktArray, change.array_id, C.kfArray, save_arrays, sizeof(save_arrays))
                end
            end
            if result.result == C.eSucceeded then
				fight_power.CheckFightPowerChange(player.GetUID())
			end
        end
        return result
    end


    processor_[C.kGetMyHeroDetail] = function(msg)
        local id = cast('const GetMyHeroDetail&', msg).hero
        local detail = new('HeroDetail[1]')
        local hero = heros_[id]
        if hero then
            local p = obj.GetHeroproperty(id)
            detail[0] = {p.life, p.strength, p.agility, p.intelligence, p.speed, p.physical_attack.min, p.physical_attack.max, p.physical_defense, p.magical_attack.min,
            p.magical_attack.max, p.magical_defense, p.real_damage, p.hit, p.dodge, p.dodge_reduce, p.resistance, p.magical_accurate, p.block, p.block_damage_reduction, p.parry, p.counterattack,
                p.counterattack_damage, p.crit, p.toughness, p.crit_damage, p.dizziness_resistance, p.sleep_resistance, p.paralysis_resistance, p.charm_resistance,
                p.silence_resistance, p.detained_resistance, p.ridicule_resistance, p.plain, p.forest, p.lake, p.coastal, p.cave, p.wasteland, p.citadel,
				p.sunny, p.rain, p.cloudy, p.snow, p.fog}
        end
        return detail[0]
    end

-- from db
    db_processor_[C.kHero] = function(msg)
        local hero_from_db = cast('const Hero&', msg)
        
		local bringup={}
		bringup.strength = hero_from_db.bringup_bin.strength
		bringup.agility = hero_from_db.bringup_bin.agility
		bringup.intelligence = hero_from_db.bringup_bin.intelligence
		bringup.changes_strength = hero_from_db.bringup_bin.changes_strength
		bringup.changes_agility = hero_from_db.bringup_bin.changes_agility
		bringup.changes_intelligence = hero_from_db.bringup_bin.changes_intelligence

        local hero = CreateHero(me, hero_from_db.id, hero_from_db.level, hero_from_db.status, hero_from_db.location, hero_from_db.exp, bringup)
        heros_[hero_from_db.id] = hero
    end

    db_processor_[C.kArrays] = function(msg)
        local Arrays = cast('const Arrays&', msg)
        arrays_ = {}
        for i=0,Arrays.count-1 do
            local array_id = Arrays.arrays[i].id
            arrays_[array_id] = {}
            for j=0,4 do
                local hero_id = Arrays.arrays[i].heros[j].id
                if hero_id~=0 then
                    arrays_[array_id][hero_id] = Arrays.arrays[i].heros[j].location
                end
            end
        end
    end

      db_processor_[C.kTrain] = function(msg)
        local hero_train = cast('const TrainNum&',msg)
        train_data.available_train_count = hero_train.available_train_count
        train_data.used_buy_count = hero_train.used_buy_count        
        train_data.add_count_time = hero_train.add_count_time
        UpdateTrainState()
        
        if train_data.time_available_train_count >= 1 and (train_data.buff_befor_add_available_train_count < train_data.max_available_train_count) then
            distance_time = train_data.time_available_train_count*train_data.comeback_time + train_data.add_count_time
            player.UpdateField(C.ktTrain, C.kInvalidID, {C.kfTrainNum, train_data.available_train_count},{C.kfAddCountTime, distance_time})
            train_data.add_count_time = distance_time
        elseif train_data.buff_befor_add_available_train_count == train_data.max_available_train_count then
            train_data.add_count_time = os.time()
        end
      end
  
    function obj.GetHeroLevel(id)
        local hero = heros_[id]
        if hero then
            return hero.level()
        end
        return nil
    end

    function obj.AddInGroupHerosExp(delta)
        for _,hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup and hero.location()>0 then hero.AddExp(delta)  end
        end
        fight_power.CheckFightPowerChange(player.GetUID())
    end

    function obj.GetHeroproperty(id)
        local hero = heros_[id]
        if hero then
            local p = hero.GetProperty()
            data.AddSkillsEffect(p, player.GetSkills(), array_, hero.location())
            return p
        end
    end

    function obj.GetHerosGroup()
        local group = {}
        local equipments = {}
        for id, hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup and hero.location()>=1 and hero.location()<=9 then
                local p = obj.GetHeroproperty(id)
                group[hero.location()] = p
                
                equipments[hero.location()] = {}
                
                for location, v in pairs(player.GetHeroEquipments(id)) do
                    equipments[hero.location()][location] = {id=v[3], kind=v[1].kind}
                end
            end
        end
        return group, array_, equipments
    end

    function obj.GetHero(id)
        return heros_[id]
    end

    function obj.GetArmySimpleInfo()
        local info = new('PlayerArmy')
        for id, hero in pairs(heros_) do
            if hero.status()==C.kHeroInGroup and hero.location()>0 and hero.location()<9 then
                info.heros[info.count] = {id, hero.level()}
                info.count = info.count+1
				if info.count>=9 then break end
            end
        end
        return info
    end

	function obj.GetHeroCount()
		return table.size(heros_)
	end

	function obj.Equip(hero_id, location, prop_kind)
        local result = { result=C.eInvalidOperation }
        local hero = heros_[hero_id]
        if hero then
            result=hero.Equip(prop_kind, location)
        end
        return result
    end

    function obj.array(array)
        if array then
            array_ = array
        else
            return array_
        end
    end

    function obj.ProcessMsgFromDb(type, msg)
        local func = db_processor_[type]
        if func then func(msg) end
    end

    function obj.ProcessMsg(type, msg)
        local func = processor_[type]
        if func then return func(msg) end
    end

    --更新数据内存
    function obj.ResetBuyTrainNum()
        train_data.used_buy_count = 0
    end
	-------------------------------------------------------------------
	--可使用训练次数
	-------------------------------------------------------------------
    function obj.UpdateTrainNum()
        UpdateTrainState()
        if not next(train_data) then
            return
        end
        if train_data.time_available_train_count >= 1 and (train_data.buff_befor_add_available_train_count < train_data.max_available_train_count) then
            local push =  new('PushTrainNum')
            push.available_train_count = train_data.available_train_count
            push.max_available_train_count = train_data.max_available_train_count
            push.used_buy_count = train_data.used_buy_count
            push.remain_buy_count = train_data.remain_used_buy_count
            local distance_time = train_data.time_available_train_count*train_data.comeback_time + train_data.add_count_time
            player.UpdateField(C.ktTrain, C.kInvalidID, {C.kfTrainNum, train_data.available_train_count},{C.kfAddCountTime, distance_time})
            train_data.add_count_time = distance_time
            GlobalSend2Gate(player.GetUID(), push)
        elseif train_data.buff_befor_add_available_train_count == train_data.max_available_train_count then
            train_data.add_count_time = os.time()
        end
    end
    
	processor_[C.kGetTrainingNum] = function(msg)
		local req = cast('const GetTrainingNum&', msg)
		local result = new("GetTrainStatusResult")
        local vip_level = player.GetVIPLevel()
        local max_buy_count = training[vip_level].max_buy_count
        result.available_train_count = train_data.available_train_count
        result.max_available_train_count = train_data.max_available_train_count
        result.used_buy_count = train_data.used_buy_count
        train_data.remain_used_buy_count = max_buy_count - train_data.used_buy_count
        result.remain_buy_count = train_data.remain_used_buy_count
		return result
	end
	-------------------------------------------------------------------
	--VIP购买
	-------------------------------------------------------------------
	 processor_[C.kBuyTrainingNum] = function(msg)
		local req = cast('const BuyTrainingNum&', msg)
		local result = new("ResultBuyTrainingNum")
		local vip_level = player.GetVIPLevel()

		if vip_level < 1 then
			result.result = C.TRAIN_VIP_ERROR
            return result
		end

		local gold  = train_buy_cost[train_data.used_buy_count + 1].consumer_gold     --钱是否足够
		
		if not player.IsGoldEnough(gold) then
			result.result = C.TRAIN_GOLD_ERROR
			return result
		end
		
        if  train_data.used_buy_count >= training[vip_level].max_buy_count then         --是否达到购买上限
            result.result = C.TRAIN_BUY_ERROR
        end
        
        train_data.used_buy_count = train_data.used_buy_count + 1 --购买次数+1
		player.ConsumeGold(gold,gold_consume_flag.buy_traing_num) --扣金币
		train_data.available_train_count = train_data.available_train_count + training[vip_level].every_time_available_train_count
		player.UpdateField(C.ktTrain, C.kInvalidID, {C.kfTrainNum, train_data.available_train_count},{C.kfBuyNum, train_data.used_buy_count})
		result.available_train_count = train_data.available_train_count
		result.is_buy_sucess = 1
		return result
	end

	processor_[C.kTraining] = function(msg) 
		local req = cast('const Training&', msg)
		local result = new("TrainResult")
		local gold = 0                     --花费金币，暂时定义为 强化为
		local is_gold_enough = false        -- 金币不足够
		local is_silver_enough = false      --银币不够
		local vip_level = player.GetVIPLevel()
		local  build_level = player.GetTrainingGroundLevel()
        if build_level == nil then
            result = C.TRAIN_MSG_ERROR
            return result
        end

        if not heros_[req.id] or heros_[req.id].status()~=C.kHeroInGroup or ( req.type<1 and req.type>3 ) then
        	result.result = C.TRAIN_MSG_ERROR
			return result
        end

		if  train_data.available_train_count  == 0 then --可训练次数为0
		    result.result = C.TRAIN_NUM_ERROR
			return result
		end

		local silver = train_level_silver[build_level].silver
		if  req.type == kOrdinaryTrain then
			is_silver_enough = player.IsSilverEnough(silver)
		end

		if req.type == kGoldTrain then
		   gold = training[vip_level].cost_gold
		   is_gold_enough = player.IsGoldEnough(gold)
		end

		if req.type == kStrengthenTrain then
			if training[vip_level].strength_cost_gold == 0 then
				result.result = C.TRAIN_VIP_LEL_ERROR
				return result
			end
		   gold = training[vip_level].strength_cost_gold
		   is_gold_enough = player.IsGoldEnough(gold)
		end

		if not is_gold_enough  and req.type ~= kOrdinaryTrain then --金币不够
			result.result = C.TRAIN_GOLD_ERROR
			return result
		end

		if not is_silver_enough  and req.type == kOrdinaryTrain then --银币不够
			result.result = C.TRAIN_SILVER_ERROR
			return result
		end

		local exp = train_level_silver[build_level].exp or 0
        local buff_value = 0
        --计算权值
        local weights  = 0
        for _,relatively_weights in pairs(train_crit_probability[req.type].crit_probability) do
            weights = weights + relatively_weights[1]
        end
        local ran_num = math.random(weights)
        for k,value in pairs(train_crit_probability[req.type].crit_probability) do
            buff_value = value[1] + buff_value
            if ran_num < buff_value then
                result.experience_num = exp*value[2]*train_crit_probability[req.type].exp_coefficient
                if value[2] == 1 then
                    result.is_crit = false
                else
                    result.is_crit = true
                end
                break
            end
        end
        
		result.is_training_sucess = true
	    result.experience_num = heros_[req.id].ShouldAddExp(result.experience_num)
		if result.experience_num == 0 then
			result.result = C.TRAIN_LEL_ERROR
			return result
		end
      
        if req.type == kOrdinaryTrain then
			player.ModifySilver(-silver)
		elseif req.type == kGoldTrain then
			player.ConsumeGold(gold,gold_consume_flag.gold_coins_training) --扣金币
        elseif req.type == kStrengthenTrain then
            player.ConsumeGold(gold,gold_consume_flag.intensive_training) --扣金币
		end

        train_data.available_train_count  = train_data.available_train_count - 1
	    result.remain_available_train_count = train_data.available_train_count 
		player.UpdateField(C.ktTrain, C.kInvalidID, {C.kfTrainNum, result.remain_available_train_count},{C.kfAddCountTime,train_data.add_count_time})
		
	    heros_[req.id].AddExp(result.experience_num)
		fight_power.CheckFightPowerChange(player.GetUID())
		return result
	end
    
    --英雄进化
    processor_[C.kEvolveHero] = function(msg)
        --获取所需金币
        local function GetMaterialsCost(materials)
            local cost_gold = 0
            for _,material in ipairs(materials) do
                local tmp_amount = player.HavePropAmount( material.kind )
                if tmp_amount<material.amount then
                    cost_gold = cost_gold + (material.amount - tmp_amount) * material.cost
                end
            end
            
            return cost_gold
        end
        
        local EvolveHero = cast("const EvolveHero&", msg)
        local result = new("EvolveHeroResult", C.eInvalidOperation)
        
        repeat
            --英雄必须存在并且没解雇
            local id = EvolveHero.hero
            local hero = heros_[id]
            if not hero or hero.status()==C.kHeroDismissed then break end
            
            --英雄必须可以升级
            if not hero_cfgs[id].upgrade or hero.level()<hero_cfgs[id].upgrade then break end
            
            --检查VIP
            local cost = GetMaterialsCost(hero_cfgs[id].materials)
            if EvolveHero.use_vip==1 and ( player.GetVIPLevel()<global.kEvolveHeroVIP or not player.IsGoldEnough(cost) ) then break end
            if EvolveHero.use_vip~=1 and cost~=0 then break end
            
            --扣除金币
            if EvolveHero.use_vip==1 then player.ConsumeGold(cost, gold_consume_flag.hero_evolve) end
            
            --使用能使用的道具
            for _,material in ipairs(hero_cfgs[id].materials) do
                player.ModifyProp(material.kind, -material.amount)
            end
            
            --改变英雄ID
            local new_id = hero_cfgs[id].superior
            player.ChangeHeroID(id, new_id)
            
            heros_[new_id] = heros_[id]
            heros_[id] = nil
            heros_[new_id].ChangeHeroID(new_id)
            data.ChangeHeroID(player.GetUID(), id, new_id)
            
            
            --返回结果
            result.hero = new_id
            result.result = C.eSucceeded
            fight_power.CheckFightPowerChange(player.GetUID())
        until true
        
        return result
    end
    
    return obj

end
