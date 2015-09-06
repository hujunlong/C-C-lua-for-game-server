#pragma once
#include "define.h"

enum Society
{
    kCreateGuild = kSocietyTypeBegin + 1,
    kGetGuildList = kSocietyTypeBegin + 2,
    kApplyGuild =  kSocietyTypeBegin + 3,
    kLeaveGuild =  kSocietyTypeBegin + 4,
    kInviteGuildMember =  kSocietyTypeBegin + 5,
    kReplyGuildInvite =  kSocietyTypeBegin + 6,
    kGetGuildApplyMemberList =  kSocietyTypeBegin + 7,
    kReplyGuildApply =  kSocietyTypeBegin + 8,
    kEditCallBoard = kSocietyTypeBegin + 9,
    kChangeGuildMemberGrade = kSocietyTypeBegin + 10,
    kDelateGuildLeader = kSocietyTypeBegin + 11,
    kTransferGuildLeader = kSocietyTypeBegin + 12,
    kKickoutGuildMember = kSocietyTypeBegin + 13,
    kGetGuildMainInfo = kSocietyTypeBegin + 14,
    kDisbandGuild = kSocietyTypeBegin + 15,
    kGetGuildMemberList = kSocietyTypeBegin + 16,

    kGetGuildHeavensent = kSocietyTypeBegin + 101,
    kSaveGuildHeavensent = kSocietyTypeBegin + 102,
    kResetGuildHeavensent = kSocietyTypeBegin + 103,

    kGetGuildAuthority = kSocietyTypeBegin + 201,
    kGetGuildGradesInfo = kSocietyTypeBegin + 202,
    kSaveGuildGradeInfo = kSocietyTypeBegin + 203,

    kUpgradeGulildIconFrame = kSocietyTypeBegin + 301,
    kUploadGulildIcon = kSocietyTypeBegin + 302,
    kGetGulildIcons = kSocietyTypeBegin + 303,
    kSaveGulildUseIcon = kSocietyTypeBegin + 304,
    kGetGuildNews = kSocietyTypeBegin + 305,
	kApplication = kSocietyTypeBegin + 306,
    //公会战
    kGetGuildWarFieldList = kSocietyTypeBegin + 401,
    kGetGuildWarFieldSignList = kSocietyTypeBegin + 402,
    kSignGuildWar = kSocietyTypeBegin + 403,
    kGetGuildGivingList = kSocietyTypeBegin + 404,
    kPrizeGuildGiving = kSocietyTypeBegin + 405,
    kEndowGuildWarField = kSocietyTypeBegin + 406,
    kGetGuildWarFieldMemberReward = kSocietyTypeBegin + 407,
    //kGetGuildWarFieldGuildReward = kSocietyTypeBegin + 408,
    kGetGuildWarFieldInfo = kSocietyTypeBegin + 409,
	kCanGuildWarFileMap = kSocietyTypeBegin + 410,
    kIsGuildInWar = kSocietyTypeBegin + 451,
    kGetGuildWarFieldFigtersCount = kSocietyTypeBegin + 452,
    kEnterGuildWarField = kSocietyTypeBegin + 453,
    kLeaveGuildWarField = kSocietyTypeBegin + 454,
    kBuyGuildWarBuff = kSocietyTypeBegin + 455,
    kGuildWarMove = kSocietyTypeBegin + 456,
    kGetGuildWarLocationInfo = kSocietyTypeBegin + 457,
    kGetGuildWarFightersInfo = kSocietyTypeBegin + 458,
    kGetGuildWarFighterName = kSocietyTypeBegin + 459,
	kGuildWarBeginTime = kSocietyTypeBegin + 460,
	kGuildWarCanBuyHarm = kSocietyTypeBegin + 461,
	kGuildWarCanBuyBuff = kSocietyTypeBegin + 462,
    
    //拍卖行
    kOpenAuctionHouse   = kSocietyTypeBegin + 801,
    kCloseAuctionHouse  = kSocietyTypeBegin + 802,
    kSaleAuctionProps   = kSocietyTypeBegin + 803,
    kBuyAuctionProps    = kSocietyTypeBegin + 804,
    kViewAuctionProps   = kSocietyTypeBegin + 805,
    kSearchAuctionProps = kSocietyTypeBegin + 806,
    kAuctionRecord      = kSocietyTypeBegin + 807,
    kAuctionPropsDetail = kSocietyTypeBegin + 808,

    //////////////////////////////////////////////////////////////////
    kCreateGuildResult = kSocietyReturnBegin + 1,
    kGuildList = kSocietyReturnBegin + 2,
    kApplyGuildResult = kSocietyReturnBegin + 3,
    kLeaveGuildResult = kSocietyReturnBegin + 4,
    kInviteGuildMemberResult = kSocietyReturnBegin + 5,
    kReplyGuildInviteResult = kSocietyReturnBegin + 6,
    kGuildApplyMemberList = kSocietyReturnBegin + 7,
    kReplyGuildApplyResult = kSocietyReturnBegin + 8,
    kEditCallBoardResult = kSocietyReturnBegin + 9,
    kChangeGuildMemberGradeResult = kSocietyReturnBegin + 10,
    kDelateGuildLeaderResult = kSocietyReturnBegin + 11,
    kTransferGuildLeaderResult = kSocietyReturnBegin + 12,
    kKickoutGuildMemberResult = kSocietyReturnBegin + 13,
    kGuildMainInfo = kSocietyReturnBegin + 14,
    kDisbandGuildResult = kSocietyReturnBegin + 15,
    kGuildMemberList = kSocietyReturnBegin + 16,

    kGuildHeavensent = kSocietyReturnBegin + 101,
    kSaveGuildHeavensentResult = kSocietyReturnBegin + 102,
    kResetGuildHeavensentResult = kSocietyReturnBegin + 103,

    kGuildAuthority = kSocietyReturnBegin + 201,
    kGuildGradesInfo = kSocietyReturnBegin + 202,
    kSaveGuildGradeInfoResult = kSocietyReturnBegin + 203,

    kUpgradeGulildIconFrameResult = kSocietyReturnBegin + 301,
    kUploadGulildIconResult = kSocietyReturnBegin + 302,
    kGulildIcons = kSocietyReturnBegin + 303,
    kSaveGulildUseIconResult = kSocietyReturnBegin + 304,
    kGulildNews = kSocietyReturnBegin + 305,

    //公会战
    kGuildWarFieldList = kSocietyReturnBegin + 401,
    kGuildWarFieldSignList = kSocietyReturnBegin + 402,
    kSignGuildWarResult = kSocietyReturnBegin + 403,
    kGuildGivingList = kSocietyReturnBegin + 404,
    kPrizeGuildGivingResult = kSocietyReturnBegin + 405,
    kEndowGuildWarFieldResult = kSocietyReturnBegin + 406,
    kGuildWarFieldMemberReward = kSocietyReturnBegin + 407,
    //kGuildWarFieldGuildReward = kSocietyReturnBegin + 408,
    kGuildWarFieldInfo = kSocietyReturnBegin + 409,
	kResultCanGuildWarFileMap =  kSocietyReturnBegin + 410,
	kGuildWarCanBuyHarmResult = kSocietyReturnBegin + 461,
	kGuildWarCanBuyBuffResult = kSocietyReturnBegin + 462,

