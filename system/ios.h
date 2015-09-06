#pragma once
#include <boost/asio/io_service.hpp>
#include <boost/system/error_code.hpp>
#include "singleton.h"

#include "export.h"

typedef singleton_default<boost::asio::io_service> sios;

namespace
{
	void IOSWork() //非阻塞，处理已经完成的io，处理完之后，函数结束;对象构造之后，就要开始调用这个函数
	{
		boost::system::error_code ec;
		sios::instance().poll(ec);
	}
}

