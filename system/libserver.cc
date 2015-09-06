#include "export.h"
#include "server.h"
#include "ios.h"
#include <thread>
#include <chrono>

extern "C"
{
	using namespace network;

#ifdef WIN32
	typedef void (__stdcall *ReadHandle)(int serial, int16_t type, int16_t bytes, int16_t flag, const uint8_t* data);
#else
	typedef void (*ReadHandle)(int serial, int16_t type, int16_t bytes, int16_t flag, const uint8_t* data);
#endif


	FUNCTION_EXPORT void* CreateServer(const char* addr, short port, ReadHandle handle )
	{
		return new CServer(addr,  port, handle);
	}

	FUNCTION_EXPORT void Poll()
	{
		IOSWork();
	}

	FUNCTION_EXPORT void SleepFor(int ms)
	{
		std::this_thread::sleep_for(std::chrono::milliseconds(ms));
	}

}
