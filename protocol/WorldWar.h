enum
{
    //前端消息范围
    kWorldWarGateBegin  = kPVPTypeBegin + 300,          // 12300
    kWorldWarGateEnd    = kPVPTypeBegin + 400,
    
    //前端消息返回范围
    kWorldWarGateReturnBegin  = kPVPReturnBegin + 300,          // 18300
    kWorldWarGateReturnEnd    = kPVPReturnBegin + 400,
    
    //跨服国战前端消息
    kGetWorldWarBaseInfo = kWorldWarGateBegin + 1,          // 12301
    kGetWorldWarReport   = kWorldWarGateBegin + 2,
    kGetWorldWarShopInfo = kWorldWarGateBegin + 3,
    kGetWorldWarNews     = kWorldWarGateBegin + 4,
    kGetWorldWarRecord   = kWorldWarGateBegin + 5,
    kSetWorldWarAuto     = kWorldWarGateBegin + 6,
    kSetWorldWarVote     = kWorldWarGateBegin + 7,
    kEnterWorldWarMap    = kWorldWarGateBegin + 8,
    kLeaveWorldWarMap    = kWorldWarGateBegin + 9,
    kMoveRoadInMap       = kWorldWarGateBegin + 10,
    kGetWorldWarTop      = kWorldWarGateBegin + 11,
    kGetWorldWarReward   = kWorldWarGateBegin + 12,
    kClearWorldWarCD     = kWorldWarGateBegin + 13,
    kBuyWorldWarProps    = kWorldWarGateBegin + 14,
    kGiveUpWinning       = kWorldWarGateBegin + 15,
    kGetFinalLocation    = kWorldWarGateBegin + 16,
    kAdvancedGradeInfo   = kWorldWarGateBegin + 17,

    //跨服国战前端消息返回
    kGetWorldWarBaseInfoResult = kWorldWarGateReturnBegin + 1,          // 18301
    kGetWorldWarReportResult   = kWorldWarGateReturnBegin + 2,
    kGetWorldWarShopInfoResult = kWorldWarGateReturnBegin + 3,
    kGetWorldWarNewsResult     = kWorldWarGateReturnBegin + 4,
    kGetWorldWarRecordResult   = kWorldWarGateReturnBegin + 5,
    kSetWorldWarAutoResult     = kWorldWarGateReturnBegin + 6,
    kSetWorldWarVoteResult     = kWorldWarGateReturnBegin + 7,
    kEnterWorldWarMapResult    = kWorldWarGateReturnBegin + 8,
    kLeaveWorldWarMapResult    = kWorldWarGateReturnBegin + 9,
    kMoveRoadInMapResult       = kWorldWarGateReturnBegin + 10,
    kGetWorldWarTopResult      = kWorldWarGateReturnBegin + 11,
    kGetWorldWarRewardResult   = kWorldWarGateReturnBegin + 12,
    kClearWorldWarCDResult     = kWorldWarGateReturnBegin + 13,
    kBuyWorldWarPropsResult    = kWorldWarGateReturnBegin + 14,
    kGiveUpWinningResult       = kWorldWarGateReturnBegin + 15,
    kGetFinalLocationResult    = kWorldWarGateReturnBegin + 16,
    kAdvancedGradeInfoResult   = kWorldWarGateReturnBegin + 17,
    
    //跨服国战前端消息推送
    kPushWorldWarLocationChange = kWorldWarGateReturnBegin + 20,            // 18320
    kPushWorldWarMapChange      = kWorldWarGateReturnBegin + 21,
    kPushAutoFightingStatus     = kWorldWarGateReturnBegin + 22,
    kPushLocationTransmit       = kWorldWarGateReturnBegin + 23,
    kPushMapVoteChange          = kWorldWarGateReturnBegin + 24,
    kPushWorldWarBegin          = kWorldWarGateReturnBegin + 25,
    kPushStartNewDay            = kWorldWarGateReturnBegin + 26,
    kPushWorldWarReport         = kWorldWarGateReturnBegin + 27,
    kPushWorldWarNotice         = kWorldWarGateReturnBegin + 28,
    
    
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    
    //服务器间内部通信范围
    kWorldWarInnerBegin = kPVPTypeBegin + 400,
    kWorldWarInnerEnd   = kPVPTypeBegin + 500,
    
    //服务器间内部通信返回范围
    kWorldWarInnerReturnBegin = kPVPReturnBegin + 400,
    kWorldWarInnerReturnEnd   = kPVPReturnBegin + 500,
    
    // 服务器间内部通信（发送给World的消息）
    kGetPlayerGroup        = kWorldWarInnerBegin + 1,
    kCheckPlayerGold       = kWorldWarInnerBegin + 2,
    kAddWorldWarProp       = kWorldWarInnerBegin + 3,
    kServerHeartBeat       = kWorldWarInnerBegin + 4,
    kAdvancedGradeResult   = kWorldWarInnerBegin + 5,
    kRemoteMethodCall      = kWorldWarInnerBegin + 6,
    
    // 发送给国战的消息（写在这里是为了跳过对kWorldWarInnerReturnBegin的拦截，直接发送到玩家对象上）
    kPushUserCommonInfo    = kWorldWarInnerBegin + 11,
    kPushPlayerInfoChanged = kWorldWarInnerBegin + 12,
    
    // 服务器间内部通信（发送给国战的消息）
    kGetPlayerGroupResult  = kWorldWarInnerReturnBegin + 1,
    kCheckPlayerGoldResult = kWorldWarInnerReturnBegin + 2,
    kAddWorldWarPropResult = kWorldWarInnerReturnBegin + 3,
    kServerHeartBeatResult = kWorldWarInnerReturnBegin + 4,
    kGetAdvancedGrade      = kWorldWarInnerReturnBegin + 5,
    
    kPushServerInfo        = kWorldWarInnerReturnBegin + 11,
};

