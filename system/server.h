#pragma once

#include <boost/asio/io_service.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/asio/deadline_timer.hpp>
#include <boost/noncopyable.hpp>
#include <functional>
#include <unordered_map>
#include <boost/pool/pool_alloc.hpp>
#include <cstdint>
#include "define.h"

namespace network
{

	class Session;

	class CServer : private boost::noncopyable
	{
	public:
		typedef std::function<void (Serial serial, int16_t type, int16_t bytes, int16_t flag, const uint8_t* data ) > SessionReceiveCallback;
		typedef std::function<void (Serial serial)> SessionErrorCallback;

	public:
		CServer(const char* aIp, unsigned short aPort, SessionReceiveCallback aReceiveHandle);

		void Close(Serial aSerial); //close a session

		template<typename T> void Send(Serial aSerial, int16_t aType, int16_t aFlag, const T& aBody) const
		{
			static_assert(std::is_pod<T>::value, "Only pod type supported!");
			Send(aSerial, aType, (uint16_t)sizeof(aBody), aFlag, &aBody);
		}

		void Send(Serial aSerial, int16_t aType, uint16_t aBytes, int16_t aFlag, const void* apBody) const ; 

		void SendBigPacket(Serial aSerial, const void* body, size_t len);

		void GetDeadSessions(Serial serials[], size_t& count);

		const char* GetSessionAddress(Serial serial); //¥ÌŒÛ∑µªÿø’÷∏’Î

		void SetSessionDeadSeconds(int seconds);
	private:

		void HandleAccept(const boost::system::error_code& aEc, Session* apSession);

		void PostAccept();

	private:
		static const int cSessionDeadSeconds = 100;

	private:
		boost::asio::ip::tcp::acceptor	mAcceptor;

		typedef std::unordered_map<Serial, Session*, std::hash<Serial>, std::equal_to<Serial>, boost::fast_pool_allocator<std::pair<Serial, Session*>>> session_map;
		session_map mSessions;

		SessionReceiveCallback mReadHandle;

//		SessionErrorCallback mErrorHandle;

		Serial mCurrentSerial;

		int mSessionDeadSeconds;
	};





















} //namespace network
