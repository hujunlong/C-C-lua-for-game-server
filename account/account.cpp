#include <iostream>
#include <map>
#include <zmq.hpp>
#include <mysql++.h>
#include "../protocol/db.h"
#include "../system/db_helper.h"
#include "../tools/string.h"
#include "../protocol/internal.h"
#include "account.h"
#include "check_card.h"


//防沉迷信息记录
struct UserRecord
{
	uint32_t record_time;		//上次记录在线时间
	uint32_t update_time;		//更新时间
	uint32_t login_time;		//登录时间
	uint32_t logout_time;
	uint32_t online_time;
	int8_t	 b_anti;			//=1, 启用防沉迷
	int8_t   b_online;
	int8_t   online_hours;
	int8_t   b_kick;			//被踢出
	int8_t   b_enable;			//是否允许登录
	//
	UserRecord()
	{
		record_time = 0;
		update_time = 0;
		login_time = 0;
		logout_time = 0;
		online_time = 0;
		b_anti = 1;
		b_online = 0;
		online_hours = 0;
		b_kick = 0;
		b_enable = 1;
	}
};

//数据库操作
class DbSession
{
private:
	mysqlpp::Connection conection_;
public:
	//初始化
	bool Init(const char* cfg_file)
	{
		return InitConnection(conection_, cfg_file);
	}
	//判断id是否存在
	bool DoHaveTheUserID( UserID uid )
	{
		char sql[256];
		sprintf(sql, "select player from `base_info` where player=%d limit 1", uid);
		auto res = QueryRead(conection_, sql);
		if (res && !res.empty())
		{
			return true;
		}

		return false;
	}
	//昵称存在
	bool DoNicknameExist(Nickname& name)
	{
		char sql[256];
		if(name.len>sizeof(name.str))
			return false;
		char tmpname[sizeof(name.str)*2+2];
		conection_.driver()->escape_string(tmpname, name.str, name.len);
		sprintf(sql, "select player from base_info where nickname=\"%s\"", tmpname);
		auto res = QueryRead(conection_, sql);
		if (res && !res.empty())
			return true;
		return false;
	}
	//注册
	bool DoRegister( InternalRegister& reg , InternalRegisterResult& r_res )
	{
		char sql[256];
		if( reg.name.len > sizeof(reg.name.str) || reg.sex>1 || reg.sex<0 )
		{
			r_res.result = (Result)p::RegisterResult::Result::kInvalidValue;
			return false;
		}
		char tmp_nickname[sizeof(reg.name.str)*2+2];
		conection_.driver()->escape_string(tmp_nickname, reg.name.str, reg.name.len);

		if(strlen(tmp_nickname)<9)
		{
			r_res.result = (Result)p::RegisterResult::Result::kInvalidValue;
			return false;
		}

		sprintf(sql, "call create_player(%d,\"%s\",%d)", reg.uid, tmp_nickname, reg.sex);
		auto res = QueryRead(conection_, sql);
		if (res && !res.empty())
		{
			int32_t result = res[0]["result"];
			if ( result == 1 )
			{
				r_res.result = (Result)p::RegisterResult::Result::kSucceeded;
				return true;
			}else if( result == 2 )
			{
				r_res.result = (Result)p::RegisterResult::Result::kUidExist;
				return false;
			}else
			{
				r_res.result = (Result)p::RegisterResult::Result::kNicknameExist;
				return false;
			}
		}else
		{
			r_res.result = (Result)p::RegisterResult::Result::kFailed;
			return false;
		}
		return false;
	}
	//获取账户信息
	bool DoGetUserAccountInfo( UserID uid, UserRecord& ur )
	{
		char sql[256];
		sprintf(sql, "select * from `anti_addiction` where player=%d limit 1", uid);
		auto res = QueryRead(conection_, sql);
		if (res && !res.empty())
		{
			auto& row = res[0];
			ur.b_anti = row["b_anti"];
			if( ur.b_anti==1 )
			{
				ur.online_time = row["online_time"];
				ur.logout_time = row["logout_time"];
			}
		}else
			return false;
		res.clear();
		sprintf(sql,"select `enable` from account where player=%d", uid);
		res = QueryRead(conection_, sql);
		if( res && !res.empty() )
		{
			auto& row = res[0];
			ur.b_enable = row["enable"];
		}else
			return false;
		return true;
	}
	//更新信息
	bool DoUpdateAntiAddictionInfo( UserID uid, UserRecord& ur)
	{
		char sql[256];
		sprintf(sql, "update `anti_addiction` set online_time=%d,logout_time=%d where player=%d limit 1",
			ur.online_time, ur.logout_time, uid);
		QueryWrite(conection_, sql);
		return true;
	}
	//重置防沉迷
	bool DoResetAntiAddictionInfo()
	{
		char sql[256];
		sprintf(sql, "update `anti_addiction` set online_time=0");
		QueryWrite(conection_, sql);
		return true;
	}
	//防沉迷信息
	bool DoProveAntiAddictionInfo(UserID uid, InternalProveAntiAddictionInfo& paa)
	{
		char sql[256];

		char tmp_name[sizeof(paa.name)*2+2];
		conection_.driver()->escape_string(tmp_name, paa.name, paa.name_len);

		char tmp_id[sizeof(paa.id)*2+2];
		conection_.driver()->escape_string(tmp_id, paa.id, paa.id_len);

		sprintf(sql, "update `anti_addiction` set b_anti=0, name=\"%s\", `id`=\"%s\" where player=%d limit 1",
				tmp_name, tmp_id, uid);
		QueryWrite(conection_, sql);
		return true;
	}
	//记录在线人数
	bool DoRecordNumberOfOnline(uint32_t number_of_online)
	{
		char sql[256];
		sprintf(sql, "insert number_of_online (`time`,amount) value(now(),%d)", number_of_online);
		QueryWrite(conection_, sql);
		return true;
	}
};

