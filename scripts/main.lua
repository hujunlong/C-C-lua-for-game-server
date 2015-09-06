math.randomseed(os.time())

require('my_ffi')
require('player')
require('data')
require('guild')
require('guild_war')
require('arena_interaction')
require('escort_interaction')
require('world_boss')
require('playground.playground')
require('tools.task_sch')
require('world_war')
require('GM')
require('assistant')
require('auction')
require('territory')
require('db')
require('grade')
require('welcome')
local config = require('config.global')

require('tools.json')

local ffi = require('ffi')

local sizeof = ffi.sizeof
local new = ffi.new
local C = ffi.C
local cast = ffi.cast
local g_players = {}



function ProcessMsgFromDb(h, msg)
	local head = cast('const MqHead&', h)
	local uid = head.aid
	if head.type==C.kPlayerBaseInfo then
		local player_info = cast('const PlayerBaseInfo&', msg)
		g_players[uid] = CreatePlayer(uid, player_info)
	end
	local player = g_players[uid]
	if player then player.ProcessDbMsg(head.type, msg, head.flag) end
end

--local log_file = io.open('log.txt', 'w')

function ProcessMsgFromGate(h,msg,len)
	local head = cast('MqHead&', h)
	local uid = head.aid
--	log_file:write(tostring(head.type)..'  ')
--	log_file:flush()
	if head.type==C.kUserExit then
		local player = g_players[uid]
		if player then player.Destroy() end
		g_players[uid] = nil
	elseif head.type==C.kUserEnter then
	elseif head.type==C.kWelcomeToGame then
		welcome.WelcomeToGame(uid)
	end
	local player = g_players[uid]
	if player then player.ProcessGateMsg(head,msg,len) end
	data.ProcessGateMsg(head, msg)
end

function ProcessMsgFromGM(h,msg,len)
	local head = cast('MqHead&', h)
	
	if len>0 then
		msg = json.decode(ffi.string(msg, len))
	else
		msg = nil
	end

	local result = nil
	if msg then
        local player = g_players[head.aid]
		if head.type==C.kGMSendMail then
			result = GM.ProcessGMMsg(head, msg, player)
		elseif player and player.IsPlayerReady() then
			result = player.ProcessGMMsg(head, msg)
		elseif not player then  
			result = GM.ProcessGMMsg(head, msg)
		end
		-- 在用户数据传输途中，不处理GM消息
	else
		--JSON解析失败
		result = {result=C.kGMJsonFail}
	end
	if result then
		local str = json.encode(result)
		local ret = ffi.new('JsonString', #str, str)
		
		C.Send2GM(head, ret, 2 + #str)
    else
        print("警告：没有返回GM消息",head.aid,head.type)
	end

end

function RunOnce()
--	for _,player in pairs(g_players) do
--		player.RunOnce()
--	end

	--检查护送是否到期
	EscortReward()

	--检查BOSS战状态
	CheckBossStatus()

	--拍卖行物品是否过期
	AuctionExpiration()
	
	--检查领地信息｛玩家5天未上线， 资源点占领上限｝
	TerritoryTrigger()

	--刷新工会战信息
    if guild_war.guild_war_step >= 4 then
        guild_war.RefreshGuildWarInfo()
    end
end

function ReloadModified() --热更新
	print"start update code"
	UpdateAchievement()
end

local function ReplenishPlayerStatus()
	for _,player in pairs(g_players) do
		player.ReplenishStatus()
	end
--	print('Online players:'..table.size(g_players))
end

local function UpdateLastActiveTime()
	local update = new('UpdateMultiFeilds2Value', C.ktStatus, C.kfPlayer, C.kfLastActiveTime, os.time())
	for uid,player in pairs(g_players) do
--		player.UpdateField(C.ktStatus, C.kInvalidID, {C.kfLastActiveTime, 0} )
		update.indexs[update.count] = uid
		update.count = update.count+1
		if update.count>=update.kMaxCount then break end
		
		player.UpdateLastActiveTime()
	end
	local head = new('MqHead', -1, update.kType, -1)
	if update.count>0 then
        C.Send2Db(head, update, sizeof(update))
        
        update.table_name = C.ktTerritoryInfo
        C.Send2Db(head, update, sizeof(update))
    end
end

local function UpdateTrainNum()        
    for _,player in pairs(g_players) do
        player.UpdateTrainNum()
    end
end

local function ResetBuyTrainNum()
    db.UpdateBuyTrainNum()
    for _,player in pairs(g_players) do
         player.ResetBuyTrainNum()
    end
end


--Timer ID define
local timers = {kReplenishPlayerStatus=nil}

timers.kReplenishPlayerStatus = ffi.CreateTimer(ReplenishPlayerStatus, 5*60) --5 minutes

ffi.CreateTimer(UpdateLastActiveTime, 15)

--重置购买次数
CreateTaskSch_Day(config.hero_train.update_buy_train_time, ResetBuyTrainNum)
--刷新玩家可用训练次数
ffi.CreateTimer(UpdateTrainNum, config.hero_train.refresh_train_time)

print(os.date('%x %X', os.time()))
data.Initialize(g_players)

--道具初始化
InitProp(g_players)
--支线
InitExplore( g_players )

--初始化公会相关数据
guild.InitGuilds(g_players)

--初始化公会战场相关数据
guild_war.InitGuildWarFields()

--初始化游乐场相关数据
InitPlayGround( g_players )

--小助手初始化
InitAssistant( g_players )

--幸运树初始化
InitTree( g_players )
InitRewardForDaysAgo(g_players)
ResetLuckyDraw(g_players)

EscortInitialize(g_players)
WorldBossInitialize(g_players)
WorldWarInitialize(g_players)

local function ResetVIPCount()
    for _,player in pairs(g_players) do
        player.ResetVIPCount()
    end
    data.ResetVipCount()
end

local function ResetTower()
    for _,player in pairs(g_players) do
        player.ResetTower()
    end
    data.ResetTower()
end

local function ResetBossSection()
    for _,player in pairs(g_players) do
        player.ResetBossSection()
    end
	data.ResetBossSection()
end

local function ResetAll()
	print('状态重置开始', os.time())
	ResetVIPCount()
	ResetTower()
	ResetArena()
	ResetEscort()
	ResetWorldBossInfo()
	ResetTerritory()
	ResetGrade()
	
	ResetAssistant()
	ResetStamina()
	ResetTree()
	ResetFished()
	ResetPlaygroundPropBuyCount()
	ResetTurntable()
	ResetRewardForDaysAgo()
	ResetLuckyDraw()
	ResetBossSection()
	print('状态重置结束', os.time())
	
    --下一天广播通知
    local NextDayOpen = new('NextDayOpen')
    GlobalSend2Gate(-1, NextDayOpen)
end

CreateWaitableTimerForResetAction(action_type.kEverydayReset, config.kGlobalResetTime, ResetAll)

