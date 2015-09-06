#pragma once
#include "define.h"
#include "game_def.h"

typedef int32_t TownItemID;


enum TownItemType
{
	kFunctionBuilding = 1,
	kBusinessBuilding = 2,
	kDecoration = 3,
	kRoad = 4
};

enum 
{
	kMaxFunctionBuildings = 100,
	kMaxBusinessBuildings = 200,
	kMaxDecorations = 4096,
	kMaxRoads = 2048,
};

typedef int16_t TownItemKind;  //sid

enum TownType
{
	//10000
	kGetMyTown = kTownTypeBegin+1,
	kGetMyTownBuildings = kTownTypeBegin + 2,
	kGetTownBlocks = kTownTypeBegin+3,
	kGetTownProsperityDegree = kTownTypeBegin+4,
	kGetBuildingExpireTime = kTownTypeBegin+5,

	kFoundation = kTownTypeBegin+10,
	kBuild = kTownTypeBegin+11,
	kMove = kTownTypeBegin+12,
	kWarehousing = kTownTypeBegin+14,
	kUpgrade = kTownTypeBegin+15,
	kMerge = kTownTypeBegin+16,
	kReap = kTownTypeBegin+17,
	kSell = kTownTypeBegin+18,
	kUnlockTownBlock =  kTownTypeBegin+19,

	kGetCommercialBuildingInfo = kTownTypeBegin + 20,
	kFusionUpgrade = kTownTypeBegin + 21,
	kOutOfNothing = kTownTypeBegin + 22,
	kTownTypeEnd = 10200,

	///下面是返回值

	//16000
	kGetMyTownResult = kTownReturnBegin+1,
	kFoundationResult = kTownReturnBegin+2,
	kBuildResult = kTownReturnBegin+3,
	kMoveResult = kTownReturnBegin+4,
	kWarehousingResult = kTownReturnBegin+6,
	kUpgradeResult = kTownReturnBegin+7,
	kMergeResult = kTownReturnBegin+8,
	kReapResult = kTownReturnBegin+9,
	kSellResult = kTownReturnBegin+10,
	kFunctionBuildingStatus = kTownReturnBegin+11,
	kBusinessBuildingStatus = kTownReturnBegin+12,
	kDecorationStatus = kTownReturnBegin+13 ,
	kRoadStatus = kTownReturnBegin+14 ,
	kTownBlocks = kTownReturnBegin+15 ,
	kUnlockTownBlockResult = kTownReturnBegin+16,
	kTownProsperityDegree = kTownReturnBegin+17,
	kMyTownBuildings = kTownReturnBegin+18,
	kGetBuildingExpireTimeResult = kTownReturnBegin+19,

	kGetCommercialBuildingInfoResult = kTownReturnBegin + 20,
	kFusionUpgradeResult = kTownReturnBegin + 21,
	kOutOfNothingResult = kTownReturnBegin + 22,
	kBuildingGot = kTownReturnBegin + 100,
};

//如果遇到未知的定义，请参照这个文件头部#include的文件

static const int8_t kDefaultAspect = 0;

struct GetMyTown	//获取城镇数据，C2S
{
	static const Type kType = kGetMyTown;
};
typedef struct GetMyTown GetMyTown;

struct  GetMyTownReturn
{
	static const Type kType = kGetMyTownResult;
	uint8_t block_status[36]; //36个区块的开启状态，0表示未开启，非0表示已开启
	int32_t max_hall_level; //最大的内政厅等级
	int32_t prosperity_degree; //繁荣度
};
typedef struct GetMyTownReturn GetMyTownReturn;


struct GetMyTownBuildings  // 按照类型获取
{
	static const Type kType = kGetMyTownBuildings;
	int8_t type;
};
typedef struct GetMyTownBuildings GetMyTownBuildings;

typedef struct _MyTownBuildings
{ 
	static const Type kType = kMyTownBuildings;
	int16_t count; //建筑物的数量
	uint8_t data[31*1024]; //建筑物的数据，结构为建筑信息的数组， 请参照下面的定义
}MyTownBuildings;

