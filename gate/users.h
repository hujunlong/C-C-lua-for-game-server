#pragma once

#include "../system/singleton.h"
#include <boost/noncopyable.hpp>
#include "../protocol/define.h"
#include "../system/define.h"
#include <queue>

class Users : private boost::noncopyable
{
public:
	typedef network::Serial Serial;

	bool Add(UserID uid, Serial serial)
	{
		if (id_serial_map_.size() >= kMaxUsersCount)
		{
			return false;
		}
		id_serial_map_[uid] = serial;
		serial_id_map_[serial] = uid;
		return true;
	}

	void Remove(Serial serial)
	{
		auto iter = serial_id_map_.find(serial);
		if (iter != serial_id_map_.end())
		{
			UserID uid = iter->second;
			serial_id_map_.erase(iter);
			id_serial_map_.erase(uid);
		}
	}

	Serial UserID2Serial(UserID uid)
	{
		auto iter = id_serial_map_.find(uid);
		if (iter != id_serial_map_.end())
		{
			return iter->second;
		}
		return network::kErrorSerial;
	}

	bool Has(Serial serial)
	{
		return serial_id_map_.find(serial) != serial_id_map_.end();
	}

	UserID Serial2UserID(Serial serial)
	{
		return serial_id_map_[serial];
	}

	template<typename Func>
	void ForEachSerial(Func f)
	{
		for (const auto& si: serial_id_map_)
		{
			f(si.first);
		}
	}

private:
	static const size_t kMaxUsersCount = 14096;
private:
	std::map<UserID, Serial> id_serial_map_;
	std::map<Serial, UserID> serial_id_map_;

	std::map<Serial, std::queue<network::Flag>> world_flags_;
	std::map<Serial, std::queue<network::Flag>> interact_flags_;
};

inline Users& GetUsers()
{
	return singleton_default<Users>::instance();
}
