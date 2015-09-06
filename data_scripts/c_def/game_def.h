#pragma once
#pragma pack(4)
#include "define.h"


enum ResourceType {kGoldRsc=1, kSilverRsc=2, kEnergyRsc=3, kLordExpRsc=4, kPropRsc=5, kFeatRsc=6, kPrestigeRsc=7, kHeroExpRsc=8,
	kMobilityRsc=9, kRechargedGold=10, kTicketsRsc=11, kAlchemyRsc=12, kProsperityDegree=13, kActivityRsc=14, kPowerRsc=15, 
	kStaminaTakeRsc=16};
typedef enum ResourceType RewardType;
enum PropType{kPropEquipment=1, kPropMaterial, kPropContainer, kPropSystem,  kPropGem, kPropResource, kPropFormula, kPropPlaygroundFood, kPropPlaygroundAgent, kPropPlaygroundEgg };
enum HoleStatus{kHoleNone, kHoleDisable, kHoleEnable, kHoleInlayed};
enum HeroStatus{kHeroDisable, kHeroInGroup, kHeroDismissed};

struct Reward  //奖励
{
	uint16_t type;  // 上面的 RewardType
	uint16_t kind; //这个值只有道具（Prop）用得上
	uint32_t amount;
};
typedef struct Reward Reward;


enum GameMainType
{
	//9000
	//初始状态获取
	kGetPlayerBaseInfo = kGameMainTypeBegin+1,
	kGetMyProps = kGameMainTypeBegin+2,
	kGetMyEquipment = kGameMainTypeBegin+3,
	kGetMyHeros = kGameMainTypeBegin+4,
	kGetMyHeroEquipment = kGameMainTypeBegin+5,
	kGetMyFormulas = kGameMainTypeBegin+6,
	kGetMyHeroProperty = kGameMainTypeBegin+7,
	kGetSkillsLevel = kGameMainTypeBegin+8,
	kGetArraysLevel = kGameMainTypeBegin+9,


	//道具、装备与背包、仓库操作
	kMoveProp = kGameMainTypeBegin+101,
	kOverlapProp = kGameMainTypeBegin+102,
	kSellProp = kGameMainTypeBegin+103,
	kDropProp = kGameMainTypeBegin+104,
	kRearrangeProp = kGameMainTypeBegin+105,
	kBuyProp = kGameMainTypeBegin+106,
	kUseProp = kGameMainTypeBegin+107,
	kRenameEquipment = kGameMainTypeBegin+108,
	kUnlockPropGrid = kGameMainTypeBegin+109,
	kRepurchase = kGameMainTypeBegin+110,
	kEquipHero = kGameMainTypeBegin+111,
	kTakeOff = kGameMainTypeBegin+112,
	kStrengthen = kGameMainTypeBegin+113,
	kActiveHole = kGameMainTypeBegin+114,
	kInlay = kGameMainTypeBegin+115,
	kCompoundGem =kGameMainTypeBegin+116,
	kEquipmentPropertyMigrate = kGameMainTypeBegin+117,
	kEquipCompound = kGameMainTypeBegin+118,
	kBuyEquip2Hero = kGameMainTypeBegin+119,
	//	kPlayerGoldChanged = kGameMainTypeBegin+20,
	//	kPlayerSilverChanged = kGameMainTypeBegin+21,
	//	kPlayerEnergyChanged = kGameMainTypeBegin+22,
	//	kPlayerLordExpChanged = kGameMainTypeBegin+23,
	//	kPlayerPropChanged = kGameMainTypeBegin+27,

	//英雄
	kRecruitHero = kGameMainTypeBegin+201,
	kDismissHero = kGameMainTypeBegin+202,
	kGetHerosRecruitable = kGameMainTypeBegin+203,
	kChangeHeroArray = kGameMainTypeBegin+204,
	kChangeHeroLocation = kGameMainTypeBegin+205,
	kUpgradeSkill = kGameMainTypeBegin+206,
	kGetMyHeroDetail = kGameMainTypeBegin+207,
	kGetBringupProperty = kGameMainTypeBegin+208,
	kApplyBringup = kGameMainTypeBegin+209,
	kAcceptBringup = kGameMainTypeBegin+210,
	kGetHeroArray = kGameMainTypeBegin+218,

