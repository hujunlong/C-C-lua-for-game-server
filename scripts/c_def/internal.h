#pragma once
#include "define.h"
#include "game_def.h"
#include "playgroud.h"
#include "town.h"

enum  Internal
{
	kUserEnter = kInternalStart+1,
	kUserExit,
	kInsertRow,
	kUpdateField,
	kDeleteRow,
	kUserEnterSucceeded,
	kPropFromDb,
	kPropSetting,
	kEquipmentFromDb,
	kUpdateStringField,
	kEquipmentGemFromDb,
	kSectionScores,
	kSkills,
	kPlayerStatus,
	kRuneStatus,
	kArenaInfo,
	kArenaHistory,
	kRuneInfoStove,
	kRuneInfoBag,
	kRuneInfoHero,
	kUpdateField2,
	kUpdateFieldWithSubIndex,
	kInsertRow2,
	kInsertGuild,
	kGradeInfo,
	kUpdateStringField2,
	kArrays,
	kEscortInfo,
	kEscortRoad,
	kEscortReward,
	kDeleteGuild,
	kEscortRobbed,
	kAccomplishedAchievements,
	kActions,
	kArenaChallenge,
	kFishInfo,
	kPlayGroundRaceInfoResult,
	kUpdateBinaryStringField,
	kReplaceIconBin,
	kGuildApplication,
	kGuildWarFiles,
	kUpdateDeltaField,
	kMemberLeaveGuild,
	kMemberJoinGuild,
	kInsertNewGuildGrade,
	kPlayGroundDragonInfoResult,
	kWorldWarInfo,
	kClientConfig,
	kLordBuffers,
	kNotifyOfNewMail,
	kExtractAttachment,
	kExtractAttachmentResult,
	kUpdateWarFieldGuild,
	kUserEnterFailed,
	kInternalLogin,
	kInternalLoginResult,
	kInternalRegister,
	kInternalRegisterResult,
	kInternalIsUidExist,
	kInternalIsUidExistResult,
	kInternalTurntableInfo,
	kInternalPlaygroundInfo,
	kInternalPlaygroundProps,
	kVIPCount,
	kInsertBattleRecord,
	kInternalLoginSucceeded,
	kInternalLogout,
	kInternalAntiAddictionShutdown,
	kInternalProveAntiAddictionInfo,
	kInternalProveAntiAddictionInfoResult,
	kUpdateDeltaFieldWithSubIndex,
	kInternalAssistantInfo,
	kQueryFightRecord,
	kQueryFightRecordResult,
	kAuctionInfo,
	kAccomplishedBranchTasks,
	kKickUser,
	kWorldServerExit,
	kAuctionOffline,
	kExcuteSqlDirectly,
	kBossesKillingTimes,
	kNotifyPlayerInfoChange,	
	kUpdateMultiFeilds2Value,
	kTrain,
	kInternalTreeInfo,
	kTowerInfo,
	kInternalIsNicknameExist,
	kInternalIsNicknameExistResult,
	kTownWarehouse,
	kUpdateFieldConditionally,
	kTerritoryOffline,
	kWelcomeToGame,
	kInternalRewardDaysAgoInfo,
	kInternalSaveWebsiteInfo,
	kInternalLuckyDrawInfo,
	kStageAward,
	kInternalCheckInEveryDayInfo,
	kInternalCheckInAccumulateInfo,
};

enum DbRuneMaxCount
{
    DB_RUNE_MAX_COUNT_STOVE = 20,              // 熔炉中最多20个符文
    DB_RUNE_MAX_COUNT_INBAG = 30,              // 包裹中最多30个符文
    DB_RUNE_MAX_COUNT = 512,                   // 数据库最多512个符文
};

struct UserEnter
{
	static const Type  kType = kUserEnter;
};
typedef struct UserEnter UserEnter;

struct UserExit
{
	static const Type  kType = kUserExit;
};
typedef struct UserExit UserExit;

typedef struct 
{ 
	static const Type kType = kKickUser;
	UserID uid;
}KickUser;


struct UserEnterFailed
{
	static const Type kType = kUserEnterFailed;

};
typedef struct UserEnterFailed UserEnterFailed;

#pragma pack(2)
struct PerField
{
	uint16_t field;
	int64_t val;
};
typedef struct PerField PerField;
#pragma pack()

struct InsertRow
{
	static const Type  kType = kInsertRow;
	uint8_t table;
	uint8_t len;
	PerField fields[6];
};
typedef struct InsertRow InsertRow;

struct InsertRow2
{
	static const Type  kType = kInsertRow2;
	uint8_t table;
	uint8_t len;
	PerField fields[6];
};
typedef struct InsertRow2 InsertRow2;

struct InsertBattleRecord
{
	static const Type  kType = kInsertBattleRecord;
	uint32_t id;
	uint32_t len;
	char str[kMaxFightRecordLength];
};
typedef struct InsertBattleRecord InsertBattleRecord;

