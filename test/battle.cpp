#include <luabind/lua_include.hpp>
//#include <luabind/luabind.hpp>
#include <iostream>
#include <time.h>
#include <cstdint>
#include <cassert>

using namespace std;

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
			const char* value = lua_tolstring(L, -1, &value_len); 
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
	bool result = false;
	TraverseTable(L, [&](lua_State* L){
		if (lua_istable(L, -1)) 
		{
			result = true;
			return true;
		}
	});
	return result;
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
	//	memset(sub_name, 0, sizeof(32));
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
			const char* value = lua_tolstring(L, -1, &value_len); 
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

void main00000()
{
	auto L = luaL_newstate();
	luaL_openlibs(L);
	
//	open(L);
	if (luaL_dofile(L, "battle.lua") != 0)
	{
		printf("%s", lua_tostring(L,-1));
		return;
	}

//	object o = luabind::globals(L);
	//char table_name[] = "battle"; 
	//o =o[table_name];

	lua_getglobal(L, "battle");
	

	auto start = ::clock();
	for (int i=0; i<1000; ++i)
	{
		g_sb.Reset();
		Table2Xml(L, "battle");
	}
	auto span = ::clock()-start;
	
	std::cout <<span;
	

	system("pause");
}