    kIsGuildInWarResult = kSocietyReturnBegin + 501,
    kGuildWarFieldFigtersCount = kSocietyReturnBegin + 502,
    kEnterGuildWarFieldResult = kSocietyReturnBegin + 503,
    kLeaveGuildWarFieldResult = kSocietyReturnBegin + 504,
    kBuyGuildWarBuffResult = kSocietyReturnBegin + 505,
    kGuildWarMoveResult = kSocietyReturnBegin + 506,
    kGuildWarLocationInfo = kSocietyReturnBegin + 507,
    kGuildWarFightersInfo = kSocietyReturnBegin + 508,
    kGuildWarFighterName = kSocietyReturnBegin + 509,
    kGuildWarBeginTimeResult = kSocietyReturnBegin + 510,
    //推送部分
    kPushInviteGuildMember = kSocietyTypeBegin + 500,
    kPushGuildDisbanded = kSocietyTypeBegin + 501,
    kPushReplyGuildApply = kSocietyTypeBegin + 502,
    kPushReplyGuildInvite = kSocietyTypeBegin + 503,
    kPushKickoutGuildMember = kSocietyTypeBegin + 504,
    kPushTransferGuildLeader = kSocietyTypeBegin + 505,
    kPushChangeGuildMemberGrade = kSocietyTypeBegin + 506,
	kPushAddGuildMember = kSocietyTypeBegin + 507,
	kPushDeleteGuildMember = kSocietyTypeBegin + 508,

    kPushGuildWarLocationFightersInfo = kSocietyTypeBegin + 551,
    kPushGuildWarLocationMembersInfo = kSocietyTypeBegin + 552,
    kPushPlayerLeaveGuildWarField = kSocietyTypeBegin + 553,
    kPushGuildWarWinItem = kSocietyTypeBegin + 554,
    kPushGuildWarResource = kSocietyTypeBegin + 555,
	kPushGuildWarEnter = kSocietyTypeBegin + 556,
	kPushGuildGradeInfo = kSocietyTypeBegin + 557,
	kPushGuildEnterAndOrderNum = kSocietyTypeBegin + 558,
	kPushGuildWarCanBuyHarm = kSocietyTypeBegin + 559,


    //拍卖行
    kOpenAuctionHouseResult   = kSocietyReturnBegin + 801,
    kCloseAuctionHouseResult  = kSocietyReturnBegin + 802,
    kSaleAuctionPropsResult   = kSocietyReturnBegin + 803,
    kBuyAuctionPropsResult    = kSocietyReturnBegin + 804,
    kViewAuctionPropsResult   = kSocietyReturnBegin + 805,
    kSearchAuctionPropsResult = kSocietyReturnBegin + 806,
    kAuctionRecordResult      = kSocietyReturnBegin + 807,
    kAuctionPropsDetailResult = kSocietyReturnBegin + 808,
    
    //拍卖行主动推送
    kPushAuctionPriceChange   = kSocietyReturnBegin + 821,
    kPushAuctionAppend        = kSocietyReturnBegin + 822,
    kPushAuctionDelete        = kSocietyReturnBegin + 823,
    kPushAuctionFailed        = kSocietyReturnBegin + 824,
};

enum SocietyResultType
{
    SocietyResultBegin = 14000,
    SOCIETY_ERROR = SocietyResultBegin + 1,                             //非法数据操作，传入数据错误
    SOCIETY_NOT_ENOUGH_GOLD = SocietyResultBegin + 2,                   //金币不足
    SOCIETY_NOT_ENOUGH_SILVER = SocietyResultBegin + 3,                 //银币不足
    SOCIETY_OVERLONG_GUILD_NAME = SocietyResultBegin + 4,               //公会名超长
    SOCIETY_BEINGLESS_GUILD = SocietyResultBegin + 5,                   //公会不存在
    SOCIETY_OVERLONG_CALLBOARD = SocietyResultBegin + 6,                //公会公告超长    
    SOCIETY_ALREADY_IN_GUILD = SocietyResultBegin + 7,                  //已经有公会
    SOCIETY_NO_IN_GUILD = SocietyResultBegin + 8,                       //未在公会中
    SOCIETY_GRADE_ERROR = SocietyResultBegin + 9,                       //权限不够
    SOCIETY_BEINGLESS_GRADE_LEVEL = SocietyResultBegin + 10,            //不存在的公会权限
    SOCIETY_ALREADY_IN_GUILD_APPLY_LIST = SocietyResultBegin + 11,      //已经在申请列表中
    SOCIETY_ALREADY_IN_GUILD_DELATE_LIST = SocietyResultBegin + 12,     //已经在弹劾列表中
    SOCIETY_NOT_FIND_MEMBER = SocietyResultBegin + 13,                  //成员不存在
    SOCIETY_YOU_ARE_LEADER = SocietyResultBegin + 14,                   //你是会长
    SOCIETY_YOU_ARE_NOT_LEADER = SocietyResultBegin + 15,               //你不是会长
    SOCIETY_DELATE_GUILD_LEADER = SocietyResultBegin + 16,              //现在不能弹劾会长
    SOCIETY_GUILD_FRAME_MAX = SocietyResultBegin + 17,                  //已经是最高级
    SOCIETY_UNKNOW_HEAVENSENT = SocietyResultBegin + 18,                //未知的天赋加点
    SOCIETY_HEAVENSENT_LEVEL_ERR = SocietyResultBegin + 19,             //天赋加点超过最大等级限制 或 公会等级不够不能加点
    SOCIETY_HEAVENSENT_PREPARE_ERR = SocietyResultBegin + 20,           //天赋加点前置错位
    SOCIETY_HEAVENSENT_COUNT_ERR = SocietyResultBegin + 21,             //天赋加点超过总点数
    SOCIETY_ACTION_ERR = SocietyResultBegin + 22,                       //无法对自己操作
    SOCIETY_DATA_NILL = SocietyResultBegin + 23,                        //操作数据出错
    SOCIETY_ALREADY_IN_SING_LIST = SocietyResultBegin + 24,             //已经在报名列表中了
    SOCIETY_GUILD_NOT_IN_WAR = SocietyResultBegin + 25,                 //公会没有参战
    SOCIETY_NOT_THE_TIME = SocietyResultBegin + 26,                     //时间未到
    SOCIETY_BUY_ERROR = SocietyResultBegin + 27,                        //超过购买上限
    SOCIETY_LEVEL_ERROR = SocietyResultBegin + 28,
	SOCIETY_GUILD_QUEUE = SocietyResultBegin +29,                      //公会参加公会战不能解散工会
	SOCIETY_GUILD_WAR_IS_ENCOURAGEMENT = SocietyResultBegin + 30,      //玩家已经领取奖励了
	SOCIETY_GUILD_WAR = SocietyResultBegin + 31,                       //公会战拥有领地不能解散工会
};

enum AuctionResultType
{
    AuctionResultBegin = 14500,
    AUCTION_SUCCESS          = AuctionResultBegin + 1,            // 成功（占位用，成功依然返回0）
    AUCTION_NOT_ACTIVATE     = AuctionResultBegin + 2,            // 尚未激活功能
    AUCTION_INVALID_ARGUMENT = AuctionResultBegin + 3,            // 参数不正确
    AUCTION_NOT_ENOUGH_SPACE = AuctionResultBegin + 4,            // 剩余位置不足
    AUCTION_NOT_FOR_AUCTION  = AuctionResultBegin + 5,            // 该物品不可出售
    AUCTION_NOT_ENOUGH_GOLD  = AuctionResultBegin + 6,            // 金币不足
    AUCTION_NOT_INVALID_ID   = AuctionResultBegin + 7,            // ID无效
    AUCTION_NOT_SET_PRICE    = AuctionResultBegin + 8,            // 未设置一口价
    AUCTION_NOT_INVALID_PAGE = AuctionResultBegin + 9,            // 页数不正确
};
//////////////////////////////////////////////////////////////////////////