struct UpdateField
{
	static const Type  kType = kUpdateField;
	int32_t id;
	uint8_t table;
	uint8_t len;
	PerField fields[6];
};
typedef struct UpdateField UpdateField;

struct UpdateStringField
{
	static const Type  kType = kUpdateStringField;
	int32_t id;
	uint8_t table;
	uint8_t filed;
	uint8_t len;
	char str[81];
};
typedef struct UpdateStringField UpdateStringField;

struct UpdateStringField2
{
	static const Type  kType = kUpdateStringField2;
	uint32_t table;
	uint32_t where_len;			//条件
	PerField where_fields[3];
	uint32_t set_filed;			//更新的值
	uint32_t set_val_len;
	char set_val_str[600];
};
typedef struct UpdateStringField2 UpdateStringField2;

struct UpdateBinaryStringField
{
	static const Type  kType = kUpdateBinaryStringField;
	uint32_t table;
	uint32_t where_len;			//条件
	PerField where_fields[3];
	uint32_t set_filed;			//更新的值
	uint32_t set_val_len;
	char set_val_str[256];
};
typedef struct UpdateBinaryStringField UpdateBinaryStringField;

struct UpdateDeltaField
{
	static const Type  kType = kUpdateDeltaField;
	int32_t index;     //索引值
	uint8_t table_name;     //表名
	uint8_t index_name;     //索引名
	uint16_t field;     //字段名
	int32_t val;        //字段增量
};
typedef struct UpdateDeltaField UpdateDeltaField;

typedef struct _UpdateMultiFeilds2Value //将表中多行的同一字段改为指定的值
{ 
	static const Type kType = kUpdateMultiFeilds2Value;
	uint8_t table_name;     //表名
	uint8_t index_name;     //索引名
	uint8_t field_name;     //要改变的字段名
	int32_t val;         //新值
	int32_t count; //有多少个
	int32_t indexs[8000]; 
	static const uint32_t kMaxCount = 8000; //注意和前面的值一致， 这样写是为了与luajit兼容
}UpdateMultiFeilds2Value;

struct ReplaceIconBin
{
	static const Type  kType = kReplaceIconBin;
	uint32_t guild_id;
	uint32_t icon_bin_len;
	char icon_bin[1024*20];
};
typedef struct ReplaceIconBin ReplaceIconBin;

struct GuildApplication
{
	static const Type  kType = kGuildApplication;
	uint32_t guild_id;
	uint32_t player_id;
	uint32_t apply_time;
	uint32_t player_name;
	uint32_t player_level;
};
typedef struct GuildApplication GuildApplication;

struct GuildWarFiles
{
	static const Type  kType = kGuildWarFiles;
	uint32_t id;
	uint32_t guild_id;
	uint32_t technology_level;
	uint32_t technology_exp;
};
typedef struct GuildWarFiles GuildWarFiles;


struct DeleteRow
{
	static const Type  kType = kDeleteRow;
	uint8_t table;
	int32_t id;
};
typedef struct DeleteRow DeleteRow;


struct QueryFightRecord
{
	static const Type  kType = kQueryFightRecord;
	uint32_t id;
};
typedef struct QueryFightRecord QueryFightRecord;

struct QueryFightRecordResult
{
	static const Type  kType = kQueryFightRecordResult;
	uint16_t flag;
	uint16_t len;
	char str[kMaxFightRecordLength];
};
typedef struct QueryFightRecordResult QueryFightRecordResult;


struct UserEnterSucceeded
{
	static const Type  kType = kUserEnterSucceeded;
};

struct Prop
{
	uint16_t kind;
	uint8_t area; //1背包 2仓库 3英雄
	uint8_t location; //位置，定义在上面的enum PropLocation中
	uint8_t amount;
	uint8_t bind;//是否绑定
};
typedef struct Prop Prop;

struct PropFromDb
{
	static const Type  kType = kPropFromDb;
	int32_t id;
	Prop prop;
};
typedef struct PropFromDb PropFromDb;

struct PropSetting
{
	static const Type  kType = kPropSetting;
	int8_t bag_grids_count;
	int8_t warehouse_grids_count;
};
typedef struct PropSetting PropSetting;

struct Equipment
{
	enum{kMaxHolesCount = 3};
	uint8_t level;
	uint8_t base_strength;
	uint8_t base_agility;
	uint8_t base_intelligence;
	int8_t hero;
	int8_t holes[kMaxHolesCount];
	PropSid gems[kMaxHolesCount];
};
typedef struct Equipment Equipment;

struct EquipmentFromDb
{
	static const Type kType = kEquipmentFromDb;
	int32_t id;
	Equipment equip;
};
typedef struct EquipmentFromDb EquipmentFromDb;

struct EquipmentGemFromDb
{
	static const Type kType = kEquipmentGemFromDb;
	PropID equipment;
	int8_t hole_index;
	uint16_t kind;
};
typedef struct EquipmentGemFromDb EquipmentGemFromDb;

struct SectionScores
{
	static const Type kType = kSectionScores;
	int8_t scores[2000];
};
typedef struct SectionScores SectionScores;

