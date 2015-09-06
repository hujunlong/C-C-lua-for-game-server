#pragma once
#include <iostream>
#include "mq_node.h"

template <typename TMQProcess>
void DealwithMQ(MQNode& mr, TMQProcess f)
{
	size_t len = 0;
	MqHead head;
	uint8_t data[MQNode::cMaxLen];
	while(mr.Fetch(head, data, len))
	{
#ifdef _DEBUG
		std::cout <<"Mqmsg, type="<<head.type<<" length="<<len<<'\n';
#endif // _DEBUG
		f( head, data, len);
	}
}
