#pragma once

#include "define.h"

enum PlaygroudType
{
//客户端发到服务端的消息
	//kPlayGroundBegin = 7000
	kGetFishingInfo = kPlayGroundBegin + 1,
	kGetFishKindRecord,
	kThrowFishingRod,
	kPullFishingRod,
	kThrowTorpedo,

	kRaceDragonGuess = kPlayGroundBegin+10,	//参与竞猜
	kRaceDragonSignup,				//赛龙报名
	kGetRaceDragonCurStep,			//当前阶段
	kGetRaceDragonTime,				//赛龙时间段<从某时间到某时间>
	kGetRaceDragonMyGuess,			//我的竞猜
	kGetRaceDragonGuessInfo,		//赛龙竞猜信息<总额>
	kGetRaceDragonMyLimit,			//我的竞猜总额限制
	kGetRaceDragonToptenInfo,		//获取前十基本信息
	kGetRaceDragonSeasonRank,		//赛季排位

	kRearDragonChangeName = kPlayGroundBegin+30,		//改名
	kRearDragonRelease,				//放生
	kRearDragonMate,				//交配
	kGetDragonList,					//获得龙的列表
	kRearDragonFeed,				//喂龙
	kRearDragonResetMateTime,		//重置交配时间
	//kGetRearDragonMateKind,			//获得交配可能得到的种类

	kGetTurntableInfo = kPlayGroundBegin+40,//获取幸运转轮信息
	kTurnTurntable ,			//转动
	kGetRewardTurntable,		//领奖

	kGetPlaygroundInfo = kPlayGroundBegin+50,		//获取游乐场信息

	kGetPlaygroundPropsInfo = kPlayGroundBegin+70,		//获取道具信息
	kPlaygroundPropBuy,								//购买
	kPlaygroundPropSell,							//出售
	kNotifyPlaygourndPropReset,						//重置


//	服务端发回去的消息
	//kPlayGroundReturnBegin = 21000
	kGetFishingInfoResult = kPlayGroundReturnBegin +1,
	kGetFishKindRecordResult,
	kThrowFishingRodResult,
	kPullFishingRodResult,
	kThrowTorpedoResult,
	kFishingInfoReset,

	kRaceDragonGuessResult = kPlayGroundReturnBegin + 10,
	kRaceDragonSignupResult,
	kGetRaceDragonCurStepResult,
	kGetRaceDragonTimeResult,
	kGetRaceDragonMyGuessResult,
	kGetRaceDragonGuessInfoResult,
	kGetRaceDragonMyLimitResult,
	kNotifyRaceDragonCurStep,				//通知,赛龙进入某阶段
	kGetRaceDragonToptenInfoResult,
	kGetRaceDragonSeasonRankResult,

	kRearDragonChangeNameResult = kPlayGroundReturnBegin + 30,		//
	kRearDragonReleaseResult,
	kRearDragonMateResult,
	kGetDragonListResult,
	kRearDragonFeedResult,
	kRearDragonResetMateTimeResult,

	kGetNewDragonNotify,				//获得新龙通知


	kGetTurntableInfoResult = kPlayGroundReturnBegin+40,
	kTurnTurntableResult,
	kGetRewardTurntableResult,
	kResetTurntableInfo,				//转轮重置消息,每天0点重置次数

	kGetPlaygroundInfoResult = kPlayGroundReturnBegin+50,

	kGetPlaygroundPropsInfoResult = kPlayGroundReturnBegin+70,
	kPlaygroundPropBuyResult ,
	kPlaygroundPropSellResult,
};

enum FishResultType
{
	FISH_SUCCEEDED = 0,
	FISH_INVALID_VALUE = kPlayGroundReturnBegin,	//无效的值
	FISH_INVALID_OPERATION,	//非法操作
	FISH_DISABLE,			//未激活
	FISH_NOT_IN_TIME,		//未及时操作
	FISH_GOLD_NOT_ENOUGH,	//金币不够
	FISH_NO_TIMES,			//不能再钓了
	FISH_LOW_VIP_LEVEL,		//vip等级不够
	FISH_BAG_LEACK_SPACE,	//背包格子不够
};

enum RaceDragonResultType
{
	RACE_DRAGON_SUCCEEDED = 0,
	RACE_DRAGON_INVALID = kPlayGroundReturnBegin+10,		//非法的数据
	RACE_DRAGON_NOT_TIME,		//此时不能
	RACE_DRAGON_LIMIT_MONEY,	//投注金额达到上限了
	RACE_DRAGON_ALREADY_SELECT,	//已经进行过该投注了
	RACE_DRAGON_SIGNUP,			//已经报过名了
	RACE_DRAGON_NOT_ENOUGH,		//钱不够哦
};

