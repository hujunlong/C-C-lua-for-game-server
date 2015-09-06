#pragma  once
#include "game_def.h"
#include "town.h"

enum DataGetType
{

	kGetOtherPlayerBaseInfo = kDataGetTypeBegin+1,
	kGetPlayerArmy = kDataGetTypeBegin+2,
	kGetPlayerEquipment = kDataGetTypeBegin+3,
	kGetOtherPlayerOverviewInfo = kDataGetTypeBegin+4,
	kGetOtherPlayerBuildings = kDataGetTypeBegin+5,
	kGetOtherPlayerHerosInfo = kDataGetTypeBegin+6,

	kGetTop	= kDataGetTypeBegin+7,
	kGetPlayerOwnRank = kDataGetTypeBegin + 8,
	kGetPlayerRemainWorship = kDataGetTypeBegin + 9,
	kGiveOtherAddWorship = kDataGetTypeBegin + 10,
	kGetWorshipList = kDataGetTypeBegin + 11,
	kGetOtherPlayerTownInfo = kDataGetTypeBegin + 12,

	//下面是返回值
	kOtherPlayerBaseInfo = kDataGetTypeReturnBegin+1,
	kPlayerArmy = kDataGetTypeReturnBegin+2,
	kPlayerEquipment = kDataGetTypeReturnBegin+3,
	kOtherPlayerOverviewInfo = kDataGetTypeReturnBegin+4,
	kOtherPlayerBuildings = kDataGetTypeReturnBegin+5,
	kOtherPlayerHerosInfo = kDataGetTypeReturnBegin+6,

	kGetTopResult = kDataGetTypeReturnBegin+7,
	kGetPlayerOwnRankResult = kDataGetTypeReturnBegin + 8,
	kGetPlayerRemainWorshipResult = kDataGetTypeReturnBegin + 9,
	kGiveOtherWorshipResult = kDataGetTypeReturnBegin + 10,
	kGetWorshipListResult = kDataGetTypeReturnBegin + 11,

	kOtherPlayerTownInfo = kDataGetTypeReturnBegin + 12,
	//直接发给world() 8901 ~ 9000直接传给 world
	kAddPrestige = kDataGetTypeBegin + 901, //加威望

	kDataGetTypeEnd = kDataGetTypeBegin + 999,
};

enum DataResultType
{
	DataResultType = 35000,
	TOP_PLAYER_HAS_WORSHIP_ERROR  = DataResultType + 1,            //对同一玩家只能膜拜一次
	TOP_GUILD_HAS_WORSHIP_ERROR  = DataResultType + 2,            //对同一工会只能膜拜一次
	TOP_REMAIN_WORSHIP_ERROR = DataResultType + 3,                //可使用膜拜次数错误
	TOP_WORSHIP_THEIR_OWN_ERROR = DataResultType + 4,             //不能膜拜自己
};

enum TopData
{
	kSelectMax = 100, //查询前100的数据
};

struct GetOtherPlayerBaseInfo //获取别人的基础信息
{ 
	static const Type kType = kGetOtherPlayerBaseInfo;
	UserID player;
};
typedef struct GetOtherPlayerBaseInfo GetOtherPlayerBaseInfo;

struct OtherPlayerBaseInfo
{ 
	static const Type kType = kOtherPlayerBaseInfo;

};
typedef struct OtherPlayerBaseInfo OtherPlayerBaseInfo;

struct GetPlayerArmy //获取别人的部队基本信息
{ 
	static const Type kType = kGetPlayerArmy;
	UserID player;
};
typedef struct GetPlayerArmy GetPlayerArmy;

struct PlayerArmy
{ 
	static const Type kType = kPlayerArmy;
	int32_t count;
	struct HeroSimpleInfo
	{
		HeroSid sid;
		uint8_t level;
	}heros[9];
};
typedef struct PlayerArmy PlayerArmy;

struct GetPlayerEquipment //获取别个玩家的某件装备的信息(非自己)
{ 
	static const Type kType = kGetPlayerEquipment;
	UserID player;
	PropID id;
};
typedef struct GetPlayerEquipment GetPlayerEquipment;

struct PlayerEquipment
{ 
	static const Type kType = kPlayerEquipment;
	Equipment4Client equip;
};
typedef struct PlayerEquipment PlayerEquipment;


typedef struct _GetOtherPlayerOverviewInfo  //获取某个用户的总揽信息（非自己）
{ 
	static const Type kType = kGetOtherPlayerOverviewInfo;
	UserID uid;
}GetOtherPlayerOverviewInfo;

typedef struct _OtherPlayerOverviewInfo  
{ 
	static const Type kType = kOtherPlayerOverviewInfo;
	uint8_t level;
	uint8_t cityhall_level;
	uint16_t rank;
	uint32_t town_prosperity_degree;
}OtherPlayerOverviewInfo;

typedef struct _GetOtherPlayerBuildings  //获取某个用户的建筑信息（非自己）
{ 
	static const Type kType = kGetOtherPlayerBuildings;
	UserID uid;
	int8_t type; //建筑物的类型，定义在town.h中的TownItemType
}GetOtherPlayerBuildings;

typedef struct _OtherPlayerBuildings
{ 
	static const Type kType = kOtherPlayerBuildings;
	int16_t count; //建筑物的数量
	uint8_t data[31*1024]; //建筑物的数据，结构为建筑信息的数组， 请参照town.h中的定义
}OtherPlayerBuildings;

typedef struct _GetOtherPlayerHerosInfo //获取其他玩家的英雄信息（不能用来获取自己的）
{ 
	static const Type kType = kGetOtherPlayerHerosInfo;
	UserID uid;
}GetOtherPlayerHerosInfo;

