local race_time_ctf = require("config.race_dragon_time")
local race_limit_ctf = require("config.race_dragon_limit")
local action_cft = require("define.action_id")
local reward_cfg = require("config.race_dragon_reward")
local coe_cfg = require("config.race_dragon_reward_coefficient")
require('achievement')
require('global_data')

local g_ = require('config.global')

local ffi = require("ffi")
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

require('tools.time')
require('tools.table_ext')


---------------------------------------
local race_timer = nil
local race_step = nil
local race_season = nil	--赛季
local time_points = {}
local online_players = {}

------------------------------------------


--初始化,最主要是获取在线玩家列表
function InitRaceDragon( g_players )
	online_players = g_players
end


local function ConvertString2timeWithWday( wday, strTime, cur_time )
	local date = os.date("*t", cur_time)

	local colon = string.find(strTime, ":")
	local hour = string.sub(strTime, 0, colon - 1)
	local min = string.sub(strTime, colon + 1)

	local dst_time = os.time({year = date.year, month = date.month, day = date.day, hour = hour, min = min})

	if date.wday == 1 then
		date.wday = 7
	else
		date.wday = date.wday - 1
	end
	dst_time = dst_time + 86400*( wday - date.wday )

	return dst_time
end

local function GetNearestNextTime( time_array, cur_time )
	local tmp = nil
	local index = nil
	for i,v in ipairs(time_array) do
		if cur_time<v then
			tmp = v
			index = i-1
			break
		end
	end
	return tmp,index
end


----------------------------------------------------
local race_guess_info = {}		--赛季竞猜信息
race_guess_info.peoples = {}	--竞猜人数
race_guess_info.money = {}		--竞猜总额
race_guess_info.odds = { 11,12,13,14,15,16,17,18,19,20,21,22 } --赔率
---

--
--获取数据库信息进行初始化
local __race_info = db.GetRaceDragonGuessInfo()
race_guess_info.peoples[1] = __race_info.pp1
race_guess_info.peoples[2] = __race_info.pp2
race_guess_info.peoples[3] = __race_info.pp3
race_guess_info.peoples[4] = __race_info.pp4
race_guess_info.peoples[5] = __race_info.pp5
race_guess_info.peoples[6] = __race_info.pp6
race_guess_info.peoples[7] = __race_info.pp7
race_guess_info.peoples[8] = __race_info.pp8
race_guess_info.peoples[9] = __race_info.pp9
race_guess_info.peoples[10] = __race_info.pp10
race_guess_info.peoples[11] = __race_info.pp11
race_guess_info.peoples[12] = __race_info.pp12
--
race_guess_info.money[1] = __race_info.mm1
race_guess_info.money[2] = __race_info.mm2
race_guess_info.money[3] = __race_info.mm3
race_guess_info.money[4] = __race_info.mm4
race_guess_info.money[5] = __race_info.mm5
race_guess_info.money[6] = __race_info.mm6
race_guess_info.money[7] = __race_info.mm7
race_guess_info.money[8] = __race_info.mm8
race_guess_info.money[9] = __race_info.mm9
race_guess_info.money[10] = __race_info.mm10
race_guess_info.money[11] = __race_info.mm11
race_guess_info.money[12] = __race_info.mm12
-----------------------------------------------------

