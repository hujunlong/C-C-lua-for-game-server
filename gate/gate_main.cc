
#include "../system/server.h"
#include "../system/ios.h"
#include "../system/define.h"
#include "../system/send.h"
#include "../protocol/game_def.h"
#include "../protocol/internal.h"
#include "../protocol/data.h"
#include "../system/timer.h"
#include "../mq/config.h"
#include "../system/mq_helper.h"
#include "users.h"
#include "interact.h"
#include "world.h"
#include "account.h"
#include "data.h"
#include "../protocol/misc.h"

using namespace network;

void NetError(Serial serial)
{
	//need to logout player
	if (GetUsers().Has(serial))
	{
		UserID uid = GetUsers().Serial2UserID(serial);
		NotifyUserExit2Interact(uid);
		NotifyUserExit2World(uid);
		GetUsers().Remove(serial);
	}
}

bool IsSessionValid(Serial serial)
{
	return GetUsers().Has(serial);
}

void PlayerMsgProcess( Serial serial, int16_t type, int16_t bytes, int16_t flag, const uint8_t* data )
{
	assert(type>=0 && bytes>=0);
	//printf("gate: got msg type: %d, serial: %08X\n", type, serial);

	UserID uid;
	MqHead head;
	switch ( type )
	{
	case Ping::kType:
		{
			if(bytes == sizeof(Ping))
			{
				Ping* ping_data =  (Ping*)(data);
				switch(ping_data->server)
				{
				case kServerIDGate:
					{
						int null_data = 0;
						GetServer().Send(serial,PingResult::kType, sizeof(null_data), 0, &null_data);
						break;
					}
				}
			}
			break;
		}		 
	case p::Login::kType:
		InternalLogin login;
		memcpy( &login, data, sizeof(p::Login) );
		login.serial = serial;
		NotifyUserEnter2Account( flag, login );
		break;
	case p::Register::kType:
		InternalRegister reg;
		p::Register* p_reg;
		p_reg = (p::Register*)data;
		reg.serial = serial;
		reg.uid = p_reg->uid;
		reg.sex = p_reg->sex;
		memcpy( &reg.name, &(p_reg->name), sizeof(p_reg->name) );
		//
		const char * ip;
		ip = GetServer().GetSessionAddress(serial);
		if(ip)
		{
			reg.ipAddr[0] = 0;
			strcat(reg.ipAddr, ip);
		}
		NotifyUserRegister2Account( flag, reg );
		break;
	case p::IsUidExist::kType:
		InternalIsUidExist ue;
		ue.serial = serial;
		ue.uid = ((p::IsUidExist*)data)->uid;
		NotifyUidExist2Account(flag, ue);
		break;
	case p::IsNicknameExist::kType:
		InternalIsNicknameExist ne;
		ne.serial = serial;
		memcpy(&ne.name, &(((p::IsNicknameExist*)data)->name), sizeof(Nickname));
		head.type = InternalIsNicknameExist::kType;	head.flag = flag;
		ProcessMsg2Account(head, (const uint8_t*)(&ne), sizeof(ne));
		break;
	case p::ProveAntiAddictionInfo::kType:
		InternalProveAntiAddictionInfo paa;
		paa.serial = serial;
		memcpy(&paa.uid, data, sizeof(p::ProveAntiAddictionInfo));
		NotifyProveAntiAddictionInfo(flag, paa);
		break;
	case p::GetAntiAddictionInfo::kType:
		if ( !IsSessionValid(serial) )
		{
			return;
		}
		uid = GetUsers().Serial2UserID(serial);
		head.aid = uid;	head.type = type;	head.flag = flag;
		ProcessMsg2Account( head, data, bytes);
		break;
	default:
		if ( !IsSessionValid(serial) )
		{
			return;
		}
		uid = GetUsers().Serial2UserID(serial);
		head.aid = uid;	head.type = type;	head.flag = flag;
		if (type < (int16_t)CommonType::kMax && type>0)
		{
			ProcessPlayerMsg2Interact( head, data, bytes);
		}
		else if (type>0)
		{
			if( type<=(int16_t)DataGetType::kDataGetTypeEnd && type>=kDataGetTypeBegin)
			{
				ProcessPlayerMsg2Data(head,data,bytes);
			}
			ProcessPlayerMsg2World(head, data, bytes);
		}
		break;
	}
}