	//新添加英雄训练
	kGetTrainingNum = kGameMainTypeBegin + 219,
	kBuyTrainingNum = kGameMainTypeBegin + 220,
	kTraining = kGameMainTypeBegin + 221,
	
	//进化英雄
	kEvolveHero = kGameMainTypeBegin + 230,
	
	//推送训练次数                                                                                                                                                    
	kPushTrainNum = kSocietyTypeBegin + 510,
	//////////////////////////////////////////////////////////////////////////


	//////////////////////////////////////////////////////////////////////////
	kGameBaseInfo = kGameMainTypeBegin+800,
	kHero,
	kEquipment4Client,
	//通知
	kPropsAlteration,
	kResourceDelta,
	kUseProp4Container,
	//////////////////////////////////////////////////////////////////////////


	kGameOperationException = kGameMainTypeBegin+998, 
	kGameMainTypeEnd = kGameMainTypeBegin+999,

	/////////////////////////////////////////////////////////////////////////////下面是返回值
	//15000
	kPlayerBaseInfo = kGameReturnBegin+1,
	kMyProps = kGameReturnBegin+2,
	kMyEquipment = kGameReturnBegin+3,
	kMyHeros = kGameReturnBegin+4,
	kMyHeroEquipment = kGameReturnBegin+5,
	kMyFormulas = kGameReturnBegin+6,
	kMyHeroProperty = kGameReturnBegin+7,
	kSkillsLevel = kGameReturnBegin+8,
	kArraysLevel = kGameReturnBegin+9,

	kMovePropResult = kGameReturnBegin+101,
	kOverlapPropResult = kGameReturnBegin+102,
	kSellPropResult = kGameReturnBegin+103,
	kDropPropResult = kGameReturnBegin+104,
	kRearrangePropResult = kGameReturnBegin+105,
	kBuyPropResult = kGameReturnBegin+106,
	kUsePropResult = kGameReturnBegin+107,
	kRenameEquipmentResult = kGameReturnBegin+108,
	kUnlockPropGridResult = kGameReturnBegin+109,
	kRePurchaseResult = kGameReturnBegin+110,
	kEquipHeroResult = kGameReturnBegin+111,
	kTakeOffResult = kGameReturnBegin+112,
	kStrengthenResult = kGameReturnBegin+113,
	kActiveHoleResult = kGameReturnBegin+114,
	kInlayResult = kGameReturnBegin+115,
	kCompoundGemResult =kGameReturnBegin+116,
	kEquipmentPropertyMigrateResult = kGameReturnBegin+117,
	kEquipCompoundResult = kGameReturnBegin+118,
	kBuyEquip2HeroResult = kGameReturnBegin+119,

	kRecruitHeroResult = kGameReturnBegin+201,
	kDismissHeroResult = kGameReturnBegin+202,
	kGetHerosRecruitableResult = kGameReturnBegin+203,
	kChangeHeroArrayResult = kGameReturnBegin+204,
	kChangeHeroLocationResult = kGameReturnBegin+205,
	kUpgradeSkillResult = kGameReturnBegin+206,
	kHeroDetail = kGameReturnBegin+207,
	kBringupProperty = kGameReturnBegin+208,
	kApplyBringupResult = kGameReturnBegin+209,
	kAcceptBringupResult = kGameReturnBegin+210,
	kStartTrainResult = kGameReturnBegin+213,
	kGetHeroArrayResult = kGameReturnBegin+218,
	//新添加返回值
	kResultTrainingNum = kGameReturnBegin + 219,
	kResultBuyTrainingNum = kGameReturnBegin + 220,
	kTrainingResult = kGameReturnBegin + 221,
	
	
	kEvolveHeroResult = kGameReturnBegin + 230,

	kHeroLevelUp = kGameReturnBegin+ 501,
};

struct GameOperationException //操作发生异常时返回，主要作调试用
{
	static const Type kType = kGameOperationException;
	int16_t operation_type;
	StringLength len;
	char error[2048];
};
typedef struct GameOperationException GameOperationException;

struct GameBaseInfo
{
	static const Type kType = kGameBaseInfo;
	UserID uid;
	int32_t gold; //代币
	double silver; //游戏币
	int32_t feat; //功绩
	int32_t prestige; //威望
	int16_t energy; //能量，活力
	int16_t mobility; //行动力
	int32_t lord_experience; //exp
	int16_t level;  //等级
	int16_t progress; //主线进度，关卡sid
	uint8_t country;
	uint8_t array; //阵形
	uint16_t vip;//玩家VIP等级
	uint32_t recharged_gold; //充值金币
	uint32_t guild_id;	//公会ID
	uint32_t power;//战斗力
};
typedef struct GameBaseInfo GameBaseInfo;

