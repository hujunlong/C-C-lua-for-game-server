

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>

#include <windows.h>

/// <summary>Displays a given error message in Lua.</summary>
/// <param name="L">Lua state to display the error on.</param>
/// <param name="f_sMsg">Error message to display.</param>
void error(lua_State *L, const char * f_sMsg)
{
	lua_pushlstring(L, f_sMsg, strlen(f_sMsg));
	lua_error(L);
}

/// <summary>Converts a single hexadecimal digit character to an integer value.</summary>
/// <param name="L">Lua state to report any errors to.</param>
/// <param name="f_cDigit">Hexadecimal digit to convert.</param>
/// <returns>Returns integer value of given hexadecimal digit.</returns>
unsigned int helper_digit2int(lua_State *L, const char f_cDigit)
{
	unsigned int _iValue = 0;
	if (f_cDigit >= '0' && f_cDigit <= '9')
		_iValue = f_cDigit - '0';
	else if (f_cDigit >= 'a' && f_cDigit <= 'f')
		_iValue = f_cDigit - 'a' + 10;
	else if (f_cDigit >= 'A' && f_cDigit <= 'F')
		_iValue = f_cDigit - 'A' + 10;
	else
		error(L, "Invalid hexadecimal digit.");
	return _iValue;
}

/// <summary>Converts a four-digit hexadecimal string to an integer value.</summary>
/// <param name="L">Lua state to report any errors to.</param>
/// <param name="f_sHex">Four-digit hexadecimal string to convert.</param>
/// <returns>Returns integer value of given four-digit hexadecimal string.</returns>
unsigned int helper_fourhex2int(lua_State *L, const char * f_sHex)
{
	return helper_digit2int(L, f_sHex[0]) * 4096 + helper_digit2int(L, f_sHex[1]) * 256 + helper_digit2int(L, f_sHex[2]) * 16 + helper_digit2int(L, f_sHex[3]);
}

/// <summary>Converts a four-digit hexadecimal string to a (possibly multi-byte) UTF-8 character.</summary>
/// <param name="L">Lua state to report any errors to.</param>
/// <param name="f_sHex">Four-digit hexadecimal string to convert.</param>
/// <param name="f_sBuf">Four-byte buffer for returned UTF-8 character.</param>
/// <param name="len">Pointer to put resulting string size in.</param>
/// <returns>Returns NOT null-terminated UTF-8 character (one to three bytes).</returns>
char * helper_fourhex2utf8(lua_State *L, const char * f_sHex, char * f_sBuf, size_t *len)
{
	unsigned int _iUtf = helper_fourhex2int(L, f_sHex);
	if (_iUtf < 128)
	{
		f_sBuf[0] = _iUtf & 0x7F;
		f_sBuf[1] = 0;
		if (len) *len = sizeof(char);
	}
	else if (_iUtf < 2048)
	{
		f_sBuf[0] = ((_iUtf >> 6) & 0x1F) | 0xC0;
		f_sBuf[1] = (_iUtf & 0x3F) | 0x80;
		f_sBuf[2] = 0;
		if (len) *len = sizeof(char) * 2;
	}
	else
	{
		f_sBuf[0] = ((_iUtf >> 12) & 0x0F) | 0xE0;
		f_sBuf[1] = ((_iUtf >> 6) & 0x3F) | 0x80;
		f_sBuf[2] = (_iUtf & 0x3F) | 0x80;
		f_sBuf[3] = 0;
		if (len) *len = sizeof(char) * 3;
	}
	return f_sBuf;
}

/// <summary>Advances the parser to the next non-whitespace character.</summary>
/// <param name="L">Lua state to report any errors to.</param>
/// <param name="f_ppCaret">Pointer to the location of the parser caret.</param>
void helper_passwhitespace(lua_State *L, char ** f_ppCaret)
{
	while (**f_ppCaret == ' ' || **f_ppCaret == '\r' || **f_ppCaret == '\n' || **f_ppCaret == '\t')
		(*f_ppCaret)++;
}

void decode_value(lua_State *L, char * str, char ** c);
void decode_string(lua_State *L, char * str, char ** c);

