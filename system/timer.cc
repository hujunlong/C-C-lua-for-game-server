#include "timer.h"
#include <boost/date_time.hpp>
#include "ios.h"

CTimer::CTimer(  ) :mTimer(sios::instance())
{
	running = false;
}

void CTimer::WaitHandler( const boost::system::error_code& aError )
{
	if (!aError)
	{
		try
		{
			mCallback();
		}
		catch (std::exception& e)
		{
			std::cout <<e.what()<<std::endl;
		}
		catch (...)
		{
			std::cout <<"Unkown exception!"<<std::endl;
		}
		if(running) Schedule();
	} 
} 

void CTimer::Schedule()
{
	mTimer.expires_from_now(boost::posix_time::milliseconds(mElapse));
	mTimer.async_wait(std::bind(&CTimer::WaitHandler, this, std::placeholders::_1));
}

void CTimer::Start( int32_t aElapse, std::function<void (void)> aCallback )
{
	running = true;
	mElapse = aElapse;
	mCallback = aCallback;
	Schedule();
}

CTimer::~CTimer()
{
	Stop();
}

void CTimer::Stop()
{
	mTimer.cancel();
	running = false;
}

void CTimer::Reset( int32_t aElapse )
{
	running = true;
	mElapse = aElapse;
	Schedule();
}
