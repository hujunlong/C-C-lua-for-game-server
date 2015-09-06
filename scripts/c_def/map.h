#pragma once

#include "define.h"
#include "game_def.h"

enum MapType
{

	kEnterSection = kMapTypeBegin+1,
	kChallengeSubSection = kMapTypeBegin+2,
	kMopUpSection = kMapTypeBegin+3,
	kGetSectionScores = kMapTypeBegin+4,
	kEnterMapArea = kMapTypeBegin+5,
	kMove2RoadLocation = kMapTypeBegin+6,
	kOpenCurrentLocationBox = kMapTypeBegin+7,
	kGetArmyLocation = kMapTypeBegin+8,
	kGetSectionPassedReward = kMapTypeBegin+9,
	kGetTaskStatus = kMapTypeBegin+10,
	kGetMapRandomBoxes = kMapTypeBegin+11,
	kGetAvailableTasks = kMapTypeBegin+12,
	kReceiveTask = kMapTypeBegin+13,
	kTryCompleteSubTask = kMapTypeBegin+14,
	kSubmitTask = kMapTypeBegin+15,
	kAbandonTask = kMapTypeBegin+16,
	kGetSectionPassedBoxReward =  kMapTypeBegin+17,
	kConvey = kMapTypeBegin+18,
	kTryCompleteTrunkTask = kMapTypeBegin+19,
	kGetBossSectionStatus = kMapTypeBegin+20,
	kResetAvailableTasks = kMapTypeBegin+21,
	kChallengeBossSection = kMapTypeBegin+22,
	kGetStamina = kMapTypeBegin+23,
	kBackToMainCity = kMapTypeBegin+24,
	kClearStaminaCD = kMapTypeBegin+25,
	kReplenishStamina = kMapTypeBegin+26,
	kClearBackToTownCD = kMapTypeBegin+27,

	//////////////////////////////////////////////////////////////////////////
	kEnterSectionResult = kMapResultBegin+1,
	kChallengeSubSectionResult = kMapResultBegin+2,
	kMopUpSectionResult = kMapResultBegin+3,
	kGetSectionScoresResult = kMapResultBegin+4,
	kEnterMapAreaResult =  kMapResultBegin+5,
	kMove2RoadLocationResult = kMapResultBegin+6,
	kOpenCurrentLocationBoxResult = kMapResultBegin+7,
	kArmyLocation = kMapResultBegin+8,
	kSectionPassedReward = kMapResultBegin+9,
	kTaskStatus = kMapResultBegin+10,
	kMapRandomBoxes = kMapResultBegin+11,
	kAvailableTasks = kMapResultBegin+12,
	kReceiveTaskResult = kMapResultBegin+13,
	kTryCompleteSubTaskResult = kMapResultBegin+14,
	kSubmitTaskResult = kMapResultBegin+15,
	kAbandonTaskResult = kMapResultBegin+16,
	kSectionPassedBoxReward = kMapResultBegin+17,
	kConveyResult = kMapResultBegin+18,
	kTryCompleteTrunkTaskResult =  kMapResultBegin+19,
	kBossSectionStatus = kMapResultBegin+20,
	kResetAvailableTasksResult = kMapResultBegin+21,
	kChallengeBossSectionResult = kMapResultBegin+22,
	kGetStaminaResult = kMapResultBegin+23,
	kBackToMainCityResult = kMapResultBegin+24,
	kClearStaminaCDResult = kMapResultBegin+25,
	kReplenishStaminaResult = kMapResultBegin+26,
	kClearBackToTownCDResult = kMapResultBegin+27,


	kEncounteredMonsters = kMapResultBegin+101,
	kWeatherChanged = kMapResultBegin+102,
	kPushStaminaInfo = kMapResultBegin+103,
	kPushForceBackToMainCity = kMapResultBegin+104,
};

typedef int16_t SectionIndex; //关卡索引

struct EnterSection //进入一个关卡
{
	static const Type kType = kEnterSection;
	SectionIndex id;
};
typedef struct EnterSection EnterSection;

struct EnterSectionResult
{
	static const Type kType = kEnterSectionResult;
	Result result;
};
typedef struct EnterSectionResult EnterSectionResult;

struct ChallengeSubSection //打当前关卡的下一组怪，仅限主线任务
{
	static const Type kType = kChallengeSubSection;
};
typedef struct ChallengeSubSection ChallengeSubSection;

