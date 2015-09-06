#ifndef _CHARUTIL_H_
#define _CHARUTIL_H_


/* charutil.h */

#define NOT_SUPPORTED	-1
#define HZ_NUM			6763
#define SYM_NUM			717
#define CODE_NUM		(HZ_NUM+SYM_NUM)

extern const unsigned short uniAUnicode[CODE_NUM];
extern const unsigned short uniAGbkcode[CODE_NUM];
extern const unsigned short gbkAGbkcode[CODE_NUM];
extern const unsigned short gbkAUnicode[CODE_NUM];


#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************
* NAME:		gb2uni
* PURPOSR:	Convert gbk string to unicode string
*			the byte order of unicode is dependent on CPU
*			the two-byte code in GBK is always big-endian
* ENTRY:	gbstr	gbk string
*			unibuf	output buffer
*			buflen	length of buffer
* EXIT:		length of unicode string
* AUTHOR: 	lvjie February 2, 2004
****************************************************************************/
int gb2uni( const unsigned char *gbstr, unsigned short *unibuf, int buflen );


/****************************************************************************
* NAME:		uni2gb
* PURPOSR:	Convert unicode string to gbk string
*			the byte order of unicode MUST be consistent with underlying CPU
*			the two-byte code in GBK is always big-endian
* ENTRY:	unistr	unicode string
*			gbbuf	output buffer
*			buflen	length of buffer
* EXIT:		length of gbk string
* AUTHOR: 	lvjie February 2, 2004
****************************************************************************/
int uni2gb( const unsigned short *unistr, unsigned char *gbbuf, int buflen );

int ucs2ToUtf8(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len);

int utf8ToUcs2(const unsigned char *s, unsigned short *wbuf, int wbuf_len);

#ifdef __cplusplus
}
#endif

#endif	//_CHARUTIL_H_
/* end of charutil.h */

