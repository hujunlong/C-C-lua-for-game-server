#pragma once
#include "define.h"

enum PVP
{
    //竞技场
    kGetArenaInfo = kPVPTypeBegin + 1,
    kGetChallengeList = kPVPTypeBegin + 2,
    kGetWarReport = kPVPTypeBegin + 3,
    kGetRankingTop = kPVPTypeBegin + 4,
    kClearCDTime = kPVPTypeBegin + 5,
    kBuyChallengeTimes = kPVPTypeBegin + 6,
    kGetRankReward = kPVPTypeBegin + 7,
    //kGetbackRankReward = kPVPTypeBegin + 8,
    kStartChallenge = kPVPTypeBegin + 9,
    kGetFirstPlace = kPVPTypeBegin + 20,
    //军阶
    kGetGradeInfo = kPVPTypeBegin + 101,
    kGetGradeReward = kPVPTypeBegin + 102,
    //kGetbackGradeReward = kPVPTypeBegin + 103,
    kElevateOfficial = kPVPTypeBegin + 104,
    kActivateHeros = kPVPTypeBegin + 105,
    kGetSpecialGradeInfo = kPVPTypeBegin + 106,
    //护送
    kGetEscortStatus = kPVPTypeBegin + 201,
    kGetEscortNews = kPVPTypeBegin + 202,
    kEnterEscortPlace = kPVPTypeBegin + 203,
    kLeaveEscortPlace = kPVPTypeBegin + 204,
    kGetEscortInfo = kPVPTypeBegin + 205,
    kSetAutoAccept = kPVPTypeBegin + 206,
    kRefreshTransport = kPVPTypeBegin + 207,
    kStartEscort = kPVPTypeBegin + 208,
    kGetEscortInfoDetail = kPVPTypeBegin + 212,
    kGetEscortRank = kPVPTypeBegin + 213,
    kRobEscort = kPVPTypeBegin + 214,
    kInviteEscortRequest = kPVPTypeBegin + 216,
    kInviteEscortRespond = kPVPTypeBegin + 217,
    kClearEscortCD = kPVPTypeBegin + 221,
    
    /*
        国战占用了
        300-500
    */
    
    //领地
    kGetTerritoryStatus = kPVPTypeBegin + 501,
    kViewTerritory = kPVPTypeBegin + 502,
    kTerritoryGPS = kPVPTypeBegin + 503,
    kMoveTerritory = kPVPTypeBegin + 504,
    //kReapResource = kPVPTypeBegin + 505,
    kGrabResource = kPVPTypeBegin + 506,
    kDiscardResource = kPVPTypeBegin + 507,
    kKillBandits = kPVPTypeBegin + 508,
    kStopViewTerritory = kPVPTypeBegin + 509,
    kClearTerritoryCD = kPVPTypeBegin + 510,
    kSetTerritorySkin = kPVPTypeBegin + 511,
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // 返回消息
    
    //竞技场
    kGetArenaInfoResult = kPVPReturnBegin + 1,
    kGetChallengeListResult = kPVPReturnBegin + 2,
    kGetWarReportResult = kPVPReturnBegin + 3,
    kGetRankingTopResult = kPVPReturnBegin + 4,
    kClearCDTimeResult = kPVPReturnBegin + 5,
    kBuyChallengeTimesResult = kPVPReturnBegin + 6,
    kGetRankRewardResult = kPVPReturnBegin + 7,
    //kGetbackRankRewardResult = kPVPReturnBegin + 8,
    kStartChallengeResult = kPVPReturnBegin + 9,
    kPushOccurredChallenge = kPVPReturnBegin + 10,
    kGetFirstPlaceResult = kPVPReturnBegin + 20,
    //军阶
    kGetGradeInfoResult = kPVPReturnBegin + 101,
    kGetGradeRewardResult = kPVPReturnBegin + 102,
    //kGetbackGradeRewardResult = kPVPReturnBegin + 103,
    kElevateOfficialResult = kPVPReturnBegin + 104,
    kActivateHerosResult = kPVPReturnBegin + 105,
    kGetSpecialGradeInfoResult = kPVPReturnBegin + 106,
    
    kPushGradeChange = kPVPReturnBegin + 150,
    
    //护送返回
    kGetEscortStatusResult = kPVPReturnBegin + 201,
    kGetEscortNewsResult = kPVPReturnBegin + 202,
    kEnterEscortPlaceResult = kPVPReturnBegin + 203,
    kLeaveEscortPlaceResult = kPVPReturnBegin + 204,
    kGetEscortInfoResult = kPVPReturnBegin + 205,
    kSetAutoAcceptResult = kPVPReturnBegin + 206,
    kRefreshTransportResult = kPVPReturnBegin + 207,
    
    kStartEscortResult = kPVPReturnBegin + 208,
    kPushEscortNews = kPVPReturnBegin + 209,
    kPushEscortInfo = kPVPReturnBegin + 210,
    kPushEscortReward = kPVPReturnBegin + 211,

    kGetEscortInfoDetailResult = kPVPReturnBegin + 212,
    kGetEscortRankResult = kPVPReturnBegin + 213,
    
    kRobEscortResult = kPVPReturnBegin + 214,
    kPushEscortBeRobed = kPVPReturnBegin + 215,
    
    kInviteEscortRequestResult = kPVPReturnBegin + 216,
    kInviteEscortRespondResult = kPVPReturnBegin + 217,
    kPushEscortInviteRequest = kPVPReturnBegin + 218,
    kPushEscortInviteRespond = kPVPReturnBegin + 219,
    kPushEscortInviteResult = kPVPReturnBegin + 220,
    
