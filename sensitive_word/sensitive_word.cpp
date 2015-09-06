#include "sensitive_word.h"
#include "sensitive.h"


typedef std::unordered_set<const char*,cstr_hash> SensitiveWord_Set;
SensitiveWord_Set g_sw_set;

SensitiveWords sw;


bool utf8_split(uint8_t* pstr, uint8_t* pend, 
				uint32_t n_words, char* pwords, uint32_t& bytes)
{
	uint32_t t_val16=0, t_val32=0;
	//
	pwords[0] = 0;
	bytes = 0;
	char word[8] = "";
	uint8_t* pcur = pstr;
	uint32_t len = (uint32_t)pend - (uint32_t)pcur;
	uint32_t s_words = 0;
	uint32_t i;
	for( i = 0; i < len; ++i)
	{
		if( pcur[i] <= 0x7F )
		{
			word[0] = pcur[i];
			word[1] = 0;
			++bytes;
		}else
		{
			if( (i+1)<len )
			{
				t_val16 = *(uint16_t*)(pcur+i);
				if( (t_val16&0xC0E0)==0x80C0 )
				{
					*(uint16_t*)word = t_val16;
					++i;
					word[2] = 0;
					bytes += 2;
				}else
				{
					if( (i+2)<len )
					{
						t_val32 = *(uint8_t*)(pcur+i+2);
						t_val32 <<= 16;
						t_val32 += t_val16;
						if( (t_val32&0xC0C0F0)==0x8080E0 )
						{
							*(uint32_t*)word = t_val32;
							i += 2;
							word[3] = 0;
							bytes += 3;
						}else
						{
							//大于3个字节的字符,未处理,直接返回false
							return false;
						}
					}
				}
			}
		}
		++s_words;
		strcat(pwords, word);
		if( s_words == n_words )
			break;
	}
	return true;
}

bool HaveSensitivewWord(char* pstr, int32_t len, bool& b_have)
{
	//
	b_have = false;
	if( pstr==nullptr || len==0 )
		return false;

	bool bres;
	char word[8] = "";
	char words[64] = "";
	char* pcur = pstr;
	char* pend = pstr+len;
	char* ptmp;
	uint32_t bytes;
	SensitiveWord_Set::const_iterator sw_it;

	for( ; (uint32_t)pcur < (uint32_t)pend;)
	{
		ptmp = pcur;
		bres = utf8_split((uint8_t*)ptmp, (uint8_t*)pend, 1, word, bytes);
		pcur += bytes;
		words[0] = 0;
		for(int32_t i=0; i<7; ++i)//最多8个字符
		{
			if(bres == false)
				return false;//failed
			//
			strcat(words, word);
			sw_it = g_sw_set.find(words);
			if( sw_it != g_sw_set.end() )
			{
				b_have=true;
				return true;
			}
			ptmp += bytes;
			if(  ptmp==pend )
				break;
			bres = utf8_split((uint8_t*)ptmp, (uint8_t*)pend, 1, word, bytes);
		}
	}
	return true;
}
bool ReplaceSensitiveWord(char* pstr, int32_t len, bool& b_done)
{
	//
	b_done = false;
	if( pstr==nullptr || len==0 )
		return false;

	bool bres;
	char word[8] = "";
	char words[64] = "";
	char* pcur = pstr;
	char* pend = pstr+len;
	char* ptmp;
	uint32_t bytes, add_bytes;
	SensitiveWord_Set::const_iterator sw_it;

	for( ; (uint32_t)pcur < (uint32_t)pend;)
	{
		ptmp = pcur;
		bres = utf8_split((uint8_t*)ptmp, (uint8_t*)pend, 1, word, bytes);
		add_bytes = bytes;
		words[0] = 0;
		for(int32_t i=0; i<7; ++i)//最多8个字符
		{
			if(bres == false)
				return false;//failed
			//
			strcat(words, word);
			sw_it = g_sw_set.find(words);
			if( sw_it != g_sw_set.end() )
			{
				b_done=true;
				ptmp = (char*)(*sw_it);
				add_bytes = *(uint8_t*)(ptmp-1);
				memset(pcur, '*', add_bytes);
				break;
			}
			ptmp += bytes;
			if(  ptmp==pend )
				break;
			bres = utf8_split((uint8_t*)ptmp, (uint8_t*)pend, 1, word, bytes);
		}
		pcur += add_bytes;
	}
	return true;
}
