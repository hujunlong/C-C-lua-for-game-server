#include "interact.h"
#include "../protocol/common.h"
#include "../protocol/internal.h"
#include "../protocol/db.h"

namespace
{
	MQNode g_mq;
}

MQNode& CreateMQ4Interact(const char* apAddress )
{
	g_mq.Init(NodeType::kServer, apAddress);
	return g_mq;
}

namespace
{
	template<typename Msg>
	void MqSend(const Msg& msg, size_t len)
	{
		g_mq.Send(msg, len);
	}
}

void ProcessPlayerMsg2Interact( const MqHead& head, const uint8_t* data, size_t len )
{
	assert(len<=kMaxProtocolLength);
	if (len <= kMaxProtocolLength)
	{
		g_mq.Send(head, data, len);
	}
}

void NotifyUserExit2Interact( UserID uid )
{
	UserExit ue;
	g_mq.Send(uid, ue.kType, 0, ue);
}

void NotifyUserEnter2Interact( UserID uid, int16_t flag )
{
	UserEnter ue;
	g_mq.Send(uid, ue.kType, flag, ue);
}