#pragma pack(1)
struct FunctionBuildingStatus //功能建筑  s2c
{
	static const Type kType = kFunctionBuildingStatus;
	TownItemID id;
	TownItemKind kind;   //sid
	int8_t x;
	int8_t y;
	int8_t aspect;
	uint8_t level;
	int8_t progress;
	int8_t reserve; //保留备用
	uint32_t last_reap; //最后一次收钱时间，单位为1970年开始计算的秒数
};
typedef struct FunctionBuildingStatus FunctionBuildingStatus;


struct BusinessBuildingStatus		//商业建筑  s2c
{
	static const Type kType = kBusinessBuildingStatus;
	TownItemID id;
	TownItemKind kind; //何种建筑
	int8_t x; //x pos
	int8_t y; //y pos
	int8_t aspect;
	bool warehoused;
	int8_t progress;
	int8_t reserve; //保留备用
	uint32_t last_reap; //同上
};
typedef struct BusinessBuildingStatus BusinessBuildingStatus;


struct DecorationStatus		//装饰  s2c
{
	static const Type kType = kDecorationStatus;
	TownItemID id;
	TownItemKind kind;
	int8_t x;
	int8_t y;
	int8_t aspect;
	bool warehoused;
};
typedef struct DecorationStatus DecorationStatus;

struct RoadStatus		//道路 s2c
{
	static const Type kType = kRoadStatus;
	TownItemID id;
	TownItemKind kind;
	int8_t x;
	int8_t y;
	int8_t aspect;
	bool warehoused;
};
typedef struct RoadStatus RoadStatus;

#pragma pack()

//struct TownDataEnd  //数据结束标志  s2c
//{
//	static const Type kType = kTownDataEnd;
//};


struct Foundation  // 创建新建筑   c2s
{
	static const Type kType = kFoundation;
	TownItemKind kind;
	int8_t x;
	int8_t y;
};
typedef struct Foundation Foundation;

struct FoundationResult   //s2c
{
	static const Type kType = kFoundationResult;
	Result result; //值为game_def.h 中的 enum GameResult 里面定义的值
	TownItemID id;
	Foundation foundation;
};
typedef struct FoundationResult FoundationResult;

struct Build   //建造一次   c2s
{
	static const Type kType = kBuild;
	TownItemID id ;
};
typedef struct Build Build;


struct BuildResult   //s2c
{
	static const Type kType = kBuildResult;
	Result result;
	TownItemID id;
	int32_t count;
	Reward rewards[5];
};
typedef struct BuildResult BuildResult;

struct Move  //c2s
{
	static const Type kType = kMove;
	TownItemID id;
	int8_t x;
	int8_t y;
	int8_t aspect;
};
typedef struct Move Move;

struct  MoveResult   //s2c
{
	static const Type kType = kMoveResult;
	Result result;
	TownItemID id;
	int8_t x;
	int8_t y;
	int8_t aspect;
};
typedef struct MoveResult MoveResult;



struct Warehousing //收到仓库   c2s
{
	static const Type kType = kWarehousing;
	TownItemID id;
};
typedef struct Warehousing Warehousing;

struct WarehousingResult   // s2c
{
	static const Type kType = kWarehousingResult;
	Result result;
	TownItemID id;
};
typedef struct WarehousingResult WarehousingResult;

struct Upgrade  //c2s
{
	static const Type kType = kUpgrade;
	TownItemID id;
};
typedef struct Upgrade Upgrade;

struct UpgradeResult  //s2c
{
	static const Type kType = kUpgradeResult;
	Result result;
	TownItemID id;
	int32_t lord_exp;
};
typedef struct UpgradeResult UpgradeResult;

struct Merge  //建筑融合  c2s
{
	static const Type kType = kMerge;
	TownItemID id;
	TownItemID other;
	TownItemKind target_kind;
	int8_t x;
	int8_t y;
};
typedef struct Merge Merge;

struct MergeResult  //s2c
{
	static const Type kType = kMergeResult;
	Result result;
	Merge origin;
	TownItemID new_item;
};
typedef struct MergeResult MergeResult;

struct Reap  //收钱  c2s
{
	static const Type kType = kReap;
	TownItemID id;
};
typedef struct Reap Reap;

struct ReapResult // s2c
{
	static const Type kType = kReapResult;
	Result result;
	TownItemID id;
	int32_t count;
	Reward rewards[5]; //5为最大值，可以忽略这个值
};
typedef struct ReapResult ReapResult;

