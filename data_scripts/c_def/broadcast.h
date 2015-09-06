#pragma once
#include "define.h"
#include "game_def.h"

enum 
{
	kGenericNotify = kBroadcastTypeBegin+1,
	kWorldBossPrepare = kBroadcastTypeBegin + 2,
	kWorldBossBegin = kBroadcastTypeBegin + 3,
	kWorldBossEnd = kBroadcastTypeBegin + 4,
	kWorldBossDead = kBroadcastTypeBegin + 5,
	kWorldBossFinalReward = kBroadcastTypeBegin + 6,
	kArenaReward = kBroadcastTypeBegin + 7,
	kNextDayOpen = kBroadcastTypeBegin + 8,
	kSystemMsg = kBroadcastTypeBegin + 9,
	kResetStamina = kBroadcastTypeBegin + 10,
	kTurntableMaxReward = kBroadcastTypeBegin + 11,
	kSectionRewardGot = kBroadcastTypeBegin + 12,
	kBossSectionPassed = kBroadcastTypeBegin + 13,
	kArenaWinner = kBroadcastTypeBegin + 14,
	kArenaTop = kBroadcastTypeBegin + 15,
	kGetRune = kBroadcastTypeBegin + 16,
	kWorldWarNotify = kBroadcastTypeBegin + 17,
	kStrengthenProp = kBroadcastTypeBegin + 18,
	kFishSomething = kBroadcastTypeBegin + 19,
	kHeroRecruited = kBroadcastTypeBegin + 20,
	kAchievementFirstAccomplish = kBroadcastTypeBegin + 21,
	kSystemNotice = kBroadcastTypeBegin + 22,
	KUpdateWorship = kBroadcastTypeBegin + 23,
	kPickTheSeed = kBroadcastTypeBegin + 24,
	kTowerNotify = kBroadcastTypeBegin + 25,
};

struct GenericNotify
{ 
	static const Type kType = kGenericNotify;
	int16_t len;
	uint8_t data[256-sizeof(int16_t)]; //压缩的字符串
};
typedef struct GenericNotify GenericNotify;

struct WorldBossPrepare // 做好挑战BOSS准备
{ 
    static const Type kType = kWorldBossPrepare;
};
typedef struct WorldBossPrepare WorldBossPrepare;

struct WorldBossBegin // BOSS可以挑战
{ 
    static const Type kType = kWorldBossBegin;
};
typedef struct WorldBossBegin WorldBossBegin;

struct WorldBossEnd // BOSS挑战结束【时间到】
{ 
    static const Type kType = kWorldBossEnd;
};
typedef struct WorldBossEnd WorldBossEnd;

struct WorldBossDead // BOSS挑战结束【死亡】
{ 
    static const Type kType = kWorldBossDead;
};
typedef struct WorldBossDead WorldBossDead;

struct WorldBossRewardInfo
{
    Nickname nickname;      // 玩家昵称
    UserID uid;
    uint32_t hurt;          // 对BOSS造成的总伤害
    uint32_t silver;        // 获得银币
};
typedef struct WorldBossRewardInfo WorldBossRewardInfo;

struct WorldBossFinalReward // BOSS发奖排行榜
{ 
    static const Type kType = kWorldBossFinalReward;
    uint32_t life;                  // BOSS总血量
    uint8_t killer;                 // 0没有最后一击 1有最后一击
    uint8_t sid;                    // 世界BOSS的SID
    uint16_t count;                 // 上榜人数(不包括最后一击)
    WorldBossRewardInfo list[4];    // [0]存放最后一击奖励，[1][2][3]存放1、2、3名
};
typedef struct WorldBossFinalReward WorldBossFinalReward;

struct ArenaReward // 竞技场发奖
{ 
    static const Type kType = kArenaReward;
};
typedef struct ArenaReward ArenaReward;


struct NextDayOpen // 第二天到了
{ 
    static const Type kType = kNextDayOpen;
};
typedef struct NextDayOpen NextDayOpen;

struct SystemMsg//系统
{
	static const Type kType = kSystemMsg;
	StringLength msg_len;
	char msg[513];
};
typedef struct SystemMsg SystemMsg;

struct ResetStamina
{
	static const Type kType = kResetStamina;
};
typedef struct ResetStamina ResetStamina;

struct TurntableMaxReward
{
	static const Type kType = kTurntableMaxReward;
	UserID uid;
	Nickname name;
};
typedef struct TurntableMaxReward TurntableMaxReward;

typedef struct _SectionRewardGot
{ 
	static const Type kType = kSectionRewardGot;
	UserID uid;
	Nickname name;
	Reward rwd;
	uint16_t section_index;
}SectionRewardGot;

typedef struct _BossSectionPassed
{ 
	static const Type kType = kBossSectionPassed;
	UserID uid;
	Nickname name;
	uint16_t section_index;
}BossSectionPassed;


typedef struct ArenaWinner  // 竞技场连胜
{ 
	static const Type kType = kArenaWinner;
	Nickname name;
    UserID uid;
	uint32_t count; // 次数
}ArenaWinner;

typedef struct ArenaTop  // 竞技场名次
{ 
	static const Type kType = kArenaTop;
	Nickname winner; /* winner打败了loser 获得了第X名 */
	Nickname loser;
    UserID uid1;
    UserID uid2;
	uint32_t rank; // 排名
}ArenaTop;

typedef struct GetRune  // 获得符文
{ 
	static const Type kType = kGetRune;
	Nickname name;
    UserID uid;
	uint32_t rune; // 符文SID
}GetRune;

typedef struct WorldWarNotify  // 国战通知
{ 
    static const Type kType = kWorldWarNotify;
    uint8_t attack;         // 攻击方国家
    uint8_t defend;         // 防守方国家
    uint8_t map;            // 地图ID
    uint8_t type;           // 发生事件，0投票完成，1进攻完成，2防守完成
}WorldWarNotify;

typedef struct _StrengthenProp
{
	static const Type kType = kStrengthenProp;
	UserID uid;
	Nickname name;
	uint8_t  level;	//装备等级
}StrengthenProp;

typedef struct _HeroRecruited   //某玩家招募了某英雄
{ 
	static const Type kType = kHeroRecruited;
	UserID uid;
	Nickname name;
	HeroSid hero;
}HeroRecruited;

typedef struct _AchievementFirstAccomplish //某成就被某玩家在全服第一次完成
{ 
	static const Type kType = kAchievementFirstAccomplish;
	UserID uid;
	Nickname name;
	uint32_t achievement_id;
}AchievementFirstAccomplish;

typedef struct _SystemNotice	//系统公告
{
	static const Type kType = kSystemNotice;
	uint16_t	 type;				//公告类型	{跑马灯1,聊天框2,同时3}
	StringLength len;				//公告长度
	char		 notice[1024];		//公告内容
}SystemNotice;

struct UpdateWorship
{
	static const Type kType = KUpdateWorship;

};
typedef struct UpdateWorship UpdateWorship;

typedef struct _BC_PickTheSeed
{
	static const Type kType = kPickTheSeed;
	UserID uid;
	Nickname name;
	uint16_t kind;		//种子sid
}BC_PickTheSeed;

typedef struct _BC_FishTheFish
{
	static const Type kType = kFishSomething;
	UserID uid;
	Nickname name;
	uint32_t kind;		//sid
	uint32_t amount;	//得到奖励数量(只有钓到鱼,此值才有效)
}BC_FishTheFish;


typedef struct TowerNotify
{
	static const Type kType = kTowerNotify;
	UserID uid;
	Nickname name;
	uint16_t tower;		//通关的塔
}TowerNotify;
