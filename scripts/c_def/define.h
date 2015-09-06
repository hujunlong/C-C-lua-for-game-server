#pragma once

#include <stdint.h>
#include <stddef.h>

typedef int16_t Type;

typedef int32_t UserID;
typedef int16_t GroupID;
typedef uint16_t StringLength;

static const uint32_t kMaxProtocolLength = 15*1024;



//Type ID 范围分配
enum
{
	kPlayGroundBegin = 7000,
	kDataGetTypeBegin = 8000,
	kGameMainTypeBegin = 9000,
	kTownTypeBegin = 10000,
	kMapTypeBegin = 11000,
	kPVPTypeBegin = 12000,
	kMiscTypeBegin = 13000,
	kSocietyTypeBegin = 14000,



	kGameReturnBegin = 15000,
	kTownReturnBegin = kGameReturnBegin + 1000, 
	kMapResultBegin = kGameReturnBegin + 2000, 
	kPVPReturnBegin = kGameReturnBegin + 3000,
	kMiscReturnBegin = kGameReturnBegin + 4000,
	kSocietyReturnBegin = kGameReturnBegin + 5000,
	kPlayGroundReturnBegin = kGameReturnBegin + 6000,


	kDataGetTypeReturnBegin = kGameReturnBegin+13000,

	kBroadcastTypeBegin=29000,
	kBroadcastTypeEnd = 29999,

	kInternalStart = 30000,

};

enum 
{
	kMaxFightRecordLength = 11*1024,
};


struct Nickname
{
	StringLength len;
	char str[18];
};
typedef struct Nickname Nickname;

struct Role
{
	enum  Sex {kMale=0, kFemale=1};
	enum  OnlineStatus {kOnline=0, kOffline=1};

	UserID uid;
	Nickname nickname;
	int16_t sex;
	int16_t online;
};
typedef struct Role Role;

struct DragonName
{
	StringLength len;
	char		 str[22];		//7个汉字
};
typedef struct DragonName DragonName;

typedef int32_t Result; 

enum GameResult
{
	eSucceeded=0,
	eInvalidValue=1, //非法的值
	eLackResource=2, //资源不足，广义的资源，包括货币、精力、道具、装备等等
	eOccupy=3, //位置被占用
	eWaitCooldown=4, //CD未到
	eInvalidOperation=5, //操作无效
	eLowLevel=6, //等级不足
	eLowHeroLevel=7, //英雄等级不够
	eSectionDisable=8, //关卡未开启
	eSectionNotPassed=9, //关卡尚未通过
	eFightFailed=10,
	eGroupFull=11, //队列已满
	eNotNearByRoad=12, //商业建筑没有在路边
	eBagFull=13, //背包满了
	eBagLeackSpace=14, //背包空间不多了
	eFunctionDisable=15, //功能未开启
	eNotMatchDepend=16, //依存关系不满足
	eLowCityHallLevel=17, //市政厅等级不够
	eLowVipLevel=18,//VIP等级不够
	eWarehouseFull=19, //仓库满了
	eBuildingIsUnique=20, //建筑是唯一的，不能多建

	eAddFriendNotExist=50,
	eAddFriendIsSelf,
	eAddFriendExist,
	eAddFoeNotExist,
	eAddFoeIsSelf,
	eAddFoeExist,
	eAddFriendMax,//好友上限
	eAddFoeMax,	//黑名单已达上限
	eWhisperNotOnline,//私聊对象不在线
	eNotJoinGuild,	//没有加入工会

	eNotDoWithSelf=96,	//不能为自已
	eUserNotExist=97,
	eCantSpeakNow=98,	//当前还不能发言

	eReceiverNotExist=100,
	eReceiverIsSelf,//接收者为自已
	eGetMailNotExist,//此邮件不存在
	eGetMailsListFailed,
	eGetMailFailed,//
	eDeleteMailFailed,
	eCantSendToFoe,//不能向黑名单发送
	eMailsOverFlowWithAttach,//带附件的邮件已经100封
	eExtractAttachmentFailed,//提取附件失败
	eAttachmentHadExtracted,//附件已经被提取过了
	eAttachmentDontExist,	//不存在附件
	
}; 
