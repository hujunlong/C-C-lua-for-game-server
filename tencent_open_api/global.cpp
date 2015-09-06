
#include <algorithm>
#include "global.h"
#include "charwrap.h"

using namespace std;

bool LY::g_is_number( const string& str )
{
	if (str.length()==0)
	{
		return false;
	}
	for (int i = 0; i < str.length(); i++)
	{
		if( str[i] < '0' || str[i] > '9')
		{
			return false;
		}
	}
	return true;
}

std::string LY::g_read_string_until( const string& str, int start, const string& until_string )
{
	if (str.length()==0)
	{
		return str;
	}
	if (until_string.length()==0)
	{
		return "";
	}
	string::size_type n = str.find(until_string, start);
	if (n != string::npos)
	{
		return str.substr(start, n-start + until_string.length());
	}
	else
		return "";

}

#define BASE64_FLAG_NONE 0
#define BASE64_FLAG_NOPAD 1
#define BASE64_FLAG_NOCRLF 2

int internal_Base64EncodeGetRequiredLength(int nSrcLen, unsigned long dwFlags= BASE64_FLAG_NONE)
{
	__int64 nSrcLen4=static_cast<__int64>(nSrcLen)*4;


	int nRet = static_cast<int>(nSrcLen4/3);

	if ((dwFlags & BASE64_FLAG_NOPAD) == 0)
		nRet += nSrcLen % 3;

	int nCRLFs = nRet / 76 + 1;
	int nOnLastLine = nRet % 76;

	if (nOnLastLine)
	{
		if (nOnLastLine % 4)
			nRet += 4-(nOnLastLine % 4);
	}

	nCRLFs *= 2;

	if ((dwFlags & BASE64_FLAG_NOCRLF) == 0)
		nRet += nCRLFs;

	return nRet;
}

bool internal_Base64Encode(const unsigned char *pbSrcData, int nSrcLen,char* szDest, __inout int *pnDestLen,
	unsigned short dwFlags = BASE64_FLAG_NONE)
{
	static const char s_chBase64EncodingTable[64] = {
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
		'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g',	'h',
		'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
		'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/' };

		if (!pbSrcData || !szDest || !pnDestLen)
		{
			return false;
		}

		if(*pnDestLen < internal_Base64EncodeGetRequiredLength(nSrcLen, dwFlags))
		{
			return false;
		}

		int nWritten( 0 );
		int nLen1( (nSrcLen/3)*4 );
		int nLen2( nLen1/76 );
		int nLen3( 19 );

		for (int i=0; i<=nLen2; i++)
		{
			if (i==nLen2)
				nLen3 = (nLen1%76)/4;

			for (int j=0; j<nLen3; j++)
			{
				unsigned long dwCurr(0);
				for (int n=0; n<3; n++)
				{
					dwCurr |= *pbSrcData++;
					dwCurr <<= 8;
				}
				for (int k=0; k<4; k++)
				{
					unsigned char b = (unsigned char)(dwCurr>>26);
					*szDest++ = s_chBase64EncodingTable[b];
					dwCurr <<= 6;
				}
			}
			nWritten+= nLen3*4;

			if ((dwFlags & BASE64_FLAG_NOCRLF)==0)
			{
				*szDest++ = '\r';
				*szDest++ = '\n';
				nWritten+= 2;
			}
		}

		if (nWritten && (dwFlags & BASE64_FLAG_NOCRLF)==0)
		{
			szDest-= 2;
			nWritten -= 2;
		}

		nLen2 = (nSrcLen%3) ? (nSrcLen%3 + 1) : 0;
		if (nLen2)
		{
			unsigned long dwCurr(0);
			for (int n=0; n<3; n++)
			{
				if (n<(nSrcLen%3))
					dwCurr |= *pbSrcData++;
				dwCurr <<= 8;
			}
			for (int k=0; k<nLen2; k++)
			{
				unsigned char b = (unsigned char)(dwCurr>>26);
				*szDest++ = s_chBase64EncodingTable[b];
				dwCurr <<= 6;
			}
			nWritten+= nLen2;
			if ((dwFlags & BASE64_FLAG_NOPAD)==0)
			{
				nLen3 = nLen2 ? 4-nLen2 : 0;
				for (int j=0; j<nLen3; j++)
				{
					*szDest++ = '=';
				}
				nWritten+= nLen3;
			}
		}

		*pnDestLen = nWritten;
		return true;
}

