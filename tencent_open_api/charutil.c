/* charutil.c */

#include "charutil.h"

/****************************************************************************

	LOCAL FUNCTIONS

****************************************************************************/


/****************************************************************************
* NAME:		binarySearch
* PURPOSR:	perform binary search in uint16 array
* ENTRY:	table	- point to uint16 array
*		tablen	- length of array
*		code	- word to search
* EXIT:		int16 - index of object, -1 for no match
* AUTHOR: 	lvjie November 18, 2003
****************************************************************************/
static short binarySearch(const unsigned short *table, 
						  unsigned short tablen, 
						  unsigned short code)
{
	unsigned short head,tail,middle;

	head = 0;
	tail = tablen-1;
	if ((code < table[head])||(code > table[tail]))
		return(-1);

	while (head <= tail)
	{
		middle = (head+tail)/2;
		if (code == table[middle])
			return (middle);
		else if (code > table[middle])
			head = middle+1;
		else
			tail = middle-1;
	}

	return (NOT_SUPPORTED);
}

static int getUniLenOfGbStr( const unsigned char *p )
{
	int len = 0;

	while ( *p ) {
		if ( *p & 0x80 ) {
			p += 2;
		}
		else {
			p += 1;
		}
		len++;
	}
	return len;
}


static int getGbLenOfUniStr( const unsigned short *p )
{
	int len = 0;

	while ( *p ) {
		if ( *p < 0x80 ) {
			len += 1;
		}
		else {
			len += 2;	/* convert unsupport char to ?? */
		}
		p++;
	}
	return len;
}


/* convert gb2312 word to unicode word. 
 return ? if unsupported */
unsigned short gbc2uc( unsigned short gbc )
{
	short index = binarySearch(gbkAGbkcode, CODE_NUM, gbc);

	if ( index == NOT_SUPPORTED ) {
		return '?';
	}
	else {
		return gbkAUnicode[index];
	}
}


/* convert unicode word to gb2312 word. 
 return ?? if unsupported */
unsigned short uc2gbc( unsigned short uc )
{
	short index = binarySearch(uniAUnicode, CODE_NUM, uc);

	if ( index == NOT_SUPPORTED ) {
		return 0x3f3f;	/* ?? */
	}
	else {
		return uniAGbkcode[index];
	}
}


// 从word中取出指定的部分,s指定高位,e指定低位,例如:
// xxxxs--------exx
// e是2,s是11
// 返回:0000s--------e
static unsigned short cut_word(unsigned short w, unsigned char s, unsigned char e)
{
	unsigned short m;
	unsigned char l;

	l = s - e + 1;
	if ( l == 16 ) {
		return w;
	}

	w = w >> e;		// 00xxxxs--------e
	m = 1 << l;		// 0000010000000000
	w &= ( m - 1 );	// 00xxxxs--------e & 0000001111111111
	return w;		// 000000s--------e
}


/****************************************************************************

	GLOBAL FUNCTIONS

****************************************************************************/


/****************************************************************************
* NAME:		gb2uni
* PURPOSR:	Convert gbk string to unicode string
*			the byte order of unicode is dependent on CPU
*			the two-byte code in GBK is always big-endian
* ENTRY:	gbstr	gbk string
*			unibuf	output buffer
*			buflen	length of buffer
* EXIT:		length of unicode string
****************************************************************************/
int gb2uni( const unsigned char *gbstr, unsigned short *unibuf, int buflen )
{
	int unilen, i;
	unilen = getUniLenOfGbStr(gbstr);
	if ( !unibuf || ( buflen <= 0 ) ) {
		return unilen;
	}

	if ( unilen > buflen ) {
		unilen = buflen;
	}

	for ( i = 0; i < unilen; i++ ) {
		if ( *gbstr & 0x80 ) {
			/* gbk-code is big-endian */
			unsigned short gbc = ( gbstr[0] << 8 ) + gbstr[1];
			unibuf[i] = gbc2uc(gbc);
			gbstr += 2;
		}
		else {
			unibuf[i] = *gbstr;
			gbstr += 1;
		}
	}

	return unilen;
}


/****************************************************************************
* NAME:		uni2gb
* PURPOSR:	Convert unicode string to gbk string
*			the byte order of unicode MUST be consistent with underlying CPU
*			the two-byte code in GBK is always big-endian
* ENTRY:	unistr	unicode string
*			gbbuf	output buffer
*			buflen	length of buffer
* EXIT:		length of gbk string
****************************************************************************/
int uni2gb( const unsigned short *unistr, unsigned char *gbbuf, int buflen )
{
	int gblen, i;
	gblen = getGbLenOfUniStr(unistr);
	if ( !gbbuf || ( buflen <= 0 ) ) {
		return gblen;
	}

	if ( gblen > buflen ) {
		gblen = buflen;
	}

	i = 0;
	while ( i < gblen ) {
		if ( *unistr < 0x80 ) {
			gbbuf[i] = (char)(*unistr);
			i++;
		}
		else {
			/* gbk-code is big-endian */
			unsigned short t = uc2gbc(*unistr);
			gbbuf[i++] = (unsigned char)( t >> 8 );
			gbbuf[i++] = (unsigned char)( t & 0xff );
		}
		unistr++;
	}

	return gblen;
}


