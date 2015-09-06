/************************************************************************/
/* 
author: liyang                                             
create date: 2013.5.21                                   
*/
/************************************************************************/
#ifndef _MYSOCKET_H_
#define _MYSOCKET_H_

//#include "stdafx.h"

#include <string>
#include <map>
#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/noncopyable.hpp>


using namespace std;

using namespace boost::asio;

#define CRLF "\r\n"
#define UNKNOWN_ERROR "unknown error."

namespace LY
{
	/*
	 * TCP socket类，具有管理功能，无需重新创建此对象，通过重连后又具备收发数据功能
	*/
	class CMySocket: public boost::noncopyable
	{
	public:
		CMySocket();
		virtual ~CMySocket();

		//设置主机地址，可以为域名或IP
		void set_host(const string& host);

		//获取主机地址
		string get_host();

		//设置端口号
		void set_port(int port);

		//获取端口号
		int get_port();

		//连接服务器
		bool connect();

		//如果是异步发送，返回0，同步发送返回实际发送的数据长度
		int send(const string& data, bool is_async = false);

		//同步接收数据，暂不提供异步接收，数据返回到data中
		int recv(string &data);	

		//关闭socket，关闭后不能再处理数据
		void close();

		//是否是域名-------------------------
		static bool is_ip_address(const string& host);

	protected:
		//异步发送数据的回调函数-----------------------
		void write_handler(
			const boost::system::error_code& error, // Result of operation.
			std::size_t bytes_transferred           // Number of bytes sent.
			); 

		//异步接收数据的回调函数-----------------------
		void read_handler(
			const boost::system::error_code& error, // Result of operation.
			std::size_t bytes_transferred           // Number of bytes received.
			); 




	private:
		io_service m_io_service;

		//内部用socket对象
		ip::tcp::socket m_socket;
		
		//保存主机
		string m_host;
		
		//保存端口
		int m_port;
	};

	typedef map<string,string> key_value_pair_map;

	/*
	 * http客户端类，提供管理功能，无需重建对象，同一对象可以反复请求不同页面
	*/
	class CHttpClient: public noncopyable
	{
	public:
		explicit CHttpClient(const string& host, int port = 80);
		virtual ~CHttpClient();
		/*
		 * HTTP GET请求，此接口主要用于请求小数据，返回数据在response_data中
		 * 参数 uri 为 uri地址，注意：uri地址不带http://
		 * 参数 request_parameter为URI参数，形如：a=1&b=2，若没有参数，传空串
		 * 参数 other_head 为其他HTTP头的配对信息
		 * 参数 status_code 为http服务器返回的状态吗，成功一般是200
		 * 参数 response_head 是返回的http响应头数据部分
		 * 参数 response_data 返回的实际数据部分
		 * 返回值如果为false，则表示发送请求失败，为true表示执行http请求成功
	    **/
		bool get_request_for_small_data(const string &uri, const string &request_parameter, const key_value_pair_map &other_head, 
			int& status_code, string& response_head, string& response_data);

		/*
		 * HTTP GET非阻塞请求，不等待返回数据
		 * 成功返回true
		 * 参数参考get_request_for_small_data接口
		*/
		bool get_request_for_non_blocking(const string &uri, const string &request_parameter, const key_value_pair_map &other_head);

		/*
		 * HTTP POST请求
		 * 参数 uri 为 uri地址，注意：uri地址不带http://
		 * 参数 request_data 为请求的数据部分
		 * 参数 other_head 为其他HTTP头的配对信息
		 * 参数 status_code 为http服务器返回的状态吗，成功一般是200
		 * 参数 response_head 是返回的http响应头数据部分
		 * 参数 response_data 返回的实际数据部分
		 * 返回值如果为false，则表示发送请求失败，为true表示执行http请求成功
		*/
		bool post_request(const string &uri, const string &request_data, const key_value_pair_map &other_head, 
			int& status_code, string& response_head, string& response_data);

		/*
		 * HTTP POST非阻塞请求，只有发送，不处理接收
		 * 成功返回true，否则false
		 * 参数 uri 为 uri地址，注意：uri地址不带http://
		 * 参数 request_data 为请求的数据部分
		 * 参数 other_head 为其他HTTP头的配对信息
		*/
		bool post_request_for_non_blocking(const string &uri, const string &request_data, const key_value_pair_map &other_head);


		
		//设置主机地址
		void set_host(const string& host);

		//获取主机地址
		string get_host();
		
		//设置端口号		
		void set_port(int port);
		