struct Heavensent
{
    uint8_t id;             //天赋id
    uint8_t level;          //天赋等级
};
typedef struct Heavensent Heavensent;

struct NewHeavensent        //全新天赋
{
    Heavensent heavensent[10];
};
typedef struct NewHeavensent NewHeavensent;

struct GuildInfo
{
    uint32_t guild_id;          //公会id
    uint32_t level;             //公会等级
    uint32_t leader;            //会长id
    uint16_t leader_name_len;   //会长名
    char leader_name[6*3];
    uint32_t icon;              //会标
    uint32_t icon_frame;        //会标框
    uint32_t exp;               //公会经验
    uint32_t activity_exp;      //公会活跃度
    uint8_t member_cur;         //当前成员数
    uint8_t member_max;         //最大成员数
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
    Heavensent heavensent[10];  //天赋
    uint32_t is_in_delate_list; //是否投过票弹劾会长
    uint16_t call_board_len0;
    uint16_t call_board_len;
    char call_board[200*3];     //公告

};
typedef struct GuildInfo GuildInfo;

struct CreateGuild              //c2s 建立公会
{
    static const Type kType = kCreateGuild;
    uint16_t len;
    char name[24];              //公会名

};
typedef struct CreateGuild CreateGuild;

struct CreateGuildResult        //c2s
{
    static const Type kType = kCreateGuildResult;
    Result result;
    uint32_t state;             //1-公会名已经在使用
};
typedef struct CreateGuildResult CreateGuildResult;

struct GuildInfoTidy
{
    uint32_t guild_id;          //公会id
    uint32_t level;             //公会等级
    uint32_t icon;              //会标
    uint32_t icon_frame;        //会标框
    uint32_t is_applying;       //是否正在申请    1-在申请列表中 0-没有申请
    uint32_t member_cur;        //当前成员数
    uint32_t member_max;        //最大成员数
    uint32_t leader;            //会长id
    uint16_t leader_name_len;   //会长名
    char leader_name[6*3];
    uint16_t unused;            //内存补齐  
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
};
typedef struct GuildInfoTidy GuildInfoTidy;

struct GetGuildList             //c2s 公会列表
{
    static const Type kType = kGetGuildList;
    uint32_t page;
};
typedef struct GetGuildList GetGuildList;

struct GuildList                //s2c
{
    static const Type kType = kGuildList;
    uint32_t pages;             //总页数
    uint32_t count;             //本页返回纪录数
    GuildInfoTidy guild_info_tidy[10];
};
typedef struct GuildList GuildList;

struct ApplyGuild               //c2s 申请公会
{
    static const Type kType = kApplyGuild;
    uint32_t guild_id;          //申请公会的ID
};
typedef struct ApplyGuild ApplyGuild;

struct ApplyGuildResult         //s2c
{
    static const Type kType = kApplyGuildResult;
    Result result;
    uint32_t state;             //1-申请的公会不存在或已解散 2-公会申请列表已满 3-等级不够25级不能申请
};
typedef struct ApplyGuildResult ApplyGuildResult;

struct LeaveGuild               //c2s 退出公会
{
    static const Type kType = kLeaveGuild;
};
typedef struct LeaveGuild LeaveGuild;

struct LeaveGuildResult         //s2c
{
    static const Type kType = kLeaveGuildResult;
    uint32_t result;
};
typedef struct LeaveGuildResult LeaveGuildResult;

struct InviteGuildMember        //c2s 邀请玩家
{
    static const Type kType = kInviteGuildMember;
    uint16_t player_name_len;   //邀请玩家
    char player_name[18];   
};
typedef struct InviteGuildMember InviteGuildMember;

struct InviteGuildMemberResult  //s2c
{
    static const Type kType = kInviteGuildMemberResult;
    Result result;
    uint32_t state;             //0-邀请成功 1-保留 2-权限不够 3-未找到邀请玩家或邀请玩家不在线
                                //4-邀请对象已经在邀请列表 5-邀请玩家已拥有公会,6等级不足
};
typedef struct InviteGuildMemberResult InviteGuildMemberResult;

struct PushInviteGuildMember    //s2c 推送邀请玩家
{
    static const Type kType = kPushInviteGuildMember;
    uint32_t player_id;         //邀请者
    uint16_t player_name_len;
    char player_name[18];   
    uint32_t guild_id;
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
};
typedef struct PushInviteGuildMember PushInviteGuildMember;

struct PushGuildDisbanded       //s2c 推送公会解散
{
    static const Type kType = kPushGuildDisbanded;
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
};
typedef struct PushGuildDisbanded PushGuildDisbanded;

struct PushReplyGuildApply      //s2c 推送回复公会申请给玩家
{
    static const Type kType = kPushReplyGuildApply;
    uint32_t guild_id;
    uint16_t agree;             //0-拒绝 1-同意
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
};
typedef struct PushReplyGuildApply PushReplyGuildApply;

struct PushReplyGuildInvite     //s2c 推送回复公会邀请给邀请者
{
    static const Type kType = kPushReplyGuildInvite;
    uint16_t player_name_len;
    char player_name[18];   
    uint32_t agree;             //0-拒绝 1-同意
};
typedef struct PushReplyGuildInvite PushReplyGuildInvite;

struct PushKickoutGuildMember   //s2c 推送踢出玩家
{
    static const Type kType = kPushKickoutGuildMember;
    uint16_t guild_name_len;
    char guild_name[8*3];       //公会名
};
typedef struct PushKickoutGuildMember PushKickoutGuildMember;

struct PushTransferGuildLeader  //s2c 推送会长转让
{
    static const Type kType = kPushTransferGuildLeader;
};
typedef struct PushTransferGuildLeader PushTransferGuildLeader;

struct ReplyGuildInvite         //c2s 回复公会邀请
{
    static const Type kType = kReplyGuildInvite;
    uint32_t agree;             //1-同意 0-不同意
    uint32_t guild_id;          //公会ID
    uint32_t player_id;         //邀请者
};
typedef struct ReplyGuildInvite ReplyGuildInvite;

struct ReplyGuildInviteResult   //s2c
{
    static const Type kType = kReplyGuildInviteResult;
    Result result;
    uint32_t state;             //1-不在邀请队列（超时或非法数据） 2-已经在公会中 3-邀请公会成员已满 4-邀请工会不存在，可能已经解散或非法数据
};
typedef struct ReplyGuildInviteResult ReplyGuildInviteResult;

struct ReplyGuildApply          //c2s 回复申请
{
    static const Type kType = kReplyGuildApply;
    uint32_t player_id;         //回复对象
    uint32_t agree;             //0-拒绝 1-邀请 
};
typedef struct ReplyGuildApply ReplyGuildApply;

struct ReplyGuildApplyResult    //s2c
{
    static const Type kType = kReplyGuildApplyResult;
    Result result;
    uint32_t state;             // 2-权限不够 3-已经不在申请列表(超时或者已经被其他管理员操作) 4-回复邀请对象已经在公会中 5-公会成员已满 对方拒绝 6
};
typedef struct ReplyGuildApplyResult ReplyGuildApplyResult;

