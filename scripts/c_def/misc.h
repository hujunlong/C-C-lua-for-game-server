#pragma once
#include "define.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

enum MiscRequestType
{
//c2s

    //宝具
    kGetStoveStatus = kMiscTypeBegin + 1,
    kGetStoveRunes = kMiscTypeBegin + 2,
    kClickMaterial = kMiscTypeBegin + 3,
    kPickupRunes = kMiscTypeBegin + 4,
    kResolveRunes = kMiscTypeBegin + 5,
    //kCooling = kMiscTypeBegin + 6,
    //kQuench = kMiscTypeBegin + 7,
    kGetBagRunes = kMiscTypeBegin + 8,
    kGetHeroRunes = kMiscTypeBegin + 9,
    kResolveBagRune = kMiscTypeBegin + 10,
    kLockRune = kMiscTypeBegin + 11,
    //kMergeAllRunes = kMiscTypeBegin + 12,
    //kMergeRune = kMiscTypeBegin + 13,
    kChangeRuneInBag = kMiscTypeBegin + 14,
    kChangeRuneOnHero = kMiscTypeBegin + 15,
    kWearDropRune = kMiscTypeBegin + 16,
    //kInjectRune = kMiscTypeBegin + 17,
    kUpgradeRune = kMiscTypeBegin + 18,
    kResolveAllRunes = kMiscTypeBegin + 19,
    kGoldActivation = kMiscTypeBegin + 20,
    kSortRunes = kMiscTypeBegin + 21,
    kUpgradeRuneOnHero = kMiscTypeBegin + 22,
    
    //成就
    kGetAllAchievements = kMiscTypeBegin+101,
    
    //世界BOSS
    kGetWorldBossInfo = kMiscTypeBegin + 201,
    kEnterWorldBoss = kMiscTypeBegin + 202,
    kLeaveWorldBoss = kMiscTypeBegin + 203,
    kAttackWorldBoss = kMiscTypeBegin + 204,
    kReduceWorldBossCD = kMiscTypeBegin + 205,
    kPhoenixNirvana = kMiscTypeBegin + 206,

	//幸运树
	kGetTreeWater = kMiscTypeBegin + 300,
	kGetTreeSeeds = kMiscTypeBegin + 301,
	kGetTreeLogs = kMiscTypeBegin + 302,
	kExitTree = kMiscTypeBegin + 303,
	kWaterTree = kMiscTypeBegin + 304,
	kPickFruit = kMiscTypeBegin + 305,

	//前几日领取金币
	kGetDaysAgoInfo = kMiscTypeBegin + 330,
	kGetRewardDaysAgo = kMiscTypeBegin + 331,
	//收藏网址
	kGetSaveWebsiteInfo = kMiscTypeBegin + 340,
	kGetSaveWebsiteReward = kMiscTypeBegin + 341,
	//抽奖
	kGetLuckyDrawInfo = kMiscTypeBegin + 350,
	kDoLuckyDraw = kMiscTypeBegin + 351,
	//每日签到
	kGetCheckInEveryDayInfo = kMiscTypeBegin + 360,
	kDoCheckInEveryDay = kMiscTypeBegin + 361,
	//累计签到
	kGetCheckInAccumulateInfo = kMiscTypeBegin + 370,
	kGetCheckInAccumulateReward = kMiscTypeBegin + 371,
	
	//试炼塔
	kGetTowerInfo = kMiscTypeBegin + 401,
	kResetTower = kMiscTypeBegin + 402,
	kFightTower = kMiscTypeBegin + 403,
	kMopupTower = kMiscTypeBegin + 404,

	//杂项
	kSelectCountry = kMiscTypeBegin + 901,
	kBuyGameResource = kMiscTypeBegin + 902,
	//kGetRemainResourceBuyTimes = kMiscTypeBegin + 903,
	kGetSystemConfig = kMiscTypeBegin + 904,
	kSetSystemConfig = kMiscTypeBegin + 905,
	kGetActivedFunctions = kMiscTypeBegin + 906,
	kGetRecommendCountry = kMiscTypeBegin + 907,
	//kGetAlchemyCount = kMiscTypeBegin + 908,
	//kUseAlchemy = kMiscTypeBegin + 909,
	kGetVIPSurplusCount = kMiscTypeBegin + 910,
	kGetRewardStatus = kMiscTypeBegin + 911,
	kViewFightRecord = kMiscTypeBegin + 912,
	//小助手
	kNotifyResetAssistant = kMiscTypeBegin + 913,
	kAssistantGetReward = kMiscTypeBegin + 914,
	kGetAssistantInfo = kMiscTypeBegin + 915,
	kRetrieveAssistantTask = kMiscTypeBegin + 916,
	
	kGetRaiders = kMiscTypeBegin + 920,
	kPing = kMiscTypeBegin + 930,
	
	kGetStageAwardInfo = kMiscTypeBegin + 940,
	kGetStageAward = kMiscTypeBegin + 941,

//s2c
    //宝具
    kGetStoveStatusResult = kMiscReturnBegin + 1,
    kGetStoveRunesResult = kMiscReturnBegin + 2,
    kClickMaterialResult = kMiscReturnBegin + 3,
    kPickupRunesResult = kMiscReturnBegin + 4,
    kResolveRunesResult = kMiscReturnBegin + 5,
    //kCoolingResult = kMiscReturnBegin + 6,
    //kQuenchResult = kMiscReturnBegin + 7,
    kGetBagRunesResult = kMiscReturnBegin + 8,
    kGetHeroRunesResult = kMiscReturnBegin + 9,
    kResolveBagRuneResult = kMiscReturnBegin + 10,
    kLockRuneResult = kMiscReturnBegin + 11,
    //kMergeAllRunesResult = kMiscReturnBegin + 12,
    //kMergeRuneResult = kMiscReturnBegin + 13,
    kChangeRuneInBagResult = kMiscReturnBegin + 14,
    kChangeRuneOnHeroResult = kMiscReturnBegin + 15,
    kWearDropRuneResult = kMiscReturnBegin + 16,
    //kInjectRuneResult = kMiscReturnBegin + 17,
    kUpgradeRuneResult = kMiscReturnBegin + 18,
    kResolveAllRunesResult = kMiscReturnBegin + 19,
    kGoldActivationResult = kMiscReturnBegin + 20,
    kSortRunesResult = kMiscReturnBegin + 21,
    kUpgradeRuneOnHeroResult = kMiscReturnBegin + 22,

    //成就
    kAllAchievements = kMiscReturnBegin+101,
    kAchievementAccomplished = kMiscReturnBegin+151,
	kBigPacket = kMiscReturnBegin+171, //测试大包

    //世界BOSS
    kGetWorldBossInfoResult = kMiscReturnBegin + 201,
    kEnterWorldBossResult = kMiscReturnBegin + 202,
    kLeaveWorldBossResult = kMiscReturnBegin + 203,
    kAttackWorldBossResult = kMiscReturnBegin + 204,
    kReduceWorldBossCDResult = kMiscReturnBegin + 205,
    kPhoenixNirvanaResult = kMiscReturnBegin + 206,
    
