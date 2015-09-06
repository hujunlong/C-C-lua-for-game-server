#ifndef _COMMUNICATE_H_
#define _COMMUNICATE_H_

#include "wx/socket.h"
#include <iostream>
#include "../protocol/misc.h"
#include "MainForm.h"


#include <string>

using namespace std;


class PingClient
{
private:
	wxSocketClient* m_socket_client;
	MainForm* m_form;
protected:
	void send_data(int server);

public:
	PingClient(MainForm* form)
	{
		m_form = form;
		m_socket_client = NULL;
		
	}
	virtual ~PingClient()
	{
		if (m_socket_client)
		{
			delete m_socket_client;
		}
		
	}
	bool connect(const wxString& server, int32_t port);
	
	void ping_to_gate();				//发送ping数据到gate服务器

};




#endif	//_COMMUNICATE_H_