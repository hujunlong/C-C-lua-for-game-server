#pragma once
#include <vector>
#include <memory>
#include "../protocol/define.h"
#include "../system/mq.h"
#include <boost/noncopyable.hpp>

struct  lua_State;

class CScript : private boost::noncopyable //host a subsystem
{
public:
	CScript();
	~CScript();
	bool Init(const char* file);
	void ReloadModified();
	void RunOnce(); //系统每隔一小段时间会调用一次，主要用于处理定时事务
	void ProcessMsgFromDb( const MqHead& head, uint8_t* data );
	void ProcessMsgFromGate( const MqHead& head, uint8_t* data, size_t len );
	void ProcessMsgFromGM( const MqHead& head, uint8_t* data, size_t len );
	const char*  GetWorldWarServerAddress();
	void RegisterWorldWar();
	void ProcessMsgFromWorldWar( const MqHead& head, uint8_t* data, size_t len );
private:
	lua_State* mL;
};