struct Skills
{
	static const Type kType = kSkills;
	enum{kMaxCount=255};
	uint32_t count;
	struct Skill
	{
		uint8_t id;
		uint8_t level;
	} skills[kMaxCount];
};
typedef struct  Skills Skills;

struct PlayerStatus
{
	static const Type kType = kPlayerStatus;
	uint32_t last_logout_time;
	uint32_t last_active_time;
	uint16_t army_area;
	uint8_t army_location;
	uint8_t encounter_cd;
	int32_t current_branch_task;
	int16_t current_trunk_task;
	int8_t trunk_task_progress;
	int8_t branch_task_progress;
	uint16_t passed_section; //最新通关的关卡
	uint16_t passed_boss_section; //最新通关的英雄关卡
	int16_t boss_killing_times; //精英boss已用挑战次数
	uint32_t replenish_time;	//补充体力到期时间
	uint32_t back_time;			//回城时间
	uint16_t stamina;			//体力<水箱>
	uint16_t stamina_take;		//携带体力<水壶>
};
typedef struct PlayerStatus PlayerStatus;

struct ClientConfig
{
	static const Type kType = kClientConfig;
	uint32_t len;
	int8_t config[256];
};
typedef struct ClientConfig ClientConfig;


struct RuneStatus
{
	static const Type kType = kRuneStatus;
	uint8_t status;
	uint32_t max_id;    //符文最大ID
	uint32_t energy;    //符文能量池
};
typedef struct RuneStatus RuneStatus;

struct RuneInfo
{
	uint32_t rune_id;
	int8_t type;
	int8_t location;
	int8_t position;
	int8_t lock;
	uint32_t exp;
};
typedef struct RuneInfo RuneInfo;

struct RuneInfoStoveList
{
	static const Type kType = kRuneInfoStove;
	uint32_t count;
	RuneInfo list[DB_RUNE_MAX_COUNT_STOVE];
};
typedef struct RuneInfoStoveList RuneInfoStoveList;

struct RuneInfoBagList
{
	static const Type kType = kRuneInfoBag;
	uint32_t count;
	RuneInfo list[DB_RUNE_MAX_COUNT_INBAG];
};
typedef struct RuneInfoBagList RuneInfoBag;

struct RuneInfoHeroList
{
	static const Type kType = kRuneInfoHero;
	uint32_t count;
	RuneInfo list[DB_RUNE_MAX_COUNT];
};
typedef struct RuneInfoHeroList RuneInfoHeroList;

struct EscortInfo
{
	static const Type kType = kEscortInfo;
	uint8_t count;
	//uint16_t total;
	uint8_t intercept;
	//uint16_t intercept_total;
	//uint8_t auto_accept;
	uint16_t refresh;
	uint32_t time;
	uint8_t transport;
};
typedef struct EscortInfo EscortInfo;

struct EscortRoad
{
	static const Type kType = kEscortRoad;
	uint32_t time;
	uint32_t guardian;
	uint8_t transport;
};
typedef struct EscortRoad EscortRoad;

struct EscortReward
{
	uint8_t transport;
	uint8_t count;
	uint8_t help;
	uint32_t silver;
	uint32_t prestige;
};
typedef struct EscortReward EscortReward;

struct EscortRewardList
{
	static const Type kType = kEscortReward;
	uint32_t count;
	EscortReward list[128];
};
typedef struct EscortRewardList EscortRewardList;

struct EscortRobbed
{
	uint32_t robber;
	uint8_t help;
	uint8_t transport;
	uint8_t winner;
	uint32_t silver;
	uint32_t prestige;
};
typedef struct EscortRobbed EscortRobbed;
struct EscortRobbedList
{
	static const Type kType = kEscortRobbed;
	uint32_t count;
	EscortRobbed list[16];
};
typedef struct EscortRobbedList EscortRobbedList;

struct ArenaChallenge
{
	uint32_t challenger;
	int32_t  rank_change;
	uint32_t war_id;
};
typedef struct ArenaChallenge ArenaChallenge;

struct ArenaChallengeList
{
	static const Type kType = kArenaChallenge;
	uint32_t count;
	ArenaChallenge list[64];
};
typedef struct ArenaChallengeList ArenaChallengeList;

struct ArenaInfo
{
	static const Type kType = kArenaInfo;
	/* 注释掉的内容，通过全局内容读取
	uint32_t rank;
	uint32_t reward;
	int32_t reward_bak;
	*/
	uint32_t time;
	int8_t count;
	uint8_t buy_count;
	/*
	uint16_t win_count;
	uint16_t lose_count;
	*/
};
typedef struct ArenaInfo ArenaInfo;

struct ArenaHistory
{
	UserID target_id;
	uint32_t initiative;
	uint32_t winner;
	int32_t rank_change;
	uint32_t war_id;
	uint32_t time;
};
typedef struct ArenaHistory ArenaHistory;

struct ArenaHistoryList
{
	static const Type kType = kArenaHistory;
	uint32_t count;
	ArenaHistory list[5];
};
typedef struct ArenaHistoryList ArenaHistoryList;

