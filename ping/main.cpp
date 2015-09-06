#include "main.h"


IMPLEMENT_APP(PingApp)

bool PingApp::OnInit()
{
	
	form = new MainForm(wxT("Ping Checker"),600,460);
	form->Show();


	return true;

}



