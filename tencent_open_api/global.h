#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include <string>
#include <vector>

using namespace std;


namespace LY
{
	//判断是否是纯数字
	bool g_is_number(const string& str);

	/*
	 * 读字符串直到until_string字符串（包括until_string字符）
	 * 如果没有发现until_string字符串，则返回空串
	*/
	string g_read_string_until(const string& str, int start, const string& until_string);

	//base64编码
	bool g_base64_encode(const string& src_data, __out string& out_data);

	//转换为大写
	void g_to_upper(__inout string &data);

	//转换为小写
	void g_to_lower(__inout string &data);

	//分割字符串,输出到lists中，返回分割后的个数，
	//注意：split_string包含多个不同分割符，每一个字符表示一个分隔符
	int g_extract_string(const string& src_data,  char* split_string, __out vector<string>& lists);

	//整形转字符串, radix表示进制,值为2-36
	string g_int_to_str(int value , int radix = 10);
	
	//无符号整形转字符串, radix表示进制,值为2-36
	string g_int_to_str(unsigned int value, int radix = 10);
	
	//64位整形转字符串, radix表示进制,值为2-36
	string g_int_to_str(__int64 value, int radix = 10);

	//字符串转整形
	int g_str_to_int(const string & value);

	//字符串转64位整形
	__int64 g_str_to_int64(const string& value);

	//ascii字符转换为utf8编码
	string g_ascii_to_utf8(const string& value);

	//utf8编码转换为ascii字符
	string g_utf8_to_ascii(const string& value);


}	//namespace LY


#endif	//_GLOBAL_H_