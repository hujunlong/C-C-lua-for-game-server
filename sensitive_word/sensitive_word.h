#pragma once

#include <cstdint>


#define SENSITIVE_WORD_API __declspec(dllexport)


extern "C"
{
	SENSITIVE_WORD_API bool ReplaceSensitiveWord(char* pstr, int32_t len, bool& b_done);
	SENSITIVE_WORD_API bool HaveSensitivewWord(char* pstr, int32_t len, bool& b_have);
};
