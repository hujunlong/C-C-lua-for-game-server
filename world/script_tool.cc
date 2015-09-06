#include "script_tool.h"
#include "transfer.h"
#include "../tools/msg_helper.h"
#include "../tools/string.h"
#include <string>
#include <zlib.h>
#include <iostream>

FUNCTION_EXPORT void Send2Db( const MqHead& head, void* data, int len )
{
	GetMQ2DB().Send(head, data, len);
}

FUNCTION_EXPORT void Send2Gate( const MqHead& head , void* data, int len )
{
	GetMQ2Gate().Send(head, data, len);
}


FUNCTION_EXPORT void Send2GM( const MqHead& head, void* data, int len )
{
	GetMQ4GM().Send(head, data, len);
}

FUNCTION_EXPORT void Send2Interact( const MqHead& head, void* data, int len )
{
	GetMQ4Interact().Send(head, data, len);
}

FUNCTION_EXPORT void Send2WorldWar( const MqHead& head, void* data, int len )
{
	GetMQ2WorldWar().Send(head, data, len);
}


FUNCTION_EXPORT void* MovePtr( void* ptr, int offset )
{
	return (char*)ptr+offset;
}

namespace
{
	struct StrBuilder
	{
		uint8_t data[256*1024];
		uint8_t* p;
		void Reset()
		{
			p = data;
		}
		void AddStr(const char* str, size_t len)
		{
			assert(len<100);
			memcpy(p, str, len);
			p += len;
		}

		void AddStr(const char* str)
		{
			size_t len = strlen(str);
			memcpy(p, str, len);
			p += len;
		}

		template<size_t N>
		void AddStr(char (&str)[N])
		{
			memcpy(p, str, N-1);
			p += N-1;
		}

		size_t TotalLen()
		{
			return p-data;
		}

	}g_sb;


}
/*
FUNCTION_EXPORT void ResetStringBuilder()
{
	g_sb.Reset();
}

FUNCTION_EXPORT void AddString2Builder(const char* str, size_t len)
{
	g_sb.AddStr(str, len);
}

FUNCTION_EXPORT size_t GetBuilderStringLength()
{
	return g_sb.TotalLen();
}

FUNCTION_EXPORT char* GetBuilderString()
{
	return (char*)g_sb.data;
}
*/
namespace
{
	char head[]= "<";
	char end_head[] = "</";
	char tail[]= ">";
	char end_tail[]= "/>";

	void Table2Xml(lua_State* L, const char* name);

	template<typename Func>
	void TraverseTable(lua_State* L, Func f)
	{
		int index = lua_gettop(L);
		lua_pushnil(L);
		while (lua_next(L, index) != 0)
		{
			f(L);
			lua_pop(L,1);
		}
	}

	const char* ToSting(lua_State* L, size_t& len)
	{
		if (lua_isnumber(L, -1))
		{
			static char sz[32];
			len = itoa(lua_tointeger(L,-1), sz);
			return sz;
		}
		return lua_tolstring(L, -1, &len);
	}

	void ProduceLeafNode(lua_State* L, const char* name)
	{
		g_sb.AddStr(head);
		g_sb.AddStr(name);
		g_sb.AddStr(" ");
		TraverseTable(L, [&](lua_State* L){
			if (!lua_istable(L, -1))
			{
				size_t key_len=0;
				size_t value_len = 0;
				const char* key = lua_tolstring(L, -2, &key_len);
				const char* value = ToSting(L, value_len);
				g_sb.AddStr(key, key_len);
				g_sb.AddStr("=");
				g_sb.AddStr("\"");
				g_sb.AddStr(value, value_len);
				g_sb.AddStr("\"");
			}
		});
		g_sb.AddStr(end_tail);
	}

	bool HasSubTable(lua_State* L)
	{
		int index = lua_gettop(L);
		lua_pushnil(L);
		while (lua_next(L, index) != 0)
		{
			if (lua_istable(L, -1))
			{
				lua_pop(L,1);
				lua_pop(L,1);
				return true;
			}
			lua_pop(L,1);
		}
		return false;
	}

	bool IsArray(lua_State* L)
	{
		return lua_objlen(L, -1)>0;
	}

	void ProduceArray(lua_State* L, const char* name)
	{
		g_sb.AddStr(head);
		g_sb.AddStr(name);
		g_sb.AddStr(tail);
		char sub_name[32];
		size_t len = strlen(name)-1;
		memcpy(sub_name, name, len);
		sub_name[len]=0;

		TraverseTable(L, [&](lua_State* L){
			Table2Xml(L, sub_name);
		});
		g_sb.AddStr(end_head);
		g_sb.AddStr(name);
		g_sb.AddStr(tail);
	}

	void ProduceNormalTable(lua_State* L, const char* name)
	{
		g_sb.AddStr(head);
		g_sb.AddStr(name);
		g_sb.AddStr(" ");
		TraverseTable(L, [&](lua_State* L){
			if (!lua_istable(L, -1))
			{
				size_t key_len=0;
				size_t value_len = 0;
				const char* key = lua_tolstring(L, -2, &key_len);
				const char* value = ToSting(L, value_len);
				g_sb.AddStr(key, key_len);
				g_sb.AddStr("=");
				g_sb.AddStr("\"");
				g_sb.AddStr(value, value_len);
				g_sb.AddStr("\"");
			}
		});
		g_sb.AddStr(tail);
		TraverseTable(L, [&](lua_State* L){
			if (lua_istable(L, -1))
			{
				size_t key_len=0;
				const char* key = lua_tolstring(L, -2, &key_len);
				Table2Xml(L, key);
			}
		});
		g_sb.AddStr(end_head);
		g_sb.AddStr(name);
		g_sb.AddStr(tail);
	}


	void Table2Xml(lua_State* L, const char* name)
	{
		if (!HasSubTable(L))
		{
			ProduceLeafNode(L, name);
		}
		else
		{
			if (IsArray(L))
			{
				ProduceArray(L, name);
			}
			else
			{
				ProduceNormalTable(L, name);
			}
		}
	}

}



FUNCTION_EXPORT int ConvertFightRecord( lua_State* L )
{
	g_sb.Reset();
	Table2Xml(L, "battle");
	static uint8_t buf[16*1024];
	unsigned long buf_len = sizeof(buf);
	compress(buf, &buf_len, g_sb.data, g_sb.TotalLen());
	if (buf_len>kMaxFightRecordLength)
	{
		std::cout <<"fight record too long:"<<buf_len<<std::endl;
		buf_len = kMaxFightRecordLength;
	}
	lua_pushlightuserdata(L, buf);
	lua_pushnumber(L, buf_len);
	return 2;
}