bool LY::g_base64_encode(const string& src_data, __out string& out_data)
{
	int out_len = internal_Base64EncodeGetRequiredLength(src_data.length ());
	out_data.resize (out_len);
	int actual_out_len = out_len;
	internal_Base64Encode((const unsigned char *)src_data.c_str (), src_data.length (), 
		(char*)out_data.c_str (), &actual_out_len);
	out_data.resize (actual_out_len);
	return actual_out_len <= out_len;
}

void LY::g_to_upper( __inout string &data )
{
	transform(data.begin (), data.end (), data.begin (), toupper);
}

void LY::g_to_lower( __inout string &data )
{
	transform(data.begin (), data.end (), data.begin (), tolower);
}

int LY::g_extract_string(const string& src_data,  char* split_string, __out vector<string>& lists )
{
	lists.resize (0);
	char *token;
	token = strtok((char*)src_data.c_str (), split_string);
	while( token != NULL )
	{
		lists.push_back (token);

		token = strtok( NULL, split_string );  
	}


	return src_data.length ();
}

std::string LY::g_int_to_str( int value , int radix)
{
	char buff[64];
	_itoa_s(value, buff, sizeof(buff), radix);
	string ret = buff;
	return ret;
}

std::string LY::g_int_to_str( unsigned int value, int radix /*= 10*/ )
{
	char buff[64];
	_ultoa(value, buff, radix);
	string ret = buff;
	return ret;
}

std::string LY::g_int_to_str( __int64 value , int radix)
{
	char buff[256];
	_i64toa_s(value,buff,sizeof(buff),radix);
	string ret = buff;
	return ret;	
}

int LY::g_str_to_int( const string & value )
{
	return atoi(value.c_str());	  
}

__int64 LY::g_str_to_int64( const string& value )
{
	return _atoi64(value.c_str());
}

std::string LY::g_ascii_to_utf8( const string& value )
{
	string utf8_string;
	if (value.length()==0)
	{
		return utf8_string;
	}

	int wbuf_len = gbk_to_ucs16((const unsigned char*)value.c_str(),NULL,0);
	wstring wstr(wbuf_len,0);

	gbk_to_ucs16((const unsigned char*)value.c_str(), (unsigned short *)wstr.c_str(), wbuf_len);

	int cbuf_len = ucs16_to_utf8((const unsigned short *)wstr.c_str(), NULL, 0);
	utf8_string.resize(cbuf_len);

	ucs16_to_utf8((const unsigned short *)wstr.c_str(), (unsigned char *)utf8_string.c_str(), cbuf_len);

	return utf8_string;
}

std::string LY::g_utf8_to_ascii( const string& value )
{
	string asc_string;
	if (value.length()==0)
	{
		return asc_string;
	}

	int wbuf_len = utf8_to_ucs16((const unsigned char *)value.c_str(), NULL, 0);
	wstring wstr(wbuf_len,0);

	utf8_to_ucs16((const unsigned char *)value.c_str(), (unsigned short *)wstr.c_str(), wbuf_len);

	int cbuf_len = ucs16_to_gbk((const unsigned short *)wstr.c_str(), NULL, 0);
	asc_string.resize(cbuf_len);

	ucs16_to_gbk((const unsigned short *)wstr.c_str(), (unsigned char *)asc_string.c_str(), cbuf_len);

	return asc_string;
}