enum RearDragonResultType
{
	REAR_DRAGON_SUCCEEDED = 0,
	REAR_DRAGON_INVALID = kPlayGroundReturnBegin+30,		//
	REAR_DRAGON_NOT_ENOUGH,		//钱不够
	REAR_DRAGON_RACING,			//报名参与比赛中.
	REAR_DRAGON_FEED_FAIL,		//喂食的食物失败
	REAR_DRAGON_NOT_TIME,		//繁殖CD时间里
	REAR_DRAGON_ROOM_LIMIT,		//龙室限制
	REAR_DRAGON_MATE_FAILED,	//交配了没生出来啦
	REAR_DRAGON_LACK_RSC,		//资源不足<比如食物,催化剂等>
	REAR_DRAGON_PROPERTY_LIMIT,	//属性限制,不能再问喂食了
};

enum TurntableTurnResultType
{
	TURNTABLE_SUCCEEDED = 0,
	TURNTABLE_INVALID = kPlayGroundReturnBegin+40,
	TURNTABLE_INVALIDOPERATION,		//非法操作
	TURNTABLE_NO_TIMES,				//没有剩余次数了
	TURNTABLE_GOLD_NOT_ENOUGH,		//金币不足
	TURNTABLE_SHOULD_GET_REWARD,	//现在应该领取奖励
	TURNTABLE_DISABLE,				//未激活
};

enum PlaygroundPropResultType
{
	PP_SUCCEEDED = 0,
	PP_INVALID = kPlayGroundReturnBegin+70,
	PP_LackResource,			//资源不足
	PP_AMOUNT_LIMIT,			//数量限制
	PP_LOW_VIP_LEVEL,			//vip等级不够
	PP_LIMIT_BUY_COUNT,			//购买次数限制
};




struct GetFishingInfo
{
	static const Type kType = kGetFishingInfo;
};
typedef struct GetFishingInfo GetFishingInfo;

struct GetFishingInfoResult
{
	static const Type kType = kGetFishingInfoResult;
	Result result;
	uint16_t fish_times;		//今日剩余可钓鱼次数
	uint16_t gold_times;		//今日使用黄金鱼竿次数
	uint16_t torpedo_times;		//..鱼雷..
	uint16_t fisheries;			//已解锁渔场,每一位代表一个渔场
};
typedef struct GetFishingInfoResult GetFishingInfoResult;

struct GetFishKindRecord
{
	static const Type kType = kGetFishKindRecord;
	uint8_t fishery;		//渔场
};
typedef struct GetFishKindRecord GetFishKindRecord;

struct FishKindRecord
{
	uint16_t  kind;		//fish kind(sid)
	uint16_t  weight;	//=0是解锁了但没有钓起过<只有需要解锁的,才能=0>
};
typedef struct FishKindRecord FishKindRecord;

struct GetFishKindRecordResult
{
	static const Type kType = kGetFishKindRecordResult;
	Result result;
	int32_t amount;		//records数量
	FishKindRecord records[20];
};
typedef struct GetFishKindRecordResult GetFishKindRecordResult;



struct FishReward
{
	uint16_t type;		//1: 道具,    2: 鱼
	uint16_t kind;		//type是道具时为道具sid, 是鱼时为鱼的Kind
	uint32_t weight;	//是鱼才有效, 鱼的重量*100,你拿到时要除以100才是鱼的真实重量
	uint32_t amount;	//是鱼才有效, 标示获得的奖励,比如1000银币,10金币,300功绩
};
typedef struct FishReward FishReward;

enum RodType { kNormalFishingRod=0, kGoldFishingRod=1, kTorpedoBomb=2 };
struct ThrowFishingRod
{
	static const Type kType = kThrowFishingRod;
	uint8_t fishery;		//渔场, 1,2,3,4,...
	uint8_t rod;			//
};
typedef struct ThrowFishingRod ThrowFishingRod;

struct ThrowFishingRodResult
{
	static const Type kType = kThrowFishingRodResult;
	Result result;
	uint32_t time;
};
typedef struct ThrowFishingRodResult ThrowFishingRodResult;

struct PullFishingRod
{
	static const Type kType = kPullFishingRod;
};
typedef struct PullFishingRod PullFishingRod;