		//获取端口号
		int get_port();


	protected:
	private:

		CMySocket m_mysocket;
 
	};

	/*
	 * CTencentOpenAPI类，封装了腾讯开放接口的API
	 * 通过此类直接调用各个接口即可
	*/
	class CTencentOpenAPI
	{
	public:
		CTencentOpenAPI(const string& host, int port = 80): m_host(host), m_port(port)
		{

		}
		virtual ~CTencentOpenAPI()
		{
		}

		/*
		 * 得到签名串
		 * 返回值为签名串
		 * 参数 appkey,由腾讯分配
		 * 参数 request_way，请求方式，值为GET或POST
		 * 参数 uri，uri地址，不包括http://，如：v3/user/get_info
		 * 参数 paramter_pair，参数对
		**/
		static string sign(const string& appkey, const string& request_way, const string& uri, const map<string,string>& paramter_pair);
		
		//url编码，腾讯的url编码规则，与标准有些差异
		static string urlencode(const string& data);

//user interface area begin-----------------

		/*
		 * 接口功能为获取用户信息，注意：返回值表示是否执行成功
		 * 参数appkey 用为签名的密钥。由腾讯分配
		 * 参数appid，应用的唯一ID。由腾讯分配，可以通过appid查找APP基本信息。
		 *
		 * 参数openid，与APP通信的用户key。由平台直接传给应用，应用原样传给平台即可
		 * 从平台跳转到应用时会调用应用的CanvasURL，平台会在CanvasURL后带上本参数
		 * 
		 * 参数openkey,session key，由平台直接传给应用，应用原样传给平台即可
		 * 从平台跳转到应用时会调用应用的CanvasURL，平台会在CanvasURL后带上本参数。
		 *
		 * 参数pf，应用的来源平台。由平台直接传给应用，应用原样传给平台即可
		 * 从平台跳转到应用时会调用应用的CanvasURL，平台会在CanvasURL后带上本参数。由平台直接传给应用，应用原样传给平台即可。
		 * 参数userip，用户的IP地址，不用可以传入空值
		 * 参数error_message，返回的错误信息
		 * 参数is_yellow_vip，返回是否为黄钻用户
		 * 参数is_yellow_year_vip，返回是否为年费黄钻用户
		 * 参数yellow_vip_level，返回黄钻等级。目前最高级别为黄钻8级(如果是黄钻用户才返回此字段)
		 * 参数is_yellow_high_vip，返回是否为豪华版黄钻用户(当pf=qzone、pengyou或qplus时返回)
		 * 参数yellow_vip_pay_way，返回用户的付费类型
		 * 0:非预付费用户(先开通业务后付费，一般指通过手机开通黄钻的用户)
		 * 1:预付费用户(先付费后开通业务，一般指通过Q币Q点、财付通或网银付费开通黄钻的用户)
		*/
		bool get_vip_user_info(const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip,
			__out string& error_message,	
			__out bool& is_yellow_vip,		
			__out bool& is_yellow_year_vip, 
			__out int& yellow_vip_level,	
			__out bool& is_yellow_high_vip,	
			__out int& yellow_vip_pay_way
			);

		/*
		 * 验证登录用户是否安装了应用。注意：返回值表示是否执行成功
		 * 参数userip，用户的IP地址，不用可以传入空值
		 * 参数error_message，返回的错误信息
		 * 参数is_setuped，表示是否安装应用
		 * 其他参数同上
		**/
		bool get_user_is_setup(const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip,
			__out string& error_message,
			__out bool& is_setuped
			);
		/*
		 * 验证用户的登录态，判断openkey是否过期，没有过期则对openkey有效期进行续期（一次调用续期2小时）。
		 * 返回值表示是否执行成功和登录成功
		 * 本接口的调用场景：
		 *（1） 用来验证用户登录态。
		 * 验证登录态的必要性详见这里：技术优化原则#1.3 需要考虑对登录态做校验；
		 * （注：如果是多区多服应用，除调用本接口进行登录态验证外，还需要调用v3/user/is_area_login接口验证是否从选区页面进入应用）。
		 * （2） 用来对openkey进行续期。
		 * 用户登录平台后进入应用时，URL中会带有该用户的OpenID和openkey，该openkey具有2小时的有效期。
		 * 如果用户在应用中一直在操作，但是2小时内没有触发OpenAPI的调用，则会导致openkey过期。
		 * 因此开发者需要调用本接口来对openkey进行续期，一次调用续期2小时。本接口无调用次数限制。
		 * 注：如果由于平台统一刷新登录态导致续期机制失效，
		 * 开发者可调用fusion2.dialog.relogin接口弹出登录弹框让用户登录，重新获得openkey。 
		 * 
		 * 参数userip，用户的IP地址，不用可以传入空值
		 * 参数is_login，返回是否登录成功
		 * 其他参数同上
		*/
		bool get_user_is_login(const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip,
			__out string& error_message,
			__out bool& is_login
			);

