#include "data.h"

namespace
{
	MQNode g_mq;
}

MQNode& CreateMQ4Data(const char* apAddress )
{
	g_mq.Init(NodeType::kServer, apAddress);
	return g_mq;
}


void ProcessPlayerMsg2Data( const MqHead& head, const uint8_t* data, size_t len)
{
	g_mq.Send(head, data, len);
}