#pragma pack(1)
typedef struct _OtherPlayerHerosInfo
{ 
	static const Type kType = kOtherPlayerHerosInfo;
	int32_t count;  //英雄个数
	struct 
	{
		HeroProperty property;
		struct
		{
			PropID id;
			PropSid sid;
		}equipments[8]; //下标是装备位置，id值为0表示无装备
	}heros_info[10];
}OtherPlayerHerosInfo;

#pragma pack()


struct TopStruct
{ 
	uint32_t rank;//排名
	uint32_t rank_data;//对应排名数据
	uint32_t worshiped_count;//被膜拜次数
	uint32_t id;     //对应公会或者玩家id
	uint16_t lenth; 
	char nickname[18];//名字
	
};
typedef struct TopStruct TopStruct;

struct TopStructGuild
{ 
	uint32_t rank;//排名
	uint32_t rank_data;//对应排名数据
	uint32_t worshiped_count;//被膜拜次数
	uint32_t id;     //对应公会或者玩家id
	uint16_t unuse; 
	uint16_t lenth; 
	char nickname[24];//名字
	
};
typedef struct TopStructGuild TopStructGuild;

struct GetTop //c2s
{ 
	static const Type kType = kGetTop;
};
typedef struct GetTop GetTop;

struct  GetTopResult//s2c
{
	static const Type kType = kGetTopResult;
	Result result;

	uint32_t count_level; //上榜银币玩家个数
	TopStruct top_level[kSelectMax];

	uint32_t count_silver;
	TopStruct top_silver[kSelectMax];

	uint32_t count_fightingPower;
	TopStruct top_fightingpower[kSelectMax];

	uint32_t count_degree_of_prosperity;
	TopStruct top_degree_of_prosperity[kSelectMax];//繁荣度

	uint32_t count_guild;
	TopStructGuild top_guild[kSelectMax];
};
typedef struct GetTopResult GetTopResult;

struct GetPlayerOwnRank//c2s
{
	static const Type kType = kGetPlayerOwnRank;
};
typedef struct GetPlayerOwnRank GetPlayerOwnRank; 

struct GetPlayerOwnRankResult//s2c
{
	static const Type kType = kGetPlayerOwnRankResult;
	Result result;
	uint32_t player_own_level_rank;
	uint32_t player_own_silver_rank;
	uint32_t player_own_fightingpower_rank;
	uint32_t player_own_degree_of_prosperity_rank;//繁荣度
	uint32_t guild_own_rank;
}; 
typedef struct GetPlayerOwnRankResult GetPlayerOwnRankResult;

struct GetPlayerRemainWorship//c2s //获取玩家自己能够使用的膜拜次数
{
	static const Type kType = kGetPlayerRemainWorship;
};
typedef struct GetPlayerRemainWorship GetPlayerRemainWorship;

struct GetPlayerRemainWorshipResult //s2c
{
	static const Type kType = kGetPlayerRemainWorshipResult ;
	Result result;
	uint32_t worshiped_level_count;        //玩家等级被膜拜次数
	uint32_t worshiped_silver_count;       //玩家银币被膜拜次数
	uint32_t worshiped_fightingpower_count;//玩家战斗力被膜拜次数
	uint32_t worshiped_degree_of_prosperity_count;//玩家繁荣度膜拜次数
	uint32_t remain_worship_count;//能够使用的膜拜剩余次数
};
typedef struct GetPlayerRemainWorshipResult GetPlayerRemainWorshipResult;


struct GiveOtherAddWorship  //给别人或者公会添加膜拜c2s
{
	static const Type kType = kGiveOtherAddWorship;
	uint32_t id;//膜拜者的id
	uint32_t type;//(1：等级排行 2:财富排行 3:战斗力排行 4：繁荣度排行 5:公会等级 )
};
typedef struct GiveOtherAddWorship GiveOtherAddWorship;

struct GiveOtherAddWorshipResult  //给别人或者公会添加膜拜s2c
{
	static const Type kType = kGiveOtherWorshipResult;
	Result result;
	bool is_worship_success;//膜拜是否成功（1：成功 0：失败 成功 前端膜拜次数对应+1）
};
typedef struct GiveOtherAddWorshipResult GiveOtherAddWorshipResult;

struct GetWorshipList //c2s
{
	static const Type kType = kGetWorshipList;
};
typedef struct GetWorshipList GetWorshipList;

struct Worship
{
	uint32_t id; 
	uint32_t type;
};
typedef struct Worship Worship;

struct GetWorshipListResult //返回玩家已经膜拜的公会或者s2c
{
	static const Type kType = kGetWorshipListResult;
	Result result;
	uint32_t count;//膜拜玩家的个数 +　膜拜公会的个数
	Worship data[30];
};
typedef struct GetWorshipListResult GetWorshipListResult;


typedef struct _GetOtherPlayerTownInfo //获取他人城镇的总体信息
{ 
	static const Type kType = kGetOtherPlayerTownInfo;
	UserID uid;
}GetOtherPlayerTownInfo;

#pragma pack(1)
typedef struct _OtherPlayerTownInfo
{ 
	static const Type kType = kOtherPlayerTownInfo;
	uint8_t block_status[36]; //36个区块的开启状态，0表示未开启，非0表示已开启
	int32_t prosperity_degree; //繁荣度
}OtherPlayerTownInfo;
#pragma pack()


struct AddPrestige //增加威望
{
	static const Type kType = kAddPrestige;
	uint32_t delta;
};
typedef struct AddPrestige AddPrestige;