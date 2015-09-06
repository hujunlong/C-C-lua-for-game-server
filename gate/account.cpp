#include "../protocol/common.h"
#include "../protocol/internal.h"
#include "../protocol/db.h"
#include "account.h"

namespace
{
	MQNode g_mq;
	int32_t g_version;
}

void InitAccount()
{
	std::ifstream version_file("version.txt");
	version_file >> g_version;
}

int32_t GetMyVersion()
{
	return g_version;
}

MQNode& CreateMQ4Account(const char* apAddress )
{
	g_mq.Init(NodeType::kServer, apAddress);
	return g_mq;
}

void NotifyUserEnter2Account( int16_t flag, InternalLogin& login )
{
	g_mq.Send(0, login.kType, flag, login);
}

void NotifyUserLoginSucceeded2Account( InternalLoginSucceeded& ls )
{
	g_mq.Send(0, ls.kType, 0, ls);
}
void NotifyUserExit2Account( InternalLogout& logout )
{
	g_mq.Send(0, logout.kType, 0, logout);
}

void NotifyUserRegister2Account( int16_t flag, InternalRegister& reg)
{
	g_mq.Send(0, reg.kType, flag, reg);
}

void NotifyUidExist2Account(int16_t flag, InternalIsUidExist& ue)
{
	g_mq.Send(0, ue.kType, flag, ue);
}

void NotifyProveAntiAddictionInfo(int16_t flag, InternalProveAntiAddictionInfo& paa)
{
	g_mq.Send(0, paa.kType,flag, paa);
}

void NotifyKick2Account(KickUser& kick)
{
	g_mq.Send(0, kick.kType, 0, kick);
}

void ProcessMsg2Account( const MqHead& head, const uint8_t* data, size_t len )
{
	g_mq.Send(head, data, len);
}