struct EditCallBoard            //c2s 编辑公告
{
    static const Type kType = kEditCallBoard;
    uint16_t len;
    char content[600];
};
typedef struct EditCallBoard EditCallBoard;

struct EditCallBoardResult      //s2c
{
    static const Type kType = kEditCallBoardResult;
    Result result;
    uint32_t state;             //1-保留 2-权限不够
};
typedef struct EditCallBoardResult EditCallBoardResult;

struct ChangeGuildMemberGrade   //c2s 改变公会成员职位
{
    static const Type kType = kChangeGuildMemberGrade;
    uint32_t player_id;         //改变对象的id
    uint32_t state;             //0-降级 1-提升
};
typedef struct ChangeGuildMemberGrade ChangeGuildMemberGrade;

struct ChangeGuildMemberGradeResult     //s2c
{
    static const Type kType = kChangeGuildMemberGradeResult;
    Result result;
    uint32_t state;                     //1-目标不在公会中 2-权限不够
};
typedef struct ChangeGuildMemberGradeResult ChangeGuildMemberGradeResult;

struct DelateGuildLeader                //c2s 弹劾会长
{
    static const Type kType = kDelateGuildLeader;
};
typedef struct DelateGuildLeader DelateGuildLeader;

struct DelateGuildLeaderResult          //s2c
{
    static const Type kType = kDelateGuildLeaderResult;
    Result result;
    //uint32_t state;
};
typedef struct DelateGuildLeaderResult DelateGuildLeaderResult;

struct TransferGuildLeader              //c2s 转让会长
{
    static const Type kType = kTransferGuildLeader;
    uint32_t player_id;                 //转让对象ID
};
typedef struct TransferGuildLeader TransferGuildLeader;

struct TransferGuildLeaderResult        //s2c
{
    static const Type kType = kTransferGuildLeaderResult;
    Result result;
    uint32_t state;                     //1-成员不存在
};
typedef struct TransferGuildLeaderResult TransferGuildLeaderResult;

struct KickoutGuildMember               //c2s 踢出成员
{
    static const Type kType = kKickoutGuildMember;
    uint32_t player_id;                 //踢出对象ID
};
typedef struct KickoutGuildMember KickoutGuildMember;

struct KickoutGuildMemberResult         //s2c
{
    static const Type kType = kKickoutGuildMemberResult;
    Result result;
    uint32_t state;                     //1-目标不在公会中(取玩家列表后目标退出公会) 2-权限不够
};
typedef struct KickoutGuildMemberResult KickoutGuildMemberResult;

struct GetGuildMainInfo                 //c2s 取公会信息
{
    static const Type kType = kGetGuildMainInfo;
};
typedef struct GetGuildMainInfo GetGuildMainInfo;

struct GuildMainInfo                    //s2c
{
    static const Type kType = kGuildMainInfo;
    Result result;
    GuildInfo guild_info;
};
typedef struct GuildMainInfo GuildMainInfo;

struct DisbandGuild                     //c2s 解散工会
{
    static const Type kType = kDisbandGuild;
};
typedef struct DisbandGuild DisbandGuild;

struct DisbandGuildResult               //s2c
{
    static const Type kType = kDisbandGuildResult;
    Result result;
};
typedef struct DisbandGuildResult DisbandGuildResult;

struct GetGuildMemberList               //c2s 取公会成员列表
{
    static const Type kType = kGetGuildMemberList;
};
typedef struct GetGuildMemberList GetGuildMemberList;

struct GuildMemberInfo
{
    uint32_t player_id;                 //成员id
    uint32_t member_level;              //成员等级
    uint32_t member_sex;                //性别
    uint32_t guild_offer;               //成员贡献度
    uint32_t grade_level;               //成员会阶等级
    uint16_t unused;                    //内存补齐
    uint16_t grade_name_len;            //会阶名
    char grade_name[24];
    uint32_t online_state;              //在线状态 0- 在线 非0-离线时间
    uint16_t member_name_len;           //成员名
    char member_name[6*3];
    uint32_t unused1;                   //war_field_offer;          //领地贡献度
    uint32_t unused2;                   //is_get_member_box;        //是否领取当日领地宝箱
};
typedef struct GuildMemberInfo GuildMemberInfo;

struct GuildMemberList                  //s2c
{
    static const Type kType = kGuildMemberList;
    Result result;
    //uint32_t pages;                       //总页数
    uint32_t count;                     //本页返回纪录数
    GuildMemberInfo guild_member_info[50];
};
typedef struct GuildMemberList GuildMemberList;

struct GetGuildApplyMemberList          //c2s 取公会申请成员列表
{
    static const Type kType = kGetGuildApplyMemberList;
};
typedef struct GetGuildApplyMemberList GetGuildApplyMemberList;

struct GuildApplyMemberInfo
{
    uint32_t player_id;                 //成员id
    uint32_t player_level;              //成员等级
    uint16_t player_name_len;           //成员名
    char player_name[6*3];
};
typedef struct GuildApplyMemberInfo GuildApplyMemberInfo;

struct GuildApplyMemberList             //s2c
{
    static const Type kType = kGuildApplyMemberList;
    uint32_t state;                     //1-保留 2-权限不够
    uint32_t count;                     //返回纪录数
    GuildApplyMemberInfo guild_apply_member_info[100];
};
typedef struct GuildApplyMemberList GuildApplyMemberList;

struct GetGuildHeavensent               //c2s 取天赋加点
 { 
    static const Type kType = kGetGuildHeavensent;
};
typedef struct GetGuildHeavensent GetGuildHeavensent;

struct GuildHeavensent                  //s2c
 { 
    static const Type kType = kGuildHeavensent;
    Result result;
    uint32_t count;                     //天赋个数  --此值一直默认为10
    Heavensent heavensent[10];
};
typedef struct GuildHeavensent GuildHeavensent;

struct SaveGuildHeavensent              //c2s 保存天赋加点
 { 
    static const Type kType = kSaveGuildHeavensent;
    uint32_t count;                     //天赋个数  --默认为10
    Heavensent heavensent[10];
};
typedef struct SaveGuildHeavensent SaveGuildHeavensent;

struct SaveGuildHeavensentResult        //s2c
 { 
    static const Type kType = kSaveGuildHeavensentResult;
    Result result;
};
typedef struct SaveGuildHeavensentResult SaveGuildHeavensentResult;

struct ResetGuildHeavensent             //c2s 重置天赋加点
 { 
    static const Type kType = kResetGuildHeavensent;
};
typedef struct ResetGuildHeavensent ResetGuildHeavensent;

struct ResetGuildHeavensentResult       //s2c
 { 
    static const Type kType = kResetGuildHeavensentResult;
    Result result;
};
typedef struct ResetGuildHeavensentResult ResetGuildHeavensentResult;


struct GetGuildAuthority                //c2s 取会阶对应权利
{
    static const Type kType = kGetGuildAuthority;
};
typedef struct GetGuildAuthority GetGuildAuthority;

struct Authority
{
    uint8_t talk_with;                  //公会发言
    uint8_t change_grade;               //升降会员
    uint8_t invite_member;              //招收成员
    uint8_t kickout_member;             //开除成员
    uint8_t edit_call_board;            //编辑公告
    uint8_t edit_icon;                  //编辑会标
    uint8_t sign_guild_war;             //战场报名
    uint8_t prize_guild_giving;         //分配仓库物品
};
typedef struct Authority Authority;