namespace
{
	DbSession g_db;
	int16_t  g_yday;		//保存启动时的日期
	uint32_t g_pre_time = 0;	//间隔n秒进行一次在线时间判断

	uint32_t g_online_record_time = 0;		//一段时间内的首次记录时间
	uint32_t g_online_record_count = 0;		//次数
	uint32_t g_number_of_online = 0;		//当前在线人数
	uint32_t g_all_online_in_time = 0;		//一段时间内的在线总人数

	std::map<UserID,UserRecord> g_user;
	typedef std::map<UserID,UserRecord>::iterator It_UserRecord;

	MQNode& GetGateMq()
	{
		static MQNode gate_mq;
		return gate_mq;
	}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg)
	{
		GetGateMq().Send(head, msg);
	}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg, size_t aLen)
	{
		GetGateMq().Send(head.aid, msg.kType, head.flag, msg, aLen);
	}
}

MQNode& GetMQ4GM()
{
	static MQNode gm_mq;
	return gm_mq;
}

void Send2GM(MqHead& head, void* data, int32_t aLen)
{
	GetMQ4GM().Send(head, data, aLen);
}

MQNode& GetMQ4PushGM()
{
	static MQNode gm_mq;
	return gm_mq;
}

void Push2GM(MqHead& head, void* data, int32_t aLen)
{
	GetMQ4PushGM().Send(head, data, aLen);
}

MQNode& CreateMQ2Gate( const char* apAddress )
{
	auto& node =  GetGateMq();
	node.Init(NodeType::kClient, apAddress);
	return node;
}

MQNode& CreateMQ4GM( const char* addr )
{
	auto& mq = GetMQ4GM();
	mq.Init(NodeType::kServer, addr);
	return mq;
}

