#include "communicate.h"

#include "MainForm.h"
#include "main.h"
#include "../protocol/misc.h"
#include "../system/define.h"

using namespace network;

MainForm::MainForm(const wxString& Caption, int width, int height): wxFrame(NULL, wxID_ANY, Caption)
{
	this->SetSize(width, height);
	//this->SetBackgroundColour(wxColour(0xC0C0C0));


	moveto_screen_center();

	new wxStaticText(this, wxID_ANY, wxT("Server:"),wxPoint(20,23));
	txtIPAddress = new wxTextCtrl(this, wxID_IPAddress_Ctrl, wxT("192.168.0.174"), wxPoint(90,20));	

	wxStaticText* stPort = new wxStaticText(this, wxID_ANY, wxT("Port:"),wxPoint(20 + txtIPAddress->GetPosition().x + txtIPAddress->GetSize().GetWidth(),23));
	txtPort = new wxTextCtrl(this, wxID_Port_Ctrl, wxT("15000"), wxPoint( 20 + stPort->GetPosition().x + stPort->GetSize().GetWidth(),20));	

	btnPing = new wxButton(this, wxID_Ping_Ctrl, wxT("Ping"), wxPoint(20 + txtPort->GetPosition().x + txtPort->GetSize().GetWidth(), 20));
	btnPing->SetToolTip(wxT("Ping response"));

	btnStop = new wxButton(this, wxID_Stop_Ctrl, wxT("Stop"),  wxPoint(20 + btnPing->GetPosition().x + btnPing->GetSize().GetWidth(), 20));
	btnStop->Show(false);
	btnStop->SetToolTip(wxT("stop ping"));

	#define BASE_TOP 60

	rbGate = new wxRadioButton(this,wxID_rbGate_Ctrl, wxT("Test gate response speed"),wxPoint(20,BASE_TOP));
	rbGate->SetValue(true);
	rbData = new wxRadioButton(this,wxID_rbData_Ctrl, wxT("Test data response speed"),wxPoint(20,BASE_TOP + 20));
	rbInteract = new wxRadioButton(this,wxID_rbInteract_Ctrl, wxT("Test interact response speed"),wxPoint(20,BASE_TOP + 40));
	rbWorld = new wxRadioButton(this,wxID_rbWorld_Ctrl, wxT("Test world response speed"),wxPoint(20,BASE_TOP + 60));
	
	txtMessage = new wxTextCtrl(this, wxID_Message_Ctrl, wxEmptyString, wxPoint(20,BASE_TOP + 80), 
		wxSize(500, 250), wxTE_MULTILINE);	

	btnClearMessage = new wxButton(this, wxID_Clear_Message_Ctrl, wxT("Clear Message"), wxPoint(20, 5 + txtMessage->GetSize().GetHeight() + txtMessage->GetPosition().y));

	btnClearMessage->SetToolTip(wxT("Clear all message"));

	//-------------------
	tmPing = NULL;

	ping_client = NULL;

}

MainForm::~MainForm()
{	
	if(tmPing)
		delete tmPing;
	if(ping_client)
		delete ping_client;

}

void MainForm::moveto_screen_center()
{
	wxScreenDC dc;
	wxSize screen_size = dc.GetSize();
	wxPoint pt;
	pt.x =  (screen_size.GetWidth() - this->GetSize().GetWidth()) / 2;
	pt.y = (screen_size.GetHeight() - this->GetSize().GetHeight()) / 2;
	this->SetPosition(pt);
}

BEGIN_EVENT_TABLE(MainForm, wxFrame)
	EVT_BUTTON(wxID_Ping_Ctrl, MainForm::OnButtonClick)
	EVT_BUTTON(wxID_Stop_Ctrl, MainForm::OnButtonClick)
	EVT_BUTTON(wxID_Clear_Message_Ctrl, MainForm::OnButtonClick)
	EVT_RADIOBUTTON(wxID_rbGate_Ctrl, MainForm::OnRadioClick)
	EVT_RADIOBUTTON(wxID_rbData_Ctrl, MainForm::OnRadioClick)
	EVT_RADIOBUTTON(wxID_rbInteract_Ctrl, MainForm::OnRadioClick)
	EVT_RADIOBUTTON(wxID_rbWorld_Ctrl, MainForm::OnRadioClick)
	EVT_TIMER(wxID_Data_Processer_Ctrl, MainForm::OnTimer)
	EVT_SOCKET(wxID_Socket_Client_1, MainForm::OnSocketEvent)

END_EVENT_TABLE()

//全局处理函数
/*
void ProcessMsgFromGate(const MqHead& h, uint8_t* data, size_t len)
{ 
	wxGetApp().form->SetLabel(wxT("TEST"));
}
*/

