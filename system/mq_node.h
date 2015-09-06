#pragma once

#include <zmq.hpp>
#include <cstdint>
#include <cstdio>
#include <boost/noncopyable.hpp>
#include "mq.h"
#include <type_traits>

enum class NodeType
{
	kServer,
	kClient
};

class MQNode  : private boost::noncopyable
{
public:
	static const size_t cMaxLen = 1024*32;

public:
	MQNode()
		:mContext(1),mSocket(mContext, ZMQ_DEALER)
	{}

	~MQNode()
	{
		mSocket.close();
	}

	void Init(NodeType aType, const char* apAddress)
	{
		if(aType==NodeType::kServer)
		{
			mSocket.bind(apAddress);
		}
		else
		{
			mSocket.connect(apAddress);
		}
	}

	//bool Fetch(void* aData, size_t& aLen, MQType& aType) /*return 0 if no data */
	//{
	//	zmq::message_t msg;
	//	try
	//	{
	//		if (mSocket.recv(&msg, ZMQ_NOBLOCK))
	//		{
	//			if (msg.size()<=cMaxLen)
	//			{
	//				aLen = msg.size()-sizeof(aType);
	//				memcpy(&aType, msg.data(), sizeof(aType));
	//				memcpy(aData, (uint8_t*)msg.data()+sizeof(aType), aLen);
	//				return msg.size()>0;
	//			}
	//			else
	//			{
	//				printf("MsgRecv::FetchMsg:: too large Msg received!\n");
	//			}
	//		}
	//	}
	//	catch (std::exception& e)
	//	{
	//		printf("Receive mq message error: %s \n", e.what());
	//	}
	//	catch (...)
	//	{
	//	}
	//	return 0;
	//}
	template<typename Head>
	bool Fetch(Head& head, void* data, size_t& len)
	{
		zmq::message_t msg;
		try
		{
			if (mSocket.recv(&msg, ZMQ_NOBLOCK))
			{
				if (msg.size()<=cMaxLen && msg.size()>=sizeof(head))
				{
					len = msg.size() - sizeof(head);
					memcpy(&head, msg.data(), sizeof(head));
					memcpy(data, (char*)msg.data()+sizeof(head), len);
					return true;
				}
				else
				{
					//char  sz[512];
					//sprintf(sz, "MsgRecv::FetchMsg:: too large Msg received!\nlen=%d", msg.size());
					printf("MsgRecv::FetchMsg:: too large Msg received!		len=%d\n", msg.size());
				}
			}
		}
		catch (std::exception& e)
		{
			printf("Receive mq message error: %s \n", e.what());
		}
		catch (...)
		{
		}
		return false;
	}



	template<typename Head, typename Msg>
	inline void Send(Head& head, const Msg& msg)
	{
		static_assert(sizeof(head) == sizeof(MqHead), "");

		static_assert(std::is_pod<Head>::value, "Only Pod supported!");
		static_assert(!std::is_pointer<Msg>::value, "Pointer is not supported!");
		head.type = (decltype(head.type))msg.kType;
		Send(head, &msg, sizeof(msg));
	}

	template<typename Head>
	inline void Send( const Head& h, const void* aData, size_t aLen )
	{
		static_assert(sizeof(h) == sizeof(MqHead), "");

		static_assert(std::is_pod<Head>::value, "Only Pod supported!");
		if (aLen+sizeof(h) > cMaxLen)
		{
			printf("MsgRecv::Send:: too large Msg!\nlen=%d", aLen);
		}

		assert(aLen+sizeof(h) <= cMaxLen);
		if (aLen+sizeof(h) <= cMaxLen)
		{
			uint8_t buf[cMaxLen];
			memcpy(buf, &h, sizeof(h));
			memcpy(buf+sizeof(h), aData, aLen);
			RawSend(buf, aLen+sizeof(h));
		}
	}

	template<typename Msg>
	inline void Send(int32_t associate_id, int16_t type, int16_t flag,  const Msg& msg)
	{
		MqHead head = {associate_id,type,flag};
		Send(head, msg);
	}

	template<typename Msg>
	inline void Send(int32_t associate_id, int16_t type, int16_t flag,  const Msg& msg, size_t len)
	{
		MqHead head = {associate_id,type,flag};
		Send(head, &msg, len);
	}

private:
	inline void RawSend( const void* aData, size_t aLen )
	{
		assert(aLen<cMaxLen);
		zmq::message_t msg(aLen);
		uint8_t* pdata = (uint8_t*)msg.data();
		memcpy(pdata, aData, aLen);
		try
		{
			mSocket.send(msg,ZMQ_NOBLOCK);
			//			socket_.send(msg);
		}
		catch (std::exception& e)
		{
			printf("Send mq message error: %s \n", e.what());
		}
		catch (...)
		{
		}
	}

private:
	zmq::context_t mContext;
	zmq::socket_t mSocket;



};