struct PullFishingRodResult
{
	static const Type kType = kPullFishingRodResult;
	Result result;
	FishReward reward;
};
typedef struct PullFishingRodResult PullFishingRodResult;

struct ThrowTorpedo
{
	static const Type kType = kThrowTorpedo;
	uint8_t fishery;
};
typedef struct ThrowTorpedo ThrowTorpedo;

struct ThrowTorpedoResult
{
	static const Type kType = kThrowTorpedoResult;
	Result result;
	int32_t amount;			//reward的数量
	FishReward rewards[5];
};
typedef struct ThrowTorpedoResult ThrowTorpedoResult;

struct FishingInfoReset
{
	static const Type kType = kFishingInfoReset;
};
typedef struct FishingInfoReset FishingInfoReset;


//赛龙

struct RaceDragonGuess
{
	static const Type kType = kRaceDragonGuess;
	int16_t	type;	//竞猜类型,赛道1-10, 单11,  双12
	int16_t money;	//单位为万
};
typedef struct RaceDragonGuess RaceDragonGuess;

struct RaceDragonGuessResult
{
	static const Type kType = kRaceDragonGuessResult;
	Result result;
};
typedef struct RaceDragonGuessResult RaceDragonGuessResult;

struct RaceDragonSignup
{
	static const Type kType = kRaceDragonSignup;
	int32_t	dragon_id;
};
typedef struct RaceDragonSignup RaceDragonSignup;

struct RaceDragonSignupResult
{
	static const Type kType = kRaceDragonSignupResult;
	Result result;
};
typedef struct RaceDragonSignupResult RaceDragonSignupResult;

struct GetRaceDragonCurStep
{
	static const Type kType = kGetRaceDragonCurStep;
};
typedef struct GetRaceDragonCurStep GetRaceDragonCurStep;

struct GetRaceDragonCurStepResult
{
	static const Type kType = kGetRaceDragonCurStepResult;
	Result	result;
	int16_t season;//赛季
	int16_t step;// 1 等待下一个赛季;  2 报名;  3 海选竞猜;		4 结算
	int32_t t_begin;
	int32_t t_end;
};
typedef struct GetRaceDragonCurStepResult GetRaceDragonCurStepResult;

struct NotifyRaceDragonCurStep
{
	static const Type kType = kNotifyRaceDragonCurStep;
	int16_t season;
	int16_t step;
	int32_t t_begin;
	int32_t t_end;
};
typedef struct NotifyRaceDragonCurStep NotifyRaceDragonCurStep;

struct GetRaceDragonTime
{
	static const Type kType = kGetRaceDragonTime;
	int8_t step;
};
typedef struct GetRaceDragonTime GetRaceDragonTime;

struct GetRaceDragonTimeResult
{
	static const Type kType = kGetRaceDragonTimeResult;
	Result result;
	int32_t t_begin;
	int32_t t_end;
};
typedef struct GetRaceDragonTimeResult GetRaceDragonTimeResult;

struct GetRaceDragonMyGuess
{
	static const Type kType = kGetRaceDragonMyGuess;
};
typedef struct GetRaceDragonMyGuess GetRaceDragonMyGuess;

struct GetRaceDragonMyGuessResult
{
	static const Type kType = kGetRaceDragonMyGuessResult;
	Result	result;
	//竞猜, 1-10 赛道,,  11 单,, 12 双
	int16_t money[12];		//竞猜金额, 单位为万
};
typedef struct GetRaceDragonMyGuessResult GetRaceDragonMyGuessResult;

struct GetRaceDragonGuessInfo
{
	static const Type kType = kGetRaceDragonGuessInfo;
};
typedef struct GetRaceDragonGuessInfo GetRaceDragonGuessInfo;

struct GetRaceDragonGuessInfoResult
{
	static const Type kType = kGetRaceDragonGuessInfoResult;
	Result	result;
	int16_t	peoples[12];	//竞猜人数
	int16_t odds[12];		//赔率
	int32_t money[12];		//竞猜总额
};
typedef struct GetRaceDragonGuessInfoResult	GetRaceDragonGuessInfoResult;

struct GetRaceDragonToptenInfo
{
	static const Type kType = kGetRaceDragonToptenInfo;
};
typedef struct GetRaceDragonToptenInfo GetRaceDragonToptenInfo;