struct Sell  //出售 c2s
{
	static const Type kType = kSell;
	TownItemID id;
};
typedef struct Sell Sell;

struct SellResult  //c2s
{
	static const Type kType = kSellResult;
	Result result;
	TownItemID id;
};
typedef struct SellResult SellResult;

struct GetTownBlocks //c2s, 获取城镇区块的状态(是否已开启)
{
	static const Type kType = kGetTownBlocks;
};
typedef struct GetTownBlocks GetTownBlocks;

struct TownBlocks //s2c  城镇区块的状态(是否已开启)
{
	static const Type kType = kTownBlocks;
	uint8_t block_status[36]; //36个区块的开启状态，0表示未开启，非0表示已开启
};
typedef struct TownBlocks TownBlocks;

struct UnlockTownBlock //c2s 开启城镇的一个区块
{
	static const Type kType = kUnlockTownBlock;
	uint8_t block_index; //0-35
	uint8_t pay_type; //0银币 1金币
};
typedef struct UnlockTownBlock UnlockTownBlock;

struct UnlockTownBlockResult
{
	static const Type kType = kUnlockTownBlockResult;
	Result result;
	uint8_t block_index; //0-35
};
typedef struct UnlockTownBlockResult UnlockTownBlockResult;

struct GetTownProsperityDegree  //获取城镇的繁荣度，C2S
{ 
	static const Type kType = kGetTownProsperityDegree;
};
typedef struct GetTownProsperityDegree GetTownProsperityDegree;

struct TownProsperityDegree //获取城镇的繁荣度的返回值,或者是服务器主动推送的当前繁荣度值
{ 
	static const Type kType = kTownProsperityDegree;
	int32_t value; //繁荣度的值
};
typedef struct TownProsperityDegree TownProsperityDegree;


typedef struct _BuildingGot //获得了某种建筑物  s2c
{ 
	static const Type kType = kBuildingGot;
	TownItemID id;
	TownItemKind kind; //sid
}BuildingGot;

typedef struct _GetBuildingExpireTime
{ 
	static const Type kType = kGetBuildingExpireTime;
	TownItemID id;
}GetBuildingExpireTime;

typedef struct _GetBuildingExpireTimeResult
{ 
	static const Type kType = kGetBuildingExpireTimeResult;
	uint32_t time;
}GetBuildingExpireTimeResult;


//建筑的相关信息
struct GetCommercialBuildingInfo //C2S
{
	static const Type kType = kGetCommercialBuildingInfo;
};
typedef struct GetCommercialBuildingInfo GetCommercialBuildingInfo;

struct BuildingInfo
{
	uint32_t is_only_building_have;			//唯一建筑是否已经拥有(1:没拥有 0:拥有)
};
typedef struct  BuildingInfo BuildingInfo;

struct GetCommercialBuildingInfoResult //s2c
{
	static const Type kType = kGetCommercialBuildingInfoResult;
	Result result;
	uint32_t open_num; //开启个数
	BuildingInfo building_info[100];
};
typedef struct GetCommercialBuildingInfoResult GetCommercialBuildingInfoResult;

//融合升级
struct FusionUpgrade //c2s
{
	static const Type kType = kFusionUpgrade;
	uint32_t base_id;//需要升级的基础建筑建筑
	uint32_t upgrade_building_id;//升级后建筑id
	TownItemID id;
};
typedef struct FusionUpgrade FusionUpgrade;

struct FusionUpgradeResult //s2c
{
	static const Type kType = kFusionUpgradeResult;
	Result result;
	uint32_t is_success;//(1：成功 2：材料不足 3：数据错误 )
};
typedef struct FusionUpgradeResult FusionUpgradeResult;

//无中生有
struct OutOfNothing //c2s
{
	static const Type kType = kOutOfNothing;
	uint32_t base_id;//需要升级的基础建筑建筑
	uint32_t upgrade_building_id;//升级后建筑id
	TownItemID id;
};
typedef struct OutOfNothing OutOfNothing;

struct OutOfNothingResult //s2c
{
	static const Type kType = kOutOfNothingResult;
	Result result;
	uint32_t is_success;//(1：成功 2:金币不够 3:数据未知)
};
typedef struct OutOfNothingResult OutOfNothingResult;

