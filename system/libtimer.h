#pragma once


#include "export.h"


extern "C"
{
#ifdef WIN32
	typedef void (__stdcall *TimerCallback)(int timer_id);
#else
    typedef void (*TimerCallback)(int timer_id);
#endif
	FUNCTION_EXPORT int CreateTimer(TimerCallback cb, int seconds);
	FUNCTION_EXPORT void StopTimer(int timer_id);
	FUNCTION_EXPORT void ResetTimer(int timer_id, int seconds);
};