/// <summary>Parses an array into a Lua table.</summary>
/// <param name="L">Lua state to report any errors to.</param>
/// <param name="f_s"></param>
/// <param name="f_ppCaret">Pointer to the location of the parser caret.</param>
void decode_array(lua_State *L, char * str, char ** f_ppCaret)
{
	if (**f_ppCaret != '[')
		error(L, "readArray() did not find '['.");
	(*f_ppCaret)++;
	lua_newtable(L);
	helper_passwhitespace(L, f_ppCaret);
	if (**f_ppCaret == ']')
	{
		(*f_ppCaret)++;
		return;
    }
	int i = 1;
	while (1)
	{
		helper_passwhitespace(L, f_ppCaret);
		lua_pushinteger(L, i);
		decode_value(L, str, f_ppCaret);
		lua_settable(L, -3);
		helper_passwhitespace(L, f_ppCaret);
		if (**f_ppCaret != ',')
			break;
        (*f_ppCaret)++;
        i++;
	}
	helper_passwhitespace(L, f_ppCaret);
	if (**f_ppCaret == ']')
		(*f_ppCaret)++;
	else
		error(L, "readArray() did not find ']'.");
}

void decode_false(lua_State *L, char * str, char ** c)
{
	if (!strncmp(*c, "false", 5))
	{
		lua_pushboolean(L, 0);
		*c += 5;
	}
	else
		error(L, "JSON readFalse b0rked :c.");
}

void decode_null(lua_State *L, char * str, char ** c)
{
	if (!strncmp(*c, "null", 4))
	{
		lua_getglobal(L, "json");
		lua_getfield(L, -1, "null");
		lua_remove(L, -2);
		*c += 4;
	}
	else
		error(L, "JSON readNull b0rked :c.");
}

void decode_number(lua_State *L, char * str, char ** c)
{
	float neg;
	if (**c == '-')
	{
		neg = -1;
		(*c)++;
	}
	else
		neg = 1;
	double num = 0;
	char * save;
	save = *c;
	char * foundDec = NULL, * foundExp = NULL, * foundEnd = NULL;
	while (foundEnd == NULL)
	{
		switch (**c)
		{
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			break;
		case '.':
			if (foundDec != NULL || foundExp != NULL)
				error(L, "bad number format");
			foundDec = *c;
			break;
		case 'e':
		case 'E':
			if (foundExp != NULL)
				error(L, "bad number format");
			foundExp = *c;
			break;
		case '-':
		case '+':
			//if (*((*c)-1) != 'e' || *((*c)-1) != 'E')
				//error(L, "bad number format");
			break;
		default:
			foundEnd = *c;
			break;
		}
		(*c)++;
	}
	*c = save;
	int exp;
	double exponent = 0;
	int exponentneg = 1;
	if (foundDec != NULL)
	{
		exp = foundDec - *c - 1;
		for (; **c != '.'; exp--)
		{
			num += (**c - '0') * pow(10, exp);
			(*c)++;
		}
		(*c)++;
		if (foundExp != NULL)
		{
			for (; **c != 'e' && **c != 'E'; exp--)
			{
				num += (**c - '0') * pow(10, exp);
				(*c)++;
			}
			(*c)++;
			if (**c == '-')
			{
				exponentneg = -1;
				(*c)++;
			}
			else if (**c == '+')
			{
				(*c)++;
			}
			exp = foundEnd - *c - 1;
			for (; *c != foundEnd; exp--)
			{
				exponent += (**c - '0') * pow(10, exp);
				(*c)++;
			}
		}
		else
		{
			for (; *c != foundEnd; exp--)
			{
				num += (**c - '0') * pow(10, exp);
				(*c)++;
			}
		}
	}
	else if (foundExp != NULL)
	{
		exp = foundExp - *c - 1;
		for (; **c != 'e' && **c != 'E'; exp--)
		{
			num += (**c - '0') * pow(10, exp);
			(*c)++;
		}
		(*c)++;
		if (**c == '-')
		{
			exponentneg = -1;
			(*c)++;
		}
		else if (**c == '+')
		{
			(*c)++;
		}
		exp = foundEnd - *c - 1;
		for (; *c != foundEnd; exp--)
		{
			exponent += (**c - '0') * pow(10, exp);
			(*c)++;
		}
	}
	else
	{
		exp = foundEnd - *c - 1;
		for (; exp >= 0; exp--)
		{
			num += (**c - '0') * pow(10, exp);
			(*c)++;
		}
	}
	num = neg * num * pow(10, exponentneg * exponent);
	lua_pushnumber(L, num);
}

