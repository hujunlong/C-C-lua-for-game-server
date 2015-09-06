
// 提供utf-8、utf-16、GBK字符串的转换功能
// 这只是一个包装，它使用Windows的API，或者与平台无关的独立代码
// 接口可以被串联使用
// 即这里只提供：utf-16<->gbk和utf-8<->utf16，但可以用户组合出utf-8<->gbk
// 不将utf-8<->gbk放到这里，因为不想使用可能与平台相关的动态内存分配

#include "string.h"
#include "charwrap.h"

#ifdef USE_WIN_FUN
#include "windows.h"
#else
#include "charutil.h"
#endif

static int ucslen(const unsigned short *ucs)
{
	const unsigned short *p;
	int ucs_len = 0;
	
	p = ucs;
	while (*p++) {
		ucs_len++;
	}
	return ucs_len;
}

// 接口约定:
// 输入的字符串必须以0结尾作为字符串结束标志
// 返回的结果不添加结尾的0

// 说明:
// 使用MultiByteToWideChar时如果将MultiByte的长度设为-1,返回的字符串也会以0结尾
// 如果指定MultiByte的长度,返回的字符串就不包含结尾的0
// WideCharToMultiByte也有类似行为
// 我既然不需要结尾的0,使用它们时就都指定了长度

int gbk_to_ucs16(const unsigned char *gbks, unsigned short *wbuf, int wbuf_len)
{
#ifdef USE_WIN_FUN
	int gbks_len;
	gbks_len = strlen(gbks);
	return MultiByteToWideChar(0, 0, (const char *)gbks, gbks_len, wbuf, wbuf_len);
#else
	return gb2uni(gbks, wbuf, wbuf_len);
#endif
}


int ucs16_to_gbk(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len)
{
#ifdef USE_WIN_FUN
	int  ucs_len;
	ucs_len = ucslen(ucs);
	return WideCharToMultiByte(0, 0, ucs, ucs_len, (char *)cbuf, cbuf_len, NULL, NULL);
#else
	return uni2gb(ucs, cbuf, cbuf_len);
#endif
}


int ucs16_to_utf8(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len)
{
#ifdef USE_WIN_FUN
	int ucs_len;
	ucs_len = ucslen(ucs);
	return WideCharToMultiByte(CP_UTF8, 0, ucs, ucs_len, (char *)cbuf, cbuf_len, NULL, NULL);
#else
	return ucs2ToUtf8(ucs, cbuf, cbuf_len);
#endif
}

int utf8_to_ucs16(const unsigned char *s, unsigned short *wbuf, int wbuf_len)
{
#ifdef USE_WIN_FUN
	int slen;
	slen = strlen(s);
	return MultiByteToWideChar(CP_UTF8, 0, (const char *)s, slen, wbuf, wbuf_len);
#else
	return utf8ToUcs2(s, wbuf, wbuf_len);
#endif
}

// The End