/*--------------------------------------------------------------------------------------------------------------------
UTF-8就是以8位为单元对UCS进行编码。从UCS-2到UTF-8的编码方式如下：

UCS-2编码(16进制) UTF-8 字节流(二进制) 
0000 - 007F 0xxxxxxx 
0080 - 07FF 110xxxxx 10xxxxxx 
0800 - FFFF 1110xxxx 10xxxxxx 10xxxxxx 

例如“汉”字的Unicode编码是6C49。6C49在0800-FFFF之间，所以肯定要用3字节模板了：
1110xxxx 10xxxxxx 10xxxxxx。
将6C49写成二进制是：0110 110001 001001， 用这个比特流依次代替模板中的x，得到：11100110 10110001 10001001，即E6 B1 89。
--------------------------------------------------------------------------------------------------------------------*/


// 先根据转换规则计算utf8串长度,同时根据输出缓冲区大小判断可以转换的ucs2码数量
// 转换
int ucs2ToUtf8(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len)
{
	int i, j, l, max_i;
	unsigned short w, w1;

	i = 0;
	max_i = 0;
	j = 0;
	w = ucs[i];
	while (w) {
		if ( w <= 0x7f ) {
			l = 1;
		}
		else if ( w <= 0x7ff ) {
			l = 2;
		}
		else {
			l = 3;
		}

		j += l;		// 累计输出长度
		if ( j <= cbuf_len ) {
			max_i = i;
		}
		i++;		// 下一个ucs2
		w = ucs[i];
	}

	if ( !cbuf || ( cbuf_len == 0 ) ) {
		return j;
	}

	j = 0;
	for  ( i = 0; i <= max_i; i++ ) {
		w = ucs[i];
		if ( w <= 0x7f ) {
			l = 1;
			cbuf[j++] = (unsigned char)w;
		}
		else if ( w <= 0x7ff ) {
			l = 2;
			w1 = cut_word(w, 10, 6);
			cbuf[j++] = 0xc0|w1;
			w1 = cut_word(w, 5, 0);
			cbuf[j++] = 0x80|w1;
		}
		else {
			l = 3;
			w1 = cut_word(w, 15, 12);
			cbuf[j++] = 0xe0|w1;
			w1 = cut_word(w, 11, 6);
			cbuf[j++] = 0x80|w1;
			w1 = cut_word(w, 5, 0);
			cbuf[j++] = 0x80|w1;
		}
	}

	return j;
}


// 先根据转换规则计算ucs2串长度, 输出缓冲区大小判断需要转换的ucs2码数量
// 转换
int utf8ToUcs2(const unsigned char *s, unsigned short *wbuf, int wbuf_len)
{
	int i, j, k;
	unsigned char c;
	unsigned char c3, c2, c4;

	i = 0;
	j = 0;
	c = s[i++];
	while (c) {
		c3 = c & 0xe0;
		c4 = c & 0xf0;
		if ( (c & 0x80) == 0 ) {
			// 单字节
		}
		else if ( c3 == 0xc0 ) {
			c2 = s[i++] & 0xc0;
			if ( c2 != 0x80 ) {
				break;
			}
		}
		else if ( c4 == 0xe0 ) {
			c2 = s[i++] & 0xc0;
			if ( c2 != 0x80 ) {
				break;
			}
			c2 = s[i++] & 0xc0;
			if ( c2 != 0x80 ) {
				break;
			}
		}
		else {
			break;	// 错误,认为结束
		}

		j++;
		c = s[i++];
	}

	if ( !wbuf || ( wbuf_len == 0 ) ) {
		return j;
	}

	if ( wbuf_len < j ) {
		j = wbuf_len;
	}

	i = 0;
	for ( k = 0; k < j; k++ ) {
		c = s[i++];
		c3 = c & 0xe0;
		c4 = c & 0xf0;
		if ( (c & 0x80) == 0 ) {
			// 单字节
			wbuf[k] = c;
		}
		else if ( c3 == 0xc0 ) {
			// 取自两个字节
			wbuf[k] = (c & 0x1f) << 6;
			c = s[i++];
			wbuf[k] |= ( c & 0x3f );
		}
		else if ( c4 == 0xe0 ) {
			// 取自3个字节
			wbuf[k] = c << 12;
			c = s[i++];
			wbuf[k] |= ( (c & 0x3f) << 6 );
			c = s[i++];
			wbuf[k] |= (c & 0x3f);
		}
	}

	return j;
}

/* end of charutil.c */
