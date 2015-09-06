

local config =
{
	kMaxLordLevel = 60,
	kMaxEnergy = 200,
	kMaxMobility = 200,
	kAddEnergy = 40,
	kAddMobility = 40,
	
	kCountrySelectReward = 2109,  --国家选择礼包，填写物品sid
	
	kGlobalResetTime = '00:00',
    
    kEvolveHeroVIP = 4,     --英雄进化VIP
    
town = {
			kMilitaryKind = 1004, --军仪所kind（SID）
			kAuctionKind = 1005, --拍卖行kind（SID）
			kCityHallKind = 1007, --市政厅的kind（SID）
			kTowerKind = 1008, --试炼塔
			kFishKind = 1009,		--钓鱼场
			kOfficeKind = 1010, 	--事务所
			kPlaygroundKind = 1012,	--游乐场
			kDragonHouseKind = 1014, --育龙场建筑的kind
			kTreeKind = 1019,		--幸运树建筑

			kTrainingGroundKind = 1015, --训练场的kind
			kSmithyKind = 1011, -- 铁匠铺
			kSkillMuseum = 1006, --科技馆
			kArenaKind = 1002, --竞技场
			kTreasureHouseKind = 1016, --宝库
            kBankKind = 1017,  --银行
            kBuildingHomes = 1013,--建筑院
            kUnlockBlockSkillID = 11, --扩地技能的id
			kWarehouseCapacity = 6,  --仓库的容量
            kCooldownReset = 25, --商业奇迹 清除所有cd时间
		},

hero = {  --英雄相关
			kOriginalHeros = {17,21}, --初始拥有的英雄
		},

prop = { --道具（包括装备）
		unlock_block = {kStartingPrice=2,kAdditonPrice=2},   --开背包仓库的格子的花费，起始值和增加值
		kActiveHoleCost = 10, --装备开孔的花费
		kPropertyMigrateCost = 30, -- 装备属性迁移
		kReservedOneHoleCostGold = 10, --保留一个孔花费金币
		kEquipDirectNeedVipLevel = 4,  --装备直接制作需要的VIP等级
		kGemDirectNeedVipLevel	 = 4,  --宝石直接制作需要的VIP等级
	},

branch_task = { --支线任务，事务所
		kResetTimePoints = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}, --每日刷新时间点（需要填写24小时制的整点）
		kMaxStaminaTake = 100,				--体力水壶最大值
		kClearStaminaCDCostGold = 2,		--清除恢复体力CD,每分钟增加消耗金币
		kBackToTownCostTime = 5,			--回城时间(分钟)
		kClearBackToTownCDCost = 10,		--清除回城时间花费金币
		kReplenishStaminaInterval = 15,		--体力回复间隔时间<每x秒回复1点>
		kReceiveSeriesTaskCost = 50,      --直接接系列任务的下一个任务  花费的金币
		kRefreshTasksCost = 20,   --忽略等待时间，直接刷新任务  花费的金币
	},
	
boss_section = { --精英boss关卡
	kSecondKillingPrice = 20, --当日再次击杀boss的花费（金币）
	kMaxKillingTimes = {[0]=5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}, --每日最大可击杀次数
},	

  guild = { --工会相关
		kCreateGuildCost = 100000,			--建立工会花费
		kResetGuildHeavensentCost = 50,		--重置公会天赋花费
		kUploadGulildIconCost = 100,		--上传会标
        kGuildNewMax = 20,                  --二十条公会新闻上限
        kGuildBaseMember = 20,              --公会基础人数为20人
        kGuildInviteOutTime = 24*3600,      --移除超时玩家
		kBuyGuildWarBuff1Cost = 50,			--购买战场BUFF1花费,恢复包
        kGuildWarBuff1HealHp = 10000,		--恢复包恢复血量
		kBuyGuildWarBuff2Times1Cost = 50,	--购买战场BUFF2花费,伤害加深,第一次购买
		kBuyGuildWarBuff2Times2Cost = 80,	--购买战场BUFF2花费,第二次购买
		kBuyGuildWarBuff2Times3Cost = 150,	--购买战场BUFF2花费,第三次购买
        kFirstAddDamagePre = 0.2,           --第一次购买伤害所增加的
        kSecondAddDamagePre = 0.5,          --第一次购买伤害所增加的
        kThirdAddDamagePre = 1,             --第一次购买伤害所增加的
        kQueueTime = 10,                   --进入排队时间(秒)
        kGuildLevel = 21,                   --创建工会的等级
        kResourcePorts = 2000,                --资源点数
        kGuildWarSignUp = "00:00",          --开始报名
		kGuildWarPerpareTime ="16:00",      --每周 结算一次公会活跃度, 并发送战前通知  
        kGuildWarEnterTime = "16:05",		--工会战入场时间
		kGuildWarBeingTime = "16:10",		--工会战开战时间
		kGuildWarEndTime = "16:30",		   --工会战结束时间
        kGuildWarRemindFirst = "16:00",   --工会战第一次提示
        kGuildWarRemindSecond = "16:03",  --工会战第二次提示
        kGuildWarRemindThird = "16:05",   --工会战第三次提示
        kGuildWarRemindFour = "16:08",    --工会战第四次提示
        kGuildWarRemindFive = "16:10",    --工会战第五次提示
        kGuildResetTime = "00:00",        --重置领取奖励
        kGuildWarCanBuyHarmVip = 3,       --能够购买伤害的VIP等级
        kGuildWarCanBuyBuffVip = 3,       --购买buff需要的VIP等级
        kGuildWarRefreshTime = 5,         --资源点刷新时间
        kGuildWarCoefficient = 0.3,       --公会战血包回血比例
	    
    },

    hero_train = {
        update_buy_train_time = "00:00",    --刷新购买训练次数时间
        comeback_time = 1200,               --20分钟增加一次可以训练的次数
        refresh_train_time = 60,            --60秒刷新一次
},
arena = { --竞技场
		cd_time = 5*60,                                     --冷却时间5分钟
		max_count = 10,                                     --最大挑战次数
		clear_cd_price = 1,                            		--清除每分钟CD所需金币
		buy_times_price = 2,                          		--购买次数 * 所需金币
		reward_time = "19:00",								--发奖时间
	},

