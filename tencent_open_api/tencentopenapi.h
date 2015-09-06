#ifndef _TENCENTOPENAPI_H_
#define _TENCENTOPENAPI_H_


#include "mysocket.h"

//为lua调用，设计的C接口

/*
 * 上报用户登录应用时的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_login_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_login_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char* userip,
	const char* svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char* opopenid,
	unsigned int level = 0
	);

/*
 * 上报用户主动注册应用时的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_register_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_register_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char* userip,
	const char* svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char* opopenid
	);

/*
 * 上报用户通过其他好友邀请去注册应用时的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_accept_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_accept_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char* userip,
	const char* svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char* opopenid
	);

/*
 * 上报用户邀请他人注册应用时的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_invite_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_invite_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char* userip,
	const char* svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char* opopenid,
	int touid = 0,
	const char* toopenid = NULL
	);

/*
 * 上报用户在应用中进行支付消费的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_consume_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_consume_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char * userip,
	const char * svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char * opopenid,
	unsigned int modifyfee,
	unsigned int touid = 0,
	const char * toopenid = NULL,
	const char * itemid = NULL,
	const char * itemtype = NULL,
	unsigned int itemcnt = 0,
	unsigned int modifyexp = 0,
	unsigned int totalexp = 0,
	int modifycoin = 0,
	unsigned int totalcoin = 0,
	unsigned int totalfee = 0,
	unsigned int level = 0
	);

/*
 * 上报用户在应用中进行支付充值的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_recharge_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_recharge_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char * userip,
	const char * svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char * opopenid,
	unsigned int modifyfee,
	unsigned int touid = 0,
	const char * toopenid = NULL,
	const char * itemid = NULL,
	const char * itemtype = NULL,
	unsigned int itemcnt = 0,
	unsigned int modifyexp = 0,
	unsigned int totalexp = 0,
	int modifycoin = 0,
	unsigned int totalcoin = 0,
	unsigned int totalfee = 0,
	unsigned int level = 0
	);

/*
 * 上报用户退出应用时的相关信息。非阻塞
 * 参数说明，请参考LY::CTencentOpenAPI::tencentlog_report_quit_for_non_blocking接口
*/
extern "C"
bool tencentlog_report_quit_for_non_blocking_for_c(
	const char * host,
	int port,
	unsigned int appid,
	const char * userip,
	const char * svrip,
	time_t time,
	unsigned int domain,
	unsigned int worldid,
	unsigned int opuid,
	const char * opopenid,
	unsigned int onlinetime,
	unsigned int level = 0
	);

/*
 * 应用调用本接口可判断用户是否安装了“QQ提醒”应用，以及是否在“QQ提醒”中开启了提醒。
 * 参数说明，请参考LY::CTencentOpenAPI::get_is_reminder_set接口
*/
extern "C"
bool get_is_reminder_set_for_c(
    const char * host,
    int port,
	const char * appkey, const char * appid, 
	const char * openkey, const char * openid, const char * pf,
	const char * userip, 
	__out char * error_message,
	int error_message_size,
	__out bool* is_setup,
	__out bool* is_enabled
	);

/*
 * 发送QQ提醒（注意：应用在接入QQ提醒时需要申请接口权限）
 * 发送成功返回true，失败返回false
 * 参数说明，请参考LY::CTencentOpenAPI::set_reminder接口
*/
extern "C"
bool set_reminder_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip, 
	const LY::CTencentOpenAPI::reminder_info* info,
	int info_size,
	char *error_message,
	int error_message_size
	);

/*
 * 发送QQ提醒,此接口为非阻塞
 * 参数info为指向reminder_info结构体的数组首地址
 * 参数info_size，为reminder_info结构体的个数，最大值为3
 * 其他参数说明，请参考LY::CTencentOpenAPI::set_reminder_for_non_blocking接口
*/
extern "C"
bool set_reminder_for_non_blocking_for_c(
    const char * host,
    int port,
	const char * appkey, const char * appid, 
	const char * openkey, const char * openid, const char * pf,
	const char * userip, 
	const LY::CTencentOpenAPI::reminder_info* info,
	int info_size
	);

//以下C接口不需要lua接口---------------------------------

/*
 * 接口功能为获取用户信息，注意：返回值表示是否执行成功
 * 参数说明，请参考LY::CTencentOpenAPI::get_vip_user_info接口
*/
extern "C"
bool get_vip_user_info_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip,
	char *error_message,
	int error_message_size,
	bool *is_yellow_vip,		
	bool *is_yellow_year_vip, 
	int *yellow_vip_level,	
	bool *is_yellow_high_vip,	
	int *yellow_vip_pay_way
	);

/*
 * 验证登录用户是否安装了应用。注意：返回值表示是否执行成功
 * 参数说明，请参考LY::CTencentOpenAPI::get_user_is_setup接口
**/
extern "C"
bool get_user_is_setup_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip,
	char *error_message,
	int error_message_size,
	bool *is_setuped
	);

/*
 * 验证用户的登录态，判断openkey是否过期，没有过期则对openkey有效期进行续期（一次调用续期2小时）。
 * 参数说明，请参考LY::CTencentOpenAPI::get_user_is_login接口
*/
extern "C"
bool get_user_is_login_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip,
	char *error_message,
	int error_message_size,
	bool *is_login
	);

/*
 * 本接口仅适用于多区多服应用，用来验证用户登录态（即验证openkey），以及验证用户是否从选区页面（即验证seqid）进入应用。
 * 参数说明，请参考LY::CTencentOpenAPI::get_is_area_login接口
*/
extern "C"
bool get_is_area_login_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip, const char *seqid,
	char *error_message,
	int error_message_size,
	bool *is_area_login
	);

/*
 * 检查文本中是否存在敏感词，并进行相应的处理：
 * 参数说明，请参考LY::CTencentOpenAPI::check_word_filter接口
*/
extern "C"
bool check_word_filter_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip, 
	const char *content,
	const char *msgid,
	char *message,
	int message_size,
	bool *is_dirty
	);

/*
 * 函数功能为垃圾消息检测
 * 参数说明，请参考LY::CTencentOpenAPI::check_spam_message接口
*/
extern "C"
bool check_spam_message_for_c(
	const char * host,
	int port,
	const char *appkey, const char *appid, 
	const char *openkey, const char *openid, const char *pf,
	const char *userip, 
	const char *ctype,
	const char *content,
	char *error_message,
	int error_message_size,
	bool *is_spiteful_message,
	int *advise_forbidden_time
	);


#endif	//_TENCENTOPENAPI_H_