		/*
	     * 本接口仅适用于多区多服应用，用来验证用户登录态（即验证openkey），以及验证用户是否从选区页面（即验证seqid）进入应用。
		 * 返回值表示是否执行成功
		 * 多区多服应用中设置有验证用户是否从选区页面进入应用的逻辑，将有助于防止用户直接通过修改应用地址的方式进入应用。
		 * 需要注意的是：
		 *（1）调用本接口后，可以做openkey以及seqid的验证，如果需要对openkey进行续期则需要调用v3/user/is_login。 
		 *（2）用户每次从选区页面登录后生成的seqid具有有效期，只可使用一次，验证一次后就会过期。
		 * 即如果应用使用同样的seqid和参数发送2次请求，第一次返回成功，第二次则会报错。
		 * 
		 * 参数seqid标识单次多区多服登录的特征码，通过该seqid可找到用户登录的唯一记录。由平台直接传给应用，应用原样传给平台即可。
		 * 参数userip，用户的IP地址，不用可以传入空值
		 * 参数is_area_login返回是否登录成功
		 * 其他参数同上
		*/
		bool get_is_area_login(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, const string& seqid,
			__out string& error_message,
			__out bool& is_area_login
			);

		/*
		 * 检查文本中是否存在敏感词，并进行相应的处理：
		 *（1）如果文本中含有高度敏感词汇的时候，则直接返回"文本中有敏感词"，不返回被*替代后的文本；
		 *（2）如果文本中含有其它级别的敏感词汇，则将敏感词替换成*，然后将文本返回。 
		 *注：
		 *（1）文本必须是utf-8编码，否则会导致敏感词不能被过滤。
		 *（2）文本urlencode后的长度不能超过9000，否则会报错。
		 * 参数content，待检查是否存在敏感词的文本。ascii编码
		 *
		 * 参数msgid,留言编号ID。最大长度64字节。务必保证msgid能唯一对应一条消息，该字段属于保留字段，用于后续程序扩展。
		 * 示例：12bbccddeeaabbccddeeaabbccddeeaabbccddee22
		 *
		 * 参数is_dirty，返回true表示有敏感词，false表示没有
		 * 参数message,返回错误信息或敏感词相关信息(由腾讯返回的)
		 * 其他参数同上
		*/
		bool check_word_filter(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, 
			const string& content,
			const string& msgid,
			__out string& message,
			__out bool& is_dirty
			);

		/*
		 * 函数功能为垃圾消息检测
		 * 本接口调用前需申请权限，申请条件及说明详见腾讯官方资料
		 * 垃圾消息检测服务主要是针对webgame类型应用中出现的虚假广告、外挂宣传、私服宣传、工作室代练和线下交易信息、竞品宣传、恶意刷屏等垃圾信息和发言行为进行检测。
		 * 系统会对应用上报的数据进行建模，从文字识别、用户行为分析、信用度体系等各个维度识别垃圾消息，并将检测结果通过本接口返回给应，然后由开发方自行处理，如丢弃、警告、禁言等。
		 * 垃圾消息检测服务的目的是为了抑制游戏内垃圾消息的传播，净化游戏中的言论环境，提高玩家的游戏体验。 
		 * 调用本接口后，将会检查应用中用户的发言、邮件、群组名等信息，对垃圾信息（例如广告、脏话）进行识别。
		 * 如果包含有垃圾信息，则给出建议的禁言时长，应用可自行进行相应的处理。
		 * 参数ctype，表示用户信息输入的途径。		 
		 *	 1：表示聊天；
		 *	 2：表示邮件；
		 *	 3：表示游戏中的角色名；
		 *	 4：表示其他类型，如sns游戏中的留言板等。
		 * 参数content，待检查是否存在垃圾信息的文本。
		 * 参数is_spiteful_message，返回值，标识用户输入的信息是否有恶意信息（0：正常； 1：有恶意信息）。
		 * 参数advise_forbidden_time，返回值，0：表示用户输入的信息中没有恶意信息，不用进行任何处理；
		 * 大于0：表示用户输入的信息中含有恶意信息，建议对该用户禁言，数值表示建议的禁言时长，以秒为单位。
		 * 其他参数同上
		*/
		bool check_spam_message(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, 
			const string& ctype,
			const string& content,
			__out string& error_message,
			__out bool& is_spiteful_message,
			__out int& advise_forbidden_time
			);
		/*
		 * 应用调用本接口可判断用户是否安装了“QQ提醒”应用，以及是否在“QQ提醒”中开启了提醒。
		 * 应用不知道用户是否开启了QQ提醒功能，无法更好地引导用户使用提醒，或借用提醒开展运营活动。
		 * 关于“QQ提醒”开启提醒功能的相关说明，详见：QQ提醒渠道简介。 
		 * 本接口需与后台接口 fusion2.dialog.authReminder 和 v3/spread/set_reminder 配套使用，完成QQ提醒功能。
		 * 注：
		 * 本接口目前只支持QQ空间平台，朋友和微博平台暂不支持。
		 * 
		 * 参数is_setup，返回true表示用户是否安装了“QQ提醒”应用。
		 * 参数is_enabled，返回true表示用户开启了该应用的提醒功能。
		 * 其他参数同上
		*/
		bool get_is_reminder_set(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, 
			__out string& error_message,
			__out bool& is_setup,
			__out bool& is_enabled
			);

