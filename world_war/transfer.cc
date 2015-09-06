#include "transfer.h"


MQNode& CreateMQ2DB( const char* apAddress )
{
	auto& mq = GetMQ2DB();
	mq.Init(NodeType::kClient, apAddress);
	return mq;
}

MQNode& CreateMQ2Gate( const char* apAddress )
{
	auto& mq = GetMQ2Gate();
	mq.Init(NodeType::kClient, apAddress);
	return mq;
}

MQNode& CreateMQ4GM( const char* addr )
{
	auto& mq = GetMQ4GM();
	mq.Init(NodeType::kServer, addr);
	return mq;
}

MQNode& CreateMQ4Interact( const char* addr )
{
	auto& mq = GetMQ4Interact();
	mq.Init(NodeType::kServer, addr);
	return mq;
}

MQNode& CreateMQ2WorldWar( const char* addr )
{
	auto& mq = GetMQ2WorldWar();
	mq.Init(NodeType::kClient, addr);
	return mq;
}

MQNode& GetMQ2DB()
{
	static MQNode mq;
	return mq;
}

MQNode& GetMQ2Gate()
{
	static MQNode mq;
	return mq;
}

MQNode& GetMQ4GM()
{
	static MQNode mq;
	return mq;
}

MQNode& GetMQ4Interact()
{
	static MQNode mq;
	return mq;
}

MQNode& GetMQ2WorldWar()
{
	static MQNode mq;
	return mq;
}