enum WorldWarResultType
{
    WorldWarResultBegin        = 12300,
    WORLD_WAR_SUCCESS          = WorldWarResultBegin + 1,            // 成功（占位用，成功依然返回0）
    WORLD_WAR_NOT_ACTIVATE     = WorldWarResultBegin + 2,            // 尚未激活功能
    WORLD_WAR_NOT_ENOUGH_VOTE  = WorldWarResultBegin + 3,            // 已经投过票了
    WORLD_WAR_INVALID_MAP      = WorldWarResultBegin + 4,            // 不正确的地图ID
    WORLD_WAR_INVALID_LOCATION = WorldWarResultBegin + 5,            // 不正确的路点ID
    WORLD_WAR_INVALID_PAGE     = WorldWarResultBegin + 6,            // 不正确页数
    WORLD_WAR_NO_ENOUGH_GOLD   = WorldWarResultBegin + 7,            // 金币不足
    WORLD_WAR_HAVE_CD_TIME     = WorldWarResultBegin + 8,            // 战斗冷却中
    WORLD_WAR_NO_NEED_CLEAR_CD = WorldWarResultBegin + 9,            // 不需要清除CD
    WORLD_WAR_NO_MORE_TIMES    = WorldWarResultBegin + 10,           // 没有战斗次数了
    WORLD_WAR_INVALID_PROPS    = WorldWarResultBegin + 11,           // 无效的道具ID
    WORLD_WAR_NO_MORE_SCORE    = WorldWarResultBegin + 12,           // 积分不足
    WORLD_WAR_BAG_FULL         = WorldWarResultBegin + 13,           // 背包空间不足
    WORLD_WAR_NO_TOP_RANK      = WorldWarResultBegin + 14,           // 还没有刷新排名
    WORLD_WAR_NO_ENOUGH_DATA   = WorldWarResultBegin + 15,           // 没有足够的玩家
    WORLD_WAR_CANT_ATTACK_BORN = WorldWarResultBegin + 16,           // 不能进攻对方出生点
    WORLD_WAR_NOT_ON_THE_MAP   = WorldWarResultBegin + 17,           // 玩家还没有进入地图
};


//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// 下面是国战系统

struct TerritoryInfo
{
    uint8_t map;
    uint8_t country;
    uint16_t vote;
};
typedef struct TerritoryInfo TerritoryInfo;

