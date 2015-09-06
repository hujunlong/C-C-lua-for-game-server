#pragma once
#include <boost/asio.hpp>
#include <functional>
#include "define.h"



typedef network::Head Head;

typedef std::function<void(Head h, uint8_t* data)> ReadHandle;

class SimpleClient
{
public:
	SimpleClient(boost::asio::io_service& ios)
		:socket_(ios)
	{}
	void Connect(const char* ip, short port)
	{
		boost::asio::ip::tcp::endpoint ep(boost::asio::ip::address_v4::from_string(ip), port);
		socket_.connect(ep);
	}
	void StartRead(ReadHandle handle)
	{
		read_handle_ = handle;
		boost::asio::async_read(socket_, boost::asio::buffer(&h_, sizeof(h_)), std::bind(&SimpleClient::ReadHeadHandle, this, std::placeholders::_1, std::placeholders::_2));
	}
	void Send(Head h, void* data, size_t len)
	{
		boost::asio::write(socket_, boost::asio::buffer(&h, sizeof(h)));
		boost::asio::write(socket_, boost::asio::buffer(data, len));
	}
	void SendHB()
	{
		Head h = {0,0,0};
		boost::asio::write(socket_, boost::asio::buffer(&h, sizeof(h)));
	}
private:
	void ReadHeadHandle(const boost::system::error_code& ec, size_t bytes)
	{
		if (!ec)
		{
			boost::asio::async_read(socket_, boost::asio::buffer(data_, h_.bytes), std::bind(&SimpleClient::ReadBodyHandle, this, std::placeholders::_1, std::placeholders::_2));
		}
	}
	void ReadBodyHandle(const boost::system::error_code& ec, size_t bytes)
	{
		if (!ec)
		{
			read_handle_(h_, data_);
			boost::asio::async_read(socket_, boost::asio::buffer(&h_, sizeof(h_)), std::bind(&SimpleClient::ReadHeadHandle, this, std::placeholders::_1, std::placeholders::_2));
		}
	}
	boost::asio::ip::tcp::socket socket_;
	Head h_;
	uint8_t data_[32*1024];
	ReadHandle read_handle_;
};