struct GetPlayerBaseInfo
{
	static const Type kType = kGetPlayerBaseInfo;
	UserID uid;
};
typedef struct GetPlayerBaseInfo GetPlayerBaseInfo;

struct PlayerBaseInfo
{
	static const Type kType = kPlayerBaseInfo;
	Role role;
	GameBaseInfo game_info;
};
typedef struct PlayerBaseInfo PlayerBaseInfo;

typedef int8_t HeroSid;

struct Bringup
{
	uint16_t strength;				//培养属性
	uint16_t agility;
	uint16_t intelligence;
};
typedef struct Bringup Bringup;

struct BringupBin
{
	uint16_t strength;				//原始属性
	uint16_t agility;
	uint16_t intelligence;
	uint16_t changes_strength;		//培养的值
	uint16_t changes_agility;
	uint16_t changes_intelligence;
};
typedef struct BringupBin BringupBin;

struct Hero // (从数据库推送过来的结构)
{
	static const Type kType = kHero;
	HeroSid id;
	int8_t status; //1在队伍中 
	uint8_t level;
	int8_t location; //在阵形中的位置
	int32_t exp;
	int32_t hp;
	BringupBin bringup_bin;		//培养的值
};
typedef struct Hero Hero;

struct HeroProperty
{
	HeroSid id;
	int8_t status; //1在队伍中 
	uint8_t level;
	int8_t location; //在阵形中的位置
	int32_t exp;
	int32_t hp;
	uint16_t strength;	//原始属性
	uint16_t agility;
	uint16_t intelligence;
	uint16_t speed;
	uint32_t power;//战斗力
};
typedef struct HeroProperty HeroProperty;
/*
*/

typedef uint32_t PropID;
typedef uint16_t PropSid;

#pragma pack(1)
struct Prop4Client //道具
{
	PropID id;
	PropSid kind;
	uint8_t location; //位置，定义在上面的enum PropLocation中
	uint8_t amount;
	uint8_t bind;//是否已经绑定
	uint8_t unused1;
	uint16_t unuesd2;
};
#pragma pack()
typedef struct Prop4Client Prop4Client;


struct Equipment4Client //装备
{
	static const Type kType = kEquipment4Client;
	uint8_t level;
	uint8_t base_strength;
	uint8_t base_agility;
	uint8_t base_intelligence;
	int8_t holes[3]; //0=无孔 1=有孔未激活 2=已激活未镶嵌 3=已镶嵌
	bool unused; //
	PropSid gems[3]; //3个位置镶嵌的宝石 
};
typedef struct Equipment4Client Equipment4Client;


enum PropArea{kAreaBag=1, kAreaWarehouse=2, kAreaHero=3, kAreaSold=4, kAreaGem=5, kAreaAuction=6, kAreaMail=7};

struct GetMyProps // c2s, 获取所有的道具基本信息，包括装备
{
	static const Type kType = kGetMyProps;
	int8_t area; //1=背包，2=仓库, 3=装备区 4=回购区 5=宝石区
};
typedef struct GetMyProps GetMyProps;

struct MyProps //s2c, 上面消息的返回，  所有的装备
{
	static const Type kType = kMyProps;
	int16_t grids_count; //格子一共有多少个可用
	int16_t count; //注意这里是2个字节
	Prop4Client props[256]; //实际有效数量由count决定
};
typedef struct MyProps MyProps;

struct GetMyEquipment //c2s,获取某个装备的详情 
{
	static const Type kType = kGetMyEquipment;
	PropID id; //道具id
};
typedef struct GetMyEquipment GetMyEquipment;

struct MyEquipment //s2c ,上面消息的返回
{
	static const Type kType = kMyEquipment;
	Equipment4Client equipment;
};
typedef struct MyEquipment MyEquipment;

struct Prop4Container
{
	PropSid kind;
	uint16_t amount;
};
typedef struct Prop4Container Prop4Container;

struct UseProp4Container
{
	static const Type kType = kUseProp4Container;
	uint32_t amount;
	Prop4Container props[12];
};
typedef struct UseProp4Container UseProp4Container;


