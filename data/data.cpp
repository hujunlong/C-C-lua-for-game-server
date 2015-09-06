#include <iostream>
#include <lua.hpp>
#include "data.h"


namespace
{
	int LuaErrorHandler(lua_State *L)
	{
		lua_getfield(L, LUA_GLOBALSINDEX,"debug");
		if( !lua_istable(L, -1))
		{
			lua_pop(L,1);
			return 1;
		}
		lua_getfield(L,-1,"traceback");
		if( !lua_isfunction(L, -1) )
		{
			lua_pop(L,2);
			return 1;
		}
		lua_pushvalue(L,1);
		lua_pushinteger(L,2);
		lua_call(L,2,1);
		return 1;
	}

	enum LUA_RETURN{LUA_NO_ERROR = 0,LUA_ERROR1,LUA_ERROR2};
	int _CallFunction(lua_State *m_luaState , int nParams)
	{
		int result = LUA_NO_ERROR;
		int size0 = lua_gettop(m_luaState);
		int error_index = lua_gettop(m_luaState) - nParams;
		lua_pushcfunction(m_luaState, LuaErrorHandler);
		lua_insert(m_luaState, error_index);
		if(lua_pcall(m_luaState, nParams, 0, error_index) != 0)
			result = LUA_ERROR1;

		lua_remove(m_luaState, error_index);
		if((lua_gettop(m_luaState) + (int)nParams  + 1) != size0)
			result = LUA_ERROR2;

		return result;
	}



	bool CallFunction(lua_State* L, const char* name, void* p1=nullptr, void* p2=nullptr, size_t p3=(size_t)-1)
	{
		int prama_count = 0;
		lua_getglobal(L, name);
		if(p1)
		{
			lua_pushlightuserdata(L, p1);
			++prama_count;
		}
		if(p2)
		{
			lua_pushlightuserdata(L, p2);
			++prama_count;
		}
		if(p3!=(size_t)-1)
		{
			lua_pushinteger(L, p3);
			++prama_count;
		}
		try
		{
			int ret = _CallFunction(L,prama_count);
			if ( ret != 0 )
			{
				char buff[1024];
				memset(buff,0,sizeof(buff));
				printf("CallFunction '%s': %s RetCode:%d\n", name, lua_tostring(L, -1), ret);
				return false;
			}
		}
		catch (std::exception& e)
		{
			std::cout << e.what() <<std::endl;
			printf("CallFunction '%s': %s \n", name, lua_tostring(L, -1));
		}
		catch (...)
		{
		}
		return true;
	}

}


namespace
{
	MQNode& GetGateMq()
	{
		static MQNode gate_mq;
		return gate_mq;
	}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg)
	{
		GetGateMq().Send(head, msg);
	}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg, size_t aLen)
	{
		GetGateMq().Send(head.aid, msg.kType, head.flag, msg, aLen);
	}
}

// MQNode& CreateMQ2Gate( const char* apAddress )
// {
// 	auto& node =  GetGateMq();
// 	node.Init(NodeType::kClient, apAddress);
// 	return node;
// }


FUNCTION_EXPORT void Send2Gate( const MqHead& head , void* data, int len )
{
	GetGateMq().Send(head, data, len);
}



void CScript::RunOnce()
{
	CallFunction(mL,  "RunOnce");
}

bool CScript::Init( const char* file )
{
	mL = luaL_newstate();
	luaL_openlibs(mL);

	if (luaL_dofile(mL, file) != 0)
	{
		printf("%s", lua_tostring(mL,-1));
		std::cerr <<"\nFailed to load " <<file <<std::endl;
		return false;
	}

	try
	{
		RunOnce();
	}
	catch (std::exception& e)
	{
		std::cerr <<e.what() <<std::endl;
		printf("%s", lua_tostring(mL,-1));
	}
	catch (...)
	{
	}

	return true;
}

void CScript::ProcessMsgFromGate( const MqHead& head, uint8_t* data, size_t len )
{
	if (!CallFunction(mL, "ProcessMsgFromGate", (void*)&head, data, len))
	{
		printf("uid:%d msg_type:%d\n",head.aid, head.type);
		const char* err_msg =  lua_tostring(mL,-1);
		GameOperationException goe = {head.type, (int16_t)strlen(err_msg)};
		memcpy(goe.error, err_msg, sizeof(goe.error));
		MqHead h2return = {head.aid, goe.kType, head.flag};
		Send2Gate(h2return, goe, sizeof(goe));
	}
}

CScript::CScript()
{
	mL = nullptr;
}

CScript::~CScript()
{
	if(mL) lua_close(mL);
}