    kClearEscortCDResult = kPVPReturnBegin + 221,
    
    /*
        国战占用了
        300-500
    */
    
    //领地
    kGetTerritoryStatusResult = kPVPReturnBegin + 501,
    kViewTerritoryResult = kPVPReturnBegin + 502,
    kTerritoryGPSResult = kPVPReturnBegin + 503,
    kMoveTerritoryResult = kPVPReturnBegin + 504,
    //kReapResourceResult = kPVPReturnBegin + 505,
    kGrabResourceResult = kPVPReturnBegin + 506,
    kDiscardResourceResult = kPVPReturnBegin + 507,
    kKillBanditsResult = kPVPReturnBegin + 508,
    kStopViewTerritoryResult = kPVPReturnBegin + 509,
    kClearTerritoryCDResult = kPVPReturnBegin + 510,
    kSetTerritorySkinResult = kPVPReturnBegin + 511,
    
    kPushTerritoryChallenge = kPVPReturnBegin + 551,
    kPushTerritoryChange = kPVPReturnBegin + 552,
    kPushTerritoryTimeout = kPVPReturnBegin + 553,
    kPushTerritoryPage = kPVPReturnBegin + 554,
};

enum ArenaResultType
{
    ArenaResultBegin = 12000,
    ARENA_SUCCESS = ArenaResultBegin + 1,                           // 成功（这个不用，用0返回）
    ARENA_NOT_ENOUGH_GOLD = ArenaResultBegin + 2,                   // 金币不足
    ARENA_NOT_ENOUGH_CHALLENGE_TIMES = ArenaResultBegin + 3,        // 挑战次数不足
    ARENA_NOT_ENOUGH_BUY_TIMES = ArenaResultBegin + 4,              // 购买次数用完
    ARENA_NOT_YET_ACTIVATE = ArenaResultBegin + 5,                  // 尚未激活竞技场功能
    ARENA_HAVE_CD_TIME = ArenaResultBegin + 6,                      // CD冷却中
    ARENA_INVALID_TARGET = ArenaResultBegin + 7,                    // 无效的挑战者目标
    ARENA_INVALID_STEP = ArenaResultBegin + 8,                      // 无效的挑战者阶梯
    ARENA_CANT_GETBACK_REWARD = ArenaResultBegin + 9,               // 不能找回昨日奖励
    ARENA_NO_GETBACK_REWARD = ArenaResultBegin + 10,                // 没有昨日奖励
    ARENA_NOT_ENOUGH_REWARD = ArenaResultBegin + 11,                // 今天没有奖励
    ARENA_NO_NEED_CLEAR_CD = ArenaResultBegin + 12,                 // 无需清除CD
};

enum GradeResultType
{
    GradeResultBegin = 12100,
    GRADE_NOT_ACTIVATE = GradeResultBegin + 1,                  // 尚未激活军阶功能
    GRADE_NOT_ENOUGH_REWARD = GradeResultBegin + 2,             // 不能领取奖励
    GRADE_CANT_GETBACK_REWARD = GradeResultBegin + 3,           // 不能找回奖励
    GRADE_CANT_UPGRADE_LEVEL = GradeResultBegin + 4,            // 不能升级官职
    GRADE_HAVE_ACTIVATE_HERO = GradeResultBegin + 5,            // 已经激活该英雄
    GRADE_CANT_ACTIVATE_HERO = GradeResultBegin + 6,            // 未到激活该英雄条件
};

enum EscortResultType
{
    EscortResultBegin = 12200,
    ESCORT_SUCCESS = EscortResultBegin + 1,                    // 成功
    ESCORT_NOT_ACTIVATE = EscortResultBegin + 2,               // 尚未激活护送功能
    ESCORT_NOT_ENOUGH_GOLD = EscortResultBegin + 3,            // 金币不足
    ESCORT_ON_THE_TOP = EscortResultBegin + 4,                 // 已经是顶级交通工具
    ESCORT_NO_MORE_TIMES = EscortResultBegin + 5,              // 没有护送次数了
    ESCORT_ON_THE_WAY = EscortResultBegin + 6,                 // 正在护送路上
    ESCORT_INVALID_TRANSPORT = EscortResultBegin + 7,          // 没有这个交通工具
    ESCORT_INVALID_PAGE = EscortResultBegin + 8,               // 没有这页排行榜
    ESCORT_INVALID_TARGET = EscortResultBegin + 9,             // 不正确的目标
    ESCORT_DONT_NEED_CLEAR = EscortResultBegin + 10,           // 不需要清除CD
};

enum TerritoryResultType
{
    TerritoryResultBegin     = 12300,
    TERRITORY_SUCCESS        = TerritoryResultBegin + 1,               // 成功
    TERRITORY_NOT_ACTIVATE   = TerritoryResultBegin + 2,               // 尚未激活领地功能
    TERRITORY_INVALID_TYPE   = TerritoryResultBegin + 3,               // 类型错误
    TERRITORY_INVALID_PAGE   = TerritoryResultBegin + 4,               // 页数错误
    TERRITORY_NO_MORE_TIMES  = TerritoryResultBegin + 5,               // 次数不够
    TERRITORY_INVALID_TARGET = TerritoryResultBegin + 6,               // 无效的目标
    TERRITORY_HAVE_CD_TIME   = TerritoryResultBegin + 7,               // 战斗CD中/保护CD中
    TERRITORY_NO_RESOURCE    = TerritoryResultBegin + 8,               // 玩家没有资源点
    TERRITORY_NO_NEED_CLEAR  = TerritoryResultBegin + 9,               // 不需要清除CD
    TERRITORY_NO_ENOUGH_GOLD = TerritoryResultBegin + 10,              // 金币不足
    TERRITORY_NO_RIGHT       = TerritoryResultBegin + 11,              // 权利不足
};

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// c2s 除了"开始一场挑战、获取排名奖励"，其它消息都不需要发送Type以外的信息