struct GradeInfo
{
	static const Type kType = kGradeInfo;
	uint8_t level;
	uint8_t progress;
	uint8_t reward;
	//int8_t reward_bak;
	//int32_t time;
};
typedef struct GradeInfo GradeInfo;
/*
struct WorldWarInfo
{
	static const Type kType = kWorldWarInfo;
	//uint32_t rank;
	uint32_t point;
	//uint32_t score;
	//uint32_t time;
	//int8_t count;
	int8_t robot;
	int8_t vote;
};
typedef struct WorldWarInfo WorldWarInfo;
*/
typedef struct _FishRecord
{
	uint16_t  kind;		//fish kind(sid)
	uint16_t  weight;	//
}FishRecord;

struct FishInfo
{
	static const Type kType = kFishInfo;
	uint16_t fish_times;
	uint16_t gold_times;
	uint16_t torpedo_times;
	uint16_t amount;
	FishRecord records[128];
};
typedef struct FishInfo FishInfo;

struct PlayGroundRaceInfoResult
{
	static const Type kType = kPlayGroundRaceInfoResult;
	int32_t signup;			//报名状态
	//投注信息
	//竞猜, 1-10 赛道,,  11 单,, 12 双
	int16_t money[12];		//竞猜金额, 单位为万
};
typedef struct PlayGroundRaceInfoResult PlayGroundRaceInfoResult;

struct PlayGroundDragonInfoResult
{
	static const Type kType = kPlayGroundDragonInfoResult;
	int16_t len;
	int16_t rooms;
	struct InternalDragonInfo
	{
		int32_t dragon_id;
		int32_t his_rank;
		int32_t m_time;
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
	}dragon[9];
};
typedef struct InternalDragonInfo InternalDragonInfo;
typedef struct PlayGroundDragonInfoResult PlayGroundDragonInfoResult;

struct MailAttachment
{
	int8_t   attach_id;	//附件1,附件2,...
	int8_t	 extracted;	//已经提取=1
	uint16_t unuse1;
	uint16_t type;		//RewardType<应策划要求,此值强制为kPropRsc>
	uint16_t kind;		//这个值只有道具（Prop）用得上
	uint32_t amount;
	int32_t  prop_id;	//道具id,当prop_id!=0时有效,同时正确填写type和kind,amount
};
 typedef struct MailAttachment MailAttachment;

 struct MailAttachments
 {
 	int32_t amount;			//附件个数
 	MailAttachment attach[8];
 };
typedef struct MailAttachments MailAttachments;

struct ExtractAttachment//s2s
{
	static const Type kType = kExtractAttachment;
	int8_t	mail_id;
	int8_t  attach_id;//附件1=1,如果为-1,代表全部提取
};
typedef struct ExtractAttachment ExtractAttachment;

struct ExtractAttachmentResult
{
	static const Type kType = kExtractAttachmentResult;
	Result result;
};
typedef struct ExtractAttachmentResult ExtractAttachmentResult;

struct NotifyOfNewMail //s2s
{
	static const Type kType = kNotifyOfNewMail;
	Result	result;
};
typedef struct NotifyOfNewMail NotifyOfNewMail;

struct InternalLogin //s2s
{
	static const int16_t kType = kInternalLogin;
	UserID uid; //user id
	StringLength key_len;
	char key[34];  //34为最大长度
	double serial;
};
typedef struct InternalLogin InternalLogin;

struct InternalLoginResult //s2s
{
	static const Type kType = kInternalLoginResult;
	Result result;
	UserID uid;
	double serial;
};
typedef struct InternalLoginResult InternalLoginResult;

struct InternalLoginSucceeded
{
	static const Type kType = kInternalLoginSucceeded;
	UserID uid;
	char   ipAddr[50];
};
typedef struct InternalLoginSucceeded InternalLoginSucceeded;

struct InternalLogout//s2s
{
	static const Type kType = kInternalLogout;
	UserID uid;
};
typedef struct InternalLogout InternalLogout;

struct InternalAntiAddictionShutdown
{
	static const Type kType = kInternalAntiAddictionShutdown;
	UserID uid;
};
typedef struct InternalAntiAddictionShutdown InternalAntiAddictionShutdown;

struct InternalProveAntiAddictionInfo
{
	static const Type kType = kInternalProveAntiAddictionInfo;
	double serial;
	UserID uid;
	StringLength name_len;
	char name[18];			//名字
	StringLength id_len;
	char id[22];			//身份证号码
};
typedef struct InternalProveAntiAddictionInfo InternalProveAntiAddictionInfo;

struct InternalProveAntiAddictionInfoResult
{
	static const Type kType = kInternalProveAntiAddictionInfoResult;
	double serial;
	Result result;
};
typedef struct InternalProveAntiAddictionInfoResult InternalProveAntiAddictionInfoResult;

struct InternalRegister //注册
{
	static const Type kType = kInternalRegister;
	double serial;
	UserID uid;
	Nickname name;
	int8_t sex;
	char   ipAddr[50];
};
typedef struct InternalRegister InternalRegister;

