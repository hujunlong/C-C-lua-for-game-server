#ifndef _CHARWRAP_H_
#define _CHARWRAP_H_


/* charwrap.h */

//#define USE_WIN_FUN

#ifdef __cplusplus
extern "C" {
#endif

int gbk_to_ucs16(const unsigned char *gbks, unsigned short *wbuf, int wbuf_len);
int ucs16_to_gbk(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len);

int ucs16_to_utf8(const unsigned short *ucs, unsigned char *cbuf, int cbuf_len);
int utf8_to_ucs16(const unsigned char *gbks, unsigned short *wbuf, int wbuf_len);

#ifdef __cplusplus
}
#endif


#endif	//_CHARWRAP_H_

/* end of charutil.h */