struct GuildAuthority                   //s2c
{
    static const Type kType = kGuildAuthority;
    Result result;
    Authority authority;
};
typedef struct GuildAuthority GuildAuthority;

struct GetGuildGradesInfo               //c2s 会长取所有会阶信息管理
 { 
    static const Type kType = kGetGuildGradesInfo;
};
typedef struct GetGuildGradesInfo GetGuildGradesInfo;

struct PushGuildGradesInfo             //改变了会阶，通知对应会阶玩家
{
	static const Type kType = kPushGuildGradeInfo;
    Authority authority;
};
typedef struct PushGuildGradesInfo PushGuildGradesInfo;

struct GuildGradeInfo
{
    uint16_t grade_level;
    uint16_t grade_name_len;
    char grade_name[24];
    Authority authority;
};
typedef struct GuildGradeInfo GuildGradeInfo;

struct PushChangeGuildMemberGrade   //s2c 推送会阶改变
{
    static const Type kType = kPushChangeGuildMemberGrade;
    uint32_t grade_level;               //会阶等级
    uint16_t unused;                    //内存补齐
    uint16_t grade_name_len;            //会阶名
    char grade_name[24];                //会阶名
    Authority grade_authority;           //权限
};
typedef struct PushChangeGuildMemberGrade PushChangeGuildMemberGrade;

struct PushAddGuildMember	//推送添加成员
{
	static const Type kType = kPushAddGuildMember;
	GuildMemberInfo info;
};
typedef struct PushAddGuildMember PushAddGuildMember;

struct PushDeleteGuildMember	//推送删除成员
{
	static const Type kType = kPushDeleteGuildMember ;
	uint16_t player_id;
};
typedef struct PushDeleteGuildMember PushDeleteGuildMember;


struct GuildGradesInfo                  //s2c
 { 
    static const Type kType = kGuildGradesInfo;
    Result result;
    uint32_t count;
    GuildGradeInfo grade_info[5];   
};
typedef struct GuildGradesInfo GuildGradesInfo;

struct SaveGuildGradeInfo               //c2s 会长保存会阶信息
 { 
    static const Type kType = kSaveGuildGradeInfo;
    GuildGradeInfo grade_info;
};
typedef struct SaveGuildGradeInfo SaveGuildGradeInfo;

struct SaveGuildGradeInfoResult         //s2c
 { 
    static const Type kType = kSaveGuildGradeInfoResult;
    Result result;
};
typedef struct SaveGuildGradeInfoResult SaveGuildGradeInfoResult;

struct UpgradeGulildIconFrame           //c2s 升级会标框
 { 
    static const Type kType = kUpgradeGulildIconFrame;
};
typedef struct UpgradeGulildIconFrame UpgradeGulildIconFrame;

struct UpgradeGulildIconFrameResult     //s2c
 { 
    static const Type kType = kUpgradeGulildIconFrameResult;
    Result result;
    uint32_t state;                     //1-保留 2-权限不够 3-达到上限
};
typedef struct UpgradeGulildIconFrameResult UpgradeGulildIconFrameResult;

struct UploadGulildIcon                 //c2s 上传会标
 { 
    static const Type kType = kUploadGulildIcon;
    uint16_t unused;                    //内存补齐
    uint16_t icon_bin_len;              //图标大小
    char icon_bin[1024*20];             //20k
};
typedef struct UploadGulildIcon UploadGulildIcon;

struct UploadGulildIconResult           //s2c
 { 
    static const Type kType = kUploadGulildIconResult;
    Result result;
    uint32_t state;                     //1-保留 2-权限不够
};
typedef struct UploadGulildIconResult UploadGulildIconResult;

struct GetGulildIcons                 //c2s 取公会所上传的会标
 { 
  static const Type kType = kGetGulildIcons;
  uint32_t guild_id;
};
typedef struct GetGulildIcons GetGulildIcons;

struct GulildIcons                    //s2c
 { 
  static const Type kType = kGulildIcons;
  Result result;
  uint16_t unused;                    //内存补齐
  uint16_t icon_bin_len;              //图标大小
  char icon_bin[1024*20];             //20k
 };
typedef struct GulildIcons GulildIcons;

struct SaveGulildUseIcon                //c2s 重新选择会标
 { 
    static const Type kType = kSaveGulildUseIcon;
    uint32_t icon;
};
typedef struct SaveGulildUseIcon SaveGulildUseIcon;

struct SaveGulildUseIconResult          //s2c
 { 
    static const Type kType = kSaveGulildUseIconResult;
    Result result;
    uint32_t state;                     //1-保留 2-权限不够
};
typedef struct SaveGulildUseIconResult SaveGulildUseIconResult;

struct GetGuildNews                     //c2s 取公会新闻
 { 
    static const Type kType = kGetGuildNews;
};
typedef struct GetGuildNews GetGuildNews;

struct GNews
{
    uint16_t triger_name_len;           //成员名
    char triger_name[6*3];
    uint32_t time;                      //新闻生成时间
    uint32_t type;                      //1 获得EXP
    uint32_t content;
};
typedef struct GNews GNews;

struct GuildNews                        //s2c
 { 
    static const Type kType = kGulildNews;
    Result result;
    uint32_t count;
    GNews gnews[100];    
};
typedef struct GuildNews GuildNews;






struct GetGuildWarFieldList             //c2s 取公会战场列表(领地跟战场统一为同一概念,未做过细区分)
 { 
    static const Type kType = kGetGuildWarFieldList;
};
typedef struct GetGuildWarFieldList GetGuildWarFieldList;

struct WarFieldTidy
{
    uint32_t war_field_id;              //战场ID
    uint32_t guild_id;                  //占领公会
    uint32_t is_signed;                 //是否已经报名这个地图
    uint32_t technology_level;          //科技等级
    uint16_t unused;                    //内存补齐
    uint16_t guild_name_len;
    char guild_name[8*3];               //公会名
};
typedef struct WarFieldTidy WarFieldTidy;

struct GuildWarFieldList                //s2c
 { 
    static const Type kType = kGuildWarFieldList;
    uint32_t count;
    WarFieldTidy war_fields_tidy[10];   //暂时定义10个，后期需根据实际情况调整
};
typedef struct GuildWarFieldList GuildWarFieldList;

struct GetGuildWarFieldSignList         //c2s 取公会战场报名列表
 { 
    static const Type kType = kGetGuildWarFieldSignList;
    uint32_t war_field_id;
};
typedef struct GetGuildWarFieldSignList GetGuildWarFieldSignList;

struct WarFieldSignInfo
{
    uint16_t guild_id;                  //报名公会ID
    uint16_t guild_name_len;
    char guild_name[8*3];
    uint32_t activity_exp;              //公会活跃度
};
typedef struct WarFieldSignInfo WarFieldSignInfo;

struct GuildWarFieldSignList            //s2c
 { 
    static const Type kType = kGuildWarFieldSignList;
    uint32_t count;
    WarFieldSignInfo war_fields_sign_info[100];         //暂时定义100个，后期需根据实际情况调整  
};
typedef struct GuildWarFieldSignList GuildWarFieldSignList;