struct InternalRegisterResult
{
	static const Type kType = kInternalRegisterResult;
	double serial;
	Result result;
	UserID uid;
};
typedef struct InternalRegisterResult InternalRegisterResult;

struct InternalWelcomeToGame
{
	static const Type kType = kWelcomeToGame;
	UserID uid;
};
typedef struct InternalWelcomeToGame InternalWelcomeToGame;

struct InternalIsUidExist
{
	static const Type kType = kInternalIsUidExist;
	double serial;
	UserID uid;
};
typedef struct InternalIsUidExist InternalIsUidExist;

struct InternalIsUidExistResult
{
	static const Type kType = kInternalIsUidExistResult;
	double serial;
	Result result;
};
typedef struct InternalIsUidExistResult InternalIsUidExistResult;

struct InternalIsNicknameExist
{
	static const Type kType = kInternalIsNicknameExist;
	double serial;
	Nickname name;
};
typedef struct InternalIsNicknameExist InternalIsNicknameExist;

struct InternalIsNicknameExistResult
{
	static const Type kType = kInternalIsNicknameExistResult;
	double serial;
	bool b_exist;
};
typedef struct InternalIsNicknameExistResult InternalIsNicknameExistResult;

struct InternalTurntableInfo
{
	static const Type kType = kInternalTurntableInfo;
	int16_t result;
	int16_t re_times;
	int8_t  times;
	int8_t  cur_point;
	int8_t  should_return;
};
typedef struct InternalTurntableInfo InternalTurntableInfo;

struct InternalPlaygroundInfo
{
	static const Type kType = kInternalPlaygroundInfo;
	int32_t tickets;
};
typedef struct InternalPlaygroundInfo InternalPlaygroundInfo;

struct InternalPlaygroundProp
{
	int16_t kind;
	int16_t amount;
	int16_t buy_count;
	int16_t unuse1;
};
typedef struct InternalPlaygroundProp InternalPlaygroundProp;

struct InternalPlaygroundProps
{
	static const Type kType = kInternalPlaygroundProps;
	int32_t amount;
	InternalPlaygroundProp prop[256];
};
typedef struct InternalPlaygroundProps InternalPlaygroundProps;

struct InternalAssistantTaskInfo
{
	int16_t task_id;
	int8_t b_retrieve;
	int8_t unuse1;
	int32_t times;
	int32_t times_back;
	int32_t remain_times;
};
typedef struct InternalAssistantTaskInfo InternalAssistantTaskInfo;

struct InternalAssistantInfo
{
	static const Type kType = kInternalAssistantInfo;
	int16_t activity;
	int16_t draw;
	int16_t unuse1;
	int16_t amount;		//task amount
	InternalAssistantTaskInfo tasks[64];
};
typedef struct InternalAssistantInfo InternalAssistantInfo;

struct NotifyPlayerInfoChange
{
	enum { kLevelChange=1, kCountryChange=2, kGuildChange=3 };
	static const Type kType = kNotifyPlayerInfoChange;
	int32_t type;
	UserID  uid;
	int32_t data;//当前级别,当前国家,当家公会
};
typedef struct NotifyPlayerInfoChange NotifyPlayerInfoChange;

struct InternalTreeSeed
{
	int32_t ripe_time;		//剩余成熟时间
	uint32_t last_water;	//上次浇水时间,绝对时间
	uint8_t	kind;			//种子种类
	int8_t	location;		//位置
	int8_t  status;			//状态
	int8_t  watered;		//浇神水次数
};
typedef struct InternalTreeSeed InternalTreeSeed;

struct InternalTreeLog
{
	int32_t id;		//来访记录id
	uint32_t time;	//来访时间
	Nickname name;	//来访玩家
};
typedef struct InternalTreeLog InternalTreeLog;

struct InternalTreeInfo
{
	static const Type kType = kInternalTreeInfo;
	uint8_t water_amount;		//神水数量
	uint8_t buy_count;			//购买神水
	uint8_t seed_amount;		//种子数量
	uint8_t log_amount;			//记录数量
	InternalTreeSeed seeds[10];
	InternalTreeLog  logs[50];
};
typedef struct InternalTreeInfo InternalTreeInfo;

typedef struct _InternalRewardDaysAgoInfo
{
	static const Type kType = kInternalRewardDaysAgoInfo;
	uint32_t reg_time;
	uint8_t  got;
}InternalRewardDaysAgoInfo;

typedef struct _InternalSaveWebsiteInfo
{
	static const Type kType = kInternalSaveWebsiteInfo;
	uint8_t b_got;
}InternalSaveWebsiteInfo;

typedef struct _InternalLuckyDrawInfo
{
	static const Type kType = kInternalLuckyDrawInfo;
	uint32_t times;
}InternalLuckyDrawInfo;

typedef struct _InternalCheckInEveryDayReward
{
	PropSid  kind;
	uint16_t amount;
}InternalCheckInEveryDayReward;

