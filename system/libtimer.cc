#include "libtimer.h"
#include "timer.h"
#include <map>
#include <memory>

namespace
{
	std::map<int, std::unique_ptr<CTimer>> g_timers;

	int g_max_id = 0;
}

FUNCTION_EXPORT int CreateTimer( TimerCallback cb, int seconds )
{
	assert(cb);
	if(!cb)
	{
		printf("Null TimerCallback assigned!\n");
		return -1;
	}
	++g_max_id;
	std::unique_ptr<CTimer> pt(new CTimer);
	pt->Start(seconds*1000, std::bind(cb, g_max_id));
	g_timers[g_max_id] = std::move(pt);
	return g_max_id;
}

FUNCTION_EXPORT void StopTimer( int timer_id )
{
	auto timer = g_timers.find(timer_id);
	if (timer!=g_timers.end())
	{
		timer->second->Stop();
	}
}

FUNCTION_EXPORT void ResetTimer( int timer_id, int seconds )
{
	auto timer = g_timers.find(timer_id);
	if (timer!=g_timers.end())
	{
		timer->second->Reset(seconds*1000);
	}
}

