#include <thread>
#include <future>
#include "data.h"
#include "../system/ios.h"
#include <iostream>

namespace
{
	CScript g_as;
}

void ProcessMsgFromGate( MqHead head, uint8_t* data, size_t len )
{
	g_as.ProcessMsgFromGate(head, data, len);
}

int main()
{
	//connect to gate server
	MQNode& mq_gate = CreateMQ2Gate(kGateForData);

	g_as.Init("data_main.lua");

	for (;;)
	{
		DealwithMQ(mq_gate, ProcessMsgFromGate);

		IOSWork();
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
	return 0;
}