struct GetWorldWarBaseInfo // 获取国战基本信息 c2s
{
    static const Type kType = kGetWorldWarBaseInfo;
};
typedef struct GetWorldWarBaseInfo GetWorldWarBaseInfo;

struct GetWorldWarBaseInfoResult // 获取国战基本信息 s2c
{
    static const Type kType = kGetWorldWarBaseInfoResult;
    Result result;          // 
    uint32_t server_time;   // 跨服服务器时间，用来同步
    uint32_t score;         // 国家贡献
    uint32_t point;         // 战场点数
    uint32_t time;          // CD时间
    uint8_t count;          // 剩余战斗次数
    uint8_t robot;          // 个位为是否自动参战，十位为自动参战场次
    int8_t vote;            // 正数为已经投票的地图ID，负数代表玩家未投票，且绝对值为投票权重
    uint8_t first;          // 是否第一次国战，如果是第一次，则只能投票，没有可以攻打的区域；并且此时不能查询战场达人
    TerritoryInfo list[10]; // 领地归属信息（不包括主城）
};
typedef struct GetWorldWarBaseInfoResult GetWorldWarBaseInfoResult;

//////////////////////////////////////////////////////////////////////////
struct WorldWarReport
{
    uint8_t count;     // 战胜人数
    uint8_t score;     // 获得积分奖励
    uint8_t prestige;  // 获得威望奖励
    uint8_t map;       // 战斗地图
    uint32_t time;     // 发生时间
};
typedef struct WorldWarReport WorldWarReport;

struct GetWorldWarReport // 获取个人战报 c2s
{
    static const Type kType = kGetWorldWarReport;
};
typedef struct GetWorldWarReport GetWorldWarReport;

struct GetWorldWarReportResult // 获取个人战报 s2c
{
    static const Type kType = kGetWorldWarReportResult;
    Result result;          // 
    uint32_t count;         // 数组实际个数
    WorldWarReport list[50];       // 按照时间顺序排列
};
typedef struct GetWorldWarReportResult GetWorldWarReportResult;

//////////////////////////////////////////////////////////////////////////

struct WorldWarProp
{
    uint32_t id;        // 道具SID，参看商店表
};
typedef struct WorldWarProp WorldWarProp;

struct GetWorldWarShopInfo // 获取国战商店信息 c2s
{
    static const Type kType = kGetWorldWarShopInfo;
};
typedef struct GetWorldWarShopInfo GetWorldWarShopInfo;

struct GetWorldWarShopInfoResult // 获取国战商店信息 s2c
{
    static const Type kType = kGetWorldWarShopInfoResult;
    Result result;          // 
    uint32_t count;
    WorldWarProp list[150];         // 可购买道具
};
typedef struct GetWorldWarShopInfoResult GetWorldWarShopInfoResult;

//////////////////////////////////////////////////////////////////////////

struct FightingInfo
{
    uint8_t map;            // 地图ID
    uint8_t attack;         // 攻击方
    uint8_t defend;         // 防守方
    uint8_t progress;       // 进攻进度 0 - 100
};
typedef struct FightingInfo FightingInfo;

struct GetWorldWarNews // 获取国战新闻 c2s
{
    static const Type kType = kGetWorldWarNews;
};
typedef struct GetWorldWarNews GetWorldWarNews;

struct GetWorldWarNewsResult // 获取国战新闻 s2c
{
    static const Type kType = kGetWorldWarNewsResult;
    Result result;          // 
    uint8_t count1;         // 国家1领地数量
    uint8_t count2;         // 国家2领地数量
    uint8_t count3;         // 国家3领地数量
    uint8_t count;          // list数量
    FightingInfo list[3];   // 战场情况
};
typedef struct GetWorldWarNewsResult GetWorldWarNewsResult;

//////////////////////////////////////////////////////////////////////////

struct ContentionInfo
{
    uint32_t time;          // 时间
    uint8_t map;            // 地图ID
    uint8_t attack;         // 攻击方
    uint8_t defend;         // 防守方
    uint8_t type;           // 发生事件，0投票完成，1进攻完成，2防守完成
};
typedef struct ContentionInfo ContentionInfo;