struct StartChallenge // 开始一场挑战
{
    static const Type kType = kStartChallenge;
    uint32_t target_rank; // 目标竞技场排名
};
typedef struct StartChallenge StartChallenge;

struct GetRankReward // 获取排名奖励
{
    static const Type kType = kGetRankReward;
    //uint8_t getback;      // 是否领取昨天的奖励，0为今天的奖励，1为昨天的奖励
};
typedef struct GetRankReward GetRankReward;

struct GetArenaInfo // 获取竞技场信息
{
    static const Type kType = kGetArenaInfo;
};
typedef struct GetArenaInfo GetArenaInfo;

struct GetChallengeList // 获取挑战列表
{
    static const Type kType = kGetChallengeList;
};
typedef struct GetChallengeList GetChallengeList;

struct GetWarReport // 进入竞技场
{
    static const Type kType = kGetWarReport;
};
typedef struct GetWarReport GetWarReport;

struct GetRankingTop // 获取排行榜前十玩家
{
    static const Type kType = kGetRankingTop;
};
typedef struct GetRankingTop GetRankingTop;

struct ClearCDTime // 清除CD
{
    static const Type kType = kClearCDTime;
};
typedef struct ClearCDTime ClearCDTime;

struct BuyChallengeTimes // 购买挑战次数
{
    static const Type kType = kBuyChallengeTimes;
};
typedef struct BuyChallengeTimes BuyChallengeTimes;

/*
struct GetbackRankReward // 找回排名奖励
{
    static const Type kType = kGetbackRankReward;
};
typedef struct GetbackRankReward GetbackRankReward;
*/

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// s2c 交互主要看这里

struct GetArenaInfoReturn // 获取竞技场信息
{
    static const Type kType = kGetArenaInfoResult;
    Result result;            //
    uint32_t rank;             // 当前竞技场排名
    uint32_t time;             // 下次可以挑战的时间
    uint16_t remain_count;     // 剩余挑战次数
    uint16_t win_count;        // 连胜次数
    uint16_t reward;           // 0为不可以领取今天奖励，1为可以领奖
    //uint16_t reward_bak;       // 0为不可以找回，1为可以找回，2为可以领取昨天的奖励
    uint8_t grade;            // 军阶
    uint8_t buy_count;         // 剩余购买次数
};
typedef struct GetArenaInfoReturn GetArenaInfoReturn;

struct ArenaTargetInfo // 目标信息
{
    uint32_t rank;      // 排名
    UserID player;      // 玩家ID
    Nickname nickname;  // 名称
    uint16_t level;      // 等级
    uint16_t grade;      // 军阶
};
typedef struct ArenaTargetInfo ArenaTargetInfo;

struct GetChallengeListReturn // 获取挑战列表
{
    static const Type kType = kGetChallengeListResult;
    Result result;          //
    uint32_t list_count;      //数组实际个数
    ArenaTargetInfo list[10]; //挑战列表，按照竞技场排名降序排列，6 5 4 3 2……
};
typedef struct GetChallengeListReturn GetChallengeListReturn;

struct ArenaWarInfo // 竞技场战报信息
{
    UserID target;       // 对方玩家ID
    Nickname nickname;   // 对方名称
    uint16_t initiative;  // 是否主动挑战，1为主动，0为被动
    uint16_t winner;      // 输赢 1为胜利，0为失败
    int32_t rank_change; // 排名改变，0未改变，正数是升，负数是降，数值是排名绝对值
    uint32_t war_id;     // 战报ID
    uint32_t time;       // 挑战发生时间
};
typedef struct ArenaWarInfo ArenaWarInfo;
struct GetWarReportReturn   // 获取最近战报
{
    static const Type kType = kGetWarReportResult;
    Result result;          //
    uint32_t war_count;    // 战报实际个数
    ArenaWarInfo list[5];  // 战报ID，按照挑战时间升序排列，[0]是最近的挑战，[4]是最久的挑战
};
typedef struct GetWarReportReturn GetWarReportReturn;

struct GetRankingTopReturn // 获取排行榜前十玩家
{
    static const Type kType = kGetRankingTopResult;
    Result result;           //
    uint32_t list_count;       //数组实际个数
    ArenaTargetInfo list[10]; //挑战列表，按照竞技场排名升序排列，1 2 3 4 5 6
};
typedef struct GetRankingTopReturn GetRankingTopReturn;

struct ClearCDTimeReturn // 清除CD
{
    static const Type kType = kClearCDTimeResult;
    Result result;          //
    uint32_t time;           //下次可以挑战的时间
};
typedef struct ClearCDTimeReturn ClearCDTimeReturn;

struct BuyChallengeTimesReturn // 购买挑战次数
{
    static const Type kType = kBuyChallengeTimesResult;
    Result result;          //
    uint8_t remain_count;    //剩余挑战次数
    uint8_t buy_count;      // 剩余购买次数
};
typedef struct BuyChallengeTimesReturn BuyChallengeTimesReturn;

struct GetRankRewardReturn // 获取排名奖励
{
    static const Type kType = kGetRankRewardResult;
    Result result;          //
    uint32_t silver;          // 银币
    uint16_t prestige;        // 威望
};
typedef struct GetRankRewardReturn GetRankRewardReturn;