    //进入世界BOOS区域后主动推送
    kPushWorldBossBoard = kMiscReturnBegin + 210,
    kPushWorldBossHurt = kMiscReturnBegin + 211,
    kPushWorldBossChallengerCount = kMiscReturnBegin + 212,
    kPushWorldBossCollectReward = kMiscReturnBegin + 213,
    kPushWorldBossReward = kMiscReturnBegin + 214,

	//幸运树
	kGetTreeWaterResult = kMiscReturnBegin + 300,
	kGetTreeSeedsResult = kMiscReturnBegin + 301,
	kGetTreeLogsResult = kMiscReturnBegin + 302,
	kExitTreeResult = kMiscReturnBegin + 303,
	kWaterTreeResult = kMiscReturnBegin + 304,
	kPickFruitResult = kMiscReturnBegin + 305,

	kPushSeedStatus = kMiscReturnBegin + 320,
	kPushVisitLog = kMiscReturnBegin + 321,
	kPushResetTree = kMiscReturnBegin + 322,

	//前3日金币
	kGetDaysAgoInfoResult = kMiscReturnBegin + 330,
	kGetRewardDaysAgoResult = kMiscReturnBegin + 331,
	//收藏网址
	kGetSaveWebsiteInfoResult = kMiscReturnBegin + 340,
	kGetSaveWebsiteRewardResult = kMiscReturnBegin + 341,
	//抽奖
	kGetLuckyDrawInfoResult = kMiscReturnBegin + 350,
	kDoLuckyDrawResult = kMiscReturnBegin + 351,
	//每日签到
	kGetCheckInEveryDayInfoResult = kMiscReturnBegin + 360,
	kDoCheckInEveryDayResult = kMiscReturnBegin + 361,
	//累计签到
	kGetCheckInAccumulateInfoResult = kMiscReturnBegin + 370,
	kGetCheckInAccumulateRewardResult = kMiscReturnBegin + 371,


	//试炼塔
	kGetTowerInfoResult = kMiscReturnBegin + 401,
	kResetTowerResult = kMiscReturnBegin + 402,
	kFightTowerResult = kMiscReturnBegin + 403,
	kMopupTowerResult = kMiscReturnBegin + 404,
	
	kPushTowerReward = kMiscReturnBegin + 411,
	
	
	//杂项
	kSelectCountryResult =  kMiscReturnBegin + 901,
	kBuyGameResourceResult = kMiscReturnBegin + 902,
	//kGetRemainResourceBuyTimesResult = kMiscReturnBegin + 903,
	kGetSystemConfigResult = kMiscReturnBegin + 904,
	kSetSystemConfigResult = kMiscReturnBegin + 905,
	kActivedFunctions = kMiscReturnBegin + 906,
	kRecommendCountry = kMiscReturnBegin + 907,
	//kAlchemyCount = kMiscReturnBegin + 908,
	//kUseAlchemyResult = kMiscReturnBegin + 909,
	kVIPSurplusCount = kMiscReturnBegin + 910,
	kRewardStatus = kMiscReturnBegin + 911,
	kFightRecord = kMiscReturnBegin + 912,
	kAssistantGetRewardResult = kMiscReturnBegin + 913,
	kGetAssistantInfoResult = kMiscReturnBegin + 914,
	kRetrieveAssistantTaskResult = kMiscReturnBegin + 915,
	
	kRaiders = kMiscReturnBegin + 920,

	kPingResult = kMiscReturnBegin + 930,

	kFunctionActived = kMiscReturnBegin + 951,
	
	kGetStageAwardInfoResult = kMiscReturnBegin + 940,
	kGetStageAwardResult = kMiscReturnBegin + 941,
};

enum RuneMaxCount
{
    RUNE_MAX_COUNT_STOVE = 20,              // 熔炉中最多20个符文
    RUNE_MAX_COUNT_INBAG = 30,              // 包裹中最多30个符文
    RUNE_MAX_COUNT_HERO = 30,               // 英雄身上最多20个符文
};

enum RuneResultType
{
    RuneResultBegin = 13000,
    RUNE_SUCCESS = RuneResultBegin + 1,                           // 成功（这个不用，用0返回）
    RUNE_NOT_YET_ACTIVATE = RuneResultBegin + 2,                  // 尚未激活本功能
    RUNE_NOT_ENOUGH_GOLD = RuneResultBegin + 3,                   // 金币不足
    RUNE_NOT_ENOUGH_COIN = RuneResultBegin + 4,                   // 银币不足
    RUNE_NOT_ENOUGH_STOVE_SPACE = RuneResultBegin + 5,            // 熔炉空间已满
    RUNE_NOT_ENOUGH_BAG_SPACE = RuneResultBegin + 6,              // 包裹空间已满
    RUNE_NOT_ENOUGH_RUNE_SPACE = RuneResultBegin + 7,             // 符文数据库空间已满
    RUNE_AMOUNT_ERROR = RuneResultBegin + 8,                      // 参数数目不正确
    //RUNE_LOW_TEMPERATURE = RuneResultBegin + 9,                   // 温度过低
    //RUNE_NOT_ENOUGH_T = RuneResultBegin + 10,                     // 温度不足
    //RUNE_CANT_USE_COOLING = RuneResultBegin + 11,                 // 不可使用冷凝剂
    RUNE_CANT_PICKUP_GARBAGE = RuneResultBegin + 12,              // 不可拾取垃圾符文
    RUNE_INVALID_RUNE_ID = RuneResultBegin + 13,                  // 无效的符文ID
    RUNE_BAG_IS_EMPTY = RuneResultBegin + 14,                     // 背包是空的
    RUNE_CANT_MERGE_LOCKED = RuneResultBegin + 15,                // 不能合并锁定的符文
    RUNE_INVALID_RUNE_POS = RuneResultBegin + 16,                 // 无效的符文位置
    RUNE_INVALID_MATERIAL = RuneResultBegin + 17,                 // 无效的材料
    RUNE_NOT_ENOUGH_ENERGY = RuneResultBegin + 18,                // 没有足够的符文能量
    RUNE_RUNE_MAX_LEVEL = RuneResultBegin + 19,                   // 符文已经升级到最高级
    RUNE_NO_MORE_TIMES = RuneResultBegin + 20,                    // 没有激活次数了
    RUNE_NO_NEED_BUY = RuneResultBegin + 21,                      // 不需要使用金币激活
};