typedef struct _InternalCheckInEveryDayRewards
{
	InternalCheckInEveryDayReward rewards[6];
}InternalCheckInEveryDayRewards;

typedef struct _InternalCheckInEveryDayInfo
{
	static const Type kType = kInternalCheckInEveryDayInfo;
	InternalCheckInEveryDayRewards rewards[5];
	uint32_t time;
	uint8_t days;
}InternalCheckInEveryDayInfo;

typedef struct _InternalCheckInAccumulateInfo
{
	static const Type kType = kInternalCheckInAccumulateInfo;
	uint32_t time;
	uint8_t days;
}InternalCheckInAccumulateInfo;

struct UpdateField2
{
	static const Type kType = kUpdateField2;
	uint32_t id;
	uint32_t sub_id;
	uint8_t table; //enum Table
	uint8_t index_filed; //enum filed
	uint8_t sub_index_filed; //enum filed
	uint8_t len;
	PerField fields[6];
};
typedef struct UpdateField2 UpdateField2;

typedef struct _UpdateFieldConditionally
{ 
	static const Type kType = kUpdateFieldConditionally;
	static const uint8_t kLess = 1;   //因为luajit解析把结构体内的enum视为全局，所以改用静态常量
	static const uint8_t kGreater = 2;
	uint32_t id;
	uint32_t sub_id;
	uint8_t table; //enum Table
	uint8_t index_filed; //enum filed
	uint8_t sub_index_filed; //enum filed
	uint8_t field; //enum filed
	uint8_t condition;  //kLess or kGreater
	uint32_t value;
}UpdateFieldConditionally;

struct UpdateFieldWithSubIndex
{
	static const Type kType = kUpdateFieldWithSubIndex;
	uint32_t index;
	uint32_t sub_index;
	uint8_t table; //enum Table
	uint8_t index_filed; //enum filed
	uint8_t sub_index_filed; //enum filed
	uint8_t len;
	PerField fields[6];
};
typedef struct UpdateFieldWithSubIndex UpdateFieldWithSubIndex;

struct UpdateDeltaFieldWithSubIndex
{ 
	static const Type kType = kUpdateDeltaFieldWithSubIndex;
	uint32_t index;
	uint32_t sub_index;
	uint8_t table; //enum Table
	uint8_t index_filed; //enum filed
	uint8_t sub_index_filed; //enum filed
	uint8_t field;
	int32_t delta;
};
typedef struct UpdateDeltaFieldWithSubIndex UpdateDeltaFieldWithSubIndex;

struct InsertGuild
{
	static const Type kType = kInsertGuild;
	uint32_t guild_id;
	uint32_t leader;
	uint32_t icon;
	uint32_t len;
	char name[24];								//公会名
	uint32_t grade1_name_len;
	char grade1_name[24];						//会长名
	uint32_t grade2_name_len;
	char grade2_name[24];						//副会长名
	uint32_t grade100_name_len;
	char grade100_name[24];						//会员名
};
typedef struct InsertGuild InsertGuild;

struct UpdateWarFieldGuild
{
	static const Type kType = kUpdateWarFieldGuild;
	uint32_t war_filed_id;
	uint32_t guild_id;
};
typedef struct UpdateWarFieldGuild UpdateWarFieldGuild;


struct InsertNewGuildGrade
{
	static const Type kType = kInsertNewGuildGrade;
	uint32_t guild_id;
	uint32_t new_grade_level;
	uint32_t new_grade_name_len;
	char new_grade_name[24];				//新会阶
};
typedef struct InsertNewGuildGrade InsertNewGuildGrade;

struct DeleteGuild
{
	static const Type kType = kDeleteGuild;
	uint32_t guild_id;
};
typedef struct DeleteGuild DeleteGuild;

struct MemberLeaveGuild
{
	static const Type kType = kMemberLeaveGuild;
	uint32_t player_id;
};
typedef struct MemberLeaveGuild MemberLeaveGuild;

struct MemberJoinGuild
{
	static const Type kType = kMemberJoinGuild;
	uint32_t player_id;
	uint32_t guild_id;
};
typedef struct MemberJoinGuild MemberJoinGuild;

struct Arrays
{
	static const Type kType = kArrays;
	int8_t count;
	struct
	{
		int8_t id;
		struct
		{
			uint8_t id;//0代表不存在
			int8_t location;
		}heros[5];
	}arrays[16];
};
typedef struct Arrays Arrays;

struct AccomplishedAchievements
{
	static const Type kType = kAccomplishedAchievements;
	int32_t count;
	struct
	{
		uint16_t id;
		uint32_t time;
	}records[1023];
};
typedef struct AccomplishedAchievements AccomplishedAchievements;

struct Actions
{
	static const Type kType = kActions;
	int32_t count;
	struct
	{
		uint16_t id;
		uint32_t kind;
		uint32_t value;
		uint32_t max;
	}records[1023];
};
typedef struct Actions Actions;

struct db_array
{
    struct
    {
        uint8_t id;//0代表不存在
        int8_t location;
    }heros[5];
};
typedef struct db_array db_array;

