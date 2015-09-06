#ifndef _MAIN_H_
#define _MAIN_H_

#include <wx/app.h>
#include "MainForm.h"

class PingApp : public wxApp
{
public:
	MainForm* form;
	virtual bool OnInit();
};

DECLARE_APP(PingApp)

#endif