struct SignGuildWar                     //c2s 公会战场报名
 { 
    static const Type kType = kSignGuildWar;
    uint32_t war_field_id;
};
typedef struct SignGuildWar SignGuildWar;

struct SignGuildWarResult               //s2c
 { 
    static const Type kType = kSignGuildWarResult;
    Result result;
    uint32_t state;                     //0-报名成功 1-每星期只能报1个战场，报名失败 2-权限不够 3-已经报名 -4占领公会默认已经报名不需要再报名
};
typedef struct SignGuildWarResult SignGuildWarResult;

struct GetGuildGivingList               //c2s 取公会战利品列表
 { 
    static const Type kType = kGetGuildGivingList;
};
typedef struct GetGuildGivingList GetGuildGivingList;

struct Giving
{
    uint32_t item_id;
    uint32_t item_count;
};
typedef struct Giving Giving;

struct GuildGivingList                  //s2c
 { 
    static const Type kType = kGuildGivingList;
    Result result;
    uint32_t state;                     //1-保留 2-权限不够
    uint32_t count;
    Giving giving[100];                 //暂时定义100个，后期需根据实际情况调整  
};
typedef struct GuildGivingList GuildGivingList;

struct PrizeGuildGiving                 //c2s 分配公会战利品
 { 
    static const Type kType = kPrizeGuildGiving;
    uint32_t item_id;
    uint32_t count;
    uint32_t player_id[50];             //分配玩家id,公会人数上限定为50个,此处也定义为50
};
typedef struct PrizeGuildGiving PrizeGuildGiving;

struct PrizeGuildGivingResult
 { 
    static const Type kType = kPrizeGuildGivingResult;
    Result result;
    uint32_t state;                     //1-会员数量大于要分配的物品库存 2-权限不够
};
typedef struct PrizeGuildGivingResult PrizeGuildGivingResult;

struct EndowGuildWarField               //c2s 领地捐赠
 { 
    static const Type kType = kEndowGuildWarField;
    uint32_t war_field_id;              //捐赠领地
	uint32_t unable;                     //占位
    double endow_count;                 //捐赠的数量
    uint32_t endow_type;                //0-银币 1-金币
};
typedef struct EndowGuildWarField EndowGuildWarField;

struct EndowGuildWarFieldResult         //s2c
 { 
    static const Type kType = kEndowGuildWarFieldResult;
    Result result;
    uint32_t technology_level;          //科技等级
    uint32_t technology_exp;            //科技当前经验
    uint32_t war_field_offer;           //领地贡献
};
typedef struct EndowGuildWarFieldResult EndowGuildWarFieldResult;

struct GetGuildWarFieldMemberReward     //c2s 领取成员每日奖励
 { 
    static const Type kType = kGetGuildWarFieldMemberReward;
    uint32_t war_field_id;
};
typedef struct GetGuildWarFieldMemberReward GetGuildWarFieldMemberReward;

struct GuildWarFieldMemberReward        //s2c
 { 
    static const Type kType = kGuildWarFieldMemberReward;
    Result result;
    uint32_t member_box_type;           //领取箱子ID
    uint32_t member_box_count;          //领取箱子个数
};
typedef struct GuildWarFieldMemberReward GuildWarFieldMemberReward;

struct GetGuildWarFieldInfo             //c2s 取战场详细信息
 { 
    static const Type kType = kGetGuildWarFieldInfo;
    uint32_t war_field_id;  
};
typedef struct GetGuildWarFieldInfo GetGuildWarFieldInfo;

struct GuildWarFieldInfo                //s2c
 { 
    static const Type kType = kGuildWarFieldInfo;
    Result result;
    uint32_t technology_level;          //科技等级
    uint32_t technology_exp;            //科技当前经验
    uint32_t war_field_offer;           //领地贡献
	uint32_t is_get_member_box;         //是否能够领取奖励 (0:不能领取 1:能够领取)
};
typedef struct GuildWarFieldInfo GuildWarFieldInfo;

struct CanGuildWarFileMap             //点击时候玩家能否参战的时候地图c2s
{
	static const Type kType = kCanGuildWarFileMap;

};
typedef struct CanGuildWarFileMap CanGuildWarFileMap;

struct ResultCanGuildWarFileMap             //点击时候玩家能否参战的时候地图s2c
{
	static const Type kType = kResultCanGuildWarFileMap;
	Result result;
	uint32_t map[10];                      //数组1表示能够打的地图
};
typedef struct ResultCanGuildWarFileMap ResultCanGuildWarFileMap;


struct GetGuildWarBeginTime            //取公会开战时间 c2s
{
	static const Type kType = kGuildWarBeginTime;
};
typedef struct GetGuildWarBeginTime GetGuildWarBeginTime;

struct GuildWarBeginTimeResult        //s2c
{
	static const Type kType = kGuildWarBeginTimeResult;
	uint32_t begin_time;//开始0 表示没开始 1表示开始了
};
typedef struct GuildWarBeginTimeResult GuildWarBeginTimeResult;

struct IsGuildInWar                     //c2s 取公会是否参战
 { 
    static const Type kType = kIsGuildInWar;
};
typedef struct IsGuildInWar IsGuildInWar;

struct IsGuildInWarResult               //s2c
 { 
    Result result;
    static const Type kType = kIsGuildInWarResult;
    //0-未参战 非0-战场个数
	uint32_t guild_war_time; //开战时间
    uint32_t count; 
    uint32_t war_field_list[10];        //
};
typedef struct IsGuildInWarResult IsGuildInWarResult;

struct GetGuildWarFieldFigtersCount     //c2s 取工会战进入成员个数
 { 
    static const Type kType = kGetGuildWarFieldFigtersCount;
    uint32_t war_field_id;  
};
typedef struct GetGuildWarFieldFigtersCount GetGuildWarFieldFigtersCount;

struct GuildWarFieldFigtersCount        //s2c
 { 
    static const Type kType = kGuildWarFieldFigtersCount;
    Result result;
    uint32_t camp;                      //0-防守方 1-进攻方
    uint32_t enter_count;               //已经进入人数
};
typedef struct GuildWarFieldFigtersCount GuildWarFieldFigtersCount;

struct EnterGuildWarField               //c2s 进入公会战场
 { 
    static const Type kType = kEnterGuildWarField;
    uint32_t war_field_id;  
};
typedef struct EnterGuildWarField EnterGuildWarField;

struct EnterGuildWarFieldResult         //s2c
 { 
    static const Type kType = kEnterGuildWarFieldResult;
    Result result;
    uint32_t enter_count;               //己方已经进入人数
    uint32_t order_count;               //己方排队人数
    uint32_t is_guild_waring;           //是否已经开战
    uint32_t first_order_time;          //第一个开始排队时间
    uint32_t location;                  //进入战场位置(默认为出身点)
    uint32_t buff_heal_hp_buy_num;     //掉线时候购买血包次数
    uint32_t buff_add_attack_buy_num;  //掉线时候购买的伤害加成次数
	uint32_t enter_time;                //进入时间
	uint32_t begin_time;                //开始时间
    uint32_t end_time;                  //结束时间
	uint32_t wait_time;                 //排队等待间隔时间(eg:20秒)
};
typedef struct EnterGuildWarFieldResult EnterGuildWarFieldResult;

struct LeaveGuildWarField               //c2s 离开公会战场
 { 
    static const Type kType = kLeaveGuildWarField;
};
typedef struct LeaveGuildWarField LeaveGuildWarField;