struct ChallengeSubSectionResult
{ 
	static const Type kType = kChallengeSubSectionResult;
	Result result;
	bool win; //是否胜利
	int8_t rewards_count;//掉落的个数
	int16_t fight_record_bytes; //战报的字节数
	Reward rewards[8]; //实际长度以前面的count为准
	uint8_t fight_record[kMaxFightRecordLength]; //实际长度以前面的bytes为准，记录为压缩后的内容
};
typedef struct ChallengeSubSectionResult ChallengeSubSectionResult;

struct GetSectionPassedReward //通关奖励
{ 
	static const Type kType = kGetSectionPassedReward;
};
typedef struct GetSectionPassedReward GetSectionPassedReward;

struct SectionPassedReward 
{
	static const Type kType = kSectionPassedReward;
	int32_t hero_exp; 
	int16_t feat;
	int8_t score;
	int8_t reserve; //保留备用
	int32_t lord_exp; //领主经验
};
typedef struct  SectionPassedReward SectionPassedReward;

struct GetSectionPassedBoxReward //获取通关宝箱奖励
{ 
	static const Type kType = kGetSectionPassedBoxReward;
};
typedef struct GetSectionPassedBoxReward GetSectionPassedBoxReward;

struct SectionPassedBoxReward
{ 
	static const Type kType = kSectionPassedBoxReward;
	uint32_t silver; //宝箱银币
	uint16_t gold; //宝箱金币,可能为0
	PropSid prop;  //宝箱中的道具(数量是固定的1)，0表示没有
	PropID prop_id; 
};
typedef struct SectionPassedBoxReward SectionPassedBoxReward;

struct MopUpSection // 扫荡
{ 
	static const Type kType = kMopUpSection;
	SectionIndex id;
	bool auto_sell_prop;
};
typedef struct MopUpSection MopUpSection;

#pragma pack(1)
struct MonsterGroupRewards
{
	int8_t count;
	Reward rewards[8]; //实际长度以前面的count为准
};
typedef struct MonsterGroupRewards MonsterGroupRewards;
#pragma pack()


struct MopUpSectionResult
{ 
	static const Type kType = kMopUpSectionResult;
	Result result;
	bool bag_full; //背包满了  这个值为true
	int8_t monsters_group_count;
	MonsterGroupRewards rewards[7]; // 实际长度以前面的count为准
	SectionPassedReward spr;
	SectionPassedBoxReward spbr;
};
typedef struct MopUpSectionResult MopUpSectionResult;

struct GetSectionScores //获取关卡评分
{ 
	static const Type kType = kGetSectionScores;
};
typedef struct GetSectionScores GetSectionScores;

struct GetSectionScoresResult
{ 
	static const Type kType = kGetSectionScoresResult;
	uint16_t max_index;
	int8_t scores[2000];
};
typedef struct GetSectionScoresResult GetSectionScoresResult;

struct EnterMapArea
{ 
	static const Type kType = kEnterMapArea;
	uint16_t id;
};
typedef struct EnterMapArea EnterMapArea;

struct EnterMapAreaResult
{ 
	static const Type kType = kEnterMapAreaResult;
	Result result;
};
typedef struct EnterMapAreaResult EnterMapAreaResult;

struct EncounteredMonsters //遭遇怪物的战斗过程，移动到某点或开箱子时发生，在Move2RoadLocationResult或OpenCurrentLocationBoxResult前发送
{ 
	static const Type kType = kEncounteredMonsters;
	int16_t fight_record_bytes;
	int16_t rewards_count;
	uint8_t record[kMaxFightRecordLength]; //实际长度以前面的为准， 记录为压缩后的内容
	Reward rewards[8];
};
typedef struct EncounteredMonsters EncounteredMonsters;

struct Move2RoadLocation //移动到旁边的一个路点
{ 
	static const Type kType = kMove2RoadLocation;
	uint8_t location;
};
typedef struct Move2RoadLocation Move2RoadLocation;

struct Move2RoadLocationResult
{ 
	static const Type kType = kMove2RoadLocationResult;
	Result result;
	int32_t encountered_monsters; // 非0表示遇到怪物发生战斗
	EncounteredMonsters em;
};
typedef struct Move2RoadLocationResult Move2RoadLocationResult;


struct OpenCurrentLocationBox //打开箱子
{ 
	static const Type kType = kOpenCurrentLocationBox;
};
typedef struct OpenCurrentLocationBox OpenCurrentLocationBox;

struct OpenCurrentLocationBoxResult
{ 
	static const Type kType = kOpenCurrentLocationBoxResult;
	Result result;
	int16_t rwds_count;
	int16_t encountered_monsters; // 非0表示遇到怪物发生战斗
	Reward rewards[8]; //长度以前面的rwds_count为准
	EncounteredMonsters em;
};
typedef struct OpenCurrentLocationBoxResult OpenCurrentLocationBoxResult;

