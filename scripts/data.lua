module('data', package.seeall)

require('db')
require('fight_power')
require('grade')
require('tools.table_ext')

local mysql = require('tools.mysql')
local prop_cfgs = require('config.props')
local hero_cfgs = require('config.hero')
local science_cfg = require('config.science')
local science_map = require('config.science_map')
local array_cfgs = require('config.array')
local property_cfgs = require('config.property')
local grade_cfg = require('config.grade')[1]
local world_boss_level = require('config.world_boss_level')

local ffi = require('my_ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local science_array_ = {}
for id,skill in pairs(science_cfg) do
    if science_map[id].type==3 then
        science_array_[id] = skill[1].gain.array
    end
end

local conn = nil

if ffi.os=='Windows' then 
    conn = mysql:connect( "192.168.0.248", "ywxm", "ywxm", "yxdl" )
else
    conn = mysql:connect( "127.0.0.1", "root", "570329", "game" )
end

db.Initialize(conn)

conn:query('select now();')

local online_players = {}		--在线玩家
local offline_players = {}		--离线玩家
local processor = {}

function Initialize(g_players)
    online_players = g_players
end

function GetAllOnlinePlayer()
    return online_players
end

function GetOnlinePlayer(uid)
    return online_players[uid]
end

--通过玩家ID 取离线玩家对象
local function GetOfflinePlayer(uid)
    local player = offline_players[uid]
    if not player then			--没有该玩家对象,初始化一个
        player = {}
        player.hero = {}
        offline_players[uid] = player
    end
    return player
end

--取离线玩家的英雄对象
function GetOfflinePlayerHero(player_id, hero_id)
    local player = GetOfflinePlayer(player_id)
    local hero = player.hero[hero_id]
    if not hero then
        hero = {}
        player.hero[hero_id] = hero
    end
    return hero
end

--异步执行SQL
local function AsynchronousSQL(sql)
    if #sql>1024*2 then
        conn:query(sql)
    else
        GlobalSend2Db( new('ExcuteSqlDirectly', #sql, sql), 2 + #sql )
    end
end

--操作时间戳
function GetActionStamp(action_type)
    local res = conn:query('select time from action_stamp where action='..action_type)
    local row = res[1]
    if not row then
        AsynchronousSQL("INSERT INTO action_stamp VALUES('1', '0', '零点公用')")
        AsynchronousSQL("INSERT INTO action_stamp VALUES('2', '0', '竞技场发奖')")
        AsynchronousSQL("INSERT INTO action_stamp VALUES('3', '0', '工会战流程')")
        return 0
    end

    return row.time
end

function SetActionStamp(action_type, time)
    AsynchronousSQL('update action_stamp set time='.. time ..' where action='..action_type)
end

function ResetVipCount()
    AsynchronousSQL('update vip_count set energy=0,mobility=0,alchemy=0,rune=0')
end

function ResetGradeReward()
    AsynchronousSQL('update grade set reward=1')
end

function ResetAdvancedGrade()
    AsynchronousSQL('update grade set level=13 where level>13')
end

function ResetTower()
    AsynchronousSQL('update tower set refresh=0')
end

--英雄进化
function ChangeHeroID(player_id, hero_id, new_id)
    AsynchronousSQL('update hero set id='..new_id..' where player='..player_id..' and id='..hero_id)
end

function ChangeRuneHeroID(player_id, hero_id, new_id)
    AsynchronousSQL('update rune_info set location='..new_id..' where player='..player_id..' and location='..hero_id)
end

--获取战报唯一序列号
function GetBattleSequence()
    local res = conn:query('SELECT IFNULL(MAX(id),0) as max_id FROM battle_record')
    return res[1].max_id
end

--获取物品唯一ID
function GetPropUUID(uid, id)
    local res = conn:query('SELECT uuid FROM prop where player='..uid..' and id='..id)

    if res[1] then
        return res[1].uuid
    end
end

--追加属性
function ReadMoreProperty(row)
    local res = conn:query('SELECT player,id,kind,amount FROM prop where uuid='..row.uuid)
    if res[1] then
        row.player = res[1].player
        row.id = res[1].id
        row.kind = res[1].kind
        row.amount = res[1].amount
        --装备属性
        if prop_cfgs[res[1].kind].type==1 then
            local equipment = conn:query('SELECT strength,agility,intelligence FROM equipment where player='..res[1].player..' and id='..res[1].id)
            if equipment[1] then
                row.strength = equipment[1].strength
                row.agility = equipment[1].agility
                row.intelligence = equipment[1].intelligence
            else
                print("装备表错误！",res[1].player,res[1].id)
            end
        end
    else
        print("拍卖行出现错误，UUID对应物品在prop表中不存在！",row.uuid)
    end
end

--获取拍卖行数据
function GetAuctionInfo()
    local info = {}
    local res = conn:query('select * from auction')
    for _,row in ipairs(res) do
        ReadMoreProperty(row)
        table.insert(info, row)
    end

    return info
end

function DeleteAuction(uuid)
    --[[
    local res = conn:query('SELECT player,id FROM prop where uuid='..uuid)
    if res[1] then
        conn:query('DELETE FROM equipment WHERE player='..res[1].player..' and id='..res[1].id)
    end
    conn:query('DELETE FROM prop WHERE uuid='..uuid)
    ]]
    AsynchronousSQL('DELETE FROM auction WHERE uuid='..uuid)
end

function ChangePropOwner(form_uid, to_uid, id)
    local res = conn:query('SELECT IFNULL(MAX(id),0) as max_id FROM prop where player='..to_uid)
    local max_id_ = res[1].max_id + 1

    res = conn:query('SELECT id FROM prop where  player='..form_uid..' and id='..id)
    if not res[1] then
        print("拍卖行物品意外消失", form_uid, id)
        return nil
    end

    AsynchronousSQL('update prop set player='..to_uid..',id='..max_id_..',area='..C.kAreaMail..',location=0 where player='..form_uid..' and id='..id)

    return max_id_
end

--检查装备是否已经绑定
function CanSellEquipment(uid, id)
    local res = conn:query('SELECT equiped FROM equipment where player='..uid..' and id='..id)

    if res[1] then
        return res[1].equiped==0
    end

end
----------------------------------------------
--攻略相关操作

function InsertRaiders(type, id, sub_id, info)
    AsynchronousSQL('INSERT INTO raiders VALUES(' .. type .. ', ' .. id .. ', ' .. sub_id .. ', ' .. info.player .. ', ' .. info.record .. ', ' .. info.level .. ', '..info.time..')')
end

function DeleteRaiders(type, id, sub_id, uid)
    AsynchronousSQL('DELETE FROM raiders WHERE type='..type..' and id='..id..' and sub_id='..sub_id..' and player='..uid)
end

function DeleteBattle(record_id)
    AsynchronousSQL('DELETE FROM battle_record WHERE id='..record_id)
end

function UpdateRaiders(type, id, sub_id, info)
    AsynchronousSQL('update raiders set record='..info.record..',level='..info.level..',time='..info.time..' WHERE type='..type..' and id='..id..' and sub_id='..sub_id..' and player='..info.player)
end

--获取所有攻略数据
function GetRaidersInfo()
    local info = {}
    local res = conn:query('select * from raiders ORDER BY time ASC')
    for _,row in ipairs(res) do
        if not info[row.type] then info[row.type] = {} end
        if not info[row.type][row.id] then info[row.type][row.id] = {} end
        if not info[row.type][row.id][row.sub_id] then info[row.type][row.id][row.sub_id] = {} end
        if #info[row.type][row.id][row.sub_id]>=5 then
            DeleteRaiders(row.type, row.id, row.sub_id, row.player)
            DeleteBattle(row.record)
            print("攻略数量超多 ", row.type, row.id, row.sub_id)
        else
            table.insert(info[row.type][row.id][row.sub_id], {player=row.player, record=row.record, level=row.level, time=row.time})
        end
    end

    return info
end

--获取服务器领地数据
function GetTerritory()
    local index = {} --玩家索引
    local info = {}
    local res = conn:query('select * from territory')
    for _,row in ipairs(res) do
        if not info[row.country] then info[row.country] = {} end
        if not info[row.country][row.type] then info[row.country][row.type] = {} end
        if not info[row.country][row.type][row.page] then info[row.country][row.type][row.page] = {style=row.style} end
        --if not info[row.country][row.type][row.page][row.seral] then info[row.country][row.type][row.page][row.seral] = {} end
        info[row.country][row.type][row.page][row.seral]= {kind=row.kind, owner=row.owner}
        
        if row.owner~=0 then
            if not index[row.owner] then index[row.owner] = {country=row.country, type=row.type, page=row.page} end
            if row.kind==0 then
                index[row.owner].city = {seral=row.seral, kind=row.kind}
            else
                index[row.owner].resource = {seral=row.seral, kind=row.kind}
            end
        end
    end

    return info, index
end

--获取所有玩家领地数据
function GetTerritoryInfo()
    local info = {}
    local res = conn:query('select * from territory_info')
    for _,row in ipairs(res) do
        info[row.player] = row
    end
    
    return info
end

--初始化服务器领地数据
function InsertTerritory(country, type, page, style, seral, kind)
    AsynchronousSQL('INSERT INTO territory VALUES(' .. country .. ', ' .. type .. ', ' .. page .. ', ' .. style .. ', ' .. seral .. ', ' .. kind .. ', 0)')
end

--分配领地给
function SetTerritoryOwner(country, type, page, seral, uid)
    AsynchronousSQL('UPDATE territory SET owner=' .. uid .. ' where country='..country..' and type='..type..' and page='..page..' and seral='..seral)
end

--插入玩家领地信息
function InsertTerritoryInfo(uid)
    AsynchronousSQL('INSERT INTO territory_info (player,last_active_time) VALUES(' .. uid .. ','.. os.time() ..')')
end

--更新玩家领地信息
function UpdateTerritoryInfo(uid, ...)
    local str = ""
    for k,v in ipairs{...} do
        if k~=1 then
            str = str .. ',' .. v[1] .. '=' .. "'" .. v[2] .. "'"
        else
            str = v[1] .. '=' .. "'" .. v[2] .. "'"
        end
    end
    AsynchronousSQL('update territory_info set ' .. str .. ' where player='..uid)
end

function ReduceTerritory(country, type, page)
    AsynchronousSQL('DELETE FROM territory where country='..country..' and type='..type..' and page='..page)
    AsynchronousSQL('update territory set page=page-1 where country='..country..' and type='..type..' and page>'..page)
end

function DeleteTerritoryInfo(uid)
    AsynchronousSQL('DELETE FROM territory_info where player='..uid)
    AsynchronousSQL('REPLACE INTO territory_offline values('..uid..','..os.time()..')')
end

function ResetTerritory()
    AsynchronousSQL('update territory_info set move=1,grab=1,robber=0,assist=0')
end

--获取国家总人数
function GetCountryCount()
    local count = {0,0,0}
    local res = conn:query('select country,count(country) as total from base_info where country<>0 group by country')
    for _,row in ipairs(res) do
        count[row.country] = row.total
    end

    return count
end

--竞技场相关操作
function GetAllArenaInfo()
    local ranks = {}
    local res = conn:query('select player,rank,reward,win_count from arena_info')
    for _,row in ipairs(res) do
        ranks[row.rank] = {}
        ranks[row.rank].player = row.player
        ranks[row.rank].reward = row.reward
        ranks[row.rank].win_count = row.win_count
    end

    --清理数据
    local res2 = conn:query('select player from arena_history group by player having count(*)>5')
    for _,row in ipairs(res2) do
        local delete_sql = "DELETE FROM arena_history WHERE player="..row.player.." and time not in (sELECT time FROM(sELECT time FROM arena_history WHERE player="..row.player.." ORDER BY time DESC LIMIT 0, 5) AS arena_history)"
        AsynchronousSQL(delete_sql)
    end
    return ranks
end

function ResetArenaInfo()
    AsynchronousSQL('update arena_info set count=0,buy_count=0')
end

function RewardArenaInfo()
    AsynchronousSQL('update arena_info set reward=rank')
end

--护送相关操作
function GetAllEscortInfo()
    local info = {}
    local res = conn:query('select player,defend_count,defend_total,win_count,score,auto_accept from escort_info')
    for _,row in ipairs(res) do
        table.insert(info,row)
    end

    return info
end

function GetAllEscortRoad()
    local road = {}
    local res = conn:query('select player,transport,guardian,time,count,looter1,looter2,silver,prestige from escort_road')
    for _,row in ipairs(res) do
        road[row.player] = row
    end
    return road
end

function DeleteEscortRoad(player_id)
    AsynchronousSQL('delete from escort_road where player=' .. player_id)
end

function ResetEscortInfo()
    AsynchronousSQL('update escort_info set count=0,defend_count=0,intercept=0,refresh=0')
end



--查询是否在该地图被公会给占领
function GetGuildWarAttibutionGuildInfo(war_field_id)
    local res = conn:query('select a.guild_id ,b.name from guild_war_fields a,guild b where a.guild_id = b.guild_id and a.id = '..war_field_id)
	return res
end

--根据公会id查询公会名字
function GetGuildName(guild_id)
	local res = conn:query('select name from guild where guild_id ='..guild_id)
	return res
end

--查询是否该队是否报名该战场
function GetIsSignList(war_id)
local res = conn:query('select map_id from guild_map_sign_list where map_id ='..war_id)
	return res
end

--获取所有已经有人完成的成就
function GetAllAccomplishedAchievements()
	local res = conn:query('select distinct id from achievement')
	local ret = {}
	for _,row in ipairs(res) do 
		local id = row.id 
		table.insert(ret, id)
	end
	return ret
end

--获取军阶等级
function GetGradeLevelFromDB(player_id)
    local res = conn:query('select level from grade where player=' .. player_id)
    local row = res[1]
    if row then
        return row.level
    end

    return 0
end

--世界BOSS相关操作
function GetWorldBossInfo(boss_cfg,boss_level)
    local res = conn:query('select id,level,dead from world_boss')
    local row = res[1]
    if not row then
        print("Init world_boss table in database")
        
        local boss_init_level = 0
        for _ in pairs(world_boss_level) do
            boss_init_level = _
            break
        end
        
        for k,v in pairs(boss_cfg) do
            AsynchronousSQL('INSERT INTO world_boss VALUES(' .. k .. ', ' .. boss_init_level .. ', 0)')
            v.level = boss_init_level
            v.dead = 0
            v.life = boss_level[v.level].life
            v.max_life = boss_level[v.level].life
            v.reward = boss_level[v.level].reward
        end
    else
        for _,row in ipairs(res) do
            boss_cfg[row.id].level = row.level
            boss_cfg[row.id].dead = row.dead
            boss_cfg[row.id].life = boss_level[row.level].life
            boss_cfg[row.id].max_life = boss_level[row.level].life
            boss_cfg[row.id].reward = boss_level[row.level].reward
        end
    end
end

function SetWorldBossInfo(id,level,dead)
    AsynchronousSQL('update world_boss set level='..level..',dead='..dead..' where id='..id)
end

function ResetWorldBossInfo()
    AsynchronousSQL('update world_boss set dead=0')
end

--
function ResetBossSection()
	AsynchronousSQL('update status set boss_killing_times=0')
	AsynchronousSQL('delete from boss_section')
end

--通过ID取玩家信息
function GetPlayerBaseInfo(uid)
    local player = online_players[uid]
    if player then									--玩家在线, 直接返回在线玩家对象
        return player.GetPlayerBaseInfo()
    end

    player = GetOfflinePlayer(uid)					--玩家不在线, 取离线玩家对象
    if not player.base_info then
        player.base_info = db.ReadOfflinePlayerInfo(uid)
    end
    
    if not player.base_info then
        error("GetPlayerBaseInfo error " .. uid )
    end
    
    return player.base_info
end

--通过ID取玩家名
function GetPlayerName(uid)
    local nickname = GetPlayerBaseInfo(uid).role.nickname
    return ffi.string(nickname.str, nickname.len)
end
--通过ID取玩家名
function GetCPlayerName(uid)
    return GetPlayerBaseInfo(uid).role.nickname
end

--通过ID取玩家性别
function GetPlayerSex(uid)
    return GetPlayerBaseInfo(uid).role.sex
end

--通过ID取玩家等级
function GetPlayerLevel(uid)
    return GetPlayerBaseInfo(uid).game_info.level
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
--下面是玩家属性计算


--获取符文信息
local rune_upgrade = require('config.rune_upgrade')
function GetRuneLevel(kind, exp)
    local level = 0
    for k,v in ipairs(rune_upgrade[kind]) do
        if not v.exp then break end
        if exp>=v.exp then
            if level<k then
                level = k
            end
        end
    end
    if level>=10 then return 10 end
    return level + 1
end
local function GetOfflineRunesProperty(player_id, hero_id)
    local res = conn:query('select type,exp from rune_info where player=' .. player_id..' and location='.. hero_id)
    local propertys = {}
    for _,v in pairs(res) do
        local property = rune_upgrade[v.type][GetRuneLevel(v.type, v.exp)].property
        for i,j in pairs(property) do
            if not propertys[i] then propertys[i] = 0 end
            propertys[i] = propertys[i] + j
        end
    end
    return propertys
end

--装备属性
local function Add2property(property, prop_cfg, equip)
	property.strength = property.strength + (prop_cfg.strength or 0)
	property.agility = property.agility + (prop_cfg.agility or 0)
	property.intelligence = property.intelligence + (prop_cfg.agility or 0)
	property.life = property.life + (prop_cfg.life or 0)
	property.physical_attack.min = property.physical_attack.min + (prop_cfg.physical_attack and prop_cfg.physical_attack.min or 0)
	property.physical_attack.max = property.physical_attack.max + (prop_cfg.physical_attack and prop_cfg.physical_attack.max or 0)
	property.physical_defense = property.physical_defense + (prop_cfg.physical_defense or 0)
	property.magical_attack.min = property.magical_attack.min + (prop_cfg.magical_attack and prop_cfg.magical_attack.min or 0)
	property.magical_attack.max = property.magical_attack.max + (prop_cfg.magical_attack and prop_cfg.magical_attack.max or 0)
	property.magical_defense = property.magical_defense + (prop_cfg.magical_defense or 0)

	if prop_cfg.properties_to_strengthen and equip then
		for name,strengthen in pairs(prop_cfg.properties_to_strengthen) do
			--local name = strengthen[1]
			if name=='physical_attack' or name=='magical_attack' then
				property[name].min = property[name].min + strengthen.min*equip.level
				property[name].max = property[name].max + strengthen.max*equip.level
			else
				property[name] = property[name] + strengthen*equip.level
			end
		end
		property.strength = property.strength + equip.base_strength
		property.agility = property.agility + equip.base_agility
		property.intelligence = property.intelligence + equip.base_intelligence
	end

	if prop_cfg.additional_properties and equip then
		for name,additional in pairs(prop_cfg.additional_properties) do
			--local name = additional[1]
			property[name] = property[name] + additional
		end
	end
end

--需要克隆的数据
local base_property = 
{
    "normal_attack", "special_attack", "passive_skill", 
    "element_relative", "momentum_type", "attack_range", "race",
    "real_damage", "speed", "hit", "dodge", "dodge_reduce", "resistance", 
    "magical_accurate", "block", "block_damage_reduction", "parry", 
    "counterattack", "counterattack_damage", "crit", "toughness", "crit_damage", 
    "dizziness_resistance", "sleep_resistance", "paralysis_resistance", 
    "charm_resistance", "silence_resistance", "detained_resistance", "ridicule_resistance", 
    "plain", "mountain", "forest", "lake", "coastal", "cave", "wasteland", "citadel", 
    "sunny", "rain", "cloudy", "snow", "fog"
}

--计算英雄相关属性
function GetProperty(cfg, bringup, level, id, equipments, runes, grade_level)
    --构建基础属性
    --local property = table.deep_clone(cfg)
    local property = {}
    for k,v in pairs(base_property) do
        property[v] = cfg[v]
    end
    
    property.level = level
    property.physical_attack = {}
    property.magical_attack = {}
    property.id = id

    --培养加成
    property.strength = cfg.strength + bringup.strength
    property.agility = cfg.agility + bringup.agility
    property.intelligence = cfg.intelligence + bringup.intelligence

    --军阶加成
    if grade_level>0 then
        for k,v in pairs(grade_cfg[grade_level].property) do
            property[k] = property[k] + v
        end
    end
    
    --等级成长
    local multiple = level-1
    property.life = cfg.life + multiple*cfg.life_per_upgrade
    property.physical_attack.min = cfg.physical_attack + multiple*cfg.physical_attack_per_upgrade
    property.physical_defense = cfg.physical_defense + multiple*cfg.physical_defense_per_upgrade
    property.magical_attack.min = cfg.magical_attack + multiple*cfg.magical_attack_per_upgrade 
    property.magical_defense = cfg.magical_defense + multiple*cfg.magical_defense_per_upgrade
    
    --装备
    property.physical_attack.max = property.physical_attack.min
    property.magical_attack.max = property.magical_attack.min
    for location,val in pairs(equipments) do
        local prop, equip = val[1],val[2]
        local prop_cfg = prop_cfgs[prop.kind]
        Add2property(property, prop_cfg, equip)
        for i=0,2 do
            if equip.holes[i]==C.kHoleInlayed then
                Add2property(property, prop_cfgs[equip.gems[i]], nil)
            end
        end
    end

    --符文
    for k,v in pairs(runes) do
        if k=='physical_attack' or k=='magical_attack' then
            property[k].min = property[k].min + v
            property[k].max = property[k].max + v
        else
            property[k] = property[k] + v
        end
    end
    
    --力敏智修正配置
    for name,property_fixed in pairs(property_cfgs) do
        for k,v in pairs(property_fixed) do
            if k=='physical_attack' or k=='magical_attack' then
                property[k].min = property[k].min + property[name] * level * v
                property[k].max = property[k].max + property[name] * level * v
            else
                property[k] = property[k] + property[name] * level * v
            end
        end
    end
    
    --速度修正
    property.speed = property.speed + property.agility
    
    return property
end

--取英雄装备信息
local function GetOfflinePlayerHeroEquipment(uid,id)
    local hero = GetOfflinePlayerHero(uid, id)
    if not hero.equipment then
        hero.equipment = db.ReadOfflineHeroEquipment(uid,id)
    end
    return hero.equipment
end

--通过玩家ID取玩家出战英雄ID加入链表
local function GetPlayerArmy(uid)
    local player = online_players[uid]
    if player then									--玩家在线, 直接返回在线玩家对象
        return player.GetArmySimpleInfo()
    end

    player = GetOfflinePlayer(uid)					--玩家不在线, 取离线玩家对象
    if not player.army then
        local army_info = new('PlayerArmy')
        local res = conn:query('select id,level from hero where player='..uid..' and status=1 and location>0')
        for _,row in ipairs(res) do
            army_info.heros[army_info.count] = {row.id, row.level}
            army_info.count = army_info.count+1
            if army_info.count>=5 then break end
        end
        player.army = army_info
    end
    
    return player.army
end

--获取玩家科技
local function GetOfflinePlayerSkills(uid)
    local res = conn:query('select id,level from skill where player=' .. uid)
    local Skills = {}
    for _,row in pairs(res) do
        Skills[row.id] = row.level
    end
    return Skills
end

--应用科技阵形加成效果
function AddSkillsEffect(property, skills, array, hero_location)
    local function ApplyEffect(name, value, isScience)
        local wait_per_queue = {}
        if name=='physical_attack' or name=='magical_attack' then
            property[name].min = property[name].min + value
            property[name].max = property[name].max + value
        elseif string.sub(name, #name-3)=='_per' and isScience then
            --百分比加成，加入队列，等会儿再乘
            local per_name = string.sub(name, 0, #name-4)
            if not wait_per_queue[per_name] then wait_per_queue[per_name] = 0 end
            
            wait_per_queue[per_name] = wait_per_queue[per_name] + value
        else
            property[name] = (property[name] or 0) + value
        end
        
        if isScience then
            --先加减，再乘除
            for per_name, per_value in pairs(wait_per_queue) do
                if per_name=='physical_attack' or per_name=='magical_attack' then
                    property[per_name].min = property[per_name].min * (1 + per_value)
                    property[per_name].max = property[per_name].max * (1 + per_value)
                else
                    property[per_name] = property[per_name] * (1 + per_value)
                end
            end
        end
    end
    for id,level in pairs(skills) do
        if not science_cfg[id] then print("AddSkillsEffect",id) break end
        if not science_cfg[id][level] then print("AddSkillsEffect",id,level) break end
        local gain = science_cfg[id][level].gain
        if gain then
            for gain_name,value in pairs(gain) do
                if science_map[id].type==2 then
                    --城建科技，无视掉
                elseif science_map[id].type==3 then
                    if array==science_array_[id] then
                        --阵形科技，因为阵形都有对应的生效位置，所以需要检查hero_location
                        local effect = array_cfgs[value][level]
                        
                        --增益
                        if effect.gain then
                            for _,location_gain in ipairs(effect.gain) do
                                local location, name, array_value = location_gain[1],location_gain[2],location_gain[3]
                                if location==hero_location then
                                    ApplyEffect(name, array_value)
                                end
                            end
                        end
                        
                        --减益（因为在转表的时候，已经把数值转为负数了，所以这里一样的用ApplyEffect接口）
                        if effect.debuff then
                            for _,location_debuff in ipairs(effect.debuff) do
                                local location, name, array_value = location_debuff[1],location_debuff[2],location_debuff[3]
                                if location==hero_location then
                                    ApplyEffect(name, array_value)
                                end
                            end
                        end
                        
                        --前中后，加上对应的速度
                        if hero_location>0 and effect.speed and property.speed then
                            local tmp,_ = math.modf((hero_location+2)/3)
                            property.speed = property.speed + effect.speed[tmp]
                        end
                    end
                elseif science_map[id].type==1 then
                    --战斗科技
                    ApplyEffect(gain_name, value, true)
                else
                    print("未知科技类型", id, science_map[id])
                end
            end
        end
    end
    
    --
    property.momentum = 0
    
    --血量取整
    property.life = math.floor(property.life)
    property.max_life = property.life
end

--通过ID取出战英雄信息
function GetPlayerHerosGroup(uid, all_in_group)

    local player = online_players[uid]
    if player then									--玩家在线, 直接返回在线玩家对象
        return player.GetHerosGroup(all_in_group)
    end

    player = GetOfflinePlayer(uid)					--玩家不在线, 取离线玩家对象
    
    --获取离线阵形
    if not player.array then
        player.array = GetPlayerBaseInfo(uid).game_info.array
    end

    --获取离线科技
    if not player.skills then
        player.skills = GetOfflinePlayerSkills(uid)
    end
    
    --获取离线英雄组属性
    if not player.group then
        local group = {}
        local equipments = {}

        local player_army = GetPlayerArmy(uid, all_in_group)		--取出战英雄链表
        for i=0, player_army.count-1 do
            local id = player_army.heros[i].sid
            local cfg = hero_cfgs[id]

            --取英雄对象
            local hero = GetOfflinePlayerHero(uid, id)

            --取离线英雄信息(等级、位置、培养属性)
            if not hero.hero_info then
                hero.hero_info = db.ReadOfflineHeroInfo(uid, id)
            end

            --取英雄装备信息
            if not hero.equipment then
                hero.equipments = GetOfflinePlayerHeroEquipment(uid, id)
            end

            --取符文信息
            if not hero.runes then
                hero.runes = GetOfflineRunesProperty(uid, id)
            end
            
            local p = GetProperty(cfg, hero.hero_info.bringup, hero.hero_info.level, id, hero.equipments, hero.runes, GetGradeLevel(uid))
            
            --科技和阵形加成
            AddSkillsEffect(p, player.skills, player.array, hero.hero_info.location)
            
            --屏蔽属性
            local forbid_property = {"dodge", "resistance", "parry", "block", "counterattack"}
            for _,name in pairs(forbid_property) do
                if cfg[name]==-1 then
                    p[name] = 0
                end
            end
            
            
            equipments[hero.hero_info.location] = {}
            for location, v in pairs(hero.equipments) do 
                equipments[hero.hero_info.location][location] = {id=v[1].id, kind=v[1].kind}
            end
            
            group[hero.hero_info.location] = p
        end

        player.group = group
        player.equipments = equipments
    end

    return table.deep_clone(player.group), player.array, player.equipments
end


--processor


local function GetPlayerEquipment(uid, id)
    local player = online_players[uid]
    if player then	
		return player.GetEquipment(id)
	else
		return db.ReadPlayerEquipment(uid, id)
	end
end

processor[C.kGetPlayerEquipment] = function(msg, uid)
	local get = cast('const GetPlayerEquipment&', msg)
	if get.player==uid then return end
	local result = new('PlayerEquipment', GetPlayerEquipment(get.player, get.id))
	return result
end

processor[C.kGetPlayerArmy] = function(msg)
    local id = cast('const GetPlayerArmy&', msg).player
    return GetPlayerArmy(id)
end

processor[C.kGetOtherPlayerHerosInfo] = function(msg)
	local get = cast('const GetOtherPlayerHerosInfo &', msg)
	local ret = new('OtherPlayerHerosInfo')
	local heros_info,_,heros_equipments = GetPlayerHerosGroup(get.uid, true)
	if heros_info then 
		for hero_location,hero in pairs(heros_info) do 
			ret.heros_info[ret.count].property = {hero.id, 1, hero.level, 0, 0, hero.life, hero.strength, hero.agility, hero.intelligence, hero.speed, fight_power.GetHeroFightPower(hero)}
--			print(hero.id, hero.status, hero.level, 0, 0, hero.hp, hero.strength, hero.agility, hero.intelligence, hero.speed, fight_power.GetHeroFightPower(hero))

			for location, v in pairs(heros_equipments[hero_location]) do 
				assert(location>=0 and location<=7)
				ret.heros_info[ret.count].equipments[location] = {v.id, v.kind}
			end
			
			ret.count = ret.count+1
		end
	end
	return ret
end

function ProcessGateMsg(head, msg)
    local f = processor[head.type]
    if f then
        local result, bytes = f(msg, head.aid)
        if result then
            head.type = result.kType
            C.Send2Gate(head, result, bytes or sizeof(result))
            assert(head.type>=C.kGameReturnBegin)
        end
    end
end

function PlayerEnter(id)
    offline_players[id] = nil
end
