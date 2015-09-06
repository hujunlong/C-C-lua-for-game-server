#pragma once
#include "../protocol/common.h"
#include "../protocol/db.h"
#include <cassert>

// static size_t LengthOfUsersList(const UsersList& list)
// {
// 	return sizeof(list)-sizeof(Role)*(list.kMaxPersonsCount-list.len);
// }

//size_t LengthOfAssociatedUsers(const db::AssociatedUsers& associates)
//{
//	return sizeof(associates.uid) + LengthOfUsersList(associates.list);
//}
//}

class DataPackageBuilder
{
public:
	DataPackageBuilder() : pos_(0)
	{
	}

	template<typename T> void Add(const T& block)
	{
		memcpy(buffer_+pos_, &block, sizeof(block));
		pos_ += sizeof(block);
	}

	void Add(const void* p, size_t bytes)
	{
		memcpy(buffer_+pos_, p, bytes);
		pos_ += bytes;
	}

	void Add(const char* sz)
	{
		size_t bytes = strlen(sz);
		memcpy(buffer_+pos_, sz, bytes);
		pos_ += bytes;
	}

	size_t length()
	{
		return pos_;
	}

	const void* data()
	{
		return buffer_;
	}

private:
	uint8_t buffer_[8*1024-sizeof(size_t)];
	size_t pos_;
};

template<size_t N>
struct TFixedString
{
	char sz[N];
};

class DataPackageReader
{
public:
	DataPackageReader(const void*  data) : buffer_(decltype(buffer_)(data))
	{}

	template<typename IntType>
	IntType ReadInt()
	{
		IntType ret = *(IntType*)buffer_;
		buffer_ += sizeof(ret);
		return ret;
	}

	StringLength ReadStringLength()
	{
		StringLength len = *(StringLength*)buffer_;
		buffer_ += sizeof(len);
		return len;
	}

	typedef TFixedString<64> FixedString;

	FixedString ReadString(size_t len)
	{
		assert(len <= sizeof(FixedString));
		FixedString str;
		memcpy(str.sz, buffer_, len);
		return str;
	}



private:
	 const uint8_t*  buffer_;
};
