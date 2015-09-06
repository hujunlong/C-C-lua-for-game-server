#pragma once
#include <mysql++.h>
#include <dbdriver.h>
#include <string>

bool InitConnection(mysqlpp::Connection& con, const char* cfg_file);

std::vector<mysqlpp::StoreQueryResult> QueryReadMulti(mysqlpp::Connection& con, const char* sql);

mysqlpp::StoreQueryResult QueryRead(mysqlpp::Connection& con, const char* sql);

mysqlpp::SimpleResult QueryWrite(mysqlpp::Connection& con, const char* sql);

mysqlpp::SimpleResult QueryWrite(mysqlpp::Connection& con, mysqlpp::Query& query);

void Binary2HexString(const void* in_data, size_t in_len, char* out_data, size_t out_len);