struct LordBuffers
{
	static const Type kType = kLordBuffers;
	struct
	{
		int16_t kind; //0表示不存在
		uint16_t value;
		uint32_t time;
	}buffers[5];
};
typedef struct LordBuffers LordBuffers;

typedef struct _ExcuteSqlDirectly// 杀伤力巨大，慎用！！！
{ 
	static const Type kType = kExcuteSqlDirectly;
	uint16_t len;
	char sql[1024*3];
}ExcuteSqlDirectly;


struct VIPCount
{
	static const Type kType = kVIPCount;
	uint16_t energy;
	uint16_t mobility;
	uint16_t alchemy;
	uint16_t rune;
	//uint8_t arena;
};
typedef struct VIPCount VIPCount;

struct AuctionInfo
{
	uint32_t uuid;
	uint32_t price;
	uint16_t status;//0 未卖出，1 2 已卖出，3 正在出售，4 竞拍成功，5 一口价购买，6 参与竞拍
	uint16_t kind;
	uint32_t amount;
	uint32_t time;
};
typedef struct AuctionInfo AuctionInfo;

struct AuctionInfoList
{
	static const Type kType = kAuctionInfo;
	uint32_t count;
	AuctionInfo list[256];
};
typedef struct AuctionInfoList AuctionInfoList;

struct AuctionOffline
{
	uint16_t kind;
	uint16_t gold;
};
typedef struct AuctionOffline AuctionOffline;

struct AuctionOfflineList
{
	static const Type kType = kAuctionOffline;
	uint32_t count;
	AuctionOffline list[256];
};
typedef struct AuctionOfflineList AuctionOfflineList;

struct AccomplishedBranchTasks
{ 
	static const Type kType = kAccomplishedBranchTasks;
	int16_t count;
	int32_t tasks[2047];
};
typedef struct AccomplishedBranchTasks AccomplishedBranchTasks;

typedef struct 
{ 
	static const Type kType = kBossesKillingTimes;
	int8_t killing_times[200];
}BossesKillingTimes;

struct  TrainNum
{
	static const Type kType = kTrain;
	uint32_t  available_train_count;
	uint32_t used_buy_count  ;
	uint32_t add_count_time;
};
typedef struct TrainNum TrainNum;


struct TowerInfo
{
	static const Type kType = kTowerInfo;
	uint32_t time;
	uint8_t tower;
	uint8_t layer;
	uint8_t refresh;
	uint8_t status;
	uint8_t suspend;
};
typedef struct TowerInfo TowerInfo;

struct TerritoryOffline
{
	static const Type kType = kTerritoryOffline;
	uint32_t time;
};
typedef struct TerritoryOffline TerritoryOffline;


typedef struct _TownWarehouse
{ 
	static const Type kType = kTownWarehouse;
	uint8_t count;
	struct 
	{
		TownItemID id;
		uint32_t expired_time;
	}items[32];
}TownWarehouse;


typedef struct StageAward
{ 
	static const Type kType = kStageAward;
	uint32_t count;
	struct 
	{
		uint8_t stage;
		uint8_t phase;
	} list[1024];
}StageAward;

//DB
static const int kInvalidID = -1;

enum Table
{
	ktBaseInfo=100,
	ktFunctionBuilding,
	ktBusinessBuilding,
	ktDecoration,
	ktRoad,
	ktHero,
	ktProp,
	ktEquipment,
	ktPropSetting,
	ktFormula,
	ktEquipmentGem,  //已作废
	ktSkill,
	ktStatus,
	ktArenaInfo,
	ktArenaHistory,
	ktRuneStatus,
	ktRuneInfo,
	ktGuild,
	ktGrade,
	ktGuildAuthority,
	ktArray,
	ktEscortInfo,
	ktEscortRoad,
	ktFish,
	ktFishRecord,
	ktSection,
	ktEscortReward,
	ktEscortRobbed,
	ktAction,
	ktAchievement,
	ktArenaChallenge,
	ktGuildIcon,
	ktPlayGroundRaceGuess,
	ktGuildMemberInfo,
	ktGuilWarFields,
	ktWorldWarInfo,
	ktLordBuffer,
	ktGuildWarMemberInfo,
	ktSettings,
	ktVIPCount,
	ktBattleRecord,
	ktTrain,
	ktGuildGiving,
	ktGuildMapSignList,
	ktAuctionInfo,
	ktAuction,
	ktGuildApplication,
	ktGuildWarFields,
	ktBranchTask,
	ktAuctionOffline,
	ktBossSection,
	ktGuildWarBuff,
	ktPlaygroundRearroom,
	ktPlaygroundDragon,
	ktAssistant,
	ktPlaygroundSignup,
	ktPlayground,
	ktMiscInfo,
	ktTreeSeed,
	ktTreeLog,
	ktTreeWater,
	ktTurntable,
	ktTower,
	ktTownWarehouse,
	ktTerritoryOffline,
	ktTerritoryInfo,
	ktConsumeRecord,
	ktRewardForDaysAgo,
	ktSaveWebsite,
	ktLuckyDraw,
	ktStageAward,
	ktCheckInEveryDay,
	ktCheckInAccumulate,
};