void decode_object(lua_State *L, char * str, char ** c)
{
	if (**c != '{')
		error(L, "JSON readObject(1) b0rked :c.");
	(*c)++;
	lua_checkstack(L, 1);
	lua_newtable(L);
	helper_passwhitespace(L, c);
    if (**c == '}')
    {
        (*c)++;
        return;
    }
	while (1)
	{
		decode_string(L, str, c);
		helper_passwhitespace(L, c);
		if (**c != ':')
		{
			error(L, "JSON readObject(2) b0rked :c.");
		}
		(*c)++;
		helper_passwhitespace(L, c);
		decode_value(L, str, c);
		lua_settable(L, -3);
		helper_passwhitespace(L, c);
		if (**c == ',')
		{
			(*c)++;
			helper_passwhitespace(L, c);
		}
		else
			break;
	}
	helper_passwhitespace(L, c);
	if (**c == '}')
		(*c)++;
	else
		error(L, strcat(*c, "JSON readObject(3) b0rked :c."));
}

void decode_string(lua_State *L, char * str, char ** c)
{
	if (**c != '"')
		error(L, "no string :c");
	(*c)++;
	int minus = 0;
	char * beginning = *c;
	char * end = NULL;
	unsigned int utf;
	while (end == NULL)
	{
		switch (**c)
		{
		case '"':
			if (*((*c) - 1) != '\\')
				end = *c;
			break;
		case '\\':
			switch (*((*c) + 1))
			{
			case '"':
			case '\\':
			case '/':
			case 'b':
			case 'f':
			case 'n':
			case 'r':
			case 't':
				minus++;
				(*c)++;
				break;
			case 'u':
				utf = helper_fourhex2int(L, (*c) + 2);
				if (utf < 128)
					minus += 5;
				else if (utf < 2048)
					minus += 4;
				else
					minus += 3;
				(*c) += 5;
				break;
			default:
				error(L, "invalid escape character");
				break;
			}
		default:
			break;
		}
		(*c)++;
	}
	*c = beginning;
	char * newstr = NULL;
	size_t len = sizeof(char) * (end - beginning - minus);
	newstr = (char*)malloc(len+1);
	memset(newstr, 0, len+1);
	char * newc = newstr;
	char * nextEscape = NULL;
	char utfbuf[4] = "";
	while (*c != end)
	{
		nextEscape = strchr(*c, '\\');
		if (nextEscape > end)
			nextEscape = NULL;
		if (nextEscape == *c)
		{
		    size_t len;
			switch (*((*c) + 1))
			{
			case '"':
				*newc = '"';
				newc++;
				(*c) += 2;
				break;
			case '\\':
				*newc = '\\';
				newc++;
				(*c) += 2;
				break;
			case '/':
				*newc = '/';
				newc++;
				(*c) += 2;
				break;
			case 'b':
				*newc = '\b';
				newc++;
				(*c) += 2;
				break;
			case 'f':
				*newc = '\f';
				newc++;
				(*c) += 2;
				break;
			case 'n':
				*newc = '\n';
				newc++;
				(*c) += 2;
				break;
			case 'r':
				*newc = '\r';
				newc++;
				(*c) += 2;
				break;
			case 't':
				*newc = '\t';
				newc++;
				(*c) += 2;
				break;
			case 'u':
				helper_fourhex2utf8(L, (*c) + 2, utfbuf, &len);
                memcpy(newc, utfbuf, len);
				newc += len;
				(*c) += 6;
				break;
			default:
				error(L, "invalid escape character");
				break;
			}
		}
		else if (nextEscape != NULL)
		{
			size_t len = nextEscape - *c;
			strncpy(newc, *c, len);
			newc += len;
			(*c) += len;
		}
		else
		{
			size_t len = end - *c;
			strncpy(newc, *c, len);
			newc += len;
			(*c) += len;
		}
	}
	*newc = 0;
	lua_pushlstring(L, newstr, newc - newstr);
	(*c)++;
	free(newstr);
}