MQNode& CreateMQ4PushGM(const char* addr)
{
	auto& mq = GetMQ4PushGM();
	mq.Init(NodeType::kClient, addr);
	return mq;
}

bool InitProcessor()
{
	time_t cur_time = time(nullptr);
	tm * p_tm = localtime(&cur_time);
	g_yday = p_tm->tm_yday;
	//
	return g_db.Init("db_cfg.lua");
}


void DoUserLogin( MqHead& h, InternalLogin& login, bool b_anti)
{
	UserRecord ur;
	int32_t i_way = 0;
	//printf("account user login: %d, %08X\n", login.uid, login.serial);
	InternalLoginResult l_res = { (Result)p::LoginReturn::Result::kFailed, login.uid, login.serial };
	if( (g_user.find(login.uid)!=g_user.end()) )
	{
		i_way = 1;
		//禁止登录
		if( g_user[login.uid].b_kick==1 &&
			(g_user[login.uid].logout_time+30)>(uint32_t)time(nullptr) )
		{
			l_res.result = (Result)p::LoginReturn::Result::kBanLogin;
		}else if( g_user[login.uid].b_enable==0 )
			l_res.result = (Result)p::LoginReturn::Result::kBanLogin;
		else
		{
			g_user[login.uid].b_kick = 0;
			l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
		}
	}
	//从数据库判断
	else if( g_db.DoHaveTheUserID(login.uid) )
	{
		i_way = 2;
		l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
	}else
	{
		l_res.result = (Result)p::LoginReturn::Result::kUserIDNotRegistered;
	}
	if( l_res.result==(Result)p::LoginReturn::Result::kSucceeded )
	{
		//
		//验证key
		//
		h.aid = login.uid;
		//
		It_UserRecord it_ur;
		uint32_t cur_time = (uint32_t)time(nullptr);
		//获取数据方式
		if( i_way==1 )
		{
			it_ur = g_user.find( login.uid );
			l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
			//
		}else if( i_way==2 )
		{
			//读取数据
			if( g_db.DoGetUserAccountInfo(login.uid, ur) )
			{
				g_user[login.uid] = ur;
				//是否禁止登录
				if( ur.b_enable==0 )
					l_res.result = (Result)p::LoginReturn::Result::kBanLogin;
				else
				{
					it_ur = g_user.find(login.uid);
					l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
				}
			}else
			{
				l_res.result = (Result)p::LoginReturn::Result::kGetAddictionInfoFailed;
			}
		}
		//
		if( l_res.result == (Result)p::LoginReturn::Result::kSucceeded )
		{
			//不防
			if( it_ur->second.b_anti==0 )
			{
				l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
			}else
			{
				//防沉迷时间
				if( it_ur->second.online_time >= 3*60*60 && (cur_time-it_ur->second.logout_time) < 5*60*60)
				{
					l_res.result = (Result)p::LoginReturn::Result::kInAddictionTime;
				}else
				{
					//时间
					if( it_ur->second.online_time >= 3*60*60 && (cur_time-it_ur->second.logout_time) >= 5*60*60 )
					{
						it_ur->second.online_time = 1;
					}
					it_ur->second.b_online = 0;
					it_ur->second.record_time = cur_time;
					l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
				}
			}
			if( !b_anti )
				l_res.result = (Result)p::LoginReturn::Result::kSucceeded;
		}
	}
	Send2Gate(h, l_res);
}

void DoUserLoginSucceeded( InternalLoginSucceeded& ls )
{
	//printf("uid: %d login succeeded\n",ls.uid);
	It_UserRecord it_ur = g_user.find( ls.uid );
	//
	if( it_ur != g_user.end() )
	{
// 		p::NotifyAntiAddictionInfo aa_info = { it_ur->second.online_time, it_ur->second.b_anti };
// 		MqHead head = { it_ur->first, aa_info.kType, -1 };
// 		Send2Gate(head, aa_info);
		it_ur->second.b_online = 1;
		it_ur->second.online_hours = (int8_t)(it_ur->second.online_time/3600);
		it_ur->second.login_time = it_ur->second.record_time = (uint32_t)time(nullptr);
		
		//
		++g_number_of_online;

		GMPlayerLogin gm;
		gm.loginTime = it_ur->second.record_time;
		gm.ipAddress[0] = 0;
		strcat(gm.ipAddress, ls.ipAddr);
		MqHead head;
		head.aid = ls.uid;
		head.flag = -1;
		head.type = gm.kType;
		SendMsg2GM(head, &gm);
	}
}

