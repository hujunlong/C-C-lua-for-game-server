#pragma once
#include <cstring>

template<typename CharType, size_t N>
inline void NullTerminateString(CharType (&str)[N])
{
	str[N-1] = 0;
}

template<typename CharType, size_t N>
void ZeroString(CharType (&str)[N] )
{
	memset(str, 0, sizeof(str));
}

int itoa(int val, char* buf)

{

	const unsigned int radix = 10;

	char* p;

	unsigned int a; //every digit

	int len;

	char* b; //start of the digit char

	char temp;

	unsigned int u;

	p = buf;

	if (val < 0)

	{

		*p++ = '-';

		val = 0 - val;

	}

	u = (unsigned int)val;

	b = p;

	do

	{

		a = u % radix;

		u /= radix;

		*p++ = a + '0';

	} while (u > 0);

	len = (int)(p - buf);

	*p-- = 0;

	//swap

	do

	{

		temp = *p;

		*p = *b;

		*b = temp;

		--p;

		++b;

	} while (b < p);

	return len;

}