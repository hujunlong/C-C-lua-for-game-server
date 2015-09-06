#pragma once
#pragma pack(1)

//////////////////////////////////////////////////////////////////////////////////////////////
// 消息类型定义

enum GMessageType
{
	/*
	* 修改玩家基本信息,一次仅允许修改一项,修改值为变动值
	* 当前支持修改信息: gold(金币),silver(银币),energy(能量),mobility(行动力),recharged(充值金币),feat(功绩),
						prestige(威望),arena(竞技场次数),world_war(国战次数),turntable(转盘次数),godwater(神水数量)
						staminatake(携带体力)， boss_section_count(精英boss次数)
	* in:{"type":"silver","value":10}
	* out:{"result": 由GMessageResult定义}
	* aid -->  需修改的玩家ID
	*/
	kModifyPlayerResource = 0,
	
	kGMSystemNotice = 1,
	
	/*
	* 踢人
	* in:int aid 
	* out:int result
	* aid -->  需踢下线的玩家ID
	*/
	kGMKickUser   = 2,		  // 踢人 
	
	/*
	* 封账号
	* in:int aid 
	* out:int result
	* aid -->  需封账号的玩家ID
	*/
	kGMCloseUser  = 3,		  // 封账号
	
	/*
	* 封IP
	* in:int ip 
	* out:int result
	* ip -->  需封锁IP地址
	*/
	kGMCloseIP	= 4,			// 封IP
	
	kGMSendLetter = 5,		  // 发信
	
	/*
	* 聊天关键字设置 
	* in:String keywords,int option
	* out:int result
	* keywords-->每个关键词用逗号分隔的字符串
	* option=1-->不导入已经存在的词语
	* option=2-->使用新的设置覆盖已经存在的词语
	* option=3-->清空当前词表后导入新词语
	*/
	kGMKeywordsSetting = 6,	
	kGMChatMonitor = 7,		 // 实时聊天监控
	kGMGag		= 8,		  // 禁言
	kGMFunctionActivate = 9,	// 系统功能激活
	kGMPropEdit   = 10,		  // 修改玩家道具
	kGMProveAntiAddiction = 11,	//验证防沉迷
	kGMSendMail = 12,			//GM发送系统邮件
	kGMPlayerLogin = 13,		//玩家登录
	kGMPlayerRegister = 14,		//注册
	kGMModifyProp = 15,			//修改<删除道具>
	kGMPlayerExit = 16,			//玩家离线
	kGMNumberOfOnline = 17,		//此时在线玩家数
};

//////////////////////////////////////////////////////////////////////////////////////////////
// 消息返回定义

struct JsonString
{
	uint16_t len;
	char str[10240];
};
typedef struct JsonString JsonString;

enum GMessageResult
{
	kGMSucceced = 0,		  // 成功
	kGMUnknown  = 1,		  // 没有提供这个方法
	kGMJsonFail = 2,		  // JSON解析失败
	kGMInvalid  = 3,		  // 参数无效
	kGMLacked   = 4,		  // 资源不足
	kGMOffline  = 5,		  // 玩家不在线，GM工具自己处理
	kGMInfoError= 6,		  // 提供的信息有误<不能通过防沉迷,未满18或数据有误>
	kGMMailsOverFlow = 7,	  // 此玩家的邮件<带附件的>达到上限,不能向其发送邮件
};

/*
//////////////////////////////////////////////////////////////////////////////////////////////

struct GMSystemNotice // 系统公告
{
	static const Type kType = kGMSystemNotice;	//1
	uint32_t start_time;	//开始时间, 开始时间小于等于结束时间
	uint32_t end_time;		//结束时间, 结束时间必须大于当前时间
	uint32_t interval;		//间隔, 单位为秒
	uint32_t type;			//公告类型	{跑马灯1,	聊天框2,	同时3}
	char*    string;		//公告内容
};
typedef struct GMSystemNotice GMSystemNotice;

struct GMSystemNoticeResult // 系统公告返回
{
	static const Type kType = kGMSystemNotice;
	uint8_t result;	   // enum GMessageResult
};
typedef struct GMSystemNoticeResult GMSystemNoticeResult;

typedef struct  //踢玩家 ，发一个 {}就可以了
{ 
	static const Type kType = kGMKickUser;
}GMKickUser;

struct GMProveAntiAddiction
{
static const Type kType = kGMProveAntiAddiction;
char name[18];			//名字
char IDcard[22];		//身份证号码
};
typedef struct GMProveAntiAddiction GMProveAntiAddiction;

struct GMMailAttach
{
	uint16_t kind;
	uint16_t amount;
};
struct GMSendMail
{
	static const Type kType = kGMSendMail;
	char subject[20];			//长度最多20个字符
	char content[20];			//长度最多1000个字符
	uint8_t attach_amount;		//附件个数,没有附件=0
	GMMailAttach attachs[8];	//最多8个附件
};

struct GMModifyProp
{
	static const Type kType = kGMModifyProp;
	PropID id;		//uint32_t
	uint8_t amount;
};
*/


struct GMPlayerLogin
{
	static const Type kType = kGMPlayerLogin;
	uint32_t loginTime;
	char ipAddress[50];
};
typedef struct GMPlayerLogin GMPlayerLogin;

struct GMPlayerRegister
{
	static const Type kType = kGMPlayerRegister;
	uint32_t registerTime;
	char	 ipAddress[50];
};
typedef struct GMPlayerRegister GMPlayerRegister;

struct GMPlayerExit
{
	static const Type kType = kGMPlayerExit;
	uint32_t online_time;		//此次登录在线时间
};
typedef struct GMPlayerExit GMPlayerExit;

struct GMNumberOfOnline
{
	static const Type kType = kGMNumberOfOnline;
	uint32_t number_of_online;		//当前在线人数
	uint32_t time;					//当前时间
};
typedef struct GMNumberOfOnline GMNumberOfOnline;

#pragma pack()