enum WorldBossResultType
{
    WorldBossResultBegin = 13200,
    BOSS_NOT_YET_ACTIVATE = WorldBossResultBegin + 1,               // 尚未激活本功能
    BOSS_NOT_YET_BEGIN = WorldBossResultBegin + 2,                  // BOSS战未开始
    BOSS_NOT_YET_REAL_BEGIN = WorldBossResultBegin + 3,             // BOSS战未真正开始
    BOSS_BOSS_ALREADY_DEAD = WorldBossResultBegin + 4,              // BOSS已经死亡
    BOSS_NOT_YET_ENTER = WorldBossResultBegin + 5,                  // 你还没有进入BOSS区域
    BOSS_ON_THE_CD_TIME = WorldBossResultBegin + 6,                 // CD冷却中
    BOSS_DONT_NEED_REDUCE_CD = WorldBossResultBegin + 7,            // 你不需要清除CD
    BOSS_NOT_ENOUGH_GOLD = WorldBossResultBegin + 8,                // 金币不足
    BOSS_NO_MORE_TIMES = WorldBossResultBegin + 9,                  // 没有购买次数了
};

enum TowerResultType
{
    TowerResultBegin = 13300,
    TOWER_SUCCESS           = TowerResultBegin + 1,                  // 成功
    TOWER_NOT_ACTIVATE      = TowerResultBegin + 2,                  // 尚未激活本功能
    TOWER_INVALID_TOWER     = TowerResultBegin + 3,                  // 无效的塔
    TOWER_ALREADY_RESET     = TowerResultBegin + 4,                  // 已经重置过塔
    TOWER_NO_RESET_TIMES    = TowerResultBegin + 5,                  // 没有重置次数了
    TOWER_NO_ENOUGH_GOLD    = TowerResultBegin + 6,                  // 金币不足
    TOWER_ONLY_MOPUP        = TowerResultBegin + 7,                  // 此时只能扫荡
    TOWER_CANT_MOPUP        = TowerResultBegin + 8,                  // 此时不能扫荡
    TOWER_ON_THE_CD_TIME    = TowerResultBegin + 9,                  // CD冷却中
    TOWER_BAG_IS_FULL       = TowerResultBegin + 10,                 // 背包已经满了，不能挑战或者扫荡
};
//////////////////////////////////////////////////////////////////////////////////////////////////

struct GetStoveStatus // 获取熔炉状态 c2s
{
    static const Type kType = kGetStoveStatus;
};
typedef struct GetStoveStatus GetStoveStatus;

struct GetStoveStatusReturn // 获取熔炉状态 s2c
{
    static const Type kType = kGetStoveStatusResult;
    Result result;          // 
    uint8_t status;        // 当前点亮状态，一号材料永远点亮。status第一位代表材料2状态，status第二位代表材料3状态，以此类推
    uint8_t count;          // VIP还可以消费的次数
};
typedef struct GetStoveStatusReturn GetStoveStatusReturn;

//////////////////////////////////////////////////////////////////////////////////////////////////
struct RuneInfoToClient
{
    uint32_t rune_id;         // 符文ID
    uint16_t rune_type;        // 符文类型｛符文表中的SID｝
    uint8_t position;         // 符文位置｛如果为0，则根据ID大小自动排序｝
    uint8_t lock;             // 是否锁定，1为锁定，0为没有锁定
    uint32_t exp;             // 符文总经验
};
typedef struct RuneInfoToClient RuneInfoToClient;

struct GetStoveRunes // 获取熔炉中符文列表 c2s
{
    static const Type kType = kGetStoveRunes;
};
typedef struct GetStoveRunes GetStoveRunes;

struct GetStoveRunesReturn // 获取熔炉中符文列表 s2c
{
    static const Type kType = kGetStoveRunesResult;
    Result result;            // 
    uint32_t bag_count;        // 包裹符文个数
    uint32_t list_count;       // 数组实际个数
    RuneInfoToClient rune_list[RUNE_MAX_COUNT_STOVE];   // 符文列表，按照位置升序排列，1 2 3 4 5 6
};
typedef struct GetStoveRunesReturn GetStoveRunesReturn;

//////////////////////////////////////////////////////////////////////////////////////////////////

struct ClickMaterial // 点击材料 c2s
{
    static const Type kType = kClickMaterial;
    uint8_t material;       // 点击的材料位置
};
typedef struct ClickMaterial ClickMaterial;

struct ClickMaterialReturn // 点击材料 s2c
{
    static const Type kType = kClickMaterialResult;
    Result result;          // 如果未成功，则不读取后面的数据
    //uint8_t temperature;    // 当前熔炉温度
    //bool is_droped;        // 是否掉落符文，1为掉落，0为未掉落
    uint32_t rune_id;       // 掉落符文ID
    uint8_t rune_type;      // 掉落符文类型｛符文表中的SID｝
    uint8_t status;         // 当前点亮状态
};
typedef struct ClickMaterialReturn ClickMaterialReturn;

//////////////////////////////////////////////////////////////////////////////////////////////////

struct PickupRunes // 拾取符文 c2s
{
    static const Type kType = kPickupRunes;
    uint32_t runes_count;       // 数组实际个数
    uint32_t runes_id[RUNE_MAX_COUNT_STOVE];     // 符文列表
};
typedef struct PickupRunes PickupRunes;

struct PickupRunesReturn // 拾取符文 s2c
{
    static const Type kType = kPickupRunesResult;
    Result result;          // 
};
typedef struct PickupRunesReturn PickupRunesReturn;

//////////////////////////////////////////////////////////////////////////////////////////////////

struct ResolveRunes // 分解符文 c2s
{
    static const Type kType = kResolveRunes;
    uint32_t runes_count;       // 数组实际个数
    uint32_t runes_id[RUNE_MAX_COUNT_STOVE];     // 符文列表
};
typedef struct ResolveRunes ResolveRunes;

struct ResolveRunesReturn // 分解符文 s2c
{
    static const Type kType = kResolveRunesResult;
    Result result;          // 
    uint32_t energy;           // 符文能量池
};
typedef struct ResolveRunesReturn ResolveRunesReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////
/*
struct Cooling // 冷却（使用冷凝剂） c2s
{
    static const Type kType = kCooling;
};
typedef struct Cooling Cooling;

struct CoolingReturn // 冷却 s2c
{
    static const Type kType = kCoolingResult;
    Result result;           // 
    uint32_t temperature;    // 当前熔炉温度
};
typedef struct CoolingReturn CoolingReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct Quench // 淬火 c2s
{
    static const Type kType = kQuench;
};
typedef struct Quench Quench;

struct QuenchReturn // 淬火 s2c
{
    static const Type kType = kQuenchResult;
    Result result;          // 
    uint32_t rune_id;       // 掉落符文ID
    uint8_t rune_type;      // 掉落符文类型｛符文表中的SID｝
};
typedef struct QuenchReturn QuenchReturn;
*/
//////////////////////////////////////////////////////////////////////////////////////////////////

struct GetBagRunes // 获取包裹中的符文 c2s
{
    static const Type kType = kGetBagRunes;
};
typedef struct GetBagRunes GetBagRunes;

struct GetBagRunesReturn // 获取包裹中的符文 s2c
{
    static const Type kType = kGetBagRunesResult;
    Result result;            // 
    uint32_t energy;           // 符文能量池
    uint32_t list_count;       // 数组实际个数
    RuneInfoToClient rune_list[RUNE_MAX_COUNT_INBAG];   // 符文列表，符文有位置属性
};
typedef struct GetBagRunesReturn GetBagRunesReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct GetHeroRunes // 获取英雄上的符文 c2s
{
    static const Type kType = kGetHeroRunes;
    uint8_t hero_id;
};
typedef struct GetHeroRunes GetHeroRunes;