void ProcessMsgFromWord( MqHead head, uint8_t* data, size_t len )
{
	//printf("got msg from world: %d\n", head.type);

	auto& users = GetUsers();
	Serial serial = users.UserID2Serial(head.aid);
	//std::cout <<"Send 2 client type="<<head.type<<" len="<<len<<"\n";
	switch ( head.type )
	{
	case kUserEnterSucceeded:
		//printf("enter succeeded , uid: %d\n", head.aid);
		p::LoginReturn login_return;
		login_return.error = p::LoginReturn::Result::kSucceeded;
		login_return.result = p::LoginReturn::Result::kSucceeded;
		login_return.now = (int32_t)time(nullptr);
		login_return.version = GetMyVersion();
		Send(serial, head.flag, login_return);
		//
		InternalLoginSucceeded ls;
		memset(&ls, 0, sizeof(ls));
		ls.uid = head.aid;
		const char * ip;
		ip = GetServer().GetSessionAddress(serial);
		if(ip)
		{
			strcat(ls.ipAddr, ip);
		}
		NotifyUserLoginSucceeded2Account( ls );

		//-----------------------test-----------------------
		//InternalWelcomeToGame welcome;
		//welcome.uid = head.aid;
		//MqHead new_head;
		//new_head.aid = head.aid;
		//new_head.type= welcome.kType;
		//new_head.flag = -1;
		//ProcessPlayerMsg2World(new_head, (uint8_t*)&welcome, sizeof(welcome));
		//
		return;
	case kKickUser:
		InternalLogout lo;
		lo.uid = head.aid;
		NotifyUserExit2Account(lo);
		NotifyKick2Account( (KickUser&)*data );
		//
		GetServer().Close(serial);
		NetError(serial);
		return;
	default:
		break;
	}

	if (head.type<=kBroadcastTypeEnd&&head.type>=kBroadcastTypeBegin)
	{
		users.ForEachSerial([&](Serial serial){Send(serial, head.type, -1, data, len);});
	}
	else
	{
		Send( serial, head.type, head.flag, data, len);
	}
}

void ProcessMsgFromInteract( MqHead head, uint8_t* data, size_t len )
{
	//assert(head.type<(int16_t)CommonType::kMax);
	auto& users = GetUsers();
	if (head.type<=kBroadcastTypeEnd&&head.type>=kBroadcastTypeBegin)
	{
	    if (head.type==29022) return;
		//printf("recv a broadcast msg from interact: type=%d,len=%d\n");
		users.ForEachSerial([&](Serial serial){Send(serial, head.type, -1, data, len);});
	}
	else
	{
		Serial serial = users.UserID2Serial(head.aid);
		Send( serial, head.type, head.flag, data, len);
	}
}

bool DoUserLogin(MqHead& head, const InternalLoginResult& l_res)
{
	bool bret = false;
	Serial serial = (Serial)l_res.serial;
	//printf("user login: %d , %08X\n", l_res.uid, serial );
	//
	p::LoginReturn login_return = {p::LoginReturn::Result::kSucceeded, (p::LoginReturn::Result)l_res.result, (int32_t)time(nullptr)};
	login_return.version = GetMyVersion();
	//
	if( l_res.result == (Result)p::LoginReturn::Result::kSucceeded )
	{
		auto old_serial = GetUsers().UserID2Serial(l_res.uid);
		if (old_serial != network::kErrorSerial)
		{
			p::AnotherLoginNotify aln;
			Send(old_serial, -1, aln);
			GetServer().Close(old_serial);
			NetError(old_serial);
		}
		//
		//uid和serial关联
		bret = GetUsers().Add(l_res.uid, serial);
		if (!bret)
		{
			printf("Uid=%d login failed: user add failed\n", l_res.uid);
			login_return.result = p::LoginReturn::Result::kFailed;
			Send(serial, head.flag, login_return);
		}else
		{//通知后端程序 , 用户登录验证成功
			NotifyUserEnter2Interact(l_res.uid, head.flag);
			NotifyUserEnter2World(l_res.uid, head.flag);
		}
	}else
	{
		printf("Uid=%d login failed, ret_val=%d\n", l_res.uid, l_res.result);
		Send(serial, head.flag, login_return);
	}
	return bret;
}

bool DoUserRegister(MqHead& head, InternalRegisterResult& r_res)
{
	//printf("register: %d, %08X\n", r_res.result, (int32_t)r_res.serial);

	p::RegisterResult r_result = {p::RegisterResult::Result::kSucceeded, (p::RegisterResult::Result)r_res.result };
	Serial serial = (Serial)r_res.serial;
	Send(serial, head.flag, r_result);
	if( r_res.result==p::RegisterResult::Result::kSucceeded )
	{
		InternalWelcomeToGame welcome = { r_res.uid };
		MqHead head = { r_res.uid, welcome.kType, -1 };
		ProcessPlayerMsg2World(head, (uint8_t*)&welcome, sizeof(welcome));
	}
	return true;
}

bool DoIsUidExist(MqHead& head, InternalIsUidExistResult& iue_res)
{
	p::IsUidExistResult ue_res = { (p::IsUidExistResult::Result)0, (p::IsUidExistResult::Result)iue_res.result };
	Serial serial = (Serial)iue_res.serial;
	Send(serial, head.flag, ue_res);
	return true;
}

