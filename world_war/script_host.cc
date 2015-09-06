#include "script_host.h"
//#include <luabind/luabind.hpp>
#include <lua.hpp>
#include <iostream>
#include <cstring>
#include <boost/noncopyable.hpp>
#include <boost/progress.hpp>
#include "script_tool.h"
#include "../protocol/db.h"
#include "../protocol/internal.h"
//#include "../protocol/db_game.h"
#include "../protocol/town.h"
//#include "luabind_expand.h"
#include "../system/libtimer.h"

static const char kScriptConfigPath[] = "scripts_cfg.lua";

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
			//if (lua_pcall(L, prama_count, 0, 0) != 0)
			//{
			//	printf("CallFunction '%s': %s\n", name, lua_tostring(L, -1));
			//	return false;
			//}
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



void* Realloc (void *ud, void *ptr, size_t osize, size_t nsize)
{
//	std::cout <<nsize <<' ';
	return std::realloc(ptr, nsize);
}

bool CScript::Init( const char* file )
{
//	mL =  lua_newstate(Realloc, nullptr);
	mL = luaL_newstate();
	luaL_openlibs(mL);
//	luaJIT_setmode(mL, -1,  LUAJIT_MODE_FUNC|LUAJIT_MODE_OFF|LUAJIT_MODE_DEBUG);

//	using namespace luabind;
//	open(mL);

	//module(mL)
	//[
	//	def("Send2Db", &Send2DbForScripts),
	//	def("Send2Gate", &Send2GateForScripts)
	//];

	//module(mL)
	//[
	//	class_<DbType>("DbType").enum_("constants")
	//	[
	//		value("kAllGameBaseInfo", (int)db::AllGameBaseInfo::kType),
	//		value("kGetAllTownItems", (int)db::GetAllTownItems::kType)
	//	]
	//];

	//注册函数给lua调用
	lua_pushcfunction(mL, ConvertFightRecord);
	lua_setglobal(mL, "ConvertFightRecord");

	if (luaL_dofile(mL, file) != 0)
	{
		printf("%s", lua_tostring(mL,-1));
		std::cerr <<"\nFailed to load " <<file <<std::endl;
		return false;
	}

	//test begin
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
	//test end

	return true;
}

void CScript::ReloadModified()
{
	/*try
	{
		luabind::call_function<void>(mL, "ReloadModified");
	}
	catch (std::exception& e)
	{
		printf("%s\n", e.what());
		printf("%s", lua_tostring(mL,-1));
	}
	catch (...)
	{
	}*/

	CallFunction(mL, "ReloadModified");
}

void CScript::RunOnce()
{
	//try
	//{
	//	luabind::call_function<void>(mL, "RunOnce");
	//}
	//catch (std::exception& e)
	//{
	//	printf("%s\n", e.what());
	//	printf("%s", lua_tostring(mL,-1));
	//}
	//catch (...)
	//{
	//}

	CallFunction(mL,  "RunOnce");
}

void CScript::ProcessMsgFromDb( const MqHead& head, uint8_t* data )
{
	if (!CallFunction(mL, "ProcessMsgFromDb", (void*)&head, data))
	{
		printf("uid:%d msg_type:%d\n",head.aid, head.type);
	}
	//try
	//{
	//	luabind::call_function<void>(mL, "ProcessMsgFromDb", LightUserData(&head), LightUserData(data));
	//}
	//catch (std::exception& e)
	//{
	//	printf("%s\n", e.what());
	//	printf("%s", lua_tostring(mL,-1));
	//}
	//catch (...)
	//{
	//}
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
		Send2Gate(h2return, &goe, sizeof(goe));
	}
	//try
	//{
	//	luabind::call_function<void>(mL, "ProcessMsgFromGate", LightUserData(&head), LightUserData(data));
	//}
	//catch (std::exception& e)
	//{
	//	printf("%s\n", e.what());
	//	const char* err_msg =  lua_tostring(mL,-1);
	//	printf("%s", err_msg);
	//	GameOperationException goe = {head.type, (int16_t)strlen(err_msg)};
	//	memcpy(goe.error, err_msg, sizeof(goe.error));
	//	MqHead h2return = {goe.kType, sizeof(goe), head.flag};
	//	Send2Gate(h2return, &goe, sizeof(goe));
	//}
	//catch (...)
	//{
	//}
}

CScript::~CScript()
{
	if(mL) lua_close(mL);
}

void CScript::ProcessMsgFromGM( const MqHead& head, uint8_t* data, size_t len)
{
	if (!CallFunction(mL, "ProcessMsgFromGM", (void*)&head, data + 2, len - 2))
	{
		const char* err_msg =  lua_tostring(mL,-1);
		GameOperationException goe = {head.type, (int16_t)strlen(err_msg)};
		memcpy(goe.error, err_msg, sizeof(goe.error));
		MqHead h2return = {head.aid, goe.kType, head.flag};
		Send2Gate(h2return, &goe, sizeof(goe));
	}
}

const char*  CScript::GetWorldWarServerAddress()
{
	lua_getglobal(mL, "GetWorldWarServerAddress");
	lua_pcall(mL, 0, 1, 0);
	const char* ptr = lua_tostring(mL, -1);
	printf("connect world_war server %s\n",ptr);
	return ptr;
}
void CScript::RegisterWorldWar()
{
	CallFunction(mL, "RegisterWorldWar");
}


void CScript::ProcessMsgFromWorldWar( const MqHead& head, uint8_t* data, size_t len )
{
	if (!CallFunction(mL, "ProcessMsgFromWorldWar", (void*)&head, data, len))
	{
		/*
		const char* err_msg =  lua_tostring(mL,-1);
		GameOperationException goe = {head.type, (int16_t)strlen(err_msg)};
		memcpy(goe.error, err_msg, sizeof(goe.error));
		MqHead h2return = {head.aid, goe.kType, head.flag};
		Send2WorldWar(h2return, &goe, sizeof(goe));
		*/
	}
}

CScript::CScript()
{
	mL = nullptr;
}