struct GetHeroRunesReturn // 获取英雄上的符文 s2c
{
    static const Type kType = kGetHeroRunesResult;
    Result result;          // 
    uint32_t list_count;       // 数组实际个数
    RuneInfoToClient rune_list[RUNE_MAX_COUNT_HERO];   // 符文列表，符文有位置属性
};
typedef struct GetHeroRunesReturn GetHeroRunesReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct ResolveBagRune // 分解背包中的符文 c2s
{
    static const Type kType = kResolveBagRune;
    uint8_t position;       // 符文位置
};
typedef struct ResolveBagRune ResolveBagRune;

struct ResolveBagRuneReturn // 分解背包中的符文 s2c
{
    static const Type kType = kResolveBagRuneResult;
    Result result;          // 
    uint32_t energy;           // 获得的能量
};
typedef struct ResolveBagRuneReturn ResolveBagRuneReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct LockRune // 锁定符文 c2s ｛如果已经锁定则命令变为解锁｝
{
    static const Type kType = kLockRune;
    uint8_t position;       // 符文位置
};
typedef struct LockRune LockRune;

struct LockRuneReturn // 锁定符文 s2c
{
    static const Type kType = kLockRuneResult;
    Result result;          // 
};
typedef struct LockRuneReturn LockRuneReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////
/*
struct MergeAllRunes // 一键合并符文 c2s ｛成功后，请重新发包请求背包列表｝
{
    static const Type kType = kMergeAllRunes;
};
typedef struct MergeAllRunes MergeAllRunes;

struct MergeAllRunesReturn // 一键合并符文 s2c
{
    static const Type kType = kMergeAllRunesResult;
    Result result;          // 
};
typedef struct MergeAllRunesReturn MergeAllRunesReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct MergeRune // 合并两个符文 c2s ｛位置2吞噬位置1的符文｝
{
    static const Type kType = kMergeRune;
    uint8_t position1;       // 符文位置1
    uint8_t position2;       // 符文位置2
};
typedef struct MergeRune MergeRune;

struct MergeRuneReturn // 合并两个符文 s2c
{
    static const Type kType = kMergeRuneResult;
    Result result;          // 
    RuneInfoToClient rune;       // 新产生的符文
};
typedef struct MergeRuneReturn MergeRuneReturn;
*/
//////////////////////////////////////////////////////////////////////////////////////////////////

struct ChangeRuneInBag // 改变符文在背包中的位置 c2s
{
    static const Type kType = kChangeRuneInBag;
    uint8_t old_position;        // 符文旧的位置
    uint8_t new_position;        // 符文新的位置
};
typedef struct ChangeRuneInBag ChangeRuneInBag;

struct ChangeRuneInBagReturn // 改变符文在背包中的位置 s2c
{
    static const Type kType = kChangeRuneInBagResult;
    Result result;          // 
};
typedef struct ChangeRuneInBagReturn ChangeRuneInBagReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct ChangeRuneOnHero // 改变符文在英雄身上的位置
{
    static const Type kType = kChangeRuneOnHero;
    uint32_t rune_id;        // 符文ID
    uint8_t hero_id;         // 英雄ID
    uint8_t position;        // 位置
};
typedef struct ChangeRuneOnHero ChangeRuneOnHero;

struct ChangeRuneOnHeroReturn // 改变符文在英雄身上的位置 s2c
{
    static const Type kType = kChangeRuneOnHeroResult;
    Result result;          // 
};
typedef struct ChangeRuneOnHeroReturn ChangeRuneOnHeroReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct WearDropRune // 穿戴符文/取下符文 c2s ｛如果符文在背包中，意味着佩带符文；如果符文已经在英雄上，意味着脱下符文｝
{
    static const Type kType = kWearDropRune;
    uint32_t rune_id;        // 符文ID
    uint8_t hero_id;         // 英雄ID
    uint8_t position;        // 位置（如果是脱下到未知地方，传0）
};
typedef struct WearDropRune WearDropRune;

struct WearDropRuneReturn // 改变符文在英雄身上的位置 s2c
{
    static const Type kType = kWearDropRuneResult;
    Result result;          // 
    uint8_t position;       // 脱下后的位置
};
typedef struct WearDropRuneReturn WearDropRuneReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////
/*
struct InjectRune // 给背包中的符文注入能量 c2s
{
    static const Type kType = kInjectRune;
    int32_t energy;         // 要注入的能量
    uint8_t position;       // 符文位置
};
typedef struct InjectRune InjectRune;

struct InjectRuneReturn // 给背包中的符文注入能量 s2c
{
    static const Type kType = kInjectRuneResult;
    Result result;          // 
    int32_t energy;           // 符文能量池
    RuneInfoToClient rune;    // 新产生的符文
};
typedef struct InjectRuneReturn InjectRuneReturn;
*/
//////////////////////////////////////////////////////////////////////////////////////////////////

struct UpgradeRune // 给背包中的符文注入能量 c2s
{
    static const Type kType = kUpgradeRune;
    uint8_t position;       // 符文位置
};
typedef struct UpgradeRune UpgradeRune;

struct UpgradeRuneReturn // 给背包中的符文注入能量 s2c
{
    static const Type kType = kUpgradeRuneResult;
    Result result;          // 
    uint32_t energy;           // 符文能量池
    //RuneInfoToClient rune;    // 新产生的符文
};
typedef struct UpgradeRuneReturn UpgradeRuneReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct ResolveAllRunes // 分解所有符文 c2s
{
    static const Type kType = kResolveAllRunes;
    uint8_t position;       // 要保留的符文位置
};
typedef struct ResolveAllRunes ResolveAllRunes;

struct ResolveAllRunesReturn // 分解所有符文 s2c
{
    static const Type kType = kResolveAllRunesResult;
    Result result;          // 
    uint32_t energy;           // 符文能量池
};
typedef struct ResolveAllRunesReturn ResolveAllRunesReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct GoldActivation // 金币直接激活赤金 c2s
{
    static const Type kType = kGoldActivation;
};
typedef struct GoldActivation GoldActivation;

struct GoldActivationReturn // 金币直接激活赤金 s2c
{
    static const Type kType = kGoldActivationResult;
    Result result;          // 
    uint8_t status;         // 当前点亮状态
    uint8_t count;  
};
typedef struct GoldActivationReturn GoldActivationReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////


struct SortRunes // 整理符文背包 c2s
{
    static const Type kType = kSortRunes;
};
typedef struct SortRunes SortRunes;

struct SortRunesResult // 整理符文背包 s2c
{
    static const Type kType = kSortRunesResult;
    Result result;          // 
	uint8_t changed;	// 1发生了改变 0 未发生改变
};
typedef struct SortRunesResult SortRunesResult;