		typedef struct _reminder_info
		{
			time_t begin_time;	//提醒开始时间（unix时间戳，指从UTC时间1970年1月1日00:00:00到当前时刻的秒数）。
			int key;			//发送提醒时，应用中某个目标的标识，由应用自定义（如QQ农场提醒用户某块地的果实成熟了，这块地的id即为key的值）。
			int type;			//发送提醒时，提醒的类型，由应用自定义，必须是20000以上的整数。
			char message[128];	//提醒的具体内容，长度限制在30个汉字以内，受限于展示的宽度，建议在20个汉字以内。
		}reminder_info, *preminder_info;
		
		/*
		 * 发送QQ提醒（注意：应用在接入QQ提醒时需要申请接口权限）
		 * 成功返回true
		 * QQ提醒信息上报接口，可一次上报多条数据（详见参数说明中关于X的规定）。
		 * 应用获得用户授权后，向用户发送提醒，适用于有冷却时间玩法的应用场景，以拉取回流用户，详见：QQ提醒渠道简介。
		 * 本接口需与接口 fusion2.dialog.authReminder 和 v3/spread/is_reminder_set 配套使用，完成QQ提醒功能。
		 * 注：
		 * 本接口目前只支持QQ空间平台，朋友和微博平台暂不支持。
		 * 最多可以设置3条提醒信息
		*/
		bool set_reminder(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, 
			const vector<reminder_info>& info,
			__out string& error_message
			);

		/*
		 * 发送QQ提醒,功能同set_reminder一样，差异在于此接口为非阻塞
		 * 并且无返回信息
		*/
		bool set_reminder_for_non_blocking(
			const string& appkey, const string& appid, 
			const string& openkey, const string& openid, const string& pf,
			const string& userip, 
			const vector<reminder_info>& info
			);

//user interface area end--------------------------------

//tencent log interface begin-----------------------------
		
		/*
		 * 上报用户登录应用时的相关信息。非阻塞
		 * 参数appid,应用的唯一标识。AppID在创建应用时分配。
		   可以通过APPID查找APP基本信息。
		   在调用OpenAPI的时候，AppID表明应用身份。
	     * 参数userip,用户机器的ip地址
		 * 参数svrip,这里的IP为当前处理用户请求的机器(cgi或者是server)IP, 请使用主机字节序，用来识别请求来源。
		   -hosting应用，请传内网IP；
		   -non-hosting应用，请传外网IP。
	     * 参数time,当前用户的操作时间，精确到秒，填入UNIX时间戳。
		 * 参数domain,表示APP所在平台，用于区分用户从哪个业务平台进入应用： 
			 QQ空间为1；
			 腾讯朋友为2；
			 腾讯微博为3；
			 Q+平台为4；
			 手机QQ空间为8；
			 手机腾讯朋友为9；
			 QQGame为10；
			 3366为11；
			 QQGame官网为12；
			 漫游为15；
			 游戏人生为16；
			 游戏联盟为17；
			 例如：用户从腾讯朋友进入了该应用，则参数值应传2。
		 * 参数worldid,非多区多服应用，这里填1。
			 多区多服应用，这里填大区服务器ID。大区服务器ID即新建服务器时自动分配的域名中的serverid。
			 登录腾讯开放平台（open.qq.com）后进入“我的管理中心”，在“选区配置”tab下新增服务器成功后，即以自增方式自动为该服务器分配了一个域名，域名格式如下：
			 s$serverid$.app$appid$.qqopenapp.com 
			 例如：
			 s3.app12345.qqopenapp.com
			 serverid即大区服务器的ID，这里s3后面的3即大区服务器ID。
		 * 参数opuid,操作者的UID，例如A偷了B的菜，这里填A的UID。
			 UID为应用自身的帐号体系中用户的ID，需为int(32)型，但是需以字符串格式传入。
		 * 参数opopenid,操作者的OpenID，例如A偷了B的菜，这里填A的OpenID。OpenID为与QQ号码一一对应的字符串。
		 * 参数level(推荐项),操作用户的等级，即opuid的等级。
		*/
		bool tencentlog_report_login_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid,
			unsigned int level = 0
			);