--赛道区段
local race_section = g_.race_dragon.kRunwaySection
--
--info
--final:是否是决赛,true,false
local function CalcDragonSpeed( info, final )
	--
	local pro = nil
	local power = info.power							--
	local speed,speed_n,speed_s,speed_w = 0, 0, 0, 0	--
	local consume,consume_n,consume_s = 0,0,0

	local bit_tmp = 0

	--------
	--2:30-24: section<7位>
	--2:23-0 : 跑路<2位表示一个状态>
	--1:31-0 : < 0 正常,, 1 特殊,, 2,,虚弱  3,,冲刺 >
	info.live2 = bit.lshift( race_section, 24 )
	info.live1 = 0
	--
	--start of race
	pro = math.random()
	if pro<=info.pro[1] then
		--
		speed = info.speed
		consume = info.speed*0.25+10
		if consume>power then
			--体力不足,使用普通速度
			speed = info.speed*0.75
			consume = speed*0.25
			if consume<=power then
				power = power - consume
			end
		else
			--起跑特殊触发
			info.live1 = info.live1 + 1
			power = power - consume
		end
	else
		speed = info.speed*0.75
		consume = speed*0.25
		if consume<=power then
			power = power - consume
		end
	end
	--
	------------------------
	--middle of race
	speed_n = info.speed*0.75
	consume_n = speed_n*0.25
	--
	speed_s = info.speed*0.9
	consume_s = speed_s*0.25
	--
	speed_w = info.speed*0.55
	--
	for i=2, race_section, 1 do
		power = power + info.resume
		pro = math.random()
		--
		if i==race_section-2 then	--倒数第三节
			--print( "dragon: " .. info.dragon .. " 特率: " .. info.pro[2] .. " 冲率: " .. info.pro[3] .. "   冲刺前体力: " .. power )
			if pro<=info.pro[3] and power>=30 then
				--冲刺状态
				--print( "dragon: " .. info.dragon .. " " .. i .. " 触发冲刺" )
				if i<=16 then
					info.live1 = info.live1 + 3*2^( (i-1)*2 )
				else
					info.live2 = info.live2 + 3*2^( (i-17)*2 )
				end
				speed = speed + info.speed*3
				break
			end
		end
		--
		if pro<=info.pro[2] and consume_s<=power then
			--特殊事件
			if i<=16 then
				info.live1 = info.live1 + 2^( (i-1)*2 )
			else
				info.live2 = info.live2 + 2^( (i-17)*2 )
			end
			--print("dragon: " .. info.dragon .. " " .. i .. " 触发特殊:" .. info.live1)
			power = power - consume_s
			speed = speed + speed_s
		else
			if consume_n>power then
				--虚弱状态
				if i<=16 then
					info.live1 = info.live1 + 2^( (i-1)*2+1 )
				else
					info.live2 = info.live2 + 2^( (i-17)*2+1 )
				end
				--print("dragon: " .. info.dragon .. " " .. i .. " 触发虚弱:" .. info.live1)
				speed = speed + speed_w
			else
				--正常速度
				speed = speed + speed_n
				power = power - consume_n
			end
		end
	end
	--

	info.a_speed = speed