struct UpgradeRuneOnHero // 升级英雄身上的符文 c2s
{
    static const Type kType = kUpgradeRuneOnHero;
    uint32_t rune_id;        // 符文ID
    uint8_t hero_id;         // 英雄ID
};
typedef struct UpgradeRuneOnHero UpgradeRuneOnHero;

struct UpgradeRuneOnHeroResult // 升级英雄身上的符文 s2c
{
    static const Type kType = kUpgradeRuneOnHeroResult;
    Result result;          // 
    uint32_t energy;           // 符文能量池
};
typedef struct UpgradeRuneOnHeroResult UpgradeRuneOnHeroResult;



//成就
struct GetAllAchievements //c2s
{ 
    static const Type kType = kGetAllAchievements;
};
typedef struct GetAllAchievements GetAllAchievements;

struct AllAchievements //s2c
{ 
    static const Type kType = kAllAchievements;
    int32_t count;
    struct 
    {
        uint16_t id;
        uint16_t reserve; //保留
		uint32_t progress;
        uint32_t accomplish_time;
    }achievements[600]; //有效长度由count决定
};
typedef struct AllAchievements AllAchievements;

struct AchievementAccomplished //s2c
{ 
    static const Type kType = kAchievementAccomplished;
    uint16_t id;
};
typedef struct AchievementAccomplished AchievementAccomplished;



//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
// 世界BOSS

//////////////////////////////////////////////////////////////////////////////////////////////////

struct WorldBossInfo
{
    uint32_t enter_time;        // 进入时间 绝对值
    uint32_t start_time;        // 开启时间
    uint32_t over_time;         // 结束时间
    uint8_t level;              // BOSS等级
    uint8_t dead;               // BOSS是否死亡
    uint8_t sid;                // BOSS SID
    uint8_t id;                 // BOSS ID
};
typedef struct WorldBossInfo WorldBossInfo;

struct GetWorldBossInfo // 获取世界BOSS信息 c2s
{
    static const Type kType = kGetWorldBossInfo;
};
typedef struct GetWorldBossInfo GetWorldBossInfo;

struct GetWorldBossInfoReturn // 获取世界BOSS信息 s2c
{
    static const Type kType = kGetWorldBossInfoResult;
    Result result;          // 
    uint32_t count;         // 实际个数
    WorldBossInfo list[5];      
};
typedef struct GetWorldBossInfoReturn GetWorldBossInfoReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct EnterWorldBoss // 进入世界BOSS区域 c2s
{
    static const Type kType = kEnterWorldBoss;
};
typedef struct EnterWorldBoss EnterWorldBoss;

struct EnterWorldBossReturn // 进入世界BOSS区域 s2c
{
    static const Type kType = kEnterWorldBossResult;
    Result result;          // 
    uint32_t life;          // BOSS当前血量
    uint32_t max_life;      // BOSS总血量
    uint32_t time;          // 玩家CD时间
    uint32_t hurt;          // 玩家伤害
    uint8_t count;          // 还可以使用不死鸟复活的次数
};
typedef struct EnterWorldBossReturn EnterWorldBossReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct LeaveWorldBoss // 退出世界BOSS区域 c2s
{
    static const Type kType = kLeaveWorldBoss;
};
typedef struct LeaveWorldBoss LeaveWorldBoss;

struct LeaveWorldBossReturn // 退出世界BOSS区域 s2c
{
    static const Type kType = kLeaveWorldBossResult;
    Result result;          // 
};
typedef struct LeaveWorldBossReturn LeaveWorldBossReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////

struct AttackWorldBoss // 攻击BOSS c2s
{
    static const Type kType = kAttackWorldBoss;
};
typedef struct AttackWorldBoss AttackWorldBoss;