void decode_true(lua_State *L, char * str, char ** c)
{
	if (!strncmp(*c, "true", 4))
	{
		lua_pushboolean(L, 1);
		*c += 4;
	}
	else
		error(L, "JSON readTrue b0rked :c.");
}

void decode_value(lua_State *L, char * str, char ** c)
{
	switch (**c)
	{
	case 'f':
		decode_false(L, str, c);
		break;
	case 'n':
		decode_null(L, str, c);
		break;
	case 't':
		decode_true(L, str, c);
		break;
	case '[':
		decode_array(L, str, c);
		break;
	case '{':
		decode_object(L, str, c);
		break;
	case '-':
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		decode_number(L, str, c);
		break;
	case '"':
		decode_string(L, str, c);
		break;
	default:
		error(L, strcat(*c, "JSON readValue b0rked :c."));
		lua_error(L);
		break;
	}
}

int decode(lua_State *L)
{
	char * str = NULL;
	size_t str_size = 0;
	if (lua_isuserdata(L, 1))
		str = (char *)lua_touserdata(L, 1);
	else
	{
		const char * sTmp = luaL_checklstring(L, 1, &str_size);
		str = (char *)malloc(str_size + 1);
		memcpy(str, sTmp, str_size);
		str[str_size] = 0;
	}

	char * c = str;
	helper_passwhitespace(L, &c);
	decode_value(L, str, &c);
	helper_passwhitespace(L, &c);
	if (*c != 0)
		error(L, "Something past the root value?");
	free(str);
	return 1;
}

///////////////////////////////////////////////////////////////////
/////////////////////// ~~~ ENCODE ~~~ ////////////////////////////
///////////////////////////////////////////////////////////////////

char int2digit(const int val)
{
	if (val >= 10)
		return 'a' + val - 10;
	else
		return '0' + val;
}

void int2fourhex(int num, char * buf)
{
	buf[0] = int2digit(num / 4096);
	num %= 4096;
	buf[1] = int2digit(num / 256);
	num %= 256;
	buf[2] = int2digit(num / 16);
	num %= 16;
	buf[3] = int2digit(num);
	buf[4] = 0;
}

char * quote(const char * S, int len)
{
	const char * c = S;
	int count = 2 + len;	// final string size, excluding zero terminator
	while (c < S + len)
	{
		switch (*c)
		{
		case '\\':
		case '"':
		case '\b':
		case '\f':
		case '\n':
		case '\r':
		case '\t':
			count++;
			break;
		default:
			if (*c < 32)
				count += 5;
			break;
		}
		c++;
	}
	// count complete, allocate and recreate string.
	char * newS = (char*)malloc(sizeof(char) * (count + 1)); // add null terminator
	char * newc = newS;
	newc[0] = '"';
	newc[1] = 'a';
	newc[2] = 'b';
	newc[3] = 'c';
	newc++;
	c = S;
	while (c < S + len)
	{
		switch (*c)
		{
		case '\\':
			newc[0] = '\\';
			newc[1] = '\\';
			newc += 2;
			break;
		case '"':
			newc[0] = '\\';
			newc[1] = '"';
			newc += 2;
			break;
		case '\b':
			newc[0] = '\\';
			newc[1] = 'b';
			newc += 2;
			break;
		case '\f':
			newc[0] = '\\';
			newc[1] = 'f';
			newc += 2;
			break;
		case '\n':
			newc[0] = '\\';
			newc[1] = 'n';
			newc += 2;
			break;
		case '\r':
			newc[0] = '\\';
			newc[1] = 'r';
			newc += 2;
			break;
		case '\t':
			newc[0] = '\\';
			newc[1] = 't';
			newc += 2;
			break;
		default:
			if (*c < 32)
			{
				newc[0] = '\\';
				newc[1] = 'u';
				newc += 2;
				int2fourhex(*c, newc);
				newc += 4;
			}
			else
			{
				newc[0] = *c;
				newc++;
			}
			break;
		}
		c++;
	}
	newc[0] = '"';
	newc[1] = 0;
	return newS;
}

typedef struct {void * value; struct s_linkedList * next;} linkedList;

void freeList(linkedList *L)
{
	if (L == NULL)
		return;
	linkedList * ptr = (linkedList *)L->next;
	free(L);
	freeList(ptr);
}