struct LeaveGuildWarFieldResult         //s2c
 { 
    static const Type kType = kLeaveGuildWarFieldResult;
};
typedef struct LeaveGuildWarFieldResult LeaveGuildWarFieldResult;

struct PushPlayerLeaveGuildWarField //s2c 推送玩家离线信息给排队链表后面的玩家
{
    static const Type kType = kPushPlayerLeaveGuildWarField;
    uint32_t enter_count;               //己方已经进入人数  
    uint32_t order_count;               //玩家前面的排队人数
    uint32_t enter_time;                //玩家还需要排队时间
};
typedef struct PushPlayerLeaveGuildWarField PushPlayerLeaveGuildWarField;

struct PushGuildEnterAndOrderNum //s2c 进入人数,
{
	static const Type kType = kPushGuildEnterAndOrderNum;
	uint32_t enter_num;
	uint32_t order_num;
};
typedef struct PushGuildEnterAndOrderNum PushGuildEnterAndOrderNum;


struct BuyGuildWarBuff                  //c2s 购买战场BUFF
 { 
    static const Type kType = kBuyGuildWarBuff;
    uint32_t war_field_id;
    uint32_t buff_type;                 //1-恢复包 2-伤害增加
};
typedef struct BuyGuildWarBuff BuyGuildWarBuff;

struct BuyGuildWarBuffResult            //s2c
 { 
    static const Type kType = kBuyGuildWarBuffResult;
    Result result;
};   
typedef struct BuyGuildWarBuffResult BuyGuildWarBuffResult;

struct GetGuildWarLocationInfo          //c2s 取战场路点信息
 { 
    static const Type kType = kGetGuildWarLocationInfo;
    uint32_t location;
};
typedef struct GetGuildWarLocationInfo GetGuildWarLocationInfo;

struct GuildWarLocationInfo             //s2c
 { 
    static const Type kType = kGuildWarLocationInfo;
    Result result;
    uint32_t attack_count;              //该点攻击方数量
    uint32_t defense_count;             //该点防守方数量
};
typedef struct GuildWarLocationInfo GuildWarLocationInfo;

struct GuildWarMove                     //c2s 战场移动
 { 
    static const Type kType = kGuildWarMove;
    uint32_t war_field_id;
    uint32_t location;
};
typedef struct GuildWarMove GuildWarMove;

struct GuildWarMoveResult               //s2c
 { 
    static const Type kType = kGuildWarMoveResult;
    Result result;
    uint32_t isCanMove;                 //是否能够移动 0不能移动 1移动
    uint32_t is_fighting;               //0-占领 1-战斗
    uint32_t is_dead;                   //是否死亡
    uint32_t reborn_location;           //死亡后复活点(未死亡为0)
    uint32_t life_percent;              //当前队剩余血量%
    uint32_t win_count;                 //本声明周期战胜次数
    uint32_t heal_hp;                   //buff回复的血量
};
typedef struct GuildWarMoveResult GuildWarMoveResult;

struct PushGuildWarLocationFightersInfo //s2c 推送路点战斗信息给被攻击者
{
    static const Type kType = kPushGuildWarLocationFightersInfo;
    uint32_t is_dead;                   //是否死亡
    uint32_t reborn_location;           //死亡后复活点(未死亡为0)
    uint32_t life_percent;              //当前队剩余血量%
    uint32_t win_count;                 //本声明周期战胜次数
    uint32_t heal_hp;                   //buff回复的血量
};
typedef struct PushGuildWarLocationFightersInfo PushGuildWarLocationFightersInfo;


struct LocationMembersInfo
{
    uint32_t location;
    uint32_t attack_count;              //攻击方数量
    uint32_t defense_count;             //防守方数量
    uint32_t camp;                      //归属阵营 0-防守方 1-攻击方 2-未占领
};
typedef struct LocationMembersInfo LocationMembersInfo;

struct PushGuildWarLocationMembersInfo  //s2c 推送路点成员信息给玩家
{
    static const Type kType = kPushGuildWarLocationMembersInfo;
    uint32_t count;          //路点个数
    LocationMembersInfo location_info[100];
};
typedef struct PushGuildWarLocationMembersInfo PushGuildWarLocationMembersInfo;

struct PushGuildWarResource  //推送资源
{
    static const Type kType = kPushGuildWarResource;
    uint32_t defenseResourceNum;  //防守资源获取量
    uint32_t attackResourceNum;  //进攻资源获取量
};
typedef struct PushGuildWarResource PushGuildWarResource;

struct PushGuildWarEnter //通知在线玩家进入公会战场
{
	 static const Type kType = kPushGuildWarEnter;
	 uint32_t isBegin;//1 通知玩家准备进入了
};
typedef struct PushGuildWarEnter PushGuildWarEnter;

struct PushGuildWarWinItem     //推送获胜方
{
    static const Type kType = kPushGuildWarWinItem;  
    uint32_t isWinner;     //是否胜利 0表示失败 1表示成功  2表示平局
};
typedef struct PushGuildWarWinItem PushGuildWarWinItem;

struct GetGuildWarFighterName  // C2S 获取资源进攻方 与 防守方公会名
{
    static const Type kType = kGetGuildWarFighterName;
    uint32_t war_field_id;
};
typedef struct GetGuildWarFighterName GetGuildWarFighterName;

struct GuildWarFighterNamerResult  //S2C 获取资源进攻方 与 防守方公会名
{
    static const Type kType = kGuildWarFighterName;
    Result result;
    uint16_t unuesed1;
    uint16_t  defenseItemNameLenth;
    char defenseItemName[8*3]; //防守公会名字
	uint32_t defense_id;
    uint32_t defense_icon;
    uint16_t unuesed2;
    uint16_t attackItemNameLenth;
    char attackItemName[8*3];  //进攻公会名字
	uint32_t attack_id;
    uint32_t attack_icon;
    uint32_t defenseResourceNum;  //初始化防守资源获取量
    uint32_t attackResourceNum;  //初始化进攻资源获取量
};
typedef struct GuildWarFighterNamerResult GuildWarFighterNamerResult;

struct GetGuildWarFightersInfo          //c2s 取战场击杀、伤亡数据
 { 
    static const Type kType = kGetGuildWarFightersInfo;
    uint32_t war_field_id; //战场id
};
typedef struct GetGuildWarFightersInfo GetGuildWarFightersInfo;

struct GuildWarFighter
{
    uint16_t player_name_len;           //成员名
    char player_name[6*3];
    uint32_t kill_count;                //击杀
    uint32_t dead_count;                //死亡
    uint32_t hits_count;                //造成伤害
    uint32_t GuildId;                   //获取公会id
};
typedef struct GuildWarFighter GuildWarFighter;

struct GuildWarFightersInfo             //s2c
{ 
    static const Type kType = kGuildWarFightersInfo;
    Result result;
    uint32_t attack_count;              //攻击方数量
    uint32_t defense_count;             //防守方数量
    GuildWarFighter fighters[100];      //50+50
};
typedef struct GuildWarFightersInfo GuildWarFightersInfo;

struct GuildWarCanBuyHarm             //c2s
{ 
	static const Type kType = kGuildWarCanBuyHarm;
};
typedef struct GuildWarCanBuyHarm GuildWarCanBuyHarm;