struct GetArmyLocation //获取部队的位置
{ 
	static const Type kType = kGetArmyLocation;
};
typedef struct GetArmyLocation GetArmyLocation;

struct ArmyLocation
{ 
	static const Type kType = kArmyLocation;
	uint16_t area; //所在的地图区域 0表示在城内
	uint8_t location; //所在的路点
};
typedef struct ArmyLocation ArmyLocation;

struct GetTaskStatus //获取任务的情况
{ 
	static const Type kType = kGetTaskStatus;
};
typedef struct GetTaskStatus GetTaskStatus;

#pragma pack(1)
struct TaskStatus  
{ 
	static const Type kType = kTaskStatus;
	uint16_t current_trunk_task; //主线任务id
	int32_t current_branch_task; //支线任务id,      注意这里改成了4字节整数！！
	int8_t sub_trunk_task; //2级任务id，此项暂未使用
	int8_t trunk_task_progress;
	int8_t sub_branch_task; 
	int8_t brach_task_progress;
};
#pragma pack()
typedef struct TaskStatus TaskStatus;

struct GetMapRandomBoxes //获取当前地图的随机box
{ 
	static const Type kType = kGetMapRandomBoxes;
};
typedef struct GetMapRandomBoxes GetMapRandomBoxes;

struct MapRandomBoxes
{ 
	static const Type kType = kMapRandomBoxes;
	uint16_t refresh_cd; //下一次地图箱子刷新的冷却时间（秒）
	uint16_t count;
	struct 
	{
		uint8_t location; //箱子所在路点
		bool opened; //是否已经被开启过了
		uint16_t sid; //箱子的sid
	}boxes[16];
};
typedef struct MapRandomBoxes MapRandomBoxes;

struct BranchTask
{
	int16_t task; //任务id
};
typedef struct BranchTask BranchTask;

struct GetAvailableTasks //获取可接的任务
{ 
	static const Type kType = kGetAvailableTasks;
	int16_t area; //区域地图的id
};
typedef struct GetAvailableTasks GetAvailableTasks;

struct AvailableTasks
{ 
	static const Type kType = kAvailableTasks;
	uint32_t next_reset_time;
	int32_t count;
	int32_t tasks[4];
};
typedef struct AvailableTasks AvailableTasks;

typedef struct  //  刷新可接任务
{ 
	static const Type kType = kResetAvailableTasks;
	int32_t map;
}ResetAvailableTasks;

typedef struct 
{ 
	static const Type kType = kResetAvailableTasksResult;
	Result result;
}ResetAvailableTasksResult;



struct ReceiveTask //接任务
{ 
	static const Type kType = kReceiveTask;
	int32_t task;
};
typedef struct ReceiveTask ReceiveTask;

struct ReceiveTaskResult
{ 
	static const Type kType = kReceiveTaskResult;
	Result result;
};
typedef struct ReceiveTaskResult ReceiveTaskResult;

struct TryCompleteSubTask  //完成当前正在进行的子任务
{ 
	static const Type kType = kTryCompleteSubTask;
};
typedef struct TryCompleteSubTask TryCompleteSubTask;

struct TryCompleteSubTaskResult
{ 
	static const Type kType = kTryCompleteSubTaskResult;
	Result result;
	int32_t has_encountered_monster; //0 未遇怪 1遇怪
	EncounteredMonsters em; //如果是打怪  才有这个
};
typedef struct TryCompleteSubTaskResult TryCompleteSubTaskResult;

struct SubmitTask //交任务
{ 
	static const Type kType = kSubmitTask;
	bool next_task_depend_this; //  是否直接接取这个任务的下一个系列任务
};
typedef struct SubmitTask SubmitTask;

struct SubmitTaskResult
{ 
	static const Type kType = kSubmitTaskResult;
	Result result;
};
typedef struct SubmitTaskResult SubmitTaskResult;

struct AbandonTask //放弃任务
{ 
	static const Type kType = kAbandonTask;

};
typedef struct AbandonTask AbandonTask;

struct AbandonTaskResult
{ 
	static const Type kType = kAbandonTaskResult;
	Result result;
};
typedef struct AbandonTaskResult AbandonTaskResult;

struct TryCompleteTrunkTask //完成当前的主线任务，如果有多个子任务，即表示完成当前的子任务
{ 
	static const Type kType = kTryCompleteTrunkTask;
};
typedef struct TryCompleteTrunkTask TryCompleteTrunkTask;

