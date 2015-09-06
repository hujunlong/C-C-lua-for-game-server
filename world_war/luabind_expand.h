#pragma once

#include <luabind/luabind.hpp>

struct LightUserData
{
	LightUserData(const void* ptr)
	{
		val=ptr;
	}
	template<typename T>
	operator T*() 
	{
		return (T*)val;
	}
private:
	const void* val;
};

namespace luabind
{

	template <>
	struct default_converter<LightUserData>
		: native_converter_base<LightUserData>
	{
		static int compute_score(lua_State* L, int index)
		{
			return lua_type(L, index) == LUA_TLIGHTUSERDATA ? 0 : -1;
		}

		LightUserData from(lua_State* L, int index)
		{
			return lua_touserdata(L, index);
		}

		void to(lua_State* L, const LightUserData& value)
		{
			lua_pushlightuserdata(L, const_cast<LightUserData&>(value));
		}
	};

} // namespace luabind