struct GetRaceDragonToptenInfoResult
{
	static const Type kType = kGetRaceDragonToptenInfoResult;
	Result result;
	int32_t len;
	struct RaceDragonToptenInfo
	{
		int32_t his_rank;
		int16_t	strength;
		int16_t agility;
		int16_t intellect;
		int16_t kind;		//
		int8_t  raceway;
		int8_t  d_state;	//1 优,,,2 良,,,, 3普通
		int8_t  ch_name;	//是否改过名
		int8_t unuse1;
		DragonName d_name;
		Nickname p_name;
	}dragon[10];
};
typedef struct RaceDragonToptenInfo RaceDragonToptenInfo;
typedef struct GetRaceDragonToptenInfoResult GetRaceDragonToptenInfoResult;

struct GetRaceDragonMyLimit
{
	static const Type kType = kGetRaceDragonMyLimit;
};
typedef struct GetRaceDragonMyLimit GetRaceDragonMyLimit;

struct GetRaceDragonMyLimitResult
{
	static const Type kType = kGetRaceDragonMyLimitResult;
	Result result;
	int16_t limit;	//限制,万
};
typedef struct GetRaceDragonMyLimitResult GetRaceDragonMyLimitResult;

struct GetRaceDragonSeasonRank
{
	static const Type kType = kGetRaceDragonSeasonRank;
	int16_t season;	//指定获取赛季
};
typedef struct GetRaceDragonSeasonRank GetRaceDragonSeasonRank;

struct RaceDragonRankInfo
{
	uint32_t live1;		//--2:23-1:0 : 跑路<2位表示一个状态>< 0 正常,, 1 特殊,, 2,,虚弱  3,,冲刺 >
	uint32_t live2;		//--2:30-2:24: section<7位>,,
	int32_t  speed;		//100%速度
	int8_t rank;
	int8_t raceway;
	uint8_t kind;
	int8_t  ch_name;	//是否改过名
	DragonName d_name;
	Nickname   p_name;
};
typedef struct RaceDragonRankInfo RaceDragonRankInfo;

struct GetRaceDragonSeasonRankResult
{
	static const Type kType = kGetRaceDragonSeasonRankResult;
	Result result;
	int32_t len;
	RaceDragonRankInfo info[10];
};
typedef struct GetRaceDragonSeasonRankResult GetRaceDragonSeasonRankResult;





//-----------育龙
struct RearDragonChangeName
{
	static const Type kType = kRearDragonChangeName;
	int32_t		 dragon_id;
	DragonName	 d_name;
};
typedef struct RearDragonChangeName RearDragonChangeName;

struct RearDragonChangeNameResult
{
	static const Type kType = kRearDragonChangeNameResult;
	Result result;
};
typedef struct RearDragonChangeNameResult RearDragonChangeNameResult;

struct RearDragonRelease
{
	static const Type kType = kRearDragonRelease;
	int32_t dragon_id;
};
typedef struct RearDragonRelease RearDragonRelease;

struct RearDragonReleaseResult
{
	static const Type kType = kRearDragonReleaseResult;
	Result result;
	int32_t amount;		//兑换券数量
};
typedef struct RearDragonReleaseResult RearDragonReleaseResult;



struct GetDragonList
{
	static const Type kType = kGetDragonList;
};
typedef struct GetDragonList GetDragonList;

struct DragonInfo
{
	int32_t dragon_id;
	int32_t his_rank;
	int32_t m_time;		//交配时间
	int16_t strength;
	int16_t agility;
	int16_t intellect;
	int16_t max_str;
	int16_t max_agi;
	int16_t max_int;
	int16_t kind;
	int16_t unuse1;
	int8_t  sex;
	int8_t  signup;
	int8_t  ch_name;
	int8_t  unuse2;
	DragonName d_name;
};
typedef struct DragonInfo DragonInfo;

struct GetDragonListResult
{
	static const Type kType = kGetDragonListResult;
	Result result;
	int8_t len;
	int8_t rooms;
	int16_t unuse;
	DragonInfo dragon[9];
};
typedef struct GetDragonListResult GetDragonListResult;

struct RearDragonFeed
{
	static const Type kType = kRearDragonFeed;
	int32_t dragon_id;
	int32_t food_kind;
};
typedef struct RearDragonFeed RearDragonFeed;

struct RearDragonFeedResult
{
	static const Type kType = kRearDragonFeedResult;
	Result result;
	int16_t strength;
	int16_t agility;
	int16_t intellect;
	int16_t unuse;
};
typedef struct RearDragonFeedResult RearDragonFeedResult;