void MainForm::OnButtonClick( wxCommandEvent& event )
{
	switch(event.GetId())
	{
	case wxID_Ping_Ctrl:
		{
			if (!tmPing)
			{
				tmPing = new wxTimer(this, wxID_Data_Processer_Ctrl);			
			}
			btnPing->Enable(false);
			btnStop->Show(true);
			m_ping_executed_count = 0;
			StartPing();

			break;
		}
	case wxID_Stop_Ctrl:
		{
			if (ping_client)
			{
				delete ping_client;
				ping_client = NULL;
			}
			btnStop->Show(false);
			btnPing->Enable(true);
			if (tmPing)
			{
				delete tmPing;
				tmPing = NULL;
			}
			break;
		}
	case wxID_Clear_Message_Ctrl:
		{
			txtMessage->Clear();
			break;
		}
	}


}

void MainForm::OnRadioClick( wxCommandEvent& event )
{
	switch(event.GetId())
	{
	case wxID_rbGate_Ctrl:
 
		txtPort->SetValue(wxT("15000"));
		break;
	case wxID_rbData_Ctrl:
		txtPort->SetValue(wxT("15000"));
		break;
	case wxID_rbInteract_Ctrl:
		txtPort->SetValue(wxT("15000"));
		break;
	case wxID_rbWorld_Ctrl:
 
		txtPort->SetValue(wxT("15000"));
		break;
	}

}

void MainForm::OnTimer(wxTimerEvent& event)
{
	switch(event.GetId())
	{
	case wxID_Data_Processer_Ctrl:
		{
			StartPing();
			break;
		}
	
	}
}

void MainForm::OnSocketEvent( wxSocketEvent& event )
{
	wxSocketBase* sock = event.GetSocket();
	switch(event.GetId())
	{
	case wxID_Socket_Client_1:
		{
			switch(event.GetSocketEvent())
			{
			case wxSOCKET_CONNECTION:
				{
					boost::posix_time::millisec_posix_time_system_config::time_duration_type time_elapse; 
					time_elapse = boost::posix_time::microsec_clock::local_time() - start_connect_time;
					
					int ticks = time_elapse.total_milliseconds();

					wxString s = wxT("server is connected, time = ");
					char s_ticks[64] = {0};
					sprintf(s_ticks,"%d", ticks);
					
					s += wxString::FromAscii(s_ticks) + wxT(" ms\r\n");
					txtMessage->AppendText(s);
					//发送ping数据包-----------------------
					ping_client->ping_to_gate();
					start_ping_time = boost::posix_time::microsec_clock::local_time();
					
					break;
				}
			case wxSOCKET_LOST:
				{
					btnPing->Enable(true);
					btnStop->Show(false);
					txtMessage->AppendText(wxT("\r\nserver is disconnected...\r\n"));
					break;
				}
			case wxSOCKET_INPUT:
				{
					char res[4096] = {0};
					sock->Read(res, sizeof(res));
					unsigned int count = sock->LastCount();
					Head head;
					if(count >= sizeof(Head))
					{
						memcpy(&head, res, sizeof(Head));
					}
					else
						return;
					if (head.type != PingResult::kType)
					{
						return;
					}
					

					wxString s = wxString::FromAscii(res);
					//txtMessage->AppendText(s);

					boost::posix_time::millisec_posix_time_system_config::time_duration_type time_elapse; 
					time_elapse = boost::posix_time::microsec_clock::local_time() - start_ping_time;
					int ticks = time_elapse.total_milliseconds();
					char s_ticks[64] = {0};
					sprintf(s_ticks,"%d", ticks);
					
					char s_count[64];
					sprintf(s_count, "%d", count);
					wxIPV4address addr;
					bool b = sock->GetPeer(addr);
					if (b)
					{
						txtMessage->AppendText(wxT("Reply from ") +  addr.IPAddress()+ wxT(": bytes = ") + 
							wxString::FromAscii(s_count) + wxT(" time = ") +
							wxString::FromAscii(s_ticks) + wxT("ms\r\n") ); 
					}
					
					m_ping_executed_count++;
					if (m_ping_executed_count < 3)
					{						
						if(tmPing)
						{
							tmPing->Start(1000, true);
						}

					}
					else
					{
						btnPing->Enable(true);
						btnStop->Show(false);
						
					}
						
					break;
				}
			}
			break;
		}
	}

}

void MainForm::StartPing()
{
	wxString address = txtIPAddress->GetValue();
	wxWritableCharBuffer buff = address.char_str();

	wxString wxs_port = txtPort->GetValue();
	wxWritableCharBuffer ansi_port = wxs_port.char_str();
	char* s_port = (char*)ansi_port;
	int32_t i_port = atoi(s_port);
	if (!ping_client)
	{
		ping_client = new PingClient(this);
	}
	ping_client->connect( address, i_port);			
	txtMessage->AppendText(wxT("\r\nconnecting server...\r\n"));

	start_connect_time = boost::posix_time::microsec_clock::local_time();
}