/*
struct GetbackRankRewardReturn // 找回排名奖励
{
    static const Type kType = kGetbackRankRewardResult;
    Result result;          //
};
typedef struct GetbackRankRewardReturn GetbackRankRewardReturn;
*/
struct StartChallengeReturn // 开始一场挑战
{
    static const Type kType = kStartChallengeResult;
    Result result;          //
    uint32_t silver;          // 银币
    uint8_t victory;         // 1代表胜利，0代表挑战失败
    uint8_t prestige;        // 威望
    uint16_t fight_record_bytes;
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct StartChallengeReturn StartChallengeReturn;

struct PushOccurredChallenge  // 你被别人挑战了｛收到此消息刷新最近战报｝
{
    static const Type kType = kPushOccurredChallenge;
    Nickname nickname;         // 挑战者名称
    int32_t rank_change;  // 排名改变，0未改变（你赢了），1未改变（你输了），负数是降（你输了，需要刷新排行榜），数值是排名绝对值
    uint32_t war_id;      // 战报ID
    uint16_t fight_record_bytes;      // 如果为0，说明是离线消息，没有保存战报，根据战报ID再次取出战报
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct PushOccurredChallenge PushOccurredChallenge;


struct GetFirstPlace
{
    static const Type kType = kGetFirstPlace;
};
typedef struct GetFirstPlace GetFirstPlace;

struct GetFirstPlaceResult
{
    static const Type kType = kGetFirstPlaceResult;
    Result result;
    uint32_t time;          // 发生时间（如果为0说明没有，后面的不读）
    Nickname winner; /* winner打败了loser 获得了第1名 */
    Nickname loser;
};
typedef struct GetFirstPlaceResult GetFirstPlaceResult;


//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// 下面是军阶系统

struct GetGradeInfo // 获取军阶信息 c2s
{
    static const Type kType = kGetGradeInfo;
};
typedef struct GetGradeInfo GetGradeInfo;

struct HeroRecruitInfo // 英雄招募状态
{
    uint8_t hero_id;
    uint8_t status;     // 0 不可招募，1 已经招募，2 可以招募
};
typedef struct HeroRecruitInfo HeroRecruitInfo;

struct GetGradeInfoReturn // 获取军阶信息 s2c
{
    static const Type kType = kGetGradeInfoResult;
    Result result;          // 
    uint32_t prestige;      // 当前总威望
    uint16_t level;          // 当前军阶等级
    uint16_t count;          // 英雄数量
    HeroRecruitInfo heros[8];     // 可以激活的英雄，最多8个
};
typedef struct GetGradeInfoReturn GetGradeInfoReturn;

//////////////////////////////////////////////////////////////////////////

struct GetGradeReward // 领取军衔奖励 c2s
{
    static const Type kType = kGetGradeReward;
    //uint8_t getback;      // 是否领取昨天的奖励，0为今天的奖励，1为昨天的奖励
};
typedef struct GetGradeReward GetGradeReward;

struct GetGradeRewardReturn // 领取军衔奖励 s2c
{
    static const Type kType = kGetGradeRewardResult;
    Result result;          // 
    uint32_t silver;        // 领到的银币
};
typedef struct GetGradeRewardReturn GetGradeRewardReturn;

//////////////////////////////////////////////////////////////////////////
/*
struct GetbackGradeReward // 找回奖励 c2s
{
    static const Type kType = kGetbackGradeReward;
};
typedef struct GetbackGradeReward GetbackGradeReward;

struct GetbackGradeRewardReturn // 找回奖励 s2c
{
    static const Type kType = kGetbackGradeRewardResult;
    Result result;          // 
};
typedef struct GetbackGradeRewardReturn GetbackGradeRewardReturn;
*/
//////////////////////////////////////////////////////////////////////////

struct ElevateOfficial // 升级官职 c2s
{
    static const Type kType = kElevateOfficial;
};
typedef struct ElevateOfficial ElevateOfficial;

struct ElevateOfficialReturn // 升级官职 s2c
{
    static const Type kType = kElevateOfficialResult;
    Result result;          // 
};
typedef struct ElevateOfficialReturn ElevateOfficialReturn;

//////////////////////////////////////////////////////////////////////////

struct ActivateHeros // 激活英雄 c2s
{
    static const Type kType = kActivateHeros;
    uint8_t hero_id;    
};
typedef struct ActivateHeros ActivateHeros;

struct ActivateHerosReturn // 激活英雄 s2c
{
    static const Type kType = kActivateHerosResult;
    Result result;          // 
};
typedef struct ActivateHerosReturn ActivateHerosReturn;

//////////////////////////////////////////////////////////////////////////

//!!!!!!!此接口废弃，使用WorldWar.h中的kAdvancedGradeInfo
struct GetSpecialGradeInfo // 获取特殊军阶信息 c2s
{
    static const Type kType = kGetSpecialGradeInfo;
};
typedef struct GetSpecialGradeInfo GetSpecialGradeInfo;

struct GetSpecialGradeInfoResult // 获取特殊军阶信息 s2c
{
    static const Type kType = kGetSpecialGradeInfoResult;
    Result result;          // 
    uint32_t score;         // 本周国家贡献
    uint32_t total;         // 本周参战人数
    uint32_t rank;          // 本周国家贡献排名
};
typedef struct GetSpecialGradeInfoResult GetSpecialGradeInfoResult;

//////////////////////////////////////////////////////////////////////////

struct GradeChange // 军阶变动推送 s2c
{
    static const Type kType = kPushGradeChange;
    uint8_t level;
};
typedef struct GradeChange GradeChange;

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// 下面是护送系统

//////////////////////////////////////////////////////////////////////////

struct GetEscortStatus // 获取护送状态 c2s
{
    static const Type kType = kGetEscortStatus;
};
typedef struct GetEscortStatus GetEscortStatus;

struct GetEscortStatusReturn // 获取护送状态 s2c
{
    static const Type kType = kGetEscortStatusResult;
    Result result;          // 
    uint8_t escort_count;     // 剩余护送次数
    uint8_t defend_count;     // 剩余护卫次数
    uint8_t intercept_count;  // 剩余拦截次数
    uint8_t auto_accept;      // 自动应答状态
    uint32_t time;            // 这个时间以后才可以再次护送
    uint16_t type;            // 交通工具状态
    uint16_t refresh;         // 刷新次数
    uint32_t rob_time;        // 这个时间以后才可以再次打劫
};
typedef struct GetEscortStatusReturn GetEscortStatusReturn;

//////////////////////////////////////////////////////////////////////////

struct EscortNews
{
    uint16_t isRob;  // 是否是抢劫新闻，1代表是，0代表不是
    uint16_t type;   // 交通工具
    union
    {
        struct 
        {
            // 某某某 成功 拦截了 某某某 护送的 XXX 队伍，抢到了 XX 银币 和 XX 威望
            Nickname looter;    // 拦截者
            Nickname escort;    // 护卫者
            uint32_t silver;     // 银币
            uint32_t prestige;   // 威望
        }looter;
        struct 
        {
            // 某某某 开始护送 【华丽的魔毯】
            Nickname escort;    // 护卫者
        }escort;
    }news;
};
typedef struct EscortNews EscortNews;

struct GetEscortNews // 获取护送咨询 c2s
{
    static const Type kType = kGetEscortNews;
};
typedef struct GetEscortNews GetEscortNews;

struct GetEscortNewsReturn // 获取护送咨询 s2c
{
    static const Type kType = kGetEscortNewsResult;
    Result result;          // 
    uint32_t count;          // 新闻实际个数
    EscortNews list[5];     // 新闻
};
typedef struct GetEscortNewsReturn GetEscortNewsReturn;

//////////////////////////////////////////////////////////////////////////

struct EnterEscortPlace // 进入护送区域，准备接收刷新消息 c2s
{
    static const Type kType = kEnterEscortPlace;
};
typedef struct EnterEscortPlace EnterEscortPlace;

struct EnterEscortPlaceReturn // 进入护送区域 s2c
{
    static const Type kType = kEnterEscortPlaceResult;
    Result result;          // 
};
typedef struct EnterEscortPlaceReturn EnterEscortPlaceReturn;

//////////////////////////////////////////////////////////////////////////

struct LeaveEscortPlace // 退出护送区域，停止接收刷新消息 c2s
{
    static const Type kType = kLeaveEscortPlace;
};
typedef struct LeaveEscortPlace LeaveEscortPlace;

struct LeaveEscortPlaceReturn // 退出护送区域 s2c
{
    static const Type kType = kLeaveEscortPlaceResult;
    Result result;          // 
};
typedef struct LeaveEscortPlaceReturn LeaveEscortPlaceReturn;

//////////////////////////////////////////////////////////////////////////

struct ClientEscortInfo
{
    UserID id;      // 玩家ID
    uint16_t time;  // 已经经过的时间
    uint16_t type;  // 交通工具类型
};
typedef struct ClientEscortInfo ClientEscortInfo;

struct GetEscortInfo // 获取护送区域信息 c2s
{
    static const Type kType = kGetEscortInfo;
};
typedef struct GetEscortInfo GetEscortInfo;

struct GetEscortInfoReturn // 获取护送区域信息 s2c
{
    static const Type kType = kGetEscortInfoResult;
    Result result;          // 
    uint32_t count;          // 实际个数
    ClientEscortInfo list[512];
};
typedef struct GetEscortInfoReturn GetEscortInfoReturn;

//////////////////////////////////////////////////////////////////////////

struct SetAutoAccept // 设置自动接受 c2s  
{
    static const Type kType = kSetAutoAccept;
    uint8_t type;           // 交通工具，发送0代表取消自动接受
};
typedef struct SetAutoAccept SetAutoAccept;

struct SetAutoAcceptReturn // 设置自动接受 s2c
{
    static const Type kType = kSetAutoAcceptResult;
    Result result;          // 
};
typedef struct SetAutoAcceptReturn SetAutoAcceptReturn;

//////////////////////////////////////////////////////////////////////////

struct RefreshTransport // 刷新交通工具 c2s
{
    static const Type kType = kRefreshTransport;
};
typedef struct RefreshTransport RefreshTransport;

struct RefreshTransportReturn // 刷新交通工具 s2c
{
    static const Type kType = kRefreshTransportResult;
    Result result;          // 
    uint8_t type;           // 获取的交通工具
};
typedef struct RefreshTransportReturn RefreshTransportReturn;

//////////////////////////////////////////////////////////////////////////

struct StartEscort // 开始护送 c2s
{
    static const Type kType = kStartEscort;
};
typedef struct StartEscort StartEscort;

struct StartEscortReturn // 开始护送 s2c
{
    static const Type kType = kStartEscortResult;
    Result result;          // 
};
typedef struct StartEscortReturn StartEscortReturn;

//////////////////////////////////////////////////////////////////////////

struct EscortRank
{
    UserID id;            // 玩家ID
    Nickname nickname;  // 玩家名称
    uint32_t rank;      // 玩家护卫排名
    uint8_t level;        // 等级
    uint8_t total;        // 护卫次数
    uint8_t count;        // 剩余护卫次数
    uint8_t accept;        // 自动应答状态
    uint32_t score;        // 总积分
};
typedef struct EscortRank EscortRank;

struct GetEscortRank // 护卫排行榜 c2s
{
    static const Type kType = kGetEscortRank;
    uint16_t page;           // 第几页
};
typedef struct GetEscortRank GetEscortRank;

struct GetEscortRankReturn // 护卫排行榜 s2c
{
    static const Type kType = kGetEscortRankResult;
    Result result;          // 
    uint16_t page_count;    // 总页数
    uint16_t count;         // 数组实际个数
    EscortRank list[10];
};
typedef struct GetEscortRankReturn GetEscortRankReturn;

//////////////////////////////////////////////////////////////////////////

struct EscortInfoDetail
{
    Nickname nickname;    // 玩家名称
    uint8_t level;        // 等级
    uint8_t type;         // 工具
    uint8_t count;        // 拦截次数；3代表已经拦截过此玩家，不能再次打劫；4代表已经你是此玩家的护卫者，不能打劫，返回内容为您护卫完成的收获；
    uint8_t guard_level;        // 护卫者等级，如果为0代表没有护卫者
    Nickname guard_nickname;    // 护卫者名称
    uint32_t silver;            // 获取银币
    uint32_t prestige;          // 获取威望
};
typedef struct EscortInfoDetail EscortInfoDetail;

struct GetEscortInfoDetail // 护送详细信息 c2s
{
    static const Type kType = kGetEscortInfoDetail;
    UserID uid;           // 玩家ID
};
typedef struct GetEscortInfoDetail GetEscortInfoDetail;

struct GetEscortInfoDetailReturn // 护送详细信息 s2c
{
    static const Type kType = kGetEscortInfoDetailResult;
    Result result;          // 
    EscortInfoDetail info;
};
typedef struct GetEscortInfoDetailReturn GetEscortInfoDetailReturn;

//////////////////////////////////////////////////////////////////////////

struct RobEscort // 打劫 c2s
{
    static const Type kType = kRobEscort;
    UserID player;           // 要打劫的玩家
};
typedef struct RobEscort RobEscort;

struct RobEscortReturn // 打劫 s2c
{
    static const Type kType = kRobEscortResult;
    Result result;          // 
    uint32_t rob_time;        // 这个时间以后才可以再次打劫
    uint32_t victory;         // 1代表胜利，0代表挑战失败
    Nickname nickname;        // 被打劫者名称
    uint32_t silver;          // 获取银币
    uint16_t prestige;        // 获取威望
    uint16_t fight_record_bytes;
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct RobEscortReturn RobEscortReturn;

//////////////////////////////////////////////////////////////////////////

struct InviteEscortRequest // 邀请好友护送 c2s
{
    static const Type kType = kInviteEscortRequest;
    UserID player;    // 护卫者，通过kGetUserIDByName获取
};
typedef struct InviteEscortRequest InviteEscortRequest;

struct InviteEscortRequestResultReturn // 邀请好友护送 s2c
{
    static const Type kType = kInviteEscortRequestResult;
    Result result;          // 
    uint8_t agree;          // 0自动应答成功；1不能邀请自己；2玩家不正确；3对方护卫次数用光；4自动应答拒绝（交通工具等级不足）；5没有自动应答并且不在线；6等待在线玩家回复
};
typedef struct InviteEscortRequestResultReturn InviteEscortRequestResultReturn;

//////////////////////////////////////////////////////////////////////////

struct InviteEscortRespond // 回应好友邀请 c2s
{
    static const Type kType = kInviteEscortRespond;
    UserID player;
    uint8_t agree;      // 0拒绝，1同意
};
typedef struct InviteEscortRespond InviteEscortRespond;

struct InviteEscortRespondResultReturn // 回应好友邀请 s2c
{
    static const Type kType = kInviteEscortRespondResult;
    Result result;          // 
    uint8_t status;         // 0回应护卫成功；1申请无效；2回应已经超时；3申请者已经出发
};
typedef struct InviteEscortRespondResultReturn InviteEscortRespondResultReturn;

//////////////////////////////////////////////////////////////////////////

struct ClearEscortCD // 清除打劫CD c2s
{
    static const Type kType = kClearEscortCD;
};
typedef struct ClearEscortCD ClearEscortCD;

struct ClearEscortCDResult // 清除打劫CD s2c
{
    static const Type kType = kClearEscortCDResult;
    Result result;          // 
};
typedef struct ClearEscortCDResult ClearEscortCDResult;

//////////////////////////////////////////////////////////////////////////
// 下面的是推送消息

struct PushEscortNews // 推送新闻 s2c
{
    static const Type kType = kPushEscortNews;
    EscortNews news;        //最近一条新闻
};
typedef struct PushEscortNews PushEscortNews;

struct PushEscortInfo // 推送护送信息 s2c
{
    static const Type kType = kPushEscortInfo;
    ClientEscortInfo info;        // 最近一条护送
};
typedef struct PushEscortInfo PushEscortInfo;

struct PushEscortReward // 获取奖励 s2c
{
    static const Type kType = kPushEscortReward;
    uint8_t isOnline;         // 0代表离线消息，1代表在线消息
    uint8_t isHelper;         // 0代表自己获得的奖励，1代表护卫别人获取的奖励
    uint8_t count;            // 被打劫次数
    uint8_t type;            // 使用的交通工具
    uint32_t silver;          // 获取银币     如果是护卫奖励，这里代表获得的积分
    uint32_t prestige;        // 获取威望
};
typedef struct PushEscortReward PushEscortReward;

struct PushEscortBeRobed // 被打劫了 s2c
{
    static const Type kType = kPushEscortBeRobed;
    uint16_t isHelper;           // 0代表自己的被抢劫了，1代表护卫别人的被打劫了
    uint8_t type;              // 交通工具
    uint8_t victory;           // 1打赢了，0代表打输了
    Nickname nickname;         // 打劫者名称
    uint32_t silver;           // 损失银币【虚假损失，只会从收取中扣除】
    uint16_t prestige;         // 损失威望
    uint16_t fight_record_bytes;      // 如果为0，说明是【离线消息，没有保存战报】
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct PushEscortBeRobed PushEscortBeRobed;

struct PushEscortInviteRequest // 别人邀请你护卫 s2c
{
    static const Type kType = kPushEscortInviteRequest;
    UserID id;            // 玩家ID
    Nickname nickname;    // 玩家名称
    uint8_t type;         // 交通工具类型
};
typedef struct PushEscortInviteRequest PushEscortInviteRequest;

struct PushEscortInviteRespond // 别人对你的邀请回应 s2c
{
    static const Type kType = kPushEscortInviteRespond;
    Nickname nickname;    // 玩家名称
    uint8_t agree;        // 0拒绝，1同意
};
typedef struct PushEscortInviteRespond PushEscortInviteRespond;

struct PushEscortInviteResult // 你护卫的玩家已经出发，护卫次数发生改变 s2c
{
    static const Type kType = kPushEscortInviteResult;
    uint8_t count;        // 剩余护卫次数
};
typedef struct PushEscortInviteResult PushEscortInviteResult;

//////////////////////////////////////////////////////////////////////////
// 下面的是领地消息

struct GetTerritoryStatus // 获取领地基本信息 c2s
{
    static const Type kType = kGetTerritoryStatus;
};
typedef struct GetTerritoryStatus GetTerritoryStatus;

struct GetTerritoryStatusResult // 获取领地基本信息 s2c
{
    static const Type kType = kGetTerritoryStatusResult;
    Result result;          // 
    uint8_t can_move;       // 0今日不可迁移 1今日可迁移
    uint8_t can_grab;       // 0今日不可抢占资源点 1今日可抢占资源点
    uint8_t rob_count;      // 您的领地上的强盗数量
    uint8_t assist;         // 您今日剩余剿匪次数
    uint32_t move_cd;       // 迁移城池失败CD时间
    uint32_t grab_cd;       // 资源点抢占失败CD时间
    uint32_t kill_cd;       // 剿匪CD时间
    uint32_t reap_cd;       // 收获资源CD时间
};
typedef struct GetTerritoryStatusResult GetTerritoryStatusResult;


struct TerritoryCity // 城池
{
    uint8_t index;    // 本页位置
    uint8_t type;     // 城池类型｛皮肤｝
    uint8_t busy;     // 是否有主 0闲置 1有人
    uint8_t bandits;  // 强盗个数
    UserID id;        // 玩家ID   (可用于取玩家更详细信息)
    Nickname name;    // 玩家名称
};
typedef struct TerritoryCity TerritoryCity;

struct TerritoryResource // 资源点
{
    uint8_t index;    // 本页位置
    uint8_t type;     // 资源点类型｛SID｝
    uint8_t busy;     // 是否有主 0闲置 1有人
    uint8_t unused;   // 对齐保留
    UserID id;        // 玩家ID   (可用于取玩家更详细信息)
    Nickname name;    // 玩家名称
    uint32_t time;    // 占领到期时间
    uint32_t guard_time;    // 保护到期时间
};
typedef struct TerritoryResource TerritoryResource;

struct ViewTerritory // 查看领地 c2s
{
    static const Type kType = kViewTerritory;
    uint32_t page;   // 领地页数 从第一页开始
    uint8_t type;    // 领地类型 1黄金领地 2白银领地 3黑铁领地 4青铜领地
};
typedef struct ViewTerritory ViewTerritory;

struct ViewTerritoryResult // 查看领地 s2c
{
    static const Type kType = kViewTerritoryResult;
    Result result;          // 
    uint32_t page;          // 领地总页数
    uint8_t style;          // 本页分布类型
    uint8_t unused;         // 对齐保留
    uint8_t city_count;     // 本页城池数量
    uint8_t resource_count; // 本页资源点数量
    TerritoryCity city_list[10];            //实际个数看city_count
    TerritoryResource resource_list[10];    //实际个数看resource_count
};
typedef struct ViewTerritoryResult ViewTerritoryResult;


struct TerritoryGPS // 定位玩家领地 c2s
{
    static const Type kType = kTerritoryGPS;
};
typedef struct TerritoryGPS TerritoryGPS;

struct TerritoryGPSResult // 定位玩家领地 s2c
{
    static const Type kType = kTerritoryGPSResult;
    Result result;          // 
    uint32_t page;          // 领地页数
    uint8_t type;           // 领地类型 1黄金领地 2白银领地 3黑铁领地 4青铜领地
};
typedef struct TerritoryGPSResult TerritoryGPSResult;


struct MoveTerritory // 迁移玩家领地 c2s
{
    static const Type kType = kMoveTerritory;
    uint32_t page;          // 领地页数
    uint8_t type;           // 领地类型 1黄金领地 2白银领地 3黑铁领地 4青铜领地
    uint8_t index;          // 在页面中的具体位置
};
typedef struct MoveTerritory MoveTerritory;

struct MoveTerritoryResult // 迁移玩家领地 s2c
{
    static const Type kType = kMoveTerritoryResult;
    Result result;          // 
    uint32_t move_cd;        // 下次可挑战时间
    uint8_t can_move;        // 0今日不可迁移 1今日可迁移
    uint8_t succeed;         // 战斗结果 0失败 1胜利
    uint16_t fight_record_bytes;      // 战报长度
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct MoveTerritoryResult MoveTerritoryResult;

/*
struct ReapResource // 收取资源 c2s
{
    static const Type kType = kReapResource;
};
typedef struct ReapResource ReapResource;

struct ReapResourceResult // 收取资源 s2c
{
    static const Type kType = kReapResourceResult;
    Result result;          //
    uint32_t amount;         // 资源量
    uint8_t type;           // 资源类型｛见资源点配置｝
};
typedef struct ReapResourceResult ReapResourceResult;
*/

struct GrabResource // 争夺资源 c2s
{
    static const Type kType = kGrabResource;
    uint32_t page;          // 领地页数
    uint8_t type;           // 领地类型 1黄金领地 2白银领地 3黑铁领地 4青铜领地
    uint8_t index;          // 在页面中的具体位置
};
typedef struct GrabResource GrabResource;

struct GrabResourceResult // 争夺资源 s2c
{
    static const Type kType = kGrabResourceResult;
    Result result;          // 
    uint32_t grab_cd;        // 下次可挑战时间
    uint8_t can_grab;        // 0今日不可抢占资源点 1今日可抢占资源点
    uint8_t succeed;         // 战斗结果 0失败 1胜利
    uint16_t fight_record_bytes;      // 战报长度
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct GrabResourceResult GrabResourceResult;


struct DiscardResource // 放弃资源 c2s
{
    static const Type kType = kDiscardResource;
};
typedef struct DiscardResource DiscardResource;

struct DiscardResourceResult // 放弃资源 s2c
{
    static const Type kType = kDiscardResourceResult;
    Result result;          // 
};
typedef struct DiscardResourceResult DiscardResourceResult;


struct KillBandits // 剿灭强盗 c2s
{
    static const Type kType = kKillBandits;
    uint32_t page;          // 领地页数
    uint8_t type;           // 领地类型 1黄金领地 2白银领地 3黑铁领地 4青铜领地
    uint8_t index;          // 在页面中的具体位置
};
typedef struct KillBandits KillBandits;

struct KillBanditsResult // 剿灭强盗 s2c
{
    static const Type kType = kKillBanditsResult;
    Result result;           // 
    uint32_t kill_cd;        // 下次可挑战时间
    uint8_t assist;          // 剩余帮助次数
    uint8_t succeed;         // 战斗结果 0失败 1胜利
    uint8_t unused;          // 对齐保留
    uint8_t type;            // 奖励类型｛见领地规则配置｝
    uint32_t amount;         // 奖励数量
    uint16_t fight_record_bytes;      // 战报长度
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct KillBanditsResult KillBanditsResult;


struct StopViewTerritory // 停止查看领地 c2s
{
    static const Type kType = kStopViewTerritory;
};
typedef struct StopViewTerritory StopViewTerritory;

struct StopViewTerritoryResult // 停止查看领地 s2c
{
    static const Type kType = kStopViewTerritoryResult;
    Result result;          // 
};
typedef struct StopViewTerritoryResult StopViewTerritoryResult;


struct ClearTerritoryCD // 花费金币清除CD c2s
{
    static const Type kType = kClearTerritoryCD;
    uint8_t type;       // 1 迁移CD 2 资源点战斗CD 3 剿匪CD
};
typedef struct ClearTerritoryCD ClearTerritoryCD;

struct ClearTerritoryCDResult // 花费金币清除CD s2c
{
    static const Type kType = kClearTerritoryCDResult;
    Result result;          // 
};
typedef struct ClearTerritoryCDResult ClearTerritoryCDResult;


struct SetTerritorySkin // 改变城池外观 c2s
{
    static const Type kType = kSetTerritorySkin;
    uint8_t type;       // 城池外观 0-……
};
typedef struct SetTerritorySkin SetTerritorySkin;

struct SetTerritorySkinResult // 改变城池外观 s2c
{
    static const Type kType = kSetTerritorySkinResult;
    Result result;          // 
};
typedef struct SetTerritorySkinResult SetTerritorySkinResult;

//////////////////////////////////////////////////////////////////////////
// 下面的是领地推送消息

struct TerritoryChallenge // 领地挑战 s2c
{
    static const Type kType = kPushTerritoryChallenge;
    Nickname name;           // 玩家名称
    uint8_t type;            // 战斗方式 0城池 1资源点
    uint8_t succeed;         // 战斗结果 0对方失败 1对方胜利
};
typedef struct TerritoryChallenge TerritoryChallenge;

struct TerritoryChange // 领地改变 s2c ｛发生此消息时重新获取当前查看页面信息｝
{
    static const Type kType = kPushTerritoryChange;
};
typedef struct TerritoryChange TerritoryChange;

struct TerritoryTimeout // 领地超时 s2c ｛您长时间不上线，与XX时间领地被系统重新分配｝
{
    static const Type kType = kPushTerritoryTimeout;
    uint32_t time;          // 移除世界
};
typedef struct TerritoryTimeout TerritoryTimeout;

struct TerritoryPage // 领地页数变动 s2c
{
    static const Type kType = kPushTerritoryPage;
    uint32_t page;          // 当前页数
    uint32_t total;         // 领地总页数
};
typedef struct TerritoryPage TerritoryPage;
