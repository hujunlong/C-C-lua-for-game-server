--成就表中的数量要求表示

local cfg = {

--综合  10开头
kSilverCost=1001, -- 银币花费
kSilverGot=1002, -- 银币收入
kGoldCost=1003, --金币花费
kGoldGot=1004, --金币收入
kBagUnlock=1005, --背包格子开启
kPropUsed=1006, --使用了某道具
kPropGot=1007, --获得了某道具
kLordLevel=1008, --领主等级


--城建 11开头
kBuidingLevel=1101, --某类建筑物达到一定等级 （最大值填level，参数填建筑物sid）
kFoundationCount=1102, --放置建筑到地图上的次数
kFoundationCount=1102, --shi
kBuildingTotalAmout=1110, --某类建筑总数量，  参数 1 功能  2 商业 3 装饰 4道路
kBuidingUpgradeCount=1111, --建筑升级的次数
kReapCount=1113, --收钱次数
kReapAmount=1114, --收钱的量
kBuildingAmout=1115, --拥有的某种建筑数量，通过附加参数指定某种建筑
kDecorationEffect=1116, --装饰的影响值，百分比(在收钱的时候才会被触发)
kMoveBuilding=1117, --移动建筑
kRotateBuilding=1118, --旋转建筑
kMergeBuilding=1119, --融合建筑
kWarehousingBuilding=1120, --放进仓库


--宝具 12开头
kRuneEnergy = 1201,		--获得符能达到一定值
kRuneRubbish = 1202,	--获得所有的垃圾（不支持）
kRuneGetSpecial = 1203,	--获得指定符文
kRuneGetMaxLevel = 1204,	--获得一定数量的10级符文
kRuneUseMaterial = 1205,	--在熔炼过程中使用某样材料一定次数

--英雄 13**
kHeroLevel = 1301, --单个英雄的等级
kHeroRecruited=1302, --英雄招募
kHeroProperty=1303, --英雄单属性
kHero3Properties=1304, --英雄三围
kHeroBringup=1305, --培养 （附加参数是培养类型）

--装备 14**
kEquipmentsQuality=1401, --拥有某种品质的装备的量，附加参数指定品质
kGotVariationGem=1402, --获得变异宝石
kOwn3HolesEquipment=1403, --拥有的3孔装备数量
kEquipmentAmountOfGems=1404,	--装备上镶嵌的宝石

--阵形 15**
kArrayLevel = 1501,		--阵型等级

--国战  16**

--公会战 17**

--育龙  18**
kRearDragonMateSpecial = 1801,	--培养出特殊品种的龙(amount=龙的种类)
kRearDragonStrength = 1802,		--龙的力量达到一定数值(amount=龙的力量)
kRearDragonAgility  = 1803,		--龙的敏捷达到一定数值(amount=龙的敏捷)
kRearDragonintelligence = 1804,	--龙的智力达到一定数值(amount=龙的智力)

--游乐场 19**
kPlaygroundGotSpecialTickets = 1901,	--获得一定数量的兑换券(amount=玩家游乐券总额)
kFishedTimes = 1902,			--钓鱼达到一定次数(每钓一次鱼,amount=此次使用钓鱼次数)
kFishedFish = 1903,				--钓到某鱼&钓起的鱼的总数(钓到某鱼,amount=1,para=kind)
kTurntableMaxReward = 1904,		--转轮获得最大奖项(每当获得最大奖项时,amount=1)
kPlaygroundRaceDragonRank = 1905,		--参加赛龙获得对应的名次(value=龙的名次)
kPlaygroundRaceDragonGuessRight = 1906,	--赛龙竞猜正确一定次数(每当竞猜正确一次,value=1)
kPlaygroundRaceDragonGotReward = 1907,	--单次比赛中获奖的金额超过一定数值(value=获奖金额<不包含本金>)
kPlaygroundRaceDragonWin = 1908,		--获胜次数,我理解为获得第一名的次数(value=1)
kFishedWeightOfFish = 1909,				--钓到的鱼的重量(amount=1, para=weight)
kFishedAllFishInFishery = 1910,				--钓起此区域所有的鱼(amount=1, para=渔场kind)
kGotFruitForTree=1911,			--幸运树收获果实(amount=1,para=果实kind)

--护送  20**
kEscortRob = 2001,	--打劫一定次数
kEscort = 2002,	--护送一定次数
kEscortHelp = 2003,	--护卫一定次数
kEscortNoRob = 2004,	--没有被拦截一次到达终点
kEscortRobHelp = 2005,	--在打劫时遇上护卫者战斗并获胜
kEscortRobEx = 2006,	--连续拦截高于自身等级N级或以上的玩家成功一定次数（TODO:很难做）
kEscortTool = 2007,	--使用某样工具一定次数
kEscortWithHelp = 2008,	--在有护卫的情况下无伤到达终点
kEscortWithHelpEx = 2009,	--在有护卫的情况下被拦截了2次到达终点
kEscortHelpEx = 2010,	--有护卫的情况下无伤到达终点。（护卫获得成就，而非邀请者）

--军阶  21**
kGradeLevel = 2101, --军阶到达某一阶段

--支线任务  22**
kCompleteBranchTask=2201, --完成特定任务
kCompleteBranchTaskCount=2202, --完成某档次的任务的次数，附加参数填写档次


--地图  23**
kOpenedMaps=2301, --开启了的地图区域块数
kEnteredArea=2302, --进入某个地图区域，附加参数填写地图id
kMapMonsterKilled=2303, --击杀了地图上的某种怪物组，附加参数填写怪物组id
kMapBoxOpenedCount=2304, --开启的宝箱个数
kMapBoxOpened=2305, --开启某种宝箱
kBoxMonsterKilledCount=2306, --宝箱怪击杀次数

--好友  24**
kFriendsAmount = 2401,	--好友达到一定数量(-模块不同,暂时未做-)

--主线  25**
kPassedSection=2501, --完成了某一节,附加参数填写节的index
kPerfectChapter=2502, --通关某章，并且评价为3星 ，附加参数填写章的id
kKillBoss=2503, --击杀某个boss， 附加参数填写怪物组id
kMainlineFightHurt=2504, --主线战斗的伤害值（需战斗胜利）
kMainlineFightInjured=2505, --主线战斗的己方受伤值（需战斗胜利）
kMainlineSilverGotByFight=2506, --通过主线战斗获得银币
kMopUpSection=2507, --扫荡主线关卡
kKillEliteBoss=2508, --击杀精英boss（附加参数填写怪物组id）

--世界boss 26**
kBOSSKiller = 2601, --获得最后1刀
kBOSSJoin = 2602, --累计参加次数
kBOSShurt = 2603, --全场BOSS战造成一定百分比伤害

--竞技场 27**
kArenaRank = 2701, --竞技场中获得一定的名次
kArenaWinning = 2702, --连续胜利一定场次
kArenaNoDead = 2703, --在竞技场中没有死亡1人而获得比赛胜利（需要战斗系统支持）
kArenaOneAlive = 2704, --在竞技场中剩余最后1人时获得比赛胜利（需要战斗系统支持）
kArenaWinTotal = 2705, --一周内胜场次数达到一定数值（不支持）

}


return cfg
