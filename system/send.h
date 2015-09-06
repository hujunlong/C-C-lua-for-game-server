#pragma once
#include "../system/server.h"


void InitSend(network::CServer* apServer);

network::CServer& GetServer();

namespace
{

	template<typename T>
	void Send(const network::Serial serial, int16_t flag, const T& data)
	{
		static network::CServer& s = GetServer();
		s.Send(serial, static_cast<int16_t>(data.kType), flag, data);
	}

	template<typename T>
	void Send(const network::Serial serial, int16_t flag, const T& data, size_t bytes)
	{
		static_assert(std::is_pod<T>::value, "Only pod type supported!");
		static network::CServer& s = GetServer();
		s.Send(serial, static_cast<int16_t>(data.kType), bytes, flag, &data);
	}

	void Send(const network::Serial serial, int16_t type, int16_t flag, const void* data, size_t bytes)
	{
		static network::CServer& s = GetServer();
		s.Send(serial, type, bytes, flag, data);
	}

	void SendBig(const network::Serial serial, const void* data, size_t bytes)
	{
		static network::CServer& s = GetServer();
		s.SendBigPacket(serial, data, bytes);
	}
}