void addToList(void * Value, linkedList * L)
{
	if (L == NULL)
	{
		L = (linkedList*)malloc(sizeof(linkedList));
		L->value = Value;
		L->next = NULL;
	}
	else
	{
		if (L->next != NULL)
		{
			addToList(Value, (linkedList *)L->next);
		}
		else
		{
			linkedList * newL = (linkedList *)malloc(sizeof(linkedList));
			L->next = (struct s_linkedList *)newL;
			newL->value = Value;
			newL->next = NULL;
		}
	}
}

linkedList * findInList(linkedList * L, void * Match)
{
	linkedList * ptr;
	linkedList * match = NULL;
	for (ptr = L; ptr != NULL; ptr = (linkedList *)ptr->next)
	{
		if (ptr->value == Match)
		{
			match = ptr;
			break;
		}
	}
	return match;
}

void removeLastFromList(linkedList * L, linkedList * Last)
{
	if (L == NULL)
	{
		return;
	}
	if (L->next == NULL)
	{
		free(L);
		if (Last != NULL)
		{
			Last->next = NULL;
		}
	}
	else
		removeLastFromList((linkedList *)L->next, L);
}

linkedList * baseList;

/// -0 +0
void encode_boolean(lua_State *L, const int value, luaL_Buffer *StringBuf)
{
	luaL_addstring(StringBuf, value ? "true" : "false");
}

/// -0 +0
void encode_null(lua_State *L, luaL_Buffer *StringBuf)
{
	luaL_addstring(StringBuf, "null");
}

/// -0 +0
void encode_number(lua_State *L, const double value, luaL_Buffer *StringBuf)
{
	char s[32];
	if (value <= DBL_MAX && value >= -DBL_MAX)  // Check to see if the number is real and finite.
	{
        sprintf(s, "%.14g", value);
        luaL_addstring(StringBuf, s);
    }
    else    // If it's not, use null.
        encode_null(L, StringBuf);
}

/// -0 +0
void encode_string(lua_State *L, const char * S, const int len, luaL_Buffer *StringBuf)
{
	char * quote_s = quote(S, len);
	luaL_addstring(StringBuf, quote_s);
	free(quote_s);
}

void encode_value(lua_State *L, luaL_Buffer *StringBuf);

/// Takes a table at the top of the stack, and appends it, stringified, to StringBuf.
void encode_table(lua_State *L, luaL_Buffer *StringBuf)
{
	void * tablePtr = (void *)lua_topointer(L, -1); // -0 +0
	linkedList * foundMatch = findInList(baseList, tablePtr);
	if (!foundMatch)
	{
		addToList(tablePtr, baseList);
		lua_checkstack(L, 6);
		lua_pushnumber(L, 1); // -0 +1
		lua_gettable(L, -2);  // -1 +1
		if (lua_isnil(L, -1))   // No t[1], treat as object.
		{
			lua_pop(L, 1);  // -1 +0
			luaL_addchar(StringBuf, '{');
			lua_getglobal(L, "pairs"); // -0 +1
			lua_pushvalue(L, -2);   // -0 +1
			lua_call(L, 1, 3);  // -2 +3 pairs(t), three return-values put on stack
			BOOL first = TRUE;
			while (1)
			{
				lua_pushvalue(L, -3);   // -0 +1
				lua_pushvalue(L, -3);   // -0 +1
				lua_pushvalue(L, -3);   // -0 +1
				lua_remove(L, -4);   // -1 +0
				lua_call(L, 2, 2);  // -3 +2 calling the iterator function, getting key,value
				if (lua_isnil(L, -2))
				{
					lua_pop(L, 4); // -4+0
					break;
				}
				else if (!lua_isstring(L, -2))
				{
					lua_pop(L, 1); // -1+0
					continue;
				}
				if (!first)
					luaL_addchar(StringBuf, ',');
				else
					first = FALSE;
				lua_pushvalue(L, -2);   // -0 +1
				encode_value(L, StringBuf); // -1 +0
				luaL_addchar(StringBuf, ':');   // -0 +0
				encode_value(L, StringBuf); // -1 +0
			}
			luaL_addchar(StringBuf, '}');
		}
		else	// t[1] exists, treat as array.
		{
			lua_pop(L, 1);  // -1 +0
			luaL_addchar(StringBuf, '[');
			lua_getglobal(L, "ipairs"); // -0+1
			lua_pushvalue(L, -2);   // -0+1
			lua_call(L, 1, 3);  // -2+3 ipairs(t), three return-values put on stack
			BOOL first = TRUE;
			while (1)
			{
				lua_pushvalue(L, -3);   // -0+1
				lua_pushvalue(L, -3);   // -0+1
				lua_pushvalue(L, -3);   // -0+1
				lua_remove(L, -4);   // -1+0
				lua_call(L, 2, 2);  // -3+2 calling the iterator function, getting key,value
				if (lua_isnil(L, -2))
				{
					lua_pop(L, 4); // -4+0
					break;
				}
				if (!first)
					luaL_addchar(StringBuf, ',');
				else
					first = FALSE;
				encode_value(L, StringBuf); // -1 +0
			}
			luaL_addchar(StringBuf, ']');
		}
		removeLastFromList(baseList, NULL);
	}
	else
	{
		printf("RECURSION\n");
		luaL_addstring(StringBuf, "RECURSION");
	}
}

