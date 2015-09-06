#include "server.h"
#include "ios.h"
#include <boost/pool/pool.hpp>
#include <boost/pool/object_pool.hpp>
#include <boost/asio/write.hpp>
#include <boost/asio/read.hpp>
#include <iostream>

namespace network
{
	namespace
	{
		//global
		boost::pool<> g_io_buffer_pool(kNormalPacketBytes);
		boost::pool<> g_big_buffer_pool(kMaxPacketBytes);
	}

	class Session
	{
	public:
		typedef std::function<void (Serial serial)> ErrorCallback;

	public:
		Session(Serial serial, CServer::SessionReceiveCallback rc)
			:serial_(serial), receive_handle_(rc),socket_(sios::instance())
		{
			big_read_body_ = nullptr;
			last_received_data_time_ = 0;
			waiting_blocks_ = 0;
			dead_ = false;
		}

		~Session() //to do  释放占用的内存池的空间
		{
			Close();
		}

		void Close()
		{
			receive_handle_ = nullptr;
			boost::system::error_code ec;
			socket_.shutdown(boost::asio::socket_base::shutdown_both, ec);
			socket_.close(ec);
//			IOSWork();
			ReleaseReadBuffer();
		}

		void Start()
		{
			socket_.set_option(boost::asio::socket_base::send_buffer_size(16*1024));
			last_received_data_time_ = std::time(nullptr);
			boost::asio::async_read(socket_, boost::asio::buffer(&read_head_, sizeof(read_head_)),
				std::bind(&Session::HandleReceiveHead, this, std::placeholders::_1, std::placeholders::_2));
		}

		//void Send2(int16_t type, uint16_t bytes, int16_t flag, const char* body)
		//{
		//	assert(bytes>0);
		//	char* buffer = (char*)g_io_buffer_pool.malloc();
		//	Head head = {flag, type, bytes};
		//	memcpy(buffer, &head, sizeof(head));
		//	uint16_t bytes2send = bytes<(kNormalPacketBytes-(uint16_t)sizeof(Head)) ? bytes : kNormalPacketBytes-(uint16_t)sizeof(Head);
		//	memcpy(buffer+sizeof(Head), body, bytes2send);
		//	size_t pos = bytes2send;
		//	boost::asio::async_write(socket_, boost::asio::buffer(buffer, sizeof(Head)+bytes2send),
		//		std::bind(&Session::HandleSend, this, buffer) );
		//	++waiting_blocks_;
		//	bytes -= bytes2send;
		//	while (bytes>0)
		//	{
		//		uint16_t bytes2send = bytes<kNormalPacketBytes?bytes:kNormalPacketBytes;
		//		char* buffer = (char*)g_io_buffer_pool.malloc();
		//		memcpy(buffer, body+pos, bytes2send);
		//		pos += bytes2send;
		//		boost::asio::async_write(socket_, boost::asio::buffer(buffer, bytes2send), std::bind(&Session::HandleSend, this, buffer) );
		//		++waiting_blocks_;
		//		bytes -= bytes2send;
		//	}
		//}

		void Send(Type type, Bytes bytes, Flag flag, const char* body)
		{
			Head h = {flag, type, bytes};
			char* buffer = nullptr;
			size_t total_len = sizeof(Head)+bytes;
			if (total_len <= kNormalPacketBytes)
			{
				buffer = (char*)g_io_buffer_pool.malloc();
			}
			else if (total_len <= kMaxPacketBytes)
			{
				buffer = (char*)g_big_buffer_pool.malloc();
			}
			if (buffer)
			{
				memcpy(buffer, &h, sizeof(h));
				memcpy(buffer+sizeof(h), body, bytes);
				boost::asio::async_write(socket_, boost::asio::buffer(buffer, total_len), std::bind(&Session::HandleSend, this, buffer, total_len));
				++waiting_blocks_;
			}
		}

		void SendBigPacket(const void* data, size_t len)
		{
			throw "Do not use this";
			//char* buf = new(char[len]);
			//memcpy(buf, data, len);
			//boost::asio::async_write(socket_, boost::asio::buffer(buf, len), std::bind(&Session::HandleSend, this, buf, len));
		}

		time_t last_received_data_time()
		{
			return last_received_data_time_;
		}

		int waiting_blocks()
		{
			if (waiting_blocks_>500)
			{
				std::cout <<"too many waiting blocks of " <<serial_ <<std::endl;
			}
			return waiting_blocks_;
		}

		boost::asio::ip::tcp::socket& socket()
		{
			return socket_;
		}

		bool dead()
		{
			return dead_;
		}

	private:

		void HandleSend(void* const chunk, size_t len)
		{
			--waiting_blocks_;
			if (len <= kNormalPacketBytes)
			{
				g_io_buffer_pool.free(chunk);
			}
			else
			{
				g_big_buffer_pool.free(chunk);
			}
		}

		boost::asio::mutable_buffers_1 GetBuffer(uint16_t bytes)
		{
			if (bytes <= BODY_SIZE)
			{
				return boost::asio::buffer(read_body_, read_head_.bytes);
			}
			big_read_body_ = (uint8_t*)g_big_buffer_pool.malloc();
			return std::move(boost::asio::buffer(big_read_body_, bytes));
		}

		void DealWithBuffer(uint16_t bytes)
		{
			uint8_t* body_to_deal_with = read_body_;
			if (bytes > BODY_SIZE)
			{
				body_to_deal_with = big_read_body_;
			}
			try
			{
				if(receive_handle_)
				{
					receive_handle_(serial_, read_head_.type, read_head_.bytes, read_head_.flag, body_to_deal_with);
				}
			}
			catch (std::exception& e)
			{
				std::cout << "receive_handle_ exception:" <<e.what() <<std::endl;
			}
			catch (...)
			{
				std::cout << "unkown exception" <<std::endl;
			}
		}