		/*
		 * 上报用户主动注册应用时的相关信息。非阻塞
		 * 其他参数意义同tencentlog_report_login_for_non_blocking
		*/
		bool tencentlog_report_register_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid
			);

		/*
		 * 上报用户通过其他好友邀请去注册应用时的相关信息。非阻塞
		 * 其他参数意义同tencentlog_report_login_for_non_blocking
		*/
		bool tencentlog_report_accept_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid
			);

		/*
		 * 上报用户邀请他人注册应用时的相关信息。非阻塞
		 * 参数touid(推荐项)，被邀请者的UID，例如B邀请A去注册某个应用，这里填A的UID。
		   UID为应用自身的帐号体系中用户的ID，需为int(32)型，但是需以字符串格式传入。
		 * 参数toopenid(推荐项)，被邀请者的OpenID，例如B邀请A去注册某个应用，这里填A的OpenID。
		   特别地，如果用户一次邀请多个用户，请上报多条数据。
		   OpenID为与QQ号码一一对应的字符串。
		 * 其他参数意义同tencentlog_report_login_for_non_blocking
		*/
		bool tencentlog_report_invite_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid,
			int touid = 0,
			const string& toopenid = ""
			);

		/*
		* 上报用户在应用中进行支付消费的相关信息。非阻塞
		* 支付消费：
		* 用户通过Q点/Q币直接购买游戏内商品的行为；
		* 或用户通过游戏内的等值货币(例如“点券/金币/元宝”等)来购买游戏内商品的行为。
		* 
		* 参数modifyfee，游戏币变化值。
		  用户进行操作后，游戏币的变化值。如果没有变化，则填0。上报单位为Q分（100Q分 = 10Q点 = 1Q币）。
		  游戏币为用户通过人民币或者Q点/Q 币兑换的游戏内等值货币(例如“点券/金币/元宝”等)，在游戏内具有真实的价值，可用于购买游戏内商品。
		  例如：
		  (1)某用户通过Q币直购游戏内商品，消费10Q币，则记入1000。
		  (2)某用户通过点券(游戏币)购买游戏内商品，消费10点券(1Q币=100点券)，则记入100。
		  (3)某用户通过Q币兑换点券(游戏币)，消费10Q币，则记入1000。
		* 参数touid（推荐项），在赠送支付时对方的UID，例如A给B用户购买某个道具，则填写B用户的UID。
		  UID为应用自身的帐号体系中用户的ID，需为int(32)型，但是需以字符串格式传入。
		* 参数toopenid（推荐项），在赠送支付时对方的OpenID，例如A给B用户购买某个道具，则填写B用户的OpenID。
		  特别地，如果用户一次操作有多个被操作的用户，请上报多条数据。
		  OpenID为与QQ号码一一对应的字符串。
		* 参数itemid（推荐项），用户操作物品ID。
		  例如用户A购买了物品X，这里填X的物品ID。
		  特别地，如果用户一次操作有多个被操作item，请上报多条数据。
		* 参数itemtype（推荐项），用户操作物品ID的分类。
		* 参数itemcnt（推荐项），用户操作物品的数量。
		  例如用户A购买了a个物品X，这里填a。
		* 参数modifyexp（推荐项），用户进行操作后，经验值的变化值。
		  例如购买道具后经验增加300，则填入300。
		* 参数totalexp（推荐项），用户进行操作后，经验值的总量。
		  例如用户经验1000，购买了某物品，经验值增加100，此处填入1100。
		* 参数modifycoin（推荐项），用户进行操作后，游戏虚拟金币的变化值。
		  例如用户购买道具后，虚拟金币减少3000，则填入-3000。
		* 参数totalcoin（推荐项），用户进行操作后，虚拟金币的总量。
		  例如用户拥有虚拟金币100，购买了某物品，消耗虚拟金币10，此处填入90。
		* 参数totalfee（推荐项），用户进行操作后，游戏币的总量。
		  例如用户拥有游戏币100，购买了某物品，消耗游戏币10，此处填入90。
		* 参数level（推荐项），操作用户的等级，即opuid的等级。
		* 其他参数同tencentlog_report_login_for_non_blocking
		*/
		 
		bool tencentlog_report_consume_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid,
			unsigned int modifyfee,
			unsigned int touid = 0,
			const string& toopenid = "",
			const string& itemid = "",
			const string& itemtype = "",
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
		   支付充值：
		   用户通过Q点/Q币兑换游戏内等值货币(例如“点券/金币/元宝”)的行为。
		 * 参数touid（推荐项），在充值时对方的UID，例如A给B用户充值，则填写B用户的UID。
		   UID为应用自身的帐号体系中用户的ID，需为int(32)型，但是需以字符串格式传入。
		 * 参数toopenid（推荐项），在充值时对方的OpenID，例如A给B用户充值，则填写B用户的OpenID。
		   特别地，如果用户一次操作有多个被操作的用户，请上报多条数据。
		   OpenID为与QQ号码一一对应的字符串。
		 * 参数itemid（推荐项），用户操作物品ID。
		   例如用户A兑换了游戏内的元宝，这里填元宝的ID。
		   特别地，如果用户一次操作有多个被操作item，请上报多条数据。
		 * 参数itemtype（推荐项），用户操作物品ID的分类。
		 * 参数itemcnt（推荐项），用户操作物品的数量。
		   例如用户A购买了a个物品X，这里填a。
		 * 参数modifyexp（推荐项），用户进行操作后，经验值的变化值。
		   例如兑换元宝后经验增加300，则填入300。
		 * 参数totalexp（推荐项），用户进行操作后，经验值的总量。
		   例如用户经验1000，兑换了元宝后，经验值增加100，此处填入1100。
		 * 参数modifycoin（推荐项），用户进行操作后，游戏虚拟金币的变化值。
		   例如用户兑换金币后，虚拟金币增加3000，则填入3000。
		 * 参数totalcoin（推荐项），用户进行操作后，虚拟金币的总量。
		   例如用户拥有虚拟金币100，通过Q点/Q币兑换了10个金币，此处填入110。
		 * 参数totalfee（推荐项），用户进行操作后，游戏币的总量。
		   例如用户拥有游戏币100，购买了某物品，消耗游戏币10，此处填入90。
		 * 参数level（推荐项），操作用户的等级，即opuid的等级。
	     * 其他参数同tencentlog_report_consume_for_non_blocking接口
		*/
		bool tencentlog_report_recharge_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid,
			unsigned int modifyfee,
			unsigned int touid = 0,
			const string& toopenid = "",
			const string& itemid = "",
			const string& itemtype = "",
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
		 * 参数onlinetime，用户本次登录的在线时长。
		 * 参数level，操作用户的等级，即opuid的等级。
		 * 其他参数同tencentlog_report_login_for_non_blocking接口
		*/
		bool tencentlog_report_quit_for_non_blocking(
			unsigned int appid,
			const string& userip,
			const string& svrip,
			time_t time,
			unsigned int domain,
			unsigned int worldid,
			unsigned int opuid,
			const string& opopenid,
			unsigned int onlinetime,
			unsigned int level = 0
			);

//tencent log interface end-----------------------------

		//设置主机地址
		void set_host(const string& host);

		//设置端口号
		void set_port(int port);


	protected:
		/*
		 * 解析http服务器的json返回数据，只解析数据部分
		 * 成功返回true，返回值在data_pair中
		**/
		bool parse_http_response_json_data(const string& response_data, __out map<string,string>& data_pair);

		/*
		 * 编码键值对的值并返回参数连接，如:a=1&b=%2D，注意：只对值进行编码
		**/
		string encode_value_of_pair_and_join(const map<string,string>& paramter_pair);

	private:
		//保存主机
		string m_host;

		//保存端口
		int m_port;
		
		

	};





}	//namespace LY



#endif	//_MYSOCKET_H_