struct GuildWarCanBuyHarmResult             //s2c
{ 
	static const Type kType = kGuildWarCanBuyHarmResult;
	bool isCanBuyHarm;
};
typedef struct GuildWarCanBuyHarmResult GuildWarCanBuyHarmResult;

struct GuildWarCanBuyBuff             //c2s
{ 
	static const Type kType = kGuildWarCanBuyBuff;
};
typedef struct GuildWarCanBuyBuff GuildWarCanBuyBuff;

struct GuildWarCanBuyBuffResult             //s2c
{ 
	static const Type kType = kGuildWarCanBuyBuffResult;
	bool isCanBuyBuff;
};
typedef struct GuildWarCanBuyBuffResult GuildWarCanBuyBuffResult;
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

// 打开拍卖行
struct OpenAuctionHouse
{ 
    static const Type kType = kOpenAuctionHouse;
};
typedef struct OpenAuctionHouse OpenAuctionHouse;

struct OpenAuctionHouseResult
{ 
    static const Type kType = kOpenAuctionHouseResult;
    Result result;
    uint8_t space;      //剩余空间
};
typedef struct OpenAuctionHouseResult OpenAuctionHouseResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 关闭拍卖行
struct CloseAuctionHouse
{ 
    static const Type kType = kCloseAuctionHouse;
};
typedef struct CloseAuctionHouse CloseAuctionHouse;

struct CloseAuctionHouseResult
{ 
    static const Type kType = kCloseAuctionHouseResult;
    Result result;
};
typedef struct CloseAuctionHouseResult CloseAuctionHouseResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 出售物品
struct SaleAuctionProps
{ 
    static const Type kType = kSaleAuctionProps;
    uint32_t id;          // 拍卖物品（背包内物品ID）
    uint16_t amount;      // 数量
    uint16_t day;         // 拍卖天数，目前支持1、2、4天
    uint32_t start;       // 起拍价
    uint32_t price;       // 一口价，0代表未设置
};
typedef struct SaleAuctionProps SaleAuctionProps;

struct SaleAuctionPropsResult
{ 
    static const Type kType = kSaleAuctionPropsResult;
    Result result;
};
typedef struct SaleAuctionPropsResult SaleAuctionPropsResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 购买物品
struct BuyAuctionProps
{ 
    static const Type kType = kBuyAuctionProps;
    uint32_t id;        // 拍卖行物品ID
    uint8_t type;       // 1一口价，2参与竞拍
};
typedef struct BuyAuctionProps BuyAuctionProps;

struct BuyAuctionPropsResult
{ 
    static const Type kType = kBuyAuctionPropsResult;
    Result result;
};
typedef struct BuyAuctionPropsResult BuyAuctionPropsResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 查看拍卖行物品列表
struct AuctionProps
{
    uint32_t id;           // 拍卖行物品ID
    uint32_t kind;         // 道具表sid
    uint32_t amount;       // 数量
    uint32_t start;        // 起拍价
    uint32_t current;      // 当前竞拍价
    uint32_t price;        // 一口价，0代表未设置
    uint32_t time;         // 拍卖时间
};
typedef struct AuctionProps AuctionProps;

struct ViewAuctionProps
{ 
    static const Type kType = kViewAuctionProps;
    uint16_t page;         // 页数，从1开始
    uint8_t sort;          // 排序方式，1竞拍价（默认），2一口价，3剩余时间
    uint8_t order;         // 顺序，0从大到小，1从小到大
};
typedef struct ViewAuctionProps ViewAuctionProps;

struct ViewAuctionPropsResult
{ 
    static const Type kType = kViewAuctionPropsResult;
    Result result;
    uint16_t page;  //总页数
    uint16_t count;
    AuctionProps list[11];
};
typedef struct ViewAuctionPropsResult ViewAuctionPropsResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 搜索拍卖行物品
struct SearchAuctionProps
{ 
    static const Type kType = kSearchAuctionProps;
    uint16_t page;          // 页数，从1开始
    uint8_t sort;           // 排序方式，1竞拍价（默认），2一口价，3剩余时间
    uint8_t order;          // 顺序，0从大到小，1从小到大
    uint8_t kind;           // 物品种类 1装备，2道具，3材料
    uint8_t type;           // 类型 0不限
    uint8_t level;          // 等级 0不限
    uint8_t quality;        // 品质 0不限，1粗糙，2普通，3优秀，4精良，5史诗，6传说
    uint8_t addition;       // 是否有附加属性
    uint8_t addition1;      // 0不限，1力量，2敏捷，3智力，4暴击
    uint8_t addition2;      // 0不限，1力量，2敏捷，3智力，4暴击
    uint8_t addition3;      // 0不限，1力量，2敏捷，3智力，4暴击
};
typedef struct SearchAuctionProps SearchAuctionProps;

struct SearchAuctionPropsResult
{ 
    static const Type kType = kSearchAuctionPropsResult;
    Result result;
    uint16_t page;  //总页数
    uint16_t count;
    AuctionProps list[11];
};
typedef struct SearchAuctionPropsResult SearchAuctionPropsResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 玩家拍卖行记录
struct TradeRecord
{
    uint32_t kind;              // 道具表sid
    uint32_t status;            // 交易完成状态， 0=未卖出 1=已卖出 2=竞拍成功 3=一口价购买 // 交易中记录，此值为起拍价，如果为0表示交易类型为正在竞拍
    uint32_t price;             // 成交金额
    uint32_t amount;            // 道具数量
    uint32_t time;              // 完成时间
};
typedef struct TradeRecord TradeRecord;

struct AuctionRecord
{ 
    static const Type kType = kAuctionRecord;
    uint8_t type;       // 1交易中，2交易完成
};
typedef struct AuctionRecord AuctionRecord;

struct AuctionRecordResult
{ 
    static const Type kType = kAuctionRecordResult;
    Result result;
    uint32_t count;
    TradeRecord list[256];
};
typedef struct AuctionRecordResult AuctionRecordResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////

// 获取物品详细信息
struct AuctionPropsDetail
{ 
    static const Type kType = kAuctionPropsDetail;
    uint32_t id;  // 拍卖行物品ID
};
typedef struct AuctionPropsDetail AuctionPropsDetail;

struct AuctionPropsDetailResult
{ 
    static const Type kType = kAuctionPropsDetailResult;
    Result result;
};
typedef struct AuctionPropsDetailResult AuctionPropsDetailResult;

//////////////////////////////////////////////////////////////////////////////////////////////////////


//拍卖行主动推送

struct AuctionPriceChange // 价格改变
{ 
    static const Type kType = kPushAuctionPriceChange;
    uint32_t id;           // 拍卖行物品ID
    uint32_t current;      // 当前竞拍价
    uint32_t time;         // 拍卖结束时间
};
typedef struct AuctionPriceChange AuctionPriceChange;

struct AuctionAppend // 加入物品
{ 
    static const Type kType = kPushAuctionAppend;
    AuctionProps prop;      // 拍卖行物品
};
typedef struct AuctionAppend AuctionAppend;

struct AuctionDelete // 物品删除
{ 
    static const Type kType = kPushAuctionDelete;
    uint32_t id;           // 拍卖行物品ID
};
typedef struct AuctionDelete AuctionDelete;

struct AuctionFailed // 竞拍失败
{ 
    static const Type kType = kPushAuctionFailed;
    uint32_t kind;              // 道具表sid
};
typedef struct AuctionFailed AuctionFailed;
