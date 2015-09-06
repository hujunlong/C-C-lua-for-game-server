
#include "communicate.h"
#include "../protocol/misc.h"
#include "../system/define.h"

using namespace network;

bool PingClient::connect(const wxString& server, int32_t port)
{
	if(m_socket_client)
	{
		delete m_socket_client;
	}
	m_socket_client = new wxSocketClient(wxSOCKET_NOWAIT);
	m_socket_client->SetEventHandler(*m_form, wxID_Socket_Client_1);
	m_socket_client->SetNotify(wxSOCKET_CONNECTION_FLAG | wxSOCKET_INPUT_FLAG | wxSOCKET_LOST_FLAG);
	m_socket_client->Notify(true);	

	wxIPV4address ip;
	ip.Hostname(server);
	ip.Service(port);
	m_socket_client->Connect(ip, false); 

	return true;
}

void PingClient::send_data(int server)
{
	Ping ping_data;
	ping_data.server = server;
	Head head;
	head.type = Ping::kType;
	head.bytes = sizeof(Ping);

	int len = sizeof(Head) + sizeof(Ping);
	string buff(len,0);

	memcpy((void*)buff.c_str(), &head, sizeof(head));
	memcpy((char*)buff.c_str() + sizeof(head), &ping_data, sizeof(Ping));

	m_socket_client->Write(buff.c_str(), len);

	
}

void PingClient::ping_to_gate()
{
	send_data(kServerIDGate);

}