void DoUserLogout( InternalLogout& logout )
{
	//printf("uid: %d, logout\n", logout.uid);
	It_UserRecord it_ur = g_user.find( logout.uid );
	//有此玩家,在线
	if( it_ur!=g_user.end() && it_ur->second.b_online==1)
	{
		it_ur->second.b_online = 0;
		it_ur->second.logout_time = (uint32_t)time(nullptr);
		g_db.DoUpdateAntiAddictionInfo(logout.uid, g_user[logout.uid]);
		//
		--g_number_of_online;

		GMPlayerExit gm_exit;
		gm_exit.online_time = it_ur->second.logout_time - it_ur->second.login_time;
		MqHead head;
		head.aid = logout.uid;
		head.flag = -1;
		head.type = gm_exit.kType;
		SendMsg2GM(head, &gm_exit);
	}
}

void DoKickUser( KickUser& kick )
{
	//是否有此id
	if( g_user.find(kick.uid)!=g_user.end() )
	{
		g_user[kick.uid].b_kick = 1;
	}
}

void DoUserRegister( MqHead& h, InternalRegister& reg)
{
	//printf("serial: %08X\n",(int32_t)reg.serial);

	InternalRegisterResult r_result;
	r_result.serial = reg.serial;
	r_result.uid = reg.uid;
	//uid正确性
	if( reg.uid<1 )
		r_result.result = (Result)p::RegisterResult::Result::kInvalidValue;
	else if( g_user.find(reg.uid)!=g_user.end() )
		r_result.result = (Result)p::RegisterResult::Result::kUidExist;
	else
	{
		g_db.DoRegister((InternalRegister&)reg, r_result);
		//是否注册成功
		if( r_result.result==(Result)p::RegisterResult::Result::kSucceeded )
		{
			UserRecord ur;
			g_user[reg.uid] = ur;
			//
			GMPlayerRegister gm_reg;
			gm_reg.registerTime = (uint32_t)time(nullptr);
			gm_reg.ipAddress[0] = 0;
			strcat(gm_reg.ipAddress, reg.ipAddr);
			MqHead head;
			head.aid = reg.uid;
			head.flag = -1;
			head.type = gm_reg.kType;
			SendMsg2GM(head, &gm_reg);
		}
	}
	Send2Gate(h, r_result);
}

void DoIsUidExist( MqHead& h, InternalIsUidExist& ue)
{
	InternalIsUidExistResult ue_res;
	ue_res.serial = ue.serial;
	//是否有此id
	if( (g_user.find(ue.uid)!=g_user.end()) || g_db.DoHaveTheUserID(ue.uid) )
	{
		ue_res.result = (Result)p::IsUidExistResult::Result::kUidExist;
	}else
	{
		ue_res.result = (Result)p::IsUidExistResult::Result::kUidNotExist;
	}
	Send2Gate(h, ue_res);
}

void DoIsNicknameExist( MqHead&h, InternalIsNicknameExist& ne)
{
	InternalIsNicknameExistResult ne_res = { ne.serial, false };
	if( g_db.DoNicknameExist(ne.name) )//昵称是否存在
		ne_res.b_exist = true;
	Send2Gate(h, ne_res);
}

