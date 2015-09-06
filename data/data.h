#include <thread>
#include <chrono>
#include <zmq.hpp>
#include <boost/noncopyable.hpp>
#include "../system/mq.h"
#include "../mq/config.h"
#include "../system/mq_node.h"
#include "../system/mq_helper.h"
#include "../protocol/game_def.h"
#include "../system/libtimer.h"


//MQNode& CreateMQ2Gate( const char* apAddress );


extern "C"
{
	FUNCTION_EXPORT void Send2Gate( const MqHead& head , void* data, int len);
};


struct  lua_State;

class CScript : private boost::noncopyable //host a subsystem
{
public:
	CScript();
	~CScript();
	bool Init(const char* file);
	void RunOnce();
	void ProcessMsgFromGate( const MqHead& head, uint8_t* data, size_t len );
private:
	lua_State* mL;
};