		void ReleaseReadBuffer()
		{
			if (big_read_body_)
			{
				g_big_buffer_pool.free(big_read_body_);
				big_read_body_ = nullptr;
			}
		}

		void HandleReceiveHead(const boost::system::error_code& ec, size_t bytes_transferred)
		{
			if (!ec && bytes_transferred==sizeof(Head) && read_head_.bytes>=0)
			{
#ifdef _DEBUG
//				std::cout <<read_head_.type <<" " <<read_head_.bytes <<"\n";
#endif
				last_received_data_time_ = std::time(nullptr);
				boost::asio::async_read(socket_, GetBuffer(read_head_.bytes),
					std::bind(&Session::HandleReceiveBody, this, std::placeholders::_1, std::placeholders::_2) );
			}
			else
			{
				dead_ = true;
			}
		}

		void HandleReceiveBody(const boost::system::error_code& ec, size_t bytes_transferred)
		{
			if (!ec && (int16_t)bytes_transferred==read_head_.bytes)
			{
#ifdef _DEBUG
//				std::cout <<bytes_transferred <<" of body \n";
#endif
				DealWithBuffer((int16_t)bytes_transferred);
				boost::asio::async_read(socket_, boost::asio::buffer(&read_head_, sizeof(read_head_)),
					std::bind(&Session::HandleReceiveHead, this, std::placeholders::_1, std::placeholders::_2));
			}
			else
			{
				dead_ = true;
			}
			ReleaseReadBuffer();
		}

	private:
		Serial serial_;
		CServer::SessionReceiveCallback receive_handle_;

		boost::asio::ip::tcp::socket socket_;
		Head read_head_;
		static const uint16_t BODY_SIZE = uint16_t(kNormalPacketBytes-sizeof(Head));
		uint8_t read_body_[BODY_SIZE];
		uint8_t* big_read_body_;

		std::time_t last_received_data_time_;
		int waiting_blocks_;
		bool dead_;
	};


	namespace
	{
		boost::object_pool<Session> gSessionPool;
	}

	CServer::CServer( const char* aIp, unsigned short aPort, SessionReceiveCallback aReceiveHandle ) :mAcceptor(sios::instance(), boost::asio::ip::tcp::endpoint(boost::asio::ip::address::from_string(aIp), aPort) )
	{
		mSessionDeadSeconds = cSessionDeadSeconds;
		mReadHandle = aReceiveHandle;
		mCurrentSerial = INT_MIN;
		PostAccept();
	}

	void CServer::Send( Serial aSerial, int16_t aType, uint16_t aBytes, int16_t aFlag, const void* apBody ) const
	{
		try
		{
			auto i = mSessions.find(aSerial);
			if (i != mSessions.end() )
			{
				i->second->Send(aType, aBytes, aFlag, (const char*)apBody);
			}
		}
		catch (std::exception& e)
		{
			std::cout << "receive_handle_ exception:" <<e.what() <<std::endl;
		}
		catch (...)
		{
			std::cout << "unknown exception" <<std::endl;
		}
	}

	void CServer::Close( Serial aSerial )
	{
		auto i = mSessions.find(aSerial);
		if (i != mSessions.end())
		{
			gSessionPool.destroy(i->second);
			mSessions.erase(i);
		}
	}

	void CServer::HandleAccept( const boost::system::error_code& aEc, Session* apSession )
	{
		if (!aEc)
		{
			mSessions[mCurrentSerial++] = apSession;
			PostAccept();
			apSession->Start();
		}
	}

	void CServer::PostAccept()
	{
		if (mCurrentSerial == kErrorSerial)
		{
			++mCurrentSerial;
		}
		Session* newSession = gSessionPool.construct(mCurrentSerial, mReadHandle);
		mAcceptor.async_accept(newSession->socket(), std::bind(&CServer::HandleAccept, this, std::placeholders::_1, newSession));
	}

	void CServer::GetDeadSessions( Serial deadSessions[], size_t& dead_count )
	{
		static const size_t kMaxSize = 1024;
		//Serial deadSessions[kMaxSize];
		dead_count = 0;
		std::time_t now = std::time(nullptr);
		for(auto& v: mSessions)
		{
			if(v.second->dead() || now-v.second->last_received_data_time()>=mSessionDeadSeconds || v.second->waiting_blocks()>500 )
			{
				deadSessions[dead_count++] = v.first;
				if (dead_count >= kMaxSize)
				{
					break;
				}
			}
		}
	}

	void CServer::SendBigPacket(Serial serial, const void* body, size_t len )
	{
		auto i = mSessions.find(serial);
		if (i != mSessions.end() )
		{
			i->second->SendBigPacket(body, len);
		}
	}

	const char* CServer::GetSessionAddress( Serial serial )
	{
		auto i = mSessions.find(serial);
		try
		{
			if (i != mSessions.end() )
			{
				return i->second->socket().remote_endpoint().address().to_string().c_str();
			}
		}
		catch (std::exception& e)
		{
			
		}
		catch (...)
		{
		}
		return nullptr;
	}

	void CServer::SetSessionDeadSeconds( int seconds )
	{
		if(seconds<0) seconds=cSessionDeadSeconds;
		if(seconds==0) seconds=INT_MAX;
		mSessionDeadSeconds = seconds;
	}

}