void DoGetAntiAddictionInfo(MqHead&h)
{
	p::GetAntiAddictionInfoResult result;
	It_UserRecord it_ur = g_user.find( h.aid );
	if( it_ur!=g_user.end() )//是否有此玩家
	{
		result.b_anti = it_ur->second.b_anti;
		result.online_time = it_ur->second.online_time;
		Send2Gate(h, result);
	}
}

void DoProveAntiAddictionInfo(MqHead& h, InternalProveAntiAddictionInfo& paa)
{
	InternalProveAntiAddictionInfoResult result;
	result.serial = paa.serial;
	//轻度判断字符串正确性
	if( paa.id_len>=sizeof(paa.id) || paa.id_len<15 || paa.name_len>=sizeof(paa.name) || paa.name_len<6 )
	{
		result.result = (Result)p::ProveAntiAddictionInfoResult::Result::kInvalidValue;
	}else
	{
		It_UserRecord it_ur = g_user.find( paa.uid);
		UserRecord ur;
		//是否有此id
		if( (it_ur!=g_user.end()) || g_db.DoHaveTheUserID(paa.uid) )
		{
			if( it_ur == g_user.end() )
			{
				if( g_db.DoGetUserAccountInfo(paa.uid, ur) )
				{
					g_user[paa.uid] = ur;
					it_ur = g_user.find(paa.uid);
				}
			}
			//防沉迷
			if( it_ur->second.b_anti==0 )
			{
				result.result = (Result)p::ProveAntiAddictionInfoResult::Result::kHadProved;
			}else
			{
				paa.id[paa.id_len] = 0;
				paa.name[paa.name_len] = 0;
				//检查提供信息的正确性
				if( NameIsRight(paa.name) && IsRight(paa.id)==0 )
				{
					it_ur->second.b_anti = 0;
					g_db.DoProveAntiAddictionInfo(paa.uid, paa);
					result.result = (Result)p::ProveAntiAddictionInfoResult::Result::kSucceeded;
				}else
				{
					result.result = (Result)p::ProveAntiAddictionInfoResult::Result::kInfoError;
				}
			}
		}else
		{
			result.result = (Result)p::ProveAntiAddictionInfoResult::Result::kUidNotExist;
		}
	}
	Send2Gate(h, result);
}

void DoCalcNumberOfOnline()
{
	if( g_online_record_time==0 )//在线人数记录时间
	{
		g_online_record_time = (uint32_t)time(nullptr);
	}else
	{
		uint32_t cur_time = (uint32_t)time(nullptr);
		if(cur_time<0xFFFFFFFF)//正确性
		{
			uint32_t diff_time = cur_time - g_online_record_time;
			//每分钟
			if(diff_time>=60)
			{
				tm * t2 = localtime((time_t*)(&cur_time));
				if(!t2)
				{
					printf("gmtime error\n");return;
				}
				printf("number of online: %-5d,%02d:%02d:%02d\n", g_number_of_online, t2->tm_hour, t2->tm_min, t2->tm_sec);
				g_online_record_time = cur_time;
				g_all_online_in_time += g_number_of_online;
				++g_online_record_count;
				//15分钟
				if(g_online_record_count>=15)
				{
					g_db.DoRecordNumberOfOnline((g_all_online_in_time/15));
					g_online_record_count = 0;
					g_all_online_in_time = 0;
				}

				//
				GMNumberOfOnline gm_online;
				gm_online.number_of_online = g_number_of_online;
				gm_online.time = cur_time;
				MqHead head;
				head.aid = 0;
				head.flag = -1;
				head.type = gm_online.kType;
				SendMsg2GM(head, &gm_online);
			}
		}
	}
}

