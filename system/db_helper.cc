#include "db_helper.h"
#include <iostream>
#include <lua.hpp>
#include <thread>
#include <chrono>

using namespace mysqlpp;
using namespace std;

mysqlpp::StoreQueryResult QueryRead( mysqlpp::Connection& con, const char* sql )
{
	mysqlpp::StoreQueryResult res;
	try
	{
		Query query = con.query(sql);
		res = query.store();
		if (!res)
		{
			cout<< query.error() <<endl;
			cout <<"The query string is:\n" <<sql <<endl;
		}
		while (query.more_results())
		{
			query.store_next();
		}
	}
	catch(std::exception& ex)
	{
		cout <<"QueryRead error,filename is db_helper.cc" <<endl;
		cout <<"The query string is:\n" <<sql <<endl;
		cout << typeid(ex).name() << endl << ex.what() << endl;
	}

	return std::move(res);
}


std::vector<mysqlpp::StoreQueryResult> QueryReadMulti( mysqlpp::Connection& con, const char* sql )
{
//	printf("%s\n", sql);
	std::vector<mysqlpp::StoreQueryResult> all_result;
//	mysqlpp::StoreQueryResult res;
	try
	{
		Query query = con.query(sql);
		auto res = query.store();
		if (!res)
		{
			cout<< query.error() <<endl;
			cout <<"The query string is:\n" <<sql <<endl;
			return all_result;
		}
		else
		{
			all_result.push_back(res);
		}
		while (query.more_results())
		{
			auto res = query.store_next();
			if (res)
			{
				all_result.push_back(res);
			}
		}
	}
	catch(std::exception& ex)
	{
		cout <<"QueryRead error,filename is db_helper.cc" <<endl;
		cout <<"The query string is:\n" <<sql <<endl;
		cout << typeid(ex).name() << endl << ex.what() << endl;
	}

	return std::move(all_result);
}

bool InitConnection( mysqlpp::Connection& con, const char* cfg_file )
{
#ifndef WIN32
	std::this_thread::sleep_for(std::chrono::seconds(3)); //waiting for mysql start
#endif // !WIN32

	lua_State*      L = luaL_newstate();
	if (luaL_dofile(L, cfg_file))
	{
		luaL_error(L, "%s:%s", cfg_file, lua_tostring(L, -1));
		exit(-1);
	}

	char db[64];
	char host[64];
	char user[64];
	char pwd[64];
	lua_getglobal(L, "db_name");
	strcpy(db, luaL_checkstring(L, -1));
	lua_getglobal(L, "db_host");
	strcpy(host,luaL_checkstring(L, -1));
	lua_getglobal(L, "db_user");
	strcpy(user,luaL_checkstring(L, -1));
	lua_getglobal(L, "db_pwd");
	strcpy(pwd,luaL_checkstring(L, -1));


	try
	{
		con.set_option(new MultiResultsOption(true));
		con.set_option(new MultiStatementsOption(true));
		con.set_option(new ReconnectOption(true));
		con.set_option(new SetCharsetNameOption("utf8"));
		con.connect(db, host, user, pwd);
	}
	catch(std::exception& ex)
	{
		cerr <<"Connect to db failed:\n";
		cerr << typeid(ex).name() << endl << ex.what() << endl;
		return false;
	}
	cout <<"Connect to db sucessed:\n";
	return true;
}

mysqlpp::SimpleResult QueryWrite( mysqlpp::Connection& con, const char* sql )
{
	if (strlen(sql)<512)
	{
//		printf("%s\n", sql);
	}
	mysqlpp::SimpleResult res;
	try
	{
		Query query = con.query(sql);
		res = query.execute();
	}
	catch(std::exception& ex)
	{
		cout <<"QueryWrite error,filename is db_helper.cc" <<endl;
		cout <<"The query string is:\n" <<sql <<endl;
		cout << typeid(ex).name() << endl << ex.what() << endl;
	}
	return res;
}

mysqlpp::SimpleResult QueryWrite( mysqlpp::Connection& con, Query& query )
{
	mysqlpp::SimpleResult res;
	try
	{
		res = query.execute();
	}
	catch(std::exception& ex)
	{
		cout <<"QueryWrite error,filename is db_helper.cc" <<endl;
		cout << typeid(ex).name() << endl << ex.what() << endl;
	}
	return res;
}

void Binary2HexString( const void* in_data, size_t in_len, char* out_data, size_t out_len )
{
	assert(out_len>=in_len*2+3);
	size_t pos = 0;
	strcpy(out_data, "0x");
	out_data += 2;
	const char* data = (const char*)in_data;
	while(pos<=in_len)
	{
		sprintf(out_data+2*pos, "%.2x", (unsigned char)*(data+pos));
		++pos;
	}
	*(out_data+2*(pos-1)) = '\0';
}
