#pragma once
//#include <luabind/object.hpp>
#include "../protocol/define.h"
#include "../system/mq.h"
#include "../system/export.h"
#include <lua.hpp>

extern "C"
{
	FUNCTION_EXPORT void Send2Gate( const MqHead& head , void* data, int len);
	FUNCTION_EXPORT void Send2Db( const MqHead& head, void* data, int len );
	FUNCTION_EXPORT void Send2GM( const MqHead& head, void* data, int len );
	FUNCTION_EXPORT void Send2Interact( const MqHead& head, void* data, int len );
	FUNCTION_EXPORT void Send2WorldWar( const MqHead& head, void* data, int len );
	FUNCTION_EXPORT void* MovePtr(void* ptr, int offset);

	//×Ö·û²Ù×÷
	FUNCTION_EXPORT int ConvertFightRecord( lua_State* L );
	/*
	FUNCTION_EXPORT void ResetStringBuilder();
	FUNCTION_EXPORT void AddString2Builder(const char*, size_t len);
	FUNCTION_EXPORT size_t GetBuilderStringLength();
	FUNCTION_EXPORT char* GetBuilderString();
	*/
//	FUNCTION_EXPORT 
};