struct GetMyHeros
{
	static const Type kType = kGetMyHeros;
};
typedef struct GetMyHeros GetMyHeros;

struct MyHeros
{
	static const Type kType = kMyHeros;
	int32_t count;
	HeroSid heros[200];
};
typedef struct MyHeros MyHeros;

struct GetMyHeroProperty
{
	static const Type kType = kGetMyHeroProperty;
	HeroSid id;
};
typedef struct GetMyHeroProperty GetMyHeroProperty;

struct MyHeroProperty	
{
	static const Type kType = kMyHeroProperty;
	HeroProperty hero;
};
typedef struct MyHeroProperty MyHeroProperty;


//培养//////////////////////////////////////////////////////////////
struct GetBringupProperty		//c2s 请求返回英雄培养属性
{
	static const Type kType = kGetBringupProperty;
	HeroSid id;
};
typedef struct GetBringupProperty GetBringupProperty;

struct BringupProperty			//s2c 返回培养属性
{
	static const Type kType = kBringupProperty;
	Bringup cur;				//当前培养值
	Bringup max;				//培养上限
	uint16_t no_saved;			//上次是否保存	1-未保存 0-已保存
	Bringup changes;			//上次培养的值（未保存的培养值）
};
typedef struct BringupProperty BringupProperty;

struct ApplyBringup				//c2s 培养
{
	static const Type kType = kApplyBringup;
	HeroSid id;
	uint8_t type;				//1-普通培养 2-金币培养 3-黄金培养 4-白金培养
};
typedef struct ApplyBringup ApplyBringup;

struct ApplyBringupResult		//s2c
{
	static const Type kType = kApplyBringupResult;
	Bringup bringup;			//培养的值（未保存的值）
};
typedef struct ApplyBringupResult ApplyBringupResult;

struct AcceptBringup			//c2s 保存培养的值
{
	static const Type kType = kAcceptBringup;
	HeroSid id;
	uint8_t type;				//1-保存 2-放弃
};
typedef struct AcceptBringup AcceptBringup;

struct AcceptBringupResult		//s2c
{
	static const Type kType = kAcceptBringupResult;
	Result result;
};
typedef struct AcceptBringupResult AcceptBringupResult;

struct GetMyHeroEquipment
{
	static const Type kType = kGetMyHeroEquipment;
	HeroSid hero_id;
};
typedef struct GetMyHeroEquipment GetMyHeroEquipment;

struct MyHeroEquipment
{
	static const Type kType = kMyHeroEquipment;
	int32_t count;
	Prop4Client equipments[8];
};
typedef struct MyHeroEquipment MyHeroEquipment;

struct GetMyFormulas //获取合成配方
{
	static const Type kType = kGetMyFormulas;
};
typedef struct GetMyFormulas GetMyFormulas;

struct MyFormulas //合成配方
{
	static const Type kType = kMyFormulas;
	enum {MAX_COUNT=300};
	uint16_t count;
	uint16_t kinds[MAX_COUNT]; //配方的sid
};
typedef struct MyFormulas MyFormulas;

//////////////////////////////////////////////////////////////////////////////////////////

struct GetSkillsLevel //获取技能的等级
{ 
	static const Type kType = kGetSkillsLevel;
};
typedef struct GetSkillsLevel GetSkillsLevel;

struct SkillLevel
{
	uint8_t sid;
	uint8_t level;
};
typedef struct SkillLevel SkillLevel;

struct SkillsLevel  //GetSkillsLevel的返回
{ 
	static const Type kType = kSkillsLevel;
	uint16_t count;
	SkillLevel values[128];
};
typedef struct SkillsLevel SkillsLevel;

//////////////////////////////////////////////////////////////////////////////////////////

struct UpgradeSkill //升级科技
{ 
	static const Type kType = kUpgradeSkill;
	uint8_t sid;
};
typedef struct UpgradeSkill UpgradeSkill;

struct UpgradeSkillResult
{ 
	static const Type kType = kUpgradeSkillResult;
	Result result;
};
typedef struct UpgradeSkillResult UpgradeSkillResult;

//////////////////////////////////////////////////////////////////////////////////////////

struct GetArraysLevel //获取阵形的等级
{ 
	static const Type kType = kGetArraysLevel;
};
typedef struct GetArraysLevel GetArraysLevel;