struct GetWorldWarRecord // 获取国战回放 c2s
{
    static const Type kType = kGetWorldWarRecord;
};
typedef struct GetWorldWarRecord GetWorldWarRecord;

struct GetWorldWarRecordResult // 获取国战回放 s2c
{
    static const Type kType = kGetWorldWarRecordResult;
    Result result;          // 
    uint32_t count;
    ContentionInfo list[3*(3+3)];   // 争夺信息，按照时间顺序
};
typedef struct GetWorldWarRecordResult GetWorldWarRecordResult;

//////////////////////////////////////////////////////////////////////////

struct SetWorldWarAuto // 设置自动参战 c2s
{
    static const Type kType = kSetWorldWarAuto;
};
typedef struct SetWorldWarAuto SetWorldWarAuto;

struct SetWorldWarAutoResult // 设置自动参战 s2c
{
    static const Type kType = kSetWorldWarAutoResult;
    Result result;          // 
    uint8_t status;         // 当前自动参战状态，个位为是否自动参战，十位为自动参战场次
};
typedef struct SetWorldWarAutoResult SetWorldWarAutoResult;

//////////////////////////////////////////////////////////////////////////

struct SetWorldWarVote // 对地区投票 c2s
{
    static const Type kType = kSetWorldWarVote;
    uint8_t map;
};
typedef struct SetWorldWarVote SetWorldWarVote;

struct SetWorldWarVoteResult // 对地区投票 s2c
{
    static const Type kType = kSetWorldWarVoteResult;
    Result result;          // 
};
typedef struct SetWorldWarVoteResult SetWorldWarVoteResult;

//////////////////////////////////////////////////////////////////////////

struct BuyWorldWarProps // 购买物品 c2s
{
    static const Type kType = kBuyWorldWarProps;
    uint32_t id;        // 需要购买的物品ID
};
typedef struct BuyWorldWarProps BuyWorldWarProps;

struct BuyWorldWarPropsResult // 购买物品 s2c
{
    static const Type kType = kBuyWorldWarPropsResult;
    Result result;          // 
    uint32_t point;         // 战场点数
};
typedef struct BuyWorldWarPropsResult BuyWorldWarPropsResult;

//////////////////////////////////////////////////////////////////////////

struct WorldWarLocationInfo
{
    uint8_t location1;      // 路点1 ID
    uint8_t location2;      // 路点2 ID
    uint8_t country;        // 路点国家，路点1用个位，路点2用十位
    uint8_t progress;       // 进攻方进度
};
typedef struct WorldWarLocationInfo WorldWarLocationInfo;

struct EnterWorldWarMap // 进入区域 c2s
{
    static const Type kType = kEnterWorldWarMap;
    uint8_t map;
};
typedef struct EnterWorldWarMap EnterWorldWarMap;

struct EnterWorldWarMapResult // 进入区域 s2c
{
    static const Type kType = kEnterWorldWarMapResult;
    Result result;           // 
    uint8_t is_attack;       // 己方是进攻方为1，否则为0
    uint8_t country;         // 对方国家
    uint8_t location;        // 出生路点【复活点+出生点 随机选择一个】
    uint8_t born_attack;     // 进攻方出生点
    uint8_t born_defend;     // 防守方出生点
    uint8_t progress;        // 进攻方进度
    uint16_t count;          // 
    WorldWarLocationInfo list[1024];     // 路点争夺信息
};
typedef struct EnterWorldWarMapResult EnterWorldWarMapResult;

//////////////////////////////////////////////////////////////////////////

struct LeaveWorldWarMap // 离开地图 c2s
{
    static const Type kType = kLeaveWorldWarMap;
};
typedef struct LeaveWorldWarMap LeaveWorldWarMap;

struct LeaveWorldWarMapResult // 离开地图 s2c
{
    static const Type kType = kLeaveWorldWarMapResult;
    Result result;          // 
};
typedef struct LeaveWorldWarMapResult LeaveWorldWarMapResult;

//////////////////////////////////////////////////////////////////////////