end
--
local function InitMassSelect( )
	local ret = {}
	--info.order	报名顺序
	--info.rank		名次
	--info.his_rank	历史名次
	--info.dragon	id
	--info.player	id
	--info.speed	速度
	--info.a_speed	全程速度
	--info.pro		几率
	--info.power	体力
	--info.intellect智力
	--info.resume	回复
	local res = db.GetSignupDragon()
	if res~=nil then
		for _, v in pairs( res ) do
			local info = {}
			info.pro = {}
			info.order = v.order
			info.dragon= v.dragon
			info.player= v.player
			info.his_rank = v.his_rank
			info.speed = (v.strength*0.15 + v.agility*0.52 + v.intellect*0.33)*0.2 + 50
			info.power = v.strength*0.1 + 50
			info.resume= v.strength*0.03 + v.intellect*0.01
			info.intellect = v.intellect

			info.pro[1] = 0.1 + v.intellect*0.0003
			info.pro[2] = info.pro[1]
			info.pro[3] = info.pro[1]
			--
			ret[#ret+1] = info
		end
	end
	return ret
end

--获取前十的基本信息提示给客户端
--
local topten_info = nil
--
local function GetToptenDragonInfo()
	topten_info = db.GetToptenDragon()
	if topten_info then
		for _,v in ipairs( topten_info ) do
			if v.ch_name==1 then
				v.d_name = ffi.string( v.d_name, sizeof(v.d_name) )
			end
		end
	end
end

--获取赛龙当前赛季
local function GetRaceDragonCurSeason( cur_step )
	--
	local season = db.GetRaceDragonLastSeason()
	if cur_step<4 then
		season = season + 1
	end
	return season
end

local function InitTopten( )
	local ret = {}
	--info.order	报名顺序
	--info.rank		名次
	--info.his_rank	历史名次
	--info.raceway  赛道
	--info.dragon	id
	--info.player	id
	--info.kind		kind
	--info.d_state	状态
	--info.speed	速度
	--info.a_speed	全程速度
	--info.pro		几率
	--info.power	体力
	--info.resume	回复
	--info.live1	现场的表现记录
	--info.live2
	--info.ch_name
	--info.d_name
	--info.p_name
	local res = db.GetToptenDragon()
	if res~=nil then
		for _, v in pairs( res ) do
			local info = {}
			info.pro = {}
			info.order = v.order
			info.his_rank = v.his_rank
			info.raceway=v.raceway
			info.dragon= v.dragon
			info.player= v.player
			info.speed = (v.strength*0.15 + v.agility*0.52 + v.intellect*0.33)*0.2 + 50
			info.power = v.strength*0.1 + 50
			info.resume= v.strength*0.03 + v.intellect*0.01
			info.ch_name = v.ch_name
			if v.ch_name==1 then
				info.d_name = ffi.string( v.d_name, sizeof(v.d_name) )
			end
			--info.p_name = ffi.string( v.p_name, sizeof(v.p_name) )
			info.p_name = v.p_name
			info.d_state= v.d_state
			info.kind  = v.kind
			--
			if v.d_state==1 then
				info.pro[1] = 0.3 + v.intellect*0.0005
				info.pro[2] = 0.1 + v.intellect*0.0005
				info.pro[3] = info.pro[1]
			elseif v.d_state==2 then
				info.pro[1] = 0.1 + v.intellect*0.0003
				info.pro[2] = info.pro[1]
				info.pro[3] = info.pro[1]
			else
				info.pro[1] = v.intellect*0.0002
				info.pro[2] = 0.1 + v.intellect*0.0003
				info.pro[3] = v.intellect*0.0003
			end
			--
			ret[#ret+1] = info
		end
	else
		return nil
	end

	return ret
end

--计算龙的状态
local function CalcDragonState( total_i, d_info )
	local rand_tmp = 0
	local i3,i7 = 0, 0

	i3 = d_info.intellect*3
	if i3>=total_i then		-- 直接肯定是优
		d_info.d_state = 1
	else
		i7 = d_info.intellect*7
		if i7>=total_i then				--优良里随机
			rand_tmp = math.random(1,i7)
			if rand_tmp<=i3 then
				d_info.d_state = 1
			else
				d_info.d_state = 2
			end
		else
			rand_tmp = math.random(1,total_i)
			if rand_tmp<=i3 then
				d_info.d_state = 1
			elseif rand_tmp<=i7 then
				d_info.d_state = 2
			else
				d_info.d_state = 3
			end
		end
	end
end

local function compare( a, b )
	if a.a_speed>b.a_speed then
		return true
	elseif a.a_speed==b.a_speed then
		if a.order<b.order then
			return true
		else
			return false
		end
	else
		return false
	end
end
--
--海选前十
local function RaceDragonMassSelect()
	local res = InitMassSelect()

	for _, v in ipairs( res ) do
		CalcDragonSpeed( v, false )
	end

	local race_ways = { 1,2,3,4,5,6,7,8,9,10 }
	local race_way_num = 10
	local pos = 0

	--总智力
	local total_i = 0
	
	local tbl_data = {}

	table.sort( res, compare )
	for i,v in ipairs( res ) do
		if i>10 then
			--保存非前10的名次
			if online_players[v.player] then
				if i<v.his_rank or v.his_rank==0 then
					--刷新在线玩家的龙的历史名次
					tbl_data.type = 1
					tbl_data.id = v.dragon
					tbl_data.data = i
					online_players[v.player].SetPlaygroundInfo( tbl_data )
				end
				online_players[v.player].RecordAction(action_cft.kPlaygroundRaceDragonRank,i)
			else
				RecordOfflinePlayerAction(v.player,action_cft.kPlaygroundRaceDragonRank, i)
			end
			v.rank = i
			db.SaveRaceDragonMassRank( v.dragon, v.rank, v.his_rank )
		else
			--前10名暂时不要保存名次,只保存赛道
			pos = math.random(1,race_way_num)
			v.raceway = race_ways[pos]
			table.remove( race_ways, pos )
			race_way_num = race_way_num - 1
			--
			total_i = total_i + v.intellect
		end
		--print( "dragon: " .. v.dragon .. " rank:" .. i .. " speed: " .. v.a_speed .. "  order:" .. v.order)
	end

	local _size = #res
	for i=1,10,1 do
		if i>_size then
			break
		end
		CalcDragonState( total_i, res[i] )
		db.SaveRaceDragonToptenInfo( res[i].dragon, res[i].d_state, res[i].raceway )
	end
end
--
--决赛
local function RaceDragonToptenFinal()
	--
	local res = InitTopten()
	if res==nil then
		return nil
	end

	for _,v in ipairs(res) do
		CalcDragonSpeed( v, true)
	end

	table.sort( res, compare )

	--成就
	if online_players[res[1].player] then
		online_players[res[1].player].RecordAction(action_cft.kPlaygroundRaceDragonWin,1)
	else
		RecordOfflinePlayerAction(res[1].player,action_cft.kPlaygroundRaceDragonWin,1)
	end
	
	local tbl_data = {}
	--
	for i,info in ipairs(res) do
		if online_players[info.player] then
			if i<info.his_rank or info.his_rank==0 then
				--刷新在线玩家的龙的历史名次
				tbl_data.type = 1
				tbl_data.id = info.dragon
				tbl_data.data = i
				online_players[info.player].SetPlaygroundInfo( tbl_data )
			end
			--修改报名状态
			tbl_data.type = 2
			tbl_data.id = info.dragon
			tbl_data.data = 0
			online_players[info.player].SetPlaygroundInfo( tbl_data )
			online_players[info.player].RecordAction(action_cft.kPlaygroundRaceDragonRank,i)
		else
			RecordOfflinePlayerAction(info.player, action_cft.kPlaygroundRaceDragonRank, i)
		end
		info.rank = i
		db.SaveRaceDragonToptenRank( race_season, info )
		--print( "dragon: " .. info.dragon .. " rank:" .. i .. " speed: " .. info.a_speed .. "  order:" .. info.order)
	end

	db.ResetRaceDragonSignupState()
	--返回名次
return res
end

local function RaceDragonReward( champion_raceway )
	--发钱发装备啦
	--从数据库获取投注玩家信息
	--注意玩家可以投注多个赛道
	local send_ret = false	--邮件发送结果
	local res = nil
	local cur_tt = os.time()
	local subject = string.format(g_.mail.kRaceDragonGuessSubject,race_season)
	local win_content = nil
	local lose_content = nil
	local b_notify = false

	res = db.GetRaceDragonGuessInfoFinal()
	if res then

	--判断单双
	local sd = math.fmod(champion_raceway,2)
	if sd==1 then
		sd=11
	else
		sd=12
	end

	local reward_info = {}

	for i, v in pairs( res ) do
		--竞猜信息
		if reward_info[v.player]==nil then
			--
			reward_info[v.player] = {}
			reward_info[v.player].win_m  = 0
			reward_info[v.player].capital = 0
			reward_info[v.player].lose_m = 0
		end

		if v.guess==champion_raceway or v.guess==sd then
			--买中赛道或买中单双
			--计算本金
			reward_info[v.player].capital = reward_info[v.player].capital + v.money*10000
			--
			reward_info[v.player].win_m = reward_info[v.player].win_m + v.money * 10000 * race_guess_info.odds[v.guess]
			--成就
			if online_players[v.player] then
				online_players[v.player].RecordAction(action_cft.kPlaygroundRaceDragonGuessRight,1)
			else
				RecordOfflinePlayerAction(v.player, action_cft.kPlaygroundRaceDragonGuessRight, 1)
			end
		else
			--输一半钱哦
			reward_info[v.player].lose_m = reward_info[v.player].lose_m + v.money*5000
		end
	end

	for i_player, v in pairs( reward_info ) do
		if v.win_m~=0 then
			--成就
			if online_players[i_player] then
				online_players[i_player].RecordAction(action_cft.kPlaygroundRaceDragonGotReward, v.win_m-v.capital)
			else
				RecordOfflinePlayerAction(i_player, action_cft.kPlaygroundRaceDragonGotReward, v.win_m-v.capital)
			end
			win_content = string.format(g_.mail.kRaceDragonGuessWinContent,race_season,v.win_m)
			if online_players[i_player]==nil then
				b_notify=false
				UpdateDeltaField( C.ktBaseInfo, C.kfPlayer, i_player, C.kfSilver, v.win_m )
			else
				b_notify=true
				online_players[i_player].ModifySilver( v.win_m )
			end
			send_ret = db.SendMail(i_player, cur_tt, subject, win_content, nil, b_notify)
		end
		if v.lose_m~=0 then
			lose_content = string.format(g_.mail.kRaceDragonGuessLoseContent, race_season)
			if online_players[i_player]==nil then
				b_notify=false
				UpdateDeltaField( C.ktBaseInfo, C.kfPlayer, i_player, C.kfSilver, v.lose_m )
			else
				b_notify=true
				online_players[i_player].ModifySilver( v.lose_m )
			end
			send_ret = db.SendMail(i_player, cur_tt, subject, lose_content, nil, b_notify)
		end
	end
	end
	-----------------------
	--根据排名对报名赛龙的玩家发奖励
	--报名只能是一条龙
	local race_win_content = nil
	res = db.GetRaceDragonSignupInfoFinal( -1 )
	local reward_index = 1
	local reward = nil
	local r1,r2
	if res then
	for i, v in pairs( res ) do
		reward = reward_cfg[reward_index]
		if reward.rank[2]~=-1 and i>reward.rank[2] then
			reward_index = reward_index + 1
			reward = reward_cfg[reward_index]
		end

		--
		r1 = reward.cardinal*coe_cfg[v.level].coefficient
		r2 = reward.prestige
		if online_players[v.player]==nil then
			b_notify=false
			UpdateDeltaField( C.ktBaseInfo, C.kfPlayer, v.player, C.kfSilver, r1 )
			UpdateDeltaField( C.ktBaseInfo, C.kfPlayer, v.player, C.kfPrestige, r2 )
		else
			b_notify=true
			online_players[v.player].ModifySilver( r1 )
			online_players[v.player].ModifyPrestige( r2 )
		end

		race_win_content = string.format(g_.mail.kRaceDragonGotRank,i, r1, r2)
		--print( race_win_content )
		send_ret = db.SendMail(v.player, cur_tt, subject, race_win_content, nil, b_notify)
	end
	end
	--
	--删除报名信息
	--print('delete signup dragon')
	db.DelRaceDragonInfo()
end

----------
--前十信息
local final_info = nil
----------
local head_   = new("MqHead", 0, C.kNotifyRaceDragonCurStep, -1)
local notify_ = new("NotifyRaceDragonCurStep")
--
local function RaceDragonTimer()
	local cur_time = os.time()

	--1 报名;  2 海选竞猜;	3 不可操作时间 ;   4 决赛;	5 结算并准备下一个赛季
	time_points[1] = ConvertString2timeWithWday( race_time_ctf[1].sign_up.wday,  race_time_ctf[1].sign_up.time,  cur_time )
	time_points[2] = ConvertString2timeWithWday( race_time_ctf[1].guess.wday,    race_time_ctf[1].guess.time,    cur_time )
	time_points[3] = ConvertString2timeWithWday( race_time_ctf[1].frozen.wday,   race_time_ctf[1].frozen.time,   cur_time )
	time_points[4] = ConvertString2timeWithWday( race_time_ctf[1].final.wday, 	 race_time_ctf[1].final.time,    cur_time )
	time_points[5] = ConvertString2timeWithWday( race_time_ctf[1].clearing.wday, race_time_ctf[1].clearing.time, cur_time )

	--使用cur_step是为了错开客户端提前获取到阶段
	local next_time,cur_step = GetNearestNextTime( time_points, cur_time )
	if next_time then
		--
		next_time = next_time - cur_time
		--
	else
		--结算并等待下一个赛季
		next_time = time_points[1] + 604800 - cur_time --7*24*60*60
		cur_step = 5
	end
	--
	--------
	--测试数据
	--next_time = 1234567
	--cur_step = 2
	---------

	if race_timer then
		C.ResetTimer( race_timer, next_time )
		--
		if cur_step<4 then
			final_info=nil
		end

		if cur_step==1 then
			--报名,进入下一个赛季
			race_season = race_season + 1
		elseif cur_step==2 then
			--海选
			RaceDragonMassSelect()
			GetToptenDragonInfo()
		elseif cur_step==4 then
			--决赛
			final_info = RaceDragonToptenFinal()
		elseif cur_step==5 then
			--结算
			if final_info==nil then
				final_info = db.GetRaceDragonToptenRank( race_season )
				if final_info then
					for _,v in ipairs( final_info ) do
						if v.ch_name==1 then
							v.d_name = ffi.string( v.d_name, sizeof(v.d_name) )
						end
					end
				end
			end
			if final_info~=nil then
				RaceDragonReward( final_info[1].raceway )
			else
				print('season: ' .. race_season .. ' final_info is nil')
			end
		end
		--
		--
		race_step = cur_step
		--通知客户端阶段改变
		notify_.step = race_step
		notify_.season = race_season
		if race_step==5 then
			notify_.t_begin = time_points[5]
			notify_.t_end = time_points[1]+86400*7
		else
			notify_.t_begin = time_points[race_step]
			notify_.t_end = time_points[race_step+1]
		end

		for uid,_ in pairs(online_players) do
			head_.aid = uid
			C.Send2Gate( head_, notify_, sizeof(notify_) )
		end
	else
		race_timer = ffi.CreateTimer( RaceDragonTimer, next_time )
		--获取当前赛季
		race_season = GetRaceDragonCurSeason( cur_step )


		if cur_step<4 then
			final_info=nil
		end

		--获取前十信息提供给客户端
		if cur_step==2 or cur_step==3 then
			GetToptenDragonInfo()
			if not topten_info then
				if db.IsHasSignupDragon() then
					--海选
					RaceDragonMassSelect()
					GetToptenDragonInfo()
				end
			end
		elseif cur_step==4 then
			--
			final_info = db.GetRaceDragonToptenRank( race_season )
			if not final_info then
				if db.IsHasToptenRank( race_season ) then
					--决赛
					final_info = RaceDragonToptenFinal()
				end
			end
		elseif cur_step==5 then
			--结算
			if final_info==nil then
				final_info = db.GetRaceDragonToptenRank( race_season )
				if not final_info then
					if db.IsHasToptenRank( race_season ) then
						--决赛
						final_info = RaceDragonToptenFinal()
					end
				else
					for _,v in ipairs( final_info ) do
						if v.ch_name==1 then
							v.d_name = ffi.string( v.d_name, sizeof(v.d_name) )
						end
					end
				end
			end
			if final_info~=nil then
				RaceDragonReward( final_info[1].raceway )
			end
		end
		----
		race_step = cur_step
	end

	print( "赛龙<race_dragon>第 " .. race_season .. " 赛季,当前阶段: " .. race_step )


end


RaceDragonTimer()





function CreateRaceDragon( player, playground )
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local l_active = false


	---
	local player_id = player.GetUID()
	local player_level = nil
	------------------------------------------------------------
	local my_guess = {}	--保存我的投注信息,从数据库获取
	local limit_money = 0	--玩家最大投注额,单位为万
	local my_guess_money = 0		--我总共投入了多少万
	local single_double = false

	--
	local already_signup = 0
	------------------------------------------------------------


	--得到数据库的信息
	db_processor_[C.kPlayGroundRaceInfoResult] = function(msg)
		local race_info = cast("const PlayGroundRaceInfoResult&",msg)
		--报名
		already_signup = race_info.signup;

		--单双
		if race_info.money[10]~=0 or race_info.money[11]~= 0 then
			single_double = true
		end

		--投注信息
		for i=1,12,1 do
			my_guess[i] = race_info.money[i-1]
			my_guess_money = my_guess_money + my_guess[i]
		end
	end

	--玩家获取赛龙当前阶段
	processor_[C.kGetRaceDragonCurStep] = function(msg)
		--1 报名;  2 海选竞猜;	3 不可操作时间 ;   4 决赛;	5 结算并准备下一个赛季
		local ret = new("GetRaceDragonCurStepResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end
		ret.step = race_step
		ret.season = race_season
		if race_step==5 then
			ret.t_begin = time_points[5]
			ret.t_end = time_points[1]+86400*7
		else
			ret.t_begin = time_points[race_step]
			ret.t_end = time_points[race_step+1]
		end
		return ret
	end

	--玩家获取赛龙的时间段
	processor_[C.kGetRaceDragonTime] = function(msg)
		local get = cast("const GetRaceDragonTime&",msg)
		local ret = new("GetRaceDragonTimeResult",0,0)

		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end
		
		--检查数据的有效性
		if get.step<1 or get.step>5 then
			return ret
		end

		if get.step==5 then
			ret.t_begin = time_points[5]
			ret.t_end = time_points[1]+86400*7
		else
			ret.t_begin = time_points[get.step]
			ret.t_end = time_points[get.step+1]
		end
		return ret
	end

	--玩家获取自已的竞猜
	processor_[C.kGetRaceDragonMyGuess] = function(msg)
		local ret = new("GetRaceDragonMyGuessResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end

		--赛道投注信息
		for i=1,12,1 do
			ret.money[i-1] = my_guess[i]
		end

		return ret
	end

	--玩家获取赛季竞猜资讯
	processor_[C.kGetRaceDragonGuessInfo] = function(msg)
		local ret = new("GetRaceDragonGuessInfoResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret,4
		end

		--检查时间段
		if race_step~=2 and race_step~=3 then
			ret.result = C.RACE_DRAGON_NOT_TIME
			return ret
		end

		for i=1,12,1 do
			ret.peoples[i-1] = race_guess_info.peoples[i]
			ret.odds[i-1] = race_guess_info.odds[i]
			ret.money[i-1] = race_guess_info.money[i]
		end

		ret.result = C.RACE_DRAGON_SUCCEEDED
		return ret
	end

	--获取前十龙基本信息
	processor_[C.kGetRaceDragonToptenInfo] = function(msg)
		local ret = new("GetRaceDragonToptenInfoResult")
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret,4
		end
		
		if race_step~=2 and race_step~=3 then
			ret.result = C.RACE_DRAGON_NOT_TIME
			return ret
		end

		local d_name = nil
		if topten_info~=nil then
			ret.len = #topten_info
			for i, v in ipairs( topten_info ) do
				ret.dragon[i-1].his_rank  = v.his_rank
				ret.dragon[i-1].strength  = v.strength
				ret.dragon[i-1].agility   = v.agility
				ret.dragon[i-1].intellect = v.intellect
				ret.dragon[i-1].raceway	  = v.raceway
				ret.dragon[i-1].d_state   = v.d_state
				ret.dragon[i-1].kind	  = v.kind
				ret.dragon[i-1].ch_name   = v.ch_name
				if v.ch_name==1 then
					ret.dragon[i-1].d_name.len= #v.d_name
					copy(ret.dragon[i-1].d_name.str, v.d_name, #v.d_name )
				end
				ret.dragon[i-1].p_name.len= sizeof(v.p_name)
				copy(ret.dragon[i-1].p_name.str, v.p_name, sizeof(v.p_name) )
			end
		else
			ret.len = 0
		end

		ret.result = C.RACE_DRAGON_SUCCEEDED
		
		local bytes = 8 + sizeof(ret.dragon[0])*ret.len
		--
		return ret,bytes
	end

	--玩家获取自已的竞猜金额上限
	processor_[C.kGetRaceDragonMyLimit] = function(msg)
		local ret = new("GetRaceDragonMyLimitResult",0)
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end
		
		--实时获取玩家等级和最大投注金额
		player_level = player.GetLevel()
		limit_money = race_limit_ctf[player_level].limit
		ret.limit = limit_money

		return ret
	end

	--获取赛季排名信息
	processor_[C.kGetRaceDragonSeasonRank] = function(msg)
		local get = cast("const GetRaceDragonSeasonRank&",msg)
		local ret = new("GetRaceDragonSeasonRankResult")
		local info = nil
		if not l_active then
			ret.result = C.eFunctionDisable
			return ret,4
		end

		if get.season>race_season or get.season<1 then
			ret.result = C.RACE_DRAGON_INVALID
			return ret
		end

		if get.season==race_season and final_info~=nil then
			if race_step<4 then
				ret.result = C.RACE_DRAGON_NOT_TIME
				return ret
			end

			info = final_info
			local _size = #info
			ret.len = _size
			for i=1,_size,1 do
				ret.info[i-1].live1 = info[i].live1
				ret.info[i-1].live2 = info[i].live2
				ret.info[i-1].speed = info[i].speed
				ret.info[i-1].rank = info[i].rank
				ret.info[i-1].raceway = info[i].raceway
				ret.info[i-1].kind = info[i].kind
				ret.info[i-1].ch_name = info[i].ch_name
				if info[i].ch_name==1 then
					ret.info[i-1].d_name.len = #info[i].d_name
					copy( ret.info[i-1].d_name.str, info[i].d_name, #info[i].d_name )
				end
				ret.info[i-1].p_name.len = sizeof(info[i].p_name)
				copy( ret.info[i-1].p_name.str, info[i].p_name, sizeof(info[i].p_name) )
			end
		else
			if get.season==race_season and final_info==nil then
				if race_step<4 then
					ret.result = C.RACE_DRAGON_NOT_TIME
					return ret
				end
			end
			info = db.GetRaceDragonToptenRank( get.season )
			if info~=nil then
				local _size = #info
				ret.len = _size
				for i=1,_size,1 do
					ret.info[i-1].live1 = info[i].live1
					ret.info[i-1].live2 = info[i].live2
					ret.info[i-1].speed = info[i].speed
					ret.info[i-1].rank = info[i].rank
					ret.info[i-1].raceway = info[i].raceway
					ret.info[i-1].kind = info[i].kind
					ret.info[i-1].ch_name = info[i].ch_name
					if info[i].ch_name==1 then
						ret.info[i-1].d_name.len = sizeof(info[i].d_name)
						copy( ret.info[i-1].d_name.str, info[i].d_name, sizeof(info[i].d_name) )
					end
					ret.info[i-1].p_name.len = sizeof(info[i].p_name)
					copy( ret.info[i-1].p_name.str, info[i].p_name, sizeof(info[i].p_name) )
				end
			else
				ret.len = 0
			end
		end

		ret.result = C.RACE_DRAGON_SUCCEEDED
		local bytes = 8 + sizeof(ret.info[0])*ret.len
		--
		return ret,bytes
	end

	--报名参与比赛
	processor_[C.kRaceDragonSignup] = function(msg)
		local ret = new("RaceDragonSignupResult",0)
		if not playground.IsRearActive() or not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end
		--检查时间段
		if race_step~=1 then
			ret.result = C.RACE_DRAGON_NOT_TIME
			return ret
		end

		--是否已经报过名
		if already_signup==1 then
			ret.result = C.RACE_DRAGON_SIGNUP
			return ret
		end

		local signup = cast("const RaceDragonSignup&", msg)

		--报名,并写入数据库
		if playground.GetDragonInfo(1,signup.dragon_id) then
			db.RaceDragonSignup( player_id, signup.dragon_id )
		else
			ret.result = C.RACE_DRAGON_INVALID
			return ret
		end

		--设置报名状态
		playground.SetDragonInfo(2, signup.dragon_id, 1 )
		already_signup = 1

		ret.result = C.RACE_DRAGON_SUCCEEDED
		return ret
	end

	--玩家参与竞猜
	processor_[C.kRaceDragonGuess] = function(msg)
		local ret = new("RaceDragonGuessResult", 0 )
		local tmp = nil

		if not l_active then
			ret.result = C.eFunctionDisable
			return ret
		end
		
		--检查时间段
		if race_step~=2 then
			ret.result = C.RACE_DRAGON_NOT_TIME
			return ret
		end

		local guess = cast("const RaceDragonGuess&",msg)

		--检查投注是否超过限制
		if guess.money < 1 then
			ret.result = C.RACE_DRAGON_INVALID
			return ret
		end
		tmp = my_guess_money + guess.money
		--实时获取玩家等级和最大投注金额
		player_level = player.GetLevel()
		limit_money = race_limit_ctf[player_level].limit
		if tmp > limit_money then
			ret.result = C.RACE_DRAGON_LIMIT_MONEY
			return ret
		end

		--检查玩家是否有这么多钱
		if not player.IsSilverEnough(guess.money*10000) then
			ret.result = C.RACE_DRAGON_NOT_ENOUGH
			return ret
		end

		if guess.type==11 or guess.type==12 then
			--单双
			--检查是否已经投注过了
			if single_double then
				ret.result = C.RACE_DRAGON_ALREADY_SELECT
				return ret
			end

		elseif guess.type >= 1 and guess.type <= 10 then
			--赛道
			--检查是否已经投注过
			if my_guess[guess.type]~=0 then
				ret.result = C.RACE_DRAGON_ALREADY_SELECT
				return ret
			end
		else
			ret.result = C.RACE_DRAGON_INVALID
			return ret
		end

		--扣除玩家银币
		player.ModifySilver( -(guess.money*10000) )

		--写入数据库
		player.InsertRow(C.ktPlayGroundRaceGuess,{C.kfPlayGroundRaceGuessGuess,guess.type},{C.kfPlayGroundRaceGuessMoney,guess.money})

		my_guess[guess.type] = guess.money
		my_guess_money = my_guess_money + guess.money
		race_guess_info.peoples[guess.type] = race_guess_info.peoples[guess.type] + 1
		race_guess_info.money[guess.type] = race_guess_info.money[guess.type] + guess.money
		--返回成功
		ret.result = C.RACE_DRAGON_SUCCEEDED
		return ret
	end
	
	--激活赛龙
	function obj.ActivateRace()
		l_active = true
	end

	--设置龙的信息,一般由育龙调用
	function obj.SetDragonInfo( type, dragon_id, data )
		if type==100 then
			if topten_info~=nil then
				for _,v in pairs( topten_info ) do
					if v.dragon==dragon_id then
						--玩家修改了龙名
						v.ch_name = 1
						v.d_name = data
					end
				end
			end
			--
			if final_info~=nil then
				for _,v in pairs( final_info ) do
					if v.dragon==dragon_id then
						--玩家修改了龙名
						v.ch_name = 1
						v.d_name = data
					end
				end
			end
		end
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
