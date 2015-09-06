#include "export.h"
#include "mq_node.h"

extern "C"
{


FUNCTION_EXPORT void* ZMQInit(NodeType aType, const char* apAddress)
{
	MQNode* mq = new MQNode();
	mq->Init(aType,apAddress);
	return mq;
}

FUNCTION_EXPORT bool ZMQFetch(void* mq,MqHead& head, void* data, size_t& len)
{
	return ((MQNode*)mq)->Fetch<MqHead>(head,data,len);
}


FUNCTION_EXPORT void ZMQSend(void* mq,const MqHead& h, const void* aData, size_t aLen )
{
	((MQNode*)mq)->Send<MqHead>(h, aData, aLen);
}

};