struct TryCompleteTrunkTaskResult
{ 
	static const Type kType = kTryCompleteTrunkTaskResult;
	Result result;
};
typedef struct TryCompleteTrunkTaskResult TryCompleteTrunkTaskResult;


struct Convey // 传送，站到传送点上的时候 发这个消息
{ 
	static const Type kType = kConvey;
};
typedef struct Convey Convey;

struct ConveyResult
{ 
	static const Type kType = kConveyResult;
	Result result;
};
typedef struct ConveyResult ConveyResult;


typedef struct _GetBossSectionStatus //获取英雄关卡的状况
{ 
	static const Type kType = kGetBossSectionStatus;
}GetBossSectionStatus;

typedef struct _BossSectionStatus //上面的返回值
{ 
	static const Type kType = kBossSectionStatus;
	uint16_t	  max_avaialbe_section; //0表示还没有
	uint8_t max_times; //最大可用次数
	uint8_t used_times; //已使用次数
	int8_t killing_times[200]; //下标表示sid
}BossSectionStatus;

typedef struct _ChallengeBossSection //挑战精英boss
{ 
	static const Type kType = kChallengeBossSection;
	uint16_t index;
	bool second_time; //再次挑战
}ChallengeBossSection;

typedef struct _BossSectionRewards
{ 
	uint16_t gold;
	uint16_t feat;
	uint32_t silver;
	uint32_t hero_exp;
	PropSid prop;
}BossSectionRewards;

typedef struct _ChallengeBossSectionResult //这个只是示意  不直接使用
{ 
	static const Type kType = kChallengeBossSectionResult;
	Result result;
	bool  win;  //战斗是否胜利
	int8_t rewards_count;//掉落的个数
	int16_t fight_record_bytes; //战报的字节数
	Reward rewards[8]; //实际长度以前面的count为准
	uint8_t fight_record[kMaxFightRecordLength]; //实际长度以前面的bytes为准，记录为压缩后的内容
	BossSectionRewards section_rewards;
}ChallengeBossSectionResult;



struct GetStamina
{
	static const Type kType = kGetStamina;
};
typedef struct GetStamina GetStamina;

struct GetStaminaResult
{
	static const Type kType = kGetStaminaResult;
	uint32_t replenish_time;	//补充体力到期时间
	uint32_t back_time;			//回到城镇的绝对
	uint16_t stamina_max;		//未使用
	uint16_t stamina;
	uint16_t stamina_take_max;	//携带体力<水壶>上限
	uint16_t stamina_take;
};
typedef struct GetStaminaResult GetStaminaResult;

struct PushStaminaInfo
{
	static const Type kType = kPushStaminaInfo;
	uint32_t replenish_time;	//补充体力到期时间
	uint16_t stamina;			//体力<水箱>
	uint16_t stamina_take;		//携带体力<水壶>
};
typedef struct PushStaminaInfo PushStaminaInfo;

struct BackToMainCity
{
	static const Type kType = kBackToMainCity;
};
typedef struct BackToMainCity BackToMainCity;

struct BackToMainCityResult
{
	static const Type kType = kBackToMainCityResult;
	Result result;
};
typedef struct BackToMainCityResult BackToMainCityResult;

struct PushForceBackToMainCity
{
	static const Type kType = kPushForceBackToMainCity;
};
typedef struct PushForceBackToMainCity PushForceBackToMainCity;

struct ClearStaminaCD
{
	static const Type kType = kClearStaminaCD;
};
typedef struct ClearStaminaCD ClearStaminaCD;

struct ClearStaminaCDResult
{
	static const Type kType = kClearStaminaCDResult;
	Result result;
};
typedef struct ClearStaminaCDResult ClearStaminaCDResult;

struct ReplenishStamina
{
	static const Type kType = kReplenishStamina;
};
typedef struct ReplenishStamina ReplenishStamina;

struct ReplenishStaminaResult
{
	static const Type kType = kReplenishStaminaResult;
	Result result;
};
typedef struct ReplenishStaminaResult ReplenishStaminaResult;

struct ClearBackToTownCD
{
	static const Type kType = kClearBackToTownCD;
};
typedef struct ClearBackToTownCD ClearBackToTownCD;

struct ClearBackToTownCDResult
{
	static const Type kType = kClearBackToTownCDResult;
	Result result;
};
typedef struct ClearBackToTownCDResult ClearBackToTownCDResult;


enum Weather{kSunny, kRain, kCloudy, kSnow, kFog};
struct WeatherChanged //s2c 主动推送
{ 
	static const Type kType = kWeatherChanged;
	uint8_t weather; //上面定义的值
};
typedef struct WeatherChanged WeatherChanged;