struct AttackWorldBossReturn // 攻击BOSS s2c
{
    static const Type kType = kAttackWorldBossResult;
    Result result;          // 
    uint32_t time;          // 下次可以挑战的时间
    uint32_t hurt;          // 本次造成BOSS伤害
    uint32_t hurt_total;    // 当前对BOSS造成的总伤害
    uint32_t silver;        // 获得银币
    uint32_t prestige;      // 获得威望
    uint16_t killer;        // 是否最后一击，1是，0否
    uint16_t fight_record_bytes;      //
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct AttackWorldBossReturn AttackWorldBossReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////


struct ReduceWorldBossCD // 减少CD c2s
{
    static const Type kType = kReduceWorldBossCD;
};
typedef struct ReduceWorldBossCD ReduceWorldBossCD;

struct ReduceWorldBossCDReturn // 减少CD s2c
{
    static const Type kType = kReduceWorldBossCDResult;
    Result result;          // 
    uint32_t time;          // 下次可以挑战的时间
};
typedef struct ReduceWorldBossCDReturn ReduceWorldBossCDReturn;
//////////////////////////////////////////////////////////////////////////////////////////////////


struct PhoenixNirvana // 不死鸟复活 c2s
{
    static const Type kType = kPhoenixNirvana;
};
typedef struct PhoenixNirvana PhoenixNirvana;

struct PhoenixNirvanaReturn // 不死鸟复活 s2c
{
    static const Type kType = kPhoenixNirvanaResult;
    Result result;          // 
    uint32_t time;          // 下次可以挑战的时间
    uint8_t count;
};
typedef struct PhoenixNirvanaReturn PhoenixNirvanaReturn;


//////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////
// 服务器推送消息，进入世界BOOS区域后主动推送
struct WorldBossBoardInfo
{
    Nickname nickname;      // 玩家昵称
    uint32_t hurt;          // 对BOSS造成的总伤害
};
typedef struct WorldBossBoardInfo WorldBossBoardInfo;

struct WorldBossBoard // 玩家对BOSS造成的伤害排行榜
{ 
    static const Type kType = kPushWorldBossBoard;
    uint32_t count;
    WorldBossBoardInfo list[10];    // 按照总伤害从高到低排序
};
typedef struct WorldBossBoard WorldBossBoard;


struct WorldBossHurt // 玩家对BOSS造成的伤害
{ 
    static const Type kType = kPushWorldBossHurt;
    uint32_t life;          // BOSS当前血量
    uint32_t count;
    uint32_t list[512];
};
typedef struct WorldBossHurt WorldBossHurt;

struct WorldBossChallengerCount // 当前玩家人数
{ 
    static const Type kType = kPushWorldBossChallengerCount;
    uint32_t count;
};
typedef struct WorldBossChallengerCount WorldBossChallengerCount;

struct WorldBossCollectReward // BOSS战结束后玩家的获奖统计
{ 
    static const Type kType = kPushWorldBossCollectReward;
    uint32_t silver;                // 总银币
    uint32_t prestige;              // 总威望
    uint32_t silver_extra;          // 最后一击获得的银币
};
typedef struct WorldBossCollectReward WorldBossCollectReward;

struct WorldBossReward // BOSS战结束后上榜玩家获取奖励
{ 
    static const Type kType = kPushWorldBossReward;
    uint32_t silver;                // 银币
};
typedef struct WorldBossReward WorldBossReward;

//////////////////////////////////////////////////////////////////////////////////////////////////



struct SelectCountry //选择国家
{ 
	static const Type kType = kSelectCountry;
	int8_t country;
};
typedef struct SelectCountry SelectCountry;

struct SelectCountryResult
{ 
	static const Type kType = kSelectCountryResult;
	Result result;
};
typedef struct SelectCountryResult SelectCountryResult;

struct BuyGameResource  //购买行动力、活力等
{ 
	static const Type kType = kBuyGameResource;
	int8_t type; //资源的类型，定义在game_def.h中
};
typedef struct BuyGameResource BuyGameResource;

struct BuyGameResourceResult
{ 
	static const Type kType = kBuyGameResourceResult;
	Result result;
	uint16_t count;      // 剩余购买次数
	uint16_t use_count;      // 已经购买次数
};
typedef struct BuyGameResourceResult BuyGameResourceResult;

/*
struct GetRemainResourceBuyTimes  //获取剩余的购买次数
{ 
	static const Type kType = kGetRemainResourceBuyTimes;
	int8_t type; //资源的类型，定义在game_def.h中
};
typedef struct GetRemainResourceBuyTimes GetRemainResourceBuyTimes;

struct GetRemainResourceBuyTimesResult
{ 
	static const Type kType = kGetRemainResourceBuyTimesResult;
	int8_t times;
};
typedef struct GetRemainResourceBuyTimesResult GetRemainResourceBuyTimesResult;
*/


struct BigPacket
{ 
	static const Type kType = kBigPacket;
	char sz[30*1024]; 
};
typedef struct BigPacket BigPacket;

/////////////////////////////////////////////////////////

struct GetConfig
{ 
	static const Type kType = kGetSystemConfig;
};
typedef struct GetConfig GetConfig;

struct GetConfigResult
{ 
	static const Type kType = kGetSystemConfigResult;
	uint8_t str[256];     //最大256字节，具体长度看实际长度
};
typedef struct GetConfigResult GetConfigResult;

/////////////////////////////////////////////////////////

struct SetConfig
{ 
	static const Type kType = kSetSystemConfig;
	uint8_t str[256];   //最大256字节，超过长度自动截断
};
typedef struct SetConfig SetConfig;

struct SetConfigResult
{ 
	static const Type kType = kSetSystemConfigResult;
};
typedef struct SetConfigResult SetConfigResult;



/////////////////////////////////////////////////////////

enum {kBuidingActive=1, kSubsystemActive=2, kMaxCityhallLevelActive=3, kMapActive=4, kSkillActive=5};
struct GetActivedFunctions //获取开启的功能
{ 
	static const Type kType = kGetActivedFunctions;
	int8_t type; //1建筑 2子系统 3最大内政厅等级 4地图 5科技
};
typedef struct GetActivedFunctions GetActivedFunctions;

struct ActivedFunctions
{ 
	static const Type kType = kActivedFunctions;
	int16_t count;
	int16_t values[255];
};
typedef struct ActivedFunctions ActivedFunctions;

struct FunctionsActived //服务端主动推送
{ 
	static const Type kType = kFunctionActived;
	int16_t count;
	int16_t functions[16];
};
typedef struct FunctionsActived FunctionsActived;

/////////////////////////////////////////////////////////

struct GetRecommendCountry //获取推荐国家
{ 
	static const Type kType = kGetRecommendCountry;
};
typedef struct GetRecommendCountry GetRecommendCountry;

struct RecommendCountry
{ 
	static const Type kType = kRecommendCountry;
	uint8_t country;
};
typedef struct RecommendCountry RecommendCountry;
/////////////////////////////////////////////////////////
/*
struct GetAlchemyCount // 获取今日使用炼金术次数
{ 
	static const Type kType = kGetAlchemyCount;
};
typedef struct GetAlchemyCount GetAlchemyCount;

struct AlchemyCount
{ 
	static const Type kType = kAlchemyCount;
	uint32_t count;
};
typedef struct AlchemyCount AlchemyCount;

/////////////////////////////////////////////////////////

struct UseAlchemy // 使用炼金术
{ 
	static const Type kType = kUseAlchemy;
};
typedef struct UseAlchemy UseAlchemy;

struct UseAlchemyResult
{ 
	static const Type kType = kUseAlchemyResult;
	Result result;          // 只有执行是否正确，使用后金币、银币主动推送
};
typedef struct UseAlchemyResult UseAlchemyResult;
*/
/////////////////////////////////////////////////////////

struct GetVIPSurplusCount // 获取VIP系统各种剩余次数
{ 
	static const Type kType = kGetVIPSurplusCount;
};
typedef struct GetVIPSurplusCount GetVIPSurplusCount;

struct VIPSurplusCount
{ 
	static const Type kType = kVIPSurplusCount;
	uint16_t count[4];       // 目前为：能力购买次数、行动力购买次数、炼金术使用次数、符文中激活赤金的次数
	uint16_t use_count[4];   // 已经使用的次数
};
typedef struct VIPSurplusCount VIPSurplusCount;


/////////////////////////////////////////////////////////

struct GetRewardStatus // 获取奖励状态
{ 
	static const Type kType = kGetRewardStatus;
};
typedef struct GetRewardStatus GetRewardStatus;

struct RewardStatus // 奖励状态
{ 
	static const Type kType = kRewardStatus;
	uint8_t arena;
	uint8_t grade;
};
typedef struct RewardStatus RewardStatus;
/////////////////////////////////////////////////////////

struct ViewFightRecord // 查看战报
{ 
	static const Type kType = kViewFightRecord;
	uint32_t war_id;
};
typedef struct ViewFightRecord ViewFightRecord;

struct FightRecord // 战报
{ 
	static const Type kType = kFightRecord;
    uint16_t fight_record_bytes;
    uint8_t fight_record[kMaxFightRecordLength];
};
typedef struct FightRecord FightRecord;
/////////////////////////////////////////////////////////

struct NotifyResetAssistant	//重置助手
{
	static const Type kType = kNotifyResetAssistant;
};
typedef struct NotifyResetAssistant NotifyResetAssistant;

struct AssistantGetReward	//领取奖励
{
	static const Type kType = kAssistantGetReward;
	uint8_t index;		//领取哪一个,以1为基数
};
typedef struct AssistantGetReward AssistantGetReward;

struct AssistantGetRewardResult
{
	static const Type kType = kAssistantGetRewardResult;
	Result result;
};
typedef struct AssistantGetRewardResult AssistantGetRewardResult;

struct GetAssistantInfo
{
	static const Type kType = kGetAssistantInfo;
};
typedef struct GetAssistantInfo GetAssistantInfo;

struct AssistantTask
{
	int16_t task_id;
	int16_t b_retrieve;		//是否可找回
	int32_t times;			//完成次数
};
typedef struct AssistantTask AssistantTask;

struct GetAssistantInfoResult
{
	static const Type kType = kGetAssistantInfoResult;
	uint16_t activity;		//活跃度
	uint16_t draw;			//领取状态
	int16_t unuse1;
	int16_t amount;			//task amount
	AssistantTask tasks[64];
};
typedef struct GetAssistantInfoResult GetAssistantInfoResult;

struct RetrieveAssistantTask
{
	static const Type kType = kRetrieveAssistantTask;
	int16_t task_id;
};
typedef struct RetrieveAssistantTask RetrieveAssistantTask;

struct RetrieveAssistantTaskResult
{
	static const Type kType = kRetrieveAssistantTaskResult;
	Result result;
	int32_t times;
};
typedef struct RetrieveAssistantTaskResult RetrieveAssistantTaskResult;


/////////////////////////////////////////////////////////////
struct GetTreeWater
{
	static const Type kType = kGetTreeWater;
};
typedef struct GetTreeWater GetTreeWater;

struct GetTreeWaterResult
{
	static const Type kType = kGetTreeWaterResult;
	Result  result;
	uint8_t water_amount;	//神水数量
	uint8_t buy_count;		//购买神水次数

};
typedef struct GetTreeWaterResult GetTreeWaterResult;

struct GetTreeSeeds
{
	static const Type kType = kGetTreeSeeds;
	UserID uid;
};
typedef struct GetTreeSeeds GetTreeSeeds;

enum TreeSeedStatus { kSeedGrowing=1, kSeedArid=2, kSeedRipe=3 };

struct TreeSeed
{
	int32_t ripe_time;	//剩余成熟时间
	uint32_t last_water;	//上次浇水时间,绝对时间
	uint8_t	kind;	//种子种类
	int8_t	location;//位置
	int8_t  status;		//状态,上面有定义
	int8_t  watered;		//浇神水次数
};
typedef struct TreeSeed TreeSeed;

struct GetTreeSeedsResult
{
	static const Type kType = kGetTreeSeedsResult;
	Result	result;
	int32_t amount;
	TreeSeed seeds[10];
};
typedef struct GetTreeSeedsResult GetTreeSeedsResult;

struct GetTreeLogs
{
	static const Type kType = kGetTreeLogs;
	UserID uid;
};
typedef struct GetTreeLogs GetTreeLogs;

struct TreeLog
{
	uint32_t time;	//来访时间
	Nickname name;	//来访玩家
};
typedef struct TreeLog TreeLog;

struct GetTreeLogsResult
{
	static const Type kType = kGetTreeLogsResult;
	Result  result;
	int16_t sex;
	int16_t amount;
	TreeLog logs[50];
};
typedef struct GetTreeLogsResult GetTreeLogsResult;

struct ExitTree		//退出幸运树,从别人的幸运树界面离开
{
	static const Type kType = kExitTree;
};
typedef struct ExitTree ExitTree;

struct ExitTreeResult
{
	static const Type kType = kExitTreeResult;
	Result result;
};
typedef struct ExitTreeResult ExitTreeResult;

enum WaterTreeType { kWaterNormal=1, kWaterGod=2, kWaterGodByBuy=3 };
struct WaterTree
{
	static const Type kType = kWaterTree;
	UserID uid;
	int8_t type;	//见上面
	int8_t location;
};
typedef struct WaterTree WaterTree;

struct WaterTreeResult
{
	static const Type kType = kWaterTreeResult;
	Result result;
};
typedef struct WaterTreeResult WaterTreeResult;

struct PushSeedStatus
{
	static const Type kType = kPushSeedStatus;
	TreeSeed seed;
};
typedef struct PushSeedStatus PushSeedStatus;

struct PushVisitLog
{
	static const Type kType = kPushVisitLog;
	TreeLog log;
};
typedef struct PushVisitLog PushVisitLog;

struct PickFruit
{
	static const Type kType = kPickFruit;
	int8_t location;
};
typedef struct PickFruit PickFruit;

struct PickFruitResult
{
	static const Type kType = kPickFruitResult;
	Result result;
};
typedef struct PickFruitResult PickFruitResult;

struct PushResetTree
{
	static const Type kType = kPushResetTree;
};
typedef struct PushResetTree PushResetTree;



//////////////////////////////////////////////////////////////////////////
//前3日金币
typedef struct _GetDaysAgoInfo
{
	static const Type kType = kGetDaysAgoInfo;
}GetDaysAgoInfo;

typedef struct _GetDaysAgoInfoResult
{
	static const Type kType = kGetDaysAgoInfoResult;
	uint16_t amount;		//领取多少金币
	uint16_t exist_reward;	//是否存在奖励, 1(存在), 0(不存在)
}GetDaysAgoInfoResult;

typedef struct _GetRewardDaysAgo
{
	static const Type kType = kGetRewardDaysAgo;
}GetRewardDaysAgo;

typedef struct _GetRewardDaysAgoResult
{
	static const Type kType = kGetRewardDaysAgoResult;
	Result result;
}GetRewardDaysAgoResult;

//////////////////////////////////////////////////////////////////////////
//收藏网址
typedef struct _GetSaveWebsiteInfo
{
	static const Type kType = kGetSaveWebsiteInfo;
}GetSaveWebsiteInfo;

typedef struct _SaveWebsiteReward
{
	uint16_t type;
	uint16_t kind;
	uint32_t amount;
}SaveWebsiteReward;

typedef struct _GetSaveWebsiteInfoResult
{
	static const Type kType = kGetSaveWebsiteInfoResult;
	uint16_t exist_reward;
	uint16_t amount;		//reward的数量
	SaveWebsiteReward rewards[4];
}GetSaveWebsiteInfoResult;

typedef struct _GetSaveWebsiteReward
{
	static const Type kType = kGetSaveWebsiteReward;
}GetSaveWebsiteReward;

typedef struct _GetSaveWebsiteRewardResult
{
	static const Type kType = kGetSaveWebsiteRewardResult;
	Result result;
}GetSaveWebsiteRewardResult;
//////////////////////////////////////////////////////////////////////////
//抽奖
typedef struct _GetLuckyDrawInfo
{
	static const Type kType = kGetLuckyDrawInfo;
}GetLuckyDrawInfo;

typedef struct _GetLuckyDrawInfoResult
{
	static const Type kType = kGetLuckyDrawInfoResult;
	uint32_t times;	//已经抽奖次数
}GetLuckyDrawInfoResult;

typedef struct _DoLuckyDraw
{
	static const Type kType = kDoLuckyDraw;
}DoLuckyDraw;

typedef struct _DoLuckyDrawResult
{
	static const Type kType = kDoLuckyDrawResult;
	Result result;
	PropID equip_id;		//装备id
	uint8_t location;
}DoLuckyDrawResult;


//////////////////////////////////////////////////////////////////////////
//每日签到
typedef struct _GetCheckInEveryDayInfo
{
	static const Type kType = kGetCheckInEveryDayInfo;
}GetCheckInEveryDayInfo;

typedef struct _CheckInEveryDayReward
{
	PropSid  kind;
	uint16_t amount;
}CheckInEveryDayReward;

typedef struct _CheckInEveryDayRewards
{
	CheckInEveryDayReward rewards[6];
}CheckInEveryDayRewards;

typedef struct _GetCheckInEveryDayInfoResult
{
	static const Type kType = kGetCheckInEveryDayInfoResult;
	CheckInEveryDayRewards rewards[5];
	uint32_t time;		//上次签到的时间
	uint8_t days;		//连续签到的天数
}GetCheckInEveryDayInfoResult;

typedef struct _DoCheckInEveryDay
{
	static const Type kType = kDoCheckInEveryDay;
}DoCheckInEveryDay;

typedef struct _DoCheckInEveryDayResult
{
	static const Type kType = kDoCheckInEveryDayResult;
	Result result;
	uint32_t time;		//签到时间
}DoCheckInEveryDayResult;

//////////////////////////////////////////////////////////////////////////
//累计签到
typedef struct _GetCheckInAccumulateInfo
{
	static const Type kType = kGetCheckInAccumulateInfo;
}GetCheckInAccumulateInfo;

typedef struct _GetCheckInAccumulateInfoResult
{
	static const Type kType = kGetCheckInAccumulateInfoResult;
	uint32_t time;		//上次签到时间
	uint8_t days;		//签到天数
}GetCheckInAccumulateInfoResult;

typedef struct _GetCheckInAccumulateReward
{
	static const Type kType = kGetCheckInAccumulateReward;
	uint8_t b_direct;		//1=直接领取(充值达到一定金币)
}GetCheckInAccumulateReward;

typedef struct _GetCheckInAccumulateRewardResult
{
	static const Type kType = kGetCheckInAccumulateRewardResult;
	Result result;
	uint32_t time;
}GetCheckInAccumulateRewardResult;



/////////////////////////////////////////////////////////

struct RaidersInfo
{
    Nickname nickname;      // 玩家昵称
    uint32_t level;         // 玩家等级
    uint32_t war_id;        // 战报ID
};
typedef struct RaidersInfo RaidersInfo;

struct GetRaiders
{
	static const Type kType = kGetRaiders;
	uint16_t id;         // 第几关
	uint8_t type;        // 攻略类型 1剧情 2英雄 3试练塔
	uint8_t sub_id;      // 第几步
};
typedef struct GetRaiders GetRaiders;

struct Raiders
{
	static const Type kType = kRaiders;
	uint32_t count;
	RaidersInfo list[5];        // 最近战报，按照时间排序
};
typedef struct Raiders Raiders;




/////////////////////////////////////////////////////////
// 试炼塔

struct GetTowerInfo
{
    static const Type kType = kGetTowerInfo;
};
typedef struct GetTowerInfo GetTowerInfo;

struct GetTowerInfoResult
{
    static const Type kType = kGetTowerInfoResult;
    Result result;
    uint8_t tower;      // 塔通关进度
    uint8_t layer;      // 层通关进度  例如 1，0 代表当前应该挑战1号塔第一层
    uint8_t refresh;    // 刷新次数
    uint8_t status;     // 当前状态 0 只能挑战 其它 当前可以扫荡的塔
    uint32_t time;      // 挑战CD时间，当前时间大于这个时间才能挑战
    uint8_t suspend;    // 当前扫荡应该从这层开始
};
typedef struct GetTowerInfoResult GetTowerInfoResult;


struct ResetTower
{
    static const Type kType = kResetTower;
    uint8_t tower;      // 重置哪个塔
};
typedef struct ResetTower ResetTower;

struct ResetTowerResult
{
    static const Type kType = kResetTowerResult;
    Result result;
};
typedef struct ResetTowerResult ResetTowerResult;


struct FightTower
{
    static const Type kType = kFightTower;
};
typedef struct FightTower FightTower;

struct FightTowerResult
{
    static const Type kType = kFightTowerResult;
    Result result;
    uint8_t tower;      // 塔通关进度
    uint8_t layer;      // 层通关进度  例如 1，0 代表当前应该挑战1号塔第一层
    uint8_t succeed;    // 战斗结果 0失败 1胜利
    uint8_t unused;     // 对齐占用
    uint32_t time;      // 挑战CD时间，当前时间大于这个时间才能挑战
    uint16_t fight_record_bytes;      // 战报长度
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct FightTowerResult FightTowerResult;


struct MopupTower
{
    static const Type kType = kMopupTower;
};
typedef struct MopupTower MopupTower;

struct MopupTowerResult
{
    static const Type kType = kMopupTowerResult;
    Result result;
    uint8_t suspend;        // 1 扫荡被挂起，清理背包后可继续扫荡 0 扫荡完成
};
typedef struct MopupTowerResult MopupTowerResult;


//试炼塔奖励推送
struct TowerRewardProp
{
    uint16_t sid;       // 道具sid
    uint16_t amount;    // 道具数量
};
typedef struct TowerRewardProp TowerRewardProp;

struct TowerReward
{
    uint32_t silver;    // 奖励银币
    uint32_t exp;       // 奖励经验
    uint8_t tower;
    uint8_t layer;
    uint8_t mopup;      // 0战斗奖励 1扫荡奖励
    uint8_t count;      // 奖励道具个数
    TowerRewardProp list[10];   //实际个数看count
};
typedef struct TowerReward TowerReward;

struct PushTowerReward
{
    static const Type kType = kPushTowerReward;
    uint32_t count;
    TowerReward list[100];   // 实际个数看count
};
typedef struct PushTowerReward PushTowerReward;

enum 
{
	kServerIDGate=1,
	kServerIDData=2,
	kServerIDWorld=3,
	kServerIDInteract=4,
};
typedef struct _Ping
{ 
	static const Type kType = kPing;
	uint8_t server;  //上面定义的enum
}Ping;

typedef struct _PingResult
{ 
	static const Type kType = kPingResult;

}PingResult;


struct GetStageAwardInfo    // 获取目标领奖信息
{
    static const Type kType = kGetStageAwardInfo;
};
typedef struct GetStageAwardInfo GetStageAwardInfo;

struct StageAwardInfo
{
    static const Type kType = kGetStageAwardInfoResult;
    uint32_t count;
    struct 
    {
        uint8_t sid;
        uint8_t stage;  // 大阶段
        uint8_t phase;  // 小阶段
        uint8_t status; // 状态 0未完成 1完成未领取 2完成已经领取
    } list[1024];
};
typedef struct StageAwardInfo StageAwardInfo;


struct GetStageAward    // 获取目标领奖
{
    static const Type kType = kGetStageAward;
    uint16_t stage;  // 大阶段
    uint16_t phase;  // 小阶段，0代表宝箱奖励
};
typedef struct GetStageAward GetStageAward;

struct StageAwardResult
{
    static const Type kType = kGetStageAwardResult;
    Result result; 
    // 实际奖励读表吧
};
typedef struct StageAwardResult StageAwardResult;
