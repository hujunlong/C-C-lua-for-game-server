#pragma once

#include <cstdint>

namespace network
{
	typedef int16_t Type;
	typedef int16_t Bytes;
	typedef int16_t Flag;

	struct Head
	{
		Flag flag;
		Type type;
		Bytes bytes;
	};

#ifdef _STRONG_CHECK   //Check "serial = userid" or "userid = serial" error, please notice the complier warnings.
//	typedef double Serial; //for 64bit OS
	typedef float Serial; //for 32bit OS
#else
	typedef int32_t Serial;
#endif

	static const int32_t kErrorSerial = INT_MAX;

	static const int32_t kSessionDeadSeconds = 130;

	static const uint16_t kNormalPacketBytes = 1024;
	static const uint16_t kMaxPacketBytes = SHRT_MAX;
}