bool DoIsNicknameExist(MqHead&h, InternalIsNicknameExistResult& ine_res)
{
	p::IsNicknameExistResult ne_res = { ine_res.b_exist };
	Serial serial = (Serial)ine_res.serial;
	Send(serial, h.flag, ne_res);
	return true;
}

bool DoAntiAddictionShutdown(InternalAntiAddictionShutdown& sd)
{
	auto& users = GetUsers();
	Serial serial = users.UserID2Serial(sd.uid);
	p::NotifyAntiAddictionShutdown notify_sd;
	Send( serial, -1, notify_sd);

	InternalLogout lo = { sd.uid };
	NotifyUserExit2Account(lo);
	//
	GetServer().Close(serial);
	NetError(serial);
	return true;
}

bool DoNotifyAntiAddictionInfo(MqHead& head, p::NotifyAntiAddictionInfo& aa_info)
{
	auto& users = GetUsers();
	Serial serial = users.UserID2Serial(head.aid);
	Send(serial, -1, aa_info);
	return true;
}

bool DoProveAntiAddictionInfoResult(MqHead& head, InternalProveAntiAddictionInfoResult& paar)
{
	p::ProveAntiAddictionInfoResult res = { (p::ProveAntiAddictionInfoResult::Result)paar.result };
	Serial serial = (Serial)paar.serial;
	Send(serial, head.flag, res);
	return true;
}

void ProcessMsgFromAccount( MqHead head, uint8_t* data, size_t len)
{
	//printf("user : %d ,, type : %d\n", head.aid, head.type);
	switch ( head.type )
	{
	case InternalLoginResult::kType:
		DoUserLogin(head, (const InternalLoginResult&)*data);
		break;
	case InternalRegisterResult::kType:
		DoUserRegister(head, (InternalRegisterResult&)*data);
		break;
	case InternalIsUidExistResult::kType:
		DoIsUidExist(head, (InternalIsUidExistResult&)*data);
		break;
	case InternalIsNicknameExistResult::kType:
		DoIsNicknameExist(head, (InternalIsNicknameExistResult&)*data);
		break;
	case InternalAntiAddictionShutdown::kType:
		DoAntiAddictionShutdown((InternalAntiAddictionShutdown&)*data);
		break;
	case p::NotifyAntiAddictionInfo::kType:
		DoNotifyAntiAddictionInfo(head, (p::NotifyAntiAddictionInfo&)*data);
		break;
	case InternalProveAntiAddictionInfoResult::kType:
		DoProveAntiAddictionInfoResult(head, (InternalProveAntiAddictionInfoResult&)*data);
		break;
	default:
		auto& users = GetUsers();
		Serial serial = users.UserID2Serial(head.aid);
		Send( serial, head.type, head.flag, data, len);
		break;
	}
}

void ProcessMsgFromData( MqHead head, uint8_t* data, size_t len)
{
//	printf("recv msg %d from data\n", head.type);

	const uint16_t kAddPrestigeBegin = 8901;
	const uint16_t kAddPrestigeEnd = 9000;
	//推送给world() 8901 ~ 9000直接传给 world
	if (head.type >= kAddPrestigeBegin && head.type <= kAddPrestigeEnd )//从data发过来的数据发到world里面
	{
		ProcessPlayerMsg2World(head,data,len);
	}
	else
	{
		auto& users = GetUsers();
		Serial serial = users.UserID2Serial(head.aid);
		Send( serial, head.type, head.flag, data, len);
	}
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        std::cerr << "Usage: gate <port>\n";
        return 1;
    }

    //for world server
	auto& mq_word = CreateMQ4World(kGateForWorld);

    //for interact server

	auto& mq_interact = CreateMQ4Interact(kGateForInteract);

	//for account server
	auto& mq_account = CreateMQ4Account(kGateForAccount);
	InitAccount();

	//for data
	auto& mq_data = CreateMQ4Data(kGateForData);

    network::CServer s("0.0.0.0", atoi(argv[1]), PlayerMsgProcess);
	if(argc>=3) s.SetSessionDeadSeconds(atoi(argv[2]));

    InitSend(&s);

    for (;;)
    {
        DealwithMQ(mq_word, ProcessMsgFromWord);
        DealwithMQ(mq_interact, ProcessMsgFromInteract);
		DealwithMQ(mq_account, ProcessMsgFromAccount);
		DealwithMQ(mq_data, ProcessMsgFromData);

		network::Serial dead_serials[2000];
		size_t dead_serials_len = 0;
		s.GetDeadSessions(dead_serials, dead_serials_len);
		for (size_t i=0; i<dead_serials_len; ++i)
		{
			if (GetUsers().Has(dead_serials[i]))
			{
				UserID uid = GetUsers().Serial2UserID(dead_serials[i]);
				InternalLogout lo = { uid };
				NotifyUserExit2Account(lo);
			}

			s.Close(dead_serials[i]);
			NetError(dead_serials[i]);
		}



        IOSWork();
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

}
