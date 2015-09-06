#pragma once

#include <boost/asio/deadline_timer.hpp>
#include <boost/system/error_code.hpp>
#include <functional>

class CTimer
{
public:
	CTimer();
	~CTimer();
	void Start(int32_t aElapse, std::function<void (void)> aCallback);  //elapse : milliseconds
	void Stop();
	void Reset(int32_t aElapse);
private:
	void WaitHandler(const boost::system::error_code& aError);
	void Schedule();

	boost::asio::deadline_timer mTimer;
	int mElapse; // milliseconds
	std::function<void (void)> mCallback;
	bool running;
};