struct ArraysLevel  //GetArrayLevel的返回
{ 
	static const Type kType = kArraysLevel;
	uint16_t count;
	SkillLevel values[32];
};
typedef struct ArraysLevel ArraysLevel;


//////////////////////////////////////////////////////////////////////////////////////////






struct MoveProp //在背包、仓库内部或二者之间移动道具
{
	static const Type kType = kMoveProp;
	PropID id;
	int8_t new_area; //1=背包，2=仓库
	uint8_t new_location; //新的位置 
};
typedef struct MoveProp MoveProp;

struct MovePropResult
{
	static const Type kType = kMovePropResult;
	Result result;
};
typedef struct MovePropResult MovePropResult;

struct OverlapProp //堆叠道具
{
	static const Type kType = kOverlapProp;
	PropID a; //把a叠到b上
	PropID b;
};
typedef struct OverlapProp OverlapProp;

struct OverlapPropResult 
{
	static const Type kType = kOverlapPropResult;
	Result result;
	uint8_t a_amount;
	uint8_t b_amount;
};
typedef struct OverlapPropResult OverlapPropResult;

struct SellProp //出售
{
	static const Type kType = kSellProp;
	PropID id;
};
typedef struct SellProp SellProp;

struct SellPropResult
{
	static const Type kType = kSellPropResult;
	Result result;
	int32_t price;
};
typedef struct SellPropResult SellPropResult;

struct DropProp //丢弃
{
	static const Type kType = kDropProp;
	PropID id;
};
typedef struct DropProp DropProp;

struct DropPropResult
{
	static const Type kType = kDropPropResult;
	Result result;
};
typedef struct DropPropResult DropPropResult;

struct RearrangeProp //整理
{
	static const Type kType = kRearrangeProp;
	int8_t area;
};
typedef struct RearrangeProp RearrangeProp;

struct RearrangePropResult
{
	static const Type kType = kRearrangePropResult;
	Result result;
};
typedef struct RearrangePropResult RearrangePropResult;

struct BuyProp //购买
{
	static const Type kType = kBuyProp;
	uint8_t shop;
	uint8_t prop_index;
	uint8_t location; //放到背包中的位置
};
typedef struct BuyProp BuyProp;

struct BuyPropResult
{
	static const Type kType = kBuyPropResult;
	Result result;
	PropID id;
};
typedef struct BuyPropResult BuyPropResult;

struct UseProp //使用
{
	static const Type kType = kUseProp;
	PropID id;
	uint8_t amount;
};
typedef struct UseProp UseProp;

struct UsePropResult
{
	static const Type kType = kUsePropResult;
	Result result;
};
typedef struct UsePropResult UsePropResult;

struct RenameEquipment //重命名装备
{
	static const Type kType = kRenameEquipment;
	PropID id;
	StringLength len;
	char name[24];
};
typedef struct RenameEquipment RenameEquipment;

struct RenameEquipmentResult
{
	static const Type kType = kRenameEquipmentResult;
	Result result;
};
typedef struct  RenameEquipmentResult RenameEquipmentResult;

struct  UnlockPropGrid //开格子
{
	static const Type kType = kUnlockPropGrid;
	int8_t area;
	uint8_t count;
};
typedef struct UnlockPropGrid UnlockPropGrid;

struct UnlockPropGridResult
{
	static const Type kType = kUnlockPropGridResult;
	Result result;
};
typedef struct UnlockPropGridResult UnlockPropGridResult;

struct Repurchase //回购卖出的道具
{
	static const Type kType = kRepurchase;
	PropID id;
	uint8_t location; //放到背包中的位置
};
typedef struct Repurchase Repurchase;

struct RepurchaseResult
{
	static const Type kType = kRePurchaseResult;
	Result result;
};
typedef struct RepurchaseResult RepurchaseResult;

enum EquipmentLocation 
{
	klHat=0,		//头盔
	klFrock=1,	//衣服
	klMantle=2,		//披风
	klMainHand=3,		//主手
	klJewelry=4,		//首饰
	klTrousers=5,		//裤子
	klShoes=6,		//鞋子
	klDeputyHand=7,		//副手
};

