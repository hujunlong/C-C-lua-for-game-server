#include "send.h"
#include "../system/server.h"

using network::CServer;

namespace 
{
	CServer* g_srv = nullptr;	
}

void InitSend( network::CServer* apServer )
{
	assert(g_srv==nullptr);
	g_srv = apServer;
}


network::CServer& GetServer()
{
	assert(g_srv!=nullptr);
	return *g_srv;
}