enum Filed
{
	kfGold,
	kfSilver,
	kfExp, //experience
	kfEnergy,
	kfFeat,
	kfPrestige,
	kfMobility,
	kfLevel,
	kfPlayer,
	kfPlayerId,
	kfID,
	kfX,
	kfY,
	kfAspect,
	kfKind,
	kfWarehoused,
	kfLastReap,
	kfProgress,
	kfAmount,
	kfStrength,
	kfAgility,
	kfIntelligence,
	kfHoles,
	kfLocation,
	kfLogoutTime,
	kfHero,
	kfArea,
	kfBagGridsCount,
	kfWarehouseGridsCount,
	kfStatus,
	kfGems,
	kfCountry,
	kfScore,
	kfArray,
	kfArmyArea,
	kfArmyLocation,
	kfEncounterCD,
	kfTrunkTask,
	kfBranchTask,
	kfTrunkTaskProgress,
	kfBranchTaskProgress,
	kfLastLogoutTime,
	kfType,
	kfRank,
	kfReward,
	kfRewardBak,
	kfTime,
	kfCount,
	kfBuyCount,
	kfWinCount,
	kfLoseCount,
	kfTarget,
	kfWinner,
	kfRankSelf,
	kfRankTarget,
	kfWarID,
	kfTemperature,
	kfFreeze,
	kfRuneID,
	kfLocked,
	kfPassedSection,
	kfPosition,
	kfGuildId,
	kfName,
	kfLeader,
	kfIcon,
	kfCallBoard,
	kfGuildGradeLevel,
	kfGradeName,
	kfGradeAuthority,
	kfTotal,
	kfIntercept,
	kfInterceptTotal,
	kfAutoAccept ,
	kfTransport,
	kfGuardian,
	kfFishFishTimes,
	kfFishGoldTimes,
	kfFishTorpedoTimes,
	kfFishKind,
	kfFishWeight,
	kfLooter1,
	kfLooter2,
	kfLastActiveTime,
	kfHelp,
	kfRefresh,
	kfBeintercepted,
	kfRobber,
	kfValue,
	kfDefendCount,
	kfDefendTotal,
	kfChallenger,
	kfRankChange,
	kfIconFrame,
	kfIconBinLen,
	kfIconBin,
	kfPlayGroundRaceGuessMoney,
	kfPlayGroundRaceGuessGuess,
	kfPlayGroundDragon,
	kfHeavensent,
	kfGuildOffer,
	kfActivityExp,
	kfRechargedGold,
	kfBringupBin,
	kfWarFieldId,
	kfTechnologyLevel,
	kfTechnologyExp,
	kfWarFieldOffer,
	kfPoint,
	kfRobot,
	kfVote,
	kfEquiped,
	kfIsGetMemberBox,
	kfSetting,
	kfAlchemy,
	kfRune,
	kfArena,
	kfMax,
	kfRecord,
	kfTrainNum,
	kfBuyNum,
	kfAddCountTime,
	kfGuildWarId,
	kfGuildCount,
	kfBoxType,
	kfPlayerFightBox,
	kfPlayerGuildBox,
	kfPlayerBox,
	kfPrice,
	kfUUID,
	kfSeller,
	kfBuyer,
	kfStart,
	kfPlayerName,
	kfPlayerLevl,
	kfBossKillingTimes,
	kfTimes,
	kfBind,
	kfBattleType,
	kfBuyLastTrainTime,
	kfRearrooms,
	kfAssActivity,
	kfAssDraw,
	kfPlaygroundHisRank,
	kfPlaygroundRank,
	kfPlaygroundDState,
	kfPlaygroundRaceway,
	kfPlaygroundSignup,
	kfPlaygroundStrength,
	kfPlaygroundAgility,
	kfPlaygroundIntellect,
	kfPlaygroundMTime,
	kfPlaygroundTickets,
	kfReplenishTime,
	kfBackTime,
	kfStamina,
	kfStaminaTake,
	kfFightPower,
	kfWorshipLevel,
	kfWorshipSilver,
	kfWorshipFightingPower,
	kfWorshipDegreeOfProsperity,
	kfWorshipGuild,
	kfWorshipUseNum,
	kfTreeKind,
	kfTreeLocation,
	kfTreeWatered,
	kfTreeStatus,
	kfTreeRipeTime,
	kfTreeLastWater,
	kfTreeId,
	kfTreeUid,
	kfTreeTime,
	kfTreeWaterAmount,
	kfTreeBuyCount,
	kfTurnTimes,
	kfTurnReTimes,
	kfTurnCurPoint,
	kfTurnResult,
	kfTurnShouldReturn,
	kfTower,
	kfLayer,
	kfSuspend,
	kfExpireTime,
	kfDegreeOfProsperity,
	kfPassedBossSection,
	kfGot,
	kfStage,
	kfPhase,
	kfRewards,
	kfDays,




	kfEnd,
};

//kfMax不要放到最后了