struct BuyEquip2Hero
{
	static const Type kType = kBuyEquip2Hero;
	uint8_t shop;
	uint8_t prop_index;
	HeroSid hero_id;
	uint8_t location; //英雄的装备面板上的位置 EquipmentLocation
};
typedef struct BuyEquip2Hero BuyEquip2Hero;

struct BuyEquip2HeroResult
{
	static const Type kType = kBuyEquip2HeroResult;
	Result result;
	PropID id;
};
typedef struct BuyEquip2HeroResult BuyEquip2HeroResult;

struct EquipHero //放装备到英雄上
{
	static const Type kType = kEquipHero;
	PropID prop;
	HeroSid hero;
	uint8_t location; //英雄的装备面板上的位置 EquipmentLocation
};
typedef struct EquipHero EquipHero;

struct EquipHeroResult
{
	static const Type kType = kEquipHeroResult;
	Result result;
};
typedef struct EquipHeroResult EquipHeroResult;

struct TakeOff //脱下英雄的装备
{
	static const Type kType = kTakeOff;
	PropID prop;
	HeroSid hero;
	uint8_t location; //背包里的位置
};
typedef struct TakeOff TakeOff;

struct TakeOffResult
{
	static const Type kType = kTakeOffResult;
	Result result;
};
typedef struct TakeOffResult TakeOffResult;

struct Strengthen //c2s 强化
{
	static const Type kType = kStrengthen;
	PropID id;
};
typedef struct Strengthen Strengthen;

struct StrengthenResult //s2c
{
	static const Type kType = kStrengthenResult;
	Result result;
};
typedef struct StrengthenResult StrengthenResult;

struct  ActiveHole //c2s 激活装备的孔
{
	static const Type kType = kActiveHole;
	PropID id;
	uint32_t hole;//0,1,2孔的索引
};
typedef struct ActiveHole ActiveHole;

struct ActiveHoleResult //s2c 
{
	static const Type kType = kActiveHoleResult;
	Result result;
};
typedef struct ActiveHoleResult ActiveHoleResult;

struct Inlay //c2s 镶嵌宝石
{
	static const Type kType = kInlay;
	PropID equipment;
	PropID inlay_gem;		//将哪个宝石嵌入
	PropID dis_gem;			//拆下的宝石叠加在哪个宝石上
	uint8_t hole; //0,1,2   孔的索引
	uint8_t b_inlay;	//嵌入(1)	卸下(0)
};
typedef struct Inlay Inlay;

struct InlayResult //s2c
{
	static const Type kType = kInlayResult;
	Result result;
};
typedef struct InlayResult InlayResult;

struct CompoundGem //合成宝石kAreaGem
{
	static const Type kType = kCompoundGem;
	uint16_t formula_kind; //配方sid
	uint16_t b_direct;		//是否一键合成
};
typedef struct CompoundGem CompoundGem;

struct CompoundGemResult
{
	static const Type kType = kCompoundGemResult;
	Result result;
	PropSid gem; //得到的宝石种类
	uint8_t amount; //宝石的数量
};
typedef struct CompoundGemResult CompoundGemResult;

struct EquipmentPropertyMigrate //装备属性转移（力量、敏捷、智力），source到dest
{ 
	static const Type kType = kEquipmentPropertyMigrate;
	PropID source;  
	PropID dest;
};
typedef struct EquipmentPropertyMigrate EquipmentPropertyMigrate;

struct EquipmentPropertyMigrateResult
{ 
	static const Type kType = kEquipmentPropertyMigrateResult;
	Result result;
};
typedef struct EquipmentPropertyMigrateResult EquipmentPropertyMigrateResult;

struct EquipCompound
{
	static const Type kType = kEquipCompound;
	PropID	 equip_id;			//即将销毁的装备id
	uint16_t b_reserved;		//是否保留宝石和洞洞
	uint16_t b_direct;			//是否直接制作装备
};
typedef struct EquipCompound EquipCompound;

struct EquipCompoundResult
{
	static const Type kType = kEquipCompoundResult;
	Result result;
	PropID equip_id;		//制造的装备id
};
typedef struct EquipCompoundResult EquipCompoundResult;












/////////////////////////////////////////////英雄

struct RecruitHero //招募
{
	static const Type kType = kRecruitHero;
	HeroSid hero;
};
typedef struct RecruitHero RecruitHero;

struct RecruitHeroResult
{
	static const Type kType = kRecruitHeroResult;
	Result result;
};
typedef struct RecruitHeroResult RecruitHeroResult;