int32_t DoGMProveAntiAddiction(MqHead& h, InternalProveAntiAddictionInfo& paa)
{
	int32_t result = kGMInvalid;
	UserID uid = h.aid;
	//信息
	if( paa.id_len>=sizeof(paa.id) || paa.id_len<15 || paa.name_len>=sizeof(paa.name) || paa.name_len<6 )
	{
		result = kGMInvalid;
	}else
	{
		It_UserRecord it_ur = g_user.find( uid);
		UserRecord ur;
		//是否有这个id
		if( (it_ur!=g_user.end()) || g_db.DoHaveTheUserID(uid) )
		{
			if( it_ur == g_user.end() )
			{
				if( g_db.DoGetUserAccountInfo(uid, ur) )
				{
					g_user[uid] = ur;
					it_ur = g_user.find(uid);
				}
			}
			//防沉迷
			if( it_ur->second.b_anti==0 )
			{
				result = kGMSucceced;
			}else
			{
				//printf("%d:%s: %d:%s\n",paa.name_len, paa.name, paa.id_len, paa.id);
				paa.id[paa.id_len] = 0;
				paa.name[paa.name_len] = 0;
				//信息是否正确
				if( NameIsRight(paa.name) && IsRight(paa.id)==0 )
				{
					it_ur->second.b_anti = 0;
					g_db.DoProveAntiAddictionInfo(uid, paa);
					result = kGMSucceced;
				}else
				{
					result = kGMInfoError;
				}
			}
		}else
		{
			result = kGMInvalid;
		}
	}
	return result;
}

void DoCalcOnlineTime()
{
	uint32_t cur_time;
	time_t t_time = time(nullptr);
	cur_time = (uint32_t)t_time;
	//间隔
	if( cur_time>g_pre_time )
	{
		g_pre_time = cur_time;
	}else
	{
		return;
	}
	struct tm * p_tm = localtime(&t_time);
	if( p_tm==nullptr )//执行结果
	{
		printf("p_tm is nullptr, cur_time: %d, error: %s\n", cur_time, strerror(errno));
	}
	//日期变动
	if( p_tm!=nullptr && p_tm->tm_yday != g_yday )
	{
		g_db.DoResetAntiAddictionInfo();
		g_yday = p_tm->tm_yday;
		for(auto& it_ur: g_user)
		{
			it_ur.second.online_time = 0;
		}
	}else
	{
		uint32_t interval = 0;
		int8_t   t_hours = 0;
		InternalAntiAddictionShutdown sd;
		p::NotifyAntiAddictionInfo aa_info;
		MqHead head = { 0, 0, -1 };
		for ( auto& it_ur: g_user )
		{
			//在线防沉迷
			if( it_ur.second.b_anti==1 && it_ur.second.b_online==1 )
			{
				interval = cur_time-it_ur.second.record_time;
				if( interval!=0 )
				{
					it_ur.second.online_time += interval;
					it_ur.second.record_time = cur_time;
					if( cur_time-it_ur.second.update_time>=30 )
					{
						//>=30秒保存一次
						//printf("it_ur:online_time=%d, g_user: time=%d\n",it_ur.second.online_time, g_user[it_ur.first].online_time);
						it_ur.second.update_time = cur_time;
						//printf("save online_time: %d\n",it_ur.second.online_time);
						g_db.DoUpdateAntiAddictionInfo(it_ur.first, it_ur.second);
					}
					if( it_ur.second.online_time>=3*60*60 )
					{
						//踢出游戏
						head.aid = it_ur.first;
						head.type = sd.kType;
						sd.uid = it_ur.first;
						Send2Gate(head, sd);
					}else
					{
						t_hours = (int8_t)(it_ur.second.online_time/3600);
						if( it_ur.second.online_hours != t_hours )
						{
							//推送在线时长
							//printf("to: %d notify online_time: %d\n",it_ur.first, it_ur.second.online_time);
							it_ur.second.online_hours = t_hours;
							aa_info.b_anti = 1;
							aa_info.online_time = it_ur.second.online_time;
							head.aid = it_ur.first;
							head.type = aa_info.kType;
							Send2Gate(head, aa_info);
						}
					}
				}
			}
		}
	}
}
