#pragma once

#include <cstdint>
#include <stdio.h>
#include <iostream>
#include <codecvt>
#include <unordered_set>



struct cstr_hash
{
	size_t operator() (const char* str) const
	{
		return stdext::hash_value(str);
	}
};

namespace std
{
	template <>
	struct equal_to<const char*> : public binary_function<const char*, const char*, bool>
	{
		bool operator()(const char* str1, const char* str2) const
		{
			return 0==strcmp(str1, str2);
		}
	};
};

typedef std::unordered_set<const char*,cstr_hash> SensitiveWord_Set;
extern SensitiveWord_Set g_sw_set;

class SensitiveWords
{
private:
	char *	 pSensitiveWord;
	uint32_t swsize;
public:
	bool GetSenstiveWordFromFile()
	{
		int iret;
		uint32_t filesize;
		FILE * fp = fopen("sensitive_word.txt","rb");
		if( fp==NULL )
			return false;
		iret = fseek(fp,0,SEEK_END);
		if( iret!=0 )
		{
			fclose(fp);
			return false;
		}
		filesize = ftell(fp);
		char * buff = new char[filesize+2+2];//begin(2) + end(2)
		*(uint16_t*)(buff+2+filesize) = 0;
		fseek(fp,0,SEEK_SET);
		iret = fread(buff+2,1,filesize,fp);
		if( iret==0 )
		{
			delete buff;
			printf("fread error: %d, %s",errno, strerror(errno));
			fclose(fp);
			return false;
		}
		fclose(fp);
		swsize = filesize;
		pSensitiveWord = buff;
		return true;
	}

	SensitiveWords()
	{
		pSensitiveWord = nullptr;
		//
		bool bret;
		bret = GetSenstiveWordFromFile();
		if( bret==false )
			throw 2;
		char* ptmp1 = pSensitiveWord;
		uint32_t pbegin = (uint32_t)ptmp1;
		uint32_t pend   = pbegin + swsize + 2 - 1;//+2(begin) -1(uint16_t)
		uint32_t ptmp2;
		for( ptmp2 = pbegin; ptmp2<pend; ++ptmp2)
		{
			if( (*(uint16_t*)ptmp2)== 0x0A0D )
			{
				*(uint16_t*)ptmp1 = (ptmp2 - ((uint32_t)ptmp1+2))<<8;
				g_sw_set.insert((ptmp1+2));
				ptmp1 = (char*)ptmp2;
				ptmp2 += 2;//主动跳过下一个关键字的第一个字符(+1,+1)
			}
		}
		if( ((uint32_t)ptmp1) != ptmp2 )
		{
			//0D 0A 73 62
			*(uint16_t*)ptmp1 = (ptmp2 - 1 - (uint32_t)ptmp1)<<8;
			g_sw_set.insert((ptmp1+2));
		}else
		{
			//0D 0A 73 62 0D 0A --> 00 02 73 62 00 00
		}

	}
	~SensitiveWords()
	{
		delete pSensitiveWord;
		pSensitiveWord = nullptr;
	}
};