struct MoveRoadInMap // 在地图路点上移动 c2s
{
    static const Type kType = kMoveRoadInMap;
    uint8_t location;
};
typedef struct MoveRoadInMap MoveRoadInMap;

struct MoveRoadInMapResult // 在地图路点上移动 s2c
{
    static const Type kType = kMoveRoadInMapResult;
    Result result;          // 
    uint8_t location;       // 如果和传过来的location不一致，说明战斗完成后需要传送
    uint8_t is_fight;       // 是否发生战斗
    uint8_t victory;        // 1代表胜利，0代表挑战失败
    uint8_t count;          // 剩余次数
    uint16_t score;         // 奖励国家贡献
    uint16_t prestige;      // 奖励威望
    uint32_t time;          // 下次可以挑战时间
    uint16_t winning;       // 连胜次数
    uint16_t fight_record_bytes;
    uint8_t fight_record[kMaxFightRecordLength];       // 战报实际长度以前面的为准， 记录为压缩后的内容
};
typedef struct MoveRoadInMapResult MoveRoadInMapResult;

//////////////////////////////////////////////////////////////////////////

struct WorldWarTop
{
    Nickname nickname;     // 玩家名称
    Nickname server;       // 服务器名称
    uint32_t score;        // 总积分
    uint8_t level;         // 玩家等级
    uint8_t country;       // 玩家国家
    uint16_t rank;         // 玩家排名
};
typedef struct WorldWarTop WorldWarTop;

struct GetWorldWarTop // 战场排行榜 c2s
{
    static const Type kType = kGetWorldWarTop;
    uint16_t page;           // 第几页
};
typedef struct GetWorldWarTop GetWorldWarTop;

struct GetWorldWarTopResult // 战场排行榜 s2c
{
    static const Type kType = kGetWorldWarTopResult;
    Result result;          // 
    uint32_t page_total;    // 总页数
    uint16_t rank;          // 玩家自己排名，不在排行榜则为0
    uint16_t count;         // 数组实际个数
    WorldWarTop list[10];
};
typedef struct GetWorldWarTopResult GetWorldWarTopResult;

//////////////////////////////////////////////////////////////////////////

struct GetWorldWarReward // 领取国战奖励 c2s
{
    static const Type kType = kGetWorldWarReward;
};
typedef struct GetWorldWarReward GetWorldWarReward;

struct GetWorldWarRewardResult // 领取国战奖励 s2c
{
    static const Type kType = kGetWorldWarRewardResult;
    Result result;          // 
};
typedef struct GetWorldWarRewardResult GetWorldWarRewardResult;

//////////////////////////////////////////////////////////////////////////

struct ClearWorldWarCD // 清除战斗CD c2s
{
    static const Type kType = kClearWorldWarCD;
};
typedef struct ClearWorldWarCD ClearWorldWarCD;

struct ClearWorldWarCDResult // 清除战斗CD s2c
{
    static const Type kType = kClearWorldWarCDResult;
    Result result;          // 
};
typedef struct ClearWorldWarCDResult ClearWorldWarCDResult;

//////////////////////////////////////////////////////////////////////////

struct GiveUpWinning // 放弃连战 c2s
{
    static const Type kType = kGiveUpWinning;
};
typedef struct GiveUpWinning GiveUpWinning;

struct GiveUpWinningResult // 放弃连战 s2c
{
    static const Type kType = kGiveUpWinningResult;
    Result result;          // 
};
typedef struct GiveUpWinningResult GiveUpWinningResult;

//////////////////////////////////////////////////////////////////////////

struct GetFinalLocation // 获取最终位置 c2s
{
    static const Type kType = kGetFinalLocation;
};
typedef struct GetFinalLocation GetFinalLocation;

struct GetFinalLocationResult // 获取最终位置 s2c
{
    static const Type kType = kGetFinalLocationResult;
    Result result;         // 
    uint8_t location;      // 新路点【实际位置】
    uint8_t target;        // 期望目标【攻击点】
};
typedef struct GetFinalLocationResult GetFinalLocationResult;

//////////////////////////////////////////////////////////////////////////