struct DismissHero //解雇
{
	static const Type kType = kDismissHero;
	HeroSid hero;
};
typedef struct DismissHero DismissHero;


struct DismissHeroResult
{
	static const Type kType = kDismissHeroResult;
	Result result;
};
typedef struct DismissHeroResult DismissHeroResult;

struct GetHerosRecruitable //获取可招募的英雄
{
	static const Type kType = kGetHerosRecruitable;
};
typedef struct GetHerosRecruitable GetHerosRecruitable;

struct GetHerosRecruitableResult
{
	static const Type kType = kGetHerosRecruitableResult;
	uint16_t count;
	struct 
	{
		HeroSid hero;
		bool dismissed;
	}heros[127];
};
typedef struct GetHerosRecruitableResult GetHerosRecruitableResult;

struct ChangeHeroArray //改变阵形
{ 
	static const Type kType = kChangeHeroArray;
	int16_t array_id;
};
typedef struct ChangeHeroArray ChangeHeroArray;

struct ChangeHeroArrayResult
{ 
	static const Type kType = kChangeHeroArrayResult;
	Result result;
};
typedef struct ChangeHeroArrayResult ChangeHeroArrayResult;


struct GetHeroArray //获取阵形
{ 
	static const Type kType = kGetHeroArray;
	int16_t array_id;
};
typedef struct GetHeroArray GetHeroArray;
struct GetHeroArrayResult
{ 
	static const Type kType = kGetHeroArrayResult;
	Result result;
	struct 
	{
		uint8_t id;//0代表不存在
		int8_t location;
	}heros[5];
};
typedef struct GetHeroArrayResult GetHeroArrayResult;


struct ChangeHeroLocation //改变英雄在阵形中的位置
{ 
	static const Type kType = kChangeHeroLocation;
	HeroSid hero;
	int8_t location;  //0表示离阵
	int16_t array_id; //阵形ID
};
typedef struct ChangeHeroLocation ChangeHeroLocation;

struct ChangeHeroLocationResult
{ 
	static const Type kType = kChangeHeroLocationResult;
	Result result;
};
typedef struct ChangeHeroLocationResult ChangeHeroLocationResult;

struct GetMyHeroDetail  //获取英雄的详细信息
{ 
	static const Type kType = kGetMyHeroDetail;
	HeroSid hero;
};
typedef struct GetMyHeroDetail GetMyHeroDetail;

struct HeroDetail //
{ 
	static const Type kType = kHeroDetail;
	int32_t		hp;
	uint16_t		strength;
	uint16_t		agility;
	uint16_t		intelligence;
	uint16_t		speed;

	int32_t		physical_attack_min;
	int32_t		physical_attack_max;
	int32_t		physical_defense;
	int32_t		magical_attack_min;
	int32_t		magical_attack_max;
	int32_t		magical_defense;
	int32_t		real_damage;

	double	hit;
	double	dodge; 
	double	dodge_reduce;
	double	resistance;
	double	magical_accurate;
	double	block;
	double	block_damage_reduction;
	double	parry;
	double	counterattack;
	double	counterattack_damage;
	double	crit;
	double	toughness;
	double	crit_damage;
	double	dizziness_resistance;
	double	sleep_resistance;
	double	paralysis_resistance;
	double	charm_resistance;
	double	silence_resistance;
	double	detained_resistance;
	double	ridicule_resistance;

	double	plain;
	double	mountain;
	double	forest;
	double	lake;
	double coastal;
	double	cave;
	double	wasteland;
	double	citadel;
	double	sunny;
	double	rain;
	double	cloudy;
	double	snow;
	double	fog;
};
typedef struct HeroDetail HeroDetail;


enum AlterationType{kAlterationAdd=1, kAlterationRemove, kAlterationUpdate, kAlterationMove};

#pragma pack(1)
struct PropAlteration
{
	PropID  id;
	PropSid kind;
	int16_t hero_id;
	int8_t  area;
	uint8_t location;
	uint8_t amount;
	uint8_t bind;//是否已经绑定
	uint8_t type; // 1增加 2删除 3改变数量 4移动位置
	uint8_t unused1;
	uint16_t unused2;
};
#pragma pack()
typedef struct PropAlteration PropAlteration;