/// Takes the value at the top of L's stack, and appends it to StringBuf.
/// -1 +0
void encode_value(lua_State *L, luaL_Buffer *StringBuf)
{
    int B;
    double N;
    size_t len;//int len;
    const char * s;
	switch (lua_type(L, -1))
	{
	case LUA_TBOOLEAN:
		B = lua_toboolean(L, -1);
		encode_boolean(L, B, StringBuf);
		break;
	case LUA_TNUMBER:
		N = lua_tonumber(L, -1);
		encode_number(L, N, StringBuf);
		break;
	case LUA_TSTRING:
		s = lua_tolstring(L, -1, &len);
		encode_string(L, s, len, StringBuf);
		break;
	case LUA_TTABLE:
		lua_checkstack(L, 2);   // Make sure we have stack space to do a comparison.
		lua_getglobal(L, "json");
		lua_getfield(L, -1, "null");
		if (lua_equal(L, -3, -1))   // if x == json.null
		{
			lua_pop(L, 2);
			encode_null(L, StringBuf);
		}
		else
		{
			lua_pop(L, 2);
			encode_table(L, StringBuf);
		}
		break;
    case LUA_TFUNCTION:
        luaL_addstring(StringBuf, "FUNCTION");
        break;
    case LUA_TUSERDATA:
		luaL_addstring(StringBuf, "USERDATA");
		break;
    case LUA_TLIGHTUSERDATA:
		luaL_addstring(StringBuf, "LIGHTUSERDATA");
		break;
    case LUA_TTHREAD:
		luaL_addstring(StringBuf, "THREAD");
		break;
    case LUA_TNIL:
		luaL_addstring(StringBuf, "");
        break;
	}
	lua_pop(L, 1);
}

int encode(lua_State * L)
{
	//lua_State * Strings = lua_open(); // Lua state which will hold the string buffer stack.
	luaL_Buffer LBuf;

	//int top = lua_gettop(L);
	luaL_buffinit(L, &LBuf); // This one.

	//lua_settop(L, top);
	encode_value(L, &LBuf); // -1 +0
	luaL_pushresult(&LBuf);  // -0 +1
	//free(LBuf);
	//lua_xmove(Strings, L, 1);   // Move the finished string to the main state.
	//lua_close(Strings);
	return 1;
}

static int null(lua_State *L)
{
	lua_pushstring(L, "null");
	return 1;
}

int luaopen_LuaJSON_lib(lua_State* L)
{
	static const struct luaL_Reg methods[] =
	{
		{"decode", decode},
		{"encode", encode},
		{NULL, NULL}
	};
	luaL_register(L, "json", methods);

    // Define json.null
	static const struct luaL_Reg null_methods[] =
	{
		{"__tostring", null},
		{"__call", null},
		{NULL, NULL}
	};
	lua_newtable(L);
	lua_newtable(L);
	luaL_register(L, NULL, null_methods);
	lua_setmetatable(L, -2);
	lua_setfield(L, -2, "null");

	return 1;
}