struct AdvancedGradeInfo // 获取高级军阶信息 c2s
{
    static const Type kType = kAdvancedGradeInfo;
};
typedef struct AdvancedGradeInfo AdvancedGradeInfo;

struct AdvancedGradeInfoResult // 获取高级军阶信息 s2c
{
    static const Type kType = kAdvancedGradeInfoResult;
    Result result;        // 
    uint32_t score;       // 本周国家贡献
    uint32_t count;       // 本周参与国战总人数
    uint32_t rank;        // 本周国家贡献排名（中午12点刷新）
};
typedef struct AdvancedGradeInfoResult AdvancedGradeInfoResult;







//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// 国战主动推送

struct WorldWarLocationChange // 路点发生了改变 s2c
{
    static const Type kType = kPushWorldWarLocationChange;
    uint8_t map;            
    uint8_t location1;      
    uint8_t location2;      
    uint8_t progress;       // 进攻进度 0 - 100
    uint8_t country;        // 路点国家，路点1用个位，路点2用十位
};
typedef struct WorldWarLocationChange WorldWarLocationChange;

struct WorldWarMapChange // 大地图发生了改变 s2c
{
    static const Type kType = kPushWorldWarMapChange;
    uint8_t map;            
    uint8_t attack;         // 攻击方
    uint8_t defend;         // 防守方
    uint8_t progress;       // 进攻进度 0 - 100，0为防守成功，100为进攻成功 ｛防守成功或者进攻成功需要显示NEW｝
};
typedef struct WorldWarMapChange WorldWarMapChange;

struct AutoFightingStatus // 自动战斗发生 s2c
{
    static const Type kType = kPushAutoFightingStatus;
    uint32_t score;      // 国家贡献
    uint32_t point;      // 战场点数
    uint32_t time;       // 下次可战斗时间【CD】
    uint8_t robot;       // 是否还在自动战斗
    uint8_t count;       // 剩余次数
    uint8_t auto_count;       // 自动战斗进行场次
};
typedef struct AutoFightingStatus AutoFightingStatus;

struct LocationTransmit // 传送至新路点 s2c
{
    static const Type kType = kPushLocationTransmit;
    uint8_t map;
    uint8_t location;      // 新路点【实际位置】
    uint8_t target;        // 期望目标【攻击点】
    uint8_t reason;        // 传送原因，0玩家所处路点被攻陷，1玩家目标点被攻破
};
typedef struct LocationTransmit LocationTransmit;

struct MapVoteChange // 地图投票数量改变 s2c
{
    static const Type kType = kPushMapVoteChange;
    uint8_t map;        // 地图
    uint8_t delta;      // 改变值
    uint16_t vote;      // 投票总数
};
typedef struct MapVoteChange MapVoteChange;

struct WorldWarBegin // 一期国战开始 s2c
{
    static const Type kType = kPushWorldWarBegin;
};
typedef struct WorldWarBegin WorldWarBegin;

struct StartNewDay // 新的一天开始了 s2c
{
    static const Type kType = kPushStartNewDay;
    uint8_t count;          // 剩余战斗次数
};
typedef struct StartNewDay StartNewDay;

struct WorldWarReport_ // 有新的个人战报 s2c ｛收到此消息需要显示NEW｝
{
    static const Type kType = kPushWorldWarReport;
    uint8_t count;     // 战胜人数
    uint8_t score;     // 获得积分奖励
    uint8_t prestige;  // 获得威望奖励
    uint8_t map;       // 战斗地图
    uint32_t time;     // 发生时间
};
typedef struct WorldWarReport_ WorldWarReport_;

struct WorldWarNotice // 走马灯公告 s2c
{
    static const Type kType = kPushWorldWarNotice;
    Nickname nickname;     // 玩家名称
    Nickname server;       // 服务器名称
    uint8_t country;       // 玩家国家
    uint8_t count;         // 玩家连胜次数
};
typedef struct WorldWarNotice WorldWarNotice;











//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// ↓↓↓↓↓↓↓↓ 以下是服务器间内部通信结构，前端不用看 ↓↓↓↓↓↓↓↓

struct ServerInfo // 注册跨服国战 s2s
{
    static const Type kType = kPushServerInfo;
    Nickname name;
};
typedef struct ServerInfo ServerInfo;

