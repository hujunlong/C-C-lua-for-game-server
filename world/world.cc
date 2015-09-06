#include <thread>
#include <future>
#include "../system/mq_node.h"
#include "../mq/config.h"
#include "../system/mq_helper.h"
#include "script_host.h"
#include "script_tool.h"
#include "transfer.h"
#include <iostream>
#include "../protocol/common.h"
#include "../protocol/town.h"
#include "../protocol/internal.h"
#include "../protocol/playgroud.h"
#include "../system/ios.h"

namespace
{
	CScript g_as;
}

void ProcessMsgFromGate( MqHead head, uint8_t* data, size_t len )
{
	if (head.type==kUserEnter)
	{
		Send2Db(head, data, len);
	}
	g_as.ProcessMsgFromGate(head, data, len);
}

void ProcessMsgFromDb( MqHead head, uint8_t* data, size_t len )
{
	if (head.type==kUserEnterSucceeded)
	{
		Send2Gate(head, data, len);
	}
	g_as.ProcessMsgFromDb(head, data);
}

void ProcessMsgFromGM( MqHead head, uint8_t* data, size_t len )
{
	printf("Receive GM message, len=%d \n", len - 2);
	g_as.ProcessMsgFromGM(head, data, len);
}

void ProcessMsgFromInteract( MqHead head, uint8_t* data, size_t len )
{
	g_as.ProcessMsgFromGate(head, data, len);
}

void ProcessMsgFromWorldWar( MqHead head, uint8_t* data, size_t len )
{
	g_as.ProcessMsgFromWorldWar(head, data, len);
}

void OnExit()
{
	printf("\nWorld server exiting!");
	MqHead head = {0, kWorldServerExit, 0};
	Send2Gate(head, &head, 0);
	std::this_thread::sleep_for(std::chrono::seconds(10));
}

int main(int argc, char* argv[])
{
	atexit(OnExit);
#ifdef WIN32
	WSADATA wsadata;
	auto ret = WSAStartup(0x0202, &wsadata);
#endif
	//connect to gate server
	MQNode& mq_gate = CreateMQ2Gate(kGateForWorld);

	//connect to db server
	MQNode& mq_db = CreateMQ2DB(kDbForWorld);

	//listen for GM
	MQNode& mq_gm = CreateMQ4GM(kGMAddr);

	//listen for interact
	MQNode& mq_interact = CreateMQ4Interact(kWorldForInteract);

	g_as.Init("main.lua");

	MQNode& mq_ww = CreateMQ2WorldWar(g_as.GetWorldWarServerAddress());
	g_as.RegisterWorldWar();

	time_t start = time(nullptr);
	for (;;)
	{
		DealwithMQ(mq_gate, ProcessMsgFromGate);
		DealwithMQ(mq_db, ProcessMsgFromDb);
		DealwithMQ(mq_gm, ProcessMsgFromGM);
		DealwithMQ(mq_ww, ProcessMsgFromWorldWar);
		DealwithMQ(mq_interact, ProcessMsgFromInteract);

		IOSWork();

		time_t now = time(nullptr);
		if (now-start >= 1)
		{
			g_as.RunOnce();
			start = now;
		}
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}

}


static_assert(sizeof(bool)==1, "Unsupported complier!!!"); //检测bool长度是不是一个字节

