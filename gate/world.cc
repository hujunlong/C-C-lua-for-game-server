#include "world.h"
#include "../protocol/internal.h"

namespace
{
	MQNode g_mq;
}

MQNode& CreateMQ4World( const char* apAddress )
{
	g_mq.Init(NodeType::kServer, apAddress);
	return g_mq;
}

void ProcessPlayerMsg2World( const MqHead& head, const uint8_t* data, size_t len )
{
	g_mq.Send(head, data, len);
}

void NotifyUserExit2World( UserID uid )
{
	UserExit ue;
	g_mq.Send(uid, ue.kType, 0, ue);
}

void NotifyUserEnter2World( UserID uid, int16_t flag )
{
	UserEnter ue;
	g_mq.Send(uid, ue.kType, flag, ue);
}