struct UserCommonInfo // 玩家常用信息 s2s
{
    static const Type kType = kPushUserCommonInfo;
    uint8_t country;
    uint8_t vip;
    uint8_t grade;
    uint8_t level;
    Nickname name;
};
typedef struct UserCommonInfo UserCommonInfo;

//////////////////////////////////////////////////////////////////////////

struct GetPlayerGroup // 获取玩家 s2s
{
    static const Type kType = kGetPlayerGroup;
    uint16_t id;
};
typedef struct GetPlayerGroup GetPlayerGroup;

struct GetPlayerGroupResult // 获取玩家 s2s
{
    static const Type kType = kGetPlayerGroupResult;
    uint16_t id;
    uint16_t len;
    char str[14*1024];
};
typedef struct GetPlayerGroupResult GetPlayerGroupResult;

//////////////////////////////////////////////////////////////////////////

struct CheckPlayerGold // 扣除玩家金币 s2s
{
    static const Type kType = kCheckPlayerGold;
    uint8_t gold;
};
typedef struct CheckPlayerGold CheckPlayerGold;

struct CheckPlayerGoldResult // 扣除玩家金币 s2s
{
    static const Type kType = kCheckPlayerGoldResult;
    uint8_t succeed;
};
typedef struct CheckPlayerGoldResult CheckPlayerGoldResult;

//////////////////////////////////////////////////////////////////////////

struct AddWorldWarProp // 添加道具 s2s
{
    static const Type kType = kAddWorldWarProp;
    uint32_t kind;              // 道具种类
    uint32_t amount;            // 道具数量
};
typedef struct AddWorldWarProp AddWorldWarProp;

struct AddWorldWarPropResult // 添加道具 s2s
{
    static const Type kType = kAddWorldWarPropResult;
    uint8_t succeed;
};
typedef struct AddWorldWarPropResult AddWorldWarPropResult;

//////////////////////////////////////////////////////////////////////////

struct PlayerInfoChanged // 玩家信息改变 s2s
{
    static const Type kType = kPushPlayerInfoChanged;
    uint8_t type;           // 1 VIP，2 level，3 grade，4 玩家离线 5 次数改变
    uint8_t value;
};
typedef struct PlayerInfoChanged PlayerInfoChanged;

//////////////////////////////////////////////////////////////////////////

struct ServerHeartBeat // 服务器心跳检测 s2s
{
    static const Type kType = kServerHeartBeat;
    uint32_t verify;
};
typedef struct ServerHeartBeat ServerHeartBeat;

struct ServerHeartBeatResult // 服务器心跳检测 s2s
{
    static const Type kType = kServerHeartBeatResult;
    uint32_t verify;
};
typedef struct ServerHeartBeatResult ServerHeartBeatResult;

//////////////////////////////////////////////////////////////////////////

struct AdvancedGrade
{
    uint32_t uid;       // 玩家ID
    uint16_t rank;      // 排名
    uint16_t level;     // 特殊军阶等级
};
typedef struct AdvancedGrade AdvancedGrade;

struct GetAdvancedGrade // 获取特殊军阶列表 s2s
{
    static const Type kType = kGetAdvancedGrade;
};
typedef struct GetAdvancedGrade GetAdvancedGrade;

struct AdvancedGradeResult // 获取特殊军阶列表 s2s
{
    static const Type kType = kAdvancedGradeResult;
    uint32_t total;         // 本周参战人数
    uint32_t count;
    AdvancedGrade list[2048];
};
typedef struct AdvancedGradeResult AdvancedGradeResult;

//////////////////////////////////////////////////////////////////////////

enum WorldWarMethodType
{
    kWorldWarCount1 = 1,        // 国战次数减少
    kWorldWarCount2 = 2,        // 国战次数增加
    kRewardPrestige = 3,        // 国战奖励威望
};

struct RemoteMethodCall // 远程方法调用 s2s
{
    static const Type kType = kRemoteMethodCall;
    uint32_t value;
    uint8_t method;
};
typedef struct RemoteMethodCall RemoteMethodCall;