struct RearDragonMate
{
	static const Type kType = kRearDragonMate;
	int32_t dragon_fid;
	int32_t dragon_mid;
	int32_t agent_kind;		//催化剂
};
typedef struct RearDragonMate RearDragonMate;

struct RearDragonMateResult
{
	static const Type kType = kRearDragonMateResult;
	Result result;
	DragonInfo dragon;
};
typedef struct RearDragonMateResult RearDragonMateResult;

struct RearDragonResetMateTime
{
	static const Type kType = kRearDragonResetMateTime;
	int32_t dragon_id;
};
typedef struct RearDragonResetMateTime RearDragonResetMateTime;

struct RearDragonResetMateTimeResult
{
	static const Type kType = kRearDragonResetMateTimeResult;
	Result result;
};
typedef struct RearDragonResetMateTimeResult RearDragonResetMateTimeResult;

struct GetNewDragonNotify
{
	static const Type kType = kGetNewDragonNotify;
	DragonInfo dragon;
};
typedef struct GetNewDragonNotify GetNewDragonNotify;





//------------幸运转轮
struct GetTurntableInfo
{
	static const Type kType = kGetTurntableInfo;
};
typedef struct GetTurntableInfo GetTurntableInfo;

struct GetTurntableInfoResult
{
	static const Type kType = kGetTurntableInfoResult;
	Result result;
	int16_t results;//转动的情景<每一位代表一个位置, 1:有图案, 0:为图案>
	int16_t re_times;//今日重转次数
	int8_t  cur_point;//当前指向位置
	int8_t  times;//剩余转轮次数
	int8_t  should_return;//是否应该重转
};
typedef struct GetTurntableInfoResult GetTurntableInfoResult;

struct TurnTurntable
{
	static const Type kType = kTurnTurntable;
};
typedef struct TurnTurntable TurnTurntable;

struct TurnTurntableResult
{
	static const Type kType = kTurnTurntableResult;
	Result result;
	int16_t results;		//整个转盘的情景
	int8_t  cur_point;		//当前指向位置
};
typedef struct TurnTurntableResult TurnTurntableResult;

struct GetRewardTurntable
{
	static const Type kType = kGetRewardTurntable;
};
typedef struct GetRewardTurntable GetRewardTurntable;

struct GetRewardTurntableResult
{
	static const Type kType = kGetRewardTurntableResult;
	Result result;
	int32_t amount;	//奖励值
};
typedef struct GetRewardTurntableResult GetRewardTurntableResult;

struct ResetTurntableInfo
{
	static const Type kType = kResetTurntableInfo;
};
typedef struct ResetTurntableInfo ResetTurntableInfo;




//游乐场
struct GetPlaygroundInfo
{
	static const Type kType = kGetPlaygroundInfo;
};
typedef struct GetPlaygroundInfo GetPlaygroundInfo;

struct GetPlaygroundInfoResult
{
	static const Type kType = kGetPlaygroundInfoResult;
	int32_t tickets;
};
typedef struct GetPlaygroundInfoResult GetPlaygroundInfoResult;





//道具
struct GetPlaygroundPropsInfo
{
	static const Type kType = kGetPlaygroundPropsInfo;
};
typedef struct GetPlaygroundPropsInfo GetPlaygroundPropsInfo;

struct PlaygroundProp
{
	int16_t kind;
	int16_t amount;
	int16_t buy_count;
	int16_t unuse1;
};
typedef struct PlaygroundProp PlaygroundProp;

struct GetPlaygroundPropsInfoResult
{
	static const Type kType = kGetPlaygroundPropsInfoResult;
	Result result;
	int32_t amount;
	PlaygroundProp prop[256];
};
typedef struct GetPlaygroundPropsInfoResult GetPlaygroundPropsInfoResult;

struct PlaygroundPropBuy
{
	static const Type kType = kPlaygroundPropBuy;
	uint8_t prop_index;
};
typedef struct PlaygroundPropBuy PlaygroundPropBuy;

struct PlaygroundPropBuyResult
{
	static const Type kType = kPlaygroundPropBuyResult;
	Result result;
};
typedef struct PlaygroundPropBuyResult PlaygroundPropBuyResult;

struct NotifyPlaygourndPropReset
{
	static const Type kType = kNotifyPlaygourndPropReset;
};
typedef struct NotifyPlaygourndPropReset NotifyPlaygourndPropReset;