struct PropsAlteration //道具的变更，服务端主动通知
{ 
	static const Type kType = kPropsAlteration;
	uint32_t amount;
	PropAlteration alters[256];
};
typedef struct PropsAlteration PropsAlteration;



struct ResourceDelta //资源的变更，类型定义在ResourceType中
{ 
	static const Type kType = kResourceDelta;
	double value; //绝对值
	int32_t delta; //变化值
	int8_t type;    //enum ResourceType
};
typedef struct ResourceDelta ResourceDelta;

enum TrainResultType
{
	trainResultBegin = 14400,
	TRAIN_VIP_ERROR = trainResultBegin + 1,	//不是VIP
	TRAIN_GOLD_ERROR = trainResultBegin + 2,//金币不够
	TRAIN_BUY_ERROR = trainResultBegin + 3,//购买次数达到最大值
	TRAIN_LEL_ERROR = trainResultBegin + 4,//英雄不能大于玩家或者训练场等级
	TRAIN_NUM_ERROR = trainResultBegin + 5,//训练次数达到上限
	TRAIN_MSG_ERROR = trainResultBegin + 6,      //传入数据错误
	TRAIN_SILVER_ERROR = trainResultBegin + 7,//银币不够
	TRAIN_VIP_LEL_ERROR = trainResultBegin + 8,//VIP等级不够
};

struct GetTrainingNum//获取训练的次数 c2s
{
	static const Type kType  = kGetTrainingNum;
};
typedef struct  GetTrainingNum GetTrainingNum;

struct GetTrainStatusResult//返回训练的状态 s2c
{
	static const Type kType = kResultTrainingNum;
	Result result;
	uint32_t available_train_count; //可训练次数
	uint32_t max_available_train_count;//最大训练次数
	uint32_t cooldown_seconds; //下次训练+1的冷却时间(秒)
	uint32_t used_buy_count;   //已购买次数
	uint32_t remain_buy_count; //剩余购买次数
};
typedef struct GetTrainStatusResult GetTrainStatusResult;

struct PushTrainNum //s2c 推送可以训练的次数,
{
	static const Type kType = kPushTrainNum;
	uint32_t available_train_count; //可使用的训练次数
	uint32_t max_available_train_count;//最大训练次数
	uint32_t used_buy_count;   //已购买次数
	uint32_t remain_buy_count; //剩余购买次数
};
typedef struct PushTrainNum PushTrainNum;

struct BuyTrainingNum//VIP购买训练次数 c2s
{
	static const Type kType  = kBuyTrainingNum;
};
typedef struct  BuyTrainingNum BuyTrainingNum;

struct ResultBuyTrainingNum //VIP购买训练次数 s2c
{
	static const Type kType = kResultBuyTrainingNum;
	Result result;
	uint32_t is_buy_sucess;   //购买是否成功 0 失败 1 成功
	uint32_t available_train_count;   //训练次数; 
};
typedef struct ResultBuyTrainingNum ResultBuyTrainingNum;

struct Training//训练类型 c2s
{
	static const Type kType = kTraining;
	uint32_t type;//1 普通训练 2 金币训练 3 强化训练
	uint32_t id;
};
typedef struct Training Training;

struct TrainResult //获取经验数据 s2c
{
	static const Type kType = kTrainingResult;
	Result result;
	bool is_training_sucess;// 金币训练  强化训练 训练次数是否用完(0:失败 1：成功)
	uint8_t unuse1;
	uint8_t unuse2;
	uint8_t unuse3;
	uint32_t experience_num; //经验值
	uint32_t remain_available_train_count;   //剩余训练次数
	bool is_crit; //暴击是否成功 (0失败 1成功)
};
typedef struct TrainResult TrainResult;

typedef struct _HeroLevelUp
{ 
	static const Type kType = kHeroLevelUp;
	uint32_t exp;
	HeroSid hero;
	uint8_t level;
}HeroLevelUp;

// 进化英雄

struct EvolveHero
{
	static const Type kType = kEvolveHero;
	uint16_t hero;      //英雄SID
	uint16_t use_vip;   //使用VIP特权直接进化
};
typedef struct EvolveHero EvolveHero;

struct EvolveHeroResult
{
	static const Type kType = kEvolveHeroResult;
	Result result;
	uint16_t hero;       // 新英雄SID
};
typedef struct EvolveHeroResult EvolveHeroResult;



#pragma pack()