escort = { --护送取经
		can_escort = 3,										--每日可护送
		can_defend = 4,										--每日可护卫
		can_intercept = 5,									--每日可打劫

		cd_time = 600,                                     --打劫冷却时间
		clear_cd_price = 3,                                --清除每分钟CD所需金币
		timeout = 60,                                      --超时时间
		price = 2,                                         --刷新所需金币 = 价格 * 次数
	},

territory = { --领地
        bronze = 4,											--青铜领地
        can_assist = 5,										--每日可帮助次数
        can_robber = 5,										--每日强盗数量

        cd_time = 20 * 60,                                 --增加CD时间
        clear_gold = 20,                                   --清除CD所需金币
    },

treasure = { --宝具

		--背包最大上限
		max_space_stove = 20,
		max_space_bag = 30,
		max_space = 512,

		wastage = 1 - 0.25,									--符文损耗

		-- 直接从“赤金”开始熔炼  200金币/次 每日重置
		gold_price = 200,
	},

auction = { --拍卖行
        --空间数量
        space = 10,
        
		--服务费
		cost = {[1]=10, [2]=20, [4]=40},

		--税率
		tax = 0.05,

		--涨价幅度
		rise = 0.1,

		--剩余时间涨幅
		delay = 5 * 60,
	},

world_boss = { --世界BOSS
		reduce_cd_time = 10,							--每XX秒算一次
		reduce_cd_gold = 1,								--清除reduce_cd_time时间所需金币
		cd_time = 40,										--CD时间
		reborn_price = 50,									--不死鸟复活价格
	},

world_war = { --国战
		address = "tcp://127.0.0.1:23450",					--服务器地址
		name = "测试服务器",								--本机名称
	},

fish = { --钓鱼相关
		kTimesEveryDay = 20,		--每天钓鱼次数
		kNeedVipLevel=3,			--鱼雷需要vip等级
	},

rear_dragon = { --育龙相关
		kChangeNameCost = 30,		--改名花费金币
		kResetMateIntervalCost = 150, --重置交配时间消耗金币
		kMateIntervalTime = 72*3600,	--交配间隔时间
		kRearroomsLimit = 9,			--育龙所等级限制
		kFeedProbability1 = 100,		--喂食成功几率
		kFeedProbability2 = 70,
		kFeedProbability3 = 30,
	},

race_dragon = { --赛龙相关
		--
		kRunwaySection = 18,				--跑道的段数
	},
	
turntable = { --转盘
		--
		kTimesEveryDay = 10,			--每天可以玩?次
		kReturnCostGold = 2,			--重转花费金币基数
	},
playground_prop = { --游乐场商店
		--
		kGoldBuyFoodNeedVipLevel = 4,	--使用金币购买食物需要vip等级
		kGoldBuyLimitFoodNeedVipLevel = 7,	--购买限量食物需要vip等级
	},

mail = { --邮件
		--
		kFishSubject = "钓鱼",
		kFishContent = "恭喜您钓鱼获得物品",
		kRaceDragonGuessSubject = "%d季赛龙竞猜",
		kRaceDragonGuessWinContent = "恭喜您在%d赛季赛龙比赛中竞猜获胜,您获得了%d银币,请查收.",
		kRaceDragonGuessLoseContent = "您在%d赛季赛龙比赛中竞猜失利,系统返还一半金额给您,请查收.祝您下次旗开得胜.",
		kRaceDragonGotRank = "恭喜您在赛龙比赛中获得名次: %d, 获得银币: %d, 威望: %d",
	},
assistant = { --助手
		kRetrieveTaskCostGold = 10,		--小助手找回任务花费金币
	},
tree = { --幸运树
		kWaterAmount = 3,			--每天的神水数量
	},
	kGoldForDaysAgo = 30,			--前3日可以领取的金币

} --end of config


return config
