
// struct_producerDlg.cpp : 实现文件
//

#include "stdafx.h"
#include "struct_producer.h"
#include "struct_producerDlg.h"
#include "afxdialogex.h"
#include <sstream>

using namespace std;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// StructProducerDlg 对话框



StructProducerDlg::StructProducerDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(StructProducerDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void StructProducerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(StructProducerDlg, CDialogEx)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON1, &StructProducerDlg::OnBnClickedButton1)
END_MESSAGE_MAP()


// StructProducerDlg 消息处理程序

BOOL StructProducerDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// 设置此对话框的图标。当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);			// 设置大图标
	SetIcon(m_hIcon, FALSE);		// 设置小图标

	// TODO: 在此添加额外的初始化代码

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

// 如果向对话框添加最小化按钮，则需要下面的代码
//  来绘制该图标。对于使用文档/视图模型的 MFC 应用程序，
//  这将由框架自动完成。

void StructProducerDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标
//显示。
HCURSOR StructProducerDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}



void StructProducerDlg::OnBnClickedButton1()
{
	CString name;
	GetDlgItemText(IDC_EDIT_NAME, name);
	if(name.GetLength()>1)
	{
		if (name[0] == 'k')
		{
			name.Delete(0,1);
		}

		stringstream  ss;
		ss<< "typedef struct _" <<name <<"\r\n { \r\n \tstatic const Type kType = k" <<name<<";\r\n\r\n}"<<name<<";\r\n\r\n";
		name+="Result";
		ss<< "typedef struct _" <<name  <<"\r\n { \r\n \tstatic const Type kType = k" <<name<<";\r\n\r\n}"<<name<<";\r\n\r\n";

		GetDlgItem(IDC_EDIT_CODE)->SetWindowText(ss.str().c_str());


		if( OpenClipboard() )

		{

			HGLOBAL clipbuffer;

			char * buffer;

			EmptyClipboard();

			clipbuffer = GlobalAlloc(GMEM_DDESHARE, ss.str().length()+1);

			buffer = (char*)GlobalLock(clipbuffer);

			strcpy(buffer, ss.str().c_str());

			GlobalUnlock(clipbuffer);

			SetClipboardData(CF_TEXT,clipbuffer);

			CloseClipboard();

		}
	}
}

